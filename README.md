Generate a SQL implementation of your fitted linear model.

# Example
    model <- lm(mpg ~ cyl + wt, data=mtcars)
    summary(model)
    Call:
    lm(formula = mpg ~ cyl + wt, data = mtcars)
    
    Residuals:
        Min      1Q  Median      3Q     Max 
    -4.2893 -1.5512 -0.4684  1.5743  6.1004 
    
    Coefficients:
                Estimate Std. Error t value Pr(>|t|)    
    (Intercept)  39.6863     1.7150  23.141  < 2e-16 ***
    cyl          -1.5078     0.4147  -3.636 0.001064 ** 
    wt           -3.1910     0.7569  -4.216 0.000222 ***
    ---
    Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
    
    Residual standard error: 2.568 on 29 degrees of freedom
    Multiple R-squared:  0.8302,	Adjusted R-squared:  0.8185 
    F-statistic: 70.91 on 2 and 29 DF,  p-value: 6.809e-12


Calling `toSql(model, "dbo.PredictMpg")` returns

    CREATE FUNCTION dbo.PredictMpg (@cyl NUMERIC(24, 6), @wt NUMERIC(24, 6))
	RETURNS NUMERIC(10,6)
	BEGIN
	-- Coefficient declarations
	DECLARE @coefIntercept NUMERIC(24, 6) = 39.6862614802529;
	DECLARE @coefCyl NUMERIC(24, 6) = -1.5077949682598;
	DECLARE @coefWt NUMERIC(24, 6) = -3.19097213898374;
	-- Response calculation
	RETURN @coefIntercept + (@coefCyl * @cyl) + (@coefWt * @wt);
	END