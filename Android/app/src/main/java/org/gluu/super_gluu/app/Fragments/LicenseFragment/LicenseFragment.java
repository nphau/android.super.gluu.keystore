package org.gluu.super_gluu.app.Fragments.LicenseFragment;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.text.method.ScrollingMovementMethod;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import org.gluu.super_gluu.app.KeyHandleInfoFragment;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

import SuperGluu.app.R;

/**
 * Created by nazaryavornytskyy on 3/22/16.
 */
public class LicenseFragment extends Fragment implements View.OnClickListener {

    OnMainActivityListener mainActivityListener;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.license_fragment, container, false);
        TextView licenseTextView = (TextView) view.findViewById(R.id.license_textView);
        licenseTextView.setText(readLicenseTxt());
        licenseTextView.setMovementMethod(new ScrollingMovementMethod());

        view.findViewById(R.id.accept_button).setOnClickListener(this);

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
