//
//  ContentView.swift
//  ClipboardManager
//
//  Created by Soumik Sarkhel on 09/11/24.
//

import SwiftUI

struct ContentView: View {
    @State var clipboardHistory: [String] = []
    
    var body: some View {
        List(clipboardHistory, id: \.self) {
            item in Text(item)
        }
        .frame(width: 300, height: 400)
        .onAppear()
    }
}

#Preview {
    ContentView()
}
