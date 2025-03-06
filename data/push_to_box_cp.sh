#!/usr/bin/env bash
#
# push final scripts and linux-terminator files to box
#
TARGET="Virus Knowledgebase/taxonomy/ICTV_update/2025_updates/20250301_msl40v1/"

#
# convert line terminators
#
source ./convert_terminators_msdos2osx.sh

#
# Box drive approach
#
mkdir -p "/Users/curtish/box/$TARGET"
cp -a \
   *.utf8.osx.txt \
   export_current_msl_tables.bat \
   convert_terminators_msdos2osx.sh \
   push_to_box_cp.sh \
   "/Users/curtish/box/$TARGET"

#
# move towards github, too
#
source ./push_to_git_repo.sh
