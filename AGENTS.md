# AGENTS.md

## Project goal
Build a Fabric Carpet extension mod named Carpet LIR Addition.
Main scope: renewable-item style survival features exposed as Carpet rules.

## Non-goals
- Do not add UI-heavy features.
- Do not introduce client-only rendering features.
- Do not perform broad refactors unrelated to the current task.
- Do not add many rules at once; keep the first batch to 1-3 real features.

## Required workflow
1. Read this file before making changes.
2. Inspect the existing project structure and preserve conventions.
3. Make small, reviewable commits.
4. Run build/test checks before concluding.
5. Update README and CHANGELOG when behavior changes.

## Rule design rules
- Every feature must be guarded by a Carpet rule.
- Default to conservative values, usually false.
- Use consistent names such as renewableThing or dispenserBehavior.
- Document trigger, effect, failure conditions, and validation steps.

## Mixin rules
- Use mixins only when simpler hooks are insufficient.
- Keep mixins thin.
- Move logic into helpers or feature classes.
- Explain injection targets and purpose in comments.

## Validation rules
For each feature, provide:
- one happy-path verification
- one negative-path verification
- one edge-case note
