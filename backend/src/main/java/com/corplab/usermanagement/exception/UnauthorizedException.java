package com.corplab.usermanagement.exception;

/**
 * Challenge 4.6: Thrown when an unauthenticated user attempts to access protected endpoints.
 */
public class UnauthorizedException extends RuntimeException {
    public UnauthorizedException(String message) {
        super(message);
    }
}
