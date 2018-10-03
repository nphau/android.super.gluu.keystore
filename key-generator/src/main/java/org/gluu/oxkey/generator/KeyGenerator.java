3/*
 * oxKeyGenerator is available under the MIT License (2008). See http://opensource.org/licenses/MIT for full text.
 *
 * Copyright (c) 2016, Gluu
 */

package org.gluu.oxkey.generator;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.StringWriter;
import java.math.BigInteger;
import java.security.InvalidAlgorithmParameterException;
import java.security.Key;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import org.apache.commons.codec.DecoderException;
import org.apache.commons.codec.binary.Hex;
import org.apache.commons.io.IOUtils;
import org.bouncycastle.asn1.ASN1Encodable;
import org.bouncycastle.asn1.ASN1EncodableVector;
import org.bouncycastle.asn1.ASN1InputStream;
import org.bouncycastle.asn1.ASN1Sequence;
import org.bouncycastle.asn1.DERSequence;
import org.bouncycastle.asn1.x500.X500Name;
import org.bouncycastle.asn1.x509.BasicConstraints;
import org.bouncycastle.asn1.x509.Extension;
import org.bouncycastle.asn1.x509.GeneralName;
import org.bouncycastle.asn1.x509.KeyPurposeId;
import org.bouncycastle.asn1.x509.KeyUsage;
import org.bouncycastle.asn1.x509.SubjectKeyIdentifier;
import org.bouncycastle.asn1.x509.SubjectPublicKeyInfo;
import org.bouncycastle.cert.X509CertificateHolder;
import org.bouncycastle.cert.X509v3CertificateBuilder;
import org.bouncycastle.cert.bc.BcX509ExtensionUtils;
import org.bouncycastle.cert.jcajce.JcaX509CertificateConverter;
import org.bouncycastle.cert.jcajce.JcaX509v3CertificateBuilder;
import org.bouncycastle.jce.ECNamedCurveTable;
import org.bouncycastle.jce.interfaces.ECPrivateKey;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.jce.spec.ECParameterSpec;
import org.bouncycastle.openssl.jcajce.JcaPEMWriter;
import org.bouncycastle.operator.ContentSigner;
import org.bouncycastle.operator.OperatorCreationException;
import org.bouncycastle.operator.jcajce.JcaContentSignerBuilder;
import org.bouncycastle.util.IPAddress;
import org.gluu.oxkey.exception.KeyGeneratorException;

/**
 * Helper class which prepares U2F server key
 *
 * @author Yuriy Movchan
 * @version June 10, 2016
 */
public class KeyGenerator {

	public static final BouncyCastleProvider BOUNCY_CASTLE_PROVIDER = new BouncyCastleProvider();

	public KeyPair generateKeyPair() throws KeyGeneratorException {
		// generate ECC key
		SecureRandom random = new SecureRandom();

		ECParameterSpec ecSpec = ECNamedCurveTable.getParameterSpec("secp256r1");
		try {
			KeyPairGenerator g = KeyPairGenerator.getInstance("ECDSA", BOUNCY_CASTLE_PROVIDER);
			g.initialize(ecSpec, random);
			KeyPair keyPair = g.generateKeyPair();

			return keyPair;
		} catch (NoSuchAlgorithmException ex) {
			throw new KeyGeneratorException("Failed to generate key pair", ex);
		} catch (InvalidAlgorithmParameterException ex) {
			throw new KeyGeneratorException("Failed to generate key pair", ex);
		}
	}

	public static String toPEM(Key key) throws KeyGeneratorException {
		StringWriter sw = new StringWriter();
		JcaPEMWriter pemWriter = new JcaPEMWriter(sw);
		try {
			pemWriter.writeObject(key);
			pemWriter.close();

			return sw.toString();
		} catch (IOException ex) {
			throw new KeyGeneratorException("Failed to convert public key to PEM format", ex);
		}
	}

	public static String toPEM(X509Certificate cert) throws KeyGeneratorException {
		StringWriter sw = new StringWriter();
		JcaPEMWriter pemWriter = new JcaPEMWriter(sw);
		try {
			pemWriter.writeObject(cert);
			pemWriter.close();

			return sw.toString();
		} catch (IOException ex) {
			throw new KeyGeneratorException("Failed to convert public key to PEM format", ex);
		}
	}

	public static String encodeHexString(byte[] arg) {
		return new String(Hex.encodeHex(arg));
	}

	public static byte[] decodeHexString(String arg) throws DecoderException {
		return Hex.decodeHex(arg.toCharArray());
	}

	/**
	 * Create a certificate to use by a Certificate Authority, signed by a self
	 * signed certificate.
	 */
	public X509Certificate createCaCert(KeyPair keyPair, String issuer, String signatureAlgorithm)
			throws KeyGeneratorException {
		
		PrivateKey privateKey = keyPair.getPrivate();
		PublicKey publicKey = keyPair.getPublic();

		try {
			// Signers name
			X500Name issuerName = new X500Name(issuer);
	
			// Subjects name - the same as we are self signed.
			X500Name subjectName = new X500Name(issuer);
	
			// Serial
			BigInteger serial = new BigInteger(256, new SecureRandom());
	
			// Not before
			Date notBefore = new Date();
	
			// Not after (5 year)
			Calendar cal = Calendar.getInstance();
			cal.setTime(notBefore);
			cal.add(Calendar.YEAR, 5);
			Date notAfter = cal.getTime();
	
			// Create the certificate - version 3
			X509v3CertificateBuilder builder = new JcaX509v3CertificateBuilder(issuerName, serial, notBefore, notAfter, subjectName, publicKey);
			builder.addExtension(Extension.subjectKeyIdentifier, false, createSubjectKeyIdentifier(publicKey));
			builder.addExtension(Extension.basicConstraints, true, new BasicConstraints(true));

			KeyUsage usage = new KeyUsage(KeyUsage.keyCertSign | KeyUsage.digitalSignature | KeyUsage.keyEncipherment
					| KeyUsage.dataEncipherment | KeyUsage.cRLSign);
			builder.addExtension(Extension.keyUsage, false, usage);

			ASN1EncodableVector purposes = new ASN1EncodableVector();
			purposes.add(KeyPurposeId.id_kp_serverAuth);
			purposes.add(KeyPurposeId.id_kp_clientAuth);
			purposes.add(KeyPurposeId.anyExtendedKeyUsage);
			builder.addExtension(Extension.extendedKeyUsage, false, new DERSequence(purposes));

			X509Certificate cert = signCertificate(builder, privateKey, signatureAlgorithm);
			cert.checkValidity(new Date());
			cert.verify(publicKey);

			return cert;
		} catch (Exception ex) {
			throw new KeyGeneratorException("Failed to generate X509Certificate", ex);
		}
	}

	/**
	 * Create a server certificate for the given domain and subject alternative
	 * names, signed by the given Certificate Authority.
	 */
	public X509Certificate createClientCert(PublicKey publicKey,
			X509Certificate certificateAuthorityCert, KeyPair certificateAuthorityKeyPair, String subject,
			String[] subjectAlternativeNameDomains, String[] subjectAlternativeNameIps, String signatureAlgorithm) throws KeyGeneratorException {
		
		PrivateKey certificateAuthorityPrivateKey = certificateAuthorityKeyPair.getPrivate();
		PublicKey certificateAuthorityPublicKey = certificateAuthorityKeyPair.getPublic();

		try {
			// Signers name
			X500Name issuerName = new X509CertificateHolder(certificateAuthorityCert.getEncoded()).getSubject();
	
			// Subjects name
			X500Name subjectName = new X500Name(subject);
	
			// Serial
			BigInteger serial = new BigInteger(256, new SecureRandom());
	
			// Not before
			Date notBefore = new Date();
	
			// Not after (5 year)
			Calendar cal = Calendar.getInstance();
			cal.setTime(notBefore);
			cal.add(Calendar.YEAR, 5);
			Date notAfter = cal.getTime();
	
			// Create the certificate - version 3
			X509v3CertificateBuilder builder = new JcaX509v3CertificateBuilder(issuerName, serial, notBefore, notAfter, subjectName, publicKey);
			builder.addExtension(Extension.subjectKeyIdentifier, false, createSubjectKeyIdentifier(publicKey));
			builder.addExtension(Extension.basicConstraints, false, new BasicConstraints(false));

			//
			// Subject alternative name
			//
			List<ASN1Encodable> subjectAlternativeNames = new ArrayList<ASN1Encodable>();
			if (subjectAlternativeNameDomains != null) {
				for (String subjectAlternativeNameDomain : subjectAlternativeNameDomains) {
					subjectAlternativeNames.add(new GeneralName(GeneralName.dNSName, subjectAlternativeNameDomain));
				}
			}
			if (subjectAlternativeNameIps != null) {
				for (String subjectAlternativeNameIp : subjectAlternativeNameIps) {
					if (IPAddress.isValidIPv6WithNetmask(subjectAlternativeNameIp) || IPAddress.isValidIPv6(subjectAlternativeNameIp)
							|| IPAddress.isValidIPv4WithNetmask(subjectAlternativeNameIp)
							|| IPAddress.isValidIPv4(subjectAlternativeNameIp)) {
						subjectAlternativeNames.add(new GeneralName(GeneralName.iPAddress, subjectAlternativeNameIp));
					}
				}
			}
			if (subjectAlternativeNames.size() > 0) {
				DERSequence subjectAlternativeNamesExtension = new DERSequence(
						subjectAlternativeNames.toArray(new ASN1Encodable[subjectAlternativeNames.size()]));
				builder.addExtension(Extension.subjectAlternativeName, false, subjectAlternativeNamesExtension);
			}

			X509Certificate cert = signCertificate(builder, certificateAuthorityPrivateKey, signatureAlgorithm);

			cert.checkValidity(new Date());
			cert.verify(certificateAuthorityPublicKey);

			return cert;
		} catch (Exception ex) {
			throw new KeyGeneratorException("Failed to generate X509Certificate", ex);
		}
	}

	private static SubjectKeyIdentifier createSubjectKeyIdentifier(Key key) throws IOException {
		ASN1InputStream is = null;
		try {
			is = new ASN1InputStream(new ByteArrayInputStream(key.getEncoded()));
			ASN1Sequence seq = (ASN1Sequence) is.readObject();
			SubjectPublicKeyInfo info = SubjectPublicKeyInfo.getInstance(seq);
			return new BcX509ExtensionUtils().createSubjectKeyIdentifier(info);
		} finally {
			IOUtils.closeQuietly(is);
		}
	}

	private static X509Certificate signCertificate(X509v3CertificateBuilder certificateBuilder, PrivateKey signedWithPrivateKey,
			String signatureAlgorithm) throws OperatorCreationException, CertificateException {
		ContentSigner signer = new JcaContentSignerBuilder(signatureAlgorithm).setProvider(BOUNCY_CASTLE_PROVIDER)
				.build(signedWithPrivateKey);
		return new JcaX509CertificateConverter().setProvider(BOUNCY_CASTLE_PROVIDER).getCertificate(certificateBuilder.build(signer));
	}

	public static void main(String[] args) throws KeyGeneratorException, IOException, DecoderException, CertificateException {
		KeyGenerator keyGenerator = new KeyGenerator();

		// Generate CA certificate
		KeyPair caKeyPair = keyGenerator.generateKeyPair();

		System.out.println("-- CA (PRIVATE KEY D): --------------------------------------------------------");
		ECPrivateKey caPrivateKey = (ECPrivateKey) caKeyPair.getPrivate();
		BigInteger caD = caPrivateKey.getD();
		String caPrivateKeyDHex = encodeHexString(caD.toByteArray()).substring(2);
		System.out.println(caPrivateKeyDHex);

		System.out.println("-- CA (PRIVATE KEY): ----------------------------------------------------------");
		System.out.println(toPEM(caKeyPair.getPrivate()));

		System.out.println("-- CA (X509 PUBLIC KEY INFO): ------------------------------------------------------");
		X509Certificate caX509Cert = keyGenerator.createCaCert(caKeyPair,
				"C=US,ST=TX,L=Austin,O=Gluu,CN=Gluu oxPush2 U2F v1.0.0 (root)",
				"SHA256WITHECDSA");
		System.out.println(caX509Cert);

		System.out.println("-- CA (X509 PUBLIC KEY): ---------------------------------------------");
		System.out.println(toPEM(caX509Cert));

		System.out.println("-- CA (DER -> HEX PUBLIC KEY): ------------------------------------------------");
		System.out.println(encodeHexString(caX509Cert.getEncoded()));

		System.out.println("-------------------------------------------------------------------------------");
		System.out.println("-------------------------------------------------------------------------------");

		// Generate client certificate
		KeyPair keyPair = keyGenerator.generateKeyPair();
		System.out.println("-- APPLICATION (PRIVATE KEY D) ------------------------------------------------");
		ECPrivateKey privateKey = (ECPrivateKey) keyPair.getPrivate();
		BigInteger d = privateKey.getD();
		String privateKeyDHex = encodeHexString(d.toByteArray()).substring(2);
		System.out.println(privateKeyDHex);

		System.out.println("-- APPLICATION (PRIVATE KEY): -------------------------------------------------");
		System.out.println(toPEM(keyPair.getPrivate()));

		System.out.println("-- APPLICATION (X509 PUBLIC KEY INFO): ---------------------------------------------");
		X509Certificate x509Cert = keyGenerator.createClientCert(keyPair.getPublic(), caX509Cert, caKeyPair,
				"C=US,ST=TX,L=Austin,O=Gluu,CN=Gluu oxPush2 U2F v1.0.0 (client)",
				null, null, "SHA256WITHECDSA");
		System.out.println(x509Cert);

		System.out.println("-- APPLICATION (X509 PUBLIC KEY): ---------------------------------------------");
		System.out.println(toPEM(x509Cert));

		System.out.println("-- APPLICATION (DER -> HEX PUBLIC KEY): ---------------------------------------");
		System.out.println(encodeHexString(x509Cert.getEncoded()));
	}

}
