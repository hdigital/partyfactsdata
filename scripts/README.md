# Development environment

## Formatting tools

Use [mdformat](https://github.com/hukkin/mdformat) for Markdown and
[Air](https://posit-dev.github.io/air/formatter.html) for R code formatting.

```sh
uvx mdformat import/parlgov

air format import/parlgov
```

## Codespaces

The project can use [GitHub Codespaces](https://github.com/features/codespaces) as a development environment.

Dependencies (e.g., R packages, Python tools) are installed when the codespace is created.

### Usage

RStudio Server starts automatically and is accessible in the VS Code 'Ports' tab on port 8787.

Login credentials:

- Username: `rstudio`
- Password: `rstudio`

To manually control RStudio:

```sh
sudo rstudio-server start
sudo rstudio-server stop
```
