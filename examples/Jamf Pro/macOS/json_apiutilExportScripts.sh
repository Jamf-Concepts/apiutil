#!/bin/bash

target="prod"		## must be defined as a target in the API Utility app
object="scripts"
appBinary="/Applications/API Utility.app/Contents/MacOS/apiutil"

if [ -z $1 ];then
	now=$(DATE +%Y%m%d_%H%M%S)
else
	now=$1
fi
saveLocation="/tmp/export/$now/$object"

if [ ! -d $saveLocation ]; then
	mkdir -p $saveLocation
fi

while read -r theScript;do 
	# Decode the JSON object
	obj=$(echo "$theScript" | base64 --decode)
	
	# Extract name and script
	name=$(echo "$obj" | jq -r '.name')
	scriptContents=$(echo "$obj" | jq -r '.scriptContents')
	
	# Sanitize filename (replace spaces and special characters)
	safe_name=$(echo "$name" | tr -d '[:cntrl:]' | tr ' ' '_' | tr -d '[:punct:]')
	
	# Ensure name is not empty
	if [[ -n "$safe_name" ]]; then
		echo "$scriptContents" > "$saveLocation/${safe_name}.sh"
		echo "Created file: $saveLocation/${safe_name}.sh"
	fi
done << EOL
$("${appBinary}" --env "$target" --path /api/v1/$object | jq -r '.results[] | @base64')
EOL

# Copyright 2025, Jamf Software LLC.
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
