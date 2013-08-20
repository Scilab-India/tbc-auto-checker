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

# NOTE: scilab version 5.4.0 or higher is recommended.


# Set your scilab path here
SCI_PATH="/home/sachin/Downloads/scilab-5.4.0-beta-2/bin/scilab-adv-cli"
# set where to store graph images
SCI_GRAPH_PATH="${HOME}/Downloads/tbc_graphs"

echo "Hello $USER, Welcome to automatic code check for Scilab textbook companion."
echo "The Date & Time is:" `date`
echo ""

SAVEIFS=$IFS			# save value of IFS, if any
IFS=$(echo -en "\n\b\:\,")	# define Internal Field Seperator(for
				# directory names with spaces)

# cleaning
# Remove previous graphs
if [ -d "${SCI_GRAPH_PATH}" -a ! -h "${SCI_GRAPH_PATH}" ];
then
    rm -rvf "${SCI_GRAPH_PATH}"
else
    echo "No previous graphs found."
fi
rm -rvf *.log			# remove previous log files

function scan_sce_for_errors() {
    # Generate output log, error log of both text and graphical based output
    # also generate graphs(currently only plots graphs which has plot*(*) function)

    unzip $1			# unzip file
    wait
    ZIPFILE=$2			# this is extracted dir name

    # make a list of all .sce file(with complete path). Exclude
    # scanning 'DEPENDENCIES' DIR

    # That awk command says the field separator FS is set to /; this
    # affects the way it reads fields. The output field separator OFS
    # is set to "."; this affects the way it prints records. This is
    # intentionally done so that 'cut' will take "." as a field
    # Seperator during final sort operation. The next statement says
    # print the last column (NF is the number of fields in the record,
    # so it also happens to be the index of the last field) as well as
    # the whole record ($0 is the whole record); it will print them
    # with the OFS between them. Then the list is sorted, treating _
    # as the field separator - since we have the filename first in the
    # record, it will sort by that. Then the cut prints only fields 3
    # through the end, again treating "." as the field separator.

    SCE_FILE_LIST=$(find ${ZIPFILE} -type f -iname "*.sce" -o -iname "*.sci" ! \
	-path "*/DEPENDENCIES*" | \
	awk -vFS=/ -vOFS="." '{print $NF,$0}' | \
	sed 's/^[[:upper:]]*//g' | \
	sed 's/^[[:lower:]]*//g' | \
	sort -n -t _ -k1 -k2 | cut -d"." -f3-)
    SCE_FILE_COUNT=$(echo "${SCE_FILE_LIST}" | wc -l)
    echo -e "Total number of .sce files(without counting DEPENDENCIES directory): ${SCE_FILE_COUNT}\n" >> ./output_${ZIPFILE}.log 

    # make directory for storing graphs(each dir will be named after a book)
    mkdir -p ${SCI_GRAPH_PATH}/${ZIPFILE}

    for sce_file in ${SCE_FILE_LIST};
    do
	CAT_FILE=$(egrep -r "plot\S[0-9]?[d]?[0-9]?[(]*[)]*" ${sce_file})
        #echo ${CAT_FILE}
	if [ -z "${CAT_FILE}" ];
	then
	    BASE_FILE_NAME=$(basename ${sce_file} .sce)
	    echo "--------- Text output file --------------"
            echo "------------- ${sce_file}  --------------"
	    echo "" >> ${sce_file}
	    echo "exit();" >> ${sce_file} 
	    sed -i '1s/^/mode(2);/' ${sce_file}
	    sed -i '1s/^/errcatch(-1,"stop");/' ${sce_file}
	    sed -i 's/xdel(winsid());//g' ${sce_file}
	    sed -i 's/clc()//g' ${sce_file}
	    sed -i 's/close;//g' ${sce_file}
	    # run command
            OUTPUT=` timeout 5 ${SCI_PATH} -nb -nwni -f ${sce_file}`
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
	    echo "-------- Graph file -----------"
	    echo "--------${sce_file}------------"
	    echo "" >> ${sce_file}
	    BASE_FILE_NAME=$(basename ${sce_file} .sce)
            # change path for storing graph image file
	    echo "xinit('${SCI_GRAPH_PATH}/${ZIPFILE}/${BASE_FILE_NAME}');xend();exit();" >> ${sce_file} 
	    sed -i '1s/^/mode(2);errcatch(-1,"stop");driver("GIF");/' ${sce_file}
	    sed -i 's/xdel(winsid());//g' ${sce_file}
	    sed -i 's/clc()//g' ${sce_file}
	    sed -i 's/close;//g' ${sce_file}	
	    # run command
	    OUTPUT=`timeout 5 ${SCI_PATH} -nb -nogui -f ${sce_file}`
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
if [ ! -z "$(find . -type f -iname '*.zip')" ];
then
    ZIP_FILE_LIST=$(ls -1 *.zip) 
    for ZIP_FILE in ${ZIP_FILE_LIST}:
    do
        # loop through the list
	remove_previous_dirs_and_unzip "${ZIP_FILE}"
    done
else
    echo "This Directory does not contains any ZIP files"
    echo "Please copy ZIP file(s) inside this directory."
    exit 1
fi

IFS=$SAVEIFS			# restore value of IFS

#----end of auto.sh----#

