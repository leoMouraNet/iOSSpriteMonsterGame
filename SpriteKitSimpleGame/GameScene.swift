import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1
    static let Projectile: UInt32 = 0b10
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let background = SKSpriteNode(imageNamed:"skyBackground")
    let player = SKSpriteNode()

    let playerAtlas = SKTextureAtlas(named:"player.atlas")
    let explosionAtlas = SKTextureAtlas(named:"explosion.atlas")
    var playerSpriteArray = Array<SKTexture>();
    var explosionSpriteArray = Array<SKTexture>();
    
    let flame = SKSpriteNode(imageNamed:"flame2")
    var isFingerOnPlayer = false
    var monstersDestroyed = 0
    var offset = CGPoint()
    
    var levelTimerLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    //Immediately after leveTimerValue variable is set, update label's text
    var levelTimerValue: Int = 30 {
        didSet {
            if (levelTimerValue<10) {
                levelTimerLabel.fontColor = SKColor.red
            }
            levelTimerLabel.text = "Timer: \(levelTimerValue)"
        }
    }
    
    override func didMove(to view: SKView) {
        //backgroundColor = SKColor.blue
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = 1
        addChild(background)
        
        levelTimerLabel.fontColor = SKColor.yellow
        levelTimerLabel.fontSize = 30
        levelTimerLabel.position = CGPoint(x: size.width/2, y: size.height/2+120)
        levelTimerLabel.text = "Timer: \(levelTimerValue)"
        levelTimerLabel.zPosition = 5
        addChild(levelTimerLabel)

        let wait = SKAction.wait(forDuration: 1) //change countdown speed here
        let block = SKAction.run({
            [unowned self] in
            
            if self.levelTimerValue > 0{
                self.levelTimerValue -= 1
            }else{
                self.removeAction(forKey: "countdown")
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameOverScene = GameOverScene(size: self.size, won: true, score: self.monstersDestroyed)
                self.view?.presentScene(gameOverScene, transition: reveal)
            }
        })
        let sequence = SKAction.sequence([wait,block])
        
        run(SKAction.repeatForever(sequence), withKey: "countdown")
        
        playerSpriteArray.append(playerAtlas.textureNamed("rocketmouse_stop"))
        playerSpriteArray.append(playerAtlas.textureNamed("rocketmouse_fly"))
        playerSpriteArray.append(playerAtlas.textureNamed("rocketmouse_dead"))
        
        for i in 1..<16 {
            let imageName = "explosion_\(i)"
            explosionSpriteArray.append(explosionAtlas.textureNamed(imageName))
        }

        player.texture = playerSpriteArray[0]
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        player.size = CGSize(width: 60, height: 60)
        player.zPosition = 4
        addChild(player)
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addMonster),
                SKAction.wait(forDuration: 1.0)
                ])
        ))
        
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed:"frame-1")
        monster.zPosition = 4
        monster.size = CGSize(width: 50, height: 50)
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Determine where to spawn the monster along the X axis
        let actualX = random(min: monster.size.width/2, max: size.width - monster.size.width/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: actualX, y: size.height + monster.size.height/2)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(6.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y: -monster.size.height/2), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        //let loseAction = SKAction.run() {
            //let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            //let gameOverScene = GameOverScene(size: self.size, won: false)
            //self.view?.presentScene(gameOverScene, transition: reveal)
        //}
        monster.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
     
        if (player.contains(touchLocation)) {
            isFingerOnPlayer = true
            player.texture = playerSpriteArray[1]
            flame.position = CGPoint(x: player.position.x-30, y: player.position.y-24)
            flame.size = CGSize(width: 25, height: 25)
            flame.zPosition = 3
            addChild(flame)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFingerOnPlayer {
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            let previousLocation = touch!.previousLocation(in: self)
            offset = touchLocation - previousLocation
            var playerY = player.position.y + (touchLocation.y - previousLocation.y)
            
            playerY = max(playerY, player.size.height/2)
            playerY = min(playerY, size.height - player.size.height/2)
            

            var playerX = player.position.x + (touchLocation.x - previousLocation.x)
            
            playerX = max(playerX, player.size.width/2)
            playerX = min(playerX, size.width - player.size.width/2)

            // Determine offset of location to flip
            if (offset.x <= 0 && player.xScale>0) {
                player.xScale = player.xScale * -1
                flame.xScale = flame.xScale * -1
            }
            if (offset.x > 0 && player.xScale<0) {
                player.xScale = player.xScale * -1;
                flame.xScale = flame.xScale * -1;
            }
            
            var flameX = CGFloat()
            if (player.xScale > 0) {
                flameX = -30
            } else {
                flameX = 30
            }
            
            player.position = CGPoint(x: playerX, y: playerY)
            flame.position = CGPoint(x: player.position.x + flameX, y: player.position.y-24)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (isFingerOnPlayer) {
            isFingerOnPlayer = false
            flame.removeFromParent()
            player.texture = playerSpriteArray[0]
            return
        } else {
            run(SKAction.playSoundFileNamed("fireball.caf", waitForCompletion: false))
            
            // 1 - Choose one of the touches to work with
            guard let touch = touches.first else {
                return
            }
            let touchLocation = touch.location(in: self)
            
            // 2 - Set up initial location of projectile
            let projectile = SKSpriteNode(imageNamed: "flame1")
            projectile.position = player.position
            projectile.zPosition = 2
            projectile.size = CGSize(width: 40, height: 40)
            
            // 3 - Determine offset of location to projectile
            let offset = touchLocation - projectile.position
            
            projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
            projectile.physicsBody?.isDynamic = true
            projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
            projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
            projectile.physicsBody?.usesPreciseCollisionDetection = true
            
            // 4 - check if you are shooting down or backwards
            // Determine offset of location to flip
            if (offset.x <= 0 && player.xScale>0) {
                player.xScale = player.xScale * -1
                flame.xScale = flame.xScale * -1
            }
            
            if (offset.x > 0 && player.xScale<0) {
                player.xScale = player.xScale * -1
                flame.xScale = flame.xScale * -1
            }
            
            if (offset.x <= 0) {
                projectile.xScale = projectile.xScale * -1
            }
            
            if (offset.y <= 0) {
                projectile.yScale = projectile.yScale * -1
            }
            
            // 5 - OK to add now - you've double checked position
            addChild(projectile)
            
            // 6 - Get the direction of where to shoot
            let direction = offset.normalized()
            
            // 7 - Make it shoot far enough to be guaranteed off screen
            let shootAmount = direction * 1000
            
            // 8 - Add the shoot amount to the current position
            let realDest = shootAmount + projectile.position
            
            // 9 - Create the actions
            let actionMove = SKAction.move(to: realDest, duration: 2.0)
            let actionMoveDone = SKAction.removeFromParent()
            projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
        }
    }
    
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        print("Hit")
        let explosion = SKSpriteNode(texture: explosionSpriteArray[0])
        
        explosion.position = monster.position
        let animationAction = SKAction.animate(with: explosionSpriteArray, timePerFrame: 0.1)
        let removeExplosion = SKAction.removeFromParent()
        let explosionAction = SKAction.sequence([animationAction,removeExplosion])
        explosion.run(explosionAction)
        explosion.zPosition = 3
        addChild(explosion)
        //run(SKAction.playSoundFileNamed("laser.wav", waitForCompletion: false))
        projectile.removeFromParent()
        monster.removeFromParent()
        monstersDestroyed += 1
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            if let monster = firstBody.node as? SKSpriteNode, let
                projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }

        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            if let monster = firstBody.node as? SKSpriteNode, let
                projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
        
        
    }

}
