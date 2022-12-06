//
//  ScannerViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 11/29/22.
//

import Foundation
import Vision
import SwiftUI
import Combine

class ScannerViewModel: ObservableObject, VNTextDetectorDelegate {
    var textDetector = VNTextDetector()
    var imageOrientation: CGImagePropertyOrientation = .up
    var recognitionLevel: VNRequestTextRecognitionLevel = .accurate
    var regionOfInterest: CGRect
    var realRegionOfInterest: CGRect
    
    @Published var coordinates: CGRect = .zero
    @Published var resultCluster: String = ""
    private var inputSubscriber: AnyCancellable?
    
    init(input: AnyPublisher<UIImage?, Never>, regionOfInterest: CGRect) {
        self.realRegionOfInterest = regionOfInterest
        self.regionOfInterest = Self.calculateRegionOfInterest(for: regionOfInterest)
        textDetector.delegate = self
        self.inputSubscriber = input.sink(receiveValue: { uiImage in
            if let image = uiImage, let cgImage = image.cgImage {
                self.textDetector.detect(from: cgImage)
            }
        })
    }
    
    private static let maxCandidates = 1 // TODO: Delegate out these customizations to others
    private static let centerPoint = CGPoint(x: 0.5, y: 0.5)
    private static let leadingPoint = CGPoint(x: 0, y: 0.5)
    
    func detectText(request: VNRequest, error: Error?) {
        if error != nil {
            debugPrint(error.debugDescription)
            return
        }

        guard let results = request.results as? [VNRecognizedTextObservation] else {
            debugPrint("no requests")
            return
        }
        
        if let result = VNTextDetector.closestTo(Self.centerPoint, in: results) {
            if let recognizedText = result.topCandidates(Self.maxCandidates).first {
                let bounds = Self.boundingBox(of: result.boundingBox,
                                              inRealRegionOfInterest: realRegionOfInterest)
                DispatchQueue.main.async { [self] in
                    coordinates = bounds
                    resultCluster = recognizedText.string
                }
            }
        }
    }
    
    fileprivate static func boundingBox(of output: CGRect, inRealRegionOfInterest roi: CGRect) -> CGRect {
        var normalizedOutput = VNImageRectForNormalizedRect(output, Int(roi.width), Int(roi.height))
        
        
        let outputTranslation = CGAffineTransform(translationX: 0, y: -roi.height)
        let outputScale = CGAffineTransform(scaleX: 1, y: -1)

        normalizedOutput = normalizedOutput.applying(outputTranslation)
        normalizedOutput = normalizedOutput.applying(outputScale)
        
        return normalizedOutput
    }
    
    /// Calculates the region of interest for the scanner based on the size of the viewport of the serach view
    /// The camera's size doesn't scale with the change in the viewport's size
    static func calculateRegionOfInterest(for roi: CGRect) -> CGRect {
        debugPrint(roi)
        let x = roi.minX / CameraViewModel.cameraSize.width
        let y = roi.minY / CameraViewModel.cameraSize.height
        let width = roi.width / CameraViewModel.cameraSize.width
        let height = roi.height / CameraViewModel.cameraSize.height
        let result = CGRect(x: x, y: y, width: width, height: height)
        return result
    }
}
