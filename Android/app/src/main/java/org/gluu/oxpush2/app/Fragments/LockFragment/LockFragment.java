package org.gluu.oxpush2.app.Fragments.LockFragment;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import org.gluu.oxpush2.app.Activities.GluuApplication;
import org.gluu.oxpush2.app.Activities.MainActivity;
import org.gluu.oxpush2.app.GluuMainActivity;
import org.gluu.oxpush2.app.R;
import org.gluu.oxpush2.net.NTP.SntpClient;

import java.net.UnknownHostException;
import java.util.Calendar;
import java.util.Timer;
import java.util.TimerTask;

/**
 * Created by nazaryavornytskyy on 4/20/16.
 */
public class LockFragment extends Fragment {

    private Timer clock;
    private Handler handler;
    private MainActivity.OnLockAppTimerOver listener;
    private Boolean isRecover;

    int min = 10;
    int sec = 0;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        super.onCreateView(inflater, container, savedInstanceState);

        final View rootView = inflater.inflate(R.layout.fragment_lock_app, container, false);

        handler = new Handler(){
            public void handleMessage(android.os.Message msg){
                if (min == 0 && sec == 0){
                    stopClocking();
                    resetCurrentPinAttempts();
                    if (listener != null){
                        listener.onTimerOver();
                    }
                }
                TextView minutes = (TextView) rootView.findViewById(R.id.locked_screen_minutes);
                TextView seconds = (TextView) rootView.findViewById(R.id.locked_screen_seconds);
                String minStr = min < 10 ? "0" + min + ":" : min + ":";
                String secStr = sec < 10 ? "0" + sec : String.valueOf(sec);
                minutes.setText(minStr);
                seconds.setText(secStr);
            }
        };
        if (isRecover) {
            min = 10;
            calculateTimeLeft();
        }
        startClockTick();

        return rootView;
    }

    private void startClockTick(){
        if (!isAppLocked() && min == 0 && sec == 0){
            if (listener != null){
                listener.onTimerOver();
            }
        }
        clock = new Timer();
        clock.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                if (sec == 0) {
                    min = min - 1;
                    min = min < 0 ? 0 : min;
                    sec = 60;
                }
                sec--;
                //send message to update UI
                handler.sendEmptyMessage(0);
            }
        }, 0, 1000);//put here time 1000 milliseconds=1 second
    }

    private void stopClocking(){
        if (clock != null) {
            clock.cancel();
            clock = null;
        }
    }

    public MainActivity.OnLockAppTimerOver getListener() {
        return listener;
    }

    public void setListener(MainActivity.OnLockAppTimerOver listener) {
        this.listener = listener;
    }

    private void calculateTimeLeft(){
        long currentTime = System.currentTimeMillis();
        try {
            currentTime = getCurrentNetworkTime();
        } catch (UnknownHostException e) {
            e.printStackTrace();
        }
        long lockedTime = Long.parseLong(getAppLockedTime());
        long diff = currentTime - lockedTime;
        long secondsInMilli = 1000;
        long minutesInMilli = secondsInMilli * 60;
        long elapsedMinutes = diff / minutesInMilli;
        diff = diff % minutesInMilli;
        long elapsedSeconds = diff / secondsInMilli;
        min = (int) (min - elapsedMinutes);
        sec = (min > 11 || min < 0) ? 0 : (int) elapsedSeconds;
        min = min < 0 ? 0 : min;
//        if (min == 0 && sec == 0){
//            setAppLocked(false);
//        }
    }

    private String getAppLockedTime(){
        SharedPreferences preferences = getContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        return preferences.getString("appLockedTime", "");
    }

    public static long getCurrentNetworkTime() throws UnknownHostException {
        SntpClient client = new SntpClient();
        int timeout = 50000;
        if (client.requestTime("time-a.nist.gov", timeout)) {
            long time = client.getNtpTime();
            Calendar calendar = Calendar.getInstance();
            calendar.setTimeInMillis(time);
            return calendar.getTimeInMillis();// this should be your date
        }
        return System.currentTimeMillis();
    }

    private Boolean isAppLocked(){
        SharedPreferences preferences = getContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        return preferences.getBoolean("isAppLocked", false);
    }

    private void setAppLocked(Boolean isLocked){
        SharedPreferences preferences = getContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isAppLocked", isLocked);
        editor.commit();
    }

    public void resetCurrentPinAttempts(){
        SharedPreferences preferences = getContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("currentPinCodeAttempts", String.valueOf(getPinCodeAttempts()));
        editor.commit();
    }

    public int getPinCodeAttempts(){
        SharedPreferences preferences = getContext().getSharedPreferences("PinCodeSettings", Context.MODE_PRIVATE);
        String pinCode = preferences.getString("pinCodeAttempts", "5");
        return Integer.parseInt(pinCode);
    }

    public Boolean getIsRecover() {
        return isRecover;
    }

    public void setIsRecover(Boolean isRecover) {
        this.isRecover = isRecover;
    }
}
