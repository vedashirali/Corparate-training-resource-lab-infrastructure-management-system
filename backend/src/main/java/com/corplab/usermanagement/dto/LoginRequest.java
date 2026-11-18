package com.corplab.usermanagement.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * Requirement 1.B.4 & Challenge 4.2: LoginRequest DTO
 * Encapsulates login credentials sent in POST /api/auth/login.
 * Includes @NotBlank annotations for server-side input validation.
 */
public class LoginRequest {

    @NotBlank(message = "Username or email is required.")
    private String usernameOrEmail;

    @NotBlank(message = "Password is required.")
    private String password;

    public LoginRequest() {
    }

    public LoginRequest(String usernameOrEmail, String password) {
        this.usernameOrEmail = usernameOrEmail;
        this.password = password;
    }

    public String getUsernameOrEmail() {
        return usernameOrEmail;
    }

    public void setUsernameOrEmail(String usernameOrEmail) {
        this.usernameOrEmail = usernameOrEmail;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
