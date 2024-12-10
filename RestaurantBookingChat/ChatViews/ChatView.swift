//
//  ChatView.swift
//  RestaurantBookingChat
//
//  Created by Natasha Murashev on 12/1/24.
//

import ChatKit
import Merge
import SwiftUI

public struct ChatView: View {
    @State private var inputFieldText: String = ""
    
    @StateObject var session: ChatSession
    
    public init(chat: PublishedAsyncBinding<Chat>) {
        _session = StateObject(wrappedValue: ChatSession(chat: chat))
    }
    
    public var body: some View {
        ChatKit.ChatView {
            messagesList
            
            if session.chat.messages.isEmpty {
                ContentUnavailableView("No Reservations", systemImage: "message.fill")
            }
        } input: {
            ChatInputBar(
                text: $inputFieldText
            ) { message in
                session.sendMessage(message)
            }
        }
        .frame(minWidth: 512)
        .toolbar {
            ToolbarItemGroup {
                Spacer()
                chatTitle
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var messagesList: some View {
        ChatMessageList(
            session.chat.messages
        ) { (message: Chat.Message) in
            ChatItemView(session: session, message: message)
        }
    }
    
    @ViewBuilder
    private var chatTitle: some View {
        EditableText(
            Chat.newChatDefaultTitle,
            text: Binding(
                get: { session.chat.title },
                set: { newTitle in
                    session.chat.title = newTitle
                    let dataStore = DataStore.shared
                    if let index = dataStore.chats.firstIndex(where: { $0.id == session.chat.id }) {
                        dataStore.chats[index].title = newTitle
                    }
                }
            )
        )
    }
}
