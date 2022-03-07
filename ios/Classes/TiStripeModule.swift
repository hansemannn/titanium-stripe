//
//  TiStripeModule.swift
//  titanium-stripe
//
//  Created by Your Name
//  Copyright (c) 2020 Your Company. All rights reserved.
//

import Stripe
import TitaniumKit
import PassKit
import UIKit

@objc(TiStripeModule)
class TiStripeModule: TiModule {
  
  var paymentContext: STPPaymentContext?
  
  var customerContext: STPCustomerContext?
  
  var ephemeralKeyAPIURL: String?
  
  func moduleGUID() -> String {
    return "8a8da6b4-4dab-4c18-9439-de2e14457a1c"
  }

  @objc(initialize:)
  func initialize(args: [Any]?) {
    guard let args = args, let params = args.first as? [String: Any] else { return }

    guard let publishableKey = params["publishableKey"] as? String, let companyName = params["companyName"] as? String else { return }
    
    ephemeralKeyAPIURL = params["ephemeralKeyAPIURL"] as? String

    STPPaymentConfiguration.shared.companyName = companyName
    STPAPIClient.shared.publishableKey = publishableKey

    customerContext = STPCustomerContext(keyProvider: self)
    paymentContext = STPPaymentContext(customerContext: customerContext!)
    
    if let styles = params["styles"] as? [String: Any] {
      if let primaryBackgroundColor = styles["primaryBackgroundColor"] {
        STPTheme.defaultTheme.primaryBackgroundColor = TiUtils.colorValue(primaryBackgroundColor)!.color
      }
      if let primaryForegroundColor = styles["primaryForegroundColor"] {
        STPTheme.defaultTheme.primaryForegroundColor = TiUtils.colorValue(primaryForegroundColor)!.color
      }
      if let secondaryForegroundColor = styles["secondaryForegroundColor"] {
        STPTheme.defaultTheme.secondaryForegroundColor = TiUtils.colorValue(secondaryForegroundColor)!.color
      }
      if let accentColor = styles["accentColor"] {
        STPTheme.defaultTheme.accentColor = TiUtils.colorValue(accentColor)!.color
      }
    }

    paymentContext?.delegate = self
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
    paymentContext?.hostViewController = UIApplication.shared.keyWindow?.rootViewController
    paymentContext?.presentPaymentOptionsViewController()
  }
  
  @objc(requestPayment:)
  func requestPayment(args: [Any]?) {
    paymentContext?.requestPayment()
  }
}

extension TiStripeModule: STPCustomerEphemeralKeyProvider {

  func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
    var urlRequest = URLRequest(url: URL(string: ephemeralKeyAPIURL!)!)
    urlRequest.httpMethod = "POST"
    urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: ["api_version": apiVersion], options: .fragmentsAllowed)

    let session = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
      guard let data = data, error == nil else {
        completion(nil, error)
        return
      }
      guard let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyHashable: Any] else {
        completion(nil, error)
        return
      }
      completion(json, nil)
    }
    session.resume()
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
