#!/bin/bash

target="prod"		## must be defined as a target in the API Utility app
object="categories"

if [ -z $1 ];then
	now=$(DATE +%Y%m%d_%H%M%S)
else
	now=$1
fi
saveLocation="/tmp/export/$now/$object"

appBinary="/Applications/API Utility.app/Contents/MacOS/apiutil"
parameters="--env "$target" --path JSSResource/$object --accept xml"

if [ ! -d $saveLocation ]; then
	mkdir -p $saveLocation
fi

# Fetch XML from API
xml_data=$("${appBinary}" --target prod --path JSSResource/categories --accept xml)

# Ensure the API response contains valid XML
if [[ -z "$xml_data" ]]; then
	echo "Error: No data received from API."
	exit 1
fi

# Define XSLT for extracting ID and Name
xslt_file="extract_categories.xsl"
cat > "$xslt_file" <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text"/>
	<xsl:template match="/categories/category">
		<xsl:value-of select="id"/><xsl:text>:</xsl:text><xsl:value-of select="name"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
</xsl:stylesheet>
EOL

# Transform XML using xsltproc
parsed_output=$(echo "$xml_data" | xsltproc "$xslt_file" -)

# Loop through the parsed output and create files
IFS=$'\n'
for line in $parsed_output; do
	id=$(echo "$line" | cut -d':' -f1)
	name=$(echo "$line" | cut -d':' -f2)
	
	# Replace spaces and special characters in filename
	safe_name=$(echo "$name" | sed 's/[^a-zA-Z0-9_-]/_/g')
	
	# Create a file and write the name and ID inside
	echo -e "<id>$id</id><category>$name</category>" > "$saveLocation/$safe_name.xml"
	echo "Created file: $saveLocation/$safe_name.xml"
done

# Cleanup temporary XSLT file
rm "$xslt_file"

# Copyright 2025, Jamf Software LLC.
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
