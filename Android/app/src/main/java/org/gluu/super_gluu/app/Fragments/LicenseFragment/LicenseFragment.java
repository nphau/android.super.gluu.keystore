package org.gluu.super_gluu.app.fragments.LicenseFragment;

import android.content.Context;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.LinearLayout;

import org.gluu.super_gluu.app.base.ToolbarFragment;
import org.gluu.super_gluu.app.fragments.KeysFragment.KeyHandleInfoFragment;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

import SuperGluu.app.R;
import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by nazaryavornytskyy on 3/22/16.
 */
public class LicenseFragment extends ToolbarFragment implements View.OnClickListener {

    OnMainActivityListener mainActivityListener;

    @BindView(R.id.nav_drawer_toolbar)
    Toolbar toolbar;

    @BindView(R.id.license_webView)
    WebView licenseWebView;

    @BindView(R.id.accept_button)
    Button acceptButton;

    private Boolean isFirstTimeLoading;

    public static LicenseFragment newInstance(boolean firstTimeLoading) {
        LicenseFragment licenseFragment = new LicenseFragment();
        Bundle bundle = new Bundle();
        bundle.putBoolean(Constant.IS_FIRST_TIME_LOADING, firstTimeLoading);
        licenseFragment.setArguments(bundle);

        return licenseFragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.license_fragment, container, false);

        ButterKnife.bind(this, view);

        isFirstTimeLoading = getArguments().getBoolean(Constant.IS_FIRST_TIME_LOADING);

        setupHomeAsUpEnabledToolbar(toolbar, getString(R.string.privacy_policy));
        setHasOptionsMenu(true);

        licenseWebView.loadDataWithBaseURL(null, readLicenseTxt(), "text/html", "UTF-8", null);


        acceptButton.setOnClickListener(this);
        LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) licenseWebView.getLayoutParams();
        if (!isFirstTimeLoading){
            acceptButton.setVisibility(View.GONE);
            //action_left_button.setVisibility(View.VISIBLE);
            params.weight = 0.25f;
        } else {
            //action_left_button.setVisibility(View.GONE);
            params.weight = 0.98f;
        }
        licenseWebView.setLayoutParams(params);

        return view;
    }

    private String readLicenseTxt(){

        InputStream inputStream = getResources().openRawResource(R.raw.license_eula);
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();

        int i;
        try {
            i = inputStream.read();
            while (i != -1)
            {
                byteArrayOutputStream.write(i);
                i = inputStream.read();
            }
            inputStream.close();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return byteArrayOutputStream.toString();
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnMainActivityListener) {
            mainActivityListener = (OnMainActivityListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnMainActivityListener");
        }
    }

    @Override
    public void onClick(View v) {
        mainActivityListener.onLicenseAgreement();
    }

    public interface OnMainActivityListener {
        void onLicenseAgreement();
        void onMainActivity();
        void onShowPinFragment(boolean enterPinCode);
        void onShowKeyInfo(KeyHandleInfoFragment infoFragment);
    }

    public class Constant {
        private static final String IS_FIRST_TIME_LOADING = "is_first_time_loading";
    }
}
