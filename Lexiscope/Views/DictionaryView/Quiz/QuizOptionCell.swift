//
//  QuizOptionCell.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/30/23.
//

import SwiftUI

struct QuizOptionCell: View {
    var text: String
    var id: Int
    @Binding var choice: Int?
    var body: some View {
        Button {
            choice = id
        } label: {
            Text(text)
        }
    }
}
