/*
view_graphs.do
View all graphs (close to default) to assess quality
IW 6aug2024
*/

clear all
cd "C:\ian\git\siman\testing"
use data/extendedtestdata, clear
siman setup, rep(re) dgm(beta pmiss mech) target(estimand) method(method) estimate(b) se(se) true(true)

siman describe 

siman zipplot if float(beta)==float(0) & float(pmiss)==float(0.2) & estim=="effect"
siman comparemethodsscatter if float(beta)==float(0) & float(pmiss)==float(0.2) & mech==1 & estim=="effect"
siman blandaltman if float(beta)==float(0) & float(pmiss)==float(0.2) & mech==1 & estim=="effect"
siman swarm if float(beta)==float(0) & float(pmiss)==float(0.2) & estim=="effect"
siman scatter if float(beta)==float(0) & float(pmiss)==float(0.2) & estim=="effect"

siman analyse 
siman table, tabdisp

siman table bias empse cover if float(beta)==float(0) & float(pmiss)==float(0.2) & mech==1 & estim=="effect", tabdisp
siman lollyplot if float(beta)==float(0) & float(pmiss)==float(0.2) & estim=="effect", legend(row(1))
siman nestloop if estim=="effect", legend(row(1)) stagger(.05) lcol(red blue green)