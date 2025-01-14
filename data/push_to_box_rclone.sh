#!/usr/bin/env bash
#
# push final scripts and linux-terminator files to box
#
TARGET="Virus Knowledgebase/taxonomy/ICTV_update/2025_updates/20250114_msl39v4_prod_export/"

#
# convert line terminators
#
source ./convert_terminators_msdos2osx.sh

#
# rclone approach
#
rclone copy \
       --progress \
       --include "*.utf8.osx.txt" \
       --include "export_current_msl_tables.bat" \
       --include "convert_terminators_msdos2osx.sh" \
       --include "push_to_box_rclone.sh" \
       . \
       "box:/$TARGET"

#
# copy to github, too
#
source ./push_to_github.sh
