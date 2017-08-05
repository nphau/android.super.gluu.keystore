package org.gluu.super_gluu.app.fragments.SettingsFragment.SettingsList;

import android.app.ActionBar;
import android.content.Context;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

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

        View actionBarView = (View) rootView.findViewById(R.id.actionBarSettings);
        actionBarView.findViewById(R.id.action_left_button).setVisibility(View.GONE);
        actionBarView.findViewById(R.id.action_right_button).setVisibility(View.GONE);
        actionBarView.findViewById(R.id.actionbar_icon).setVisibility(View.GONE);
        TextView title = (TextView) actionBarView.findViewById(R.id.actionbar_textview);
        title.setVisibility(View.VISIBLE);
        title.setText("MENU");

        listSettings = new ArrayList<String>();
        listSettings.add("Pin code");
        listSettings.add("Fingerprint");
//        listSettings.add("U2F BLE device(s)");
        listSettings.add("Trust all (SSL)");
        listSettings.add("");
        listSettings.add("User guide");
        listSettings.add("Privacy policy");
        Boolean isAdFree = Settings.getPurchase(context);
        if (!isAdFree){
            listSettings.add("Upgrade to Ad-Free");
        }
        listSettings.add("");
        listSettings.add("Version");

        mListener = new SettingsListListener() {
            @Override
            public void onSettingsList(Fragment settingsFragment) {
                FragmentTransaction transaction = getFragmentManager().beginTransaction();
                Settings.setIsSettingsMenuVisible(context, true);
                transaction.replace(R.id.root_frame, settingsFragment);
                transaction.addToBackStack(null);
                transaction.commit();
                getActivity().invalidateOptionsMenu();
            }
        };

        listAdapter = new SettingsListFragmentAdapter(getActivity(), listSettings, mListener);
        ListView lv = (ListView) rootView.findViewById(R.id.settingsListView);
        lv.setAdapter(listAdapter);

        TextView info = (TextView) rootView.findViewById(R.id.textView3);
        Typeface face = Typeface.createFromAsset(getActivity().getAssets(), "ProximaNova-Regular.otf");
        info.setTypeface(face);

        return rootView;
    }

    public interface SettingsListListener {
        void onSettingsList(Fragment settingsFragment);
    }

}