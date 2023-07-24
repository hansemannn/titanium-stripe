//
//  TiStripeModule.swift
//  titanium-stripe
//
//  Created by Your Name
//  Copyright (c) 2020 Your Company. All rights reserved.
//

import StripePaymentSheet
import TitaniumKit
import PassKit
import UIKit

@objc(TiStripeModule)
class TiStripeModule: TiModule {
        
  var paymentSheet: PaymentSheet!
  
  func moduleGUID() -> String {
    return "8a8da6b4-4dab-4c18-9439-de2e14457a1c"
  }

  @objc(initialize:)
  func initialize(args: [Any]?) {
    guard let args = args, let params = args.first as? [String: Any] else { return }

    guard let publishableKey = params["publishableKey"] as? String else { return }
    
    STPAPIClient.shared.publishableKey = publishableKey
  }
  
  @objc(showPaymentSheet:)
  func showPaymentSheet(args: [Any]) {
    guard let params = args.first as? [String: Any] else {
      fatalError("Missing parameters when calling showPaymentSheet")
    }

    let callback = params["callback"] as? KrollCallback
    let merchantDisplayName = params["merchantDisplayName"] as? String
    let customerId = params["customerId"] as? String
    let customerEphemeralKeySecret = params["customerEphemeralKeySecret"] as? String
    let paymentIntentClientSecret = params["paymentIntentClientSecret"] as? String
    let appearance = params["appearance"] as? [String: Any]

    guard let customerId, let customerEphemeralKeySecret, let paymentIntentClientSecret, let callback else {
      NSLog("[ERROR] Missing required parameters \"customerId\", \"customerEphemeralKeySecret\" and \"paymentIntentClientSecret\"")
      return
    }
    
    var configuration = PaymentSheet.Configuration()
    
    if let appearance {
      configuration.appearance = mappedAppearance(appearance);
    }
    
    if let merchantDisplayName {
      configuration.merchantDisplayName = merchantDisplayName
    }
    
    configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
    
    configuration.allowsDelayedPaymentMethods = true
    self.paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
    
    self.paymentSheet.present(from: TiApp.controller().topPresentedController()) { result in
      switch result {
      case .completed:
        callback.call([["success": true]], thisObject: self)
      case .canceled:
        callback.call([["cancel": true]], thisObject: self)
      case .failed(let error):
        callback.call([["success": false, "error": error.localizedDescription] as [String : Any]], thisObject: self)
      }
    }
  }
  
  private func mappedAppearance(_ params: [String: Any]) -> PaymentSheet.Appearance {
    var appearance = PaymentSheet.Appearance()
    
    if let colors = params["colors"] as? [String: Any] {
      if let background = colors["background"] {
        appearance.colors.background = TiUtils.colorValue(background).color
      }
      if let text = colors["text"] {
        appearance.colors.text = TiUtils.colorValue(text).color
      }
      if let textSecondary = colors["textSecondary"] {
        appearance.colors.textSecondary = TiUtils.colorValue(textSecondary).color
      }
      if let primary = colors["primary"] {
        appearance.colors.primary = TiUtils.colorValue(primary).color
      }
    }
    
    if let font = params["font"] {
      appearance.font.base = TiUtils.fontValue(font).font()
    }
    
    return appearance
  }
}
