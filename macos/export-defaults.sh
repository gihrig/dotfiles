#!/usr/bin/env bash

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
echo "Quitting System Preferences..."
osascript -e 'tell application "System Preferences" to quit'

###############################################################################
echo "Exporting settings to defaults.zip"
###############################################################################

function exportDefaults {
    local outdir="$HOME/dotfiles-defaults"
    local outdirApple="$outdir/apple"
    local outdirUser="$outdir/user"
    local outdirGlobal="$outdir/global"
    local filesdone=0
    local filecount=0
    local filestotal=0
    local globals=0


    function cleanOutdirs {
        [[ ! -d $outdir ]] && mkdir "$outdir"
        if [[ -d $outdirApple ]]; then
            echo "removing all files in $outdirApple"
            rm -rf "${outdirApple/*}"
        else
            mkdir "$outdirApple"
        fi

        if [[ -d $outdirUser ]]; then
            echo "removing all files in $outdirUser"
            rm -rf "${outdirUser/*}"
        else
            mkdir "$outdirUser"
        fi

        if [[ -d $outdirGlobal ]]; then
            echo "removing all files in $outdirGlobal"
            rm -rf "${outdirGlobal/*}"
        else
            mkdir "$outdirGlobal"
        fi
    }

    function exportDomains {
        filesdone=0
        filecount=0
        for domain in "${domains[@]}"; do
            plist="${domain}.plist"
            if [[ $globals == 0 ]]; then
                if [[ $domain =~ com.apple ]]; then
                    defaults export "$domain" "$outdirApple/$plist"
                    #echo "writing $plist to $outdirApple"
                    filecount=$((filecount+1))
                else
                    defaults export "$domain" "$outdirUser/$plist"
                    #echo "writing $plist to $outdirUser"
                    filecount=$((filecount+1))
                fi
            else
                sudo defaults export "$domain" "$outdirGlobal/$plist"
                #echo "writing $plist to $outdirGlobal"
                filecount=$((filecount+1))
            fi
            filesleft=$((filesleft-1))
            filesdone=$((filesdone+1))
            echo -ne "[ $filesdone/$filesleft ] \r"
        done
    }

    cleanOutdirs

    # -------------------------------------------------
    local domainsWithSeparator="$(defaults domains)"
    local domains=(${domainsWithSeparator//,/})
    local filesleft=${#domains[@]}
    echo "USER namespace has ${#domains[@]} domains, exportig..."
    exportDomains
    echo "written $filecount files in $outdir"
    local filestotal=$((filestotal+filecount))
    # -------------------------------------------------
    globals=1
    # -------------------------------------------------
    local domainsWithSeparator="$(sudo defaults domains)"
    local domains=(${domainsWithSeparator//,/})
    local filesleft=${#domains[@]}
    echo "GLOBAL namespace has ${#domains[@]} domains, exportig..."
    exportDomains
    echo "written $filecount files in $outdir"
    local filestotal=$((filestotal+filecount))
    echo ""
    # -------------------------------------------------

    sudo chown -R "$(whoami)":staff "$outdir"
    cd "$outdir"
    zip -q -r defaults.zip .

    local timed="$((SECONDS / 3600))hrs $(((SECONDS / 60) % 60))min $((SECONDS % 60))sec"

    echo "Exported $filestotal files in $timed to $outdir"
    echo ""
    echo "Copy ~/dotfiles-defaults/defaults.zip to ~/.config/dotfiles/macos for future import"
    echo ""
}

exportDefaults
