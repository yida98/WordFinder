//
//  DictionaryView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/6/22.
//

import Foundation
import SwiftUI

struct DictionaryView: View {
    @ObservedObject var viewModel: DictionaryViewModel
    @FocusState private var searchIsFocused: Bool
    @Binding var searchOpen: Bool
    
    init(viewModel: DictionaryViewModel, searchOpen: Binding<Bool>) {
        self.viewModel = viewModel
        self._searchOpen = searchOpen
        UIToolbar.appearance().setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        UIToolbar.appearance().clipsToBounds = true
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    HStack {
                        TextField("Search from \(viewModel.vocabularySize)", text: $viewModel.textFilter) {
                            viewModel.handleNewRequest(viewModel.textFilter)
                            viewModel.textFilter = ""
                        }
                        .foregroundColor(.verdigrisDark)
                        .focused($searchIsFocused)
                        .submitLabel(viewModel.textFilter.count > 0 ? .search : .done)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button {
                                    UIApplication.shared.endEditing()
                                } label: {
                                    Image(systemName: "keyboard.chevron.compact.down.fill")
                                        .foregroundColor(.boyBlue)
                                        .padding(4)
                                        .padding(.horizontal, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(.thickMaterial)
                                                .shadow(color: .verdigris.opacity(0.5), radius: 3, y: 2)
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.white)
                                                }
                                        
                                        )
                                }
                            }
                        }
                        if viewModel.textFilter.count > 0 {
                            Button {
                                searchIsFocused = false
                                viewModel.textFilter = ""
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.verdigris) // primary
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.3))
                    .mask {
                        RoundedRectangle(cornerRadius: 16)
                    }
                    .onTapGesture {
                        withAnimation {
                            searchOpen = false
                            viewModel.showingVocabulary = true
                        }
                    }
                    Toggle("Familiar", isOn: $viewModel.filterFamiliar).toggleStyle(StarToggleStyle())
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                TabView(selection: $viewModel.showingVocabulary) {
                    SavedWordsView(viewModel: viewModel.getSavedWordsViewModel())
                        .tag(true)
                    
                    SearchInputView(viewModel: viewModel)
                        .tag(false)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .animation(.easeIn(duration: 0.5), value: viewModel.showingVocabulary)
                .ignoresSafeArea(.keyboard)
            }
        }
    }
}

struct StarToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Group {
            if configuration.isOn {
                Star(cornerRadius: 1)
                    .fill(Color.verdigris)
                    .frame(width: 20, height: 20)
            } else {
                Star(cornerRadius: 1)
                    .fill(Color.verdigris.opacity(0.5))
                    .frame(width: 20, height: 20)
            }
        }
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }
}
