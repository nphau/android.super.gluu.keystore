package org.gluu.super_gluu.app.fragments.SettingsFragment;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.v4.app.Fragment;
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
import org.gluu.super_gluu.app.gluuToast.GluuToast;
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

        fingerprint = new Fingerprint(context);

        final String settingsId = this.getArguments().getString(Constant.SETTINGS_ID);

        if(settingsId != null) {
            switch (settingsId) {
                case Constant.SSL_CONNECTION_TYPE:
                    setupHomeAsUpEnabledToolbar(toolbar, getString(R.string.trust_all_ssl));
                    titleTextView.setText(getString(R.string.trust_all_certificate));
                    subtitleTextView.setText(R.string.warning_trust_all_certificate);
                    settingsIconImageView.setImageDrawable(getResources().getDrawable(R.drawable.icon_trust_all));
                    break;
                case Constant.FINGERPRINT_TYPE:
                    setupHomeAsUpEnabledToolbar(toolbar, getString(R.string.fingerprint_title));
                    titleTextView.setText(getString(R.string.fingerprint_title));

                    if(fingerprint.checkIfFingerprintEnabled()) {
                        subtitleTextView.setText(getString(R.string.pin_code_text));
                    } else {
                        subtitleTextView.setText(getString(R.string.fingerprint_off_device));
                    }
                    settingsIconImageView.setImageDrawable(getResources().getDrawable(R.drawable.icon_touch_id));
                    break;
            }
        } else {
            setupHomeAsUpEnabledToolbar(toolbar, getString(R.string.settings_title));
        }
        setHasOptionsMenu(true);

        if(settingsId.equals(Constant.FINGERPRINT_TYPE)) {
            if(!fingerprint.checkIfFingerprintEnabled()) {
                showToastWithText("Fingerprint is turned off for this device");

                switchSettings.setEnabled(false);
                switchSettings.setClickable(false);
            }
        }

        switchSettings.setChecked(Settings.getSettingsValueEnabled(context, settingsId));

        switchSettings.setOnClickListener(v -> {

            Log.i("boogie", "Switch touched");

            if (settingsId != null && settingsId.equals(Constant.SSL_CONNECTION_TYPE)) {
                GluuApplication.isTrustAllCertificates = switchSettings.isChecked();
            } else {
                if (switchSettings.isChecked() && fingerprint.startFingerprintService()) {
                    Log.v("TAG", "Fingerprint Settings enable: " + switchSettings.isChecked());
                } else {
                    switchSettings.setChecked(false);
                    showToastWithText(getString(R.string.fingerprint_off_device));
                }
            }
            Settings.setSettingsValueEnabled(context, settingsId, switchSettings.isChecked());
            // Init network layer
            CommunicationService.init();
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
        LayoutInflater layoutInflater = getLayoutInflater();
        if(layoutInflater != null) {
            View view = layoutInflater.inflate(R.layout.gluu_toast, null);
            gluuToast.showGluuToastWithText(view, text);
        }
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
        LayoutInflater inflater = getLayoutInflater();
        if(inflater != null) {
            View view = inflater.inflate(R.layout.gluu_toast, null);
            gluuToast.showGluuToastWithText(view, text);
        }
    }

    public static class Constant {
        public final static String SETTINGS_ID = "settingsId";
        public final static String USER_GUIDE_URL = "https://gluu.org/docs/supergluu/3.0.0/user-guide/";

        //types
        public final static String SSL_CONNECTION_TYPE = "SSLConnectionSettings";
        public final static String FINGERPRINT_TYPE = "FingerprintSettings";
    }
}
