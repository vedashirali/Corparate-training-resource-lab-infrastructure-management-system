package com.corplab.usermanagement.controller;

import com.corplab.usermanagement.dto.UserResponse;
import com.corplab.usermanagement.service.UserService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * Requirement 1.B.4: Controller Layer - DashboardController
 * Exposes GET /api/dashboard to fetch authenticated user data.
 */
@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*", allowCredentials = "false")
public class DashboardController {

    private final UserService userService;

    public DashboardController(UserService userService) {
        this.userService = userService;
    }

    /**
     * GET /api/dashboard
     * Returns dashboard data for the authenticated user.
     * Enforces backend security: throws 403 Forbidden if not authenticated.
     */
    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> getDashboard(HttpSession session) {
        UserResponse user = userService.getDashboardUser(session);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Welcome to Dashboard!");
        response.put("user", user);

        return ResponseEntity.ok(response);
    }
}
