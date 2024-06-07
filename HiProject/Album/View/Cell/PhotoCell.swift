//
//  PhotoCell.swift
//  HiProject
//
//  Created by 노주영 on 5/29/24.
//

import AVKit
import AVFoundation
import Photos

import UIKit

final class PhotoCell: UICollectionViewCell {
    static let id = "PhotoCell"
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var videoBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.layer.addSublayer(playerLayer)
        return view
    }()
    
    private lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer()
        let width = (UIScreen.main.bounds.width - 48) / 2
        playerLayer.frame = CGRect(x: 0, y: 0, width: width, height: width)
        playerLayer.videoGravity = .resizeAspectFill
        return playerLayer
    }()
    
    // MARK: Initializer
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 20
        
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
//        contentView.addSubview(videoBackgroundView)
//        
//        videoBackgroundView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
    }
    
    func setImage(info: AssetInfo) {
        imageView.image = info.image
    }
    
//    func setPlayer(info: VideoCellInfo?) {
//        guard let info = info else { return }
//        dump(info.avAsset)
//        let playerItem = AVPlayerItem(asset: info.avAsset)
//        let player = AVPlayer(playerItem: playerItem)
//        playerLayer.player = player
//        // 메인 스레드에서 플레이어 재생 시작
//        DispatchQueue.main.async { [weak self] in
//            self?.playerLayer.player?.play()
//        }
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        // 플레이어 정지 및 초기화
//        playerLayer.player?.pause()
//        playerLayer.player?.replaceCurrentItem(with: nil)
//    }
}
