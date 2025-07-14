FROM eclipse-temurin:21-jdk-alpine AS base
WORKDIR /app
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN chmod +x  mvnw
RUN ./mvnw dependency:resolve
COPY src ./src

FROM base AS test
CMD ["./mvnw", "test"]

FROM base AS development
CMD ["./mvnw", "spring-boot:run"]


FROM base AS build
RUN ./mvnw package

FROM eclipse-temurin:21-jre-alpine AS staging
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring
EXPOSE 8080
COPY --from=build /app/target/springboot-task-tracker-h2-api-poc.jar /home/spring/springboot-task-tracker-h2-api-poc.jar
ENTRYPOINT ["java", "-jar", "/home/spring/springboot-task-tracker-h2-api-poc.jar" ]

FROM eclipse-temurin:21-jre-alpine AS production
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring
EXPOSE 8080
COPY ./target/springboot-task-tracker-h2-api-poc.jar /home/spring/springboot-task-tracker-h2-api-poc.jar
ENTRYPOINT [ "java", "-jar", "/home/spring/springboot-task-tracker-h2-api-poc.jar" ]