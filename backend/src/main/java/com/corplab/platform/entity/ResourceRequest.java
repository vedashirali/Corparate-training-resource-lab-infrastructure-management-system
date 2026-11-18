package com.corplab.platform.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "resource_requests")
public class ResourceRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "resource_name", nullable = false, length = 150)
    private String resourceName;

    @Column(name = "requester_name", nullable = false, length = 100)
    private String requesterName;

    @Column(name = "requester_email", length = 120)
    private String requesterEmail;

    @Column(nullable = false, length = 255)
    private String purpose;

    @Column(name = "booking_date", length = 30)
    private String bookingDate;

    @Column(name = "time_slot", length = 50)
    private String timeSlot = "09:00 - 12:00";

    @Column(nullable = false, length = 30)
    private String status = "PENDING"; // PENDING, APPROVED, REJECTED, COMPLETED

    @Column(name = "admin_remarks", length = 255)
    private String adminRemarks;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.status == null) this.status = "PENDING";
    }

    public ResourceRequest() {}

    public ResourceRequest(String resourceName, String requesterName, String requesterEmail, String purpose, String bookingDate, String timeSlot, String status) {
        this.resourceName = resourceName;
        this.requesterName = requesterName;
        this.requesterEmail = requesterEmail;
        this.purpose = purpose;
        this.bookingDate = bookingDate;
        this.timeSlot = timeSlot;
        this.status = status;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getResourceName() { return resourceName; }
    public void setResourceName(String resourceName) { this.resourceName = resourceName; }

    public String getRequesterName() { return requesterName; }
    public void setRequesterName(String requesterName) { this.requesterName = requesterName; }

    public String getRequesterEmail() { return requesterEmail; }
    public void setRequesterEmail(String requesterEmail) { this.requesterEmail = requesterEmail; }

    public String getPurpose() { return purpose; }
    public void setPurpose(String purpose) { this.purpose = purpose; }

    public String getBookingDate() { return bookingDate; }
    public void setBookingDate(String bookingDate) { this.bookingDate = bookingDate; }

    @com.fasterxml.jackson.annotation.JsonProperty("date")
    public void setDate(String date) {
        if (this.bookingDate == null || this.bookingDate.isBlank()) {
            this.bookingDate = date;
        }
    }

    public String getTimeSlot() { return timeSlot; }
    public void setTimeSlot(String timeSlot) { this.timeSlot = timeSlot; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getAdminRemarks() { return adminRemarks; }
    public void setAdminRemarks(String adminRemarks) { this.adminRemarks = adminRemarks; }

    public LocalDateTime getCreatedAt() { return createdAt; }
}
