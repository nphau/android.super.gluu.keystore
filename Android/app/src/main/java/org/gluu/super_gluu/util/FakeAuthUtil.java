package org.gluu.super_gluu.util;

import android.content.Intent;

import org.gluu.super_gluu.app.GluuMainActivity;
import org.gluu.super_gluu.model.OxPush2Request;

/**
 * Created by SamIAm on 3/14/18.
 */

public abstract class FakeAuthUtil {

    private static final String QR_CODE_PUSH_NOTIFICATION_MESSAGE =
            GluuMainActivity.class.getPackage().getName() + ".QR_CODE_PUSH_NOTIFICATION_MESSAGE";
    private static final String QR_CODE_PUSH_NOTIFICATION = "QR_CODE_PUSH_NOTIFICATION";

    public static Intent getFakeAuthBroadcastIntent() {
        String message =
                "{\"app\":\"https://cred3.gluu.org/cred-manager\",\"method\":\"authenticate\",\"req_ip\":\"38.142.29.4\",\"created\":\"2018-03-14T19:41:29.094000\",\"issuer\":\"https://cred3.gluu.org\",\"req_loc\":\"United%20States%2C%20Texas%2C%20Houston\",\"state\":\"00f14ff3-e153-4f1f-a4c4-4587241b3b4d\",\"username\":\"eric3\"}\n";

        Intent intent = new Intent(QR_CODE_PUSH_NOTIFICATION);
        intent.putExtra(QR_CODE_PUSH_NOTIFICATION_MESSAGE, message);
        return intent;
    }

    public static OxPush2Request getFakeOXRequest() {
        OxPush2Request oxPush2Request =
                new OxPush2Request("eric3",
                        "https://cred3.gluu.org",
                        "https://cred3.gluu.org/cred-manager",
                        "00f14ff3-e153-4f1f-a4c4-4587241b3b4d",
                        "authenticate", "2018-03-14T19:41:29.094000",
                        null);
        oxPush2Request.setLocationCity("United%20States%2C%20Texas%2C%20Houston");
        oxPush2Request.setLocationIP("38.142.29.4");
        return oxPush2Request;
    }
}
