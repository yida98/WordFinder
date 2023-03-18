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
                VStack(spacing: 40) {
                    Image(systemName: "books.vertical")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .scaledToFit()
                        .foregroundStyle(.linearGradient(colors: [.gradient2, .gradient5], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Text("nothing to quiz")
                        .font(.largeTitleQuiz.bold())
                        .foregroundStyle(.linearGradient(colors: [.gradient2, .gradient5], startPoint: .topLeading, endPoint: .bottomTrailing))
                }
                .padding(50)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.thinMaterial)
                )
                Spacer()
            }
            Spacer()
        }
        .background(LinearGradient(colors: [.gradient2, .gradient5], startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

struct QuizPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        QuizPlaceholder()
    }
}
