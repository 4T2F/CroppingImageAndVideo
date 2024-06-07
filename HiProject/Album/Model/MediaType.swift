//
//  MediaType.swift
//  HiProject
//
//  Created by 노주영 on 5/29/24.
//

enum MediaType {
    case image
    case video
    
    var title: String {
        switch self {
        case .image:
            return "이미지"
        case .video:
            return "비디오"
        }
    }
}
