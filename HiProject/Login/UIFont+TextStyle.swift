//
//  UIFont+TextStyle.swift
//  ATeen
//
//  Created by 최동호 on 5/27/24.
//

/*
 
 Text Style     기본 폰트 크기 (pt)    기본 폰트 무게
 
 largeTitle     34                  bold
 title1         28                  regular
 title2         22                  regular
 title3         20                  regular
 headline       17                  semibold
 subheadline    15                  regular
 body           17                  regular
 callout        16                  regular
 footnote       13                  regular
 caption1       12                  regular
 caption2       11                  regular
 
 */

import UIKit

extension UIFont {
    // 텍스트 스타일과 원하는 폰트 무게를 받아 폰트를 생성하는 함수
    static func customFont(forTextStyle style: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.preferredFont(forTextStyle: style)
        let fontMetrics = UIFontMetrics(forTextStyle: style)
        let descriptor = systemFont.fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight]])
        return fontMetrics.scaledFont(for: UIFont(descriptor: descriptor, size: 0))
    }
}

