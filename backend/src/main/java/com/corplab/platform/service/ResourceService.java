package com.corplab.platform.service;

import com.corplab.platform.dto.ResourceRequest;
import com.corplab.platform.entity.LabResource;
import com.corplab.platform.entity.User;
import com.corplab.platform.exception.ResourceNotFoundException;
import com.corplab.platform.exception.UnauthorizedException;
import com.corplab.platform.repository.LabResourceRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ResourceService {

    private final LabResourceRepository resourceRepository;
    private final AuthService authService;

    public ResourceService(LabResourceRepository resourceRepository, AuthService authService) {
        this.resourceRepository = resourceRepository;
        this.authService = authService;
    }

    public List<LabResource> getAllResources(HttpSession session) {
        authService.getAuthenticatedUser(session);
        return resourceRepository.findAllByOrderByCreatedAtDesc();
    }

    public LabResource getResourceById(Long id, HttpSession session) {
        authService.getAuthenticatedUser(session);
        return resourceRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Resource not found with ID: " + id));
    }

    public LabResource createResource(ResourceRequest request, HttpSession session) {
        User currentUser = authService.getCurrentEntity(session);

        LabResource resource = new LabResource(
                request.getTitle().trim(),
                request.getCategory().trim(),
                request.getCapacity(),
                request.getStatus().trim().toUpperCase(),
                request.getDescription(),
                currentUser
        );
        return resourceRepository.save(resource);
    }

    public LabResource updateResource(Long id, ResourceRequest request, HttpSession session) {
        User currentUser = authService.getCurrentEntity(session);
        LabResource resource = getResourceById(id, session);

        if (!resource.getCreatedBy().getId().equals(currentUser.getId()) && !"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
            throw new UnauthorizedException("You are not authorized to update this resource.");
        }

        resource.setTitle(request.getTitle().trim());
        resource.setCategory(request.getCategory().trim());
        resource.setCapacity(request.getCapacity());
        resource.setStatus(request.getStatus().trim().toUpperCase());
        resource.setDescription(request.getDescription());

        return resourceRepository.save(resource);
    }

    public void deleteResource(Long id, HttpSession session) {
        User currentUser = authService.getCurrentEntity(session);
        LabResource resource = getResourceById(id, session);

        if (!resource.getCreatedBy().getId().equals(currentUser.getId()) && !"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
            throw new UnauthorizedException("You are not authorized to delete this resource.");
        }

        resourceRepository.delete(resource);
    }
}