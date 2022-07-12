//
//  CameraViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2022-05-03.
//

import SwiftUI
//import Vision
import Combine
import AVFoundation

class CameraViewModel: ObservableObject {
    @Published var coords: [CGRect] = [CGRect]()
    @Published var bufferSize: CGSize = CGSize(width: 1, height: 1) {
        willSet {
            trueCameraHeight = Constant.screenBounds.width / (newValue.height / newValue.width)
        }
    }
    
    @Published var trueCameraHeight: CGFloat = 1
    
    @Published var word: String = ""
//    @Published var headwordEntry: HeadwordEntry? {
//        willSet {
//            loading = false
//        }
//    }
    
    @Published var loading: Bool = false
    @Published var allowsCameraUsage: Bool = true
    
    static let viewportSize = CGSize(width: Constant.screenBounds.width * 0.3,
                                     height: 65)
    static let boundingBoxPadding: CGFloat = 4
    static let boundingBoxCornerRadius: CGFloat = 6
    static let viewFurtherInset: CGFloat = 50
    
    static let buttonSize = CGSize(width: 90, height: 40)
    static let buttonPadding: CGFloat = 50
    static let buttonCornerRadius: CGFloat = 20
    
    var cancellableSet = Set<AnyCancellable>()
    
    init() {
        CameraViewModel.requestCameraAccess { success in
            Just(success)
                .receive(on: RunLoop.main)
                .assign(to: &self.$allowsCameraUsage)
        }
    }
    
    func lookup() {
        if word != "" {
            loading = true

//            URLTask.shared.get(word: word)
//                .receive(on: RunLoop.main)
//                .sink(receiveCompletion: { completion in
//                    debugPrint("completed")
//                }, receiveValue: { entry in
//                    if let newEntry = entry {
//                        self.headwordEntry = newEntry
//                    } else {
//                        self.headwordEntry = nil
//                    }
//                })
//                .store(in: &cancellableSet)
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
}
