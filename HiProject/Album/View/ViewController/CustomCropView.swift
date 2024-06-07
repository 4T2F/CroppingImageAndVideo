//
//  CustomCropView.swift
//  HiProject
//
//  Created by 노주영 on 6/7/24.
//

import SnapKit

import UIKit

final class CustomCropView: UIView {
    let imageSize: CGSize
    
    private lazy var firstLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var secondLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var thirdLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var fourthLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    init(frame: CGRect, imageSize: CGSize) {
        self.imageSize = imageSize
        super.init(frame: frame)
        
        self.linesChangeState(isCropping: false)
        
        self.addSubview(firstLineView)
        self.addSubview(secondLineView)
        self.addSubview(thirdLineView)
        self.addSubview(fourthLineView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func linesChangeState(isCropping: Bool) {
        if isCropping {
            UIView.animate(withDuration: 0.2, delay: 0) {
                self.firstLineView.isHidden = false
                self.secondLineView.isHidden = false
                self.thirdLineView.isHidden = false
                self.fourthLineView.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.2, delay: 0) {
                self.firstLineView.isHidden = true
                self.secondLineView.isHidden = true
                self.thirdLineView.isHidden = true
                self.fourthLineView.isHidden = true
            }
        }
    }
}

// MARK: - Layout
extension CustomCropView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        firstLineView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
            
            if imageSize.height < 500 {
                make.top.equalToSuperview().offset(imageSize.height / 3)
            } else {
                make.top.equalToSuperview().offset(500 / 3)
            }
        }
        
        secondLineView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
            
            if imageSize.height < 500 {
                make.top.equalTo(self.firstLineView.snp.centerY).offset(imageSize.height / 3)
            } else {
                make.top.equalTo(self.firstLineView.snp.centerY).offset(500 / 3)
            }
        }
        
        thirdLineView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(0.5)
            
            if imageSize.height < 500 {
                make.leading.equalToSuperview().offset(imageSize.height / 1.16 / 3)
            } else {
                if imageSize.width < ViewValues.width {
                    make.leading.equalToSuperview().offset(imageSize.width / 3)
                } else {
                    make.leading.equalToSuperview().offset(ViewValues.width / 3)
                }
            }
        }
        
        fourthLineView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(0.5)
            
            if imageSize.height < 500 {
                make.trailing.equalToSuperview().offset(-imageSize.height / 1.16 / 3)
            } else {
                if imageSize.width < ViewValues.width {
                    make.trailing.equalToSuperview().offset(-imageSize.width / 3)
                } else {
                    make.trailing.equalToSuperview().offset(-ViewValues.width / 3)
                }
            }
        }
    }
}




