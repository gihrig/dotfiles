#!/bin/bash

# Remove and prevent creation Apple metadata on backup drives
# /usr/local/bin/clean_meta_priv.sh  (owned root:wheel, chmod 700)

vol_path="$1"
# Disable writing .DS_Store to external drives
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
rm -rfd "$vol_path"/{.DS_Store,.fseventsd,.Trashes,.TemporaryItems}
touch $vol_path/.metadata_never_index && chmod 444 $vol_path/.metadata_never_index
touch $vol_path/.Trashes && chmod 444 $vol_path/.Trashes
touch $vol_path/.TemporaryItems && chmod 444 $vol_path/.TemporaryItems
mkdir $vol_path/.fseventsd && touch $vol_path/.fseventsd/no_log && chmod 444 $vol_path/.fseventsd/no_log
find "$vol_path" -name ".DS_Store" -delete
mdutil -i off "$vol_path"
if [[ -d "$vol_path/.Spotlight-V100" ]]; then
    mdutil -X "$vol_path"
fi
