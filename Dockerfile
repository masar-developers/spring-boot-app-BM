# Stage 1: Build Stage
FROM openjdk:17-jdk-slim AS builder
WORKDIR /app
COPY . .
RUN ./gradlew build -x test

# Stage 2: Run Stage
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=builder /app/build/libs/demo-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 80
ENTRYPOINT ["java", "-jar", "app.jar"]