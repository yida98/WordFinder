//
//  CameraViewControllerRepresentable.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/23/22.
//

import Foundation
import Vision
import SwiftUI
import Combine
import AVFoundation

struct CameraViewRepresentable: UIViewRepresentable {
    var viewModel: CameraViewModel
    
    func makeUIView(context: Context) -> CameraScannerView {
        let cameraView = CameraScannerView()
        cameraView.viewModel = viewModel
        cameraView.delegate = context.coordinator
        return cameraView
    }
    
    func updateUIView(_ uiView: CameraScannerView, context: Context) {
        uiView.startRunning()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        let parent: CameraViewRepresentable
        
        var request: VNRecognizeTextRequest!
        var sequenceHandler = VNSequenceRequestHandler()
        
        init(_ parent: CameraViewRepresentable) {
            self.parent = parent
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }


            request.recognitionLevel = .accurate
//            request.usesLanguageCorrection = true
//            request.recognitionLanguages = [

            // The origin point is a corner, not the centre origin
            let height = (Constant.screenBounds.width / (parent.viewModel.bufferSize.height / parent.viewModel.bufferSize.width))
            let originX = (Constant.screenBounds.width - CameraViewModel.viewportSize.width) / 2
            let originY = (height - CameraViewModel.viewportSize.height)/2

            request.regionOfInterest = Self.normalizeBounds(for: CGRect(origin: CGPoint(x: originX,
                                                                                        y: originY),
                                                                   size: CameraViewModel.viewportSize),
                                                            in: parent.viewModel.bufferSize)
//            let imageRequestHandler = VNImageRequestHandler(cgImage: imageFromSampleBuffer(sampleBuffer : sampleBuffer).cgImage!, options: [:])
//            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            /// Turned off `Address Sanitizer` to ensure `VNImageRequestHandler` doesn't deallocate non-allocated memory
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                            orientation: CGImagePropertyOrientation.right,
                                                            options: [:])

            do {
                try imageRequestHandler.perform([request])
            } catch {
                // TODO: Handle errors
                debugPrint(error)
            }
        }
        
        private static func normalizeBounds(for regionOfInterest: CGRect, in bufferSize: CGSize) -> CGRect {
            
            var rect = regionOfInterest
            let width = Constant.screenBounds.width
            let height = width / (bufferSize.height / bufferSize.width)
            rect.origin = CGPoint(x: rect.minX/width, y: rect.minY/height)
            rect.size = CGSize(width: rect.size.width/width, height: rect.size.height/height)
            return rect
        }
        
        private static func normalizeSize(for regionOfInterest: CGSize, in bufferSize: CGSize) -> CGSize {
            
            var size = regionOfInterest
            let width = Constant.screenBounds.width
            let height = width / (bufferSize.height / bufferSize.width)

            size = CGSize(width: size.width/width, height: size.height/height)
            
            return size
        }
        
//        func imageFromSampleBuffer(sampleBuffer : CMSampleBuffer) -> UIImage {
//            // Get a CMSampleBuffer's Core Video image buffer for the media data
//            let  imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
//            // Lock the base address of the pixel buffer
//            CVPixelBufferLockBaseAddress(imageBuffer!, CVPixelBufferLockFlags.readOnly)
//
//
//            // Get the number of bytes per row for the pixel buffer
//            let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer!)
//
//            // Get the number of bytes per row for the pixel buffer
//            let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!)
//            // Get the pixel buffer width and height
//            let width = CVPixelBufferGetWidth(imageBuffer!)
//            let height = CVPixelBufferGetHeight(imageBuffer!)
//
//            // Create a device-dependent RGB color space
//            let colorSpace = CGColorSpaceCreateDeviceRGB()
//
//            // Create a bitmap graphics context with the sample buffer data
//            var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue
//            bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
//            //let bitmapInfo: UInt32 = CGBitmapInfo.alphaInfoMask.rawValue
//            let context = CGContext.init(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
//            // Create a Quartz image from the pixel data in the bitmap graphics context
//            let quartzImage = context?.makeImage()
//            // Unlock the pixel buffer
//            CVPixelBufferUnlockBaseAddress(imageBuffer!, CVPixelBufferLockFlags.readOnly)
//
//            // Create an image object from the Quartz image
//            let image = UIImage.init(cgImage: quartzImage!)
//
//            return image
//        }
    }
}

class CameraScannerView: UIView {
    
    private let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private let deviceOutput = AVCaptureVideoDataOutput()
    private static let maxCandidates = 1 // TODO: Delegate out these customizations to others
    
    var bufferSize: CGSize = .zero
    
    var viewModel: CameraViewModel!
    
    //DELEGATE
    var delegate: CameraViewRepresentable.Coordinator?
    
    private var loaded = false
    
    override func layoutSubviews() {
        self.delegate!.request = VNRecognizeTextRequest(completionHandler: detectText)
        if !loaded {
            self.frame.size = CGSize(width: Constant.screenBounds.width, height: Constant.screenBounds.width * Self.bufferRatio)
            setup()
        }
        super.layoutSubviews()
    }
    
    func setup() {
        startLiveVideo()
        loaded = true
    }
    
    func startRunning() {
        session.startRunning()
    }
    
    static private var bufferRatio: CGFloat = 640/480
    
    func startLiveVideo() {
        session.sessionPreset = .vga640x480
        viewModel.bufferSize = CGSize(width: 640, height: 480)
        
        var deviceInput: AVCaptureDeviceInput!
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            debugPrint("No video device; might be using a simulator.")
            return
        }
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
//        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        
        
        deviceOutput.alwaysDiscardsLateVideoFrames = true
        deviceOutput.setSampleBufferDelegate(delegate, queue: DispatchQueue.global())
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        if let previewLayerConnection = previewLayer.connection {
            previewLayerConnection.videoOrientation = .portrait
        }
        
        if let deviceConnection = deviceOutput.connection(with: .video) {
            deviceConnection.isEnabled = true
            deviceConnection.preferredVideoStabilizationMode = .off
        }
        
//        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = self.frame
        self.layer.insertSublayer(previewLayer, at: 0)
//        self.view.layer.insertSublayer(previewLayer, at: 0)
    
    }

// MARK: - Text Detection
    private func detectText(request: VNRequest, error: Error?) {
        if error != nil {
            debugPrint(error.debugDescription)
            return
        }

        // TODO: Reassess need
//        DispatchQueue.main.async { [self] in
//            viewModel.coords = [CGRect]()
//            viewModel.word = ""
//        }
        guard let results = request.results as? [VNRecognizedTextObservation] else {
            debugPrint("no requests")
            return
        }
        
        if let result = Self.closestTo(.bottom, in: results) {
            if let recognizedText = result.topCandidates(CameraScannerView.maxCandidates).first {
                var bounds = result.boundingBox
                
                if viewModel != nil {
                    DispatchQueue.main.async { [self] in
                        bounds = Self.boundingBox(forRegionOfInterest: bounds, fromOutput: CameraViewModel.viewportSize)
                        viewModel.coords.append(bounds)
                        viewModel.word = recognizedText.string
                    }
                }
            }
        }
    }
    
// MARK: - Helper Functions
    private static func closestTo(_ point: Point,in results: [VNRecognizedTextObservation]) -> VNRecognizedTextObservation? {
        return results.reduce(results.first) { result, observation in
            var prevDistance: Float = 0
            var currDistance: Float = 0
            guard let prev = result else {
                return observation
            }
            var pointX, pointY, prevX, prevY, currX, currY: Float
            
            switch point {
            case .top:
                pointX = 0.5
                pointY = 1
                prevX = Float(prev.boundingBox.midX)
                prevY = Float(prev.boundingBox.maxY)
                currX = Float(observation.boundingBox.midX)
                currY = Float(observation.boundingBox.maxY)
            case .bottom:
                pointX = 0.5
                pointY = 0
                prevX = Float(prev.boundingBox.midX)
                prevY = Float(prev.boundingBox.minY)
                currX = Float(observation.boundingBox.midX)
                currY = Float(observation.boundingBox.minY)
                
            default: // Centre case
                pointX = 0.5
                pointY = 0.5
                prevX = Float(prev.boundingBox.midX)
                prevY = Float(prev.boundingBox.midY)
                currX = Float(observation.boundingBox.midX)
                currY = Float(observation.boundingBox.midY)
            }
            
            prevDistance += (pointX - prevX).magnitude + (pointY - prevY).magnitude
            currDistance += (pointX - currX).magnitude + (pointY - currY).magnitude
            
//            print(prevDistance, prev.boundingBox.midX, prev.boundingBox.midY, currDistance, observation.boundingBox.midX, observation.boundingBox.midY)
            return prevDistance > currDistance ? observation : result
        }
    }
    
    
    fileprivate static func boundingBox(forRegionOfInterest: CGRect, fromOutput size: CGSize) -> CGRect {
        
        let imageWidth = size.width
        let imageHeight = size.height
        
        let imageRatio = imageWidth / imageHeight
        let width = imageWidth
        let height = width / imageRatio
        
        // Begin with input rect.
        var rect = forRegionOfInterest
        
//        let bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
        let uiRotationTransform = CGAffineTransform(translationX: 1, y: 1).rotated(by: CGFloat.pi)
//        let transform = bottomToTopTransform.concatenating(uiRotationTransform)
        rect = rect.applying(uiRotationTransform)
        
        rect.size.height *= height
        rect.size.width *= width
        
        rect.origin.x = (rect.origin.x) * width
        rect.origin.y = rect.origin.y * height

        return rect
    }

}
