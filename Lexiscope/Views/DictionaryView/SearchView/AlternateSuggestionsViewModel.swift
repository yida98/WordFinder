//
//  AlternateSuggestionsViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 6/28/23.
//

import Foundation
import Combine

class AlternateSuggestionsViewModel: ObservableObject {
    @Published var suggestions: [String]
    private var selectedWordPublisher: PassthroughSubject<String, Never>
    
    init(suggestions: [String]) {
        self.suggestions = suggestions
        self.selectedWordPublisher = PassthroughSubject<String, Never>()
        
        WordSearchRequestManager.shared.addPublisher(selectedWordPublisher.eraseToAnyPublisher())
    }
    
    func handleTap(at index: Int) {
        selectedWordPublisher.send(suggestions[index])
    }
}
