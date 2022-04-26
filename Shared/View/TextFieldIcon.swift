//
//  TextFieldIcon.swift
//  SwiftUI Auth & CoreData & CloudKit
//
//  Created by Ashraful Islam Rupu on 2/27/22.
//

import SwiftUI

struct TextFieldIcon: View {
    var iconName: String
    @Binding var currentlyEditing: Bool
    @State private var colorAngle: Double = 0.0
    @Binding var passedIMage : UIImage?
    
    var gradient1: [Color] = [
        Color.init(red: 101/255, green: 134/255, blue: 1),
        Color.init(red: 1, green: 64/255, blue: 80/255),
        Color.init(red: 109/255, green: 1, blue: 185/255),
        Color.init(red: 39/255, green: 232/255, blue: 1)
    ]
    
    var body: some View {
        ZStack {
            ZStack {
                
                if currentlyEditing {
                    AngularGradient(colors: gradient1, center: .center, angle: .degrees(colorAngle))
                }
                
                Color.primary
                    .cornerRadius(12)
                    .opacity(0.8)
                .blur(radius: 3.0)
                .onAppear(){
                    withAnimation(.linear(duration: 7)) {
                        self.colorAngle += 350
                    }
                }
            }
        }
        .cornerRadius(12)
        .overlay(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: 1)
                    .blendMode(.overlay)
                
                if passedIMage != nil {
                    Image(uiImage: passedIMage!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 28, height: 28, alignment: .center)
                        .cornerRadius(8)
                }else {
                    Image(systemName: iconName)
                        .gradientForeground(colors: [Color.cyan, Color.cyan])
                        .font(.system(size: 17, weight: .medium))
                }
                
            }
        )
        .frame(width: 36, height: 36, alignment: .center)
        .padding([.vertical, .leading], 8)
        
    }
}

struct TextFieldIcon_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldIcon(iconName: "key", currentlyEditing: .constant(true), passedIMage: .constant(nil))
    }
}
