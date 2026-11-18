package com.corplab.usermanagement.exception;

/**
 * Thrown when user credentials do not match records in the database.
 */
public class InvalidCredentialsException extends RuntimeException {
    public InvalidCredentialsException(String message) {
        super(message);
    }
}
