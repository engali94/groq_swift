//
//  ThemePickerView.swift
//  GroqChatDemo
//
//  Created by Ali Hilal on 23/02/2025.
//

import SwiftUI

struct ThemePickerView: View {
    @Binding var selectedTheme: Theme
    
    var body: some View {
        Menu("Theme") {
            ForEach(Theme.allCases) { theme in
                Button {
                    withAnimation {
                        selectedTheme = theme
                    }
                } label: {
                    Label(theme.name, systemImage: theme.icon)
                }
            }
        }
    }
}
