#!/bin/bash

target="prod"		## must be defined as a target in the API Utility app
object="computergroups"
appBinary="/Applications/API Utility.app/Contents/MacOS/apiutil"

if [ -z $1 ];then
	now=$(DATE +%Y%m%d_%H%M%S)
else
	now=$1
fi
saveLocation="/tmp/export/$now"

if [ ! -d "$saveLocation/smartcomputergroups" ]; then
	mkdir -p "$saveLocation//smartcomputergroups"
fi
if [ ! -d "$saveLocation/staticcomputergroups" ]; then
	mkdir -p "$saveLocation//staticcomputergroups"
fi


while read -r info;do 
	
	objectInfo="${info:1:${#info}-2}"
	
	id=$(echo $objectInfo | awk -F ":::" '{print $1}')
	name=$(echo $objectInfo | awk -F ":::" '{print $2}')
	is_smart=$(echo $objectInfo | awk -F ":::" '{print $3}')
	
	theObject=$("${appBinary}" --env "$target" --path /JSSResource/$object/id/$id --accept xml | xmllint --format -)
	
	# Replace spaces and special characters in filename
	safe_name=$(echo "$name" | tr -d '[:cntrl:]' | tr ' ' '_' | tr -d '[:punct:]')
	
	if $is_smart;then
		echo -e "${theObject}" > "$saveLocation/smartcomputergroups/$safe_name.xml"
		echo "Created file: $saveLocation/smartcomputergroups/$safe_name.xml"
	else
		echo -e "${theObject}" > "$saveLocation/staticcomputergroups/$safe_name.xml"
		echo "Created file: $saveLocation/staticcomputergroups/$safe_name.xml"
	fi
	
done << EOL
$("${appBinary}" --env "$target" --path /JSSResource/$object | jq '.computer_groups[] | "\(.id):::\(.name):::\(.is_smart)"')
EOL

# Copyright 2025, Jamf Software LLC.
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.