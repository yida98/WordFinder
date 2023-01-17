//
//  DictionaryView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/6/22.
//

import Foundation
import SwiftUI

struct DictionaryView: View {
    @StateObject var viewModel: DictionaryViewModel = DictionaryViewModel()
    
    var body: some View {
        VStack {
            DefinitionView(viewModel: viewModel.getDefinitionViewModel())
                .padding()
            Spacer()
        }
    }
}
