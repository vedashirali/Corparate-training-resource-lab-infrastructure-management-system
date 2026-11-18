package com.corplab.platform.repository;

import com.corplab.platform.entity.Lab;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LabRepository extends JpaRepository<Lab, Long> {
    List<Lab> findAllByOrderByCreatedAtDesc();
    long countByStatus(String status);
}
