%this code calculate the break even point with NPV
clear
pre=[613590 632173 651498 671596 692498 714237 736845 760357 784809 810240];
bess=[361300 376183 391806 407895 424406 441335 458746 476716 495231 514325];
pv=[446413 458580 471246 484430 498154 512439 527309 542787 558898 575667];
bsave=pre-bess;
psave=pre-pv;
i=0.02;
rate=(1+i).^(0:9);
bnpv=bsave./rate;
pnpv=psave./rate;
bcost=1299000;
pcost=768000;
%%
cumsum(bnpv)-bcost %break even between 5-6 years
cumsum(pnpv)-pcost %break even between 4-5 years
%%
ROIb=sum(bnpv)/bcost
ROIp=sum(pnpv)/pcost
%%
bcost_remain=bcost-sum(bnpv(1:5))
load('LP06_new.mat');
monthbill=sum(max(qnet,0).*P,2)+Dmax*max(qnet,[],2)
cumsum(monthbill)-bcost_remain
%%  
pcost_remain=pcost-sum(pnpv(1:4))
load('LP05_new.mat');
monthbill=sum(max(qnet,0).*P,2)+Dmax*max(qnet,[],2)
cumsum(monthbill)-pcost_remain
%%
pre_all=sum(pre);
bess_all=sum(bess);
pv_all=sum(pv);
(pre_all-bess_all)/pre_all
(pre_all-pv_all)/pre_all