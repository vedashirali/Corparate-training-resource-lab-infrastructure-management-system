package com.corplab.platform.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/ai")
public class AiAssistantController {

    @PostMapping("/ask")
    public ResponseEntity<Map<String, Object>> askAi(@RequestBody Map<String, String> request) {
        String prompt = request.getOrDefault("prompt", "").trim();
        if (prompt.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "error", "Prompt cannot be empty."));
        }

        return ResponseEntity.ok(Map.of(
                "success", true,
                "status", "AI Module Ready",
                "message", "CorpLab AI Assistant endpoint is online. Add a Gemini API key whenever you wish to enable live cloud LLM queries.",
                "echoPrompt", prompt
        ));
    }
}
