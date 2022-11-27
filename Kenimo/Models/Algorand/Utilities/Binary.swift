//
//  Binary.swift
//  ArchWallet
//
//  Created by Morgan Wilde on 8/25/22.
//

import Foundation

struct Binary {
  static func convert(array source: [UInt], fromBits sourceBitCount: UInt, toBits targetBitCount: UInt) -> [UInt] {
    var target = Array<UInt>()
    let targetBitMask = UInt(
      String(repeating: "1", count: Int(targetBitCount)),
      radix: 2
    )!
    
    var buffer: UInt = 0
    var bufferBitCount: UInt = 0
    for bits in source {
      // Insert new bits in front of the old bits in the buffer.
      buffer |= bits << bufferBitCount
      bufferBitCount += sourceBitCount
      
      // If there are enough bits in the buffer to fill up the target, consume them.
      while bufferBitCount >= targetBitCount {
        target.append(buffer & targetBitMask)
        buffer >>= targetBitCount
        bufferBitCount -= targetBitCount
      }
    }
    
    // Don't lose any bits that weren't processed in the main loop.
    if bufferBitCount > 0 {
      target.append(buffer)
    }
    
    return target
  }
}
