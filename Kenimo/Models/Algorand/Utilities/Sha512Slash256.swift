//
//  Sha512Slash256.swift
//  ArchWallet
//
//  Created by Morgan Wilde on 8/21/22.
//

// Algorithm pseudo code taken from https://en.wikipedia.org/wiki/SHA-2.
// Some inspiration taken from https://github.com/mlachmish/Cryptography/blob/master/Cryptography/Algorithms/Hash/SHA2.swift.
// Algorand Swift SDK https://github.com/Jesulonimi21/Swift-Algorand-Sdk/blob/7bd4c548b79279b2d42a9768fb3abb44d0b118b7/Sources/swift-algorand-sdk/Constants.swift

import Foundation
import CryptoKit

private let chunkSize = 1024
private let chunkSizeInBytes = chunkSize / 8

// Initial hash values (big-endian).
private let h: Array<UInt64> = [
  0x22312194FC2BF72C, 0x9F555FA3C84C64C2, 0x2393B86B6F53B151, 0x963877195940EABD,
  0x96283EE2A88EFFE3, 0xBE5E1E2553863992, 0x2B0199FC2C85B8AA, 0x0EB72DDC81C52CA2
]

// Round constants.
private let k: Array<UInt64> = [
  0x428a2f98d728ae22, 0x7137449123ef65cd, 0xb5c0fbcfec4d3b2f, 0xe9b5dba58189dbbc,
  0x3956c25bf348b538, 0x59f111f1b605d019, 0x923f82a4af194f9b, 0xab1c5ed5da6d8118,
  0xd807aa98a3030242, 0x12835b0145706fbe, 0x243185be4ee4b28c, 0x550c7dc3d5ffb4e2,
  0x72be5d74f27b896f, 0x80deb1fe3b1696b1, 0x9bdc06a725c71235, 0xc19bf174cf692694,
  0xe49b69c19ef14ad2, 0xefbe4786384f25e3, 0x0fc19dc68b8cd5b5, 0x240ca1cc77ac9c65,
  0x2de92c6f592b0275, 0x4a7484aa6ea6e483, 0x5cb0a9dcbd41fbd4, 0x76f988da831153b5,
  0x983e5152ee66dfab, 0xa831c66d2db43210, 0xb00327c898fb213f, 0xbf597fc7beef0ee4,
  0xc6e00bf33da88fc2, 0xd5a79147930aa725, 0x06ca6351e003826f, 0x142929670a0e6e70,
  0x27b70a8546d22ffc, 0x2e1b21385c26c926, 0x4d2c6dfc5ac42aed, 0x53380d139d95b3df,
  0x650a73548baf63de, 0x766a0abb3c77b2a8, 0x81c2c92e47edaee6, 0x92722c851482353b,
  0xa2bfe8a14cf10364, 0xa81a664bbc423001, 0xc24b8b70d0f89791, 0xc76c51a30654be30,
  0xd192e819d6ef5218, 0xd69906245565a910, 0xf40e35855771202a, 0x106aa07032bbd1b8,
  0x19a4c116b8d2d0c8, 0x1e376c085141ab53, 0x2748774cdf8eeb99, 0x34b0bcb5e19b48a8,
  0x391c0cb3c5c95a63, 0x4ed8aa4ae3418acb, 0x5b9cca4f7763e373, 0x682e6ff3d6b2b8a3,
  0x748f82ee5defb2fc, 0x78a5636f43172f60, 0x84c87814a1f0ab72, 0x8cc702081a6439ec,
  0x90befffa23631e28, 0xa4506cebde82bde9, 0xbef9a3f7b2c67915, 0xc67178f2e372532b,
  0xca273eceea26619c, 0xd186b8c721c0c207, 0xeada7dd6cde0eb1e, 0xf57d4f7fee6ed178,
  0x06f067aa72176fba, 0x0a637dc5a2c898a6, 0x113f9804bef90dae, 0x1b710b35131c471b,
  0x28db77f523047d84, 0x32caab7b40c72493, 0x3c9ebe0a15c9bebc, 0x431d67c49c100d4c,
  0x4cc5d4becb3e42b6, 0x597f299cfc657e2a, 0x5fcb6fab3ad6faec, 0x6c44198c4a475817
]

extension UInt64 {
  func rotateRight(_ distance: UInt64) -> UInt64 {
    return (self >> distance) | (self << (64 - distance))
  }
}

struct Sha512Slash256 {
  
  internal static func preprocess(_ bytes: [UInt8]) -> [UInt8] {
    let bitCount = bytes.count * 8
    var processed = Array<UInt8>(bytes)
    
    // Add 1 bit and 7 zeros as padding.
    processed.append(0b1000_0000)
    
    // Calculate how many zeros need to be added to make bytes a multiple of 1024 bits.
    // We added 7 zeros already by appending the 1 bit.
    // The original bitCount will be recorded as a 128-bit big-endian integer.
    let addedBitCount = 1 + 7 + 128
    let zeroPaddingBitCount = chunkSize - (bitCount + addedBitCount) % chunkSize
    
    processed += Array<UInt8>(repeating: 0b0000_0000, count: zeroPaddingBitCount / 8)
    
    // Add the original bytes length in bits.
    // Because it's expected to be a 128-bit integer, I need to pad with 8 zero bytes, since Swift Int is only 64 bits long.
    let bitCountBytes = (
      Array<UInt8>(repeating: 0x00, count: 8) +
      withUnsafeBytes(of: bitCount.bigEndian, Array<UInt8>.init)
    )
    processed += bitCountBytes
    
    return processed
  }
  
  static func hash(bytes: [UInt8]) -> [UInt8] {
    let preprocessed = preprocess(bytes)
    
    // Work on 1024-bit chunks.
    let chunkCount = preprocessed.count / chunkSizeInBytes
    let chunks: [[UInt8]] = (0..<chunkCount).map { index in
      let from = index * chunkSizeInBytes
      let to = (index + 1) * chunkSizeInBytes
      return Array<UInt8>(preprocessed[from..<to])
    }
    
    // Initialize variables.
    var h0 = h[0]
    var h1 = h[1]
    var h2 = h[2]
    var h3 = h[3]
    var h4 = h[4]
    var h5 = h[5]
    var h6 = h[6]
    var h7 = h[7]
    
    
    for chunk in chunks {
      var w = Array<UInt64>(repeating: 0, count: k.count)
      
      // Fill the first 16 words of the message schedule array w by assembling UInt64 from every 8 bytes.
      for cursor in stride(from: 0, to: chunkSizeInBytes, by: UInt64.bitWidth / 8) {
        var buffer: UInt64 = 0
        for i in 0..<8 {
          buffer <<= 8
          buffer |= UInt64(chunk[cursor + i])
        }
        w[cursor / 8] = buffer
      }
      
      // Extend the first 16 words into the remaining 48 words of the message schedule array.
      for i in 16..<w.count {
        let s0 = w[i-15].rotateRight(1) ^ w[i-15].rotateRight(8) ^ (w[i-15] >> 7)
        let s1 = w[i-2].rotateRight(19) ^ w[i-2].rotateRight(61) ^ (w[i-2] >> 6)
        // Use the overflow addition operator "&+" because we're OK with overflow here.
        w[i] = w[i-16] &+ s0 &+ w[i-7] &+ s1
      }
      
      // Initialize working variables to current hash value.
      var a = h0
      var b = h1
      var c = h2
      var d = h3
      var e = h4
      var f = h5
      var g = h6
      var h = h7
      
      // Compression function main loop.
      for i in 0..<80 {
        let S1 = e.rotateRight(14) ^ e.rotateRight(18) ^ e.rotateRight(41)
        let ch = (e & f) ^ (~e & g)
        let temp1 = h &+ S1 &+ ch &+ k[i] &+ w[i]
        let S0 = a.rotateRight(28) ^ a.rotateRight(34) ^ a.rotateRight(39)
        let maj = (a & b) ^ (a & c) ^ (b & c)
        let temp2 = S0 &+ maj
        
        h = g
        g = f
        f = e
        e = d &+ temp1
        d = c
        c = b
        b = a
        a = temp1 &+ temp2
      }
      
      // Add the compressed chunk to the current hash value.
      h0 = h0 &+ a
      h1 = h1 &+ b
      h2 = h2 &+ c
      h3 = h3 &+ d
      h4 = h4 &+ e
      h5 = h5 &+ f
      h6 = h6 &+ g
      h7 = h7 &+ h
    }
    
    var hash: Array<UInt8> = []
    
    for section in [h0, h1, h2, h3] {
      let truncated = withUnsafeBytes(of: section.bigEndian, Array<UInt8>.init)
      hash += truncated
    }
    
    return hash
  }
  static func hash(bytes: Data) -> [UInt8] {
    return self.hash(bytes: Array<UInt8>(bytes))
  }
  
}
