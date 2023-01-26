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
        VStack {
            DefinitionView(viewModel: viewModel.getDefinitionViewModel(),
                           expanded: $viewModel.expanded,
                           focusedWord: $currentWord)
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 50)
    }
}
