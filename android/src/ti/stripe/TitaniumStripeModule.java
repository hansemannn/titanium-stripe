/**
 * This file was auto-generated by the Titanium Module SDK helper for Android
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2018 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package ti.stripe;

import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.annotations.Kroll;

import org.appcelerator.titanium.TiApplication;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.kroll.common.TiConfig;

import com.stripe.android.PaymentConfiguration;
import com.stripe.android.EphemeralKeyProvider;

@Kroll.module(name="TitaniumStripe", id="ti.stripe")
public class TitaniumStripeModule extends KrollModule {/* implements EphemeralKeyProvider {*/

	// Standard Debugging variables
	private static final String LCAT = "TitaniumStripeModule";
	private static final boolean DBG = TiConfig.LOGD;

	private String ephemeralKeyAPIURL = "";

	@Kroll.method
	public void initialize(KrollDict params) {
		String publishableKey = params.getString("publishableKey");
		ephemeralKeyAPIURL = params.getString("ephemeralKeyAPIURL");
		PaymentConfiguration.init(TiApplication.getInstance().getApplicationContext(), publishableKey);
	}
/*
	@Override
    public void createEphemeralKey(
            @NonNull @Size(min = 4) String apiVersion,
            @NonNull final EphemeralKeyUpdateListener keyUpdateListener) {
	// RequestQueue queue = Volley.newRequestQueue(this);
	
		// StringRequest stringRequest = new StringRequest(Request.Method.POST, ephemeralKeyAPIURL,
		// 		new Response.Listener<String>() {
		// 			@Override
		// 			public void onResponse(String response) {
		// 				keyUpdateListener.onKeyUpdate(response);	
		// 			}
		// 		}, new Response.ErrorListener() {
		// 	@Override
		// 	public void onErrorResponse(VolleyError error) {
		// 		keyUpdateListener.onKeyUpdate(null);	
		// 	}
		// }){
		// 	@Override
		// 	public byte[] getBody() throws AuthFailureError {
		// 		ObjectMapper objectMapper = new ObjectMapper();
		// 		final Map<String, String> apiParamMap = new HashMap<>();
		// 		apiParamMap.put("api_version", apiVersion);
		// 		String json = objectMapper.writeValueAsString(elements);
		
		// 		return json.getBytes();
		// 	}
		// };
		// // Add the request to the RequestQueue.
		// queue.add(stringRequest);
		// requestQueue.start();
	}
	*/
}

