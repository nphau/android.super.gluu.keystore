package org.gluu.super_gluu.app.fragments.SettingsFragment.SettingsList;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;
import java.util.ArrayList;
import java.util.List;

import SuperGluu.app.R;

/**
 * Created by nazaryavornytskyy on 3/23/16.
 */
public class SettingsListFragment extends Fragment {

    private Context context;
    private LayoutInflater inflater;

    private SettingsListFragmentAdapter listAdapter;
    private SettingsListListener mListener;
    private List<String> listSettings = new ArrayList<String>();

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    @Override
    public void onStop() {
        super.onStop();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_settings, container, false);
        context = getContext();
        this.inflater = inflater;
        View rootView = inflater.inflate(R.layout.fragment_key_list, container, false);

        listSettings.add("Pin code");
        listSettings.add("TouchID (fingerprint)");
//        listSettings.add("U2F BLE device(s)");
        listSettings.add("Trust all (SSL)");

        mListener = new SettingsListListener() {
            @Override
            public void onSettingsList(String settingsName) {

            }
        };

        listAdapter = new SettingsListFragmentAdapter(getActivity(), listSettings, mListener);
        ListView lv = (ListView) rootView.findViewById(R.id.settingsListView);
        lv.setAdapter(listAdapter);

        return view;
    }

    public interface SettingsListListener {
        void onSettingsList(String settingsName);
    }

}