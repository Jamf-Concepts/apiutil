#!/bin/bash

# Requires setup of the Jamf API Utility https://concepts.jamf.com/#api-utility 

API_TARGET_NAME='pro'

# Output file
OUTPUT_FILE="jamf_mobile_apps.csv"


echo "Getting a list of application IDs..."
APP_DATA=$(jamfapi --target "${API_TARGET_NAME}" --path "/JSSResource/mobiledeviceapplications")

echo "Extracting a list of app IDs..."
APP_IDS=$(echo "${APP_DATA}" | jq '.mobile_device_applications[]?.id')

echo "Writing CSV header to output file"
echo "\"App Name\",\"App Store URL\"" > "$OUTPUT_FILE"

echo "Reading information for each app id and exporting data to output file"
for APP_ID in $APP_IDS; do
  echo "Processing App ID $APP_ID..."

  APP_JSON=$(jamfapi --target "${API_TARGET_NAME}" --path "/JSSResource/mobiledeviceapplications/id/$APP_ID")

  APP_NAME=$(echo "$APP_JSON" | jq -r '.mobile_device_application.general.name')
  APP_URL=$(echo "$APP_JSON" | jq -r '.mobile_device_application.general.itunes_store_url')

  echo "\"$APP_NAME\",\"$APP_URL\"" >> "$OUTPUT_FILE"
done

echo "Export complete. Results saved to $(pwd)/${OUTPUT_FILE}."
