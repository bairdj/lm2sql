#' Create SQL function definition from linear model
#'
#' Generates a user-defined SQL function from a fitted linear model which can then be used for prediction.
#'
#' @param model Model to create SQL function from
#' @param fn_title Name of function to create. Should generally include the schema
#' @param numeric_type SQL type to use for numeric parameters. This is also used in the coefficient definitions
#' @param return_type SQL type of return value
#' @param ... Additional arguments
#'
#' @return Response
#' @export
#'
#' @rdname toSql
#' @importFrom methods setGeneric setMethod
#'
#' @examples
#' fitted_model <- lm(mpg ~ cyl + wt, data=mtcars)
#' toSql(fitted_model, "dbo.PredictModel")
#'
setGeneric("toSql", function(model, fn_title, numeric_type = "NUMERIC(24, 6)", return_type = "NUMERIC(10,6)", ...) {
  standardGeneric("toSql")
  })


#' @rdname toSql
#' @importFrom glue glue_collapse glue_data
setMethod("toSql", "lm", function(model, fn_title, numeric_type, return_type) {
  terms <- attr(model$terms, "dataClasses")[attr(model$terms,"term.labels")]
  # Map R types to SQL types https://docs.microsoft.com/en-us/sql/machine-learning/r/r-libraries-and-data-types?view=sql-server-ver15
  terms[terms == "numeric"] <- numeric_type
  terms[terms == "integer"] <- "INT"
  terms[terms == "POSIXct"] <- "DATETIME"
  terms[terms == "character"] <- "VARCHAR(MAX)"
  params <- list(name=names(terms), type=terms)
  param_string <- glue::glue_collapse(glue::glue_data(params, "@{name} {type}"), sep=", ")
  coefficients <- data.frame(name=names(model$coefficients), value=model$coefficients)
  intercept <- coefficients[coefficients$name == "(Intercept)",]$value
  coefficients <- coefficients[coefficients$name != "(Intercept)",]
  coefficient_string <- glue::glue_collapse(glue::glue_data(coefficients, "DECLARE @{get_coefficient_name(name)} {numeric_type} = {value};"),sep="\n")
  calc_string <- glue::glue_collapse(glue::glue_data(coefficients, "(@{get_coefficient_name(name)} * @{name})"), sep = " + ")
  template <- "CREATE FUNCTION {fn_title} ({param_string})
             RETURNS {return_type}
             BEGIN
             -- Coefficient declarations
             DECLARE @coefIntercept {numeric_type} = {intercept};
             {coefficient_string}
             -- Response calculation
             RETURN @coefIntercept + {calc_string};
             END
             "
  return(glue::glue(template))
})
