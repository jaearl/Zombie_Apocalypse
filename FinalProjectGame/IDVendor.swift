//
//  IDVendor.swift
//  AlarmConfig
//
//  Created by Jared Earl on 2/18/18.
//  Copyright © 2018 Jared Earl. All rights reserved.
//

import Foundation

//This vendor ensures that each customer always gets a unique id while the program is running
class UUIDVendor {
    
    //keep track of all ID's
    private static var idSet: Set<String> = Set<String>([])
    private static var vendLock: NSLock = NSLock()
    
    //vends the unique id
    static func vendUUID() -> String {
        vendLock.lock()
        var idString: String = UUID().uuidString
        
        //don't allow duplicates
        while idSet.contains(idString){
            idString = UUID().uuidString
        }
        
        idSet.insert(idString)
        vendLock.unlock()
        
        return idString
    }
}
