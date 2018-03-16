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

/**
 * Created by nazaryavornytskyy on 3/22/16.
 */
public class LicenseFragment extends ToolbarFragment implements View.OnClickListener {

    OnMainActivityListener mainActivityListener;

    public Boolean getForFirstLoading() {
        return isForFirstLoading;
    }

    public void setForFirstLoading(Boolean forFirstLoading) {
        isForFirstLoading = forFirstLoading;
    }

    private Boolean isForFirstLoading = true;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.license_fragment, container, false);

        Toolbar toolbar = (Toolbar) view.findViewById(R.id.nav_drawer_toolbar);
        setupHomeAsUpEnabledToolbar(toolbar, getString(R.string.privacy_policy));
        setHasOptionsMenu(true);

        WebView licenseWebView = (WebView) view.findViewById(R.id.license_webView);
        licenseWebView.loadDataWithBaseURL(null, readLicenseTxt(), "text/html", "UTF-8", null);
//        licenseTextView.setMovementMethod(new ScrollingMovementMethod());

        Button acceptButton = (Button) view.findViewById(R.id.accept_button);

        acceptButton.setOnClickListener(this);
        LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) licenseWebView.getLayoutParams();
        if (!isForFirstLoading){
            acceptButton.setVisibility(View.GONE);
            //action_left_button.setVisibility(View.VISIBLE);
            params.weight = 0.25f;
        } else {
            //action_left_button.setVisibility(View.GONE);
            params.weight = 0.98f;
        }
        licenseWebView.setLayoutParams(params);
        //Setup fonts
        Typeface face = Typeface.createFromAsset(getActivity().getAssets(), "ProximaNova-Regular.otf");
        acceptButton.setTypeface(face);

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
        void onShowPinFragment();
        void onShowKeyInfo(KeyHandleInfoFragment infoFragment);
    }
}
