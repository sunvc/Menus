//
//  ItemDetailView.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/9/13.
//

import SwiftUI
import ScalingHeaderScrollView
import Defaults
import TipKit


struct itemsView: View {
	
	@EnvironmentObject var manager:peacock
    var selectedItem: CategoryData
    @State private var progress:CGFloat = 1
    @State private var isScrolling:Bool = false
    
    @State private var showCardDetail:Bool = false
    
    var columns = Array(repeating: GridItem(.flexible(),spacing: 30), count: 3)
    
    @Default(.Subcategorys) var subcategoryItems
    
    @Default(.Items) var items
    
    var selectItems:[SubCategoryData]{
        return subcategoryItems.filter({$0.categoryId  == selectedItem.id})
    }


    @Environment(\.dismiss) var dismiss

    var body: some View {
        
        ScalingHeaderScrollView {
            ZStack {
                Color(from: selectedItem.color)
                    .edgesIgnoringSafeArea(.all)

                if ISPAD{
                    ipadHeader()
                } else{
                    iphoneHeader()
                }
                
                
            }
        } content: {
            ZStack{
                
                LazyVStack{
                    
                    ForEach(selectItems, id: \.id){item in
                        if items.filter({$0.subcategoryId == item.id}).count > 0{
                            itemView(subcategory: item)
                        }
                    }
                    
                    if selectItems.count > 1{
                        Spacer(minLength: 200)
                    }
                    
                }
                
                
            }
            
            
            
        }
        .initialSnapPosition(initialSnapPosition: 1)
        .allowsHeaderGrowth()
        .height(min: 100.0, max: 100)
        .collapseProgress( .constant(1))
        .setHeaderSnapMode(.immediately)
        .hideScrollIndicators()
        .scrollToTop(resetScroll: .constant(true))
        .background(
            Color.background
        )
        
		
        
        
        
        
    }
    
    private func ipadHeader() -> some View{
        ZStack{
            HStack{
                VStack{
                    Spacer()
                    Button{
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.8)) {
                            self.dismiss()
                        }
                        
                    }label:{
                        Image(systemName: "house.circle")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                
                VStack(alignment: .leading){
                    Spacer()
                    
                    Text(selectedItem.title )
                        .font(.largeTitle)
                        .bold()

                    Text(selectedItem.subTitle)
                }
                .foregroundColor(.white)
                .frame(minWidth: 200)
                .padding(.vertical)
                Spacer()
                
                VStack{
                    Spacer()
                    PickerOfCardView()
                    
                }
                
                
                
                VStack{
                    Spacer()
                    AsyncImageView(imageUrl: selectedItem.image)

                        .scaledToFit()
                        .frame(width: 200)
                        .padding(.trailing, 100)
                }
                
            }
            .opacity( 1 - progress)
            
            VStack{
                Spacer()
                HStack{
                    Button{
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.8)) {
                            self.dismiss()
                        }
                        
                    }label:{
                        Image(systemName: "chevron.left.2")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    
                    Spacer()
					
                    AsyncImageView(imageUrl: selectedItem.image)
                        .scaledToFit()
                        .frame(width: 50)
                        .padding(.horizontal)

                    Text(selectedItem.title )
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                        .lineLimit(1)



                    Text(selectedItem.subTitle)
                        .lineLimit(1)
                        .foregroundColor(.white)

                    
                    PickerOfCardView()
						
                    
                    Spacer()
                    
                }
            }
            .opacity(progress)
            .opacity(max(0, min(1, (progress - 0.75) * 4.0)))
            
        }
        
    }
    
    private func  iphoneHeader() -> some View{
        
        ZStack{
            ZStack{
                VStack{
                    Spacer()
                    HStack(alignment: .bottom){
                        Button{
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.8)) {
                                self.dismiss()

                            }
                            
                        }label:{
                            Image(systemName: "chevron.left.2")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading){
                            Text(selectedItem.title )
                                .font(.title)
                                .bold()
                                .minimumScaleFactor(0.5)

                            Text(selectedItem.subTitle)
                                .minimumScaleFactor(0.5)
                        }
                        .foregroundColor(.white)
                        
                        Spacer()
                    }
                }
                
                VStack{
                    HStack{
                        Spacer()
                        PickerOfCardView()
                            .padding(.top, 30)

							
                    }
                    Spacer()
                }
                
                
                
                
                HStack{
                    Spacer()
                    VStack{
                        Spacer()
                        AsyncImageView(imageUrl: selectedItem.image)
                            .scaledToFit()
                            .frame(width: 100)
                            .padding(.trailing, 10)

                    }
                }
            }
            .padding(10)
            .opacity( 1 - progress)
            
            VStack{
                Spacer()
                HStack{
                    Button{
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.8)) {
                            self.dismiss()
                        }
                        
                    }label:{
                        Image(systemName: "chevron.left.2")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    
                    VStack(alignment: .leading){
                        Text(selectedItem.title )
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)


                        Text(selectedItem.subTitle)
                            .lineLimit(1)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.5)
                    }
                    Spacer()
                    
                    PickerOfCardView()
						
                    
                }.padding(.horizontal,10)
            }
            .opacity(progress)
            .opacity(max(0, min(1, (progress - 0.75) * 4.0)))
            
        }
    }
}


struct PickerOfCardView: View {

	@EnvironmentObject var manager:peacock
    @Default(.Cards) var cards
    let nonmember = MemberCardData.nonmember
    var body: some View {
        Picker(selection: Binding(get: {
            manager.selectCard
        }, set: { value in
            manager.selectCard = value
        })) {
            Text(verbatim: "\(nonmember.name)").tag(nonmember)
            
            ForEach(cards, id: \.id){card in
                Text("\(card.title)\(card.name)").tag(card)
                
            }
        } label: {
            Text("选择卡片")
        }.padding()
            .accentColor(.white)
    }
}






#Preview {
    itemsView(selectedItem: CategoryData(id: "", title: "", subTitle: "", image: "", color: ""))
		.environmentObject(peacock.shared)
}
