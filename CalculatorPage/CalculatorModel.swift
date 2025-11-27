//
//  CalculatorModel.swift
//  PeacockMenus
//
//  Created by lynn on 2025/7/4.
//
import Foundation
import SwiftUI

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

struct NumberPress: Equatable, Codable, Hashable {
    var id: String = UUID().uuidString
    var value: String
    var image: String? = nil
    var color: Color
    var sound: String

    enum Key: String, CaseIterable, Hashable {
        case ac = "AC"
        case parentheses = "()"
        case divide = "/"
        case back
        case seven = "7"
        case eight = "8"
        case nine = "9"
        case multiply = "*"
        case four = "4"
        case five = "5"
        case six = "6"
        case minus = "-"
        case one = "1"
        case two = "2"
        case three = "3"
        case plus = "+"
        case zero = "0"
        case point = "."
        case percent = "%"
        case equal = "="
    }

    static let results: [String: NumberPress] = [
        "AC": NumberPress(value: "AC", color: Color.cyan, sound: "piano1"),
        "()": NumberPress(value: "()", image: "parentheses", color: Color.cyan, sound: "piano2"),
        "/": NumberPress(value: "/", image: "divide", color: Color.cyan, sound: "piano3"),
        "back": NumberPress(
            value: "back",
            image: "arrow.backward",
            color: Color.cyan,
            sound: "piano4"
        ),
        "7": NumberPress(value: "7", color: Color.gray, sound: "piano15"),
        "8": NumberPress(value: "8", color: Color.gray, sound: "piano6"),
        "9": NumberPress(value: "9", color: Color.gray, sound: "piano7"),
        "*": NumberPress(value: "*", image: "multiply", color: Color.cyan, sound: "piano8"),
        "4": NumberPress(value: "4", color: Color.gray, sound: "piano9"),
        "5": NumberPress(value: "5", color: Color.gray, sound: "piano10"),
        "6": NumberPress(value: "6", color: Color.gray, sound: "piano11"),
        "-": NumberPress(value: "-", image: "minus", color: Color.cyan, sound: "piano12"),
        "1": NumberPress(value: "1", color: Color.gray, sound: "piano13"),
        "2": NumberPress(value: "2", color: Color.gray, sound: "piano14"),
        "3": NumberPress(value: "3", color: Color.gray, sound: "piano15"),
        "+": NumberPress(value: "+", image: "plus", color: Color.cyan, sound: "piano16"),
        "0": NumberPress(value: "0", color: Color.gray, sound: "piano17"),
        ".": NumberPress(value: ".", color: Color.gray, sound: "piano18"),
        "%": NumberPress(value: "%", image: "percent", color: Color.cyan, sound: "piano19"),
        "=": NumberPress(value: "=", image: "equal", color: Color.green, sound: "piano20"),
    ]
    static subscript(key: String) -> NumberPress {
        return results[key] ?? results["="]!
    }

    static subscript(key: Key) -> NumberPress {
        return results[key.rawValue] ?? results["="]!
    }
}

extension Color: @retroactive Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let alpha = try container.decode(Double.self, forKey: .alpha)

        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if let cgColor = cgColor {
            let components = cgColor.components ?? [0, 0, 0, 1]
            try container.encode(components[0], forKey: .red)
            try container.encode(components[1], forKey: .green)
            try container.encode(components[2], forKey: .blue)
            try container.encode(components[3], forKey: .alpha)
        }
    }
}
