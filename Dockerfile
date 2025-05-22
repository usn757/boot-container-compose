# ./Dockerfile
# Stage 1: Build
# 이미지를 기반으로 빌드 단계를 시작
# 이미지는 Alpine Linux 기반에 Java 17 JDK가 설치되어 있어
# Java 코드를 컴파일하고 빌드하는 데 필요한 모든 도구 제공
# "build"라는 이름으로 지정.
# 나중에 이 단계에서 생성된 결과물을 참조할 때 사용
FROM eclipse-temurin:17-jdk-alpine AS build
# 컨테이너 내의 작업 디렉토리를 /app으로 설정.
# 이후 명령어들은 이 디렉토리에서 실행
WORKDIR /app

# 그래들 파일 복사 및 의존성 캐싱
# 호스트(Dockerfile위치)의 gradlew (Gradle Wrapper 실행 스크립트) 파일을
# 컨테이너의 현재 작업 디렉토리 (/app)로 복사
COPY gradlew .
# 호스트의 gradle 디렉토리(Gradle Wrapper 관련 파일 포함)를
# 컨테이너의 /app/gradle 디렉토리로 복사
COPY gradle gradle
# 호스트의 build.gradle 파일과 settings.gradle 파일(Gradle 빌드 설정 파일)을
# 컨테이너의 /app 디렉토리로 복사
COPY build.gradle settings.gradle ./
# 복사된 gradlew 스크립트에 실행 권한을 부여
RUN chmod +x ./gradlew

# 소스 코드 복사 및 빌드
COPY src src
RUN ./gradlew build -x test

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# 빌드 스테이지에서 JAR 파일만 복사
COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8080

ENV SPRING_PROFILES_ACTIVE=prod

ENTRYPOINT ["java", "-jar", "app.jar"]