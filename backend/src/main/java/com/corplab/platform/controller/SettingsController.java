package com.corplab.platform.controller;

import com.corplab.platform.entity.ActivityLog;
import com.corplab.platform.repository.ActivityLogRepository;
import com.corplab.platform.service.AuthService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/settings")
public class SettingsController {

    private final ActivityLogRepository activityLogRepository;
    private final AuthService authService;

    public SettingsController(ActivityLogRepository activityLogRepository, AuthService authService) {
        this.activityLogRepository = activityLogRepository;
        this.authService = authService;
    }

    @GetMapping("/logs")
    public ResponseEntity<List<ActivityLog>> getActivityLogs(HttpSession session) {
        authService.getAuthenticatedUser(session);
        return ResponseEntity.ok(activityLogRepository.findTop20ByOrderByTimestampDesc());
    }
}
