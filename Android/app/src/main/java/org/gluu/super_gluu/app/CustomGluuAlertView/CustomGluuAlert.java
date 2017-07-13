package org.gluu.super_gluu.app.customGluuAlertView;

import android.app.Activity;
import android.app.Dialog;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputFilter;
import android.text.TextWatcher;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import org.gluu.super_gluu.app.GluuMainActivity;
import SuperGluu.app.R;

/**
 * Created by nazaryavornytskyy on 4/15/16.
 */
public class CustomGluuAlert extends Dialog implements android.view.View.OnClickListener {

    private String title, message, yesTitle, noTitle;
//    private Activity activity;
    private Button yes, no;
    private GluuMainActivity.GluuAlertCallback mListener;
    private Boolean isTextView = false;
    private String text;

    public CustomGluuAlert(Activity a) {
        super(a);
//        this.activity = a;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.custom_gluu_alert);
        TextView title = (TextView) findViewById(R.id.alert_title_textView);
        TextView message = (TextView) findViewById(R.id.alert_message_textView);
        if (this.title != null && !this.title.isEmpty()){
            title.setText(this.title);
        }
        if (this.message != null && !this.message.isEmpty()){
            message.setText(this.message);
        }
        yes = (Button) findViewById(R.id.yes_button);
        if (this.yesTitle != null && !this.yesTitle.isEmpty()){
            yes.setText(this.yesTitle);
        } else {
            yes.setVisibility(View.GONE);
        }
        no = (Button) findViewById(R.id.no_button);
        if (this.noTitle != null && !this.noTitle.isEmpty()){
            no.setText(this.noTitle);
        } else {
            no.setVisibility(View.GONE);
        }
        final EditText textField = (EditText) findViewById(R.id.alert_textField);
        if (isTextView){
            textField.setVisibility(View.VISIBLE);
            textField.setFilters(new InputFilter[]{new InputFilter.LengthFilter(50)});
            textField.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {

                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                    text = String.valueOf(s);
                }

                @Override
                public void afterTextChanged(Editable s) {

                }
            });
        } else {
            textField.setVisibility(View.GONE);
        }
        yes.setOnClickListener(this);
        no.setOnClickListener(this);
        super.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.yes_button:
                if (mListener != null){
                     mListener.onPositiveButton();
                }
                dismiss();
                break;

            case R.id.no_button:
                if (mListener != null){
                    mListener.onNegativeButton();
                }
                dismiss();
                break;

        default:
            break;
        }
        dismiss();
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getYesTitle() {
        return yesTitle;
    }

    public void setYesTitle(String yesTitle) {
        this.yesTitle = yesTitle;
    }

    public String getNoTitle() {
        return noTitle;
    }

    public void setNoTitle(String noTitle) {
        this.noTitle = noTitle;
    }

    public Object getmListener() {
        return mListener;
    }

    public void setmListener(GluuMainActivity.GluuAlertCallback mListener) {
        this.mListener = mListener;
    }

    public Boolean getIsTextView() {
        return isTextView;
    }

    public void setIsTextView(Boolean isTextView) {
        this.isTextView = isTextView;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }
}
