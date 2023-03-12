//
//  SavedWordsView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/17/23.
//

import SwiftUI

struct SavedWordsView: View {
    @ObservedObject var viewModel: SavedWordsViewModel
    @Binding var text: String
    @State var previousTitle: String = ""
    
    var body: some View {
        ScrollViewReader { reader in
            ZStack {
                ScrollView(showsIndicators: false) {
                    if viewModel.vocabulary == nil {
                        Image(systemName: "text.book.closed")
                            .opacity(0.5)
                    } else {
                        ForEach(filteredSectionsDisplay(), id: \.self) { key in
                            Section {
                                ForEach(filteredDisplay(at: key)) { entry in
                                    DefinitionView(viewModel: DefinitionViewModel(headwordEntry: entry.getHeadwordEntry(),
                                                                                  saved: true,
                                                                                  expanded: false),
                                                   spacing: 3)
                                    .definitionCard()
                                    .onTapGesture {
                                        viewModel.presentingVocabularyEntry = entry
                                        if viewModel.presentingVocabularyEntry != nil {
                                            viewModel.isPresenting = true
                                        }
                                    }
                                    .id(entry.word)
                                }
                            } header: {
                                HStack {
                                    Text("\(key.uppercased())")
                                        .font(.footnote)
                                        .bold()
                                        .foregroundColor(.verdigris) // primary
                                    Spacer()
                                }
                            }.id(key)
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
                HStack {
                    Spacer()
                    SectionedScrollView(sectionTitles: filteredSectionsDisplay(), scrollProxy: reader, previousTitle: $previousTitle)
                }
            }
            .sheet(isPresented: $viewModel.isPresenting, onDismiss: {
                if let entry = viewModel.presentingVocabularyEntry {
                    DataManager.shared.resaveVocabularyEntry(entry)
                }
            }, content: {
                if let entry = viewModel.presentingVocabularyEntry {
                    FullSavedWordView(viewModel: FullSavedWordViewModel(headwordEntry: entry.getHeadwordEntry(),
                                                                     saved: true))
                } else {
                    EmptyView()
                }
            })
        }
    }
    
    private func handleTap(on word: String?, scrollProxy: ScrollViewProxy) {
        if let word = word {
            scrollProxy.scrollTo(word, anchor: .top)
        }
    }
    
    private func filteredDisplay(at key: String) -> [VocabularyEntry] {
        let filteredEntries = viewModel.vocabularyDictionary![key]!.filter {
            if let word = $0.word {
                return word.lowercased().hasPrefix(text.lowercased())
            }
            return false
        }
        return filteredEntries
    }
    
    private func filteredSectionsDisplay() -> [String] {
        var filteredSections = viewModel.sectionTitles ?? [String]()
        if let sectionTitles = viewModel.sectionTitles, text.count > 0 {
            filteredSections = sectionTitles.filter { text.lowercased().hasPrefix($0) }
        }
        return filteredSections
    }
}

extension VocabularyEntry {
    func getHeadwordEntry() -> HeadwordEntry {
        DataManager.decodedHeadwordEntryData(self.headwordEntry!)
    }
}
