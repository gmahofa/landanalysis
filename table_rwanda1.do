
*** specify a path for tmp files

global hhdta "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\WorldBank\hhdta"
global tmp "C:\Users\Mahofa"
global lisd "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\WorldBank\lisd"
global proc "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\WorldBank\proc"
global output "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\WorldBank\output"

*global temp 	"C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\WorldBank\data"
*global tmp C:\Users\Mahofa /* this is necessary for the code to work **/

**Generating tables
*1) 
use "$proc\hhdlisting", clear
cap table1 province s1q2 using $tmp\, id(hhid) order /*Table 1*/
export excel using "$output\landincidence272019.xls", firstrow(variables) replace

*2)
use "$proc\newparcelmgd", clear
drop interview__id s3q16* owner_parcel newproster__id-landuse ///
dclnreq-dcdisp area
cap table1 province_cd  mode_tr regis s1q2 using $tmp\, id(newparcelid) order /*Table 2*/
replace label="Amount willing to pay to register the" if variables=="wtp_value_newr"
replace label="Market" if variables=="market"
replace label="Inherited" if variables=="inheritance_newr"
replace label="Alerted village leaders" if variables=="ivleader"
replace label="Started registration of transaction" if variables=="startreg"
replace label="Not officially registered" if variables=="not_reg"
replace label="Officially registered" if variables=="registered"
export excel using "$output\newparceld1", firstrow(variables) replace

*3)
use  "$proc\newparcelfinal", clear
drop owner_parcel
cap table1 mode_tr regis using $tmp\, id(newparcelid) order  /*Table 3*/
replace label="Purchase value of the parcel" if variables=="s3q12"
replace label="Amount willing to pay (WTP) for registration (RWF)" if variables=="wtp_value_newr"
replace label="Area of newly acquired parcel in hectares" if variables=="area_acq"
replace label="Residential" if variables=="dresid"
replace label="Annual crop" if variables=="danncrop"
replace label="Permanent crop" if variables=="dpermcrop"
replace label="Fallow" if variables=="dfallow"
replace label="Residential and annual cropping" if variables=="dres_acropp"
replace label="Residential and permanent cropping" if variables=="dres_pcropp"
replace label="Residential and fallow" if variables=="dres_fallow"
replace label="Annual and permanent cropping" if variables=="dacrop_pcropp"
replace label="Annual cropping and fallow" if variables=="dacrop_fallow"
replace label="Permanent cropping and fallow" if variables=="dpcropp_fallow"
replace label="Newly acquired parcel was purchased" if variables=="market"
replace label="New parcel inherited" if variables=="inheritance"
replace label="Other means" if variables=="other"
replace label="Mode of acquisition" if variables=="mode_tr"
replace label="Officially registered" if variables=="regis"
replace label="Legally not required" if variables=="dclnreq"
replace label="Registration fees are to expensive" if variables=="dcexp"
replace label="Do not know it was required" if variables=="dclknw"
replace label="Registration office too far" if variables=="dcofar"
replace label="Revious owner had no certificate" if variables=="dcflt"
replace label="Subdivision was not legally possible" if variables=="dcsdna"
replace label="Subdivision costs were too high" if variables=="dcsdcost"
replace label="Land under dispute" if variables=="dcdisp"
replace label="Not officially registered" if variables=="not_reg"
replace label="Registered" if variables=="registered"
replace label="Male only" if variables=="maleonly"
replace label="Female only" if variables=="femaleonly"
replace label="Joint" if variables=="joint"
export excel using "$output\newparc_table3", firstrow(variables) replace


*4)Table 4
use "$proc\hhd_merged", clear
merge 1:1 interview__id using "$proc\asset_quartiles"
keep if _merge == 3
drop _merge
save "$proc\hhdmergedasst", replace
merge 1:1 interview__id using "$tmp\reg_mktstatus" /*some hhds from using not matching-dropped hhd from pilot probably*/
encode interview__id, gen(hhid)
keep if _merge == 3
drop interview__id _merge
order hhid, before(s1q2)
lab var purchvalue_asset0 "Purchase value of non-agric assets"
lab var purchvalue_asset1 "Purchase value of agric assets"
winsor2 purchvalue_asset0 if purchvalue_asset0!=., replace cuts(20 80)
winsor2 purchvalue_asset1 if purchvalue_asset1!=., replace cuts(18 82)
drop hedcount head male s5q4-id_use live_hhd instwife_yes-writ_consent d_one ///
d_onesles d_oneuse
capture table1 trans regstatus s1q2 using $tmp\, id(hhid) order  /*Table4*/ 
do "$hhdta\labelhhd.do"
export excel using "$output\descriptives09022019_1.xls", firstrow(variables) replace

*5) Table 5
use "$proc\parc_sold", clear
drop village_cd interview__id
keep if s4q11f >= 2013
cap table1 province_cd s1q2 s4q11g using $tmp\, id(soldparcid) order
replace label="Number of subdivision (fragments)" if variables=="s4q7"
replace label="Are of the parcel sold" if variables=="area_sold"
replace label="Plot swas subdivided before transfer" if variables=="subdivided_out"
replace label="Obtained cadastral maps for fragments" if variables=="cadmap_out"
replace label="Process for obtaining cadastral maps ongoing" if variables=="ongproc_out"
replace label="Not obtained cadastral maps" if variables=="notobt_out"
replace label="s4q11g==Sold" if variables=="I1"
replace label="s4q11g==Bequeathed, given away, donated" if variables=="I2"
replace label="s4q11g==Taken by authorities" if variables=="I3"
replace label="s4q11g==Traded for another land" if variables=="I4"
replace label="s4q11g==Other" if variables=="I5"
export excel using "$output\toros_inf282019", firstrow(var) replace
****
*Fragments level
use "$proc\trn_outfinal", clear
cap table1 province_cd mode_tr s1q2 using $tmp\, id(toid) order
replace label="How was the fragment transferred out?" if variables=="s2q11g"
replace label="Sales price of the fragment" if variables=="s2q11h"
replace label="Number of fragments transferred out or taken away" if variables=="s2q10"
replace label="s2q11c==Male" if variables=="dgenderparty1"
replace label="s2q11c==Female" if variables=="dgenderparty2"
replace label="s2q11c==Not Applicable" if variables=="dgenderparty3"
replace label="s2q11d==Son/daughter/grand child" if variables=="drelhdparty1"
replace label="s2q11d==Parent" if variables=="drelhdparty2"
replace label="s2q11d==Spouse" if variables=="drelhdparty3"
replace label="s2q11d==Brother/Sister" if variables=="drelhdparty4"
replace label="s2q11d==Uncle/Aunt" if variables=="drelhdparty5"
replace label="s2q11d==Grand parent" if variables=="drelhdparty6"
replace label="s2q11d==Nephew/Niece" if variables=="drelhdparty7"
replace label="Area in hectares" if variables=="area"
replace label="s2q11g==Sold" if variables=="dtrnsby1"
replace label="s2q11g==Bequeathed, given away, donated" if variables=="dtrnsby2"
replace label="s2q11g==Taken by authorities" if variables=="dtrnsby3"
replace label="s2q11g==Traded for another land" if variables=="dtrnsby4"
replace label="s2q11g==Other" if variables=="dtrnsby5"
replace label="svalue" if variables=="svalue"
replace label="s2q8==Yes" if variables=="dmap1"
replace label="s2q8==Process ongoing" if variables=="dmap2"
replace label="s2q8==No" if variables=="dmap3"
replace label="s2q6==Yes" if variables=="fragyes1"
replace label="s2q6==No" if variables=="fragyes2"
replace label="s2q11d==Cousin/relative" if variables=="drelhdparty8"
replace label="s2q11d==(Son, daughter, or grand child)-in-law" if variables=="drelhdparty9"
replace label="s2q11d==Parent-in-law, grand parent-in-law" if variables=="drelhdparty10"
replace label="s2q11d==Brother/Sister-in-law" if variables=="drelhdparty11"
replace label="s2q11d==Friend" if variables=="drelhdparty12"
replace label="s2q11d==Neighbor" if variables=="drelhdparty13"
replace label="s2q11d==Business partner" if variables=="drelhdparty14"
replace label="s2q11d==Other unrelated person" if variables=="drelhdparty15"
export excel using "$output\fragout_012019.xls", firstrow(variables) replace


*6) Table 6
*POTENTIAL DETERMINANTS:LPM AND PROBIT AT PARCEL LEVEL
use "$tmp\household2018_to", clear
encode village_cd, g(vill_code)
keep interview__id vill_code
save "$proc\hhdvil", replace

use "$proc\newparcelmgd", clear
mer m:1 interview__id using "$proc\hhdvil"
keep if _mer == 3
drop _mer
mer m:1 interview__id using "$proc\hhdmergedasst"
keep if _mer == 3
drop _mer s3q16*
save "$proc\newparcel_to_cnstct", replace
tab regis, mi nolabel /*dependent variable*/
g vasset = asset_val0 + asset_val1
g lnvasset = ln(vasset)

*g lnpurchvalue_asset1 = ln(1+ purchvalue_asset1)
g lnarea = ln(area)
/*g married_ = married + married1
drop married married1
ren married_ married
g leg_marr = married*legal_marr
g sec_edu = school*sec_vocational*/
*winsor2 wtp_value_newr if wtp_value_newr!=., replace cuts(10 90)
g drewher = (dnone + dnone_sles + dnone_use)/3
lab var drewher "Hhds without knowledge abt where to register"
g dcorrt = (d1 + d1_use + d1_sles)/3
lab var dcorrt "Hhds with knowledge abt where to register"
recode s1q5 (2 = 1) (4 = 3)

** knowledge institution

g dnone_ins = (dnone + dnone_sles + dnone_use)/3
g d1_ins = (d1 + d1_sles + d1_use)/3
g dall_ins = (dall + dall_sles + dall_use)/3
g dtan_regk = (both+joint)/2
egen dlit = rowmax(kinyarwanda english french)
for var primary sec_vocational tertiary edu: recode X .=0 if school==0
g lnage = ln(age)
g lnage2 = lnage*lnage
g regis_s = regis==1 | startreg==1

g lnwtp = ln(wtp_value_newr)

****
*Regressions
/*
reg regis lnarea_acq lnpurchvalue_asset1 b2.landuse i.mode_tr age female ///
hhdsize_1 dreginst dcorrt i.s1q5, ro
foreach var in lnarea_acq lnpurchvalue_asset1 b2.landuse i.mode_tr age female ///
hhdsize_1 dreginst dcorrt i.s1q5 {
	local newlist `newlist' `var'
	reg regis `newlist'
}	
*/
*LPM

eststo clear

qui eststo: reg regis_s lnarea lnvasset b2.landuse i.mode_tr ///
lnage hhdsize female edu non_agric both dnone s3q10, ro

qui eststo: xtreg regis_s lnarea lnvasset b2.landuse i.mode_tr ///
lnage hhdsize female edu non_agric both dnone s3q10, fe i(vill_code) ro
 
*Probit
qui eststo: probit regis_s lnarea lnvasset b2.landuse i.mode_tr ///
lnage hhdsize female edu non_agric both dnone s3q10, ro

*WTP Estimates
qui eststo: reg lnwtp lnarea lnvasset b2.landuse i.mode_tr ///
lnage hhdsize female edu non_agric both dnone s3q10, ro

qui eststo: xtreg lnwtp lnarea lnvasset b2.landuse i.mode_tr ///
lnage hhdsize female edu non_agric both dnone s3q10, fe i(vill_code) ro

/*tobit wtp_value_newr lnarea_acq lnpurchvalue_asset1 residential_acq ancrop_acq permcrop_acq non_agric_acq ///
fallow_acq age female hhdsize_1,  ll(200)*/

*Table 6
esttab using "$output\LPM_probit.doc", se rtf replace ///
starlevels( * 0.10 ** 0.05 *** 0.010) nodep stats(N r2 r2_p chi2)  ///
varlabels(lnarea "Ln area in ha" lnvasset "Ln vlaue of assets" edu "Heads years of education" ///
lnage "Ln age of head" female "Female headed houshold" hhdsize_1 "Household size" ///
non_agric "Non-agriculture primary occupation" both "Knowledge of joint registration" dnone "No correct answer for inheritance registration instituions" ///
s3q10 "Year of acquisition")
eststo clear

log close
exit

