# latex-action 

[![GitHub Actions Status](https://github.com/tawalaya/latex-diff-action/workflows/Test%20Github%20Action/badge.svg)](https://github.com/tawalaya/latex-diff-action/actions)

GitHub Action to compile LaTeX documents, based on [https://github.com/xu-cheng/latex-action/actions](https://github.com/xu-cheng/latex-action/actions). Extend with [git-latexdiff](https://gitlab.com/git-latexdiff/git-latexdiff) and latex statistics.

It is based on  [a docker image](https://github.com/xu-cheng/latex-docker) with a full [TeXLive](https://www.tug.org/texlive/) environment installed, for more see [Dockerfile](./Dockerfile).

If you want to run arbitrary commands in a TeXLive environment, use [texlive-action](https://github.com/xu-cheng/texlive-action) instead.

## Inputs

* `root_file`

    The root LaTeX file to be compiled. This input is required. You can also pass multiple files as a multi-line string to compile multiple documents. For example:
    ```yaml
    - uses: tawalaya/latex-diff-action@v1
      with:
        root_file: |
          file1.tex
          file2.tex
    ```

* `working_directory`

    The working directory for the LaTeX engine.

* `compiler`

    The LaTeX engine to be invoked. By default, [`latexmk`](https://ctan.org/pkg/latexmk) is used, which automates the process of generating LaTeX documents by issuing the appropriate sequence of commands to be run.

* `args`

    The extra arguments to be passed to the LaTeX engine. By default, it is `-pdf -file-line-error -halt-on-error -interaction=nonstopmode`. This tells `latexmk` to use `pdflatex`. Refer to [`latexmk` document](http://texdoc.net/texmf-dist/doc/support/latexmk/latexmk.pdf) for more information.

* `extra_system_packages`

    The extra packages to be installed by [`apk`](https://pkgs.alpinelinux.org/packages) separated by space. For example, `extra_system_packages: "py-pygments"` will install the package `py-pygments` to be used by the `minted` for code highlights.

* `pre_compile`

    Arbitrary bash codes to be executed before compiling LaTeX documents. For example, `pre_compile: "tlmgr update --all"` to update all TeXLive packages.

* `post_compile`

    Arbitrary bash codes to be executed after compiling LaTeX documents. For example, `post_compile: "latexmk -c"` to clean up temporary files.

**The following inputs are only valid if the input `compiler` is not changed.**

* `latexmk_shell_escape`

    Instruct `latexmk` to enable `--shell-escape`.

* `latexmk_use_lualatex`

    Instruct `latexmk` to use LuaLaTeX.

* `latexmk_use_xelatex`

    Instruct `latexmk` to use XeLaTeX.
* `compile_diff`

  runs `git-latexdiff` against the previous commit using `git-latexdiff --main $root_file  --no-view -o diff.pdf --cleanup all --ignore-makefile HEAD~ --`. Using this together with the `working_directory` might be needed.

* `with_stats`

  uses `latexpand` and `texcount` to give you some latex statisitcs

## Example

```yaml
name: Build LaTeX document
on: [push]
jobs:
  build_latex:
    runs-on: ubuntu-latest
    steps:
      - name: Set up Git repository
        uses: actions/checkout@v2
      - name: Compile LaTeX document
        uses: xu-cheng/latex-action@v2
        with:
          root_file: main.tex
```

For furhter examples look at the [original](https://github.com/xu-cheng/latex-action).

## Gerenrated Files
 - diff.pdf : contains the `latexdiff` results
 - stats.txt : contains the `texcount` stats
 - `root_file`.pdf : containts the compiled tex file

## License

MIT
