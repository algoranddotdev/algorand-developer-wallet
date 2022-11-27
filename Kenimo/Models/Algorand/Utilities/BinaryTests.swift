//
//  BinaryTests.swift
//  ArchWalletTests
//
//  Created by Morgan Wilde on 8/25/22.
//

import XCTest

class BinaryTests: XCTestCase {
  
  func testConvertArrayFrom8To11Bit() {
    let assertions: [(input: Array<UInt>, output: Array<UInt>)] = [
      // Emoty array.
      ([], []),
      // Checking various lengths.
      ([0], [0]),
      ([0, 0], [0, 0]),
      ([0, 0, 0], [0, 0, 0]),
      ([0, 0, 0, 0], [0, 0, 0]),
      ([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0]),
      (
        [
          0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0
        ],
        [
          0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0
        ]
      ),
      // Checking for correct bit masking and appending.
      ([0b0000_0001, 0b0000_0001, 0b0000_0001, 0b0000_0001], [0b001_0000_0001, 0b000_0010_0000, 0b000_0000_0100]),
      ([1, 2, 4, 8, 16, 32, 64, 128], [513, 128, 32, 8, 1026, 256]),
      // Convert 32 bytes to 24 mnemonic word indices.
      (
        [
          1, 1, 1, 1, 1, 1, 1, 1,
          1, 1, 1, 1, 1, 1, 1, 1,
          1, 1, 1, 1, 1, 1, 1, 1,
          1, 1, 1, 1, 1, 1, 1, 1
        ],
        [
          257, 32, 1028, 128, 16, 514, 64, 8,
          257, 32, 1028, 128, 16, 514, 64, 8,
          257, 32, 1028, 128, 16, 514, 64, 0
        ]
      ),
      (
        [
          0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff,
          0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff,
          0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff,
          0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff,
        ],
        [
          1792, 31, 1020, 1920, 15, 510, 1984, 7,
          255, 2016, 1027, 127, 2032, 1537, 63, 2040,
          1792, 31, 1020, 1920, 15, 510, 1984, 7
        ]
      )
    ]
    
    for assertion in assertions {
      XCTAssertEqual(Binary.convert(array: assertion.input, fromBits: 8, toBits: 11), assertion.output)
    }
  }
  func testConvertArrayFrom11To8Bit() {
    let assertions: [(input: Array<UInt>, output: Array<UInt>)] = [
      // Emoty array.
      ([], []),
      // Checking various lengths.
      ([0], [0, 0]),
      ([0, 0], [0, 0, 0]),
      ([0, 0, 0], [0, 0, 0, 0, 0]),
      ([0, 0, 0, 0], [0, 0, 0, 0, 0, 0]),
      ([0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0]),
      (
        [
          0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0
        ],
        [
          0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0,
          0
        ]
      ),
      // Convert 24 mnemonic word indices to 32 + 1 bytes.
      (
        [
          257, 32, 1028, 128, 16, 514, 64, 8,
          257, 32, 1028, 128, 16, 514, 64, 8,
          257, 32, 1028, 128, 16, 514, 64, 0
        ],
        [
          1, 1, 1, 1, 1, 1, 1, 1,
          1, 1, 1, 1, 1, 1, 1, 1,
          1, 1, 1, 1, 1, 1, 1, 1,
          1, 1, 1, 1, 1, 1, 1, 1,
          0
        ]
      ),
      (
        [
          1792, 31, 1020, 1920, 15, 510, 1984, 7,
          255, 2016, 1027, 127, 2032, 1537, 63, 2040,
          1792, 31, 1020, 1920, 15, 510, 1984, 7
        ],
        [
          0, 255, 0, 255, 0, 255, 0, 255,
          0, 255, 0, 255, 0, 255, 0, 255,
          0, 255, 0, 255, 0, 255, 0, 255,
          0, 255, 0, 255, 0, 255, 0, 255,
          0
        ]
      )
    ]
    
    for assertion in assertions {
      XCTAssertEqual(Binary.convert(array: assertion.input, fromBits: 11, toBits: 8), assertion.output)
    }
  }
  
}
