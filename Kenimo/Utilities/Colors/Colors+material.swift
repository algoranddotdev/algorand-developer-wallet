//
//  Colors+material.swift
//  Kenimo
//
//  Created by Morgan Wilde on 10/11/22.
//

import SwiftUI

struct MaterialColor {
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

extension Colors {
  struct Material {
    static let pink = MaterialColor(
      colors: [
        50: "fce4ec",
        100: "f8bbd0",
        200: "f48fb1",
        300: "f06292",
        400: "ec407a",
        500: "e91e63",
        600: "d81b60",
        700: "c2185b",
        800: "ad1457",
        900: "880e4f",
        "A100": "ff80ab",
        "A200": "ff4081",
        "A400": "f50057",
        "A700": "c51162",
      ]
    )
    static let grey = MaterialColor(
      colors: [
        50: "fafafa",
        100: "f5f5f5",
        200: "eeeeee",
        300: "e0e0e0",
        400: "bdbdbd",
        500: "9e9e9e",
        600: "757575",
        700: "616161",
        800: "424242",
        900: "212121",
        "A100": "f5f5f5",
        "A200": "eeeeee",
        "A400": "bdbdbd",
        "A700": "616161"
      ]
    )
    static let cyan = MaterialColor(
      colors: [
        50: "e0f7fa",
        100: "b2ebf2",
        200: "80deea",
        300: "4dd0e1",
        400: "26c6da",
        500: "00bcd4",
        600: "00acc1",
        700: "0097a7",
        800: "00838f",
        900: "006064",
        "A100": "84ffff",
        "A200": "18ffff",
        "A400": "00e5ff",
        "A700": "00b8d4",
      ]
    )
    static let lightBlue = MaterialColor(
      colors: [
        50: "e1f5fe",
        100: "b3e5fc",
        200: "81d4fa",
        300: "4fc3f7",
        400: "29b6f6",
        500: "03a9f4",
        600: "039be5",
        700: "0288d1",
        800: "0277bd",
        900: "01579b",
        "A100": "80d8ff",
        "A200": "40c4ff",
        "A400": "00b0ff",
        "A700": "0091ea",
      ]
    )
    static let teal = MaterialColor(
      colors: [
        50: "e0f2f1",
        100: "b2dfdb",
        200: "80cbc4",
        300: "4db6ac",
        400: "26a69a",
        500: "009688",
        600: "00897b",
        700: "00796b",
        800: "00695c",
        900: "004d40",
        "A100": "a7ffeb",
        "A200": "64ffda",
        "A400": "1de9b6",
        "A700": "00bfa5"
      ]
    )
    static let blueGrey = MaterialColor(
      colors: [
        50: "eceff1",
        100: "cfd8dc",
        200: "b0bec5",
        300: "90a4ae",
        400: "78909c",
        500: "607d8b",
        600: "546e7a",
        700: "455a64",
        800: "37474f",
        900: "263238",
        "A100": "cfd8dc",
        "A200": "b0bec5",
        "A400": "78909c",
        "A700": "455a64"
      ]
    )
    static let deepOrange = MaterialColor(
      colors: [
        500: "ff5722"
      ]
    )
    
    private init() {}
  }
}

// New Color
//
//static let colorName = MaterialColor(
//  colors: [
//    50: "",
//    100: "",
//    200: "",
//    300: "",
//    400: "",
//    500: "",
//    600: "",
//    700: "",
//    800: "",
//    900: "",
//    "A100": "",
//    "A200": "",
//    "A400": "",
//    "A700": "",
//  ]
//)
