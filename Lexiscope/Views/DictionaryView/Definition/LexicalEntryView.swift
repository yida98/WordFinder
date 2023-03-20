//
//  SenseView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/28/23.
//

import SwiftUI

struct LexicalEntryView: View {
    var lexicalEntry: LexicalEntry
    @Binding var expanded: Bool
    var spacing: CGFloat
    
    var body: some View {
        VStack(spacing: spacing) {
            HStack {
                Text(lexicalEntry.lexicalCategory.text.capitalized)
                    .font(.caption.bold())
                    .italic()
                    .foregroundColor(.verdigrisDark) // primaryDark
                Spacer()
            }
            
            ForEach(senses().indices, id: \.self) { senseIndex in
                HStack {
                    if senses().count > 1 && expanded {
                        VStack {
                            Text("\(senseIndex + 1)")
                                .font(.caption)
                                .foregroundColor(.verdigris) // primary
                                .padding(.vertical, 2)
                            Spacer()
                        }
                    }
                    VStack(spacing: 8) {
                        HStack {
                            Text("\(senses()[senseIndex].definitions?.first ?? "")")
                                .font(.bodyBaskerville)
                                .textSelection(.enabled)
                                .foregroundColor(Color(white: 0.4))
                            Spacer()
                        }
                        if expanded, let exampleText = example(at: senseIndex) {
                            HStack {
                                Text(exampleText)
                                    .font(.caption)
                                    .italic()
                                    .textSelection(.enabled)
                                    .foregroundColor(Color(white: 0.8))
                                Spacer()
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    
    private func senses() -> [Sense] {
        if expanded {
            return lexicalEntry.allSenses()
        } else {
            if let firstSense = lexicalEntry.allSenses().first { return [firstSense] }
            else { return [] }
        }
    }
    
    private func example(at senseIndex: Int) -> String? {
        let examples = senses()[senseIndex].examples?.compactMap { $0.text }
        return examples?.first
    }
}
