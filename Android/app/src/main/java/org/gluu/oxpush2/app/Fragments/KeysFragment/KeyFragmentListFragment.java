package org.gluu.oxpush2.app.Fragments.KeysFragment;

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;
import android.widget.TextView;

import com.google.gson.Gson;

import org.gluu.oxpush2.app.CustomGluuAlertView.CustomGluuAlert;
import org.gluu.oxpush2.app.Fragments.LicenseFragment.LicenseFragment;
import org.gluu.oxpush2.app.KeyHandleInfoFragment;
import org.gluu.oxpush2.app.R;
import org.gluu.oxpush2.store.AndroidKeyDataStore;
import org.gluu.oxpush2.u2f.v2.model.TokenEntry;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by nazaryavornytskyy on 3/1/16.
 */
public class KeyFragmentListFragment extends Fragment {

    private KeyFragmentListAdapter listAdapter;
    private KeyHandleInfo mListener;
    private KeyHandleChangeName cListener;
    private AndroidKeyDataStore dataStore;
    private List<TokenEntry> listToken;
    private TextView renameText;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);

        View rootView = inflater.inflate(R.layout.fragment_key_list, container, false);

        listToken = getListToken(rootView);
        ListView lv = (ListView) rootView.findViewById(R.id.keyHandleListView);
        mListener = new KeyHandleInfo() {
            @Override
            public void onKeyHandleInfo(KeyHandleInfoFragment infoFragment) {
                FragmentTransaction transaction = getFragmentManager().beginTransaction();

                transaction.replace(R.id.keys_root_frame, infoFragment);
                transaction.addToBackStack(null);
                transaction.commit();
            }
        };

        cListener = new KeyHandleChangeName() {
            @Override
            public void onKeyNameChanged(String keyID) {
                CustomGluuAlert gluuAlert = new CustomGluuAlert(getActivity());
                gluuAlert.setMessage(getActivity().getApplicationContext().getString(R.string.enter_new_key_name));
                gluuAlert.setYesTitle(getActivity().getApplicationContext().getString(R.string.yes));
                gluuAlert.setNoTitle(getActivity().getApplicationContext().getString(R.string.no));
//                gluuAlert.setmListener(listener);
                gluuAlert.show();
            }
        };
        listAdapter = new KeyFragmentListAdapter(getActivity(), listToken, mListener);
        lv.setAdapter(listAdapter);
        lv.setEmptyView(rootView.findViewById(R.id.empty_keyList));

        TextView availableKeys = (TextView) rootView.findViewById(R.id.availableKeys_textView);
        availableKeys.setText(rootView.getContext().getString(R.string.available_keys, String.valueOf(listAdapter.getCount())));
        renameText = (TextView) rootView.findViewById(R.id.rename_textView);

        return rootView;
    }

    @Override
    public void onResume() {
        super.onResume();
        checkTokenList();
    }

    void checkTokenList(){
        if (listToken.size() == 0) {
            renameText.setVisibility(View.GONE);
        }
    }

    List<TokenEntry> getListToken(View view){
        Context context = view.getContext();
        dataStore = new AndroidKeyDataStore(context);
        List<String> tokensString = dataStore.getTokenEntries();
        List<TokenEntry> tokens = new ArrayList<TokenEntry>();
        for (String tokenString : tokensString){
            TokenEntry token = new Gson().fromJson(tokenString, TokenEntry.class);
            tokens.add(token);
        }

        return tokens;
    }

    public interface KeyHandleInfo {
        void onKeyHandleInfo(KeyHandleInfoFragment infoFragment);
    }

    public interface KeyHandleChangeName {
        void onKeyNameChanged(String keyID);
    }

}
