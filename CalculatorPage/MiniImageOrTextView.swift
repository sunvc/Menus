//
//  MiniImageOrTextView.swift
//  Calculator
//
//  Created by lynn on 2025/6/30.
//
import SwiftUI


struct MiniImageOrTextView: View {
    var item: String
    var body: some View {
        ZStack{
            switch item {
            case "/":
                Image(systemName: "divide")
                    .foregroundStyle(.gray)
            case "*":
                Image(systemName: "multiply")
                    .foregroundStyle(.gray)
            case "+":
                Image(systemName: "plus")
                    .foregroundStyle(.gray)
            case "-":
                Image(systemName: "minus")
                    .foregroundStyle(.gray)
            default:
                Text(verbatim: item)
                    .lineLimit(1)
                    .font(.largeTitle)
                    .foregroundStyle(.primary)
            }
        }
    }
    
}

