{smcl}
{* *! version 1.1.1 25March2014}{...}
{cmd:help xtld}
{hline}

{title:Title}

{phang}
{bf:xtld} {hline 2} Long difference instrumental variables estimation for dynamic panel models according to Hahn et al. (2007) 

{title:Syntax}

{p 8 16 2}
{cmd:xtld} {depvar} [{indepvars}] {ifin} [{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt iter}}determines the number of iterations {p_end}
{synopt:{opt difflength}}determines the differencing length{p_end}
{synoptline}


{title:Description}

{p 4 4 2}
{cmd:xtld} conducts long difference (LD) estimation as described in Hahn et al. (2007). Typical applications are dynamic panel regressions with highly persistent data series and a short time dimension as well as fixed effects.   

{p 4 4 2}Hahn et al. (2007) show that LD estimation is less biased compared to standard GMM estimators like Blundell/Bond {manhelp xtdpdsys XT}. 

{p 4 4 2}The LD estimator uses 2SLS estimation applying lagged levels of the regressors and the residuals as instruments. 
The LD estimator builds on the model of Hahn et al. (2007) and allows for unbalanced panel data with a lagged dependent 
variable: 


{p 8 4 2}y_it - y_it-k = lamda * (y_it-1 - y_it-k-1) + gamma(X_it-1 - X_it-k-1) + e_it-e_it-1;	(Eq. 1){p_end}

{p 4 4 2}rearranging:{p_end}

{p 8 4 2}delta y_it,t-k = lamda *delta y_it-1,t-k-1 + gamma*delta*X_it-1,t-k-1 + e_it,t-k;	(Eq. 2){p_end}

{p 4 4 2}with{p_end}

{p 8 4 2}y_it: observable dependent variable,{p_end}
{p 8 4 2}X_it: set of exogenous regressors,{p_end}
{p 8 4 2}e_it: N(0,sigma^2_u) error term,{p_end}
{p 8 4 2}i = 1,...,N,{p_end}
{p 8 4 2}t = 1,...,T,{p_end}
{p 8 4 2}k = 1,...,K, where k is the lag length{p_end}

{p 4 4 2}Hahn et al. (2007) suggest to use L_it-k-1 as well as the residuals L_it-1 - lamdahat*L_it-2 - gammahat* X_it-2, ..., 
L_it-k - lamdahat*L_it-k-1 - gammahat* X_it-k-1 as valid instruments. Estimation of Eq. 2 is then further iterated. Accoridng to Hahn et al. (2007), three iterations are said to be sufficient.  
We use the Stata time series operators (S.and L.) to calculate seasonal differences and lagged seasonal differences, see {help tsvarlist} for details. 


{p 4 4 2}
{cmd:xtld} requires the data to be {helpb xtset} and {opt by} is allowed; see {help prefix}.


{title:Options}

{dlgtab:Main}


{phang}
{opt iter} determines the number of iterations. The default value is 3, folloiwng Hahn et al. (2007).

{phang}
{opt difflength} determines the lag length (number of differencing length). The default value is 5. 




{title:References}

{p 4 4 2}
Hahn J., J. Hausman, and G. Kuersteiner. "Long difference instrumental variables estimation for dynamic panel models with fixed effects."
Journal of Econometrics, 140 (2007), 574-617


{title:Authors}

{p 4 4 2}Catharina Klepsch, University of Munich, klepsch@bwl.lmu.de{p_end}



{title:Also see}

{psee}
{space 2}Help: {manhelp 2SLS XT}, {manhelp xtdpdsys XT}, {manhelp xtset XT}
{p_end}
