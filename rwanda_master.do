clear
set more off
cap log close

global code 	"\code\"
global data 	"\data\"
global rawdata 	"\rawdata\"
global output	"\output\"
global temp 	"\temp\"

do "..\code\rwanda_create.do"
do "..\code\rwanda_summary.do"
