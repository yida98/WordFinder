//
//  SavedWordsView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/17/23.
//

import SwiftUI

struct SavedWordsView: View {
    @ObservedObject var viewModel: SavedWordsViewModel
    
    var body: some View {
        ScrollViewReader { reader in
            ScrollView(showsIndicators: false) {
                if viewModel.vocabulary == nil {
                    Image(systemName: "text.book.closed")
                        .opacity(0.5)
                } else {
                    ForEach(alphabetizedKeys(), id: \.self) { key in
                        Section {
                            ForEach(alphabetizedDictionary()[key]!) { entry in
                                DefinitionView(viewModel: DefinitionViewModel(vocabularyEntry: entry),
                                               expanded: $viewModel.expanded)
                                .id(entry.word)
                                .onTapGesture(perform: {
                                    handleTap(on: entry, scrollProxy: reader)
                                })
                            }
                        } header: {
                            HStack {
                                Text("\(key.uppercased())")
                                Spacer()
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    private func alphabetizedDictionary() -> [Character: [VocabularyEntry]] {
        guard let vocabulary = viewModel.vocabulary else { return [:] }
        
        var dict = [Character: [VocabularyEntry]]()
        for vocabularyEntry in vocabulary {
            let firstLetter = vocabularyEntry.word!.first!
            if dict.keys.contains(firstLetter) {
                var array = dict[firstLetter]
                array!.append(vocabularyEntry)
                array!.sort(by: { $0.word! < $1.word! })
                dict[firstLetter] = array
            } else {
                dict[firstLetter] = [vocabularyEntry]
            }
        }
        
        return dict
    }
    
    private func alphabetizedKeys() -> [Character] {
        return alphabetizedDictionary().keys.sorted()
    }
    
    private func alphabetizedVocabulary() -> [[VocabularyEntry]] {
        var result = [[VocabularyEntry]]()
        for key in alphabetizedKeys() {
            result.append(alphabetizedDictionary()[key]!)
        }
        return result
    }
    
    private func handleTap(on vocabularyEntry: VocabularyEntry, scrollProxy: ScrollViewProxy) {
        viewModel.expanded.toggle()
        scrollProxy.scrollTo(vocabularyEntry.word, anchor: .top)
    }
}
