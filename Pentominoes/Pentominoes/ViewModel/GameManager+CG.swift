//
//  GameManager+CG.swift
//  Pentominoes
//
//  Created by Andrew Wu on 9/17/23.
//

import Foundation
import CoreGraphics


extension GameManager {
    
    func getRealSize(_ unitSize : Size) -> CGSize {
        return CGSize(width: unitSize.width * self.blockSize, height: unitSize.height * self.blockSize)
    }
    
    func getRealPosition(for unitPosition : Position, with size : Size) -> CGPoint {
        var width = size.width
        var height = size.height
        // compute top-left coord
        let topLeftX : Int = unitPosition.x * self.blockSize
        let topLeftY : Int = unitPosition.y * self.blockSize
        // consider orientation
        let orientation = unitPosition.orientation.z % 360
        if orientation % 180 != 0 {
            swap(&width, &height)
        }
        // compute offset (to center, and +0.5 manual refine)
        let xOffset : CGFloat = 0.5 * CGFloat(blockSize) + CGFloat(width * blockSize / 2)
        let yOffset : CGFloat = 0.5 * CGFloat(blockSize) + CGFloat(height * blockSize / 2)
        return CGPoint(x: CGFloat(topLeftX) + xOffset, y: CGFloat(topLeftY) + yOffset)
    }
    
    func getUnitMove(of translation: CGSize) -> Size {
        let width = Int(round(translation.width / CGFloat(blockSize)))
        let height = Int(round(translation.height / CGFloat(blockSize)))
        return Size(width: width, height: height)
    }
    
}
