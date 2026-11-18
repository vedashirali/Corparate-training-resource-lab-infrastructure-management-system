package com.corplab.platform.controller;

import com.corplab.platform.entity.ActivityLog;
import com.corplab.platform.repository.*;
import com.corplab.platform.service.AuthService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    private final AuthService authService;
    private final UserRepository userRepository;
    private final LabRepository labRepository;
    private final LabResourceRepository resourceRepository;
    private final TrainingProgramRepository programRepository;
    private final ResourceRequestRepository requestRepository;
    private final ActivityLogRepository activityLogRepository;

    public DashboardController(AuthService authService,
                               UserRepository userRepository,
                               LabRepository labRepository,
                               LabResourceRepository resourceRepository,
                               TrainingProgramRepository programRepository,
                               ResourceRequestRepository requestRepository,
                               ActivityLogRepository activityLogRepository) {
        this.authService = authService;
        this.userRepository = userRepository;
        this.labRepository = labRepository;
        this.resourceRepository = resourceRepository;
        this.programRepository = programRepository;
        this.requestRepository = requestRepository;
        this.activityLogRepository = activityLogRepository;
    }

    @GetMapping("/overview")
    public ResponseEntity<Map<String, Object>> getOverview(HttpSession session) {
        authService.getAuthenticatedUser(session);

        long totalEmployees = userRepository.countByRoleIn(List.of("EMPLOYEE", "TRAINEE"));
        long totalTrainers = userRepository.countByRole("TRAINER");
        long totalPrograms = programRepository.count();
        long availableLabs = labRepository.countByStatus("ACTIVE");
        long totalResources = resourceRepository.count();
        long pendingRequests = requestRepository.countByStatus("PENDING");

        List<ActivityLog> recentActivities = activityLogRepository.findTop20ByOrderByTimestampDesc();

        return ResponseEntity.ok(Map.of(
                "totalEmployees", totalEmployees,
                "totalTrainers", totalTrainers,
                "totalPrograms", totalPrograms,
                "availableLabs", availableLabs,
                "totalResources", totalResources,
                "pendingRequests", pendingRequests,
                "systemStatus", "OPERATIONAL",
                "uptime", "99.98%",
                "recentActivities", recentActivities
        ));
    }

    @GetMapping("/statistics")
    public ResponseEntity<Map<String, Object>> getStatistics(HttpSession session) {
        authService.getAuthenticatedUser(session);

        Map<String, Object> monthlyEnrollment = Map.of(
                "labels", List.of("Jun", "Jul", "Aug", "Sep", "Oct", "Nov"),
                "values", List.of(28, 42, 65, 88, 110, 145)
        );

        Map<String, Object> labUtilization = Map.of(
                "labels", List.of("Cloud Lab A", "AI Research Lab", "Dev Lab B", "Network Lab C"),
                "values", List.of(82, 94, 68, 55)
        );

        Map<String, Object> resourceCategories = Map.of(
                "labels", List.of("Cloud Compute", "AI / GPU", "Database", "DevOps"),
                "values", List.of(40, 30, 18, 12)
        );

        return ResponseEntity.ok(Map.of(
                "monthlyEnrollment", monthlyEnrollment,
                "labUtilization", labUtilization,
                "resourceCategories", resourceCategories
        ));
    }
}
