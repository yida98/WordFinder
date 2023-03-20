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
                ZStack {
                    SearchView(viewModel: viewModel.getSearchViewModel())

                    if (viewModel.shouldFogCamera)  {
                        Rectangle()
                            .background(.ultraThinMaterial)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.searchOpen = true
                                }
                            }
                    }
                }
                Spacer()
            }.ignoresSafeArea()
            VStack {
                Spacer()
                    .frame(height: viewModel.searchViewActiveOffset)
                    .ignoresSafeArea()
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.linearGradient(colors: [.gradient2a, .gradient1a], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(idealWidth: .infinity, idealHeight: .infinity)
                        .shadow(radius: 4)
                        .ignoresSafeArea()
                    DictionaryView(viewModel: viewModel.getDictionaryViewModel(), searchOpen: $viewModel.searchOpen)
                        .onTapGesture {
                            /// This allows the inside `ScrollView` drag gestures to co-exist with this `DragGesture`
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                                .onChanged({ dragValue in
                                    let yTouchOffset = dragValue.location.y - dragValue.startLocation.y
                                    let yMoveModifier = viewModel.offsetMoveModifier(for: yTouchOffset)
                                    let yMovement = (yTouchOffset * yMoveModifier) + viewModel.getCurrentStaticOffset()
                                    viewModel.searchViewActiveOffset = yMovement > 0 ? yMovement : 0
                                })
                                .onEnded({ dragValue in
                                    withAnimation {
                                        if viewModel.shouldToggle(dragValue.translation.height) {
                                            viewModel.searchOpen.toggle()
                                        } else {
                                            viewModel.resetOffset()
                                        }
                                    }
                                })
                        )
                        .animation(.easeInOut, value: viewModel.searchOpen)
                        .sheet(isPresented: $viewModel.isPresentingQuiz, onDismiss: {
                            viewModel.dismissQuiz()
                        }, content: {
                            if DataManager.shared.hasAnyVocabulary(), let quizzables = QuizViewModel.getQuizzable(), quizzables.count > 0 {
                                QuizView(viewModel: viewModel.getQuizViewModel(with: quizzables), isPresenting: $viewModel.isPresentingQuiz)
                                    .background(LinearGradient(colors: [.gradient2, .gradient5], startPoint: .topLeading, endPoint: .bottomTrailing))
                            } else {
                                QuizPlaceholder()
                            }
                        })
                    
                    VStack {
                        Spacer()
                        HStack {
                            Button {
                                viewModel.openQuiz()
                            } label: {
                                HStack {
                                    Image(systemName: "star.circle.fill")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(.white)
                                    Text("Q U I Z")
                                        .font(.footnote.bold())
                                        .foregroundColor(.white)
                                }
                                .padding(5)
                                .padding(.horizontal, 8)
                            }
                            .buttonStyle(MenuButtonStyle(fillColor: LinearGradient(colors: [.gradient2, .gradient5], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                         strokeColor: .gradient2))
                            Spacer()
                            Toggle(isOn: $viewModel.searchOpen) {
                                HStack {
                                    Image(systemName: "camera.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 14, height: 14)
                                        .foregroundStyle(viewModel.searchOpen ? .linearGradient(colors: [.white], startPoint: .topLeading, endPoint: .bottomTrailing) : .linearGradient(colors: [.sunglow, .gradient5], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    Text("C A M")
                                        .font(.footnote.bold())
                                        .foregroundStyle(viewModel.searchOpen ? .linearGradient(colors: [.white], startPoint: .topLeading, endPoint: .bottomTrailing) : .linearGradient(colors: [.sunglow, .gradient5], startPoint: .topLeading, endPoint: .bottomTrailing))
                                }
                                .padding(5)
                                .padding(.horizontal, 8)
                            }
                            .toggleStyle(MenuToggleStyle(fillColor: .linearGradient(colors: [.sunglow, .gradient5], startPoint: .topLeading, endPoint: .bottomTrailing), strokeColor: .satinGold))
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 13)
                    .ignoresSafeArea(.keyboard)
                }
            }
        }
    }
}

struct MenuButtonStyle<Fill: View>: ButtonStyle {
    var fillColor: Fill
    var strokeColor: Color
        
    init(fillColor: Fill, strokeColor: Color) {
        self.fillColor = fillColor
        self.strokeColor = strokeColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                fillColor
            ).mask {
                RoundedRectangle(cornerRadius: 12)
            }
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct MenuToggleStyle<Fill: ShapeStyle>: ToggleStyle {
    var fillColor: Fill
    var strokeColor: Color
    
    init(fillColor: Fill, strokeColor: Color) {
        self.fillColor = fillColor
        self.strokeColor = strokeColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        if configuration.isOn {
            configuration.label
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(fillColor)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(fillColor, lineWidth: 2)
                }
                .animation(.easeOut(duration: 0.1), value: configuration.isOn)
                .onTapGesture {
                    withAnimation {
                        configuration.isOn.toggle()
                    }
                }
        } else {
            configuration.label
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(fillColor, lineWidth: 2)
                }
                .animation(.easeOut(duration: 0.1), value: configuration.isOn)
                .onTapGesture {
                    withAnimation {
                        configuration.isOn.toggle()
                    }
                }
        }
    }
}
