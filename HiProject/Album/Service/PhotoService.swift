//
//  PhotoService.swift
//  HiProject
//
//  Created by 노주영 on 5/29/24.
//

import Photos
import UIKit

protocol PhotoService {
    func convertAlbumToPHAssets(
        album: PHFetchResult<PHAsset>,
        completion: @escaping ([PHAsset]) -> Void)
    func fetchVideo(
        phAsset: PHAsset,
        size: CGSize,
        completion: @escaping (AVAsset?, AVAudioMix?) -> Void)
    func fetchImage(
        phAsset: PHAsset,
        size: CGSize,
        contentMode: PHImageContentMode,
        version: PHImageRequestOptionsVersion,
        completion: @escaping (UIImage) -> Void)
}

final class MyPhotoService: NSObject, PhotoService {
    private let imageManager = PHCachingImageManager()
    weak var delegate: PHPhotoLibraryChangeObserver?
    
    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func convertAlbumToPHAssets(
        album: PHFetchResult<PHAsset>,
        completion: @escaping ([PHAsset]) -> Void
    ) {
        guard 0 < album.count else { return }
        
        var phAssets = [PHAsset]()
        
        album.enumerateObjects { asset, index, stopPointer in
            guard index <= album.count - 1 else {
                stopPointer.pointee = true
                return
            }
            phAssets.append(asset)
        }
        completion(phAssets)
    }
    
    func fetchVideo(
        phAsset: PHAsset,
        size: CGSize,
        completion: @escaping (AVAsset?, AVAudioMix?) -> Void
    ) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = false
        options.deliveryMode = .highQualityFormat
        
        imageManager.requestAVAsset(
            forVideo: phAsset,
            options: options) { avAsset, avAudio, _ in
                completion(avAsset, avAudio)
            }
    }
    
    func fetchImage(
        phAsset: PHAsset,
        size: CGSize,
        contentMode: PHImageContentMode,
        version: PHImageRequestOptionsVersion,
        completion: @escaping (UIImage) -> Void
    ) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = false
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.version = version
        
        imageManager.requestImage(
            for: phAsset,
            targetSize: size,
            contentMode: contentMode,
            options: options,
            resultHandler: { image, _ in
                guard let image else { return }
                completion(image)
            }
        )
    }
}

extension MyPhotoService: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        delegate?.photoLibraryDidChange(changeInstance)
    }
}
