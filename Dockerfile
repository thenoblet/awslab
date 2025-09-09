# Stage 1: Build the application using Maven
FROM maven:3.8-openjdk-21 AS build
WORKDIR /app
COPY pom.xml .
# Download dependencies first to leverage Docker layer caching
RUN mvn dependency:go-offline
COPY src ./src
# Build the application, skipping tests for a faster pipeline build
RUN mvn package -DskipTests

# Stage 2: Create the final lightweight image
FROM amazoncorretto:21-alpine-jre
WORKDIR /app
# Copy the built JAR from the 'build' stage
COPY --from=build /app/target/*.jar app.jar
# Expose the port the application runs on (default for Spring Boot is 8080)
EXPOSE 8080
# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
