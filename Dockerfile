# Use an OpenJDK image
FROM openjdk:17-jdk-slim

# Set work directory
WORKDIR /app

# Copy the built jar
COPY target/spring-petclinic-*.jar app.jar

# Run the app
ENTRYPOINT ["java", "-jar", "app.jar"]
