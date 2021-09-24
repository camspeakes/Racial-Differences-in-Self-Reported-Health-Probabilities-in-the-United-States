/* Template Do File */


clear /*clears any previous content*/

capture log close /* closes any open log files */

set more off /* allows for longer panel views */

cd "C:\Users\CS20JG\Downloads" /* note: this command directory will be dependant on where you save your things, this cd is for FSU vLab*/


/* Set-up */

use LLCP2015.dta /*data file*/

log using "DLLog15clean", text replace


/*Data Work*/

keep _state genhlth iyear dispcode hlthpln1 _ageg5yr marital children educa income2 sex exerany2 qlactlm2 veteran _bmi5cat _race

/*Drop incomplete interviews*/
drop if dispcode == 120

/*Clear missing or refused*/

foreach x of varlist genhlth hlthpln1 marital exerany2 qlactlm2 veteran educa {
		foreach i in 7 9 {
			replace `x' = . if `x' == `i'
			}
		}

foreach x of varlist children   {
		foreach i in 99 {
			replace `x' = . if `x' == `i'
			}
		}		
		
foreach x of varlist income2   {
		foreach i in 77 99 {
			replace `x' = . if `x' == `i'
			}
		}		

foreach x of varlist _race {
	foreach i in 6 7 9 {
		replace `x' = . if `x' == `i'
	}
}

/*Variable Recoding*/
foreach x of varlist _race {
	foreach i in 4 5 {
		replace `x' = 3 if _race == `i'
	}
	foreach i in 8 {
		replace `x' = 4 if _race == `i'
	}
}

	* Combines Asian, Native Hawaiian, Pacific Islander, Native American and Native Alaskan
	* Recodes Hispanic from 8 to 4
	
foreach x of varlist genhlth {
	foreach i in 1 2 {
		replace `x' = 1 if genhlth == `i'
	}
	foreach i in 3 4 5 {
		replace `x' = 0 if genhlth == `i'
	}
}

	*genhlth now a binary, 1 if excellent or very good, 0 if less

	
gen numchild = 0

		replace numchild = 3 if children >= 3
		replace numchild = 2 if children == 2
		replace numchild = 1 if children == 1
		replace numchild = . if children >= 10
		replace numchild = 0 if children == 88
		
		drop children

replace _ageg5yr = . if _ageg5yr == 14		

capture log close

log using "DLLog15results", text replace
		
/*Regression*/

logit genhlth i._race  
	margins, dydx(_race) 

logit genhlth i._race hlthpln1 
	margins, dydx(_race)
	
logit genhlth i._race hlthpln1 i._ageg5yr marital i.numchild i.educa i.income2 sex exerany2 qlactlm2 veteran i._bmi5cat i._state
	margins, dydx(_race)
	

/* End Do File */
capture log close
