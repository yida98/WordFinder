//
//  SavedWordsView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/17/23.
//

import SwiftUI

struct SavedWordsView: View {
    
    var list: [String] = ["a", "b", "c"]
    var body: some View {
        ScrollView {
            ForEach(list, id: \.self) { word in
                SavedWordsCell(word: word)
            }
        }
    }
}

struct SavedWordsView_Previews: PreviewProvider {
    static var previews: some View {
        SavedWordsView()
    }
}
