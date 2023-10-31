********************************************************************************
*Do File for loading and preparing for cleaning and preparing data from Rwanda 
*Land Transactions Household and Listings 2018-World Bank Project
********************************************************************************

clear
cap log close
set more off, perm 

global temp 	"C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\WorldBank\data"
global tmp 		"C:\Users\Mahofa"
log using "$temp\loading.txt", replace text

********************************************************************************
********************************************************************************
*LOADING LISTINGS DATA
use "$temp\Rwanda_Listing_2018", clear
drop if province == 1  /*dropping Kigali City*/
drop if village == 57070401
drop if province == .
drop if province == .a
g down = s2q1==1 if s2q1!=.
g daq2013 = s2q2==1 if s2q2!=.
g dgve2013 = s2q3==1 if s2q3!=.
g drntout = s2q4==1 if s2q4!=.
g drntin = s2q5==1 if s2q5!=.
g dmortg = s2q6==1 if s2q6!=.
g dtrns2013 = daq2013==1 | dgve2013==1 if daq2013!=. | dgve2013!=.
keep interview__id province  down-dtrns2013
save "$temp\Rwandalisting", replace

use "$temp\hh_rost", clear /*from listing data*/
keep if s1q3 == 1
keep interview__id s1q2  
merge 1:1 interview__id using "$temp\Rwandalisting"
keep if _merge == 3
drop _merge
encode interview__id, gen(hhid)
drop interview__id
drop if s1q2 == .a
save "$temp\hhdlisting", replace
********************************************************************************
********************************************************************************
*LOADING THE HOUSEHOLD ROSTER FROM HOUSEHOLD FULL DATA

use "$temp\Rwanda_household_2018", clear
d /*describe the data*/
isid interview__id /*unique identifier for this dataset*/
codebook interview__id


*No of registered parcels: Old Parcels;hever this will be obtained from oproster
inspect noparcels 
replace noparcels = . if noparcels == .a
gen noparcels_1 = noparcels
order noparcels_1, after(noparcels)
replace noparcels_1 = 0 if noparcels_1 == .
sum noparcels, d /* average no of parcels for those who own parcels*/
spikeplot noparcels 
sum noparcels_1, d

so interview__id
drop if village == "57070401"
encode province_cd, g(province_cd1)
drop province_cd
ren province_cd1 province_cd
order province_cd, before(district)
save "$tmp\household2018_to", replace

use "$temp\hhroster", clear
d
isid interview__id hhroster__id  /*checking unique identifier*/
codebook interview__id
so interview__id
merge m:1 interview__id using "$tmp\household2018_to" /*combining with other household characteristics*/
keep if _merge == 3
drop _merge s5respondent s6respondent sssys_irnd has__errors interview__status

order province province_cd  district district_cd  sector sector_cd  cell cell_cd ///
village village_cd name_head telephone telephone_confirm telephone_corrected gps_int__Latitude ///
gps_int__Longitude gps_int__Accuracy gps_int__Altitude gps_int__Timestamp, after(hhroster__id)

*SECTION 1 CONTINUED: Cleaning other household characteristics-variables

*Gender variable
numlabel s1q2, add
tab s1q2, mi
*gender missing:trying to infer gender from other variables
list interview__id hhroster__id s1q2 if s1q2 ==.a
list interview__id hhroster__id s1q2 s1q3 if s1q2 ==.a
list interview__id hhroster__id s1q2 s1q3 s1q5 if s1q2 ==.a
list hhroster__id s1q2 s1q3 s1q5 if interview__id=="5e0022551d9749eba3672a034e47fce1"
replace s1q2 = 2 if interview__id=="5e0022551d9749eba3672a034e47fce1"&s1q2 == .a

recode s1q2 (1 = 0) (2 = 1), gen(female)
lab val female female 
lab def female 0 "Male" 1 "Female"
table s1q2 female
recode s1q2 (2  = 0), gen(male)
table s1q2 male
lab val male male
lab def male 0 "Female" 1 "Male"


*Relationship to head
tab s1q3, mi
numlabel s1q3, add
recode s1q3 (2/18  = 0), gen(head)
table  s1q3 head
byso interview__id: egen hedcount=total(head)
preserve
keep if hedcount == 1
save "$tmp\hhdhead", replace
restore

keep if hedcount == 0
so interview__id hhroster__id
br interview__id hhroster__id name name_head s1q3 head
replace name = proper(name)
replace head = 1 if name==name_head
drop hedcount
byso interview__id: egen hedcount=total(head)
preserve
keep if hedcount == 1
save "$tmp\hhdhead1", replace
restore
keep if hedcount == 0
so interview__id hhroster__id
br interview__id hhroster__id name name_head s1q3 head
replace name_head = proper(name_head)
replace head = 1 if name==name_head
drop hedcount
byso interview__id: egen hedcount=total(head)
preserve 
keep if hedcount == 1
save "$tmp\hhdhead2", replace
restore
keep if hedcount == 0
so interview__id hhroster__id
br interview__id hhroster__id name name_head s1q3 head
replace name = "Uzabakiho Jean" if name == "Uzabakiriho Jean"
replace name = "Nkuziryo Charles" if name == "Nkunziryayo Charles"
replace name = "Barasebwa Annastasi" if name == "Barasabwa Anastasi"
replace name = "Nyirahabimana Elinestine" if name == "Nyiransabimana Elinestine"
replace name = "Nyiragwiza Cloude" if name == "Nyiragwiza Cloudine"
replace name = "Tuyisenge Emauel" if name == "Tuyisenge Emanuel"
replace name = "Mukamparirwa Mwwayijyi" if name == "Mukamparirwa Mwayijyi"
replace name = "Gahijyiro Ezekieli" if name == "Gahigiro Ezekieri"
replace name = "Nyirandemeye Flester" if name == "Nyirandemeye Flesta"
replace name = "Mukamana Rose" if name == "Mukamana Marie Rose"
replace name = "Beninka Elina" if name == "Beninka Eline"
replace name = "Mukandoli Seraphine" if name == "Mukandoli Seraphine"
replace name = "Mukandoli Seraphine" if name == "Mukandoli Selaphine"
replace name = "Gasana Alex" if name == "Gasana Sept"
replace name = "Habimana Jean Damascene" if name == "Habimana J.Damascene"
replace name = "Karukaka Velena" if name == "Mukarukaka Velena"
replace name = "Ndengerabahizi Emma" if name == "Ndegerabahizi Emmanuel"
replace name = "Nkumukiza Augustin" if name == "Nkurikiyumukiza Augustin"
replace name = "Ryazigwa Liberatha" if name == "Ryaziga Liberathe"
replace name = "Mukagomayubu" if name == "Mukangomayubu Beatrice"
replace name = "Musabyimana Esperance" if name == "Musabyimana  Esperance"
replace name = "Mukangwije Anstasie" if name == "Mukangwije  Anastasie"
replace name = "Nyiranzegure Saveline" if name == "Nyiranzigure Saveline"
replace name = "Mpongano Esperance" if name == "Mpongano Eperance"
replace head = 1 if name==name_head
drop hedcount
byso interview__id: egen hedcount=total(head)
preserve
keep if hedcount == 1
save "$temp\hhdhead3", replace
restore
keep if hedcount == 0 /*for these households no name matches and difficult to ascertain head*/
//replace head = 1 if s1q3 == 2
append using "$temp\hhdhead3" "$tmp\hhdhead2" "$tmp\hhdhead1" "$tmp\hhdhead" 

*Age of household head: How old in completed years
inspect s1q4 /*negative age in some observations:-99 the obs will be set to missing*/
list s1q4 if s1q4 < 0
replace s1q4 = . if s1q4 == -99
ren s1q4 age
spikeplot age 
spikeplot age if head == 1

*Marital Status of head: Consider all categories
numlabel s1q5, add
tab s1q5, mi
recode s1q5 (2/7  = 0), gen(married)
lab var married "Married Monogamously"
table s1q5 married
recode s1q5 (1 3/7 = 0) (2 =1), gen(married1)
lab var married1 "Married Polygamously"
table s1q5 married1
recode s1q5 (3 = 1) (1/2 4/7  = 0), gen(liv_togeth)
lab var liv_togeth "Living together: Monogamously"
table s1q5 liv_togeth
recode s1q5 (4 = 1) (1/3 5/7  = 0), gen(liv_together1)
lab var liv_together1 "Living together: Polygamously"
table s1q5 liv_together1
recode s1q5 (5 = 1) (1/4 6/7 = 0), gen(divorced)
lab var divorced "Divorced/Separated"
table s1q5 divorced
recode s1q5 (6 = 1) (1/5 7 = 0), gen(widow)
lab var widow "Widow/Widower"
table s1q5 widow
recode s1q5 (7 =1) (1/6  = 0), gen(never_mrrd)
lab var never_mrrd "Never Married"
table s1q5 never_mrrd
recode s1q5 (2 = 1) (3/7 = 0), g(marrd) 
table s1q5 marrd

*Does the spouse live in the household
numlabel s1q6, add
tab s1q6, mi
recode s1q6 (2  = 0), gen(live_hhd)
lab var live_hhd "The spouse live in the household"
table s1q6 live_hhd

*Legal status of marriage
numlabel s1q8, add
tab s1q8,mi
recode s1q8 (2 = 0) if marrd == 1, gen(legal_marr)
lab var legal_marr "Legally married"
table s1q8 legal_marr 


*Property management
numlabel s1q10, add
tab s1q10 , mi
recode s1q10 (2/5 = 0), gen(community)
lab var community "Regime of community of property"
table s1q10 community
recode s1q10 (1 = 0) (2 = 1) (3/5 = 0), gen(ltd_community)
lab var ltd_community "Regime of ltd community of acquests"
table s1q10 ltd_community
recode s1q10 (1/2 = 0) (3 = 1) (4/5 = 0), gen(separation)
lab var separation "Separation of property"
table s1q10 separation
recode s1q10 (1/3 5 = 0) (4 = 1), gen(noprovision)
lab var noprovision "No provisions made"
table s1q10 noprovision

*Year married
inspect s1q11 /*some missing-maybe not married*/
tab s1q11 
tab s1q11 if head == 1&married == 1
gen year = 2018-s1q11 if head == 1&married == 1
lab var year "Years in marriage"

*Whether attended school-education
numlabel s1q12, add
tab s1q12, mi 
recode s1q12 (2  = 0), gen(school)
lab var school "Has head attended school"
table s1q12 school 

*Education level of head
numlabel s1q13, add
tab s1q13, mi
recode s1q13 (0/6 = 1) (7/18 = 2) (19/25 = 3) (98 .a = .) (97 = 0), gen(educ_lev)
table s1q13 educ_lev
lab value educ_lev educ_lev
lab define educ_lev  0 "Nursery" 1 "Primary" 2 "Sec/Vocational" 3 "University"
lab var educ_lev educ_lev
recode educ_lev (2/3  = 0) (0 = 1), gen(primary)
lab var primary "Primary Education"
table educ_lev primary
recode educ_lev (2 = 1) (1 3 = 0), gen(sec_vocational)
lab var sec_vocational "Secondary and vocational"
table educ_lev sec_vocational
recode educ_lev (3 = 1)(1/2 = 0), gen(tertiary)
lab var tertiary "University Education"
table educ_lev tertiary
g edu = .
replace edu = 0 if s1q13 == 0&s1q13 == 97
replace edu = 1 if s1q13 == 1
replace edu = 2 if s1q13 == 2
replace edu = 3 if s1q13 == 3
replace edu = 4 if s1q13 == 4
replace edu = 5 if s1q13 == 5
replace edu = 6 if s1q13 == 6
replace edu = 7 if s1q13 == 7
replace edu = 8 if s1q13 == 8
replace edu = 9 if s1q13 == 9
replace edu = 10 if s1q13 == 10
replace edu = 11 if s1q13 == 11
replace edu = 12 if s1q13 == 12
replace edu = 7 if s1q13 == 13
replace edu = 8 if s1q13 == 14
replace edu = 9 if s1q13 == 15
replace edu = 10 if s1q13 == 16
replace edu = 11 if s1q13 == 17
replace edu = 12 if s1q13 == 18
replace edu = 13 if s1q13 == 19
replace edu = 14 if s1q13 == 20
replace edu = 15 if s1q13 == 21
replace edu = 16 if s1q13 == 22
replace edu = 17 if s1q13 == 23
replace edu = 18 if s1q13 == 24
replace edu = 19 if s1q13 == 25
lab var edu "Years of schooling"

*Ability to read in various languages-hhd head
numlabel s1q14, add
tab s1q14, mi 
recode s1q14 (3 = 1) (1/2 = 0), gen(kinyarwanda)
table s1q14 kinyarwanda
lab var kinyarwanda "Able to read kinyarwanda"
numlabel s1q15, add
tab s1q15, mi
recode s1q15 (3 = 1) (1/2 = 0), gen(english)
table s1q15 english
lab var english "Able to read and write english"
numlabel s1q16, add
tab s1q16, mi
recode s1q16 (3 = 1) (1/2 = 0), gen(french)
table s1q16 french 
lab var french "Able to read and write French"

*Primary occupation 
numlabel s1q17, add
tab s1q17, mi 
recode s1q17 (3 = 1) (2 4/23 = 0), gen(agric)
table s1q17 agric /*checking if done correctly*/
lab var agric "Works in agriculture"
recode s1q17 (1 3 16/21 23= 0) (2 4/15 22 = 1), gen(non_agric) 
table s1q17 non_agric
lab var non_agric "Works in non-agric"

*Secondary occupation
numlabel s1q18, add
tab s1q18, mi
recode s1q18 (3 = 1) (2 4/97 = 0), gen(agric_sec)
table s1q18 agric_sec
recode s1q18 (2 4/15 22 = 1) (1 3 16/21 23 97 = 0), gen(nonagr_sec)
table s1q18 nonagr_sec
lab var agric_sec "Secondary occuption:Head works in agric"
lab var nonagr_sec "Secondary occuption:Head works in non-agric"

*Religous denomination
numlabel s1q19, add
tab s1q19, mi
recode s1q19 (2/9 = 0), gen(catholic)
table s1q19 catholic
recode s1q19 (2 = 1) (1 3/9 = 0), gen(protestant)
table s1q19 protestant
recode s1q19 (1/2 8 = 0) (3/7 9 = 1), gen(other)
table s1q19 other
lab var catholic "Head is catholic"
lab var protestant "Head is protestant"
lab var other "Other religion:Head"

*Household composition variables including hhd size
byso interview__id:egen hhdsize_1 = count(hhroster__id)
lab var hhdsize_1 "Household size"
byso interview__id: egen chdn = total(age <= 14) /*total number of chdn*/
lab var chdn "Number of children 0-14"
byso interview__id: egen nofemale = total(age <= 14&female ==1) /*female children less than 14*/
lab var nofemale "Number of female children below the age of 14"
byso interview__id: egen nomale = total(age <= 14&female ==0) /*male children less than 14*/
lab var nomale "Number of male children below the age of 14"
byso interview__id: egen youth = total(inrange(age, 15,34)) 
lab var youth "Number of youth 15-34"
byso interview__id: egen youthmale = total(inrange(age, 15,34) & female == 0)
lab var  youthmale "Number of male youth 15-34"
byso interview__id: egen youthfmale = total(inrange(age, 15,34) & female == 1) 
lab var  youthfmale "Number of female youth 15-34"
byso interview__id: egen adult = total(inrange(age, 35,60)) 
lab var adult "Number of adults 35-60"
byso interview__id: egen adultmale = total(inrange(age, 35,60) & female == 0) /* adult male between 35 and 60*/
lab var adultmale "Adult male aged between 35 and 60"
byso interview__id: egen adultfemale = total(inrange(age, 35,60) & female == 1) /* adult female between 35 and 60*/
lab var adultfemale "Adult female aged between 35 and 60"
byso interview__id: egen old = total(age > 60& age != .) 
lab var old "Number of elders"
byso interview__id: egen oldfemale = total(age > 60 & female == 1 & age != .) /* old female between 35 and 60*/
lab var oldfemale "Number of female members aged 60 and above"
byso interview__id: egen oldmale = total(age > 60 & female == 0 & age != .) /* old female between 15 and 60*/
lab var oldmale "Number of male members aged 60 and above"


*New parcels:list of newly acquired parcels
foreach var of varlist s3q1__0 s3q1__1 s3q1__2 s3q1__3 s3q1__4 s3q1__5 ///
s3q1__6 s3q1__7 s3q1__8 s3q1__9 {
replace `var' = "." if `var' == "##N/A##"
}
gen new0=real( s3q1__0)
replace s3q1__0 = "." if new0 ==19
forvalues i = 1/10 {
gen parcel`i' = 1

}

replace parcel1 = 0 if s3q1__0 == "."
replace parcel2 = 0 if s3q1__1 == "."
replace parcel3 = 0 if s3q1__2 == "."
replace parcel4 = 0 if s3q1__3 == "."
replace parcel5 = 0 if s3q1__4 == "."
replace parcel6 = 0 if s3q1__5 == "."
replace parcel7 = 0 if s3q1__6 == "."
replace parcel8 = 0 if s3q1__7 == "."
replace parcel9 = 0 if s3q1__8 == "."
replace parcel10 = 0 if s3q1__9 == "."
egen newparcel = rowtotal(parcel1 parcel2 parcel3 parcel4 parcel5 parcel6 ///
parcel7 parcel8 parcel9 parcel10)
drop new0
lab var newparcel "Parcels in"

*Parcels sold:transfers out
foreach var of varlist s4q1__0 s4q1__1 s4q1__2 s4q1__3 s4q1__4 s4q1__5 ///
s4q1__6 s4q1__7 s4q1__8 s4q1__9 {
replace `var' = "." if `var' == "##N/A##"
}
forvalues i = 1/10 {
gen parcelout`i' = 1

}

replace parcelout1 = 0 if s4q1__0 == "."
replace parcelout2 = 0 if s4q1__1 == "."
replace parcelout3 = 0 if s4q1__2 == "."
replace parcelout4 = 0 if s4q1__3 == "."
replace parcelout5 = 0 if s4q1__4 == "."
replace parcelout6 = 0 if s4q1__5 == "."
replace parcelout7 = 0 if s4q1__6 == "."
replace parcelout8 = 0 if s4q1__7 == "."
replace parcelout9 = 0 if s4q1__8 == "."
replace parcelout10 = 0 if s4q1__9 == "."
egen parcelout = rowtotal(parcelout*)
lab var parcelout "Parcels sold"

********************************************************************************
*SECTION 5: INSTITUTIONS AND LEGAL KNOWLEDGE
keep if head == 1 /*3 households with no head defined*/
*Can husband mortgage land without wife's consent
numlabel s5q1, add
tab s5q1 if head == 1, mi
recode s5q1 (2/3  = 0), gen(instwife_yes)
table s5q1 instwife_yes
recode s5q1 (2 = 1) (1 3  = 0), gen(instwife_no)
table s5q1 instwife_no
lab var instwife_yes "Husband can mortgage land without wife's consent"
lab var instwife_no "Husband canno mortgage land without wife's consent"

*Inheritance rights:Husband is no more
numlabel s5q2, add
tab s5q2, mi
recode s5q2 (2/5 = 0), gen(spouse)
table s5q2 spouse
lab var spouse "Spouse will own all the land"
recode s5q2 (1 3/5 = 0) (2 = 1), gen(spouse_50)
table s5q2 spouse_50
lab var spouse_50 "The spouse owns a 50% share, and the other is shared equally"
recode s5q2 (1/2 4/5 = 0) (3 =1), gen(equalshre)
table s5q2 equalshre
lab var equalshre "The spouse and chdn own equal shares"
recode s5q2 (1/3 5 = 0) (4 = 1), gen(childn)
table s5q2 childn
lab var childn "The children own all the land"

*Daughter/son inheritance if spouse were to die
numlabel s5q3, add
tab s5q3, mi
recode s5q3 (2/5 = 0), gen(son_inhe)
table s5q3 son_inhe
lab var son_inhe "Son will inherit"
recode s5q3 (1 3/5  = 0) (2 = 1), gen(son1)
table s5q3 son1
lab var son1 "Son inherit but will take care of others"
recode s5q3 (3 = 1) (1/2 4/5  = 0), gen(daughter)
table s5q3 daughter
lab var daughter "Daughter will inherit"
recode s5q3 (4 = 1) (1/3 5 = 0), gen(equaldiv)
table s5q3 equaldiv
lab var equaldiv "Equally divided"


*Joint titling under CPR
numlabel s5q4, add
tab s5q4, mi
recode s5q4 (2/4 = 0), gen(husband)
table s5q4 husband
lab var husband "Only husband name on cert under CPR"
recode s5q4 (2 = 1) (1 3/4 = 0), gen(wifeonly)
table s5q4 wifeonly
lab var wifeonly "Only wife name on cert under CPR"
recode s5q4 (3 = 1) (1/2 4 = 0), gen(both)
table s5q4 both
lab var both "Both names on the certificate"

*Husband purchasing land:joint titling
numlabel s5q5, add
tab s5q5, mi
recode s5q5 (2/4  = 0), gen(joseph)
table s5q5 joseph
lab var joseph "Register under the name of husband"
recode s5q5 (1 3/4  = 0) (2 = 1), gen(joint)
table s5q5 joint
lab var joint "Joint registration"
recode s5q5 (1/2 4 = 0) (3 = 1), gen(writ_consent)
table s5q5 writ_consent
lab var writ_consent "Written consent"
****
*Generate index for registration institutions
*Method 1: PCA
/*factor instwife_no equalshre equaldiv both joint
predict dreginst*/
*Method 2:
g dreginst = (instwife_no + equalshre + equaldiv + both + joint)/5
lab var dreginst "Index of knowlede of registration institutions"
*Knowledge about inheritance registration: where to go to legally register transfer
foreach var of varlist s5q6__1 s5q6__2 s5q6__3 s5q6__4 s5q6__5 {
tab `var', mi
}
ren s5q6__1 vill_leaders
ren s5q6__2 cell_leader
ren s5q6__3 sec_leader
ren s5q6__4 dist_land
ren s5q6__5 nat_land
g d_one = sec_leader + dist_land + nat_land
recode d_one (2/3 = 1), g(d1)
lab var d1 "At least one correct answer"
recode d_one (1/2 = 0) (3 = 1), g(dall)
lab var dall "All correct answers"
recode d_one (0 = 1) (1/3 = 0), g(dnone)
lab var dnone "All incorrect answers"
gen dincorrt = vill_leaders + cell_leader
recode dincorrt (2 = 1)
lab var dincorrt "At least one incorrect answer"

*Registration fee :inheritance
inspect s5q7 /* some negative values trnsform to missing*/
list s5q7 if s5q7 < 0
replace s5q7 = . if s5q7 < 0

sum s5q7 if head == 1
ren s5q7 reg_fee
replace reg_fee = . if reg_fee == 99
winsor2 reg_fee if reg_fee!=. , replace cuts(15 85)
*Type of doc:inheritance
foreach var of varlist s5q8__1 s5q8__2 s5q8__3 s5q8__4 s5q8__5 s5q8__6 {
tab `var', mi 
}

ren s5q8__1 inheritance
ren s5q8__2 land_lease
ren s5q8__3 reg_cert
ren s5q8__4 cad_map
ren s5q8__5 app_form
ren s5q8__6 identity

*Places to register sales transaction
foreach var of varlist s5q9__1 s5q9__2 s5q9__3 s5q9__4 s5q9__5 { 
tab `var', mi 
}
ren s5q9__1 villlead_sal
ren s5q9__2 cell_sales
ren s5q9__3 land_sales
ren s5q9__4 dislnd_sales
ren s5q9__5 nati_sales
g d_onesles = land_sales + dislnd_sales + nati_sales
recode d_onesles (2/3 = 1), g(d1_sles)
lab var d1_sles "At least one correct answer"
recode d_onesles (1/2 = 0) (3 = 1), g(dall_sles)
lab var dall_sles "All correct answers"
recode d_onesles (0 = 1) (1/3 = 0), g(dnone_sles)
lab var dnone_sles "All incorrect answers"
gen dincorrt_sles = villlead_sal + cell_sales
recode dincorrt_sles (2 = 1)
lab var dincorrt_sles "At least one incorrect answer"

*Registration fees sales
inspect s5q10
list s5q10 if s5q10 < 0
replace s5q10 = . if s5q10 < 0
replace s5q10 = . if s5q10 == 99
sum s5q10 if head == 1
ren s5q10 regfee_sales
winsor2 regfee_sales if regfee_sales!=., replace cuts(15 85)

*Required doc for sales transaction and where to initiate land use change
foreach var of varlist s5q11__1 s5q11__2 s5q11__3 s5q11__4 s5q11__5 s5q11__6 ///
s5q11__7 s5q12__1 s5q12__2 s5q12__3 s5q12__4 s5q12__5 {
tab `var', mi
}

ren (s5q11__1 s5q11__2 s5q11__3 s5q11__4 s5q11__5 s5q11__6 ///
s5q11__7 s5q12__1 s5q12__2 s5q12__3 s5q12__4 s5q12__5) (agre_aut lease_sales ///
regcert_sales cadmap_sales appform_sales id_sales informa_sales villder_use ///
celleader_use secland_use distland_use natnal_use)
****
g d_oneuse = secland_use + distland_use + natnal_use
recode d_oneuse (2/3 = 1), g(d1_use)
lab var d1_use "At least one correct answer"
recode d_oneuse (1/2 = 0) (3 = 1), g(dall_use)
lab var dall_use "All correct answers"
recode d_oneuse (0 = 1) (1/3 = 0), g(dnone_use)
lab var dnone_use "All incorrect answers"
gen dincorrt_use = villder_use + celleader_use
recode dincorrt_use (2 = 1)
lab var dincorrt_use "At least one incorrect answer"

*Payment for land use change
inspect s5q13
list s5q13 if s5q13 < 0
replace s5q13 = . if s5q13 < 0
replace s5q13 = . if s5q13 == 99
ren s5q13 landuse_fee
sum landuse_fee if head == 1
winsor2 landuse_fee if landuse_fee!=., replace cuts(15 85)
***
*Regist fee
foreach var of varlist reg_fee regfee_sales landuse_fee {
g _`var' = 100*(`var'/27000)
}

*Documents for land use change
foreach var of varlist s5q14* {
tab `var', mi
}
ren (s5q14__1 s5q14__2 s5q14__3 s5q14__4 s5q14__5) (lndlease_use regcert_use ///
cadmap_use appform_lease id_use)
so interview__id hhroster__id
numlabel, remove
so interview__id
drop interview__key hhroster__id province province_cd  ///
district district_cd sector sector_cd  cell cell_cd cell_cd-name ///
phone_confirm phone_corrected s1q3 s1q4_corrected s1q6-s5q3  year educ_lev parcel1-parcelout 
lab var _reg_fee "Inheritance fee"
lab var _regfee_sales "Sales fee"
lab var _landuse_fee "Landuse change fee"
save "$temp\hhd_merged", replace
//save "$tmp\household", replace
keep interview__id s1q2
save "$tmp\hhdgender", replace

********************************************************************************

/*MERGING HHD DATA WITH PARCLES DATA TO GET LAND PARTICIPATION
use "$temp\oproster", clear
d
keep yearcert interview__id
tab yearcert, mi
keep if yearcert >= 2013&yearcert !=.
duplicates drop interview__id, force
so interview__id
save "$tmp\oproster_tmhhd", replace
use "$tmp\household", clear
*Merge with Old parcel roster to det hhd registering land
merge 1:1 interview__id using "$tmp\oproster_tmhhd"
//drop if _merge == 2
gen land = _merge
drop _merge yearcert
tab land
recode land (3 = 2) 
lab def land 1 "Not register" 2 "Registered"
lab val land land
lab var land "Had registered parcel"
recode land (1 = 0) (2 = 1), gen(land_dummy)
table land land_dummy
save "$tmp\hhd_opro_tm", replace

use "$temp\fragroster", clear
d
keep interview__id s2q11f
tab s2q11f, mi
keep if s2q11f >= 2013&s2q11f <= 2018
duplicates drop interview__id, force
so interview__id
save "$tmp\fragtom", replace
use "$tmp\hhd_opro_tm", clear
merge 1:1 interview__id using "$tmp\fragtom"
//drop if _merge == 2
gen land_frag = _merge
drop _merge s2q11f
tab land_frag
recode land_frag (3 = 2) 
lab def land_frag 1 "NotTransffrag"  2 "Transffrag"
lab val land_frag land_frag
lab var land_frag "Transferred fragments from old parcels"
recode land_frag (1 = 0) (2 = 1), gen(landfrag_dummy)
save "$tmp\hhd_opro_frag_tm", replace

use  "$temp\newproster", clear
d
keep s3q10 interview__id
tab s3q10, mi
replace s3q10 = . if s3q10 == -99
replace s3q10 = 2014 if s3q10 == 20014
replace s3q10 = 2015 if s3q10 == 20015
replace s3q10 = 2008 if s3q10 == 20088
replace s3q10 = 2012 if s3q10 == 20129
keep if s3q10 >= 2013&s3q10 <= 2018
drop s3q10
duplicates drop 
save "$tmp\newptm", replace
use "$tmp\hhd_opro_frag_tm", clear
merge 1:1 interview__id using "$tmp\newptm"
//drop if _merge == 2
gen land_acq = _merge
drop _merge 
tab land_acq
recode land_acq (3 = 2) 
lab def land_acq 1 "NotAcqdland" 2 "Acqland"
lab val land_acq land_acq
lab var land_acq "Acquired land/new parcel"
recode land_acq (1 = 0) (2 = 1), gen(landacq_dummy)
save "$tmp\hhd_opro_frag_np_tm", replace

use "$temp\toroster", clear
d
codebook interview__id
keep interview__id 
duplicates drop
so interview__id
save "$tmp\tro_tm", replace
use "$tmp\hhd_opro_frag_np_tm", clear
merge 1:1 interview__id using "$tmp\tro_tm"
//drop if _merge == 2
gen land_sold = _merge
drop _merge
tab land_sold, mi
recode land_sold (3 = 2) 
lab def land_sold 1 "Notsold" 2 "Sold"
lab val land_sold land_sold
lab var land_sold "Land/parcels sold"
recode land_sold (1 = 0) (2 = 1), gen(landsold_d)
save "$tmp\hhd_opro_frag_np_tr_tm", replace

use "$temp\tofragroster", clear
d
keep interview__id s4q11f
tab s4q11f, mi
keep if s4q11f >= 2013&s4q11f <= 2018
duplicates drop interview__id, force
so interview__id
save "$tmp\tofrag_tm", replace
use "$tmp\hhd_opro_frag_np_tr_tm", clear
merge 1:1 interview__id using "$tmp\tofrag_tm"
//drop if _merge == 2
gen land_soldfrag = _merge
drop _merge s4q11f
tab land_soldfrag
recode land_soldfrag (3 = 2) 
lab def land_soldfrag 1 "Notsoldfrag" 2 "Soldfrag"
lab val land_soldfrag land_soldfrag
lab var land_soldfrag "Fragments sold or taken away"
recode land_soldfrag (1 = 0) (2 = 1), gen(landsoldfrag)
/*egen dropid = group(province_cd district_cd sector_cd cell_cd village_cd)

*Dropping villages in pretest as advised by Daniel
foreach i in 1 2 3 4 {
drop if dropid == `i'
}
*merge with asset roster
merge 1:1 interview__id using "$temp\asset_quartiles"
keep if _merge == 3
drop _merge
*/ */

********************************************************************************
********************************************************************************
*SECTION 2:OLD PARCEL ROSTER
use "$temp\oproster", clear
egen oparcelid = group(interview__id oproster__id) /*Old Parcel identification*/
order oparcelid, before(village_parcel)
 
*Village where parcel is located
tab village_parcel, mi
encode village_parcel, gen(villparcel)
order villparcel, after(village_parcel)
lab list villparcel

*Unique parcel identifier
codebook upi

*Area of parcel
inspect area
sum area /*average area in square metres*/
*Covert to ha by dividing by 10000
gen area1 = area/10000
drop area 
ren area1 area
sum area
lab var area "Area in hectares"

*Ownership of parcel
numlabel s2q3, add
tab s2q3, mi
recode s2q3 (2/3  = 0), gen(own)
table s2q3 own
lab var own "Own all"
recode s2q3 (2 = 1) (1 3  = 0), gen(part)
table s2q3 part
lab var part "Own part"
recode s2q3 (1/2  = 0) (3 = 1), gen(noown) 
table s2q3 noown
lab var noown "No longer owns"

*Land use of parcel
foreach var of varlist s2_landuse__1 s2_landuse__2 s2_landuse__3 s2_landuse__4 ///
s2_landuse__5 s2_landuse__6 {
tab `var', mi
}
g dresid = (s2_landuse__1 == 1 | s2_landuse__4 == 1) if s2_landuse__1 !=. & s2_landuse__1 !=.a
g dagric = s2_landuse__2==1 | s2_landuse__3==1 |  s2_landuse__5==1 | s2_landuse__6==1 if s2_landuse__1 !=. & s2_landuse__1 !=.a
g mixeduse = dresid == 1 & dagric == 1 if dresid!=.
for var dresid dagric: recode X 1=0 if mixeduse==1

lab var dresid "Residential"
lab var dagric "Agricultural"
lab var mixeduse "Mixed use"

g landuse = .
replace landuse = 1 if dresid == 1
replace landuse = 2 if dagric == 1
replace landuse = 3 if mixeduse == 1
lab def landuse 1 "Residential" 2 "Agricultural" 3 "Mixed use"
lab val landuse landuse

*Area still owned 
inspect s2q4
gen area_owned = s2q4/10000
sum area_owned

*Land certificate or lease contract
numlabel cert, add
tab cert, mi
recode cert (2 = 0), gen(certificate)
table cert certificate
lab var certificate "Land certificate for the parcel"
g dnocert = cert == 2 if cert !=.

*Year certificate was issued
tab yearcert if certificate == 1, mi

*Reason for not possessing a certificate
numlabel nocert, add
tab nocert if certificate == 0, mi
recode nocert (2/5 = 0), gen(unrdispute)
table nocert unrdispute 
lab var unrdispute "Unresolved dispute"
recode nocert (2 = 1) (1 3/5 = 0), gen(wetland)
table nocert wetland
lab var wetland "Located in wetland"
recode nocert (3 = 1) (1/2 4/5 = 0), gen(notpicked)
table nocert notpicked
lab var notpicked "Cert issued but not picked"
recode nocert (4 = 1) (1/3 5 = 0), gen(notready)
table nocert notready
lab var notready "Cert not ready"

*Year of aquisition
tab s2q1, mi

numlabel nopickcert, add
tab nopickcert, mi
recode nopickcert (2/4 = 0), gen(nopayfee)
table nopickcert nopayfee
lab var nopayfee "Reason for not picking certificate/lease contract:Does not want to pay"
recode nopickcert (2 = 1) (1 3/4 = 0), gen(notime)
table nopickcert notime
lab var notime "Reason for not picking certificate/lease contract: No time-will pick up later"
recode nopickcert (3 = 1) (1/2 4 = 0), gen(stayoffice)
table nopickcert stayoffice 
lab var stayoffice "Reason for not picking certificate/lease contract:Want docs to stay in dist land office"

*How was the parcel acquired
numlabel s2q2, add
tab s2q2, mi
recode s2q2 (2 = 1) (3/7 = 0), gen(market)
table s2q2 market
lab var market "Market"
recode s2q2 (3/4 = 1) (1/2 5/7  = 0), gen(inheritance)
table s2q2 inheritance
lab var inheritance "Inheritance"
recode s2q2 (5/7 = 1) (1/4 = 0), g(other)
table s2q2 other
recode s2q2 (2 = 1) (3/4 = 2) (4/7 = 3), g(mode_tr)
table s2q2 mode_tr
lab def mode_tr 1 "Market" 2 "Inheritance" 3 "NonMarket_other"
lab val mode_tr mode_tr
*Cadastral map for subdivision
numlabel s2q5, add
tab s2q5, mi
recode s2q5 (1/3 =1), gen(trnsout_part)
table s2q5 trnsout_part
tab trnsout_part
lab var trnsout_part "Those who transfered out part of parcel"
g map_yes = s2q5 == 1 if s2q5!=.
table s2q5 map_yes
lab var map_yes "Obtained cadastral map for subdivision"
g ongoing = s2q5 == 2 if s2q5!=.
table s2q5 ongoing
lab var ongoing "Process ongoing"
g noobtain = s2q5 == 3  if s2q5!=.
table s2q5 noobtain
lab var noobtain "Did not obtain map"

*Parcel divided before transfer
numlabel s2q6, add
tab s2q6, mi
g subdivision = s2q6  == 1 if s2q6!=.
table s2q6 subdivision
lab var subdivision "Parcel subdivided into multiple plots before transfered"

*No of subdivisions
inspect s2q7
sum s2q7
ren s2q7 nosubdiv
lab var nosubdiv "No of subdivisions before transfer"

*Cadastral Maps for fragments
numlabel s2q8, add
tab s2q8, mi
g mapyes = s2q8 == 1 if s2q8!=.
table s2q8 mapyes
lab var mapyes "Obtained cad maps for fragments"
g ong_fra = s2q8 == 2 if s2q8!=.
table s2q8 ong_fra
lab var ong_fra "Process for obtaining cad map for fragements ongoing"
g no_fra = s2q8 == 3 if  s2q8!=.
table s2q8 no_fra
lab var no_fra "Not obtained cad map for fragments"

*Reason for not obtaining cad map
numlabel s2q9, add
tab s2q9, mi
recode s2q9 (2/4 = 0), gen(notknow)
table s2q9 notknow
lab var notknow "Not know if new maps were needed"
recode s2q9 (2 = 1) (1 3/4 = 0), gen(afford)
table s2q9 afford
lab var afford "Could not afford the costs"
recode s2q9 (3 = 1) (1/2 4 = 0), gen(toosmall)
table s2q9 toosmall
lab var toosmall "Parcel too small to subdivide"


*No of fragments transfered out
inspect s2q10
sum s2q10
so interview__id
numlabel, remove
preserve
keep if s2q1 >=2013&s2q1<=2018
save "$temp\acquired2018", replace
restore

preserve
keep interview__id oproster__id area s2q3 s2q6 nosubdiv map_yes ongoing noobtain
keep if s2q3 == 3
save "$temp\give2013", replace
restore

preserve
keep interview__id oproster__id s2q3 area s2q6 s2q10
keep if s2q3==2 | s2q3==3
sort interview__id oproster__id
save "$temp\fraggive2013", replace
restore

drop interview__key oproster__id village_parcel villparcel owner_parcel upi ///
parcel_name
save "$temp\oldparcel1", replace
keep if yearcert >=2013&yearcert!=. /*restricted to transactions since 2013*/
keep interview__id oparcelid certificate dnocert market inheritance map_yes ongoing noobtain
save "$temp\oldparcel_to", replace
use "$tmp\household2018_to", clear
keep interview__id province_cd 
merge 1:m interview__id using "$temp\oldparcel_to"
keep if _merge == 3
drop interview__id _merge
capture table1 province_cd using $tmp\, id(oparcelid) order
export excel using "$temp\olparce_d", firstrow(var) replace
********************************************************************************

*SECTION 2: TRANSFERRED FRAGMENTS ROSTER

use "$temp\fragroster", clear
d
isid interview__id oproster__id fragroster__id
egen oldfragid = group(interview__id oproster__id fragroster__id)
*Location of indiv where fragment was transfered
numlabel s2q11b, add
tab s2q11b, mi
recode s2q11b (2/6 = 0), gen(samevill)
table s2q11b samevill
lab var samevill "Same village"
recode s2q11b (2 = 1) (1 3/6 = 0), gen(anvill_op)
table s2q11b anvill_op
lab var anvill_op "Another village, this cell"
recode s2q11b (3 = 1) (1/2 4/6 = 0), gen(ancell_op)
table s2q11b ancell_op
lab var ancell_op "Another cell, this sector"
recode s2q11b (4 = 1) (1/3 5/6 = 0), gen(ansect_op)
table s2q11b ansect_op
lab var ansect_op "Another sector, this district"
recode s2q11b (5 = 1) (1/4 6 = 0), gen(andist_op)
table s2q11b andist_op
lab var andist_op "Another district"
recode s2q11b (6 = 1) (1/5 = 0), gen(abroad_op)
table s2q11b abroad_op 
lab var abroad_op "Abroad"

*Gender of individual where frag was transferred
numlabel s2q11c, add
tab s2q11c, mi
g female_op = s2q11c == 2 if s2q11c!=.
table s2q11c female_op
lab var female_op "Fragment transferred to female"
g male_opfr = s2q11c == 1 if s2q11c!=.
lab var male_opfr "Fragment transferred to male"

*Relationship to head of indiv where parcel was tranferred
numlabel s2q11d, add
tab s2q11d, mi
g parent = s2q11d ==2 if s2q11d!=.
table s2q11d parent
lab var parent "Parcel transferred to parent"
g son_daughter = s2q11d == 1 if s2q11d!=. 
table s2q11d son_daughter
lab var son_daughter "Parcel transfer to Son/Daughter/grand child"
recode s2q11d (3 =1) (1/2 4/15 .a . = 0), gen(spouse_frag)
table s2q11d spouse_frag
lab var s2q11d "Spouse:Fragments transferred to"
recode s2q11d (4 = 1) (1/3 5/15 = 0), gen(brother)
table s2q11d brother
lab var brother "Brother/sister:Fragments tranferred to"
recode s2q11d (5 = 1) (1/4 6/15 = 0), gen(uncle)
table s2q11d uncle 
lab var uncle "Uncle/Aunt: Fragments transferred to"
recode s2q11d (6 = 1) (1/5 7/15 = 0), gen(grand_parent)
table s2q11d grand_parent
lab var grand_parent "Grand parent: Fragments transferred to"
recode s2q11d (7 = 1) (1/6 8/15 = 0), gen(nephew)
table s2q11d nephew
lab var nephew "Nephew/Niece:Fragments transferred to"
recode s2q11d (8 = 1) (1/7 9/15 = 0), gen(cousin)
table s2q11d cousin
lab var cousin "Cousin/relative: Fragments transferred to"
recode s2q11d (9 = 1) (1/8 10/15 = 0), gen(son_inlaw)
table s2q11d son_inlaw
lab var son_inlaw "Son, daughter, or grand child-in law: Fragments transferred to"
recode s2q11d (10 = 1) (1/9 11/15 = 0), gen(parent_inlaw)
table s2q11d parent_inlaw
lab var parent_inlaw "Parent-in-law, grand parent-in-law;Fragemnts transferred to"
recode s2q11d (11 = 1) (1/10 12/15 = 0), gen(brother_inlaw)
table s2q11d brother_inlaw
lab var brother_inlaw "Brother/Sister-in-law: Fragments transferred to"
recode s2q11d (12 = 1) ( 1/11 13/15 = 0), gen(friend)
table s2q11d friend
lab var friend "Friend: Fragments transferred to"
recode s2q11d (13 = 1) (1/12 14/15 = 0), gen(neighbor)
table s2q11d neighbor
lab var neighbor "Neighbor: Fragments transferred to"
recode s2q11d (14 = 1) (1/13 15 = 0), gen(busi_part)
table s2q11d busi_part
lab var busi_part "Business partner: Fragments transferred to"
g other_tofra = s2q11d == 15 if  s2q11d!=.
table s2q11d other_tofra
lab var other_tofra "Parcel transferred to other unrelated person"

*Area of fragment taken away
inspect s2q11e
gen area_tofrag = s2q11e/10000
sum area_tofrag
lab var area_tofrag "Area of fragment taken away"
*Year transferred
tab s2q11f, mi

*How was fragment transferred out?
numlabel s2q11g, add
tab s2q11g, mi
g frag_sold = s2q11g == 1 if  s2q11g!=.
table s2q11g frag_sold
lab var frag_sold "Market"
g frag_beq = s2q11g == 2 if s2q11g!=.
table s2q11g frag_beq
lab var frag_beq "Fragment bequeted, given away, donated"
recode s2q11g (3 = 1) (1/2 4/5 = 0), gen(auth_frag)
table s2q11g auth_frag
lab var auth_frag "Taken by authorities"
recode s2q11g (4 = 1) (1/3 5  = 0), gen(traded_frag)
table  s2q11g traded_frag
lab var traded_frag "Traded for another land"

inspect s2q11h
numlabel, remove

preserve
sort interview__id oproster__id
merge interview__id oproster__id using "$temp\fraggive2013"
drop if _mer==1
keep interview__id oproster__id fragroster__id female_op male_opfr parent ///
son_daughter other_tofra frag_sold frag_beq s2q11f s2q11h
keep if s2q11f >=2013&s2q11f<=2018
drop s2q11f
save "$temp\fraggive", replace
restore


save "$temp\fragroster_1.dta", replace
keep if s2q11f >=2013&s2q11f<=2018
keep interview__id oldfragid female_op male_opfr parent son_daughter other_tofra frag_sold frag_beq
save "$temp\fragroster_1to.dta", replace 
use "$tmp\household2018_to", clear
keep interview__id province_cd 
merge 1:m interview__id using "$temp\fragroster_1to.dta"
keep if _merge == 3
drop interview__id _merge
save "$temp\fragroster_an", replace
/*cap table1 province_cd using $tmp\, id(oldfragid) order
export excel using "$temp\oldfrag_d2", firstrow(var) replace
*/

use "$temp\fragroster_an", clear
keep if frag_sold == 1
cap table1 province_cd using $tmp\, id(oldfragid) order
export excel using "$temp\oldfrag_mkt", firstrow(var) replace
use "$temp\fragroster_an", clear
/*keep if frag_beq == 1
cap table1 province_cd using $tmp\, id(oldfragid) order
export excel using "$temp\oldfrag_inh", firstrow(var) replace
*/
********************************************************************************
********************************************************************************

*SECTION 3: NEW PARCEL ROSTER DATA: PARCEL IN
use "$temp\newproster", clear
isid interview__id newproster__id  /*unique identifiers*/
d
egen newparcelid = group(interview__id newproster__id) /*New parcel identification*/
*Location of parcel: 
numlabel s3q2, add
tab s3q2, mi
recode s3q2 (2/4 = 0), gen(thisvillage)
table s3q2 thisvillage
lab var thisvillage "New parcel located in the village"
recode s3q2 (2 = 1) (1 3/4 = 0), gen(anvill)
table s3q2 anvill
lab var anvill "New parcel located in another village"
recode s3q2 (3 = 1) (1/2 4 = 0), gen(ancell)
table s3q2 ancell
lab var ancell "New parcel located in another cell"

*Unique Parcel Identifcation
tab s3q3 /*know upi*/
codebook s3q4 /*lot of missing values*/

*LOCATION OF PERSON FROM WHOM PARCEL WAS ACQUIRED
numlabel s3q6, add
tab s3q6, mi
recode s3q6 (2/7 .a = 0), gen(thisvill_acq)
table s3q6 thisvill_acq
lab var thisvill_acq "Acquired from a person in this village"
recode s3q6 (2 = 1) (1 3/7 = 0), gen(anvill_acq)
table s3q6 anvill_acq
lab var anvill_acq "Acquired from a person in another village"
recode s3q6 (3 = 1) (1/2 4/7 = 0), gen(ancell_acq)
table s3q6 ancell_acq
lab var ancell_acq "Acquired from a person in another cell"
recode s3q6 (4 = 1) (1/3 5/7 = 0), gen(ansec_acq)
table s3q6 ansec_acq
lab var ansec_acq "Acquired from a person in another sector"
recode s3q6 (5 = 1) (1/4 6/7 = 0), gen(andistric_acq)
table s3q6 andistric_acq
lab var andistric_acq "Acquired from person from another district"
recode s3q6 (6 = 1) (1/5 7 = 0), gen(abroad)
table s3q6 abroad
lab var abroad "Acquired from a person living abroad"
recode s3q6 (7 = 1) (1/6 = 0), gen(deceased)
table s3q6 deceased
lab var deceased "Acquired from a deceased person"

*Gender of the person whom land was acquired from
numlabel s3q7, add
tab s3q7, mi
recode s3q7 (2 = 1) (1 3 = 0), gen(female_acq)
table s3q7 female_acq
lab var female "Parcels acquired from female"
recode s3q7 (2/3 = 0), gen(male_acq)
table s3q7 male_acq
lab var male_acq "Parcels acquired from males"

*Relationship to head from whom parcel was acquired
numlabel s3q8, add
tab s3q8, mi
recode s3q8 (2 = 1) (1 3/15 = 0), gen(parent)
table s3q8 parent
lab var parent "Parcel acquired from parent"
recode s3q8 (2/15 .a . = 0), gen(son_daughter)
table s3q8 son_daughter
lab var son_daughter "Parcel acquired from Son/Daughter/grand child"
recode s3q8 (3 =1) (1/2 4/15 = 0), gen(spouse_frag)
table s3q8 spouse_frag
lab var s3q8 "Spouse:Parcel acquired from"
recode s3q8 (4 = 1) (1/3 5/15 = 0), gen(brother)
table s3q8 brother
lab var brother "Brother/sister:Parcel acquired from"
recode s3q8 (5 = 1) (1/4 6/15 = 0), gen(uncle)
table s3q8 uncle 
lab var uncle "Uncle/Aunt: Parcel acquired from"
recode s3q8 (6 = 1) (1/5 7/15  = 0), gen(grand_parent)
table s3q8 grand_parent
lab var grand_parent "Grand parent: Parcel acquired from"
recode s3q8 (7 = 1) (1/6 8/15 = 0), gen(nephew)
table s3q8 nephew
lab var nephew "Nephew/Niece:Parcel acquired from"
recode s3q8 (8 = 1) (1/7 9/15 = 0), gen(cousin)
table s3q8 cousin
lab var cousin "Cousin/relative: Parcel acquired from"
recode s3q8 (9 = 1) (1/8 10/15 = 0), gen(son_inlaw)
table s3q8 son_inlaw
lab var son_inlaw "Son, daughter, or grand child-in law: Parcel acquired from"
recode s3q8 (10 = 1) (1/9 11/15 = 0), gen(parent_inlaw)
table s3q8 parent_inlaw
lab var parent_inlaw "Parent-in-law, grand parent-in-law;Parcel acquired from"
recode s3q8 (11 = 1) (1/10 12/15 = 0), gen(brother_inlaw)
table s3q8 brother_inlaw
lab var brother_inlaw "Brother/Sister-in-law: Parcel acquired from"
recode s3q8 (12 = 1) ( 1/11 13/15 = 0), gen(friend)
table s3q8 friend
lab var friend "Friend: Parcel acquired from"
recode s3q8 (13 = 1) (1/12 14/15 = 0), gen(neighbor)
table s3q8 neighbor
lab var neighbor "Neighbor: Parcel acquired from"
recode s3q8 (14 = 1) (1/13 15 = 0), gen(busi_part)
table s3q8 busi_part
lab var busi_part "Business partner: Parcel acquired from"
recode s3q8 (15 = 1) (1/14 = 0), gen(other_tofra)
table s3q8 other_tofra
lab var other_tofra "Parcel acquired from unrelated person"


*Area of new parcel
inspect s3q9
replace s3q9 = . if s3q9 <= 0 /*replace negative and zero values with missing*/
gen area_acq = s3q9/10000
sum area
lab var area_acq "Area of newly acquired parcel in hectares"

*Land use new parcel
foreach var of varlist s3_landuse__1 s3_landuse__2 s3_landuse__3 s3_landuse__4 ///
s3_landuse__5 s3_landuse__6 {
tab `var', mi
}
g dresid = (s3_landuse__1 == 1 | s3_landuse__4 == 1) if s3_landuse__1 !=. & s3_landuse__1 !=.a
g dagric = s3_landuse__2==1 | s3_landuse__3==1 |  s3_landuse__5==1 | s3_landuse__6==1 if s3_landuse__1 !=. & s3_landuse__1 !=.a
g mixeduse = dresid == 1 & dagric == 1 if dresid!=.
for var dresid dagric: recode X 1=0 if mixeduse==1

lab var dresid "Residential"
lab var dagric "Agricultural"
lab var mixeduse "Mixed use"

g landuse = .
replace landuse = 1 if dresid == 1
replace landuse = 2 if dagric == 1
replace landuse = 3 if mixeduse == 1
lab def landuse 1 "Residential" 2 "Agricultural" 3 "Mixed use"
lab val landuse landuse

*Year of acquisition
tab s3q10, mi
replace s3q10 = . if s3q10 == -99
replace s3q10 = 2014 if s3q10 == 20014
replace s3q10 = 2015 if s3q10 == 20015
replace s3q10 = 2008 if s3q10 == 20088
replace s3q10 = 2012 if s3q10 == 20129
gen year2013 =(s3q10>=2013&s3q10<=2018) /*dummy for land acquired 2013 and after*/
table s3q10 year2013
keep if year2013 == 1 /*restricting to new parcels since January 2013*/


*Mode of acquisition
numlabel s3q11, add
tab s3q11, mi
recode s3q11 (2 = 1) (3/7  = 0), gen(market)
table s3q11 market
lab var market "Newly acquired parcel was purchased"
recode s3q11 (3/4 = 1) (1/2 5/7 = 0), gen(inheritance)
table s3q11 inheritance
lab var inheritance "New parcel inherited"
recode s3q11 (5/7 = 1) (1/4 = 0), gen(other)
table s3q11 other
lab var other "Other means"

recode s3q11 (2 = 1) (3/4 = 2) ( 5/7 = 3), g(mode_tr)
table s3q11 mode_tr
lab def mode_tr 1 "Market" 2 "Inherited" 3 "NonMarket_other"
lab val mode_tr mode_tr
lab var mode_tr "Mode of acquisition"
*Purchase value
inspect s3q12
sum s3q12, d
winsor2 s3q12 if s3q12!=., replace cuts(10 90)

*Informed village leaders, land cert and hhd member listed
foreach var of varlist s3q13 s3q14 s3q15 {
tab `var', mi

recode `var' (2 = 0), gen(_`var')
}
g regis = s3q14 == 1&s3q15 == 1
lab var regis "Officially registered"
g ivleader = s3q13 == 1 if s3q13!=.
lab var ivleader "Reported to village leaders"

*Started registration
numlabel s3q17, add
tab s3q17, mi
recode s3q17 (2 = 1) (3  = 0), gen(startreg)
table s3q17 startreg
lab var startreg "Started registration of transaction"

*Reasons for not registering
foreach var of varlist s3q18__1 s3q18__2 s3q18__3 s3q18__4 s3q18__5 s3q18__6 ///
s3q18__7 s3q18__8 s3q18__9 {
tab `var', mi
}
for var s3q18*: recode X 2=.67 3=.33

g dclnreq = s3q18__1 if s3q18__2<=1
g dcexp =s3q18__2 if s3q18__2<=1
g dclknw = s3q18__4 if s3q18__4<=1
g dcofar = s3q18__3 if s3q18__3<=1
g dcflt = s3q18__5 if s3q18__5<=1
g dcsdna = s3q18__6 if s3q18__6<=1
g dcsdcost = s3q18__7 if s3q18__7<=1
g dcdisp = s3q18__8 if s3q18__8<=1

*how much wtp for transaction registration
inspect s3a19
list s3a19 if s3a19 < 0
replace s3a19 = . if s3a19 < 0
ren s3a19 wtp_value_newr 
winsor2 wtp_value_newr if wtp_value_newr!=., replace cuts(1 99)

*Stage of registration
numlabel s3q20, add
tab s3q20, mi
recode s3q20 (2/4  = 0), gen(formpicked)
table s3q20 formpicked
lab var formpicked "Stage in the registration process:form picked"
recode s3q20 (2 = 1) (1 3/4 = 0), gen(appl_sub)
table s3q20 appl_sub
lab var appl_sub "Stage in the registration process:application submitted"
recode s3q20 (3 = 1) (1/2 4 = 0), gen(transfr_sig)
table s3q20 transfr_sig
lab var transfr_sig "Stage in the registration process:transfer signed"
numlabel, remove
so interview__id
save "$temp\newparcel", replace
keep interview__id newparcelid newproster__id s3q4 market inheritance other regis startreg ivleader ///
wtp_value_newr mode_tr area_acq s3q10 s3q11 s3q12 s3q16* dresid dagric mixeduse ///
dclnreq-dcdisp landuse
ren (s3q4 area_acq) (upi area)
save "$tmp\newparcelto",replace
use "$temp\acquired2018", clear
keep interview__id oproster__id  upi market inheritance other certificate mode_tr ///
owner_parcel area  s2q1 dresid dagric mixeduse landuse
ren (oproster__id certificate s2q1 ) (newproster__id  regis s3q10)
recode regis (0 = 1) /*all to be added to registered category from oldroster*/
save "$temp\acquired2018to", replace
use "$tmp\newparcelto", clear
append using "$temp\acquired2018to"
save "$tmp\newpacquired", replace

use "$tmp\household2018_to", clear
keep interview__id province_cd 
merge 1:1 interview__id using "$tmp\hhdgender"
keep if _mer == 3
drop _merge
merge 1:m interview__id using "$tmp\newpacquired"
keep if _merge == 3
drop _merge /*interview__id*/
lab def regis 0 "Not Registered" 1 "Registered"
lab val regis regis
g not_reg = regis == 0
g registered = regis == 1
lab var not_reg "Not officially registered"
lab var registered "Registered"
drop newparcelid /*comment this when merging with regname data*/
egen newparcelid = group(interview__id newproster__id) /*comment this when merging with regname data*/
save "$temp\newparcelmgd", replace

/*use "$temp\newparcelmgd", clear
keep if market == 1
capture table1 prov_code s1q2 using $tmp\, id(newparcelid) order
replace label="Amount willing to pay to register the transfer" if variables=="wtp_value_newr"
replace label="Newly acquired parcel was purchased" if variables=="market"
replace label="New parcel inherited" if variables=="inheritance_n~r"
replace label="RECODE of s3q14 (Possession of land certificate and lease)" if variables=="_s3q14"
replace label="Not officially registered" if variables=="noregis"
replace label="Started registration of transaction" if variables=="startreg"
export excel using "$temp\newparc_mkt", firstrow(variables) replace

use "$temp\newparcelmgd", clear
keep if inheritance_newr == 1
capture table1 prov_code s1q2 using $tmp\, id(newparcelid) order
replace label="Amount willing to pay to register the transfer" if variables=="wtp_value_newr"
replace label="Newly acquired parcel was purchased" if variables=="market"
replace label="New parcel inherited" if variables=="inheritance_n~r"
replace label="RECODE of s3q14 (Possession of land certificate and lease)" if variables=="_s3q14"
replace label="Not officially registered" if variables=="noregis"
replace label="Started registration of transaction" if variables=="startreg"
export excel using "$temp\newparc_inh", firstrow(variables) replace
*/
****
use "$temp\newparcel", clear
keep interview__id newparcelid s3q16* 
for var s3q16__*: replace X = X +1 if X!=. | X!=.a
/*tostring s3q16*, replace
foreach X of varlist s3q16* {
rename `X' `substr(`X',1,5)'
}*/
ren (s3q16__0-s3q16__59) (s3q160 s3q161 s3q162 s3q163 s3q164 s3q165 ///
s3q166 s3q167 s3q168 s3q169 s3q1610 s3q1611 s3q1612 s3q1613 ///
s3q1614 s3q1615 s3q1616 s3q1617 s3q1618 s3q1619 s3q1620 s3q1621 ///
s3q1622 s3q1623 s3q1624 s3q1625 s3q1626 s3q1627 s3q1628 s3q1629 ///
s3q1630 s3q1631 s3q1632 s3q1633 s3q1634 s3q1635 s3q1636 s3q1637 ///
s3q1638 s3q1639 s3q1640 s3q1641 s3q1642 s3q1643 s3q1644 s3q1645 ///
s3q1646 s3q1647 s3q1648 s3q1649 s3q1650 s3q1651 s3q1652 s3q1653 ///
s3q1654 s3q1655 s3q1656 s3q1657 s3q1658 s3q1659)
//duplicates drop newparcelid, force
reshape long s3q16, i(newparcelid) j(j)
keep newparcelid interview__id s3q16
ren s3q16 hhroster__id
so interview__id hhroster__id
merge m:m interview__id hhroster__id using "$temp\hhroster"
keep if _merge == 3
drop _merge
keep interview__id newparcelid hhroster__id s1q2 hhroster__id
ren s1q2 regname_sex
reshape wide regname_sex , i(newparcelid) j( hhroster__id )
for var regname_sex*: tostring X, g(_X)
drop regname_sex*
for var _regname_sex*: replace X = "" if X == "."
g genderregnam = _regname_sex1 + _regname_sex2 + _regname_sex3 + _regname_sex4 ///
 + _regname_sex5 + _regname_sex5 + _regname_sex7 + _regname_sex9
g maleonly = genderregnam == "1" | genderregnam == "11"
g femaleonly = genderregnam == "2"
g joint = genderregnam == "112" | genderregnam == "12" | genderregnam == "122" ///
| genderregnam == "1222" | genderregnam == "21" | genderregnam == "211"

keep newparcelid interview__id  maleonly femaleonly joint
lab var maleonly "Male only"
lab var femaleonly "Female only"
lab var joint "Joint"
save "$temp\regname", replace
****
*Acquired parcels from old roster
use "$temp\acquired2018", clear
keep interview__id owner_parcel oproster__id upi
ren oproster__id newproster__id
egen newparcelid = group(interview__id newproster__id)
//split owner_parcel, p(;)
drop  newproster__id owner_parcel 
duplicates drop upi, force

/*ren (owner_parcel1-owner_parcel3) (owner1 owner2 owner3)
drop tagid
reshape long owner, i(upi) j(j)
ren owner name
*/
so upi
save "$temp\acqname", replace
use "$temp\UPI_Gender_dup", clear
drop interview__id area village_parcel oproster__id
so upi
save "$temp\upi_gender", replace
use "$temp\acqname", clear
mer 1:m upi using "$temp\upi_gender"
keep if _mer == 3
drop _mer 
duplicates drop 
drop owner1_ owner2_ owner3_ owner4_ owner4_gender
replace owner1_gender = "F" if owner1_gender == "FM"
replace owner1_gender = "M" if owner1_gender == "ML"
replace owner2_gender = "F" if owner2_gender == "FM"
replace owner2_gender = "M" if owner2_gender == "ML"
g genderregnam = owner1_gender + owner2_gender + owner3_gender 
g maleonly = genderregnam == "M" | genderregnam == "MM"
g femaleonly = genderregnam =="F" | genderregnam == "FF"
g joint = genderregnam =="FM" | genderregnam == "MF" | genderregnam == "MFM" | genderregnam == "MMF"
drop owner1_gender owner2_gender owner3_gender genderregnam upi
so newparcelid
save "$temp\acqname_upigendr", replace
append using "$temp\regname"
so interview__id
merge m:m interview__id using "$temp\newparcelmgd"
drop if _mer == 1
drop _mer
keep interview__id maleonly-joint interview__id newproster__id wtp_value_newr-dcdisp s3q12 ///
area-registered
egen newparcelid = group(interview__id newproster__id)
drop interview__id newproster__id
lab var dclnreq "Legally not required"
lab var dcexp "Registration fees are to expensive"
lab var dclknw "Do not know it was required"
lab var dcofar "Registration office too far"
lab var dcflt "Revious owner had no certificate"
lab var dcsdna "Subdivision was not legally possible"
lab var dcsdcost "Subdivision costs were too high"
lab var dcdisp "Land under dispute"
save "$temp\newparcelfinal", replace

use "$temp\newparcelmgd", clear /*for hhd data*/
keep regis interview__id newproster__id mode_tr market inheritance other
egen newparcelid = group(interview__id newproster__id)
byso interview__id: egen nprcel = count(newparcelid>0)
byso interview__id: egen totrg = total(regis)
g regstatus = .
replace regstatus = 0 if totrg == 0
replace regstatus = 1 if totrg >=1&totrg == nprcel
replace regstatus = 2 if regstatus == .
lab def regstatus 0 "Not registered" 1 "Registered All" 2 "Registered some"
lab val regstatus regstatus
drop totrg
byso interview__id: egen mkt = total(market)
duplicates tag interview__id, g(tagid)
g trans = .
replace trans = 1 if nprcel == mkt
replace trans = 2 if mkt == 0
replace trans = 1 if mkt == 2&tagid == 1
//replace trans = 2 if mkt == 0&tagid == 1
replace trans = 3 if mkt == 1&tagid == 1
replace trans = 3 if trans ==.
drop mkt tagid nprcel
lab def trans 1 "Market only" 2 "Non Market" 3 "Market some"
lab val trans trans
duplicates drop interview__id, force
keep interview__id regstatus trans
g mkt_only = trans == 1
lab var mkt_only "Marketonly"
g non_mkt = trans == 2
lab var non_mkt "NonMarket"
g mkt_some = trans == 3
lab var mkt_some "Marketsome"
g noreg = regstatus == 0
lab var noreg "Not registered"
g regall = regstatus == 1
lab var regall "Registered all"
g regsome = regstatus == 2
lab var regsome "Registered some"
save "$tmp\reg_mktstatus", replace
*******************************************************************************

*SECTION 4: SOLD OR GIVEN AWAY PARCEL ROSTER DATA
use "$temp\toroster", clear
isid interview__id toroster__id
egen soldparcid = group(interview__id toroster__id)

*Location of parcel sold
numlabel s4q2, add
tab s4q2, mi
recode s4q2 (2/4 = 0), gen(vill_out)
table s4q2 vill_out
lab var vill_out "Parcel sold in this village"
recode s4q2 (2 = 1) (1 3/4 = 0), gen(anvill_out)
table s4q2 anvill_out
lab var anvill_out "Parcel sold is in another village"
recode s4q2 (3 = 1) (1/2 4 = 0), gen(ancell_out)
table s4q2 ancell_out
lab var ancell_out "Parcel sold is in another cell"
recode s4q2 (4 = 1) (1/3 = 0), gen(dist_out)
table s4q2 dist_out
lab var dist_out "Parcel sold is in another district"

*unique parcel number
codebook s4q4 /*some missing upi number*/

*Area of parcel sold
inspect s4q5
sum s4q5
gen area_sold = s4q5/10000
sum area_sold
lab var area_sold "Are of the parcel sold"

*Was plot subdivided
numlabel s4q6, add
tab s4q6, mi
recode s4q6 (2 = 0), gen(subdivided_out)
table s4q6 subdivided_out
lab var subdivided_out "Plot swas subdivided before transfer"
recode s4q6 (2 = 1) (1 = 0), gen(notdivided_out)
table s4q6 notdivided_out
lab var notdivided_out "Plot was not subdivided before transfer"

*Number of subdivisions
inspect s4q7
sum s4q7

*Obtained cadastral maps
numlabel s4q8, add
tab s4q8, mi
g cadmap_out = s4q8 == 1 if s4q8!=.
table s4q8 cadmap_out
lab var cadmap_out "Obtained cadastral maps for fragments"
g ongproc_out = s4q8 == 2 if s4q8!=.
table s4q8 ongproc_out
lab var ongproc_out "Process for obtaining cadastral maps ongoing"
g notobt_out = s4q8 == 3 if s4q8!=.
table s4q8 notobt_out
lab var notobt_out "Not obtained cadastral maps"

*Reasons for not obtaining cadastral maps
numlabel s4q9, add
tab s4q9, mi
recode s4q9 (2/4 = 0), gen(notknow_out)
table s4q9 notknow_out
lab var notknow_out "Reason for not obtaining cadastral maps:Not know"
recode s4q9 (2 = 1) (1 3/4 = 0), gen(afford_out)
table s4q9 afford_out
lab var afford_out "Reason for not obtaining cadastral maps: could not afford costs"
recode s4q9 (3 = 1) (1/2 4 = 0), gen(toosmall)
table s4q9 toosmall 
lab var toosmall "Reason for not obtaining cadastral maps: parcel too small legally"
*Fragments sold
inspect s4q10
sum s4q10
save "$temp\toroster1", replace
keep interview__id toroster__id soldparcid area_sold cadmap_out ongproc_out notobt_out ///
subdivided_out s4q7 
so interview__id toroster__id
mer m:m interview__id toroster__id using "$temp\tofragroster"
keep if _mer == 3
drop _mer interview__key tofragroster__id s4q11a-s4q11f s4q11h
save "$temp\toroster1_to", replace
use "$temp\give2013", clear
so interview__id oproster__id
mer m:m interview__id oproster__id using "$temp\fragroster"
keep if _mer == 3
drop _mer
keep s2q11g interview__id oproster__id s2q6 nosubdiv area map_yes ongoing noobtain
ren (oproster__id s2q6 nosubdiv map_yes ongoing noobtain area s2q11g) (toroster__id ///
subdivided_out s4q7 cadmap_out ongproc_out notobt_out area_sold s4q11g)
save "$temp\give2013to", replace
use "$temp\toroster1_to", clear
append using "$temp\give2013to"
drop soldparcid
egen soldparcid = group(interview__id toroster__id)
save "$temp\give2013tom", replace
use "$tmp\household2018_to", clear
keep interview__id province_cd
merge 1:m interview__id using "$temp\give2013tom"
keep if _merge == 3
drop _merge
merge m:1 interview__id using "$tmp\hhdgender"
keep if _merge == 3
drop interview__id _merge
tab s4q11g, g(I)
drop toroster__id
save "$temp\parc_sold", replace

*SECTION 4: Transferred Fragments data in sold or given away
use "$temp\tofragroster", clear
isid interview__id toroster__id tofragroster__id
egen tofragid = group(interview__id toroster__id tofragroster__id)
*Location of parcel
numlabel s4q11b, add
tab s4q11b, mi
recode s4q11b (2/6 = 0), gen(vill_fragout)
table s4q11b vill_fragout
lab var vill_fragout "Fragment sold in this village"
recode s4q11b (2 = 1) (1 3/6 = 0), gen(anvill_fragout)
table s4q11b anvill_fragout
lab var anvill_fragout "Fragment sold is in another village"
recode s4q11b (3 = 1) (1/2 4/6 = 0), gen(ancell_fragout)
table s4q11b ancell_fragout
lab var ancell_fragout "Fragment sold is in another cell"
recode s4q11b (4 = 1) (1/3 5/6 = 0), gen(ansect_fragout)
table s4q11b ansect_fragout
lab var ansect_fragout "Fragnent sold is in another sector"

*Gender of person who acquired fragment
numlabel s4q11c, add
tab s4q11c, mi
g female_frag_acq = s4q11c == 1 if s4q11c!=.
table s4q11c female_frag_acq
lab var female_frag_acq "Parcels acquired from female"
g male_frag_acq = s4q11c == 2 if s4q11c!=.
table s4q11c male_frag_acq
lab var male "Parcels acquired from males"

*Relationship to head of the person to whom the fragment was acquired
numlabel s4q11d, add
tab s4q11d, mi
g parent = s4q11d == 1 if  s4q11d!=.
table s4q11d parent
lab var parent "Parcel acquired from parent"
g son_daughter = s4q11d == 2 if s4q11d!=.
table s4q11d son_daughter
lab var son_daughter "Son/Daughter/grand child"
recode s4q11d (3 =1) (1/2 4/15 = 0), gen(spouse_frag)
table s4q11d spouse_frag
lab var spouse_frag "Spouse:Fragments transferred to"
recode s4q11d (4 = 1) (1/3 5/15 = 0), gen(brother)
table s4q11d brother
lab var brother "Brother/sister:Fragments tranferred to"
recode s4q11d (5 = 1) (1/4 6/15 = 0), gen(uncle)
table s4q11d uncle 
lab var uncle "Uncle/Aunt: Fragments transferred to"
recode s4q11d (6 = 1) (1/5 7/15 = 0), gen(grand_parent)
table s4q11d grand_parent
lab var grand_parent "Grand parent: Fragments transferred to"
recode s4q11d (7 = 1) (1/6 8/15 = 0), gen(nephew)
table s4q11d nephew
lab var nephew "Nephew/Niece:Fragments transferred to"
recode s4q11d (8 = 1) (1/7 9/15 = 0), gen(cousin)
table s4q11d cousin
lab var cousin "Cousin/relative: Fragments transferred to"
recode s4q11d (9 = 1) (1/8 10/15 = 0), gen(son_inlaw)
table s4q11d son_inlaw
lab var son_inlaw "Son, daughter, or grand child-in law: Fragments transferred to"
recode s4q11d (10 = 1) (1/9 11/15 = 0), gen(parent_inlaw)
table s4q11d parent_inlaw
lab var parent_inlaw "Parent-in-law, grand parent-in-law;Fragemnts transferred to"
recode s4q11d (11 = 1) (1/10 12/15 = 0), gen(brother_inlaw)
table s4q11d brother_inlaw
lab var brother_inlaw "Brother/Sister-in-law: Fragments transferred to"
recode s4q11d (12 = 1) ( 1/11 13/15 = 0), gen(friend)
table s4q11d friend
lab var friend "Friend: Fragments transferred to"
recode s4q11d (13 = 1) (1/12 14/15 = 0), gen(neighbor)
table s4q11d neighbor
lab var neighbor "Neighbor: Fragments transferred to"
recode s4q11d (14 = 1) (1/13 15 = 0), gen(busi_part)
table s4q11d busi_part
lab var busi_part "Business partner: Fragments transferred to"
g other_tofra = s4q11d == 15 if s4q11d!=.
table s4q11d other_tofra
lab var other_tofra "Parcel acquired from other unrelated person"

*Area of parcel sold
inspect s4q11e
sum s4q11e
gen area_fragsold = s4q11e/10000
sum area_fragsold
lab var area_fragsold "Area of fragment transferred"

*Year in which fragment was sold
tab s4q11f, mi

*How was the fragment transferred out
numlabel s4q11g, add
tab s4q11g, mi
g tofrag_sold = s4q11g == 1 if s4q11g!=.
table s4q11g tofrag_sold
lab var tofrag_sold "Market"
g tofrag_beq = s4q11g == 2 if s4q11g!=.
table s4q11g tofrag_beq
lab var tofrag_beq "Fragment bequeted, given away, donated"
recode s4q11g (3 = 1) (1/2 4/5 = 0), gen(auth_tofrag)
table s4q11g auth_tofrag
lab var auth_tofrag "Taken by authorities"
recode s4q11g (4 = 1) (1/3 5 = 0), gen(traded_tofrag)
table  s4q11g traded_tofrag
lab var traded_tofrag "Traded for another land"
numlabel, remove

*Sales price for fragment
inspect s4q11h
sum s4q11h, d

preserve
keep interview__id toroster__id tofragroster__id female_frag_acq male_frag_acq ///
parent son_daughter other_tofra tofrag_sold tofrag_beq s4q11f s4q11h
keep if s4q11f >=2013&s4q11f<=2018
drop s4q11f
ren toroster__id oproster__id 
ren tofragroster__id fragroster__id
ren s4q11h s2q11h
ren (female_frag_acq male_frag_acq tofrag_sold tofrag_beq) (female_op male_opfr ///
frag_sold frag_beq)
append using "$temp\fraggive"
save "$temp\trn_out", replace
restore

save "$temp\tofragroster1.dta", replace
keep if s4q11f>=2013&s4q11f<=2018
keep interview__id tofragid female_frag_acq male_frag_acq parent son_daughter other_tofra tofrag_sold tofrag_beq
save "$temp\tofragroster1_to", replace
use "$tmp\household2018_to", clear
keep interview__id province_cd 
merge 1:m interview__id using "$temp\tofragroster1_to"
keep if _merge == 3
drop interview__id _merge
save "$temp\tofragroster1_mgd", replace
cap table1 province_cd using $tmp\, id(tofragid) order
export excel using "$temp\tofrag_inf", firstrow(var) replace
use "$temp\tofragroster1_mgd", clear
keep if tofrag_sold == 1
cap table1 province_cd using $tmp\, id(tofragid) order
export excel using "$temp\tofragid_mkt", firstrow(var) replace
use "$temp\tofragroster1_mgd", clear
keep if tofrag_beq == 1
cap table1 province_cd using $tmp\, id(tofragid) order
export excel using "$temp\tofragid_inh", firstrow(var) replace

use "$tmp\household2018_to", clear
keep interview__id province_cd 
save "$temp\hhdprovince", replace
use "$temp\trn_out", clear
so interview__id
merge m:1 interview__id using "$temp\hhdprovince"
keep if _mer == 3
drop _mer
merge m:1 interview__id using "$tmp\hhdgender"
keep if _mer == 3
drop _mer
egen toid = group(interview__id oproster__id fragroster__id)
drop interview__id oproster__id fragroster__id
winsor2 s2q11h if s2q11h!=., replace cuts(5 95)
g mode_tr = .
replace mode_tr = 1 if frag_sold == 1
replace mode_tr = 2 if frag_beq == 1
lab def mode_tr 1 "Market" 2 "Inheritance"
lab val mode_tr mode_tr
save "$temp\trn_outfinal", replace
/*cap table1 mode_tr province_cd s1q2 using $tmp\, id(toid) order
replace label="Sales price of the fragment" if variables=="s2q11h"
replace label="Parcels acquired from female" if variables=="female_op"
replace label="Parcels acquired from males" if variables=="male_opfr"
replace label="Parcel acquired from parent" if variables=="parent"
replace label="Son/Daughter/grand child" if variables=="son_daughter"
replace label="Parcel acquired from other unrelated person" if variables=="other_tofra"
replace label="Market" if variables=="frag_sold"
replace label="Fragment bequeted, given away, donated" if variables=="frag_beq"
replace label="Sex" if variables=="s1q2"

export excel using "$temp\tofragid_all", firstrow(var) replace
use "$temp\trn_outfinal", replace
keep if frag_sold == 1
cap table1 mode_tr province_cd s1q2 using $tmp\, id(toid) order
replace label="Sales price of the fragment" if variables=="s2q11h"
replace label="Parcels acquired from female" if variables=="female_op"
replace label="Parcels acquired from males" if variables=="male_opfr"
replace label="Parcel acquired from parent" if variables=="parent"
replace label="Son/Daughter/grand child" if variables=="son_daughter"
replace label="Parcel acquired from other unrelated person" if variables=="other_tofra"
replace label="Market" if variables=="frag_sold"
replace label="Fragment bequeted, given away, donated" if variables=="frag_beq"
replace label="Sex" if variables=="s1q2"
export excel using "$temp\tofragid_mkt", firstrow(var) replace
*/

***** 
*Transferred out fragments
*household level data
use "$tmp\household2018_to", clear
keep interview__id province_cd
so interview__id
save "$temp\hhdregion", replace

** individual
use "$temp\hhroster", clear
g dhead = s1q3==1 if s1q3<=18
g dmale = s1q2==1 if s1q2<=2
g dmcrt = s1q8==1 if s1q8<=2
g dmcum = s1q10==1 if s1q10<=5
g yrmr = s1q11 if s1q11!=.a

keep interview__id s1q2 dhead

keep if dhead==1
sort interview__id
drop dhead
save "$tmp\hh_marriage", replace

** old parcel roster

use "$temp\oproster", clear
sort interview__id
keep interview__id oproster__id s2q3 area s2q6 s2q8 s2q10
keep if s2q3==2 | s2q3==3
sort interview__id oproster__id
save tmp2, replace

** transfered out fragments
use "$temp\fragroster", clear
sort interview__id
sort interview__id oproster__id
merge interview__id oproster__id using tmp2
drop if _mer==1
keep interview__id oproster__id fragroster__id s2q11c s2q11d s2q11e s2q11f s2q11g ///
s2q11h area s2q3 s2q6 s2q8 s2q10
replace s2q11e=area if s2q3==3 & s2q6==2
keep interview__id oproster__id fragroster__id s2q6 s2q8 s2q10 s2q11c s2q11d s2q11e ///
s2q11f s2q11g s2q11h

save tmp3, replace

*** 
use  "$temp\toroster", clear
isid interview__id toroster__id
keep interview__id toroster__id s4q6 s4q8 s4q10
so interview__id toroster__id
save tmp5, replace
use "$temp\tofragroster", clear
so interview__id toroster__id
mer interview__id toroster__id using tmp5
keep if _mer == 3
keep interview__id toroster__id tofragroster__id s4q6 s4q8 s4q10 s4q11c s4q11d /// 
s4q11e s4q11f  s4q11g s4q11h
ren toroster__id oproster__id 
ren tofragroster__id fragroster__id
ren s4q6 s2q6
ren s4q8 s2q8
ren s4q10 s2q10
ren s4q11c s2q11c
ren s4q11d s2q11d
ren s4q11e s2q11e
ren s4q11f s2q11f
ren s4q11g s2q11g
ren s4q11h s2q11h
append using tmp3
mer m:1 interview__id using "$tmp\hh_marriage"
keep if _mer == 3
drop _mer
mer m:1 interview__id using "$temp\hhdregion"
keep if _mer == 3
egen fragid=group( interview__id oproster__id fragroster__id)
drop  interview__id oproster__id fragroster__id _merge
save trn_out, replace

use trn_out, clear

keep if s2q11f>=2013&s2q11f<=2018
tab s2q11c if s2q11c<=3, g(dgenderparty)
tab s2q11d if s2q11d<=15, g(drelhdparty)
tab s2q8 if s2q8 <= 3, g(dmap)
tab s2q6, g(fragyes)
g area = s2q11e/10000
tab s2q11g if s2q11g<=5, g(dtrnsby)
g svalue = s2q11h if dtrnsby1==1
winsor2 svalue if svalue!=., replace cuts(5 95)
/*g svalueh = s2q11h/area if dtrnsby1==1
winsor2 svalueh if svalueh!=., replace cuts(5 95)
*/
drop s2q11e s2q8 s2q6 s2q11c s2q11d s2q11f s2q8 s2q11h

********************************************************************************
********************************************************************************
*SECTION6:LOADING THE ASSETS DATASET
use "$temp\assets", clear
numlabel assets__id, add
tab assets__id, mi
g agrva = assets__id == 28 | assets__id == 29 | assets__id == 30 | assets__id == 31 ///
| assets__id == 32 | assets__id == 33 | assets__id == 34 | assets__id == 35 | ///
assets__id == 36 if assets__id!=.

*Creating Agricultural assets dummy and other asset categories
gen agric_assets = .
replace agric_assets = 1 if assets__id == 24
replace agric_assets = 1 if assets__id >= 28
replace agric_assets = 2 if assets__id >=1&assets__id<=6
replace agric_assets = 2 if assets__id >=16&assets__id<=20
replace agric_assets = 2 if assets__id >=22&assets__id<=23
replace agric_assets = 3 if assets__id >=7&assets__id<=9
replace agric_assets = 3 if assets__id == 11
replace agric_assets = 3 if assets__id == 25
replace agric_assets = 4 if assets__id ==10
replace agric_assets = 4 if assets__id ==15
replace agric_assets = 5 if assets__id >=12&assets__id<=13
replace agric_assets = 5 if assets__id >=26&assets__id<=27
replace agric_assets = 0 if agric_assets == .

table  assets__id agric_assets
*Asset ownership
numlabel s6q1, add
tab s6q1, mi
recode s6q1 (2 .a = 0), gen(asset)
tab  asset
lab var asset "Own an asset"
inspect s6q3
list s6q3 if s6q3 < 0
replace s6q3 = . if s6q3 < 0
numlabel s6q4, add
tab s6q4, mi
recode s6q4 (2 = 0), gen(assetbuy)
tab assetbuy
lab var assetbuy "Did you buy anyone in the hhd buy item in the last 12 months"

*Amount spent in buying asset
inspect s6q5
preserve
keep asset interview__id assets__id asset s6q3  s6q5
save "$temp\assetindex", replace
restore

*Value of assets
inspect s6q3 /* need to sort out -99 values*/
replace s6q3 = . if s6q3 == -99
ren s6q3 asset_val
ren s6q5 purchvalue_asset
sum asset_val if asset == 1
total asset_val if asset == 1
//keep if asset == 1 /*keeping only those who reported owning an asset*/
preserve
collapse (sum) asset_val, by(interview__id)
save "$temp\assets_1", replace
restore

collapse (sum) asset_val purchvalue_asset, by(interview__id agrva)
reshape wide asset_val purchvalue_asset, i(interview__id) j(agrva)
//drop asset_val*
save "$temp\assets_agric", replace

*To compute wealthy index for each household based on asset ownership
use "$temp\assetindex", clear
numlabel, remove
reshape wide asset s6q3 assetbuy s6q5, i(interview__id) j(assets__id) /*reshaping data so that we can do principal component analysis*/
pca asset1 asset2 asset3 asset4 asset5 asset6 asset7 asset8 asset9 asset10 ///
asset11 asset12 asset13 asset14 asset15 asset16 asset17 asset18 asset19 ///
asset20 asset21 asset22 asset23 asset24 asset25 asset26 asset27 asset28 ///
asset29 asset30 asset31 asset32 asset33 asset34 asset35 asset36
predict asset_index
xtile wealth_qurtile = asset_index, nq(4)
keep interview__id s6q314-assetbuy14 s6q321-assetbuy21 asset_index wealth_qurtile
so interview__id
merge 1:1 interview__id using "$temp\assets_agric"
drop _merge
save "$temp\asset_quartiles", replace
keep interview__id wealth_qurtile
save "$temp\assetqua_tm", replace
collapse (sum) parcel_out, by(village_cd)
so village_cd
save "..\data\village_out", replace
*/
*******


log close
exit







