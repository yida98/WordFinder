//
//  String_ext.swift
//  Lexiscope
//
//  Created by Yida Zhang on 6/16/23.
//

import Foundation
import UIKit

extension String {
    func markMWTokens(tokenMap: [String: String]) -> String {
        var input = self
        let keyArray = tokenMap.keys.map { String($0) }
        
        for key in keyArray {
            input = input.replacingOccurrences(of: key, with: tokenMap[key] ?? "")
        }
        input = input.handleMWTokenWithFieldsErased()
        
        return input
    }
    
    private func handleMWTokenWithFieldsErased() -> String {
        var result = ""
        var token = ""
        
        for char in self {
            switch (char, token.isEmpty) {
            case ("{", true): token.append(char)
            case ("}", false):
                result.append(token.tokenWithFieldsValue())
                token = ""
            case (_, true):
                result.append(char)
            case (_, false):
                token.append(char)
            }
        }
        return result
    }
    
    func tokenWithFieldsValue() -> String {
        var token = self
        token.removeFirst()
        token.removeLast()
        let fields = token.split(separator: "|", omittingEmptySubsequences: true).map { String($0) }
        if fields.count > 1 {
            return fields[1]
        } else {
            return ""
        }
    }
    
    func removeAllTokens() -> String {
        let regex = try! NSRegularExpression(pattern: #"[{][\w\\/|\s]*[}]"#)
        let range: NSRange = NSRange(location: 0, length: self.count)
        let replacedmentText = regex.stringByReplacingMatches(in: self, range: range, withTemplate: "")
        return replacedmentText
    }
    
    func superscriptedByMWToken() -> NSAttributedString {
        superscripted(delimiterBy: "^")
    }
    
    func subscriptedByMWToken() -> NSAttributedString {
        superscripted(delimiterBy: "~")
    }
    
    func superscripted(delimiterBy marker: Character) -> NSAttributedString {
        scripted(delimiterBy: marker, superscripted: true)
    }
    
    func subscripted(delimiterBy marker: Character) -> NSAttributedString {
        scripted(delimiterBy: marker, superscripted: false)
    }
    
    private func scripted(delimiterBy marker: Character, superscripted: Bool) -> NSAttributedString {
        let superOffset = 10.0
        let superFont = UIFont.systemFont(ofSize: superscripted ? 6 : -6)
        let superAttribs: [NSAttributedString.Key: Any] = [.baselineOffset: superOffset]
        
        let attribString = NSMutableAttributedString(string: "")
        var superString = ""
        
        for char in self {
            switch (char, superString.isEmpty) {
            case (marker, true): superString.append(char)
            case (marker, false):
                attribString.append(NSAttributedString(string: superString.replacingOccurrences(of: String(marker), with: ""), attributes: superAttribs))
                superString = ""
            case (_, true): attribString.append(NSAttributedString(string: String(char)))
            case (_, false): superString.append(char)
            }
        }
        return attribString
    }
}

