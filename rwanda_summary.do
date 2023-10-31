clear
cap log close
set matsize 1000
set more off, perm 

/*global code 	"\code\"
global data 	"\data\"
global rawdata 	"\rawdata\"
global output	"\output\"*/
global temp 	"C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\WorldBank\data"
global tmp 		"C:\Users\Mahofa"

log using "$temp\descriptives.txt", replace text
/*
use "..\data\household", clear
merge m:1 interview__id using "..\data\asset_quartiles"
drop _merge
*Distribution of households by regions
d
foreach var of varlist prov_code dist_code sect_code cell_code vill_code {
tab `var' if head == 1
}

qui outreg2 using "..\output\descript.xls" if head == 1, sum(log) ///
replace eqkeep(N mean sd) keep(female age hhsize married school ///
primary sec_vocational live_hhd nofemale nomale adultmale noparcels ///
adultfemale oldfemale oldmale community ltd_community separation ///
kinyarwanda english french agric non_agric agric_sec nonagr_sec catholic protestant other ///
instwife_yes instwife_no spouse spouse_50 equalshre chdn son_inhe son1 ///
daughter equaldiv husband wifeonly both joseph joint writ_consent vill_leaders ///
cell_leader sec_leader dist_land nat_land reg_fee inheritance land_lease ///
reg_cert cad_map app_form identity villlead_sal cell_sales land_sales ///
dislnd_sales nati_sales regfee_sales agre_aut lease_sales regcert_sales ///
cadmap_sales appform_sales id_sales informa_sales villder_use celleader_use ///
secland_use distland_use natnal_use landuse_fee lndlease_use regcert_use ///
cadmap_use appform_lease) 
foreach i in 1 2 3 4 {
qui outreg2 using "..\output\descript.xls" if head == 1&wealth_qurtile == `i', sum(log) ///
append eqkeep(N mean sd) keep(female age hhsize married school ///
primary sec_vocational live_hhd nofemale nomale adultmale noparcels ///
adultfemale oldfemale oldmale community ltd_community separation ///
kinyarwanda english french agric non_agric agric_sec nonagr_sec catholic protestant other ///
instwife_yes instwife_no spouse spouse_50 equalshre chdn son_inhe son1 ///
daughter equaldiv husband wifeonly both joseph joint writ_consent vill_leaders ///
cell_leader sec_leader dist_land nat_land reg_fee inheritance land_lease ///
reg_cert cad_map app_form identity villlead_sal cell_sales land_sales ///
dislnd_sales nati_sales regfee_sales agre_aut lease_sales regcert_sales ///
cadmap_sales appform_sales id_sales informa_sales villder_use celleader_use ///
secland_use distland_use natnal_use landuse_fee lndlease_use regcert_use ///
cadmap_use appform_lease) 
}

qui outreg2 using "..\output\legalmarr.xls" if head == 1&married == 1, sum(log) ///
replace eqkeep(N mean sd) keep(legal_marr)

*Individual level characteristics
qui outreg2 using "..\output\descript_indi.xls", sum(log) ///
replace eqkeep(N mean sd) keep(female age married school ///
primary sec_vocational live_hhd kinyarwanda english french ///
agric non_agric agric_sec nonagr_sec catholic protestant other)

qui outreg2 using "..\output\legalmarr_ind.xls" if married == 1, sum(log) ///
replace eqkeep(N mean sd) keep(legal_marr)

*Household level characteristics by wealthy quartile
*/

********************************************************************************

*DESCRIPTIVES FOR OLD PARCELS ROSTER
use "$tmp\household2018_to", clear
keep interview__id  province_cd prov_code 
merge 1:m interview__id using "$temp\oldparcel1"
keep if _merge == 3
drop _merge
merge m:1 interview__id using "$temp\assetqua_tm" /*merge with wealthy quartiles*/
keep if _merge == 3
keep if yearcert >=2013&yearcert!=.
drop _merge
keep prov_code oparcelid area own part noown residential anncrop permcrop non_agrland fallow other ///
s2q10 map_yes ongoing noobtain subdivision nosubdiv mapyes ong_fra no_fra notknow ///
afford toosmall wealth_qurtile nopayfee-stayoffice area_owned purchased-walked_op ///
certificate unrdispute wetland notpicked notready
lab var area_owned "Area still owned"
save "$temp\oldparc_table1", replace

/*
qui outreg2 using "..\output\oldpar.xls", sum(log) replace eqkeep(N mean sd) ///
keep(area own part noown residential anncrop permcrop non_agrland fallow other ///
area_owned certificate unrdispute wetland notpicked notready purchased ///
exchange inheritance gift govtall s2q10 )
foreach i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 {
qui outreg2 using "..\output\oldpar.xls" if dist_code_1 == `i', sum(log) append eqkeep(N mean sd) ///
keep(area own part noown residential anncrop permcrop non_agrland fallow other ///
area_owned certificate unrdispute wetland notpicked notready purchased ///
exchange inheritance gift govtall s2q10)

 }
 tab yearcert /*year certificate was issued*/
 tab s2q1 /*year parcel acquired*/
 
 qui outreg2 using "..\output\oldpar_1.xls" if trnsout_part == 1, sum(log) ///
 replace eqkeep(N mean sd)   keep(map_yes ongoing noobtain  ///
 nosubdiv mapyes ong_fra no_fra notknow afford toosmall)
 save "..\data\oldparcel_1", replace*/
 *******************************************************************************
 *Section 2: Fragroster
use "$tmp\household2018_to", clear
keep interview__id   prov_code 
merge 1:m interview__id using "$temp\fragroster_1.dta"
keep if _merge == 3
tab s2q11f, mi
keep if s2q11f >= 2013&s2q11f <= 2018
drop _merge s2q11f
merge m:1 interview__id using "$temp\assetqua_tm"
keep if _merge == 3
keep prov_code area_tofrag frag_sold frag_beq auth_frag traded_frag s2q11h oldfragid wealth_qurtile
save "$temp\oldfrag_table1", replace
 
 /*qui outreg2 using "..\output\fragroster_1.xls", sum(log) replace eqkeep(N mean sd) ///
 keep(samevill anvill_op ancell_op ansect_op andist_op abroad_op female_op area_tofrag ///
 frag_sold frag_beq auth_frag traded_frag s2q11h)
 tab s2q11d, mi */
 
 *SECTION 3: DESCRIPTIVES FOR NEW PARCELS:TRANSFERS IN
use "$tmp\household2018_to", clear
keep interview__id prov_code 
merge 1:m interview__id using "$temp\newparcel"
keep if _merge == 3
drop _merge
tab s3q10, mi
merge m:1 interview__id using "$temp\assetqua_tm"
keep if _merge == 3
keep newparcelid area purchased_newr inheritance_newr gift_newr govtall_newr walked_newr residential ancrop ///
 permcrop non_agric fallow otheruses s3q14 s3q12
save "$temp\newparce_table1", replace
 
 /*
qui outreg2 using "..\output\newpar_1.xls", sum(log) replace eqkeep(N mean sd) ///  
 keep( thisvillage anvill ancell thisvill_acq anvill_acq ancell_acq ansec_acq ///
 andistric_acq abroad deceased female male area purchased_newr ///
 inheritance_newr gift_newr govtall_newr residential ancrop ///
 permcrop non_agric fallow otheruses _s3q13 _s3q14 _s3q15 startreg wtp_value value formpicked ///
 appl_sub transfr_sig)
 foreach i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 {
 qui outreg2 using "..\output\newpar_1.xls" if dist_code_1 == `i', sum(log) append eqkeep(N mean sd) ///  
 keep( thisvillage anvill ancell thisvill_acq anvill_acq ancell_acq ansec_acq ///
 andistric_acq abroad deceased female male area purchased_newr ///
 inheritance_newr gift_newr govtall_newr residential ancrop ///
 permcrop non_agric fallow otheruses _s3q13 _s3q14 _s3q15 startreg wtp_value value formpicked ///
 appl_sub transfr_sig)
}
 tab s3q8, mi
 tab s3q10 if s3q10 >= 2013 , mi year of acquisition; there is 2019 and another year-probably typo*/
 *******************************************************************************
 
 *SECTION 4: DESCRIPTIVES FOR PARCELS SOLD OR GIVEN AWAY
use "$tmp\household2018_to", clear
keep interview__id prov_code 
merge 1:m interview__id using "$temp\toroster1"
keep if _merge == 3
drop _merge
merge m:1 interview__id using "$temp\assetqua_tm"
keep if _merge == 3
keep soldparcid prov_code wealth_qurtile vill_out anvill_out ancell_out dist_out ///
 area_sold subdivided_out notdivided_ou s4q7 cadmap_out ongproc_out notobt_out notknow_out ///
 afford_out s4q10 toosmall
 save "$temp\soldparc_table1", replace
/*
 qui outreg2 using "..\output\transfer_out.xls", sum(log) replace eqkeep(N mean sd) ///
 keep(vill_out anvill_out ancell_out dist_out area_sold subdivided_out notdivided_out)
 foreach i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 {
 qui outreg2 using "..\output\transfer_out.xls" if dist_code_1 == `i', sum(log) append eqkeep(N mean sd) ///
 keep(vill_out anvill_out ancell_out dist_out area_sold subdivided_out notdivided_out)
}
 qui outreg2 using "..\output\transfer_out1.xls" if subdivided_out == 1, sum(log) ///
 replace eqkeep(N mean sd) keep(s4q7 cadmap_out ongproc_out notobt_out notknow_out ///
 afford_out s4q10)
*/

 *Section 4: Fragments data
use "$tmp\household2018_to", clear
keep interview__id prov_code 
merge 1:m interview__id using "$temp\tofragroster1.dta"
keep if _merge == 3
tab s4q11f, mi
drop _merge
keep if s4q11f >=2013&s4q11f <= 2018
merge m:1 interview__id using "$temp\assetqua_tm"
keep if _merge == 3

keep tofragid prov_code parent-other_tofra vill_fragout anvill_fragout ///
ancell_fragout ansect_fragout female male area_fragsold ///
 tofrag_sold tofrag_beq auth_tofrag traded_tofrag s4q11h wealth_qurtile
save "$temp\tofrag_table1", replace
/*
 qui outreg2 using "..\output\tofrag.xls", sum(log) replace eqkeep(N mean sd) ///
 keep(vill_fragout anvill_fragout ancell_fragout ansect_fragout female male area_fragsold ///
 tofrag_sold tofrag_beq auth_tofrag traded_tofrag s4q11h) 
 tab s4q11d, mi
 
 *Descriptives for Assets
 
use "..\data\assets", clear
merge 1:1 interview__id using "..\data\asset_quartiles"
keep if _merge == 3
drop _merge
format asset_val %10.2f
qui outreg2 using "..\output\desc_asset.xls", sum(log) ///
replace eqkeep(N mean sd) keep(asset_val asset_index)
 foreach i in 1 2 3 4 {
 qui outreg2 using "..\output\desc_asset.xls" if wealth_qurtile == `i', sum(log) ///
append eqkeep(N mean sd) keep(asset_val asset_index)
}

use "..\data\assets_agric", clear
merge 1:1 interview__id using "..\data\asset_quartiles"
keep if _merge == 3
drop _merge
foreach var of varlist asset_val0 asset_val1 {
replace `var' = 0 if `var' == .
}
qui outreg2 using "..\output\desc_asset_agr.xls", sum(log) ///
replace eqkeep(N mean sd) keep(asset_val0 asset_val1)
 foreach i in 1 2 3 4 {
qui outreg2 using "..\output\desc_asset_agr.xls" if wealth_qurtile == `i', sum(log) ///
append eqkeep(N mean sd) keep(asset_val0 asset_val1)
}
********************************************************************************
 *VILLAGE LEVEL PARCEL CHARACTERISTICS
 *Merging village level parcel in and parcel out data
 use "..\data\village_in", clear
 merge 1:1 village_cd using "..\data\village_out"
 drop _merge
 ren parcel parcel_in
 gen balance = parcel_in - parcel_out
 qui outreg2 using "..\output\transfer_out.xls", sum(log) replace eqkeep(N mean sd) 
*/

 log close
 exit

