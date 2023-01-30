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
    
    @Published var headwordEntry: HeadwordEntry
    @Published var saved: Bool?
    
    init(headwordEntry: HeadwordEntry, saved: Bool) {
        self.headwordEntry = headwordEntry
        self.saved = saved
    }
    
    var allSortedPronunciations: [InlineModel1] {
        if let pronunciations = headwordEntry.allPronunciations() {
            let nonnilPronunciations = pronunciations
                .filter { $0.phoneticSpelling != nil }
            var uniquePronunciationStrings = Set<String>()
            var uniquePronunciations = [InlineModel1]()
            for pronunciation in nonnilPronunciations {
                if !uniquePronunciationStrings.contains(pronunciation.phoneticSpelling!) {
                    uniquePronunciations.append(pronunciation)
                }
                uniquePronunciationStrings.insert(pronunciation.phoneticSpelling!)
            }
            uniquePronunciations.sort(by: { $0.phoneticSpelling! < $1.phoneticSpelling! })
            return uniquePronunciations
        }
        return []
    }
    
    func lexicalEntries(for headwordEntry: HeadwordEntry) -> [LexicalEntry]? {
        return headwordEntry.lexicalEntries
    }
    
    func bookmarkWord() {
        if DataManager.shared.fetchVocabularyEntry(for: headwordEntry.word) != nil {
            saved = false
            DataManager.shared.deleteVocabularyEntry(for: headwordEntry.word)
        } else {
            saved = true
            let encoder = JSONEncoder()
            do {
                let headwordData = try encoder.encode(headwordEntry)
                DataManager.shared.saveVocabularyEntryEntity(headwordEntry: headwordData, word: headwordEntry.word)
                
                for url in headwordEntry.allPronunciationURLs() {
                    URLTask.shared.downloadAudioFileData(from: url) { data, urlResponse, error in
                        if let data = data {
                            DataManager.shared.savePronunciation(url: url as NSURL, pronunciation: data)
                        }
                    }
                }
            } catch {
                fatalError("Cannot encode \(headwordEntry) entry into data.")
            }
        }
    }
    
    private var soundPlayer: AVAudioPlayer?
    
    func pronounce(_ string: String?) {
        guard let string = string, let url = URL(string: string) else { return }
        pronounce(url: url)
    }
    
    func pronounce(url: URL) {
        guard let pronunciation = DataManager.shared.fetchPronunciation(for: url as NSURL) as? Pronunciation, let pronunciationData = pronunciation.pronunciation else {
            URLTask.shared.downloadAudioFileData(from: url) { [weak self] data, urlResponse, error in
                if let data = data {
                    self?.playSound(from: data)
                }
            }
            return
        }
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

extension Sense {
    func allSenses() -> [Sense]? {
        guard let subsenses = self.subsenses else { return [self] }
        var result = [self]
        result.append(contentsOf: subsenses.compactMap {
            return $0.allSenses()
        }.flatMap { $0 })
        return result
    }
}

extension LexicalEntry {
    func allSenses() -> [Sense] {
        self.entries.compactMap { $0.senses?.compactMap { $0.allSenses() }.flatMap { $0 } }.flatMap { $0 }
    }
}

extension HeadwordEntry {
    func allPronunciations() -> [InlineModel1]? {
        let phoneticSpellings = self.lexicalEntries.compactMap {
            $0.entries.compactMap {
                $0.pronunciations
            }.flatMap { $0 }
        }.flatMap { $0 }
        
        return phoneticSpellings.count > 0 ? phoneticSpellings : nil
    }
}

extension InlineModel1 {
    var hasAudio: Bool {
        return self.audioFile != nil
    }
}
