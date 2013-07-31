# tbc-auto-checker
### Auto checker script for Scilab Textbook Companion.

### Usage

* Clone this repository 

```bash
git clone https://github.com/Scilab-India/tbc-auto-checker.git
```

* Change path to this directory

```bash
cd tbc-auto-checker
```

* Place ZIP file(s) of book(s) in this directory and run the script

```bash
bash auto.sh
```

### Output

* The output log files and error log files will be generated
separately.

#### text output

* Text output will be stored in `output_<book-name>.log` file.

#### graph output

* You have to set a variable `SCI_GRAPH_PATH` to a path where you want
all the graphs to be stored.

* Graphs with text output will be stored in
  `output_graph_<book-name>.log` file
  
#### errors

* **for text based errors**: `error_<book-name>.log`

* **for graph based errors**: `error_graph_<book-name>.log`

#### Warning

* All output are first stored in a variable and then written to
  respective files. You may run out of memory sometimes.

#### Site

Please visit
[http://scilab.in/Textbook_Companion_Project](http://scilab.in/Textbook_Companion_Project)
for more info.

