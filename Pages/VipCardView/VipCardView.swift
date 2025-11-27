//
//  VipCardView.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/9/9.
//

import RealmSwift
import SwiftUI

struct VipCardView: View {
    @ObservedRealmObject var item: MemberCardRealmData
//    var item:MemberCardData
    var size: CGSize = .init(width: 340, height: 220)
    var big: Bool = false

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(big ? .largeTitle : .title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color("accent2"))
                            .padding(.top)
                            .minimumScaleFactor(0.5)

                        Text(item.subTitle)
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                    Spacer()

                    Text(item.name)
                        .font(big ? .title : .title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("accent2"))
                }
                .padding(.horizontal)
                Spacer()
            }

            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    HStack {
                        Text("¥")
                            .font(.caption)

                        Text("\(item.money)")
                            .font(big ? .title : .title2)
                            .fontWeight(.bold)

                        Text("元")
                            .font(.caption)

                    }.padding()
                        .foregroundColor(Color("accent2"))
                    Spacer()
                }
            }

            VStack {
                Spacer()

                HStack {
                    Spacer()
                    AsyncImageView(imageURL: item.image)
                        .scaledToFit()
                        .frame(width: size.height - (big ? 80 : 50))
                }
            }

            HStack {
                Text(item.footer)
                    .font(.system(size: 17))
                    .lineLimit(3)
                    .bold()
                    .foregroundColor(.white)
                    .offset(x: -size.width)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(10)
            .frame(minHeight: 80)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .offset(x: -size.width + 10)
            .contentShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(width: size.width, height: size.height)
        .background(Color.background0)
        .clipped()
        .cornerRadius(10)
        .shadow(color: Color.shadow1, radius: 10, x: 5, y: 10)
        .shadow(color: Color.shadow2, radius: 1, x: -1, y: -1)
    }
}
