//
//  HomeVipCards.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/9/13.
//

import SwiftUI
import Defaults
import TipKit
import Defaults

struct HomeVipCards: View {
    @Default(.Cards) var cards
    @Default(.homeCardTitle) var title
    @Default(.homeCardSubTitle) var subTitle
	
	@EnvironmentObject var manager:peacock
    @State private var selectVip: MemberCardData?
    @Namespace private var homeSpace
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack{
                VStack(alignment: .leading){
                   
                        
                    Text(title)
                        .font(.title)
                       .fontWeight(.heavy)
              
                       
                     Text(subTitle)
                        .foregroundColor(.gray)
                }.padding(.leading, 30)
                
                
                
                
                Spacer()
            }
            
            
            iphoneViews
                .if(ISPAD) { _ in
                    ipadViews
                }

        }
        .sheet(item: $selectVip) { item in

            VipDetailView(item: item)
                .navigationTransition(
                    .zoom(sourceID: item.id, in: homeSpace)
                )
        }
    }
    
    private var iphoneViews: some View{
        TabView{
            ForEach(cards) { item in
                GeometryReader { proxy in
                    HStack{
                        Spacer()
                        VipCardView(item: item, size: CGSize(width: 355, height: 230))
                            .rotation3DEffect(
                                .degrees(proxy.frame(in: .global).minX / -10),
                                axis: (x: 0, y: 1, z: 0), perspective: 1
                            )
                            .blur(radius: abs(proxy.frame(in: .global).minX) / 40)
                            .padding(10)
                            .onTapGesture {
                                self.selectVip = item
                            }
                            .matchedTransitionSource(
                                id: item.id,
                                in: homeSpace
                            )
                        Spacer()
                    }


                }
			}
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 250)
    }
    
    
    
    
	private var ipadViews: some View{
		ScrollViewReader { proxy in
			ScrollView(.horizontal, showsIndicators: false) {
				HStack(alignment: .center, spacing: 0) {
					
					scallBtn( proxy: proxy, isHead: true)
					
					
					ForEach(cards) { item in
						VipCardView(item: item,size: CGSize(width: 355, height: 230))
							.scaleEffect(0.95)
							.padding(.horizontal, 20)
							.id(item.id)
                            .onTapGesture {
                                self.selectVip = item
                            }
                            .matchedTransitionSource(id: item.id, in: homeSpace)
					}
					scallBtn( proxy: proxy, isHead: false)
					
				}
				.padding(.leading, 10)
				.padding(.vertical)
			}
		}
		
		
	}
	
    
    
}



extension View{
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    /// https://www.avanderlee.com/swiftui/conditional-view-modifier/
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

