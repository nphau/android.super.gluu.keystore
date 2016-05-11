package org.gluu.oxpush2.app.GluuToast;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.media.Image;
import android.renderscript.Allocation;
import android.renderscript.Element;
import android.renderscript.RenderScript;
import android.renderscript.ScriptIntrinsicBlur;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import org.gluu.oxpush2.app.R;


/**
 * Created by nazaryavornytskyy on 5/10/16.
 */
public class GluuPushToastFactory {

    public static GluuPushToast makeText(Activity activity, long length, View.OnClickListener listener) {

        final View view = activity.getLayoutInflater().inflate(
                R.layout.gluu_push_toast,
                (ViewGroup) activity.getWindow().getDecorView(),
                false
        );
        view.findViewById(R.id.push_toast_deny_button).setOnClickListener(listener);
        view.findViewById(R.id.push_toast_approve_button).setOnClickListener(listener);

        ImageView pushImageView = (ImageView) view.findViewById(R.id.push_imageView);
        RelativeLayout backgroundLayout = (RelativeLayout) view.findViewById(R.id.push_toast_layout);
        BitmapDrawable drawable = (BitmapDrawable) pushImageView.getDrawable();
        Bitmap bitmap = drawable.getBitmap();
//        textView.setText("Radius: " + "" + radiusArr[position]);
        Bitmap blurred = blurRenderScript(activity.getBaseContext(), bitmap, 25);//second parametre is radius
        Drawable dBackground = new BitmapDrawable(activity.getResources(), blurred);
        backgroundLayout.setBackground(dBackground);
//        pushImageView.setImageBitmap(blurred);                          //radius decide blur amount


        final GluuPushToast toast = new GluuPushToast(activity, view);
        toast.setLength(length);
        return toast;
    }

    private static Bitmap blurRenderScript(Context context, Bitmap smallBitmap, int radius) {

        try {
            smallBitmap = RGB565toARGB888(smallBitmap);
        } catch (Exception e) {
            e.printStackTrace();
        }


        Bitmap bitmap = Bitmap.createBitmap(
                smallBitmap.getWidth(), smallBitmap.getHeight(),
                Bitmap.Config.ARGB_8888);

        RenderScript renderScript = RenderScript.create(context);

        Allocation blurInput = Allocation.createFromBitmap(renderScript, smallBitmap);
        Allocation blurOutput = Allocation.createFromBitmap(renderScript, bitmap);

        ScriptIntrinsicBlur blur = ScriptIntrinsicBlur.create(renderScript,
                Element.U8_4(renderScript));
        blur.setInput(blurInput);
        blur.setRadius(radius); // radius must be 0 < r <= 25
        blur.forEach(blurOutput);

        blurOutput.copyTo(bitmap);
        renderScript.destroy();

        return bitmap;

    }

    private static Bitmap RGB565toARGB888(Bitmap img) throws Exception {
        int numPixels = img.getWidth() * img.getHeight();
        int[] pixels = new int[numPixels];

        //Get JPEG pixels.  Each int is the color values for one pixel.
        img.getPixels(pixels, 0, img.getWidth(), 0, 0, img.getWidth(), img.getHeight());

        //Create a Bitmap of the appropriate format.
        Bitmap result = Bitmap.createBitmap(img.getWidth(), img.getHeight(), Bitmap.Config.ARGB_8888);

        //Set RGB pixels.
        result.setPixels(pixels, 0, result.getWidth(), 0, 0, result.getWidth(), result.getHeight());
        return result;
    }

}
