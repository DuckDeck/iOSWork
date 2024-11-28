//
//  VideoCreate.swift
//  iOSWork
//
//  Created by Stan Hu on 2024/11/28.
//

import Foundation

class VideoCreate {
    func generateVideo(images: [UIImage], duration: Double, size: CGSize, completion: @escaping (URL?) -> Void) {
        // 创建视频输出路径
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_video.mp4")
        
        // 删除已有文件（如果存在）
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }
        
        // 设置视频写入器
        let writer = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4)
        guard let videoWriter = writer else {
            completion(nil)
            return
        }
        
        // 设置视频输入
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height
        ]
        let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoInput.expectsMediaDataInRealTime = false
        
        // 设置像素缓冲区
        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: size.width,
            kCVPixelBufferHeightKey as String: size.height
        ]
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput, sourcePixelBufferAttributes: pixelBufferAttributes)
        
        // 添加输入到写入器
        if videoWriter.canAdd(videoInput) {
            videoWriter.add(videoInput)
        }
        
        // 开始写入
        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: .zero)
        
        if images.count == 1 {
            // 准备像素缓冲区
            let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool!
            let frameDuration = CMTimeMake(value: 1, timescale: 30) // 每帧持续 1/30 秒
            let totalFrames = Int(duration * 30) // 计算总帧数
            
            DispatchQueue.global().async {
                var frameCount = 0
                while frameCount < totalFrames {
                    autoreleasepool {
                        let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
                        if let pixelBuffer = self.createPixelBuffer(from: images[0], size: size, pixelBufferPool: pixelBufferPool), videoInput.isReadyForMoreMediaData {
                            pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                        }
                        frameCount += 1
                    }
                }
                
                // 结束写入
                videoInput.markAsFinished()
                videoWriter.finishWriting {
                    DispatchQueue.main.async {
                        completion(videoWriter.status == .completed ? outputURL : nil)
                    }
                }
            }
        } else {
            // 准备像素缓冲区
            let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool!
            let frameDurationTime = CMTimeMake(value: Int64(duration * 1000), timescale: 1000) // 每帧的持续时间
            
            DispatchQueue.global().async {
                var frameCount = 0
                for image in images {
                    autoreleasepool {
                        let presentationTime = CMTimeMultiply(frameDurationTime, multiplier: Int32(frameCount))
                        if let pixelBuffer = self.createPixelBuffer(from: image, size: size, pixelBufferPool: pixelBufferPool), videoInput.isReadyForMoreMediaData {
                            pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                        }
                        frameCount += 1
                    }
                }
                
                // 结束写入
                videoInput.markAsFinished()
                videoWriter.finishWriting {
                    DispatchQueue.main.async {
                        completion(videoWriter.status == .completed ? outputURL : nil)
                    }
                }
            }
        }
    }

    // 创建像素缓冲区
    private func createPixelBuffer(from image: UIImage, size: CGSize, pixelBufferPool: CVPixelBufferPool) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        if let cgImage = image.cgImage {
            let rect = CGRect(origin: .zero, size: size)
            context?.clear(rect)
            context?.draw(cgImage, in: rect)
        }
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        return buffer
    }
}
