#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

for tool in xelatex biber; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Missing dependency: $tool. Install TeX Live or MacTeX." >&2
    exit 1
  fi
done

mkdir -p build output/pdf
entry='\input{main.tex}'
if LC_ALL=C grep -Eq '^[[:space:]]*@[[:alpha:]]+[[:space:]]*[{(]' references.bib; then
  entry='\def\TemplateHasReferences{1}\input{main.tex}'
fi

xelatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=build -jobname=main "$entry"
if [[ "$entry" == *TemplateHasReferences* ]]; then
  biber --input-directory=build --output-directory=build main
fi
xelatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=build -jobname=main "$entry"
xelatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=build -jobname=main "$entry"
cp build/main.pdf output/pdf/docs-cs-project-template.pdf
echo 'Built output/pdf/docs-cs-project-template.pdf'
