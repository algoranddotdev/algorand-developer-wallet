//
//  Action.swift
//  Kenimo
//
//  Created by Morgan Wilde on 10/14/22.
//

import SwiftUI

struct Action<Content>: View where Content : View {
  
  let title: Content
  let isDisabled: Bool
  let isInverted: Bool
  let isSecondary: Bool
  let action: () -> Void
  
  var backgroundGradient: Gradient {
    if isDisabled {
      return Gradient(stops: [
        .init(color: Colors.Material.grey[200], location: 0)
      ])
    } else if isInverted || isSecondary {
      return Gradient(stops: [
        .init(color: Colors.Material.grey[100], location: 0),
        .init(color: Colors.Material.grey[300], location: 1)
      ])
    } else {
      return Gradient(stops: [
        .init(color: Colors.Material.pink[500], location: 0),
        .init(color: Colors.Material.pink[700], location: 1)
      ])
    }
  }
  var foregroundColor: Color {
    if isDisabled {
      return Colors.Material.grey[400]
    } else if isInverted {
      return Colors.Material.pink[700]
    } else if isSecondary {
      return Colors.Material.grey[700]
    } else {
      return Colors.Material.grey[100]
    }
  }
  
  var titleIsIcon: Bool {
    return title as? Image != nil
  }
  
  var body: some View {
    Button(action: action) {
      title
        .frame(height: 50)
        .frame(maxWidth: isSecondary ? nil : .infinity)
        .padding(.horizontal, 16)
        .font(.system(size: 14).weight(isSecondary ? .regular : .semibold))
        .background {
          LinearGradient(
            gradient: backgroundGradient,
            startPoint: .top,
            endPoint: .bottom
          )
            .cornerRadius(8)
            .shadow(
              color: Colors.Material.grey[400],
              radius: isDisabled ? 0 : 1,
              x: 0,
              y: isDisabled ? 0 : 1
            )
        }
        .foregroundColor(foregroundColor)
    }
  }
  
  init(
    title: Content,
    isDisabled: Bool = false,
    isInverted: Bool = false,
    isSecondary: Bool = false,
    action: @escaping () -> Void = {}
  ) {
    self.title = title
    self.isDisabled = isDisabled
    self.isInverted = isInverted
    self.isSecondary = isSecondary
    self.action = action
  }
}

extension Action {
  func isDisabled(_ value: Bool?) -> some View {
    return Action(
      title: title,
      isDisabled: value ?? false,
      isInverted: isInverted,
      isSecondary: isSecondary,
      action: action
    )
  }
  func isInverted(_ value: Bool?) -> some View {
    return Action(
      title: title,
      isDisabled: isDisabled,
      isInverted: value ?? false,
      isSecondary: isSecondary,
      action: action
    )
  }
  func isSecondary(_ value: Bool?) -> some View {
    return Action(
      title: title,
      isDisabled: isDisabled,
      isInverted: isInverted,
      isSecondary: value ?? false,
      action: action
    )
  }
}

struct Action_Previews: PreviewProvider {
  static var previews: some View {
    VStack(alignment: .leading) {
      HStack {
        Action(title: Text("Test"))
        Text("default")
      }
      HStack {
        Action(title: Text("Test"))
          .isDisabled(true)
        Text("disabled")
      }
      HStack {
        Action(title: Text("Test"))
          .isSecondary(true)
        Text("secondary")
      }
      HStack {
        Action(title: Text("Test"))
          .isInverted(true)
        Text("inverted")
      }
      HStack {
        Action(title: Text("Test"), isDisabled: true, isInverted: true)
        Text("disabled, inverted")
      }
      HStack {
        Action(title: Image(systemName: "chevron.left"))
        Text("image")
      }
      HStack {
        Action(title: Image(systemName: "chevron.left"), isDisabled: true)
        Text("image, disabled")
      }
      HStack {
        Action(title: Image(systemName: "chevron.left"), isInverted: true)
        Text("image, inverted")
      }
      HStack {
        Action(title: Image(systemName: "chevron.left"), isDisabled: true, isInverted: true)
        Text("image, disabled, inverted")
      }
    }
    .padding(32)
    .font(.system(size: 12))
    .foregroundColor(.gray)
  }
}
