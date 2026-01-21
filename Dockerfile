FROM eclipse-temurin:21-jdk AS build
WORKDIR /workspace

COPY gradlew gradlew.bat build.gradle settings.gradle /workspace/
COPY gradle /workspace/gradle
COPY src /workspace/src

RUN chmod +x /workspace/gradlew \
  && /workspace/gradlew --no-daemon clean bootJar -x test

FROM eclipse-temurin:21-jre AS runtime
WORKDIR /app

ENV TZ=UTC
ENV JAVA_OPTS=""
ENV SPRING_PROFILES_ACTIVE=prod

RUN useradd -r -u 10001 -g root appuser
USER 10001

COPY --from=build /workspace/build/libs/*.jar /app/app.jar

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]