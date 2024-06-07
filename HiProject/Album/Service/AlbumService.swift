//
//  AlbumService.swift
//  HiProject
//
//  Created by 노주영 on 5/29/24.
//

import Photos
import UIKit

protocol AlbumService {
    func getAlbums(
        mediaType: MediaType,
        completion: @escaping ([Album]) -> Void)
}

final class MyAlbumService: AlbumService {
    func getAlbums(
        mediaType: MediaType,
        completion: @escaping ([Album]) -> Void
    ) {
        var albums = [Album]()
        
        defer { completion(albums) }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = getPredicate(mediaType: mediaType)
        fetchOptions.sortDescriptors = getSortDescriptors
        
        let standardFetchResult = PHAsset.fetchAssets(with: fetchOptions)
        albums.append(
            .init(
                fetchResult: standardFetchResult,
                albumName: mediaType.title))
        
        // 3. smart 앨범을 query로 이미지 가져오기
        let smartAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .any,
            options: PHFetchOptions()
        )
        
        smartAlbums.enumerateObjects { [weak self] phAssetCollection, index, pointer in
            guard let self, index <= smartAlbums.count - 1 else {
                pointer.pointee = true
                return
            }
            
            if phAssetCollection.estimatedAssetCount == NSNotFound {
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = getPredicate(mediaType: mediaType)
                fetchOptions.sortDescriptors = getSortDescriptors

                let fetchResult = PHAsset.fetchAssets(
                    in: phAssetCollection,
                    options: fetchOptions)
                
                albums.append(
                    .init(
                        fetchResult: fetchResult,
                        albumName: mediaType.title))
            }
        }

    }
    
    private func getPredicate(mediaType: MediaType) -> NSPredicate {
        let format = "mediaType == %d"
        switch mediaType {
        case .image:
            return .init(
                format: format,
                PHAssetMediaType.image.rawValue
            )
        case .video:
            return .init(
                format: format,
                PHAssetMediaType.video.rawValue
            )
        }
    }
    
    private let getSortDescriptors = [
        NSSortDescriptor(key: "creationDate", ascending: false),
        NSSortDescriptor(key: "modificationDate", ascending: false)
    ]
}
