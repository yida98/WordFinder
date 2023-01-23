//
//  SavedWordsCell.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/17/23.
//

import SwiftUI

struct SavedWordsCell: View {
    var vocabularyEntry: VocabularyEntry
    var body: some View {
        NavigationLink {
            DefinitionView(viewModel: DefinitionViewModel(vocabularyEntry: vocabularyEntry))
        } label: {
            Text(vocabularyEntry.word ?? "")
        }
    }
}
