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
    
    @Published var trimPositions: (Double, Double)


    // MARK: - Private properties
    private lazy var trimmingControlView: TrimmingControlView = TrimmingControlView(trimPositions: trimPositions)

    private var cancellables = Set<AnyCancellable>()

    private let asset: AVAsset
    private let generator: VideoTimelineGeneratorProtocol = VideoTimelineGenerator()
    
    // MARK: - Life Cycle
    init(
        asset: AVAsset,
        trimPositions: (Double, Double)) {
        self.asset = asset
        self.trimPositions = trimPositions

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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let track = asset.tracks(withMediaType: AVMediaType.video).first
        let assetSize = track!.naturalSize.applying(track!.preferredTransform)
        let ratio = abs(assetSize.width) / abs(assetSize.height)
        let bounds = trimmingControlView.bounds
        let frameWidth = bounds.height * ratio
        let count = Int(bounds.width / frameWidth) + 1
        
        generator.videoTimeline(for: asset, in: trimmingControlView.bounds, numberOfFrames: count)
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] images in
                guard let self = self else { return }
                self.updateVideoTimeline(with: images, assetAspectRatio: ratio)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helpers
    private func configUserInterface() {
        view.backgroundColor = .systemBackground
        view.addSubview(trimmingControlView)

    }
    
    private func configLayout() {
        trimmingControlView.snp.makeConstraints { make in
            make.height.equalTo(60.0)         // 높이 설정
            make.left.equalToSuperview().inset(28.0)   // 왼쪽 가장자리에 여백 설정
            make.right.equalToSuperview().inset(28.0)  // 오른쪽 가장자리에 여백 설정
            make.centerY.equalToSuperview()   // 수평 축에 맞춤
        }
    }
    
    private func setButtonActions() {
        
    }
    
    // MARK: - Actions
    
}

// MARK: - Extensions here

// MARK: Bindings
fileprivate extension TrimVideoControlViewController {
    func setupBindings() {
        trimmingControlView.$trimPositions
            .dropFirst(1)
            .assign(to: \.trimPositions, weakly: self)
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
