//
//  ContentView.swift
//  ImageView
//
//  Created by electrozone on 3/27/26.
//

import SwiftUI

struct Car: View {
    @State var lampWidth: [CGFloat] = [320.0, 130.0]
    @State var lampHeight: [CGFloat] = [500.0, 200.0]
    @State var imageLamp: [String] = ["lamp_on", "lamp_off"]
    @State var imageLargeSmallSeq: Int = 0
    @State var toggleStatus: Bool = true
    @State var buttonString: String = "축소"
    
    var body: some View {
        VStack {
            Image(toggleStatus ? imageLamp[0] : imageLamp[1])
                .resizable()
                .frame(width: lampWidth[imageLargeSmallSeq], height: lampHeight[imageLargeSmallSeq])
                .fixedSize()
                .padding(.bottom, 100)
                .frame(width: 400, height: 500) //size는 무조건 frame
            
           HStack(content: {
               Button(buttonString, action: {
                   displayImage(buttonString)
               })
               .padding(.trailing, 50) // leading-> 오른쪽, trailing->왼쪽
               
               Text(toggleStatus ? "켜짐" : "꺼짐")
               
               Toggle("", isOn: $toggleStatus)
                   .labelsHidden()
               
               
           })
            
        }
        .padding()
    } // body
    
    // ---Function ----
    func displayImage(_ s: String){
        if s == "축소"{
            imageLargeSmallSeq = 1
            buttonString = "확대"
        }else{
            imageLargeSmallSeq = 0
            buttonString = "축소"
        }
    }
    
    
}

#Preview {
    Car()
}
