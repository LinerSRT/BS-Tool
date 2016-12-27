#!/bin/bash
export curdate=`date "+_%H:%M"`
#Variables
OUT_DIR="out"
source initialization.bsf
config_script(){
if [ ! -f initialization.bsf ]
  then
    whiptail --title "BS Tool" --msgbox "Config file not found! Re-config...." 10 60
    touch initialization.bsf
    echo "#!/bin/bash" > initialization.bsf
	#Setting CROSS_COMPILE
	if [ -z $CROSS_COMPILE ]
		then
			CROSS_COMPILE=$(whiptail --title "BS Tool" --inputbox "Edit path to cross-compiler tool." 10 60 3>&1 1>&2 2>&3)
  			read CROSS_COMPILE
			echo "CROSS_COMPILE='$CROSS_COMPILE'" >> initialization.bsf
		else
  			echo "CROSS_COMPILE='$CROSS_COMPILE'" >> initialization.bsf
	fi 

	#Getting kernel source version
	PATCHLEVEL=$(grep -oP 'PATCHLEVEL = \K.*'  kernel/Makefile)
	SUBLEVEL=$(grep -oP 'SUBLEVEL = \K.*'  kernel/Makefile)
	if [ -z $PATCHLEVEL ]
		then
		PATCHLEVEL=$(grep -oP 'PATCHLEVEL = \K.*'  Makefile)
		SUBLEVEL=$(grep -oP 'SUBLEVEL = \K.*'  Makefile)
	fi
	echo "KRN_VER='3.$PATCHLEVEL.$SUBLEVEL'" >> initialization.bsf

	#Setting project name
	PJ_NAME=$(whiptail --title "BS Tool" --inputbox "Set project name" 10 60 3>&1 1>&2 2>&3)
	echo "PROJECT_NAME='$PJ_NAME'" >> initialization.bsf

	#Getting number of cores
	N_CORES=$(grep -c ^processor /proc/cpuinfo)
	echo "NUMBER_OF_CORES='$N_CORES'" >> initialization.bsf
	
	#PATH's
	if [ "$PATCHLEVEL" -eq "4" ]
	 then
		KERN_IMG=$OUT_DIR/target/product/$PJ_NAME/obj/KERNEL_OBJ/arch/arm/boot/zImage
		mkdir $OUT_DIR/kernel
	 else
		mkdir $OUT_DIR/kernel
		KERN_IMG=/arch/arm/boot/zImage
	fi
	echo "KERN_IMG='$KERN_IMG'" >> initialization.bsf
	echo "KERN_FOLDER='$OUT_DIR/kernel'" >> initialization.bsf
	mkdir $OUT_DIR/logs
	
	#Configuring script
	if(whiptail --title  "BS Tool" --yesno  "Download BS Tool recommended cross-compile tool?" 10 60)
	then
		echo "USE_OTHER_CROSS_COMPILER='yes'" >> initialization.bsf
	else
		echo "USE_OTHER_CROSS_COMPILER='no'" >> initialization.bsf
	fi

	if(whiptail --title  "BS Tool" --yesno  "Use BS Boot-packer?" 10 60)
	then
		echo "USE_BOOT_PACK='yes'" >> initialization.bsf
	else
		echo "USE_BOOT_PACK='no'" >> initialization.bsf
	fi
	
	if(whiptail --title  "BS Tool" --yesno  "Pack boot.img or recovery.img after successful build?" 10 60)
	then
		echo "PACK_IMG_AFTER_BUILD='yes'" >> initialization.bsf
	else
		echo "PACK_IMG_AFTER_BUILD='no'" >> initialization.bsf
	fi

	if(whiptail --title  "BS Tool" --yesno  "Open kernel.log after fail compilation?" 10 60)
	then
		echo "FAIL_LOG='yes'" >> initialization.bsf
	else
		echo "FAIL_LOG='no'" >> initialization.bsf
	fi

	if(whiptail --title  "BS Tool" --yesno  "Download packages for compiling?" 10 60)
	then
		echo "ADD_PKG='yes'" >> initialization.bsf
	else
		echo "ADD_PKG='no'" >> initialization.bsf
	fi

	if(whiptail --title  "BS Tool" --yesno  "Store debuging logs in $OUT_DIR folder (logcat, dmesg and etc.)?" 10 60)
	then
		echo "STORE_LOG_DB='yes'" >> initialization.bsf
	else
		echo "STORE_LOG_DB='no'" >> initialization.bsf
	fi
 fi
main_menu
}
{
    for ((i = 0 ; i <= 100 ; i+=20)); do
        sleep 0.15
        echo $i
    done
} | whiptail --gauge "Loading..." 6 60 0
#-----------------------Functions---------------------------------------
get_logcat(){
	read LOGCAT < <(adb logcat)
	cd $OUT_DIR/logs
	echo $LOGCAT >> logcat-$curdate.txt
	 cd .. && cd ..
	 whiptail --title "BS Tool" --msgbox "Log saved to $OUT_DIR/logs" 10 60
	log_menu
}
get_dmesg(){
	read DMESG < <(adb shell su -c dmesg)
	cd $OUT_DIR/logs
	echo $DMESG >> dmesg-$curdate.txt
	 cd .. && cd ..
	 whiptail --title "BS Tool" --msgbox "Log saved to $OUT_DIR/logs" 10 60
	log_menu
}
get_kmsg(){
	read KMSG < <(adb shell su -c cat proc/kmsg)
	cd $OUT_DIR/logs
	echo $KMSG >> kmsg-$curdate.txt
	 cd .. && cd ..
	 whiptail --title "BS Tool" --msgbox "Log saved to $OUT_DIR/logs" 10 60
	log_menu
}
get_device_info(){
	whiptail --title "BS Tool" --msgbox "Power on the phone and turn on debug mode in developer settings!" 10 60
	sleep 0.3s
	read CPU_PHONE < <(adb shell cat proc/cpuinfo | grep -o "MT[0-9][0-9][0-9][0-9]")
	read RAM_PHONE_KB < <(adb shell cat proc/meminfo | grep MemTotal | grep -o "[0-9]*")
	read KERN_VER_PHONE < <(adb shell cat proc/version | grep -o "3\.[0-9]*\.[0-9]*")
	read MANUFACTURER < <(adb shell cat system/build.prop | grep -oEi "manufacturer=[a-z]*")
	echo "CPU_PHONE='$CPU_PHONE'" >> initialization.bsf
	echo "RAM_PHONE_KB='$RAM_PHONE_KB'" >> initialization.bsf
	echo "KERN_VER_PHONE='$KERN_VER_PHONE'" >> initialization.bsf
	echo "MANUFACTURER='$MANUFACTURER'" >> initialization.bsf
}
#-----------------------MENU Construct----------------------------------
remount_sys(){

}
log_menu(){
LOG_MENU=$(whiptail --title  "BS Tool" --menu  "	" 10 60 4 \
"1" "Get logcat" \
"2" "Get dmesg" \
"3" "Get kmsg or lastkmsg" \
"4" "Back"  3>&1 1>&2 2>&3)

if [ $LOG_MENU -eq "4" ]
	then
	debug_menu
fi
if [ $LOG_MENU -eq "1" ]
	then
	get_logcat
fi
if [ $LOG_MENU -eq "2" ]
	then
	get_dmesg
fi
if [ $LOG_MENU -eq "3" ]
	then
	get_kmsg
fi
}

reboot_menu(){
REBOOT_MENU=$(whiptail --title  "BS Tool" --menu  "	" 10 60 4 \
"1" "Reboot to fastboot" \
"2" "Reboot to recovery" \
"3" "Reboot to system" \
"4" "Back"  3>&1 1>&2 2>&3)

if [ $REBOOT_MENU -eq "4" ]
	then
	debug_menu
fi
if [ $REBOOT_MENU -eq "1" ]
	then
	adb reboot fastboot
	sleep 1s
fi
if [ $REBOOT_MENU -eq "2" ]
	then
	adb reboot recovery
	sleep 1s
fi
if [ $REBOOT_MENU -eq "3" ]
	then
	adb reboot
	sleep 1s
fi
}

debug_menu(){
DEBUG_MENU=$(whiptail --title  "BS Tool" --menu  "	" 10 60 4 \
"1" "Get log's" \
"2" "Get device info" \
"3" "Reboot menu" \
"4" "Back"  3>&1 1>&2 2>&3)

if [ $DEBUG_MENU -eq "4" ]
	then
	main_finctions
fi
if [ $DEBUG_MENU -eq "1" ]
	then
	log_menu
fi
if [ $DEBUG_MENU -eq "2" ]
	then
	get_device_info
	debug_menu
fi
}

compile_menu(){
COMPILE_MENU=$(whiptail --title  "BS Tool" --menu  "	" 10 60 4 \
"1" "Compile new kernel" \
"2" "Re-compile kernel" \
"3" "Clean out directory" \
"4" "Back"  3>&1 1>&2 2>&3)

if [ $COMPILE_MENU -eq "4" ]
	then
	main_finctions
fi
if [ $COMPILE_MENU -eq "4" ]
	then
	main_finctions
fi
}

flash_menu(){
FLASH_MENU=$(whiptail --title  "BS Tool" --menu  "	" 10 60 4 \
"1" "Flash boot/recovery from fastboot" \
"2" "Flash boot/recovery from recovery (BETA)" \
"3" "Back"  3>&1 1>&2 2>&3)

if [ $FLASH_MENU -eq "3" ]
	then
	main_finctions
fi
if [ $FLASH_MENU -eq "4" ]
	then
	main_finctions
fi
}

main_finctions(){
MAIN_FUNC=$(whiptail --title  "BS Tool" --menu  "	" 10 60 4 \
"1" "Compiling" \
"2" "Debuging" \
"3" "Flashing" \
"4" "Back"  3>&1 1>&2 2>&3)

if [ $MAIN_FUNC -eq "4" ]
	then
	main_menu
fi
if [ $MAIN_FUNC -eq "1" ]
	then
	compile_menu
fi
if [ $MAIN_FUNC -eq "2" ]
	then
	debug_menu
fi
if [ $MAIN_FUNC -eq "3" ]
	then
	flash_menu
fi

}

settigs_menu(){
SETTINGS_MENU=$(whiptail --title  "BS Tool" --menu  "	" 10 60 4 \
"1" "Download BS Boot-packer add-on manual " \
"2" "Re-config script" \
"3" "Back"  3>&1 1>&2 2>&3)
if [ $SETTINGS_MENU -eq "3" ]
	then
	main_menu
fi
if [ $SETTINGS_MENU -eq "2" ]
	then
	rm -rf initialization.bsf
	rm -rf $OUT_DIR/kernel
	rm -rf $OUT_DIR/logs
	config_script
fi
if [ $SETTINGS_MENU -eq "1" ]
	then
	download_packer
fi
}

main_menu(){
MAIN_MENU=$(whiptail --title  "BS Tool" --menu  "BS Tool - the script is designed to simplify compiling kernels for Mediatek based chip. It has a simple and intuitive interface, additional functions. Automatic adjustment at the first start. The functions will be updated over time as well as add new ones.
-----------------------------------------------------" 18 60 4 \
"1" "Main functions" \
"2" "Settings" \
"3" "About" \
"4" "Exit"  3>&1 1>&2 2>&3)

if [ $MAIN_MENU -eq "1" ] 
	then
	main_finctions
fi
if [ $MAIN_MENU -eq "2" ] 
	then
	settigs_menu
fi
if [ $MAIN_MENU -eq "3" ] 
	then
	whiptail --title "BS Tool" --msgbox "Created by SeriniTY(c). All rights reserved. Smart Rom Team" 7 64
	main_menu
fi
if [ $MAIN_MENU -eq "4" ] 
	then
	clear
	exit
fi
}
#Script body
main_menu
