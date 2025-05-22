# Spring Boot Docker 기반 애플리케이션 (Pet API, PostgreSQL, Docker Compose 활용)

이 프로젝트는 간단한 'Pet(반려동물)' 정보를 관리하는 REST API를 제공하는 Spring Boot 애플리케이션입니다. Docker Compose를 사용하여 애플리케이션과 PostgreSQL 데이터베이스를 컨테이너 환경에서 손쉽게 실행하고 관리할 수 있도록 구성되어 있습니다. 이 문서는 프로젝트 설정, 빌드, Docker Compose를 사용한 실행 및 API 사용 방법에 대해 안내합니다.

## ✨ 주요 기능

* Pet(반려동물) 엔티티 관리를 위한 REST API (`/api/pet`) 제공
* Pet 정보 전체 조회 (GET) 및 신규 등록 (POST) 기능 구현
* 최적화된 이미지 크기를 위한 멀티 스테이지 Dockerfile
* PostgreSQL을 데이터베이스 백엔드로 사용 (컨테이너화)
* **Docker Compose를 통한 다중 컨테이너 애플리케이션 정의 및 실행**
* `.env` 파일 및 Spring 프로필을 통한 구성 관리
* **볼륨을 사용한 데이터 영속화**

## 🛠️ 사전 준비 사항

시작하기 전에 다음 프로그램들이 설치되어 있는지 확인하세요:

* [Docker Desktop](https://www.docker.com/get-started) (Windows, macOS 사용자) 또는 Docker Engine 및 Docker Compose CLI (Linux 사용자)
* [Git](https://git-scm.com/) (리포지토리 복제를 위해)
* Java Development Kit (JDK) (예: Eclipse Temurin 17 이상) - Docker 빌드 전에 로컬에서 Java 프로젝트를 빌드할 경우 필요. Docker 빌드 자체는 JDK 이미지를 사용.
* 텍스트 편집기 또는 IDE

## ⚙️ 프로젝트 설정

### 1. 리포지토리 복제 (Clone)

```bash
git clone <your-repository-url>
cd <your-project-directory>
```
`<your-repository-url>`과 `<your-project-directory>`를 실제 값으로 변경해주세요.

### 2. 환경 변수 설정 (`.env` 파일)

프로젝트의 루트 디렉토리에 `.env` 파일을 생성합니다. 이 파일은 Docker Compose 및 애플리케이션 컨테이너에 환경 변수를 전달하는 데 사용됩니다.

**`./.env` 파일 내용 예시:**

```env
# Spring Boot Application DB Connection
DB_URL=jdbc:postgresql://db:5432/${DB_NAME} # Docker Compose 서비스 이름 'db' 사용
DB_USERNAME=postgres
DB_PASSWORD=rootpass # Spring Boot 앱이 사용할 비밀번호

# Ports (호스트 외부 포트 설정)
APP_PORT=18787
DB_PORT=15432

# PostgreSQL Container Settings (docker-compose.yml의 db 서비스에서 사용)
POSTGRES_USER=${DB_USERNAME}
POSTGRES_PASSWORD=${DB_PASSWORD} # 또는 rootpass와 같이 직접 설정
DB_NAME=mydatabase # 애플리케이션에서 연결할 데이터베이스 이름

# Spring Profile (선택 사항, docker-compose.yml에서 직접 설정 가능)
# SPRING_PROFILES_ACTIVE=dev
```

**주요 환경 변수 설명:**
* `DB_URL`: 애플리케이션이 데이터베이스에 연결하기 위한 JDBC URL입니다. Docker Compose 네트워크 내에서 `db` 서비스(PostgreSQL 컨테이너)를 찾도록 호스트 이름을 `db`로 지정합니다. `${DB_NAME}`은 아래 정의된 데이터베이스 이름을 참조합니다.
* `DB_USERNAME`, `DB_PASSWORD`: 애플리케이션이 DB에 접속 시 사용할 사용자 정보입니다.
* `APP_PORT`, `DB_PORT`: 호스트 머신과 컨테이너 간 포트 매핑 시 사용할 호스트 측 포트 번호입니다.
* `POSTGRES_USER`, `POSTGRES_PASSWORD`, `DB_NAME`: PostgreSQL 컨테이너가 시작될 때 데이터베이스 및 사용자를 초기화하기 위해 사용되는 값들입니다. Docker Compose 파일에서 이 변수들을 참조합니다.

## 🐳 Docker Compose를 사용한 실행 및 관리

이 프로젝트는 Docker Compose를 사용하여 여러 컨테이너(애플리케이션, 데이터베이스)를 쉽게 관리합니다.

### Docker Compose란?

Docker Compose는 여러 컨테이너로 구성된 Docker 애플리케이션을 정의하고 실행하기 위한 도구입니다. `docker-compose.yml`이라는 YAML 파일을 사용하여 애플리케이션의 서비스, 네트워크, 볼륨 등을 설정하고, `docker-compose up`, `docker-compose down`과 같은 단일 명령으로 전체 애플리케이션 스택을 관리할 수 있습니다.

### Docker Compose 사용의 이점

* **다중 컨테이너 관리 단순화**: 여러 `docker run` 명령 대신, YAML 파일과 간단한 명령으로 전체 스택을 쉽게 관리합니다.
* **설정 중앙 집중화 및 버전 관리**: 모든 서비스 구성이 `docker-compose.yml` 파일 하나에 모여있어 관리가 용이하고, Git 등으로 버전 관리가 가능합니다.
* **자동 네트워크 설정 및 서비스 디스커버리**: Compose가 생성한 네트워크 내에서 서비스 이름을 호스트명으로 사용하여 컨테이너 간 통신이 간편해집니다. (예: `app` 서비스에서 `db` 서비스로 접근)
* **일관되고 재현 가능한 환경**: `Dockerfile`이 이미지의 재현성을 보장하듯, `docker-compose.yml`은 다중 컨테이너 환경의 재현성을 보장합니다.
* **개발 효율성 향상**: 로컬에서 전체 애플리케이션 스택을 빠르게 시작하고 중지할 수 있습니다.
* **데이터 영속성 관리**: 볼륨 설정을 통해 컨테이너가 중지/삭제되어도 데이터베이스 데이터와 같은 중요 데이터를 안전하게 보존합니다.

### `docker-compose.yml` 파일 설정 개요

프로젝트 루트의 `docker-compose.yml` 파일은 다음과 같은 주요 서비스와 설정을 포함합니다:

* **`services:`**
    * **`app` (Spring Boot 애플리케이션 서비스)**:
        * 현재 디렉토리의 `Dockerfile`을 사용하여 이미지를 빌드 (`build: .`).
        * `.env` 파일에서 환경 변수 로드 (`env_file: .env`).
        * 호스트의 `${APP_PORT}`와 컨테이너의 `8080` 포트 매핑.
        * `db` 서비스에 대한 의존성 및 `healthcheck` 조건 설정.
        * `app-network` 사용자 정의 네트워크 사용.
    * **`db` (PostgreSQL 데이터베이스 서비스)**:
        * `postgres:16-alpine` 이미지 사용.
        * `.env` 파일의 변수를 참조하여 `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB` 환경 변수 설정.
        * 호스트의 `${DB_PORT}`와 컨테이너의 `5432` 포트 매핑.
        * `postgres-data` 명명된 볼륨을 사용하여 데이터 영속화.
        * `app-network` 사용자 정의 네트워크 사용 및 `healthcheck` 설정.
* **`volumes:`**:
    * `postgres-data`: PostgreSQL 데이터를 저장하기 위한 명명된 볼륨 정의.
* **`networks:`**:
    * `app-network`: `app`과 `db` 서비스 간 통신을 위한 사용자 정의 브릿지 네트워크 정의.

### 실행 방법

1.  **(선택 사항) 이전에 수동으로 실행한 컨테이너 정리**:
    이전에 `docker run`으로 실행한 컨테이너가 있다면 충돌을 피하기 위해 정리합니다.
    ```bash
    docker stop boot-container-review postgres
    docker rm boot-container-review postgres
    docker network rm db-network
    ```
2.  **Docker Compose로 전체 스택 시작**:
    프로젝트 루트 디렉토리에서 다음 명령을 실행합니다.
    ```bash
    docker-compose up --build -d
    ```
    * `--build`: 이미지를 새로 빌드합니다 (소스 코드나 Dockerfile 변경 시 유용).
    * `-d`: 백그라운드(detached mode)에서 실행합니다.
    * 처음 실행 시 또는 로그를 자세히 보고 싶다면 `-d` 없이 `docker-compose up` 실행.

### 주요 명령어 및 실습 내용 요약

* **서비스 상태 확인**:
    ```bash
    docker-compose ps
    ```
    * `app`과 `db` 서비스가 `Up` 상태이고, `db` 서비스가 `(healthy)` 상태인지 확인합니다.

* **로그 확인**:
    ```bash
    docker-compose logs app
    docker-compose logs db
    docker-compose logs -f app # 실시간 로그 확인
    ```

* **실행 중인 컨테이너 내부에서 명령어 실행 (`exec`)**:
    * **DB 컨테이너 접속 및 데이터 확인**:
        ```bash
        docker-compose exec db psql -U ${DB_USERNAME} -d ${DB_NAME}
        ```
      (psql 접속 후) `SELECT * FROM pet;` 실행, `\q`로 종료.
    * **App 컨테이너 환경 변수 확인**:
        ```bash
        docker-compose exec app printenv
        ```
    * **App 컨테이너 파일 시스템 확인** (MINGW64/Git Bash에서는 경로 문제로 `sh -c` 사용):
        ```bash
        docker-compose exec app sh -c "ls -l /app"
        ```

* **특정 서비스 이미지 리빌드**: (소스 코드 변경 시)
    ```bash
    docker-compose build app
    ```
  이후 `docker-compose up -d --no-deps app` 등으로 해당 서비스만 재시작하거나, 전체 스택을 재시작 (`docker-compose down && docker-compose up -d --build`).

* **서비스 중지 및 제거**:
    * **컨테이너, 네트워크만 제거 (볼륨 유지)**:
        ```bash
        docker-compose down
        ```
      이후 `docker volume ls`로 `프로젝트명_postgres-data` 볼륨이 남아있는지 확인. `docker-compose up -d` 시 이 볼륨 재사용.
    * **컨테이너, 네트워크, 볼륨까지 모두 제거**:
        ```bash
        docker-compose down -v
        ```
      이후 `docker volume ls`로 `프로젝트명_postgres-data` 볼륨이 삭제되었는지 확인. `docker-compose up -d` 시 새 빈 볼륨 생성.

---
## 🏗️ 애플리케이션 이미지 빌드 (수동 방식 - 참고용)

Docker Compose를 사용하면 `build: .` 설정으로 인해 `docker-compose up` 시 자동으로 이미지가 빌드되지만, 수동으로 이미지를 빌드하려면 다음 명령을 사용할 수 있습니다.

```bash
docker build -t my-boot:postgres -f Dockerfile .
```

---
## 🌐 애플리케이션 접속

Docker Compose로 서비스가 실행된 후, 호스트 머신의 다음 URL로 애플리케이션에 접속할 수 있습니다. (포트는 `.env` 파일의 `APP_PORT` 값 사용)

* **애플리케이션 URL**: `http://localhost:${APP_PORT}` (예: `http://localhost:18787`)

### 📄 API 명세

애플리케이션은 다음의 API 엔드포인트를 제공합니다.

#### 1. Pet 정보 전체 조회

* **HTTP Method**: `GET`
* **Endpoint**: `/api/pet`
* **설명**: 등록된 모든 Pet(반려동물)의 목록을 조회합니다.
* **`curl` 예시**:
    ```bash
    curl http://localhost:${APP_PORT}/api/pet
    ```

#### 2. 신규 Pet 등록

* **HTTP Method**: `POST`
* **Endpoint**: `/api/pet`
* **설명**: 새로운 Pet(반려동물) 정보를 등록합니다.
* **요청 본문 (JSON)**:
    ```json
    {"name":"새로운펫"}
    ```
* **`curl` 예시** (한글 전송 시 터미널 인코딩 문제로 파일 사용 권장):
    * `payload.json` 파일 생성: `{"name":"컴포즈펫"}` (UTF-8 인코딩으로 저장)
    * 실행:
    ```bash
    curl -X POST -H "Content-Type: application/json; charset=utf-8" -d @payload.json http://localhost:${APP_PORT}/api/pet
    ```

#### 데이터 모델

##### Pet
| 필드명 | 타입   | 설명                     |
|--------|--------|--------------------------|
| `id`   | Long   | 고유 식별자 (자동 생성) |
| `name` | String | 반려동물 이름             |

---
## 📄 Dockerfile 구조

`Dockerfile`은 멀티 스테이지 빌드 방식을 사용합니다:

* **1단계 (`build` 스테이지):** JDK 이미지를 사용하여 Gradle로 Java 애플리케이션을 컴파일하고 실행 가능한 JAR 파일을 빌드합니다.
* **2단계 (런타임 스테이지):** JRE 이미지를 사용하여 `build` 스테이지에서 생성된 JAR 파일만 복사하여 최종 이미지 크기를 최적화합니다.

---
## 💡 프로젝트 핵심 및 컨테이너화의 이점

이 프로젝트의 개발 및 운영 과정에서 **컨테이너 기술(Docker)은 핵심적인 역할**을 수행합니다. 데이터베이스(PostgreSQL)와 Spring Boot 애플리케이션 모두 Docker 컨테이너로 실행되며, Docker 네트워크를 통해 상호 작용합니다. 이러한 컨테이너 기반 접근 방식은 다음과 같은 주요 이점을 제공합니다.

1.  **환경 일관성 (Consistent Environments)**: 개발, 테스트, 운영 환경 전반에 걸쳐 동일한 실행 환경을 보장.
2.  **의존성 관리 단순화 (Simplified Dependency Management)**: 모든 의존성을 컨테이너 내에 캡슐화.
3.  **이식성 향상 (Portability)**: Docker가 설치된 어떤 환경에서도 동일하게 실행.
4.  **격리성 증대 (Isolation)**: 각 컨테이너는 독립적으로 실행되어 안정성과 보안성 향상.
5.  **개발 환경 설정 간소화 (Simplified Setup)**: 몇 가지 명령으로 전체 개발 스택을 빠르게 구축.
6.  **빠른 배포 및 확장성 기반 (Rapid Deployment & Scalability Foundation)**: 신속한 인스턴스 실행 및 유연한 확장.
7.  **재현성 보장 (Reproducibility)**: 빌드 및 실행 환경을 언제든지 동일하게 재현.
8.  **DevOps 문화 촉진 (DevOps Enablement)**: CI/CD 파이프라인 등 현대적인 DevOps 관행 도입에 기여.

---
## 📚 더 알아보기: 유용한 Docker Compose 기능들 (추후 학습 List)

Docker Compose에는 이 프로젝트에서 다룬 것 외에도 유용하고 강력한 기능들이 많습니다. 나중에 더 깊이 학습해보시면 좋을 주제들입니다:

* **`.env` 파일의 고급 활용**:
    * 환경별로 다른 `.env` 파일 사용 (예: `.env.dev`, `.env.prod`).
    * 변수 치환 우선순위 이해.
* **서비스 스케일링 (Service Scaling)**:
    * `docker-compose up --scale <서비스명>=<인스턴스수>` 명령으로 특정 서비스의 컨테이너 수를 늘릴 수 있습니다 (주로 stateless 애플리케이션에 유용).
    * 예: `docker-compose up --scale app=3 -d`
* **여러 `docker-compose.yml` 파일 사용**:
    * 기본 `docker-compose.yml` 파일에 공통 설정을 두고, `docker-compose.override.yml` 또는 개발/운영별 YAML 파일을 만들어 특정 환경에 대한 설정을 겹쳐쓰거나 확장할 수 있습니다.
    * 예: `docker-compose -f docker-compose.yml -f docker-compose.dev.yml up`
* **Healthchecks 심화**:
    * 단순히 서비스 시작 순서만 보장하는 `depends_on` 외에, `healthcheck`를 정교하게 설정하여 서비스가 실제로 준비될 때까지 기다리게 하는 방법 (`start_period`, `timeout`, `retries` 등 상세 설정).
* **Docker Compose 프로필 (Profiles)**:
    * 특정 서비스 그룹에 프로필을 지정하여, `docker-compose --profile <프로필명> up` 명령으로 원하는 서비스 그룹만 선택적으로 시작할 수 있습니다. (예: 기본 웹 서비스 외에 개발용 도구 서비스 그룹 별도 실행)
* **볼륨 드라이버 및 고급 볼륨 옵션**:
    * 로컬 볼륨 외에 클라우드 스토리지 등과 연동되는 다양한 볼륨 드라이버 사용.
* **시크릿(Secrets) 관리**:
    * 비밀번호나 API 키와 같은 민감한 정보를 안전하게 컨테이너에 전달하는 방법.

---
## 💻 기술 스택

* Java 17
* Spring Boot
* Spring Data JPA
* Gradle
* PostgreSQL
* Docker
* **Docker Compose**
* Lombok