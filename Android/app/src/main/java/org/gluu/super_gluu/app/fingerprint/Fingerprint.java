package org.gluu.super_gluu.app.fingerprint;

import android.Manifest;
import android.app.KeyguardManager;
import android.content.Context;
import android.content.pm.PackageManager;
import android.hardware.fingerprint.FingerprintManager;
import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyPermanentlyInvalidatedException;
import android.security.keystore.KeyProperties;
import android.support.v4.app.ActivityCompat;
import android.view.LayoutInflater;
import android.view.View;
import org.gluu.super_gluu.app.GluuToast.GluuToast;
import java.io.IOException;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.UnrecoverableKeyException;
import java.security.cert.CertificateException;
import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;

import SuperGluu.app.R;

/**
 * Created by nazaryavornytskyy on 3/1/17.
 */
public class Fingerprint {

    private Context context;
    // Variable used for storing the key in the Android Keystore container
    private KeyStore keyStore;
    private static final String KEY_NAME = "androidHive";
    private Cipher cipher;
    private KeyguardManager keyguardManager;
    private FingerprintManager fingerprintManager;
    private FingerprintHandler helper;

    public Fingerprint(Context context) {
        this.context = context;

        // Initializing both Android Keyguard Manager and Fingerprint Manager
        keyguardManager = (KeyguardManager) context.getSystemService(Context.KEYGUARD_SERVICE);
        fingerprintManager = (FingerprintManager) context.getSystemService(Context.FINGERPRINT_SERVICE);
        helper = new FingerprintHandler(context);
    }

    public Boolean startFingerprintService() {
        // Check whether the device has a Fingerprint sensor
        if (!fingerprintManager.isHardwareDetected()) {
            /**
             * An error message will be displayed if the device does not contain the fingerprint hardware.
             * However if you plan to implement a default authentication method,
             * you can redirect the user to a default authentication activity from here.
             * Example:
             * Intent intent = new Intent(this, DefaultAuthenticationActivity.class);
             * startActivity(intent);
             */
            helper.showToast("Your Device does not have a Fingerprint Sensor");
            return false;
        } else {
            // Checks whether fingerprint permission is set on manifest
            if (ActivityCompat.checkSelfPermission(context, Manifest.permission.USE_FINGERPRINT) != PackageManager.PERMISSION_GRANTED) {
                helper.showToast("Fingerprint authentication permission not enabled");
                return false;
            }else{
                // Check whether at least one fingerprint is registered
                if (!fingerprintManager.hasEnrolledFingerprints()) {
                    helper.showToast("Register at least one fingerprint in Settings");
                    return false;
                }else{
                    // Checks whether lock screen security is enabled or not
                    if (!keyguardManager.isKeyguardSecure()) {
                        helper.showToast("Lock screen security not enabled in Settings");
                    }else{
                        generateKey();
                        if (cipherInit()) {
                            FingerprintManager.CryptoObject cryptoObject = new FingerprintManager.CryptoObject(cipher);

                            helper.startAuth(fingerprintManager, cryptoObject);
                        }
                    }
                    return true;
                }

            }
        }
    }

    protected void generateKey() {
        try {
            keyStore = KeyStore.getInstance("AndroidKeyStore");
        } catch (Exception e) {
            e.printStackTrace();
        }


        KeyGenerator keyGenerator;
        try {
            keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore");
        } catch (NoSuchAlgorithmException | NoSuchProviderException e) {
            throw new RuntimeException("Failed to get KeyGenerator instance", e);
        }


        try {
            keyStore.load(null);
            keyGenerator.init(new
                    KeyGenParameterSpec.Builder(KEY_NAME,
                    KeyProperties.PURPOSE_ENCRYPT |
                            KeyProperties.PURPOSE_DECRYPT)
                    .setBlockModes(KeyProperties.BLOCK_MODE_CBC)
                    .setUserAuthenticationRequired(true)
                    .setEncryptionPaddings(
                            KeyProperties.ENCRYPTION_PADDING_PKCS7)
                    .build());
            keyGenerator.generateKey();
        } catch (NoSuchAlgorithmException |
                InvalidAlgorithmParameterException
                | CertificateException | IOException e) {
            throw new RuntimeException(e);
        }
    }


    public boolean cipherInit() {
        try {
            cipher = Cipher.getInstance(KeyProperties.KEY_ALGORITHM_AES + "/" + KeyProperties.BLOCK_MODE_CBC + "/" + KeyProperties.ENCRYPTION_PADDING_PKCS7);
        } catch (NoSuchAlgorithmException | NoSuchPaddingException e) {
            throw new RuntimeException("Failed to get Cipher", e);
        }


        try {
            keyStore.load(null);
            SecretKey key = (SecretKey) keyStore.getKey(KEY_NAME,
                    null);
            cipher.init(Cipher.ENCRYPT_MODE, key);
            return true;
        } catch (KeyPermanentlyInvalidatedException e) {
            return false;
        } catch (KeyStoreException | CertificateException | UnrecoverableKeyException | IOException | NoSuchAlgorithmException | InvalidKeyException e) {
            throw new RuntimeException("Failed to init Cipher", e);
        }
    }
}
