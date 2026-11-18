package com.corplab.platform.controller;

import com.corplab.platform.dto.ResourceRequest;
import com.corplab.platform.entity.LabResource;
import com.corplab.platform.service.ResourceService;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/resources")
public class ResourceController {

    private final ResourceService resourceService;

    public ResourceController(ResourceService resourceService) {
        this.resourceService = resourceService;
    }

    @GetMapping
    public ResponseEntity<List<LabResource>> getAll(HttpSession session) {
        return ResponseEntity.ok(resourceService.getAllResources(session));
    }

    @GetMapping("/{id}")
    public ResponseEntity<LabResource> getOne(@PathVariable Long id, HttpSession session) {
        return ResponseEntity.ok(resourceService.getResourceById(id, session));
    }

    @PostMapping
    public ResponseEntity<LabResource> create(@Valid @RequestBody ResourceRequest request, HttpSession session) {
        LabResource created = resourceService.createResource(request, session);
        return new ResponseEntity<>(created, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<LabResource> update(@PathVariable Long id, @Valid @RequestBody ResourceRequest request, HttpSession session) {
        LabResource updated = resourceService.updateResource(id, request, session);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> delete(@PathVariable Long id, HttpSession session) {
        resourceService.deleteResource(id, session);
        return ResponseEntity.ok(Map.of("success", true, "message", "Resource deleted successfully."));
    }
}