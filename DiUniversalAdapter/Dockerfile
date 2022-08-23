# escape=\

#  Change the base image as appropriate for your scenario.
FROM mcr.microsoft.com/dotnet/framework/runtime:4.7.2-windowsservercore-ltsc2019
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR /app

COPY ["./DiUniversalAdapter Service","./"]
COPY Wait-Service.ps1 ./

RUN "C:/Windows/Microsoft.NET/Framework64/v4.0.30319/installutil.exe" /LogToConsole=true /ShowCallStack C:/app/DiUniversalAdapter.Running.WSHost.exe;

ENTRYPOINT ["powershell"]
CMD C:\app\Wait-Service.ps1 -ServiceName 'DiUniversalAdapterWindowsService' -AllowServiceRestart
#CMD Get-EventLog -LogName System -After (Get-Date).AddHours(-1) | Format-List ;\
#  $idx = (get-eventlog -LogName System -Newest 1).Index; \
#  while ($true) \
#  {; \
#  start-sleep -Seconds 1; \
#  $idx2  = (Get-EventLog -LogName System -newest 1).index; \
#  get-eventlog -logname system -newest ($idx2 - $idx) |  sort index | Format-List; \
#  $idx = $idx2; \
#  }