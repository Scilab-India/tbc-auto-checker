#!/usr/bin/env python3
"""
display_density.py

Original author: Sachin Patil(isachin@iitb.ac.in)

This file is part of tbc-auto-checker.
tbc-auto-checker is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.
tbc-auto-checker is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with tbc-auto-checker.  If not, see <http://www.gnu.org/licenses/>.

NOTE: Python version 3 or higher is recommended.

Script to scan .sci and .sce files and displays percentage of lines
having function disp() and/or printf(). Run the script using:

./display_density.py

It should print filenames with percentage which is equal-to or exceeds LIMIT.
The default log file(density.log) has detail information of line counts

Usage:
1. Unzip the .zip file(s)
2. Set the directory to scan, by default the script will scan all directories in
   present directory
3. Set the percentage limit in variable PERCENTAGE_LIMIT
4. Optionally you can set the log file name
"""
import fnmatch, re
import os

# Give directory name to scan OR dot(.) to scan all directories in
# present directory
DIR="."                      
FILE_EXTN=['sce','sci']         # file extension without dot
LOG_FILE="density.log"          # log file name
PERCENTAGE_LIMIT=40             # upper limit in percentage

def calculate_percentage(file_list, PERCENTAGE_LIMIT):
    """Calculate percentage of lines with function disp() & printf()
    
    Arguments:
    - `file_list`: list of file with full path
    - `PERCENTAGE_LIMIT`: set upper limit percentage
    """
    for each_file in file_list:
        # print(each_file)
        read_file = open(each_file).readlines()
        line_count, disp_count = 0, 0
        for line in read_file:
            disp = re.search("(disp[()])|(printf[()])",line)
            if disp:
                # print(disp.group())
                disp_count += 1
            line_count += 1
        
        f = open(LOG_FILE,"a+")
        f.write("\n"+each_file+"\n====================")
        f.write("\nTotal lines: %d" %(line_count))
        f.write("\nLines with disp()/printf(): %d" % (disp_count))
        percentage=((disp_count/line_count)*100)
        if ((disp_count/line_count)*100) >= PERCENTAGE_LIMIT:
            print("Percentage: %.2f %%, file: %s"% (percentage, each_file))
            f.write("\nWARNING!! Percentage: %.2f %%\n\n" % (percentage))
        else:
            f.write("\nPercentage: %.2f %%\n\n" % (percentage))
        f.close()


def scan_files(DIR, FILE_EXTN):
    """Scan directory for given file extension(s)
    
    Arguments:
    - `DIR`: directory to scan
    - `FILE_EXTN`: list of file extension
    """
    match=[]
    for root, dirnames, filenames in os.walk(DIR):
        for filename in fnmatch.filter(filenames, '*'): # match everything
            extn = os.path.splitext(filename)[1].strip('.') # strip out extension
            if extn in FILE_EXTN: # filter out selected extensions
                match.append(os.path.join(root, filename)) # append it to a list
            else:
                pass
    match.sort()
    return match

if __name__ == "__main__":
    if os.path.exists(LOG_FILE):
        os.remove(LOG_FILE)

    calculate_percentage(scan_files(DIR, FILE_EXTN), PERCENTAGE_LIMIT)

