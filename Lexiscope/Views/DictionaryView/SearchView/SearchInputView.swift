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
                if let results = viewModel.retrieveEntry, !results.entries.isEmpty {
                    ScrollView(showsIndicators: false) {
                        ForEach(results.entries.indices, id: \.self) { headwordEntryIndex in
                            MWRetrieveEntryView(group: results.entries[headwordEntryIndex])
                                .definitionCard()
                                .id(String(headwordEntryIndex + 1))
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                } else {
                    VStack {
                        Text("No results")
                            .placeholder()
                        Text("Try another search")
                            .placeholder()
                    }
                }
                
//                if viewModel.retrieveEntryResults().isEmpty {
//                    Text("No results")
//                        .placeholder()
//                } else {
//                    ScrollView(showsIndicators: false) {
//                        ForEach(viewModel.retrieveEntryResults().indices, id: \.self) { headwordEntryIndex in
//                            if let definitionViewModel = definitionViewModel(at: headwordEntryIndex) {
//                                DefinitionView(viewModel: definitionViewModel, spacing: 3)
//                                    .definitionCard()
//                                    .onTapGesture {
//                                        viewModel.toggleExpanded(at: headwordEntryIndex)
//                                    }
//                                    .id(String(headwordEntryIndex + 1))
//                            } else {
//                                EmptyView()
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 40)
//                    .padding(.bottom, 50)
//                }
                HStack {
                    Spacer()
                    SectionedScrollView(sectionTitles: viewModel.retrieveEntryResultSectionTitles(),
                                        scrollProxy: proxy,
                                        previousTitle: $previousTitle)
                }
            }
        }
    }
    
    private func definitionViewModel(at index: Int) -> DefinitionViewModel? {
        if index < viewModel.retrieveResultsDefinitionVMs.count {
            return viewModel.retrieveResultsDefinitionVMs[index]
        }
        return nil
    }
}

extension Text {
    func placeholder() -> some View {
        return self
            .font(.largeTitleQuiz.bold())
            .foregroundStyle(.thickMaterial)
    }
}
