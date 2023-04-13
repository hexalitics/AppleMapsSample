//
//  SceneDelegate.swift
//  AppleMapsSample
//
//  Created by Sadanand Lowanshi on 21/03/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else {
      return
    }
    let mapFeaturesController = MapFeaturesController()
    let navigationController = UINavigationController(rootViewController: mapFeaturesController)
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    
  }

  func sceneWillResignActive(_ scene: UIScene) {
    
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
   
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    
  }
}

