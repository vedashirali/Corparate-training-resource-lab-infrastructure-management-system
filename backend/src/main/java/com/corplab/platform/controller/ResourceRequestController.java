package com.corplab.platform.controller;

import com.corplab.platform.dto.UserResponse;
import com.corplab.platform.entity.ActivityLog;
import com.corplab.platform.entity.ResourceRequest;
import com.corplab.platform.exception.ResourceNotFoundException;
import com.corplab.platform.repository.ActivityLogRepository;
import com.corplab.platform.repository.ResourceRequestRepository;
import com.corplab.platform.service.AuthService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/resource-requests")
public class ResourceRequestController {

    private final ResourceRequestRepository requestRepository;
    private final AuthService authService;
    private final ActivityLogRepository activityLogRepository;

    public ResourceRequestController(ResourceRequestRepository requestRepository,
                                     AuthService authService,
                                     ActivityLogRepository activityLogRepository) {
        this.requestRepository = requestRepository;
        this.authService = authService;
        this.activityLogRepository = activityLogRepository;
    }

    @GetMapping
    public ResponseEntity<List<ResourceRequest>> getAllRequests(HttpSession session) {
        UserResponse user = authService.getAuthenticatedUser(session);
        // Admin and Trainers see all; Employees see their own or all for transparency
        if ("ADMIN".equalsIgnoreCase(user.getRole()) || "TRAINER".equalsIgnoreCase(user.getRole())) {
            return ResponseEntity.ok(requestRepository.findAllByOrderByCreatedAtDesc());
        }
        return ResponseEntity.ok(requestRepository.findAllByOrderByCreatedAtDesc());
    }

    @PostMapping
    public ResponseEntity<ResourceRequest> createRequest(@RequestBody ResourceRequest req, HttpSession session) {
        UserResponse user = authService.getAuthenticatedUser(session);

        if (req.getResourceName() == null || req.getResourceName().isBlank()) {
            throw new IllegalArgumentException("Resource Name is required.");
        }
        if (req.getPurpose() == null || req.getPurpose().isBlank()) {
            throw new IllegalArgumentException("Purpose is required.");
        }

        req.setRequesterName(user.getFullName());
        req.setRequesterEmail(user.getEmail());
        req.setStatus("PENDING");

        ResourceRequest saved = requestRepository.save(req);
        activityLogRepository.save(new ActivityLog(user.getUsername(), "REQUEST_SUBMITTED", "Requested " + saved.getResourceName() + " for " + saved.getPurpose()));
        return new ResponseEntity<>(saved, HttpStatus.CREATED);
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<ResourceRequest> updateStatus(@PathVariable Long id, @RequestBody Map<String, String> body, HttpSession session) {
        UserResponse user = authService.getAuthenticatedUser(session);

        ResourceRequest req = requestRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Resource request not found with ID: " + id));

        String newStatus = body.get("status");
        String remarks = body.getOrDefault("adminRemarks", "");

        if (newStatus != null && !newStatus.isBlank()) {
            req.setStatus(newStatus.trim().toUpperCase());
        }
        if (remarks != null) {
            req.setAdminRemarks(remarks);
        }

        ResourceRequest updated = requestRepository.save(req);
        activityLogRepository.save(new ActivityLog(user.getUsername(), "REQUEST_" + req.getStatus(), "Updated request #" + id + " to " + req.getStatus()));
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteRequest(@PathVariable Long id, HttpSession session) {
        UserResponse user = authService.getAuthenticatedUser(session);

        ResourceRequest req = requestRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Resource request not found with ID: " + id));

        requestRepository.delete(req);
        activityLogRepository.save(new ActivityLog(user.getUsername(), "REQUEST_CANCELLED", "Deleted resource request #" + id));
        return ResponseEntity.ok(Map.of("success", true, "message", "Resource request deleted successfully."));
    }
}
