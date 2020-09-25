package ti.stripe;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import com.stripe.android.PaymentSession;
import com.stripe.android.PaymentSessionConfig;
import com.stripe.android.PaymentSessionData;
import com.stripe.android.model.PaymentMethod;
import com.stripe.android.model.ShippingInformation;

public class TiHostActivity extends Activity {
    private PaymentSession paymentSession;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // This currently does not work?!
        /*paymentSession = new PaymentSession(
                this,
                new PaymentSessionConfig.Builder()
                        .setShouldPrefetchCustomer(true)
                        .setShippingInfoRequired(false)
                        .setShippingMethodsRequired(false)
                        .build()
        );*/
        setupPaymentSession();
    }

    private void setupPaymentSession() {
        paymentSession.init(
                new PaymentSession.PaymentSessionListener() {
                    @Override
                    public void onCommunicatingStateChanged(boolean isCommunicating) {
                        // update UI, such as hiding or showing a progress bar
                    }

                    @Override
                    public void onError(int errorCode, String errorMessage) {
                        // handle error
                    }

                    @Override
                    public void onPaymentSessionDataChanged(PaymentSessionData data) {
                        final PaymentMethod paymentMethod = data.getPaymentMethod();
                        // use paymentMethod
                    }
                }
        );
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (data != null) {
            paymentSession.handlePaymentData(requestCode, resultCode, data);
        }
    }

    private ShippingInformation getDefaultShippingInfo() {
        // optionally specify default shipping address
        return new ShippingInformation();
    }
}