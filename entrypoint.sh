#!/usr/bin/env bash

set -e

info() {
  echo -e "\033[1;34m$1\033[0m"
}

warn() {
  echo "::warning :: $1"
}

error() {
  echo "::error :: $1"
  exit 1
}

root_file="${1}"
working_directory="${2}"
compiler="${3}"
args="${4}"
extra_packages="${5}"
extra_system_packages="${6}"
pre_compile="${7}"
post_compile="${8}"
latexmk_shell_escape="${9}"
latexmk_use_lualatex="${10}"
latexmk_use_xelatex="${11}"
compile_diff="${12}"
with_stats="${13}"

if [[ -z "$root_file" ]]; then
  error "Input 'root_file' is missing."
fi

if [[ -z "$compiler" && -z "$args" ]]; then
  warn "Input 'compiler' and 'args' are both empty. Reset them to default values."
  compiler="latexmk"
  args="-pdf -file-line-error -halt-on-error -interaction=nonstopmode"
fi

IFS=' ' read -r -a args <<< "$args"

if [[ "$compiler" = "latexmk" ]]; then
  if [[ -n "$latexmk_shell_escape" ]]; then
    args+=("-shell-escape")
  fi

  if [[ -n "$latexmk_use_lualatex" && -n "$latexmk_use_xelatex" ]]; then
    error "Input 'latexmk_use_lualatex' and 'latexmk_use_xelatex' cannot be used at the same time."
  fi

  if [[ -n "$latexmk_use_lualatex" ]]; then
    for i in "${!args[@]}"; do
      if [[ "${args[i]}" = "-pdf" ]]; then
        unset 'args[i]'
      fi
    done
    args+=("-lualatex")
    # LuaLaTeX use --flag instead of -flag for arguments.
    for VAR in -file-line-error -halt-on-error -shell-escape; do
      for i in "${!args[@]}"; do
        if [[ "${args[i]}" = "$VAR" ]]; then
          args[i]="-$VAR"
        fi
      done
    done
    args=("${args[@]/#-interaction=/--interaction=}")
  fi

  if [[ -n "$latexmk_use_xelatex" ]]; then
    for i in "${!args[@]}"; do
      if [[ "${args[i]}" = "-pdf" ]]; then
        unset 'args[i]'
      fi
    done
    args+=("-xelatex")
  fi
else
  for VAR in "${!latexmk_@}"; do
    if [[ -n "${!VAR}" ]]; then
      error "Input '${VAR}' is only valid if input 'compiler' is set to 'latexmk'."
    fi
  done
fi

if [[ -n "$extra_system_packages" ]]; then
  for pkg in $extra_system_packages; do
    info "Install $pkg by apk"
    apk --no-cache add "$pkg"
  done
fi

if [[ -n "$extra_packages" ]]; then
  warn "Input 'extra_packages' is deprecated. We now build LaTeX document with full TeXLive installed."
fi

if [[ -n "$working_directory" ]]; then
  cd "$working_directory"
fi

if [[ -n "$pre_compile" ]]; then
  info "Run pre compile commands"
  eval "$pre_compile"
fi

while IFS= read -r f; do
  if [[ -z "$f" ]]; then
    continue
  fi

  info "Compile $f"

  if [[ ! -f "$f" ]]; then
    error "File '$f' cannot be found from the directory '$PWD'."
  fi

  "$compiler" "${args[@]}" "$f"
done <<< "$root_file"

if [[ -n "$compile_diff" ]]; then
    latexdiff_compiler_arg=""
  if [[ -n "$latexmk_use_xelatex" ]]; then
      latexdiff_compiler_arg="--xelatex"
  elif [[ -n "$latexmk_use_lualatex" ]]; then
      latexdiff_compiler_arg="--lualatex"
  fi
  info "latex diff"
  git-latexdiff --verbose --main "$root_file" $latexdiff_compiler_arg --no-view -o diff.pdf --cleanup all --ignore-makefile $(git rev-parse HEAD^) --
fi

if [[ -n "$with_stats" ]]; then
  info "creating statistics"
  latexpand "$root_file" | texcount - > stats.txt
fi

if [[ -n "$post_compile" ]]; then
  info "Run post compile commands"
  eval "$post_compile"
fi
