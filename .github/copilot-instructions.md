# Code conventions
- boolean variables must be prefixed with 'b'. This applies to variables only, not functions.
- boolean variables should be named such that they pose a question for which "true" or "false" are valid answers.  This applies to variables only, not functions.

# Prompt guidlines
## Features
- if reading from a prompt file you MUST check for the section heading "FEATURE <number>: <short-description>"
- if a feature headings are present, you MUST implement these features in the order specified from lowest to highest
- treat lower numbered features as higher priority
- treat a given feature as dependent on all features with a lower number
- do not begin designing or implementing a feature until all lower numbered features are implemented
## Specs
- If reading from a prompt file you MUST check for the section heading "SPEC: <short-description>"
- If the spec heading is present you MUST create a specification sheet with a detailed plan for implementing the spec described under this heading.
- Use the file at .github\prompts\spec-template.md as a template for the specification sheet.
- DO NOT alter any code in the codebase.  ONLY create a spec-sheet.