//
//  Extensions.swift
//  pInspire
//
//  Created by 臧晓雪 on 5/8/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit

extension Int {
    var arc4random: Int {
        return Int(arc4random_uniform(UInt32(self)))
    }
}

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

extension String
{
    func formatIntoValidFirebaseKeyString() -> String
    {
        var newStr = self
        let invalidChars = ["#", "/", ".", "[", "]", "$"]
        for invalidChar in invalidChars {
            if self.contains(invalidChar) {
                newStr = newStr.replace(target: invalidChar, withString:" ")
            }
        }
        return newStr
    }
}
extension Array {
    mutating func shuffle() {
        var last = count - 1
        while(last > 0)
        {
            // Swap the cards randomly.
            let rand = Int(arc4random_uniform(UInt32(last)))
            swapAt(last, rand)
            last -= 1
        }
    }
}

extension CGFloat {
    var arc4random: CGFloat {
        return self * (CGFloat(arc4random_uniform(UInt32.max))/CGFloat(UInt32.max))
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}

extension CGRect
{
    func zoom(by scale: CGFloat) -> CGRect {
        return insetBy(dx: (width - width * scale) / 2, dy: (height - height * scale) / 2)
    }
    
    enum Division {
        case horizontally(by: Int)
        case vertically(by: Int)
        
        var count: Int {
            switch self {
            case .horizontally(let count): return count
            case .vertically(let count): return count
            }
        }
    }
    
    func divided(_ division: CGRect.Division) -> [CGRect] {
        var subrects = [CGRect]()
        // protect against bad input and move to CGFloat world
        let count = division.count > 0 ? CGFloat(division.count) : 0
        // stride creates a StrideTo<CGFloat> struct
        //  (which implements the Sequence protocol so we can do for-in on it)
        // CGFloat has to implement the Strideable protocol (which CGFloat does)
        //  for the stride(from:to:by:) function to work with it
        // alt-click on stride here to see how this generic function is declared
        // you can see that it takes arguments of type T which are forced to be Strideable
        //  by the where clause at the end of its declaration
        //  and you can also see that it returns a StrideTo<T> struct
        // there's also a stride(from:through:by:) function available
        for index in stride(from: 0, to: count, by: 1) {
            switch division {
            case .horizontally:
                subrects.append(CGRect(
                    origin: CGPoint(x: origin.x + (size.width / count) * index, y: origin.y),
                    size: CGSize(width: size.width / count, height: size.height)
                ))
                
            case .vertically:
                subrects.append(CGRect(
                    origin: CGPoint(x: origin.x, y: origin.y + (size.height / count) * index),
                    size: CGSize(width: size.width, height: size.height / count)
                ))
            }
        }
        return subrects
    }
}
