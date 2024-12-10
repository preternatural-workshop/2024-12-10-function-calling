//
//  ChatItemCell.swift
//  RestaurantBookingChat
//
//  Created by Natasha Murashev on 12/1/24.
//

import ChatKit
import Swallow
import SwiftUI

public struct ChatItemView: View {
    public let session: ChatSession
    public let message: Chat.Message
    
    public var body: some View {
        ChatItemCell(item: AnyChatMessage(message.text))
            .roleInvert(message.role == .assistant)
            .onDelete {
                session.delete(message)
            }
            .onResend {
                Task {
                    session.sendMessage(message.text)
                }
            }
            .cocoaListItem(id: message.id)
            .chatItemDecoration(placement: .besideItem) {
                Menu {
                    ChatItemActions()
                } label: {
                    Image(systemName: .squareAndPencil)
                        .foregroundColor(.secondary)
                        .font(.body)
                        .fontWeight(.medium)
                }
                .menuStyle(.button)
                .buttonStyle(.plain)
            }
    }
}
