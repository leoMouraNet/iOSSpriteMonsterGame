import Foundation
import SpriteKit

class GameOverSceneMutiplayer: SKScene {
    
    init(size: CGSize, score1:Int, score2:Int) {
        
        super.init(size: size)
        backgroundColor = SKColor.white
        
        
        let message1 = score1 >= score2 ? "Winner! :D" : "Looser :["
        let message2 = score2 >= score1 ? "Winner! :D" : "Looser :["
        
    
        let label1 = SKLabelNode(fontNamed: "Chalkduster")
        label1.text = message1
        label1.fontSize = 30
        label1.fontColor = SKColor.black
        label1.position = CGPoint(x: size.width * 0.2, y: size.height/2)
        addChild(label1)
        
        let labelScore1 = SKLabelNode(fontNamed: "Chalkduster")
        labelScore1.text = "Score: \(score1)"
        labelScore1.fontSize = 30
        labelScore1.fontColor = SKColor.black
        labelScore1.position = CGPoint(x: size.width * 0.2, y: size.height/2-45)
        addChild(labelScore1)

        
        let label2 = SKLabelNode(fontNamed: "Chalkduster")
        label2.text = message2
        label2.fontSize = 30
        label2.fontColor = SKColor.black
        label2.position = CGPoint(x: size.width * 0.7, y: size.height/2)
        addChild(label2)
        
        let labelScore2 = SKLabelNode(fontNamed: "Chalkduster")
        labelScore2.text = "Score: \(score2)"
        labelScore2.fontSize = 30
        labelScore2.fontColor = SKColor.black
        labelScore2.position = CGPoint(x: size.width * 0.7, y: size.height/2-45)
        addChild(labelScore2)

        
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
