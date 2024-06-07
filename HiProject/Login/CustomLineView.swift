//
//  CustomLineView.swift
//  HiProject
//
//  Created by 노주영 on 5/28/24.
//

import SnapKit

import UIKit

final class CustomLineView: UIView {
    
    lazy var firstColorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "mainColor")
        return view
    }()
    
    lazy var secondColorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "mainColor")
        return view
    }()
    
    lazy var thirdColorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "mainColor")
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(secondColorLineView)
        self.addSubview(firstColorLineView)
        self.addSubview(thirdColorLineView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension CustomLineView {
    override func layoutSubviews() {
        super.layoutSubviews()
        secondColorLineView.snp.makeConstraints { make in
            make.centerX.top.bottom.equalToSuperview()
            make.width.equalTo(ViewValues.componentPickerWidth)
        }
        
        firstColorLineView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(self.secondColorLineView.snp.leading).offset(-10)
        }
        
        thirdColorLineView.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.leading.equalTo(self.secondColorLineView.snp.trailing).offset(10)
        }
    }
}



