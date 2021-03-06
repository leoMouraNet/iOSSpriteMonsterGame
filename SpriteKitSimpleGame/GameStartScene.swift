import Foundation
import SpriteKit

class GameStartScene: SKScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        let labelTitle = SKLabelNode(fontNamed: "Chalkduster")
        labelTitle.text = "Monsters.IO"
        labelTitle.fontSize = 40
        labelTitle.fontColor = SKColor.yellow
        labelTitle.position = CGPoint(x: size.width/2, y: size.height/2+55)
        addChild(labelTitle)
        
        let labelInsert1 = SKLabelNode(fontNamed: "Chalkduster")
        labelInsert1.text = "One Player"
        labelInsert1.fontSize = 30
        labelInsert1.fontColor = SKColor.white
        labelInsert1.position = CGPoint(x: size.width * 0.3, y: size.height/2)

        let labelInsert2 = SKLabelNode(fontNamed: "Chalkduster")
        labelInsert2.text = "Two Players"
        labelInsert2.fontSize = 30
        labelInsert2.fontColor = SKColor.white
        labelInsert2.position = CGPoint(x: size.width * 0.7, y: size.height/2)

        
        let fadeOut = SKAction.fadeOut(withDuration: 1)
        let fadeIn = SKAction.fadeIn(withDuration: 1)
        let pulse = SKAction.sequence([fadeOut, fadeIn])
        let pulseForever = SKAction.repeatForever(pulse)
        
        labelInsert1.run(pulseForever)
        labelInsert2.run(pulseForever)
        addChild(labelInsert1)
        addChild(labelInsert2)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        if (touchLocation.x < size.width/2) {
            let reveal = SKTransition.doorsOpenVertical(withDuration: 0.5)
            let scene = GameScene(size: size)
            self.view?.presentScene(scene, transition:reveal)
        } else {
            let reveal = SKTransition.doorsOpenVertical(withDuration: 0.5)
            let scene = GameSceneMultiplayer(size: size)
            self.view?.presentScene(scene, transition:reveal)
        }

    }

}

