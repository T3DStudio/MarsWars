

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
carea:word;
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

   ex:=round(map_mw/pf_pathmap_w);
   for sx:=0 to pf_pathmap_c do
   for sy:=0 to pf_pathmap_c do
    if(sx>=ex)or(sy>=ex)then pf_pathgrid_areas[sx,sy]:=pf_solid;

   // areas
   carea:=0;
   for sx:=0 to pf_pathmap_c do
   for sy:=0 to pf_pathmap_c do
    if(pf_pathgrid_areas[sx,sy]=0)then
    begin
       carea+=1;
       pf_FillArea(sx,sy,carea);
       if(carea=65535)then break;
    end;
end;

function pf_CheckBorders(cx,cy:integer):boolean;
begin
   pf_CheckBorders:=(0<=cx)and(0<=cy)and(cx<=pf_pathmap_c)and(cy<=pf_pathmap_c);
end;

function pf_GetAreaZone(cx,cy:integer):word;
begin
   if(pf_CheckBorders(cx,cy)=false)
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

function pf_EqZones(z1,z2:word):boolean;
begin
   pf_EqZones:=(z1=z2)and(not pf_IfObstacleZone(z1));
end;

{
function pf_find(startx,starty,endx,endy:integer;nextx,nexty:pinteger):boolean;
var i,pfdist,pfvx,pfvy,

    pfNodes_p : integer;

function pfCellDistance(_sx,_sy,_ex,_ey:integer):integer;
begin
   pfCellDistance:=max2(abs(_sx-_ex),abs(_sy-_ey));
end;

{function pfAddNode(cx,cy,rx,ry:integer):boolean;
begin
   pfAddNode:=false;
   if(pfNodes_c>=pfMaxNodes)then exit;
   if(pf_check_borders (cx,cy)=false           )then exit;
   if(pf_pathgrid_areas[cx,cy]=pf_solid        )then exit;
   if(pf_pathgrid_tmpg [cx,cy]=pf_pathgrid_tmpb)then exit;

   pfNodes_c+=1;
   with pfNodes[pfNodes_c] do
   begin
      pos_x:=cx;
      pos_y:=cy;
      if(rx=-1)then rootx:=pos_x else rootx:=rx;
      if(ry=-1)then rooty:=pos_y else rooty:=ry;
   end;
   pf_pathgrid_tmpg[cx,cy]:=pf_pathgrid_tmpb;
   pfAddNode:=true;
end; }

procedure pfCalcVector(_sx,_sy,_ex,_ey:integer;_vx,_vy:pinteger);
//var dx,dy:integer;
begin
//   dx:=abs(_sx-_ex);
//   dy:=abs(_sy-_ey);

   {if(dx=0)
   begin

   end; }
   _vx^:=sign(_ex-_sx);
   _vy^:=sign(_ey-_sy);
end;

procedure pfAddNodes(_sx,_sy,_rx,_ry:integer);
begin
   pfCalcVector(_sx,_sy,endx,endy,@pfvx,@pfvy);
   if (not pfAddNode(_sx+pfvx            ,_sy+pfvy            ,_rx,_ry))then
   if (not pfAddNode(_sx+sign( pfvx+pfvy),_sy+sign( pfvy-pfvx),_rx,_ry))     //+45
   and(not pfAddNode(_sx+sign( pfvx-pfvy),_sy+sign( pfvy+pfvx),_rx,_ry))then //-45
   if (not pfAddNode(_sx+pfvy            ,_sy-pfvx            ,_rx,_ry))     //+90
   and(not pfAddNode(_sx-pfvy            ,_sy+pfvx            ,_rx,_ry))then //-90
   if (not pfAddNode(_sx+sign( pfvy-pfvx),_sy+sign(-pfvx-pfvy),_rx,_ry))     //+135
   and(not pfAddNode(_sx+sign(-pfvy-pfvx),_sy+sign( pfvx-pfvy),_rx,_ry))then //-135
           pfAddNode(_sx-pfvx            ,_sy-pfvy            ,_rx,_ry)      // 180
   {pfAddNode(_sx+pfvx            ,_sy+pfvy            ,_rx,_ry);
   pfAddNode(_sx+sign( pfvx+pfvy),_sy+sign( pfvy-pfvx),_rx,_ry);//+45
   pfAddNode(_sx+sign( pfvx-pfvy),_sy+sign( pfvy+pfvx),_rx,_ry);//-45
   pfAddNode(_sx+pfvy            ,_sy-pfvx            ,_rx,_ry);//+90
   pfAddNode(_sx-pfvy            ,_sy+pfvx            ,_rx,_ry);//-90
   pfAddNode(_sx+sign( pfvy-pfvx),_sy+sign(-pfvx-pfvy),_rx,_ry);//+135
   pfAddNode(_sx+sign(-pfvy-pfvx),_sy+sign( pfvx-pfvy),_rx,_ry);//-135
   pfAddNode(_sx-pfvx            ,_sy-pfvy            ,_rx,_ry);// 180}
   {if (not pfAddNode(_sx+pfvx            ,_sy+pfvy            ,_rx,_ry))
   and(not pfAddNode(_sx+sign( pfvx+pfvy),_sy+sign( pfvy-pfvx),_rx,_ry))     //+45
   and(not pfAddNode(_sx+sign( pfvx-pfvy),_sy+sign( pfvy+pfvx),_rx,_ry))     //-45
   and(not pfAddNode(_sx+pfvy            ,_sy-pfvx            ,_rx,_ry))     //+90
   and(not pfAddNode(_sx-pfvy            ,_sy+pfvx            ,_rx,_ry))then //-90
   if (not pfAddNode(_sx+sign( pfvy-pfvx),_sy+sign(-pfvx-pfvy),_rx,_ry))     //+135
   and(not pfAddNode(_sx+sign(-pfvy-pfvx),_sy+sign( pfvx-pfvy),_rx,_ry))then //-135
           pfAddNode(_sx-pfvx            ,_sy-pfvy            ,_rx,_ry)      // 180   }
end;

begin
   pf_find:=false;

   if(startx<0)
   or(starty<0)
   or(startx>pf_pathmap_c)
   or(starty>pf_pathmap_c)
   then exit;

   i:=pfCellDistance(startx,starty,endx,endy);
   if(i<=1)then exit;

   pf_pathgrid_tmpb+=1;

   pfNodes_c:=0;
   pfNodes_p:=0;
   pfdist:=32000;

   //initial nodes
   pfAddNodes(startx,starty,-1,-1);

   while(pfNodes_p<pfNodes_c)do
   begin

      pfNodes_p+=1;
      with pfNodes[pfNodes_p] do
      begin
         i:=pfCellDistance(pos_x,pos_y,endx,endy);
         if(i<pfdist)then
         begin
            pfdist:=i;
            nextx^:=rootx;
            nexty^:=rooty;
            if(pfdist<=1)then break;
         end;
         pfAddNodes(pos_x,pos_y,rootx,rooty);
      end;
   end;
   pf_find:=true;
end;



{procedure pf_unit(pu:PTUnit);
var _pos_cx,
    _pos_cy,
    _mv_cx,
    _mv_cy,
    _next_cx,
    _next_cy: integer;
    pfcall:boolean;
begin
   with pu^ do
   begin
      if(uf>uf_ground)or(speed<=0)then exit;

      pfcall:=false;

      if(pf_pos_x<>x)or(pf_pos_y<>y)then
      begin
         pf_pos_x:=x;
         pf_pos_y:=y;
         _pos_cx :=pf_pos_x div pf_pathmap_w;
         _pos_cy :=pf_pos_y div pf_pathmap_w;
         if(pf_pos_cx<>_pos_cx)
         or(pf_pos_cy<>_pos_cy)then
         begin
            pf_pos_cx:=_pos_cx;
            pf_pos_cy:=_pos_cy;
            pfcall:=true;
         end;
      end;

      if(pf_mv_x<>mv_x)or(pf_mv_y<>mv_y)then
      begin
         pf_mv_x:=mv_x;
         pf_mv_y:=mv_y;
         _mv_cx:=pf_mv_x div pf_pathmap_w;
         _mv_cy:=pf_mv_y div pf_pathmap_w;
         if(pf_mv_cx <>_mv_cx )
         or(pf_mv_cy <>_mv_cy )then
         begin
            pf_mv_cx :=_mv_cx;
            pf_mv_cy :=_mv_cy;
            pfcall:=true;
         end
         else
         begin
            pf_mv_nx:=mv_x;
            pf_mv_ny:=mv_y;
         end;
      end;

      if(pfcall)then
      begin
         if(pf_find(pf_pos_cx,pf_pos_cy,pf_mv_cx,pf_mv_cy,@_next_cx,@_next_cy))then
         begin
            pf_mv_nx:=_next_cx*pf_pathmap_w+pf_pathmap_hw;
            pf_mv_ny:=_next_cy*pf_pathmap_w+pf_pathmap_hw;
         end
         else
         begin
            pf_mv_nx:=mv_x;
            pf_mv_ny:=mv_y;
         end;
      end;

      mv_x:=pf_mv_nx;
      mv_y:=pf_mv_ny;
   end;
end;  }

   }


