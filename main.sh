#!/bin/bash
#Variables
OUT_DIR="out"
source initialization.bsf
download_packer(){
	echo "download" #EDIT THISSS!!!!! 
}
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
	
	#Configuring script
	if(whiptail --title  "BS Tool" --yesno  "Download BS Tool recommended cross-compile tool?" 10 60)
	then
		echo "USE_OTHER_CROSS_COMPILER='yes'" >> initialization.bsf
		echo "download" #EDIT THISSS!!!!!
	else
		echo "USE_OTHER_CROSS_COMPILER='no'" >> initialization.bsf
	fi

	if(whiptail --title  "BS Tool" --yesno  "Use BS Boot-packer?" 10 60)
	then
		echo "USE_BOOT_PACK='yes'" >> initialization.bsf
		download_packer(){
			echo "download" #EDIT THISSS!!!!! 
		}
		download_packer
	else
		echo "USE_BOOT_PACK='no'" >> initialization.bsf
	fi
	
	if(whiptail --title  "BS Tool" --yesno  "Pack boot.img or recovery.img after successful build?" 10 60)
	then
		echo "PACK_IMG_AFTER_BUILD='yes'" >> initialization.bsf
	else
		echo "PACK_IMG_AFTER_BUILD='no'" >> initialization.bsf
	fi
 fi
}
{
    for ((i = 0 ; i <= 100 ; i+=20)); do
        sleep 0.15
        echo $i
    done
} | whiptail --gauge "Loading..." 6 60 0

settigs_menu(){
SETTINGS_MENU=$(whiptail --title  "BS Tool" --menu  "	" 10 60 4 \
"1" "Show device info" \
"2" "Download BS Boot-packer add-on " \
"3" "Re-config script" \
"4" "Back"  3>&1 1>&2 2>&3)
if [ $SETTINGS_MENU -eq "4" ]
	then
	main_menu
fi
if [ $SETTINGS_MENU -eq "3" ]
	then
	rm -rf initialization.bsf
	rm -rf $OUT_DIR/kernel
	config_script
fi
if [ $SETTINGS_MENU -eq "2" ]
	then
	download_packer
fi
if [ $SETTINGS_MENU -eq "1" ]
	then
	whiptail --title "BS Tool" --msgbox "Kernel version: $KRN_VER
Device platform: testing" 10 60
	main_menu
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
fi
if [ $MAIN_MENU -eq "4" ] 
	then
	clear
	exit
fi
}
main_menu
