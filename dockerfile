FROM eclipse-temurin:25-jdk AS base
SHELL ["/bin/bash", "-c"]

FROM base AS build
ENV BUILD_PATH="/appbuild"
USER root:root

RUN rm -rf /var/lib/apt/list/*

USER 1000:1000
WORKDIR ${BUILD_PATH}

COPY --chown=1000:1000 gradlew.bat gradlew build.gradle settings.gradle ./
COPY --chown=1000:1000 gradle ./gradle

RUN chmod +x ${BUILD_PATH}/gradlew \
    && chown -R 1000:1000 .
RUN ./gradlew dependencies

COPY --chown=1000:1000 . .
# can add args later
RUN ./gradlew assemble

FROM eclipse-temurin:25-jdk
ARG APP_BUILD_PATH="/appbuild"
ARG APP_BUILD_FOLDER="build/libs"
ENV APP_PATH="/app"

USER root:root
WORKDIR ${APP_PATH}

COPY --from=build ${APP_BUILD_PATH}/${APP_BUILD_FOLDER}/*.jar ${APP_PATH}/app.jar

USER 1000:1000
# can add args later
ENTRYPOINT ["sh", "-c", "java -jar ${APP_PATH}/app.jar"]