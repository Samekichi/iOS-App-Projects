//
//  EditPanelView.swift
//  Spelling Challenge
//
//  Created by Andrew Wu on 8/27/23.
//

import SwiftUI

struct EditPanelView: View {
    
    @EnvironmentObject var gameManager : GameManager
    
    var body: some View {
        HStack{
            // Delete picked letter
            Button(action: gameManager.onDelete) {
                Image(systemName: "delete.left.fill")
                    .foregroundColor(Color.red)
                    .font(.largeTitle)
                    
            }
            .disabled(gameManager.isEmpty)
            .opacity(gameManager.isEmpty ? viewConstants.disabledOpacity : viewConstants.enabledOpacity)
            
            Spacer()
            
            // Submit picked letter
            Button(action: gameManager.onSubmit) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.green)
                    .font(.largeTitle)
                    
            }
            .disabled(!gameManager.isValid)
            .opacity(gameManager.isValid ? viewConstants.enabledOpacity : viewConstants.disabledOpacity)
        }
        .padding(20)
    }
}
