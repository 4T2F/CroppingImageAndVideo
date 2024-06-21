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
    let playerController = AVPlayerViewController()
    var trimmer = VideoTrimmer()
    
    // MARK: - Private properties
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didSelectCancelButton(_:)), for: .touchUpInside)
        return button
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
    private var wasPlaying = false
    private var player: AVPlayer! {playerController.player}
    private let asset: AVAsset?
    
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
        setAssets()
    }
    
    // MARK: - Helpers
    private func configUserInterface() {
        view.backgroundColor = .black
        view.addSubview(cancelButton)
        playerController.player = AVPlayer()
        addChild(playerController)
        view.addSubview(playerController.view)
        
        trimmer.minimumDuration = CMTime(seconds: 1, preferredTimescale: 600)
        trimmer.addTarget(self, action: #selector(didBeginTrimming(_:)), for: VideoTrimmer.didBeginTrimming)
        trimmer.addTarget(self, action: #selector(didEndTrimming(_:)), for: VideoTrimmer.didEndTrimming)
        trimmer.addTarget(self, action: #selector(selectedRangeDidChanged(_:)), for: VideoTrimmer.selectedRangeChanged)
        trimmer.addTarget(self, action: #selector(didBeginScrubbing(_:)), for: VideoTrimmer.didBeginScrubbing)
        trimmer.addTarget(self, action: #selector(didEndScrubbing(_:)), for: VideoTrimmer.didEndScrubbing)
        trimmer.addTarget(self, action: #selector(progressDidChanged(_:)), for: VideoTrimmer.progressChanged)
        view.addSubview(trimmer)
        view.addSubview(trimmingStackView)
        
    }
    
    private func configLayout() {
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
        }
        
        playerController.view.snp.makeConstraints { make in
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
            make.top.equalTo(playerController.view.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
    }
    
    private func setAssets() {
        trimmer.asset = asset
        
        updatePlayerAsset()
        
        playerController.player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 30), queue: .main) { [weak self] time in
            guard let self = self else { return }
            let finalTime = self.trimmer.trimmingState == .none ? CMTimeAdd(time, self.trimmer.selectedRange.start) : time
            self.trimmer.progress = finalTime
        }
        updateLabels()
    }
    
    // MARK: - Helpers
    private func updateLabels() {
        leadingTrimLabel.text = trimmer.selectedRange.start.displayString
        trailingTrimLabel.text = trimmer.selectedRange.end.displayString
    }
    
    private func updatePlayerAsset() {
        guard let asset = asset else { return }
        let outputRange = trimmer.trimmingState == .none ? trimmer.selectedRange : asset.fullRange
        let trimmedAsset = asset.trimmedComposition(outputRange)
        if trimmedAsset != player.currentItem?.asset {
            player.replaceCurrentItem(with: AVPlayerItem(asset: trimmedAsset))
        }
    }
    // MARK: - Input
    @objc private func didBeginTrimming(_ sender: VideoTrimmer) {
        updateLabels()
        
        wasPlaying = (player.timeControlStatus != .paused)
        player.pause()
        
        updatePlayerAsset()
    }
    
    @objc private func didEndTrimming(_ sender: VideoTrimmer) {
        updateLabels()
        
        if wasPlaying == true {
            player.play()
        }
        
        updatePlayerAsset()
    }
    
    @objc private func selectedRangeDidChanged(_ sender: VideoTrimmer) {
        updateLabels()
    }
    
    @objc private func didBeginScrubbing(_ sender: VideoTrimmer) {
        updateLabels()
        
        wasPlaying = (player.timeControlStatus != .paused)
        player.pause()
    }
    
    @objc private func didEndScrubbing(_ sender: VideoTrimmer) {
        updateLabels()
        
        if wasPlaying == true {
            player.play()
        }
    }
    
    @objc private func progressDidChanged(_ sender: VideoTrimmer) {
        updateLabels()
        
        let time = CMTimeSubtract(trimmer.progress, trimmer.selectedRange.start)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    // MARK: - Actions
    @objc func didSelectCancelButton(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: false)
    }
    
}

// MARK: - Extensions here
