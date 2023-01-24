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
                    ForEach(viewModel.vocabulary!) { vocabularyEntry in
                        DefinitionView(viewModel: DefinitionViewModel(vocabularyEntry: vocabularyEntry),
                                       expanded: $viewModel.expanded)
                        .id(vocabularyEntry.word)
                        .onTapGesture(perform: {
                            handleTap(on: vocabularyEntry, scrollProxy: reader)
                        })
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
