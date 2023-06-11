import Stripe from 'ti.stripe';

const win = Ti.UI.createWindow({
    backgroundColor: '#fff',
});

let credentials = {};

win.addEventListener('open', () => initialize());

const button = Ti.UI.createButton({ title: 'Show payment sheet', enabled: false });
button.addEventListener('click', () => action());

win.add(button);
win.open();

async function initialize() {
    credentials = await getCredentials();

    Stripe.initialize({
        publishableKey: credentials.publishableKey
    });
}

function action() {
    Stripe.showPaymentSheet({
        callback: event => {
            console.warn(event);
        },
        merchantDisplayName: 'Test',
        customerEphemeralKeySecret: credentials.ephemeralKey,
        paymentIntentClientSecret: credentials.paymentIntent,
        customerId: credentials.customer,
        // appearance: {
        //     font: {
        //         fontFamily: 'PT Mono',
        //         fontSize: 20
        //     },
        //     colors: {
        //         background: 'red',
        //         text: 'blue',
        //         textSecondary: 'green',
        //         primary: 'yellow'
        //     }
        // }
    });
}

function getCredentials() {
    return new Promise((resolve, reject) => {
        const httpCLient = Ti.Network.createHTTPClient({
            onload: function() {
                const json = JSON.parse(this.responseText);
                button.enabled = true;
                resolve(json);
            },
            onerror: err => console.error(err)
        });
        httpCLient.open('POST', 'https://stripe-mobile-payment-sheet.glitch.me/checkout');
        httpCLient.send()
    });
}