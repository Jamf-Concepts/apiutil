#!/bin/bash

# Makes a call to the JAMF Pro API to get a list of device IDs belonging to a group

# The Jamf Pro API returns object data in JSON format. 
# The JSON data is parsed using jq, a command line program that comes pre-installed with modern version of macOS. 
# The $? variable is checked to see if an API error occurred. 


TARGET="pro"
GROUP_NAME="students"

# url-encode the group name in case there's a space
GROUP_NAME_ENCODED=$(jq -rn --arg v "$GROUP_NAME" '$v|@uri')  

ENDPOINT="/JSSResource/mobiledevicegroups/name/${GROUP_NAME_ENCODED}"

# Make an API call
group_json=$(apiutil --target "$TARGET" --path "$ENDPOINT" 2>&1)

# Check for errors
if [[ $? -ne 0 ]]; then
  # Exit if there was an error.
  echo "❌ Error running apiutil. The API returned:"
  echo "${group_json}"
  exit 1
fi

# If we're still running, then the API call worked. 

# Extract the device IDs from the JSON into an array

device_ids=($(jq '.mobile_device_group.mobile_devices[].id' <<< "$group_json"))
if [ ${#device_ids[@]} -eq 0 ]; then
  echo "⚠️ No devices found in group: $GROUP_NAME"
  exit 2
fi

echo "✅ Found ${#device_ids[@]} devices"

# Copyright 2025, Jamf Software LLC.
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
