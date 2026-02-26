package com.calculator;

import org.springframework.web.bind.annotation.*;

@RestController
public class LoginController {

    @PostMapping("/login")
    public String login(@RequestBody LoginRequest request) {

        // hardcoded username and password
        if("admin".equals(request.getUsername()) &&
           "password".equals(request.getPassword())) {

            return "SUCCESS";
        }

        return "FAIL";
    }

}

class LoginRequest {

    private String username;
    private String password;

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}