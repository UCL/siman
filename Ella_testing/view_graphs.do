/*
view_graphs.do
View all graphs (close to default) to assess quality
IW 6aug2024
*/

clear all
cd "C:\ian\git\siman\Ella_testing"
use data/extendedtestdata2, clear
siman setup, rep(re) dgm(beta pmiss mech) target(estimand) method(method) estimate(b) se(se) true(true)

siman describe 

siman zipplot if beta==1 & pmiss==1 & estim=="effect"
siman comparemethodsscatter if beta==1 & pmiss==1 & mech==1 & estim=="effect"
siman blandaltman if beta==1 & pmiss==1 & mech==1 & estim=="effect"
siman swarm if beta==1 & pmiss==1 & estim=="effect"
siman scatter if beta==1 & pmiss==1 & estim=="effect"

siman analyse 

siman table bias empse cover if beta==1 & pmiss==1 & mech==1 & estim=="effect"
siman lollyplot if beta==1 & pmiss==1 & estim=="effect", legend(row(1))
siman nestloop if estim=="effect", legend(row(1)) stagger(.05) lcol(red blue green)