---
name: concise-validation-messages
description: Write or shorten application validation errors and alerts so users can quickly understand the problem and correct it. Use when creating or revising user-facing validation copy; not for diagnostic logs or conversational responses.
---

Write concise, precise messages in the application's established terminology.

- Use a short title naming the problem, such as "Daily limit exceeded".
- State the failed condition once. Include the relevant date, row, or field only when it identifies what needs attention.
- For limits, show the actual value and allowed value with units. If the limit covers multiple records, label the actual value as the total; do not imply it belongs only to the current record.
- Omit zero-value breakdowns, redundant context, apologies, and introductory wording.
- Add a brief corrective action when the remedy is unclear. Retain necessary distinctions, conditions, and permissions rather than shortening away meaning.
- Prefer product language over setting names or implementation details unless naming a setting helps the user change it.
- Follow existing translation and interpolation conventions. Preserve validation behavior; changing copy alone does not authorize changing limits, permissions, or workflows.

Example:

Before: "2026-10-08: already recorded 0h, this timesheet 8h. Standard Working Hours allows 7h per day."

After, with title "Daily limit exceeded": "2026-10-08: 8h total exceeds the 7h daily limit."

Review that the message accurately identifies the failure and leaves the user enough information to act. When editing code, update existing assertions affected by the copy and follow the repository's verification requirements.
