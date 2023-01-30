//
//  FullSavedWordView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/30/23.
//

import SwiftUI

struct FullSavedWordView: View {
    @ObservedObject var viewModel: DefinitionViewModel
    
    var body: some View {
        VStack {
            DefinitionView(viewModel: viewModel)
        }
        .ignoresSafeArea()
    }
}
