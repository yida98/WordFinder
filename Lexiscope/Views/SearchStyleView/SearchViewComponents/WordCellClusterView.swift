//
//  WordCellClusterView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/10/22.
//

import SwiftUI

struct WordCellClusterView: View {
    @ObservedObject var viewModel: SearchViewModel
    var scrollProxy: ScrollViewProxy
    var body: some View {
        HStack(spacing: -4) {
            ForEach(0..<viewModel.individualWords.count, id: \.self) { wordIndex in
                WordCell(word: viewModel.individualWords[wordIndex],
                         selected: wordIndex == viewModel.selectedWordIndex)
                    .onAppear {
                        withAnimation {
                            scrollProxy.scrollTo(wordIndex, anchor: .center)
                        }
                    }
                    .onTapGesture {
                        viewModel.handleTap(at: wordIndex)
                        withAnimation {
                            scrollProxy.scrollTo(wordIndex, anchor: .center)
                        }
                    }
            }
        }
    }
}
