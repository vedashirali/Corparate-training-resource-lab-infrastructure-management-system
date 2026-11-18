package com.corplab.platform.repository;

import com.corplab.platform.entity.LabResource;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LabResourceRepository extends JpaRepository<LabResource, Long> {
    List<LabResource> findAllByOrderByCreatedAtDesc();
    long countByStatus(String status);
}
