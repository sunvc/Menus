//
//  ResultView.swift
//  Calculator
//
//  Created by lynn on 2025/6/30.
//

import Defaults
import SwiftUI

struct ResultView: View {
    var result: resultModel

    var tap: (() -> Void)? = nil
    @Default(.numberSuffix) var numberSuffix
    @Default(.results) var results

    var body: some View {
        GeometryReader {
            let size = $0.size
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    Menu {
                        Section {
                            Button {
                                tap?()
                            } label: {
                                Label("选择", systemImage: "arrow.down")
                            }
                        }
                        Button {
                            UIPasteboard.general.string = result.bodys.joined()
                        } label: {
                            Label("复制", systemImage: "doc.on.doc")
                        }
                        Button(role: .destructive) {
                            results.removeAll(where: { $0.id == result.id })
                        } label: {
                            Label("删除", systemImage: "trash.circle")
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Spacer()
                            ForEach(Array(result.bodys.enumerated()), id: \.element) { _, item in
                                MiniImageOrTextView(item: item)
                            }
                            Image(systemName: "equal")
                                .foregroundStyle(.gray)
                            Text(Manager.texthandler(result.result))
                                .lineLimit(1)
                                .font(.largeTitle)

                            let pre = Manager.chineseUnit(result.result)

                            if !pre.isEmpty && numberSuffix {
                                HStack(spacing: 0) {
                                    Text(verbatim: "(")
                                        .foregroundStyle(.gray)
                                    Text(verbatim: "\(pre)")

                                    Text(verbatim: ")")
                                        .foregroundStyle(.gray)
                                }
                            }

                            Text(verbatim: "")
                                .id(result.id)
                        }
                        .frame(minWidth: size.width - 20)
                        .contentShape(Rectangle())
                    }.tint(Color.primary)
                }
                .padding(.horizontal, 10)
                .scrollIndicators(.hidden)
                .viewExtractor(result: { view in
                    if let view = view as? UIScrollView {
                        view.bounces = false
                    }

                })
                .onAppear {
                    proxy.scrollTo(result.id, anchor: .bottomLeading)
                }
            }
        }
    }
}

#Preview {
    CalculatorView()
}
