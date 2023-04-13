//
//  LookAroundView.swift
//  AppleMapsSample
//
//  Created by Lucky on 10/04/23.
//


import SwiftUI
import MapKit

@available(iOS 16.0, *)
struct LookAroundView: UIViewControllerRepresentable {
  typealias UIViewControllerType = MKLookAroundViewController
  
  @Binding var tappedLocation: CLLocationCoordinate2D?
  @Binding var showLookAroundView: Bool
  
  
  func makeUIViewController(context: Context) -> MKLookAroundViewController {
    return MKLookAroundViewController()
  }
  
  @available(iOS 16.0, *)
  func updateUIViewController(_ uiViewController: MKLookAroundViewController, context: Context) {
    if let tappedLocation {
      Task {
        let scene = await getScene(tappedLocation: .init(latitude: tappedLocation.latitude, longitude: tappedLocation.longitude))
        
        if scene == nil {
          withAnimation {
            self.showLookAroundView = false
          }
          return
        }
        
        withAnimation {
          self.showLookAroundView = true
        }
        
        uiViewController.scene = scene
      }
    }
  }
  
  @available(iOS 16.0, *)
  func getScene(tappedLocation: CLLocationCoordinate2D?) async -> MKLookAroundScene? {
    if let latitude = tappedLocation?.latitude, let longitude = tappedLocation?.longitude {
      let sceneRequest = MKLookAroundSceneRequest(coordinate: .init(latitude: latitude, longitude: longitude))
      
      do {
        return try await sceneRequest.scene
      } catch {
        return nil
      }
    } else {
      return nil
    }
  }
}
