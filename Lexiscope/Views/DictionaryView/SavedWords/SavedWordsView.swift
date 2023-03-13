//
//  SavedWordsView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/17/23.
//

import SwiftUI

struct SavedWordsView: View {
    @ObservedObject var viewModel: SavedWordsViewModel
    @State var previousTitle: String = ""
    
    var body: some View {
        ScrollViewReader { reader in
            ZStack {
                ScrollView(showsIndicators: false) {
                    if viewModel.vocabulary == nil {
                        Image(systemName: "text.book.closed")
                            .opacity(0.5)
                    } else {
                        ForEach(viewModel.sectionTitles ?? [String](), id: \.self) { key in
                            Section {
                                ForEach(display(at: key)) { entry in
                                    DefinitionView(viewModel: DefinitionViewModel(headwordEntry: entry.getHeadwordEntry(),
                                                                                  saved: true,
                                                                                  expanded: false),
                                                   spacing: 3,
                                                   familiar: entry.recallDates?.count ?? 0 >= 4)
                                    .definitionCard(familiar: entry.recallDates?.count ?? 0 >= 4)
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
                    SectionedScrollView(sectionTitles: viewModel.sectionTitles ?? [String](), scrollProxy: reader, previousTitle: $previousTitle)
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
    
    private func display(at key: String) -> [VocabularyEntry] {
        guard let dictionary = viewModel.vocabularyDictionary, let result = dictionary[key] else {
            return [VocabularyEntry]()
        }
        return result
    }
}

extension VocabularyEntry {
    func getHeadwordEntry() -> HeadwordEntry {
        DataManager.decodedHeadwordEntryData(self.headwordEntry!)
    }
}
