# EnumModule.psm1



# From repository: https://github.com/ElianFabian/powershell-utils



# This file should be called in the file located at $PROFILE as "using module EnumModule"



enum CaseType
{
    CamelCase;      # camelCase
    PascalCase;     # PascalCase
    SnakeCase;      # snake_case
	UpperSnakeCase; # SNAKE_CASE
	KebabCase;      # kebab-case
	TrainCase;      # Train-Case
}
