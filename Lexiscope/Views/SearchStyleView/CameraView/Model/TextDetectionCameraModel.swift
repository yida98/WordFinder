//
//  CameraModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 10/13/22.
//

import Foundation
import AVFoundation
import Vision

class TextDetectionCameraModel {
    
// MARK: - Live Video
    private let session = AVCaptureSession()
    private let deviceOutput = AVCapturePhotoOutput()
    var previewLayer: AVCaptureVideoPreviewLayer! = nil
    
    let sessionPreset: AVCaptureSession.Preset

    init(sessionPreset: AVCaptureSession.Preset) {
        self.sessionPreset = sessionPreset
    }
    
    func startLiveVideo() -> AVCaptureVideoPreviewLayer? {
        var deviceInput: AVCaptureDeviceInput!
        guard let firstDevice = getListOfCameras().first, let videoDevice = AVCaptureDevice.default(firstDevice.deviceType, for: .video, position: .back) else {
            debugPrint("No video device; might be using a simulator.")
            return nil
        }
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            print("Could not create video device input: \(error)")
            return nil
        }
        session.beginConfiguration()
        
        // FIXME: Super slow creating the first view. Async some functions
        session.sessionPreset = sessionPreset
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        session.commitConfiguration()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        return previewLayer
    }
    
    public func getListOfCameras() -> [AVCaptureDevice] {
        
    #if os(iOS)
        let session = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInWideAngleCamera,
                .builtInTelephotoCamera
            ],
            mediaType: .video,
            position: .unspecified)
    #elseif os(macOS)
        let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInWideAngleCamera
            ],
            mediaType: .video,
            position: .unspecified)
    #endif
        
        return session.devices
    }
    
    func startRunning() {
        DispatchQueue.global().async {
            self.session.startRunning()
        }
    }
    
    func stopRunning() {
        DispatchQueue.global().async {
            self.session.stopRunning()
        }
    }
    
    func capturePhoto(with settings: AVCapturePhotoSettings, delegate: AVCapturePhotoCaptureDelegate) {
        deviceOutput.capturePhoto(with: settings, delegate: delegate)
    }
    
    func zoom(_ scale: CGFloat) {
        guard let captureDevice = session.inputs.first as? AVCaptureDeviceInput else { return }
        let device = captureDevice.device
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            
            device.videoZoomFactor = scale
        } catch let error {
            debugPrint("Could not lock device for configuration due to: \(error.localizedDescription)")
        }
    }
    
    var maxZoomFactor: CGFloat {
        guard let captureDevice = session.inputs.first as? AVCaptureDeviceInput else { return 1 }
        let device = captureDevice.device
        return device.activeFormat.videoMaxZoomFactor
    }
}
