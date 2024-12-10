//
//  DataStore.swift
//  RestaurantBookingChat
//
//  Created by Natasha Murashev on 12/1/24.
//

import CorePersistence

final class DataStore: ObservableObject {
    static let shared = DataStore()
    
    @FileStorage(
        .appDocuments,
        path: "RestaurantBookingChat/chats.json",
        coder: .json,
        options: .init(readErrorRecoveryStrategy: .discardAndReset)
    )
    var chats: IdentifierIndexingArrayOf<Chat> = []
    
    private init() {
        if chats.isEmpty {
            chats.append(Chat())
        }
    }
}

