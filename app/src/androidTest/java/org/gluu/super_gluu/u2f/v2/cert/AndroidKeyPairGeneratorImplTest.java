package org.gluu.super_gluu.u2f.v2.cert;

import org.gluu.super_gluu.u2f.v2.exception.U2FException;
import org.junit.Assert;
import org.junit.Test;

import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.spec.ECParameterSpec;
import java.security.spec.ECPoint;

public class AndroidKeyPairGeneratorImplTest {

    private static int count;
    private AndroidKeyPairGeneratorImpl generator;


    @org.junit.BeforeClass
    public static void beforeClass() {
        print("This executes before any test cases. Count = " + count++);
    }

    @org.junit.Before
    public void setup() {
        generator = new AndroidKeyPairGeneratorImpl();
        print("Running a test...");
    }

    @Test
    public void testKeyFactory() {
        try {
            KeyFactory keyFactory = generator.getKeyFactory();
            keyFactory.getAlgorithm();
        } catch (U2FException e) {
            e.printStackTrace();
        }
    }

    @Test
    public void testKeyPair() {
        try {
            generator.generateKeyPair();
        } catch (U2FException e) {
            e.printStackTrace();
        }
    }

    @Test
    public void testGetParameterSpec() {
        try {
            ECParameterSpec ecParameters = generator.getParameterSpec();
            ECPoint point = ecParameters.getGenerator();
        } catch (U2FException e) {
            e.printStackTrace();
        }
    }

    @Test
    public void encodePublicKey() {
        try {
            KeyPair keyPair = generator.generateKeyPair();
            byte[] userPublicKey = generator.encodePublicKey(keyPair.getPublic());

        } catch (U2FException e) {
            e.printStackTrace();
        }
    }

    @Test
    public void keyPairToJson() {
        try {
            KeyPair keyPair = generator.generateKeyPair();
            String json = generator.keyPairToJson(keyPair);
            json.length();
        } catch (U2FException e) {
            e.printStackTrace();
        }
    }

    @Test
    public void keyPairFromJson() {
        try {
            KeyPair encodeKeyPair = generator.generateKeyPair();
            String json = generator.keyPairToJson(encodeKeyPair);
            KeyPair decodeKeyPair = generator.keyPairFromJson(json);
            Assert.assertArrayEquals(encodeKeyPair.getPrivate().getEncoded(), decodeKeyPair.getPrivate().getEncoded());
        } catch (U2FException e) {
            e.printStackTrace();
        }
    }

    @org.junit.AfterClass
    public static void afterClass() {
        print("This executes after any test cases. Count = " + count++);
    }

    @org.junit.After
    public void teardown() {
        print("Count = " + count++);
    }

    private static void print(String message) {
        System.out.println(message);
    }

}