//
//  ViewController.swift
//  FinalProjectGame
//
//  Created by Jared Earl on 4/22/18.
//  Copyright © 2018 Jared Earl. All rights reserved.
//

import UIKit

/**
 GameControllerDelegate is used to request updates and report events
 */
protocol GameControllerDelegate: AnyObject {
    func boundsSet(bounds: CGRect)
}

/**
 This class is the controller for the full game view
 */
class GameViewController: UIViewController, DatasetDelegate, GameControllerDelegate {
    
    var delegateID: String = UUIDVendor.vendUUID()
    var displayLink : CADisplayLink!
    let objectLock = ObjLock()
    
    
    //abstract away ugly code
    private var gameView: GameView {
        return view as! GameView
    }

    //constructor
    init(isNewGame: Bool){
        super.init(nibName: nil, bundle: nil)
        
        //configuration
        edgesForExtendedLayout = .init(rawValue: 0)
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Pause", style: .plain, target: self, action: #selector(pauseButtonHit)), animated: true)
        
        for view in gameView.boardView.controls.subviews as [UIView] {
            if let btn = view as? UIButton {
                btn.addTarget(self, action: #selector(controlPressed(button:)), for: .touchDown)
                btn.addTarget(self, action: #selector(controlUnpressed(button:)), for: [.touchUpInside, .touchUpOutside, .touchDragOutside])
            }
        }
        
        //new game or resume
        if(isNewGame){
            startNewGame()
        }
        else {
            resumeGame()
        }
    }
    required init?(coder aDecoder: NSCoder){
        fatalError()
    }

    //overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = GameView()
        gameView.boardView.delegate = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        gameView.layoutSubviews()
        gameView.setNeedsDisplay()
    }
    
    //implement DatasetDelegate
    func datasetUpdated() {
        let curGame:Game = GameData.getGame()
        objectLock.lock(obj: curGame) {
            gameView.badGuys = curGame.badGuys
            gameView.bullets = curGame.bullets
            gameView.player = curGame.player
            gameView.playerHealth = curGame.playerHealth
            gameView.score = curGame.score
            gameView.level = curGame.level
            gameView.gameIsOver = curGame.gameIsOver
            
            if curGame.gameIsOver {
                endGame(isHighscore: GameData.isaHighscore(score: curGame.score))
            }
        }
    }
    //implement gamecontroller delegate
    func boundsSet(bounds: CGRect) {
        var _ = GameData.setGetSize(isSetting: true, size: bounds.size)
    }
    
    //controls buttons
    @objc func controlPressed(button: UIButton) {
        
        if button.title(for: .normal) == "U" {
            var _ = GameData.trueForButtonPressed(isSetting: true, state: ButtonPressed.up)
            //GameData.setButtonPressed(state: ButtonPressed.up)
        }
        else if button.title(for: .normal) == "D" {
            var _ = GameData.trueForButtonPressed(isSetting: true, state: ButtonPressed.down)
            //GameData.setButtonPressed(state: ButtonPressed.down)
        }
        else if button.title(for: .normal) == "L" {
            var _ = GameData.trueForButtonPressed(isSetting: true, state: ButtonPressed.left)
            //GameData.setButtonPressed(state: ButtonPressed.left)
        }
        else if button.title(for: .normal) == "R" {
            var _ = GameData.trueForButtonPressed(isSetting: true, state: ButtonPressed.right)
            //GameData.setButtonPressed(state: ButtonPressed.right)
        }
        else if button.title(for: .normal) == "F" {
            var _ = GameData.trueForButtonPressed(isSetting: true, state: ButtonPressed.fire)
            //GameData.setButtonPressed(state: ButtonPressed.fire)
        }
        else {
            print("Something wend wrong in controlPressed")
        }
        
    }
    @objc func controlUnpressed(button: UIButton) {
        var _ = GameData.trueForButtonPressed(isSetting: true, state: ButtonPressed.none)
        //GameData.setButtonPressed(state: ButtonPressed.none)
    }
    
    //starts a new game
    private func startNewGame() {
        print("starting new game")
        GameData.newGame()
        startLoop()
    }

    //resumes the game
    private func resumeGame() {
        print("resuming game")
        GameData.play()
        startLoop()
    }
    
    //pauses the game
    private func pauseGame() {
        print("pausing game")
        GameData.pauseGame()
        stopLoop()
    }
    
    //takes appropriate steps when the game is over
    private func endGame(isHighscore: Bool) {
        print("Detected game end")
        stopLoop()
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(pauseButtonHit)), animated: true)
        
        if isHighscore {
            navigationController?.pushViewController(HighScoresTableViewController(), animated: true)
        }
    }
    
    //gets info from the model and tells the view to update
    private func updateView() {
        datasetUpdated()
    }
    
    //calink functions
    @objc func handleTimer() {
        updateView()
    }
    private func startLoop() {
        print("starting display loop")
        displayLink = CADisplayLink(target: self, selector: #selector(handleTimer))
        displayLink.preferredFramesPerSecond = 60
        displayLink.add(to: .main, forMode: .commonModes)
    }
    private func stopLoop() {
        print("stopping display loop")
        displayLink?.invalidate()
        //displayLink.remove(from: .main, forMode: .commonModes)
        displayLink = nil
    }
    
    
    //navigation bar functions
    //pauses the game and returns to the menu
    @objc func pauseButtonHit() {
        pauseGame()
        navigationController?.popViewController(animated: true)
    }
}




