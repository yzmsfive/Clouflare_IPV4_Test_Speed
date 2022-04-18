chcp 936>nul
@echo off
cd "%~dp0"
color A
setlocal enabledelayedexpansion
set version=20220208

:main
cls
title CF��ѡIP
echo 1. IPV4��ѡ&echo 0. ��ջ���.
set /p menu=��ѡ��˵�:
if %menu%==0 del ipv4.txt ipv6.txt data.txt ip.txt CR.txt CRLF.txt cut.txt speed.txt meta.txt>nul 2>&1&RD /S /Q rtt>nul 2>&1
if %menu%==1 title IPV4��ѡ&set ips=ipv4&set /a selfmode=0&goto bettercloudflareip
goto main

:singletest
set /p ip=��������Ҫ���ٵ�IP:
curl --resolve service.baipiao.eu.org:443:!ip! https://service.baipiao.eu.org -o temp.txt -#
for /f "tokens=2 delims==" %%i in ('findstr "domain=" temp.txt') do (
set domain=%%i
)
for /f "delims=" %%i in ('findstr "file=" temp.txt') do (
set file=%%i
set file=!file:~5!
)
del temp.txt
title  ���ڲ��� !ip!
curl --resolve !domain!:443:!ip! https://!domain!/!file! -o nul --connect-timeout 5 --max-time 15
goto :eof

:bettercloudflareip
set /a tasknum=25
set /a bandwidth=0
set /p bandwidth=�����������Ĵ����С(Ĭ��%bandwidth%,��λ Mbps):
set /p tasknum=������RTT���Խ�����(Ĭ��%tasknum%,���50):
if %tasknum% EQU 0 (set /a tasknum=25&echo ����������Ϊ0,�Զ�����ΪĬ��ֵ)
if %tasknum% GTR 50 (set /a tasknum=50&echo ��������������,�Զ�����Ϊ���ֵ)
set /a speed=bandwidth*128
set /a startH=%time:~0,2%
if %time:~3,1% EQU 0 (set /a startM=%time:~4,1%) else (set /a startM=%time:~3,2%)
if %time:~6,1% EQU 0 (set /a startS=%time:~7,1%) else (set /a startS=%time:~6,2%)
call :start
exit

:start
del data.txt ip.txt CR.txt CRLF.txt cut.txt speed.txt meta.txt>nul 2>&1
RD /S /Q rtt>nul 2>&1
if exist "!ips!.txt" goto resolve
if not exist "!ips!.txt" goto dnsresolve

:dnsresolve
echo DNS������ȡCF !ips! �ڵ�
echo �����������Ⱦ,���ֶ����� !ips!.txt ������
curl --!ips! --retry 3 -s https://service.baipiao.eu.org/meta -o meta.txt
if not exist "meta.txt" goto start
for /f "tokens=2 delims==" %%i in ('findstr "asn=" meta.txt') do (
	set asn=%%i
)
for /f "tokens=2 delims==" %%i in ('findstr "isp=" meta.txt') do (
	set isp=%%i
)
for /f "tokens=2 delims==" %%i in ('findstr "country=" meta.txt') do (
	set country=%%i
)
for /f "tokens=2 delims==" %%i in ('findstr "region=" meta.txt') do (
	set region=%%i
)
for /f "tokens=2 delims==" %%i in ('findstr "city=" meta.txt') do (
	set city=%%i
)
for /f "tokens=2 delims==" %%i in ('findstr "longitude=" meta.txt') do (
	set longitude=%%i
)
for /f "tokens=2 delims==" %%i in ('findstr "latitude=" meta.txt') do (
	set latitude=%%i
)
curl --!ips! --retry 3 https://service.baipiao.eu.org -o data.txt -#
if not exist "data.txt" goto start
goto checkupdate

:resolve
for /f "delims=" %%i in (!ips!.txt) do (
set resolveip=%%i
)
echo ָ�������ȡCF !ips! �ڵ�
echo �����ʱ���޷���ȡCF !ips! �ڵ�,�������г���ѡ����ջ���
curl --!ips! --resolve service.baipiao.eu.org:443:!resolveip! --retry 3 -s https://service.baipiao.eu.org/meta -o meta.txt
if not exist "meta.txt" goto start
for /f "tokens=2 delims==" %%i in ('findstr "asn=" meta.txt') do (
	set asn=%%i
)
for /f "tokens=2 delims==" %%i in ('findstr "isp=" meta.txt') do (
	set isp=%%i
)
for /f "tokens=2 delims==" %%i in ('findstr "country=" meta.txt') do (
	set country=%%i
)
for /f "tokens=2 delims==" %%i in ('findstr "region=" meta.txt') do (
	set region=%%i
)
for /f "tokens=2 delims==" %%i in ('findstr "city=" meta.txt') do (
	set city=%%i
)
for /f "tokens=2 delims==" %%i in ('findstr "longitude=" meta.txt') do (
	set longitude=%%i
)
for /f "tokens=2 delims==" %%i in ('findstr "latitude=" meta.txt') do (
	set latitude=%%i
)
curl --!ips! --resolve service.baipiao.eu.org:443:!resolveip! --retry 3 https://service.baipiao.eu.org -o data.txt -#
if not exist "data.txt" goto start
goto checkupdate

:checkupdate
for /f "tokens=2 delims==" %%i in ('findstr "domain=" data.txt') do (
set domain=%%i
)
for /f "delims=" %%i in ('findstr "file=" data.txt') do (
set file=%%i
set file=!file:~5!
)
for /f "tokens=2 delims==" %%i in ('findstr "url=" data.txt') do (
set url=%%i
)
for /f "tokens=2 delims==" %%i in ('findstr "app=" data.txt') do (
set app=%%i
if !app! NEQ !version! (echo �����°汾����: !app!&echo ���µ�ַ: !url!&title ���º�ſ���ʹ��&echo ��������˳�����&pause>nul&exit)
)
if not exist "RTT.bat" echo ��ǰ��������&echo ����������Release�汾: !url! &pause>nul&exit
if not exist "CR2CRLF.exe" echo ��ǰ��������&echo ����������Release�汾: !url! &pause>nul&exit
if !selfmode!==0 (goto getip) else (set /a a=0&goto selfconfigip)

:getip
for /f "skip=4" %%i in (data.txt) do (
echo %%i>>ip.txt
)
goto rtt

:selfconfigip
if !a!==256 (goto rtt) else (echo !selfip!.!a!>>ip.txt&set /a a=a+1&goto selfconfigip)

:rtt
del meta.txt data.txt
mkdir rtt
for /f "tokens=2 delims=:" %%i in ('find /c /v "" ip.txt') do (
set /a ipnum=%%i
)
if !tasknum! GTR !ipnum! set /a tasknum=ipnum
set /a iplist=ipnum/tasknum
set /a a=1
set /a b=1
for /f "delims=" %%i in (ip.txt) do (
echo %%i>>rtt/!b!.txt
if !a! EQU !iplist! (set /a a=1&set /a b=b+1) else (set /a a=a+1)
)
del ip.txt
if !a! NEQ 1 set /a a=1&set /a b=b+1
title RTT������
goto rtttest

:rtttest
if !a! NEQ !b! (start /b RTT.bat !a!>nul&set /a a=a+1&goto rtttest) else (goto rttstatus)

:rttstatus
timeout /T 2 /NOBREAK>nul
for /f "delims=" %%i in ('dir rtt /o:-s /b^| findstr txt^| find /c /v ""') do (
set /a taskstatus=%%i
if !taskstatus! NEQ 0 (echo �ȴ�RTT���Խ���,ʣ������� !taskstatus!&goto rttstatus) else (echo RTT�������)
)
for /f "delims=" %%i in ('dir rtt /o:-s /b^| find /c /v ""') do (
set /a status=%%i
if !status! EQU 0 echo ��ǰ����IP������RTT����&goto start
)
copy rtt\*.log rtt\ip.txt>nul
sort rtt/ip.txt /O ip.txt
for /f "tokens=2 delims=:" %%i in ('find /c /v "" ip.txt') do (
if %%i LSS 5 (echo ��ǰ����IP������RTT����&set /a tasknum=10&goto start)
)
set /a a=0
for /f "tokens=2,3 delims= " %%i in (ip.txt) do (
set /a a=a+1
if !a!==1 echo ��1��IP %%j �����ӳ� %%i ����
)
set /a a=0
for /f "tokens=2,3 delims= " %%i in (ip.txt) do (
set /a a=a+1
if !a!==2 echo ��2��IP %%j �����ӳ� %%i ����
)
set /a a=0
for /f "tokens=2,3 delims= " %%i in (ip.txt) do (
set /a a=a+1
if !a!==3 echo ��3��IP %%j �����ӳ� %%i ����
)
set /a a=0
for /f "tokens=2,3 delims= " %%i in (ip.txt) do (
set /a a=a+1
if !a!==4 echo ��4��IP %%j �����ӳ� %%i ����
)
set /a a=0
for /f "tokens=2,3 delims= " %%i in (ip.txt) do (
set /a a=a+1
if !a!==5 echo ��5��IP %%j �����ӳ� %%i ����
)
title ��������
set /a a=0
for /f "tokens=2,3 delims= " %%i in (ip.txt) do (
set /a a=a+1
if !a! GTR 5 echo û�������ٶ�Ҫ���IP&goto start
del CRLF.txt cut.txt speed.txt>nul 2>&1
set avgms=%%i
set anycast=%%j
echo ���ڲ��� !anycast!
curl --resolve !domain!:443:!anycast! https://!domain!/!file! -o nul --connect-timeout 5 --max-time 10 > CR.txt 2>&1
findstr "0:" CR.txt >> CRLF.txt
CR2CRLF CRLF.txt>nul
for /f "delims=" %%i in (CRLF.txt) do (
set s=%%i
set s=!s:~73,5!
echo !s%!>>cut.txt
)
for /f "delims=" %%i in ('findstr /v "k M" cut.txt') do (
set x=%%i
set x=!x:~0,5!
set /a x=!x%!/1024
echo !x! >> speed.txt
)
for /f "delims=" %%i in ('findstr "k" cut.txt') do (
set x=%%i
set x=!x:~0,4!
set /a x=!x%!
echo !x! >> speed.txt
)
for /f "delims=" %%i in ('findstr "M" cut.txt') do (
set x=%%i
set x=!x:~0,2!
set y=%%i
set y=!y:~3,1!
set /a x=!x%!*1024
set /a y=!y%!*1024/10
set /a z=x+y
echo !z! >> speed.txt
)
set /a max=0
for /f "tokens=1,2" %%i in ('type "speed.txt"') do (
if %%i GEQ !max! set /a max=%%i
)
echo !anycast! ��ֵ�ٶ� !max! kB/s
if !max! GEQ !speed! cls&goto end
)

:end
set /a realbandwidth=max/128
set /a stopH=%time:~0,2%
if %time:~3,1% EQU 0 (set /a stopM=%time:~4,1%) else (set /a stopM=%time:~3,2%)
if %time:~6,1% EQU 0 (set /a stopS=%time:~7,1%) else (set /a stopS=%time:~6,2%)
set /a starttime=%startH%*3600+%startM%*60+%startS%
set /a stoptime=%stopH%*3600+%stopM%*60+%stopS%
if %starttime% GTR %stoptime% (set /a alltime=86400-%starttime%+%stoptime%) else (set /a alltime=%stoptime%-%starttime%)
curl --!ips! --resolve service.baipiao.eu.org:443:!anycast! --retry 3 -s -X POST https://service.baipiao.eu.org -o data.txt
for /f "tokens=2 delims==" %%i in ('findstr "publicip=" data.txt') do (
set publicip=%%i
)
for /f "tokens=2 delims==" %%i in ('findstr "colo=" data.txt') do (
set colo=%%i
)
echo ��ѡIP !anycast!
echo ����IP !publicip!
echo ������ AS!asn!
echo ��Ӫ�� !isp!
echo ��γ�� !longitude!,!latitude!
echo λ����Ϣ !city!,!region!,!country!
echo ���ÿ�� !bandwidth! Mbps
echo ʵ����� !realbandwidth! Mbps
echo ��ֵ�ٶ� !max! kB/s
echo �����ӳ� !avgms! ����
echo �������� !colo!
echo �ܼ���ʱ !alltime! ��
echo !anycast!>!ips!.txt
echo !anycast!|clip
del data.txt ip.txt CR.txt CRLF.txt cut.txt speed.txt meta.txt>nul 2>&1
RD /S /Q rtt>nul 2>&1
title ��ѡIP�Ѿ��Զ����Ƶ�������
echo ��������ر�
pause>nul
goto :eof