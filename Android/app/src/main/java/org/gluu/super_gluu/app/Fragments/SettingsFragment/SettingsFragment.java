package org.gluu.super_gluu.app.fragments.SettingsFragment;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.Switch;
import android.widget.TextView;

import org.gluu.super_gluu.app.activities.GluuApplication;
import org.gluu.super_gluu.app.base.ToolbarFragment;
import org.gluu.super_gluu.app.fingerprint.Fingerprint;
import org.gluu.super_gluu.app.settings.Settings;
import org.gluu.super_gluu.net.CommunicationService;

import SuperGluu.app.R;
import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by nazaryavornytskyy on 5/17/17.
 */

public class SettingsFragment extends ToolbarFragment {

    private Context context;

    private Fingerprint fingerprint;

    @BindView(R.id.nav_drawer_toolbar)
    Toolbar toolbar;

    @BindView(R.id.setting_switch)
    Switch switchSettings;

    @BindView(R.id.settings_subtitle_text_view)
    TextView subtitleTextView;

    @BindView(R.id.settings_title_text_view)
    TextView titleTextView;

    @BindView(R.id.settings_image_view)
    ImageView settingsIconImageView;

    String settingsId = null;

    private BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            // Get extra data included in the Intent
            boolean success = intent.getBooleanExtra("message", false);
            switchSettings.setChecked(success);
            String message = success ? "You've success authenticated by fingerprint" : "You've failed authenticated by fingerprint";
            showToast(message);
        }
    };

    public static SettingsFragment newInstance(String settingsId) {
        SettingsFragment settingsFragment = new SettingsFragment();
        Bundle bundle = new Bundle();
        bundle.putString(Constant.SETTINGS_ID, settingsId);
        settingsFragment.setArguments(bundle);

        return settingsFragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_settings, container, false);

        ButterKnife.bind(this, view);

        context = getContext();

        fingerprint = new Fingerprint(context, false);

        settingsId = this.getArguments().getString(Constant.SETTINGS_ID);

        if(settingsId == null) {
            throw new RuntimeException("Must send a settings type to create generic settings fragment");
        }

        switch (settingsId) {
            case Constant.SSL_CONNECTION_TYPE:
                setDefaultToolbar(toolbar, getString(R.string.trust_all_ssl_no_parentheses), true);
                titleTextView.setText(getString(R.string.trust_all_certificate));
                subtitleTextView.setText(R.string.warning_trust_all_certificate);
                settingsIconImageView.setImageDrawable(getResources().getDrawable(R.drawable.icon_trust_all));
                break;
            case Constant.FINGERPRINT_TYPE:
                setDefaultToolbar(toolbar, getString(R.string.fingerprint_title), true);
                titleTextView.setText(getString(R.string.fingerprint_title));
                settingsIconImageView.setImageDrawable(getResources().getDrawable(R.drawable.icon_touch_id));

                if(fingerprint.checkIfFingerprintEnabled()) {
                    subtitleTextView.setText(getString(R.string.fingerprint_protection_description));
                } else {
                    subtitleTextView.setText(getString(R.string.fingerprint_off_device));
                    showToast(getString(R.string.fingerprint_off_device));
                    switchSettings.setEnabled(false);
                    switchSettings.setClickable(false);
                }
                break;

        }
        setHasOptionsMenu(true);

        switchSettings.setChecked(Settings.getSettingsValueEnabled(context, settingsId));

        switchSettings.setOnClickListener(v -> {

            switch (settingsId) {
                case Constant.SSL_CONNECTION_TYPE:
                    GluuApplication.isTrustAllCertificates = switchSettings.isChecked();

                    updateSettingsAfterClick();
                    break;

                case Constant.FINGERPRINT_TYPE:
                    if (switchSettings.isChecked() && fingerprint.startFingerprintService()) {
                        Log.v("TAG", "Fingerprint Settings enable: " + switchSettings.isChecked());
                    } else {
                        switchSettings.setChecked(false);
                    }

                    updateSettingsAfterClick();
                    break;
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


    private void showWarning(int statusId) {
        String message = context.getString(statusId);
        Intent intent = new Intent("ox_request-precess-event");

        // You can also include some extra data.
        intent.putExtra("message", message);
        LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
    }

    public void showToast(String text){
        org.gluu.super_gluu.app.gluuToast.CustomToast customToast = new org.gluu.super_gluu.app.gluuToast.CustomToast(context);
        LayoutInflater inflater = getLayoutInflater();
        if(inflater != null) {
            View view = inflater.inflate(R.layout.custom_toast, null);
            customToast.showGluuToastWithText(view, text);
        }
    }

    private void updateSettingsAfterClick() {
        Settings.setSettingsValueEnabled(context, settingsId, switchSettings.isChecked());
        // Init network layer
        CommunicationService.init();
    }

    public static class Constant {
        private final static String SETTINGS_ID = "settingsId";

        //types
        public final static String SSL_CONNECTION_TYPE = "SSLConnectionSettings";
        public final static String FINGERPRINT_TYPE = "FingerprintSettings";
    }
}
