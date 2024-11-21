//
//  AnalyticsService.swift
//  TrackerApp
//
//  Created by Гена Утин on 20.11.2024.
//

import Foundation
import YandexMobileMetrica

let apiKey: String = "629f7c33-bbf5-479d-948c-005dd92a8aff"

final class AnalyticsService {
    
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "\(apiKey)") else { return }
        YMMYandexMetrica.activate(with: configuration)
    }
    
    static func logEvent(event: String, screen: String, item: String? = nil) {
        var eventParams: [String: Any] = [
            "event": event,
            "screen": screen]
        
        if let item {
            eventParams["item"] = item
        }
        
        YMMYandexMetrica.reportEvent("ui_event", parameters: eventParams, onFailure: { error in
            print("Error: \(error.localizedDescription)")
        })
    }
}
