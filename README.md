# budget-dbt

Project using data build tool (dbt) to load, normalise, and analyse financial transactions with SQLite.

## Setup

The project requires the SQLite CLI, which can be installed using winget:
```sh
winget install --id SQLite.SQLite
```

It also requires SQLite extensions for cryptography functions, which can be added by:

1. Install the [SQLPkg CLI](https://github.com/nalgeon/sqlpkg-cli)
2. Install the crypto extension:
    ```sh
    sqlpkg install nalgeon/crypto
    ```
3. Add the extension path to the dbt `profiles.yml` file:
    ```yml
    dev:
      extensions:
        - '~/.sqlpkg/nalgeon/crypto/crypto.dll'
    ```
4. It's also helpful to add the extension and other settings to the `~/.sqliterc` file:
    ```sh
    .headers on
    .load C:\Users\{USER}\.sqlpkg/nalgeon/crypto/crypto.dll
    ```