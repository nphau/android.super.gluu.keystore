package org.gluu.super_gluu.app.base;

import androidx.fragment.app.Fragment;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import android.view.MenuItem;

/**
 * Created by SamIAm on 3/16/18.
 */

public class ToolbarFragment extends Fragment {

    public void setDefaultToolbar(Toolbar toolbar, String titleText, boolean isHomeAsUpEnabled) {

        AppCompatActivity appCompatActivity = (AppCompatActivity) getActivity();
        if(appCompatActivity != null) {

            appCompatActivity.setSupportActionBar(toolbar);

            ActionBar actionBar = appCompatActivity.getSupportActionBar();

            if(actionBar != null) {
                appCompatActivity.getSupportActionBar().setTitle(titleText);
                appCompatActivity.getSupportActionBar().setDisplayHomeAsUpEnabled(isHomeAsUpEnabled);
                appCompatActivity.getSupportActionBar().setHomeButtonEnabled(isHomeAsUpEnabled);
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
