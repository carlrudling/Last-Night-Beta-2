import Foundation
import SwiftUI
import Kingfisher
import AVFoundation
import UIKit
import Photos


class SlideShowViewModel: ObservableObject {
    @Published var currentImageIndex: Int = 0
    @Published var timer: Timer? = nil
    @Published var showPhotoGrid = false
    @Published var showUserGrid = false
    @Published var playButtonPressed: Bool = false  // New state variable
    @Published var isLoading: Bool = true
    @Published var imagesForSlideshow: [UIImage] = []
    @Published var isNavigationLinkActive: Bool = false
    @Published var selectedDetent: PresentationDetent = .medium
    @Published var slideShowCreatePopUp = false
    @Published var isProcessingVideo = false
    @Published var successMessage = false
    @Published var errorMessage = false
    @Published var isAnimating = false
    

    
    var posts: [Post] = [] // Array of Post objects
    
    // Other properties and methods as needed
    
    // Function to format the image path
    func formattedImagePath(from imagePath: String) -> String {
        let imagePath = "\(imagePath).jpg"
        print(imagePath)
        return imagePath
    }
    
    
    func updateSlideshow(with selectedImagePaths: [String]) {
        let sortedImagePaths = sortImagePathsByUploadTime(selectedImagePaths, using: posts)
        
        // Preload images and update imagesForSlideshow
        ImageViewModel.preloadImages(paths: sortedImagePaths) { images in
            DispatchQueue.main.async {
                self.imagesForSlideshow = images
            }
        }
    }
    
    private func sortImagePathsByUploadTime(_ selectedImagePaths: [String], using posts: [Post]) -> [String] {
        let selectedPosts = posts.filter { post in
            let postImagePathWithExtension = post.imagePath + ".jpg"
            return selectedImagePaths.contains(postImagePathWithExtension)
        }
        
        let sortedPosts = selectedPosts.sorted { $0.uploadTime < $1.uploadTime }
        let sortedPaths = sortedPosts.map { $0.imagePath + ".jpg" } // Add .jpg extension to each path
        
        print("Sorted image paths: \(sortedPaths)")
        return sortedPaths
    }
    
    
    //MARK: Methods for coverting slideshow to videofile & Downloading
    
    func pixelBuffer(from image: UIImage) -> CVPixelBuffer? {
        let ciImage = CIImage(image: image)
        let size = image.size
        
        var pixelBuffer: CVPixelBuffer?
        let options: [CFString: Any] = [kCVPixelBufferCGImageCompatibilityKey: true, kCVPixelBufferCGBitmapContextCompatibilityKey: true]
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, options as CFDictionary, &pixelBuffer)
        
        if status != kCVReturnSuccess {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.draw(ciImage!.cgImage!, in: CGRect(x: 0, y: 0, width: ciImage!.extent.size.width, height: ciImage!.extent.size.height))
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    
    func createVideoFromImages(images: [UIImage], fps: Int32 = 1, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = urls.first else {
            completion(.failure(CustomError.directoryNotFound))
            return
        }
        
        let videoOutputURL = documentDirectory.appendingPathComponent("slideshow.mp4")
        if fileManager.fileExists(atPath: videoOutputURL.path) {
            try? fileManager.removeItem(at: videoOutputURL)
        }
        
        guard let assetWriter = try? AVAssetWriter(outputURL: videoOutputURL, fileType: .mp4) else {
            completion(.failure(CustomError.assetWriterCreationFailed))
            return
        }
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 1080,
            AVVideoHeightKey: 1920
        ]
        
        let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        assetWriter.add(assetWriterInput)
        
        let sourceBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: 1080,
            kCVPixelBufferHeightKey as String: 1920
        ]
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: sourceBufferAttributes)
        
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: CMTime.zero)
        
        let mediaQueue = DispatchQueue(label: "mediaInputQueue")
        
        var frameCount = 0
        let frameDuration = CMTimeMake(value: 1, timescale: 1)
        
        assetWriterInput.requestMediaDataWhenReady(on: mediaQueue) {
            while assetWriterInput.isReadyForMoreMediaData {
                if frameCount >= images.count {
                    assetWriterInput.markAsFinished()
                    assetWriter.finishWriting {
                        if assetWriter.status == .completed {
                            DispatchQueue.main.async {
                                completion(.success(videoOutputURL)) // Pass the URL of the created video
                            }
                        } else if assetWriter.status == .failed {
                            DispatchQueue.main.async {
                                completion(.failure(assetWriter.error ?? CustomError.videoCreationFailed))
                            }
                        }
                    }
                    
                    break
                    
                }
                
                let image = images[frameCount]
                // Transform the image if necessary to ensure correct orientation
                let transformedImage = self.transformImageForCorrectOrientation(image: image)
                
                
                if let buffer = self.pixelBuffer(from: transformedImage) {
                    let frameTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
                    pixelBufferAdaptor.append(buffer, withPresentationTime: frameTime)
                    frameCount += 1
                }
            }
        }
    }
    
    private func appendPixelBuffer(forImage image: UIImage, pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor, atTime time: CMTime) {
        guard let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool else {
            print("Pixel buffer asset writer input did not have a pixel buffer pool available; dropping frame.")
            return
        }
        
        var maybePixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &maybePixelBuffer)
        
        if let pixelBuffer = maybePixelBuffer, status == kCVReturnSuccess {
            fillPixelBufferFromImage(image: image, pixelBuffer: pixelBuffer)
            pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: time)
        } else {
            print("Could not get pixel buffer from pool; dropping frame.")
        }
    }
    
    private func fillPixelBufferFromImage(image: UIImage, pixelBuffer: CVPixelBuffer) {
        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        let data = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: data, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)!
        
        context.draw(image.cgImage!, in: CGRect(origin: .zero, size: image.size))
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
    }
    
    func saveVideoToPhotos(url: URL) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    // Video saved successfully
                    print("Video saved to Photos")
                } else {
                    // Error saving video
                    print("Error saving video to Photos: \(error?.localizedDescription ?? "unknown error")")
                }
            }
        }
    }
    
    func transformImageForCorrectOrientation(image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        switch image.imageOrientation {
        case .up:
            return image
        case .down, .downMirrored:
            return rotateImage(cgImage: cgImage, angle: -.pi) // Adjusted angle
        case .left, .leftMirrored:
            return rotateImage(cgImage: cgImage, angle: -.pi / 2) // Adjusted angle
        case .right, .rightMirrored:
            return rotateImage(cgImage: cgImage, angle: .pi / 2) // Adjusted angle
        case .upMirrored:
            return flipImageHorizontally(image: image)
        @unknown default:
            return image
        }
    }
    
    
    func rotateImage(cgImage: CGImage, angle: CGFloat) -> UIImage {
        var newImage = UIImage(cgImage: cgImage)
        DispatchQueue.main.sync {
            let size = CGSize(width: cgImage.width, height: cgImage.height)
            let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: size))
            rotatedViewBox.transform = CGAffineTransform(rotationAngle: angle)
            let rotatedSize = rotatedViewBox.frame.size

            UIGraphicsBeginImageContext(rotatedSize)
            if let bitmap = UIGraphicsGetCurrentContext() {
                bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
                bitmap.rotate(by: angle)
                bitmap.scaleBy(x: 1.0, y: -1.0)
                bitmap.draw(cgImage, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
                newImage = UIGraphicsGetImageFromCurrentImageContext() ?? newImage
            }
            UIGraphicsEndImageContext()
        }
        return newImage
    }

    
    func flipImageHorizontally(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: image.size.width, y: 0)
        context.scaleBy(x: -1, y: 1)
        context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
    
    func addWatermark(to videoURL: URL, watermarkImage: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let asset = AVAsset(url: videoURL)
        let composition = AVMutableComposition()
        guard let compositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
              let assetTrack = asset.tracks(withMediaType: .video).first else {
            completion(.failure(CustomError.videoProcessingFailed))
            return
        }

        // Add the video track to the composition
        try? compositionTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of: assetTrack, at: CMTime.zero)

        
        let watermarkSize = CGSize(width: watermarkImage.size.width, height: watermarkImage.size.height)
        let videoSize = CGSize(width: assetTrack.naturalSize.width, height: assetTrack.naturalSize.height)
        let marginRight = 20.0 // Margin from the right edge
        let marginTop = 20.0 // Margin from the top

        let watermarkPosition = CGPoint(
            x: videoSize.width - watermarkSize.width - marginRight,
            y: videoSize.height - watermarkSize.height - marginTop
        )
        
        // Create a layer for the watermark
        let watermarkLayer = CALayer()
        watermarkLayer.contents = watermarkImage.cgImage
        watermarkLayer.frame = CGRect(origin: watermarkPosition, size: watermarkSize)
        watermarkLayer.opacity = 0.7

        // Create a layer for the video
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(x: 0, y: 0, width: assetTrack.naturalSize.width, height: assetTrack.naturalSize.height)

        // Create a parent layer and add the video and watermark layers
        let parentLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: assetTrack.naturalSize.width, height: assetTrack.naturalSize.height)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(watermarkLayer)

        // Create a video composition
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = assetTrack.naturalSize
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)

        // Create and add instruction
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack)
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        // Define the output URL for the watermarked video
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("watermarkedVideo.mp4")
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }

        

        // Export the video
        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            completion(.failure(CustomError.videoExportFailed))
            return
        }

        exporter.videoComposition = videoComposition

        exporter.outputURL = outputURL
        exporter.outputFileType = .mp4

        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                switch exporter.status {
                case .completed:
                    completion(.success(outputURL))
                case .failed, .cancelled:
                    completion(.failure(exporter.error ?? CustomError.videoExportFailed))
                default:
                    break
                }
            }
        }
    }


    func createAndWatermarkVideo(images: [UIImage], watermarkImage: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        createVideoFromImages(images: images, fps: 30) { result in
            switch result {
            case .success(let videoURL):
                print("Video created at: \(videoURL)")
                self.addWatermark(to: videoURL, watermarkImage: watermarkImage) { watermarkResult in
                    DispatchQueue.main.async {
                        self.isAnimating = false // Stop animation in both success and failure cases
                        switch watermarkResult {
                        case .success(let watermarkedVideoURL):
                            print("Watermarked video saved at: \(watermarkedVideoURL)")
                            self.saveVideoToPhotos(url: watermarkedVideoURL)
                            withAnimation{
                                self.successMessage = true
                                self.isAnimating = false
                            }
                            completion(.success(watermarkedVideoURL))
                        case .failure(let error):
                            print("Error adding watermark: \(error)")
                            withAnimation{
                                self.errorMessage = true
                                self.isAnimating = false
                            }
                            completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isAnimating = false // Stop animation here as well
                    self.errorMessage = true
                    completion(.failure(error))
                }
                print("Error creating video: \(error)")
            }
        }
    }



    
    
}





enum CustomError: Error {
    case directoryNotFound
    case assetWriterCreationFailed
    case videoCreationFailed
    case videoProcessingFailed
    case videoExportFailed
}

