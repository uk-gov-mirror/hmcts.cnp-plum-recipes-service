FROM hmcts/cnp-java-base:openjdk-11-distroless-1.0-beta

COPY lib/applicationinsights-agent-2.4.0-BETA-SNAPSHOT.jar lib/AI-Agent.xml /opt/app/
COPY build/libs/moj-rhubarb-recipes-service.jar /opt/app/

CMD ["moj-rhubarb-recipes-service.jar"]
