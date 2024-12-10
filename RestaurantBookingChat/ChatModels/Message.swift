//
//  Message.swift
//  RestaurantBookingChat
//
//  Created by Natasha Murashev on 12/1/24.
//

import Foundation

extension Chat {
    public struct Message: Codable, Hashable, Identifiable, Sendable {
        public enum Role: Codable, Hashable, Sendable {
            case user
            case assistant
        }
        
        public var id = UUID()
        public var creationDate: Date = Date()
        public var text: String
        public var role: Role = .user
        
        public init(
            id: UUID = UUID(),
            creationDate: Date = Date(),
            text: String,
            role: Role
        ) {
            self.id = id
            self.creationDate = creationDate
            self.text = text
            self.role = role
        }
    }
}

