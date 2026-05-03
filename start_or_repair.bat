@echo off
docker ps -a --format "{{.Names}}" | findstr /C:"workstation" > nul
if %errorlevel% equ 0 (
    docker exec workstation rm -rf /var/run/xrdp 2>nul
    docker stop workstation
)

docker images workstation:latest --format "{{.Repository}}" | findstr /C:"workstation" > nul || (
    echo Image not found. Image compile is beginning...
    docker rm -v workstation
    docker build -t workstation .
)

docker ps -a --format "{{.Names}}" | findstr /C:"workstation" > nul
if %errorlevel% equ 0 (
    docker start workstation
) else (
    docker run -d -p 3389:3389 --name workstation workstation:latest sleep infinity
)

docker exec workstation /usr/sbin/xrdp 
docker exec workstation /usr/sbin/xrdp-sesman

echo Container is working.
pause