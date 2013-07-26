#!/usr/bin/env bash
# Auto checker script for Scilab Textbook Companion
# http://scilab.in/Textbook_Companion_Project

# Original author: Lavitha Pereira

# This file is part of tbc-auto-checker.
# tbc-auto-checker is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# tbc-auto-checker is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with tbc-auto-checker.  If not, see <http://www.gnu.org/licenses/>.

# IMPORTANT:Please modify variable `OUTPUT` according to your scilab path
# NOTE: scilab version 5.4.0 or higher is recommended.

echo "Hello $USER, Welcome to automatic CODE CHECK"
echo "The Date & Time is:" `date`


read -p "Enter the name of zip file : " ZIPFILE
rm -rvf ${ZIPFILE}
if [ -e ${ZIPFILE}.zip ]; 
then
    unzip ${ZIPFILE}.zip
else
    echo "${ZIPFILE}.zip does not exist!!"
    exit 1
fi
SCE_FILE_LIST=$(find ${ZIPFILE} -type f -iname "*.sce")
echo ${SCE_FILE_LIST}

rm -rvf temp
rm -rvf error*.log
rm -rvf error_graph*.log
rm -rvf output*.log
rm -rvf output_graph*.log

mkdir temp


for sce_file in ${SCE_FILE_LIST};
do
    CAT_FILE=$(grep "plot" ${sce_file})
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
	OUTPUT=`scilab-adv-cli -nb -nwni -f ${sce_file}`
	echo $OUTPUT
	if [[ "${OUTPUT}" =~ "!--error" ]];
        then
	    echo "ERROR: ${sce_file}" >> ./error.log
	    echo "${OUTPUT}" >> ./error.log
	else
	    echo "#################${sce_file}#####################" >> ./output.log
	    echo "${OUTPUT}" >> ./output.log
	fi
	unset OUTPUT
	unset BASE_FILE_NAME
    else
	echo "Graph file"
	echo "--------${sce_file}------------"
        echo "-------------------------------"
	echo "" >> ${sce_file}
	BASE_FILE_NAME=$(basename ${sce_file} .sce)
	# change path
	echo "xinit('${HOME}/Downloads/temp/${BASE_FILE_NAME}');xend();exit();" >> ${sce_file} 
	sed -i '1s/^/mode(2);errcatch(-1,"stop");driver("GIF");/' ${sce_file}
	sed -i 's/clc()//g' ${sce_file}	
	
	OUTPUT=`scilab-adv-cli -nb -nogui -f ${sce_file}`
	echo ${OUTPUT}
	if [[ "${OUTPUT}" =~ "error" ]];
        then
	    echo "#############ERROR: ${sce_file}##################" >> ./error_graph.log
	    echo "${OUTPUT}" >> ./error_graph.log
	else
	    echo "###################### ${sce_file}###################" >> ./output_graph.log
	    echo "${OUTPUT}" >> ./output_graph.log
	fi
	unset OUTPUT
	unset BASE_FILE_NAME
    fi
done


#---End of code----#

