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
        HStack {
            WordCellClusterView(viewModel: viewModel)
        }
    }
}
