

procedure pf_FillArea(px,py:integer;arean:word);
var d:byte;
begin
   if(px<0)or(py<0)or(px>pf_pathmap_c)or(py>pf_pathmap_c)then exit;
   if(pf_pathgrid_areas[px,py]>0)then exit;

   pf_pathgrid_areas[px,py]:=arean;

   for d:=0 to 7 do pf_FillArea(px+dir_stepX[d],py+dir_stepY[d],arean);
end;

procedure pf_MakeZoneGrid;
var d,sx,sy,ix,iy,ex,ey: integer;
begin
   FillChar(pf_pathgrid_areas,SizeOf(pf_pathgrid_areas),0);

   // solid cells
   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t>0)and(r>=pf_pathmap_w)then
     begin
        sx:=mm3i(0,(x-r) div pf_pathmap_w,pf_pathmap_c);
        sy:=mm3i(0,(y-r) div pf_pathmap_w,pf_pathmap_c);
        ex:=mm3i(0,(x+r) div pf_pathmap_w,pf_pathmap_c);
        ey:=mm3i(0,(y+r) div pf_pathmap_w,pf_pathmap_c);

        for ix:=sx to ex do
         for iy:=sy to ey do
          if(point_dist_int(ix*pf_pathmap_w+pf_pathmap_hw,iy*pf_pathmap_w+pf_pathmap_hw,x,y)<=r)then //-bld_dec_mr
           pf_pathgrid_areas[ix,iy]:=pf_solid;
     end;

   ex:=round(map_Size/pf_pathmap_w);
   for sx:=0 to pf_pathmap_c do
   for sy:=0 to pf_pathmap_c do
    if(sx>=ex)or(sy>=ex)then pf_pathgrid_areas[sx,sy]:=pf_solid;

   // areas
   map_pf_lastZone:=0;
   for sx:=0 to pf_pathmap_c do
   for sy:=0 to pf_pathmap_c do
    if(pf_pathgrid_areas[sx,sy]=0)then
    begin
       map_pf_lastZone+=1;
       pf_FillArea(sx,sy,map_pf_lastZone);
       if(map_pf_lastZone=65535)then break;
    end;
end;

function pf_CheckBorders(cx,cy:integer):boolean;
begin
   pf_CheckBorders:=(0<=cx)and(0<=cy)and(cx<=pf_pathmap_c)and(cy<=pf_pathmap_c);
end;

function pf_GetAreaZone(cx,cy:integer):word;
begin
   if(not pf_CheckBorders(cx,cy))
   then pf_GetAreaZone:=pf_solid
   else pf_GetAreaZone:=pf_pathgrid_areas[cx,cy];
end;

function pf_get_area(x,y:integer):word;
begin
    pf_get_area:=pf_GetAreaZone(x div pf_pathmap_w,y div pf_pathmap_w);
end;

function pf_IfObstacleZone(zone:word):boolean;
begin
   pf_IfObstacleZone:=(zone=pf_solid);
end;



