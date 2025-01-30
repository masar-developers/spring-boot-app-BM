package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

@RestController
public class LiveController {

    @Autowired
    private DataSource dataSource;

    @GetMapping("/live")
    public ResponseEntity<String> liveCheck() {
        try (Connection connection = dataSource.getConnection()) {
            // If the connection is successful, the application is considered healthy.
            return ResponseEntity.ok("Well done");
        } catch (SQLException e) {
            // If an error happens while making the connection, it is considered "maintenance".
           return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body("Maintenance");
        }
    }
}