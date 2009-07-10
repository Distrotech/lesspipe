#!/bin/bash
# lesspipe.sh, a preprocessor for less (version 1.60)
#===============================================================================
### THIS FILE IS GENERATED FROM lesspipe.sh.in, PLEASE GET THE TAR FILE
### ftp://ftp.ifh.de/pub/unix/utility/lesspipe.tar.gz
### AND RUN configure TO GENERATE A lesspipe.sh THAT WORKS IN YOUR ENVIRONMENT
#===============================================================================
#
# Usage:   lesspipe.sh is called when the environment variable LESSOPEN is set:
#	   LESSOPEN="|lesspipe.sh %s"; export LESSOPEN	(sh like shells)
#	   setenv LESSOPEN "|lesspipe.sh %s"		(csh, tcsh)
#	   Use the fully qualified path if lesspipe.sh is not in the search path
#	   View files in multifile archives:
#			less archive_file:contained_file
#	   This can be used to extract ASCII files from a multifile archive:
#			less archive_file:contained_file>extracted_file
#	   As less is not good for extracting binary data use instead:
#			lesspipe.sh archive_file:contained_file>extracted_file
#          Even a file in a multifile archive that itself is contained in yet
#          another archive can be viewed this way:
#			less super_archive:archive_file:contained_file
#	   Display the last file in the file1:..:fileN chain in raw format:
#	   Suppress input filtering:	less file1:..:fileN:   (append a colon)
#	   Suppress decompression:	less file1:..:fileN::  (append 2 colons)
#
# Required programs and supported formats: see the separate file README
# License: GPL (see file LICENSE)
# History: see the separate file ChangeLog
# Author:  Wolfgang Friebel, DESY (Wolfgang.Friebel AT desy.de)
#
#===============================================================================
#setopt KSH_ARRAYS SH_WORD_SPLIT
set +o noclobber
tarcmd=gtar
if [[ `tar --version 2>&1` = *GNU* ]]; then
  tarcmd=tar
fi
filecmd='file -L -s';
sep=:						# file name separator
altsep==					# alternate separator character
if [[ -f "$1" && "$1" = *$sep* || "$1" = *$altsep ]]; then
  sep=$altsep
  xxx="${1%=}"
  set "$xxx"
fi
tmpdir=$(mktemp -d -p "${TMPDIR:-/tmp}" lesspipe.XXXXXXXXXX)

nexttmp () {
  # nexttmp -d returns a directory
  mktemp -p "$tmpdir" $1
}
[[ -d "$tmpdir" ]] || exit 1
trap "rm -rf '$tmpdir'" 0
trap - PIPE

filetype () {
  # wrapper for 'file' command
  typeset name
  name="$1"
  if [[ "$1" = - ]]; then
    dd bs=40000 count=1 > "$tmpdir/file" 2>/dev/null
    set "$tmpdir/file" "$2"
    name="$filen"
  fi
  typeset type
  # type=" $($filecmd -b "$1")" # not supported by all versions of 'file'
  type=$($filecmd "$1" | cut -d : -f 2-)
  if [[ "$type" = " empty" ]]; then
    # exit if file returns "empty" (e.g., with "less archive:nonexisting_file")
    exit 1
  elif [[ "$type" = *XML* && "$name" = *html ]]; then
    type=" HTML document text"
  elif [[ "$type" != *lzip*compress* && ("$name" = *.lzma || "$name" = *.tlz) ]]; then
    type=" LZMA compressed data"
  elif [[ ("$type" = *Zip* || "$type" = *ZIP*) && ("$name" = *.jar || "$name" = *.xpi) ]]; then
    type=" Jar archive"
  elif [[ "$type" = *Microsoft\ Office\ Document* && ("$name" = *.ppt) ]]; then
       type=" PowerPoint document"
  elif [[ "$type" = *Microsoft\ Office\ Document* && ("$name" = *.xls) ]]; then
       type=" Excel document"
  fi
  echo "$type"
}

show () {
  file1="${1%%$sep*}"
  rest1="${1#$file1}"
  while [[ "$rest1" = ::* ]]; do
    if [[ "$rest1" = "::" ]]; then
      break
    else
      rest1="${rest1#$sep$sep}"
      file1="${rest1%%$sep*}"
      rest1="${rest1#$file1}"
      file1="${1%$rest1}"
    fi
  done
  rest11="${rest1#$sep}"
  file2="${rest11%%$sep*}"
  rest2="${rest11#$file2}"
  while [[ "$rest2" = ::* ]]; do
    if [[ "$rest2" = "::" ]]; then
      break
    else
      rest2="${rest2#$sep$sep}"
      file2="${rest2%%$sep*}"
      rest2="${rest2#$file2}"
      file2="${rest11%$rest2}"
    fi
  done
  if [[ "$file2" != "" ]]; then
    in_file="-i$file2"
  fi
  rest2="${rest11#$file2}"
  rest11="$rest1"
  if [[ "$cmd" = "" ]]; then
    type=$(filetype "$file1") || exit 1
    get_cmd "$type" "$file1" "$rest1"
    if [[ "$cmd" != "" ]]; then
      show "-$rest1"
    else
      isfinal "$type" "$file1" "$rest11"
    fi
  elif [[ "$c1" = "" ]]; then
    c1=("${cmd[@]}")
    type=$("${c1[@]}" | filetype -) || exit 1
    get_cmd "$type" "$file1" "$rest1"
    if [[ "$cmd" != "" ]]; then
      show "-$rest1"
    else
      "${c1[@]}" | isfinal "$type" - "$rest11"
    fi
  elif [[ "$c2" = "" ]]; then
    c2=("${cmd[@]}")
    type=$("${c1[@]}" | "${c2[@]}" | filetype -) || exit 1
    get_cmd "$type" "$file1" "$rest1"
    if [[ "$cmd" != "" ]]; then
      show "-$rest1"
    else
      "${c1[@]}" | "${c2[@]}" | isfinal "$type" - "$rest11"
    fi
  elif [[ "$c3" = "" ]]; then
    c3=("${cmd[@]}")
    type=$("${c1[@]}" | "${c2[@]}" | "${c3[@]}" | filetype -) || exit 1
    get_cmd "$type" "$file1" "$rest1"
    if [[ "$cmd" != "" ]]; then
      show "-$rest1"
    else
      "${c1[@]}" | "${c2[@]}" | "${c3[@]}" | isfinal "$type" - "$rest11"
    fi
  elif [[ "$c4" = "" ]]; then
    c4=("${cmd[@]}")
    type=$("${c1[@]}" | "${c2[@]}" | "${c3[@]}" | "${c4[@]}" | filetype -) || exit 1
    get_cmd "$type" "$file1" "$rest1"
    if [[ "$cmd" != "" ]]; then
      show "-$rest1"
    else
      "${c1[@]}" | "${c2[@]}" | "${c3[@]}" | "${c4[@]}" | isfinal "$type" - "$rest11"
    fi
  elif [[ "$c5" = "" ]]; then
    c5=("${cmd[@]}")
    type=$("${c1[@]}" | "${c2[@]}" | "${c3[@]}" | "${c4[@]}" | "${c5[@]}" | filetype -) || exit 1
    get_cmd "$type" "$file1" "$rest1"
    if [[ "$cmd" != "" ]]; then
      echo "$0: Too many levels of encapsulation"
    else
      "${c1[@]}" | "${c2[@]}" | "${c3[@]}" | "${c4[@]}" | "${c5[@]}" | isfinal "$type" - "$rest11"
    fi
  fi
}

get_cmd () {
  cmd=
  typeset t
  if [[ "$1" = *[blg]zip*compress* || "$1" = *compress\'d\ * || "$1" = *packed\ data* || "$1" = *LZMA*compress* ]]; then ## added '#..then' to fix vim's syntax parsing
    if [[ "$3" = $sep$sep ]]; then
      return
    elif [[ "$1" = *bzip*compress* ]]; then
      cmd=(bzip2 -cd "$2")
      if [[ "$2" != - ]]; then filen="$2"; fi
      case "$filen" in
        *.bz2) filen="${filen%.bz2}";;
        *.tbz) filen="${filen%.tbz}.tar";;
      esac
      return
    elif [[ "$1" = *lzip*compress* ]]; then
      cmd=(lzip -cd "$2")
      if [[ "$2" != - ]]; then filen="$2"; fi
      case "$filen" in
        *.lz) filen="${filen%.lz}";;
        *.tlz) filen="${filen%.tlz}.tar";;
      esac
    elif [[ "$1" = *LZMA*compress* ]]; then
      cmd=(lzma -cd "$2")
      if [[ "$2" != - ]]; then filen="$2"; fi
      case "$filen" in
        *.lzma) filen="${filen%.lzma}";;
        *.tlz) filen="${filen%.tlz}.tar";;
      esac
    elif [[ "$1" = *gzip\ compress* || "$1" =  *compress\'d\ * || "$1" = *packed\ data* ]]; then ## added '#..then' to fix vim's syntax parsing
      cmd=(gzip -cd "$2")
      if [[ "$2" != - ]]; then filen="$2"; fi
      case "$filen" in
        *.gz) filen="${filen%.gz}";;
        *.tgz) filen="${filen%.tgz}.tar";;
      esac
    fi
    return
  fi

  rsave="$rest1"
  rest1="$rest2"
  if [[ "$file2" != "" ]]; then
    if [[ "$1" = *\ tar* || "$1" = *\	tar* ]]; then
      cmd=(istar "$2" "$file2")
    elif [[ "$1" = *Debian* ]]; then
      t=$(nexttmp)
      if [[ "$file2" = control/* ]]; then
        istemp "ar p" "$2" control.tar.gz | gzip -dc - > "$t"
        file2=".${file2:7}"
      else
        istemp "ar p" "$2" data.tar.gz | gzip -dc - > "$t"
      fi
      cmd=(istar "$t" "$file2")
    elif [[ "$1" = *RPM* ]]; then
      cmd=(isrpm "$2" "$file2")
    elif [[ "$1" = *Jar\ archive* ]]; then
      cmd=(isjar "$2" "$file2")
    elif [[ "$1" = *Zip* || "$1" = *ZIP* ]]; then
      cmd=(istemp "unzip -avp" "$2" "$file2")
    elif [[ "$1" = *RAR\ archive* ]]; then
      cmd=(istemp "unrar p -inul" "$2" "$file2")
    elif [[ "$1" = *7-zip\ archive* ]]; then
      cmd=(istemp "7za e -so" "$2" "$file2")
    elif [[ "$1" = *[Cc]abinet* ]]; then
      cmd=(iscab "$2" "$file2")
    elif [[ "$1" = *\ ar\ archive* ]]; then
      cmd=(istemp "ar p" "$2" "$file2")
    elif [[ "$1" = *ISO\ 9660* ]]; then
      cmd=(isoinfo "-i$2" "-x$file2")
    fi
    if [[ "$cmd" != "" ]]; then
      filen="$file2"
    fi
  fi
}

iscab () {
  typeset t
  if [[ "$1" = - ]]; then
    t=$(nexttmp)
    cat > "$t"
    set "$t" "$2"
  fi
  cabextract -pF "$2" "$1"
}

istar () {
  $tarcmd Oxf "$1" "$2" 2>/dev/null
}

isdvi () {
  typeset t
  if [[ "$1" != *.dvi ]]; then
    t="$tmpdir/tmp.dvi"
    cat "$1" > "$t"
    set "$t"
  fi
  dvi2tty -q "$1"
}

istemp () {
  typeset prog
  typeset t
  prog="$1"
  t="$2"
  shift
  shift
  if [[ "$t" = - ]]; then
    t=$(nexttmp)
    cat > "$t"
  fi
  if [[ $# -gt 0 ]]; then
    $prog "$t" "$@" 2>/dev/null
  else
    $prog "$t" 2>/dev/null
  fi
}

nodash () {
  typeset prog
  prog="$1"
  shift
  if [[ "$1" = - ]]; then
    shift
    if [[ $# -gt 0 ]]; then
      $prog "$@" 2>/dev/null
    else
      $prog 2>/dev/null
    fi
  else
    $prog "$@" 2>/dev/null
  fi
}

isrpm () {
  typeset t
  if [[ "$1" = - ]]; then
    t=$(nexttmp)
    cat > "$t"
    set "$t" "$2"
  fi
  # setup $b as a batch file containing "$b.out"
  typeset b
  b=$(nexttmp)
  echo "$b.out" > "$b"
  rpm2cpio "$1"|cpio -i --quiet --rename-batch-file "$b" "$2"
  cat "$b.out"
}

isjar () {
  case "$2" in
    /*) echo "lesspipe can't unjar files with absolute paths" >&2
      exit 1
      ;;
    ../*) echo "lesspipe can't unjar files with ../ paths" >&2
      exit 1
      ;;
  esac
  typeset d
  d=$(nexttmp -d)
  [[ -d "$d" ]] || exit 1
  cat "$1" | (
    cd "$d"
    fastjar -x "$2"
    if [[ -f "$2" ]]; then
      cat "$2"
    fi
  )
}

PARSEHTML=yes
parsehtml () { nodash "elinks -dump -force-html" "$1"; }
#parsexml () { nodash "elinks -dump -default-mime-type text/xml" "$1"; }

isfinal() {
  typeset t
  if [[ "$3" = $sep$sep ]]; then
    cat "$2"
    return
  elif [[ "$3" = $sep* ]]; then
    cat "$2"
    return
  fi
  if [[ "$1" = *No\ such* ]]; then
    exit 1
  elif [[ "$1" = *directory* ]]; then
    echo "==> This is a directory, showing the output of"
    echo "ls -lA $2"
    # color requires -r or -R when calling less, not recommended
    typeset COLOR
    if [[ $(tput colors) -ge 8 && ("$LESS" = *-*r* || "$LESS" = *-*R*) ]]; then
      COLOR="--color=always"
    fi
    ls -lA $COLOR "$2"
  elif [[ "$1" = *\ tar* || "$1" = *\	tar* ]]; then
    echo "==> use tar_file${sep}contained_file to view a file in the archive"
    $tarcmd tvf "$2"
  elif [[ "$1" = *RPM* ]]; then
    echo "==> use RPM_file${sep}contained_file to view a file in the RPM"
    istemp "rpm -qivp" "$2"
    echo "================================= Content ======================================"
    istemp rpm2cpio "$2"|cpio -i -tv --quiet
  elif [[ "$1" = *roff* ]]; then
    DEV=utf8
    if [[ $LANG != *UTF*8* && $LANG != *utf*8* ]]; then
      if [[ "$LANG" = ja* ]]; then
        DEV=nippon
      else
        DEV=latin1
      fi
    fi
    MACRO=andoc
    if [[ "$2" = *.me ]]; then
      MACRO=e
    elif [[ "$2" = *.ms ]]; then
      MACRO=s
    fi
    echo "==> append $sep to filename to view the nroff source"
    groff -s -p -t -e -T$DEV -m$MACRO "$2"
  elif [[ "$1" = *Debian* ]]; then
    echo "==> use Deb_file${sep}contained_file to view a file in the Deb"
    echo
    istemp "ar p" "$2" control.tar.gz | gzip -dc - | $tarcmd tvf - | sed -r 's/(.{48})\./\1control/'
    echo
    istemp "ar p" "$2" data.tar.gz | gzip -dc - | $tarcmd tvf -
  # do not display all perl text containing pod using perldoc
  #elif [[ "$1" = *Perl\ POD\ document\ text* || "$1" = *Perl5\ module\ source\ text* ]]; then
  elif [[ "$1" = *Perl\ POD\ document\ text* ]]; then
    echo "==> append $sep to filename to view the perl source"
    istemp perldoc "$2"
  elif [[ "$1" = *\ script* ]]; then
    set "plain text" "$2"
  elif [[ "$1" = *text\ executable* ]]; then
    set "plain text" "$2"
  elif [[ "$1" = *PostScript* ]]; then
    echo "==> append $sep to filename to view the postscript file"
    istemp ps2ascii "$2"
  elif [[ "$1" = *executable* ]]; then
    echo "==> append $sep to filename to view the binary file"
    nodash strings "$2"
  elif [[ "$1" = *\ ar\ archive* ]]; then
    echo "==> use library${sep}contained_file to view a file in the archive"
    istemp "ar vt" "$2"
  elif [[ "$1" = *shared* ]]; then
    echo "==> This is a dynamic library, showing the output of nm"
    istemp nm "$2"
  elif [[ "$1" = *Jar\ archive* ]]; then
    echo "==> use jar_file${sep}contained_file to view a file in the archive"
    nodash "fastjar -tf" "$2"
  elif [[ "$1" = *Zip* || "$1" = *ZIP* ]]; then
    echo "==> use zip_file${sep}contained_file to view a file in the archive"
    istemp "unzip -lv" "$2"
  elif [[ "$1" = *RAR\ archive* ]]; then
    echo "==> use rar_file${sep}contained_file to view a file in the archive"
    istemp "unrar v" "$2"
  elif [[ "$1" = *7-zip\ archive* ]]; then
    typeset res
    res=$(istemp "7za l" "$2")
    if [[ "$res" = *\ 1\ file* ]]; then
      echo "==> a 7za archive containing one file was silently unpacked"
      if [[ "$2" != - ]]; then
        7za e -so "$2" 2>/dev/null
      else
        # extract name of temporary file containing the 7za archive
        t=${res#*Listing\ archive:\ }
        t2="
"
        t=${t%%$t2*}
        7za e -so $t 2>/dev/null
      fi
    else
      echo "==> use 7za_file${sep}contained_file to view a file in the archive"
      echo "$res"
    fi
  elif [[ "$1" = *[Cc]abinet* ]]; then
    echo "==> use cab_file${sep}contained_file to view a file in the cabinet"
    istemp "cabextract -l" "$2"
  elif [[ "$1" = *\ DVI* ]]; then
    echo "==> append $sep to filename to view the binary DVI file"
    isdvi "$2"
  elif [[ "$PARSEHTML" = yes && "$1" = *HTML* ]]; then
    echo "==> append $sep to filename to view the HTML source"
    parsehtml "$2"
  elif [[ "$PARSEHTML" = yes && "$1" = *PDF* ]]; then
    echo "==> append $sep to filename to view the PDF source"
    t=$(nexttmp)
    cat "$2" > "$t"; pdftohtml -stdout "$t" | parsehtml -
  elif [[ "$1" = *PDF* ]]; then
    echo "==> append $sep to filename to view the PDF source"
    istemp pdftotext "$2" -
  elif [[ "$1" = *Microsoft\ Word* || "$1" = *Microsoft\ Office* ]]; then
    echo "==> append $sep to filename to view the raw word document"
    antiword "$2"
  elif [[ "$1" = *Rich\ Text\ Format* ]]; then
    if [[ "$PARSEHTML" = yes ]]; then
      echo "==> append $sep to filename to view the RTF source"
      istemp "unrtf --html" "$2" | parsehtml -
    else
      echo "==> append $sep to filename to view the RTF source"
      istemp "unrtf --text" "$2" | sed -e "s/^### .*//" | fmt -s
    fi
  elif [[ "$1" = *OpenDocument\ [CHMPST]* || "$1" = *OpenOffice\.org\ 1\.x\ [CIWdgpst]* ]]; then
    echo "==> append $sep to filename to view the OpenOffice or OpenDocument source"
    istemp sxw2txt "$2"
  elif [[ "$1" = *ISO\ 9660* ]]; then
    if [[ "$2" != - ]]; then
      echo "==> append $sep to filename to view the binary data"
      isoinfo -d -i "$2"
      joliet=`isoinfo -d -i "$2" | egrep '^Joliet'|cut -c1`
      echo "================================= Content ======================================"
      isoinfo -lR$joliet -i "$2"
    fi
  elif [[ "$1" = *image\ data*  || "$1" = *image\ text* || "$1" = *JPEG\ file* || "$1" = *JPG\ file* ]]; then
    echo "==> append $sep to filename to view the binary data"
    identify -verbose "$2"
  elif [[ "$1" = *MPEG\ *layer\ 3\ audio* || "$1" = *MPEG\ *layer\ III* || "$1" = *mp3\ file* || "$1" = *MP3* ]]; then
    echo "==> append $sep to filename to view the binary data"
    istemp "id3v2 -l" "$2"
  elif [[ "$1" = *perl\ Storable* ]]; then
    echo "==> append $sep to filename to view the binary data"
    perl -MStorable=retrieve -MData::Dumper -e '$Data::Dumper::Indent=1;print Dumper retrieve shift' "$2"
  elif [[ "$1" = *UTF-8* && $LANG != *UTF*8* && $LANG != *utf*8* ]]; then
    echo "==> append $sep to filename to view the UTF-8 encoded data"
    iconv -c -f UTF-8 -t ISO-8859-1 "$2"
  elif [[ "$1" = *ISO-8859* && ($LANG = *UTF*8* || $LANG = *utf*8*) ]]; then
    echo "==> append $sep to filename to view the ISO-8859 encoded data"
    iconv -c -f ISO-8859-1 -t UTF-8 "$2"
  elif [[ "$1" = *UTF-16* && $LANG != *UTF*8* && $LANG != *utf*8* ]]; then
    echo "==> append $sep to filename to view the UTF-16 encoded data"
    iconv -c -f UTF-16 -t ISO-8859-1 "$2"
  elif [[ "$1" = *UTF-16* && ($LANG = *UTF*8* || $LANG = *utf*8*) ]]; then
    echo "==> append $sep to filename to view the UTF-16 encoded data"
    iconv -c -f UTF-16 -t UTF-8 "$2"
  elif [[ "$1" = *GPG\ encrypted\ data* ]]; then
    echo "==> append $sep to filename to view the encrypted file"
    gpg -d "$2"
  elif [[ "$1" = *data* ]]; then
    echo "==> append $sep to filename to view the $1 source"
    nodash strings "$2"
  else
    set "plain text" "$2"
  fi
  if [[ "$2" = - ]]; then
    cat
  fi  
}

IFS=$sep a="$@"
IFS=' '
if [[ "$a" = "" ]]; then
  if [[ "$SHELL" = *csh ]]; then
    echo "setenv LESSOPEN \"|$0 %s\""
  else
    echo "LESSOPEN=\"|$0 %s\""
    echo "export LESSOPEN"
  fi
else
  # check for pipes so that "less -f ... <(cmd) ..." works properly
  [[ -p "$1" ]] && exit 1
  show "$a"
fi