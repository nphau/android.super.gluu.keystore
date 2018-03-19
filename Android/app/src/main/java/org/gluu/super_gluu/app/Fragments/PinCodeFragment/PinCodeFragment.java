package org.gluu.super_gluu.app.fragments.PinCodeFragment;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.TextView;

import org.gluu.super_gluu.app.customGluuAlertView.CustomGluuAlert;
import org.gluu.super_gluu.app.services.GlobalNetworkTime;
import org.gluu.super_gluu.app.settings.Settings;
import org.gluu.super_gluu.util.PinEntryEditText;

import SuperGluu.app.R;
import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by nazaryavornytskyy on 3/24/16.
 */
public class PinCodeFragment extends Fragment {

    @BindView(R.id.nav_drawer_toolbar)
    Toolbar toolbar;
    @BindView(R.id.attemptsLabel)
    TextView attemptsTextView;
    @BindView(R.id.enter_passcode_text_view)
    TextView enterPasscodeTextView;

    @BindView(R.id.pin_code_edit_text)
    PinEntryEditText pinCodeEditText;

    Context context;

    public PinCodeViewListener pinCodeViewListener;

    private String fragmentType;
    private boolean isSettings;
    private boolean newPin;
    private int setNewPinAttempts;
    private boolean isSetNewPinCode;

    public static PinCodeFragment newInstance(String fragmentType, boolean isNewPinCode, boolean isSettings) {
        PinCodeFragment pinCodeFragment = new PinCodeFragment();
        Bundle bundle = new Bundle();
        bundle.putString(Constant.FRAGMENT_TYPE, fragmentType);
        bundle.putBoolean(Constant.NEW_PIN_CODE, isNewPinCode);
        bundle.putBoolean(Constant.IS_SETTINGS, isSettings);
        pinCodeFragment.setArguments(bundle);
        return pinCodeFragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_pin_code, container, false);
        ButterKnife.bind(this, view);

        context = getContext();

        ((AppCompatActivity) getActivity()).setSupportActionBar(toolbar);

        fragmentType = getArguments().getString(Constant.FRAGMENT_TYPE, Constant.ENTER_CODE);
        isSettings = getArguments().getBoolean(Constant.IS_SETTINGS, false);
        isSetNewPinCode = getArguments().getBoolean(Constant.NEW_PIN_CODE, false);


        if (fragmentType.equals(Constant.SET_CODE)) {
            ((AppCompatActivity) getActivity()).getSupportActionBar().setTitle(getString(R.string.set_passcode));
            enterPasscodeTextView.setText(getString(R.string.enter_a_passcode));
        } else {
            ((AppCompatActivity) getActivity()).getSupportActionBar().setTitle(getString(R.string.enter_passcode));
            enterPasscodeTextView.setText(getString(R.string.enter_your_passcode));
        }

        setHasOptionsMenu(true);

        updatePinCodeView();
        setNewPinAttempts = 0;

        return view;
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        inflater.inflate(R.menu.menu_pin_code_entry, menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

        switch (item.getItemId()) {
            case R.id.cancel_action:
                exitScreen();
                return true;
        }

        return super.onOptionsItemSelected(item);
    }


    private void updatePinCodeView(){
        pinCodeEditText.postDelayed(new Runnable() {
            @Override
            public void run() {
                pinCodeEditText.requestFocus();
                InputMethodManager imm = (InputMethodManager) context.getSystemService(Context.INPUT_METHOD_SERVICE);
                if(imm != null) {
                    imm.showSoftInput(pinCodeEditText, InputMethodManager.SHOW_IMPLICIT);
                }
            }
        }, 400);


        //get local variables
        final String pinCode = Settings.getPinCode(context);
        int attempts = Settings.getCurrentPinCodeAttempts(context);

        //Set attempts left view

        if(isSetNewPinCode) {
            enterPasscodeTextView.setText("Enter your current passcode");
        } else {
            attemptsTextView.setText(getAttemptsLeftText(attempts));
        }

        if (pinCode == null){
            attemptsTextView.setVisibility(View.GONE);
        }

        pinCodeEditText.setOnPinEnteredListener(new PinEntryEditText.OnPinEnteredListener() {
            @Override
            public void onPinEntered(CharSequence str) {

                String passcode = str.toString();
                //If there is no pin code set
                if (pinCode == null) {
                    if (setNewPinAttempts == 0){
                        setNewPinAttempts++;
                        pinCodeEditText.setText("");
                    } else {
                        attemptsTextView.setVisibility(View.VISIBLE);
                        attemptsTextView.setText(R.string.successfully_set_pin);
                        setNewPin(passcode);
                    }
                    //If we are setting a new code
                } else if (newPin) {
                    if (passcode.equalsIgnoreCase(pinCode)) {
                        showAlertView(getString(R.string.same_pin_code));
                        getActivity().onBackPressed();
                    } else {
                        showAlertView(getString(R.string.new_pin_success));
                        Settings.savePinCode(context, passcode);
                        getActivity().onBackPressed();
                    }
                    newPin = false;
                    //If user entered correct pin code
                } else if (passcode.equalsIgnoreCase(Settings.getPinCode(context))) {
                    if (isSetNewPinCode) {
                        attemptsTextView.setVisibility(View.INVISIBLE);
                        enterPasscodeTextView.setText("Enter new passcode");
                        pinCodeEditText.setText("");
                        newPin = true;
                        Settings.resetCurrentPinAttempts(context);
                        return;
                    } else {
                        attemptsTextView.setText(R.string.correct_pin_code);
                    }
                    if (pinCodeViewListener != null) {
                        pinCodeViewListener.onCorrectPinCode(true);
                    }
                    Settings.resetCurrentPinAttempts(context);
                } else {
                    wrongPinCode();
                }
            }
        });
    }

    @SuppressLint("DefaultLocale")
    private String getAttemptsLeftText(int attempts) {
        return String.format(Constant.ATTEMPTS_LEFT_FORMAT, attempts);
    }

    private void setNewPin(String passcode){
        Settings.savePinCode(context, passcode);
        pinCodeViewListener.onCorrectPinCode(true);
        Settings.resetCurrentPinAttempts(context);

        //Hide keyboard
        ((InputMethodManager) getActivity().getSystemService(Activity.INPUT_METHOD_SERVICE))
                .toggleSoftInput(InputMethodManager.SHOW_IMPLICIT, 0);

        getActivity().onBackPressed();
    }

    private void wrongPinCode(){
        increaseAttempts();

        int attempts = Settings.getCurrentPinCodeAttempts(context);
        String attemptsText = getAttemptsLeftText(attempts);
        attemptsTextView.setText(attemptsText);

        pinCodeEditText.setText("");
        if (attempts <= 0) {
            Settings.resetCurrentPinAttempts(context);
            if (isSettings) {
                Settings.setAppLocked(context, true);
                setCurrentNetworkTime();
            }
            pinCodeViewListener.onCorrectPinCode(false);
        }
    }

    private void setCurrentNetworkTime() {
        new GlobalNetworkTime().getCurrentNetworkTime(context, new GlobalNetworkTime.GetGlobalTimeCallback() {
            @Override
            public void onGlobalTime(Long time) {
                Settings.setAppLockedTime(context, String.valueOf(time));
            }
        });
    }

    private void showAlertView(String message){
        CustomGluuAlert gluuAlert = new CustomGluuAlert(getActivity());
        gluuAlert.setMessage(message);
        gluuAlert.setYesTitle(getActivity().getApplicationContext().getString(R.string.ok));
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

    public void increaseAttempts(){
        int attempts = Settings.getCurrentPinCodeAttempts(context);
        attempts--;
        Settings.setCurrentPinCodeAttempts(context, attempts);
    }

    private void exitScreen() {
        Settings.saveIsReset(context);
        getActivity().onBackPressed();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    public interface PinCodeViewListener{
        public void onNewPinCode(String pinCode);
        public void onCorrectPinCode(boolean isPinCodeCorrect);
    }

    public class Constant {
        public static final String FRAGMENT_TYPE = "code_type";
        public static final String NEW_PIN_CODE = "new_pin_code";
        public static final String IS_SETTINGS = "is_settings";


        public static final String ENTER_CODE = "enter_code";
        public static final String SET_CODE = "set_code";

        public static final String ATTEMPTS_LEFT_FORMAT = "%d attempts left";
    }
}
