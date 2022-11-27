//
//  WordView.swift
//  Kenimo
//
//  Created by Morgan Wilde on 10/10/22.
//

import SwiftUI

extension MnemonicScreen {
  struct WordView: View {
    let index: Int
    let word: Mnemonic.Word
    var isFocused: Bool = false
    
    var wordForegroundColor: Color {
      if isFocused {
        return Colors.Material.teal[500]
      } else if word.isValid {
        return Colors.Material.grey[700]
      } else {
        return Colors.Material.deepOrange[500]
      }
    }
    var indicatorIcon: String? {
      if isFocused {
        return "pencil.circle.fill"
      } else if !word.isValid {
        return "exclamationmark.circle.fill"
      } else {
        return nil
      }
    }
    var backgroundColor: Color {
      if isFocused {
        return Colors.Material.teal[50]
      } else {
        return Colors.Material.grey[300]
      }
    }
    
    var body: some View {
      HStack(spacing: 8) {
        HStack {
          Spacer()
          Text("\(index + 1)")
            .font(.system(size: 14))
            .foregroundColor(Colors.Material.grey[500])
        }
        .frame(width: 26)
        
        Divider()
        
        Text(word.string)
          .frame(maxWidth: .infinity, alignment: .leading)
          .foregroundColor(wordForegroundColor)
        
        if let indicatorIcon = indicatorIcon {
          ZStack(alignment: .center) {
            Image(systemName: indicatorIcon)
              .imageScale(.small)
              .foregroundColor(wordForegroundColor)
          }
          .frame(width: 16, height: 16)
          .padding(.trailing, 8)
        } else if let bits = word.bits {
          Text(bits)
            .font(.system(size: 12).monospaced())
            .foregroundColor(Colors.Material.grey[500])
            .padding(.trailing, 8)
        }
      }
      .frame(height: 20)
      .background(backgroundColor)
      .cornerRadius(16)
    }
  }
}

struct Previews_MnemonicScreen_WordView: PreviewProvider {
  static var previews: some View {
    Group {
      MnemonicScreen.WordView(
        index: 0,
        word: Mnemonic.Word("test"),
        isFocused: false
      )
      .previewDisplayName("WordView")
      MnemonicScreen.WordView(
        index: 0,
        word: Mnemonic.Word("test"),
        isFocused: true
      )
      .previewDisplayName("WordView, focused")
      MnemonicScreen.WordView(
        index: 0,
        word: Mnemonic.Word("tests"),
        isFocused: false
      )
      .previewDisplayName("WordView, invalid")
    }
  }
}
