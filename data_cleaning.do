
** data cleaning 

cd "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\WorldBank\data"


global hh "U:\AFR\Rwanda\Transaction\Data\HH"
global ls "U:\AFR\Rwanda\Transaction\Data\Listing"
global tmp "U:\AFR\Rwanda\Transaction\Data\Temp"

*************** listing data


use $ls\01032019\Rwanda_Listing_2018, clear

drop if province==1

g down = s2q1==1 if s2q1!=.
g daq2013 = s2q2==1 if s2q2!=.
g dgve2013 = s2q3==1 if s2q3!=.
g drntout = s2q4==1 if s2q4!=.
g drntin = s2q5==1 if s2q5!=.
g dmortg = s2q6==1 if s2q6!=.
g dtrns2013 = daq2013==1 | dgve2013==1 if daq2013!=. | dgve2013!=.

table province, c(mean down mean daq2013 mean dgve2013 mean dtrns2013 count down)

table province, c(mean drntout mean drntin mean dmortg count down)



** hhousehold: sample
use Z:\AFR\Rwanda\LTR\Impact2\MonitoringIndicators\Sample\sample_rural, clear
keep province_code province_name district_code district_name sector_code sector_name cell_code cell_name village_code village_name
sort province_name district_name sector_name cell_name village_name

save tmp1, replace

***

use "$temp\Rwanda_household_2018", clear
keep interview__id province province_cd district district_cd sector sector_cd cell cell_cd village village_cd
sort province province_cd district district_cd sector sector_cd cell cell_cd village village_cd
merge province province_cd district district_cd sector sector_cd cell cell_cd village village_cd using "$temp\update_geo_code"

replace province = substr(village_code,1,1) if _mer==3
replace district = province + substr(village_code,3,1) if _mer==3
replace sector = district + substr(village_code,4,2) if _mer==3
replace cell = sector + substr(village_code,6,2) if _mer==3
replace village = cell + substr(village_code,8,2) if _mer==3
drop village_code _merge
sort interview__id
save "$temp\geo_code", replace




***** household level data
** individual
use "$temp\hhroster", clear
g dhead = s1q3==1 if s1q3<=18
g dmale = s1q2==1 if s1q2<=2
g dmcrt = s1q8==1 if s1q8<=2
g dmcum = s1q10==1 if s1q10<=5
g yrmr = s1q11 if s1q11!=.a

keep interview__id dhead - yrmr

keep if dhead==1

sort interview__id

save "$tmp\hh_marriage", replace

** old parcel roster

use "$temp\oproster", clear
sort interview__id
merge interview__id using "$temp\geo_code"
keep if _mer==3
drop province - _mer

keep interview__id oproster__id s2q3 area s2q6 s2q10
keep if s2q3==2 | s2q3==3
sort interview__id oproster__id
save tmp2, replace

** transfered out fragments
use "$temp\fragroster", clear
sort interview__id
merge interview__id using "$temp\geo_code"
keep if _mer==3
drop province - _mer

sort interview__id oproster__id
merge interview__id oproster__id using tmp2
drop if _mer==1
keep interview__id oproster__id fragroster__id s2q11b s2q11e s2q11f s2q11g s2q11h area s2q3 s2q6
replace s2q11e=area if s2q3==3 & s2q6==2
keep interview__id oproster__id fragroster__id s2q11b s2q11e s2q11f s2q11g s2q11h

save tmp3, replace

*** 

use "$temp\tofragroster", clear
sort interview__id
merge interview__id using geo_code
keep if _mer==3
drop province - _mer
keep interview__id toroster__id tofragroster__id s4q11b s4q11e s4q11f s4q11g s4q11h
ren s4q11b s2q11b
ren s4q11e s2q11e
ren s4q11f s2q11f
ren s4q11g s2q11g
ren s4q11h s2q11h

append using tmp3

save trn_out, replace

use trn_out, clear

keep if s2q11f>=2013
tab s2q11b if s2q11b<=7, g(dlocparty)
g area = s2q11e/10000
tab s2q11g if s2q11g<=5, g(dtrnsby)
g svalue = s2q11h if dtrnsby1==1
winsor2 svalue if svalue!=., replace cuts(5 95)
g svalueh = s2q11h/area if dtrnsby1==1
winsor2 svalueh if svalueh!=., replace cuts(5 95)




** new parcel roster

use "$temp\newproster", clear
sort interview__id
merge interview__id using "$tmp\hh_marriage"
drop if _mer==2
drop _mer

g area=s3q9
recode area .a=.
replace area=. if area<=0

replace area=area/10000

g dresuse=s3_landuse__1==1 if s3_landuse__1<=2
g dacropuse=s3_landuse__2==1 if s3_landuse__2<=2
g dpcropuse=s3_landuse__3==1 if s3_landuse__3<=2
g dfallow=s3_landuse__4==1 if s3_landuse__4<=2
g dnaguse=s3_landuse__5==1 if s3_landuse__5<=2
g douse=s3_landuse__6==1 if s3_landuse__6<=2

g dknowupi = s3q3==1 if s3q3<=2
g dknowparty = s3q5!="##N/A##" & substr(s3q5,1,2)!="Xx" & substr(s3q5,1,2)!="xx"
tab s3q6 if s3q6<=7, g(dlocparty)
g dfdrel = s3q8<=4 if s3q8<=15
g dsdrel = s3q8>=5 & s3q8<=11 if s3q8<=15
g dneigfr = s3q8>=12 & s3q8<=14 if s3q8<=15
g dnonrel = s3q8==15 if s3q8<=15

g dmaleo=dmale==1 & dmcum!=1
g dfemaleo = dmale!=1 & dmcum!=1
g djnt=dmcum==1

g dpurch = s3q11==1 if s3q11<=7
g pvalue = s3q12 if dpurch==1
winsor2 pvalue if pvalue!=., replace cuts(5 95)
g pvalueh = s3q12/area if dpurch==1
winsor2 pvalueh if pvalueh!=., replace cuts(5 95)
g dnonmacq = s3q11>=2 & s3q11<=4 if s3q11<=7
g dgovall = s3q11==5 if s3q11<=7
g dothacq = s3q11>=6 & s3q11<=7 if s3q11<=7

g dvoffinf = s3q13==1 if s3q13<=2
g dhcert = s3q14==1 if s3q14<=2
g dhmmcert = s3q15==1 if dhcert==1

tab s3q17 if s3q17<=3, g(dstarproc)
tab s3q20 if s3q20<=4 & s3q17<=3, g(dstgproc)

for var s3q18*: recode X 2=.67 3=.33

g dclnreq = s3q18__1 if s3q18__2<=1
g dcexp =s3q18__2 if s3q18__2<=1
g dclknw = s3q18__4 if s3q18__4<=1
g dcofar = s3q18__3 if s3q18__3<=1
g dcflt = s3q18__5 if s3q18__5<=1
g dcsdna = s3q18__6 if s3q18__6<=1
g dcsdcost = s3q18__7 if s3q18__7<=1
g dcdisp = s3q18__8 if s3q18__8<=1

g wtp = s3a19 if s3a19>0 & s3a19!=. & s3a19!=.a
winsor2 wtp if wtp!=., replace cuts(1 99)


keep if s3q10>=2013 & s3q10<=2018

keep interview__id area-wtp
 
g lnduse =3 if dresuse==1 &  dacropuse + dpcropuse + dfallow + dnaguse + douse==0
recode lnduse .=1 if dacropuse==1
recode lnduse .=2 if dpcropuse==1
recode lnduse .=4 if dnaguse==1
g trans = 10 if dpurch==1
recode trans . = 11

sort interview__id
merge interview__id using "$tmp\geo_code"
drop if _mer==2
drop _mer

save "$tmp\newparcel_desc", replace



**

use "$tmp\newparcel_desc", clear
g hhid = _n
drop interview__id province - village_cd

label define lnduse 1 "Annual" 2 "Pern" 3 "Res" 4 "Nonagr"
label values lnduse lnduse
label define trans 10 "Purch" 11 "Nonmon"
label values trans trans


table1 lnduse trans using $tmp\, id(hhid) order 

***
use newparcel_desc, clear
collapse area, by(interview__id lnduse trans)
tab lnduse, g(use)
tab trans, g(trn)
g n=1
collapse (max) n use1 - trn2, by(interview__id)
