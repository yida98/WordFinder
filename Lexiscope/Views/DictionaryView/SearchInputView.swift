//
//  SearchInputView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/25/23.
//

import SwiftUI

struct SearchInputView: View {
    @ObservedObject var viewModel: DictionaryViewModel
    @State var currentWord: String?
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                ForEach(viewModel.retrieveEntryResults().indices, id: \.self) { headwordEntryIndex in
                    DefinitionView(viewModel: viewModel.makeDefinitionViewModel(with: viewModel.retrieveEntryResults()[headwordEntryIndex]),
                                   focusedWord: $currentWord)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
}
