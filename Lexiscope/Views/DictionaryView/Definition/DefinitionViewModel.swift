//
//  DefinitionViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/14/22.
//

import Foundation
import Combine
import AVFoundation
import SwiftUI

class DefinitionViewModel: ObservableObject {
    
    @Published var vocabularyEntry: VocabularyEntry? {
        didSet {
            if let vocabularyEntry = vocabularyEntry {
                self.saved = vocabularyEntry.saved
            }
        }
    }
    @Published var saved: Bool?
    
    init(vocabularyEntry: VocabularyEntry? = nil) {
        if let vocabularyEntry = vocabularyEntry {
            self.vocabularyEntry = vocabularyEntry
        }
    }
    
    var retrieveEntry: RetrieveEntry? {
        if let vocabularyEntry = vocabularyEntry, let retrieveEntry = vocabularyEntry.retrieveEntry {
            return DataManager.decodedRetrieveEntryData(retrieveEntry)
        }
        return nil
    }
    
    func bookmarkWord() {
        if let vocabularyEntry = vocabularyEntry, let currWord = vocabularyEntry.word {
            if vocabularyEntry.saved {
                DataManager.shared.unbookmarkWord(currWord)
            } else {
                DataManager.shared.bookmarkNewWord(currWord)
            }
            saved = vocabularyEntry.saved
        }
    }
    
    private var soundPlayer: AVAudioPlayer?
    
    func pronounce() {
        guard let vocabularyEntry = vocabularyEntry, let pronunciationData = vocabularyEntry.pronunciation else { return }
        playSound(from: pronunciationData)
    }
    
    private func playSound(from data: Data) {
        do {
            soundPlayer = try AVAudioPlayer(data: data)
            soundPlayer?.prepareToPlay()
            soundPlayer?.volume = 1
            soundPlayer?.play()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
}
