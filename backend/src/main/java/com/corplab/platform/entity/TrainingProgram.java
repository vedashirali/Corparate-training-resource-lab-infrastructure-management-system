package com.corplab.platform.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "training_programs")
public class TrainingProgram {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "program_code", nullable = false, unique = true, length = 30)
    private String programCode;

    @Column(nullable = false, length = 150)
    private String title;

    @Column(nullable = false, length = 50)
    private String category; // Cloud, AI, Security, Full Stack

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "trainer_name", length = 100)
    private String trainerName;

    @Column(length = 50)
    private String duration = "4 Weeks";

    @Column(name = "start_date", length = 30)
    private String startDate;

    @Column(name = "end_date", length = 30)
    private String endDate;

    @Column(name = "enrolled_count", nullable = false)
    private Integer enrolledCount = 0;

    @Column(nullable = false, length = 30)
    private String status = "OPEN"; // OPEN, ONGOING, COMPLETED

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.enrolledCount == null) this.enrolledCount = 0;
        if (this.status == null) this.status = "OPEN";
    }

    public TrainingProgram() {}

    public TrainingProgram(String programCode, String title, String category, String description, String trainerName, String duration, String startDate, String endDate, Integer enrolledCount, String status) {
        this.programCode = programCode;
        this.title = title;
        this.category = category;
        this.description = description;
        this.trainerName = trainerName;
        this.duration = duration;
        this.startDate = startDate;
        this.endDate = endDate;
        this.enrolledCount = enrolledCount;
        this.status = status;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getProgramCode() { return programCode; }
    public void setProgramCode(String programCode) { this.programCode = programCode; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getTrainerName() { return trainerName; }
    public void setTrainerName(String trainerName) { this.trainerName = trainerName; }

    public String getDuration() { return duration; }
    public void setDuration(String duration) { this.duration = duration; }

    public String getStartDate() { return startDate; }
    public void setStartDate(String startDate) { this.startDate = startDate; }

    public String getEndDate() { return endDate; }
    public void setEndDate(String endDate) { this.endDate = endDate; }

    public Integer getEnrolledCount() { return enrolledCount; }
    public void setEnrolledCount(Integer enrolledCount) { this.enrolledCount = enrolledCount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }

    @com.fasterxml.jackson.annotation.JsonProperty("code")
    public void setCode(String code) {
        if (this.programCode == null || this.programCode.isBlank()) {
            this.programCode = code;
        }
    }

    @com.fasterxml.jackson.annotation.JsonProperty("trainer")
    public void setTrainer(String trainer) {
        if (this.trainerName == null || this.trainerName.isBlank()) {
            this.trainerName = trainer;
        }
    }
}
