//
//  ContentView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2022-05-03.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        ZStack {
            VStack {
                SearchView(viewModel: viewModel.getSearchViewModel())
                Spacer()
            }
            VStack {
                Spacer()
                    .frame(height: viewModel.searchViewOffset)
                DictionaryView()
                    .background(.white)
                    .mask {
                        RoundedRectangle(cornerRadius: 20)
                    }
                    .shadow(radius: 4)
            }
        }.ignoresSafeArea()
    }
    
    // TODO: Remove after debug
    static private var someEntry: OxfordEntry.HeadwordEntry = {
        let subsense = OxfordEntry.Sense(definitions: ["(in tennis and similar games) a service that an opponent is unable to touch and thus wins a point"], id: "m_en_gbus0005680.013", subsenses: nil)
        let sense1 = OxfordEntry.Sense(definitions: ["a playing card with a single spot on it, ranked as the highest card in its suit in most card games", "a person who excels at a particular sport or other activity"], id: "m_en_gbus0005680.006", subsenses: nil)
        let sense2 = OxfordEntry.Sense(definitions: nil, id: "m_en_gbus0005680.010", subsenses: nil)
        let sense3 = OxfordEntry.Sense(definitions: ["a pilot who has shot down many enemy aircraft, especially in World War I or World War II."], id: "m_en_gbus0005680.011", subsenses: [subsense])
        
        let pronunciation = OxfordEntry.InlineModel1(audioFile: nil, dialects: nil, phoneticNotation: "respell", phoneticSpelling: "ās", regions: nil, registers: nil)
        let pronunciation2 = OxfordEntry.InlineModel1(audioFile: nil, dialects: nil, phoneticNotation: "respell", phoneticSpelling: "āss", regions: nil, registers: nil)
        
        let entry = OxfordEntry.Entry(homographNumber: nil, pronunciations: [pronunciation, pronunciation2], senses: [sense1, sense2, sense3])
        let lexicalEntry = OxfordEntry.LexicalEntry(entries: [entry], language: "us-en", lexicalCategory: OxfordEntry.LexicalCategory(id: "noun", text: "Noun"), pronunciations: [pronunciation], root: nil, text: "ace")

        let lexicalEntry2 = OxfordEntry.LexicalEntry(entries: [entry], language: "us-en", lexicalCategory: OxfordEntry.LexicalCategory(id: "adjective", text: "Adjective"), pronunciations: [pronunciation2], root: nil, text: "ace")
        let hwEntry = OxfordEntry.HeadwordEntry(id: "1", language: "en-us", lexicalEntries: [lexicalEntry, lexicalEntry2], pronunciations: [pronunciation, pronunciation2], type: nil, word: "ace")
        return hwEntry
    }()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel())
    }
}
