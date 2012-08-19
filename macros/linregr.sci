function varargout=linregr(varargin)
// An interactive tool for carrying out multi linear regression.
// Calling Sequence
//  linregr()           // start linregr with some demo data in interactive mode...
//  linregr(Data[,Names]) // Start in interactive mode using the data set Data (with optional column names Names) 
//  [beta,stat]=linregr(Data,Names,Zdef,Ydef[,alfa]) // run in silent command line mode - returning the results as variables.
// Parameters
//  Data : matrix containing experimental variables as column vectors.
//  Names: optional space separated string containing names for each column in Data. Each name must be a valid name for a Scilab variable.
//  Zdef: optional space separated string defining the linear regression matrix Z
//  Ydef: optional space separated string defining the dependent variable
//  alfa: optional significance level (default = 0.05) for the parameter confidence interval estimate.
//  beta: parameter estimates (only in command line mode).
//  stat: data structure with various statistical results (only in command line mode).
//  stat.Z: dependent variable matrix
//  stat.ZTZ: ZTZ=Z'*Z; 
//  stat.cov: cov=inv(ZTZ); // covariance matrix
//  stat.b: b=cov*Z'*Y; // linear regression parameters
//  stat.bint: bint=cdft('T',n-p,1-alfa/2,alfa/2)*sqrt(diag(cov)); // confidence interval for b
//  stat.bdev: bdev=sqrt(diag(cov))*SSxy; // Standard deviation of estimate
//  stat.Yhat: Yhat=Z*b; // estimate of Y
//  stat.Y: dependent observations 
//  stat.resid: resid=Y-Yhat; // residuals
//  stat.SSr: SSr=resid'*resid; // residual error
//  stat.Ybar: Ybar=mean(Y); // average Y
//  stat.SSt: SSt=(Y-Ybar)'*(Y-Ybar); // variance of the data points Y about mean(Y)
//  stat.SSe: SSe=(Yhat-Ybar)'*(Yhat-Ybar); // variance of the estimates Yhat about mean(Y)
//  stat.SSxy: SSxy=sqrt(SSr/(n-p)); // standard error of estimates of y on x
//  stat.SSy: SSy=sqrt(SSt/length(Y));  
//  stat.R2: R2=1-SSr/SSt; // R^2 of multiple correlation of y on all x
//  stat.R2adj: R2adj=1-SSr/SSt*(n-1)/(n-p-1); // R2 adjusted for the number of regression variables
// Description
//  linregr is a user friendly tool for analysing data using multi linear regression.
//   
//  In interactive mode a graphical user interface is presented and statistical results from 
//  regression analysis is presented in the Scilab Console window.
//
//  When run in silent command line mode the results are returned as the parameters beta and stat. 
//  In this mode no statistical information is displayed in the Scilab Console window. 
//
//  See the Scilab Demonstrations section for some linear regression test problems from 
//  the NIST StRD Dataset Archives.
//  
// Examples
//  X=[0:.1:2*%pi]'; Y=[X+rand(X)+X.^2+10*sin(X)];
//  [b,stat]=linregr([Y X],'y x','x x.^2 sin(x)','y')  // solve problem in command line mode
//
//  // Example from http://en.wikipedia.org/wiki/Simple_linear_regression
//  Height=[1.47, 1.50, 1.52, 1.55, 1.57, 1.60, 1.63, 1.65, 1.68, 1.70, 1.73, 1.75, 1.78, 1.80, 1.83]';
//  Weight=[52.21, 53.12, 54.48, 55.84, 57.20, 58.57, 59.93, 61.29, 63.11, 64.47, 66.28, 68.10, 69.92, 72.19, 74.46]';
//  linregr([Weight Height],'Weight Height'); // Interactive mode
//
// See also
//  nlinregr
//  nlinlsq
// Bibliography
//  http://en.wikipedia.org/wiki/Regression_analysis
//  NIST StRD Dataset Archives - Linear regression: http://www.itl.nist.gov/div898/strd/general/dataarchive.html
// Authors
//  T. Pettersen, top@tpett.com


if argn(2)==0 then
    disp('// Demo of linregr...');
    disp('X=[0:.1:2*%pi]''; Y=[X+rand(X)+X.^2+10*sin(X)];');
    disp('linregr([Y X],''Y X'')')
    X=[0:.1:2*%pi]'; Y=[X+rand(X)+X.^2+10*sin(X)];
    linregr([Y X],'Y X','X X.^2 sin(X)','Y')
    varargout=list([]);
    return
end

if typeof(varargin(1))=='constant' & argn(1)<2 then  // First call - initialize GUI
  DATA=varargin(1);
  [n,col]=size(DATA); // n=data points and col = number of columns (variables)
  if argn(2)>=2 then
    Names=varargin(2);
    if typeof(Names)<>'string' then
      error(sprintf(gettext("%s: Wrong type for input argument #%d: String expected.\n"),'linregr',2));
    end
    Names=tokens(Names); // turn space separated string into array
    if size(Names,'*')<>col then
      error(sprintf(gettext("%s: Wrong size for input argument #%d: Number of space separated names must match number of columns.\n"),'linregr',2)); 
    end
  else
    Names=sprintf('c%i\n',[1:col]');
  end
  if argn(2)>=3 then Zdef=varargin(3); else Zdef=sprintf('%s ',Names(2:$))+' 1'; end
  if argn(2)>=4 then Ydef=varargin(4); else Ydef=Names(1); end
  if argn(2)==5 then alfa=varargin(5); else alfa=0.05; end
  
  pg=list();    // Set up the GUI
  pg($+1)=list(list([1 3],'frame','Input data'));
  pg($+1)=list(list('text','No. of data points:'),list('text',sprintf('%i',n)),..
               list('text','No. of columns:'),list('text',sprintf('%i',col)));
  pg($+1)=list(list('text','Column names:'),list('text',sprintf('%s ',Names)));
  pg($+1)=list(list([1 5],'frame','Linear regression model: Yhat = Z*beta'));
  pg($+1)=list(list('text','Dependent variable: Y='),list('edit',Ydef,'tag','linregr_Y'));
  pg($+1)=list(list('text','Independent variables: Z='),list('edit',Zdef,'tag','linregr_regmod'));
  pg($+1)=list(list('text','alfa='),list('edit',string(alfa),'tag','linregr_alfa'));
  pg($+1)=list(list(1),list('pushbutton','Show data','callback','linregr(''''Show data'''')'),..
               list('pushbutton','Solve','callback','linregr(''''Solve'''')'),..
               list('pushbutton','Export','callback','linregr(''''Export_Solution'''')'),..
               list('pushbutton','Exit','callback','delete(gcbo.Parent)'),..
               list('pushbutton','Help','callback','help(''''linregr'''')'),list(1));
  h=guimaker(pg,list('linregr() - interactive linear regression'),[],2);
  // Store data in gui
  ud.data=DATA; ud.Names=Names; ud.h_Y=findobj('tag','linregr_Y'); ud.h_W=findobj('tag','linregr_W'); 
  ud.h_regmod=findobj('tag','linregr_regmod'); ud.h_alfa=findobj('tag','linregr_alfa');
  set(h(1),'userdata',ud); 
  varargout=list([]);
  return  
end

if argn(2)>3 then    // silent command line mode
    if argn(2)==5 then alfa=varargin(5); else alfa=0.05; end
    Ydef=varargin(4); Zdef=varargin(3); Names=varargin(2); Data=varargin(1);
    [b,stat]=linregr_solve(Data,Names,Zdef,Ydef,alfa,%f);
    varargout=list(b,stat);
    return
end

if argn(2)>2 then
  Interactive=%f;
else
  Interactive=%t;
end

// If called from gui
cmd=varargin(1);
h=gcbo; ud=get(h.Parent,'userdata');  // read data from gui
[r,c]=size(ud.data);

select cmd
  case "Show data"
    h=scf(); h.figure_name="linregr(""Show data"")";  // versus data points.
    n=round(c^0.5); m=ceil(c/n);
    set(h,'immediate_drawing','off');
    for i=1:n,
      for j=1:m,
        col=(i-1)*m+j;
        if col<=c then
          subplot(n,m,col); 
          plot(ud.data(:,col),'.'); xgrid()
          xtitle('','point #',sprintf('%s',ud.Names(col)));
        end
      end
    end
    set(h,'immediate_drawing','on');    
    varargout=list([]);
    
  case "Solve"
    Ydef=get(ud.h_Y,'string');
    Zdef=get(ud.h_regmod,'string');
    try 
      alfa=evstr(get(ud.h_alfa,'string')); 
    catch
      error(sprintf(gettext("%s: invalid value for alfa.\n"),'linregr'));
    end

    [b,stat]=linregr_solve(ud.data,ud.Names,Zdef,Ydef,alfa,Interactive); // Solve linear regression problem

    if Interactive then
      varargout=list([],[]);    // exit empty handed
    else
      varargout=list(b,stat);   // exit with results in output variables
    end
    ud.b=b; ud.stat=stat;
    set(gcbo.Parent,'userdata',ud); 

  case "Export_Solution"
      if ~isfield(ud,'stat') then
        disp('No solution is available - press Solve.');
        varargout=list([],[]);    // exit empty handed
      else
        disp('linregr: Exporting b and stat to Console memory... (if you get an error message - it won''t work due to a bug.)');
        [b,stat]=return(ud.b,ud.stat);
      end
end
endfunction
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
function [b,stat]=linregr_solve(Data,Names,Zdef,Ydef,alfa,Interactive)
    // 
    yvar=Ydef;
    regmod=Zdef; 
    if size(Names,'*')==1 then
        Names=tokens(Names); // turn space separated string into array
    end
    [r,c]=size(Data);
    for i=1:c, // locally define variable names
        try 
            execstr(sprintf('%s=Data(:,%i);',Names(i),i));
        catch 
            error(sprintf(gettext("%s: invalid variable name %s.\n",'linregr_solve'),Names(i)));
        end
    end

    try 
        execstr('Y='+yvar+';'); 
    catch 
        error(sprintf('Invalid definition of Y=%s. Check syntax.',yvar)); 
    end
    zvar=tokens(regmod); Z=[];
    for i=1:size(zvar,'r'),
        if zvar(i)=='1' then 
            Z=[Z ones(r,1)];
        else
            try 
                execstr('Z=[Z '+zvar(i)+'];'); 
            catch 
                error(sprintf('Invalid element %s. Check syntax.',zvar(i)));
            end
        end
    end

    // Solve linear regression problem based on the defined regression variables.
    [n,p]=size(Z);                  // n - # data points, p - # regression parameters
    ZTZ=Z'*Z;                       // 
    if det(ZTZ)==0 then error('Z matrix is not invertible'); end
    cov=inv(ZTZ);                   // covariance matrix 
    b=cov*Z'*Y;                     // least square linear estimate  parameters
    Yhat=Z*b;                       // estimated Y
    resid=Y-Yhat;                   // residual 
    SSr=resid'*resid;               // residual error (residual sum of squares)
    MSr=SSr/(n-p);                  // mean residual sum of squares
    Ybar=mean(Y);               
    SSt=(Y-Ybar)'*(Y-Ybar);       // variance of the data points about Ybar
    SSe=(Yhat-Ybar)'*(Yhat-Ybar); // variance of the estimates about Ybar
    
    SSxy=sqrt(SSr/(n-p));             // Residual standard deviation
    SSy=sqrt(SSt/length(Y));
    bdev=sqrt(diag(cov))*SSxy;        // Standard deviation of estimate
    bint=cdft('T',n-p,1-alfa/2,alfa/2)*sqrt(diag(cov))*SSxy; // confidence interval for b
    R2=1-SSr/SSt;                   // coefficient^2 of multiple correlation of y on all x
    R2adj=1-SSr/SSt*(n-1)/(n-p-1);  // R2 adjusted for the number of independent variables in the regression model
    mod_txt=yvar+'=';
    for i=1:size(zvar,'r')
        if zvar(i)=='1' then
            mod_txt=mod_txt+sprintf(' + b(%i)',i);
        else
            mod_txt=mod_txt+sprintf(' + b(%i)*%s',i,zvar(i));
        end
    end
    
    if Interactive then
        printf('\n\tAnalysis of variance:\n');
        printf('\t--------------------------------------------------------------------\n');
        printf('\tSource                       df    SS         MS         F \n');
        printf('\t--------------------------------------------------------------------\n');
        printf('\tSSr = sum[(Yhat-mean(Y))^2] %2i    %10.2e %10.2e %10.2e\n',p-1,SSe,SSe/(p-1),(SSe/(p-1))/(SSr/(n-p)));
        printf('\tSSe = sum[(Y-Yhat)^2]       %2i    %10.2e %10.2e\n',n-p,SSr,SSr/(n-p));
        printf('\t--------------------------------------------------------------------\n');
        printf('\tSSt = sum[(Y-mean(Y))^2]    %2i    %10.2e\n',n-1,SSt);
        printf('\t--------------------------------------------------------------------\n');
        printf('\tDependent variable (n=%i data points): Y = %s\n',n,yvar);
        printf('\tRegression model: Yhat = ');
        for i=1:size(zvar,'r')
            if i>1 then printf(' + '); end
            if zvar(i)=='1' then printf('beta(%i)',i); else printf('beta(%i)*%s',i,zvar(i)); end
        end
        printf('\n');
      
        printf('\t                         Conf. int    | Standard dev.\n');
        printf('\tParameter   Estimate     alpha=%5g  | of estimate\n',alfa);
        printf('\t--------------------------------------------------------------------\n');
        for i=1:size(zvar,'r'),
            printf('\tbeta(%i) = %10.2e +/- %10.2e   | %10.2e\n',i,b(i),bint(i),bdev(i));
        end
        printf('\t--------------------------------------------------------------------\n');
        printf('\tR^2 multiple correlation of y on all x:      %0.3f\n',R2);
        printf('\tR^2 adjusted for no. of indep. regr. var.:   %0.3f\n',R2adj);
        printf('\tResidual standard deviation, SSxy:           %0.3e\n',SSxy);
        printf('\n\n');
  
        h=scf(); 
        h.figure_name=sprintf('yhat=f(beta,Z); Z=[%s]',regmod);
        c=size(Z,'c');
        n=round(c^0.5); m=ceil(c/n);
        set(h,'immediate_drawing','off');
        for i=1:n,
            for j=1:m,
                col=(i-1)*m+j;
                if col<=c then
                    subplot(n,m,col); 
                    if zvar(col)<>'1' then
                        plot(Z(:,col),resid,'s'); xgrid()
                        xtitle('Z=['+regmod+']',zvar(col),'residual=Y-Yhat');
                    end
                end
            end
        end
        set(h,'immediate_drawing','on');
        scf(); 
        subplot(211)
        X=1:length(Y); plot(X,Y,'.'); plot(X,Yhat,'s'); 
        plot(X,mean(Y)*ones(Y),'-');
        xtitle('','data point #',sprintf('Y=%s',yvar));
        legend('Data','Model');
        subplot(212); qqplot(Y-Yhat); ylabel('residual=Y-Yhat')
    end
  
  // Confidence interval for yhat:
  // yhat|xi = Z*b +/- cdft('T',n-p,1-alfa/2,alfa/2)*sqrt(1/(n-p)*SSr*(1/n+(xi-mean(x(i)))^2))
  stat.Z=Z; stat.ZTZ=ZTZ; stat.cov=cov; stat.b=b; stat.bint=bint; stat.bdev=bdev;
  stat.Yhat=Yhat; stat.Y=Y; stat.resid=resid; stat.SSr=SSr; stat.Ybar=Ybar;
  stat.SSt=SSt; stat.SSe=SSe; stat.SSxy=SSxy; stat.SSy=SSy; stat.R2=R2;
  stat.R2adj=R2adj;
endfunction


