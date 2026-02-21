package com.calculator;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class RequestLoggingFilter extends OncePerRequestFilter {
    private static final Logger log = LoggerFactory.getLogger(RequestLoggingFilter.class);

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String uri = request.getRequestURI();
        String method = request.getMethod();

        // Only log calculator calls to reduce noise
        if (uri != null && uri.startsWith("/calc")) {
            String op = "";
            String[] parts = uri.split("/");
            if (parts.length >= 3) op = parts[2];

            String a = request.getParameter("a");
            String b = request.getParameter("b");

            String clientIp = extractClientIp(request);

            log.info("Request: op={} a={} b={} method={} path={} clientIp={}", op, a, b, method, uri, clientIp);
        }

        filterChain.doFilter(request, response);
    }

    private String extractClientIp(HttpServletRequest request) {
        String xf = request.getHeader("X-Forwarded-For");
        if (xf != null && !xf.isBlank()) {
            return xf.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
/* 
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
 AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

GITHUB_TOKEN=ghp_1234567890abcdefghijklmnopqrstuvwxyz

DB_PASSWORD=SuperSecretPassword123!
*/