//
//  Colors.swift
//  Kenimo
//
//  Created by Morgan Wilde on 10/11/22.
//

import SwiftUI

struct Colors {
  private let colors: [AnyHashable: String]
  private let defaultColor: String
  
  subscript(index: AnyHashable) -> Color {
    let colorHex = colors[index] ?? defaultColor
    return Color(hex: colorHex)
  }
  
  init(colors: [AnyHashable: String], defaultColor: String? = nil) {
    self.colors = colors
    self.defaultColor = defaultColor ?? colors[500] ?? "#ff0000"
  }
}
