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
    func fullRange() async throws -> CMTimeRange {
        let duration = try await load(.duration)
        return CMTimeRange(start: .zero, duration: duration)
    }

    func trimmedComposition(_ range: CMTimeRange) async throws -> AVAsset {
        let fullRange = try await fullRange()
        guard CMTimeRangeEqual(fullRange, range) == false else { return self }

        let composition = AVMutableComposition()
        try await composition.insertTimeRange(range, of: self, at: .zero)

        let videoTracks = try await loadTracks(withMediaType: .video)
        if let videoTrack = videoTracks.first {
            let preferredTransform = try await videoTrack.load(.preferredTransform)
            composition.tracks.forEach { $0.preferredTransform = preferredTransform }
        }
        return composition
    }
}

final class VideoTrimViewController: UIViewController {

    let playerController = AVPlayerViewController()
    var trimmer: VideoTrimmer!
    var timingStackView: UIStackView!
    var leadingTrimLabel: UILabel!
    var currentTimeLabel: UILabel!
    var trailingTrimLabel: UILabel!

    private var wasPlaying = false
    private var player: AVPlayer! {playerController.player}
    private var asset: AVAsset?

    init(asset: AVAsset) {
        self.asset = asset
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Input
    @objc private func didBeginTrimming(_ sender: VideoTrimmer) {
          updateLabels()

          wasPlaying = (player.timeControlStatus != .paused)
          player.pause()

          Task {
              do {
                  try await updatePlayerAsset()
              } catch {
                  print("player asset 업데이트 실패: \(error)")
              }
          }
      }


    @objc private func didEndTrimming(_ sender: VideoTrimmer) {
        updateLabels()

        if wasPlaying == true {
            player.play()
        }

        Task {
            do {
                try await updatePlayerAsset()
            } catch {
                print("player asset 업데이트 실패: \(error)")
            }
        }
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

    // MARK: - Private
    private func updateLabels() {
        leadingTrimLabel.text = trimmer.selectedRange.start.displayString
        currentTimeLabel.text = trimmer.progress.displayString
        trailingTrimLabel.text = trimmer.selectedRange.end.displayString
    }
    
    func updatePlayerAsset() async throws {
        let outputRange: CMTimeRange
        
        guard let avasset = asset else { return }
        
        if trimmer.trimmingState == .none {
            outputRange = trimmer.selectedRange
        } else {
            outputRange = try await avasset.fullRange()
        }
        
        let trimmedAsset = try await avasset.trimmedComposition(outputRange)
        if trimmedAsset != player.currentItem?.asset {
            player.replaceCurrentItem(with: AVPlayerItem(asset: trimmedAsset))
        }
    }


    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGroupedBackground

        asset = AVURLAsset(url: Bundle.main.resourceURL!.appendingPathComponent("SampleVideo.mp4"), options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])

        playerController.player = AVPlayer()
        addChild(playerController)
        view.addSubview(playerController.view)
        playerController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerController.view.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 720 / 1280)
        ])


        // THIS IS WHERE WE SETUP THE VIDEOTRIMMER:
        trimmer = VideoTrimmer()
        trimmer.minimumDuration = CMTime(seconds: 1, preferredTimescale: 600)
        trimmer.addTarget(self, action: #selector(didBeginTrimming(_:)), for: VideoTrimmer.didBeginTrimming)
        trimmer.addTarget(self, action: #selector(didEndTrimming(_:)), for: VideoTrimmer.didEndTrimming)
        trimmer.addTarget(self, action: #selector(selectedRangeDidChanged(_:)), for: VideoTrimmer.selectedRangeChanged)
        trimmer.addTarget(self, action: #selector(didBeginScrubbing(_:)), for: VideoTrimmer.didBeginScrubbing)
        trimmer.addTarget(self, action: #selector(didEndScrubbing(_:)), for: VideoTrimmer.didEndScrubbing)
        trimmer.addTarget(self, action: #selector(progressDidChanged(_:)), for: VideoTrimmer.progressChanged)
        view.addSubview(trimmer)
        trimmer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trimmer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trimmer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            trimmer.topAnchor.constraint(equalTo: playerController.view.bottomAnchor, constant: 16),
            trimmer.heightAnchor.constraint(equalToConstant: 50),
        ])

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
        timingStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timingStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            timingStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            timingStackView.topAnchor.constraint(equalTo: trimmer.bottomAnchor, constant: 8),
        ])

        trimmer.asset = asset
     
        Task {
            do {
                try await updatePlayerAsset()
                updateLabels()
            } catch {
                print("player asset 업데이트 실패: \(error)")
            }
        }
        
        player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 30), queue: .main) { [weak self] time in
            guard let self = self else {return}
 
            let finalTime = self.trimmer.trimmingState == .none ? CMTimeAdd(time, self.trimmer.selectedRange.start) : time
            self.trimmer.progress = finalTime
        }
        
      
    }
}

