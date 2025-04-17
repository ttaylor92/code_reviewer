# Elixir Anti-Patterns

## Comments and Documentation
- Avoid overusing comments for self-explanatory code
- Use clear and descriptive function names instead of comments
- Prefer module attributes for magic numbers over comments
- Use `@doc` and `@moduledoc` for documentation instead of comments

## Error Handling
- Avoid complex else clauses in `with` expressions
- Normalize return types in specific private functions
- Use pattern matching for error handling
- Return tuples with `:ok` and `:error` atoms
- Use the `with` special form for complex error handling
- Avoid using exceptions for control flow

## Pattern Matching
- Avoid complex extractions in function clauses
- Extract only pattern/guard related variables in function signatures
- Use pattern matching for data validation
- Be explicit with case statements, avoid using `_` as a catch-all
- Use pattern matching to handle known cases explicitly

## Dynamic Atom Creation
- Never use `String.to_atom/1` with user input
- Use `String.to_existing_atom/1` for dynamic atom creation
- Define all possible atoms explicitly in the module
- Use module functions to convert strings to atoms
- Handle invalid input explicitly

## Function Parameters
- Avoid long parameter lists (more than 5-6 parameters)
- Group related arguments into maps or structs
- Use keyword lists for optional parameters
- Consider splitting functions that take many unrelated arguments

## Namespace Management
- Always use the library name as a prefix for modules
- Avoid defining modules outside your package's namespace
- Follow the established naming conventions for protocols
- Be careful with module names when extending other libraries

## Map Access
- Use `map.key` notation for required fields
- Use `map[:key]` notation for optional fields
- Use pattern matching for multiple key validation
- Consider using structs for fixed field sets
- Be explicit about required vs optional fields

## Truthiness
- Use `and`, `or`, and `not` for boolean operations
- Avoid using `&&`, `||`, and `!` with boolean values
- Be explicit about boolean operations
- Use proper boolean operators when interfacing with Erlang code

## Struct Design
- Keep structs under 32 fields
- Group optional fields into nested maps or structs
- Use nested structs for related fields
- Consider using tuples for fields that are always used together
- Balance API ergonomics with memory efficiency 