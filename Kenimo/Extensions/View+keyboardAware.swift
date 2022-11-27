//
//  View+keyboardAware.swift
//  Kenimo
//
//  Created by Morgan Wilde on 9/9/22.
//

import SwiftUI

struct KeyboardAware: ViewModifier {
  func body(content: Content) -> some View {
    GeometryReader { geometry in
      content
    }
  }
}

extension View {
  func keyboardAware() -> some View {
    return modifier(KeyboardAware())
  }
}
