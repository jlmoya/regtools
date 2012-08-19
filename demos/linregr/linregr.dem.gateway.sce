
demopath = get_absolute_file_path("linregr.dem.gateway.sce");

subdemolist=[..
    "Longley","Longley.dem.sce" ; ..
    "NoInt1","NoInt1.dem.sce" ; ..
    "NoInt2","NoInt2.dem.sce" ; ..
    "Pontius","Pontius.dem.sce" ; ..
    "Wampler1","Wampler1.dem.sce" ; ..
    "Wampler2","Wampler2.dem.sce" ; ..
    "Wampler3","Wampler3.dem.sce" ; ..
]

subdemolist(:,2) = demopath + subdemolist(:,2);
