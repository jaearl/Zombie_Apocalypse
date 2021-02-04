//
//  Model.swift
//  FinalProjectGame
//
//  Created by Jared Earl on 4/22/18.
//  Copyright © 2018 Jared Earl. All rights reserved.
//

import Foundation
import UIKit

//****constants*******
let bulletRadius = 10.0
let badGuyRadius = 20.0
let playerRadius = 20.0
let bulletSpeed = 800.0
let badGuySpeed = 15.0
let playerSpeed = 200.0
let nextFireTimeLimit = 0.10
let startingNumBadGuys = 10
let badGuyTime:TimeInterval = 1.0
//******End constants*****

/**
 DatasetDelegate defines the protocol for the view that will hold the games
 */
protocol DatasetDelegate: class {
    var delegateID: String { get }
    func datasetUpdated()
}

/**
 HighScore class records high score information
 */
final class HighScore: NSObject, Codable {
    var score: Int
    var date: Date
    
    init(score: Int, date: Date){
        self.score = score
        self.date = date
    }
}
////******************************************************GAME LOGIC IS IMPLEMENTED IN C++ *****************************************************
/**
 Game class holds data for individual games
 */
final class Game: NSObject, Codable {
    //variables saved in a Game object
    var badGuys: [CGPoint]
    var bullets: [CGPoint]
    var player: CGPoint
    var playerHealth: Int
    var score: Int
    var level: Int
    var numEnemiesLeft: Int
    var gameIsOver = false
    
    init(badGuys: [CGPoint], bullets: [CGPoint], player: CGPoint, score: Int, level: Int, numEnemiesLeft: Int, playerHealth: Int, gameIsOver: Bool){
        self.badGuys = badGuys
        self.bullets = bullets
        self.player = player
        self.score = score
        self.level = level
        self.playerHealth = playerHealth
        self.numEnemiesLeft = numEnemiesLeft
        self.gameIsOver = gameIsOver
    }
}

/**
 GameData class holds all games that are currently being played
 */
final class GameData {
    
    //keeps track of the dataset delegate
    private final class WeakDatasetDelegate {
        weak var delegate: DatasetDelegate?
        
        init(delegate: DatasetDelegate) {
            self.delegate = delegate
        }
    }
    
    //member variables
    private static var buttonState: ButtonPressed = ButtonPressed.none
    private static var boardSize: CGSize = CGSize(width: 250, height: 300)
    private static let lock = NSLock()
    static var game: Game = Game(badGuys: [], bullets: [], player: CGPoint(x: 200, y: 300), score: 0, level: 1, numEnemiesLeft: startingNumBadGuys, playerHealth: 100, gameIsOver: false) //loadData()
    private static var highScores: [HighScore] = []
    private static var gameLoop: GameLoop = GameLoop(badGuys: game.badGuys, bullets: game.bullets, player: game.player, score: game.score, level: game.level, numEnemiesLeft: game.numEnemiesLeft, playerHealth: game.playerHealth, gameIsOver: game.gameIsOver)
    private static var objectLock: ObjLock = ObjLock()
    private static var delegatesLock: NSLock = NSLock()
    private static var delegates: [String: WeakDatasetDelegate] = [:]
    
    private static let entriesEncoder: JSONEncoder = {
        let entriesEncoder = JSONEncoder()
        entriesEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return entriesEncoder
    }()
    
    //makes new game and starts it
    static func newGame() {
        objectLock.lock(obj: game){
            game = Game(badGuys: [], bullets: [], player: CGPoint(x:200, y: 300), score: 0, level: 1, numEnemiesLeft: startingNumBadGuys, playerHealth: 100, gameIsOver: false)
            gameLoop = GameLoop(badGuys: game.badGuys, bullets: game.bullets, player: game.player, score: game.score, level: game.level, numEnemiesLeft: game.numEnemiesLeft, playerHealth: game.playerHealth, gameIsOver: game.gameIsOver)
        }
        
        gameLoop.play()
    }
    
    //pauses the game
    static func pauseGame() {
        gameLoop.pause()
        saveData()
    }
    
    //plays the game
    static func play() {
        gameLoop.play()
    }
    
    //updates the current game
    static func updateGame(badGuys: [CGPoint], bullets: [CGPoint], player: CGPoint, score: Int, health: Int, gameIsOver: Bool, level: Int, numEnemiesLeft: Int){
        objectLock.lock(obj: game){
            game.badGuys = badGuys
            game.bullets = bullets
            game.playerHealth = health
            game.player = player
            game.score = score
            game.gameIsOver = gameIsOver
            game.level = level
            game.numEnemiesLeft = numEnemiesLeft
        }
        if gameIsOver {
            saveData()
        }
    }
    
    //Thread safe access to the button state
    static func trueForButtonPressed(isSetting: Bool, state: ButtonPressed) -> ButtonPressed{
        lock.lock()
        if isSetting {
            buttonState = state
        }
        let temp = buttonState
        lock.unlock()
        return temp
    }
    
    //thread safe access to the bounds
    static func setGetSize(isSetting: Bool, size: CGSize) -> CGSize {
        lock.lock()
        if isSetting {
            boardSize = size
            //print("boarsize set to width: \(size.width), height: \(size.height)")
        }
        let temp = boardSize
        lock.unlock()
        return temp
    }
    
    //returns the specified highscore at the given index
    static func entry(atIndex index: Int) -> HighScore {
        var entry: HighScore?
        objectLock.lock(obj: highScores as AnyObject) {
            entry = highScores[index]
        }
        return entry!
    }
    
    //returns how many highscores
    static var highscoresCount: Int {
        var count: Int = 0
        objectLock.lock(obj: highScores as AnyObject) {
            count = highScores.count
        }
        return count
    }
    
    static func isaHighscore(score: Int) -> Bool {
        var isa = false
        objectLock.lock(obj: highScores as AnyObject){
            for record in highScores {
                if record.score == score {
                    isa = true
                    break
                }
            }
        }
        
        return isa
    }
    
    //adds a new highscore
    static func addHighScore(score: Int, date: Date){
        let newHighScore = HighScore(score: score, date: date)
        
        objectLock.lock(obj: highScores as AnyObject){
            
            //keep the top ten high scores
            highScores.append(newHighScore)
            
            if highScores.count > 10 {
                
                highScores.sort{ $0.score > $1.score}// && $0.date < $1.date}
                highScores.sort{ $0.score == $1.score && $0.date > $1.date}
                highScores.remove(at: 10)
            }
            //otherwise just order them
            else {
                highScores.sort{ $0.score > $1.score }
            }
        }
    }
    
    //returns the game in its current state
    static func getGame() -> Game {
        var tempGame: Game?
        
        objectLock.lock(obj: game){
            tempGame = game
        }
        
        return tempGame!
    }
    
    //load in all game data
    static func loadData() {
        game = loadGame()
        highScores = loadHighScores()
    }
    
    //this funciton loads the game from a file
    private static func loadGame() -> Game {
        var loadedData: Game = Game(badGuys: [], bullets: [], player: CGPoint(x:200, y: 300), score: 0, level: 1, numEnemiesLeft: 5, playerHealth: 100, gameIsOver: false)
        objectLock.lock(obj: game){
        
            guard let fileURL: URL = try?
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: true).appendingPathComponent("Game.json", isDirectory: false),
                let encodedDataset: Data = try? Data(contentsOf: fileURL, options: [])
                else {
                    print("creating default game")
                    //loadedData = Game(badGuys: [], bullets: [], player: CGPoint(x:200, y: 300), score: 0, level: 1, numEnemiesLeft: 5, playerHealth: 100, gameIsOver: false)
                    return
            }
            do {
                print("Loading data\n")
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: fileURL.path) {
                    loadedData = try JSONDecoder().decode(Game.self, from: encodedDataset)
                    print("Loaded data\n")
                }
                else {
                    print("No data file exists yet")
                }
            }
            catch {
                print(error.localizedDescription)
                //loadedData = Game(badGuys: [], bullets: [], player: CGPoint(x:200, y: 300), score: 0, level: 1, numEnemiesLeft: 5, playerHealth: 100, gameIsOver: false)
                
            }
        }
        
        return loadedData
    }
    
    //this funciton loads the highscores from a file
    private static func loadHighScores() -> [HighScore] {
        var loadedData: [HighScore] = []
        objectLock.lock(obj: game){
            
            guard let fileURL: URL = try?
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: true).appendingPathComponent("Highscores.json", isDirectory: false),
                let encodedDataset: Data = try? Data(contentsOf: fileURL, options: [])
                else {
                    //loadedData = Game(badGuys: [], bullets: [], player: CGPoint(x:200, y: 300), score: 0, level: 1, numEnemiesLeft: 5, playerHealth: 100, gameIsOver: false)
                    return
            }
            do {
                print("Loading Highscores data\n")
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: fileURL.path) {
                    loadedData = try JSONDecoder().decode([HighScore].self, from: encodedDataset)
                    print("Loaded Highscores data\n")
                }
                else {
                    print("No data file exists yet")
                }
            }
            catch {
                print(error.localizedDescription)
                //loadedData = Game(badGuys: [], bullets: [], player: CGPoint(x:200, y: 300), score: 0, level: 1, numEnemiesLeft: 5, playerHealth: 100, gameIsOver: false)
                
            }
        }
        
        return loadedData
    }
    
    //this function saves the data to a file
    private static func saveData() {
        objectLock.lock(obj: game){
        
            //save game
            guard let fileURL: URL = try?
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: true).appendingPathComponent("Game.json", isDirectory: false),
                let encodedDataset: Data = try? entriesEncoder.encode(game)
                else {
                    return
            }
            do {
                try encodedDataset.write(to: fileURL, options: [.atomic, .completeFileProtection])
                print("Game Saved")
                //print(fileURL.absoluteString)
                //print(String(data: encodedDataset, encoding: .utf8))
            }
            catch {
                print(error.localizedDescription)
                return
            }
            
            guard let fileURL2: URL = try?
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: true).appendingPathComponent("Highscores.json", isDirectory: false),
                let encodedDataset2: Data = try? entriesEncoder.encode(highScores)
                else {
                    return
            }
            do {
                try encodedDataset2.write(to: fileURL2, options: [.atomic, .completeFileProtection])
                print("highscores Saved")
                //print(fileURL.absoluteString)
                //print(String(data: encodedDataset, encoding: .utf8))
            }
            catch {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    //registers a new delegate
    static func registerDelegate(delegate: DatasetDelegate) {
        delegatesLock.lock()
        delegates[delegate.delegateID] = WeakDatasetDelegate(delegate: delegate)
        delegatesLock.unlock()
    }
}
