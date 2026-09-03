---
name: safe-cleanup
description: Tidy or restructure files without risk — archive instead of delete, preview first, and confirm before anything destructive. Use when organizing, removing clutter, or moving folders around.
---

# Safe cleanup

**Use when** organizing files, clearing clutter, or restructuring folders. The
aim is a tidy workspace with nothing lost and every step reversible.

## Steps

1. **Preview first (dry run).** List exactly what you propose to move or remove,
   and why — before touching anything.
2. **Archive, don't delete.** Move unwanted items to `_archive\YYYY-MM-DD\`
   instead of deleting them.
3. **For genuine deletion, get explicit confirmation** in that moment. A past
   "yes" does not authorize a new delete.
4. **Stay in the workspace.** Never operate on paths outside the `work\` folder.
5. **Verify the result** and keep it reversible (archive folder + version
   control).

## Avoid

- Bulk recursive deletes (`Remove-Item -Recurse -Force`) without confirmation.
- Moving files out of the workspace, or into the private zone.
- "Cleaning up" something you didn't create without flagging it first.
