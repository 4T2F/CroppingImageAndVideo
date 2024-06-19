//
//  VideoTrimViewController.swift
//  HiProject
//
//  Created by 최동호 on 6/19/24.
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
        return String(format: "%@.%03d", formatter.string(from: offset) ?? "00:00", nanoseconds)
    }
}

extension AVAsset {
    var fullRange: CMTimeRange {
        Task {
            do {
                return CMTimeRange(start: .zero, duration: try await load(.duration))
            } catch {
                return CMTimeRange(start: .zero, duration: CMTime(seconds: 0, preferredTimescale: .zero))
            }
        }
        return CMTimeRange(start: .zero, duration: CMTime(seconds: 0, preferredTimescale: .zero))
    }
    
    func trimmedComposition(_ range: CMTimeRange) async throws -> AVAsset {
        guard CMTimeRangeEqual(fullRange, range) == false else {return self}
        
        let composition = AVMutableComposition()
        
        do {
            try await composition.insertTimeRange(range, of: self, at: .zero)
            
            if let videoTrack = try await loadTracks(withMediaType: .video).first {
                for i in composition.tracks {
                    i.preferredTransform = try await videoTrack.load(.preferredTransform)
                }
            }
        } catch {
            print("이게 맞나")
        }
        return composition
    }
}

final class VideoTrimViewController: UIViewController {
    // MARK: - Public properties
    let playerController = AVPlayerViewController()
    
    var trimmer: VideoTrimmer!
    var timingStackView: UIStackView!
    var leadingTrimLabel: UILabel!
    var currentTimeLabel: UILabel!
    var trailingTrimLabel: UILabel!
    
    // MARK: - Private properties
    private var wasPlaying = false
    private var player: AVPlayer! {playerController.player}
    private var asset: AVAsset?
    
    // MARK: - Life Cycle
    
    init(asset: AVAsset) {
        self.asset = asset
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        
        asset = AVURLAsset(url: Bundle.main.resourceURL!.appendingPathComponent("SampleVideo.mp4"), options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        
        playerController.player = AVPlayer()
        addChild(playerController)
        view.addSubview(playerController.view)
        playerController.view.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(view.safeAreaLayoutGuide.snp.width).multipliedBy(720.0 / 1280.0)
        }
        
        // 비디오 트리머 설정
        trimmer = VideoTrimmer()
        trimmer.minimumDuration = CMTime(seconds: 1, preferredTimescale: 600)
        trimmer.addTarget(self, action: #selector(didBeginTrimming(_:)), for: VideoTrimmer.didBeginTrimming)
        trimmer.addTarget(self, action: #selector(didEndTrimming(_:)), for: VideoTrimmer.didEndTrimming)
        trimmer.addTarget(self, action: #selector(selectedRangeDidChanged(_:)), for: VideoTrimmer.selectedRangeChanged)
        trimmer.addTarget(self, action: #selector(didBeginScrubbing(_:)), for: VideoTrimmer.didBeginScrubbing)
        trimmer.addTarget(self, action: #selector(didEndScrubbing(_:)), for: VideoTrimmer.didEndScrubbing)
        trimmer.addTarget(self, action: #selector(progressDidChanged(_:)), for: VideoTrimmer.progressChanged)
        view.addSubview(trimmer)
        trimmer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(playerController.view.snp.bottom).offset(16)
            make.height.equalTo(50)
        }
        
        leadingTrimLabel = UILabel()
        leadingTrimLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        leadingTrimLabel.textAlignment = .left
        
        currentTimeLabel = UILabel()
        currentTimeLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        currentTimeLabel.textAlignment = .center
        
        trailingTrimLabel = UILabel()
        trailingTrimLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        trailingTrimLabel.textAlignment = .right
        
        timingStackView = UIStackView(arrangedSubviews: [leadingTrimLabel, currentTimeLabel, trailingTrimLabel])
        timingStackView.axis = .horizontal
        timingStackView.alignment = .fill
        timingStackView.distribution = .fillEqually
        timingStackView.spacing = UIStackView.spacingUseSystem
        view.addSubview(timingStackView)
        timingStackView.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.top.equalTo(trimmer.snp.bottom).offset(8)
        }
        
        trimmer.asset = asset
        Task {
            await updatePlayerAsset()
            
        }
        player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 30), queue: .main) { [weak self] time in
            guard let self = self else { return }
            let finalTime = self.trimmer.trimmingState == .none ? CMTimeAdd(time, self.trimmer.selectedRange.start) : time
            self.trimmer.progress = finalTime
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLabels()
    }
    
    // MARK: - Input
    @objc private func didBeginTrimming(_ sender: VideoTrimmer) async {
        updateLabels()
        
        wasPlaying = (player.timeControlStatus != .paused)
        player.pause()
        
        await updatePlayerAsset()
    }
    
    @objc private func didEndTrimming(_ sender: VideoTrimmer) async {
        updateLabels()
        
        if wasPlaying == true {
            player.play()
        }
        
        await updatePlayerAsset()
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
    
    private func updateLabels() {
        leadingTrimLabel.text = trimmer.selectedRange.start.displayString
        currentTimeLabel.text = trimmer.progress.displayString
        trailingTrimLabel.text = trimmer.selectedRange.end.displayString
    }
    
    private func updatePlayerAsset() async {
        let outputRange = trimmer.trimmingState == .none ? trimmer.selectedRange : asset?.fullRange
        do {
            let trimmedAsset = try await asset?.trimmedComposition(outputRange!)
            if trimmedAsset != player.currentItem?.asset {
                player.replaceCurrentItem(with: AVPlayerItem(asset: trimmedAsset!))
            }
        } catch {
            print("update 실패")
        }
    }
    
    
    // MARK: - Actions
    
}

// MARK: - Extensions here
