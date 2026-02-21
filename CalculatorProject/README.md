CalculatorProject
=================

Simple Spring Boot calculator service with a static frontend.

Build and run locally
---------------------

2. Run (direct jar on Linux):

```bash
java -jar CalculatorProject/target/CalculatorProject-1.0.jar
```

Or use the included start/stop helpers (recommended for background runs):

```bash
cd CalculatorProject
# build first
mvn clean package -DskipTests
./bin/start.sh
./bin/stop.sh
```

Open http://localhost:8080/ to use the frontend.
```

Run container:

```bash
docker run -p 8080:8080 --rm calculator:latest
```

Notes
-----
- API endpoints: `/calc/add`, `/calc/sub`, `/calc/mul`, `/calc/div`.
- Frontend uses the same host (relative paths) so it works when served from the app.
- Division by zero returns HTTP 400 with an error message.

Logging
-------
- Logs are written to `./logs/app.log` by default (configurable via `LOG_HOME` environment variable or JVM property `-DLOG_HOME=/path/to/logs`).
- A rolling daily log with size-based rotation is configured in `src/main/resources/logback-spring.xml`.
- Incoming requests to the web UI are logged with the performed operation and input values (query params `a` and `b`) and the client IP. See `src/main/java/com/calculator/RequestLoggingFilter.java` for details.

Running as a Linux service (systemd)
----------------------------------
Copy the jar to `/opt/calculator` (or your preferred location) and the `systemd/calculator.service` template shows the `ExecStart` to use. Example steps:

```bash
sudo mkdir -p /opt/calculator /var/log/calculator
sudo cp CalculatorProject/target/CalculatorProject-1.0.jar /opt/calculator/
sudo cp CalculatorProject/systemd/calculator.service /etc/systemd/system/calculator.service
sudo systemctl daemon-reload
sudo systemctl enable --now calculator.service
sudo journalctl -u calculator -f
```

Adjust the `User` and paths in the unit file as needed.
