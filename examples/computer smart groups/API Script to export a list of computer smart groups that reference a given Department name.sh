#!/bin/bash

# API Script to export a list of computer smart groups that reference a given Department name

# (!) Requires setup of the Jamf API Utility https://concepts.jamf.com/#api-utility 


# SETTINGS...

# The name of the Jamf Pro target you set up in the API Utility
API_TARGET_NAME='pro'

# What's the base URL to your Jamf Pro? (Needed so we can output a list of links to edit the smart groups)
JAMF_URL="https://my.jamfcloud.com"

# The name of the department you want to cross-reference. 
DEPARTMENT='Managers'


# CODE...

# Where to save the results? 
OUTPUT_FILE="List of computer smart groups that reference the ${DEPARTMENT} department.csv"

echo "Getting a list of computer smart groups..."
DATA=$(jamfapi --target "${API_TARGET_NAME}" --path "/JSSResource/computergroups")

echo "Extracting a list of smart group IDs..."
ITEM_IDS=$(echo "${DATA}" | jq '.computer_groups[] | select(.is_smart == true) | .id')


echo "Writing CSV header to output file"
echo "\"Group Name\",\"Group URL\"" > "$OUTPUT_FILE"

echo "Reading information for each group id and exporting info on any that reference the given department..."
for ITEM_ID in $ITEM_IDS; do
  echo "Processing item ID $ITEM_ID..."

  ITEM_JSON=$(jamfapi --target "${API_TARGET_NAME}" --path "/JSSResource/computergroups/id/$ITEM_ID")
	GROUP_NAME=$(echo "$ITEM_JSON" | jq -r '.computer_group.name')

  MATCH=$(echo "$ITEM_JSON" | jq -r '.computer_group.criteria[]? | select(.name == "Department" and .value == "Managers")')
  if [[ -n "$MATCH" ]]; then
    GROUP_URL="$JAMF_URL/computergroups.html?id=${ITEM_ID}&o=r"
    echo "\"$GROUP_NAME\",\"$GROUP_URL\"" >> "$OUTPUT_FILE"
    echo "✅ Match found for ${GROUP_NAME}"
  else
		echo "${GROUP_NAME} does not reference \"${DEPARTMENT}\""
  fi

done

echo "Export complete. Results saved to $(pwd)/${OUTPUT_FILE}."


# Copyright 2025 Jamf

# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

