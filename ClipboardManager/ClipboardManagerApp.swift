//
//  ClipboardManagerApp.swift
//  ClipboardManager
//
//  Created by Soumik Sarkhel on 09/11/24.
//

import SwiftUI

@main
struct ClipboardManagerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
