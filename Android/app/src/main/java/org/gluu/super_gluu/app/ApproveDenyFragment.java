package org.gluu.super_gluu.app;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import org.apache.commons.codec.binary.StringUtils;
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
import java.util.Timer;
import java.util.TimerTask;

import SuperGluu.app.R;

public class ApproveDenyFragment extends Fragment implements View.OnClickListener{

    SimpleDateFormat isoDateTimeFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS");

    private Boolean isUserInfo = false;
    private LogInfo logInfo;
    private OxPush2Request push2Request;
    private GluuMainActivity.RequestProcessListener listener;

    private RelativeLayout relativeLayout;

    private Timer clock;
    private Handler handler;

    int sec = 40;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        final View rootView = inflater.inflate(R.layout.fragment_approve_deny, container, false);
        handler = initHandler(rootView);
        Button approveButton = (Button) rootView.findViewById(R.id.button_approve);
        Button denyButton = (Button) rootView.findViewById(R.id.button_deny);
        if (isUserInfo){
            View timerView = (View) rootView.findViewById(R.id.timer_view);
            TextView titleTextView = (TextView) rootView.findViewById(R.id.title_textView);
            timerView.setVisibility(View.GONE);
            titleTextView.setText(R.string.info);
            approveButton.setVisibility(View.GONE);
            denyButton.setVisibility(View.GONE);
        } else {
            rootView.findViewById(R.id.approve_deny_close_button).setVisibility(View.GONE);
            startClockTick(rootView);
        }

        relativeLayout = (RelativeLayout)rootView.findViewById(R.id.mainRelativeLayout);
        final RelativeLayout topRelativeLayout = (RelativeLayout)rootView.findViewById(R.id.topRelativeLayout);
        final LinearLayout buttonsLayout = (LinearLayout)rootView.findViewById(R.id.action_button_group);
        final DisplayMetrics metrics = new DisplayMetrics();
        WindowManager wm = (WindowManager) rootView.getContext().getSystemService(Context.WINDOW_SERVICE);
        wm.getDefaultDisplay().getMetrics(metrics);
        topRelativeLayout.post(new Runnable() {
                                   public void run() {
                                       int h = topRelativeLayout.getHeight();
                                       int h2 = buttonsLayout.getHeight();
                                       relativeLayout.setMinimumHeight(metrics.heightPixels - h*2 - h2 - 50);
                                   }
                               }
        );
        updateLogInfo(rootView);
        rootView.findViewById(R.id.approve_deny_close_button).setOnClickListener(this);
        approveButton.setOnClickListener(this);
        denyButton.setOnClickListener(this);

        return rootView;
    }

    private void updateLogInfo(View rootView){
        if (push2Request != null){
            TextView application = (TextView) rootView.findViewById(R.id.text_application_label);
            URL url = null;
            try {
                url = new URL(push2Request.getIssuer());
            } catch (MalformedURLException e) {
                e.printStackTrace();
            }
            String baseUrl = "Gluu Server " + url.getHost();
            application.setText(baseUrl);
            TextView applicationUrl = (TextView) rootView.findViewById(R.id.text_application_value);
            applicationUrl.setText(push2Request.getIssuer());
            TextView userName = (TextView) rootView.findViewById(R.id.text_user_name_label);
            userName.setText(push2Request.getUserName());
            TextView locationIP = (TextView) rootView.findViewById(R.id.location_ip);
            locationIP.setText(push2Request.getLocationIP());
            TextView locationAddress = (TextView) rootView.findViewById(R.id.location_address);
            if (push2Request.getLocationCity() != null) {
                try {
                    locationAddress.setText(java.net.URLDecoder.decode(push2Request.getLocationCity(), "UTF-8"));
                } catch (UnsupportedEncodingException e) {
                    Log.d(this.getClass().getName(), e.getLocalizedMessage());
                }
            }
            TextView type = (TextView) rootView.findViewById(R.id.text_type);
            AndroidKeyDataStore dataStore = new AndroidKeyDataStore(getContext());
            final List<byte[]> keyHandles = dataStore.getKeyHandlesByIssuerAndAppId(push2Request.getIssuer(), push2Request.getApp());
            final boolean isEnroll = (keyHandles.size() == 0) || StringUtils.equals(push2Request.getMethod(), "enroll");
            if (isEnroll){
                type.setText("enroll");
            } else {
                type.setText(push2Request.getMethod());
            }
            TextView time = (TextView) rootView.findViewById(R.id.text_application_created_label);
            time.setText(getTimeFromString(push2Request.getCreated()));
            TextView date = (TextView) rootView.findViewById(R.id.text_created_value);
            date.setText(getDateFromString(push2Request.getCreated()));
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

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.button_approve){
            if (listener != null){
                listener.onApprove();
            }
            stopClocking();
            closeView();
        } else if (v.getId() == R.id.button_deny){
            if (listener != null){
                listener.onDeny();
            }
            stopClocking();
            closeView();
        } else {
//            stopClocking();
            closeView();
        }
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
        clock.cancel();
        clock = null;
    }

    private void closeView(){
        if (isUserInfo) {
            setIsButtonVisible(true);
            getActivity().invalidateOptionsMenu();
        }
        getFragmentManager().popBackStack();
    }

    public void setIsButtonVisible(Boolean isVsible){
        SharedPreferences preferences = getContext().getSharedPreferences("CleanLogsSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isCleanButtonVisible", isVsible);
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
}
