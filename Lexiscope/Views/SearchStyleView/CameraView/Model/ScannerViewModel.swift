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
    
    @Published var coordinates: CGRect = .zero
    private var resultCluster: PassthroughSubject<String, Never>
    private var inputSubscriber: AnyCancellable?
    
    var regionOfInterestDelegate: ROIDelegate?
    
    init(input: AnyPublisher<UIImage?, Never>, regionOfInterestDelegate: ROIDelegate) {
        self.resultCluster = PassthroughSubject<String, Never>()
        self.regionOfInterestDelegate = regionOfInterestDelegate
        
        textDetector.delegate = self
        self.inputSubscriber = input.sink(receiveValue: { [weak self] uiImage in
            if let image = uiImage,
                let cgImage = image.cgImage {
                self?.textDetector.detect(from: cgImage)
            }
        })
        WordSearchRequestManager.shared.addPublisher(resultCluster.eraseToAnyPublisher(), to: .cluster)
    }
    
    private static let maxCandidates = 1 // TODO: Delegate out these customizations to others
    
    func detectText(request: VNRequest, error: Error?) {
        if error != nil {
            debugPrint(error.debugDescription)
            return
        }

        guard let results = request.results as? [VNRecognizedTextObservation] else {
            debugPrint("no requests")
            return
        }
        
        if let roiDelegate = regionOfInterestDelegate,
           let result = VNTextDetector.closestTo(upsideDownLocationOfInterest(), in: results) {
            if let recognizedText = result.topCandidates(Self.maxCandidates).first {
                let bounds = Self.boundingBox(of: result.boundingBox,
                                              inRealRegionOfInterest: roiDelegate.getRealRegionOfInterest())
                DispatchQueue.main.async { [self] in
                    coordinates = bounds
                    resultCluster.send(recognizedText.string)
                }
            }
        }
    }
    
    func upsideDownLocationOfInterest() -> CGPoint {
        guard let regionOfInterestDelegate = regionOfInterestDelegate else { return .zero }
        let loc = regionOfInterestDelegate.getLocationOfInterest()
        return CGPoint(x: loc.x, y: 1 - loc.y)
    }
    
    func getRegionOfInterest() -> CGRect {
        guard let normalizationDelegate = regionOfInterestDelegate else { return .zero }
        return normalizationDelegate.getRegionOfInterest()
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

protocol ROIDelegate {
    func getRegionOfInterest() -> CGRect
    func getRealRegionOfInterest() -> CGRect
    func getLocationOfInterest() -> CGPoint
}
