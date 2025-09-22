//
//  shape+.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/9/13.
//

import Foundation
import SwiftUI




extension Color{
	init(from comm: String) {
		// 判断是否是十六进制颜色代码
		if comm.hasPrefix("#") || comm.range(of: "^[0-9A-Fa-f]{3,8}$", options: .regularExpression) != nil {
			self = Color(hex: comm)
		} else {
			// 默认作为资源名称初始化
			self = Color(comm)
		}
	}
	
	init(hex: String) {
		let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int: UInt64 = 0
		Scanner(string: hex).scanHexInt64(&int)
		
		let a, r, g, b: UInt64
		switch hex.count {
		case 3: // RGB (12-bit)
			(a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: // RGB (24-bit)
			(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: // ARGB (32-bit)
			(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default:
			(a, r, g, b) = (1, 1, 1, 0) // 处理无效输入，默认白色
		}
		
		self.init(
			.sRGB,
			red: Double(r) / 255,
			green: Double(g) / 255,
			blue:  Double(b) / 255,
			opacity: Double(a) / 255
		)
	}
	
	func toHex(includeAlpha: Bool = true) -> String? {
		// 将颜色转换为 UIColor，以便访问其组件
		guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
			return nil
		}
		
		// 获取颜色组件
		let r = Float(components[0])
		let g = Float(components[1])
		let b = Float(components[2])
		let a = (components.count > 3 ? Float(components[3]) : 1.0)
		
		// 转换为 0 到 255 的整数值
		let rInt = Int(r * 255)
		let gInt = Int(g * 255)
		let bInt = Int(b * 255)
		let aInt = Int(a * 255)
		
		if includeAlpha {
			// 返回包含 alpha 的十六进制字符串
			return String(format: "#%02X%02X%02X%02X", aInt, rInt, gInt, bInt)
		} else {
			// 返回不包含 alpha 的十六进制字符串
			return String(format: "#%02X%02X%02X", rInt, gInt, bInt)
		}
	}
}


extension View {
	var deviceCornerRadius: CGFloat {
		let key = "_displayCornerRadius"
		if let screen = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen {
			if let cornerRadius = screen.value(forKey: key) as? CGFloat {
				return cornerRadius
			}
			
			return 0
		}
		
		return 0
	}
}


// MARK: - buttons 视图
struct ButtonPress: ViewModifier{
    var releaseStyles:Double = 0.0
    var maxX:Double = 0.0
    var onPress:((DragGesture.Value)->Void)? = nil
    var onRelease:((DragGesture.Value)->Bool)? = nil
    
    @State private var ispress = false
    
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .scaleEffect(ispress ? 0.99 : 1)
            .opacity(ispress ? 0.6 : 1)
            .animation(.easeInOut(duration: 0.1), value: ispress)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ result in
                        self.ispress = true
                        onPress?(result)
                        if releaseStyles > 0.0 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + releaseStyles ){
                                self.ispress = false
                            }
                        }
                    })
                    .onEnded({ result in
                        self.ispress = false
                        if abs(result.translation.width) <= maxX {
                            
                            if let success = onRelease?(result), success{
                                Haptic.impact()
                            }
                        }
                    })
            )
    }
}



extension View{
    func VButton(_ maxX:Double = 0.0,
                 release:Double = 0.0,
                 onPress: ((DragGesture.Value)->Void)? = nil,
                 onRelease: ((DragGesture.Value)->Bool)? = nil)-> some View{
        modifier(ButtonPress(releaseStyles: release, maxX: maxX, onPress:onPress, onRelease: onRelease))
    }
}



extension View{
    @ViewBuilder
    func viewExtractor(result: @escaping (UIView)-> ()) -> some View{
        self
            .background(ViewExtractHelper(result: result))
            .compositingGroup()
    }
}


fileprivate struct ViewExtractHelper: UIViewRepresentable {
    var result:(UIView) -> ()
    func makeUIView(context: Context) -> some UIView {
        let view  = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            if let uikitview = view.superview?.superview?.subviews.last?.subviews.first{
                result(uikitview)
            }
        }
        
        return view
        
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct TagLayout: Layout {
    /// Layout Properties
    var alignment: Alignment = .center
    /// Both Horizontal & Vertical
    var spacing: CGFloat = 10
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        var height: CGFloat = 0
        let rows = generateRows(maxWidth, proposal, subviews)
        
        for (index, row) in rows.enumerated() {
            /// Finding max Height in each row and adding it to the View's Total Height
            if index == (rows.count - 1) {
                /// Since there is no spacing needed for the last item
                height += row.maxHeight(proposal)
            } else {
                height += row.maxHeight(proposal) + spacing
            }
        }
        
        return .init(width: maxWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        /// Placing Views
        var origin = bounds.origin
        let maxWidth = bounds.width
        
        let rows = generateRows(maxWidth, proposal, subviews)
        
        for row in rows {
            /// Chaning Origin X based on Alignments
            let leading: CGFloat = bounds.maxX - maxWidth
            let trailing = bounds.maxX - (row.reduce(CGFloat.zero) { partialResult, view in
                let width = view.sizeThatFits(proposal).width
                
                if view == row.last {
                    /// No Spacing
                    return partialResult + width
                }
                /// With Spacing
                return partialResult + width + spacing
            })
            let center = (trailing + leading) / 2
            
            /// Resetting Origin X to Zero for Each Row
            origin.x = (alignment == .leading ? leading : alignment == .trailing ? trailing : center)
            
            for view in row {
                let viewSize = view.sizeThatFits(proposal)
                view.place(at: origin, proposal: proposal)
                /// Updaing Origin X
                origin.x += (viewSize.width + spacing)
            }
            
            /// Updating Origin Y
            origin.y += (row.maxHeight(proposal) + spacing)
        }
    }
    
    /// Generating Rows based on Available Size
    func generateRows(_ maxWidth: CGFloat, _ proposal: ProposedViewSize, _ subviews: Subviews) -> [[LayoutSubviews.Element]] {
        var row: [LayoutSubviews.Element] = []
        var rows: [[LayoutSubviews.Element]] = []
        
        /// Origin
        var origin = CGRect.zero.origin
        
        for view in subviews {
            let viewSize = view.sizeThatFits(proposal)
            
            /// Pushing to New Row
            if (origin.x + viewSize.width + spacing) > maxWidth {
                rows.append(row)
                row.removeAll()
                /// Resetting X Origin since it needs to start from left to right
                origin.x = 0
                row.append(view)
                /// Updating Origin X
                origin.x += (viewSize.width + spacing)
            } else {
                /// Adding item to Same Row
                row.append(view)
                /// Updating Origin X
                origin.x += (viewSize.width + spacing)
            }
        }
        
        /// Checking for any exhaust row
        if !row.isEmpty {
            rows.append(row)
            row.removeAll()
        }
        
        return rows
    }
}

/// Returns Maximum Height From the Row
extension [LayoutSubviews.Element] {
    func maxHeight(_ proposal: ProposedViewSize) -> CGFloat {
        return self.compactMap { view in
            return view.sizeThatFits(proposal).height
        }.max() ?? 0
    }
}
