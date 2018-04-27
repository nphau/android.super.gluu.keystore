package org.gluu.super_gluu.app.fragment;

import android.app.Activity;
import android.text.format.DateUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.daimajia.swipe.SwipeLayout;

import org.gluu.super_gluu.app.LogState;
import org.gluu.super_gluu.app.model.LogInfo;
import org.gluu.super_gluu.app.settings.Settings;
import org.gluu.super_gluu.model.OxPush2Request;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import SuperGluu.app.R;

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
    public Boolean isSelectAllMode = false;

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
        ViewHolder holder;
        if (view == null) {
            view = mInflater.inflate(R.layout.fragment_log, parent, false);
            holder = new ViewHolder();
            View swipeView = view.findViewById(R.id.delete_layout);
            swipeView.setTag(position);
            holder.checkBox = view.findViewById(R.id.logCheckBox);
            holder.contentTextView = view.findViewById(R.id.content_text_view);
            holder.dateTextView = view.findViewById(R.id.created_date_text_view);
            holder.typeImageView = view.findViewById(R.id.log_item_image_view);
            holder.logMainView = view.findViewById(R.id.log_main_view);


            holder.deleteButton = swipeView.findViewById(R.id.swipe_delete_button);
            holder.showButton = swipeView.findViewById(R.id.swipe_show_button);
            holder.swipeLayout =  view.findViewById(R.id.swipe_layout);
            holder.index = position;

            holder.swipeLayout.addSwipeListener(new SwipeLayout.SwipeListener() {
                @Override
                public void onStartOpen(SwipeLayout layout) {

                }

                @Override
                public void onOpen(SwipeLayout layout) {
                    selectedLogList.add(list.get(position));
                }

                @Override
                public void onStartClose(SwipeLayout layout) {

                }

                @Override
                public void onClose(SwipeLayout layout) {
                    LogInfo checkedLogInfo = list.get(position);
                    Iterator<LogInfo> iter = selectedLogList.iterator();
                    while (iter.hasNext()) {
                        LogInfo logInf = iter.next();
                        if (checkedLogInfo.getCreatedDate().equalsIgnoreCase(logInf.getCreatedDate())){
                            iter.remove();
                        }
                    }
                }

                @Override
                public void onUpdate(SwipeLayout layout, int leftOffset, int topOffset) {

                }

                @Override
                public void onHandRelease(SwipeLayout layout, float xvel, float yvel) {

                }
            });
            view.setTag(holder);
        } else {
            holder = (ViewHolder) view.getTag();
        }
        LogInfo log = list.get(position);
        if (log.getLogState() == LogState.ENROL_FAILED || log.getLogState() == LogState.LOGIN_FAILED
                || log.getLogState() == LogState.UNKNOWN_ERROR || log.getLogState() == LogState.LOGIN_DECLINED || log.getLogState() == LogState.ENROL_DECLINED){
            holder.typeImageView.setImageResource(R.drawable.log_row_item_red_icon);
        } else {
            holder.typeImageView.setImageResource(R.drawable.log_row_item_green_icon);
        }

        holder.logMainView.setOnClickListener(v -> {
            OxPush2Request request = oxPush2Adapter(list.get(position));
            RequestDetailFragment requestDetailFragment =
                    RequestDetailFragment.newInstance(true, log, request, null);

            if (mListener != null) {
                Settings.setIsBackButtonVisibleForLog(activity.getApplicationContext(), true);
                mListener.onKeyHandleInfo(requestDetailFragment);
            }
        });
        String title = log.getIssuer();
            String timeAgo = (String) DateUtils.getRelativeTimeSpanString(Long.valueOf(log.getCreatedDate()), System.currentTimeMillis(),
                    DateUtils.MINUTE_IN_MILLIS);
            holder.dateTextView.setText(timeAgo);
        switch (log.getLogState()){
            case LOGIN_SUCCESS:
                title = "Logged in " + log.getIssuer();
                break;
            case ENROL_SUCCESS:
                title = "Enroll to " + log.getIssuer();
                break;
            case ENROL_DECLINED:
                title = "Declined enroll to " + log.getIssuer();
                break;
            case LOGIN_DECLINED:
                title = "Declined login to " + log.getIssuer();
                break;

            default:
                break;
        }
        holder.contentTextView.setText(title);

        final String item = log.getUserName();
        if (item != null) {

            holder.deleteButton.setOnClickListener(v -> {
                if (mListener != null) {
                    mListener.onDeleteLogEvent();
                }
            });
            holder.showButton.setOnClickListener(v -> {
                OxPush2Request request = oxPush2Adapter(list.get(position));
                RequestDetailFragment requestDetailFragment =
                        RequestDetailFragment.newInstance(true, log, request, null);
                requestDetailFragment.setPush2Request(request);
                if (mListener != null) {
                    Settings.setIsBackButtonVisibleForLog(activity.getApplicationContext(), true);
                    mListener.onKeyHandleInfo(requestDetailFragment);
                }
            });
        }

        holder.checkBox.setChecked(selectedLogList.size() > 0);
        LogInfo checkedLogInfo = (LogInfo) getItem(position);
        for (LogInfo logInf : new ArrayList<>(selectedLogList)){
            if (isSelectAllMode){
                holder.checkBox.setChecked(isSelectAllMode);
            } else {
                holder.checkBox.setChecked(checkedLogInfo.getCreatedDate().equalsIgnoreCase(logInf.getCreatedDate()));
            }
        }
        holder.checkBox.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (holder.checkBox.isPressed()) {
                if (isChecked) {
                    selectedLogList.add((LogInfo) getItem(position));
                } else {
                    LogInfo checkedLogInfo1 = list.get(position);
                    Iterator<LogInfo> iter = selectedLogList.iterator();
                    while (iter.hasNext()) {
                        LogInfo logInf = iter.next();
                        if (checkedLogInfo1.getCreatedDate().equalsIgnoreCase(logInf.getCreatedDate())) {
                            iter.remove();
                        }
                    }
                }
            }
        });
        if (isEditingMode){
            holder.checkBox.setVisibility(View.VISIBLE);
        } else {
            holder.checkBox.setVisibility(View.GONE);
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
    }

    public List<LogInfo> getSelectedLogList(){
        return selectedLogList;
    }

    public void selectAllLogs(){
        selectedLogList.clear();
        selectedLogList.addAll(list);
    }

    public void deSelectAllLogs(){
        selectedLogList.clear();
    }

    private class ViewHolder {
        int index;
        RelativeLayout logMainView;
        ImageView typeImageView;
        CheckBox checkBox;
        TextView contentTextView;
        TextView dateTextView;
        RelativeLayout deleteButton;
        RelativeLayout showButton;
        SwipeLayout swipeLayout;
    }
}
