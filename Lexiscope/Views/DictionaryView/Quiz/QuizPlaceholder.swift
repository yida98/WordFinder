//
//  QuizPlaceholder.swift
//  Lexiscope
//
//  Created by Yida Zhang on 3/13/23.
//

import SwiftUI

struct QuizPlaceholder: View {
    var familiars: (Int, Int)
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                VStack(spacing: 40) {
                    VStack {
                        Text(getContextualLabel())
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(.thinMaterial)
                        Text("DAILY QUIZ")
                            .multilineTextAlignment(.center)
                            .font(.largeTitleQuiz.bold())
                            .foregroundStyle(.thinMaterial)
                            .padding()
                            .overlay {
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(.thinMaterial, lineWidth: 6)
                            }
                    }
                    Image(systemName: "books.vertical")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .scaledToFit()
                        .foregroundStyle(.thinMaterial)
                }
                .padding(50)
                Spacer()
                HStack {
                    Text("\(familiars.0) of \(familiars.1) familiar")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.silverLakeBlue)
                }
                Spacer()
            }
            Spacer()
        }
        .background(LinearGradient(colors: [.gradient2, .gradient5], startPoint: .topLeading, endPoint: .bottomTrailing))
    }
    
    private func getContextualLabel() -> String {
        if familiars.1 == 0 {
            return "Bookmark more words to play"
        } else {
            return "Come back tomorrow"
        }
    }
}

struct QuizPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        QuizPlaceholder(familiars: (7, 10))
    }
}
