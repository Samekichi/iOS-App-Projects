//
//  MapCornerControlView.swift
//  Campus
//
//  Created by Andrew Wu on 10/16/23.
//

import SwiftUI
import MapKit

struct MapCornerControlView: View {
    @State private var isMapKindTextVisible : Bool = false
    @Binding var mapKind : MapKind
    @Binding var configuration : MapConfig
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            // Standard / Hybrid / Imagery
            HStack(alignment: .center) {
                Spacer()
                Menu{
                    Button(action: {configuration = .standard}) {
                        Group{
                            Text("Standard")
                            Image(systemName: "map")
                        }
                    }
                    Button(action: {configuration = .hybrid}) {
                        Group{
                            Text("Hybrid")
                            Image(systemName: "square.stack.3d.up")
                        }
                    }
                    Button(action: {configuration = .imagery}) {
                        Group{
                            Text("Imagery")
                            Image(systemName: "globe.asia.australia")
                        }
                    }
                } label: {
                    Image(systemName: "map.fill")
                        .padding()
                        .frame(width: 45, height: 45, alignment: .center)
                        .background(Color("Appearance").opacity(0.75))
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.25), radius: 4)
                }
                .padding(.trailing, 5)
            }
            // UIKit / SwiftUI
            HStack(alignment: .center) {
                Spacer()
                if isMapKindTextVisible {
                    Text(mapKind == .UIKit ? "UIKit" : "SwiftUI")
                        .foregroundStyle(.primary)
                        .font(.title3)
                        .bold()
                        .opacity(0.67)
                }
                Button(action: {
                    mapKind = mapKind == .UIKit ? .SwiftUI : .UIKit
                    withAnimation(.linear(duration:0.25)) {
                        isMapKindTextVisible = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.linear(duration:0.25)) {
                                isMapKindTextVisible = false
                            }
                        }
                    }
                }) {
                    Image(systemName: mapKind == .UIKit ? "swift" : "cube.fill")
                        .padding()
                        .frame(width: 45, height: 45, alignment: .center)
                        .background(Color("Appearance").opacity(0.75))
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.25), radius: 4)
                }
                .padding(.trailing, 5)
            }
        }
        
    }
}

#Preview {
    MapCornerControlView(mapKind: .constant(.UIKit), configuration: .constant(.standard))
}
