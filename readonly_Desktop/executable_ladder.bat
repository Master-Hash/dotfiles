rem chcp 65001
rem start "Clash" "C:\Users\hash\Documents\naiveproxy\clash-windows-amd64-v3.exe" -f "C:\Users\hash\OneDrive\应用\clash\Hash.yaml"
rem start "Clash.Meta" "C:\Users\hash\Documents\naiveproxy\mihomo-windows-amd64.exe" -f "C:\Users\hash\OneDrive\应用\clash\mihomo.yaml"
rem start "Clash.Meta" "C:\Users\hash\Documents\naiveproxy\mihomo-windows-amd64.exe" -f "C:\Users\hash\OneDrive\应用\clash\mihomo.yaml"

cd C:\Users\hash\

start "Naïveproxy" "C:\Users\hash\Documents\naiveproxy\naive.exe" "C:\Users\hash\Documents\naiveproxy\config.json"
rem start "Warp+" "C:\Users\hash\Documents\naiveproxy\wireproxy.exe" -c "C:\Users\hash\Documents\naiveproxy\wgcf-profile.conf"
start "sing-box" sudo "C:\Users\hash\Documents\naiveproxy\sing-box.exe" run -c "C:\Users\hash\OneDrive\应用\clash\config.json"
