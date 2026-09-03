---
name: debug-systematically
description: When something breaks, find the root cause methodically instead of guessing at fixes. Use on any error, test failure, or unexpected behavior.
---

# Debug systematically

**Use when** something errors, a test fails, or behavior is not what you expect.
The goal is the *root cause*, not a patch that makes the symptom disappear.

## Steps

1. **Reproduce it reliably** and capture the exact error message / behavior.
   A bug you can't reproduce, you can't confirm you've fixed.
2. **Form one hypothesis** about the cause.
3. **Test that hypothesis with the smallest possible check** — a single change, a
   print, a narrowed input. Do not change many things at once.
4. **Confirm the root cause** before writing the fix.
5. **Fix it, then verify**: re-run the failing case, and check you didn't break
   anything adjacent.

## Avoid

- "Shotgun debugging" — changing several things and hoping.
- Declaring it fixed without re-running the thing that failed.
- Fixing the symptom while leaving the cause in place.
