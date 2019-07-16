ARG APP_INSIGHTS_AGENT_VERSION=2.5.0-BETA

FROM hmctspublic.azurecr.io/base/java:openjdk-11-distroless-1.0

COPY lib/applicationinsights-agent-2.5.0-BETA.jar lib/AI-Agent.xml /opt/app/
COPY build/libs/moj-rhubarb-recipes-service.jar /opt/app/

CMD ["moj-rhubarb-recipes-service.jar"]
