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
                       NormalizationDelegate {
    
    @Published var allowsCameraUsage: Bool = true
    
    // TODO: Fix all of these magic values
    var cameraSizePublisher: CurrentValueSubject<CGSize, Never> = CurrentValueSubject<CGSize, Never>(.zero)
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
                                y: (cameraSizePublisher.value.height - cameraViewportSize.height) / 2)
        let regionOfInterest = CGRect(origin: roiOrigin,
                                      size: cameraViewportSize)
        let viewModel = ScannerViewModel(input: $capturedImage.eraseToAnyPublisher(),
                                         regionOfInterest: regionOfInterest,
                                         normalizationDelegate: self)
        scannerViewModel = viewModel
        return viewModel
    }
    
    /// Calculates the region of interest for the scanner based on the size of the viewport of the serach view
    /// The camera's size doesn't scale with the change in the viewport's size
    func normalize(rect: CGRect) -> CGRect {
        let x = rect.minX / cameraSizePublisher.value.width
        let y = rect.minY / cameraSizePublisher.value.height
        let width = rect.width / cameraSizePublisher.value.width
        let height = rect.height / cameraSizePublisher.value.height
        let result = CGRect(x: x, y: y, width: width, height: height)
        return result
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate

    // MARK: Camera variables
    var camera: TextDetectionCameraModel?
    /// The session preset determines the buffer's aspect ratio
    var sessionPreset: AVCaptureSession.Preset = .photo
    var bufferRatio: CGFloat = .zero
    @Published var capturedImage: UIImage?
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let previewImage = UIImage(data: imageData) else { return }
        capturedImage = previewImage.resizingTo(size: cameraSizePublisher.value)
    }
    
    func handleCameraViewTap() {
        if (capturedImage != nil) {
            resumeCamera()
        } else {
            takePhoto()
        }
    }
    
    private func takePhoto() {
        var photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first,
            let camera = camera {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            camera.capturePhoto(with: photoSettings, delegate: self)
            
            self.camera = nil
        }
    }
    
    func startCamera() {
        setBufferRatio(with: .photo)
        camera = TextDetectionCameraModel(sessionPreset: sessionPreset)
        camera?.startRunning()
    }
    
    private func resumeCamera() {
        capturedImage = nil
    }
    
    func cameraPreviewLayer() -> CALayer? {
        return camera?.startLiveVideo()
    }
    
    func setBufferRatio(with preset: AVCaptureSession.Preset) {
        sessionPreset = preset
        // TODO: Other presets
        bufferRatio = 4/3
        
        let cameraSize = CGSize(width: cameraViewportSize.width,
                                height: cameraViewportSize.width * bufferRatio)
        cameraSizePublisher.send(cameraSize)
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
