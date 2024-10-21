*! xtdpf, version 1.1, David Florysiak & Catharina Klepsch, September 2013

* Syntax:
* =======
* 
* xtdpf depvar [indepvar] [if] [in] [, timedummies keepit lc(string) rc(string)]
* xtdpf is byable.

* Notes:
* ======

* Dataset has to be declared as a paneldataset: tsset panelvar timevar
* Program written with Stata version 11
* User has to ensure that variable abbreviations are allowed: "set varabbrev on" 

*--------------------------------------------------

	* 1. Eliminate any "dpf-program" from memory:
		capture program drop xtdpf		

	* 2. Name of the program: xtdpf
		program define xtdpf, eclass sortpreserve byable(recall) 
		version 11
		syntax varlist(numeric ts) [if] [in][,timedummies keepit lc(string) rc(string)]
		marksample touse			//mark obs. for if and in
				
		
	* 3. Split varlist into dependent and independent variables:
		tokenize `varlist'		// load varlist into numbered local macros
		local yvar `1'			// first variable in the provided varlist is the dependent variable
		macro shift				// shifts varlist by one value, `*' will take the value of 3 and higher variables in varlist
		local xvar `*'


	* 4. Check if the dataset is tsset:
		qui tsset 
		local panelvar `r(panelvar)'
		local timevar  `r(timevar)'
		local time_min `r(tmins)'
		local time_max `r(tmaxs)'
					
		if "`panelvar'"=="" {
				di as err "must specify panelvar and timevar; use xtset"
				exit 459
		}
		
			
	* 5. Generate for the dependent variable LAGGED values (temporary variable)
		tsunab lag_y:l.`yvar'


	* 6. Generate yi0 (being the first value of the dependent variable for each panelvar):
		tempvar tmp_firsty	notmissing r1
		bys `panelvar': generate `notmissing' = _n if !missing(`yvar')
		bys `panelvar': egen `r1' = min(`notmissing')
		bys `panelvar': gen `tmp_firsty' = `yvar'[`r1']
		bys `panelvar': replace `tmp_firsty' = . if missing(`yvar')
		*bys `panelvar': generate `tmp_firsty' = `yvar'[1]	 
		label var `tmp_firsty' "For each ID the first entry of `yvar'"
		
		
		
	* 7. Generate for all explanatory Variables (except lag_y) MEAN values
	
		local meanvars = ""
		
		tsrevar `xvar'
		display "`r(varlist)'"
		local xvar_new `r(varlist)'
		
		foreach x of varlist `xvar_new' {
		tempvar mean`x'

		bys `panelvar':  egen `mean`x'' = mean(`x') 
		label var `mean`x'' "mean_`x'"
		local meanvars `meanvars' `mean`x''
		}
		
			
	* 8. Generate time-dummy variables if option timedummies selected
		if "`timedummies'"=="timedummies" {
			local tvars = ""	
			qui sum `timevar'
			forv i = `r(min)' / `r(max)' {
			qui gen `timevar'_`i' = 1 if `timevar'==`i' 
			qui replace `timevar'_`i'= 0 if `timevar'_`i'==. 
			local tvars `tvars' `timevar'_`i'
			}
			local timedummies `tvars'
			}
				
	* 9. Censoring bounds
	
		* Left censoring
			if "`lc'" != "" {
				local lc `lc'
				}
			else {
				local lc = 0
			}
		
		* Right censoring
			if "`rc'" != "" {
				local rc `rc'
				}
			else {
				local rc = 1
			}
				
		
	* 10. Tobit estimation (doubly-censored)
			
		if "`timedummies'" != "" {
		
		xttobit `yvar' `lag_y' `xvar' `tmp_firsty' `meanvars' `timedummies'  if `touse', intm(gh) ll(`lc') ul(`rc')
		display "Definition of variables:"
		display ""
		foreach var of varlist `tmp_firsty' `meanvars'  {
		local name: variable label `var'
		display "`var' = `name'"
		}
		} 
		else{
		xttobit `yvar' `lag_y'  `xvar' `tmp_firsty' `meanvars'  if `touse', intm(gh) ll(`lc') ul(`rc')
		display "Definition of variables:"
		display ""
		foreach var of varlist  `tmp_firsty' `meanvars'{
		local name: variable label `var'
		display "`var' = `name'"
		}
		}
		
		if "`keepit'" == "" {
		if "`timedummies'" != "" {
		drop `timedummies' 
		}
		}
		
		
		
		
		
end

