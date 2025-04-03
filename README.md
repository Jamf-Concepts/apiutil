# Jamf API Helper

An app to simplify the creation of admin API scripts and prompt some thought about how we handle secrets. 


&nbsp;

## Table of Contents

- [Jamf API Helper - Summary](#jamf-api-helper)
- [User's Guide](#users-guide)
- [Appendix: How to Keep a Secret](#appendix-how-to-keep-a-secret)


&nbsp;

## Summary

The application has two components:

The macOS GUI app is used to add  "environments". These are the connection information for your Jamf servers. Since they include login secrets, the app will store these in your user keychain. 

The second component is a command-line binary used to access the keychain information and simplify API calls. 

Say we're writing a script to pull down information about all the computers enrolled in Jamf Pro. We would first need to write some code to obtain a bearer token using the API's auth endpoint, and if we're being diligent, we would add the ability to refresh tokens as they near expiration and invalidate them when they're no longer needed. Then we'd need a looping structure with some logic to fetch all pages from the `/api/v1/computers-inventory` endpoint, concatenating or processing the pages as we go. 

The Jamf API Helper app simplifies all that. Once we've saved our credentials, instead of writing the 50-line script described above, now it's just a one-liner...

`jamfapi --endpoint "/api/v1/computers-inventory"`

The jamfapi binary handles the rest. 

> **Note:** This project is intended for use by Jamf admins writing scripts to run on their own computers, not for scripts that run on the Macs they manage. Secrets sent to client devices, no matter the delivery mechanism or obfuscation used, are discoverable by users or malware. Secrets for cloud applications and functions should be stored and retrieved using a secret manager supported by the cloud platform. 


&nbsp;

## User's Guide

### Managing Environments

Before we can make API calls, we'll need to save some login information. Opening the app will show a list of any items that have been saved. 

![](images/env-list.png)

Initially, the list inside the app will be blank. Add environments using the "Add" button. The environment name is used to describe the environment and differentiate it from other configured environments. Environment names cannot contain spaces. For Jamf Pro credentials, you may supply either a Client ID and Secret, or a Username and Password.  

![](images/addPro.png)

Jamf Protect utilizes an API Client and Secret:
![](images/addProtect.png)

Jamf School utilizes basic auth based on network ID and key:
![](images/addSchool.png)

Once at least one environment has been entered, you can start using the utility's command-line component. 

### SIMPLIFYING THE PATH TO THE COMMAND LINE EXECUTABLE


The command-line binary we'll be calling from our shell scripts is buried inside the Jamf API Helper app. It's inside the bundles `Contents/MacOS/` folder.  

![](images/binary.png)

If the jamfapi app is in your Applications folder, you could call the command line utility like this: 

`/Applications/jamfapi.app/Contents/MacOS/jamfapi  ...`

But that's a lot to type. We should create a shortcut so we can simply say `jamfapi  ...`

If you only need the shortcut for your own account, you can add an alias in your shell configuration file. The following is an example of adding the alias:

```sh
sudo sh -c 'echo "\nalias jamfapi=\'/Applications/jamfapi.app/Contents/MacOS/jamfapi\'" >> ~/.zshrc'
```

After editing your shell configuration file, reload the shell configuration file to reflect the changes:

```sh
source ~/.zshrc
```

As an alternative, if you wanted to make the simplified command line available to all users and shells, we can add a wrapper script to a directory that's already in macOS's default search path. 

```sh
sudo sh -c 'echo "#!/bin/bash\n/Applications/jamfapi.app/Contents/MacOS/jamfapi \"\$@\"" > /usr/local/bin/jamfapi; chmod +x "/usr/local/bin/jamfapi"'
```

(L's version...)

```
echo '#!/bin/zsh' | sudo tee /usr/local/bin/jamfapi
echo 'exec "/Applications/jamfapi.app/Contents/MacOS/jamfapi" "$@"' | sudo tee -a /usr/local/bin/jamfapi
```

&nbsp;
  
## Making API Calls

jamfapi(1)

### NAME  

jamfapi – A command-line tool for interacting with Jamf APIs.

### SYNOPSIS  

```sh
jamfapi [OPTIONS]
```

### DESCRIPTION  

jamfapi simplifies the process of making API calls to Jamf product APIs. A companion GUI app is run prior to calling the command line binary to setup target server URLs and authentication credentials. 

### OPTIONS  

`--target, --env, --environment _Name_`

Specifies the target API server and authentication group for the request by its display name. The parameter is optional if only one environment has been configured and required if multiple environments have been configured. 

`--method, --action _METHOD_`

(Optional) Specifies the HTTP method for the API request (e.g., GET, POST, PUT, PATCH, DELETE). "GET" will be used if not specified. 

`--endpoint _PATH_`

Specifies the API endpoint, relative to the base server URL. For example, "/JSSResource/buildings" or "/api/v1/buildings/id/9".

`--data _PAYLOAD_`

(Optional) Specifies the payload body for endpoints and methods that accept data.

`--accept _MIME_TYPE_`

(Optional) Overrides the default `Accept` header for the request. The accept header may be specified if an endpoint supports multiple return options. This parameter would not be used frequently. In the case of many Jamf Pro Classic API endpoints, the return results can be either XML or JSON. If it is not specified, "application/JSON" will be returned. 

`--content, --content-type _MIME_TYPE_`

(Optional) Overrides the `Content-Type` header for the request. If not specified, "text/XML" is assumed for calls to the Jamf Pro classic API and "application/JSON" is assumed for calls to the Jamf Pro API. Note: Since most endpoints only accept a single content type, there are only a few cases where this parameter could be used. 

> ***(to-do... I think there are some asset upload endpoints that accept binary data. Do we have a list?)***


### EXAMPLES  

Get a list of buildings:  
```
jamfapi --target "pro-prod" --endpoint "/JSSResource/buildings"
```

Create a new building:  
```
jamfapi --method "POST" --endpoint "/JSSResource/buildings" --data "<building><name>Building Name</name></building>"
```

### USAGE NOTES

#### A simple "get"
```sh
jamfapi --endpoint "/JSSResource/buildings"
```

In this example, the only parameter specified is the endpoint. This is the simplest possible invocation of the utility. 

- The `--target` parameter has been omitted so the command would only work in a setup where only a single named target has been configured in the application's keychain. 
- The HTTP `--method` parameter is omitted so "GET" will be used. 
- The `--accept` parameter is omitted so "application/json" output will be requested. 
- The `--content` parameter would not apply here since no data is being sent.  

If the Jamf Pro server has just one building configured and it is named "Apple Park", the output of the command would be:  

```sh
[
  {
    "size": 1,
    "building": {
      "id": 1,
      "name": "Apple Park"
    }
  }
]
```

#### Same request, more parameters

> The following command will return the same result as the example above because all of the added parameter values match their defaults. There's no technical reason to specify default values explicitly but some developers like to put them in anyway to make the command more self-documenting. The parameter values in this example are wrapped in quotes. This is only technically required when a value contains an un-escaped shell delimiter character (e.g., a space), but some developers like to quote things anyway to make it easier to see that the enclosed string is the parameter's value. The "\\" at the end of all but the last line is the shell script "continuation character". It's used here as an example of how to break a command into multiple lines if you wish to improve your script's readability when a command has many parameters. 

```sh
jamfapi \
  --target "pro" \
  --method "get" \
  --accept "application/json" \
  --endpoint "/JSSResource/buildings"
```

#### Retrieving XML

The output of API commands are JSON as it is both jamfapi's default and we did not override it with an --accept parameter. But since we are using a Classic API endpoint, we also have the choice to request XML output adding the --accept parameter. 

```sh
jamfapi --target "pro-prod" --endpoint "/JSSResource/buildings" --accept "text/xml"
```

Historically, many API scripts using Jamf Pro's Classic API would request XML-formatted output because command line utilities for parsing XML (i.e. xpath and xmllint) came pre-installed in to macOS while jq, the common choice for parsing JSON was not. But jq is included in more recent versions of macOS and is generally thought to be easier to work with so many developers prefer it. However, XML may also be preferred when you need to get the data from a Classic API endpoint that you intend to use it as the basis for the body you need for a subsequent post or put because the Classic API accepts only XML data. 

#### Creating a new resource

In the examples section above, we showed how to use Jamf Pro's Classic API to create a new building entry. Because we're using a classic API endpoint, we supplied the data as XML. 

```sh
jamfapi --method "POST" --endpoint "/JSSResource/buildings" --data "<building><name>Apple Park</name></building>"
```

The buildings object endpoint has a sibling in the more modern Jamf Pro API that can be used to accomplish the same thing. But where the Classic API uses XML input, the Jamf Pro API requires JSON. Note that because the data value contains double-quotes and spaces, we wrap the value in single quotes. 

```sh
jamfapi --method "POST" --endpoint "/api/v1/buildings" --data '{"name": "Apple Park"}'
```

#### Pagination

Some Jamf Pro Endpoints return "paginated" data. For example, if we want to retrieve complete details on every computer from a Jamf Pro instance that manages tens of thousands of devices, it would be a lot more manageable to download them in chunks. So a script that wants the full list will require some looping and logic to obtain the full list. The jamfapi utility will take care of that for you, downloading all pages and returning them in a single response. However, if you want your script to process the chunks individually, you can include the pagination parameters in your URL. 

Returns all computers:

```sh
jamfapi --endpoint "/api/v1/computers-inventory"
```

Returns the third page of 100 computers:

```sh
jamfapi --endpoint "/api/v1/computers-inventory?page=3&page-size=100"
```

### EXIT STATUS  

```
20x-50x : The HTTP Status code returned by the Jamf API
 0      : Parameter Error
-1      : DNS Error
-2      : Connection Error
-3      : Timeout Error
```

### SEE ALSO  

Jamf API documentation: [https://developer.jamf.com/](https://developer.jamf.com/)

&nbsp; 

&nbsp; 

&nbsp; 
-
-
-
-


##Stuff for later? 

Add in explanations of Leslie's full examples. Show how to use jq to get useful data. How to get a list of serial numbers, eg. 

**To be added in MVP v2...**

--object _OBJECT_TYPE_  
Specifies the object type (e.g., categories, buildings). *(Not used in MVP.)*


**Let's not include these for now -- to encourage people to use the GUI App and not put secrets on command line calls**

--account, --username _USERNAME_  
Specifies the username or account name for authentication.

--clientid _CLIENT_ID_  
Specifies the client ID for authentication.

--server _URL_  
Specifies the base URL of the Jamf server. Trailing slashes will be removed.


# SERVER TYPE  

These won't be needed since we're specifying the product type in the targets saved in keychain, right? 

--pro, --jamfpro, --jamf-pro  
Indicates that the request is for Jamf Pro.

--protect, --jamfprotedt, --jamf-protect  
Indicates that the request is for Jamf Protect.

--school, --jamfschool, --jamf-school  
Indicates that the request is for Jamf School.
