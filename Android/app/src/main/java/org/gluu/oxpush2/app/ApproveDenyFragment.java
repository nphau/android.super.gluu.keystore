package org.gluu.oxpush2.app;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import org.gluu.oxpush2.app.model.LogInfo;
import org.gluu.oxpush2.model.OxPush2Request;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.Timer;
import java.util.TimerTask;

public class ApproveDenyFragment extends Fragment implements View.OnClickListener{

    private Boolean isUserInfo = false;
    private LogInfo logInfo;
    private OxPush2Request push2Request;
    private GluuMainActivity.RequestProcessListener listener;

    private Timer clock;
    private Handler handler;

    int sec = 40;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        final View rootView = inflater.inflate(R.layout.fragment_approve_deny, container, false);
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
            startClockTick();
        }
        updateLogInfo(rootView);
        rootView.findViewById(R.id.approve_deny_close_button).setOnClickListener(this);
        approveButton.setOnClickListener(this);
        denyButton.setOnClickListener(this);

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
        return rootView;
    }

    private void updateLogInfo(View rootView){
        if (logInfo != null){
            TextView application = (TextView) rootView.findViewById(R.id.text_application_label);
            URL url = null;
            try {
                url = new URL(logInfo.getIssuer());
            } catch (MalformedURLException e) {
                e.printStackTrace();
            }
            String baseUrl = "Gluu Server " + url.getHost();
            application.setText(baseUrl);
            TextView applicationUrl = (TextView) rootView.findViewById(R.id.text_application_value);
            applicationUrl.setText(logInfo.getIssuer());
            TextView userName = (TextView) rootView.findViewById(R.id.text_user_name_label);
            userName.setText(logInfo.getUserName());
            TextView locationIP = (TextView) rootView.findViewById(R.id.location_ip);
            locationIP.setText(logInfo.getLocationIP());
            TextView locationAddress = (TextView) rootView.findViewById(R.id.location_address);
            locationAddress.setText(logInfo.getLocationAddress());
        }
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
            stopClocking();
            closeView();
        }
    }

    private void startClockTick(){
        clock = new Timer();
        clock.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                sec--;
                //send message to update UI
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
