//
//  KenimoApp.swift
//  Kenimo
//
//  Created by Morgan Wilde on 9/8/22.
//

import SwiftUI

@main
struct KenimoApp: App {
  @StateObject private var dataController = DataController()
  
  var body: some Scene {
    WindowGroup {
      MainView()
        .preferredColorScheme(.light)
        .environment(\.managedObjectContext, dataController.container.viewContext)
    }
  }
}
