//
//  Color+hex.swift
//  Kenimo
//
//  Created by Morgan Wilde on 10/9/22.
//

import SwiftUI

extension Color {
  public init(hex: String) {
    let sanitizedHex = hex
      .replacingOccurrences(of: "0x", with: "")
      .replacingOccurrences(of: "#", with: "")
    let number = Int(sanitizedHex, radix: 16)!
    let red = (0xff0000 & number) >> 16
    let green = (0x00ff00 & number) >> 8
    let blue = 0x0000ff & number
    
    self.init(
      red: Double(red) / 255,
      green: Double(green) / 255,
      blue: Double(blue) / 255
    )
  }
}
