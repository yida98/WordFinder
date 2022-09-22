//
//  SearchIconView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 9/21/22.
//

import SwiftUI

struct SearchIconView: View {
    var selected: Bool
    var systemName: String
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: selected ? 34 : 31, height: selected ? 34 : 31)
                .foregroundColor(.black)
                .opacity(selected ? 0.5 : 0.1)
                .overlay {
                    Image(systemName: systemName)
                        .foregroundColor(.white)
                        .opacity(selected ? 0.9 : 0.7)
                }
        }
    }
}
