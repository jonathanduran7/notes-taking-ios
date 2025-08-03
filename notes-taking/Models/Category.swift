//
//  Category.swift
//  notes-taking
//
//  Created by Jonathan Duran on 01/08/2025.
//

import Foundation
import SwiftData

@Model
final class Category {
    var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func updateName(_ newName: String) {
        self.name = newName
        self.updatedAt = Date()
    }
}

@Model
final class Notes {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var category: Category?
    
    init(title: String, content: String, category: Category? = nil) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.category = category
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func update(title: String, content: String, category: Category?) {
        self.title = title
        self.content = content
        self.category = category
        self.updatedAt = Date()
    }
}