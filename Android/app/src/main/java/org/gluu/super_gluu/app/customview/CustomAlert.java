package org.gluu.super_gluu.app.customview;

import android.app.Activity;
import android.app.Dialog;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputFilter;
import android.text.TextWatcher;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import org.gluu.super_gluu.app.activities.MainNavDrawerActivity;
import org.gluu.super_gluu.app.NotificationType;

import SuperGluu.app.R;
import butterknife.BindView;
import butterknife.ButterKnife;

/**
 * Created by nazaryavornytskyy on 4/15/16.
 */
public class CustomAlert extends Dialog implements android.view.View.OnClickListener {

    private String subTitle, message, yesTitle, noTitle;
    private MainNavDrawerActivity.GluuAlertCallback listener;
    private Boolean isTextView = false;
    private String text;

    public NotificationType type;

    @BindView(R.id.alert_message_textView)
    TextView messageTextView;
    @BindView(R.id.alert_message_subText)
    TextView subTitleTextView;
    @BindView(R.id.alert_textField)
    EditText alertEditText;
    @BindView(R.id.yes_button)
    Button yesButton;
    @BindView(R.id.no_button)
    Button noButton;
    @BindView(R.id.actionbar_icon)
    ImageView alertImageView;
    @BindView(R.id.alert_buttons_view)
    LinearLayout alertButtonsContainer;

    public CustomAlert(Activity activity) {
        super(activity);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.custom_alert);

        ButterKnife.bind(this);

        if (subTitle != null && !subTitle.isEmpty()){
            subTitleTextView.setText(subTitle);
        }
        if (message != null && !message.isEmpty()){
            messageTextView.setText(message);
            if (subTitleTextView.getText().length() > 0){
                if(getContext().getResources() != null) {
                    messageTextView.setTextColor(
                            getContext().getResources().getColor(R.color.acceptGreen));
                }
                if (type == NotificationType.RENAME_KEY || type == NotificationType.DEFAULT){
                    Typeface face = Typeface.createFromAsset(
                            getContext().getAssets(), "ProximaNova-Semibold.otf");
                    messageTextView.setTypeface(face);
                    messageTextView.setTextSize(24);
                }
            } else {
                ViewGroup.MarginLayoutParams params = (ViewGroup.MarginLayoutParams) subTitleTextView.getLayoutParams();
                params.topMargin = 0;
                params.bottomMargin = 0;
                subTitleTextView.requestLayout();
            }
        }

        if (yesTitle != null && !yesTitle.isEmpty()){
            yesButton.setText(yesTitle);
        } else {
            yesButton.setVisibility(View.GONE);
        }

        if (noTitle != null && !noTitle.isEmpty()){
            noButton.setText(noTitle);
        } else {
            noButton.setVisibility(View.GONE);
        }
        if (yesButton.getVisibility() == View.GONE && noButton.getVisibility() == View.GONE){
            yesButton.setVisibility(View.VISIBLE);
            yesButton.setText(R.string.ok);
        }
        if (isTextView){
            alertEditText.setVisibility(View.VISIBLE);
            alertEditText.setFilters(new InputFilter[]{new InputFilter.LengthFilter(50)});
            alertEditText.addTextChangedListener(new TextWatcher() {
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
            alertEditText.setVisibility(View.GONE);
            ViewGroup.MarginLayoutParams params =
                    (ViewGroup.MarginLayoutParams) alertButtonsContainer.getLayoutParams();
            params.topMargin = 0;
            alertButtonsContainer.requestLayout();
        }
        yesButton.setOnClickListener(this);
        noButton.setOnClickListener(this);

        //Setup title icons
        if (type == NotificationType.RENAME_KEY){
            alertImageView.setImageResource(R.drawable.edit_key_icon);
        } else if (type == NotificationType.DEFAULT){
            alertImageView.setImageResource(R.drawable.default_alert_icon);
        }

        Window window = getWindow();

        if(window != null) {
            window.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        }

    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.yes_button:
                if (listener != null){
                    listener.onPositiveButton();
                }
                dismiss();
                break;

            case R.id.no_button:
                if (listener != null){
                    listener.onNegativeButton();
                }
                dismiss();
                break;

        default:
            break;
        }
        dismiss();
    }

    public void setSubTitle(String sub_title) {
        this.subTitle = sub_title;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public void setYesTitle(String yesTitle) {
        this.yesTitle = yesTitle;
    }

    public void setNoTitle(String noTitle) {
        this.noTitle = noTitle;
    }

    public void setListener(MainNavDrawerActivity.GluuAlertCallback listener) {
        this.listener = listener;
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
