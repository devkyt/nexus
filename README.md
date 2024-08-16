


## Setup Proxy
To start using Sonatype Nexus as a dependencies proxy and cache storage you first need to point package managers to it. 
So they won't be communicate with official registries directly as it was before but instead will request all packages through Nexus server.

### Npm
Save this config to .npmrc file in your user directory ("C:\Users\Dev\"):
```toml
registry = https://nexus.organization.com/repository/npm-group/

email = dev@organization.com

always-auth = true
strict-ssl = false

//nexus.novotrend.de/repository/npm-group/:_auth = username:password | base64
```

Run ```npm install <package-name>`` in some project to check if everything is working.


### NuGet
Create NuGet.Config file with following content:
```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
    <config>
        <add key="dependencyVersion" value="Highest" />
        <add key="maxHttpRequestsPerSource" value="16" />
    </config>
    <packageSources>
        <clear />
        <add key="nexus"  value="https://nexus.organization.com/repository/nuget-proxy/index.json" allowInsecureConnections="true" />
    </packageSources>
    <packageSourceCredentials>
        <nexus>
            <add key="Username" value="username" />
            <add key="ClearTextPassword" value="password" />
        </nexus>
    </packageSourceCredentials>
</configuration>
```

Save it to "C:\Program Files (x86)\NuGet\Config\" directory. Then ensure Nexus is added to NuGet source list:
```sh
nuget list source
```

If it's on the list, delete nuget.org from sources:
```sh
dotnet nuget remove source nuget.org
```

Run ```dotnet add package <package-name>``` in some project to check if everything is working.
