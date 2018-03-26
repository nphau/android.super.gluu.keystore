package org.gluu.super_gluu.app.fragments.PinCodeFragment;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.TextView;
import android.widget.Toast;

import org.gluu.super_gluu.app.customGluuAlertView.CustomGluuAlert;
import org.gluu.super_gluu.app.services.GlobalNetworkTime;
import org.gluu.super_gluu.app.settings.Settings;
import org.gluu.super_gluu.u2f.v2.entry.Entry;
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

    private String initialPinCode = null;

    Context context;

    private EntryType entryType;
    private EntryLevel entryLevel = EntryLevel.ONE;

    public enum EntryType {
        SETTING_NEW, ENTERING_NORMAL, CHANGING_CURRENT
    }

    public enum EntryLevel {
        ONE, TWO
    }

    public PinCodeViewListener pinCodeViewListener;

    public static PinCodeFragment newInstance(EntryType entryType) {
        PinCodeFragment pinCodeFragment = new PinCodeFragment();
        Bundle bundle = new Bundle();
        bundle.putSerializable(Constant.ENTRY_TYPE, entryType);
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

        entryType = (EntryType) getArguments().getSerializable(Constant.ENTRY_TYPE);

        if (entryType == EntryType.SETTING_NEW || entryType == EntryType.CHANGING_CURRENT) {
            ActionBar actionBar = ((AppCompatActivity) getActivity()).getSupportActionBar();
            if(actionBar != null) {
                actionBar.setTitle(getString(R.string.set_passcode));
            }
        } else {
            ActionBar actionBar = ((AppCompatActivity) getActivity()).getSupportActionBar();
            if(actionBar != null) {
                actionBar.setTitle(getString(R.string.enter_passcode));
            }
        }

        setHasOptionsMenu(true);

        updatePinCodeView();

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
        pinCodeEditText.postDelayed(() -> {
            pinCodeEditText.requestFocus();
            InputMethodManager imm = (InputMethodManager) context.getSystemService(Context.INPUT_METHOD_SERVICE);
            if(imm != null) {
                imm.showSoftInput(pinCodeEditText, InputMethodManager.SHOW_IMPLICIT);
            }
        }, 400);


        final String pinCode = Settings.getPinCode(context);

        switch (entryType) {
            case SETTING_NEW:
                enterPasscodeTextView.setText(R.string.enter_your_passcode);
                break;
            case ENTERING_NORMAL:
                enterPasscodeTextView.setText(R.string.enter_your_passcode);
                break;
            case CHANGING_CURRENT:
                enterPasscodeTextView.setText(R.string.enter_your_old_passcode);
                break;
        }

        attemptsTextView.setVisibility(View.GONE);


        pinCodeEditText.setOnPinEnteredListener(str -> {
            handlePinCodeAttempt(str.toString(), pinCode);
        });
    }

    private void handlePinCodeAttempt(String enteredPinCode, String currentPinCode) {

        switch (entryType) {
            case SETTING_NEW:
                userSettingUpPinCode(enteredPinCode);
                break;
            case ENTERING_NORMAL:
                userEnteringNormalPincode(enteredPinCode, currentPinCode);
                break;
            case CHANGING_CURRENT:
                userChangingCurrentPinCode(enteredPinCode, currentPinCode);
                break;
        }

    }

    private void userSettingUpPinCode(String enteredPinCode) {
        if (entryLevel == EntryLevel.TWO) {
            //Re-entering the pin code to make sure it matches first code entered
            if (enteredPinCode.equalsIgnoreCase(initialPinCode)) {
                correctPinCode(enteredPinCode, getString(R.string.correct_pin_code));
            } else {
                initialPinCode = null;
                enterPasscodeTextView.setText(R.string.enter_your_passcode);
                entryLevel = EntryLevel.ONE;
                attemptsTextView.setVisibility(View.VISIBLE);
                attemptsTextView.setText(R.string.pin_codes_dont_match);
                pinCodeEditText.setText("");
            }
        } else if (entryLevel == EntryLevel.ONE) {
            //Entering the pin code for the first time
            initialPinCode = enteredPinCode;
            pinCodeEditText.setText("");
            attemptsTextView.setVisibility(View.INVISIBLE);
            enterPasscodeTextView.setText(R.string.re_enter_your_passcode);
            entryLevel = EntryLevel.TWO;
        }
    }

    private void userEnteringNormalPincode(String enteredPinCode, String currentPinCode) {
        if (enteredPinCode.equalsIgnoreCase(currentPinCode)) {
            //User entered correct pin code
            attemptsTextView.setVisibility(View.VISIBLE);
            attemptsTextView.setText(R.string.correct_pin_code);

            if (pinCodeViewListener != null) {
                pinCodeViewListener.onCorrectPinCode(true);
            }
            Settings.resetCurrentPinAttempts(context);
        } else {
            //User entered wrong pin code
            wrongPinCode();
        }
    }

    private void userChangingCurrentPinCode(String enteredPinCode, String currentPinCode) {
        if (entryLevel == EntryLevel.TWO) {
            //User already entered old passcode and are setting their new passcode
            correctPinCode(enteredPinCode, getString(R.string.code_changed));
        } else {
            //User is entering their old passcode before they can set their new passcode
            if (enteredPinCode.equalsIgnoreCase(currentPinCode)) {
                //User entered correct pin code
                attemptsTextView.setVisibility(View.GONE);
                enterPasscodeTextView.setText(R.string.enter_new_passcode);

                if (entryLevel == EntryLevel.ONE) {
                    pinCodeEditText.setText("");

                    entryLevel = EntryLevel.TWO;
                }
                Settings.resetCurrentPinAttempts(context);
            } else {
                //User entered incorrect pin code
                wrongPinCode();
            }
        }
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

    private void correctPinCode(String passcode, String correctText) {
        setNewPin(passcode);
        attemptsTextView.setVisibility(View.VISIBLE);
        attemptsTextView.setText(correctText);
    }

    private void wrongPinCode(){
        pinCodeEditText.setText("");
        attemptsTextView.setVisibility(View.VISIBLE);

        increaseAttempts();

        int attempts = Settings.getCurrentPinCodeAttempts(context);
        String attemptsText = getAttemptsLeftText(attempts);
        attemptsTextView.setText(attemptsText);

        pinCodeEditText.setText("");
        if (attempts <= 0) {
            Settings.resetCurrentPinAttempts(context);
            if (entryType == EntryType.CHANGING_CURRENT) {
                Settings.setAppLocked(context, true);
                setCurrentNetworkTime();
            }
            pinCodeViewListener.onCorrectPinCode(false);
        }
    }

    private void setCurrentNetworkTime() {
        new GlobalNetworkTime().getCurrentNetworkTime(context,
                time -> Settings.setAppLockedTime(context, String.valueOf(time)));
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

        public static final String ENTRY_TYPE = "entry_type";


        public static final String ENTER_CODE = "enter_code";
        public static final String SET_CODE = "set_code";

        public static final String ATTEMPTS_LEFT_FORMAT = "%d attempts left";
    }
}
