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
        VStack {
            HStack {
                Text(vocabularyEntry.word ?? "")
                Spacer()
            }
            Spacer()
        }
        .padding()
        .background(Color(white: 0.9))
        .mask {
            RoundedRectangle(cornerRadius: 14)
        }
    }
}
