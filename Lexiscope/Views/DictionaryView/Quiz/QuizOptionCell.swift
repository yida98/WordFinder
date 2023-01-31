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
    var parentGeometryProxy: GeometryProxy
    
    var body: some View {
        let binding = Binding<Bool>(get: { self.id == self.choice }, set: { _ in self.choice = self.id })
        Toggle(isOn: binding) {
            Text(text)
                .foregroundColor(.white)
        }
        .frame(maxWidth: parentGeometryProxy.size.width)
        .padding()
        .toggleStyle(NeumorphicToggleStyle(shape: RoundedRectangle(cornerRadius: 30), start: .periwinkleCrayola, end: .boyBlue))
    }
}
