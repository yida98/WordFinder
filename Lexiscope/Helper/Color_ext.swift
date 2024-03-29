//
//  Color_ext.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/7/22.
//

import Foundation
import SwiftUI

extension Color {
    static let lightGrey: Color = Color(white: 0.9)
    static let raisonBlack: Color = Color(red: 57/255, green: 54/255, blue: 64/255)
    
    // MARK: Blue
    static let babyPowder: Color = Color(red: 252/255, green: 251/255, blue: 247/255)
    static let blueCrayola: Color = Color(red: 22/255, green: 115/255, blue: 255/255)
    static let boyBlue: Color = Color(red: 95/255, green: 159/255, blue: 255/255)
    static let darkSkyBlue: Color = Color(red: 60/255, green: 152/255, blue: 250/255)
    static let uranianBlue: Color = Color(red: 186/255, green: 222/255, blue: 255/255)
    static let beauBlue: Color = Color(red: 182/255, green: 204/255, blue: 224/255)
    static let magnolia: Color = Color(red: 248/255, green: 242/255, blue: 252/255)
    static let lavendarGray: Color = Color(red: 193/255, green: 185/255, blue: 201/255)
    static let moodPurple: Color = Color(red: 130/255, green: 119/255, blue: 137/255)
    static let sonicSilver: Color = Color(red: 127/255, green: 121/255, blue: 121/255)
    static let thistle: Color = Color(red: 213/255, green: 197/255, blue: 227/255)
    static let ultraViolet: Color = Color(red: 106/255, green: 76/255, blue: 147/255)
    
    static let silverLakeBlue: Color = Color(red: 98/255, green: 144/255, blue: 195/255)
    
    // MARK: Green
    static let yellowGreenCrayola: Color = Color(red: 181/255, green: 239/255, blue: 138/255)
    static let hunterGreen: Color = Color(red: 69/255, green: 107/255, blue: 76/255)
    static let morningBlue: Color = Color(red: 130/255, green: 158/255, blue: 135/255)
    static let morningDustBlue: Color = Color(red: 192/255, green: 206/255, blue: 195/255)
    static let darkSeaGreen: Color = Color(red: 156/255, green: 186/255, blue: 141/255)
    static let commonGreen: Color = Color(red: 125/255, green: 219/255, blue: 134/255)
    static let forestGreen: Color = Color(red: 54/255, green: 134/255, blue: 45/255)
    
    static let honeydew: Color = Color(red: 200/255, green: 222/255, blue: 202/255)
    
    // MARK: Red
    static let redwood: Color = Color(red: 158/255, green: 83/255, blue: 70/255)
    static let bittersweet: Color = Color(red: 255/255, green: 89/255, blue: 94/255)
    
    static let timberWolf: Color = Color(red: 232/255, green: 223/255, blue: 223/255)
    
    // MARK: Yellow
    static let sunglow: Color = Color(red: 255/255, green: 202/255, blue: 58/255)
    static let mikadoYellow: Color = Color(red: 255/255, green: 200/255, blue: 0/255)
    static let satinGold: Color = Color(red: 181/255, green: 155/255, blue: 40/255)
    
    
    
    static let verdigris: Color = Color(red: 117/255, green: 185/255, blue: 190/255)
    static let verdigrisLight: Color = Color(red: 238/255, green: 246/255, blue: 247/255)
    static let verdigrisDark: Color = Color(red: 78/255, green: 161/255, blue: 166/255)
    static let ashGrayLight: Color = Color(red: 215/255, green: 234/255, blue: 225/255)
    static let pineGreen: Color = Color(red: 61/255, green: 115/255, blue: 102/255)
    static let celadon: Color = Color(red: 177/255, green: 232/255, blue: 190/255)
    
    static let gradient1: Color = Color(red: 189/255, green: 150/255, blue: 255/255)
    static let gradient1a: Color = Color(red: 239/255, green: 230/255, blue: 255/255)
    static let gradient2: Color = Color(red: 133/255, green: 196/255, blue: 255/255)
    static let gradient2a: Color = Color(red: 219/255, green: 240/255, blue: 255/255)
    static let gradient3: Color = Color(red: 166/255, green: 247/255, blue: 207/255)
    static let gradient3a: Color = Color(red: 213/255, green: 247/255, blue: 230/255)
    static let gradient4: Color = Color(red: 255/255, green: 245/255, blue: 223/255)
    static let gradient5: Color = Color(red: 255/255, green: 176/255, blue: 242/255)
}

struct ColorSet {
    var primaryFill: Color
    var secondaryFill: Color
    var shadowFill: Color
    var primaryHighlight: Color
    var secondaryHighlight: Color?
}
