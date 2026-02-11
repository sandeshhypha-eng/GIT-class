package com.calculator;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/calc")
public class CalculatorController {

    @GetMapping("/add")
    public double add(@RequestParam double a, @RequestParam double b) {
        return a + b;
    }

    @GetMapping("/sub")
    public double subtract(@RequestParam double a, @RequestParam double b) {
        return a - b;
    }

    // @GetMapping("/mul")
    // public double multiply(@RequestParam double a, @RequestParam double b) {
    //     return a * b;
    // }

    // @GetMapping("/div")
    // public double divide(@RequestParam double a, @RequestParam double b) {
    //     if (b == 0) throw new ArithmeticException("Cannot divide by zero");
    //     return a / b;
    // }
}