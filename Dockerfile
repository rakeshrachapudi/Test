# =========================================
# STAGE 1: Build the application using Maven
# =========================================
FROM maven:3.8.5-openjdk-17 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy only the necessary files for dependency resolution
COPY backend/pom.xml .

# Download dependencies first (leverages Docker caching)
RUN mvn dependency:go-offline

# Copy the actual project source
COPY backend/src ./src

# Build the application (skip tests for faster build)
RUN mvn clean package -DskipTests

# =========================================
# STAGE 2: Create a lightweight runtime image
# =========================================
FROM openjdk:17-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the generated JAR from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the port your Spring Boot app listens on
EXPOSE 8080

# Define the command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]

