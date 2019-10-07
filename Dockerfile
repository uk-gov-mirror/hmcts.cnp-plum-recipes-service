ARG APP_INSIGHTS_AGENT_VERSION=2.5.0
FROM hmctspublic.azurecr.io/base/java:openjdk-11-distroless-1.2

COPY lib/AI-Agent.xml /opt/app/
COPY build/libs/moj-rhubarb-recipes-service.jar /opt/app/

CMD ["moj-rhubarb-recipes-service.jar"]
