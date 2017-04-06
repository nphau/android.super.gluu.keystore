package org.gluu.super_gluu.app.Fragments.PinCodeFragment;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import org.gluu.super_gluu.app.Fragments.LicenseFragment.LicenseFragment;
import SuperGluu.app.R;

/**
 * Created by nazaryavornytskyy on 3/24/16.
 */
public class PinCodeSettingFragment extends Fragment implements View.OnClickListener {

    LicenseFragment.OnMainActivityListener mainActivityListener;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_pin_code_setting, container, false);
        view.findViewById(R.id.yes_button).setOnClickListener(this);
        view.findViewById(R.id.no_button).setOnClickListener(this);

        if (!isPin()){
            mainActivityListener.onShowPinFragment();
        }

        return view;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof LicenseFragment.OnMainActivityListener) {
            mainActivityListener = (LicenseFragment.OnMainActivityListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnMainActivityListener");
        }
    }

    @Override
    public void onClick(View v) {

        switch (v.getId()){
            case R.id.yes_button:
                mainActivityListener.onShowPinFragment();
                setPincodeEnabled(true);
                break;
            case R.id.no_button:
                mainActivityListener.onMainActivity();
                setPincodeEnabled(false);
                break;
            default:
                break;
        }

    }

    public void setPincodeEnabled(Boolean isEnabled){
        SharedPreferences preferences = getContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isPinEnabled", isEnabled);
        editor.commit();
    }

    public Boolean isPin(){
        SharedPreferences preferences = getContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        String pinCode = preferences.getString("PinCode", "null");
        return pinCode.equalsIgnoreCase("null");
    }
}
