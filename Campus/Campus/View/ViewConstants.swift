//
//  ViewConstants.swift
//  Campus
//
//  Created by Andrew Wu on 10/7/23.
//

import Foundation
import SwiftUI

struct constants {
    static var routeColor = Color.blue
    static var routeOutlineColor = Color.white
    static var currentStepColor = Color.green
    static var routeStyle = StrokeStyle(lineWidth: constants.routeLineWidth, lineCap: .round, lineJoin: .round)
    static var routeOutlineStyle = StrokeStyle(lineWidth: constants.routeOutlineWidth, lineCap: .round, lineJoin: .round)
    static var routeLineWidth : CGFloat = 6
    static var routeOutlineWidth : CGFloat = 10
}
