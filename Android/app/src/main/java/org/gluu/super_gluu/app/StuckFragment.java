package org.gluu.super_gluu.app;

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;

import org.gluu.super_gluu.app.fingerprint.Fingerprint;
import org.gluu.super_gluu.app.listener.EntrySelectedListener;

import SuperGluu.app.R;
import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by SamIAm on 3/27/18.
 */

public class StuckFragment extends Fragment {

    @BindView(R.id.image_view_fingerprint)
    ImageView fingerprintImageView;

    @BindView(R.id.button_enter_passcode)
    Button enterPasscodeButton;

    Fingerprint fingerprint;

    EntrySelectedListener stuckListener;

    private boolean showPinCode = false;
    private boolean showFingerprint = false;

    public static StuckFragment newInstance(boolean showPinCode, boolean showFingerprint) {
        StuckFragment stuckFragment = new StuckFragment();
        Bundle args = new Bundle();
        args.putBoolean(Constant.SHOW_PIN_CODE, showPinCode);
        args.putBoolean(Constant.SHOW_FINGERPRINT, showFingerprint);
        stuckFragment.setArguments(args);

        return stuckFragment;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof EntrySelectedListener) {
            stuckListener = (EntrySelectedListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement EntrySelectedListener");
        }
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {

        View rootView = inflater.inflate(R.layout.fragment_stuck, container, false);
        ButterKnife.bind(this, rootView);

        showPinCode = getArguments().getBoolean(Constant.SHOW_PIN_CODE);
        showFingerprint = getArguments().getBoolean(Constant.SHOW_FINGERPRINT);

        if(showPinCode) {
            enterPasscodeButton.setVisibility(View.VISIBLE);
        } else {
            enterPasscodeButton.setVisibility(View.GONE);
        }

        if(showFingerprint) {
            fingerprintImageView.setVisibility(View.VISIBLE);
        } else {
            fingerprintImageView.setVisibility(View.GONE);
        }

        enterPasscodeButton.setOnClickListener(view -> stuckListener.onPinCodeSelected());

        fingerprintImageView.setOnClickListener(view -> stuckListener.fingerPrintEntered());

        return rootView;
    }

    public static class Constant {
        public static final String SHOW_PIN_CODE = "show_pin_code";
        public static final String SHOW_FINGERPRINT = "show_fingerprint";
    }


}
