//
//  TabCell.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/17/23.
//

import SwiftUI

struct TabCell: View {
    @Binding var selected: Bool
    var label: String
    var systemImage: String
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                Image(systemName: systemImage)
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(selected ? .blue : .gray)
        }
    }
}
