//
// Copyright (c) Vatsal Manot
//

import SwiftUIX
import Swallow

struct ContentView: View {
    @StateObject var dataStore: DataStore = .shared
    
    @UserStorage("navigationSelection", deferUpdates: true)
    var selection: Chat.ID?
    
    var chats: IdentifierIndexingArray<Chat, Chat.ID> {
        get {
            dataStore.chats.sorted { $0.creationDate > $1.creationDate }
        } nonmutating set {
            dataStore.chats = newValue
        }
    }
    
    public var body: some View {
        NavigationSplitView {
            chatList
                .toolbar {
                    Spacer()
                    newChatButton
                }
        } detail: {
            selectedChat
        }
    }
    
    @ViewBuilder
    private var chatList: some View {
        VStack {
            List(selection: $selection) {
                Section("Restaurant Bookings") {
                    ForEach(chats) { (chat: Chat) in
                        NavigationLink(value: chat.id) {
                            Group {
                                chatTitle(for: chat)
                            }
                            .frame(width: .greedy, alignment: .leading)
                            .id(chat.id)
                        }
                        .contextMenu {
                            Button("Delete") {
                                chats.remove(chat)
                            }
                        }
                    }
                }
            }
        }
        .navigationSplitViewColumnWidth(min: 256, ideal: 350, max: 400) 
    }
    
    @ViewBuilder
    private var selectedChat: some View {
        Group {
            if
                let selection = selection,
                let chat: Chat = dataStore.chats[id: selection]
            {
                ChatView(chat: .unwrapping(dataStore, \.chats[id: selection], defaultValue: chat))
            }
        }
        .id(selection)
    }
    
    private func chatTitle(for chat: Chat) -> some View {
        TextField(
            Chat.newChatDefaultTitle,
            text: Binding(
                get: { chat.title },
                set: { newTitle in
                    if let index = dataStore.chats.firstIndex(where: { $0.id == chat.id }) {
                        dataStore.chats[index].title = newTitle
                    }
                }
            )
        )
    }
    
    @ViewBuilder
    private var newChatButton: some View {
        Button(Chat.newChatDefaultTitle, systemImage: .plus) {
            let newChat = Chat()
            dataStore.chats.append(newChat)
            selection = newChat.id
        }
        .help(Text("Start a new restaurant reservation chat!"))
    }
}
