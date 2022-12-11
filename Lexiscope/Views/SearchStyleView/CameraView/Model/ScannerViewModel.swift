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
    private var textDetector = VNTextDetector()
    
    // MARK: VNTextDetectorDelegate
    var imageOrientation: CGImagePropertyOrientation = .up
    var recognitionLevel: VNRequestTextRecognitionLevel = .accurate
    var regionOfInterest: CGRect
    
    private var realRegionOfInterest: CGRect
    
    @Published var coordinates: CGRect = .zero
    private var resultCluster: PassthroughSubject<String, Never>
    private var inputSubscriber: AnyCancellable?
    
    var normalizationDelegate: NormalizationDelegate?
    
    init(input: AnyPublisher<UIImage?, Never>, regionOfInterest: CGRect, normalizationDelegate: NormalizationDelegate) {
        self.realRegionOfInterest = regionOfInterest
        self.normalizationDelegate = normalizationDelegate
        self.regionOfInterest = normalizationDelegate.normalize(rect: regionOfInterest)
        
        self.resultCluster = PassthroughSubject<String, Never>()
        
        textDetector.delegate = self
        self.inputSubscriber = input.sink(receiveValue: { uiImage in
            if let image = uiImage, let cgImage = image.cgImage {
                self.textDetector.detect(from: cgImage)
            }
        })
        WordSearchRequestManager.shared.addPublisher(resultCluster.eraseToAnyPublisher())
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
                    resultCluster.send(recognizedText.string)
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
}

protocol NormalizationDelegate {
    func normalize(rect: CGRect) -> CGRect
}
