//
//  TrimVideoControlViewController.swift
//  HiProject
//
//  Created by 최동호 on 6/10/24.
//

import SnapKit

import AVFoundation
import Combine
import UIKit

final class TrimVideoControlViewController: UIViewController {
    // MARK: - Public properties
    var viewModel = TrimVideoControlViewModel()
    
    // MARK: - Private properties
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didSelectCancelButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var videoBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.addSublayer(playerLayer)
        return view
    }()
    
    private lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer()
        let size = CGSize(width: ViewValues.width, height: ViewValues.height / 2)
        playerLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        playerLayer.videoGravity = .resizeAspect
        return playerLayer
    }()
    
    private lazy var trimmingControlView: TrimmingControlView = TrimmingControlView(viewModel: viewModel)
    private var cancellables = Set<AnyCancellable>()
    
    private let asset: AVAsset
    private let generator = VideoTimelineGenerator()
    
    // MARK: - Life Cycle
    init(
        asset: AVAsset
    ) {
        self.asset = asset
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUserInterface()
        configLayout()
        setButtonActions()
        setupBindings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        Task {
            await setPlayer()
            await setTrimTrack()
        }
    }
    
    // MARK: - Helpers
    private func configUserInterface() {
        view.backgroundColor = .black
        view.addSubview(cancelButton)
        view.addSubview(videoBackgroundView)
        view.addSubview(trimmingControlView)
    }
    
    private func configLayout() {
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
        }
        
        videoBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.cancelButton.snp.bottom).offset(50)
        }
        
        trimmingControlView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-80)
            make.height.equalTo(60)
        }
    }
    
    private func setButtonActions() {
        
    }
    
    private func setTrimTrack() async {
        do {
            guard let track = try await asset.loadTracks(withMediaType: .video).first else { return }
            let assetSize = try await track.load(.naturalSize).applying(track.load(.preferredTransform))
            let ratio = abs(assetSize.width) / abs(assetSize.height)
            let bounds = trimmingControlView.bounds
            let frameWidth = bounds.height * ratio / 2
            let count = Int(bounds.width / frameWidth * 2) + 1

            await generator.videoTimeline(for: asset, in: trimmingControlView.bounds, numberOfFrames: count)
                .replaceError(with: [])
                .receive(on: DispatchQueue.main)
                .sink { [weak self] images in
                    guard let self = self else { return }
                    self.updateVideoTimeline(with: images, assetAspectRatio: ratio)
                }
                .store(in: &cancellables)
        } catch let error {
            print("trimTrack Error: \(error)")
        }
    }
    
    private func setPlayer() async {
        let composition = AVMutableComposition()
        var startTime = CMTime()
        var endTime = CMTime()
        
        do {
            let duration = try await asset.load(.duration)
            
            startTime = CMTime(
                seconds: duration.seconds * viewModel.trimPositions.0,
                preferredTimescale: duration.timescale)
            endTime = CMTime(
                seconds: duration.seconds * viewModel.trimPositions.1,
                preferredTimescale: duration.timescale)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            let videoTrackComposition = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            let audioTrackComposition = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            try await videoTrackComposition?.insertTimeRange(
                timeRange,
                of: try asset.loadTracks(withMediaType: .video)[0],
                at: .zero)
            
            if let audioTrack = try await asset.loadTracks(withMediaType: .audio).first {
                try audioTrackComposition?.insertTimeRange(timeRange, of: audioTrack, at: .zero)
            } else {
                audioTrackComposition?.insertEmptyTimeRange(CMTimeRangeMake(start: .zero, duration: duration))
            }
        } catch let error {
            print("에러: \(error)")
        }
        
        if playerLayer.player == nil {
            let playerItem = AVPlayerItem(asset: composition)
            let player = AVPlayer(playerItem: playerItem)
            playerLayer.player = player
            // 메인 스레드에서 플레이어 재생 시작
            DispatchQueue.main.async { [weak self] in
                self?.playerLayer.player?.play()
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.playerLayer.player?.seek(to: startTime) {_ in
                    self?.playerLayer.player?.play()
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc func didSelectCancelButton(_ sender: UIButton) {
        self.playerLayer.player?.pause()
        self.navigationController?.popViewController(animated: false)
    }
}

// MARK: - Extensions here

// MARK: Bindings
fileprivate extension TrimVideoControlViewController {
    func setupBindings() {
        viewModel.$trimPositions
            .dropFirst(1)
            .sink { _ in
                Task {
                    await self.setPlayer()
                }
            }
            .store(in: &cancellables)
        //        trimmingControlView.$trimPositions
        //            .dropFirst(1)
        //            .assign(to: \.trimPositions, weakly: self)
        //            .store(in: &cancellables)
    }
    
    func updateVideoTimeline(with images: [CGImage], assetAspectRatio: CGFloat) {
        guard !trimmingControlView.isConfigured else { return }
        guard !images.isEmpty else { return }
        
        trimmingControlView.configure(with: images, assetAspectRatio: assetAspectRatio)
    }
}


extension Publisher where Self.Failure == Never {
    func assign<Root: AnyObject>(
        to keyPath: WritableKeyPath<Root, Self.Output>, weakly object: Root) -> AnyCancellable {
            sink { [weak object] (output) in
                object?[keyPath: keyPath] = output
            }
        }
}
