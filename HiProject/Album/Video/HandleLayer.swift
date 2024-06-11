//
//  HandleLayer.swift
//  HiProject
//
//  Created by 최동호 on 6/10/24.
//

import UIKit

final class HandleLayer: CALayer {

    enum Side {
        case left
        case right
    }

    //private lazy var imageLayer: CALayer = makeImageLayer()
    private let side: Side

    init(side: Side) {
        self.side = side

        super.init()
        cornerRadius = 3.5
        backgroundColor = UIColor(named: "mainColor")?.cgColor
    }

    override init(layer: Any) {
        self.side = .left
        
        super.init(layer: layer)
    }

    override func layoutSublayers() {
        super.layoutSublayers()

        //addSublayer(imageLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    func makeImageLayer() -> CALayer {
//        let layer = CALayer()
//        layer.frame = CGRect(x: 0, y: 0, width: 6, height: 16)
//        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        layer.position = CGPoint(x: bounds.midX, y: bounds.midY)
//
//        let maskLayer = CALayer()
//        maskLayer.frame = layer.bounds
//        maskLayer.contentsGravity = .resizeAspect
//        layer.mask = maskLayer
//        layer.backgroundColor = UIColor.black.cgColor
//
//        return layer
//    }
}

extension UIColor {
    static let background = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // 1D2227
    static let foreground = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1215686275, alpha: 1) // FFFFFF
    static let border = #colorLiteral(red: 0.9490196078, green: 0.9568627451, blue: 0.9647058824, alpha: 1) // F2F4F6
    static let croppingPreset = #colorLiteral(red: 0.9490196078, green: 0.9568627451, blue: 0.9647058824, alpha: 1) // F2F4F6
    static let croppingPresetSelected = #colorLiteral(red: 0.7323174477, green: 0.7364212871, blue: 0.7465394735, alpha: 1) // F2F4F6
}
