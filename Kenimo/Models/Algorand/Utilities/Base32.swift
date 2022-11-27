//
//  Base32.swift
//  ArchWallet
//
//  Created by Morgan Wilde on 8/18/22.
//

import Foundation

let upperCaseLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
let numbers = "234567"
let padding = "="

let characters = (
  Array(upperCaseLetters) +
  Array(numbers)
).map {
  String($0)
}
var encoding: [String: Int] = Dictionary(uniqueKeysWithValues: characters.enumerated().map { ($1, $0) })

enum Base32Error: Error, Equatable {
  case invalidInputLength(length: Int)
}

struct Base32 {
  static func encode(bytes: [UInt8]) -> String {
    var encoded = ""
    let paddingLength = bytes.count % 5
    let lengthWithoutPadding = bytes.count - paddingLength
    
    if lengthWithoutPadding > 0 {
      for cursor in stride(from: 0, to: lengthWithoutPadding, by: 5) {
        // Assemble 5 bytes into a single sequence of 40 bits.
        var bits = 0
        for byte in 0..<5 {
          bits = bits << 8
          bits += Int(bytes[cursor + byte])
        }
        
        // Extract 8 5-bit segments using bit masking.
        var buffer = ""
        for _ in 0..<8 {
          let segment = bits & 0b11111
          buffer = characters[segment] + buffer
          bits = bits >> 5
        }
        
        encoded += buffer
      }
    }
    
    if paddingLength > 0 {
      // Find how many 5-bit segments we can fill with data.
      // Calculate how big the gap is between paddedBytes and 40 bits.
      let segments = Int(((Double(paddingLength) * 8) / 5).rounded(.up))
      let gap = segments * 5 - paddingLength * 8
      
      var bits = 0
      for byte in 0..<paddingLength {
        bits = bits << 8
        bits += Int(bytes[lengthWithoutPadding + byte])
      }
      
      bits = bits << gap
      
      // Extract 5-bits segments using bit masking.
      var buffer = ""
      for _ in 0..<segments {
        let segment = bits & 0b11111
        buffer = characters[segment] + buffer
        bits = bits >> 5
      }
      
      encoded += buffer + String(repeating: padding, count: 8 - segments)
    }
    
    return encoded
  }
  static func encode(bytes: Data) -> String {
    return self.encode(bytes: Array<UInt8>(bytes))
  }
  static func decode(string: String) throws -> [UInt8] {
    // Make sure input is a valid Base32 string with length being a multiple of 8.
    if string.count % 8 != 0 {
      throw Base32Error.invalidInputLength(length: string.count)
    }
    
    let characters = Array(string).map { String($0) }
    var decoded: Array<UInt8> = []
    
    for cursor in stride(from: 0, to: string.count, by: 8) {
      // Assemble 8 5-bit segments into one 40 bit long number.
      var bits = 0
      var segments = 0
      
      for segment in 0..<8 {
        let symbol = characters[cursor + segment]
        if symbol == padding {
          // Ignore padding.
          break
        }
        
        bits = bits << 5
        bits += encoding[symbol]!
        segments += 1
      }
      
      // Using bit mapping extract 5, 4, 3, 2, or 1 bytes from the number, depending on padding.
      let lengthWithoutPadding = Int(((Double(segments) * 5) / 8).rounded(.down))
      let gap = segments * 5 - lengthWithoutPadding * 8
      
      var buffer: Array<UInt8> = []
      for byte in 0..<lengthWithoutPadding {
        buffer.append(
          UInt8((bits >> (8 * byte + gap)) & 0b11111111)
        )
      }
      
      decoded.append(contentsOf: buffer.reversed())
    }
    
    return decoded
  }
  static func decode(algorandAddress: String) -> [UInt8] {
    return try! self.decode(string: algorandAddress + "======")
  }
}
