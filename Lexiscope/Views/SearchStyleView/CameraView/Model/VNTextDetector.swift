//
//  VNTextDetector.swift
//  Lexiscope
//
//  Created by Yida Zhang on 11/28/22.
//

import Foundation
import Vision

class VNTextDetector: ObservableObject {
    
    var delegate: VNTextDetectorDelegate?
    
    init() {}
    
    func detect(from imageData: Data) {
        guard let delegate = delegate else {
            debugPrint("The delegate was never specified.")
            return
        }
        let handler = VNImageRequestHandler(data: imageData, orientation: delegate.imageOrientation)
        handleDetection(handler: handler)
    }
    
    func detect(from image: CGImage) {
        guard let delegate = delegate else {
            debugPrint("The delegate was never specified.")
            return
        }
        let handler = VNImageRequestHandler(cgImage: image, orientation: delegate.imageOrientation)
        handleDetection(handler: handler)
    }
    
    private func handleDetection(handler: VNImageRequestHandler) {
        guard let delegate = delegate else {
            debugPrint("The delegate was never specified.")
            return
        }
        let requestHandler = delegate.detectText(request:error:)
        let request = VNRecognizeTextRequest(completionHandler: requestHandler)
        
        request.regionOfInterest = delegate.getRegionOfInterest()
        request.recognitionLevel = delegate.recognitionLevel
        do {
            try handler.perform([request])
        } catch {
            debugPrint("Could not handle \(request) because of \(error)")
        }
    }
    
    // MARK: Helper funcs
    
    static func closestTo(_ point: CGPoint,in results: [VNRecognizedTextObservation]) -> VNRecognizedTextObservation? {
        return results.reduce(results.first) { partialResult, observation in
            guard let currResult = partialResult else { return partialResult }
            let currResultPoint = CGPoint(x: currResult.boundingBox.midX, y: currResult.boundingBox.midY)
            let observationPoint = CGPoint(x: observation.boundingBox.midX, y: observation.boundingBox.midY)
            let currIsCloserToPoint = point.isCloser(to: currResultPoint, than: observationPoint)
            return currIsCloserToPoint ? currResult : observation
        }
    }
}

extension CGPoint {
    func isCloser(to a: CGPoint, than b: CGPoint) -> Bool {
        let aDistance = (a.x - self.x).magnitude + (a.y - self.y).magnitude
        let bDistance = (b.x - self.x).magnitude + (b.y - self.y).magnitude
        
        return aDistance < bDistance ? true : false
    }
    
    
}

protocol VNTextDetectorDelegate {
    var imageOrientation: CGImagePropertyOrientation { get set }
    var recognitionLevel: VNRequestTextRecognitionLevel { get set }
    func detectText(request: VNRequest, error: Error?)
    func getRegionOfInterest() -> CGRect
}
