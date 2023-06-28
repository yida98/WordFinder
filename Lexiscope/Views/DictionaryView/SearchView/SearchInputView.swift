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
                            if let entryViewModel = definitionViewModel(at: headwordEntryIndex) {
                                MWRetrieveEntryView(viewModel: entryViewModel)
                                    .definitionCard()
                                    .onTapGesture {
                                        viewModel.toggleExpanded(at: headwordEntryIndex)
                                    }
                                    .id(String(headwordEntryIndex + 1))
                            } else {
                                EmptyView()
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                } else {
                    VStack {
                        if let suggestions = viewModel.suggestions {
                            Text("Did you mean:")
                            ForEach(suggestions.indices, id: \.self) { suggestionIndex in
                                Text(suggestions[suggestionIndex])
                            }
                        } else {
                            Text("NO RESULTS")
                                .placeholder()
                        }
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
    
    private func definitionViewModel(at index: Int) -> MWRetrieveGroupViewModel? {
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
