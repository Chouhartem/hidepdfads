#!/bin/env sh
LATEXCC=${LATEXCC:=pdflatex}

print_help() {
  >&2 echo "Usage: $0 <command> [<args>]"
  >&2 echo -e "\nThis tool uses latex to cover a specific region of a PDF file on every page.\n"
  >&2 echo "<command> can be:"
  >&2 echo -e "\thelp:\tdisplay this help message"
  >&2 echo -e "\tlist:\tlist the different presets"
  >&2 echo -e "\tpreset:\tuse an existing preset\n\t\targuments: <preset> <infile> <outfile>"
  >&2 echo -e "\tmanual:\tset coordinates and dimension of the rectangle\n\t\targuments: <infile> <outfile> X Y L H [color=white] [unit=cm] [format=a4]"
}

gen_pdf() { # arguments: infile outfile X Y L H color unit format
  if [ $# -ne 9 ]
  then
    >&2 echo -e "Function gen_pdf: wrong number of arguments\n"
    exit 1
  fi
  infile="$1"
  outfile="$2"
  X="$3"
  Y="$4"
  L="$5"
  H="$6"
  color="$7"
  unit="$8"
  format="$9"
  tmp_dir=`mktemp -d`
  act_dir=$(pwd)

  cp "$infile" "$tmp_dir"
  cd "$tmp_dir"
  echo "\\documentclass[$format""paper]{article}" > main.tex
  cat <<EOB >>main.tex
\usepackage{tikz}
\usetikzlibrary{calc}
\usepackage{pdfpages}
\pagestyle{empty}
\begin{document}
\includepdf[pages={-},% include all pages
  pagecommand={% is called at the beginning of each inclusion
      \begin{tikzpicture}[remember picture,overlay]
EOB
  echo "\\draw[color=$color,fill=$color] (\$(current page.north west) + ($X$unit, -$Y$unit)\$) rectangle ++ ($L$unit, -$H$unit);\\end{tikzpicture}}]{$infile}\\end{document}" >>main.tex
  $LATEXCC -interaction=nonstopmode main.tex || { >&2 echo -e "\n\n\nLaTeX error during compilation"; rm -r "$tmp_dir"; exit 1; }
  $LATEXCC -interaction=nonstopmode main.tex
  cp -i main.pdf "$act_dir/$outfile"
  rm -r "$tmp_dir"
}

case "$1" in
  "list")
    echo -n "Available presets: "
    preset_list=$(sed '0,/^__DATA__$/d' "$0" | cut -d' ' -f1)
    echo $preset_list
    ;;
  "help")
    print_help
    ;;
  "")
    print_help
    ;;
  "preset")
    if [ $# -ne 4 ]
    then
      >&2 echo -e "preset: wrong number of arguments\n"
      print_help
    else
      read_presets="$(sed '0,/^__DATA__$/d' "$0")"
      i=0
      while read -r line
      do
        presets[$i]="$line"
        i=`echo $i + 1 | bc`
      done <<< "$read_presets"
      for elts in "${presets[@]}"
      do
        x=($elts)
        [[ "$2" == ${x[0]} ]] && gen_pdf "$3" "$4" "${x[1]}" "${x[2]}" "${x[3]}" "${x[4]}" "${x[5]}" "${x[6]}" "${x[7]}" && exit 0
      done
      >&2 echo -e "preset: preset \"$2\" not found\n"
      print_help
    fi
    ;;
  "manual")
    if [ $# -lt 7 ]
    then
      >&2 echo -e "manual: wrong number of arguments\n"
      print_help
    else
      color=${8:-white}
      unit=${9:-cm}
      format=${10:-a4}
      gen_pdf "$2" "$3" "$4" "$5" "$6" "$7" "$color" "$unit" "$format" && exit 0
    fi
esac

exit

# data format: X Y L H color unit format
__DATA__
