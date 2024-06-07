//
//  CustomBirthButton.swift
//  ATeen
//
//  Created by 노주영 on 5/28/24.
//

import SnapKit

import UIKit

final class CustomBirthButton: CustomImageLabelButton {
    
    private var customLabelWidthAnchor: Constraint?
    
    override init(
        imageName: String,
        imageColor: UIColor?,
        textColor: UIColor,
        labelText: String,
        buttonBackgroundColor: UIColor,
        labelFont: UIFont,
        frame: CGRect
    ) {
        super.init(
            imageName: imageName,
            imageColor: imageColor,
            textColor: textColor,
            labelText: labelText,
            buttonBackgroundColor: buttonBackgroundColor,
            labelFont: labelFont,
            frame: frame
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeWidth(year: String, month: String, day: String) {
        let text = year + "년 " + month + "월 " + day + "일"
        
        //value로 사용할 내가 적용하고싶은 폰트 사이즈 객체 생성
        let fontSize = UIFont.customFont(forTextStyle: .callout, weight: .bold)

        //NSMutableAttributedString객체를 생성한다.(label에 있는 Text를 이용한다.)
        let attributedStr = NSMutableAttributedString(
            string: text)

        //위에서 만든 attributedStr에, addAttribute()메소드를 통해 스타일 적용.
        attributedStr.addAttribute(.font, value: fontSize, range: (text as NSString).range(of: year))
        attributedStr.addAttribute(.font, value: fontSize, range: (text as NSString).range(of: month))
        attributedStr.addAttribute(.font, value: fontSize, range: (text as NSString).range(of: day))
                
        //최종적으로 내 label에 text가 아닌, attributedText를 적용
        self.customLabel.attributedText = attributedStr
        
        self.customLabel.sizeToFit()
        
//        self.customLabelWidthAnchor?.update(
//            offset: (self.customLabel.attributedText as NSString).size(withAttributes: [NSAttributedString.Key.font: self.customLabel.attributedText]).width + 10)
    }
}

// MARK: - Layout
extension CustomBirthButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        customLabel.textAlignment = .left
        customLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
//            self.customLabelWidthAnchor = make.width.equalTo(
//                (self.customLabel.text! as NSString).size(withAttributes: [NSAttributedString.Key.font: self.customLabel.font!]).width + 10).constraint
        }
        
        customImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(self.customLabel.snp.trailing).offset(5)
            make.width.height.equalTo(ViewValues.defaultButtonSize)
        }
    }
}



