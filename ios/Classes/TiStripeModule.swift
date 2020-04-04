//
//  TiStripeModule.swift
//  titanium-stripe
//
//  Created by Your Name
//  Copyright (c) 2020 Your Company. All rights reserved.
//

import Stripe
import TitaniumKit
import UIKit

@objc(TiStripeModule)
class TiStripeModule: TiModule {
  
  var paymentContext: STPPaymentContext?
  
  var customerContext: STPCustomerContext?
  
  func moduleGUID() -> String {
    return "8a8da6b4-4dab-4c18-9439-de2e14457a1c"
  }

  @objc(initialize:)
  func initialize(args: [Any]?) {
    guard let args = args, let params = args.first as? [String: Any] else { return }

    customerContext = STPCustomerContext(keyProvider: self)
    paymentContext = STPPaymentContext(customerContext: customerContext!)

    guard let publishableKey = params["publishableKey"] as? String, let companyName = params["companyName"] as? String else { return }

    STPPaymentConfiguration.shared().companyName = companyName
    STPAPIClient.shared().publishableKey = publishableKey
    
    if let styles = params["styles"] as? [String: Any] {
      if let primaryBackgroundColor = styles["primaryBackgroundColor"] {
        STPTheme.default().primaryBackgroundColor = TiUtils.colorValue(primaryBackgroundColor)?.color
      }
      if let primaryForegroundColor = styles["primaryForegroundColor"] {
        STPTheme.default().primaryForegroundColor = TiUtils.colorValue(primaryForegroundColor)?.color
      }
      if let secondaryForegroundColor = styles["secondaryForegroundColor"] {
        STPTheme.default().secondaryForegroundColor = TiUtils.colorValue(secondaryForegroundColor)?.color
      }
      if let accentColor = styles["accentColor"] {
        STPTheme.default().accentColor = TiUtils.colorValue(accentColor)?.color
      }
    }

    paymentContext?.delegate = self
    paymentContext?.hostViewController = TiApp().controller.topPresentedController()
  }
  
  @objc(updatePaymentDetails:)
  func updatePaymentDetails(args: [Any]?) {
    guard let args = args, let params = args.first as? [String: Any] else { return }
    
    guard let items = params["items"] as? [[String: Any]],
      let currency = params["currency"] as? String,
      let country = params["country"] as? String else { return }

    paymentContext?.paymentCurrency = currency
    paymentContext?.paymentCountry = country
    paymentContext?.paymentSummaryItems = items.map({
      PKPaymentSummaryItem(label: $0["label"] as! String,
                           amount: NSDecimalNumber(value: $0["amount"] as! Double))
    })
  }

  @objc(showPaymentOptions:)
  func showPaymentOptions(args: [Any]?) {
    paymentContext?.presentPaymentOptionsViewController()
  }
  
  @objc(requestPayment:)
  func requestPayment(args: [Any]?) {
    paymentContext?.requestPayment()
  }
}

extension TiStripeModule: STPCustomerEphemeralKeyProvider {
  func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
    // TODO: Generate ephemeral key online and pass result here
    completion([:], nil)
    
    //
    //    let endpoint = "/api/passengers/me/ephemeral_keys"
    //
    //    guard
    //        !baseURLString.isEmpty,
    //        let baseURL = URL(string: baseURLString),
    //        let url = URL(string: endpoint, relativeTo: baseURL) else {
    //            completion(nil, CustomerKeyError.missingBaseURL)
    //            return
    //    }
    //
    //    let parameters: [String: Any] = ["api_version": apiVersion]
    //
    //    Alamofire.request(url, method: .post, parameters: parameters).responseJSON { (response) in
    //        guard let json = response.result.value as? [AnyHashable: Any] else {
    //            completion(nil, CustomerKeyError.invalidResponse)
    //            return
    //        }
    //
    //        completion(json, nil)
    //    }
  }
  
  
}

// MARK: STPPaymentContextDelegate

extension TiStripeModule : STPPaymentContextDelegate {

  func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
    fireEvent("error", with: ["error": error.localizedDescription])
  }
  
  func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
    fireEvent("contextChange")
  }
  
  func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
    let event = ["stripeId": paymentResult.paymentMethod?.stripeId, "customerId": paymentResult.paymentMethod?.customerId]
    fireEvent("paymentResult", with: event)
  }
  
  func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
    fireEvent("finish", with: ["status": status.rawValue, "error": error?.localizedDescription ?? ""])
  }
}
