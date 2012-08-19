function results_eval(Data,Names,funDef,pDef,bInit)
global Solved Failed
  try
   [phat,yhat,stat]=nlinregr(Data,Names,funDef,pDef,'y',1,bInit);
    abs_err=abs((phat-b)./b);
    if max(abs_err)<1e-4 then
      printf('Solved\t'); Solved=Solved+1;
    else
      printf('%.5g%%\t',max(abs_err)*100);
      printf('b:'); printf('%.5g ',b); Failed=Failed+1;
      printf('yhat=%s',funDef);
    end    
  catch
    [msg,no]=lasterror(%t);
    printf('FAILED: %s',msg); 
    printf('yhat=%s',funDef);
    Failed=Failed+1;
  end  
  printf('\n');
endfunction

warning('off')
tests=['BoxBOD','Chwirut1','Chwirut2','DanWood','Eckerle4','Gauss1','Gauss2',..
       'Hahn1','Kirby2','Lanczos3','MGH09','MGH10','MGH17','Misra1a','Misra1b',..
       'Nelson','Rat42','Thurber',];
global Solved Failed
Solved=0; Failed=0; Total=0;
printf('Problem\tEst.\tmax(rel.err.)\n');
for i=1:size(tests,'*'),
  exec(tests(i)+'.sce'); Total=Total+1;

  printf('%s\t',tests(i));
  printf('bInit1\t');
  results_eval(Data,Names,funDef,pDef,bInit1)
  
  printf('%s\t',' ');
  printf('bInit2\t');
  results_eval(Data,Names,funDef,pDef,bInit2)
  
  printf('%s\t',' ');
  printf('b   \t');
  results_eval(Data,Names,funDef,pDef,b)
end
printf('Solved=%i, Failed=%i, Total=%i\n',Solved,Failed,Total);
warning('on');

