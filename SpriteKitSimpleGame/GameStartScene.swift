import Foundation
import SpriteKit

class GameStartScene: SKScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        let labelTitle = SKLabelNode(fontNamed: "Chalkduster")
        labelTitle.text = "Monsters.IO"
        labelTitle.fontSize = 40
        labelTitle.fontColor = SKColor.yellow
        labelTitle.position = CGPoint(x: size.width/2, y: size.height/2+45)
        addChild(labelTitle)
        
        let labelInsert = SKLabelNode(fontNamed: "Chalkduster")
        labelInsert.text = "Insert the coin"
        labelInsert.fontSize = 40
        labelInsert.fontColor = SKColor.white
        labelInsert.position = CGPoint(x: size.width/2, y: size.height/2)
        
        let fadeOut = SKAction.fadeOut(withDuration: 1)
        let fadeIn = SKAction.fadeIn(withDuration: 1)
        let pulse = SKAction.sequence([fadeOut, fadeIn])
        let pulseForever = SKAction.repeatForever(pulse)
        
        labelInsert.run(pulseForever)
        
        addChild(labelInsert)
        
        
    }

}
