//
//  DataController.swift
//  Kenimo
//
//  Created by Morgan Wilde on 10/19/22.
//

import Foundation
import CoreData

class DataController: ObservableObject {
  let container = NSPersistentContainer(name: "Kenimo")
  
  init() {
    container.loadPersistentStores { description, error in
      if let error = error {
        print("CoreData failed to load \(error.localizedDescription).")
      }
    }
  }
}
