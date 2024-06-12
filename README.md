
We are using [Material Theme](https://squidfunk.github.io/mkdocs-material/setup/changing-the-colors/).

If we want to version the documentation: [Setting up versioning](https://squidfunk.github.io/mkdocs-material/setup/setting-up-versioning/)

- [Documentation to handle multi-languages](https://github.com/squidfunk/mkdocs-material/discussions/2346)
- [Documentation on folder structure and overriding](https://squidfunk.github.io/mkdocs-material/customization/#extending-the-theme)


# Local testing

## Single language with auto-refresh

Using `mkdocs serve` the website will auto refresh if you modify markdown files.
But you can activate this for a single language.

Execute following command (for english) :

```
pipenv run mkdocs serve -f config/en/mkdocs.yml
```

The website will be accessible in local at [http://localhost:8000/](http://localhost:8000/)

Each time you modify markdown files, the website will be refreshed.


## Multi language

Execute following commands :

```
pipenv shell
mkdocs build -f config/en/mkdocs.yml
mkdocs build -f config/fr/mkdocs.yml
python -m http.server 8000 -d site
```

The website will be accessible in local at [http://localhost:8000/en/](http://127.0.0.1:8000/en/)

To refreh the website, you'll have to execute again build commands and restart http server.

*Note: you'll not be able to switch languages as URL is not good in local*