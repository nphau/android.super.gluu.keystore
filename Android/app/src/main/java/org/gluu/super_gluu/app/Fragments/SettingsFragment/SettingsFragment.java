package org.gluu.super_gluu.app.fragments.SettingsFragment;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Switch;

import org.gluu.super_gluu.app.activities.GluuApplication;
import org.gluu.super_gluu.app.fingerprint.Fingerprint;
import org.gluu.super_gluu.app.gluuToast.GluuToast;
import org.gluu.super_gluu.app.settings.Settings;
import org.gluu.super_gluu.net.CommunicationService;

import SuperGluu.app.R;

/**
 * Created by nazaryavornytskyy on 5/17/17.
 */

public class SettingsFragment extends Fragment {

    private Context context;
    private LayoutInflater inflater;
    private Fingerprint fingerprint;
    private Switch switchFingerprint;

    private BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            // Get extra data included in the Intent
            boolean success = intent.getBooleanExtra("message", false);
            switchFingerprint.setChecked(success);
            String message = success ? "You've success authenticated by fingerprint" : "You've failed authenticated by fingerprint";
            showToast(message);
        }
    };

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_settings, container, false);
        context = getContext();
        this.inflater = inflater;
        fingerprint = new Fingerprint(context);

        final Switch switchSSL = (Switch) view.findViewById(R.id.switch_ssl);
        switchSSL.setChecked(Settings.getSSLEnabled(context));
        switchSSL.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (switchSSL.isChecked()) {
                    showWarning(R.string.warning_trust_all_certificate);
                }
                GluuApplication.isTrustAllCertificates = switchSSL.isChecked();
                Settings.setSSLEnabled(context, switchSSL.isChecked());
                Log.v("TAG", "SSL Settings enable: " + switchSSL.isChecked());
                // Init network layer
                CommunicationService.init();
            }
        });

        switchFingerprint = (Switch) view.findViewById(R.id.switch_fingerprint);
        switchFingerprint.setChecked(Settings.getFingerprintEnabled(context));
        switchFingerprint.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (switchFingerprint.isChecked() && fingerprint.startFingerprintService()) {
                    Settings.setFingerprintEnabled(context, switchFingerprint.isChecked());
                    Log.v("TAG", "Fingerprint Settings enable: " + switchFingerprint.isChecked());
                } else {
                    switchFingerprint.setChecked(false);
                    showToastWithText("Fingerprint is not available for this device");
                }

            }
        });

        //Setup message receiver
        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(mMessageReceiver,
                new IntentFilter("fingerprint_authentication_result"));

        return view;
    }

    @Override
    public void onStop() {
        super.onStop();
        LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(mMessageReceiver);
    }

    private void showToastWithText(String text){
        GluuToast gluuToast = new GluuToast(context);
        View view = inflater.inflate(R.layout.gluu_toast, null);
        gluuToast.showGluuToastWithText(view, text);
    }

    private void showWarning(int statusId) {
        String message = context.getString(statusId);
        Intent intent = new Intent("ox_request-precess-event");
        // You can also include some extra data.
        intent.putExtra("message", message);
        LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
    }

    public void showToast(String text){
        GluuToast gluuToast = new GluuToast(context);
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.gluu_toast, null);
        gluuToast.showGluuToastWithText(view, text);
    }
}
