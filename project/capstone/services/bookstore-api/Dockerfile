FROM eclipse-temurin:17-jdk AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
# Use Maven wrapper if available, otherwise the system mvn
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/* \
 && mvn -B -DskipTests package

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=builder /app/target/*.jar /app/app.jar
EXPOSE 8080
USER nobody
CMD ["java", "-jar", "/app/app.jar"]
