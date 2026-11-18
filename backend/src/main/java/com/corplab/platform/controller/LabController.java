package com.corplab.platform.controller;

import com.corplab.platform.dto.UserResponse;
import com.corplab.platform.entity.ActivityLog;
import com.corplab.platform.entity.Lab;
import com.corplab.platform.exception.ResourceNotFoundException;
import com.corplab.platform.repository.ActivityLogRepository;
import com.corplab.platform.repository.LabRepository;
import com.corplab.platform.service.AuthService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/labs")
public class LabController {

    private final LabRepository labRepository;
    private final AuthService authService;
    private final ActivityLogRepository activityLogRepository;

    public LabController(LabRepository labRepository,
                         AuthService authService,
                         ActivityLogRepository activityLogRepository) {
        this.labRepository = labRepository;
        this.authService = authService;
        this.activityLogRepository = activityLogRepository;
    }

    @GetMapping
    public ResponseEntity<List<Lab>> getAllLabs(HttpSession session) {
        authService.getAuthenticatedUser(session);
        return ResponseEntity.ok(labRepository.findAllByOrderByCreatedAtDesc());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Lab> getLabById(@PathVariable Long id, HttpSession session) {
        authService.getAuthenticatedUser(session);
        Lab lab = labRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Lab not found with ID: " + id));
        return ResponseEntity.ok(lab);
    }

    @PostMapping
    public ResponseEntity<Lab> createLab(@RequestBody Lab lab, HttpSession session) {
        UserResponse actor = authService.getAuthenticatedUser(session);

        if (lab.getLabName() == null || lab.getLabName().isBlank()) {
            throw new IllegalArgumentException("Lab Name is required.");
        }
        if (lab.getLocation() == null || lab.getLocation().isBlank()) {
            throw new IllegalArgumentException("Location is required.");
        }

        Lab saved = labRepository.save(lab);
        activityLogRepository.save(new ActivityLog(actor.getUsername(), "LAB_CREATED", "Created lab venue: " + saved.getLabName()));
        return new ResponseEntity<>(saved, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Lab> updateLab(@PathVariable Long id, @RequestBody Lab updated, HttpSession session) {
        UserResponse actor = authService.getAuthenticatedUser(session);

        Lab lab = labRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Lab not found with ID: " + id));

        if (updated.getLabName() != null) lab.setLabName(updated.getLabName());
        if (updated.getLocation() != null) lab.setLocation(updated.getLocation());
        if (updated.getCapacity() != null) lab.setCapacity(updated.getCapacity());
        if (updated.getDescription() != null) lab.setDescription(updated.getDescription());
        if (updated.getStatus() != null) lab.setStatus(updated.getStatus());

        Lab saved = labRepository.save(lab);
        activityLogRepository.save(new ActivityLog(actor.getUsername(), "LAB_UPDATED", "Updated lab venue: " + saved.getLabName()));
        return ResponseEntity.ok(saved);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteLab(@PathVariable Long id, HttpSession session) {
        UserResponse actor = authService.getAuthenticatedUser(session);

        Lab lab = labRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Lab not found with ID: " + id));

        labRepository.delete(lab);
        activityLogRepository.save(new ActivityLog(actor.getUsername(), "LAB_DELETED", "Deleted lab venue: " + lab.getLabName()));
        return ResponseEntity.ok(Map.of("success", true, "message", "Lab deleted successfully."));
    }
}
