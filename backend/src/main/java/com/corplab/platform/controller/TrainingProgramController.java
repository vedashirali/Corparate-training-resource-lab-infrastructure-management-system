package com.corplab.platform.controller;

import com.corplab.platform.dto.UserResponse;
import com.corplab.platform.entity.ActivityLog;
import com.corplab.platform.entity.TrainingProgram;
import com.corplab.platform.exception.ResourceNotFoundException;
import com.corplab.platform.repository.ActivityLogRepository;
import com.corplab.platform.repository.TrainingProgramRepository;
import com.corplab.platform.service.AuthService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/training-programs")
public class TrainingProgramController {

    private final TrainingProgramRepository programRepository;
    private final AuthService authService;
    private final ActivityLogRepository activityLogRepository;

    public TrainingProgramController(TrainingProgramRepository programRepository,
                                     AuthService authService,
                                     ActivityLogRepository activityLogRepository) {
        this.programRepository = programRepository;
        this.authService = authService;
        this.activityLogRepository = activityLogRepository;
    }

    @GetMapping
    public ResponseEntity<List<TrainingProgram>> getAllPrograms(HttpSession session) {
        authService.getAuthenticatedUser(session);
        return ResponseEntity.ok(programRepository.findAllByOrderByCreatedAtDesc());
    }

    @GetMapping("/{id}")
    public ResponseEntity<TrainingProgram> getProgramById(@PathVariable Long id, HttpSession session) {
        authService.getAuthenticatedUser(session);
        TrainingProgram program = programRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Training program not found with ID: " + id));
        return ResponseEntity.ok(program);
    }

    @PostMapping
    public ResponseEntity<TrainingProgram> createProgram(@RequestBody TrainingProgram program, HttpSession session) {
        UserResponse actor = authService.getAuthenticatedUser(session);

        if (program.getProgramCode() == null || program.getProgramCode().isBlank()) {
            throw new IllegalArgumentException("Program Code is required.");
        }
        if (program.getTitle() == null || program.getTitle().isBlank()) {
            throw new IllegalArgumentException("Program Title is required.");
        }

        TrainingProgram saved = programRepository.save(program);
        activityLogRepository.save(new ActivityLog(actor.getUsername(), "PROGRAM_CREATED", "Created curriculum: " + saved.getTitle()));
        return new ResponseEntity<>(saved, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<TrainingProgram> updateProgram(@PathVariable Long id, @RequestBody TrainingProgram updated, HttpSession session) {
        UserResponse actor = authService.getAuthenticatedUser(session);

        TrainingProgram program = programRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Training program not found with ID: " + id));

        if (updated.getTitle() != null) program.setTitle(updated.getTitle());
        if (updated.getCategory() != null) program.setCategory(updated.getCategory());
        if (updated.getDescription() != null) program.setDescription(updated.getDescription());
        if (updated.getTrainerName() != null) program.setTrainerName(updated.getTrainerName());
        if (updated.getDuration() != null) program.setDuration(updated.getDuration());
        if (updated.getStartDate() != null) program.setStartDate(updated.getStartDate());
        if (updated.getEndDate() != null) program.setEndDate(updated.getEndDate());
        if (updated.getStatus() != null) program.setStatus(updated.getStatus());
        if (updated.getEnrolledCount() != null) program.setEnrolledCount(updated.getEnrolledCount());

        TrainingProgram saved = programRepository.save(program);
        activityLogRepository.save(new ActivityLog(actor.getUsername(), "PROGRAM_UPDATED", "Updated curriculum: " + saved.getTitle()));
        return ResponseEntity.ok(saved);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteProgram(@PathVariable Long id, HttpSession session) {
        UserResponse actor = authService.getAuthenticatedUser(session);

        TrainingProgram program = programRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Training program not found with ID: " + id));

        programRepository.delete(program);
        activityLogRepository.save(new ActivityLog(actor.getUsername(), "PROGRAM_DELETED", "Deleted program: " + program.getTitle()));
        return ResponseEntity.ok(Map.of("success", true, "message", "Training program deleted successfully."));
    }
}
