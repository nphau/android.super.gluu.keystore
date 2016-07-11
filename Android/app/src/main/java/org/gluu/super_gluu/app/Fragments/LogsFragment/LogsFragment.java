package org.gluu.super_gluu.app.Fragments.LogsFragment;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.LocalBroadcastManager;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ListView;
import android.widget.TextView;

import org.gluu.super_gluu.app.ApproveDenyFragment;
import SuperGluu.app.R;
import org.gluu.super_gluu.app.model.LogInfo;
import org.gluu.super_gluu.store.AndroidKeyDataStore;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;

/**
 * Created by nazaryavornytskyy on 3/22/16.
 */
public class LogsFragment extends Fragment {

    private LogsFragmentListAdapter listAdapter;
    private AndroidKeyDataStore dataStore;
    private LogInfoListener mListener;
    private ListView listView;
    private List<LogInfo> logs;

    private BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            // Get extra data included in the Intent
//            String message = intent.getStringExtra("message");
            logs = dataStore.getLogs();
            // fire the event
            listAdapter.updateResults(logs);
        }
    };

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        super.onCreateView(inflater, container, savedInstanceState);

        View rootView = inflater.inflate(R.layout.fragment_logs_list, container, false);

        listView = (ListView) rootView.findViewById(R.id.logs_listView);
        mListener = new LogInfoListener() {
            @Override
            public void onKeyHandleInfo(ApproveDenyFragment approveDenyFragment) {
                setIsButtonVisible(false);
                getActivity().invalidateOptionsMenu();
                FragmentTransaction transaction = getFragmentManager().beginTransaction();
                transaction.replace(R.id.logs_root_frame, approveDenyFragment);
                transaction.addToBackStack(null);
                transaction.commit();
            }
        };
        dataStore = new AndroidKeyDataStore(rootView.getContext());
        List<LogInfo> logsFromDB = new ArrayList<LogInfo>(dataStore.getLogs());
        Collections.sort(logsFromDB, new Comparator<LogInfo>(){
            public int compare(LogInfo log1, LogInfo log2) {
                Date date1 = new Date(Long.valueOf(log1.getCreatedDate()));
                Date date2 = new Date(Long.valueOf(log2.getCreatedDate()));
                return date1.compareTo(date2);
            }
        });
//        Collections.reverse(logsFromDB);
        logs = logsFromDB;
        listAdapter = new LogsFragmentListAdapter(getActivity(), logs, mListener);
        listView.setAdapter(listAdapter);
        listView.post(new Runnable() {
            @Override
            public void run() {
                // Select the last row so it will scroll into view...
                listView.setSelection(logs.size() - 1);
            }
        });
        TextView noLogs = (TextView) rootView.findViewById(R.id.noLogs_textView);
        DisplayMetrics metrics = new DisplayMetrics();
        WindowManager wm = (WindowManager) rootView.getContext().getSystemService(Context.WINDOW_SERVICE);
        wm.getDefaultDisplay().getMetrics(metrics);
        noLogs.setY(metrics.heightPixels/3);
        listView.setEmptyView(noLogs);

        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(mMessageReceiver,
                new IntentFilter("reload-logs"));

        return rootView;
    }

    public void setIsButtonVisible(Boolean isVsible){
        SharedPreferences preferences = getContext().getSharedPreferences("CleanLogsSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isCleanButtonVisible", isVsible);
        editor.commit();
    }

    public interface LogInfoListener {
        void onKeyHandleInfo(ApproveDenyFragment approveDenyFragment);
    }

}
