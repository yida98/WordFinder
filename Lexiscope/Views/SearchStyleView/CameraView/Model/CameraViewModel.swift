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

class CameraViewModel: NSObject,
                        ObservableObject,
                        AVCaptureVideoDataOutputSampleBufferDelegate,
                        AVCapturePhotoCaptureDelegate,
                        AVCaptureVideoTextDetectionDelegate {
    
    @Published var hasCapturedImage: Bool = false
    @Published var loading: Bool = false
    
    @Published var word: String = ""
//    @Published var headwordEntry: HeadwordEntry? {
//        willSet {
//            loading = false
//        }
//    }
    @Published var allowsCameraUsage: Bool = true
    
    // TODO: Fix all of these magic values
    static let viewportSize = CGSize(width: Constant.screenBounds.width * 0.3,
                                     height: 65)
    static let cameraSize = CGSize(width: Constant.screenBounds.width,
                                   height: Constant.screenBounds.width * CameraViewModel.bufferRatio)
    
//    static let boundingBoxPadding: CGFloat = 4
//    static let boundingBoxCornerRadius: CGFloat = 6
//    static let viewFurtherInset: CGFloat = 50
//
//    static let buttonSize = CGSize(width: 90, height: 40)
//    static let buttonPadding: CGFloat = 50
//    static let buttonCornerRadius: CGFloat = 20
    
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
    
// MARK: - Text Detection
    private static let maxCandidates = 1 // TODO: Delegate out these customizations to others
    
    private static let centerPoint = CGPoint(x: 0.5, y: 0.5)
    private static let leadingPoint = CGPoint(x: 0, y: 0.5)
    
    internal func detectText(request: VNRequest, error: Error?) {
        if error != nil {
            debugPrint(error.debugDescription)
            return
        }

        guard let results = request.results as? [VNRecognizedTextObservation] else {
            debugPrint("no requests")
            return
        }
        
        if let result = TextDetector.closestTo(Self.centerPoint, in: results) {
            if let recognizedText = result.topCandidates(Self.maxCandidates).first {
                let bounds = Self.boundingBox(forRegionOfInterest: result.boundingBox, fromOutput: CameraViewModel.viewportSize)
                DispatchQueue.main.async { [self] in
                    coordinates = bounds
                    word = recognizedText.string
                }
            }
        }
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate

    // MARK: Camera variables
    var camera: TextDetectionCameraModel?
    let sessionPreset: AVCaptureSession.Preset = .photo
    @Published var capturedImage: UIImage?
    @Published var coordinates: CGRect = .zero
//    @Published var bufferSize: CGSize = CGSize(width: 4032, height: 3024)
    static let bufferRatio: CGFloat = 4032/3024
    
    internal func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let previewImage = UIImage(data: imageData) else { return }
        capturedImage = previewImage.resizingTo(size: CameraViewModel.cameraSize)
        TextDetector.detect(from: imageData, request: detectText(request:error:))
    }
    
    func takePhoto() {
        var photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first,
            let camera = camera {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            camera.capturePhoto(with: photoSettings, delegate: self)
            
            self.camera = nil
        }
    }
    
    func startCamera() {
        camera = TextDetectionCameraModel(sessionPreset: sessionPreset,
                                          captureVideoTextDetectionDelegate: self)
        camera?.startRunning()
    }
    
    func resumeCamera() {
        capturedImage = nil
    }
    
    func cameraPreviewLayer() -> CALayer? {
        return camera?.startLiveVideo()
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

protocol AVCaptureVideoTextDetectionDelegate {
    func detectText(request: VNRequest, error: Error?)
}
	
extension UIImage {
    func resizingTo(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
