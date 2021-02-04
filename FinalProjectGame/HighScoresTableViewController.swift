//
//  HighScoresTableViewController.swift
//  FinalProjectGame
//
//  Created by Jared Earl on 4/24/18.
//  Copyright © 2018 Jared Earl. All rights reserved.
//

import Foundation
import UIKit


/**
 GameTableViewController handles the logic and data of the Game List
 */
class HighScoresTableViewController: UITableViewController, DatasetDelegate {
    
    var delegateID: String = UUIDVendor.vendUUID()
    
    //implementation of DatasetDelegate
    func datasetUpdated() {
        tableView.reloadData()
    }
    
    private static var cellReuseIdentifier =
    "HighScoresTableViewController.DatasetItemsCellIdentifier"
    
    //load register with the alarm data
    override func viewDidLoad() {
        super.viewDidLoad()
        GameData.registerDelegate(delegate: self)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: HighScoresTableViewController.cellReuseIdentifier)
    }
    
    //override to make it so new navigation bar button goes back to being in normal state
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        datasetUpdated()
    }
    
    //things
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //dispose of any resources that can be recreated
    }
    
    //returns the number of Game List items
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard tableView === self.tableView, section == 0 else {
            return 0
        }
        return GameData.highscoresCount
    }
    
    //Updates the list with a fancy string showing details of each high score
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard tableView === self.tableView, indexPath.section == 0, indexPath.row < GameData.highscoresCount else {
            return UITableViewCell()
        }
        var cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: HighScoresTableViewController.cellReuseIdentifier, for: indexPath)
        if cell.detailTextLabel == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: HighScoresTableViewController.cellReuseIdentifier)
        }
        let highScore = GameData.entry(atIndex: indexPath.row)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss"
        let dateString = dateFormatter.string(from: highScore.date)
        let cellText = "Highscore " + String(highScore.score) + "    Date " + dateString
        cell.textLabel?.text = cellText
        
        return cell
    }
    
    @objc func backButtonHit() {
        navigationController?.popViewController(animated: true)
    }
}
