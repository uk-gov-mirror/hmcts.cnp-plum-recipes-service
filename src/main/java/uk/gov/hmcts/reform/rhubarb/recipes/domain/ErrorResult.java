package uk.gov.hmcts.reform.rhubarb.recipes.domain;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_EMPTY)
public class ErrorResult {

    private final ErrorCode errorCode;
    private final List<String> errors;
}
