//
//  TrimVideoControlViewController.swift
//  HiProject
//
//  Created by 최동호 on 6/10/24.
//

import SnapKit

import AVKit
import UIKit

extension CMTime {
    var displayString: String {
        let offset = TimeInterval(seconds)
        
        let numberOfNanosecondsFloat = (offset - TimeInterval(Int(offset))) * 1000.0
        let nanoseconds = Int(numberOfNanosecondsFloat)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        
        var formattedString = formatter.string(from: offset) ?? "00:00"
        formattedString += String(format: ".%02d",
                                  nanoseconds).prefix(3) // .을 포함 3개 -> 소수점 2자리까지
        return formattedString
    }
}

extension AVAsset {
    var fullRange: CMTimeRange {
        return CMTimeRange(start: .zero, duration: duration)
    }
    func trimmedComposition(_ range: CMTimeRange) -> AVAsset {
        guard CMTimeRangeEqual(fullRange, range) == false else {return self}
        
        let composition = AVMutableComposition()
        try? composition.insertTimeRange(range, of: self, at: .zero)
        
        if let videoTrack = tracks(withMediaType: .video).first {
            composition.tracks.forEach {$0.preferredTransform = videoTrack.preferredTransform}
        }
        return composition
    }
}

final class TrimVideoControlViewController: UIViewController {
    // MARK: - Public properties
    
    // MARK: - Private properties
    private let asset: AVAsset?
    
    private var timeObserverToken: Any?
    
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
    
    private lazy var leadingTrimLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private lazy var slash: UILabel = {
        let label = UILabel()
        label.text = "/"
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var trailingTrimLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    private lazy var trimmingStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [leadingTrimLabel, slash, trailingTrimLabel])
        stackView.alignment = .fill
        stackView.spacing = UIStackView.spacingUseSystem
        return stackView
    }()
    
    private lazy var trimmer: VideoTrimmer = {
        let trimmer = VideoTrimmer()
        trimmer.minimumDuration = CMTime(seconds: 1, preferredTimescale: 600)
        trimmer.addTarget(self, action: #selector(didBeginTrimming(_:)), for: VideoTrimmer.didBeginTrimming)
        trimmer.addTarget(self, action: #selector(didEndTrimming(_:)), for: VideoTrimmer.didEndTrimming)
        trimmer.addTarget(self, action: #selector(selectedRangeDidChanged(_:)), for: VideoTrimmer.selectedRangeChanged)
        trimmer.addTarget(self, action: #selector(didBeginScrubbing(_:)), for: VideoTrimmer.didBeginScrubbing)
        trimmer.addTarget(self, action: #selector(didEndScrubbing(_:)), for: VideoTrimmer.didEndScrubbing)
        trimmer.addTarget(self, action: #selector(progressDidChanged(_:)), for: VideoTrimmer.progressChanged)
        return trimmer
    }()
    
    // MARK: - Life Cycle
    init(asset: AVAsset) {
        self.asset = asset
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        removePlayerObservers()
        playerLayer.player = nil
        trimmer.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUserInterface()
        configLayout()
        setAssets()
    }
    
    // MARK: - Helpers
    private func configUserInterface() {
        view.backgroundColor = .black
        view.addSubview(cancelButton)
        view.addSubview(videoBackgroundView)
        view.addSubview(trimmer)
        view.addSubview(trimmingStackView)
    }
    
    private func configLayout() {
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
        }
        
        videoBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(view.safeAreaLayoutGuide.snp.width)
        }
        
        trimmer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-70)
            make.height.equalTo(50)
        }
        
        trimmingStackView.snp.makeConstraints { make in
            make.bottom.equalTo(trimmer.snp.top).offset(-16)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setAssets() {
        trimmer.asset = asset
        
        updatePlayerAsset()
        updateTrimLabel()
        
        // 동영상의 프레임 속도
        let nominalFrameRate = asset?.tracks(withMediaType: .video).first?.nominalFrameRate ?? 30
        let interval = CMTime(seconds: 1 / Double(nominalFrameRate), preferredTimescale: 600)
        
        self.timeObserverToken = playerLayer.player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            
            self.trimmer.progress = CMTimeAdd(self.trimmer.progress, interval)
            
            if self.trimmer.progress <= self.trimmer.selectedRange.end {
                leadingTrimLabel.text = self.trimmer.progress.displayString
            } else {
                playerLayer.player?.pause()
                leadingTrimLabel.text = self.trimmer.selectedRange.end.displayString
            }
        }
    }
    
    private func updateTrimLabel() {
        leadingTrimLabel.text = trimmer.selectedRange.start.displayString
        trailingTrimLabel.text = trimmer.selectedRange.end.displayString
    }
    
    private func updateScrubbingLabel(state: String) {
        let time = CMTimeSubtract(trimmer.progress, trimmer.selectedRange.start)
        leadingTrimLabel.text = time.displayString
        
        switch state {
        case "begin":
            playerLayer.player?.pause()
        case "change":
            playerLayer.player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        default:
            break
        }
    }
    
    private func updatePlayerAsset() {
        guard let asset = asset else { return }
        
        let outputRange = trimmer.trimmingState == .none ? trimmer.selectedRange : asset.fullRange
        let trimmedAsset = asset.trimmedComposition(outputRange)
        let time = trimmer.selectedRange.start
        trimmer.progress = time
        
        if trimmedAsset != playerLayer.player?.currentItem?.asset {
            if playerLayer.player == nil {
                playerLayer.player = AVPlayer(playerItem: AVPlayerItem(asset: trimmedAsset))
                playerLayer.player?.play()
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.playerLayer.player?.seek(
                        to: time,
                        toleranceBefore: .zero,
                        toleranceAfter: .zero,
                        completionHandler: { _ in
                            self?.playerLayer.player?.play()
                        })
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.playerLayer.player?.seek(
                    to: time,
                    toleranceBefore: .zero,
                    toleranceAfter: .zero,
                    completionHandler: { _ in
                        self?.playerLayer.player?.play()
                    })
            }
        }
    }
    
    private func removePlayerObservers() {
        if let token = timeObserverToken {
            playerLayer.player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    // MARK: - Action
    @objc private func didBeginTrimming(_ sender: VideoTrimmer) {
        updateTrimLabel()
        updatePlayerAsset()
    }
    
    @objc private func didEndTrimming(_ sender: VideoTrimmer) {
        updateTrimLabel()
        updatePlayerAsset()
    }
    
    @objc private func selectedRangeDidChanged(_ sender: VideoTrimmer) {
        playerLayer.player?.pause()
        updateTrimLabel()
    }
    
    @objc private func didBeginScrubbing(_ sender: VideoTrimmer) {
        updateScrubbingLabel(state: "begin")
    }
    
    @objc private func didEndScrubbing(_ sender: VideoTrimmer) {
        self.playerLayer.player?.play()
    }
    
    @objc private func progressDidChanged(_ sender: VideoTrimmer) {
        updateScrubbingLabel(state: "change")
    }
    
    @objc func didSelectCancelButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
}
