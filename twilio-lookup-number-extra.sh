#!/bin/bash
# Graham's basic script to research a phone number - typically used to determine whether it's associated with scams.
# Requires/assumes a Twilio.com account and relevant binaries on MacOS via HomeBrew.
# License: GPL 3.0

[[ -z "$TWILIO_ACCOUNT_SID" ]] && { echo "TWILIO_ACCOUNT_SID must be defined. Exiting." ; exit 1; }

[[ -z "$TWILIO_AUTH_TOKEN" ]] && { echo "TWILIO_AUTH_TOKEN must be defined. Exiting." ; exit 1; }

[[ -z "$1" ]] && { echo "Please specify the number to look up - e.g. 12223334444" ; exit 1; }

# I use shellcheck to help catch and troubleshoot mistakes in my shell scripts.
SHELLCHECK=/opt/homebrew/bin/shellcheck
# jq makes JSON output more human-readable.
JQ=/opt/homebrew/bin/jq
# curl is an HTTP(S) swiss-army knife
CURL=/usr/bin/curl

# Ensure that shellcheck exists and is executable.  Otherwise, exit.
if [[ -x "$SHELLCHECK" ]]
then
  # Ensure this script meets shellcheck's approval before continuing any further.
  $SHELLCHECK "$0" || exit 1
else
  echo "shellcheck not found at '$SHELLCHECK', but is required. Exiting."
  exit 1
fi

# Ensure that curl exists and is executable.  Otherwise, exit.
if [[ ! -x "$CURL" ]]
then
  echo "curl not found at '$CURL', but is required. Exiting."
  exit 1
fi

echo ""
echo "... BEGINNING of results for +$1 ..."
echo ""

echo "START of Twilio-native carrier and caller name:"
echo ""
$CURL -s -XGET "https://lookups.twilio.com/v1/PhoneNumbers/+$1/?Type=carrier&Type=caller-name" -u "$TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN" | $JQ
echo ""
echo "END of Twilio-native carrier and caller name."
echo ""

echo ""
echo "START of Telo OpenCNAM lookup:"
echo ""
$CURL -s -XGET "https://lookups.twilio.com/v1/PhoneNumbers/+$1/?AddOns=telo_opencnam" -u "$TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN" | $JQ
echo ""
echo "END of Telo OpenCNAM lookup."
echo ""

echo ""
echo "START of Trestle lookup:"
echo ""
$CURL -s -XGET "https://lookups.twilio.com/v1/PhoneNumbers/+$1/?AddOns=trestle_reverse_phone" -u "$TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN" | $JQ
echo ""
echo "END of Trestle lookup."echo ""
echo ""

echo ""
echo "... DONE displaying results for +$1..."
echo ""
