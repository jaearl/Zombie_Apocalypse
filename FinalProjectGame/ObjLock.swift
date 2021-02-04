//
//  ObjLock.swift
//  FinalProjectGame
//
//  Created by Jared Earl on 4/23/18.
//  Copyright © 2018 Jared Earl. All rights reserved.
//

import Foundation


/**
 This class allows the user to lock and object while performing an opteration on it
 */
class ObjLock {
    func lock(obj: AnyObject, blk:() -> ()) {
        let lock = NSLock()
        lock.lock()
        objc_sync_enter(obj)
        blk()
        objc_sync_exit(obj)
        lock.unlock()
    }
}
