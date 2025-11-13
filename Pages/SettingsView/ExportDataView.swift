//
//  ExportDataView.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/9/8.
//

import SwiftUI

struct ExportDataView: View {
	@EnvironmentObject var manager:peacock

    @State private var exportData:String = "没有数据"
    @State private var fileURL:URL?
    @State private var isEditing:Bool = false
    
    var body: some View {
        List{
            
//            编辑
            Section{
                TextEditor(text: $exportData)
                    .frame(maxHeight: 500)
                    .truncationMode(.tail)
                    .disabled(!isEditing)
            }header: {
                Text("全部数据")
            }
            
            
        }.toolbar{
            if let fileurl = fileURL{
                ToolbarItem(placement: .topBarLeading) {
                    ShareLink(item: fileurl, preview: SharePreview(String("menus.json"), icon: "square.and.arrow.up"))
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button{
                    self.isEditing.toggle()
                }label: {
                    Label(isEditing ? "完成" : "编辑", systemImage: isEditing ? "checkmark.circle" : "square.and.pencil.circle")
                }
            }
            
        }
        .task {
            DispatchQueue.global(qos: .background).async {
                let data = peacock.shared.exportTotalData()
                let file =  peacock.shared.saveJSONToTempFile(object: data, fileName: "PeacockMenus-\(Date().yyyyMMddhhmmss())")
                DispatchQueue.main.async {
                    self.fileURL = file
                    self.exportData = peacock.shared.exportData()
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        ExportDataView()
			.environmentObject(peacock.shared)
    }
   
}
