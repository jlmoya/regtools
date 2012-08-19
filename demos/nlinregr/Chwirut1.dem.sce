mode(1)
exec(get_absolute_file_path('Chwirut1.dem.sce')+'Chwirut1.sce')
[phat,yhat,stat]=nlinregr(Data,Names,funDef,dfunDef,pDef,'y',1,bInit1)
printf('NIST reference solution: '); printf('%e ',b);

nlinregr(Data,Names,funDef,dfunDef,pDef,'y',1,bInit1)
