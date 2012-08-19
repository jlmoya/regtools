mode(1)
exec(get_absolute_file_path('Thurber.dem.sce')+'Thurber.sce')
[phat,yhat,stat]=nlinregr(Data,Names,funDef,dfunDef,pDef,'y',1,bInit1)
printf('NIST reference solution: '); printf('%e ',b);
nlinregr(Data,Names,funDef,dfunDef,pDef,'y',1,bInit1)
