/*
 *  oxPush2 is available under the MIT License (2008). See http://opensource.org/licenses/MIT for full text.
 *
 *  Copyright (c) 2014, Gluu
 */

package org.gluu.super_gluu.app.fragment;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Bundle;
import android.os.Vibrator;
import android.support.v4.app.Fragment;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.CardView;
import android.util.Log;
import android.util.Pair;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.TextView;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.InterstitialAd;
import com.google.android.gms.ads.MobileAds;
import com.google.gson.Gson;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;

import org.gluu.super_gluu.app.ProcessManager;
import org.gluu.super_gluu.app.activities.CustomBarcodeScannerActivity;
import org.gluu.super_gluu.app.activities.MainNavDrawerActivity;
import org.gluu.super_gluu.app.customview.CustomAlert;
import org.gluu.super_gluu.app.customview.CustomToast;
import org.gluu.super_gluu.app.listener.OxPush2RequestListener;
import org.gluu.super_gluu.app.services.FingerPrintManager;
import org.gluu.super_gluu.app.settings.Settings;
import org.gluu.super_gluu.model.OxPush2Request;
import org.gluu.super_gluu.store.AndroidKeyDataStore;
import org.gluu.super_gluu.u2f.v2.SoftwareDevice;
import org.gluu.super_gluu.u2f.v2.exception.U2FException;
import org.gluu.super_gluu.u2f.v2.model.TokenResponse;
import org.gluu.super_gluu.u2f.v2.store.DataStore;
import org.json.JSONException;

import java.io.IOException;

import SuperGluu.app.BuildConfig;
import SuperGluu.app.R;
import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Main activity fragment
 *
 * Created by Yuriy Movchan on 12/28/2015.
 */
public class HomeFragment extends Fragment implements TextView.OnEditorActionListener {

    private static final String TAG = "main-activity-fragment";

    private OxPush2RequestListener oxPush2RequestListener;

    private Context context;

    private InterstitialAd mInterstitialAd;

    @BindView(R.id.button_scan)
    Button scanButton;

    @BindView(R.id.adView)
    AdView adView;

    @BindView(R.id.remove_ad_card_view)
    CardView removeAdView;

    @BindView(R.id.button_remove_ads)
    Button removeAdsButton;

    @BindView(R.id.welcome_text_view)
    TextView welcomeTextView;
    @BindView(R.id.description_text_view)
    TextView descriptionTextView;

    private SoftwareDevice u2f;
    private AndroidKeyDataStore dataStore;

    private BroadcastReceiver adBroadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {

            boolean isAdFree = intent.getBooleanExtra("isAdFree", false);

            if (context != null) {
                handleAdBroadcastIntent(isAdFree);
            }
        }
    };

    private BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            // Get extra data included in the Intent
            String message = intent.getStringExtra("message");
            if (context != null && !message.isEmpty()) {
                showDialog(message);
            }
            Boolean isAdFree = Settings.getPurchase(context);
            if (mInterstitialAd.isLoaded() && !isAdFree) {
                if (mInterstitialAd == null){
                    initGoogleInterstitialAd();
                }
                mInterstitialAd.show();
            }
        }
    };

    private BroadcastReceiver mPushMessageReceiver = new BroadcastReceiver() {
        @SuppressLint("NewApi")
        @Override
        public void onReceive(Context context, Intent intent) {
            if (!getActivity().isDestroyed()) {
                // Get extra data included in the Intent
                String message = intent.getStringExtra(MainNavDrawerActivity.QR_CODE_PUSH_NOTIFICATION_MESSAGE);
                final OxPush2Request oxPush2Request = new Gson().fromJson(message, OxPush2Request.class);
                onQrRequest(oxPush2Request);
                //play sound and vibrate
                try {
                    Uri notification = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
                    Ringtone r = RingtoneManager.getRingtone(context, notification);
                    r.play();
                } catch (Exception e) {
                    e.printStackTrace();
                }
                ((Vibrator)getActivity().getSystemService(Context.VIBRATOR_SERVICE)).vibrate(800);
            }
        }
    };

    private BroadcastReceiver onAdFree = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            runSubscribeFlow();
        }
    };

    private BroadcastReceiver onRestorePurchase = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            runRestorePurchaseFlow();
        }
    };

    public HomeFragment() {}

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_home, container, false);

        ButterKnife.bind(this, view);

        context = view.getContext();
        this.dataStore = new AndroidKeyDataStore(context);
        this.u2f = new SoftwareDevice(getActivity(), dataStore);

        scanButton.setOnClickListener(scanView -> submit());
        removeAdsButton.setOnClickListener(buttonView -> runSubscribeFlow());

        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(onAdFree,
                new IntentFilter("on-ad-free-flow"));
        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(onRestorePurchase,
                new IntentFilter("on-restore-purchase-flow"));

        setupBannerAd();

        //Init GoogleMobile AD
        initGoogleInterstitialAd();

        return view;
    }

    private void setupBannerAd() {
        if(Settings.getPurchase(getContext()) || !getResources().getBoolean(R.bool.adsEnabled)) {
            adView.setVisibility(View.GONE);
            removeAdView.setVisibility(View.GONE);
        } else {
            MobileAds.initialize(getActivity().getApplicationContext(), "ca-app-pub-3932761366188106~2301594871");
            AdRequest adRequest = new AdRequest.Builder().build();
            adView.loadAd(adRequest);
        }
    }

    @Override
    public void onResume() {
        super.onResume();

        if (!isConnected(context)) {
            scanButton.setEnabled(false);
        } else {
            scanButton.setEnabled(true);
        }
        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(mMessageReceiver,
                new IntentFilter("ox_request-precess-event"));

        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(adBroadcastReceiver,
                new IntentFilter("on-ad-free-event"));

        //Check push data
        checkIsPush();

        if(adView != null) {
            adView.resume();
        }
    }

    @Override
    public void onPause() {
        if(adView != null) {
            adView.pause();
        }
        super.onPause();
    }

    @Override
    public void onStop() {
        super.onStop();
        LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(mPushMessageReceiver);
        LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(mMessageReceiver);
        LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(adBroadcastReceiver);
    }

    @Override
    public void onDestroy() {
        if(adView != null) {
            adView.destroy();
        }
        super.onDestroy();
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OxPush2RequestListener) {
            oxPush2RequestListener = (OxPush2RequestListener) context;
        } else {
            throw new RuntimeException(context.toString() + " must implement OnFragmentInteractionListener");
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);


        switch (requestCode) {
            case IntentIntegrator.REQUEST_CODE:
                if (resultCode == Activity.RESULT_OK) {
                    // Parsing bar code reader result
                    IntentResult result = IntentIntegrator.parseActivityResult(requestCode, resultCode, data);
                    if (BuildConfig.DEBUG) Log.d(TAG, "Parsing QR code result: " + result.toString());
                    OxPush2Request oxPush2Request = null;
                    try {
                        oxPush2Request = new Gson().fromJson(result.getContents(), OxPush2Request.class);
                    }
                    catch (Exception ex){
                        //skip exception there
                    }
                    onQrRequest(oxPush2Request);
                }
                if (resultCode == Activity.RESULT_CANCELED) {
                    showToastWithText(context.getString(R.string.canceled_process_qr_code));
                }
                break;
        }
    }

    @Override
    public boolean onEditorAction(TextView view, int actionId, KeyEvent event) {
        if (actionId == EditorInfo.IME_ACTION_GO) {
            submit();
            return true;
        }

        return false;
    }

    private void runSubscribeFlow(){
        if (oxPush2RequestListener != null) {
            oxPush2RequestListener.onAdFreeButtonClick();
        }
    }

    private void runRestorePurchaseFlow(){
        if (oxPush2RequestListener != null) {
            oxPush2RequestListener.onPurchaseRestored();
        }
    }

    private void initGoogleInterstitialAd(){
        if(getResources().getBoolean(R.bool.adsEnabled)) {
            mInterstitialAd = new InterstitialAd(context);
            //todo this should be a build flavor attribute
            mInterstitialAd.setAdUnitId("ca-app-pub-3326465223655655/1731023230");

            mInterstitialAd.setAdListener(new AdListener() {

                @Override
                public void onAdOpened() {
                    // Code to be executed when the ad is displayed.
                    Log.i("Ads", "onAdOpened");
                }

                @Override
                public void onAdClosed() {
                    // Load the next interstitial.
                    mInterstitialAd.loadAd(new AdRequest.Builder().build());
                }
            });
            requestNewInterstitial();
        }
    }

    private void requestNewInterstitial() {
        AdRequest adRequest = new AdRequest.Builder()
                .addTestDevice(AdRequest.DEVICE_ID_EMULATOR)
                .build();

        mInterstitialAd.loadAd(adRequest);
    }

    private void onQrRequest(OxPush2Request oxPush2Request){
        if (oxPush2Request == null){
            showToastWithText("You scanned wrong QR code");
        } else {
            oxPush2RequestListener.onQrRequest(oxPush2Request);
        }
    }

    private void showToastWithText(String text){
        CustomToast customToast = new CustomToast(context);
        LayoutInflater layoutInflater = getLayoutInflater();
        if(layoutInflater != null) {
            View view = getLayoutInflater().inflate(R.layout.custom_toast, null);
            customToast.showGluuToastWithText(view, text);
        }
    }

    private void submit() {
        IntentIntegrator integrator = IntentIntegrator.forSupportFragment(this);
        integrator.setDesiredBarcodeFormats(IntentIntegrator.QR_CODE_TYPES);
        integrator.setCaptureActivity(CustomBarcodeScannerActivity.class);
        integrator.initiateScan();
    }


    private void showDialog(String message){
        Log.i("boogie", message);

        Activity activity = getActivity();
        Pair<String, String> titleMessageText = getTitleBasedOnMessage(message);

        final CustomAlert gluuAlert = new CustomAlert(activity);
        gluuAlert.setHeader(titleMessageText.first);
        gluuAlert.setMessage(titleMessageText.second);
        gluuAlert.setPositiveText(getString(R.string.ok));
        gluuAlert.setListener(new MainNavDrawerActivity.GluuAlertCallback() {
            @Override
            public void onPositiveButton() {
                //Skip here
            }

            @Override
            public void onNegativeButton() {
                //Skip here
            }
        });
        gluuAlert.show();
    }


    private Pair<String, String> getTitleBasedOnMessage(String message) {

        switch (message) {
            case Constant.AUTH_SUCCESS:
                return new Pair<>(getString(R.string.success), getString(R.string.auth_result_success));
            case Constant.AUTH_FAILURE:
            case Constant.AUTHENTICATED_FAILED_OTHER:
                return new Pair<>(getString(R.string.failed), getString(R.string.deny_result_success));
            case Constant.ENROLLMENT_SUCCESS:
                return new Pair<>(getString(R.string.enroll_result_title), message);
            case Constant.FIDO_U2F_INVALID:
                return new Pair<>(getString(R.string.fido_failure), message);
            case Constant.CHALLENGE:
                return new Pair<>(getString(R.string.challenge), message);
            case Constant.DECLINE_FAILED:
                return new Pair<>(getString(R.string.decline), message);
            default:
                return new Pair<>(getString(R.string.generic_auth_result), message);
        }
    }

    public void checkIsPush(){
        final SharedPreferences preferences = context.getSharedPreferences("oxPushSettings", Context.MODE_PRIVATE);
        final String requestString = preferences.getString("oxRequest", "null");
        if (!requestString.equalsIgnoreCase("null")) {
            //First need to check is app protected by Fingerprint
            Boolean isFingerprint = Settings.getFingerprintEnabled(context);
            if (isFingerprint){
                FingerPrintManager fingerPrintManager = new FingerPrintManager((AppCompatActivity) getActivity());
                fingerPrintManager.onFingerPrint(new FingerPrintManager.FingerPrintManagerCallback() {
                    @Override
                    public void fingerprintResult(Boolean isSuccess) {
                        makeOxRequest(preferences, requestString);
                    }
                });
            } else {
                makeOxRequest(preferences, requestString);
            }
        }
    }

    private void makeOxRequest(SharedPreferences preferences, String requestString){
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("oxRequest", null);
        editor.apply();
        Settings.setPushDataEmpty(getContext());
        final OxPush2Request oxPush2Request = new Gson().fromJson(requestString, OxPush2Request.class);
        final ProcessManager processManager = createProcessManager(oxPush2Request);
        if (preferences.getString("userChoose", "null").equalsIgnoreCase("deny")) {
            showToastWithText(context.getString(R.string.process_deny_start));
            processManager.onOxPushRequest(true);
            return;
        }
        if (preferences.getString("userChoose", "null").equalsIgnoreCase("approve")) {
            showToastWithText(context.getString(R.string.process_authentication_start));
            processManager.onOxPushRequest(false);
            return;
        }
    }

    private ProcessManager createProcessManager(OxPush2Request oxPush2Request){
        ProcessManager processManager = new ProcessManager();
        processManager.setOxPush2Request(oxPush2Request);
        processManager.setDataStore(dataStore);
        processManager.setActivity(getActivity());
        processManager.setOxPush2RequestListener(new OxPush2RequestListener() {
            @Override
            public void onQrRequest(OxPush2Request oxPush2Request) {
                //skip code there
            }

            @Override
            public TokenResponse onSign(String jsonRequest, String origin, Boolean isDeny) throws JSONException, IOException, U2FException {
                return u2f.sign(jsonRequest, origin, isDeny);
            }

            @Override
            public TokenResponse onEnroll(String jsonRequest, OxPush2Request oxPush2Request, Boolean isDeny) throws JSONException, IOException, U2FException {
                return u2f.enroll(jsonRequest, oxPush2Request, isDeny);
            }

            @Override
            public DataStore onGetDataStore() {
                return dataStore;
            }

            @Override
            public void onAdFreeButtonClick(){}

            @Override
            public void onPurchaseRestored() {}
        });

        return processManager;
    }

    private static boolean isConnected(final Context context) {
        ConnectivityManager cm =
                (ConnectivityManager)context.getSystemService(Context.CONNECTIVITY_SERVICE);

        NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        boolean isConnected = activeNetwork != null &&
                activeNetwork.isConnectedOrConnecting();
        return isConnected;
    }

    private void handleAdBroadcastIntent(Boolean isAdFree){
        if (isAdFree) {
            removeAdView.setVisibility(View.GONE);
            adView.setVisibility(View.GONE);
        }
    }

    private class Constant {
        private static final String AUTH_SUCCESS = "You have successfully authenticated!";
        private static final String AUTH_FAILURE = "The authentication request has been denied or failed.";
        private static final String ENROLLMENT_SUCCESS = "Your enrollment was successful!";
        private static final String FIDO_U2F_INVALID = "Fido U2F token response is invalid";
        private static final String CHALLENGE = "Challenges doesn\'t match";
        private static final String DECLINE_FAILED = "Decline Failed";
        private static final String AUTHENTICATED_FAILED_OTHER = "Authentication failed!";
    }

}
