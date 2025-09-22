//
//  HomeItemsView.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/9/13.
//


import Defaults
import SwiftUI

struct HomeItemsView: View {
	
	@State var showContent = false
	@State var showMenu = false

	
	@Default(.Categorys) var items
	@Default(.homeItemsTitle) var title
	@Default(.homeItemsSubTitle) var subTitle
	
	@EnvironmentObject var manager:peacock

    @Namespace private var itemSpace


    @State private var selectedItem:CategoryData? = nil

	var body: some View {
		
		VStack {
			HStack {
				VStack(alignment: .leading) {
					Text(title)
						.font(.title)
						.fontWeight(.heavy)
					
					Text(subTitle)
						.foregroundColor(.gray)
				}
				Spacer()
				
			}
			.padding(.leading, 30.0)
			
			
			ScrollViewReader { proxy in
				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						
						scallBtn(proxy: proxy, isHead: true)
						
						
						ForEach($items) { item in
							Button(action: {
								withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.8)){
									self.selectedItem = item.wrappedValue
								}
							}) {
								
								if ISPAD{
									categoryCardView(item: item)
										.fixedSize(horizontal: true, vertical:  false)
										.zIndex(100)
								}else{
									GeometryReader { geometry in
										HStack{
											categoryCardView(item: item)
												.fixedSize(horizontal: true, vertical: false)
										}
										.rotation3DEffect(Angle(degrees: Double(geometry.frame(in: .global).minX - 40) / -20), axis: (x: 0, y: 10, z: 0))
									}.frame(width: 260)
								}
								
								
								
							}
                            .padding(.trailing, 30)
							.id(item.id)
                            .matchedTransitionSource(id: item.id, in: itemSpace)

						}
						
						scallBtn(proxy: proxy)
					}
					.padding(.trailing, 30)
					.padding(.leading, 10)
				}
			}
			
		}
        .fullScreenCover(item: $selectedItem) { item in
            itemsView( selectedItem: item)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .navigationTransition(
                    .zoom(sourceID: item.id, in: itemSpace)
                )

        }

		
		
	}
}

struct categoryCardView: View {
	@Binding var item: CategoryData
	@EnvironmentObject var manager:peacock
	var body: some View {
		ZStack{
			Color(from:  item.color)
				
			
			VStack(alignment: .leading) {
				VStack(alignment: .leading){
					Text(item.title)
						.font(.title)
						.fontWeight(.bold)
						.minimumScaleFactor(0.8)
						.lineLimit(1)
					
					Text(item.subTitle)
						.minimumScaleFactor(0.6)
						.lineLimit(1)
					
					
				}
				.foregroundColor(.white)
				.padding(30)
				
				Spacer()
				
				
				
				AsyncImageView(imageUrl: item.image)
				
					.aspectRatio(contentMode: .fit)
					.frame(width: 260)
			}
			
		}
		
		.cornerRadius(30)
		.shadow(color: Color.shadow2, radius: 1, x: -1, y: -1)
		.shadow(color: Color.shadow1, radius: 1, x: 1, y: 1)
		.shadow(color: Color.shadow1, radius: 10, x: 10, y: 10)
		.shadow(color: Color(from:item.color), radius: 3, x: 3, y: 3)
		.padding()
		.frame(width: 260)
		
		
		
	}
}

#Preview {
	@Previewable @State var showDetail:Bool = false
	HomeItemsView()
		.environmentObject(peacock.shared)
}
