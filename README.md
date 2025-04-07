
<!--
![GitHub release (latest by date)](https://img.shields.io/github/v/release/Concepts/jamfapi?display_name=tag) ![GitHub all releases](https://img.shields.io/github/downloads/Concepts/jamfapi/total)  ![GitHub latest release](https://img.shields.io/github/downloads/Concepts/jamfapi/latest/total)
 ![GitHub issues](https://img.shields.io/github/issues-raw/Concepts/jamfapi) ![GitHub closed issues](https://img.shields.io/github/issues-closed-raw/Concepts/jamfapi)
 -->


# Jamf API Helper

An app to simplify the creation of admin API scripts and prompt some thought about how we handle secrets. 


&nbsp;

## Table of Contents

- [Jamf API Helper - Summary](#jamf-api-helper)
- [User's Guide](../../wiki)


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
