package org.gluu.super_gluu.app.fragments.SettingsFragment.SettingsList;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.google.gson.Gson;

import org.gluu.super_gluu.app.KeyHandleInfoFragment;
import org.gluu.super_gluu.app.fragments.SettingsFragment.SettingsFragment;
import org.gluu.super_gluu.app.fragments.SettingsFragment.SettingsPinCode;
import org.gluu.super_gluu.app.settings.Settings;

import java.util.List;

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

    public SettingsListFragmentAdapter(Activity activity, List<String> listContact, SettingsListFragment.SettingsListListener settingsListListener) {
        list = listContact;
        this.activity = activity;
        this.context = activity.getApplicationContext();
        mInflater = LayoutInflater.from(activity);
        mListener = settingsListListener;
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
        }
        TextView status = (TextView) view.findViewById(R.id.settings_status);
        if (status != null) {
            Boolean value = Settings.getSettingsValueEnabled(this.context, position == 1 ? "FingerprintSettings" : "SSLConnectionSettings");
            if (position > 0) {
                value = Settings.getSettingsValueEnabled(this.context, position == 1 ? "FingerprintSettings" : "SSLConnectionSettings");
            } else {
                value = Settings.getPinCodeEnabled(this.context);
            }
            String valueString = value ? "On" : "Off";
            status.setText("Status: " + valueString);
        }

        view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int position = (int) v.getTag();
                if (mListener != null) {
                    mListener.onSettingsList(getFragment(position));
                }
            }
        });

        return view;
    }
}
