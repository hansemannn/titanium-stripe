var Stripe = require('ti.stripe');

var win = Ti.UI.createWindow({
    backgroundColor: '#fff',
    layout: 'vertical'
});

win.addEventListener('open', initialize);
win.open();

addButton('Update payment details', updatePaymentDetails);
addButton('Show payment options', showPaymentOptions);
addButton('Request payment', requestPayment);

function initialize() {
    Stripe.initialize({
        publishableKey: 'YOUR_PUBLISHABLE_KEY',
        companyName: 'YOUR_COMPANY_NAME',
        styles: {
            primaryBackgroundColor: 'red',
            primaryForegroundColor: 'blue',
            secondaryForegroundColor: 'yellow',
            accentColor: 'green'
        }
    });
}

function updatePaymentDetails() {
    Stripe.updatePaymentDetails({
        currency: 'EUR',
        country: 'DE',
        items: [{
            label: 'Item 1',
            amount: 12.50
        }, {
            label: 'Ite, 2',
            amount: 0.49
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
    var button = Ti.UI.createButton({ top: 100, title });
    button.addEventListener('click', action);

    return button;
}