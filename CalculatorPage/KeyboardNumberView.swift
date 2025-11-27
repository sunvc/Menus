//
//  KeyboardNumberView.swift
//  PeacockMenus
//
//  Created by lynn on 2025/7/4.
//

import Defaults
import SwiftUI

struct KeyboardNumberView: View {
    @Default(.results) var results

    var height: CGFloat
    var menu: (ButtonType) -> Void
    var onTap: (String) -> Void
    let firstRaws: [[NumberPress.Key]] = [
        [.ac, .divide, .multiply, .back],
        [.seven, .eight, .nine, .minus],
        [.four, .five, .six, .plus],
    ]

    enum ButtonType: String, CaseIterable {
        case clear = "windshield.rear.and.wiper"
        case sum
        case average = "a.circle"

        var name: String {
            switch self {
            case .clear:
                String(localized: "清屏")
            case .sum:
                String(localized: "求和")
            case .average:
                String(localized: "平均值")
            }
        }
    }

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 1, verticalSpacing: 1) {
            ForEach(firstRaws, id: \.self) { items in
                GridRow {
                    ForEach(items, id: \.self) { item in
                        NumberButton(key: item, height: height, tap: onTap)
                    }
                }
            }

            GridRow {
                Grid(alignment: .leading, horizontalSpacing: 1, verticalSpacing: 1) {
                    GridRow {
                        NumberButton(key: .one, height: height, tap: onTap)
                        NumberButton(key: .two, height: height, tap: onTap)
                        NumberButton(key: .three, height: height, tap: onTap)
                    }
                    GridRow {
                        HStack(spacing: 1) {
                            MenuPress()
                                .frame(width: 100)
                            NumberButton(key: .zero, height: height, tap: onTap)
                        }.gridCellColumns(2)

                        NumberButton(key: .point, height: height, tap: onTap)
                    }
                }.gridCellColumns(3)

                NumberButton(key: .equal, height: height * 2, tap: onTap)
            }
        }
    }

    @ViewBuilder
    func MenuPress() -> some View {
        Menu {
            ForEach(ButtonType.allCases, id: \.self) { item in
                Section {
                    Button(role: item == .clear ? .destructive : .cancel) {
                        withAnimation {
                            menu(item)
                        }
                    } label: {
                        Label(item.name, systemImage: item.rawValue)
                    }
                }
            }
            Section {
                NavigationLink {
                    CalculatorSettings()
                } label: {
                    Label("设置", systemImage: "gear")
                }
            }

        } label: {
            ZStack {
                Rectangle()
                    .fill(Color.orange.gradient)
                Image(systemName: "filemenu.and.selection")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }.preferredColorScheme(.dark)
    }
}

struct NumberButton: View {
    var item: NumberPress
    var key: NumberPress.Key
    var height: CGFloat
    var onTap: (String) -> Void

    init(key: NumberPress.Key, height: CGFloat, tap: @escaping (String) -> Void) {
        self.height = height
        item = NumberPress[key]
        onTap = tap
        self.key = key
    }

    var body: some View {
        Button {
            onTap(item.value)
        } label: {
            ZStack {
                Rectangle()
                    .fill(item.color.gradient)
                if let image = item.image {
                    Image(systemName: image)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                } else {
                    Text(item.value)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }.frame(height: heightHandler(key: key))
    }

    func heightHandler(key: NumberPress.Key) -> CGFloat {
        let specialKeys: [NumberPress.Key] = [.zero, .point, .percent, .equal]
        if specialKeys.contains(key) {
            return height + 20
        } else {
            return height
        }
    }
}
