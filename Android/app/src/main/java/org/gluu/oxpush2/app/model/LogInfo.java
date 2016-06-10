package org.gluu.oxpush2.app.model;

import android.util.Log;

import org.gluu.oxpush2.app.LogState;
import org.gluu.oxpush2.u2f.v2.entry.Entry;
import org.gluu.oxpush2.util.Utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created by nazaryavornytskyy on 4/19/16.
 */
public class LogInfo extends Entry{//} implements Comparable<LogInfo> {

//    SimpleDateFormat isoDateTimeFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS");

    private String locationIP;
    private String locationAddress;
    private String message;
    private LogState logState;
    private String method;

    public LogInfo() {
    }

    public LogInfo(String issuer, String userName, String locationIP, String locationAddress, String created) {
        setIssuer(issuer);
        setUserName(userName);
        setCreatedDate(created);
        this.locationIP = locationIP;
        this.locationAddress = locationAddress;
    }

    public String getLocationIP() {
        return locationIP;
    }

    public void setLocationIP(String locationIP) {
        this.locationIP = locationIP;
    }

    public String getLocationAddress() {
        return locationAddress;
    }

    public void setLocationAddress(String locationAddress) {
        this.locationAddress = locationAddress;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public LogState getLogState() {
        return logState;
    }

    public void setLogState(LogState logState) {
        this.logState = logState;
    }

    public String getMethod() {
        return method;
    }

    public void setMethod(String method) {
        this.method = method;
    }

}
