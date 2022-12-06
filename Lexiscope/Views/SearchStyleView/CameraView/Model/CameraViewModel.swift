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
                       AVCapturePhotoCaptureDelegate {
    
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
    static let cameraSize = CGSize(width: Constant.screenBounds.width,
                                   height: Constant.screenBounds.width * CameraViewModel.bufferRatio)
    
    var cancellableSet = Set<AnyCancellable>()
    
    var cameraViewportSize: CGSize
    
    convenience override init() {
        self.init(cameraViewportSize: .zero)
    }
    
    init(cameraViewportSize: CGSize) {
        self.cameraViewportSize = cameraViewportSize
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
    
    private var scannerViewModel: ScannerViewModel?
    
    func getScannerModel() -> ScannerViewModel {
        // Assuming the origin is the lower-left corner of the parent (i.e. the camera)
        let roiOrigin = CGPoint(x: 0,
                                y: (Self.cameraSize.height - cameraViewportSize.height) / 2)
        let regionOfInterest = CGRect(origin: roiOrigin,
                                      size: cameraViewportSize)
        let viewModel = ScannerViewModel(input: $capturedImage.eraseToAnyPublisher(),
                                         regionOfInterest: regionOfInterest)
        scannerViewModel = viewModel
        return viewModel
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate

    // MARK: Camera variables
    var camera: TextDetectionCameraModel?
    let sessionPreset: AVCaptureSession.Preset = .photo
    @Published var capturedImage: UIImage?
//    @Published var bufferSize: CGSize = CGSize(width: 4032, height: 3024)
    static let bufferRatio: CGFloat = 4032/3024
    
    internal func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let previewImage = UIImage(data: imageData) else { return }
        capturedImage = previewImage.resizingTo(size: CameraViewModel.cameraSize)
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
        camera = TextDetectionCameraModel(sessionPreset: sessionPreset)
        camera?.startRunning()
    }
    
    func resumeCamera() {
        capturedImage = nil
    }
    
    func cameraPreviewLayer() -> CALayer? {
        return camera?.startLiveVideo()
    }
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
