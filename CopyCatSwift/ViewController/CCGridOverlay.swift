import UIKit

class CCGridOverlay: UIView {
    enum GridType {
        case None
        case Grid
    }
    let _gridLoop: [GridType] = [.None, .Grid]
    
    func drawGrid( p: UIBezierPath, rect: CGRect) {
        let leftPoint1 = CGPoint(x: 0, y: rect.height * (1-0.618))
        let leftPoint2 = CGPoint(x: 0, y: rect.height * 0.618)
        let rightPoint1 = CGPoint(x: rect.width, y: rect.height * (1-0.618) )
        let rightPoint2 = CGPoint(x: rect.width, y: rect.height * 0.618)
        
        p.moveToPoint(leftPoint1)
        p.addLineToPoint(rightPoint1)
        p.closePath()
        p.moveToPoint(leftPoint2)
        p.addLineToPoint(rightPoint2)
        p.closePath()
        
        let topPoint1 = CGPoint(x: rect.width * (1-0.618), y: 0)
        let topPoint2 = CGPoint(x: rect.width * 0.618, y: 0)
        let bottomPoint1 = CGPoint(x: rect.width * (1-0.618), y: rect.height)
        let bottomPoint2 = CGPoint(x: rect.width * 0.618, y:rect.height)
        
        p.moveToPoint(topPoint1)
        p.addLineToPoint(bottomPoint1)
        p.closePath()
        p.moveToPoint(topPoint2)
        p.addLineToPoint(bottomPoint2)
        p.closePath()
        
        // stroke
        UIColor.lightGrayColor().set()
        p.stroke()
    }
    
    //draw the grid lines
    override func drawRect(rect: CGRect) {
        let aPath = UIBezierPath()
        drawGrid(aPath, rect: rect)
    }
    
}