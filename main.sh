#!/usr/bin/env bash


set -euo pipefail;

function GET_PERCENTAGE {
    local START_TIMESTAMP;
    local END_TIMESTAMP;
    local CURRENT_TIMESTAMP;
    START_TIMESTAMP=$(date -d "$START_DATE" +%s);
    END_TIMESTAMP=$(date -d "$END_DATE" +%s);
    CURRENT_TIMESTAMP=$(date +%s);
    local TOTAL_DAYS=$(( (END_TIMESTAMP - START_TIMESTAMP) / (60*60*24) ));
    local CURRENT_DAY=$(( (CURRENT_TIMESTAMP - START_TIMESTAMP) / (60*60*24) ));
    echo $(( (CURRENT_DAY * 100) / TOTAL_DAYS ));
}

function DISPLAY {
    local PERCENTAGE;
    PERCENTAGE=$(GET_PERCENTAGE);
    local FILLED=$(( LENGTH * PERCENTAGE / 100 ));
    local BLANK=$(( LENGTH - FILLED ));
    local BAR="";
    for ((i=0;i<FILLED;i++)) {
        BAR="${BAR}▓";
    }
    for ((i=0;i<BLANK;i++)) {
        BAR="${BAR}░";
    }
    echo "${BAR} ${PERCENTAGE}%";
}

function MAIN {
    local BAR_NOW;
    local BAR="";
    BAR_NOW=$(DISPLAY);
    if [ -f "$WORKDIR"/bar ]; then
        BAR=$(cat "$WORKDIR"/bar);
    fi
    echo ">>> Bot started.";
    while true; do
        BAR_NOW=$(DISPLAY);
        if [ "$BAR" == "$BAR_NOW" ]; then
            sleep 100;
            continue;
        fi
        curl -X POST \
            "https://api.telegram.org/bot${API_TOKEN}/sendMessage" \
            -d "chat_id=${CHAT_ID}&text=${BAR_NOW}";
        echo "$BAR_NOW" > "$WORKDIR"/bar;
        BAR="$BAR_NOW";
    done
}

MAIN;
