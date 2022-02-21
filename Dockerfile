ARG APP_INSIGHTS_AGENT_VERSION=3.2.6
FROM hmctspublic.azurecr.io/base/java:17-distroless

COPY build/libs/moj-rhubarb-recipes-service.jar /opt/app/
COPY lib/applicationinsights.json /opt/app/

CMD ["moj-rhubarb-recipes-service.jar"]
