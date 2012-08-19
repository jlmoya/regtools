mode(1)
exec(get_absolute_file_path('MGH09.dem.sce')+'MGH09.sce')
[phat,yhat,stat]=nlinregr(Data,Names,funDef,dfunDef,pDef,'y',1,bInit2)
printf('NIST reference solution: '); printf('%e ',b);
nlinregr(Data,Names,funDef,dfunDef,pDef,'y',1,bInit2)
