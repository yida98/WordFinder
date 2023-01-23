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
        ScrollView {
            if viewModel.vocabulary == nil {
                Image(systemName: "text.book.closed")
                    .opacity(0.5)
            } else {
                ForEach(viewModel.vocabulary!) { vocabularyEntry in
                    SavedWordsCell(vocabularyEntry: vocabularyEntry)
                }
            }
        }
    }
}
