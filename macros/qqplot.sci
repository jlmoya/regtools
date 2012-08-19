function qqplot(varargin)
// Draw a quantile-quantile plot 
// Calling Sequence
//   qqplot(x,y) // compare two data sets x and y
//   qqplot(x,dist,p1,p2,...) // compare x with a distribution function with parameters p1,p2,...
//   qqplot(x)       // compare x with the standard normal distribution function (N(0,1))
//
// Parameters
// x: data set x (vector)
// y: a second data set y (vector) to compare with x
// dist: distribution function (beta | bin | chi | chn | f | fnc | gam | nbn | nor | poi | t) (string). 
// p1,p2,...: parameters relevant for the selected distribution function. See Description for details.
//
// Description
//  Compare two data sets by plotting the quantiles of each set against each other (x versys y).
//  One data set may also be plotted against quantiles generated from a statistical distribution 
//  function. 
//  
//  If the data sets come from identical distributions the points fall along the 45degree line (x=y). 
//  If the data sets come from distributions that are linearly dependent the points fall along a 
//  straight line different from x=y. 
//
//  A straight line is drawn through the first and third quantile of the two data sets.
//
// Calling sequence for comparing data set x with the available distribution functions:
// <itemizedlist>
// <listitem>Beta distribution : qqplot(x,'beta',A,B)</listitem>
// <listitem>Binomial distribution : qqplot(x,'bin',S,Pr,Ompr)</listitem>
// <listitem>Chi-square distribution : qqplot(x,'chi',Df) </listitem>
// <listitem>Non-central Chi-square distribution : qqplot(x,'chn',Df,Pnonc)</listitem>
// <listitem>F distribution : qqplot(x,'f',Dfn,Dfd)</listitem>
// <listitem>Non-central F distribution : qqplot(x,'fnc',Dfn,Dfd,Pnonc)</listitem>
// <listitem>Gamma distribution : qqplot(x,'gam',Shape,Scale)</listitem>
// <listitem>Negative binomial distribution : qqplot(x,'nbn',Pr,Ompr,S)</listitem>
// <listitem>Normal distribution : qqplot(x,'nor',Mean,Std)</listitem>
// <listitem>Poisson distribution : qqplot(x,'poi',Xlam)</listitem>
// <listitem>Student's T distribution : qqplot(x,'t',Df)</listitem>
// </itemizedlist>
//  See help cdfDIST - where DIST is beta|bin|chi|chn|f|fnc|gam|nbn|nor|poi|t for more information 
//  on the parameters associated with every distribution function.
//
// Examples
// // Compare two data sets
//  x=rand(25,1); y=rand(20,1);  
//  scf(); qqplot(x,y); // they should come from the same distribution
// 
//  // The rand() function does not follow a normal N(0,1) distribution.
//  scf(); qqplot(rand(100,1)); ylabel('Samples from rand()');
//
//  // Use grand() to get a normal distribution
//  scf(); qqplot(grand(100,1,'nor',0,1)); ylabel('grand(100,1,''nor'',0,1)');
//
// // Example from the R package (www.r.org).
// // Precipitation in US Cities, (Statistical Abstracts of the United States, 1975.).  
// precip=[67.0, 54.7,  7.0, 48.5, 14.0, 17.2, 20.7, 13.0, 43.4, 40.2, 38.9, 54.5, 59.8, 48.3, 22.9,..
//         11.5, 34.4, 35.1, 38.7, 30.8, 30.6, 43.1, 56.8, 40.8, 41.8, 42.5, 31.0, 31.7, 30.2, 25.9,..
//         49.2, 37.0, 35.9, 15.0, 30.2,  7.2, 36.2, 45.5,  7.8, 33.4, 36.1, 40.2, 42.7, 42.5, 16.2,..
//         39.0, 35.0, 37.0, 31.4, 37.6, 39.9, 36.2, 42.8, 46.4, 24.7, 49.1, 46.0, 35.9,  7.8, 48.2,..
//         15.2, 32.5, 44.7, 42.6, 38.8, 17.4, 40.8, 29.1, 14.6, 59.2]; 
//   scf(); qqplot(precip) // compare with a N(0,1) distribution.
//   ylabel('Precipitation in 70 US cities [in/yr]');
//
// See also
//  grand
//  quart
// Bibliography
//   Wikipedia; http://en.wikipedia.org/wiki/Q-Q_plot
// Authors
//   T. Pettersen, top@tpett.com 
  
  [lhs,rhs]=argn();
  if rhs==0 then  // no input arg.
    help qqplot
    return;
  end

  apifun_checktype("qqplot",varargin(1),"x",1,"constant");
  if rhs>1 then
      apifun_checktype("qqplot",varargin(2),"y",2,"constant");
  end
  if rhs>2 then
      apifun_checktype("qqplot",varargin(2),"dist",2,"string");
      apifun_checktype("qqplot",varargin(3),"p1",3,"constant");
  end
  if rhs>3 then
      apifun_checktype("qqplot",varargin(4),"p2",4,"constant");
  end
      
  x=varargin(1)(:); // data set x as column vector
  
  if rhs==2 then                            // qqplot(x,y) - comparison of two data sets.
    y=varargin(2)(:);
    n=min(length(x),length(y)); // # elements in the smallest dataset
    if n>99 then    // perctl requires integer values in the range [0,100]
      p=(1:99)';
    else
      p=int(100*((1:n)' - 0.5) ./ n); 
    end
    if length(x)==n then xx=gsort(x); else xx=perctl(x,p); xx=gsort(xx(:,1)); end
    if length(y)==n then yy=gsort(y); else yy=perctl(y,p); yy=gsort(yy(:,1)); end
    xleg="X quantiles"; yleg="Y quantiles";
  else                                        // compare x with distribution function
    if rhs==1 then                        // qqplot(x) (normal mean=0, std=1 distribution) 
      dist='nor'; 
      par=list(0,1);
    else                                      // qqplot(x,dist,p1,p2,...) type of call
      dist=varargin(2); 
      par=list(); for i=3:rhs, par(i-2)=varargin(i); end 
    end
      
    n=length(x);      // no of data points
    p=((1:n)' - 0.5) ./ n;   // default quartiles
    I=ones(x);
    select convstr(dist),
      case 'beta' then
        if length(par)<>2 then
          error(sprintf(gettext("%s: expected qqplot(x,''beta'',A,B).\n"),"qqplot"));
        end
        A=par(1)*I; B=par(2)*I;
        y=cdfbet("XY",A,B,p,1-p);
        yleg=sprintf("Beta distribution (A=%g, B=%g)",A(1),B(1));
      case 'bin' then
        if length(par)<>3 then
          error(sprintf(gettext("%s: expected qqplot(x,''bin'',S,Pr,Ompr).\n"),"qqplot"));
        end
        S=par(1)*I; Pr=par(2)*I; Ompr=par(3)*I;
        y=cdfbin("Xn",Pr,Ompr,p,1-p,S);
        yleg=sprintf("Binomial distribution (S=%g, Pr=%g, Ompr=%g)",S(1),Pr(1),Ompr(1));
      case 'chi' then
        if length(par)<>1 then
          error(sprintf(gettext("%s: expected qqplot(x,''chi'',Df).\n"),"qqplot"));
        end
        Df=par(1)*I; 
        y=cdfchi("X",Df,p,1-p);
        yleg=sprintf("Chi-square distribution (Df=%g)",Df(1));
      case 'chn' then
        if length(par)<>2 then
          error(sprintf(gettext("%s: expected qqplot(x,''chn'',Df,Pnonc).\n"),"qqplot"));
        end
        Df=par(1)*I; Pnonc=par(2)*I; 
        y=cdfchi("X",Df,Pnonc,p,1-p);
        yleg=sprintf("Non-central Chi-square distribution (Df=%g,Pnonc=%g)",Df(1),Pnonc(1));
      case 'f' then
        if length(par)<>2 then
          error(sprintf(gettext("%s: expected qqplot(x,''f'',Dfn,Dfd).\n"),"qqplot"));
        end
        Dfn=par(1)*I; Dfd=par(2)*I; 
        y=cdff("F",Dfn,Dfd,p,1-p);
        yleg=sprintf("F distribution (Dfn=%g,Dfd=%g)",Dfn(1),Dfd(1));
      case 'fnc' then
        if length(par)<>3 then
          error(sprintf(gettext("%s: expected qqplot(x,''f'',Dfn,Dfd,Pnonc).\n"),"qqplot"));
        end
        Dfn=par(1)*I; Dfd=par(2)*I; Pnonc=par(3)*I;
        y=cdffnc("F",Dfn,Dfd,Pnonc,p,1-p);
        yleg=sprintf("Non-central F distribution (Dfn=%g,Dfd=%g,Pnonc=%g)",Dfn(1),Dfd(1),Pnonc(1));
      case 'gam' then
        if length(par)<>2 then
          error(sprintf(gettext("%s: expected qqplot(x,''gam'',Shape,Scale).\n"),"qqplot"));
        end
        Shape=par(1)*I; Scale=par(2)*I; 
        y=cdfgam("X",Shape,Scale,p,1-p);
        yleg=sprintf("gamma distribution (Shape=%g,Scale=%g)",Shape(1),Scale(1));
      case 'nbn' then
        if length(par)<>3 then
          error(sprintf(gettext("%s: expected qqplot(x,''nbn'',Pr,Ompr,S).\n"),"qqplot"));
        end
        Pr=par(1)*I; Ompr=par(2)*I; S=par(3)*I; 
        y=cdfnbn("Xn",Pr,Ompr,p,1-p,S);
        yleg=sprintf("Negative binomial distribution (Pr=%g,Ompr=%g,S=%g)",Pr(1),Ompr(1),S(1));
      case 'nor' then
        if length(par)<>2 then
          error(sprintf(gettext("%s: expected qqplot(x,''nor'',Mean,Std).\n"),"qqplot"));
        end
        Mean=par(1)*I; Std=par(2)*I; 
        y=cdfnor("X",Mean,Std,p,1-p);    
        yleg=sprintf("Normal distribution (Mean=%g, Std=%g)",Mean(1),Std(1));
      case 'poi' then
        if length(par)<>1 then
          error(sprintf(gettext("%s: expected qqplot(x,''poi'',Xlam).\n"),"qqplot"));
        end
        Xlam=par(1)*I; 
        y=cdfpoi("S",Xlam,p,1-p);    
        yleg=sprintf("Poisson distribution (Xlam=%g)",Xlam(1));
      case 't' then
        if length(par)<>1 then
          error(sprintf(gettext("%s: expected qqplot(x,''t'',Df).\n"),"qqplot"));
        end
        Df=par(1)*I; 
        y=cdft("T",Df,p,1-p);    
        yleg=sprintf("Student''s T distribution (Df=%g)",Df(1));
      else
        error(sprintf(gettext("%s: %s is not a valid distribution function.\n"),"qqplot",dist));
    end
    tmp=x; x=y; y=tmp; // Swap x and y to plot x data as y axis and distribution function along the x axis.
    xleg=yleg; yleg="Sample quantiles";
    xx=gsort(x); yy=gsort(y);  
  end
  
  // straight line through 1. and 3. quantile
  qrtx=quart(x); qrty=quart(y);   
  dx=qrtx(3)-qrtx(1); 
  dy=qrty(3)-qrty(1); 
  slope=dy./dx;
  centerx=(qrtx(1)+qrtx(3))/2; 
  centery=(qrty(1)+qrty(3))/2;
  maxx=max(x); maxy=centery + slope.*(maxx-centerx); 
  minx=min(x); miny=centery - slope.*(centerx-minx);  
  mx=[minx;maxx]; my=[miny;maxy];
  
  plot(xx,yy,'.',mx,my,'k-');
  xtitle('Quantile-Quantile plot',xleg,yleg);    
endfunction
