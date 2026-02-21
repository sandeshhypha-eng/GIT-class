package com.calculator;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;

@RestController
@RequestMapping("/calc")
@CrossOrigin(origins = "*")
public class CalculatorController {
    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(CalculatorController.class);

    @GetMapping("/add")
    public Map<String, Object> add(@RequestParam double a, @RequestParam double b) {
        double r = a + b;
        log.info("add called: a={} b={} result={}", a, b, r);
        return Map.of("operation", "add", "a", a, "b", b, "result", r);
    }

    @GetMapping("/sub")
    public Map<String, Object> subtract(@RequestParam double a, @RequestParam double b) {
        double r = a - b;
        log.info("sub called: a={} b={} result={}", a, b, r);
        return Map.of("operation", "sub", "a", a, "b", b, "result", r);
    }

    @GetMapping("/mul")
    public Map<String, Object> multiply(@RequestParam double a, @RequestParam double b) {
        double r = a * b;
        log.info("mul called: a={} b={} result={}", a, b, r);
        return Map.of("operation", "mul", "a", a, "b", b, "result", r);
    }

    @GetMapping("/div")
    public Map<String, Object> divide(@RequestParam double a, @RequestParam double b) {
        if (b == 0) {
            log.warn("divide called with b=0: a={}", a);
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Cannot divide by zero");
        }
        double r = a / b;
        log.info("div called: a={} b={} result={}", a, b, r);
        return Map.of("operation", "div", "a", a, "b", b, "result", r);
    }
}