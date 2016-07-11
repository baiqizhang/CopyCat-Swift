import UIKit

class CCGridOverlay: UIView {
    enum GridType {
        case None
        case ThreeCut
        case Grid
        case Square
    }
    let _gridLoop: [GridType] = [.None, .ThreeCut, .Grid, .Square]
    var _gridIndex: Int = 0
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
        self.backgroundColor = UIColor.redColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    func changeToNextType() -> GridType {
        self._gridIndex += 1
        if self._gridIndex >= self._gridLoop.count {
            self._gridIndex = 0
        }
        setNeedsDisplay()
        return self._gridLoop[self._gridIndex]
    }
    
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
        UIColor.whiteColor().set()
        p.stroke()
    }
    
    func drawThreeCut( p: UIBezierPath, rect: CGRect) {
        let leftPoint1 = CGPoint(x: 0, y: rect.height / 3)
        let leftPoint2 = CGPoint(x: 0, y: rect.height * 2 / 3)
        let rightPoint1 = CGPoint(x: rect.width, y: rect.height / 3 )
        let rightPoint2 = CGPoint(x: rect.width, y: rect.height * 2 / 3)
        
        p.moveToPoint(leftPoint1)
        p.addLineToPoint(rightPoint1)
        p.closePath()
        p.moveToPoint(leftPoint2)
        p.addLineToPoint(rightPoint2)
        p.closePath()
        
        let topPoint1 = CGPoint(x: rect.width / 3, y: 0)
        let topPoint2 = CGPoint(x: rect.width * 2 / 3, y: 0)
        let bottomPoint1 = CGPoint(x: rect.width / 3, y: rect.height)
        let bottomPoint2 = CGPoint(x: rect.width * 2 / 3, y:rect.height)
        
        p.moveToPoint(topPoint1)
        p.addLineToPoint(bottomPoint1)
        p.closePath()
        p.moveToPoint(topPoint2)
        p.addLineToPoint(bottomPoint2)
        p.closePath()
        
        // stroke
        UIColor.whiteColor().set()
        p.stroke()
    }
    
    func drawSquare( p: UIBezierPath, rect: CGRect) {
        let leftPoint1 = CGPoint(x: 0, y: (rect.height - rect.width) / 2)
        let leftPoint2 = CGPoint(x: 0, y: (rect.height + rect.width) / 2)
        let rightPoint1 = CGPoint(x: rect.width, y: (rect.height - rect.width) / 2)
        let rightPoint2 = CGPoint(x: rect.width, y: (rect.height + rect.width) / 2)
        
        p.moveToPoint(leftPoint1)
        p.addLineToPoint(rightPoint1)
        p.closePath()
        p.moveToPoint(leftPoint2)
        p.addLineToPoint(rightPoint2)
        p.closePath()
        
        // stroke
        UIColor.whiteColor().set()
        p.stroke()
    }
    
    //draw the grid lines
    override func drawRect(rect: CGRect) {
        let aPath = UIBezierPath()
        switch self._gridLoop[self._gridIndex]{
        case .Grid:
            drawGrid(aPath, rect: rect)
        case .Square:
            drawSquare(aPath, rect: rect)
        case .ThreeCut:
            drawThreeCut(aPath, rect: rect)
        case .None:
            return
        }
    }
    
}