
*** specify a path for tmp files

global tmp Z:\path  /* this is necessary for the code to work **/

**open data
use data, clear


recode rntl 10=1 20=2 30=3 /* category variable */

label define rntl 1 "Tenant" 2 "Autarky" 3 "Landlord", replace
label values rntl rntl

recode rntlex 10=1 20=2 30=3 /* category variable */

label define rntlex 1 "Ttenant" 2 "Tautarky" 3 "Tlandlord", replace
label values rntlex rntlex

*** run order do file (optional)

do order

quietly ttst1 rntl 1 2 rntl 2 3 rntlex 1 2 rntlex 2 3, newvars(Tenant Landlord Ttenant Tlandlord) temp($tmp\) /* the newvars are the variable names for the t-test, specify as many as the number of tests */

/*** this is the t-test for the equality mean values, and can be commented if it is not needed but then add capture while running the table1 code ***/

table1 rntl rntlex using $tmp\, id(hhid) order  /** add capture if the ttst1 code is commented on ***/ /** note that hhid -- household, parcel or individual identifier can only be a numeric value ***/

**then run the label do file (optional)

do label

/*   example of the label do file


replace label="Owned land in hectares" if variables=="lnd_own" 				
replace label="Temporarily exchanged land in hectares" if variables=="lnd_tex" 				
replace label="Female headed household" if variables=="hd_female" 			
replace label="Age of household head in years" if variables=="hd_age" 				
replace label="Head has primary school education" if variables=="hd_primsch" 			
replace label="Head has secondary school education" if variables=="hd_secvoc" 			
replace label="Number of dependent" if variables=="dpndt" 				
replace label="Number of male adults" if variables=="madult" 				
replace label="Number of female adults" if variables=="fadult" 				
replace label="Sale value of household assets in USD1000" if variables=="salev_ttlassets_usd" 	
replace label="Sale value of livestock in USD1000" if variables=="ttlcvalue_lvstck_usd" 
replace label="Constrained in the semi-formal credit market" if variables=="sfccstr" 				
replace label="Involved in off-farm wage employment" if variables=="wgemp" 				
replace label="Has non-farm enterprises" if variables=="entr" 				
replace label="Time dummy" if variables=="round" 				
replace label="LTR village X time dummy" if variables=="trtmnt" 		
*/

export excel /*to export into excel files */
