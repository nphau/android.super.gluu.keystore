package org.gluu.super_gluu.app.fragments.LogsFragment;

import android.app.Activity;
import android.graphics.Typeface;
import android.support.v4.content.ContextCompat;
import android.text.format.DateUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.TextView;

import org.gluu.super_gluu.app.ApproveDenyFragment;
import org.gluu.super_gluu.app.customGluuAlertView.CustomGluuAlert;
import org.gluu.super_gluu.app.LogState;
import SuperGluu.app.R;
import org.gluu.super_gluu.app.model.LogInfo;
import org.gluu.super_gluu.app.settings.Settings;
import org.gluu.super_gluu.model.OxPush2Request;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

/**
 * Created by nazaryavornytskyy on 4/5/16.
 */
public class LogsFragmentListAdapter extends BaseAdapter {

    private List<LogInfo> list;
    private List<LogInfo> selectedLogList = new ArrayList<>();
    private LayoutInflater mInflater;
    private LogsFragment.LogInfoListener mListener;
    private Activity activity;

    public Boolean isEditingMode = false;

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
    public View getView(final int position, View convertView, ViewGroup parent) {
        View view = convertView;

        if (view == null) {
            LayoutInflater inflater = mInflater;
            view = inflater.inflate(R.layout.fragment_log, null);
        }
        view.setTag(position);
        TextView contentView = (TextView) view.findViewById(R.id.content);
        List<LogInfo> logsFromDB = new ArrayList<LogInfo>(list);
        Collections.sort(logsFromDB, new Comparator<LogInfo>(){
            public int compare(LogInfo log1, LogInfo log2) {
                Date date1 = new Date(Long.valueOf(log1.getCreatedDate()));
                Date date2 = new Date(Long.valueOf(log2.getCreatedDate()));
                return date1.compareTo(date2);
            }
        });
        Collections.reverse(logsFromDB);
        list = logsFromDB;
        final LogInfo log = list.get(position);
        if (log.getLogState() == LogState.ENROL_FAILED || log.getLogState() == LogState.LOGIN_FAILED
                || log.getLogState() == LogState.UNKNOWN_ERROR || log.getLogState() == LogState.LOGIN_DECLINED){
            ImageView logo = (ImageView) view.findViewById(R.id.logLogo);
            contentView.setTextColor(ContextCompat.getColor(view.getContext(), R.color.redColor));
            logo.setImageResource(R.drawable.gluu_icon_red);
            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    CustomGluuAlert gluuAlert = new CustomGluuAlert(activity);
                    String message = log.getMessage() != null ? log.getMessage() : "Unknown error";
                    gluuAlert.setMessage(message);
                    gluuAlert.show();
                }
            });
        } else {
            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int position = (int) v.getTag();
                    ApproveDenyFragment approveDenyFragment = new ApproveDenyFragment();
                    approveDenyFragment.setIsUserInfo(true);
                    OxPush2Request request = oxPush2Adapter(list.get(position));
                    approveDenyFragment.setPush2Request(request);
                    if (mListener != null) {
//                        Settings.setIsBackButtonVisible(activity.getApplicationContext(), true);
                        Settings.setIsBackButtonVisibleForLog(activity.getApplicationContext(), true);
                        mListener.onKeyHandleInfo(approveDenyFragment);
                    }
                }
            });
        }
        String title = log.getIssuer();
            String timeAgo = (String) DateUtils.getRelativeTimeSpanString(Long.valueOf(log.getCreatedDate()), System.currentTimeMillis(),
                    DateUtils.MINUTE_IN_MILLIS);
            TextView createdTime = (TextView) view.findViewById(R.id.created_date);
            createdTime.setText(timeAgo);
        switch (log.getLogState()){
            case LOGIN_SUCCESS:
                title = "Logged in " + log.getIssuer();
                break;
            case ENROL_SUCCESS:
                title = "Enrol to " + log.getIssuer();
                break;
            case ENROL_DECLINED:
                title = "Declined enrol to " + log.getIssuer();
                break;
            case LOGIN_DECLINED:
                title = "Declined login to " + log.getIssuer();
                break;

            default:
                break;
        }
        contentView.setText(title);

        //Setup fonts
        Typeface face = Typeface.createFromAsset(activity.getAssets(), "ProximaNova-Regular.otf");
        Typeface faceTitle = Typeface.createFromAsset(activity.getAssets(), "ProximaNova-Semibold.otf");
        contentView.setTypeface(faceTitle);
        createdTime.setTypeface(face);

        //Show hide checkboxes depends on editing mode
        final CheckBox check = (CheckBox) view.findViewById(R.id.logCheckBox);
        check.setTag(position);
        check.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked){
                    selectedLogList.add(list.get((Integer) check.getTag()));
                } else {
                    LogInfo checkedLogInfo = list.get((Integer) check.getTag());
                    Iterator<LogInfo> iter = selectedLogList.iterator();
                    while (iter.hasNext()) {
                        LogInfo logInf = iter.next();
                        if (checkedLogInfo.getCreatedDate().equalsIgnoreCase(logInf.getCreatedDate())){
                            iter.remove();
                        }
                    }
                }
            }
        });
        if (isEditingMode){
            check.setVisibility(View.VISIBLE);
        } else {
            check.setVisibility(View.GONE);
        }

        return view;
    }

    private OxPush2Request oxPush2Adapter(LogInfo logInfo) {
        OxPush2Request request = new OxPush2Request();
        request.setUserName(logInfo.getUserName());
        request.setIssuer(logInfo.getIssuer());
        request.setLocationCity(logInfo.getLocationAddress());
        request.setLocationIP(logInfo.getLocationIP());
        request.setCreated(logInfo.getCreatedDate());
        request.setMethod(logInfo.getMethod());
        return request;
    }

    public void updateResults(List<LogInfo> results) {
        list = results;
        //Triggers the list update
        notifyDataSetChanged();
//        Settings.setIsButtonVisible(activity.getApplicationContext(), list.size() != 0);
    }

    public List<LogInfo> getSelectedLogList(){
        return selectedLogList;
    }
}
