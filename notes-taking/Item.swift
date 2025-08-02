//
//  Item.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
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
