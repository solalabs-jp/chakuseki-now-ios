//
//  Item.swift
//  chakuseki-now-mac
//
//  Created by 鈴木拓也 on 2026/04/22.
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
