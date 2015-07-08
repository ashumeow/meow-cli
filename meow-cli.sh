NAME=meow-cli
VERSION=1.0.0

function main {
  local help=\
"Usage: $NAME [options] <command> [<arguments>...]

Options:
  -v, --version   print version
"
}

function error {
  printf "Error: %s\n" "$*" >&2
}
