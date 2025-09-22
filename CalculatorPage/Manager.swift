//
//  Manager.swift
//  Calculator
//
//  Created by lynn on 2025/6/30.
//
import Foundation
import Expression
import Defaults
import SwiftUI

class Manager{
    static let symbols = ["+", "-", "*", "/"]
    
    static func appendOrReplaceLastToken(in tokens: [String], with newValue: String) -> [String] {
        var result = tokens
        if let last = result.last {
            if symbols.joined().contains(last) {
                result.append(newValue) // 最后是符号，追加
            } else {
                result[result.count - 1] = newValue // 最后是数字，替换
            }
        } else {
            result.append(newValue) // 空数组，直接加
        }
        return result
    }
    
    static func evaf(_ tokens:[String]) -> String{
        let result = eva(tokens)
        return "\(formatDecimal(result, maxDigits: Defaults[.doubleInt]))"
    }
    
    static func eva(_ tokens: [String]) -> Decimal {
        // 先处理乘除运算
        var intermediateTokens = [String]()
        var i = 0
        let n = tokens.count
        
        while i < n {
            let token = tokens[i]
            if token == "*" || token == "/" {
                // 获取操作符前后的数字
                let left = Decimal(string: intermediateTokens.removeLast())!
                let right = Decimal(string: tokens[i+1])!
                let result: Decimal
                if token == "*" {
                    result = left * right
                } else {
                    result = left / right
                }
                intermediateTokens.append(result.description)
                i += 2 // 跳过已处理的右操作数
            } else if token == "+" || token == "-" {
                // 加减法先保留，后面处理
                intermediateTokens.append(token)
                i += 1
            } else {
                // 数字直接加入
                intermediateTokens.append(token)
                i += 1
            }
        }
        
        // 然后处理加减运算
        var result = Decimal(string: intermediateTokens[0])!
        i = 1
        let m = intermediateTokens.count
        
        while i < m {
            let token = intermediateTokens[i]
            if token == "+" {
                let right = Decimal(string: intermediateTokens[i+1])!
                result += right
                i += 2
            } else if token == "-" {
                let right = Decimal(string: intermediateTokens[i+1])!
                result -= right
                i += 2
            } else {
                i += 1
            }
        }
        
        return result
    }

    
   static func evaluateExpression(_ expressionString: String) -> String {
       
       let tokens = self.tokenizeMathExpression(expressionString)
       
       let result = self.eva(tokens)
    
        
        return "\(formatDecimal(result, maxDigits: Defaults[.doubleInt]))"
    }
    
    
    static func formatDecimal(_ number: Decimal, maxDigits: Int = 6) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maxDigits
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false // 不加千分位

        return formatter.string(from: number as NSNumber) ?? "\(number)"
    }

    
    
    static func texthandler(_ text:String)-> String{

        
        let texts = tokenizeMathExpression(text)
        
        let result = texts.compactMap { item in
            if symbols.contains(item){
                return item
            }
            let doubles = item.split(separator: ".", omittingEmptySubsequences: false)
            
            if doubles.count > 0{
                return doubles.compactMap { subtext in
                    let double = String(subtext)
                    if let first = doubles.first, first == double{
                        return formatNumberWithComma(double)
                    }
                    return double
                }.joined(separator: ".")
            }
            
            if item == texts.last{
                if let f = Float(item),
                   f.truncatingRemainder(dividingBy: 1) == 0, f == 0 {
                    return item
                }
            }
            
            return formatNumberWithComma(item)
        }.joined()
        
        return result.replacingOccurrences(of: "/", with: "÷")
            .replacingOccurrences(of: "*", with: "×")
    }
    
    static func toScientificNotation(_ number: Double, fractionDigits: Int = 6) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.positiveFormat = "0.#E+0"
        formatter.exponentSymbol = "e"
        formatter.maximumFractionDigits = fractionDigits

        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    static func formatNumberWithComma(_ numberString: String) -> String {

        guard Defaults[.thousandPoints] else { return numberString}
        
        var input = numberString.trimmingCharacters(in: .whitespaces)
        
        // 处理负号
        var sign = ""
        if input.hasPrefix("-") {
            sign = "-"
            input.removeFirst()
        }

        // 拆分整数和小数部分
        let parts = input.split(separator: ".", omittingEmptySubsequences: false)
        let integerPart = String(parts[0])
        let decimalPart = parts.count > 1 ? "." + parts[1] : ""

        // 插入千分位逗号
        var result = ""
        for (i, char) in integerPart.reversed().enumerated() {
            if i != 0 && i % 3 == 0 {
                result.insert(",", at: result.startIndex)
            }
            result.insert(char, at: result.startIndex)
        }

        return sign + result + decimalPart
    }
    
    static func tokenizeMathExpression(_ expression: String) -> [String] {
        // 正则表达式模式：匹配数字或运算符
        let pattern = #"(\d+\.?\d*|[-+*/x])"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        
        let matches = regex.matches(in: expression,
                                    range: NSRange(expression.startIndex..., in: expression))
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: expression) else { return nil }
            return String(expression[range])
        }
    }

    static func normalizeNumberString(_ input: String) -> String {
        // 去除前后空格
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 空字符串处理
        guard !trimmed.isEmpty else { return "0" }
        
        // 检查是否为有效数字格式
//        let isDecimal = trimmed.contains(".")
        let hasDigits = trimmed.contains { $0.isNumber }
        
        guard hasDigits else { return "0" }
        
        // 处理纯零情况
        if trimmed.allSatisfy({ $0 == "0" || $0 == "." }) {
            return "0"
        }
        
        // 分割整数和小数部分
        let parts = trimmed.components(separatedBy: ".")
        var integerPart = parts[0]
        let decimalPart = parts.count > 1 ? parts[1] : ""
        
        // 规范化整数部分
        integerPart = normalizeIntegerPart(integerPart)
        
        // 检查小数部分是否全为零
        let decimalAllZeros = decimalPart.allSatisfy { $0 == "0" }
        
        // 组合结果
        if decimalPart.isEmpty || decimalAllZeros {
            return integerPart
        } else {
            // 规范化小数部分（去除后导零）
            let normalizedDecimal = decimalPart.replacingOccurrences(of: "0+$", with: "", options: .regularExpression)
            return "\(integerPart).\(normalizedDecimal)"
        }
    }

    static  func normalizeIntegerPart(_ part: String) -> String {
        // 去除前导零
        var result = part.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
        
        // 如果去除后为空，说明原数就是0
        if result.isEmpty {
            return "0"
        }
        
        // 处理负号
        if part.hasPrefix("-") && result != "0" {
            result = "-" + result
        }
        
        return result
    }

    
    static func removeZeroAndOperators(from tokens: [String]) -> [String] {
        var result = tokens
        var indicesToRemove: Set<Int> = []
        
        for (index, value) in result.enumerated() {
            if value == "0" {
                indicesToRemove.insert(index)
                if index > 0 {
                    indicesToRemove.insert(index - 1)
                }
            }
        }
        
        for index in indicesToRemove.sorted(by: >) {
            result.remove(at: index)
        }
        
        if let first = result.first,
           result.count == 1 && symbols.contains(first){
            result = []
        }
        
        return result
    }
    
    static func chineseUnit(_  numberString: String) -> String {
        guard let number = Decimal(string: numberString) else {
            return ""
        }

        let units: [(Decimal, String)] = [
            (Decimal(string: "1e45")!, ""),
            (Decimal(string: "1e44")!, "载"),
            (Decimal(string: "1e43")!, "千正"),
            (Decimal(string: "1e42")!, "百正"),
            (Decimal(string: "1e41")!, "十正"),
            (Decimal(string: "1e40")!, "正"),
            (Decimal(string: "1e39")!, "千涧"),
            (Decimal(string: "1e38")!, "百涧"),
            (Decimal(string: "1e37")!, "十涧"),
            (Decimal(string: "1e36")!, "涧"),
            (Decimal(string: "1e35")!, "千沟"),
            (Decimal(string: "1e34")!, "百沟"),
            (Decimal(string: "1e33")!, "十沟"),
            (Decimal(string: "1e32")!, "沟"),
            (Decimal(string: "1e31")!, "千穰"),
            (Decimal(string: "1e30")!, "百穰"),
            (Decimal(string: "1e29")!, "十穰"),
            (Decimal(string: "1e28")!, "穰"),
            (Decimal(string: "1e27")!, "千秭"),
            (Decimal(string: "1e26")!, "百秭"),
            (Decimal(string: "1e25")!, "十秭"),
            (Decimal(string: "1e24")!, "秭"),
            (Decimal(string: "1e23")!, "千垓"),
            (Decimal(string: "1e22")!, "百垓"),
            (Decimal(string: "1e21")!, "十垓"),
            (Decimal(string: "1e20")!, "垓"),
            (Decimal(string: "1e19")!, "千京"),
            (Decimal(string: "1e18")!, "百京"),
            (Decimal(string: "1e17")!, "十京"),
            (Decimal(string: "1e16")!, "京"),
            (Decimal(string: "1e15")!, "千兆"),
            (Decimal(string: "1e14")!, "百兆"),
            (Decimal(string: "1e13")!, "十兆"),
            (Decimal(string: "1e12")!, "兆"),
            (Decimal(string: "1e11")!, "千亿"),
            (Decimal(string: "1e10")!, "百亿"),
            (Decimal(string: "1e9")!, "十亿"),
            (Decimal(string: "1e8")!, "亿"),
            (Decimal(string: "1e7")!, "千万"),
            (Decimal(string: "1e6")!, "百万"),
            (Decimal(string: "1e5")!, "十万"),
            (Decimal(string: "1e4")!, "万")
        ]

        for (threshold, unit) in units {
            if number >= threshold {
                return unit
            }
        }

        return ""
    }

    
}

#Preview{
    CalculatorView()
}
