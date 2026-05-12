---
description: Security baseline for all generated or modified code
globs:
alwaysApply: true
---
# Security Baseline

Apply to all code generated or modified, regardless of language.

## Secrets
Never hardcode API keys, tokens, passwords, or certificates. Use environment variables or a secrets manager.
Never include secrets in comments, logs, test fixtures, or example code.

## SQL
Never construct SQL with string interpolation or concatenation on external input. Always use parameterized queries.
BAD:  `query = f"SELECT * FROM users WHERE id = {user_id}"`
GOOD: `cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))`

## Code Execution
Never use `eval`, `exec`, or equivalent dynamic code execution on any input that is not fully controlled by the application itself.

## TLS
Never disable certificate verification. Never set `verify=False`, `InsecureSkipVerify: true`, or equivalent.
Enforce TLS 1.2 minimum on all new TLS configuration.

## Cryptography
Never use MD5 or SHA-1 for security purposes. Use SHA-256 or stronger.
Never use ECB mode. For passwords use bcrypt, Argon2, or scrypt -- never plain hash.
For tokens, nonces, or session IDs use a cryptographically secure random source.

## Logging
Never log passwords, tokens, session IDs, PII, or internal stack traces in responses returned to callers.
Error messages to external callers must be generic. Detailed context goes to server-side logs only.

## Dependencies
Never pin to `latest` or open version ranges. Always pin exact versions.
Before suggesting a package install, verify the exact package name matches the intended library -- flag typosquatting risk.

## Input Validation
Validate all input at trust boundaries. Whitelist allowed values where possible. Never pass raw external input into file operations, shell commands, queries, or template engines.

## Prompt Construction
When writing code that constructs LLM prompts programmatically, always structurally separate system instructions from external content. Never concatenate raw document text, API responses, or user input directly with system instructions.
BAD:  `prompt = system_prompt + user_document`
GOOD: `prompt = system_prompt + "<untrusted_data>" + user_document + "</untrusted_data>"`

## SSRF (Server-Side Request Forgery)
Never pass user-controlled URLs or hostnames directly to HTTP clients, DNS resolvers, or any outbound network call.
Before making an outbound request with a user-supplied URL, validate and reject requests to:
- Loopback: `127.0.0.1`, `::1`, `localhost`
- Link-local / cloud metadata: `169.254.169.254`, `fd00::/8`
- Private RFC1918 ranges: `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`
- Internal hostnames: anything not resolving to a public IP
Parse the URL, resolve the hostname, and check the resolved IP -- not just the raw string.

## JWT
Never accept a JWT without explicitly specifying the expected algorithm.
Never trust `alg: none`. Reject tokens where `alg` differs from what the server issued.
Always verify the signature before reading any claim. Never decode without verification.
BAD:  `jwt.decode(token)` -- uses algorithm from the token header itself
GOOD: `jwt.decode(token, secret, algorithms=["HS256"])`

## Open Redirect
Never redirect to a URL taken directly from user input without an allowlist.
BAD:  `redirect(request.args.get("next"))`
GOOD: Validate the destination is a relative path or matches an explicit allowlist of trusted domains.

## Cookie Security
Always set `HttpOnly`, `Secure`, and `SameSite` flags on session and auth cookies.
`HttpOnly` -- prevents JavaScript from reading the cookie (XSS session hijack mitigation).
`Secure` -- cookie only sent over HTTPS.
`SameSite=Strict` (or `Lax`) -- CSRF mitigation.
Never set session cookies without all three flags.

## HTTP Security Headers
All HTTP responses serving HTML must include:
- `Content-Security-Policy` -- restrict script/style/frame sources
- `X-Content-Type-Options: nosniff` -- prevent MIME sniffing
- `X-Frame-Options: DENY` -- prevent clickjacking
- `Strict-Transport-Security: max-age=31536000; includeSubDomains` -- enforce HTTPS

## Mass Assignment
Never bind a raw HTTP request body or query parameters directly to a database model or entity.
Always use an explicit DTO or allowlist of permitted fields.
BAD:  `user.update(request.body)` -- attacker can set `role: admin`
GOOD: `user.update({ name: body.name, email: body.email })` -- explicit fields only
