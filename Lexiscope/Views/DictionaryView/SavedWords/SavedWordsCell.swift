//
//  SavedWordsCell.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/17/23.
//

import SwiftUI

struct SavedWordsCell: View {
    var word: String
    var body: some View {
        NavigationLink {
            DefinitionView(viewModel: DefinitionViewModel())
        } label: {
            Text(word)
        }
    }
}

struct SavedWordsCell_Previews: PreviewProvider {
    static var previews: some View {
        SavedWordsCell(word: "blood")
    }
}
