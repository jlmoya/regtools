mode(1)
//
// Demo of nlinlsq.sci
//

deff('yhat=nlinmod(p,x)',['yhat=p(1)+p(2)*exp(p(3)*x);']); // define regression model to be fitted
deff('dydp=dnlinmod(p,x)',['dydp=[ones(x),exp(p(3)*x),p(2)*x.*exp(p(3)*x)];']); // define d(yhat)/dp
x=-[1:100]'/10; phat=[2;10;0.5];               // generate some data points
y=nlinmod(phat,x)+grand(100,1,'nor',0,1)/2;    // with with random noice added.
p0=ones(3,1); // initial estimate for the regression parameters.
// Solve nonlinear regression problem with output every 4'th iteration and nameing of model parmameters.
[p,stat]=nlinlsq(list(nlinmod),list(dnlinmod),x,y,[],p0,[],[],list(4,'A B C'));
halt()   // Press return to continue
 
// Solve weighted nonlinear regression problem with default names for the regression parameters
// and numerical derivatives.
[pwt,stat]=nlinlsq(list(nlinmod),'',x,y,(1)./y,p0,[],[],10);
halt()   // Press return to continue
 
// Show the difference between the two solutions...
scf(); plot(x,y,'o'); xtitle('Demo of nlinlsq()','x','y=A+B*exp(C*x)')
plot(x,nlinmod(p,x),'b-'); plot(x,nlinmod(pwt,x),'r-');
xgrid(); legend('Data','unweighted','weighted',2);
halt()   // Press return to continue
 
// Solve weighted nonlinear regression problem without analytical derivaties.
[pwt,stat]=nlinlsq(list(nlinmod),[],x,y,(1)./y,p0,[],[],10);
halt()   // Press return to continue
 
clc;
// Display the regression report from the previous solution.
nlinlsq(stat)
halt()   // Press return to continue
 
//========= E N D === O F === D E M O =========//
