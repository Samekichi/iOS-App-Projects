//
//  PreferenceButtonView.swift
//  Pentominoes
//
//  Created by Andrew Wu on 9/18/23.
//

import SwiftUI

struct PreferenceButtonView: View {
    @EnvironmentObject var manager : GameManager
    
    var body: some View {
        HStack {
            Spacer()
//            Button(action: {manager.preference()}) {
//                Image(systemName: "gear")
//            }
//            .font(.largeTitle)
//            .padding(4)
//            .foregroundColor(.white)
//            .background(RoundedRectangle(cornerRadius: 10)
//                            .fill(.gray))
        }
    }
}

//struct PreferenceButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreferenceButtonView()
//    }
//}
