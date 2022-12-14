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
                       ROIDelegate {
    
    @Published var allowsCameraUsage: Bool = true
    
    var cameraSizePublisher: CurrentValueSubject<CGSize, Never> = CurrentValueSubject<CGSize, Never>(.zero)
    var cameraViewportSize: CGSize
    private var locationOfInterest: CGPoint
    
    convenience override init() {
        self.init(cameraViewportSize: .zero)
    }
    
    init(cameraViewportSize: CGSize) {
        self.cameraViewportSize = cameraViewportSize
        self.locationOfInterest = .zero
        super.init()
        CameraViewModel.requestCameraAccess { success in
            Just(success)
                .receive(on: RunLoop.main)
                .assign(to: &self.$allowsCameraUsage)
        }
        setBufferRatio(with: .photo)
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
    
    private func makeScannerModel() -> ScannerViewModel {
        return ScannerViewModel(input: $capturedImage.eraseToAnyPublisher(),
                                         regionOfInterestDelegate: self)
    }
    
    func getScannerModel() -> ScannerViewModel {
        if scannerViewModel != nil {
            return scannerViewModel!
        }
        scannerViewModel = makeScannerModel()
        return scannerViewModel!
    }
    
    /// Calculates the region of interest for the scanner based on the size of the viewport of the serach view
    /// The camera's size doesn't scale with the change in the viewport's size
    private func normalize(rect: CGRect) -> CGRect {
        let x = rect.minX / cameraSizePublisher.value.width
        let y = rect.minY / cameraSizePublisher.value.height
        let width = rect.width / cameraSizePublisher.value.width
        let height = rect.height / cameraSizePublisher.value.height
        let result = CGRect(x: x, y: y, width: width, height: height)
        return result
    }
    
    func getRegionOfInterest() -> CGRect {
        let regionOfInterest = normalize(rect: getRealRegionOfInterest())
        return regionOfInterest
    }
    
    func getRealRegionOfInterest() -> CGRect {
        // Assuming the origin is the lower-left corner of the parent (i.e. the camera)
        let roiOrigin = CGPoint(x: 0,
                                y: (cameraSizePublisher.value.height - cameraViewportSize.height) / 2)
        let regionOfInterest = CGRect(origin: roiOrigin,
                                      size: cameraViewportSize)
        return regionOfInterest
    }
    
    func getLocationOfInterest() -> CGPoint {
        let x = locationOfInterest.x / cameraViewportSize.width
        let y = locationOfInterest.y / cameraViewportSize.height
        return CGPoint(x: x, y: y)
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
    
    func handleCameraViewTap(at location: CGPoint) {
        locationOfInterest = location
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
        }
    }
    
    func startCamera() {
        camera = TextDetectionCameraModel(sessionPreset: sessionPreset)
        camera?.startRunning()
    }
    
    private func resumeCamera() {
        capturedImage = nil
        locationOfInterest = .zero
        scannerViewModel?.coordinates = .zero
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
