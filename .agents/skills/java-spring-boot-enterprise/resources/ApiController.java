package com.example.demo;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1")
public class ApiController {
    @GetMapping("/status")
    public String getStatus() { return "OK"; }
}
