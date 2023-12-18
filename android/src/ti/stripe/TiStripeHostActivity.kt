package ti.stripe

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.Window
import android.view.WindowManager
import androidx.activity.ComponentActivity
import com.stripe.android.paymentsheet.PaymentSheet
import com.stripe.android.paymentsheet.PaymentSheetResult

class TiStripeHostActivity : ComponentActivity() {
    private lateinit var paymentSheet: PaymentSheet

    private lateinit var params: HashMap<*, *>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Configure activity layout (in addition to the style)
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        window.setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        title = ""

        params = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getSerializableExtra("params", HashMap::class.java)!!
        } else {
            intent.getSerializableExtra("params") as HashMap<*, *>
        }

        paymentSheet = PaymentSheet(this, ::onPaymentSheetResult)

        val merchantDisplayName: String = params["merchantDisplayName"] as String
        val customerId: String = params["customerId"] as String
        val customerEphemeralKeySecret: String = params["customerEphemeralKeySecret"] as String
        val paymentIntentClientSecret: String = params["paymentIntentClientSecret"] as String
        val appearance: HashMap<*, *>? = params["appearance"] as? HashMap<*, *>
        val merchantCountryCode: String = params["merchantCountryCode"] as String
        val googlePayTest: Boolean? = params["googlePayTest"] as? Boolean

        val customerConfig = PaymentSheet.CustomerConfiguration(
            customerId,
            customerEphemeralKeySecret
        )

        val googlePayConfiguration = PaymentSheet.GooglePayConfiguration(
            environment = when (googlePayTest) {
                true -> PaymentSheet.GooglePayConfiguration.Environment.Test
                false -> PaymentSheet.GooglePayConfiguration.Environment.Production
                null -> PaymentSheet.GooglePayConfiguration.Environment.Production
            },
            countryCode = merchantCountryCode
        )

        val configuration = PaymentSheet.Configuration.Builder(merchantDisplayName)
            .customer(customerConfig)
            .allowsDelayedPaymentMethods(true)
            .googlePay(googlePayConfiguration)

        appearance?.let {
            configuration.appearance(mappedAppearance(it))
        }

        paymentSheet.presentWithPaymentIntent(
            paymentIntentClientSecret,
            configuration.build()
        )
    }

    private fun onPaymentSheetResult(paymentSheetResult: PaymentSheetResult) {
        when(paymentSheetResult) {
            is PaymentSheetResult.Canceled -> {
                print("Canceled")

                val intent = Intent()
                intent.putExtra("cancel", true)
                setResult(RESULT_CANCELED, intent)
            }
            is PaymentSheetResult.Failed -> {
                print("Error: ${paymentSheetResult.error}")

                val intent = Intent()
                intent.putExtra("success", false)
                intent.putExtra("error", paymentSheetResult.error.message)
                setResult(RESULT_CANCELED, intent)
            }
            is PaymentSheetResult.Completed -> {
                // Display for example, an order confirmation screen
                print("Completed")

                val intent = Intent()
                intent.putExtra("success", true)
                setResult(RESULT_OK, intent)
            }
        }

        finish()
    }

    private fun mappedAppearance(params: HashMap<*, *>): PaymentSheet.Appearance {
        val appearance = PaymentSheet.Appearance()
        val colors = params["colors"] as? HashMap<*, *>
        val font = params["font"] as? HashMap<*, *>

        if (colors != null) {
            // TODO
        }
        if (font != null) {
            // TODO
        }
        return appearance
    }
}