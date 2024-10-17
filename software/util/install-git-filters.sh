#!/usr/bin/env bash
git config --local filter.xml_last_change.clean "sed -E 's/last_change[=][\"][^\"]*[\"]/last_change=\"\"/'"
git config --local filter.xml_last_change.smudge cat
echo "Installed git filter to local/repo config: xml_last_change"
git config --local filter.debug_profile_uuid.clean "sed -E 's/[\"]uuid[\"]:[ ]*[\"][0-9a-zA-Z]{32}[\"]/\"uuid\": \"00000000000000000000000000000000\"/'"
git config --local filter.debug_profile_uuid.smudge cat
echo "Installed git filter to local/repo config: debug_profile_uuid"
