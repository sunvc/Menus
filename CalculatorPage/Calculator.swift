//
//  Calculator.swift
//  Calculator
//
//  Created by lynn on 2025/6/30.
//

import SwiftUI
import Expression
import Defaults

extension resultModel: Defaults.Serializable{}

extension Defaults.Keys{
    
    static let results = Key<[resultModel]>("results", default: [])
    static let thousandPoints = Key<Bool>("thousandPoints", default: false)
    static let numberSuffix = Key<Bool>("numberSuffix", default: true)
    static let doubleInt = Key<Int>("doubleInt", default: 2)
    
    static let feedback = Key<Bool>("feedback", default: false)
}

struct resultModel:Codable, Equatable{
    var id:String = UUID().uuidString
    var timestamp:Date = .now
    var title:String? = nil
    var body:String
    
    var bodys:[String]{
        guard body.count != 0 else { return [""]}
        
        let texts = Manager.tokenizeMathExpression(body)
        
        
        return texts
    }
    
    var result: String {
        Manager.evaluateExpression(body)
    }
    
    static let `default` = resultModel(title: "", body: "")
    
}

struct CalculatorView: View {
    
    @Default(.results) var results
    @Default(.defaultHome)  var defaultHome
    @Default(.numberSuffix) var numberSuffix
    var height:CGFloat{
        let bounds = UIScreen.main.bounds
        return ((bounds.height / 2) - 100) / 4
    }
    @State private var title:String? = nil
    @State private var titleInput:String = ""
    
    @State private var inputText:String = ""
    @State private var resultNumber:String = ""
    @State private var maxDecimalPlaces:Int = 2
    
    @FocusState private var focused
    var body: some View {
        VStack {
            ScrollViewReader{proxy in
                List{
                  
                    ForEach(results, id: \.id) { item in
                       
                            VStack(spacing: 0){
                                
                                if let title = item.title{
                                    Text(title)
                                        .font(.largeTitle)
                                }
                                
                                ResultView(result:item){
                                    let tokens = Manager.tokenizeMathExpression(inputText)
                                    self.inputText = Manager.appendOrReplaceLastToken(in: tokens, with: item.result).joined()
                                }
                                    .frame( height: 35)
                                    
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            
                       
                    }
                    HStack{
                        if let title = title{
                            Text(title)
                        }
                        Spacer()
                    }.id("currentResult")
                        .listRowSeparator(.hidden)
                }
                .listStyle(PlainListStyle())
                .listSectionSeparator(.hidden)
                .listSectionSeparatorTint(Color.clear)
                .onAppear{
                    proxy.scrollTo("currentResult", anchor: .bottom)
                }
                .onChange(of: results) {_, newValue in
                    proxy.scrollTo("currentResult", anchor: .bottom)
                }
            }
            
            
            VStack{
                
                GeometryReader {
                    let size = $0.size
                    HStack(spacing: 0){
                        ScrollViewReader{proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack{
                                    Spacer()
                                    Group{
                                        if resultNumber.isEmpty{
                                            Text(Manager.texthandler(inputText))
                                           
                                        }else{
                                            Text(Manager.texthandler(resultNumber))
                                            let pre = Manager.chineseUnit(resultNumber)
                                            
                                            if !pre.isEmpty && numberSuffix{
                                                HStack(spacing: 0){
                                                    Text(verbatim: "(")
                                                        .foregroundStyle(.gray)
                                                    Text(verbatim: "\(pre)")
                                                    
                                                    Text(verbatim: ")")
                                                        .foregroundStyle(.gray)
                                                }.font(.largeTitle.bold())
                                                
                                            }
                                        }
                                    }
                                    .padding(.trailing, 10)
                                    .font(.system(size: 50).bold())
                                    .multilineTextAlignment(.trailing)
                                    
                                    .id("3000")
                                    .onChange(of: inputText) { _,newValue in
                                        proxy.scrollTo("3000", anchor: .trailing)
                                    }
                                    
                                }
                                .frame(minWidth: size.width)
                            }
                            .viewExtractor(result: { view in
                                if let view = view as? UIScrollView{
                                    view.bounces = false
                                }
                                
                            })
                            .scrollIndicators(.hidden)
                            .frame(width: size.width, height: size.height)
                            
                        }
                    }
                    
                }.frame(height: 35)
       
               
                KeyboardNumberView(height: height){ mode in
                    self.inputText = ""
                    self.resultNumber = ""
                    switch mode{
                    case .clear:
                        results = []
                    case .average:
                        
                        guard results.count > 0 else { return }
                        
                        var tokens:[String] = []
                        
                        results.forEach { item in
                            tokens.append(item.result)
                            if results.last != item{
                                tokens.append("+")
                            }
                        }
                        tokens = [Manager.evaf(tokens)]
                        
                        tokens.append("/")
                        tokens.append("\(results.count)")
                      
                        self.resultNumber = Manager.evaf(tokens)
                        
                    case .sum:
                       
                        
                        guard results.count > 0 else {return }
                        
                        var tokens:[String] = []
                        
                        results.forEach { item in
                            tokens.append(item.result)
                            if results.last != item{
                                tokens.append("+")
                            }
                        }
                        
                  
                        self.resultNumber =  Manager.evaf(tokens)
                    }
                }onTap: { btn in
                    button(btn)
                }
            }
            
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .safeAreaInset(edge: .top){
            HStack{
                if defaultHome == .calculator{
                    Menu{
                        ForEach(Page.arr,id: \.self){ item in
                            if item != peacock.shared.page{
                                Button{
                                    withAnimation {
                                        peacock.shared.page = item
                                    }
                                }label:{
                                    Label(item.name, systemImage: item.rawValue)
                                }
                            }
                        }
                    }label: {
                        Image(systemName: "filemenu.and.selection")
                            .font(.title)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .padding(.leading)
                        
                    }
                }else{
                    Button{
                        withAnimation {
                            peacock.shared.page = defaultHome
                        }
                    }label:{
                        Image(systemName: "xmark")
                            .font(.title)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .padding(.leading)
                    }
                }
                
                Spacer()
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack{
                Text("输入备注")
                    
                TextField("123", text: $titleInput)
                    .focused($focused)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
            .padding(.top, 5)
            .padding(.horizontal)
            .font(.largeTitle)
            .opacity(focused ? 1 : 0)
        }
    }
    
   
    
    func button(_ text:String){
        Haptic.impact(.light)
        if self.resultNumber != ""{
            self.resultNumber = ""
        }
        
        switch text{
        case "AC":
            self.inputText = ""
            return
        case "back":
            self.inputText = String(self.inputText.dropLast())
            return
        case "/","*","+","-":
            if let last = inputText.last, Int(String(last)) != nil {
                self.inputText += text
            }else if let last = inputText.last, String(last) != text {
                self.inputText = String(self.inputText.dropLast()) + text
            }
            var texts = Manager.tokenizeMathExpression(inputText)
            
            self.inputText = texts.compactMap { item in
                if ["/","*","+","-"].contains(item) {
                    return item
                }
                if texts.last == item{
                    return item
                }
                return Manager.normalizeNumberString(item)
            }.joined()
            
            texts = Manager.tokenizeMathExpression(inputText)
            self.inputText = Manager.removeZeroAndOperators(from: texts).joined()
            return
        case ".":
            let texts = Manager.tokenizeMathExpression(inputText)
            if let last = inputText.last, Int(String(last)) != nil,
               let success = texts.last?.contains("."),  !success {
                self.inputText += text
            }
            return
        
        case "=":
            guard inputText.count > 0 else { return }
            var texts = Manager.tokenizeMathExpression(inputText)
            
            self.inputText = texts.compactMap { item in
                if ["/","*","+","-"].contains(item) {
                    return item
                }
                return Manager.normalizeNumberString(item)
            }.joined()
            
            texts = Manager.tokenizeMathExpression(inputText)
            if let last = texts.last, ["/","*","+","-"].contains(last){
                self.inputText = texts.dropLast().joined()
            }
            texts = Manager.tokenizeMathExpression(inputText)
            let result = Manager.removeZeroAndOperators(from: texts).joined()
            let resultNumber = Manager.evaluateExpression(result)
            if texts.count > 1{
                results.append(resultModel(title: title, body: result))
                
                
                self.title = ""
                self.resultNumber = resultNumber
                self.inputText = ""
            }
            return
        case "0":
            self.inputText += text
            var texts = Manager.tokenizeMathExpression(inputText)
            if let item = texts.last, !item.contains("."),
               let number = Int(item),
               let index = texts.firstIndex(where: {$0 == item}){
                texts[index] = String(number)
                self.inputText = texts.joined()
            }
            return
        default:
            self.inputText += text
        }
        
    }
    
    
}

#Preview {
    CalculatorView()
}

