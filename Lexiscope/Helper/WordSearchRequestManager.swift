//
//  WordSearchRequestManager.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/10/22.
//

import Foundation
import Combine
import SwiftUI

class WordSearchRequestManager {
    static let shared = WordSearchRequestManager()
    var requestStream: CurrentValueSubject<String, Never>
    var requestClusterStream: CurrentValueSubject<String, Never>
    var wordSearchRequestSubscriber = Set<AnyCancellable>()
    
    private init() {
        self.requestStream = CurrentValueSubject<String, Never>("")
        self.requestClusterStream = CurrentValueSubject<String, Never>("")
    }
    
    func clusterStream() -> AnyPublisher<String, Never> {
        return requestClusterStream.eraseToAnyPublisher()
    }
    
    func stream() -> AnyPublisher<String, Never> {
        return requestStream.eraseToAnyPublisher()
    }
    
    func addPublisher(_ publisher: AnyPublisher<String, Never>, to stream: Stream = .single) {
        var requestStream: ReferenceWritableKeyPath<WordSearchRequestManager, String>
        switch stream {
        case .cluster:
            requestStream = \WordSearchRequestManager.requestClusterStream.value
        default:
            requestStream = \WordSearchRequestManager.requestStream.value
        }
        publisher
            .assign(to: requestStream, on: self)
            .store(in: &wordSearchRequestSubscriber)
    }
    
    enum Stream {
        case single
        case cluster
    }
}
