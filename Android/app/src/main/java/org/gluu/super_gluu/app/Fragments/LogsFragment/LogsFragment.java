package org.gluu.super_gluu.app.fragments.LogsFragment;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import org.gluu.super_gluu.app.ApproveDenyFragment;
import SuperGluu.app.R;
import butterknife.BindView;
import butterknife.ButterKnife;

import org.gluu.super_gluu.app.GluuMainActivity;
import org.gluu.super_gluu.app.base.ToolbarFragment;
import org.gluu.super_gluu.app.customGluuAlertView.CustomGluuAlert;
import org.gluu.super_gluu.app.model.LogInfo;
import org.gluu.super_gluu.store.AndroidKeyDataStore;
import org.gluu.super_gluu.util.FakeDataUtil;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;

/**
 * Created by nazaryavornytskyy on 3/22/16.
 */
public class LogsFragment extends ToolbarFragment {

    private LogsFragmentListAdapter listAdapter;
    private AndroidKeyDataStore dataStore;
    private LogInfoListener mListener;
    public ApproveDenyFragment.OnDeleteLogInfoListener deleteLogListener;
    private List<LogInfo> logs;

    @BindView(R.id.nav_drawer_toolbar)
    Toolbar toolbar;
    @BindView(R.id.noLogs_textView)
    TextView noLogsTextView;
    @BindView(R.id.logs_listView)
    ListView listView;
    @BindView(R.id.edit_container)
    RelativeLayout editContainer;
    @BindView(R.id.cancel_text_view)
    TextView cancelTextView;
    @BindView(R.id.delete_text_view)
    TextView deleteTextView;


    private BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            // Get extra data included in the Intent
//            String message = intent.getStringExtra("message");
            reloadLogs();
            // fire the event
            listAdapter.updateResults(logs);
        }
    };

    private BroadcastReceiver mEditingModeReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            // Get extra data included in the Intent
            Boolean editMode = intent.getBooleanExtra("isEditingMode", false);
            // fire the event
            listAdapter.isEditingMode = editMode;
            listAdapter.notifyDataSetChanged();
        }
    };

    private BroadcastReceiver mDeleteReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            showAlertView();
        }
    };

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        super.onCreateView(inflater, container, savedInstanceState);

        View rootView = inflater.inflate(R.layout.fragment_logs_list, container, false);

        ButterKnife.bind(this, rootView);

        setDefaultToolbar(toolbar, getString(R.string.logs), true);
        setHasOptionsMenu(true);

        dataStore = new AndroidKeyDataStore(getActivity().getApplicationContext());
        reloadLogs();
        mListener = new LogInfoListener() {
            @Override
            public void onKeyHandleInfo(ApproveDenyFragment approveDenyFragment) {
                setIsButtonVisible(false);
                getActivity().invalidateOptionsMenu();
                FragmentTransaction transaction = getFragmentManager().beginTransaction();
                transaction.replace(R.id.main_frame_layout, approveDenyFragment);
                transaction.addToBackStack(null);
                transaction.commit();
            }

            @Override
            public void onDeleteLogEvent() {
                showAlertView();
            }
        };

        cancelTextView.setOnClickListener(view -> {
            putScreenIntoViewMode();
            hideEditContainer();
        });

        deleteTextView.setOnClickListener(view -> showAlertView());


        listAdapter = new LogsFragmentListAdapter(getActivity(), logs, mListener);
        listView.setAdapter(listAdapter);
        listView.post(() -> {
            // Select the last row so it will scroll into view...
            listView.setSelection(0);//logs.size() - 1);
        });

        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(mMessageReceiver,
                new IntentFilter("reload-logs"));
        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(mEditingModeReceiver,
                new IntentFilter("editing-mode-logs"));
        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(mDeleteReceiver,
                new IntentFilter("on-delete-logs"));

        return rootView;
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        inflater.inflate(R.menu.menu_logs_list, menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

        switch (item.getItemId()) {
            case R.id.edit_action:
                putScreenIntoEditMode();
                showEditContainer();
                return true;
        }

        return super.onOptionsItemSelected(item);
    }

    private void showEditContainer() {
        editContainer.setVisibility(View.VISIBLE);
    }

    private void hideEditContainer() {
        editContainer.setVisibility(View.GONE);
    }

    private void putScreenIntoEditMode() {
        deselectAll();
        listAdapter.isEditingMode = true;
        listAdapter.notifyDataSetChanged();
    }

    private void putScreenIntoViewMode() {
        listAdapter.isEditingMode = false;
        listAdapter.notifyDataSetChanged();
    }


    private void deselectAll() {
        //Deselect all records
        listAdapter.isSelectAllMode = false;
        listAdapter.notifyDataSetChanged();
        listAdapter.deSelectAllLogs();
    }

    private void selectAll() {
        //Select all records
        listAdapter.isSelectAllMode = true;
        listAdapter.selectAllLogs();
        listAdapter.notifyDataSetChanged();
    }

    @Override
    public void onPause(){
        super.onPause();
        LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(mDeleteReceiver);
//        LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(mMessageReceiver);
//        LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(mEditingModeReceiver);
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof ApproveDenyFragment.OnDeleteLogInfoListener) {
            deleteLogListener = (ApproveDenyFragment.OnDeleteLogInfoListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnDeleteKeyHandleListener");
        }
    }

    private void reloadLogs(){
        List<LogInfo> logsFromDB = new ArrayList<LogInfo>(dataStore.getLogs());
        Collections.sort(logsFromDB, (log1, log2) -> {
            Date date1 = new Date(Long.valueOf(log1.getCreatedDate()));
            Date date2 = new Date(Long.valueOf(log2.getCreatedDate()));
            return date1.compareTo(date2);
        });
        Collections.reverse(logsFromDB);
        logs = logsFromDB;

        if(logs.size() == 0) {
            noLogsTextView.setVisibility(View.VISIBLE);
        } else {
            noLogsTextView.setVisibility(View.GONE);
        }

    }

    void showAlertView(){
        final Fragment frg = this;
        GluuMainActivity.GluuAlertCallback listener = new GluuMainActivity.GluuAlertCallback(){
            @Override
            public void onPositiveButton() {
                if (!listAdapter.getSelectedLogList().isEmpty() && deleteLogListener != null){
                    deleteLogListener.onDeleteLogInfo(listAdapter.getSelectedLogList());
                    FragmentTransaction ft = getFragmentManager().beginTransaction();
                    ft.detach(frg).attach(frg).commit();
                }
            }

            @Override
            public void onNegativeButton() {
                //Skip here
            }
        };
        CustomGluuAlert gluuAlert = new CustomGluuAlert(getActivity());
        if (listAdapter.getSelectedLogList().isEmpty()){
//            gluuAlert.setMessage(getActivity().getApplicationContext().getString(R.string.clear_log_empty_title));
            gluuAlert.setSub_title(getActivity().getApplicationContext().getString(R.string.clear_log_empty_title));
            gluuAlert.setYesTitle(getActivity().getApplicationContext().getString(R.string.ok));
        } else {
//            gluuAlert.setMessage(getActivity().getApplicationContext().getString(R.string.clear_log_title));
            gluuAlert.setSub_title(getActivity().getApplicationContext().getString(R.string.clear_log_title));
            gluuAlert.setYesTitle(getActivity().getApplicationContext().getString(R.string.yes));
            gluuAlert.setNoTitle(getActivity().getApplicationContext().getString(R.string.no));
        }
        gluuAlert.setmListener(listener);
        gluuAlert.show();
    }

    public void setIsButtonVisible(Boolean isVsible){
        SharedPreferences preferences = getContext().getSharedPreferences("CleanLogsSettings", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean("isCleanButtonVisible", isVsible);
        editor.commit();
    }

    public interface LogInfoListener {
        void onKeyHandleInfo(ApproveDenyFragment approveDenyFragment);
        void onDeleteLogEvent();
    }

}
