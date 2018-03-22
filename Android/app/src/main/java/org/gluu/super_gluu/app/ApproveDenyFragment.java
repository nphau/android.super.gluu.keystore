package org.gluu.super_gluu.app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.dinuscxj.progressbar.CircleProgressBar;

import org.apache.commons.codec.binary.StringUtils;
import org.gluu.super_gluu.app.base.ToolbarFragment;
import org.gluu.super_gluu.app.customGluuAlertView.CustomGluuAlert;
import org.gluu.super_gluu.app.model.LogInfo;
import org.gluu.super_gluu.model.OxPush2Request;
import org.gluu.super_gluu.store.AndroidKeyDataStore;
import org.gluu.super_gluu.util.Utils;

import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Timer;
import java.util.TimerTask;

import SuperGluu.app.R;
import butterknife.BindView;
import butterknife.ButterKnife;

public class ApproveDenyFragment extends ToolbarFragment {

    SimpleDateFormat isoDateTimeFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS");

    private Boolean isUserInfo = false;
    private LogInfo logInfo;
    private OxPush2Request push2Request;
    private GluuMainActivity.RequestProcessListener listener;
    public OnDeleteLogInfoListener deleteLogListener;

    private CircleProgressBar mLineProgressBar;

    private Timer clock;
    private Handler handler;

    private ImageView logo_imageView;

    int sec = 40;

    private BroadcastReceiver mDeleteReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            showAlertView();
        }
    };

    @BindView(R.id.nav_drawer_toolbar)
    Toolbar toolbar;

    @BindView(R.id.approve_layout)
    LinearLayout approveLayout;
    @BindView(R.id.deny_layout)
    LinearLayout denyLayout;

    @BindView(R.id.location_address_text_value)
    TextView addressTextView;
    @BindView(R.id.location_ip_text_value)
    TextView ipLocationTextView;
    @BindView(R.id.hour_minute_time_text_value)
    TextView hourMinuteTextView;
    @BindView(R.id.date_time_text_value)
    TextView dateTextView;
    @BindView(R.id.event_text_value)
    TextView eventTextView;
    @BindView(R.id.username_text_value)
    TextView usernameTextView;

    @BindView(R.id.application_text_view)
    TextView applicationTextView;

    @BindView(R.id.url_text_view)
    TextView urlTextView;

    @BindView(R.id.main_image_view)
    ImageView mainImageView;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        final View rootView = inflater.inflate(R.layout.fragment_approve_deny, container, false);

        ButterKnife.bind(this, rootView);
        handler = initHandler(rootView);
        mLineProgressBar = (CircleProgressBar) rootView.findViewById(R.id.line_progress);
        mLineProgressBar.setMax(sec);


        //Setup fonts
        if (isUserInfo){
            View timerView = (View) rootView.findViewById(R.id.timer_view);
            TextView timerTextView = (TextView) rootView.findViewById(R.id.timer_textView);
            timerView.setVisibility(View.GONE);
            timerTextView.setVisibility(View.GONE);
            approveLayout.setVisibility(View.GONE);
            denyLayout.setVisibility(View.GONE);
            mLineProgressBar.setVisibility(View.GONE);
        } else {
            RelativeLayout topRelativeLayout = (RelativeLayout) rootView.findViewById(R.id.custom_approve_deny_toolbar);
            ViewGroup.MarginLayoutParams params = (ViewGroup.MarginLayoutParams) topRelativeLayout.getLayoutParams();
            params.topMargin = 10;
            topRelativeLayout.requestLayout();
            startClockTick(rootView);
        }

        setHasOptionsMenu(true);

        if(isUserInfo) {
            setDefaultToolbar(toolbar, getString(R.string.log_details), true);
        } else {
            setDefaultToolbar(toolbar, getString(R.string.permission_approval), false);
        }

        updateLogInfo();
        updateLogo();
        approveLayout.setOnClickListener(view -> {
            if(listener != null) {
                listener.onApprove();
            }
            cleanUpViewAfterClick();
        });
        denyLayout.setOnClickListener(view -> {
            if(listener != null) {
                listener.onDeny();
            }
            cleanUpViewAfterClick();
        });

        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(mDeleteReceiver,
                new IntentFilter("on-delete-log-event"));

        return rootView;
    }

    @Override
    public void onResume() {
        super.onResume();
        if (sec == 0){
            listener.onDeny();
            closeView();
        }
    }

    @Override
    public void onPause(){
        super.onPause();
        LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(mDeleteReceiver);
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnDeleteLogInfoListener) {
            deleteLogListener = (OnDeleteLogInfoListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnDeleteKeyHandleListener");
        }
    }

    private void updateLogInfo(){
        if (push2Request != null){

            URL url = null;
            try {
                url = new URL(push2Request.getIssuer());
            } catch (MalformedURLException e) {
                e.printStackTrace();
            }
            String baseUrl = "Gluu Server " + url.getHost();
            applicationTextView.setText(baseUrl);

            urlTextView.setText(push2Request.getIssuer());

            usernameTextView.setText(push2Request.getUserName());

            ipLocationTextView.setText(push2Request.getLocationIP());
            if (push2Request.getLocationCity() != null) {
                try {
                    addressTextView.setText(java.net.URLDecoder.decode(push2Request.getLocationCity(), "UTF-8"));
                } catch (UnsupportedEncodingException e) {
                    Log.d(this.getClass().getName(), e.getLocalizedMessage());
                }
            }
            AndroidKeyDataStore dataStore = new AndroidKeyDataStore(getContext());
            final List<byte[]> keyHandles = dataStore.getKeyHandlesByIssuerAndAppId(push2Request.getIssuer(), push2Request.getApp());
            final boolean isEnroll = (keyHandles.size() == 0) || StringUtils.equals(push2Request.getMethod(), "enroll");
            eventTextView.setText(capitalize(push2Request.getMethod()));
            hourMinuteTextView.setText(getTimeFromString(push2Request.getCreated()));
            dateTextView.setText(getDateFromString(push2Request.getCreated()));
        }
    }

    private void updateLogo(){

        if(isUserInfo) {
            mainImageView.setImageDrawable(getContext().getDrawable(R.drawable.log_detail_icon));
        } else {
            mainImageView.setImageDrawable(getContext().getDrawable(R.drawable.accept_deny_detail_icon));
        }
    }

    private String getDateFromString(String dateString){
        SimpleDateFormat userDateTimeFormat = new SimpleDateFormat("MMM d, yyyy");
        Date createdDate = null;
        if (Utils.isNotEmpty(dateString)) {
            if (isUserInfo){
                Date resultdate = new Date(Long.valueOf(dateString));
                return userDateTimeFormat.format(resultdate);
            } else {
                try {
                    createdDate = isoDateTimeFormat.parse(dateString);
                } catch (ParseException ex) {
                    Log.e(this.getClass().getName(), "Failed to parse ISO date/time: " + dateString, ex);
                }
            }
        }

        String createdString = "";
        if (createdDate != null) {
            createdString = userDateTimeFormat.format(createdDate);
        }
        return createdString;
    }

    private String getTimeFromString(String dateString){
        SimpleDateFormat userDateTimeFormat = new SimpleDateFormat("HH:mm:ss");
        Date createdDate = null;
        if (Utils.isNotEmpty(dateString)) {
            if (isUserInfo){
                Date resultdate = new Date(Long.valueOf(dateString));
                return userDateTimeFormat.format(resultdate);
            } else {
                try {
                    createdDate = isoDateTimeFormat.parse(dateString);
                } catch (ParseException ex) {
                    Log.e(this.getClass().getName(), "Failed to parse ISO date/time: " + dateString, ex);
                }
            }
        }

        String createdString = "";
        if (createdDate != null) {
            createdString = userDateTimeFormat.format(createdDate);
        }
        return createdString;
    }

    public static String capitalize(String text){
        String c = (text != null)? text.trim() : "";
        String[] words = c.split(" ");
        String result = "";
        for(String w : words){
            result += (w.length() > 1? w.substring(0, 1).toUpperCase(Locale.US) + w.substring(1, w.length()).toLowerCase(Locale.US) : w) + " ";
        }
        return result.trim();
    }

    void showAlertView(){
        GluuMainActivity.GluuAlertCallback listener = new GluuMainActivity.GluuAlertCallback(){
            @Override
            public void onPositiveButton() {
                if (deleteLogListener != null){
                    deleteLogListener.onDeleteLogInfo(push2Request);
                }
//                android.support.v4.app.FragmentManager fm = getFragmentManager();
//                fm.popBackStack();
            }

            @Override
            public void onNegativeButton() {
                //Skip here
            }
        };
        CustomGluuAlert gluuAlert = new CustomGluuAlert(getActivity());
        gluuAlert.setMessage(getActivity().getApplicationContext().getString(R.string.clear_log_title));
        gluuAlert.setYesTitle(getActivity().getApplicationContext().getString(R.string.yes));
        gluuAlert.setNoTitle(getActivity().getApplicationContext().getString(R.string.no));
        gluuAlert.setmListener(listener);
        gluuAlert.show();
    }

    public Boolean getIsUserInfo() {
        return isUserInfo;
    }

    public void setIsUserInfo(Boolean isUserInfo) {
        this.isUserInfo = isUserInfo;
    }

    public LogInfo getLogInfo() {
        return logInfo;
    }

    public void setLogInfo(LogInfo logInfo) {
        this.logInfo = logInfo;
    }

    public void cleanUpViewAfterClick() {
        stopClocking();
        closeView();
    }

    private void startClockTick(final View rootView){
        clock = new Timer();
        clock.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                sec--;
                //send message to update UI
                if (handler == null){
                    handler = initHandler(rootView);
                }
                handler.sendEmptyMessage(0);
            }
        }, 0, 1000);//put here time 1000 milliseconds=1 second
    }

    private void stopClocking(){
        if (clock != null) {
            clock.cancel();
        }
        clock = null;
    }

    private void closeView(){
        setIsBackButtonVisible(false);
        if (isUserInfo) {
            setIsButtonVisible(true);
            getActivity().invalidateOptionsMenu();
        }
        try {
            getFragmentManager().popBackStack();
        }
        catch (RuntimeException ex){
            //ignore there
        }
    }

    public void setIsButtonVisible(Boolean isVsible){
        SharedPreferences preferences = getContext().getSharedPreferences("CleanLogsSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isCleanButtonVisible", isVsible);
        editor.commit();
    }

    public void setIsBackButtonVisible(Boolean isVsible){
        SharedPreferences preferences = getContext().getSharedPreferences("CleanLogsSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isBackButtonVisible", isVsible);
        editor.commit();
    }

    private Handler initHandler(final View rootView){
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                handler = new Handler(){
                    public void handleMessage(android.os.Message msg){
                        if (sec == 0){
                            stopClocking();
                            closeView();
                        }
                        mLineProgressBar.setProgress(sec);
                        TextView seconds = (TextView) rootView.findViewById(R.id.timer_textView);
                        String secStr = sec < 10 ? "0" + sec : String.valueOf(sec);
                        seconds.setText(secStr);
                    }
                };
            }
        });
        return handler;
    }

    public OxPush2Request getPush2Request() {
        return push2Request;
    }

    public void setPush2Request(OxPush2Request push2Request) {
        this.push2Request = push2Request;
    }

    public GluuMainActivity.RequestProcessListener getListener() {
        return listener;
    }

    public void setListener(GluuMainActivity.RequestProcessListener listener) {
        this.listener = listener;
    }

    public interface OnDeleteLogInfoListener {
        void onDeleteLogInfo(OxPush2Request oxPush2Request);
        void onDeleteLogInfo(List<LogInfo> logInfos);
    }
}
