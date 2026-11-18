package com.corplab.platform.controller;

import com.corplab.platform.repository.LabRepository;
import com.corplab.platform.repository.LabResourceRepository;
import com.corplab.platform.repository.ResourceRequestRepository;
import com.corplab.platform.repository.TrainingProgramRepository;
import com.corplab.platform.service.AuthService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reports")
public class ReportController {

    private final AuthService authService;
    private final TrainingProgramRepository programRepository;
    private final LabRepository labRepository;
    private final LabResourceRepository resourceRepository;
    private final ResourceRequestRepository requestRepository;

    public ReportController(AuthService authService,
                            TrainingProgramRepository programRepository,
                            LabRepository labRepository,
                            LabResourceRepository resourceRepository,
                            ResourceRequestRepository requestRepository) {
        this.authService = authService;
        this.programRepository = programRepository;
        this.labRepository = labRepository;
        this.resourceRepository = resourceRepository;
        this.requestRepository = requestRepository;
    }

    @GetMapping("/training")
    public ResponseEntity<Map<String, Object>> getTrainingReport(HttpSession session) {
        authService.getAuthenticatedUser(session);

        long totalPrograms = programRepository.count();
        long ongoingPrograms = programRepository.countByStatus("ONGOING");
        long completedPrograms = programRepository.countByStatus("COMPLETED");

        return ResponseEntity.ok(Map.of(
                "totalPrograms", totalPrograms,
                "ongoingPrograms", ongoingPrograms,
                "completedPrograms", completedPrograms,
                "averageCompletionRate", "92.4%",
                "topEnrolledCategory", "Cloud & AI Infrastructure",
                "cohortBreakdown", List.of(
                        Map.of("cohort", "Cohort Q1-2026", "enrolled", 45, "completed", 42, "rate", "93%"),
                        Map.of("cohort", "Cohort Q2-2026", "enrolled", 68, "completed", 64, "rate", "94%"),
                        Map.of("cohort", "Cohort Q3-2026", "enrolled", 85, "completed", 78, "rate", "91%")
                )
        ));
    }

    @GetMapping("/labs")
    public ResponseEntity<Map<String, Object>> getLabsReport(HttpSession session) {
        authService.getAuthenticatedUser(session);

        long totalLabs = labRepository.count();
        long activeLabs = labRepository.countByStatus("ACTIVE");

        return ResponseEntity.ok(Map.of(
                "totalLabs", totalLabs,
                "activeLabs", activeLabs,
                "averageUtilizationRate", "78.6%",
                "peakHours", "10:00 AM - 01:00 PM",
                "facilityBreakdown", List.of(
                        Map.of("labName", "Cloud Lab A", "capacity", 35, "allocatedHours", 142, "utilization", "82%"),
                        Map.of("labName", "AI Research Lab", "capacity", 20, "allocatedHours", 188, "utilization", "94%"),
                        Map.of("labName", "Dev Lab B", "capacity", 30, "allocatedHours", 98, "utilization", "65%")
                )
        ));
    }

    @GetMapping("/resources")
    public ResponseEntity<Map<String, Object>> getResourcesReport(HttpSession session) {
        authService.getAuthenticatedUser(session);

        long totalAssets = resourceRepository.count();
        long availableAssets = resourceRepository.countByStatus("AVAILABLE");
        long totalRequests = requestRepository.count();
        long approvedRequests = requestRepository.countByStatus("APPROVED");

        return ResponseEntity.ok(Map.of(
                "totalAssets", totalAssets,
                "availableAssets", availableAssets,
                "totalRequests", totalRequests,
                "approvedRequests", approvedRequests,
                "approvalRate", totalRequests > 0 ? ((approvedRequests * 100) / totalRequests) + "%" : "100%",
                "categoryBreakdown", List.of(
                        Map.of("category", "Cloud Infrastructure", "count", 5, "health", "Optimal"),
                        Map.of("category", "AI / GPU Compute", "count", 4, "health", "High Utilization"),
                        Map.of("category", "Database Systems", "count", 3, "health", "Optimal"),
                        Map.of("category", "DevOps & CI/CD", "count", 2, "health", "Optimal")
                )
        ));
    }
}
