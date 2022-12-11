//
//  WordCell.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/10/22.
//

import SwiftUI

struct WordCell: View {
    var word: String
    var selected: Bool = false
    var body: some View {
        Text(word)
            .fixedSize(horizontal: true, vertical: true)
            .padding(4)
            .padding(.horizontal, 3)
            .background(selected ? Color.orange.opacity(0.3) : .clear)
            .cornerRadius(5)
    }
}

struct WordCell_Previews: PreviewProvider {
    static var previews: some View {
        WordCell(word: "Red")
    }
}
