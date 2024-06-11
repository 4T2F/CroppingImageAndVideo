//
//  VideoTimeLineGenerator.swift
//  HiProject
//
//  Created by 최동호 on 6/10/24.
//

import AVFoundation
import Combine
import Foundation

protocol VideoTimelineGeneratorProtocol {
    func videoTimeline(for asset: AVAsset, in bounds: CGRect, numberOfFrames: Int) async -> AnyPublisher<[CGImage], Error>
}

final class VideoTimelineGenerator: VideoTimelineGeneratorProtocol {
    func videoTimeline(for asset: AVAsset, in bounds: CGRect, numberOfFrames: Int) async -> AnyPublisher<[CGImage], Error> {
        let generator = AVAssetImageGenerator(asset: asset)
        let times = await frameTimes(for: asset, numberOfFrames: numberOfFrames)
        return Future { promise in
            var images = [CGImage]()

            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = .zero // TODO

            generator.generateCGImagesAsynchronously(forTimes: times) { _, cgImage, _, result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let cgImage = cgImage {
                    images.append(cgImage)
                    if images.count == numberOfFrames {
                        promise(.success(images))
                    }
                } else {
                    fatalError("Error while generating CGImages")
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

fileprivate extension VideoTimelineGenerator {
    func frameTimes(for asset: AVAsset, numberOfFrames: Int) async -> [NSValue] {
        var timesForThumbnails = [CMTime]()
        
        do {
            let duration = try await asset.load(.duration)
            let timeIncrement = (duration.seconds * 1000) / Double(numberOfFrames)
            
            for index in 0..<numberOfFrames {
                let cmTime = CMTime(value: Int64(timeIncrement * Float64(index)), timescale: 1000)
                timesForThumbnails.append(cmTime)
            }
        } catch let error {
            print("error: \(error)")
        }
        return timesForThumbnails.map(NSValue.init)
    }
}

