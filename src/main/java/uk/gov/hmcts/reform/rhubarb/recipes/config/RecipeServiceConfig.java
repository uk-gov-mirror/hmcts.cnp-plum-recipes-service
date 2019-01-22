package uk.gov.hmcts.reform.rhubarb.recipes.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import uk.gov.hmcts.reform.rhubarb.recipes.data.RecipeStore;

@Configuration
public class RecipeServiceConfig {

    @Bean
    public RecipeStore recipeStore(NamedParameterJdbcTemplate jdbcTemplate) {
        return new RecipeStore(jdbcTemplate);
    }
}
