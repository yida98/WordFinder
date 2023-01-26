//
//  SearchInputView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/25/23.
//

import SwiftUI

struct SearchInputView: View {
    @ObservedObject var viewModel: DictionaryViewModel
    
    var body: some View {
        VStack {
            DefinitionView(viewModel: viewModel.getDefinitionViewModel(), expanded: $viewModel.expanded)
        }
        .padding(50)
        .padding(.top, -50)
    }
}
