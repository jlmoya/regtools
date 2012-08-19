mode(1)
exec(get_absolute_file_path('Misra1b.dem.sce')+'Misra1b.sce')
[phat,yhat,stat]=nlinregr(Data,Names,funDef,dfunDef,pDef,'y',1,bInit1)
printf('NIST reference solution: '); printf('%e ',b);
nlinregr(Data,Names,funDef,dfunDef,pDef,'y',1,bInit1)
