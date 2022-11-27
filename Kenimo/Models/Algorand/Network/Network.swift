//
//  Network.swift
//  Kenimo
//
//  Created by Morgan Wilde on 10/19/22.
//

import Foundation
import CoreData

struct Network {
  enum Variant {
    case sandbox
    case test
    case main
    case unknown
  }
  
  var variant: Variant
  var host: String
  
  func request(for path: String) -> URLRequest {
    let url = URL(string: "\(host)\(path)")!
    var request = URLRequest(url: url)
    
    if variant == .sandbox {
      request.setValue("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", forHTTPHeaderField: "X-Algo-API-Token")
    }
    
    return request
  }
}
