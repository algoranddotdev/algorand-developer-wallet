//
//  AlgorandNetwork+CoreDataProperties.swift
//  Kenimo
//
//  Created by Morgan Wilde on 10/20/22.
//
//

import Foundation
import CoreData


extension AlgorandNetwork {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<AlgorandNetwork> {
    return NSFetchRequest<AlgorandNetwork>(entityName: "AlgorandNetwork")
  }
  
  @NSManaged public var name: String
  @NSManaged public var typeInteger: Int16
  @NSManaged public var isActive: Bool
  @NSManaged public var host: String
  
}

enum AlgorandNetworkType: Int16, CaseIterable, Identifiable {
  case sandbox = 0
  case test = 1
  case main = 2
  case unknown = 32767
  
  var id: Self { self }
  var name: String {
    switch self {
    case .sandbox:
      return "Sandbox"
    case .test:
      return "TestNet"
    case .main:
      return "MainNet"
    case .unknown:
      return "Unknown"
    }
  }
}

extension AlgorandNetwork : Identifiable {
  var type: AlgorandNetworkType {
    set {
      typeInteger = newValue.rawValue
    }
    get {
      AlgorandNetworkType(rawValue: typeInteger) ?? .unknown
    }
  }
}
