//
//  Album.swift
//  HiProject
//
//  Created by 노주영 on 6/4/24.
//

import Photos

struct Album {
    let name: String
    let album: PHFetchResult<PHAsset>
    
    init(fetchResult: PHFetchResult<PHAsset>, albumName: String) {
        name = albumName
        album = fetchResult
    }
}
