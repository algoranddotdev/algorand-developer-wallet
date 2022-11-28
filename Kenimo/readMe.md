#  Algorand Developer Wallet

This project got started while I was working on a new Algorand JavaScript SDK and couldn't make further progress due to Pera Algo wallet and WalletConnect/WebSocket issues. It eventually matured into a branded product called Kenimo when I was seeking support from the Algorand Foundation to complete development. At this point in time, development has been paused due to lack of support from the Algorand Foundation.

The main idea was to build a bobile wallet exprience for Algorand that would leapfrog existing solutions in order to enable real consumer addoption. The problems that exist in the current landscape step from the fact that Pera Algo wallet, and others in its stead, have adopted the WalletConnect protocol, which was designed for Ethereum and works well with other EVM chains. The protocol relies on WebSocket connections to relay information between web app and wallet, which on a mobile device is a terrible experience, with dropped connections and inconsistent user experience.

A brand new wallet + wallet-to-web-app protocol designed for Algorand fround the ground up is not a simple task, but one that I realized was unavoidable if I wanted to create a truly great developer experience for the Algorand JavaScript SDK. So I decided to focus on targeting developers with features that would cater to them first, and worry about regular users later. These features include the following.

1. Full support of local sandbox environments (not limited to MainNet and TestNet anymore)
2. A new, more accessible, wallet-to-web-app interface that's based on JSON
3. The ability to accessibly parse transaction content on the wallet
4. Ideally, no bridge server in between app and wallet by using deep links for everything
5. Handle all heavy lifting of submitting transactions on the wallet, leaving clients light and accessible
6. Observer accounts that don't require private key (imagine tracking other Algorand accounts on your phone)
7. Mobile push notification services for decentralized app developers

## Structure

This is a SwiftUI native iOS app built by following the latest APIs that Apple provides. I worked on this repository up to a point where I was able to submit signed transactions to Sandbox and TestNet environments, some of those screens have been remove because they were more like test benches. The current state of the app includes the start of a user's journey - adding a private key using a 25 word mnemonic phrase. Due to the developer focus of this wallet, I envisioned various extra information that might be useful for devs, as an example - while adding mnemonic words you get to see the actual bit values for each word.

The project is split up into `Models`, `Components`, `Screens`, `Extensions`, and `Utilities`. Most of the work has gone into the `Models/Algorand` part of the app, with custom implementations of MessagePack, Base 32, SHA 512/256, and others. I followed Test Driven Design principles while working on most of the model. These custom implementations have allowed me to more deeply understand how the full stack works and in turn find ways to optimize.

## Running

To run this project, simply select simulator or device and click "Run". You should be greeted by an new Account screen.

![Account Mnemonic](/documentation/assets/screen.account.mnemonic.png)

## Testing

Tests can be performed using the standard Xcode XCTest tools. Currently, there are 40 tests and they're all passing.
