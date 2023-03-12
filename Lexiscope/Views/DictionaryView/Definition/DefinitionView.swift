//
//  DefinitionView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 9/19/22.
//

import SwiftUI

struct DefinitionView: View {
    @ObservedObject var viewModel: DefinitionViewModel
    var spacing: CGFloat
    var familiar: Bool = false
    
    var body: some View {
        VStack(spacing: spacing) {
            HStack {
                Text(viewModel.headwordEntry.word)
                    .foregroundColor(.verdigrisDark) // primaryDark
                Spacer()
                Button {
                    viewModel.bookmarkWord()
                } label: {
                    if familiar {
                        Star(cornerRadius: 1)
                            .fill(Color.verdigris)
                            .frame(width: 16, height: 16)
                    } else {
                        Image(systemName: viewModel.saved ?? false ? "bookmark.fill" : "bookmark")
                            .foregroundColor(Color.verdigris) // primary
                    }
                }
            }
            HStack {
                Text("/")
                    .font(.caption2)
                    .foregroundColor(.init(white: 0.5)) // neutral
                    .padding(.vertical, 2)
                ForEach(viewModel.allSortedPronunciations, id: \.phoneticSpelling) { pronunciation in
                    Button {
                        viewModel.pronounce(pronunciation.audioFile)
                    } label: {
                        Text(pronunciation.phoneticSpelling!)
                            .font(.caption2)
                            .foregroundColor(.init(white: 0.5)) // neutral
                            .padding(2)
                            .background(pronunciation.hasAudio ? Color.verdigris.opacity(0.4) : Color.clear) // primary
                            .cornerRadius(4)
                    }
                }
                Text("/")
                    .font(.caption2)
                    .foregroundColor(.init(white: 0.5)) // neutral
                    .padding(.vertical, 2)
                Spacer()
            }
            ScrollView(showsIndicators: false) {
                ForEach(viewModel.lexicalEntries()) { lexicalEntry in
                    LexicalEntryView(lexicalEntry: lexicalEntry, expanded: $viewModel.expanded, spacing: spacing)
                }
            }
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

struct DefinitionCard: ViewModifier {
    var familiar: Bool = false
    func body(content: Content) -> some View {
        content
            .animation(.default, value: 0.5)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(familiar ? Color.verdigris : .clear, lineWidth: 3)
                    .background(Color(white: 0.97))
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension DefinitionView {
    func definitionCard(familiar: Bool = false) -> some View {
        modifier(DefinitionCard(familiar: familiar))
    }
}
