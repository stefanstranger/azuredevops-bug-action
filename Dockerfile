FROM mcr.microsoft.com/powershell:lts-alpine-3.10
RUN pwsh -c "Install-Module VSTeam -Scope AllUsers -Acceptlicense -Force"
COPY ./src/ ./tmp/
ENTRYPOINT ["pwsh","-File","/tmp/scripts/Create-Bug.ps1"]