// Aayusha Lamichhane
// Econ 352
// Final Paper

// Effects of COVID-19 Lockdown Duration on Business Start-ups: U.S. Analysis
// Here, HPBA is High Propensity Business Application

//Installing de Chaisemartin and D'Haultfœuille's difference-in-differences estimator
ssc install did_multiplegt

// Main data file 
use CombinedData-Lamichhane.dta, clear

// Generating variables to xtset them
encode State, gen(state_n)
gen t = mofd(new_date)
format t %tm

xtset state_n t 
order state_n t 

// Generating the lockdwon group variable
egen lock_group = total(r_lockdown_1), by (state_n)
// Here lock_group is 0 if states did not install lockdown in my study period, 1 if states installed lockdown for April, 2 if states installed lockdown for April and May, 3 if states installed lockdown in April, May, June.

// Labeling variables
label variable HPBA "High Propensity Business Application"
label variable lock_group "Different Lockdown installation groups"
label variable r_lockdown_1 "Lockdown periods"
label variable r_install_1 "Lockdown installation month"


// Restricting our data 
gen panel = ( new_date >= td("01jan2018") & new_date <= td("30nov2020"))

// Droping variables that are not needed
drop if panel == 0 
drop panel
drop r_lockdown_2
drop r_install_2

preserve

// HPBA in different lockdown groups
collapse (mean) HPBA, by (lock_group t)
twoway line HPBA t if lock_group == 1 || line HPBA t if lock_group == 2 || line HPBA t if lock_group == 3 || line HPBA t if lock_group == 0, legend(label(1 "April Only") label(2 "April & May") label(3 "April-June") label(4 "No Lockdown")) xtitle("Month")

// For parallel trends assumption 
collapse (mean) HPBA, by (lock_group t)
gen temp = 0
replace temp = HPBA if lock_group==0
egen baseHPBA = max(temp), by(t)
gen diffHPBA = HPBA-baseHPBA
replace diffHPBA = diffHPBA-3176.82+636.125 if lock_group==1
replace diffHPBA = diffHPBA-2390.79+636.125 if lock_group==2
replace diffHPBA = diffHPBA-1465+636.125 if lock_group==3

// 636.125 : 2018m1 for group0
// 3176.82 : diffHPBA for group1 (2018m1) + diffHPBA for group0 (2018m1) 
// 2390.79 : diffHPBA for group2 (2018m1) + diffHPBA for group0 (2018m1) 
// 1465 : diffHPBA for group3 (2018m1) + diffHPBA for group0 (2018m1) 

twoway line diffHPBA t if lock_group == 1, lcolor(emidblue) lpattern(longdash_dot) || line diffHPBA t if lock_group == 2, lcolor(dknavy) lpattern(dash) || line diffHPBA t if lock_group == 3, lcolor(ebblue) legend(label(1 "April Only") label(2 "April & May") label(3 "April-June")) xtitle("Month") yline(0, lcolor(cranberry)) xline(722.5, lcolor(black)) ytitle("Difference vs. Base Group in Average HPBA") xline(732, lcolor(black))



// Modeling the relationship between lockdown duration and HPBA 
. net from http://www.stata-journal.com/software/sj3-2/
. net describe st0039
. net install st0039

restore

// Transforming variables
gen lnHPBA = ln(HPBA)
gen lnCases = ln(casesmon)
gen lnVacc = ln(daily_vaccinations)
replace lnVacc = 0 if daily_vaccinations==0
replace lnCases = 0 if casesmon==0
gen dlnHPBA = D.lnHPBA
gen dlnCases = D.lnCases
gen dlnVacc = D.lnVacc
gen dLayoffRate = D.LayoffRate
gen dJobPostRate = D.JobPostRate
gen dunemploymentRate = D.unemploymentRate


// Different testing 
// Check for pre-COVID evidence of serial correlation (Nope)
xtserial lnHPBA LayoffRate JobPostRate unemploymentRate if t<tm(2020m3)
 
// Prior to COVID, any evidence that possible covariates affected HPBA? (Nope)
xtreg lnHPBA LayoffRate JobPostRate unemploymentRate i.t if t<tm(2020m3), fe vce(robust)
test LayoffRate JobPostRate unemploymentRate

// Using de Chaisemartin and D'Haultfœuille's difference-in-differences estimator
// Base model: should we be concerned about March 2020 anticipation effect?
// Without controlling for cases, it appears so...
# delimit ;
did_multiplegt lnHPBA lock_group t r_lockdown_1,
       dynamic(4) placebo(3)
       robust_dynamic
       //controls(dlnCases)
       cluster(state_n) breps(50)
       graphoptions(yline(0) legend(off) ylabel(,format(%3.2f)))
       ;
# delimit cr
 
// Here's the preferred model, controlling for growth in COVID cases:
# delimit ;
did_multiplegt lnHPBA lock_group t r_lockdown_1,
       dynamic(4) placebo(3)
       robust_dynamic
       controls(dlnCases)
       cluster(state_n) breps(50)
       graphoptions(yline(0) legend(off) ylabel(,format(%3.2f)))
       ;
# delimit cr
 
// For traditional p-values from this output, run:
ereturn list
scalar t_stat = e(effect_0)/e(se_effect_0)
scalar p_val = 2*normal(-abs(t_stat))
scalar t_stat_1 = e(effect_1)/e(se_effect_1)
scalar p_val_1 = 2*normal(-abs(t_stat_1))
scalar t_stat_2 = e(effect_2)/e(se_effect_2)
scalar p_val_2 = 2*normal(-abs(t_stat_2))
scalar t_stat_3 = e(effect_3)/e(se_effect_3)
scalar p_val_3 = 2*normal(-abs(t_stat_3))
scalar t_stat_4 = e(effect_4)/e(se_effect_4)
scalar p_val_4 = 2*normal(-abs(t_stat_4))
di "Immediate Effect: Coeff: " e(effect_0), "P-value: " p_val
di "1 Month Later: Coeff: " e(effect_1), "P-value: " p_val_1
di "2 Months Later: Coeff: " e(effect_2), "P-value: " p_val_2
di "3 Months Later: Coeff: " e(effect_3), "P-value: " p_val_3
di "4 Months Later: Coeff: " e(effect_4), "P-value: " p_val_4
 

// Naive panel first difference model with separate lockdown groups
regress D.lnHPBA lock_group#1.r_lockdown_1 D.lnCases i.t, nocons vce(cluster state_n)


