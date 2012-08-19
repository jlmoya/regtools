// =====================================================================
// Created by help_from_sci
// See SCI/contrib/toolbox_skeleton/demos/toolbox_skeleton.dem.gateway.sce
// for an example on how to define subdemolist manually.
// ====================================================================
demopath = get_absolute_file_path("qqplot.dem.gateway.sce");

dem_sce=findfiles(demopath,'*.dem.sce');
subdemolist=[strsubst(dem_sce,'.dem.sce',''),dem_sce];

subdemolist(:,2) = demopath + subdemolist(:,2);
// ====================================================================
