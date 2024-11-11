#!/bin/sh

# ---------------------------------------------------------------------------
# Program: converting text files encodings (character sets)
# Author:  Eugene P. Morgunov
# Date:    11.02.2014
# Version: 0.2
# ---------------------------------------------------------------------------

# This program converts character sets for ALL text files in the current
# directory.

# check if we have "iconv" program installed in our system
iconv -l > /dev/null 2>&1

if [ $? != 0 ]; then
  echo "Can't find \"iconv\" program -- so can't work"
  return
fi

# take the name of the script
SCRIPT=`basename $0`

# check positional parameters supplied to the script

# if the number of parameters is not two
if [ $# != 2 ]; then
  echo "Wrong number of parameters. You must supply two parameters:"
  echo "source file character set and target file character set."
  echo "Example: ${SCRIPT} CP1251 UTF-8"
  echo ""
  echo "You can get all possible character sets using command"
  echo "iconv -l"
  return
else
  FROM=$1
  TO=$2
fi


# process all the files in a directory but the script itself
for f in `ls -1`
do
  # the script itself shouldn't be converted
  if [ $f = ${SCRIPT} ]; then
    continue
  fi

  # converting
  iconv -f ${FROM} -t ${TO} $f > ${f}.conv

  # check the result of this operation (we use shell variable $? for this)
  if [ $? != 0 ]; then
    echo "Error while converting file $f"
    rm ${f}.conv
    read -p "Hit enter" r
    continue
  fi

  # remove or add CR (carriage return) symbols if needed
  
  # if source file comes from Windows world...
  if [ $FROM = "CP866" ] || [ $FROM = "CP1251" ]; then
    # ...and goes to Unix world
    if [ $TO != "CP866" ] && [ $TO != "CP1251" ]; then
      # RS (input records separator) -- CR and LF (ASCII 13 and 10)
      # ORS (output records separator) -- LF only (ASCII 10)
      # NOTE. Suffixes are: conv -- converted, fin -- final.
      awk 'BEGIN { RS = "\r\n"; ORS = "\n" } { print; }' ${f}.conv > ${f}.fin
    fi
  # if source file comes from Unix world...
  else  # $FROM -- not CP1251 and not CP866
    # ...and goes to Windows world
    if [ $TO = "CP866" ] || [ $TO = "CP1251" ]; then
      awk 'BEGIN { RS = "\n"; ORS = "\r\n" } { print; }' ${f}.conv > ${f}.fin
    fi
  fi

  # remove unconverted file
  rm $f

  if [ -f ${f}.fin ]; then
    # rename a final converted file to its original name
    mv ${f}.fin $f

    # remove a half-processed file
    rm ${f}.conv
  # when converting from Windows to Windows there won't be .fin file
  else
    # rename a converted file to its original name
    mv ${f}.conv $f
  fi
  
  # print a file name for a user to be informed about progress in our work
  echo $f
done
