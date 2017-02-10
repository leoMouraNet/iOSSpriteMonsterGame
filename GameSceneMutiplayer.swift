import SpriteKit
import GameplayKit

class GameSceneMultiplayer: SKScene, SKPhysicsContactDelegate {
    
    let background = SKSpriteNode(imageNamed:"skyBackground")
    let player1 = SKSpriteNode()
    let player2 = SKSpriteNode()
    
    let playerAtlas = SKTextureAtlas(named:"player.atlas")
    let explosionAtlas = SKTextureAtlas(named:"explosion.atlas")
    var playerSpriteArray = Array<SKTexture>();
    var explosionSpriteArray = Array<SKTexture>();
    
    let flame1 = SKSpriteNode(imageNamed:"flame2")
    let flame2 = SKSpriteNode(imageNamed:"flame2")

    var isFingerOnPlayer1 = false
    var isFingerOnPlayer2 = false

    var monstersDestroyed1 = 0
    var monstersDestroyed2 = 0

    var offset1 = CGPoint()
    var offset2 = CGPoint()
    
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
                let gameOverScene = GameOverSceneMutiplayer(size: self.size, score1: self.monstersDestroyed1, score2: self.monstersDestroyed2)
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
        
        player1.texture = playerSpriteArray[0]
        player1.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        player1.size = CGSize(width: 60, height: 60)
        player1.zPosition = 4
        addChild(player1)

        player2.texture = playerSpriteArray[0]
        player2.position = CGPoint(x: size.width * 0.9, y: size.height * 0.5)
        player2.size = CGSize(width: 60, height: 60)
        player2.zPosition = 4
        player2.xScale = -1
        addChild(player2)

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
        let monster1 = SKSpriteNode(imageNamed:"frame-1")
        monster1.zPosition = 4
        monster1.size = CGSize(width: 50, height: 50)
        monster1.physicsBody = SKPhysicsBody(rectangleOf: monster1.size)
        monster1.physicsBody?.isDynamic = true
        monster1.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster1.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        monster1.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Determine where to spawn the monster along the X axis
        let actualX1 = random(min: monster1.size.width/2, max: size.width/2 - monster1.size.width/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster1.position = CGPoint(x: actualX1, y: size.height + monster1.size.height/2)
        
        // Add the monster to the scene
        addChild(monster1)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(6.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: actualX1, y: -monster1.size.height/2), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        //let loseAction = SKAction.run() {
        //let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        //let gameOverScene = GameOverScene(size: self.size, won: false)
        //self.view?.presentScene(gameOverScene, transition: reveal)
        //}
        monster1.run(SKAction.sequence([actionMove, actionMoveDone]))
        
        // Create sprite
        let monster2 = SKSpriteNode(imageNamed:"frame-1")
        monster2.zPosition = 4
        monster2.size = CGSize(width: 50, height: 50)
        monster2.physicsBody = SKPhysicsBody(rectangleOf: monster2.size)
        monster2.physicsBody?.isDynamic = true
        monster2.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster2.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        monster2.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Determine where to spawn the monster along the X axis
        let actualX2 = random(min: size.width/2 + monster2.size.width/2, max: size.width - monster2.size.width/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster2.position = CGPoint(x: actualX2, y: size.height + monster2.size.height/2)
        
        // Add the monster to the scene
        addChild(monster2)
        
        // Determine speed of the monster
        let actualDuration2 = random(min: CGFloat(2.0), max: CGFloat(6.0))
        
        // Create the actions
        let actionMove2 = SKAction.move(to: CGPoint(x: actualX2, y: -monster2.size.height/2), duration: TimeInterval(actualDuration2))
        let actionMoveDone2 = SKAction.removeFromParent()
        //let loseAction = SKAction.run() {
        //let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        //let gameOverScene = GameOverScene(size: self.size, won: false)
        //self.view?.presentScene(gameOverScene, transition: reveal)
        //}
        monster2.run(SKAction.sequence([actionMove2, actionMoveDone2]))
        
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)

            if (player1.contains(touchLocation)) {
                isFingerOnPlayer1 = true
                player1.texture = playerSpriteArray[1]
                flame1.position = CGPoint(x: player1.position.x-30, y: player1.position.y-24)
                flame1.size = CGSize(width: 25, height: 25)
                flame1.zPosition = 3
                addChild(flame1)
            }

        if (player2.contains(touchLocation)) {
                isFingerOnPlayer2 = true
                player2.texture = playerSpriteArray[1]
                flame2.position = CGPoint(x: player2.position.x-30, y: player2.position.y-24)
                flame2.size = CGSize(width: 25, height: 25)
                flame2.zPosition = 3
                addChild(flame2)
            }
            
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFingerOnPlayer1 {
            let touch1 = touches.first
            let touchLocation1 = touch1!.location(in: self)
            let previousLocation1 = touch1!.previousLocation(in: self)
            offset1 = touchLocation1 - previousLocation1
            var playerY1 = player1.position.y + (touchLocation1.y - previousLocation1.y)
            
            playerY1 = max(playerY1, player1.size.height/2)
            playerY1 = min(playerY1, size.height - player1.size.height/2)
            
            
            var playerX1 = player1.position.x + (touchLocation1.x - previousLocation1.x)
            
            playerX1 = max(playerX1, player1.size.width/2)
            playerX1 = min(playerX1, size.width - player1.size.width/2)
            
            // Determine offset of location to flip
            if (offset1.x <= 0 && player1.xScale>0) {
                player1.xScale = player1.xScale * -1
                flame1.xScale = flame1.xScale * -1
            }
            if (offset1.x > 0 && player1.xScale<0) {
                player1.xScale = player1.xScale * -1;
                flame1.xScale = flame1.xScale * -1;
            }
            
            var flameX1 = CGFloat()
            if (player1.xScale > 0) {
                flameX1 = -30
            } else {
                flameX1 = 30
            }
            
            player1.position = CGPoint(x: playerX1, y: playerY1)
            flame1.position = CGPoint(x: player1.position.x + flameX1, y: player1.position.y-24)
        }
        
        if isFingerOnPlayer2 {
            let touch2 = touches.first
            let touchLocation2 = touch2!.location(in: self)
            let previousLocation2 = touch2!.previousLocation(in: self)
            offset2 = touchLocation2 - previousLocation2
            var playerY2 = player2.position.y + (touchLocation2.y - previousLocation2.y)
            
            playerY2 = max(playerY2, player2.size.height/2)
            playerY2 = min(playerY2, size.height - player2.size.height/2)
            
            
            var playerX2 = player2.position.x + (touchLocation2.x - previousLocation2.x)
            
            playerX2 = max(playerX2, player2.size.width/2)
            playerX2 = min(playerX2, size.width - player2.size.width/2)
            
            // Determine offset of location to flip
            if (offset2.x <= 0 && player2.xScale>0) {
                player2.xScale = player2.xScale * -1
                flame2.xScale = flame2.xScale * -1
            }
            if (offset2.x > 0 && player2.xScale<0) {
                player2.xScale = player2.xScale * -1;
                flame2.xScale = flame2.xScale * -1;
            }
            
            var flameX2 = CGFloat()
            if (player2.xScale > 0) {
                flameX2 = -30
            } else {
                flameX2 = 30
            }
            
            player2.position = CGPoint(x: playerX2, y: playerY2)
            flame2.position = CGPoint(x: player2.position.x + flameX2, y: player2.position.y-24)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        if (touchLocation.x < size.width/2) {
            if (isFingerOnPlayer1) {
                isFingerOnPlayer1 = false
                flame1.removeFromParent()
                player1.texture = playerSpriteArray[0]
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
                projectile.position = player1.position
                projectile.zPosition = 2
                projectile.size = CGSize(width: 40, height: 40)
                projectile.name = "player1"
                
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
                if (offset.x <= 0 && player1.xScale>0) {
                    player1.xScale = player1.xScale * -1
                    flame1.xScale = flame1.xScale * -1
                }
                
                if (offset.x > 0 && player1.xScale<0) {
                    player1.xScale = player1.xScale * -1
                    flame1.xScale = flame1.xScale * -1
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
        } else {
            if (isFingerOnPlayer2) {
                isFingerOnPlayer2 = false
                flame2.removeFromParent()
                player2.texture = playerSpriteArray[0]
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
                projectile.position = player2.position
                projectile.zPosition = 2
                projectile.size = CGSize(width: 40, height: 40)
                projectile.name = "player2"
                
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
                if (offset.x <= 0 && player2.xScale>0) {
                    player2.xScale = player2.xScale * -1
                    flame2.xScale = flame2.xScale * -1
                }
                
                if (offset.x > 0 && player2.xScale<0) {
                    player2.xScale = player2.xScale * -1
                    flame2.xScale = flame2.xScale * -1
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
        if (projectile.name=="player1") {
            monstersDestroyed1 += 1
        } else {
            monstersDestroyed2 += 1
        }
        projectile.removeFromParent()
        monster.removeFromParent()
        
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
