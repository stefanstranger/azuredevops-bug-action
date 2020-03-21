FROM mcr.microsoft.com/powershell:7.0.0-rc.3-alpine-3.8
RUN pwsh -c "Install-Module VSTeam -Scope AllUsers -Acceptlicense -Force"
COPY ./src/ ./tmp/
ENTRYPOINT ["pwsh","-File","/tmp/scripts/Create-Bug.ps1"]