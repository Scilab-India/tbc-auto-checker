#!/usr/bin/env bash
# Auto checker script for Scilab Textbook Companion
# http://scilab.in/Textbook_Companion_Project

# Original author: Lavitha Pereira

# This file is part of tbc-auto-checker.
# tbc-auto-checker is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# tbc-auto-checker is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with tbc-auto-checker.  If not, see <http://www.gnu.org/licenses/>.

# IMPORTANT:Please modify variable `OUTPUT` according to your scilab path
# NOTE: scilab version 5.4.0 or higher is recommended.


# SET YOUR SCILAB PATH HERE
SCI_PATH="/home/sachin/Downloads/scilab-5.4.0-beta-2/bin/scilab-adv-cli"


echo "Hello $USER, Welcome to automatic code check for Scilab textbook companion."
echo "The Date & Time is:" `date`
echo ""

SAVEIFS=$IFS			# save value of IFS, if any
IFS=$(echo -en "\n\b\:\,")	# define Internal Field Seperator(for
				# directory names with spaces)

# cleaning
rm -rvf ${HOME}/Downloads/tbc_graphs
rm -rvf *.log

function scan_sce_for_errors() {
    # Generate output log, error log of both text and graphical based output
    # also generate graphs(currently only plots graphs which has plot*(*) function)

    unzip $1			# unzip file
    wait
    ZIPFILE=$2			# this is extracted dir name

    # make a list of all .sce file(with complete path). Exclude
    # scanning 'DEPENDENCIES' DIR
    SCE_FILE_LIST=$(find ${ZIPFILE} -type f -iname "*.sce" ! -path "*/DEPENDENCIES*")

    # make directory for storing graphs(each dir will be named after a book)
    mkdir -p ${HOME}/Downloads/tbc_graphs/${ZIPFILE}

    for sce_file in ${SCE_FILE_LIST};
    do
	CAT_FILE=$(egrep -r "plot\S[0-9]?[d]?[0-9]?[(]*[)]*" ${sce_file})
        #echo ${CAT_FILE}
	if [ -z "${CAT_FILE}" ];
	then
	    BASE_FILE_NAME=$(basename ${sce_file} .sce)
	    echo "Plain file"
	    echo "-------------------------------"
            echo "--------${sce_file}------------"
	    echo "" >> ${sce_file}
	    echo "exit();" >> ${sce_file} 
	    sed -i '1s/^/mode(2);/' ${sce_file}
	    sed -i '1s/^/errcatch(-1,"stop");/' ${sce_file}
	    sed -i 's/clc()//g' ${sce_file}
	    sed -i 's/close;//g' ${sce_file}
	    # run command
            OUTPUT=`${SCI_PATH} -nb -nwni -f ${sce_file}`
	    echo $OUTPUT
	    if [[ "${OUTPUT}" =~ "!--error" ]];
            then
		echo "ERROR: ${sce_file}" >> ./error_${ZIPFILE}.log
		echo "${OUTPUT}" >> ./error_${ZIPFILE}.log
	    else
		echo "################# ${sce_file} #####################" >> ./output_${ZIPFILE}.log
		echo "${OUTPUT}" >> ./output_${ZIPFILE}.log
	    fi
	    unset OUTPUT
	    unset BASE_FILE_NAME
	else
	    echo "Graph file"
	    echo "--------${sce_file}------------"
            echo "-------------------------------"
	    echo "" >> ${sce_file}
	    BASE_FILE_NAME=$(basename ${sce_file} .sce)
            # change path for storing graph image file
	    echo "xinit('${HOME}/Downloads/tbc_graphs/${ZIPFILE}/${BASE_FILE_NAME}');xend();exit();" >> ${sce_file} 
	    sed -i '1s/^/mode(2);errcatch(-1,"stop");driver("GIF");/' ${sce_file}
	    sed -i 's/clc()//g' ${sce_file}
	    sed -i 's/close;//g' ${sce_file}	
	    # run command
	    OUTPUT=`${SCI_PATH} -nb -nogui -f ${sce_file}`
	    echo ${OUTPUT}
	    if [[ "${OUTPUT}" =~ "error" ]];
            then
		echo "ERROR: ${sce_file}" >> ./error_graph_${ZIPFILE}.log
		echo "${OUTPUT}" >> ./error_graph_${ZIPFILE}.log
	    else
		echo "###################### ${sce_file} ###################" >> ./output_graph_${ZIPFILE}.log
		echo "${OUTPUT}" >> ./output_graph_${ZIPFILE}.log
	    fi
	    unset OUTPUT
	    unset BASE_FILE_NAME
	fi
    done
}

function remove_previous_dirs_and_unzip(){
    # remove any previous directories and unzip files

    # echo $1 exist
    ZIP_DIR=$(basename $1 .zip)
    # echo ${ZIP_DIR}
    if [ -d "${ZIP_DIR}" -a ! -h "${ZIP_DIR}" ]; 
    # file is a directory(true) and is not a symbolic link
    then
	# echo ${ZIP_DIR}
	rm -rvf "${ZIP_DIR}"
	wait
	scan_sce_for_errors "$1" "${ZIP_DIR}" # call function to generate output
    else
	echo Directory: "${ZIP_DIR}" does not exist!!
	scan_sce_for_errors "$1" "${ZIP_DIR}" # call function to generate output
    fi
}

# make a list of .zip files
ZIP_FILE_LIST=$(ls -1 *.zip)
for ZIP_FILE in ${ZIP_FILE_LIST}:
do
    # loop through the list
    remove_previous_dirs_and_unzip "${ZIP_FILE}"
done

IFS=$SAVEIFS			# restore value of IFS

#----end of auto.sh----#

