# ERP Bulk Attendance Upload from txt file
The erp.py script can upload the bulk attendances of students for multiple dates mentioned in date_loader.txt to the ERP system with a single click. This program requires the selenium and webdriver_manager packages. This version of code can handle multiple classes in single date. To install selenium, you need to write:
```
pip3 install selenium
pip3 install webdriver_manager
```
The program is tested with <b>python 3.9.6</b>, <b>selenium 4.25.0</b> & <b>webdriver_manager 4.0.2</b>
This repository has two files: (1) date_loader.txt and (2)erp.py
## Steps
The execution is involved with two steps: (1) Writing date_loader.txt in proper format(2) Run erp.py script with required command line arguments.
### 1. Write date_loader.txt
You need to make a date_loader.txt file which must have 4 columns in each rows. The 1st column stores the date, 2nd column stores the time of the class, 3rd column stores the student attendance status ('P'/'A') and finaly the 4th column should be the serial number of the students. <b>Please be carefull, date_loader.txt must not have any empty lines</b>
```
15/10/2024; 08:0 AM-09:0 AM; P; 1, 3, 5, 7
15/10/2024; 11:0 AM-12:0 AM; A; 2, 4, 6, 7
17/10/2024; 08:0 AM-09:0 AM; P; 1, 3, 5, 7, 22
```
In this above example, the students of serial number 1, 3, 5, 7 were present on date: 15/10/2024.<br>
Similarly, the students of serial number 2, 4, 6, 7 were absent on 18/10/2024.<br>
If you have just one class in a day, you can keep the 2nd column (time) blank like below:
```
15/10/2024; ; P; 1, 3, 5, 7
16/10/2024; ; A; 2, 4, 6, 7
17/10/2024; ; P; 1, 3, 5, 7, 22
```
<b>It is to be noted that the format of 1st column (dates) and format of 2nd column (time) should be maintained as per the ERP format</b>
### 2. run erp.py script
The erp.py required 5 command line argumenrs
```
 python3 erp.py -u username -p password -sm semester -sb subject -hl headless
```
For an example username: 123456789, password=password, semester='ODD SEM 2024 - ITER' and subject='CSE3156/Digital Forensics Workshop'. The 5th command -hl headless is to run the program in headless mode (Chorme will run in backgrounnd). Please check the semester and subjects from details from your ERP login->webkisok(side bar)->>webkisok->select institurte->acamdemic info->student attendance-> dropdowns.

If you want to run the chorme in headless mode you need to write
```
 python3 erp.py -u 123456789 -p password -sm 'ODD SEM 2024 - ITER' -sb 'CSE3156/Digital Forensics Workshop' -hl headless
 python3 erp.py -u 123456789 -p password -sm 'EVEN SEM 2025 - ITER' -sb 'CSE3157/Penetration Testing Workshop' -hl headless
```
if you want to run with Chrome Gui
```
 python3 erp.py -u 123456789 -p password -sm 'ODD SEM 2024 - ITER' -sb 'CSE3156/Digital Forensics Workshop'
```
<b>Feel free to contact me rourabpaul@soa.ac.in</b>

