#!/bin/bash

target="prod"		## must be defined as a target in the API Utility app
object="policies"
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

while read -r info;do 
	policyInfo="${info:1:${#info}-2}"

	id=$(echo $policyInfo | awk -F ":" '{print $1}')
	name=$(echo $policyInfo | awk -F ": " '{print $2}')
	
	thePolicy=$("${appBinary}" --env "$target" --path /JSSResource/$object/id/$id --accept xml | xmllint --format -)
	
	# Replace spaces and special characters in filename
	safe_name=$(echo "$name" | tr -d '[:cntrl:]' | tr ' ' '_' | tr -d '[:punct:]')
	
	# Create a file and write the name and ID inside
	echo -e "${thePolicy}" > "$saveLocation/$safe_name.xml"
	echo "Created file: $saveLocation/$safe_name.xml"
	
done << EOL
$("${appBinary}" --env "$target" --path /JSSResource/$object | jq '.policies[] | select(.name | test("^[0-9]{4}-[0-9]{2}-[0-9]{2} at ") | not) | "\(.id): \(.name)"')
EOL

# Copyright 2025, Jamf Software LLC.
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
