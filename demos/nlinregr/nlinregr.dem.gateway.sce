
demopath = get_absolute_file_path("nlinregr.dem.gateway.sce");

subdemolist=[..
    "BoxBOD","BoxBOD.dem.sce" ; ..
    "Chwirut1","Chwirut1.dem.sce" ; ..
    "Chwirut2","Chwirut2.dem.sce" ; ..
    "DanWood","DanWood.dem.sce" ; ..
    "Eckerle4","Eckerle4.dem.sce" ; ..
    "Gauss1","Gauss1.dem.sce" ; ..
    "Gauss2","Gauss2.dem.sce" ; ..
    "Hahn1","Hahn1.dem.sce" ; ..
    "Kirby2","Kirby2.dem.sce" ; ..
    "Lanczos3","Lanczos3.dem.sce" ; ..
    "MGH09","MGH09.dem.sce" ; ..
    "MGH10","MGH10.dem.sce" ; ..
    "MGH17","MGH17.dem.sce" ; ..
    "Misra1a","Misra1a.dem.sce" ; ..
    "Misra1b","Misra1b.dem.sce" ; ..
    "Nelson","Nelson.dem.sce" ; ..
    "Rat42","Rat42.dem.sce" ; ..
    "Thurber","Thurber.dem.sce" ; ..
]

subdemolist(:,2) = demopath + subdemolist(:,2);
