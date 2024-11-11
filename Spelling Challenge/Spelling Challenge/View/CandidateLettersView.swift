//
//  CandidateLettersView.swift
//  Spelling Challenge
//
//  Created by Andrew Wu on 8/27/23.
//

import SwiftUI


struct CandidateLettersView: View {
    
    @EnvironmentObject var gameManager : GameManager
    
    let candidateLetters : [ Character ]
    var numberOfLetters : Int  {candidateLetters.count}
    var angles : [CGFloat] {
        switch numberOfLetters {
        case 5:
            return [0, 45, 135, 225, 315]
        case 6:
            return [0, 18, 90, 162, 234, 306]
        case 7:
            return [0, 30, 90, 150, 210, 270, 330]
        default:
            return []
        }
    }
    var rotations : [CGFloat] {
        switch numberOfLetters {
        case 5:
            return [0, 0, 0, 0, 0]
        case 6:
            return [-18, -198, -198, -198, -198, -198]
        case 7:
            return [0, 0, 0, 0, 0, 0, 0]
        default:
            return []
        }
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack{
                ForEach(0..<numberOfLetters, id:\.self) { i in
                    
                    var isCenter : Bool  { i == 0 }
                    let angle : CGFloat = CGFloat(angles[i] * .pi / 180.0)
                    let offset : CGFloat = isCenter ? CGFloat() : CGFloat(80)
                    
                    CandidateLetterButton(letter: candidateLetters[i], isCenter: isCenter, rotation: rotations[i])
                        .position(x: center.x + offset * cos(angle), y: center.y + offset * sin(angle))
                }
            }
        }
    }
}


struct CandidateLetterButton : View {
    
    @EnvironmentObject var gameManager : GameManager
    let letter : Character
    let isCenter : Bool
    let rotation : CGFloat
    
    var body : some View {
        Button(
            String(letter),
            action: { gameManager.onLetterTapped(letter: letter)
            }
        )
        .frame(width: 45, height: 45)
        .padding()
        .foregroundColor(.white)
        .background(
            Group {
                isCenter ? Color(red: 234/255, green: 139/255, blue: 11/255) : Color(red: 100/255, green: 127/255, blue: 147/255)
            }
            .clipShape(NPolygon(sides: gameManager.numberOfSides))
            .rotationEffect(Angle(degrees: rotation))
        )
        .font(.largeTitle)
        .bold()
    }
}

struct NPolygon : Shape {
    
    let sides : Int  // sides = numberOfLetters - 1
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        let r = min(rect.size.width, rect.size.height) / 2.0
        let center = CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0)

        for i in 0..<sides {
            let angle = CGFloat(i) * (360.0 / CGFloat(sides)) * CGFloat.pi / 180.0
            let point = CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        path.closeSubpath()
        return path
    }
    
}
