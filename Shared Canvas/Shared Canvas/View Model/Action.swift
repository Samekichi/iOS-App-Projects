//
//  Action.swift
//  Shared Canvas
//
//  Created by Andrew Wu on 12/1/23.
//

import Foundation

enum ActionType : Codable {
    case add, erase, move, canvasParameter
}

struct Action : Codable {
    let actionType : ActionType
    
    // Add / Move
    let elementID : UUID?
    // Erase
    let elementIDs : Set<UUID>?
    
    // Add
    let element : AnyCanvasElement?
    
    // Move
    let translation : CGSize?
    
    init(actionType: ActionType, elementID: UUID? = nil, elementIDs: Set<UUID>? = nil, element: AnyCanvasElement? = nil, translation: CGSize? = nil) {
        self.actionType = actionType
        self.elementID = elementID
        self.elementIDs = elementIDs
        self.element = element
        self.translation = translation
    }
}
