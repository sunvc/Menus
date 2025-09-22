//
//  VipDetailView.swift
//  PeacockMenus
//
//  Created by lynn on 2025/6/28.
//

import SwiftUI
import Defaults

struct VipDetailView: View {
    var item: MemberCardData
    @State private var select:MemberCardData
    @Default(.Cards) var cards
    
    init(item: MemberCardData) {
        self.item = item
        self._select = State(wrappedValue: item)
    }
    var body: some View {
        NavigationStack{
            VStack{
                CardsView()
                ScrollView(.vertical){
                    VStack{
                        HStack{
                            Text(select.footer)
                                .font(.headline)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.top)
                        .padding(.horizontal, 30)
                    }
                }
            }
            .navigationTitle(select.subTitle)
            .navigationBarTitleDisplayMode(.inline)
        }.presentationSizing(.fitted)
    }
    
    @ViewBuilder
    func CardsView()-> some View{
        TabView(selection: $select) {
            ForEach(cards) { item in

                GeometryReader { proxy in
                    HStack{
                        Spacer()
                        VipCardView(
                            item: item,
                            size: CGSize(
                                width: min(proxy.size.width - (ISPAD ? 100 : 20), 500),
                                height: proxy.size.height - (ISPAD ? 10 : 30)
                            ),
                            big: true
                        )

                        Spacer()
                    }
                    
                }.tag(item)

            }
        }
        .tabViewStyle(.page)
        .frame(height: 300)
    }
}
