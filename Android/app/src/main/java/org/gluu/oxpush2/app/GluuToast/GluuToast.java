package org.gluu.oxpush2.app.GluuToast;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import org.gluu.oxpush2.app.R;

/**
 * Created by nazaryavornytskyy on 4/25/16.
 */
public class GluuToast extends Toast {

    private Context context;

    /**
     * Construct an empty Toast object.  You must call {@link #setView} before you
     * can call {@link #show}.
     *
     * @param context The context to use.  Usually your {@link Application}
     *                or {@link Activity} object.
     */
    public GluuToast(Context context) {
        super(context);
        this.context = context;
    }


    public void showGluuToastWithText(View layout, String text){

        // set a message
        TextView textView = (TextView) layout.findViewById(R.id.toast_text);
        textView.setText(text);

        // Toast...
        Toast toast = new Toast(context);
        toast.setGravity(Gravity.TOP, 0, 180);
        toast.setDuration(Toast.LENGTH_SHORT);
        toast.setView(layout);
        toast.show();
    }
}
