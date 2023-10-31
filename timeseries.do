

*** specify a path for tmp files

global hhdta "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\WorldBank\hhdta"
global tmp "C:\Users\Mahofa"
global lisd "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\WorldBank\lisd"
global proc "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\WorldBank\proc"
global output "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\WorldBank\output"

use  "$proc\newparcel_to_cnstct", clear
order province_cd vill_code interview__id newproster__id s3q10, before(s1q2)
drop newparcelid
egen newpid = group(interview__id newproster__id)
order newpid, before(s3q10)
ren s3q10 year
format year %6.0f
save tmp10, replace
collapse (sum) registered not_reg market inheritance other,by(vill_code year)
g acquired = registered + not_reg
save "$proc\village_year", replace
collapse (sum) registered not_reg market inheritance other acquired,by(year)
save "$proc\year", replace
***

use "$proc\parc_sold", clear
encode village_cd, g(village)
drop village_cd
order village, before(s4q7)
ren village village_cd
keep if s4q11f >= 2013&s4q11f!=.
drop if s4q11f == .a
keep village_cd s4q11f sold-other
ren s4q11f year
format year %6.0f
collapse (sum) sold-other, by(village_cd year)
ren other other_1
g disposed = sold + bequethed + other_1
so year
save "$proc\vill_disposed", replace
collapse (sum) sold-other_1 disposed, by(year)
save "$proc\year_disposed", replace
mer 1:1 year using "$proc\year" /* combining acquired and disposed parcels*/
drop _mer
g year_dis = year

order year disposed sold bequethed other_1, after(year_dis)
order year acquired, before(registered)
lab var year "year acquired"
lab var acquired "total acquired"
lab var registered "registered"
lab var not_reg "not registered"
lab var market "market transaction"
lab var inheritance "inheritance transaction"
lab var other "other transaction"
lab var year_dis "year of disposal"
lab var disposed "total parcels disposed"
lab var sold "sold"
lab var bequethed "bequethed"
lab var other_1 "other"
save "$proc\acqd_dis", replace
****

*To check whether parcels disposed were acquired within the 2013-2018 period
*Merge the parcel sold and acquired roster
use "$proc\newparcel_to_cnstct", clear
order province_cd vill_code interview__id newproster__id s3q10, before(s1q2)
drop newparcelid
drop if upi == ""
drop if upi == "##N/A##"
so upi
save "$proc\newparcel_to_", replace
use "$proc\parc_sold", clear
drop if upi == ""
drop if upi == "##N/A##"
ren other other_1
so upi
mer m:m upi using "$proc\newparcel_to_"
keep if _mer == 3
drop _mer
keep  registered not_reg market inheritance other sold bequethed other_1 s3q10 s4q11f
drop if s4q11f == .a
order s3q10 s4q11f, before(sold)
so s3q10
drop if s3q10>s4q11f
order sold bequethed other_1, after(registered)
collapse (sum) market-other_1, by(s3q10 s4q11f)
g acquired = not_reg + registered 
g disposed = sold + bequethed + other_1
order acquired, before(market)
order disposed, before(sold)
ren s3q10 yr_acquired
ren s4q11f yr_disposed
format yr_acquired %6.0f
format yr_disposed %6.0f
lab var acquired "total acquired"
lab var registered "registered"
lab var not_reg "not registered"
lab var market "market transaction"
lab var inheritance "inheritance transaction"
lab var other "other transaction"
lab var disposed "total parcels disposed"
lab var sold "sold"
lab var bequethed "bequethed"
lab var other_1 "other"
save "$proc\disposed13_18", replace
*********

*Household land ownership
use "$proc\oldown2013", clear
collapse (sum) area, by(interview__id)
so interview__id
save tmp11, replace
use tmp10, clear
keep if year == 2013
collapse (sum) area, by(interview__id)
ren area area2013
so interview__id
mer 1:1 interview__id using tmp11
drop _mer
for var area2013 area: replace X = 0 if X == .
save tmp12, replace
use "$proc\parc_sold", clear
keep interview__id area_sold s4q11f
keep if s4q11f == 2013
collapse (sum) area_sold, by(interview__id)
so interview__id
save tmp13, replace
***
use tmp12, clear
mer 1:1 interview__id using tmp13
drop if _mer == 2
drop _mer
replace area_sold = 0  if area_sold == .

g land = area2013 + area - area_sold
drop if land <0
keep interview__id land
save tmp14, replace
****
*2018 land ownership
use tmp10, clear
drop if year == 2013
collapse (sum) area, by(interview__id)
so interview__id
save tmp15, replace
****
use "$proc\parc_sold", clear
keep interview__id area_sold s4q11f
drop if s4q11f <=2013
collapse (sum) area_sold, by(interview__id)
so interview__id
save tmp16, replace
****
use tmp14, clear
mer 1:1 interview__id using tmp15
drop _mer
mer 1:1 interview__id using tmp16
drop if _mer == 2
drop _mer
for var land area area_sold: replace X = 0 if X == .
g land2018 = land + area - area_sold
keep interview__id land land2018
replace land2018 = 0 if land2018 < 0
ren land land2013
save "$proc\hhdland", replace

reshape long land, i(interview__id) j(year)
lorenz estimate land, over(year) gini
lorenz graph, aspectratio(1) overlay








