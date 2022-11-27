//
//  KeyboardResponder.swift
//  Kenimo
//
//  Created by Morgan Wilde on 10/9/22.
//

import SwiftUI

class KeyboardResponder: ObservableObject {
  @Published private(set) var currentHeight: CGFloat = 0
  
  init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyBoardWillShow(notification:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyBoardWillHide(notification:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc func keyBoardWillShow(notification: Notification) {
//    print(notification.userInfo)
    if
      let userInfo = notification.userInfo,
      let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
    {
//      currentHeight = keyboardFrame.cgRectValue.height
      withAnimation {
        currentHeight = keyboardFrame.cgRectValue.height
      }
    }
  }
  
  @objc func keyBoardWillHide(notification: Notification) {
//    currentHeight = 0
    withAnimation {
      currentHeight = 0
    }
  }
}
