//
//  DefinitionView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 9/19/22.
//

import SwiftUI

struct DefinitionView: View {
    @ObservedObject var viewModel: DefinitionViewModel
    @Binding var focusedWord: String?
    
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.headwordEntry.word)
                Spacer()
                Button {
                    viewModel.bookmarkWord()
                } label: {
                    Image(systemName: viewModel.saved ?? false ? "bookmark.fill" : "bookmark")
                }
            }
            HStack {
                Text("/")
                ForEach(viewModel.allSortedPronunciations, id: \.phoneticSpelling) { pronunciation in
                    Button {
                        viewModel.pronounce(pronunciation.audioFile)
                    } label: {
                        Text(pronunciation.phoneticSpelling!)
                            .font(.caption2)
                            .foregroundColor(.moodPurple)
                            .padding(4)
                            .background(Color.boyBlue.opacity(0.4))
                            .cornerRadius(4)
                    }
                }
                Text("/")
            }
            ScrollView(showsIndicators: false) {
                ForEach(viewModel.headwordEntry.lexicalEntries) { lexicalEntry in
                    LexicalEntryView(lexicalEntry: lexicalEntry)
                }
            }
        }
        .animation(.default, value: 0.5)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(white: 0.95))
        .mask {
            RoundedRectangle(cornerRadius: 10)
        }
//                ForEach(headwordEntries, id: \.self) { headwordEntry in
//                    HStack {
//                        Text(headwordEntry.word)
//                        Spacer()
//                        Button {
//                            viewModel.bookmarkWord()
//                        } label: {
//                            Image(systemName: viewModel.saved ?? false ? "bookmark.fill" : "bookmark")
//                        }
//                    }
//                    ScrollView(.vertical, showsIndicators: false) {
//                        Text(Self.phoneticString(for: headwordEntry))
//                            .font(.caption2)
//                            .foregroundColor(.moodPurple)
//                        if viewModel.expanded { // TODO: Remove
//                            ForEach(viewModel.lexicalEntries(for: headwordEntry)) { lexicalEntry in
//                                HStack {
//                                    Text(lexicalEntry.lexicalCategory.text.capitalized) /// e.g. preposition, adjective, verb
//                                        .font(.caption)
//                                        .italic()
//                                        .foregroundColor(Color(white: 0.8))
//                                    Spacer()
//                                }
//                                ForEach(lexicalEntry.allSenses().indices, id: \.self) { senseIndex in
//                                    HStack {
//                                        if lexicalEntry.allSenses()[senseIndex].definitions != nil {
//                                            ForEach(lexicalEntry.allSenses()[senseIndex].definitions!, id: \.self) { definition in
//                                                if lexicalEntry.allSenses().count > 1 {
//                                                    VStack {
//                                                        Text("\(senseIndex + 1)")
//                                                            .font(.caption)
//                                                            .foregroundColor(Color(white: 0.6))
//                                                        Spacer()
//                                                    }
//                                                } else {
//                                                    EmptyView()
//                                                }
//                                                Text("\(definition)")
//                                                    .font(.subheadline)
//                                                    .foregroundColor(Color(white: 0.6))
//                                            }
//                                        } else {
//                                            EmptyView()
//                                        }
//                                        Spacer()
//                                    }
//                                }
//                            }
//                        } else {
//                            VStack {
//                                HStack {
//                                    Text(collapsedLexicalCategory(for: headwordEntry))
//                                        .font(.caption)
//                                        .italic()
//                                        .foregroundColor(Color(white: 0.8))
//                                    Spacer()
//                                }
//                                HStack {
//                                    Text(collapsedDefinition(for: headwordEntry))
//                                        .font(.subheadline)
//                                        .foregroundColor(Color(white: 0.6))
//                                    Spacer()
//                                }
//                            }
//                        }
//                    }
//                    .onTapGesture {
//                        viewModel.expanded.toggle()
//                        focusedWord = headwordEntry.word
//                    }
//                }
    }
    
    struct Style: ViewStyleSheet {
        var primaryColor: Color?
        var secondaryColor: Color?
        var backgroundColor: Color?
        var highlightColor: Color?
    }
    
    // MARK: - Entry functions
    private static func phoneticString(for word: HeadwordEntry) -> String {
        let phoneticSet = phoneticSet(for: word)
        let phoneticList = Array(phoneticSet).sorted()
        return "/  \(Array(phoneticList).joined(separator: ", "))  /"
    }
    
    private static func phoneticSet(for word: HeadwordEntry) -> Set<String> {
        var phoneticSet = Set<String>()
        let entries = word.lexicalEntries.flatMap { $0.entries }
        for entry in entries {
            if let p = entry.pronunciations {
                p.map {
                    $0.phoneticSpelling
                }.forEach {
                    if $0 != nil { phoneticSet.insert($0!)
                    }
                }
            }
        }
        return phoneticSet
    }
    
    private func collapsedLexicalCategory(for headwordEntry: HeadwordEntry) -> String {
        return headwordEntry.lexicalEntries[0].lexicalCategory.text.capitalized
    }
    
    private func collapsedDefinition(for headwordEntry: HeadwordEntry) -> String {
        return headwordEntry.lexicalEntries.first?.allSenses().first?.definitions?.first ?? ""
    }
    
}

protocol ViewStyleSheet {
    var primaryColor: Color? { get }
    var secondaryColor: Color? { get }
    var backgroundColor: Color? { get }
    var highlightColor: Color? { get }
}

extension Sense: Identifiable {
    var hasDefinitions: Bool {
        return self.definitions == nil
    }
}
