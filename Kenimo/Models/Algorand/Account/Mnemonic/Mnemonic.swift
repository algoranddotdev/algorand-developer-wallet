//
//  Mnemonic.swift
//  Kenimo
//
//  Created by Morgan Wilde on 10/10/22.
//

import Foundation
import SwiftUI

func load<T: Decodable>() -> T {
  let file = Bundle.main.url(forResource: "wordList.json", withExtension: nil)!
  let data = try? Data(contentsOf: file)
  let wordList = try? JSONDecoder().decode(T.self, from: data!)
  
  return wordList!
}

fileprivate let wordList: [String] = load()

enum MnemonicError: Error, Equatable {
  case unexpectedWordCount
  case unknown(word: String)
  case invalidChecksum
}

struct Mnemonic {
  
  struct Word: Equatable {
    static func == (left: Word, right: Word) -> Bool {
      return left.string == right.string
    }
    
    var string: String
    
    var number: Int? {
      return wordList.firstIndex(of: string)
    }
    var bits: String? {
      if let number = number {
        let bytes = withUnsafeBytes(of: UInt16(number).bigEndian, Array<UInt8>.init)
        let bits = bytes.map { String($0, radix: 2) }
        var formattedBits = ""
        
        // Add the leading 3 bits formatted as 4.
        formattedBits += String(repeating: "0", count: 4 - bits[0].count) + bits[0]
        
        // Pad to a full byte and then split at 4 bits.
        let lastByte = String(repeating: "0", count: 8 - bits[1].count) + bits[1]
        formattedBits += " " + lastByte[lastByte.startIndex..<lastByte.index(lastByte.startIndex, offsetBy: 4)]
        formattedBits += " " + lastByte[lastByte.index(lastByte.startIndex, offsetBy: 4)..<lastByte.index(lastByte.startIndex, offsetBy: 8)]
        
        return formattedBits
      }
      return nil
    }
    var isValid: Bool {
      return number != nil
    }
    
    init(_ string: String) {
      self.string = string
    }
  }
  
  static let targetWordCount = 25
  
  var words: [Word]
  
  mutating func addWord(_ string: String) {
    if words.count < Mnemonic.targetWordCount {
      words.append(Word(string))
    }
  }
  
  func generateSeed() throws -> [UInt8] {
    var wordBits = try words.map { word in
      guard let wordNumber = word.number else {
        throw MnemonicError.unknown(word: word.string)
      }
      return UInt(wordNumber)
    }
    
    if wordBits.count != Mnemonic.targetWordCount {
      throw MnemonicError.unexpectedWordCount
    }
    
    let lastWordBits = wordBits.popLast()!
    
    var seed = Binary.convert(array: wordBits, fromBits: 11, toBits: 8).map { UInt8($0) }
    
    // Drop the last zero byte.
    _ = seed.popLast()
    
    // Calculate checksum and compare it with the last word in the mnemonic.
    let hash = Sha512Slash256.hash(bytes: seed)
    let checksumBits = Binary.convert(array: hash.map { UInt($0) }, fromBits: 8, toBits: 11).first!
    
    if lastWordBits != checksumBits {
      throw MnemonicError.invalidChecksum
    }
    
    return seed
  }
}
