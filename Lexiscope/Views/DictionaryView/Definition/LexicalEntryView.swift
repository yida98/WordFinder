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
                    .font(.caption)
                    .italic()
                    .foregroundColor(Color(white: 0.8))
                Spacer()
            }
            
            ForEach(senses().indices, id: \.self) { senseIndex in
                HStack {
                    if senses().count > 1 && expanded {
                        VStack {
                            Text("\(senseIndex + 1)")
                                .font(.caption)
                                .foregroundColor(.verdigris)
                                .padding(.vertical, 2)
                            Spacer()
                        }
                    }
                    VStack {
                        HStack {
                            Text("\(senses()[senseIndex].definitions?.first ?? "")")
                                .font(.subheadline)
                                .foregroundColor(Color(white: 0.6))
                            Spacer()
                        }
                        if expanded {
                            HStack {
                                Text("\(senses()[senseIndex].examples?.first?.text ?? "")")
                                    .font(.caption)
                                    .italic()
                                    .foregroundColor(Color(white: 0.7))
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
}
