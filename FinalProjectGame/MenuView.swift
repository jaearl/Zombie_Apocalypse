//
//  MenuView.swift
//  FinalProjectGame
//
//  Created by Jared Earl on 4/22/18.
//  Copyright © 2018 Jared Earl. All rights reserved.
//

import Foundation
import UIKit

/**
 Main menu view is the view that greets the user and allows them to look start a new game,
 resume a game, or view highscores
 */
class MenuView: UIView {
    
    //title
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Dragon Ball Zombies"
        label.backgroundColor = UIColor.white
        label.textColor = UIColor.red
        label.font = label.font.withSize(20)
        
        return label
    }()
    
    //set up buttons
    let newGameButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("New Game", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 2.0;
        button.layer.borderColor = UIColor.black.cgColor
        
        return button
    }()
    let resumeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Resume Game", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 2.0;
        button.layer.borderColor = UIColor.black.cgColor
        
        return button
    }()
    
    let highScoresButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("High Scores", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 2.0;
        button.layer.borderColor = UIColor.black.cgColor
        
        return button
    }()
    
    //add subviews and initialize the view
    override init(frame: CGRect){
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(newGameButton)
        addSubview(resumeButton)
        addSubview(highScoresButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("It's Apple. What did you expect?")
    }
    
    //manually layout the main menu
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = UIColor(patternImage: resizeImage(image: UIImage(named: "background4.png")!, size: bounds.size))
        
        var cursor: CGPoint = .zero
        let buttonHeight = CGFloat(40.0);
        let buttonWidth = CGFloat(160.0);
        let labelWidth = buttonWidth + 30;
        let spacing = bounds.height/4
        let titleY = bounds.height/12 - 30
        
        cursor.y = titleY
        cursor.x = bounds.width/2 - labelWidth/2 - bounds.width/5
        
        titleLabel.frame = CGRect(x: cursor.x, y: cursor.y, width: labelWidth, height: buttonHeight)
        
        cursor.y = spacing
        cursor.x = bounds.width/2 - buttonWidth/2
        
        newGameButton.frame = CGRect(x: cursor.x, y: cursor.y, width: buttonWidth, height: buttonHeight)
        
        cursor.y += spacing
        
        resumeButton.frame = CGRect(x: cursor.x, y: cursor.y, width: buttonWidth, height: buttonHeight)
        
        cursor.y += spacing
        
        highScoresButton.frame = CGRect(x: cursor.x, y: cursor.y, width: buttonWidth, height: buttonHeight)
    }
    
    //helpers
    //this function resizes an image to the given size.
    func resizeImage(image: UIImage, size: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
