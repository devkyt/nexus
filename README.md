


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

Run ```npm install <package-name>``` in some project to check if everything is working.


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

### Docker

## Raw Repo
Pack content of the folder into the archive:
```sh
tar -acf build-29-08-2024.zi -C build *
```

Send to the Nexus raw repo:
```sh
curl -v --user admin:admin123 --upload-file .\build-29-08-2024.zip https://nexus.novotrend.de/repository/raw/
```

Upload from the the Nexus raw repo: 
```sh
curl -vL --user admin:admin123 -o build.zip  https://nexus.novotrend.de/repository/raw/build-29-08-2024.zip
```

## Reset Admin Password
If you forget or lost an admin password, you can reset it via H2 console. 

Go to $NEXUS_DATA/etc folder and add these lines to nexus.properties:
```
nexus.h2.httpListenerEnabled=true
nexus.h2.httpListenerPort=1234
```

Restart container with 1234 port exposed:
```yaml
ports:
    - 8082:8081
    - 1234:1234 
```

Then open localhost:1234 in browser and connect to db:
```
Save Settings: Generic H2 (Embedded)
Driver: org.h2.Driver
JDBC URL: jdbc:h2:file:nexus
username: <blank>
password: <blank>
```

Reset password to default "admin123":
```sql
UPDATE security_user SET password='$shiro1$SHA-512$1024$NE+wqQq/TmjZMvfI7ENh/g==$V4yPw8T64UQ6GfJfxYq2hLsVrBY8D1v+bktfOxGdt4b/9BthpWPNUy/CBk6V9iA0nHpzYzJFWO8v/tZFtES8CA==', status='active' WHERE id='admin';
```

Update role mapping for admin: 
```sql
UPDATE user_role_mapping SET roles='["nx-admin"]' WHERE user_id = 'admin';
UPDATE user_role_mapping SET user-lo='admin' WHERE user_id = 'admin';
```

After that close port in container, delete h2 lines from properties and restart Nexus to apply last changes.