---
name: frappe-site-api
description: >-
  Read from or change a running Frappe or ERPNext site through its REST API
  with credentials kept on this machine. Use when a task needs data or
  documents on a live, Frappe Cloud, or local site rather than in a repo.
---
# Frappe site API

## Credentials

Each site's API credentials live in `~/.config/<site>/env`, readable only by the owner (mode 600), never in a repo or in dotfiles:

```bash
export <PREFIX>_ERP_URL='https://<site>'
export <PREFIX>_ERP_API_KEY='…'
export <PREFIX>_ERP_API_SECRET='…'
```

Source the file in the same command that uses it, send `Authorization: token <key>:<secret>`, and never print the key, the secret, or the file unredacted. Find which site a task means by listing `~/.config/*/env` and confirming the URL with the user when more than one fits.

## Reads and writes

- Reads (GET, `get_count`, `get_versions`, `getdoctype`) are inspection and need no approval.
- Any write on a live site (insert, save, submit, cancel, delete, rename, settings, series counters) needs the user's approval naming the site and the action. Say what will change before doing it.
- Prefer a dry run first: `POST /api/method/run_doc_method` with `docs` set to an unsaved document (`"name": "new-<doctype>-check", "__islocal": 1`) runs a whitelisted controller method and returns the result without saving it.
- After a write, read the document back and report its state, with a desk link to it.

## Request details that save a retry

- Start with `GET /api/method/frappe.auth.get_logged_user` to confirm which user the key acts as.
- URL-encode doctype and document names in paths (`Salary%20Slip`, `Sal%20Slip%2FEMP%2F00001`).
- Send a browser- or curl-like `User-Agent` from scripts; some sites refuse Python's default one with 403.
- List calls take JSON in `fields` and `filters`. Aggregates as strings (`count(name)`) are refused; count with `frappe.client.get_count` or by counting rows.
- A list query on a table without `creation` (such as `Series`) needs an explicit `order_by`.
- A whitelisted method on a single doctype (such as Document Naming Settings) through `run_doc_method` must include the document's current `modified`, or it fails with TimestampMismatchError.
- `frappe.client.cancel` cancels a submitted document; `DELETE /api/resource/<doctype>/<name>` deletes a draft or cancelled one; the "Amend" of a cancelled document is a new insert with `amended_from` set.
- A `DELETE` that answers 202 has been accepted; list the doctype again to confirm it is gone.

## Links

Link every document a reply names: `<site-url>/desk/<doctype-slug>/<url-encoded name>` on Frappe v16, `/app/` on v15 and earlier. The doctype slug is lower case with hyphens (`Payment Entry` → `payment-entry`).
