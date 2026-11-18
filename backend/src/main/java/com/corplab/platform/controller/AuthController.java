package com.corplab.platform.controller;

import com.corplab.platform.dto.LoginRequest;
import com.corplab.platform.dto.RegisterRequest;
import com.corplab.platform.dto.UserResponse;
import com.corplab.platform.service.AuthService;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> register(@Valid @RequestBody RegisterRequest request) {
        UserResponse user = authService.register(request);
        return new ResponseEntity<>(Map.of(
                "success", true,
                "message", "User registered successfully.",
                "user", user
        ), HttpStatus.CREATED);
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@Valid @RequestBody LoginRequest request, HttpSession session) {
        UserResponse user = authService.login(request, session);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Login successful.",
                "user", user
        ));
    }

    @GetMapping("/profile")
    public ResponseEntity<Map<String, Object>> getProfile(HttpSession session) {
        UserResponse user = authService.getAuthenticatedUser(session);
        return ResponseEntity.ok(Map.of("success", true, "user", user));
    }

    @GetMapping("/me")
    public ResponseEntity<Map<String, Object>> getCurrentUser(HttpSession session) {
        return getProfile(session);
    }

    @PostMapping("/logout")
    public ResponseEntity<Map<String, Object>> logout(HttpSession session) {
        authService.logout(session);
        return ResponseEntity.ok(Map.of("success", true, "message", "Logged out successfully."));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<Map<String, Object>> forgotPassword(@RequestBody Map<String, String> body) {
        String identifier = body.get("identifier");
        if (identifier == null || identifier.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Please provide a valid username or email."));
        }
        String token = authService.forgotPassword(identifier);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Temporary security reset code generated: " + token + ". Use this to authenticate or reset your credentials.",
                "resetCode", token
        ));
    }
}
