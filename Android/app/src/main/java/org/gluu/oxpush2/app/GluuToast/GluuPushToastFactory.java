package org.gluu.oxpush2.app.GluuToast;

import android.app.Activity;
import android.view.View;
import android.view.ViewGroup;

import org.gluu.oxpush2.app.R;

/**
 * Created by nazaryavornytskyy on 5/10/16.
 */
public class GluuPushToastFactory {

    public static GluuPushToast makeText(
            Activity activity, long length, View.OnClickListener listener) {

        final View view = activity.getLayoutInflater().inflate(
                R.layout.gluu_push_toast,
                (ViewGroup) activity.getWindow().getDecorView(),
                false
        );
        view.findViewById(R.id.push_toast_deny_button).setOnClickListener(listener);
        view.findViewById(R.id.push_toast_approve_button).setOnClickListener(listener);

        final GluuPushToast toast = new GluuPushToast(activity, view);
        toast.setLength(length);
        return toast;
    }
}
