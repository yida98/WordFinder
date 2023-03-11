//
//  FullSavedWordNotesEditor.swift
//  Lexiscope
//
//  Created by Yida Zhang on 3/9/23.
//

import SwiftUI
import Combine

struct FullSavedWordNotesEditor: View {
    @FocusState var isFocused: Bool
    @Binding var text: String
    
    var body: some View {
        VStack {
            HStack {
                Text("Note")
                    .fullSavedWordSectionTitle()
                Spacer()
            }
            if #available(iOS 16.0, *) {
                TextEditor(text: $text)
                    .font(.subheadline)
                    .focused($isFocused)
                    .foregroundColor(.verdigrisDark)
                    .onAppear {
                        isFocused = true
                    }
                    .scrollContentBackground(.hidden)
            } else {
                // Fallback on earlier versions
                TextEditor(text: $text)
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }
            }
        }.padding(60)
        .background(Color.verdigrisLight.ignoresSafeArea())
    }
}
