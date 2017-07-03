package org.gluu.super_gluu.app.fragments.SettingsFragment.SettingsList;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;

import org.gluu.super_gluu.app.settings.Settings;

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

        context = getContext();
        this.inflater = inflater;
        View rootView = inflater.inflate(R.layout.settings_list, container, false);

        listSettings = new ArrayList<String>();
        listSettings.add("Pin code");
        listSettings.add("TouchID (fingerprint)");
//        listSettings.add("U2F BLE device(s)");
        listSettings.add("Trust all (SSL)");
        listSettings.add("");
        listSettings.add("User guide");
        listSettings.add("Feedback");
        listSettings.add("Privacy policy");
        listSettings.add("");
        listSettings.add("Version");
//        Boolean isAdFree = Settings.getPurchase(context);
//        if (!isAdFree){
//            listSettings.add("Ad Free");
//        }

        mListener = new SettingsListListener() {
            @Override
            public void onSettingsList(Fragment settingsFragment) {
                FragmentTransaction transaction = getFragmentManager().beginTransaction();

                transaction.replace(R.id.root_frame, settingsFragment);
                transaction.addToBackStack(null);
                transaction.commit();
            }
        };

        listAdapter = new SettingsListFragmentAdapter(getActivity(), listSettings, mListener);
        ListView lv = (ListView) rootView.findViewById(R.id.settingsListView);
        lv.setAdapter(listAdapter);

        return rootView;
    }

    public interface SettingsListListener {
        void onSettingsList(Fragment settingsFragment);
    }

}