//
//  ContentView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2022-05-03.
//

import SwiftUI

struct ContentView: View {
    var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding()
            Spacer()
            CameraView(viewModel: viewModel.getCameraViewModel())
                .background(Color.red) // TODO: Remove me
                .clipped()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel())
    }
}
