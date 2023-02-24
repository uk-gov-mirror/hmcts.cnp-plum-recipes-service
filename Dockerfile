 # renovate: datasource=github-releases depName=microsoft/ApplicationInsights-Java
ARG APP_INSIGHTS_AGENT_VERSION=3.4.10
ARG PLATFORM=""
FROM hmctspublic.azurecr.io/base/java${PLATFORM}:17-distroless

COPY build/libs/moj-rhubarb-recipes-service.jar /opt/app/
COPY lib/applicationinsights.json /opt/app/

CMD ["moj-rhubarb-recipes-service.jar"]
