//
//  GameView.swift
//  FinalProjectGame
//
//  Created by Jared Earl on 4/22/18.
//  Copyright © 2018 Jared Earl. All rights reserved.
//

import Foundation
import UIKit

/**
 This is the main view that is the root view of the GameViewController and contains all the subvies necessary to
 render the game
 */
class GameView: UIView {
    
    //variables
    var badGuys: [CGPoint] {
        set {
            boardView.badGuys = newValue
        }
        get {
            return boardView.badGuys
        }
    }
    var bullets: [CGPoint] {
        set {
            boardView.bullets = newValue
        }
        get {
            return boardView.bullets
        }
    }
    var player: CGPoint {
        set {
            boardView.player = newValue
        }
        get {
            return boardView.player
        }
    }
    var gameIsOver: Bool {
        set {
            boardView.gameIsOver = newValue
        }
        get {
            return boardView.gameIsOver
        }
    }
    var score: Int {
        set
        {
            scoreLabel.text = "  Score: " + String(newValue)            
        }
        get
        {
            let indexStartOfNumber = scoreLabel.text!.index((scoreLabel.text!.startIndex), offsetBy: 9)
            let numString = scoreLabel.text?[indexStartOfNumber...]
            
            return Int(String(describing: numString))!
        }
    }
    var level: Int {
        set
        {
            levelLabel.text = "  Level: " + String(newValue)
            boardView.level = newValue
        }
        get
        {
            let indexStartOfNumber = levelLabel.text!.index((levelLabel.text!.startIndex), offsetBy: 10)
            let numString = levelLabel.text?[indexStartOfNumber...]
            
            return Int(String(describing: numString))!
        }
    }
    var playerHealth: Int {
        get {
            let indexStartOfNumber = healthLabel.text!.index((healthLabel.text!.startIndex), offsetBy: 11)
            let numString = healthLabel.text?[indexStartOfNumber...]
            
            return Int(String(describing: numString))!
        }
        set {
            healthLabel.text = "  Health: " + String(newValue)
        }
    }
    private var healthBar: UIProgressView = {
        let bar = UIProgressView()
        bar.setProgress(100.0, animated: false)
        return bar
    }()
    private let healthLabel: UILabel = {
        let label = UILabel()
        label.text = "Health"
        return label
    }()
    private var scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "  Score: 0"
        //label.backgroundColor = UIColor(patternImage: UIImage(named: "zombie.png")!)
        return label
    }()
    private var levelLabel: UILabel = {
        let label = UILabel()
        label.text = "  Level: 1"
        return label
    }()
    var boardView: BoardView = {
        let board = BoardView()
        
        return board
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        addSubview(scoreLabel)
        addSubview(levelLabel)
        addSubview(healthLabel)
        addSubview(boardView)
        //addSubview(controls)
        //addSubview(playerLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("It's Apple. What did you expect?")
    }
    
    //manually layout the game
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //just layout static components
        var cursor: CGPoint = .zero
        
        //score label top right
        let scoreAndLabelWidth = bounds.width/2
        let scoreAndLabelheight = CGFloat(40.0)
        scoreLabel.frame = CGRect(x: cursor.x, y: cursor.y, width: scoreAndLabelWidth, height: scoreAndLabelheight)
        
        //level Label top left
        cursor.x += scoreAndLabelWidth
        levelLabel.frame = CGRect(x: cursor.x, y: cursor.y, width: scoreAndLabelWidth, height: scoreAndLabelheight)
        
        //health label below the labels
        cursor = .zero
        cursor.y += scoreAndLabelheight + 1.0
        let healthbarHeight = CGFloat(40.0)
        healthLabel.frame = CGRect(x: cursor.x, y: cursor.y, width: bounds.width, height: healthbarHeight)
        
        cursor.y += healthbarHeight
        boardView.frame = CGRect(x: cursor.x, y: cursor.y, width: bounds.width, height: bounds.height - cursor.y)
        
    }
    
    //this function resizes an image to the given size.
    func resizeImage(image: UIImage, size: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if newImage == nil {
            newImage = image
        }
        return newImage!
    }
}









/**
 This class provides the box for the characters relative positions
 */
class BoardView: UIView {
    
    //variables
    var badGuys:[CGPoint] {
        get {
            var positions: [CGPoint] = []
            for badGuy in badGuysLabels {
                positions.append(badGuy.frame.origin)
            }
            return positions
        }
        set {
            removeBadGuyLabels()
            var newBadGuys: [UILabel] = []
            for value in newValue {
                let uiLabel = genBadGuyLabel(origin: value)
                newBadGuys.append(uiLabel)
                addSubview(uiLabel)
            }
            badGuysLabels = newBadGuys
            setNeedsLayout()
        }
    }
    var bullets:[CGPoint] {
        get {
            var positions: [CGPoint] = []
            for bullet in bulletLabels {
                positions.append(bullet.frame.origin)
            }
            return positions
        }
        set {
            removeBulletLabels()
            var newBullets: [UILabel] = []
            for value in newValue {
                let uiLabel = genBulletLabel(origin: value)
                newBullets.append(uiLabel)
                addSubview(uiLabel)
            }
            bulletLabels = newBullets
            setNeedsLayout()
        }
    }
    var player:CGPoint {
        get {
            return playerLabel.frame.origin
        }
        set {
            playerLabel.removeFromSuperview()
            playerLabel = genPlayerLabel(origin: newValue)
            addSubview(playerLabel)
            //playerLabel.frame.origin = newValue
            setNeedsLayout()
        }
    }
    var controls: ControlsView = ControlsView()
    var gameIsOver: Bool {
        set {
            if newValue == true {
                gameIsOverLabel.text = "GAME OVER"
            }
            else {
                gameIsOverLabel.text = ""
            }
        }
        get {
            if gameIsOverLabel.text == "GAME OVER" {
                return true
            }
            else {
                return false
            }
        }
    }
    var level: Int {
        set
        {
            levelint = newValue
            if newValue == 1 {
                backgroundColor = UIColor(patternImage: resizeImage(image: UIImage(named: "background2.png")!, size: self.frame.size))
            }
            else if newValue == 2 {
                backgroundColor = UIColor(patternImage: resizeImage(image: UIImage(named: "background3.png")!, size: self.frame.size))
            }
            else if newValue == 3 {
                backgroundColor = UIColor(patternImage: resizeImage(image: UIImage(named: "background4.png")!, size: self.frame.size))
                
            }
            else {
                print("problem with setting level in boardview")
            }
        }
        get
        {
            return levelint
        }
    }
    //contains all the labels for the bad guys
    private var badGuysLabels: [UILabel] = []
    //contains all the labels for the bullets
    private var bulletLabels: [UILabel] = []
    //the label representing the player
    private var playerLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    private var gameIsOverLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.red
        label.font = label.font.withSize(30)
        label.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        return label
    }()
    private var levelint:Int = 1
    
    //delegate to communicate with controller
    var delegate: GameControllerDelegate? = nil
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        addSubview(controls)
        addSubview(playerLabel)
        addSubview(gameIsOverLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("It's Apple. What did you expect?")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var cursor:CGPoint = .zero
        
        //game is over placement
        let labelWidth: CGFloat = 175.0
        let labelHeight: CGFloat = 50.0
        cursor.x = bounds.width/2.0 - labelWidth/2.0
        cursor.y = bounds.height/2.0 - labelHeight/2.0
        gameIsOverLabel.frame = CGRect(x: cursor.x, y: cursor.y, width: labelWidth, height: labelHeight)
        
        //now for the controls
        let boxHeight = bounds.width/2.0
        cursor.x = bounds.width/2
        cursor.y = bounds.height - boxHeight
        controls.frame = CGRect(x: cursor.x, y: cursor.y, width: boxHeight, height: boxHeight)
        
        //lastly send out the bounds of the game to the model
        cursor = .zero
        delegate?.boundsSet(bounds: CGRect(x: cursor.x, y: cursor.y, width: bounds.width - CGFloat(playerRadius*2), height: bounds.height - cursor.y - CGFloat(playerRadius*2)))
    }
    
    
    
    //_____________________________helpers______________________________________________
    
    //helpers that generate a type of label given the parameters and remove old ones from subviews
    func genBadGuyLabel(origin: CGPoint) -> UILabel {
        let uiLabel = UILabel()
        uiLabel.frame = CGRect(x: origin.x, y: origin.y, width: CGFloat(badGuyRadius * 2.0), height: CGFloat(badGuyRadius * 2.0))
        if levelint == 1 {
            uiLabel.backgroundColor = UIColor(patternImage: resizeImage(image: UIImage(named: "zombie.png")!, size: uiLabel.frame.size))
        }
        else if levelint == 2 {
            uiLabel.backgroundColor = UIColor(patternImage: resizeImage(image: UIImage(named: "zombie2.png")!, size: uiLabel.frame.size))
        }
        else if levelint == 3 {
            uiLabel.backgroundColor = UIColor(patternImage: resizeImage(image: UIImage(named: "zombie3.png")!, size: uiLabel.frame.size))
        }
        else {
            uiLabel.backgroundColor = UIColor(patternImage: resizeImage(image: UIImage(named: "zombie.png")!, size: uiLabel.frame.size))
        }
        return uiLabel
    }
    func genBulletLabel(origin: CGPoint) -> UILabel {
        let label = UILabel()
        label.frame = CGRect(x: origin.x, y: origin.y, width: CGFloat(bulletRadius * 2.0), height: CGFloat(bulletRadius * 2.0))
        label.backgroundColor = UIColor(patternImage: resizeImage(image: UIImage(named: "projectile.png")!, size: label.frame.size))
        return label
    }
    func genPlayerLabel(origin: CGPoint) -> UILabel {
        let label = UILabel()
        label.frame = CGRect(x: origin.x, y: origin.y, width: CGFloat(playerRadius * 2.0), height: CGFloat(playerRadius * 2.0))
        label.backgroundColor = UIColor(patternImage: resizeImage(image: UIImage(named: "player.png")!, size: label.frame.size))
        return label
    }
    func removeBadGuyLabels() {
        for label in badGuysLabels {
            label.removeFromSuperview()
        }
    }
    func removeBulletLabels() {
        for label in bulletLabels {
            label.removeFromSuperview()
        }
    }
    
    //this function resizes an image to the given size.
    func resizeImage(image: UIImage, size: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if newImage == nil {
            newImage = image
        }
        
        return newImage!
    }
}










/**
 This class is the view for the controls of the game
 */
class ControlsView: UIView {

    //set up buttons
    let upButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("U", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 2.0;
        button.layer.borderColor = UIColor.black.cgColor
        
        return button
    }()
    let downButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("D", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 2.0;
        button.layer.borderColor = UIColor.black.cgColor
        
        return button
    }()
    let leftButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("L", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 2.0;
        button.layer.borderColor = UIColor.black.cgColor
        
        return button
    }()
    let rightButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("R", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 2.0;
        button.layer.borderColor = UIColor.black.cgColor
        
        return button
    }()
    let fireButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("F", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        //button.backgroundColor = UIColor.white
        //button.background
        button.layer.borderWidth = 2.0;
        button.layer.borderColor = UIColor.black.cgColor
        
        return button
    }()
    
    //add subviews and initialize the view
    override init(frame: CGRect){
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0.0, alpha: 0.0)//nil//UIColor(white: UIColor.white.cgColor as! CGFloat, alpha: 0.0) //transparent background
        addSubview(upButton)
        addSubview(downButton)
        addSubview(leftButton)
        addSubview(rightButton)
        addSubview(fireButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("It's Apple. What did you expect?")
    }
    
    //manually layout the main menu
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var cursor: CGPoint = .zero
        let buttonHeight = CGFloat(40.0)
        let buttonWidth = CGFloat(40.0)
        
        //it will be a square so first one is top middle
        cursor.x = bounds.width/2 - buttonWidth/2
        cursor.y = bounds.height/4 - buttonHeight/2
        upButton.frame = CGRect(x: cursor.x, y: cursor.y, width: buttonWidth, height: buttonHeight)
        
        //left one is midway down and 1/4
        cursor.x = bounds.width/4 - buttonWidth/2
        cursor.y = bounds.height/2 - buttonHeight/2
        leftButton.frame = CGRect(x: cursor.x, y: cursor.y, width: buttonWidth, height: buttonHeight)
        
        //right one is midway down and 3/4 over
        cursor.x = bounds.width/4*3 - buttonWidth/2
        rightButton.frame = CGRect(x: cursor.x, y: cursor.y, width: buttonWidth, height: buttonHeight)
        
        //botton one is 3/4 way down and middle
        cursor.x = bounds.width/2 - buttonWidth/2
        cursor.y = bounds.height/4*3 - buttonHeight/2
        downButton.frame = CGRect(x: cursor.x, y: cursor.y, width: buttonWidth, height: buttonHeight)
        
        //fire button is right in middle
        cursor.x = bounds.width/2 - buttonWidth/2
        cursor.y = bounds.height/2 - buttonHeight/2
        fireButton.frame = CGRect(x: cursor.x, y: cursor.y, width: buttonWidth, height: buttonHeight)
    }
}




































