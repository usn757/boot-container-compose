# Spring Boot Docker 기반 애플리케이션 (PostgreSQL 연동)

이 프로젝트는 간단한 'Pet(반려동물)' 정보를 관리하는 REST API를 제공하는 Spring Boot 애플리케이션입니다. Docker 컨테이너로 패키징되어 있으며, PostgreSQL 데이터베이스 또한 Docker 컨테이너로 실행하여 연동합니다.

## ✨ 주요 기능

* "Pet(반려동물) 엔티티 관리를 위한 REST API (/api/pet) 제공"
* "Pet 정보 조회 (GET) 및 등록 (POST) 기능 구현"
* 최적화된 이미지 크기를 위한 멀티 스테이지 Dockerfile을 사용한 컨테이너화
* PostgreSQL을 데이터베이스 백엔드로 사용 (컨테이너화)
* 사용자 정의 Docker 네트워크를 통한 컨테이너 간 통신 설정
* `.env` 파일 및 Spring 프로필을 통한 구성 관리



## 🛠️ 사전 준비 사항

시작하기 전에 다음 프로그램들이 설치되어 있는지 확인하세요:

* [Docker](https://www.docker.com/get-started)
* [Git](https://git-scm.com/) (리포지토리 복제를 위해)
* Java Development Kit (JDK) (예: Eclipse Temurin 17 이상) - Docker 빌드 전에 로컬에서 Java 프로젝트를 빌드할 경우 필요합니다. Docker 빌드 자체는 JDK 이미지를 사용합니다.
* 텍스트 편집기 또는 IDE

## ⚙️ 프로젝트 설정

### 1. 리포지토리 복제 (Clone)

```bash
git clone https://github.com/usn757/boot-container
cd boot-container
```

### 2. 환경 변수 설정

프로젝트의 루트 디렉토리에 `.env` 파일을 생성합니다. 이 파일은 애플리케이션 컨테이너에 환경 변수를 전달하는 데 사용됩니다.

**`./.env` 파일 내용:**

```env
DB_URL=jdbc:postgresql://postgres:5432/postgres
DB_USERNAME=postgres
DB_PASSWORD=rootpass
```

**설명:**
* `DB_URL`: PostgreSQL 데이터베이스 연결을 위한 JDBC URL입니다. `postgres`는 사용자 정의 Docker 네트워크에서 PostgreSQL 컨테이너의 서비스 이름으로 사용됩니다.
* `DB_USERNAME`: PostgreSQL 데이터베이스 사용자 이름입니다.
* `DB_PASSWORD`: PostgreSQL 데이터베이스 비밀번호입니다. PostgreSQL 컨테이너 실행 시 설정한 `POSTGRES_PASSWORD`와 일치해야 합니다.

애플리케이션의 Dockerfile은 `SPRING_PROFILES_ACTIVE=prod`로 설정되어 있으므로, `src/main/resources/application-prod.yaml` 파일의 설정을 사용합니다. 이 파일은 위의 환경 변수들을 사용하여 데이터 소스를 구성합니다.

## 🏗️ 애플리케이션 이미지 빌드

제공된 Dockerfile을 사용하여 Spring Boot 애플리케이션용 Docker 이미지를 빌드합니다:

```bash
docker build -t my-boot:postgres -f Dockerfile .
```
(Dockerfile의 이름이 정확히 `Dockerfile`이라면 `-f Dockerfile` 부분은 생략 가능합니다.)

## 🚀 Docker로 애플리케이션 실행하기

애플리케이션과 PostgreSQL 데이터베이스를 실행하려면 다음 단계를 따르세요:

### 1. Docker 네트워크 생성

이 네트워크는 애플리케이션 컨테이너와 데이터베이스 컨테이너가 서로 통신할 수 있도록 합니다.

```bash
docker network create db-network
```

### 2. PostgreSQL 컨테이너 실행

```bash
docker run -d \
    -p 5432:5432 \
    --name postgres \
    --network db-network \
    -e POSTGRES_PASSWORD=rootpass \
    postgres:16-alpine
```
* `-d`: 백그라운드에서 실행 (detached mode).
* `-p 5432:5432`: 호스트의 5432 포트와 컨테이너의 5432 포트를 매핑합니다.
* `--name postgres`: 컨테이너 이름을 `postgres`로 지정합니다.
* `--network db-network`: 이 컨테이너를 `db-network`에 연결합니다.
* `-e POSTGRES_PASSWORD=rootpass`: 기본 `postgres` 사용자의 비밀번호를 설정합니다. **이 값은 `.env` 파일의 `DB_PASSWORD`와 일치해야 합니다.**
* `postgres:16-alpine`: 사용할 PostgreSQL 이미지입니다.

### 3. Spring Boot 애플리케이션 컨테이너 실행

```bash
docker run -d \
    -p 8787:8080 \
    --name boot-container-review \
    --env-file .env \
    --network db-network \
    my-boot:postgres
```
* `-d`: 백그라운드에서 실행.
* `-p 8787:8080`: 호스트의 8787 포트와 컨테이너의 8080 포트를 매핑합니다 (Dockerfile의 `EXPOSE 8080` 및 `application-prod.yaml`의 `server.port`에 정의된 대로).
* `--name boot-container-review`: 컨테이너 이름을 `boot-container-review`로 지정합니다.
* `--env-file .env`: `.env` 파일에서 환경 변수를 로드합니다.
* `--network db-network`: 이 컨테이너를 `db-network`에 연결합니다.
* `my-boot:postgres`: 이전에 빌드한 애플리케이션 이미지입니다.


## 🌐 애플리케이션 접속

두 컨테이너가 모두 실행되면 호스트 머신에서 Spring Boot 애플리케이션에 접속할 수 있습니다.

* **애플리케이션 URL**: `http://localhost:8787`


## 📄 API 명세

애플리케이션은 다음의 API 엔드포인트를 제공합니다.

### 1. Pet 정보 전체 조회

* **HTTP Method**: `GET`
* **Endpoint**: `/api/pet`
* **설명**: 등록된 모든 Pet(반려동물)의 목록을 조회합니다.
* **응답 본문 예시**:
    ```json
    [
        {"id": 1, "name": "꼬미"},
        {"id": 2, "name": "멍멍이"}
    ]
    ```
* **`curl` 예시**:
    ```bash
    curl http://localhost:8787/api/pet
    ```

### 2. 신규 Pet 등록

* **HTTP Method**: `POST`
* **Endpoint**: `/api/pet`
* **설명**: 새로운 Pet(반려동물) 정보를 등록합니다.
* **요청 본문 (JSON)**:
    ```json
    {
        "name": "야옹이"
    }
    ```
* **응답 본문 예시 (HTTP 201 Created)**:
    ```json
    {
        "id": 3,
        "name": "야옹이"
    }
    ```
* **`curl` 예시**:
    ```bash
    curl -X POST -H "Content-Type: application/json" -d '{"name":"야옹이"}' http://localhost:8787/api/pet
    ```

### 데이터 모델

#### Pet
| 필드명 | 타입   | 설명                     |
|--------|--------|--------------------------|
| `id`   | Long   | 고유 식별자 (자동 생성) |
| `name` | String | 반려동물 이름             |

## 📜 로그 확인하기

* **애플리케이션 로그:**
    ```bash
    docker logs boot-container-review
    ```
* **PostgreSQL 로그:**
    ```bash
    docker logs postgres
    ```

## 🛑 중지 및 정리

컨테이너와 네트워크를 중지하고 제거하려면 다음 명령을 사용하세요:

1.  **컨테이너 중지:**
    ```bash
    docker stop boot-container-review postgres
    ```
2.  **컨테이너 제거:**
    ```bash
    docker rm boot-container-review postgres
    ```
3.  **(선택 사항) 네트워크 제거:**
    ```bash
    docker network rm db-network
    ```
4.  **(선택 사항) 애플리케이션 이미지 제거:**
    ```bash
    docker rmi my-boot:postgres
    ```

## 📄 Dockerfile 구조

`Dockerfile`은 멀티 스테이지 빌드 방식을 사용합니다:

* **1단계 (`build` 스테이지):** JDK 이미지(`eclipse-temurin:17-jdk-alpine`)를 사용하여 Gradle로 Java 애플리케이션을 컴파일하고 실행 가능한 JAR 파일을 빌드합니다.
* **2단계 (런타임 스테이지):** JDK 이미지보다 작은 JRE 이미지(`eclipse-temurin:17-jre-alpine`)를 사용합니다. `build` 스테이지에서 빌드된 JAR 파일만 복사하여 애플리케이션 실행에 최적화된 가벼운 최종 이미지를 만듭니다.

## 💻 기술 스택

* Java 17
* Spring Boot
* Gradle
* PostgreSQL
* Docker

