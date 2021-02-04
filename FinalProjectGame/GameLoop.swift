
//
//  GameLoop.swift
//  FinalProjectGame
//
//  Created by Jared Earl on 4/22/18.
//  Copyright © 2018 Jared Earl. All rights reserved.
//

import Foundation
import UIKit

//global enum definition to indicate what the user is pressing if anything
enum ButtonPressed: Int {
    case up = 1
    case down = 2
    case left = 3
    case right = 4
    case fire = 5
    case none = 6
}

/**
 GameLoop is the loop class that updates the game in the background in a loop on a different thread
 and also provides capabilities to start and pause the game
 ***************** ALL LOGIC INTENSIVE PORTIONS ARE IMPLEMENTED IN C++*********************************
 */
class GameLoop : NSObject {
    
    //variables saved in a Game object
    var badGuys: [CGPoint]
    var bullets: [CGPoint]
    var player: CGPoint
    var playerHealth: Int
    var score: Int
    var level: Int
    var badGuysLeft: Int
    var gameIsOver = false
    
    //constructor
    init(badGuys: [CGPoint], bullets: [CGPoint], player: CGPoint, score: Int, level: Int, numEnemiesLeft: Int, playerHealth: Int, gameIsOver: Bool){
        self.badGuys = badGuys
        self.bullets = bullets
        self.player = player
        self.score = score
        self.level = level
        self.playerHealth = playerHealth
        self.badGuysLeft = numEnemiesLeft
        self.gameIsOver = gameIsOver
        self.lastExecuted = Date()
    }
    deinit{
        //blockOperation?.cancel()
        queue.cancelAllOperations()
        
    }
    
    //other variables
    private let objectLock = ObjLock()
    private var lastExecuted: Date
    //private var buttonPressed = ButtonPressed.none
    private var totalGuySpeed: Double {
        get {
            return badGuySpeed * Double(level)
        }
    }
    private var timeTillNextBadGuy:TimeInterval = 3.0
    private var timeSinceLastBulletFired: TimeInterval = 0.0
    private let badGuyStartPlaces: [CGPoint] = [CGPoint(x: 60,y: 0), CGPoint(x: 120,y: 0)]
    
    //bounds of the game
    private var bounds:CGSize = CGSize(width: 250,height: 350)
    
    //c api
    var api = API()
    
    //threading stuff
    private let background = DispatchQueue.global()
    private let queue = OperationQueue()
    private var blockOperation: BlockOperation?
    private var semaphore = DispatchSemaphore(value: 1)
    
    //this function starts the game loop
    func play() {
        lastExecuted = Date()
        if !gameIsOver {
            blockOperation = BlockOperation {
                self.loop()
            }
            queue.addOperation(blockOperation!)
        }
    }
    
    //suspends the game loop
    func pause() {
        //background.suspend()
        if blockOperation != nil {
            blockOperation!.cancel()
        }
        //queue.cancelAllOperations()
    }
    
    //game loop
    private func loop() {
        while !gameIsOver {
            if blockOperation!.isCancelled {
                break
            }
            calculateGameState()
        }
        print("game loop ended")
    }
    
    //main game loop function
    private func calculateGameState() {
        bounds = GameData.setGetSize(isSetting: false, size: CGSize(width: 0,height: 0))
        let buttonPressed = GameData.trueForButtonPressed(isSetting: false, state: ButtonPressed.none)
        
        //set lastExecuted and calculate the time elapsed
        let prevExecuted = lastExecuted
        lastExecuted = Date()
        let timeElapsed: TimeInterval = lastExecuted.timeIntervalSince(prevExecuted)
        timeSinceLastBulletFired += timeElapsed
        
        //calculate the distances moved for each type of object
        let badGuyDistanceMoved: Double = api.calcDistanceMoved(timeElapsed, totalGuySpeed)
        let bulletDistanceMoved: Double = api.calcDistanceMoved(timeElapsed, bulletSpeed)
        var playerDistanceMoved: Double = 0.0
        if buttonPressed != ButtonPressed.none && buttonPressed != ButtonPressed.fire {
            playerDistanceMoved = api.calcDistanceMoved(timeElapsed, playerSpeed)
        }
        if buttonPressed == ButtonPressed.fire && timeSinceLastBulletFired > nextFireTimeLimit {
            print("bullet fired")
            bullets.append(CGPoint(x: player.x, y: player.y + 10.0))
            timeSinceLastBulletFired = 0.0
        }
        
        
        //move all bad guys and bullets and the player
        moveBadGuys(distance: CGFloat(badGuyDistanceMoved))
        moveBullets(distance: CGFloat(bulletDistanceMoved))
        movePlayer(distance: CGFloat(playerDistanceMoved), buttonPressed: buttonPressed)
        
        //first find collisions between bullets and bad guys getting rid of the bullets and bad guys
        checkHits()
        
        //now check for collisions between bad guys and player
        checkPlayerHits()
        
        //add new badguys
        timeTillNextBadGuy -= timeElapsed
        if timeTillNextBadGuy <= 0 && badGuysLeft > 0 {
            addBadGuy()
        }
        
        //if playerHealth is at zero then game over
        if playerHealth < 1 {
            endGame()
        }
        
        //else if all the bad guys are gone then next level
        if badGuys.count == 0 && badGuysLeft == 0 {
            nextLevel()
        }
        
        //update dataset
        GameData.updateGame(badGuys: badGuys, bullets: bullets, player: player, score: score, health: playerHealth, gameIsOver: gameIsOver, level: level, numEnemiesLeft: badGuysLeft)
    }
    
    
    //helper to check if the player has been hit
    private func checkPlayerHits() {
        let oldCount = badGuys.count
        let newBadGuys: NSMutableArray = api.checkPlayerHits(player, &badGuys, Int32(badGuys.count))
        badGuys = []
        for guy in newBadGuys {
            badGuys.append(guy as! CGPoint)
        }
        //print("new bad guys count = \(badGuys.count)")
        let diff = oldCount - badGuys.count
        playerHealth = Int(api.calcHealth(Int32(playerHealth), Int32(diff)))
    }
    
    //helper to update bullets and bad guys
    private func checkHits() {
        
        let oldBadGuysCount = badGuys.count
        let oldBulletsCount = bullets.count
        let newBadGuys: NSMutableArray = api.checkBadGuys(&badGuys, &bullets, Int32(oldBadGuysCount), Int32(oldBulletsCount))
        let newBullets: NSMutableArray = api.checkBullets(&badGuys, &bullets, Int32(oldBadGuysCount), Int32(oldBulletsCount))
        badGuys = []
        for guy in newBadGuys {
            badGuys.append(guy as! CGPoint)
        }
        bullets = []
        for bullet in newBullets {
            bullets.append(bullet as! CGPoint)
        }
        let diff = oldBulletsCount - bullets.count
        if diff != oldBadGuysCount - badGuys.count {
            print("There was a problem with bullets and bad guys")
        }
        score = Int(api.calcNewScore(Int32(score), (Int32(diff))))
    }
    
    
    //helper function to increment the level
    private func nextLevel() {
        if level < 3 {
            level += 1
            badGuysLeft = startingNumBadGuys * level
        }
        else {
            endGame()
        }
    }
    
    //helper function to end the game
    private func endGame() {
        //set flag to over and suspend the process
        print("gameLoop ending game")
        GameData.addHighScore(score: score, date: Date())
        
        gameIsOver = true
    }
    
    //helper function that adds a new badguy to the list
    private func addBadGuy() {
        badGuysLeft -= 1
        timeTillNextBadGuy = badGuyTime
        
        let randomx = Int(arc4random_uniform(UInt32(bounds.width)))
        
        badGuys.append(CGPoint(x: randomx, y: 0))
    }
    
    //helper to move the bullets
    private func moveBullets(distance: CGFloat) {
        let newBullets:NSMutableArray = api.moveBullets(&bullets, Int32(bullets.count), Double(distance))
        bullets = []
        for bullet in newBullets {
            bullets.append(bullet as! CGPoint)
        }
    }
    
    //calculates the positions of the bad guys relative to the bounds
    private func moveBadGuys(distance: CGFloat) {
        let newBadGuys:NSMutableArray = api.moveBadGuys(&badGuys, Int32(badGuys.count), Double(distance), Double(bounds.height), Double(bounds.width))
        badGuys = []
        for guy in newBadGuys {
            badGuys.append(guy as! CGPoint)
        }
    }
    
    //helper function that moves the player
    private func movePlayer(distance: CGFloat, buttonPressed: ButtonPressed){
        player = api.movePlayer(player, Double(distance), Int32(buttonPressed.rawValue), Double(bounds.height), Double(bounds.width))
    }
    
}
