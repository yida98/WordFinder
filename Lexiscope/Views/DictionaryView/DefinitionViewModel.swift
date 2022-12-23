//
//  DefinitionViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/14/22.
//

import Foundation
import Combine

class DefinitionViewModel: ObservableObject {
    
    @Published var headwordEntry: HeadwordEntry?
    
    init() {
        wordStreamSubscriber = Set<AnyCancellable>()
        subscribeToWordRequestStream()
    }
    
    var wordStreamSubscriber: Set<AnyCancellable>
    func subscribeToWordRequestStream() {
        WordSearchRequestManager.shared.stream().sink(receiveValue: handleNewRequest(_:)).store(in: &wordStreamSubscriber)
    }
    
    private func handleNewRequest(_ word: String?) {
        guard let word = word else { return }
        URLTask.shared.define(word: word)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                debugPrint("completed")
            }, receiveValue: { entry in
                self.headwordEntry = entry
            })
            .store(in: &wordStreamSubscriber)
    }
}
