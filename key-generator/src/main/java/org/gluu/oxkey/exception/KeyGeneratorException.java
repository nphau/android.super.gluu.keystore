/*
 * oxKeyGenerator is available under the MIT License (2008). See http://opensource.org/licenses/MIT for full text.
 *
 * Copyright (c) 2016, Gluu
 */

package org.gluu.oxkey.exception;

/**
 * Key generator exception
 *
 * @author Yuriy Movchan
 * @version June 10, 2016
 */
public class KeyGeneratorException extends Exception {

	private static final long serialVersionUID = 8393571944435996338L;

	public KeyGeneratorException(String message) {
        super(message);
    }

    public KeyGeneratorException(String message, Throwable cause) {
        super(message, cause);
    }

}
