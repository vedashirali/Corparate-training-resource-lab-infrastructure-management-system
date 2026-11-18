package com.corplab.usermanagement.controller;

import com.corplab.usermanagement.dto.LoginRequest;
import com.corplab.usermanagement.dto.LoginResponse;
import com.corplab.usermanagement.service.UserService;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * Requirement 1.B.4: Controller Layer - AuthController
 * Exposes REST endpoints for user authentication and logout.
 */
@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*", allowCredentials = "false")
public class AuthController {

    private final UserService userService;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    /**
     * POST /api/auth/login
     * Authenticates user using username or email + password.
     */
    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request, HttpSession session) {
        LoginResponse response = userService.authenticate(request, session);
        return ResponseEntity.ok(response);
    }

    /**
     * POST /api/auth/logout
     * Challenge 4.4: Destroys user session.
     */
    @PostMapping("/logout")
    public ResponseEntity<Map<String, String>> logout(HttpSession session) {
        userService.logout(session);
        return ResponseEntity.ok(Map.of("message", "Logged out successfully."));
    }
}
