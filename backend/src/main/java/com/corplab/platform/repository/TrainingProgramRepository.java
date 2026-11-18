package com.corplab.platform.repository;

import com.corplab.platform.entity.TrainingProgram;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TrainingProgramRepository extends JpaRepository<TrainingProgram, Long> {
    List<TrainingProgram> findAllByOrderByCreatedAtDesc();
    long countByStatus(String status);
}
