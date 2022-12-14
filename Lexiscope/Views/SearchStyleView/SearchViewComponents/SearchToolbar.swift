//
//  SearchToolbar.swift
//  Lexiscope
//
//  Created by Yida Zhang on 9/21/22.
//

import SwiftUI

struct SearchToolbar: View {
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ScrollView(.horizontal, showsIndicators: false) {
                    WordCellClusterView(viewModel: viewModel)
                }
                Spacer()
            }
            Spacer()
        }
        .frame(height: 30)
    }
}
