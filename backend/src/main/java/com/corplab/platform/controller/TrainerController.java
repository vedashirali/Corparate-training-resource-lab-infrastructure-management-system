package com.corplab.platform.controller;

import com.corplab.platform.dto.UserResponse;
import com.corplab.platform.entity.ActivityLog;
import com.corplab.platform.entity.User;
import com.corplab.platform.exception.ResourceNotFoundException;
import com.corplab.platform.repository.ActivityLogRepository;
import com.corplab.platform.repository.UserRepository;
import com.corplab.platform.service.AuthService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/trainers")
public class TrainerController {

    private final UserRepository userRepository;
    private final AuthService authService;
    private final PasswordEncoder passwordEncoder;
    private final ActivityLogRepository activityLogRepository;

    public TrainerController(UserRepository userRepository,
                             AuthService authService,
                             PasswordEncoder passwordEncoder,
                             ActivityLogRepository activityLogRepository) {
        this.userRepository = userRepository;
        this.authService = authService;
        this.passwordEncoder = passwordEncoder;
        this.activityLogRepository = activityLogRepository;
    }

    @GetMapping
    public ResponseEntity<List<UserResponse>> getAllTrainers(HttpSession session) {
        authService.getAuthenticatedUser(session);
        List<User> trainers = userRepository.findByRoleOrderByCreatedAtDesc("TRAINER");
        List<UserResponse> responses = trainers.stream()
                .map(authService::toUserResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(responses);
    }

    @PostMapping
    public ResponseEntity<UserResponse> createTrainer(@RequestBody Map<String, String> body, HttpSession session) {
        UserResponse actor = authService.getAuthenticatedUser(session);

        String username = body.get("username");
        String email = body.get("email");
        String fullName = body.get("fullName");
        String department = body.getOrDefault("department", "Cloud & DevOps");
        String phone = body.getOrDefault("phone", "");
        String password = body.getOrDefault("password", "Trainer@123");

        if (username == null || username.isBlank() || email == null || email.isBlank()) {
            throw new IllegalArgumentException("Username and Email are required.");
        }
        if (userRepository.existsByUsername(username.trim())) {
            throw new IllegalArgumentException("Username is already in use.");
        }
        if (userRepository.existsByEmail(email.trim().toLowerCase())) {
            throw new IllegalArgumentException("Email is already in use.");
        }

        User user = new User(
                username.trim(),
                email.trim().toLowerCase(),
                (fullName != null && !fullName.isBlank()) ? fullName.trim() : username.trim(),
                passwordEncoder.encode(password),
                "TRAINER",
                department,
                phone
        );
        User saved = userRepository.save(user);

        activityLogRepository.save(new ActivityLog(actor.getUsername(), "TRAINER_CREATED", "Added trainer: " + saved.getFullName()));
        return new ResponseEntity<>(authService.toUserResponse(saved), HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserResponse> updateTrainer(@PathVariable Long id, @RequestBody Map<String, String> body, HttpSession session) {
        UserResponse actor = authService.getAuthenticatedUser(session);

        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Trainer not found with ID: " + id));

        if (body.containsKey("fullName")) user.setFullName(body.get("fullName").trim());
        if (body.containsKey("department")) user.setDepartment(body.get("department").trim());
        if (body.containsKey("phone")) user.setPhone(body.get("phone").trim());

        User updated = userRepository.save(user);
        activityLogRepository.save(new ActivityLog(actor.getUsername(), "TRAINER_UPDATED", "Updated trainer: " + updated.getFullName()));
        return ResponseEntity.ok(authService.toUserResponse(updated));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteTrainer(@PathVariable Long id, HttpSession session) {
        UserResponse actor = authService.getAuthenticatedUser(session);

        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Trainer not found with ID: " + id));

        userRepository.delete(user);
        activityLogRepository.save(new ActivityLog(actor.getUsername(), "TRAINER_DELETED", "Deleted trainer: " + user.getFullName()));
        return ResponseEntity.ok(Map.of("success", true, "message", "Trainer deleted successfully."));
    }
}
