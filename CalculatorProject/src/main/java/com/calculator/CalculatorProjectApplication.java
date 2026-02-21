package com.calculator;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SpringBootApplication
public class CalculatorProjectApplication {
	private static final Logger log = LoggerFactory.getLogger(CalculatorProjectApplication.class);

	public static void main(String[] args) {
		log.info("Starting CalculatorProject application");
		for (int i = 0; i < args.length; i++) {
			log.debug("Arg[{}] = {}", i, args[i]);
		}
		SpringApplication.run(CalculatorProjectApplication.class, args);
		log.info("CalculatorProject started successfully");
	}
}
