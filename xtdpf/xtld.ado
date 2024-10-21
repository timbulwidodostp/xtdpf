*! xtld, version 1.0, Catharina Klepsch, March 2014
* Based on Peter Iliev and David Florysiak
* LD estimator according to Hahn, Hausman, Kuersteiner, Long difference instrumental variables estimation for dynamic panel models with fixed effects, Journal of Econometrics (2007)

* Syntax:
* =======
* 
* xtld depvar [indepvar] [if] [in] [, iter(string) difflength(string)]
* xtld is byable.

* Notes:
* ======

* Dataset has to be declared as a paneldataset: tsset panelvar timevar
* Program written with Stata version 13
* User has to ensure that variable abbreviations are allowed: "set varabbrev on" 

*--------------------------------------------------

	* 1. Eliminate any "xtld-program" from memory:
		capture program drop xtld		

	* 2. Name of the program: xtld
		program define xtld, eclass sortpreserve byable(recall) 
		version 11
		syntax varlist(numeric ts) [if] [in][, iter(string) difflength(string)]
		marksample touse			//mark obs. for if and in
				
		
	* 3. Split varlist into dependent and independent variables:
		tokenize `varlist'		// load varlist into numbered local macros
		local yvar `1'			// first variable in the provided varlist is the dependent variable
		macro shift				// shifts varlist by one value, `*' will take the value of 2 and higher variables in varlist
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
		
				
					
	* 5. Define number of iterations and differencing length
					
		
	* Number of iteration loops
			if "`iter'" != "" {
				local iter `iter'
				local maxiter = `iter'
				}
			else {
				local iter = 3  		//default according to Hahn et al. (2007) 
				local maxiter = 3
				}
			
	* Number of differencing length
			if "`difflength'" != "" {
				local difflength `difflength'
				}
			else {
				local difflength = 5  // default as in Hahn et al. (2008) 
			}
			
			
	* Number of residuals used as IVs
			
		local nres  = `difflength'-1
				
	
	* IV for endogenous regressor (lagged y):
	
		local ivy = `difflength'+1
		
		
	* Generate variables to store estimates
						
			*Residuals
			local res = ""
			forv i = 1/`nres'{
			tempvar res_`i'
			qui gen res_`i' = .
			local res `res_`i''
			}
			
			*beta-estimates
			local b = ""
			local b_x = ""
			
			foreach var of varlist  `yvar' `xvar'{
			tempvar b_`var'
			tempvar b_x_`var'
			qui gen b_`var' = .
			qui gen b_x_`var' = .
			local b `b_`var''
			local b_x `b_x_`var''
			}
			
			
			
			
			
			
	* 6. 2SLS estimation 
	

		
		* First iteration: obtain first starting values
		
		qui ivreg s`difflength'.`yvar' (s`difflength'l.`yvar' = l`ivy'.`yvar') s`difflength'l.(`xvar'), cluster(`panelvar') noc
		
		
		* Save estimated beta_coefficients
			
			foreach var of varlist `yvar' {
			qui replace b_`var' =_b[s`difflength'l.`var'] 
			}
			
			foreach var of varlist  `xvar' {
			qui replace b_`var' =_b[s`difflength'l.`var']
			}
		
		
			
		
		* Iteration loop ( + difflength loop)
		
		local yhat = ""
		
		forvalues iter = 1/`iter'{
			forvalues i = 1/`nres'{
			local j = `i'+1
			
				foreach var of varlist  `yvar' {
				qui replace b_x_`var' =_b[s`difflength'l.`var'] * l`j'.`var'
				}
			
				foreach var of varlist  `xvar' {
				qui replace b_x_`var' =_b[s`difflength'l.`var'] * l`j'.`var'
				}
				
			
					
				tempvar yhat	
				qui egen `yhat' = rowtotal(b_x_*)
				local yhat `yhat'
		qui{	
		by `panelvar': replace res_`i' = l`i'.`yvar' - `yhat'
		}
		
	}		
		
	* 2SLS using residuals as additional instruments
		

		
		if `iter'!=`maxiter'{
		qui{
		
		ivreg s`difflength'.`yvar' (s`difflength'l.`yvar' = l`ivy'.`yvar' res_*) s`difflength'l.(`xvar') , cluster(`panelvar') noc
			
			foreach var of varlist `yvar' {
			qui replace b_`var' =_b[s`difflength'l.`var']
			}
			foreach var of varlist  `xvar' {
			qui replace b_`var' =_b[s`difflength'l.`var'] 
			}
		}
		}
		
		else{
		ivreg s`difflength'.`yvar' (s`difflength'l.`yvar' = l`ivy'.`yvar' res_*) s`difflength'l.(`xvar') , cluster(`panelvar') noc
			
			foreach var of varlist  `xvar' {
			qui replace b_`var' =_b[s`difflength'l.`var'] 
			}
		}
		
		
		
		} 
		

	
		drop b_* res_*
		
		
		
		
end

