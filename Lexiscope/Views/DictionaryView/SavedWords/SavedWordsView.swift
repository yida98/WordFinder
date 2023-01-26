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
                                        .font(.footnote)
                                        .bold()
                                        .foregroundColor(.thistle)
                                    Spacer()
                                }
                            }.id(key)
                        }
                    }
                }
                .padding(50)
                .padding(.top, -50)
                HStack {
                    Spacer()
                    SectionedScrollView(viewModel: viewModel, sectionTitles: filteredSectionsDisplay(), scrollProxy: reader)
                }
            }
        }
    }
    
    private func handleTap(on vocabularyEntry: VocabularyEntry, scrollProxy: ScrollViewProxy) {
        viewModel.expanded.toggle()
        scrollProxy.scrollTo(vocabularyEntry.word, anchor: .top)
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
