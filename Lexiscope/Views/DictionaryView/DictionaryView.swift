//
//  DictionaryView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/6/22.
//

import Foundation
import SwiftUI

struct DictionaryView: View {
    @StateObject var viewModel: DictionaryViewModel = DictionaryViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.showingVocabulary) {
            SavedWordsView()
                .padding(70)
                .padding(.bottom, -40)
                .tag(true)
            
            DefinitionView(viewModel: viewModel.getDefinitionViewModel())
                .padding(70)
                .padding(.bottom, -40)
                .tag(false)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .padding(.bottom, 20)
    }
}
