//
//  CameraViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2022-05-03.
//

import SwiftUI
import Vision
import Combine
import AVFoundation

class CameraViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    
    @Published var capturedImage: Bool = false
    @Published var loading: Bool = false
    
    // MARK: Camera variables
    @Published var coordinates: CGRect = .zero
    @Published var bufferSize: CGSize = CGSize(width: 1, height: 1) {
        willSet {
            trueCameraHeight = Constant.screenBounds.width / (newValue.height / newValue.width)
        }
    }
    
    @Published var trueCameraHeight: CGFloat = 1
    
    @Published var word: String = ""
//    @Published var headwordEntry: HeadwordEntry? {
//        willSet {
//            loading = false
//        }
//    }
    @Published var allowsCameraUsage: Bool = true
    
    // FIXME: Fix all of these magic values
    static let viewportSize = CGSize(width: Constant.screenBounds.width * 0.3,
                                     height: 65)
    static let boundingBoxPadding: CGFloat = 4
    static let boundingBoxCornerRadius: CGFloat = 6
    static let viewFurtherInset: CGFloat = 50
    
    static let buttonSize = CGSize(width: 90, height: 40)
    static let buttonPadding: CGFloat = 50
    static let buttonCornerRadius: CGFloat = 20
    
    var cancellableSet = Set<AnyCancellable>()
    
    override init() {
        super.init()
        CameraViewModel.requestCameraAccess { success in
            Just(success)
                .receive(on: RunLoop.main)
                .assign(to: &self.$allowsCameraUsage)
        }
    }
    
    func lookup() {
        if word != "" {
            loading = true

//            URLTask.shared.get(word: word)
//                .receive(on: RunLoop.main)
//                .sink(receiveCompletion: { completion in
//                    debugPrint("completed")
//                }, receiveValue: { entry in
//                    if let newEntry = entry {
//                        self.headwordEntry = newEntry
//                    } else {
//                        self.headwordEntry = nil
//                    }
//                })
//                .store(in: &cancellableSet)
        }
    }
    
    func removeEntry(indexSet: IndexSet) {
//        Storage.shared.entries.remove(atOffsets: indexSet)
    }
    
    static func requestCameraAccess(_ completion: @escaping (_ success: Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { success in
            completion(success)
        }
    }
    
// MARK: - Live Video
    private let session = AVCaptureSession()
    private let deviceOutput = AVCaptureVideoDataOutput()
    var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private static let maxCandidates = 1 // TODO: Delegate out these customizations to others
    static let bufferRatio: CGFloat = 640/480
    var isRunning: Bool = false
    
//    var bufferSize: CGSize = .zero
    
    func startLiveVideo() -> AVCaptureVideoPreviewLayer? {
        request = VNRecognizeTextRequest(completionHandler: detectText(request:error:))

        // FIXME: Super slow creating the first view. Async some functions
        session.sessionPreset = .vga640x480
        bufferSize = CGSize(width: 640, height: 480)
        
        var deviceInput: AVCaptureDeviceInput!
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            debugPrint("No video device; might be using a simulator.")
            return nil
        }
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            print("Could not create video device input: \(error)")
            return nil
        }
        
//        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        
        deviceOutput.alwaysDiscardsLateVideoFrames = true
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global())
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
        
        return previewLayer
    }
    
    func startRunning() {
        session.startRunning()
        isRunning = true
    }
    
    func stopRunning() {
        session.stopRunning()
        isRunning = false
    }

// MARK: - Text Detection
    private func detectText(request: VNRequest, error: Error?) {
        if error != nil {
            debugPrint(error.debugDescription)
            return
        }

        guard let results = request.results as? [VNRecognizedTextObservation] else {
            debugPrint("no requests")
            return
        }
        
        if let result = Self.closestTo(.bottom, in: results) {
            if let recognizedText = result.topCandidates(Self.maxCandidates).first {
                var bounds = result.boundingBox
                DispatchQueue.main.async { [self] in
                    bounds = Self.boundingBox(forRegionOfInterest: bounds, fromOutput: CameraViewModel.viewportSize)
                    coordinates = bounds
                    word = recognizedText.string
                }
            }
        }
    }
    
// MARK: Helper Functions
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

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    var request: VNRecognizeTextRequest!
    var sequenceHandler = VNSequenceRequestHandler()
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }


        request.recognitionLevel = .accurate
//            request.usesLanguageCorrection = true
//            request.recognitionLanguages = [

        /// The origin point is the lower-left corner, not the centre origin
        let height = (Constant.screenBounds.width / (bufferSize.height / bufferSize.width))
        let originX = (Constant.screenBounds.width - CameraViewModel.viewportSize.width) / 2
        let originY = (height - CameraViewModel.viewportSize.height)/2

        request.regionOfInterest = Self.normalizeBounds(for: CGRect(origin: CGPoint(x: originX,
                                                                                    y: originY),
                                                                    size: CameraViewModel.viewportSize),
                                                        in: bufferSize)
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
    
    // MARK: Helper funcs
    
    /// Calculate the `regionOfInterest` in the `bufferSize` normalized for the screen size
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
    
    // MARK: - AVCapturePhotoCaptureDelegate
    
    let photoOutput = AVCapturePhotoOutput()
    
    internal func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let previewImage = UIImage(data: imageData)
        
//            viewModel.
    }
    
    func takePhoto() {
        let photoSettings = AVCapturePhotoSettings()
//        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
//            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
//            photoOutput.capturePhoto(with: photoSettings, delegate: self)
//        }
    }
}

extension CameraViewModel {
//    static let scannerSize: CGSize = CGSize(width: , height: <#T##CGFloat#>)
}
	
