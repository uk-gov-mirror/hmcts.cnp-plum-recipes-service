package uk.gov.hmcts.reform.rhubarb.recipes.domain;

import java.util.List;

public class RecipeList {

    public final List<Recipe> recipes;

    public RecipeList(List<Recipe> recipes) {
        this.recipes = recipes;
    }
}
