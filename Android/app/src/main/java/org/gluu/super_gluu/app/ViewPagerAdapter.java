package org.gluu.super_gluu.app;

import android.content.Context;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.LightingColorFilter;
import android.graphics.drawable.Drawable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.content.ContextCompat;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.style.ImageSpan;

import org.gluu.super_gluu.app.fragments.PageRootFragment;

import SuperGluu.app.R;

/**
 * Created by nazaryavornytskyy on 3/21/16.
 */
public class ViewPagerAdapter extends FragmentStatePagerAdapter {

    // Tab Titles
    private String tabTitles[] = new String[] { "Home", "Logs", "Keys" , "Settings"};
    final int PAGE_COUNT = tabTitles.length;
    Context context;

    public ViewPagerAdapter(FragmentManager fm) {
        super(fm);
    }

    public ViewPagerAdapter(FragmentManager fm, Context context) {
        super(fm);
        this.context = context;
    }

    @Override
    public int getCount() {
        return PAGE_COUNT;
    }

    @Override
    public Fragment getItem(int position) {
        PageRootFragment rootFragment = new PageRootFragment();
        switch (position) {
            case 0:
                return rootFragment.newInstance(FragmentType.FRAGMENT_TYPE.MAIN_FRAGMENT);//new MainActivityFragment();
            case 1:
                return rootFragment.newInstance(FragmentType.FRAGMENT_TYPE.LOGS_FRAGMENT);//new LogsRootFragment();//LogsFragment();
            case 2:
                return rootFragment.newInstance(FragmentType.FRAGMENT_TYPE.KEYS_FRAGMENT);//new KeysRootFragment();//KeyFragmentListFragment();
            case 3:
                return rootFragment.newInstance(FragmentType.FRAGMENT_TYPE.SETTINGS_FRAGMENT);//new SettingsRootFragment();//SettingsListFragment.createInstance();
        }
        return null;
    }

    @Override
    public CharSequence getPageTitle(int position) {
//        return tabTitles[position];
        SpannableStringBuilder sb = new SpannableStringBuilder("  " + tabTitles[position]); // space added before text for convenience
        Drawable drawable = null;
        ImageSpan span = null;
        int image = 0;
        ColorFilter filter;
        switch (position){
            case 0 :
                image = R.drawable.home_action;
                drawable = ContextCompat.getDrawable(context, image);
                drawable.setBounds(0, 0, drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight());
                filter = new LightingColorFilter( Color.rgb(1, 161, 97), Color.rgb(1, 161, 97));
                drawable.setColorFilter(filter);
                span = new ImageSpan(drawable, ImageSpan.ALIGN_BOTTOM);
                sb.setSpan(span, 0, 1, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

                return sb;
            case 1 :
                image = R.drawable.logs_action;
                drawable = ContextCompat.getDrawable(context, image);
                drawable.setBounds(0, 0, drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight());
                filter = new LightingColorFilter( Color.rgb(1, 161, 97), Color.rgb(1, 161, 97));
                drawable.setColorFilter(filter);
                span = new ImageSpan(drawable, ImageSpan.ALIGN_BOTTOM);
                sb.setSpan(span, 0, 1, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

                return sb;
            case 2 :
                image = R.drawable.keys_action;
                drawable = ContextCompat.getDrawable(context, image);
                drawable.setBounds(0, 0, drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight());
                filter = new LightingColorFilter( Color.rgb(1, 161, 97), Color.rgb(1, 161, 97));
                drawable.setColorFilter(filter);
                span = new ImageSpan(drawable, ImageSpan.ALIGN_BOTTOM);
                sb.setSpan(span, 0, 1, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

                return sb;

            case 3 :
                image = R.drawable.settings_action;
                drawable = ContextCompat.getDrawable(context, image);
                drawable.setBounds(0, 0, drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight());
                filter = new LightingColorFilter( Color.rgb(1, 161, 97), Color.rgb(1, 161, 97));
                drawable.setColorFilter(filter);
                span = new ImageSpan(drawable, ImageSpan.ALIGN_BOTTOM);
                sb.setSpan(span, 0, 1, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

                return sb;
        }

        return null;
    }
}
