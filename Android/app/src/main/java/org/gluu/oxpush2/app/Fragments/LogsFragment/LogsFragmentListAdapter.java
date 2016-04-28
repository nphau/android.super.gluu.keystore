package org.gluu.oxpush2.app.Fragments.LogsFragment;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.support.v4.content.ContextCompat;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import org.gluu.oxpush2.app.ApproveDenyFragment;
import org.gluu.oxpush2.app.CustomGluuAlertView.CustomGluuAlert;
import org.gluu.oxpush2.app.LogState;
import org.gluu.oxpush2.app.R;
import org.gluu.oxpush2.app.model.LogInfo;
import org.gluu.oxpush2.u2f.v2.model.TokenEntry;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by nazaryavornytskyy on 4/5/16.
 */
public class LogsFragmentListAdapter extends BaseAdapter {

    private List<LogInfo> list;
    private LayoutInflater mInflater;
    private LogsFragment.LogInfoListener mListener;
    private Activity activity;

    public LogsFragmentListAdapter(Activity activity, List<LogInfo> logs, LogsFragment.LogInfoListener listener){
        this.list = logs;
        this.activity = activity;
        mInflater = LayoutInflater.from(activity);
        mListener = listener;
    }


    @Override
    public int getCount() {
        return list.size();
    }

    @Override
    public Object getItem(int position) {
        return list.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view = convertView;

        if (view == null) {
            LayoutInflater inflater = mInflater;
            view = inflater.inflate(R.layout.fragment_log, null);
        }

        TextView contentView = (TextView) view.findViewById(R.id.content);
        final LogInfo log = list.get(position);
        Button arrowButton = (Button) view.findViewById(R.id.arrow_button);
        arrowButton.setTag(position);
        if (log.getLogState() == LogState.ENROL_FAILED || log.getLogState() == LogState.LOGIN_FAILED
                || log.getLogState() == LogState.UNKNOWN_ERROR){
            ImageView logo = (ImageView) view.findViewById(R.id.logLogo);
            contentView.setTextColor(ContextCompat.getColor(view.getContext(), R.color.redColor));
            logo.setImageResource(R.drawable.gluu_icon_red);
            Button arrowButon = (Button) view.findViewById(R.id.arrow_button);
            arrowButon.setBackgroundResource(R.drawable.info_icon);
            arrowButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    CustomGluuAlert gluuAlert = new CustomGluuAlert(activity);
                    gluuAlert.setMessage(log.getMessage());
                    gluuAlert.show();
                }
            });
        } else {
            arrowButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int position = (int) v.getTag();
                    ApproveDenyFragment approveDenyFragment = new ApproveDenyFragment();
                    approveDenyFragment.setIsUserInfo(true);
                    approveDenyFragment.setLogInfo(list.get(position));
                    if (mListener != null) {
                        mListener.onKeyHandleInfo(approveDenyFragment);
                    }
                }
            });
        }
        String title = log.getIssuer();
        switch (log.getLogState()){
            case LOGIN_SUCCESS:
                title = "Logged in " + log.getIssuer();
                break;
            case ENROL_SUCCESS:
                title = "Enrol to " + log.getIssuer();
                break;

            default:
                break;
        }
        contentView.setText(title);

        return view;
    }

    public void updateResults(List<LogInfo> results) {
        list = results;
        //Triggers the list update
        notifyDataSetChanged();
    }
}
