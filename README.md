# Titanium Stripe

Use the native Stripe SDK's (iOS/Android) in Titanium!

## Requirements

- [x] Titanium SDK 9.2.0+
- [x] iOS 12+
- [x] Android 5+
- [x] A server to generate the ephemeral key (e.g. with Node.js or PHP)

## Example

See the [app.js](./example/app.js) for a detailed example.

## Apple Pay Support
Follow steps listed here:

https://stripe.com/docs/payments/accept-a-payment?platform=ios&ui=payment-sheet#ios-card-scanning

- [x] Register for an Apple Merchant ID
- [x] Create a new Apple Pay certificate
- [x] Add Entitlements.plist to root with Merchant ID created above
- [x] Enable Apple Pay payment method in Stripe account:

https://dashboard.stripe.com/settings/payment_methods/connected_accounts

## Google Pay Support
Follow steps listed here:

https://stripe.com/docs/payments/accept-a-payment?platform=android&ui=payment-sheet#android-google-pay

Join the Google Pay API Test group to use test cards in the Test Environment:

https://groups.google.com/g/googlepay-test-mode-stub-data/about

- [x] Enable Google Pay payment method in Stripe account:

https://dashboard.stripe.com/settings/payment_methods/connected_accounts


## Author

Hans Knöchel

## License

UNLICENSED 
