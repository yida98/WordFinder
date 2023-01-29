//
//  SenseView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/28/23.
//

import SwiftUI

struct LexicalEntryView: View {
    var lexicalEntry: LexicalEntry
    
    var body: some View {
        VStack {
            Text(lexicalEntry.lexicalCategory.text.capitalized)
                .font(.caption)
                .italic()
                .foregroundColor(Color(white: 0.8))
            
            ForEach(lexicalEntry.allSenses().indices) { senseIndex in
                HStack {
                    if lexicalEntry.allSenses().count > 1 {
                        VStack {
                            Text("\(senseIndex + 1)")
                                .font(.subheadline)
                                .foregroundColor(.moodPurple)
                            Spacer()
                        }
                    }
                    Text("\(lexicalEntry.allSenses()[senseIndex].definitions?.first ?? "")")
                        .font(.subheadline)
                        .foregroundColor(Color(white: 0.6))
                    Text("\(lexicalEntry.allSenses()[senseIndex].examples?.first?.text ?? "")")
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(Color(white: 0.4))
                }
            }
        }
    }
}
