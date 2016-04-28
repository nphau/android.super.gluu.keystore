/*
 *  oxPush2 is available under the MIT License (2008). See http://opensource.org/licenses/MIT for full text.
 *
 *  Copyright (c) 2014, Gluu
 */

package org.gluu.oxpush2.app;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.TextView;
import android.widget.Toast;

import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;

import org.gluu.oxpush2.app.GluuToast.GluuToast;
import org.gluu.oxpush2.app.listener.OxPush2RequestListener;
import org.gluu.oxpush2.app.model.LogInfo;
import org.gluu.oxpush2.store.AndroidKeyDataStore;

import java.util.List;

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

    public MainActivityFragment() {}

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_main, container, false);
        this.inflater = inflater;
        view.findViewById(R.id.button_scan).setOnClickListener(this);
        //Setup message receiver
        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(mMessageReceiver,
                new IntentFilter("ox_request-precess-event"));
        context = view.getContext();
        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
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
        oxPush2RequestListener = null;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

//        Toast.makeText(getActivity(), R.string.process_qr_code, Toast.LENGTH_SHORT).show();

        switch (requestCode) {
            case IntentIntegrator.REQUEST_CODE:
                if (resultCode == Activity.RESULT_OK) {
                    showToastWithText(context.getString(R.string.process_qr_code));
                    // Parsing bar code reader result
                    IntentResult result = IntentIntegrator.parseActivityResult(requestCode, resultCode, data);
                    if (BuildConfig.DEBUG) Log.d(TAG, "Parsing QR code result: " + result.toString());

                    ((OxPush2RequestListener) getActivity()).onQrRequest(result.getContents());

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

    private void showToastWithText(String text){
        GluuToast gluuToast = new GluuToast(context);
        View view = inflater.inflate(R.layout.gluu_toast, null);
        gluuToast.showGluuToastWithText(view, text);
    }

    private void submit() {
        if (oxPush2RequestListener != null) {
//            String request = "{\"app\":\"https://ce-release.gluu.org/identity/authentication/authcode\",\n" +
//                    "\"username\":\"yure\",\n" +
//                    "\"method\":\"enroll\",\n" +
//                    "\"state\":\"894f00e2-0ab1-4b5a-ae0b-54690a95b018\",\n" +
//                    "\"created\":\"2016-04-27T11:23:18.267000\",\n" +
//                    "\"issuer\":\"https://ce-release.gluu.org\"}\n";
//            oxPush2RequestListener.onQrRequest(request);
//            AndroidKeyDataStore dataStore = new AndroidKeyDataStore(getContext());
//            List<LogInfo> logs = dataStore.getLogs();
//            ApproveDenyFragment approveDenyFragment = new ApproveDenyFragment();
//            approveDenyFragment.setIsUserInfo(false);
//            approveDenyFragment.setLogInfo(logs.get(0));
//            FragmentTransaction transaction = getFragmentManager().beginTransaction();
//            transaction.replace(R.id.main_root_frame, approveDenyFragment);
//            transaction.addToBackStack(null);
//            transaction.commit();
            IntentIntegrator integrator = IntentIntegrator.forSupportFragment(this);
            integrator.setDesiredBarcodeFormats(IntentIntegrator.QR_CODE_TYPES);
            integrator.setPrompt(getString(R.string.scan_oxpush2_prompt));
            integrator.initiateScan();
        }
    }

}
