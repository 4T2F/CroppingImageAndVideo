//
//  VideoTimeLineView.swift
//  HiProject
//
//  Created by 최동호 on 6/10/24.
//

import SnapKit

import UIKit

final class VideoTimelineView: UIView {

    // MARK: Init
    init() {
        super.init(frame: .zero)
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VideoTimelineView {
    func configure(with frames: [CGImage], assetAspectRatio: CGFloat) {
        subviews.forEach { $0.removeFromSuperview() }
        
        let width = bounds.height * assetAspectRatio

        frames.enumerated().forEach {
            let imageView = UIImageView()
            imageView.image = UIImage(cgImage: $0.1, scale: 1.0, orientation: .up)
            addSubview(imageView)
            
            imageView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.height.equalTo(self)      // 높이 매칭
                make.width.equalTo(width)      // 너비 설정
            }

            if $0.0 == 0 {
                imageView.snp.makeConstraints { make in
                    make.left.equalToSuperview() // 왼쪽 고정
                }
            } else {
                let previousImageView = subviews[$0.0 - 1]
                imageView.snp.makeConstraints { make in
                    make.left.equalTo(previousImageView.snp.right) // 이전 이미지뷰의 오른쪽에 위치
                }
            }
        }
    }
}
