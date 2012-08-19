function [p,stat]=nlinlsq(funlist,dfun,x,y,wt,p0,plo,pup,info,algo,df)
// Non-linear [weighted] least square solver with statistical analysis of the solution.
//
// Calling Sequence
// [p,[stat]]=nlinlsq(funlist,dfun,x,y,[wt],p0,[plo],[pup],[info],[algo],[df])
// p=nlinlsq(funlist,[],x,y,[],p0) // shortest call - with numerical derivatives
// nlinlsq(stat)  // print report from a previously solved regression problem.
//
// Parameters
//  funlist: string - name of non-linear model (or list with additional parameters)  
//  dfun: optional function returning the derivative of the non-linear model wrt the regression parameters p. If dfun='' numerical derivaties are used.
//  x: matrix - independent variables (as column vectors)
//  y: column vector - dependent variables
//  wt: optional column vector with weights for each dependent variable y (typically wt=(1)./y).
//  p0: column vector - inital estimates for regression parameters
//  plo: optional column vector - lower bounds for regression parameters
//  pup: optional column vector - upper bounds for regression parameters
//  info: optional list - output options
//  info(1): scalar - =0; (default) no output; =1 summary report after solution; >1 output after every info(1)'th iteration. 
//  info(2): optional text matrix or space separated string with names for the regression parameters. If not present p(1), p(2),... are used as names for the regression parameters in p.
//  algo: optional string - solution method ('qn' -(default) quasi-newton, 'gc' - conjugate gradient, 'nd' - non-differentiable model.)
//  df: optional scalar - degrees of freedom for non linear regression problem
//  p: vector - least square solution of regression parameters p
//  stat: optional structure - statistical data from parmeter estimation problem.
//  stat.ss : weighted residual sum of squares ( ss = (wt.*res)'*(wt.*res) )
//  stat.df : degrees of freedom ( df = length(y) - length(p) )
//  stat.res : vector with residuals ( res = y-funlist(p,x,...) )
//  stat.p : vector with solution of the WLSQ problem ( min sum(res.^2) subject to plo le p le pup )
//  stat.pint : confidence interval (alfa=5%) for reqression parameters ( pint = devp*cdft('T',df,1-alfa/2,alfa/2) ) 
//  stat.covp : parameter covariance matrix ( covp = inv(df/ss*(J'*J)) where J is the Jacobi matrix of res wrt p at the solution)
//  stat.corp : parameter correlation matrix ( corp = covp./sqrt(devp2*devp2'); where devp2=devp.^2; )
//  stat.devp : standard error ( devp = sqrt(diag(covp)) ).
//
// Description
//  nlinlsq solves non linear weigthed least square problems 
//  using the Scilab function optim as the non-linear optimization routine. 
//
//  Minimize SS = SUM(i, (wt*(y(i) - f(p,x(i))))^2 ) with respect to plo le p le pup.
//
//  The gradient information for the optim algorithm is estimated numerically using the 
//  numdiff function, unless dfun is defined - in which case df/dp = dfun(p,x,...) is used.  
//  dfun(p,x,...) should return [df/dp(1) df/dp(2) ... df/dp(np)] as a column matrix.
//
//  Model parameters are automatically scaled using the values in p0 as scaling factors. 
//  If max(p/p0)gt1000 or min(p/p0)le1e-3 it may be wise to re run 
//  nlinlsq with the new solution as initial quess in order to provide better scaling of the model parameters.
//
//  Statistical analysis inspired by the nls function in R (www.r.org) is available through the output variable stat.
//  
// Examples
//  deff('yhat=nlinmod(p,x)',['yhat=p(1)+p(2)*exp(p(3)*x);']); // define regression model to be fitted
//  deff('dydp=dnlinmod(p,x)',['dydp=[ones(x),exp(p(3)*x),p(2)*x.*exp(p(3)*x)];']); // define d(yhat)/dp
//  x=-[1:100]'/10; phat=[2;10;0.5];               // generate some data points 
//  y=nlinmod(phat,x)+grand(100,1,'nor',0,1)/2;    // with with random noice added.
//  p0=ones(3,1); // initial estimate for the regression parameters.
//  // Solve nonlinear regression problem with output every 4'th iteration and nameing of model parmameters.
//  [p,stat]=nlinlsq(list(nlinmod),list(dnlinmod),x,y,[],p0,[],[],list(4,'A B C'));
//
//  // Solve weighted nonlinear regression problem with default names for the regression parameters
//  // and numerical derivatives.
//  [pwt,stat]=nlinlsq(list(nlinmod),'',x,y,(1)./y,p0,[],[],10);
//
//  // Show the difference between the two solutions...
//  scf(); plot(x,y,'o'); xtitle('Demo of nlinlsq()','x','y=A+B*exp(C*x)')
//  plot(x,nlinmod(p,x),'b-'); plot(x,nlinmod(pwt,x),'r-'); 
//  xgrid(); legend('Data','unweighted','weighted',2);
//
//  // Solve weighted nonlinear regression problem without analytical derivaties.
//  [pwt,stat]=nlinlsq(list(nlinmod),[],x,y,(1)./y,p0,[],[],10);
//
//  clc; 
//  // Display the regression report from the previous solution.
//  nlinlsq(stat)
//
// See also
//  nlinregr
//
// Authors
//  T. Pettersen, top@tpett.com

// Copyright Torbjørn Pettersen (2005-2011)
// $Revision: 1.7 $
// $Date: 2011-03-02 18:59:23+01 $

global nlinlsq_; nlinlsq_.itt=0; nlinlsq_.info=0;

[lhs,rhs]=argn(); // sjekk antall input/output argumenter.
if rhs==0 then // kjør en demo.
    disp('Demo of nlinlsq');
    deff('yhat=nlinmod(p,x)',['yhat=p(1)+p(2)*exp(p(3)*x);']);                      // yhat
    deff('dydp=dnlinmod(p,x)',['dydp=[ones(x),exp(p(3)*x),p(2)*x.*exp(p(3)*x)];']); // d(yhat)/dp
    x=-[1:100]'/10; phat=[2;10;0.5];               // generate some data points 
    y=nlinmod(phat,x)+grand(100,1,'nor',0,1)/2; 
    p0=ones(phat);
    [p,stat]=nlinlsq(list(nlinmod),list(dnlinmod),x,y,[],p0,[],[],list(4,'A B C'));
    [pwt,stat]=nlinlsq(list(nlinmod),list(dnlinmod),x,y,(1)./y,p0,[],[],10);
  
    scf(); plot(x,y,'o'); xtitle('Demo of nlinlsq()','x','y=a+b*exp(c*x)')
    plot(x,nlinmod(p,x),'b-'); plot(x,nlinmod(pwt,x),'r-'); 
    xgrid(); legend('Data','unweighted','weighted',2);
    return
end

if rhs==1 then
    if type(funlist)==17 then
        report_summary(funlist); 
        p=stat.p; return; 
    else
        error('Invalid input in call to nlinlsq.'); 
    end
end

if ~isempty(wt) & length(wt)~=length(y) then error('wt should have same length as y'); end
if rhs<7 | isempty(plo) then plo=-%inf*ones(p0); end
if rhs<8 | isempty(pup) then pup=%inf*ones(p0); end
if rhs<9 then info=0; end
if rhs<10 | isempty(algo) then algo='qn'; end

if length(plo)==1 then plo=plo*ones(p0); end
if length(pup)==1 then pup=pup*ones(p0); end

p0=p0(:); plo=plo(:); pup=pup(:); // ensure only column vectors

// Add labels to model parameters
if length(info)==1 then 
  info=list(info,sprintf('p(%i)\n',[1:length(p0)]')); 
elseif max(size(info(2)))==1 then
  info(2)=tokens(info(2));
elseif max(size(info(2)))~=length(p0) then
  error('Parameter names given in info does not match number of parameters');
end;
nlinlsq_.info=info;

// add dfun, independent, dependent and weights for use in costf
//if ~isempty(x) then funlist($+1)=x; end
funlist($+1)=dfun(1);
funlist($+1)=x;
funlist($+1)=y; 
funlist($+1)=wt;
nlinlsq_.pScale=p0;
[ss,p]=optim(list(costf,funlist),'b',plo./nlinlsq_.pScale,pup./nlinlsq_.pScale,p0./nlinlsq_.pScale,algo); // solve optimisation problem
p=p.*nlinlsq_.pScale;

if lhs==2 | info(1) then  // if statistical data is required...
  [res,J]=costf(p./nlinlsq_.pScale,5,funlist);  // evaluate residual and Jacobi matrix at solution

  m=length(res);               // number of data points
  np=length(p);                // number of parameters
  if rhs<10 then 
    df=m-np;                     // degrees of freedom
  end

  if isempty(wt) then
    ss = (res)'*(res)
  else
    ss = (wt.*res)'*(wt.*res);   // weighted sum of squares
  end
  s2 = ss/df;                  // Estimate of error variance
  sres=sqrt(s2);               // Residual standard deviation (http://www.itl.nist.gov/div898/handbook/pri/section5/pri599.htm)
  covp=inv(1/s2*(J'*J));       // covariance matrix of parameters
  devp=sqrt(diag(covp));       // deviation vector 
  devp2=devp.^2;
  corp=covp./sqrt(devp2*devp2'); // parameter correlation matrix
  alfa=0.05;
  pint=devp*cdft('T',df,1-alfa/2,alfa/2); // parameter confidence interval
	
  stat.ss=ss; stat.s2=s2; stat.sres=sres; stat.covp=covp; stat.df=df;
  stat.devp=devp; stat.corp=corp; stat.pint=pint; stat.p=p;
  stat.res=res; stat.J=J; stat.info=info;
  
  if info(1) then
    h=scf(); set(h,'immediate_drawing','off');
    nvar=size(x,'c'); // number of independent variables
    n=round((nvar+3)^0.5); m=ceil((nvar+3)/n);
    for i=1:n,
      for j=1:m,
        col=(i-1)*m+j;
        if col<=nvar+3 then
          subplot(n,m,col);
          if col<=nvar then
            plot(x(:,col),res,'.'); xgrid(); xtitle('',sprintf('x(%i)',col),'res=y-f(p,x)');
          elseif col==nvar+1 then
            plot(y,res,'.'); xgrid(); xtitle('','y','res=y-f(p,x)');
          elseif col==nvar+2 then
            plot(res(1:$-1),res(2:$),'.'); xgrid(); xtitle('Auto correlation','res(i)','res(i+1)');
          elseif col==nvar+3 then
            qqplot(res); ylabel('res=y-f(p,x))');
          end          
        end
      end
    end
    set(h,'immediate_drawing','on');
    report_summary(stat);
  end
end
endfunction
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

function [f,g,ind]=costf(p,ind,funlist)
// p - optimization parameters
// ind - control index
// funlist(1) - f(p,x,[optional parameters])
//        (2) - d(f(p,x,[optional parameters]))/dp
//        (3:$-3) - optional parameters
//        ($-2) - x independent variables
//        ($-1) - y dependent variables
//        ($) - wt weight of residuals

global nlinlsq_;
pReal=p.*nlinlsq_.pScale;
wt=funlist($); if isempty(wt) then wt=1; end
y=funlist($-1);
lst=funlist($-2);                                           // get x and any
if size(funlist)>5 then lst=lstcat(lst,funlist(3:$-3)); end // additional parameters
f=[]; g=[];
if ind==2 then 	// return f
    f=costf2(p,funlist);
end
if ind==3 | ind==4 then
    if typeof(funlist(2))<>"function" then
        g = numdiff(list(costf2,funlist),p)';    // numerical derivatives
    else    // analytical derivatives
        yhat = funlist(1)(pReal,lst);
        dfdp = funlist(2)(pReal,lst); 
        [n,m]=size(dfdp);
        g = -2 * nlinlsq_.pScale .* sum( dfdp .* ((wt.^2) .* (y-yhat)*ones(1,m)),'r')';
    end
end
if ind==4 then // return f and g
    f=costf2(p,funlist);
elseif ind==5 then  // Generate statistics for current solution
    f = y - funlist(1)(pReal,lst);
    if typeof(funlist(2))<>"function" then
        g = numdiff(list(funlist(1),lst),pReal);
    else
        g = funlist(2)(pReal,lst);
    end
else
    ind=-1;
end
if nlinlsq_.info(1) then
  np=length(p);
  if nlinlsq_.itt==0 then
    printf('----------------------------------------------------------------------\n');
    printf('                     nlinlsq solution progress                        \n');
    printf('----------------------------------------------------------------------\n');
    printf(' Itt       SS       gradient '); printf(' %10s',nlinlsq_.info(2)); printf('\n');
  end
  if ~modulo(nlinlsq_.itt,nlinlsq_.info(1)) & ind>1 & ind<5 then
    printf(' %3i  %10.2e  %10.2e |',nlinlsq_.itt,f,sum(abs(g)));
    printf(' %10.2e',pReal(:)); printf('\n');
  end
end
nlinlsq_.itt=nlinlsq_.itt+1; // itteration counter
//if ~modulo(nlinlsq_.itt,15) then disp('Test numdiff'); pause; end
endfunction
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

function [ss,g]=costf2(p,funlist,gdef)
// 
global nlinlsq_;
pReal=p.*nlinlsq_.pScale;
y=funlist($-1);     // dependent variable
wt=funlist($);      // weight vector
res=y-funlist(1)(pReal,funlist(3:$-2));
if isempty(wt) then
    ss=res(:)'*res(:);
else
    ss=(wt.*res(:))'*(wt.*res(:));
end
if argn(1)==2 then
    lst=funlist($-2);                                           // get x and any
    if size(funlist)>4 then lst=lstcat(lst,funlist(3:$-3)); end // additional parameters
    if argn(2)==3 then
        g=gdef(pReal,funlist(3:$-2));
    else
        g=numdiff(list(funlist(1),lst),pReal);
    end
end
endfunction

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

function report_summary(stat)
printf('\n=============================================================\n');
printf('                      REPORT SUMMARY                      \n');
printf('-------------------------------------------------------------\n');
printf('Parameters:\n');
printf('           Estimate   Std. Error     t-value  Pr(>|t|)   Sign\n');
tTest=stat.p./stat.devp; [P,Q]=cdft('PQ',abs(tTest),stat.df*ones(stat.p)); 
Sign=[]; np=length(stat.p);
for i=1:np, 
  if 2*Q(i)<0.001 then 
    Sign=[Sign;'***'];
  elseif 2*Q(i)>=0.001 & 2*Q(i)<0.01 then
    Sign=[Sign;'** '];
  elseif 2*Q(i)>=0.01 & 2*Q(i)<0.05 then
    Sign=[Sign;'*  '];
  elseif 2*Q(i)>=0.05 & 2*Q(i)<0.1 then
    Sign=[Sign;'.  '];
  else
    Sign=[Sign;'   '];
  end
end
printf('%10s %10.2e  %10.2e %10.2f  %10.2e %4s\n',stat.info(2),stat.p,stat.devp,tTest,2*Q,Sign);
printf('---\n');
printf('Signif. codes: 0 `***´ 0.001 `**´ 0.01 `*´ 0.05 `.´ 0.1 ` ´ 1\n');
printf('\nResidual standard error: %9.2e on %i degrees of freedom\n',sqrt(stat.s2),stat.df);
printf('\nResidual sum of squares: %9.2e\n',stat.ss);
printf('\n-----\nAsymptotic confidence interval:\n');
printf('             2.5%%        97.5%%\n');
printf('%10s %10.2e   %10.2e\n',stat.info(2),stat.p-stat.pint,stat.p+stat.pint);
if np>1 then
  printf('\n-----\nCorrelation matrix:\n');
  printf('          '); printf(' %10s',stat.info(2)([1:np-1])); printf('\n');
  for i=2:np, 
    printf(' %10s',stat.info(2)(i)); printf(' %10.3f',stat.corp(i,1:i-1)'); printf('\n');
  end
end
printf('=============================================================\n\n');
endfunction

