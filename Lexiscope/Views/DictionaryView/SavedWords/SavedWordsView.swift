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
            ZStack {
                ScrollView(showsIndicators: false) {
                    if viewModel.vocabulary == nil {
                        Image(systemName: "text.book.closed")
                            .opacity(0.5)
                    } else {
                        ForEach(viewModel.sectionTitles!, id: \.self) { key in
                            Section {
                                ForEach(viewModel.vocabularyDictionary![key]!) { entry in
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
                HStack {
                    Spacer()
                    if viewModel.sectionTitles != nil {
                        SectionedScrollView(viewModel: viewModel, sectionTitles: viewModel.sectionTitles!, scrollProxy: reader)
                    }
                }
            }
        }
    }
    
    private func handleTap(on vocabularyEntry: VocabularyEntry, scrollProxy: ScrollViewProxy) {
        viewModel.expanded.toggle()
        scrollProxy.scrollTo(vocabularyEntry.word, anchor: .top)
    }
}
