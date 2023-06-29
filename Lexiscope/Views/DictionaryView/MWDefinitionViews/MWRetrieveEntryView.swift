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
    @State var previousTitle: String = ""
    var body: some View {
        ScrollViewReader { proxy in
            ZStack {
                VStack(spacing: 10) {
                    VStack(spacing: 6) {
                        // MARK: - Header
                        HStack {
                            Text(viewModel.group.getWord()) // TODO: Headword text decoration (i.e. a*mo*ni*um)
                                .font(viewModel.expanded ? .largeTitlePrimary : .titlePrimary)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .textSelection(.enabled)
                                .foregroundColor(.pineGreen) // primaryDark
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
                        if !viewModel.group.allPronunciations().isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    Text("/")
                                        .font(.caption)
                                        .foregroundColor(.init(white: 0.5)) // neutral
                                    ForEach(viewModel.group.allPronunciations().indices, id: \.self) { pronunciationIndex in
                                        if let writtenPronunciation = viewModel.group.allPronunciations()[pronunciationIndex].writtenPronunciation {
                                            Button {
                                                DataManager.shared.pronounce(viewModel.group.allPronunciations()[pronunciationIndex].audioFile)
                                            } label: {
                                                Text(writtenPronunciation)
                                                    .font(.caption)
                                                    .foregroundColor(.init(white: 0.5)) // neutral
                                                    .padding(2)
                                                    .background(viewModel.group.allPronunciations()[pronunciationIndex].hasAudio ? Color.verdigris.opacity(0.3) : Color.clear) // primary
                                                    .cornerRadius(4)
                                            }
                                        }
                                    }
                                    Text("/")
                                        .font(.caption)
                                        .foregroundColor(.init(white: 0.5)) // neutral
                                }
                            }
                        }
                    }
                    ScrollView(showsIndicators: false) {
                        if viewModel.expanded {
                            VStack(spacing: 10) {
                                ForEach(viewModel.group.entries.indices, id: \.self) { entryIndex in
                                    MWRetrieveHeadwordView(retrieveEntry: viewModel.group.entries[entryIndex])
                                        .id(String(entryIndex + 1))
                                    if entryIndex < viewModel.group.entries.count - 1 {
                                        Divider()
                                    }
                                }
                                if !viewModel.group.allEtymology().isEmpty {
                                    Divider()
                                    Etymology(et: viewModel.group.allEtymology())
                                }
                            }
                        } else {
                            if let shortDef = viewModel.group.allShortDefs().first {
                                HStack {
                                    Text(shortDef)
                                        .font(.bodyPrimary)
                                        .foregroundColor(Color(white: 0.4))
                                    Spacer()
                                }
                            }
                        }
                    }
                    Divider()
                    HStack {
                        Text("some decorative text to balanace out the UI")
                            .font(.captionPrimary)
                            .foregroundColor(.verdigris)
                        Spacer()
                    }
                }
                
                if viewModel.group.entries.count > 1 {
                    HStack {
                        Spacer()
                        SectionedScrollView(sectionTitles: entryScrollSectionTitles(), scrollProxy: proxy, previousTitle: $previousTitle)
                    }
                    .offset(x: 50) // TODO: Magic number
                }
            }
        }
    }
    
    private func entryScrollSectionTitles() -> [String] {
        viewModel.group.entries.reduce([String]()) { valueSoFar, newValue in
            var newArray = valueSoFar
            newArray.append(String(valueSoFar.count + 1))
            return newArray
        }
    }
}

struct Etymology: View {
    var et: [(String, MWEtymology)]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(et.indices, id: \.self) { etIdx in
                HStack {
                    Text("Etymology")
                        .font(.titlePrimary)
                        .foregroundColor(.verdigrisDark)
                    Spacer()
                }
                HStack {
                    Text(et[etIdx].0)
                        .font(.headlinePrimary)
                        .foregroundColor(Color.pineGreen)
                    Spacer()
                }
                Text(et[etIdx].1.textValue().localizedTokenizedString())
                    .senseParagraph()
            }
        }
    }
}
