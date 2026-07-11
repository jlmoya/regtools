function varargout=nlinregr(varargin)
// Interactive non linear regression solver
// Calling Sequence
//  nlinregr(Data,Names,funDef,dfunDef,pDef,YDef[,WDef][,pEst][,pLo][,pUp][,alfa]) // Start in interactive mode.
//  [phat,yhat[,stat]]=nlinregr(Data,Names,funDef,dfunDef,pDef,YDef[,WDef][,pEst][,pLo][,pUp][,alfa]); // Run in silent command line mode.
//  nlinregr();  // Start nlinregr with example data in interactive mode.
// Parameters
//  Data: matrix with experimental data (dependent and independent variables) stored as column vectors. 
//  Names: string with space separated names for each column vector in Data. E.g 'x y z'.
//  funDef: string with definition of the non linear regression function yhat=f(x,p). E.g 'A+B*exp(C*x)'.
//  dfunDef: optional string with definition analytical derivatives df(x,p)/dp. e.g '[ones(x),exp(C*x),B*x.*exp(C*x)]'.
//  pDef: string with space separated parameter names. E.g. 'A B C'
//  YDef: string with name of the dependent data variables y (from Names)' E.g 'y'
//  WDef: optional flag selecting predefined weight strategy: =1(default): no weight factor wt=ones(y). =2: wt=(1)./y.^2. =3: wt=(1)./y.
//  pEst: optional column vector with initial estimate for non linear regression parameters. Default is ones(np,1). pEst is also used for internal scaling of the model parameters.
//  pLo: optional lower bounds on parameters as column vector or scalar (default = +%Inf).
//  pUp: optional upper bounds on parameters as column vector or scalar (default = -%Inf).
//  alfa: optional significance level for parameter confidence interval estimates (default alfa=0.05).
//  phat: parameter value at the solution of the non linear regression problem.
//  yhat: dependent variable estimates (yhat=f(x,phat)).
//  stat: optional structure with regression statistics at the solution.
//  stat.ss : weighted residual sum of squares ( ss = (wt.*res)'*(wt.*res) )
//  stat.df : degrees of freedom ( df = length(y) - length(p) )
//  stat.res : vector with residuals ( res = y-f(x,p) )
//  stat.p : vector with solution of the WLSQ problem ( Minimize: ss. Subject to: plo .le. p .le. pup.)
//  stat.pint : confidence interval (at alfa significance level) for reqression parameters ( pint = devp*cdft('T',df,1-alfa/2,alfa/2) ) 
//  stat.covp : parameter covariance matrix ( covp = inv(df/ss*(J'*J)) where J is the Jacobi matrix of res wrt p at the solution p=phat)
//  stat.corp : parameter correlation matrix ( corp = covp./sqrt(devp2*devp2'); where devp2=devp.^2; )
//  stat.devp : standard error ( devp = sqrt(diag(covp)) ).
// Description
//  nlinregr is an interactive frontend for the non linear regression solver nlinlsq.
//
//  A non linear function yhat=f(x,p) is fitted to the data set y [x] using
//  non linear regression analysis. The following optimization problem is solved:
//
//  Minimize ss=sum(((y-f(x,p)).*wt).^2) subject to: pLo .le.  p .le.  pUp.
//
//  Regression statistics like asymptotic confidence intervals and correlation matrix 
//  for the model parameters are calculated and presented in a solution report inspired by 
//  the nls function in R Project.
// 
//  Note that new data may be loaded directly from Excel spreadsheet files when nlinregr is 
//  started in interactive mode. 
//  Use the button "Load data" from the GUI to read data from .xls files.
//  The data in the Excel spreadsheets must be located in the upper left corner of the spreadsheet.
//  The first row should contain Names for each column vector in Data.
//  Numbers in subsequent rows are stored in Data. Number of columns must match number of columns
//  in the first row. 
//
//  See the Scilab Demonstrations section for some non linear regression test problems from 
//  the NIST StRG Dataset Archives. nlinregr is not able to solve all these problems. 
//  Consider using R for hard problems. 
//  
// Examples
//  x=-[1:100]'/10; y=2+10*exp(x/2)+grand(100,1,'nor',0,1)/2; // some noisy data
//  fun='A+B*exp(C*x)'; dfun='[ones(x), exp(C*x), B*x.*exp(C*x)]';
//  [p,yhat,stat]=nlinregr([x y],'x y',fun,dfun,'A B C','y',1,[1;1;1]) // fit curve directly
//
//  nlinregr([x y],'x y',fun,dfun,'A B C','y',1,[1;1;1]); // solve problem interactivly from gui
//
//  // Data example from R (http://www.r-project.org/). See help on nls and DNase in R.
//  conc=[0.04882812 0.04882812 0.1953125 0.1953125 0.390625 0.390625 0.78125 0.78125 1.5625 1.5625 3.125 3.125 6.25 6.25 12.5 12.5]';
//  density=[0.017 0.018 0.121 0.124 0.206 0.215 0.377 0.374 0.614 0.609 1.019 1.001 1.334 1.364 1.73 1.71]';
//  fun='Asym./(1+exp((xmid-log(conc))./scal))'; pnames='Asym xmid scal';
//  dfun='[1.0./(exp((xmid-log(conc))/scal)+1), Asym*exp((xmid-log(conc))/scal)./(scal*(exp((xmid-log(conc))/scal)+1).^2), Asym*(xmid-log(conc)).*exp((xmid-log(conc))/scal)./(scal^2*(exp((xmid-log(conc))/scal)+1).^2)]'; 
//  [p,yhat,stat]=nlinregr([conc density],'conc density',fun,dfun,'Asym xmid scal','density',1,[1;1;1]); // unweighted model
//
//  nlinregr([conc density],'conc density',fun,dfun,'Asym xmid scal','density',2,[1;1;1]); // weighted model
//
// See also
//  nlinlsq
//  linregr
// Authors
//  T. Pettersen, top@tpett.com
// Bibliography
//  The R Project (www.r-project.org)
//  NIST StRD Dataset Archives - Non linear regression http://www.itl.nist.gov/div898/strd/general/dataarchive.html

// Copyright Torbjørn Pettersen (2008-2011)
// $Revision: 1.4 $
// $Date: 2011-02-25 18:59:13+01 $

if argn(2)==1 then // Assume that we where called from the gui
  cmd=varargin(1); // What to do...
  h_gui=gcbo.Parent;
  ud=gcbo.Parent.user_data; // get user data stored in the GUI figure.
  varargout=list([]);
  select cmd
    case "Plot data"
      legs='Plus|Circle|Asterisk|Point|Cross|Square|Diamond|Solid|Dashed|Dotted|Dash-dotted';
      legs2=tokens('+|o|*|.|x|s|d|-|--|:|-.','|');
      pg=list();
      pg($+1)=list(list(1),list('text','Data'),list('text','Model'));
      pg($+1)=list(list('text','Y-axis'),list('text',ud.Names(get(ud.h_Y,'value'))),list('checkbox',''));
      pg($+1)=list(list('text','X-axis'),list('popupmenu',strcat(ud.Names,'|')),list(1));
      pg($+1)=list(list('text','Legend'),list('popupmenu',legs,'value',2),list('popupmenu',legs,'value',8));
      pg($+1)=list(list(1),list('pushbutton','Plot','callback','OK=%t'),list('pushbutton','Cancel','callback','CANCEL=%t'),list(1));
      [Model,Xaxis,DataLeg,ModelLeg]=guimaker(pg,list('Plot options',300),[],'nlinregr_PlotOptions');
      if ~isempty(Model) then
        if isempty(ud.stat) then
          disp('Press Solve to solve regression model. Plotting only data points')
          Model=0;
        end
        
        scf();
        if Model then
          plot(ud.data(:,Xaxis),ud.data(:,get(ud.h_Y,'value')),legs2(DataLeg),..
               ud.data(:,Xaxis),ud.yhat,legs2(ModelLeg));
          xtitle(ud.Formula,ud.Names(Xaxis),ud.Names(get(ud.h_Y,'value')));
          legend('Data','Model',5);
        else
          plot(ud.data(:,Xaxis),ud.data(:,get(ud.h_Y,'value')),legs2(DataLeg))
          xtitle('',ud.Names(Xaxis),ud.Names(get(ud.h_Y,'value')));
        end
      end
    case "Load data"
      xlsfile=uigetfile('*.xls','','Read data from Excel spreadsheet file');
      shts=readxls(xlsfile);
      filled=[]; name=[];
      for i=1:length(shts)
        if sum(~isnan(shts(i).value))>0 then filled($+1)=i; name($+1)=shts(i).name; end
      end
      if length(filled)==0 then 
        warning(sprintf(gettext('%s: %s contains no data.\n'),'nlinregr',xlsfile));
        return;
      end
      if length(filled)>1 then
        slct=x_choose(name,['Double-click on sheet name';'to load data from.']);
        if slct==0 then 
          warning(sprintf(gettext('%s: No data sheet selected.\n'),'nlinregr'));
          return;
        end
      else
        slct=1;
      end
      data=shts(filled(slct)).value;
      [i,j]=find(~isnan(data));
      ud.data=data(min(i):max(i),min(j):max(j)); // get rid of %nan
      ud.Names=shts(filled(slct)).text(min(i)-1,min(j):max(j))'; // get hold of column names
      if find(isnan(ud.data)) then
        warning(sprintf(gettext('%s: Failed to read data from sheet %s workbook %s.\n'),'nlinregr',name(slct),xlsfile));
        return
      end
      
      [p,f,e]=fileparts(xlsfile); 
      set(ud.h_DataSource,'string',sprintf('Sheet %s in book %s',name(slct),f+e));
      
      [n,col]=size(ud.data);
      set(ud.h_n,'string',string(n)); set(ud.h_col,'string',string(col));
      set(ud.h_Names,'string',sprintf('%s ',ud.Names));
      set(ud.h_Y,'string',strsubst(stripblanks(sprintf('%s ',ud.Names)),' ','|'));
      set(gcbo.Parent,'user_data',ud);
      
    case "Solve"
      // Convert regression function into the curve function passed on to nlinlsq()
      formula=get(ud.h_regmod,'string');
      formula=nlinregr_formula(formula,get(ud.h_p,'string'),'p(%i)');
      formula=nlinregr_formula(formula,sprintf('%s ',ud.Names),'data(:,%i)');            
      deff('[yhat]=curve(p,data)','yhat='+formula);
      // and do the same for the analytical derivative - if given.
      formula=get(ud.h_dregmod,'string');
      if isempty(formula) then
          dcurve=[];
      else
          formula=nlinregr_formula(formula,get(ud.h_p,'string'),'p(%i)');
          formula=nlinregr_formula(formula,sprintf('%s ',ud.Names),'data(:,%i)');            
          deff('[dydp]=dcurve(p,data)','dydp='+formula);
      end
      // assign the local variable y as the dependent variable.
      y=ud.data(:,get(ud.h_Y,'value')); // dependent variables
      ud.Formula=ud.Names(get(ud.h_Y,'value'))+'='+get(ud.h_regmod,'string'); // regression model
      // assign the local variable wt as the weight vector for the dependent variable y
      wt_selection=get(ud.h_W,'value');
      select wt_selection
        case 1, 
          wt=[]; wt_def='1';
        case 2,
          wt= 1 ./(y.^2); wt_def='(1)./(y.^2)';
        case 3,
          wt = 1 ./ y; wt_def='(1)./y';
        else
          error('nlinregr: noe feil med wt');
      end
      // create pest as initial estimate for parameter values
      try 
        pest=evstr(get(ud.h_pEst,'string'));
      catch
        error(sprintf(gettext("%s: invalid pEst value. Check input.\n"),'nlinregr'));
      end
      // create plo as lower bound for parameter values
      try 
        plo=evstr(get(ud.h_pLo,'string'));
      catch
        error(sprintf(gettext("%s: invalid pLo value. Check input.\n"),'nlinregr'));
      end
      // create pup as upper bound for parameter values
      try 
        pup=evstr(get(ud.h_pUp,'string'));
      catch
        error(sprintf(gettext("%s: invalid pUp value. Check input.\n"),'nlinregr'));
      end
     
      // Check if the initial estimate and the model is ok
      try
        yhat=curve(pest,ud.data);
      catch
        msg=['Failed to solve the regression model f(x,p).'
             'Check inital estimate and model equation for syntax errors.'
             'Hints: Use .*, ./ and .^ for vector operations.'
             '       1./x is not the same as (1)./x.'
             ];
        printf('%s\n',msg);
        return
      end

      // Solve regression problem.
      printf(['Minimize\tsum(((y-yhat).*wt).^2)\nSubject to:\t yhat=%s\n\t\twt=%s\n'],get(ud.h_regmod,'string'),wt_def);
      [phat,stat]=nlinlsq(list(curve),list(dcurve),ud.data,y,wt,pest,plo,pup,list(10,get(ud.h_p,'string')));
      set(ud.h_pEst,'string',sprintf('%.3g ',phat(:))); // update gui
      if max(phat./pest(:))>1e3 | min(phat./pest(:))<1e-3 then 
        printf('nlinregr: Poor initial estimate - leads to poor scaling.\n\tPress Solve to re solve model with better scaling.\n');
      end
      
      yhat=curve(phat,ud.data);
      if argn(1)>1 then
        varargout=list(phat,yhat,stat);
      else
        varargout=list(phat);
      end
      ud.stat=stat; ud.phat=phat; ud.yhat=yhat;
      set(gcbo.Parent,'user_data',ud);
    case "Export solution"
      if isempty(ud.stat) then
        disp('No solution is available - press Solve.');
      else
        disp('nlinregr: Exporting phat, yhat and stat to Console memory...');
        [phat,yhat,stat]=return(ud.phat,ud.yhat,ud.stat);
      end
    else
      if typeof(cmd)<>'string' then error(sprintf(gettext("%s: Expected string argument - invalid call!\n"),'nlinregr')); end
      error(sprintf(gettext("%s: Invalid command %s - invalid call!\n"),'nlinregr',cmd));
  end
  varargout=list([]);
  return
end

if argn(2)<5 & argn(2)>1 then error(sprintf(gettext("%s: wrong number of input arguments.\n"),'nlinreg')); end

if argn(2)==0 then // no input - run a demo
  x=-[1:100]'/10;
  y=2+10*exp(0.5*x)+grand(100,1,'nor',0,1)/2; 
  Data=[x y]; Names='x y';
  YDef='y'; funDef='A + B*exp(C*x)'; dfunDef='[ones(x), exp(C*x), B*x.*exp(C*x)]';
  pDef='A B C'; WDef='1'; pEst=[1 1 1]'; 
  nlinregr(Data,Names,funDef,dfunDef,pDef,YDef,WDef,pEst);
  varargout=list([]);
  return
end

Data=varargin(1); Names=varargin(2); funDef=varargin(3); dfunDef=varargin(4);
pDef=varargin(5); YDef=varargin(6); 
YDefAlts=strsubst(stripblanks(sprintf('%s ',Names)),' ','|');
YDefSlct=find(tokens(Names)==YDef); 
if isempty(YDefSlct) then error(sprintf(gettext("%s: %s is not a valid column name.\n"),'nlinregr',YDef)); end
if argn(2)<7 then WDef=1; else WDef=varargin(7); end
if argn(2)<8 then pEst=ones(size(tokens(pDef),'*'),1); else pEst=varargin(8); end
if argn(2)<9 then pLo=[]; else pLo=varargin(9); end
if argn(2)<10 then pUp=[]; else pUp=varargin(10); end
if argn(2)<11 then alfa=0.05; else alfa=varargin(11); end

[n,col]=size(Data); // n=data points and col = number of columns (variables)

// Check input.
if typeof(Data)<>'constant' then error(sprintf(gettext("%s: wrong type for argument# %d. Expected matrix.\n"),'nlinreg',1)); end
if size(tokens(Names),'r')<>col then error(sprintf(gettext("%s: number of Names does not match number of columns in Data.\n"),'nlinreg')); end

if typeof(Names)<>'string' then error(sprintf(gettext("%s: Wrong type for input argument #%d: String expected.\n"),'linregr',2)); end
Names=tokens(Names); // turn space separated string into array
if size(Names,'*')<>col then error(sprintf(gettext("%s: Wrong size for input argument #%d: \n\tNumber of space separated names must match number of columns.\n"),'linregr',2));  end

if argn(1)<2 then   // interactive mode
  if ~isdef("guimaker") then
    error(sprintf(gettext("%s: guimaker is not installed - the interactive GUI is unavailable.\n\tUse command-line mode instead: [phat,yhat,stat]=%s(Data,Names,funDef,dfunDef,pDef,YDef,...).\n"),'nlinregr','nlinregr'));
  end
  if findobj('tag','nlinregr_DataSource') then
     error(sprintf(gettext('%s: nlinregr is already running.\n'),'nlinregrn'));
  end
  pg=list();    // Set up the GUI
  pg($+1)=list(list([1 4],'frame','Input data'));
  pg($+1)=list(list('text','Data source:'),list(4,'text','','tag','nlinregr_DataSource'));
  pg($+1)=list(list('text','No. of data points:'),list('text',sprintf('%i',n),'tag','nlinregr_n'),..
               list('text','No. of columns:'),list('text',sprintf('%i',col),'tag','nlinregr_col'));
  pg($+1)=list(list('text','Column names:'),list('text',sprintf('%s ',Names),'tag','nlinregr_Names'));
  pg($+1)=list(list([1 7],'frame','Non linear regression model: y = f(X,p)'));
  pg($+1)=list(list('text','Dependent variable: y='),..
               list('popupmenu',YDefAlts,'value',YDefSlct,'tag','nlinregr_Y','HorizontAlalignment','center'),..
               list('text','Weight matrix: W='),..
               list('popupmenu','none|1./y.^2|1./y','value',1,'tag','nlinregr_W','HorizontAlalignment','center'));
  pg($+1)=list(list('text','Regression model: f(X,p)='),list(3,'edit',funDef,'tag','nlinregr_fun','HorizontAlalignment','center'));
  pg($+1)=list(list('text','Analytical derivatives: df/dp'),list(3,'edit',dfunDef,'tag','nlinregr_dfun','HorizontAlalignment','center'));
  pg($+1)=list(list('text','Parameter names:'),list('edit',pDef,'tag','nlinregr_p','HorizontAlalignment','center'),..
               list('text','Initial estimate: pEst='),list('edit',sprintf('%g ',pEst),'tag','nlinregr_pEst','HorizontAlalignment','center'));
  pg($+1)=list(list('text','Lower bound:'),list('edit','','tag','nlinregr_pLo','HorizontAlalignment','center'),..
               list('text','Upper bound:'),list('edit','','tag','nlinregr_pUp','HorizontAlalignment','center'));
  pg($+1)=list(list('text','alfa='),list('edit','0.05','tag','nlinregr_alfa','HorizontAlalignment','center'),list(1),list(1));
  pg($+1)=list(list(1));
  pg($+1)=list(list(1),list('pushbutton','Plot data','callback','nlinregr(''''Plot data'''')'),..
               list('pushbutton','Load data','callback','nlinregr(''''Load data'''')'),..
               list('pushbutton','Solve','callback','nlinregr(''''Solve'''')'),..
               list('pushbutton','Export sol.','callback','nlinregr(''''Export solution'''')'),..
               list('pushbutton','Exit','callback','delete(gcbo.Parent)'),..
               list('pushbutton','Help','callback','help(''''nlinregr'''')'),list(1));
  h=guimaker(pg,list('nlinregr() - non linear regression',650),[],2);
  // Store data and handles as user data in the gui window 
  ud.data=Data; ud.Names=Names; ud.h_Y=findobj('tag','nlinregr_Y'); ud.h_W=findobj('tag','nlinregr_W'); 
  ud.h_p=findobj('tag','nlinregr_p');   ud.h_pEst=findobj('tag','nlinregr_pEst'); 
  ud.h_pLo=findobj('tag','nlinregr_pLo'); ud.h_pUp=findobj('tag','nlinregr_pUp'); 
  ud.h_regmod=findobj('tag','nlinregr_fun'); ud.h_dregmod=findobj('tag','nlinregr_dfun'); 
  ud.h_alfa=findobj('tag','nlinregr_alfa');
  ud.h_DataSource=findobj('tag','nlinregr_DataSource');
  ud.h_Names=findobj('tag','nlinregr_Names');
  ud.h_n=findobj('tag','nlinregr_n'); ud.h_col=findobj('tag','nlinregr_col');
  ud.stat=[]; // indicate no solution.
  set(h(1),'userdata',ud); 
  varargout=list([]);
  return
end

// direct call - just solve the model and return
[phat,yhat,stat]=nlinregr_solve(funDef,dfunDef,pDef,Names,Data(:,YDefSlct),Data,WDef,pEst,pLo,pUp)
varargout=list(phat,yhat,stat);
endfunction
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
function new_expr=nlinregr_formula(expr,old_names,new_nameformat)
  // private function which replace parameter names with p(1),...p(n) and 
  // independent variables with data(:,1),...data(:,i). Used to create the curve function.
  expr=stripblanks(expr);
  Names=tokens(old_names);
  str='[\=\.\^\+\-\(\)\*\/\\,]';
  for i=1:size(Names,'*'),
    [m,n]=regexp(expr,'/^'+Names(i)+'/'); // parameter alone in front
    if ~isempty(m) then expr=sprintf(new_nameformat,i)+part(expr,[n+1:length(expr)]); end
    [m,n]=regexp(expr,'/'+str+'\s*'+Names(i)+'\s*'+str+'/'); // parameter in the middle
    while ~isempty(m) // continue until all occurences have been replaced
      expr=part(expr,[1:m(1)])+sprintf(new_nameformat,i)+part(expr,[n(1):length(expr)]);
      [m,n]=regexp(expr,'/'+str+Names(i)+str+'/'); // parameter in the middle
    end
    [m,n]=regexp(expr,'/'+Names(i)+'$/'); // parameter alone in the back
    if ~isempty(m) then expr=part(expr,[1:m-1])+sprintf(new_nameformat,i); end
  end  
  new_expr=expr; 
endfunction
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
function [phat,yhat,stat]=nlinregr_solve(formula,dformula,pNames,colNames,y,data,wt_selection,pEst,pLo,pUp)
  // Convert regression function into the curve function passed on to nlinlsq()
  formula=nlinregr_formula(formula,pNames,'p(%i)');
  formula=nlinregr_formula(formula,sprintf('%s ',colNames),'data(:,%i)');            
  deff('[yhat]=curve(p,data)','yhat='+formula);
  // and do the same for the analytical derivative - if given.
  if isempty(dformula) then
      dcurve=[];
  else
      dformula=nlinregr_formula(dformula,pNames,'p(%i)');
      dformula=nlinregr_formula(dformula,sprintf('%s ',colNames),'data(:,%i)');            
      deff('[dydp]=dcurve(p,data)','dydp='+dformula);
  end
  // assign the local variable wt as the weight vector for the dependent variable y
  select wt_selection
    case 1, 
      wt=[];
    case 2,
      wt= 1 ./(y.^2);
    case 3,
      wt = 1 ./ y;
    else
      error('nlinregr: noe feil med wt');
  end

  set(gda(),'labels_font_size',3); // no default-font for old men...
  try
    yhat=curve(pEst,data);
  catch
    disp('Error executing: yhat=curve(pEst,data)');
    pause
  end
  
  // Solve regression problem.
  [phat,stat]=nlinlsq(list(curve),list(dcurve),data,y,wt,pEst,pLo,pUp,list(0,pNames));
  yhat=curve(phat,data);
endfunction

