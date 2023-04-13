//
//  Extension + Uicontroller.swift
//  AppleMapsSample
//
//  Created by Lucky on 23/03/23.
//

import UIKit
import Combine

extension UIControl {
  
  final class UIControlSubscription<SubscriberType: Subscriber, Control: UIControl>: Subscription where SubscriberType.Input == Control {
    private var subscriber: SubscriberType?
    private unowned let control: Control
    
    init(subscriber: SubscriberType, control: Control, event: UIControl.Event) {
      self.subscriber = subscriber
      self.control = control
      control.addTarget(self, action: #selector(eventHandler), for: event)
    }
    
    func request(_ demand: Subscribers.Demand) {
      
    }
    
    func cancel() {
      subscriber = nil
    }
    
    @objc private func eventHandler() {
      _ = subscriber?.receive(control)
    }
  }
  
  struct UIControlPublisher<Control: UIControl>: Publisher {
    
    typealias Output = Control
    typealias Failure = Never
    
    private unowned let control: Control
    private let controlEvents: UIControl.Event
    
    init(control: Control, events: UIControl.Event) {
      self.control = control
      self.controlEvents = events
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, S.Failure == UIControlPublisher.Failure, S.Input == UIControlPublisher.Output {
      let subscription = UIControlSubscription(subscriber: subscriber, control: control, event: controlEvents)
      subscriber.receive(subscription: subscription)
    }
  }
}

extension UIButton {
  
  func publisher(for events: UIControl.Event) -> UIControlPublisher<UIButton> {
    return UIControlPublisher(control: self, events: events)
  }
  
  var tap: UIControlPublisher<UIButton> {
    return UIControlPublisher(control: self, events: .touchUpInside)
  }
}

extension UITextField {
  func publisher(for events: UIControl.Event) -> UIControlPublisher<UITextField> {
    return UIControlPublisher(control: self, events: events)
  }
}

extension UISwitch {
  func publisher(for events: UIControl.Event) -> UIControlPublisher<UISwitch> {
    return UIControlPublisher(control: self, events: events)
  }
}

extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping()->()) {
        addAction(UIAction { (action: UIAction) in closure() }, for: controlEvents)
    }
}
