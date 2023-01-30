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
                    .foregroundColor(.moodPurple)
                Spacer()
                Button {
                    viewModel.bookmarkWord()
                } label: {
                    Image(systemName: viewModel.saved ?? false ? "bookmark.fill" : "bookmark")
                        .foregroundColor(Color.boyBlue)
                }
            }
            HStack {
                Text("/")
                    .font(.caption2)
                    .foregroundColor(.moodPurple)
                    .padding(.vertical, 4)
                ForEach(viewModel.allSortedPronunciations, id: \.phoneticSpelling) { pronunciation in
                    Button {
                        viewModel.pronounce(pronunciation.audioFile)
                    } label: {
                        Text(pronunciation.phoneticSpelling!)
                            .font(.caption2)
                            .foregroundColor(.moodPurple)
                            .padding(4)
                            .background(pronunciation.hasAudio ? Color.boyBlue.opacity(0.4) : Color.clear)
                            .cornerRadius(4)
                    }
                }
                Text("/")
                    .font(.caption2)
                    .foregroundColor(.moodPurple)
                    .padding(.vertical, 4)
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
