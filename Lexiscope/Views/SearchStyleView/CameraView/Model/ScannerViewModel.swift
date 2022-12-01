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
    var imageOrientation: CGImagePropertyOrientation = .right
    var recognitionLevel: VNRequestTextRecognitionLevel = .accurate
    
    @Published var coordinates: CGRect = .zero
    @Published var resultCluster: String = ""
    private var inputSubscriber: AnyCancellable?
    
    init(input: AnyPublisher<UIImage?, Never>) {
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
                let bounds = Self.boundingBox(forRegionOfInterest: result.boundingBox, fromOutput: .zero)
                DispatchQueue.main.async { [self] in
                    coordinates = bounds
                    resultCluster = recognizedText.string
                }
            }
        }
    }
    
    /// Calculate the `regionOfInterest` in the `bufferSize` normalized for the screen size
    private static func normalizeBounds(for regionOfInterest: CGRect, in bufferSize: CGSize) -> CGRect {
        
        var rect = regionOfInterest
        let width = Constant.screenBounds.width
        let height = width / (bufferSize.height / bufferSize.width)
        rect.origin = CGPoint(x: rect.minX/width, y: rect.minY/height)
        rect.size = CGSize(width: rect.size.width/width, height: rect.size.height/height)
        return rect
    }
    
    private static func normalizeSize(for regionOfInterest: CGSize, in bufferSize: CGSize) -> CGSize {
        
        var size = regionOfInterest
        let width = Constant.screenBounds.width
        let height = width / (bufferSize.height / bufferSize.width)

        size = CGSize(width: size.width/width, height: size.height/height)
        
        return size
    }
    
    fileprivate static func boundingBox(forRegionOfInterest: CGRect, fromOutput size: CGSize) -> CGRect {
        
        let imageWidth = size.width
        let imageHeight = size.height
        
        let imageRatio = imageWidth / imageHeight
        let width = imageWidth
        let height = width / imageRatio
        
        // Begin with input rect.
        var rect = forRegionOfInterest
        
        // FIXME: Figure out actual rotation
//        let bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
        let uiRotationTransform = CGAffineTransform(translationX: 1, y: 1).rotated(by: CGFloat.pi)
//        let transform = bottomToTopTransform.concatenating(uiRotationTransform)
        rect = rect.applying(uiRotationTransform)
        
        rect.size.height *= height
        rect.size.width *= width
        
        rect.origin.x = (rect.origin.x) * width
        rect.origin.y = rect.origin.y * height

        return rect
    }
}
