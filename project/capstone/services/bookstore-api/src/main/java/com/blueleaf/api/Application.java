package com.blueleaf.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@SpringBootApplication
@RestController
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @GetMapping("/api/books")
    public List<Map<String, Object>> books() {
        return List.of(
            Map.of("id", 1, "title", "Site Reliability Engineering", "author", "Beyer et al."),
            Map.of("id", 2, "title", "Accelerate", "author", "Forsgren, Humble, Kim"),
            Map.of("id", 3, "title", "The Phoenix Project", "author", "Gene Kim")
        );
    }

    @GetMapping("/healthz")
    public Map<String, Object> health() {
        return Map.of("ok", true);
    }
}
