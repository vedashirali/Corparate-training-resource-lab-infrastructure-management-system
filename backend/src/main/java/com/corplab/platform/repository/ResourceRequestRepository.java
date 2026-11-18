package com.corplab.platform.repository;

import com.corplab.platform.entity.ResourceRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ResourceRequestRepository extends JpaRepository<ResourceRequest, Long> {
    List<ResourceRequest> findAllByOrderByCreatedAtDesc();
    List<ResourceRequest> findByRequesterEmailOrderByCreatedAtDesc(String requesterEmail);
    long countByStatus(String status);
}
