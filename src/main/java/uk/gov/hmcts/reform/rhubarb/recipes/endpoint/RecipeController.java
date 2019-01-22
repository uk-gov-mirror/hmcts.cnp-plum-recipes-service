package uk.gov.hmcts.reform.rhubarb.recipes.endpoint;

import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiResponse;
import io.swagger.annotations.ApiResponses;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import uk.gov.hmcts.reform.rhubarb.recipes.data.RecipeStore;
import uk.gov.hmcts.reform.rhubarb.recipes.domain.ErrorResult;
import uk.gov.hmcts.reform.rhubarb.recipes.domain.Recipe;
import uk.gov.hmcts.reform.rhubarb.recipes.domain.RecipeList;
import uk.gov.hmcts.reform.rhubarb.recipes.exception.NoRecipeFoundException;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping(
    path = "recipes",
    produces = MediaType.APPLICATION_JSON_VALUE
)
public class RecipeController {

    private final RecipeStore recipeStore;

    public RecipeController(RecipeStore recipeStore) {
        this.recipeStore = recipeStore;
    }

    @GetMapping(path = "/{id}")
    @ApiOperation("Find recipe by ID")
    @ApiResponses({
        @ApiResponse(code = 200, message = "Success"),
        @ApiResponse(code = 404, message = "Not found", response = ErrorResult.class),
    })
    public Recipe read(
        @PathVariable String id
    ) {

        return recipeStore
            .read(id)
            .orElseThrow(NoRecipeFoundException::new);
    }

    @GetMapping
    @ApiOperation(value = "Find all your drafts", notes = "Returns an empty array when no drafts were found")
    @ApiResponses({
        @ApiResponse(code = 200, message = "Success"),
    })
    public RecipeList readAll(
        @RequestParam(required = false) Map<String, String> params
    ) {

        List<Recipe> recipes = recipeStore.readAll();

        return new RecipeList(recipes);
    }

}
