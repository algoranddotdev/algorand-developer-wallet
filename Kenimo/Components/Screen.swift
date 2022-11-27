//
//  Screen.swift
//  Kenimo
//
//  Created by Morgan Wilde on 9/14/22.
//

import SwiftUI

struct Screen<Header, Content> {
  var header: () -> Header
  var content: (ScreenProxy) -> Content
  var action: () -> Void = {}
  
  @available(*, unavailable)
  init(content: @escaping (ScreenProxy) -> Content, header: @escaping () -> Header) {
    self.content = content
    self.header = header
  }
}

struct ScreenProxy {
  var scrollViewProxy: ScrollViewProxy
  var geometryProxy: GeometryProxy
}

extension Screen: View where Content : View, Header : View {
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(spacing: 0) {
        Button {
          action()
        } label: {
          ZStack(alignment: .center) {
            Image(systemName: "arrow.left")
              .foregroundColor(Colors.Material.teal[800])
          }
          .frame(width: 40, height: 40)
          .padding(.leading, 16)
          .padding(.trailing, 16)
        }
        
        header()
          .foregroundColor(Colors.Material.teal[900])
          .font(.system(size: 20))
          .frame(height: 40)
        
        Spacer()
        
        ZStack(alignment: .center) {
          Image(systemName: "line.3.horizontal")
            .foregroundColor(Colors.Material.teal[800])
        }
        .frame(width: 40, height: 40)
        .padding(.leading, 16)
        .padding(.trailing, 16)
      }
      .compositingGroup()
      .zIndex(1)
      .background(Colors.Material.teal[300])
      .overlay {
        GeometryReader { geometry in
          Path { path in
            path.move(to: CGPoint(
              x: 0,
              y: geometry.size.height
            ))
            path.addLine(to: CGPoint(
              x: geometry.size.width,
              y: geometry.size.height
            ))
            path.closeSubpath()
          }
          .stroke(Colors.Material.teal[500])
        }
      }
      .shadow(
        color: Colors.Material.grey[500],
        radius: 4,
        x: 0,
        y: 2
      )
      
      GeometryReader { geometryProxy in
        VStack(spacing: 0) {
          ScrollViewReader { scrollViewProxy in
            ScrollView {
              VStack(alignment: .leading, spacing: 0) {
                content(
                  ScreenProxy(
                    scrollViewProxy: scrollViewProxy,
                    geometryProxy: geometryProxy
                  )
                )
              }
              .frame(
                maxWidth: .infinity,
                minHeight: geometryProxy.size.height,
                maxHeight: .infinity,
                alignment: .topLeading
              )
//              .background(.red)
            }
            .background(Colors.Material.blueGrey[100])
            .ignoresSafeArea(.keyboard)
          }
        }
        .coordinateSpace(name: "ScreenScrollView")
      }
    }
      .navigationTitle("")
      .navigationBarHidden(true)
  }
  
  init(
    @ViewBuilder content: @escaping (ScreenProxy) -> Content,
    @ViewBuilder header: @escaping () -> Header,
    action: @escaping () -> Void = {}
  ) {
    self.content = content
    self.header = header
    self.action = action
  }
}

struct Previews_Screen: PreviewProvider {
  static var previews: some View {
    Screen { screen in
      Text("Test")
    } header: {
      Text("Kenimo")
    }
  }
}
