package org.gluu.super_gluu.app.fragments.SettingsFragment.SettingsList;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.content.LocalBroadcastManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import org.gluu.super_gluu.app.fragments.LicenseFragment.LicenseFragment;
import org.gluu.super_gluu.app.fragments.SettingsFragment.SettingsFragment;
import org.gluu.super_gluu.app.fragments.SettingsFragment.SettingsPinCode;
import org.gluu.super_gluu.app.purchase.InAppPurchaseService;
import org.gluu.super_gluu.app.settings.Settings;

import java.util.List;

import SuperGluu.app.BuildConfig;
import SuperGluu.app.R;

/**
 * Created by nazaryavornytskyy on 5/17/17.
 */

public class SettingsListFragmentAdapter extends BaseAdapter {

    private List<String> list;
    private LayoutInflater mInflater;
    private Context context;
    private Activity activity;
    private SettingsListFragment.SettingsListListener mListener;
    private Typeface face;
    //For purchases
    private InAppPurchaseService inAppPurchaseService = new InAppPurchaseService();

    public SettingsListFragmentAdapter(Activity activity, List<String> listContact, SettingsListFragment.SettingsListListener settingsListListener) {
        list = listContact;
        this.activity = activity;
        this.context = activity.getApplicationContext();
        mInflater = LayoutInflater.from(activity);
        mListener = settingsListListener;
        face = Typeface.createFromAsset(activity.getAssets(), "ProximaNova-Regular.otf");
        initIAPurchaseService();
    }

    private void initIAPurchaseService(){
        inAppPurchaseService.initInAppService(context);
        inAppPurchaseService.setCustomEventListener(new InAppPurchaseService.OnInAppServiceListener() {
            @Override
            public void onSubscribed(Boolean isSubscribed) {
                if (list.size() == 4 && isSubscribed){
                    list.remove(3);
                    notifyDataSetChanged();
                }
//                initGoogleADS(isSubscribed);
            }
        });
    }

    Fragment getFragment(int position){
        switch (position){
            case 0:
                return new SettingsPinCode();
            case 1:
                return createSettingsFragment("FingerprintSettings");
            case 2:
                return createSettingsFragment("SSLConnectionSettings");
        }
        return null;
    }

    SettingsFragment createSettingsFragment(String settingsId){
        SettingsFragment sslFragment = new SettingsFragment();
        Bundle bundle = new Bundle();
        bundle.putString("settingsId", settingsId);
        sslFragment.setArguments(bundle);
        return sslFragment;
    }

    @Override
    public int getCount() {
        return list.size();
    }

    @Override
    public Object getItem(int position) {
        return list.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view = convertView;

        if (view == null) {
            LayoutInflater inflater = mInflater;
            view = inflater.inflate(R.layout.fragment_setting_list, null);
        }
        view.setTag(position);

        TextView settingName = (TextView) view.findViewById(R.id.settings_name);

        if (settingName != null) {
            settingName.setText(list.get(position));
            settingName.setTypeface(face);
        }
        ImageView settingArrow = (ImageView) view.findViewById(R.id.settingArrow);
        TextView info = (TextView) view.findViewById(R.id.textInfo);
        if (position > 2) {
            settingArrow.setVisibility(View.VISIBLE);
            if (position == 3 || position == 7 || position == 8) {
                settingArrow.setVisibility(View.GONE);
                if (settingName.getText().equals("Version")) {
                    int versionCode = BuildConfig.VERSION_CODE;
                    String versionName = BuildConfig.VERSION_NAME;
                    info.setText(versionName + " - " + String.valueOf(versionCode));
                    view.setBackgroundColor(Color.WHITE);
                    info.setVisibility(View.VISIBLE);
                    info.setTypeface(face);
                } else {
                    info.setVisibility(View.GONE);
                    view.setBackgroundColor(Color.parseColor("#efeff4"));
                }
            }
        } else {
            view.setBackgroundColor(Color.WHITE);
            settingArrow.setVisibility(View.VISIBLE);
            info.setVisibility(View.GONE);
        }
//        TextView status = (TextView) view.findViewById(R.id.settings_status);
//        if (status != null) {
//            status.setVisibility(View.GONE);
//            Boolean value;
//            if (position > 0) {
//                value = Settings.getSettingsValueEnabled(this.context, position == 1 ? "FingerprintSettings" : "SSLConnectionSettings");
//            } else {
//                value = Settings.getPinCodeEnabled(this.context);
//            }
//            if (position < 2) {
////                status.setText("Tired of ads? Upgrade to ad free for $0.99/month!");
////            } else {
//                String valueString = value ? "On" : "Off";
//                status.setText("Status: " + valueString);
//            } else {
//                status.setVisibility(View.GONE);
//            }
//        }

        view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int position = (int) v.getTag();
//                if (position == 3){
//                    inAppPurchaseService.purchase(activity);
//                    return;
//                }
                if (mListener != null && position < 3) {
                    mListener.onSettingsList(getFragment(position));
                } else if (position == 4){
                    Uri uri = Uri.parse("https://gluu.org/docs/supergluu/3.0.0/user-guide/");
                    Intent intent = new Intent(Intent.ACTION_VIEW, uri);
                    activity.startActivity(intent);
                } else if (position == 5) {
                    LicenseFragment licenseFragment = new LicenseFragment();
                    licenseFragment.setForFirstLoading(false);
                    mListener.onSettingsList(licenseFragment);
                } else if (position == 6 && !Settings.getPurchase(context)){
                    Intent intent = new Intent("on-ad-free-flow");
                    LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
                }
            }
        });

        return view;
    }
}
