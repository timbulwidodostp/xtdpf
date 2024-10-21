{smcl}
{* *! version 1.1.1 28aug2013}{...}
{cmd:help xtdpf}
{hline}

{title:Title}

{phang}
{bf:xtdpf} {hline 2} Dynamic panel estimation with a fractional dependent variable

{title:Syntax}

{p 8 16 2}
{cmd:xtdpf} {depvar} [{indepvars}] {ifin} [{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt dropit}}drops internally generated variables {p_end}
{synopt:{opt timedummies}}adds time dummies to the regression{p_end}
{synopt:{opt lc(string)}} left-censoring variable/limit, default is zero{p_end}
{synopt:{opt rc(string)}} right-censoring variable/limit, default is one{p_end}
{synoptline}


{title:Description}

{p 4 4 2}
{cmd:xtdpf} conducts DPF (dynamic panel fractional) estimation as described in Elsas and Florysiak (2013). Typical applications are panel regressions with a lagged dependent variable, which is fractional, i.e. bounded between zero and one (e.g. firms' debt ratios, payout ratios, unemployment rates etc.). Often, researchers are interested in the  so-called speed of adustment (SOA) in a partial adjustment model, which then corresponds to (1 - coefficient on the lagged dependent variable).   

{p 4 4 2}Since the dependent variable is censored, standard panel estimators (like fixed-effects ({cmd:xtreg}) or 
GMM-estimators like Blundell/Bond ({cmd:xtdpdsys}) will be biased. 

{p 4 4 2}The DPF estimator uses a doubly-censored Tobit specification that allows for 
corner observations at both zero and one, with a lagged dependent variable 
and unobserved heterogeneity. The DPF estimator builds on the model of 
Loudermilk (2007) and allows for unbalanced panel data with a lagged dependent 
variable. 

{p 4 4 2}In non-linear panel models there is no known transformation to eliminate
unobserved heterogeneity (i.e. the fixed-effects) from the ML estimates of the explanatory variables 
(see Loudermilk 2007). The DPF estimator therefore specifies an explicit distribution of the fixed-effects. The unobserved heterogeneity is eliminated by including the fixed-effects under this assumption 
explicitly as regressors. Elsas and Florysiak (2013) discuss several situations of mis-specification of the fixed-effects distribution 
and the corresponding robustness of the DPF estimator.     

{p 4 4 2}
{cmd:xtdpf} employs a latent variable specification and fits the regression equation

{p 8 4 2}y_it = Z_it * phi + rho * y_i,t-1 + c_i + u_it,{p_end}

{p 4 4 2}where the fixed-effects ditribution is assumed to be{p_end}

{p 8 4 2}c_i = alpha_0 + alpha_1 * y_i0 + mean_Z_i * alpha_2 + a_i,{p_end}

{p 4 4 2}with{p_end}

{p 8 4 2}y_it: observable dependent variable,{p_end}
{p 8 4 2}Z_it: set of exogenous regressors,{p_end}
{p 8 4 2}u_it: N(0,sigma^2_u) error term,{p_end}
{p 8 4 2}mean_Z_i: time series averages of Zit,{p_end}
{p 8 4 2}a_i: N(0,sigma^2_a) error term,{p_end}
{p 8 4 2}i = 1,...,N,{p_end}
{p 8 4 2}t = 1,...,T,{p_end}

{p 4 4 2}
using {cmd:xttobit} with options intm(gh) and ll(0), ul(1). {cmd:xtdpf} requires the 
data to be {helpb xtset} and {opt by} is allowed; see {help prefix}.

{p 4 4 2}
{cmd:xtdpf} generates and saves the lagged dependent variable y_i,t-1 as lag_depvar, 
the first observation of the dependent variable yi0 as first_depvar, and the time series 
averages of Zit as mean_indepvars. 

{title:Options}

{dlgtab:Main}

{phang}
{opt dropit} drops the internally generated variables, lag_depvar, first_depvar, 
mean_indepvars, and time dummies if the option timedummies is specified. Do not 
use this option if you want to calculate predicted values.

{phang}
{opt timedummies} adds time dummies to the regression. Time dummies are generated 
and saved as timevar_1,...,timevar_T. Time dummies should not be included in mean_Zi, 
which is ensured by this option.

{phang}
{opt lc(string)} changes the left-censoring limit. Default value is zero.

{phang}
{opt rc(string)} changes the right-censoring limit. Default value is one.

{title:Example 1: Simpel DPF estimation}

{p 4 4 2}
This example illustrates DPF estimation with artificial data. The dynamic model is estimated using simulated panel data, where the dependent variable is bounded by 0 and 1. The data are generated according to the DPF's data-generating process, 
with N=100 individuals repeatedly observed over T=9 time periods (thus 8 periods per individual can be used for estimation due to the lagged dependant).  

{p 4 4 2}
Data comprises a single exogenous regressor z, and rho = 0.8 (i.e. SOA=1-rho=0.2). Further, it is assumed z ~ U(-0.5,1), phi = 0.2, alpha_0 = 0.1, alpha_1 = 0.1, alpha_2 = -0.25. Errors are normally distributed with
 u_it ~ N(0,0.1^2), and an error term a_i ~ N(0,0.1^2) for the fixed-effects. See Section 
III.A.1 in Elsas and Florysiak (2013) for more details.

{p 4 4 2}{cmd:quietly {c -(}}{p_end}
{p 4 4 2}{cmd:clear}{p_end}
{p 4 4 2}{cmd:set obs 900}{p_end}

{p 4 4 2}{cmd:* ---- Set parameters}{p_end}
{p 4 4 2}{cmd:local rho=0.8}{p_end}
{p 4 4 2}{cmd:gen i = mod(_n-1,100) + 1}{p_end}
{p 4 4 2}{cmd:sort i}{p_end}
{p 4 4 2}{cmd:gen t = mod(_n-1,9) + 1}{p_end}
{p 4 4 2}{cmd:gen z = -0.5 + 1.5 * runiform()}{p_end}
{p 4 4 2}{cmd:gen a = rnormal(0,0.1)}{p_end}
{p 4 4 2}{cmd:gen u = rnormal(0,0.1)}{p_end}

{p 4 4 2}{cmd:* ---- Generate data}{p_end}
{p 4 4 2}{cmd:by i: egen mean_zi = mean(z)}{p_end}
{p 4 4 2}{cmd:by i: gen yHash = (1-`rho') * z * 1 + 0.1 - 0.25 * mean_zi + a[1] if t == 1}{p_end}
{p 4 4 2}{cmd:gen y = .}{p_end}
{p 4 4 2}{cmd:by i: replace y = 0 if yHash <= 0 & t == 1}{p_end}
{p 4 4 2}{cmd:by i: replace y = yHash if yHash > 0 & yHash < 1 & t == 1}{p_end}
{p 4 4 2}{cmd:by i: replace y = 1 if yHash >= 1 & t == 1}{p_end}
{p 4 4 2}{cmd:by i: gen c = 0.1 + 0.1 * y[1] - 0.25 * mean_zi + a[1]}{p_end}
{p 4 4 2}{cmd:forvalues k = 2(1)9 {c -(}}{p_end}
{p 8 4 2}{cmd:	by i: replace yHash = `rho' * y[_n-1] + (1-`rho') * z * 1 + c + u if t == `k'} {p_end}
{p 8 4 2}{cmd:	by i: replace y = 0 if yHash <= 0 & t == `k'}{p_end}
{p 8 4 2}{cmd:	by i: replace y = yHash if yHash > 0 & yHash < 1 & t == `k'}{p_end}
{p 8 4 2}{cmd:	by i: replace y = 1 if yHash >= 1 & t == `k'}{p_end}
{p 4 4 2}{cmd:{c )-}}{p_end}
{p 4 4 2}{cmd:{c )-}}{p_end}

{p 4 4 2}{cmd:* ---- Run xtdpf on generated dataset.}{p_end}
{p 4 4 2}{cmd:xtset i t}{p_end}
{p 4 4 2}{cmd:xtdpf y z}{p_end}




{title:Example 2: MC simulation comparing different estimators}

{p 4 4 2} This example compares DPF estimates to those of alternative estimators (Blundell/Bond and FE) using Monte Carlo simulation. In each of the 10 simulation runs, SOA is estimated using simulated panel data, where the dependent variable is bounded by 0 and 1. All parameterisations are the same as in Example 1.   


{p 4 4 2}{cmd:clear}{p_end}

{p 4 4 2}{cmd:* ---- Parameters for MC}{p_end}
{p 4 4 2}{cmd:local sim=10}{p_end}
{p 4 4 2}{cmd:matrix dpf=J(`sim',1,0) }{p_end}
{p 4 4 2}{cmd:matrix fe=J(`sim',1,0) }{p_end}
{p 4 4 2}{cmd:matrix blundellBond=J(`sim',1,0)}{p_end}

{p 4 4 2}{cmd: forvalues s=1(1)`sim' {c -(}}{p_end}
{p 8 4 2}{cmd:quietly {c -(}}{p_end}
{p 8 4 2}{cmd:clear}{p_end}
{p 8 4 2}{cmd:set obs 900}{p_end}

{p 8 4 2}{cmd:* ---- Set parameters}{p_end}
{p 8 4 2}{cmd:local rho=0.8}{p_end}
{p 8 4 2}{cmd:gen i = mod(_n-1,100) + 1}{p_end}
{p 8 4 2}{cmd:sort i}{p_end}
{p 8 4 2}{cmd:gen t = mod(_n-1,9) + 1}{p_end}
{p 8 4 2}{cmd:gen z = -0.5 + 1.5 * runiform()}{p_end}
{p 8 4 2}{cmd:gen a = rnormal(0,0.1)}{p_end}
{p 8 4 2}{cmd:gen u = rnormal(0,0.1)}{p_end}

{p 8 4 2}{cmd:* ---- Generate data}{p_end}
{p 8 4 2}{cmd:by i: egen mean_zi = mean(z)}{p_end}
{p 8 4 2}{cmd:by i: gen yHash = (1-`rho') * z * 1 + 0.1 - 0.25 * mean_zi + a[1] if t == 1}{p_end}
{p 8 4 2}{cmd:gen y = .}{p_end}
{p 8 4 2}{cmd:by i: replace y = 0 if yHash <= 0 & t == 1}{p_end}
{p 8 4 2}{cmd:by i: replace y = yHash if yHash > 0 & yHash < 1 & t == 1}{p_end}
{p 8 4 2}{cmd:by i: replace y = 1 if yHash >= 1 & t == 1}{p_end}
{p 8 4 2}{cmd:by i: gen c = 0.1 + 0.1 * y[1] - 0.25 * mean_zi + a[1]}{p_end}
{p 8 4 2}{cmd:forvalues k = 2(1)9 {c -(}}{p_end}
{p 10 4 2}{cmd:	by i: replace yHash = `rho' * y[_n-1] + (1-`rho') * z * 1 + c + u if t == `k'} {p_end}
{p 10 4 2}{cmd:	by i: replace y = 0 if yHash <= 0 & t == `k'}{p_end}
{p 10 4 2}{cmd:	by i: replace y = yHash if yHash > 0 & yHash < 1 & t == `k'}{p_end}
{p 10 4 2}{cmd:	by i: replace y = 1 if yHash >= 1 & t == `k'}{p_end}
{p 8 4 2}{cmd:{c )-}}{p_end}

{p 8 4 2}{cmd:* ---- Run xtdpf on generated dataset.}{p_end}
{p 8 4 2}{cmd:xtset i t}{p_end}
{p 8 4 2}{cmd:xtdpf y z}{p_end}
{p 8 4 2}{cmd:matrix substitute dpf[`s',1]=_b[l1.y]}{p_end}

{p 8 4 2}{cmd:* --- Compare to Blundell/Bond and FE}{p_end}
{p 8 4 2}{cmd:xtdpdsys y z, twostep}{p_end}
{p 8 4 2}{cmd:matrix substitute blundellBond[`s',1]=_b[L.y]}{p_end}
{p 8 4 2}{cmd:xtreg y l1.y z, fe}{p_end}
{p 8 4 2}{cmd:matrix substitute fe[`s',1]=_b[l1.y]}{p_end}
{p 8 4 2}{cmd:}}{p_end}

{p 4 4 2}{cmd:* ---- Analysis }{p_end}
{p 4 4 2}{cmd:svmat dpf}{p_end}
{p 4 4 2}{cmd:svmat fe}{p_end}
{p 4 4 2}{cmd:svmat blundellBond}{p_end}
{p 4 4 2}{cmd:	quietly {c -(}}{p_end}
{p 8 4 2}{cmd:	replace dpf1=1-dpf1}{p_end}
{p 8 4 2}{cmd:	replace fe1=1-fe1}{p_end}
{p 8 4 2}{cmd:	replace blundellBond1=1-blundellBond1}{p_end}
{p 4 4 2}{cmd:}}{p_end}
{p 4 4 2}{cmd:}}{p_end}
{p 4 4 2}{cmd:summarize dpf* fe* blundellBond*}{p_end}
{p 4 4 2}{cmd: display as text "Note: Table shows average SOA estimates. The true value is 0.2"}{p_end} 

{p 4 4 2}The final table summarises estimated coefficients of the three models (transformed to SOA, where SOA is (1-rho)). Since the true SOA is set to 0.2, the results demonstrate unbiasedness of the DPF estimator, severe overestimation of SOA for FE, and underestimation by the Blundell/Bond estimator. Note that FE estimates would be biased even without censoring because of the lagged dependent variable used as a regressor, while Blundell/Bond should be unbiased without uncensoring.


{title:References}

{p 4 4 2}
Elsas, R., and D. Florysiak. "Dynamic Capital Structure Adjustment and 
the Impact of Fractional Dependent Variables." Available at http://www.ssrn.com/abstract=1632362.

{p 4 4 2}
Loudermilk, M. S. "Estimation of Fractional Dependent Variables in Dynamic Panel Data
Models with an Application to Firm Dividend Policy." Journal of Business and Economic
Statistics, 25 (2007), 462-472.


{title:Authors}

{p 4 4 2}David Florysiak, University of Munich, florysiak@bwl.lmu.de{p_end}
{p 4 4 2}Catharina Klepsch, University of Munich, klepsch@bwl.lmu.de{p_end}



{title:Also see}

{psee}
{space 2}Help: {manhelp xttobit XT}, {manhelp xtdpdsys XT}, {manhelp xtset XT}
{p_end}
