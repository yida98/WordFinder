//
//  TextDetector.swift
//  Lexiscope
//
//  Created by Yida Zhang on 11/28/22.
//

import Foundation
import Vision

struct TextDetector {
    static func detect(from imageData: Data, request: VNRequestCompletionHandler?) {
        let handler = VNImageRequestHandler(data: imageData, orientation: .right
        
        )
        let request = VNRecognizeTextRequest(completionHandler: request)
        
        request.recognitionLevel = .accurate
        do {
            try handler.perform([request])
        } catch {
            debugPrint("Could not handle \(request).")
        }
    }
    
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
