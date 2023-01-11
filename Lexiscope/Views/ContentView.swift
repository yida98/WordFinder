//
//  ContentView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2022-05-03.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        ZStack {
            VStack {
                SearchView(viewModel: viewModel.getSearchViewModel())
                Spacer()
            }
            VStack {
                Spacer()
                    .frame(height: viewModel.searchViewOffset)
                DictionaryView()
                    .background(.white)
                    .mask {
                        RoundedRectangle(cornerRadius: 20)
                    }
                    .shadow(radius: 4)
            }
            Button("Tap me") {
                viewModel.searchOpen.toggle()
            }
        }.ignoresSafeArea()
    }
}
