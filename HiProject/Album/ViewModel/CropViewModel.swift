//
//  CropViewModel.swift
//  HiProject
//
//  Created by 노주영 on 6/7/24.
//

import Photos
import UIKit

class CropViewModel {
    var albums: [PHFetchResult<PHAsset>] = []
    var photos: [AssetInfo] = []
    
    private let authService = MyPhotoAuthService()
    private let albumService = MyAlbumService()
    private let photoService = MyPhotoService()
}

// MARK: - PhotoViewController
extension CropViewModel {
    func loadAlbums(
        mediaType: MediaType,
        completion: @escaping () -> Void
    ) {
        albumService.getAlbums(mediaType: mediaType) { albums in
            self.albums = albums.map(\.album)
            completion()
        }
    }
    
    func loadAsset(completion: @escaping () -> Void) {
        guard !albums.isEmpty else { return }
        
        let album = albums[0]
        
        photoService.convertAlbumToPHAssets(album: album) { phAssets in
            self.photos = phAssets.map {
                .init(phAsset: $0, image: nil, avAsset: nil, avAudio: nil)
            }
            completion()
        }
    }
    
    func fetchImage(
        item: Int,
        size: CGSize,
        contentMode: PHImageContentMode,
        version: PHImageRequestOptionsVersion,
        completion: @escaping (PHAsset, UIImage) -> Void
    ) {
        let imageInfo = photos[item]
        let phAsset = imageInfo.phAsset

        photoService.fetchImage(
                        phAsset: phAsset,
                        size: size,
                        contentMode: contentMode,
                        version: version,
                        completion: { image in
                            completion(phAsset, image)
                        }
                    )
    }
    
    func fetchVideo(
        phAsset: PHAsset,
        size: CGSize,
        completion: @escaping (AVAsset?, AVAudioMix?) -> Void
    ) {
        photoService.fetchVideo(
            phAsset: phAsset,
            size: size) { avAsset, avAudio in
                completion(avAsset, avAudio)
            }
    }
}

