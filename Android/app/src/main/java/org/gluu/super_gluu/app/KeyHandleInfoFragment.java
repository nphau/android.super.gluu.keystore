package org.gluu.super_gluu.app;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.content.LocalBroadcastManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TableLayout;
import android.widget.TextView;

import com.google.gson.Gson;

import org.gluu.super_gluu.app.customGluuAlertView.CustomGluuAlert;
import org.gluu.super_gluu.app.settings.Settings;
import org.gluu.super_gluu.u2f.v2.model.TokenEntry;
import org.gluu.super_gluu.util.Utils;

import java.net.URI;
import java.net.URISyntaxException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import SuperGluu.app.R;

/**
 * Created by nazaryavornytskyy on 3/1/16.
 */
public class KeyHandleInfoFragment extends Fragment implements View.OnClickListener{

    final SimpleDateFormat isoDateTimeFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS");
    final SimpleDateFormat userDateTimeFormat = new SimpleDateFormat("MMM d, yyyy HH:mm:ss");

    private static final String ARG_PARAM1 = "tokenEntry";
    private TokenEntry tokenEntry;
    private OnDeleteKeyHandleListener mDeleteListener;

    private Activity mActivity;

    private BroadcastReceiver mDeleteReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            // Get extra data included in the Intent
//            Boolean isAdFree = intent.getBooleanExtra("isAdFree", false);
            showAlertView();
        }
    };

    public static KeyHandleInfoFragment newInstance(String tokenEntity) {
        KeyHandleInfoFragment fragment = new KeyHandleInfoFragment();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, tokenEntity);
        fragment.setArguments(args);

        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (getArguments() != null) {
            String tokenString = getArguments().getString(ARG_PARAM1);
            tokenEntry = new Gson().fromJson(tokenString, TokenEntry.class);
        }
        //Setup message receiver\
        if (mActivity == null){
            mActivity = getActivity();
        }
        LocalBroadcastManager.getInstance(mActivity).registerReceiver(mDeleteReceiver,
                new IntentFilter("on-delete-key-event"));
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        View rootView = inflater.inflate(R.layout.fragment_keyhandle_info, container, false);
        updateKeyHandleDetails(rootView);
//        rootView.findViewById(R.id.delete_button).setOnClickListener(this);
//        rootView.findViewById(R.id.close_button).setOnClickListener(this);
        return rootView;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnDeleteKeyHandleListener) {
            mDeleteListener = (OnDeleteKeyHandleListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnDeleteKeyHandleListener");
        }
    }

    @Override
    public void onPause(){
        super.onPause();
        LocalBroadcastManager.getInstance(mActivity).unregisterReceiver(mDeleteReceiver);
    }

    private void updateKeyHandleDetails(View view) {
        ((TextView) view.findViewById(R.id.keyHandle_user_name_label_value)).setText(tokenEntry.getUserName());
        setupPairingDateByFormat((TextView) view.findViewById(R.id.keyHandle_created_value));
        try {
            URI uri = new URI(tokenEntry.getIssuer());
            String path = uri.getHost();
            ((TextView) view.findViewById(R.id.keyHandle_issuer_value)).setText(path);
        } catch (URISyntaxException e) {
            ((TextView) view.findViewById(R.id.keyHandle_issuer_value)).setText(tokenEntry.getIssuer());
            e.printStackTrace();
        }

        String keyStr = Utils.encodeHexString(tokenEntry.getKeyHandle());
        String keyHandleString = keyStr.substring(0, 6) + "..." + keyStr.substring(keyStr.length()-6);
        ((TextView) view.findViewById(R.id.keyHandle_id)).setText(keyHandleString);
    }

    @Override
    public void onClick(View v) {
//        if(v.getId() == R.id.delete_button){
//            showAlertView();
//        } else {
//            getFragmentManager().popBackStack();
//        }
    }

    void showAlertView(){
        GluuMainActivity.GluuAlertCallback listener = new GluuMainActivity.GluuAlertCallback(){
            @Override
            public void onPositiveButton() {
                mDeleteListener.onDeleteKeyHandle(tokenEntry.getKeyHandle());
                android.support.v4.app.FragmentManager fm = getFragmentManager();
                fm.popBackStack();
            }

            @Override
            public void onNegativeButton() {
                //Skip here
            }
        };
        CustomGluuAlert gluuAlert = new CustomGluuAlert(mActivity);
        gluuAlert.setMessage(mActivity.getApplicationContext().getString(R.string.approve_delete));
        gluuAlert.setYesTitle(mActivity.getApplicationContext().getString(R.string.yes));
        gluuAlert.setNoTitle(mActivity.getApplicationContext().getString(R.string.no));
        gluuAlert.setmListener(listener);
        gluuAlert.show();
    }

    void setupPairingDateByFormat(TextView textView){

        if (textView != null && tokenEntry.getCreatedDate() != null) {
            Date date = null;
            try {
                date = isoDateTimeFormat.parse(tokenEntry.getCreatedDate());
            } catch (ParseException e) {
                e.printStackTrace();
            }
            if (date != null) {
                String pairingDate = userDateTimeFormat.format(date);
                textView.setText(pairingDate);
            }
        } else {
            textView.setText(R.string.no_date);
        }
    }

    public interface OnDeleteKeyHandleListener {
        void onDeleteKeyHandle(byte[] keyHandle);
    }
}
