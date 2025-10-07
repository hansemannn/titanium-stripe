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
        NSLog("[ERROR] Missing parameters when calling showPaymentSheet")
        return
      }

      let callback = params["callback"] as? KrollCallback
      let merchantDisplayName = params["merchantDisplayName"] as? String
      let paymentIntentClientSecret = params["paymentIntentClientSecret"] as? String

      // Optional (only if you want saved PMs / returning customers)
      let customerId = params["customerId"] as? String
      let customerEphemeralKeySecret = params["customerEphemeralKeySecret"] as? String

      // Optional Apple Pay
      let merchantId = params["merchantId"] as? String
      let merchantCountryCode = params["merchantCountryCode"] as? String

      guard let callback else {
        NSLog("[ERROR] Missing required parameter \"callback\"")
        return
      }
      guard let paymentIntentClientSecret else {
        NSLog("[ERROR] Missing required parameter \"paymentIntentClientSecret\"")
        callback.call([["success": false, "error": "Missing paymentIntentClientSecret"]], thisObject: self)
        return
      }

      var configuration = PaymentSheet.Configuration()

      // Appearance (optional)
      if let appearanceDict = params["appearance"] as? [String: Any] {
        configuration.appearance = mappedAppearance(appearanceDict)
      }

      if let merchantDisplayName {
        configuration.merchantDisplayName = merchantDisplayName
      }

      // Apple Pay (optional)
      if let merchantId {
        configuration.applePay = .init(
          merchantId: merchantId,
          merchantCountryCode: merchantCountryCode ?? "US"
        )
      }

      // Customer (optional) — only set if both values exist
      if let customerId, let customerEphemeralKeySecret {
        configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
      }

      configuration.allowsDelayedPaymentMethods = true

      // Create and present the sheet (guest or customer — both use the same initializer)
      self.paymentSheet = PaymentSheet(
        paymentIntentClientSecret: paymentIntentClientSecret,
        configuration: configuration
      )

      DispatchQueue.main.async {
        self.paymentSheet.present(from: TiApp.controller().topPresentedController()) { result in
          switch result {
          case .completed:
            callback.call([["success": true]], thisObject: self)
          case .canceled:
            callback.call([["cancel": true]], thisObject: self)
          case .failed(let error):
            callback.call([["success": false, "error": error.localizedDescription]], thisObject: self)
          }
        }
      }
    }

    @objc(isApplePaySupported:)
    func isApplePaySupported(args: [Any]) -> Bool {
        return PKPaymentAuthorizationController.canMakePayments()
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
    
      if let primaryButton = params["primaryButton"] as? [String: Any] {
        if let borderRadius = primaryButton["borderRadius"] as? CGFloat {
          appearance.primaryButton.cornerRadius = borderRadius
        }
        if let borderWidth = primaryButton["borderWidth"] as? CGFloat {
          appearance.primaryButton.borderWidth = borderWidth
        }
        if let borderColor = primaryButton["borderColor"] {
          appearance.primaryButton.borderColor = TiUtils.colorValue(borderColor).color
        }
      }

    
    if let font = params["font"] {
      appearance.font.base = TiUtils.fontValue(font).font()
    }
    
    return appearance
  }
}
