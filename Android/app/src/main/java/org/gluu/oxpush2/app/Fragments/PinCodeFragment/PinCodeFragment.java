package org.gluu.oxpush2.app.Fragments.PinCodeFragment;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import com.github.simonpercic.rxtime.RxTime;
import com.mhk.android.passcodeview.PasscodeView;

import org.gluu.oxpush2.app.Activities.MainActivity;
import org.gluu.oxpush2.app.CustomGluuAlertView.CustomGluuAlert;
import org.gluu.oxpush2.app.R;

import java.net.UnknownHostException;

import rx.android.schedulers.AndroidSchedulers;
import rx.functions.Action1;

/**
 * Created by nazaryavornytskyy on 3/24/16.
 */
public class PinCodeFragment extends Fragment implements View.OnClickListener {

    private View view;
    private boolean isSettings;
    private boolean newPin;
    private boolean isWrongPin;
    public PinCodeViewListener pinCodeViewListener;
    private boolean isSetNewPinCode;
    private TextView pinCodeTitle;
    private TextView attemptsLabel;

    private Context context;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        view = inflater.inflate(R.layout.fragment_pin_code, container, false);
        context = getContext();
        view.findViewById(R.id.close_button).setVisibility(View.GONE);
        Button closeButton = (Button) view.findViewById(R.id.close_button);
        closeButton.setOnClickListener(this);
        pinCodeTitle = (TextView) view.findViewById(R.id.pin_code_title);
        attemptsLabel = (TextView) view.findViewById(R.id.attemptsLabel);
        updatePinCodeView();
        return view;
    }

    private void updatePinCodeView(){
        /**
         * find view and add the completion listener
         * */
        final PasscodeView pcView = (PasscodeView) view.findViewById(R.id.pin_view);

        pcView.postDelayed(new Runnable() {
            @Override
            public void run() {
                pcView.requestToShowKeyboard();
            }
        }, 400);
        int attempts = isWrongPin ? getCurrentPinCodeAttempts() : getPinCodeAttempts();
        attemptsLabel.setText("You have " + getCurrentPinCodeAttempts() + " attempts left");
        if (getCurrentPinCodeAttempts() <= 2) {
            attemptsLabel.setTextColor(getResources().getColor(R.color.redColor));
        }
        pcView.setPasscodeEntryListener(new PasscodeView.PasscodeEntryListener() {
            @Override
            public void onPasscodeEntered(String passcode) {
                if (getPinCode().equalsIgnoreCase("null")) {
                    setNewPin(passcode);
                } else if (newPin) {
                    if (passcode.equalsIgnoreCase(getPinCode())) {
                        showAlertView("Failed! New Pin code the same like old.");
                        getActivity().onBackPressed();
                    } else {
                        showAlertView("New Pin changed success!");
                        savePinCode(passcode);
                        getActivity().onBackPressed();
                    }
                    newPin = false;
                } else if (passcode.equalsIgnoreCase(getPinCode())) {
                    if (isSetNewPinCode) {
                        attemptsLabel.setVisibility(View.GONE);
                        pinCodeTitle.setText(R.string.set_new_pin_code);
                        pcView.clearText();
                        newPin = true;
                        resetCurrentPinAttempts();
                        return;
                    } else {
                        attemptsLabel.setTextColor(getResources().getColor(R.color.greenColor));
                        attemptsLabel.setText("Pin code is correct!");
                    }
                    if (pinCodeViewListener != null) {
                        pinCodeViewListener.onCorrectPinCode(true);
                    }
                    isWrongPin = false;
                    resetCurrentPinAttempts();
                } else {
                    wrongPinCode(pcView);
                }
            }
        });
//        pinCodeView = (PinCodeView) view.findViewById(R.id.pin_view);
//        pinCodeView.resetPinCodeBoxes();

//        pinCodeView.setCompletionListener(getContext());
//        pinCodeView.setWrongEnteredPinCodesCount(getPinCodeAttempts());
        String pinCode = getPinCode();
        if (pinCode.equalsIgnoreCase("null")){
//            pinCodeView.setPinViewInfoMessageVisable(true);
//            pinCodeView.setDefaultPinCode(pinCode);
//            pinCodeView.setPinCodeMode(PinCodeView.PinCodeMode.VERIFY_PINCODE);
            attemptsLabel.setVisibility(View.GONE);
            pinCodeTitle.setText(R.string.set_new_pin_code);
        } else {
//            /**
//             * set PinCodeMode to SET_NEW_PINCODE in order to create the new pin code,
//             * your responsibility is how you handle the new pin code after entering it
//             * */
//            pinCodeView.setPinViewInfoMessageVisable(false);
//            pinCodeView.setPinCodeMode(PinCodeView.PinCodeMode.SET_NEW_PINCODE);
//            if (getIsReset()) {
//                attemptsLabel.setVisibility(View.VISIBLE);
//                if (isSettings) {
//                    view.findViewById(R.id.close_button).setVisibility(View.VISIBLE);
//                } else {
//                    view.findViewById(R.id.close_button).setVisibility(View.GONE);
//                }
//            }
            if (!newPin) {
                pinCodeTitle.setText(R.string.enter_pin_code);
            }
        }

    }

    private void setNewPin(String passcode){
        isWrongPin = false;
        savePinCode(passcode);
        if (!isSettings) {
            pinCodeViewListener.onCorrectPinCode(true);
        }
        resetCurrentPinAttempts();
        getActivity().onBackPressed();
    }

    private void wrongPinCode(PasscodeView pcView){
        isWrongPin = true;
        increaseAttempts();
        String attemptsText = "You have " + getCurrentPinCodeAttempts() + " attempts left";
        if (getCurrentPinCodeAttempts() <= 2) {
            attemptsLabel.setTextColor(getResources().getColor(R.color.redColor));
        }
        attemptsLabel.setText(attemptsText);
        pcView.clearText();
        if (getCurrentPinCodeAttempts() <= 0) {
            resetCurrentPinAttempts();
            if (isSettings) {
                setAppLocked(true);
                setCurrentNetworkTime();
            }
//            else {
                pinCodeViewListener.onCorrectPinCode(false);
//            }
        }
    }

    private void setCurrentNetworkTime() {
        // a singleton
        RxTime rxTime = new RxTime();
        rxTime.currentTime()
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new Action1<Long>() {
                    @Override
                    public void call(Long time) {
                        // use time
                        setAppLockedTime(String.valueOf(time));
                    }
                });
    }

    private void showAlertView(String message){
        CustomGluuAlert gluuAlert = new CustomGluuAlert(getActivity());
        gluuAlert.setMessage(message);
        gluuAlert.show();
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof PinCodeViewListener) {
            pinCodeViewListener = (PinCodeViewListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement PinCodeViewListener");
        }
    }

    public String getPinCode(){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        String pinCode = preferences.getString("PinCode", "null");
        return pinCode;
    }

    public void savePinCode(String password){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("PinCode", password);
        editor.commit();
    }

    private void setAppLockedTime(String lockedTime){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("appLockedTime", lockedTime);
        editor.commit();
    }

    public Boolean getIsReset(){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        Boolean isFirstLoad = preferences.getBoolean("isReset", false);
        return isFirstLoad;
    }

    public void saveIsReset(){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isReset", false);
        editor.commit();
    }

    public int getPinCodeAttempts(){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        String pinCode = preferences.getString("pinCodeAttempts", "5");
        return Integer.parseInt(pinCode);
    }

    public void resetCurrentPinAttempts(){
        saveIsReset();
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("currentPinCodeAttempts", String.valueOf(getPinCodeAttempts()));
        editor.commit();
    }

    public int getCurrentPinCodeAttempts(){
        SharedPreferences preferences = getContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        String pinCode = preferences.getString("currentPinCodeAttempts", String.valueOf(getPinCodeAttempts()));
        return Integer.parseInt(pinCode);
    }

    public void increaseAttempts(){
        int attempts = getCurrentPinCodeAttempts();
        attempts--;
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("currentPinCodeAttempts", String.valueOf(attempts));
        editor.commit();
    }

    private void setAppLocked(Boolean isLocked){
        SharedPreferences preferences = context.getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isAppLocked", isLocked);
        editor.commit();
    }

    @Override
    public void onClick(View v) {
        saveIsReset();
        getActivity().onBackPressed();
    }

    public void setIsSettings(Boolean isSettings) {
        this.isSettings = isSettings;
    }

    public void setIsSetNewPinCode(Boolean isSetNewPinCode) {
        this.isSetNewPinCode = isSetNewPinCode;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    public interface PinCodeViewListener{
        public void onNewPinCode(String pinCode);
        public void onCorrectPinCode(boolean isPinCodeCorrect);
    }
}
