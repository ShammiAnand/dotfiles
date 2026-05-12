---
description: Secure coding rules for Python development
globs: "**/*.py,**/*.pyw,**/*.ipynb"
alwaysApply: false
---
# Secure Python Development

## Deserialization
Never use `pickle`, `marshal`, or `shelve` on untrusted data. Use `json` or `pydantic`.

## YAML / XML
Always use `yaml.safe_load()`, never `yaml.load()`.
Always use `defusedxml` for XML parsing, never stdlib `xml.*` parsers on untrusted input.

## Subprocess
Never use `os.system()`. Use `subprocess.run()` with a list of arguments.
Never pass `shell=True` when any part of the command includes external input.

## Randomness
Never use `random` for tokens, nonces, OTPs, or session IDs. Use `secrets`.
BAD:  `token = str(random.randint(100000, 999999))`
GOOD: `token = secrets.token_urlsafe(32)`

## Secret Comparison
Never use `==` to compare tokens or secrets. Use `hmac.compare_digest()` to prevent timing attacks.

## Path Traversal
When constructing file paths from external input, always resolve and verify the final path stays within the intended directory.
```python
safe = Path("/app/uploads")
resolved = (safe / user_input).resolve()
if not str(resolved).startswith(str(safe)):
    raise ValueError("Path traversal")
```

## Security Checks
Never use `assert` as a security gate. Python strips asserts with `-O`. Use explicit `if` + `raise`.

## Framework-Specific
Flask: never run with `debug=True` outside localhost. Always load `SECRET_KEY` from an environment variable.
FastAPI: always define explicit Pydantic models for request bodies. Never accept `dict` or `Any` from external input.

## Server-Side Template Injection (SSTI)
Never pass user input into `render_template_string()` or any dynamically constructed Jinja2/Mako/Cheetah template.
SSTI in Jinja2 leads directly to RCE.
BAD:
```python
render_template_string(f"Hello {request.args.get('name')}")
```
GOOD:
```python
render_template("hello.html", name=request.args.get("name"))
```

## Path Traversal -- os.path.join Absolute Input
`os.path.join` silently discards all preceding components when it encounters an absolute path segment.
BAD:  `os.path.join("/safe/uploads", "/etc/passwd")` returns `/etc/passwd`
Always use `pathlib.Path` with `.resolve()` and a prefix check -- not `os.path.join` alone.

## ReDoS
Never compile or execute a regex pattern supplied by external input. Python's `re` module has no timeout -- a crafted pattern causes catastrophic backtracking that blocks the process.
If dynamic patterns are required, use the `re2` library (linear time guarantee) and enforce a maximum pattern length.

## Django-Specific
Never use `.raw()` or `.extra()` with string formatting on external input -- they bypass Django ORM parameterization.
BAD:  `User.objects.raw(f"SELECT * FROM users WHERE name = '{name}'")`
GOOD: `User.objects.raw("SELECT * FROM users WHERE name = %s", [name])`
Never set `DEBUG = True` in production.
Always set `ALLOWED_HOSTS` explicitly -- never use `["*"]` in any environment accessible from a network.

## Temporary Files
Never rely on `tempfile.NamedTemporaryFile` for security-sensitive temporary storage.
Use `tempfile.mkstemp()` which returns an OS-level file descriptor with exclusive create semantics:
```python
fd, path = tempfile.mkstemp(suffix=".tmp", dir="/secure/tmp")
try:
    os.write(fd, data)
finally:
    os.close(fd)
    os.unlink(path)
```
