//
//  View+styled.swift
//  Kenimo
//
//  Created by Morgan Wilde on 9/9/22.
//

import SwiftUI

extension View {
  @ViewBuilder func styled<Content: View>(
    conditionally condition: Bool? = nil,
    modify: (Self) -> Content
  ) -> some View
  {
    if condition == nil || (condition != nil && condition!) {
      modify(self)
    } else {
      self
    }
  }
}
