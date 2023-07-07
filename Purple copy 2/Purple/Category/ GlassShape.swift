//
//   GlassShape.swift
//  Purple
//
//  Created by Farhad on 16/05/2023.
//


import SwiftUI
public struct GlassShape: View {
    
    @State private var location: CGPoint = .zero
    @State var isDragging = false
    
    private var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                self.location = value.location
                self.isDragging = true
            }
            .onEnded {_ in self.isDragging = false}
    }
    
    public init() {}
    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.clear
                GlassBackground()
                ZStack {
                    CardView()
                        .overlay(
                            CardOverlayView()
                        )
                        .cornerRadius(16)
                }
                .position(location)
                .animation(.easeOut, value: location)
                .gesture(drag)
                
            }
            .onAppear {
                location = CGPoint(x: proxy.size.width * 0.5, y: proxy.size.height * 0.5)
            }
        }
    }
}

fileprivate
struct GlassBackground: View {
    var body: some View {
        GeometryReader { proxy in
            Circle()
                .fill(LinearGradient(colors: [Color("Icon"),
                                                Color("Text2")],
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing))
                .frame(width: 100, height: 100)
                .position(x: proxy.size.width * 0.3, y: proxy.size.height * 0.65)
            
            Circle()
                .fill(LinearGradient(colors: [Color("Icon"),
                                              Color("Text2")],
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing))
                .frame(width: 100, height: 100)
                .position(x: proxy.size.width * 0.6, y: proxy.size.height * 0.4)
            
            Circle()
                .fill(LinearGradient(colors: [Color("Icon"),
                                              Color("Text2")],
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing))
                .frame(width: 50, height: 50)
                .position(x: proxy.size.width * 0.7, y: proxy.size.height * 0.65)
        }
    }
}

fileprivate
struct CardView: View {
    var body: some View {
        if #available(macOS 12.0, *) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 400, height: 400)
                .background(.ultraThinMaterial)
        } else {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 400, height: 400)
                .background(Color.white.opacity(0.6))
        }
    }
}

fileprivate
struct CardOverlayView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(LinearGradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0), Color.white.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        }
    }
}

struct GlassShape_Previews: PreviewProvider {
    static var previews: some View {
        GlassShape()
    }
}
