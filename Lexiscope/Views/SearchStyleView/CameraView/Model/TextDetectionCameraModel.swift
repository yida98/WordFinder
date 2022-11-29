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
    let captureVideoTextDetectionDelegate: AVCaptureVideoTextDetectionDelegate

    init(sessionPreset: AVCaptureSession.Preset, captureVideoTextDetectionDelegate: AVCaptureVideoTextDetectionDelegate) {
        self.sessionPreset = sessionPreset
        self.captureVideoTextDetectionDelegate = captureVideoTextDetectionDelegate
    }
    
    func startLiveVideo() -> AVCaptureVideoPreviewLayer? {
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
        session.beginConfiguration()
        
        // FIXME: Super slow creating the first view. Async some functions
        session.sessionPreset = sessionPreset
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        session.commitConfiguration()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        return previewLayer
    }
    
    func startRunning() {
        self.session.startRunning()
    }
    
    func capturePhoto(with settings: AVCapturePhotoSettings, delegate: AVCapturePhotoCaptureDelegate) {
        deviceOutput.capturePhoto(with: settings, delegate: delegate)
    }
    
}
