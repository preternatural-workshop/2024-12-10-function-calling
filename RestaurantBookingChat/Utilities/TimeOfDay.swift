//
//  TimeOfDay.swift
//  RestaurantBookingChat
//
//  Created by Natasha Murashev on 12/2/24.
//

import Foundation

public struct TimeOfDay: Codable, Hashable, Sendable {
    public var hour: Int
    public var minute: Int
    
    public init(hour: Int, minute: Int) {
        self.hour = max(0, min(23, hour))
        self.minute = max(0, min(59, minute))
    }
    
    public init(from date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        self.hour = components.hour ?? 0
        self.minute = components.minute ?? 0
    }
    
    public init?(timeString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale.current
        
        guard let date = dateFormatter.date(from: timeString) else {
            return nil
        }
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        guard let hour = components.hour,
              let minute = components.minute else {
            return nil
        }
        
        self.init(hour: hour, minute: minute)
    }
    
    // Format time as string (e.g., "14:30" or "02:30 PM")
    public func formatted(use24Hour: Bool = true) -> String {
        if use24Hour {
            return String(format: "%02d:%02d", hour, minute)
        } else {
            let period = hour >= 12 ? "PM" : "AM"
            let hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
            return String(format: "%02d:%02d %@", hour12, minute, period)
        }
    }
}

