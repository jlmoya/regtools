// ====================================================================
// Created by toolbox_creator
// See SCI/contrib/toolbox_skeleton/demos/toolbox_skeleton.dem.gateway.sce
// for an example on how to define subdemolist manually.
// ====================================================================
demopath = get_absolute_file_path("regtools.dem.gateway.sce");

f=findfiles(demopath);
subdemolist=[];
for i=1:size(f,'*'),
  if f(i)<>'regtools.dem.gateway.sce' then
    if isdir(demopath+f(i)) then
      subdemolist=[subdemolist;f(i),f(i)+filesep()+f(i)+'.dem.gateway.sce'];      
    else
      subdemolist=[subdemolist;strsubst(f(i),'.dem.sce',''),f(i)];
    end
  end
end
subdemolist(:,2) = demopath + subdemolist(:,2);
// ====================================================================
