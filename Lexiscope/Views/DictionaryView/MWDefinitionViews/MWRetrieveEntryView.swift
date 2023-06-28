//
//  MWRetrieveEntryView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 6/26/23.
//

import SwiftUI

struct MWRetrieveEntryView: View {
    @ObservedObject var viewModel: MWRetrieveGroupViewModel
    var familiar: Bool = false
    
    @State var presentAlert: Bool = false
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                // MARK: - Header
                HStack {
                    Text(viewModel.group.getWord()) // TODO: Headword text decoration (i.e. a*mo*ni*um)
                    // TODO: Function label will change depending on the scroll position
    //                if let functionLabel = retrieveEntry.fl {
    //                    Text(functionLabel) // TODO: Function label style
    //                }
                    Spacer()
                    
                    Button {
                        if viewModel.saved {
                            presentAlert = true
                        } else {
                            viewModel.bookmark()
                        }
                    } label: {
                        if familiar {
                            Star(cornerRadius: 1)
                                .fill(Color.darkSkyBlue)
                                .frame(width: 20, height: 20)
                        } else {
                            Image(viewModel.saved ? "bookmark.fill" : "bookmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                        }
                    }.alert(isPresented: $presentAlert) {
                        Alert(title: Text("Unbookmarking"), message: Text("Are you sure you want to unbookmark \(viewModel.group.getWord())"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Unbookmark")) {
                            viewModel.bookmark()
                        })
                    }
                }
                
                Divider()
                
                // MARK: - Pronunciation
                // TODO: Prounciation style
                if !viewModel.group.allPronunciations().isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Text("/")
                            ForEach(viewModel.group.allPronunciations().indices, id: \.self) { pronunciationIndex in
                                Button {
                                    DataManager.shared.pronounce(viewModel.group.allPronunciations()[pronunciationIndex].audioFile)
                                } label: {
                                    Text(viewModel.group.allPronunciations()[pronunciationIndex].writtenPronunciation!)
                                        .font(.caption)
                                        .foregroundColor(.init(white: 0.5)) // neutral
                                        .padding(2)
                                        .background(viewModel.group.allPronunciations()[pronunciationIndex].hasAudio ? Color.verdigris.opacity(0.3) : Color.clear) // primary
                                        .cornerRadius(4)
                                }
                            }
                            Text("/")
                        }
                    }
                }
                
                ScrollView(showsIndicators: false) {
                    if let label = viewModel.group.allInflectionLabels(), !label.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            Text(label.localizedTokenizedString()) // TODO: Small size
                        }
                        
                        Divider()
                    }
                    
                    ForEach(viewModel.group.entries) { entry in
                        MWRetrieveHeadwordView(retrieveEntry: entry)
                        Divider()
                    }
                }
                
                Text("some decorative text to balanace out the UI")
            }
        }
    }
}
