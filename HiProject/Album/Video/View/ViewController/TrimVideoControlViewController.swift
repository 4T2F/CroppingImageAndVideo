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
    var timeObserver: Any?
    var startTime = CMTime()
    var endTime = CMTime()
    
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
    
    private lazy var playTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .customFont(forTextStyle: .footnote, weight: .bold)
        return label
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await setPlayer()
            await setTrimTrack()
            setupBindings()
        }
    }
    
    // MARK: - Helpers
    private func configUserInterface() {
        view.backgroundColor = .black
        view.addSubview(cancelButton)
        view.addSubview(videoBackgroundView)
        view.addSubview(trimmingControlView)
        view.addSubview(playTimeLabel)
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
        
        playTimeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.trimmingControlView.snp.top).offset(-10)
            make.width.equalTo(150)
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
        var interval = CMTime()
        
        do {
            let duration = try await asset.load(.duration)
            
            interval = CMTime(seconds: 0.1, preferredTimescale: duration.timescale)
            
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
            
            playTimeLabel.text = self.viewModel.fomattingDouble(time: startTime.seconds) + " / " + self.viewModel.fomattingDouble(time: endTime.seconds)
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
                self?.playerLayer.player?.seek(to: self?.startTime ?? CMTime.zero) {_ in
                    self?.playerLayer.player?.play()
                }
            }
        }

        DispatchQueue.main.async { [weak self] in
            self?.timeObserver = self?.playerLayer.player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { time in
                Task { @MainActor in
                    self?.observeTime(time: time)
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc func didSelectCancelButton(_ sender: UIButton) {
        self.playerLayer.player = nil
        if let timeObserver = timeObserver {
            self.playerLayer.player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        self.navigationController?.popViewController(animated: false)
    }
    
    @MainActor
    func observeTime(time: CMTime) {
        viewModel.playheadProgress = time
    }
}

// MARK: - Extensions here

// MARK: Bindings
fileprivate extension TrimVideoControlViewController {
    func setupBindings() {
        viewModel.$trimPositions
            .dropFirst(1)
            .sink { [weak self] _ in
                Task {
                    await self?.setPlayer()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$playheadProgress
            .sink { [weak self] time in
                if self?.endTime.seconds ?? 1 <= time.seconds {
                    self?.playerLayer.player?.pause()
                } else {
                    self?.playTimeLabel.text = (self?.viewModel.fomattingDouble(time: time.seconds) ?? "00:00") + " / " + (self?.viewModel.fomattingDouble(time: self?.endTime.seconds ?? 0) ?? "00:00")
                    
                    self?.trimmingControlView.internalPlayHeadProgressValue = (time.seconds - (self?.startTime.seconds ?? 0)) / ((self?.endTime.seconds ?? 1) - (self?.startTime.seconds ?? 0))
                }
                
            }
            .store(in: &cancellables)
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
