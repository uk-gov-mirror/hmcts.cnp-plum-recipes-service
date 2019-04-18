package uk.gov.hmcts.reform.rhubarb.functional;

import io.restassured.RestAssured;
import org.junit.Before;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static io.restassured.RestAssured.get;

public class RecipesTest {

    private static final Logger log = LoggerFactory.getLogger(RecipesTest.class);

    @Before
    public void before() {
        String appUrl = System.getenv("TEST_URL");
        if (appUrl == null) {
            appUrl = "http://localhost:4550";
        }

        RestAssured.baseURI = appUrl;
        RestAssured.useRelaxedHTTPSValidation();
        log.info("Base Url set to: " + RestAssured.baseURI);
    }

    @Test
    public void recipes_list_returns_200() {
        get("/recipes").then().statusCode(200);
    }
}
