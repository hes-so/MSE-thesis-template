##################################################
# Variables
#
open := if os() == "linux" {
  "xdg-open"
} else if os() == "macos" {
  "open"
} else {
  "start \"\" /max"
}

project_dir   := justfile_directory()
project_name  := file_stem(justfile_directory())
project_tag   := "0.0.2"

typst_version := "typst -V"
typst_github  := "https://github.com/typst/typst --tag v0.14.2"

template_dir  := join(justfile_directory(), "template")
doc_name      := "thesis"
type          := "draft"
lang          := "en"

local_dir := if os() == "macos" {
  "~/Library/Application\\ Support/typst/packages/local"
} else {
  "~/.local/share/typst/packages/local"
}

preview_dir := if os() == "macos" {
  "~/Library/Caches/typst/packages/preview"
} else {
  "~/.cache/typst/packages/preview"
}

release_dir := if os() == "macos" {
"~/Library/Application\\ Support/typst/packages/preview"
} else {
"~/.local/share/typst/packages/preview"
}

##################################################
# COMMANDS
#
# List all commands
@default:
  just --list

# Information about the environment
@info:
  echo "Environment Informations\n------------------------\n"
  echo "    OS          : {{os()}}({{arch()}})"
  echo "    Open        : {{open}}"
  echo "    Typst       : `{{typst_version}}`"
  echo "    Projectdir  : {{project_dir}}"
  echo "    Projectname : {{project_name}}"

# install required sw
[windows]
[linux]
@install:
  echo "Install typst"
  cargo install --git {{typst_github}}

# install required sw
[macos]
@install:
  echo "Install typst"
  brew install typst

# create or update a symlink to the current project root
[linux]
[macos]
@link path:
  echo "Link template in {{path}} to current project root"
  echo "  {{path}}/{{project_tag}} -> {{project_dir}}"
  mkdir -p {{preview_dir}}/{{project_name}}
  rm -rf {{path}}/{{project_tag}}
  ln -s {{project_dir}} {{path}}/{{project_tag}}

# remove symlink/folder for current project version
[linux]
[macos]
@unlink path:
  echo "Remove template link/folder from {{path}}"
  echo "  {{path}}/{{project_tag}}"
  rm -rf {{path}}/{{project_tag}}

# create or update a symlink in preview package path to the current project root
[linux]
[macos]
@link-preview: (link preview_dir / project_name)

# create or update a symlink in local package path to the current project root
[linux]
[macos]
@link-local: (link local_dir / project_name)

# create or update symlinks preview and local to the current project root
[linux]
[macos]
@link-all: link-preview link-local

# remove preview symlink/folder for current project version
[linux]
[macos]
@unlink-preview: (unlink preview_dir / project_name)

# remove local symlink/folder for current project version
[linux]
[macos]
@unlink-local: (unlink local_dir / project_name)

# remove all symlinks preview and local for current project version
[linux]
[macos]
@unlink-all: unlink-preview unlink-local

# check if a symlink exists at the given path and where it points
[linux]
[macos]
check-link path:
  #!/usr/bin/env sh
  echo "Check link for {{path}}"
  expanded_path=$(eval echo "{{path}}")
  if [ -L "$expanded_path" ]; then
    target=$(readlink "$expanded_path")
    echo "  linked -> $target"
  elif [ -d "$expanded_path" ]; then
    echo "  exists (directory, not a symlink)"
  else
    echo "  unlinked"
  fi

# check if both preview and local symlinks exist
[linux]
[macos]
@check-links:
  just check-link {{local_dir}}/{{project_name}}/{{project_tag}}
  just check-link {{preview_dir}}/{{project_name}}/{{project_tag}}

# install the template as release package
[linux]
[macos]
@copy-release:
  echo "Install template as release package"
  echo "  {{release_dir}}/{{project_name}}/{{project_tag}}"
  mkdir -p {{release_dir}}/{{project_name}}/{{project_tag}}
  cp -r ./* {{release_dir}}/{{project_name}}/{{project_tag}}
  rm -f {{release_dir}}/{{project_name}}/{{project_tag}}/guide-to-thesis.pdf
  rm -f {{release_dir}}/{{project_name}}/{{project_tag}}/guide-to-typst.pdf
  rm -f {{release_dir}}/{{project_name}}/{{project_tag}}/sample.png
  rm -f {{release_dir}}/{{project_name}}/{{project_tag}}/sample.svg
  rm -f {{release_dir}}/{{project_name}}/{{project_tag}}/justfile
  rm -f {{release_dir}}/{{project_name}}/{{project_tag}}/cliff.toml
  rm -f {{release_dir}}/{{project_name}}/{{project_tag}}/template/*.pdf
  sed -i '' '/!\[\](https:\/\/tianji\.zahno\.dev\/telemetry/d' {{release_dir}}/{{project_name}}/{{project_tag}}/README.md

# generate changelog and tag for the current release
@changelog-unreleased:
  git-cliff --unreleased --tag  {{project_tag}} -o CHANGELOG.md

# generate changelog for latest version bump only. Append to current file
@changelog-latest:
  git cliff --unreleased --tag {{project_tag}} --prepend CHANGELOG.md

# watch a typ file for continuous incremental build
watch file_name=doc_name type=type lang=lang:
  typst c {{template_dir}}/{{file_name}}.typ --input type={{type}} --input lang={{lang}}
  just open {{file_name}}
  typst w {{template_dir}}/{{file_name}}.typ --input type={{type}} --input lang={{lang}}

# open pdf
open file_name=doc_name:
  {{open}} {{template_dir}}/{{file_name}}.pdf

# build, rename and copy a typ file to a pdf
@pdf file_name=doc_name type=type lang=lang:
  echo "--------------------------------------------------"
  echo "-- Generate {{file_name}}.pdf of type {{type}} in language {{lang}}"
  echo "--"
  typst c {{template_dir}}/{{file_name}}.typ  --input type={{type}} --input lang={{lang}}
  mv {{template_dir}}/{{file_name}}.pdf {{template_dir}}/{{file_name}}-{{lang}}-{{type}}.pdf
  just clean

# build, rename and copy a typ file in all variants
@pdf-all file_name=doc_name:
  echo "--------------------------------------------------"
  echo "-- Generate all variants of {{file_name}}.pdf"
  echo "--"
  just pdf {{file_name}} draft en
  just pdf {{file_name}} final en
  just pdf {{file_name}} draft de
  just pdf {{file_name}} final de
  just pdf {{file_name}} draft fr
  just pdf {{file_name}} final fr

# generate thumbnail.png (first page of thesis.typ at 300 DPI)
# requires: typst, pdftoppm (poppler), magick (ImageMagick)
thumbnail file_name=doc_name lang=lang:
  #!/usr/bin/env sh
  echo "--------------------------------------------------"
  echo "-- Generate thumbnail.png from page 1 of {{file_name}}.pdf"
  echo "--"
  typst c {{template_dir}}/{{file_name}}.typ --input type=final --input lang={{lang}}
  tmp_dir=$(mktemp -d)
  pdftoppm -f 1 -l 1 -r 300 -png -singlefile {{template_dir}}/{{file_name}}.pdf "$tmp_dir/thumb"
  mv "$tmp_dir/thumb.png" {{project_dir}}/thumbnail.png
  rm -rf "$tmp_dir"
  just clean

# generate sample.png (3-column montage of selected pages of thesis.typ at 300 DPI)
# requires: typst, pdftoppm (poppler), magick (ImageMagick)
# pages: space-separated list of page numbers, e.g. "1 3 4 5 8 9 17"
sample file_name=doc_name pages="1 2 3 4 7 8 10 12 22" lang=lang:
  #!/usr/bin/env sh
  echo "--------------------------------------------------"
  echo "-- Generate sample.png from pages [{{pages}}] of {{file_name}}.pdf"
  echo "--"
  typst c {{template_dir}}/{{file_name}}.typ --input type=final --input lang={{lang}}
  tmp_dir=$(mktemp -d)
  for page in {{pages}}; do
    pdftoppm -f $page -l $page -r 300 -png -singlefile \
      {{template_dir}}/{{file_name}}.pdf "$tmp_dir/page-$(printf '%03d' $page)"
  done
  magick montage "$tmp_dir"/page-*.png -geometry +4+4 -tile 3x {{project_dir}}/sample.png
  rm -rf "$tmp_dir"
  just clean

# generate both thumbnail.png and sample.png
@screenshots:
  just thumbnail
  just sample

# cleanup intermediate files
[linux]
[macos]
@clean:
  echo "--------------------------------------------------"
  echo "-- Clean {{project_name}}"
  echo "--"
  rm lib/*.pdf || true
  rm template/metadata.pdf || true
  rm template/main/*.pdf || true
  rm template/tail/*.pdf || true

# cleanup intermediate files
[windows]
@clean:
  echo "--------------------------------------------------"
  echo "-- Clean {{project_name}}"
  echo "--"
  del /q /s lib\*.pdf 2>nul
  del /q /s template\metadata.pdf 2>nul
  del /q /s template\main\*.pdf 2>nul
  del /q /s template\tail\*.pdf 2>nul
