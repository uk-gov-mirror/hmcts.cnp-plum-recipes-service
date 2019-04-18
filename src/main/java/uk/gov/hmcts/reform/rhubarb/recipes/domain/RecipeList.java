package uk.gov.hmcts.reform.rhubarb.recipes.domain;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class RecipeList {

    private final List<Recipe> recipes;
}
