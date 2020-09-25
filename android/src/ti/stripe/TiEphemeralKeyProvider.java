package ti.stripe;

import com.stripe.android.EphemeralKeyProvider;
import com.stripe.android.EphemeralKeyUpdateListener;

import org.jetbrains.annotations.NotNull;

public class TiEphemeralKeyProvider implements EphemeralKeyProvider {

    @Override
    public void createEphemeralKey(@NotNull String apiVersion, @NotNull EphemeralKeyUpdateListener ephemeralKeyUpdateListener) {
        // TODO: Add a HTTP request here and use the backend API info (url)
        //       via a module property
        ephemeralKeyUpdateListener.onKeyUpdate("<TEST>");
    }
}