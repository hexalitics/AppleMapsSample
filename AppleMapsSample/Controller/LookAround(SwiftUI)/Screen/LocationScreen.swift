//
//  LocationScreen.swift
//  AppleMapsSample
//
//  Created by Lucky on 10/04/23.
//

import SwiftUI
import MapKit

@available(iOS 16.0, *)
struct LocationScreen: View {
  
  @State var tappedLocation: CLLocationCoordinate2D?
  @State var showLookAroundView: Bool = false
  
  @State private var lookAroundViewLocation: CGPoint = .zero
  
  var body: some View {
    GeometryReader { geo in
      ZStack {
        Color.white.onAppear {
          self.lookAroundViewLocation = .init(x: 150, y: geo.size.height - 100)
        }
        MapView(tappedLocation: $tappedLocation)
        LookAroundView(
          tappedLocation: $tappedLocation,
          showLookAroundView: $showLookAroundView
        )
        .frame(width: 250, height: 150)
        .cornerRadius(10)
        .position(lookAroundViewLocation)
        .gesture(dragGesture)
        .opacity(showLookAroundView ? 1 : 0)
      }
      .navigationTitle("Look Around")
    }.ignoresSafeArea(edges: .bottom)
  }
  
  var dragGesture: some Gesture {
    DragGesture()
      .onChanged { value in
        self.lookAroundViewLocation = value.location
      }
  }
}
