//
//  SignUpViewModel.swift
//  HiProject
//
//  Created by 노주영 on 6/4/24.
//

import Photos
import UIKit

class SignUpViewModel {
    var selectPhotoAsset = Array(repeating: AssetInfo.self, count: 10)
    
    private let authService = MyPhotoAuthService()
    
    func requestAuthorization(completion: @escaping (Result<Void, NSError>) -> Void) {
        authService.requestAuthorization { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure:
                completion(.failure(.init()))
            }
        }
    }
}
