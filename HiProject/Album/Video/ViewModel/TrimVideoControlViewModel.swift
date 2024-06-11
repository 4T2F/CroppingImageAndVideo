//
//  TrimVideoControlViewModel.swift
//  HiProject
//
//  Created by 노주영 on 6/10/24.
//

import Foundation

class TrimVideoControlViewModel: ObservableObject {
    @Published var trimPositions: (Double, Double) = (0.0, 1.0)
}
