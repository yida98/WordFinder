//
//  WordSearchRequestManager.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/10/22.
//

import Foundation
import Combine

class WordSearchRequestManager {
    static let shared = WordSearchRequestManager()
    var requestStream: CurrentValueSubject<String, Never>
    var wordSearchRequestSubscriber = Set<AnyCancellable>()
    
    init() {
        self.requestStream = CurrentValueSubject<String, Never>("")
    }
    
    func stream() -> AnyPublisher<String, Never> {
        return requestStream.eraseToAnyPublisher()
    }
    
    func addPublisher(_ publisher: AnyPublisher<String, Never>) {
        publisher
            .assign(to: \.requestStream.value, on: self)
            .store(in: &wordSearchRequestSubscriber)
    }
}
