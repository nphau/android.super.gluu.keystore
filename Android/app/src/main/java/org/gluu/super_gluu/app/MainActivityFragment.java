/*
 *  oxPush2 is available under the MIT License (2008). See http://opensource.org/licenses/MIT for full text.
 *
 *  Copyright (c) 2014, Gluu
 */

package org.gluu.super_gluu.app;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Vibrator;
import android.support.v4.app.Fragment;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.TextView;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.InterstitialAd;
import com.google.gson.Gson;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;

import org.gluu.super_gluu.app.gluuToast.GluuToast;
import org.gluu.super_gluu.app.listener.OxPush2RequestListener;
import org.gluu.super_gluu.model.OxPush2Request;

import SuperGluu.app.BuildConfig;
import SuperGluu.app.R;

/**
 * Main activity fragment
 *
 * Created by Yuriy Movchan on 12/28/2015.
 */
public class MainActivityFragment extends Fragment implements TextView.OnEditorActionListener, View.OnClickListener {

    private static final String TAG = "main-activity-fragment";

    private OxPush2RequestListener oxPush2RequestListener;

    private LayoutInflater inflater;

    private Context context;

    private InterstitialAd mInterstitialAd;

    private BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            // Get extra data included in the Intent
            String message = intent.getStringExtra("message");
            if (context != null) {
                showToastWithText(message);
            }
        }
    };

    private BroadcastReceiver mPushMessageReceiver = new BroadcastReceiver() {
        @SuppressLint("NewApi")
        @Override
        public void onReceive(Context context, Intent intent) {
            if (!getActivity().isDestroyed()) {
                // Get extra data included in the Intent
                String message = intent.getStringExtra(GluuMainActivity.QR_CODE_PUSH_NOTIFICATION_MESSAGE);
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

    public MainActivityFragment() {}

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_main, container, false);
        this.inflater = inflater;
        view.findViewById(R.id.button_scan).setOnClickListener(this);
        //Setup message receiver
        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(mMessageReceiver,
                new IntentFilter("ox_request-precess-event"));
//        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(mPushMessageReceiver,
//                new IntentFilter(GluuMainActivity.QR_CODE_PUSH_NOTIFICATION));
        context = view.getContext();
        //Init GoogleMobile AD
        initGoogleInterstitialAd();
        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    @Override
    public void onStop() {
        super.onStop();
        LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(mPushMessageReceiver);
        LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(mMessageReceiver);
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
    public void onDetach() {
        super.onDetach();
//        oxPush2RequestListener = null;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

//        Toast.makeText(getActivity(), R.string.process_qr_code, Toast.LENGTH_SHORT).show();

        switch (requestCode) {
            case IntentIntegrator.REQUEST_CODE:
                if (resultCode == Activity.RESULT_OK) {
//                    showToastWithText(context.getString(R.string.process_qr_code));
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
    public void onClick(View v) {
        submit();
    }

    @Override
    public boolean onEditorAction(TextView view, int actionId, KeyEvent event) {
        if (actionId == EditorInfo.IME_ACTION_GO) {
            submit();
            return true;
        }

        return false;
    }

    private void initGoogleInterstitialAd(){
        mInterstitialAd = new InterstitialAd(context);
        mInterstitialAd.setAdUnitId("ca-app-pub-3326465223655655/1731023230");

        mInterstitialAd.setAdListener(new AdListener() {
            @Override
            public void onAdClosed() {
                requestNewInterstitial();
            }
        });
        requestNewInterstitial();
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
        GluuToast gluuToast = new GluuToast(context);
        View view = inflater.inflate(R.layout.gluu_toast, null);
        gluuToast.showGluuToastWithText(view, text);
        if (mInterstitialAd.isLoaded()) {
            mInterstitialAd.show();
        }
    }

    private void submit() {
        if (oxPush2RequestListener != null) {
//            String message = "{\"req_ip\":\"178.136.126.205\",\"app\":\"https://ce-release.gluu.org/identity/authentication/authcode\",\"username\":\"nazar2017\",\"method\":\"authenticate\",\"req_loc\":\"Ukraine%2C%20L%27vivs%27ka%20Oblast%27%2C%20Lviv\",\"state\":\"cd98df91-3b71-4911-9a15-84253c326c7c\",\"created\":\"2016-05-10T09:19:46.260000\",\"issuer\":\"https://ce-release.gluu.org\"}";
//            OxPush2Request oxPush2Request = null;
//            try {
//                oxPush2Request = new Gson().fromJson(message, OxPush2Request.class);
//            }
//            catch (Exception ex){
//                //skip exception there
//            }
//            onQrRequest(oxPush2Request);
            IntentIntegrator integrator = IntentIntegrator.forSupportFragment(this);
            integrator.setDesiredBarcodeFormats(IntentIntegrator.QR_CODE_TYPES);
            integrator.setPrompt(getString(R.string.scan_oxpush2_prompt));
            integrator.initiateScan();
        }
    }

}
