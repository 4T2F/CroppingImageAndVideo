//
//  TrimVideoControlViewModel.swift
//  HiProject
//
//  Created by 노주영 on 6/10/24.
//

import AVFoundation
import Foundation

class TrimVideoControlViewModel: ObservableObject {
    @Published var trimPositions: (Double, Double) = (0.0, 1.0)
    @Published var playheadProgress: CMTime = .zero
//    
//    @Published var editedPlayerItem: AVPlayerItem
//    private var durationUpdateCancellable: Cancellable?
//    
    func fomattingDouble(time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

