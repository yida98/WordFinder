//
//  QuizPlaceholder.swift
//  Lexiscope
//
//  Created by Yida Zhang on 3/13/23.
//

import SwiftUI

struct QuizPlaceholder: View {
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Text("Nothing to")
                    .placeholder(color: .verdigrisDark)
                Text("quiz")
                    .placeholder(color: .verdigrisDark)
                Spacer()
            }
            Spacer()
        }
        .background(Color.verdigris)
    }
}

struct QuizPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        QuizPlaceholder()
    }
}
