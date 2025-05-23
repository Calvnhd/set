# Code conventions
- boolean variables must be prefixed with 'b'
- boolean variables should be named such that they pose a question for which "true" or "false" are valid answers

# Prompt guidlines
- if reading from a prompt file you MUST check for the section heading "FEATURE <number>: <short-description>"
- if a feature headings are present, you MUST implement these features in the order specified from lowest to highest
- treat lower numbered features as higher priority
- treat a given feature as dependent on all features with a lower number
- do not begin designing or implementing a feature until all lower numbered features are implemented