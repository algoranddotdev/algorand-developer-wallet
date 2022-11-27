//
//  MnemonicView.swift
//  Kenimo
//
//  Created by Morgan Wilde on 9/8/22.
//

import SwiftUI
import Combine

let words = "pulp wise length prosper orchard country eager minute lady eagle winner topple taxi much chimney public solar lake december taxi write feed siege abandon power".split(separator: " ").map { Mnemonic.Word(String($0)) }

struct MnemonicScreen: View {
  
  @EnvironmentObject var store: KenimoStore
  
  enum Field: Hashable {
    case word
  }
  
  @State private var mnemonic = Mnemonic(words: [Mnemonic.Word("test")])
  
  @State private var focusedWord: String = ""
  @State private var focusedWordIndex: Int? = nil
  
  @State private var wordsScrollViewProxy: ScrollViewProxy?
  @FocusState private var focusedField: Field?
  
  @ObservedObject private var keyboard = KeyboardResponder()
  @Namespace var bottomId
  
  var previousFocusedWordIndex: Int? {
    if let focusedWordIndex = focusedWordIndex {
      return max(0, focusedWordIndex - 1)
    } else {
      return nil
    }
  }
  var nextFocusedWordIndex: Int? {
    if let focusedWordIndex = focusedWordIndex {
      var wordCount = mnemonic.words.count
      let nextFocusedWordIndex = focusedWordIndex + 1
      if focusedWordIndex >= mnemonic.words.count && focusedWord.count > 0 {
        // Account for the new word that is yet to be added
        wordCount += 1
      }
      
      return min(wordCount, nextFocusedWordIndex, Mnemonic.targetWordCount - 1)
    } else {
      return nil
    }
  }
  
  var body: some View {
    Screen { screen in
      Text("Mnemonic Phrase")
        .font(.system(size: 18, weight: .regular, design: .default))
        .foregroundColor(Colors.Material.teal[900])
        .padding(.horizontal, 16)
        .padding(.top, 16)
      
        
      Text("Your Algorand account can be managed by providing the 25 word mnemonic phrase. Kenimo uses the Apple keychain to securely store your private key.")
        .font(.system(size: 14))
        .foregroundColor(Colors.Material.grey[700])
        .padding(16)
      
      Divider()
      
      ScrollViewReader { scrollViewProxy in
        ScrollView(showsIndicators: false) {
          VStack(alignment: .leading, spacing: 4) {
            ForEach(0 ..< mnemonic.words.count, id: \.self) { index in
              WordView(
                index: index,
                word: mnemonic.words[index],
                isFocused: focusedField == .word && focusedWordIndex == index
              )
              .id(index)
              .onTapGesture {
                withAnimation(Animation.easeInOut(duration: 0.25)) {
                  focusedWordIndex = index
                }
              }
            }
            if focusedWordIndex == mnemonic.words.count {
              WordView(
                index: mnemonic.words.count,
                word: Mnemonic.Word(focusedWord),
                isFocused: true
              )
              .id(focusedWordIndex)
              .opacity(focusedWordIndex == mnemonic.words.count ? 1 : 0)
              .transition(.move(edge: .bottom).combined(with: .opacity))
            }
          }
          .padding(.vertical, 16)
        }
        .padding(.horizontal, 16)
        .frame(idealHeight: 0)
        .onAppear {
          wordsScrollViewProxy = scrollViewProxy
          withAnimation {
            wordsScrollViewProxy?.scrollTo(focusedWordIndex, anchor: .bottom)
          }
        }
      }
      
      
      if mnemonic.words.count < Mnemonic.targetWordCount || focusedWordIndex != nil {
        Divider()
        
        HStack(alignment: .bottom) {
          Action(title: Image(systemName: "chevron.left"), isDisabled: previousFocusedWordIndex == focusedWordIndex, isInverted: true, isSecondary: true) {
            saveOrUpdateWord()
            withAnimation(Animation.easeInOut(duration: 0.25)) {
              self.focusedWordIndex = previousFocusedWordIndex
            }
          }
          
          VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
              Text("Mnemonic Word")
              if let focusedWordIndex = focusedWordIndex {
                Text("#\(focusedWordIndex + 1)")
                  .padding(.horizontal, 4)
                  .foregroundColor(Colors.Material.teal[500])
                  .background(Colors.Material.teal[50])
                  .cornerRadius(4)
                Text("/ \(Mnemonic.targetWordCount)")
              }
            }
            .foregroundColor(Colors.Material.grey[700])
            
            HStack {
              TextField("empty...", text: $focusedWord)
                .keyboardType(.asciiCapable)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 16)
                .frame(height: 50)
                .font(.system(size: 14))
                .background(
                  ZStack {
                    RoundedRectangle(cornerRadius: 6)
                      .fill(
                        focusedField == .word
                        ? Colors.Material.grey[50]
                        : Colors.Material.grey[100]
                      )
                      .shadow(
                        color: Colors.Material.grey[400],
                        radius: focusedField == .word ? 1 : 0,
                        x: 0,
                        y: focusedField == .word ? 1 : 0
                      )
                    RoundedRectangle(cornerRadius: 6)
                      .stroke(focusedField == .word ? Colors.Material.teal[500] : Colors.Material.blueGrey[200], lineWidth: 1)
                  }
                )
                .foregroundColor(Colors.Material.grey[900])
                .focused($focusedField, equals: .word)
                .onTapGesture {
                  focusedField = .word
                  focusedWordIndex = mnemonic.words.count - 1
                }
                .onChange(of: focusedWord) { nextFocusedWord in
                  if let focusedWordIndex = focusedWordIndex, focusedWordIndex < mnemonic.words.count {
                    mnemonic.words[focusedWordIndex].string = nextFocusedWord
                  }
                }
                .onSubmit {
                  focusedField = nil
                  focusedWordIndex = nil
                  saveOrUpdateWord()
                }
                .onAppear {
//                  focusedField = .word
//                  if let focusedWordIndex = focusedWordIndex, mnemonic.words.count > focusedWordIndex {
//                    focusedWord = mnemonic.words[focusedWordIndex].string
//                  }
                }
            }
          }
          
          Action(title: Image(systemName: "chevron.right"), isDisabled: nextFocusedWordIndex == focusedWordIndex, isInverted: true, isSecondary: true) {
            saveOrUpdateWord()
            withAnimation(Animation.easeInOut(duration: 0.25)) {
              self.focusedWordIndex = nextFocusedWordIndex
            }
          }
//          .isDisabled(nextFocusedWordIndex == focusedWordIndex)
//          .isInverted(true)
//          .isSecondary(true)
        }
        .id(bottomId)
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, max(0, keyboard.currentHeight - screen.geometryProxy.safeAreaInsets.bottom + 16))
        .onChange(of: keyboard.currentHeight) { newValue in
          screen.scrollViewProxy.scrollTo(bottomId, anchor: .bottom)
        }
        .onAnimationCompleted(for: keyboard.currentHeight) {
          withAnimation {
            wordsScrollViewProxy?.scrollTo(focusedWordIndex, anchor: .bottom)
          }
        }
        .onChange(of: focusedWordIndex) { nextFocusedWordIndex in
          focusedField = .word
          
          if let nextFocusedWordIndex = nextFocusedWordIndex, nextFocusedWordIndex < mnemonic.words.count {
            focusedWord = mnemonic.words[nextFocusedWordIndex].string
          } else {
            focusedWord = ""
          }
          
          withAnimation {
            wordsScrollViewProxy?.scrollTo(nextFocusedWordIndex, anchor: .bottom)
          }
        }
        .onChange(of: mnemonic.words) { nextWords in
          withAnimation {
            wordsScrollViewProxy?.scrollTo(focusedWordIndex, anchor: .bottom)
          }
        }
      } else {
        Divider()
        VStack(alignment: .center) {
          HStack(spacing: 16) {
            Action(title: Text("Edit"), isSecondary: true) {
              focusedWordIndex = 24
            }
            Action(title: Text("Proceed")) {
              do {
                let seed = try mnemonic.generateSeed()
                print(seed)
                let account = try Account(privateKeyBytes: seed)
                
                store.accounts.append(account)
                store.screen = .accounts
              } catch {
                print(error)
              }
            }
          }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .padding(.horizontal, 16)
      }
    } header: {
      Text("Add Account")
    } action: {
      store.screen = .accounts
    }
    .ignoresSafeArea(.keyboard)
  }
  
  func saveOrUpdateWord() {
    if let focusedWordIndex = focusedWordIndex, focusedWordIndex < mnemonic.words.count {
      mnemonic.words[focusedWordIndex].string = focusedWord
    } else if focusedWord.count > 0 {
      mnemonic.addWord(focusedWord)
    }
  }
}

fileprivate extension MnemonicScreen {
  init(mnemonic: Mnemonic, focusedWordIndex: Int? = 0) {
    self._mnemonic = State(initialValue: mnemonic)
    self._focusedWordIndex = State(initialValue: focusedWordIndex)
  }
}

struct Previews_MnemonicScreen: PreviewProvider {
  static var previews: some View {
    Group {
      MnemonicScreen(
        mnemonic: Mnemonic(words: [
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
        ]),
        focusedWordIndex: 0
      )
      .previewDisplayName("Mnemonic, focused #0 word")
      
      MnemonicScreen(
        mnemonic: Mnemonic(words: [
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
          Mnemonic.Word("test"),
        ]),
        focusedWordIndex: nil
      )
      .previewDisplayName("Mnemonic, focused #24 word")
    }
  }
}
