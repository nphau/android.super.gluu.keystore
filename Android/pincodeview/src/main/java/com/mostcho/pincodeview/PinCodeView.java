package com.mostcho.pincodeview;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.LayerDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.OvalShape;
import android.graphics.drawable.shapes.RectShape;
import android.os.Build;
import android.text.Editable;
import android.text.InputFilter;
import android.text.InputType;
import android.text.TextWatcher;
import android.text.method.PasswordTransformationMethod;
import android.util.AttributeSet;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

/**
 * Created by mostcho.
 */
public class PinCodeView extends LinearLayout {
    // ---------------------------------------------------------------------------------------------
    // Constants
    // ---------------------------------------------------------------------------------------------
    private static final String TAG = PinCodeView.class.getSimpleName();

    private static final int BOX_SIZE_DP = 70; //dp
    private static final int BOX_MARGIN_DP = 8; //dp
    private static final int BOX_TEXT_COLOR = Color.BLACK;
    private static final int BOX_TEXT_SIZE = 1; //sp
    private static final int BOX_SECURITY_DOT_INSET = 18; //dp
    private static final boolean BOX_CURSOR_VISIBLE = false;

    private static final int WARNING_MSG_TEXT_SIZE = 20; //sp
    private static final int WARNING_MSG_MARGIN_DP = 8; //dp

    private static final int DEFAULT_WRONG_ENTERED_PINCODES_COUNT = 5;

    public static class PinCodeMode {
        public static final int SET_NEW_PINCODE = 0;
        public static final int VERIFY_PINCODE = 1;
    }

    // ---------------------------------------------------------------------------------------------
    // Fields
    // ---------------------------------------------------------------------------------------------
    private TextView mTvInfoMessage;
    private LinearLayout mLlPinCodeBoxesHolder;

    private EditText mEtPinBox1;
    private EditText mEtPinBox2;
    private EditText mEtPinBox3;
    private EditText mEtPinBox4;

    private Drawable mPinBoxEmpty;
    private Drawable mPinBoxFilled;

    private String mDefaultPinCode = "0000";

    private int mWrongEnteredPinCodesCount = 0;
    private int mDefaultWrongEnteredPinCodesCount = DEFAULT_WRONG_ENTERED_PINCODES_COUNT;

    private int mPinCodeViewMode = PinCodeMode.VERIFY_PINCODE;

    private IPinCodeViewListener mListener;

    // ---------------------------------------------------------------------------------------------
    // Constructors
    // ---------------------------------------------------------------------------------------------

    /**
     * Default constructor.
     *
     * @param context
     */
    public PinCodeView(Context context) {
        super(context);
        mTvInfoMessage = new TextView(context);
        mLlPinCodeBoxesHolder = new LinearLayout(context);
        mEtPinBox1 = new EditText(context);
        mEtPinBox2 = new EditText(context);
        mEtPinBox3 = new EditText(context);
        mEtPinBox4 = new EditText(context);
        initPinCodeView();
    }

    /**
     * Default constructor.
     *
     * @param context
     * @param attrs
     */
    public PinCodeView(Context context, AttributeSet attrs) {
        super(context, attrs);
        mTvInfoMessage = new TextView(context, attrs);
        mLlPinCodeBoxesHolder = new LinearLayout(context, attrs);
        mEtPinBox1 = new EditText(context, attrs);
        mEtPinBox2 = new EditText(context, attrs);
        mEtPinBox3 = new EditText(context, attrs);
        mEtPinBox4 = new EditText(context, attrs);
        initPinCodeView();
    }

    /**
     * Default constructor.
     *
     * @param context
     * @param attrs
     * @param defStyleAttr
     */
    public PinCodeView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        mTvInfoMessage = new TextView(context, attrs, defStyleAttr);
        mLlPinCodeBoxesHolder = new LinearLayout(context, attrs, defStyleAttr);
        mEtPinBox1 = new EditText(context, attrs, defStyleAttr);
        mEtPinBox2 = new EditText(context, attrs, defStyleAttr);
        mEtPinBox3 = new EditText(context, attrs, defStyleAttr);
        mEtPinBox4 = new EditText(context, attrs, defStyleAttr);
        initPinCodeView();
    }

    // ---------------------------------------------------------------------------------------------
    // Public methods
    // ---------------------------------------------------------------------------------------------

    /**
     * Add the PinCodeView.IPinCodeViewListener in order to receive back information from
     * the PinCodeView.
     *
     * @param context Activity implementing PinCodeView.IPinCodeViewListener.
     */
    public void setCompletionListener(Context context) {
        if (context instanceof IPinCodeViewListener) {
            mListener = (IPinCodeViewListener) context;
        } else {
            throw new RuntimeException(context.toString() + " must implement " +
                "IPinCodeViewListener");
        }
    }

    /**
     * Set PinCodeView operation mode. Modes are SET_NEW_PINCODE and VERIFY_PINCODE.
     * SET_NEW_PINCODE is used only for creating new pin code. The result is passed like String in
     * the IPinCodeViewListener.onNewPinCode().
     * VERIFY_PINCODE is used to check the default pin code with the new entered one. The result is
     * passed like true/false in the method IPinCodeViewListener.onCorrectPinCode().
     *
     * @param pinCodeViewMode On of the items from PinCodeView.PinCodeMode.
     */
    public void setPinCodeMode(int pinCodeViewMode) {
        mPinCodeViewMode = pinCodeViewMode;
    }

    /**
     * Default pin code witch is used for verification with the entered codes.
     *
     * @param pinCode
     */
    public void setDefaultPinCode(String pinCode) {
        mDefaultPinCode = pinCode;
    }

    /**
     * Set visibility of the info message below pin boxes.
     *
     * @param isVisible
     */
    public void setPinViewInfoMessageVisable(boolean isVisible) {
        if (isVisible) {
            mTvInfoMessage.setVisibility(VISIBLE);
        } else {
            mTvInfoMessage.setVisibility(GONE);
        }
    }

    /**
     * Set the count of retries to enter the correct pin. After the count is reached the result is
     * passed as false value in the IPinCodeViewListener.onCorrectPinCode(). It should be handled
     * after going to this method.
     *
     * @param count Retries count.
     */
    public void setWrongEnteredPinCodesCount(int count) {
        mDefaultWrongEnteredPinCodesCount = count;
    }

    /**
     * Reset pin boxes in there initial state. PinCodeMode is NOT affected by calling this method.
     */
    public void resetPinCodeBoxes() {
        Log.d(TAG, "Resetting pin boxes");
        mEtPinBox1.setText("");
        mEtPinBox2.setText("");
        mEtPinBox3.setText("");
        mEtPinBox4.setText("");

        mEtPinBox1.setFocusableInTouchMode(true);
        mEtPinBox2.setFocusableInTouchMode(false);
        mEtPinBox3.setFocusableInTouchMode(false);
        mEtPinBox4.setFocusableInTouchMode(false);

        mEtPinBox1.requestFocus();
    }

    /**
     * Reset PinCodeView info message. Pin boxes and PinCodeMode are NOT affected by this method.
     */
    public void resetInfoMessage() {
        mTvInfoMessage.setText("");
    }

    // ---------------------------------------------------------------------------------------------
    // Private methods
    // ---------------------------------------------------------------------------------------------
    private void initPinCodeView() {
        setOrientation(VERTICAL);
        setGravity(VERTICAL);

        createPinCodeViewFields();
        addView(mLlPinCodeBoxesHolder);

        createWarningMessage();
        addView(mTvInfoMessage);
    }

    private void createPinCodeViewFields() {
        LayoutParams params = new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        mLlPinCodeBoxesHolder.setLayoutParams(params);
        mLlPinCodeBoxesHolder.setOrientation(HORIZONTAL);

        mPinBoxEmpty = createEmptyPinBoxBackground();
        mPinBoxFilled = createFilledPinBoxBackground();

        mEtPinBox1 = createPinBox(mEtPinBox1);
        mEtPinBox2 = createPinBox(mEtPinBox2);
        mEtPinBox3 = createPinBox(mEtPinBox3);
        mEtPinBox4 = createPinBox(mEtPinBox4);

        mLlPinCodeBoxesHolder.addView(mEtPinBox1);
        mLlPinCodeBoxesHolder.addView(mEtPinBox2);
        mLlPinCodeBoxesHolder.addView(mEtPinBox3);
        mLlPinCodeBoxesHolder.addView(mEtPinBox4);

        resetPinCodeBoxes();

        mEtPinBox1.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                if (count == 0) {
                    mEtPinBox1.setSelection(0);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        mEtPinBox1.setBackground(mPinBoxEmpty);
                    } else {
                        mEtPinBox1.setBackgroundDrawable(mPinBoxEmpty);
                    }
                } else if (count == 1) {
                    mEtPinBox1.setSelection(1);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        mEtPinBox1.setBackground(mPinBoxFilled);
                    } else {
                        mEtPinBox1.setBackgroundDrawable(mPinBoxFilled);
                    }
                }
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (count == 1) {
                    Log.d(TAG, "PBox1 = " + s);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        mEtPinBox1.setBackground(mPinBoxFilled);
                    } else {
                        mEtPinBox1.setBackgroundDrawable(mPinBoxFilled);
                    }
                    mEtPinBox2.setFocusableInTouchMode(true);
                    mEtPinBox2.requestFocus();
                    mEtPinBox1.setFocusableInTouchMode(false);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.length() == 0) {
                    Log.d(TAG, "PBox1 = clear");
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        mEtPinBox1.setBackground(mPinBoxEmpty);
                    } else {
                        mEtPinBox1.setBackgroundDrawable(mPinBoxEmpty);
                    }
                    mEtPinBox1.setSelection(0);
                }
            }
        });
        mEtPinBox2.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                if (count == 0) {
                    mEtPinBox2.setSelection(0);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        mEtPinBox2.setBackground(mPinBoxEmpty);
                    } else {
                        mEtPinBox2.setBackgroundDrawable(mPinBoxEmpty);
                    }
                } else if (count == 1) {
                    mEtPinBox2.setSelection(1);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        mEtPinBox2.setBackground(mPinBoxFilled);
                    } else {
                        mEtPinBox2.setBackgroundDrawable(mPinBoxFilled);
                    }
                }
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (count == 1) {
                    Log.d(TAG, "PBox2 = " + s);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        mEtPinBox2.setBackground(mPinBoxFilled);
                    } else {
                        mEtPinBox2.setBackgroundDrawable(mPinBoxFilled);
                    }
                    mEtPinBox3.setFocusableInTouchMode(true);
                    mEtPinBox3.requestFocus();
                    mEtPinBox2.setFocusableInTouchMode(false);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.length() == 0) {
                    Log.d(TAG, "PBox2 = clear");
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        mEtPinBox2.setBackground(mPinBoxEmpty);
                    } else {
                        mEtPinBox2.setBackgroundDrawable(mPinBoxEmpty);
                    }
                    mEtPinBox1.setFocusableInTouchMode(true);
                    mEtPinBox1.requestFocus();
                    mEtPinBox2.setFocusableInTouchMode(false);
                }
            }
        });
        mEtPinBox3.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                if (count == 0) {
                    mEtPinBox3.setSelection(0);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        mEtPinBox3.setBackground(mPinBoxEmpty);
                    } else {
                        mEtPinBox3.setBackgroundDrawable(mPinBoxEmpty);
                    }
                } else if (count == 1) {
                    mEtPinBox3.setSelection(1);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        mEtPinBox3.setBackground(mPinBoxFilled);
                    } else {
                        mEtPinBox3.setBackgroundDrawable(mPinBoxFilled);
                    }
                }
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (count == 1) {
                    Log.d(TAG, "PBox3 = " + s);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        mEtPinBox3.setBackground(mPinBoxFilled);
                    } else {
                        mEtPinBox3.setBackgroundDrawable(mPinBoxFilled);
                    }
                    mEtPinBox4.setFocusableInTouchMode(true);
                    mEtPinBox4.requestFocus();
                    mEtPinBox3.setFocusableInTouchMode(false);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.length() == 0) {
                    Log.d(TAG, "PBox3 = clear");
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        mEtPinBox3.setBackground(mPinBoxEmpty);
                    } else {
                        mEtPinBox3.setBackgroundDrawable(mPinBoxEmpty);
                    }
                    mEtPinBox2.setFocusableInTouchMode(true);
                    mEtPinBox2.requestFocus();
                    mEtPinBox3.setFocusableInTouchMode(false);
                }
            }
        });
        mEtPinBox4.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                if (count == 0) {
                    mEtPinBox4.setSelection(0);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        mEtPinBox4.setBackground(mPinBoxEmpty);
                    } else {
                        mEtPinBox4.setBackgroundDrawable(mPinBoxEmpty);
                    }
                } else if (count == 1) {
                    mEtPinBox4.setSelection(1);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        mEtPinBox4.setBackground(mPinBoxFilled);
                    } else {
                        mEtPinBox4.setBackgroundDrawable(mPinBoxFilled);
                    }
                }
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (count == 1) {
                    Log.d(TAG, "PBox4 = " + s);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        mEtPinBox4.setBackground(mPinBoxFilled);
                    } else {
                        mEtPinBox4.setBackgroundDrawable(mPinBoxFilled);
                    }
                    Log.d(TAG, "Pin Code entered");
                    mEtPinBox4.setSelection(1);
                    if (mListener != null) {
                        switch (mPinCodeViewMode) {
                            case PinCodeMode.SET_NEW_PINCODE:
                                Log.d(TAG, "PinCodeMode.SET_NEW_PINCODE = " + getPinCode());
                                mTvInfoMessage.setTextColor(Color.BLACK);
                                mTvInfoMessage.setText("Your new Pin Code is " + getPinCode());
                                mListener.onNewPinCode(getPinCode());
                                break;

                            case PinCodeMode.VERIFY_PINCODE:
                                Log.d(TAG, "PinCodeMode.VERIFY_PINCODE");
                                if (mDefaultPinCode.contentEquals(getPinCode())) {
                                    mWrongEnteredPinCodesCount = 0;
                                    mTvInfoMessage.setTextColor(Color.GREEN);
                                    mTvInfoMessage.setText("Pin Code verified");
                                    mListener.onCorrectPinCode(true);
                                } else {
                                    mWrongEnteredPinCodesCount++;
                                    if (mDefaultWrongEnteredPinCodesCount == mWrongEnteredPinCodesCount) {
                                        mWrongEnteredPinCodesCount = 0;
                                        mListener.onCorrectPinCode(false);
                                    } else {
                                        mTvInfoMessage.setTextColor(Color.RED);
                                        mTvInfoMessage.setText((mDefaultWrongEnteredPinCodesCount - mWrongEnteredPinCodesCount) + " entries left");
                                        resetPinCodeBoxes();
                                    }
                                }
                                break;
                        }
                    }
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.length() == 0) {
                    Log.d(TAG, "PBox4 = clear");
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        mEtPinBox4.setBackground(mPinBoxEmpty);
                    } else {
                        mEtPinBox4.setBackgroundDrawable(mPinBoxEmpty);
                    }
                    mEtPinBox3.setFocusableInTouchMode(true);
                    mEtPinBox3.requestFocus();
                    mEtPinBox4.setFocusableInTouchMode(false);
                }
            }
        });
    }

    private EditText createPinBox(EditText et) {
        int size = dpToPx(BOX_SIZE_DP);
        LayoutParams params = new LayoutParams(size, size);
        int margin = dpToPx(BOX_MARGIN_DP);
        params.setMargins(margin, margin, margin, margin);
        et.setLayoutParams(params);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
            et.setBackground(mPinBoxEmpty);
        } else {
            et.setBackgroundDrawable(mPinBoxEmpty);
        }
        et.setCursorVisible(BOX_CURSOR_VISIBLE);
        et.setGravity(VERTICAL);
        et.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_VARIATION_PASSWORD);
        et.setFilters(new InputFilter[]{new InputFilter.LengthFilter(4)});
        et.setTextColor(BOX_TEXT_COLOR);
        et.setTextSize(TypedValue.COMPLEX_UNIT_SP, BOX_TEXT_SIZE);
        et.setTransformationMethod(new AsteriskPasswordTransformationMethod());
        return et;
    }

    private void createWarningMessage() {
        LayoutParams params = new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        int margin = dpToPx(WARNING_MSG_MARGIN_DP);
        params.setMargins(margin, 0, margin, 0);
        mTvInfoMessage.setLayoutParams(params);
        mTvInfoMessage.setGravity(Gravity.CENTER_HORIZONTAL);
        mTvInfoMessage.setTextSize(WARNING_MSG_TEXT_SIZE);
    }

    private int dpToPx(int dp) {
        return (int) (dp * Resources.getSystem()
            .getDisplayMetrics().density);
    }

    private String getPinCode() {
        String pinCode = "";
        pinCode += mEtPinBox1.getText()
            .toString();
        pinCode += mEtPinBox2.getText()
            .toString();
        pinCode += mEtPinBox3.getText()
            .toString();
        pinCode += mEtPinBox4.getText()
            .toString();

        Log.d(TAG, "entered pinCode = " + pinCode);
        return pinCode;
    }

    private Drawable createEmptyPinBoxBackground() {
        ShapeDrawable rectangle = new ShapeDrawable(new RectShape());
        rectangle.getPaint()
            .setColor(Color.WHITE);
        return rectangle;
    }

    private Drawable createFilledPinBoxBackground() {
        ShapeDrawable rectangle = new ShapeDrawable(new RectShape());
        rectangle.getPaint()
            .setColor(Color.WHITE);

        ShapeDrawable oval = new ShapeDrawable(new OvalShape());
        oval.getPaint()
            .setColor(Color.BLACK);
        int ovalInset = dpToPx(BOX_SECURITY_DOT_INSET);

        Drawable[] layers = {rectangle, oval};
        LayerDrawable layerDrawable = new LayerDrawable(layers);
        layerDrawable.setLayerInset(1, ovalInset, ovalInset, ovalInset, ovalInset);
        return layerDrawable;
    }

    // ---------------------------------------------------------------------------------------------
    // Interfaces
    // ---------------------------------------------------------------------------------------------

    /**
     * Interface which comunicate with the states of the PinCode view and the Activity/Fragment.
     */
    public interface IPinCodeViewListener {
        void onNewPinCode(String pinCode);

        void onCorrectPinCode(boolean isPinCodeCorrect);
    }

    // ---------------------------------------------------------------------------------------------
    // Private classes
    // ---------------------------------------------------------------------------------------------
    private class AsteriskPasswordTransformationMethod extends PasswordTransformationMethod {
        @Override
        public CharSequence getTransformation(CharSequence source, View view) {
            return new PasswordCharSequence(source);
        }

        private class PasswordCharSequence implements CharSequence {
            private CharSequence mSource;

            public PasswordCharSequence(CharSequence source) {
                mSource = source; // Store char sequence
            }

            public char charAt(int index) {
                return '\u25CF'; // This is the important part
            }

            public int length() {
                return mSource.length(); // Return default
            }

            public CharSequence subSequence(int start, int end) {
                return mSource.subSequence(start, end); // Return default
            }
        }
    }

}