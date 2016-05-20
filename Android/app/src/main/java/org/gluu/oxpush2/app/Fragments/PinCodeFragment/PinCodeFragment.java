package org.gluu.oxpush2.app.Fragments.PinCodeFragment;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.content.LocalBroadcastManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.TextView;

import com.mostcho.pincodeview.PinCodeView;

import org.gluu.oxpush2.app.CustomGluuAlertView.CustomGluuAlert;
import org.gluu.oxpush2.app.R;

/**
 * Created by nazaryavornytskyy on 3/24/16.
 */
public class PinCodeFragment extends Fragment implements View.OnClickListener {

    private PinCodeView pinCodeView;
    private View view;
    private Boolean isReset;

    private BroadcastReceiver mReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String message = intent.getStringExtra("message");
            if (message.equalsIgnoreCase("reset")) {
                updatePinCodeView();
            } else {
                getActivity().onBackPressed();
            }
        }
    };

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        view = inflater.inflate(R.layout.fragment_pin_code, container, false);
        updatePinCodeView();
        Button closeButton = (Button) view.findViewById(R.id.close_button);
        closeButton.setOnClickListener(this);

        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(mReceiver,
                new IntentFilter("reset_pin_code-event"));

        return view;
    }

    private void updatePinCodeView(){
        /**
         * find view and add the completion listener
         * */
        pinCodeView = (PinCodeView) view.findViewById(R.id.pin_view);
        pinCodeView.resetPinCodeBoxes();
        TextView pinCodeTitle = (TextView) view.findViewById(R.id.pin_code_title);
        pinCodeView.setCompletionListener(getContext());
        pinCodeView.setWrongEnteredPinCodesCount(getPinCodeAttempts());
        String pinCode = getPinCode();
        if (!pinCode.equalsIgnoreCase("0000")){
            pinCodeView.setPinViewInfoMessageVisable(true);
            pinCodeView.setDefaultPinCode(pinCode);
            pinCodeView.setPinCodeMode(PinCodeView.PinCodeMode.VERIFY_PINCODE);
            pinCodeTitle.setText(R.string.enter_pin_code);
        } else {
            /**
             * set PinCodeMode to SET_NEW_PINCODE in order to create the new pin code,
             * your responsibility is how you handle the new pin code after entering it
             * */
            pinCodeView.setPinViewInfoMessageVisable(false);
            pinCodeView.setPinCodeMode(PinCodeView.PinCodeMode.SET_NEW_PINCODE);
            pinCodeTitle.setText(R.string.set_new_pin_code);
        }

        if (getIsReset()){
            view.findViewById(R.id.close_button).setVisibility(View.VISIBLE);
        } else {
            view.findViewById(R.id.close_button).setVisibility(View.GONE);
        }
        showKeyboard();
    }

    private void showKeyboard(){
        InputMethodManager imm = (InputMethodManager)getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.showSoftInput(view, InputMethodManager.SHOW_IMPLICIT);
    }

    public String getPinCode(){
        SharedPreferences preferences = getContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        String pinCode = preferences.getString("PinCode", "0000");
        return pinCode;
    }

    public Boolean getIsReset(){
        SharedPreferences preferences = getContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        Boolean isFirstLoad = preferences.getBoolean("isReset", false);
        return isFirstLoad;
    }

    public void saveIsReset(){
        SharedPreferences preferences = getContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isReset", false);
        editor.commit();
    }

    public int getPinCodeAttempts(){
        SharedPreferences preferences = getContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        String pinCode = preferences.getString("pinCodeAttempts", "5");
        return Integer.parseInt(pinCode);
    }

    @Override
    public void onClick(View v) {
        saveIsReset();
        getActivity().onBackPressed();
    }

    public void setIsReset(Boolean isReset) {
        this.isReset = isReset;
    }

    @Override
    public void onDestroy() {
        // Unregister since the activity is about to be closed.
        LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(mReceiver);
        super.onDestroy();
    }
}
