package com.corplab.platform;

import com.corplab.platform.entity.*;
import com.corplab.platform.repository.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootApplication
public class PlatformApplication {

    public static void main(String[] args) {
        SpringApplication.run(PlatformApplication.class, args);
        System.out.println("===============================================================");
        System.out.println("  CorpLab Platform REST API is LIVE on http://localhost:8085 ");
        System.out.println("  Web Dashboard Interface: http://localhost:8085/dashboard.html ");
        System.out.println("  MySQL Database: corplab_enterprise_db (Port 3307)          ");
        System.out.println("  Admin Login: admin / Admin@123                              ");
        System.out.println("===============================================================");
    }

    @Bean
    public CommandLineRunner initEnterpriseSeedData(
            UserRepository userRepository,
            LabRepository labRepository,
            LabResourceRepository resourceRepository,
            TrainingProgramRepository programRepository,
            ResourceRequestRepository requestRepository,
            ActivityLogRepository activityLogRepository,
            PasswordEncoder passwordEncoder) {
        return args -> {
            // 1. Seed Admin User
            User admin = userRepository.findByUsernameOrEmail("admin").orElse(null);
            if (admin == null) {
                admin = new User(
                        "admin",
                        "admin@corplab.com",
                        "System Administrator",
                        passwordEncoder.encode("Admin@123"),
                        "ADMIN",
                        "IT Infrastructure",
                        "+1-555-0101"
                );
                admin = userRepository.save(admin);
            }

            // 2. Seed Trainers if missing
            if (userRepository.countByRole("TRAINER") == 0) {
                userRepository.save(new User("david.k", "david.kumar@corplab.com", "David Kumar", passwordEncoder.encode("Trainer@123"), "TRAINER", "Cloud & DevOps", "+1-555-0102"));
                userRepository.save(new User("elena.r", "elena.r@corplab.com", "Elena Rostova", passwordEncoder.encode("Trainer@123"), "TRAINER", "AI & Data Science", "+1-555-0103"));
                userRepository.save(new User("marcus.v", "marcus.v@corplab.com", "Marcus Vance", passwordEncoder.encode("Trainer@123"), "TRAINER", "Cybersecurity", "+1-555-0104"));
            }

            // 3. Seed Employees if missing
            if (userRepository.countByRoleIn(java.util.List.of("EMPLOYEE", "TRAINEE")) == 0) {
                userRepository.save(new User("rahul.s", "rahul.s@corplab.com", "Rahul Sharma", passwordEncoder.encode("Employee@123"), "EMPLOYEE", "Engineering", "+1-555-0105"));
                userRepository.save(new User("priya.p", "priya.p@corplab.com", "Priya Patel", passwordEncoder.encode("Employee@123"), "EMPLOYEE", "Cloud Architecture", "+1-555-0106"));
                userRepository.save(new User("vikram.m", "vikram.m@corplab.com", "Vikram Malhotra", passwordEncoder.encode("Employee@123"), "EMPLOYEE", "DevOps", "+1-555-0107"));
                userRepository.save(new User("neha.d", "neha.d@corplab.com", "Neha Deshmukh", passwordEncoder.encode("Employee@123"), "EMPLOYEE", "Data Science", "+1-555-0108"));
            }

            // 3b. Seed Veda account
            if (userRepository.findByUsernameOrEmail("vedashirali729@gmail.com").isEmpty()) {
                userRepository.save(new User("veda", "vedashirali729@gmail.com", "Veda Shirali", passwordEncoder.encode("ganesha@999999"), "EMPLOYEE", "Engineering", "+91-9999999999"));
            }

            // 3c. Seed Sairam account
            if (userRepository.findByUsernameOrEmail("sairam@gmail.com").isEmpty()) {
                userRepository.save(new User("sairam", "sairam@gmail.com", "Sairam", passwordEncoder.encode("sairam@99999"), "EMPLOYEE", "Engineering", "+91-8888888888"));
            }

            // 4. Seed Labs if missing
            if (labRepository.count() == 0) {
                labRepository.save(new Lab("Cloud Lab A", "Tech Tower B, Floor 3, Room 302", 35, "High-bandwidth facility configured for Kubernetes and Cloud clustering.", "ACTIVE"));
                labRepository.save(new Lab("AI Research Lab", "Innovation Hub, Floor 4, Suite 410", 20, "Climate-controlled lab equipped with high-density GPU compute racks.", "ACTIVE"));
                labRepository.save(new Lab("Dev Lab B", "Engineering Wing, Ground Floor, Room 105", 30, "General development environment with dual-boot Linux/Windows workstations.", "ACTIVE"));
            }

            // 5. Seed Training Programs if missing
            if (programRepository.count() == 0) {
                programRepository.save(new TrainingProgram("DEV-201", "Cloud Infrastructure & Kubernetes Administration", "Cloud Infrastructure", "Hands-on enterprise curriculum covering container orchestration and pod autoscaling.", "David Kumar", "4 Weeks", "2026-11-20", "2026-12-20", 28, "ONGOING"));
                programRepository.save(new TrainingProgram("AI-301", "Deep Learning & Neural Networks Acceleration", "Artificial Intelligence", "Distributed model training, PyTorch CUDA optimization, and TensorRT inference.", "Elena Rostova", "6 Weeks", "2026-11-25", "2027-01-05", 22, "OPEN"));
                programRepository.save(new TrainingProgram("SEC-401", "Enterprise Zero Trust & Cyber Defense Architecture", "Cybersecurity", "Hands-on security auditing, firewall configuration, and incident drills.", "Marcus Vance", "3 Weeks", "2026-12-01", "2026-12-22", 15, "OPEN"));
                programRepository.save(new TrainingProgram("FSJ-101", "Enterprise Java Full Stack with Spring Boot", "Software Engineering", "Building resilient REST APIs with Spring Boot, Hibernate, and modern UI.", "Ananya Sen", "8 Weeks", "2026-11-10", "2027-01-10", 35, "ONGOING"));
            }

            // 6. Seed Lab Resources if missing
            if (resourceRepository.count() == 0) {
                resourceRepository.save(new LabResource("Kubernetes Master Node 01", "Cloud Infrastructure", 64, "AVAILABLE", "Primary cluster controller with 16 vCPUs and Calico CNI", admin));
                resourceRepository.save(new LabResource("NVIDIA RTX 4090 Deep Learning Rig", "AI / GPU Compute", 128, "RESERVED", "Equipped with PyTorch 2.4 and CUDA 12.4 acceleration", admin));
                resourceRepository.save(new LabResource("PostgreSQL HA DB Node", "Database Systems", 32, "AVAILABLE", "High-availability replica node for lab testing and replication", admin));
                resourceRepository.save(new LabResource("DevOps CI/CD Build Runner", "DevOps & CI/CD", 64, "AVAILABLE", "Dedicated runner node for pipeline automation and Docker builds", admin));
            }

            // 7. Seed Resource Requests if missing
            if (requestRepository.count() == 0) {
                requestRepository.save(new ResourceRequest("NVIDIA RTX 4090 Deep Learning Rig", "Rahul Sharma", "rahul.s@corplab.com", "Distributed PyTorch model training and validation", "2026-11-20", "09:00 - 12:00", "APPROVED"));
                requestRepository.save(new ResourceRequest("Kubernetes Master Node 01", "Priya Patel", "priya.p@corplab.com", "Calico Network Policy and ingress testing", "2026-11-22", "14:00 - 17:00", "PENDING"));
                requestRepository.save(new ResourceRequest("DevOps CI/CD Build Runner", "Vikram Malhotra", "vikram.m@corplab.com", "Pipeline stress testing", "2026-11-24", "10:00 - 13:00", "PENDING"));
            }

            // 8. Log initial activity
            activityLogRepository.save(new ActivityLog("SYSTEM", "SYSTEM_READY", "CorpLab Platform Enterprise backend initialized successfully"));
        };
    }
}
