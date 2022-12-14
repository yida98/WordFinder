//
//  WordCellClusterView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/10/22.
//

import SwiftUI

struct WordCellClusterView: View {
    @ObservedObject var viewModel: SearchViewModel
    var body: some View {
        HStack(spacing: -10) {
            ForEach(0..<viewModel.individualWords.count, id: \.self) { wordIndex in
                WordCell(word: viewModel.individualWords[wordIndex],
                         selected: wordIndex == viewModel.selectedWordIndex)
                    .onTapGesture {
                        viewModel.handleTap(at: wordIndex)
                    }
            }
        }
    }
}
