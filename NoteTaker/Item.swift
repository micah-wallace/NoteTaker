//
//  Item.swift
//  NoteTaker
//
//  Created by Wallace, Micah on 2/13/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
