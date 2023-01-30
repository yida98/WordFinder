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
    @State var previousTitle: String = ""
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack {
                ScrollView(showsIndicators: false) {
                    ForEach(viewModel.retrieveEntryResults().indices, id: \.self) { headwordEntryIndex in
                        DefinitionView(viewModel: viewModel.makeDefinitionViewModel(with: viewModel.retrieveEntryResults()[headwordEntryIndex]))
                        .id(String(headwordEntryIndex + 1))
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
                HStack {
                    Spacer()
                    SectionedScrollView(sectionTitles: viewModel.retrieveEntryResultSectionTitles(),
                                        scrollProxy: proxy,
                                        previousTitle: $previousTitle)
                }
            }
        }
    }
}
