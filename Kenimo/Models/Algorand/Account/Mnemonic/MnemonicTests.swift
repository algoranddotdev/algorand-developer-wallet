//
//  MnemonicTests.swift
//  KenimoTests
//
//  Created by Morgan Wilde on 10/12/22.
//

import XCTest

final class MnemonicTests: XCTestCase {
  
  func testWordEqualTo0() {
    let mnemonic = Mnemonic(words: [
      Mnemonic.Word("abandon")
    ])
    
    XCTAssertEqual(mnemonic.words[0].bits, "0000 0000 0000")
  }
  func testWordEqualTo1() {
    let mnemonic = Mnemonic(words: [
      Mnemonic.Word("ability")
    ])
    
    XCTAssertEqual(mnemonic.words[0].bits, "0000 0000 0001")
  }
  func testWordEqualTo8() {
    let mnemonic = Mnemonic(words: [
      Mnemonic.Word("absurd")
    ])
    
    XCTAssertEqual(mnemonic.words[0].bits, "0000 0000 1000")
  }
  func testWordEqualTo17() {
    let mnemonic = Mnemonic(words: [
      Mnemonic.Word("acquire")
    ])
    
    XCTAssertEqual(mnemonic.words[0].bits, "0000 0001 0001")
  }
  func testWordEqualTo136() {
    let mnemonic = Mnemonic(words: [
      Mnemonic.Word("baby")
    ])
    
    XCTAssertEqual(mnemonic.words[0].bits, "0000 1000 1000")
  }
  func testWordEqualTo273() {
    let mnemonic = Mnemonic(words: [
      Mnemonic.Word("captain")
    ])
    
    XCTAssertEqual(mnemonic.words[0].bits, "0001 0001 0001")
  }
  func testWordEqualTo2047() {
    let mnemonic = Mnemonic(words: [
      Mnemonic.Word("zoo")
    ])
    
    XCTAssertEqual(mnemonic.words[0].bits, "0111 1111 1111")
  }
  
}
