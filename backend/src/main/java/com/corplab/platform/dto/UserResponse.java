package com.corplab.platform.dto;

public class UserResponse {
    private Long id;
    private String username;
    private String email;
    private String fullName;
    private String role;
    private String department;
    private String phone;

    public UserResponse() {}

    public UserResponse(Long id, String username, String email, String role) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.fullName = username;
        this.role = role;
    }

    public UserResponse(Long id, String username, String email, String fullName, String role, String department, String phone) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.fullName = (fullName != null && !fullName.isBlank()) ? fullName : username;
        this.role = role;
        this.department = department;
        this.phone = phone;
    }

    public Long getId() { return id; }
    public String getUsername() { return username; }
    public String getEmail() { return email; }
    public String getFullName() { return (fullName != null && !fullName.isBlank()) ? fullName : username; }
    public String getRole() { return role; }
    public String getDepartment() { return department; }
    public String getPhone() { return phone; }
}
