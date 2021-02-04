//
//  MenuViewController.swift
//  FinalProjectGame
//
//  Created by Jared Earl on 4/22/18.
//  Copyright © 2018 Jared Earl. All rights reserved.
//

import Foundation
import UIKit

//AlarmTableViewController handles the logic and data of the Alarm List
class MenuViewController: UIViewController {
    
    var delegateID: String = UUIDVendor.vendUUID()
    
    private var menuView: MenuView {
        return view as! MenuView
    }
    
    init(){
        super.init(nibName: nil, bundle: nil)
        edgesForExtendedLayout = .init(rawValue: 0)
    }
    required init?(coder aDecoder: NSCoder){
        fatalError()
    }
    
    //sets the view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = MenuView()
        
        menuView.newGameButton.addTarget(self, action: #selector(MenuViewController.newGameButtonTapped(button:)), for: .touchUpInside)
        menuView.resumeButton.addTarget(self, action: #selector(MenuViewController.resumeGameButtonTapped(button:)), for: .touchUpInside)
        menuView.highScoresButton.addTarget(self, action: #selector(MenuViewController.highScoreButtonTapped(button:)), for: .touchUpInside)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    //fuction that handles the event when the newGameButton is tapped
    @objc func newGameButtonTapped(button: UIButton){
        //push a new game
        navigationController?.pushViewController(GameViewController(isNewGame: true), animated: true)
    }
    
    //function that handles the event when the resume game button is tapped
    @objc func resumeGameButtonTapped(button: UIButton){
        //just resume whatever the current game is
        navigationController?.pushViewController(GameViewController(isNewGame: false), animated: true)
    }
    
    //function that handels the event when the high scores button is tapped
    @objc func highScoreButtonTapped(button: UIButton){
        navigationController?.pushViewController(HighScoresTableViewController(), animated: true)
    }
}
