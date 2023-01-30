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
    
    var body: some View {
        VStack {
            HStack {
                Text(lexicalEntry.lexicalCategory.text.capitalized)
                    .font(.caption)
                    .italic()
                    .foregroundColor(Color(white: 0.8))
                Spacer()
            }
            
            ForEach(senses().indices, id: \.self) { senseIndex in
                HStack {
                    if senses().count > 1 {
                        VStack {
                            Text("\(senseIndex + 1)")
                                .font(.subheadline)
                                .foregroundColor(.moodPurple)
                            Spacer()
                        }
                    }
                    Text("\(senses()[senseIndex].definitions?.first ?? "")")
                        .font(.subheadline)
                        .foregroundColor(Color(white: 0.6))
                    Text("\(senses()[senseIndex].examples?.first?.text ?? "")")
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(Color(white: 0.4))
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
