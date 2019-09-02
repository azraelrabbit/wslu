version="01"

help="wslcron --startup --service [service|command]"

startup=0
isService=0
name=""
nname=""

while [ "$1" != "" ]; do
	case "$1" in
		-s|--startup) startup=1;shift;;
		-S|--service) isService=1; shift;;
		-h|--help) help "$0" "$help_short"; exit;;
		-v|--version) echo "wslu v$wslu_version; wslusc v$version"; exit;;
		*) name="$*";break;;
	esac
done

if [[ "$name" != "" ]]; then
	tpath=$(double_dash_p "$(wslvar -s TMP)") # Windows Temp, Win Double Sty.
	script_location="$(wslpath "$(wslvar -s USERPROFILE)")/wslu" # Windows wslu, Linux WSL Sty.
	localfile_path="/usr/share/wslu" # WSL wslu source file location, Linux Sty.
	script_location_win="$(double_dash_p "$(wslvar -s USERPROFILE)")\\wslu" #  Windows wslu, Win Double Sty.

	# Check presence of runHidden.vbs 
	if [[ ! -f $script_location/runHidden.vbs ]]; then
		echo "${warn} runHidden.vbs not found in Windows directory. Copying right now..."
		[[ -d $script_location ]] || mkdir "$script_location"
		if [[ -f $localfile_path/runHidden.vbs ]]; then
			cp "$localfile_path"/runHidden.vbs "$script_location"
			echo "${info} runHidden.vbs copied. Located at \"$script_location\"."
		else
			echo "${error} runHidden.vbs not found. Failed to copy."
			exit 30
		fi
	fi

	if [[ $isService -eq 1 ]]; then
		nname="wsl.exe -d $WSL_DISTRO_NAME -u root service $name start"
	#else
	#	# TODO: handle normal command
	fi

	if [[ $startup -eq 1 ]]; then
		echo "Import-Module 'C:\\WINDOWS\\system32\\WindowsPowerShell\\v1.0\\Modules\\Microsoft.PowerShell.Utility\\Microsoft.PowerShell.Utility.psd1'; \$action = New-ScheduledTaskAction -Execute 'C:\\Windows\\System32\\wscript.exe'  -Argument '$script_location_win\\runHidden.vbs $nname'; \$trigger =  New-ScheduledTaskTrigger -AtLogOn -User \$env:userdomain\\\$env:username; \$task = New-ScheduledTask -Action \$action -Trigger \$trigger -Description Generated_By_WSL_Utilities; Register-ScheduledTask -InputObject \$task -TaskPath '\\' -TaskName 'WSL_Service_Startup_$name' -Force;" > "$(wslpath "$(wslvar -s TMP)")"/tmp.ps1
		winps_exec "$script_location_win"\\sudo.ps1 "$tpath"\\tmp.ps1
		rm "$(wslpath "$(wslvar -s TMP)")"/tmp.ps1
	#else
	#	TODO: not startup, more complicated rule.
	fi
#else:
#	TODO: not handled for now
fi