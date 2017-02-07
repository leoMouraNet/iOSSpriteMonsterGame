import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, won:Bool, score:Int) {
        
        super.init(size: size)
        
        
        backgroundColor = SKColor.white
        
        
        let message = won ? "You Won! :D" : "You Lose :["
        
        
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        let labelScore = SKLabelNode(fontNamed: "Chalkduster")
        labelScore.text = "Your score: \(score)"
        labelScore.fontSize = 30
        labelScore.fontColor = SKColor.black
        labelScore.position = CGPoint(x: size.width/2, y: size.height/2-45)
        addChild(labelScore)
        
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run() {
                
                let reveal = SKTransition.doorsCloseVertical(withDuration: 0.5)
                let scene = GameStartScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
        
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
