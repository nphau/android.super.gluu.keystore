package org.gluu.super_gluu.u2f.v2.cert;

import android.util.Log;

import org.apache.commons.codec.DecoderException;
import org.gluu.super_gluu.u2f.v2.exception.U2FException;
import org.gluu.super_gluu.util.Utils;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.math.BigInteger;
import java.security.AlgorithmParameters;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.Signature;
import java.security.SignatureException;
import java.security.interfaces.ECPrivateKey;
import java.security.interfaces.ECPublicKey;
import java.security.spec.ECGenParameterSpec;
import java.security.spec.ECParameterSpec;
import java.security.spec.ECPoint;
import java.security.spec.ECPrivateKeySpec;
import java.security.spec.ECPublicKeySpec;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.InvalidParameterSpecException;

import SuperGluu.app.BuildConfig;

public class AndroidKeyPairGeneratorImpl implements org.gluu.super_gluu.u2f.v2.cert.KeyPairGenerator {

    private static final String TAG = AndroidKeyPairGeneratorImpl.class.getName();
    private static final String ALGO = "EC";

    @Override
    public KeyPair generateKeyPair() throws U2FException {
        try {
            KeyPairGenerator generator = KeyPairGenerator.getInstance("EC");
            generator.initialize(new ECGenParameterSpec("secp256r1"));
            return generator.generateKeyPair();
        } catch (NoSuchAlgorithmException | InvalidAlgorithmParameterException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public byte[] sign(byte[] signedData, PrivateKey privateKey) throws U2FException {
        try {
            Signature signature = Signature.getInstance("SHA256withECDSA");
            signature.initSign(privateKey);
            signature.update(signedData);
            return signature.sign();
        } catch (NoSuchAlgorithmException | InvalidKeyException | SignatureException e) {
            throw new U2FException("Error when signing", e);
        }
    }

    @Override
    public byte[] generateKeyHandle() {
        SecureRandom random = new SecureRandom();
        byte[] keyHandle = new byte[64];
        random.nextBytes(keyHandle);
        return keyHandle;
    }

    @Override
    public byte[] encodePublicKey(PublicKey publicKey) {
        byte[] encodedWithPadding = publicKey.getEncoded();
        byte[] encoded = new byte[65];
        System.arraycopy(encodedWithPadding, 26, encoded, 0, encoded.length);

        if (BuildConfig.DEBUG) Log.d(TAG, "Encoded public key: " + Utils.encodeHexString(encoded));

        return encoded;
    }

    public KeyFactory getKeyFactory() throws U2FException {
        try {
            return KeyFactory.getInstance(ALGO);
        } catch (NoSuchAlgorithmException e) {
            throw new U2FException("Error when getKeyFactory", e);
        }
    }

    public String keyPairToJson(KeyPair keyPair) throws U2FException {

        ECPrivateKey privateKey = (ECPrivateKey) keyPair.getPrivate();
        ECPublicKey publicKey = (ECPublicKey) keyPair.getPublic();

        BigInteger x = publicKey.getW().getAffineX();
        BigInteger y = publicKey.getW().getAffineY();
        BigInteger d = privateKey.getS();

        try {
            JSONObject jsonPrivateKey = new JSONObject();
            jsonPrivateKey.put("d", Utils.encodeHexString(d.toByteArray()));

            JSONObject jsonPublicKey = new JSONObject();
            jsonPublicKey.put("x", Utils.encodeHexString(x.toByteArray()));
            jsonPublicKey.put("y", Utils.encodeHexString(y.toByteArray()));

            JSONObject jsonKeyPair = new JSONObject();
            jsonKeyPair.put("privateKey", jsonPrivateKey);
            jsonKeyPair.put("publicKey", jsonPublicKey);

            String keyPairJson = jsonKeyPair.toString();

            if (BuildConfig.DEBUG) Log.d(TAG, "JSON key pair: " + keyPairJson);

            return keyPairJson;
        } catch (JSONException ex) {
            throw new U2FException("Failed to serialize key pair to JSON", ex);
        }
    }

    @Override
    public PrivateKey loadPrivateKey(String privateKeyD) throws U2FException {
        try {
            KeyFactory fac = getKeyFactory();
            ECParameterSpec ecParameters = getParameterSpec();
            ECPrivateKeySpec keySpec =
                    new ECPrivateKeySpec(
                            new BigInteger(privateKeyD, 16), ecParameters);
            return fac.generatePrivate(keySpec);
        } catch (InvalidKeySpecException ex) {
            throw new U2FException("Failed to load private key", ex);
        }
    }

    public ECParameterSpec getParameterSpec() throws U2FException {
        ECParameterSpec ecParameters;
        AlgorithmParameters parameters;
        try {
            parameters = AlgorithmParameters.getInstance(ALGO);
            parameters.init(new ECGenParameterSpec("secp256r1"));
            ecParameters = parameters.getParameterSpec(ECParameterSpec.class);

        } catch (NoSuchAlgorithmException | InvalidParameterSpecException e) {
            throw new U2FException("Failed to deserialize key pair from JSON", e);
        }
        return ecParameters;
    }

    public KeyPair keyPairFromJson(String keyPairJson) throws U2FException {
        BigInteger x;
        BigInteger y;
        BigInteger d;
        try {
            JSONObject jsonKeyPair = (JSONObject) new JSONTokener(keyPairJson).nextValue();
            JSONObject jsonPrivateKey = jsonKeyPair.getJSONObject("privateKey");
            d = new BigInteger(Utils.decodeHexString(jsonPrivateKey.getString("d")));

            JSONObject jsonPublicKey = jsonKeyPair.getJSONObject("publicKey");
            x = new BigInteger(Utils.decodeHexString(jsonPublicKey.getString("x")));
            y = new BigInteger(Utils.decodeHexString(jsonPublicKey.getString("y")));
        } catch (JSONException | DecoderException ex) {
            throw new U2FException("Failed to deserialize key pair from JSON", ex);
        }

        ECParameterSpec ecParameters = getParameterSpec();
        ECPoint validatePoint = new ECPoint(x, y);
        ECPublicKeySpec publicKeySpec = new ECPublicKeySpec(validatePoint, ecParameters);
        ECPrivateKeySpec privateKeySpec = new ECPrivateKeySpec(d, ecParameters);

        try {
            KeyFactory keyFactory = getKeyFactory();
            PrivateKey privateKey = keyFactory.generatePrivate(privateKeySpec);
            PublicKey publicKey = keyFactory.generatePublic(publicKeySpec);
            return new KeyPair(publicKey, privateKey);
        } catch (InvalidKeySpecException ex) {
            throw new U2FException("Failed to deserialize key pair from JSON", ex);
        }
    }
}
