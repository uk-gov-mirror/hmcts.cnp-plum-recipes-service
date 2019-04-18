package uk.gov.hmcts.reform.rhubarb.recipes.domain;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class Recipe {

    private final String id;
    @JsonIgnore
    private final String userId;
    private final String name;
    private final String ingredients;
    private final String method;
}
