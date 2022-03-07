var Stripe = require('ti.stripe');

var win = Ti.UI.createWindow({
    backgroundColor: '#fff',
    layout: 'vertical'
});

win.addEventListener('open', initialize);
win.open();

addButton('Show payment options', showPaymentOptions);
addButton('Request payment', requestPayment);

function initialize() {
    Stripe.initialize({
        ephemeralKeyAPIURL: 'YOUR_EPHEMERAL_KEY_POST_API_URL',
        publishableKey: 'YOUR_PUBLISHABLE_KEY',
        companyName: 'YOUR_COMPANY_NAME',
        styles: {
            primaryBackgroundColor: 'white',
            primaryForegroundColor: 'black',
            secondaryForegroundColor: 'gray',
            accentColor: 'blue'
        }
    });

    updatePaymentDetails();
}

function updatePaymentDetails() {
    Stripe.updatePaymentDetails({
        currency: 'USD',
        country: 'US',
        items: [{
            label: 'Apples & Oranges',
            amount: 6.50
        }, {
            label: 'Beer & Fuse',
            amount: 9.99
        }]
    });
}

function showPaymentOptions() {
    Stripe.showPaymentOptions();
}

function requestPayment() {
    Stripe.requestPayment();
}

function addButton(title, action) {
    var button = Ti.UI.createButton({ top: 75, title });
    button.addEventListener('click', action);

    win.add(button);
}
