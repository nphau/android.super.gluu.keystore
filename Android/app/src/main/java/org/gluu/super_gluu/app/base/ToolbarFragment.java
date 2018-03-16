package org.gluu.super_gluu.app.base;

import android.support.v4.app.Fragment;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;

/**
 * Created by SamIAm on 3/16/18.
 */

public class ToolbarFragment extends Fragment {

    public void setupToolbar(Toolbar toolbar, String titleText) {

        AppCompatActivity appCompatActivity = (AppCompatActivity) getActivity();
        if(appCompatActivity != null) {

            appCompatActivity.setSupportActionBar(toolbar);

            //toolbar.setTitle(titleText);

            ActionBar actionBar = appCompatActivity.getSupportActionBar();

            if(actionBar != null) {
                appCompatActivity.getSupportActionBar().setTitle(titleText);
                appCompatActivity.getSupportActionBar().setDisplayHomeAsUpEnabled(true);
                appCompatActivity.getSupportActionBar().setHomeButtonEnabled(true);
                appCompatActivity.getSupportActionBar().setDisplayShowHomeEnabled(true);
            }
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

        if(item.getItemId() == android.R.id.home) {
            getActivity().onBackPressed();
            return false;
        }
        return super.onOptionsItemSelected(item);
    }
}
