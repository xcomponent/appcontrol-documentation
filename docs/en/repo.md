# Git integration

AppControl YAML or XML files can be conveniently stored in a Git repository for version control and collaboration. Additionally, you can display the live status of your application directly in your documentation by adding a markdown badge link. For example:

```markdown
![My App](https://appcontrol.xcomponent.com/core/api/badge?applicationName=MYAPP,v1@myaccount)
```

This badge will display the real-time status of your application in your documentation.

![Badges](badges.png)

## Automating Application Deployment with AppControl APIs

AppControl provides powerful APIs that allow for automatic deployment of applications through custom scripts. These scripts can be integrated into your CI/CD pipelines or used for ad-hoc deployments. Below is a generic example of a script that loads and deploys an application map (in YAML or XML format) to AppControl.

**Sample Deployment Script**

```bash
#!/usr/bin/env bash
set -o errexit
set -o nounset

# API endpoint for AppControl
export API=${APPCONTROL_HOME:-https://appcontrol.xcomponent.com}/core

debug() {
    [[ "${DEBUG:-0}" != "0" ]] && echo "$@"
}

main() {
    # Check if the required parameters are passed
    if [[ $# -lt 2 ]]; then
        echo "Usage: $0 <map-file> <gateway-name>"
        exit 1
    fi

    local mapFile="$1"
    local agentProxyName="$2"
    local mapFileContents=$(cat "$mapFile")

    # Extract application name and version from the map file (XML or YAML)
    local mapName=$(grep "<app name" "$mapFile" | cut -d "\"" -f2)
    local mapVersion=$(grep "<app name" "$mapFile" | cut -d "\"" -f4)
    local escapedMapFileContents

    # Check if XML parsing failed (if mapName or mapVersion is empty, fallback to YAML)
    if [[ -z "$mapName" ]] || [[ -z "$mapVersion" ]]; then
        echo "XML parsing failed or not XML format. Trying YAML..."

        # Attempt to read the file as YAML using yq
        mapName=$(yq e '.Name' "$mapFile")
        mapVersion=$(yq e '.Version' "$mapFile")

        if [[ -z "$mapName" ]] || [[ -z "$mapVersion" ]]; then
            echo "YAML parsing failed. Please check the file format."
            exit 1
        fi
    fi

    # Escape file contents to be used in the JSON payload
    escapedMapFileContents=$(echo "$mapFileContents" | jq -aRs .)

    # Prepare the data payload for the API
    data=$(jq -n --arg xml "$escapedMapFileContents" \
                    --arg app "$mapName" \
                    --arg version "$mapVersion" \
                    --arg gateway "$agentProxyName" \
                    '{
                        Xml: $xml,
                        Application: $app,
                        Version: $version,
                        AgentProxyName: $gateway,
                        LoadMap: "true",
                        OverWrite: "true",
                        UseDefaultAgent: "false"
                    }')

    echo "Loading $mapName $mapVersion using gateway $agentProxyName..."

    # Send the API request
    curl $API/api/Configuration -X PUT \
         --header "Content-Type: application/json" \
         --header "Authorization: bearer $AUTH" \
         --data-binary "$data" \
         --fail
}

main "$@"

```

**Example of usage**

```bash
./deploy_app.sh myapp.yaml Azure_Gateway
```

This script will upload the myapp.yaml file and use the specified gateway (Azure_Gateway).
