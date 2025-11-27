//
//  SubCategoryView.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/9/14.
//

import Defaults
import RealmSwift
import SwiftUI

struct SubCategoryView: View {
    @ObservedRealmObject var subcategory: SubCategoryRealmData

    @ObservedResults(ItemRealmData.self, sortDescriptor: SortDescriptor(
        keyPath: \ItemRealmData.sort, ascending: true
    )) var items
    @State private var showCardDetail: Bool = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    ZStack(alignment: .bottomTrailing) {
                        VStack(alignment: .leading) {
                            Text(subcategory.title)
                                .font(ISPAD ?.title : .title2)
                                .bold()
                                .padding(.top)
                                .lineLimit(1)
                                .layoutPriority(1)
                                .fixedSize(horizontal: true, vertical: false)

                            Text(subcategory.subTitle)
                                .font(.title3)
                                .foregroundStyle(Color.gray)
                                .minimumScaleFactor(0.8)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)

                            if !ISPAD {
                                Text(subcategory.footer)
                                    .minimumScaleFactor(0.3)
                                    .lineLimit(1)
                            }
                        }

                        Text("\(items.filter { $0.subcategoryID == subcategory.id }.count)")
                            .padding(5)
                            .foregroundStyle(.gray)
                            .offset(x: 20)
                    }

                    .padding(.leading, ISPAD ? 50 : 30)

                    if ISPAD {
                        Text(subcategory.footer)
                            .padding(.leading, 10)
                            .minimumScaleFactor(0.3)
                            .lineLimit(1)
                            .padding(.leading)
                    }

                    Spacer()

                    HStack {
                        Toggle(isOn: $showCardDetail) {
                            if ISPAD {
                                Label("显示课程", systemImage: "list.bullet.rectangle")
                                    .minimumScaleFactor(0.3)
                            }
                        }

                        Spacer()
                    }
                    .frame(maxWidth: ISPAD ? 200 : 40)
                    .padding(.trailing, 10)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(
                            items.filter { $0.subcategoryID == subcategory.id },
                            id: \.id
                        ) { item in
                            ProjectCardView(data: item, show: $showCardDetail)
                                .padding()
                                .padding(.bottom)
                        }
                    }.padding(.horizontal, 30)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showCardDetail = true
            }
        }
    }
}

enum showType {
    case all
    case base
    case course
}
