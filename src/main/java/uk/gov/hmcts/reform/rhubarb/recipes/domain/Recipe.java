package uk.gov.hmcts.reform.rhubarb.recipes.domain;

import com.fasterxml.jackson.annotation.JsonIgnore;

public class Recipe {

    public final String id;

    @JsonIgnore
    public final String userId;

    public final String name;

    public final String ingredients;

    public final String method;

    public Recipe(
        String id,
        String userId,
        String name,
        String ingredients,
        String method
    ) {
        this.id = id;
        this.userId = userId;
        this.name = name;
        this.ingredients = ingredients;
        this.method = method;
    }
}
