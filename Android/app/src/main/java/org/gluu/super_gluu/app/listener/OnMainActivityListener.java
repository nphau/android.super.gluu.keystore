package org.gluu.super_gluu.app.listener;

import org.gluu.super_gluu.app.fragments.KeysFragment.KeyHandleInfoFragment;

/**
 * Created by SamIAm on 3/20/18.
 */

public interface OnMainActivityListener {

    void onMainActivity();
    void onShowPinFragment(boolean enterPinCode);
    void onShowKeyInfo(KeyHandleInfoFragment infoFragment);
}
