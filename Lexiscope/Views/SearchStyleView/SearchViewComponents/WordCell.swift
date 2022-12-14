//
//  WordCell.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/10/22.
//

import SwiftUI

struct WordCell: View {
    var word: String
    var selected: Bool
    var body: some View {
        Text(word)
            .foregroundColor(selected ? .black : .white.opacity(0.5))
            .fixedSize(horizontal: true, vertical: true)
            .padding(2)
            .padding(.horizontal, 3)
            .background(selected ? Color.blueCrayola.opacity(0.3) : .clear)
            .cornerRadius(5)
    }
}

struct WordCell_Previews: PreviewProvider {
    static var previews: some View {
        WordCell(word: "Red", selected: true)
    }
}
