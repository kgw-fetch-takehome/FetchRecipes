//
//  ColorExt.swift
//  FetchRecipes
//
//  Created by Kenneth Worley on 2/6/25.
//

import Foundation
import SwiftUI

extension Color {
    static func background(opacity: Double) -> Color {
        // When dark mode, a bit less opaque matches the effect seen in light mode for given value
        let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        let useOpacity = isDarkMode ? 0.75 * opacity : opacity
        return Color(UIColor.systemBackground).opacity(useOpacity)
    }
}
