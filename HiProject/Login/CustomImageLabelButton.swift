//
//  CustomImageLabelButton.swift
//  ATeen
//
//  Created by phang on 5/25/24.
//

import UIKit

// MARK: - 이미지 와 라벨이 하나씩 존재하는 버튼
class CustomImageLabelButton: UIButton {
    // MARK: - Public properties
    var imageName: String
    var imageColor: UIColor?
    var textColor: UIColor
    var labelText: String
    var buttonBackgroundColor: UIColor
    var labelFont: UIFont
    
    lazy var customImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        if let imageColor = imageColor {
            imageView.tintColor = imageColor
        }
        return imageView
    }()
    
    lazy var customLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = labelText
        label.textColor = textColor
        label.font = labelFont
        return label
    }()
    
    // MARK: - Life Cycle
    init(
        imageName: String,
        imageColor: UIColor?,
        textColor: UIColor,
        labelText: String,
        buttonBackgroundColor: UIColor,
        labelFont: UIFont,
        frame: CGRect
    ) {
        self.imageName = imageName
        self.imageColor = imageColor
        self.textColor = textColor
        self.labelText = labelText
        self.buttonBackgroundColor = buttonBackgroundColor
        self.labelFont = labelFont
        
        super.init(frame: frame)

        configuration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    func configuration() {
        self.backgroundColor = self.buttonBackgroundColor
        self.addSubview(customImageView)
        self.addSubview(customLabel)
    }
}
