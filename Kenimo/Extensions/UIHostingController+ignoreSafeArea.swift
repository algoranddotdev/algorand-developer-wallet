//
//  UIHostingController+ignoreSafeArea.swift
//  Kenimo
//
//  Created by Morgan Wilde on 9/22/22.
//

import SwiftUI

/// Taken from this [article](https://defagos.github.io/swiftui_collection_part3/).
extension UIHostingController {
  convenience public init(rootView: Content, ignoreSafeArea: Bool) {
    self.init(rootView: rootView)
    
    if ignoreSafeArea {
      disableSafeArea()
    }
  }
  
  func disableSafeArea() {
    guard let viewClass = object_getClass(view) else {
      return
    }
    
    let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
    if let viewSubclass = NSClassFromString(viewSubclassName) {
      object_setClass(view, viewSubclass)
    } else {
      guard
        let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String,
        let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0)
      else {
        return
      }
      
      if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
        let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in return .zero }
        class_addMethod(
          viewSubclass,
          #selector(getter: UIView.safeAreaInsets),
          imp_implementationWithBlock(safeAreaInsets),
          method_getTypeEncoding(method)
        )
      }
      
      objc_registerClassPair(viewSubclass)
      object_setClass(view, viewSubclass)
    }
  }
}
