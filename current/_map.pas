{$IFDEF _FULLGAME}

procedure map_seed2theme;
var
theme,
terrain,
crater,
liquid,
teleport:integer;
mseed   :cardinal;
function Pick(n:integer):integer;
var c:cardinal;
begin
   c:=cardinal(n);
   if(c=0)
   then Pick:=-1
   else
   begin
      if(mseed=0)then mseed:=cardinal.MaxValue-mseed;
      Pick :=mseed mod c;
      mseed:=mseed div c;
   end;
end;
begin
   mseed  :=map_seed;
   theme  :=Pick(theme_n);
   SetTheme(theme);

   terrain :=Pick(theme_cur_terrain_n );
   crater  :=Pick(theme_cur_crater_n  );
   liquid  :=Pick(theme_cur_liquid_n  );
   teleport:=Pick(theme_cur_teleport_n);
   SetTerrainIDs(-terrain,-crater,-liquid,-teleport);
end;

procedure map_MakeVisGrid;
var
 x, y,
mx,my,
 i   :integer;
ddir :single;
function GetTile(cx,cy:integer;val:byte;crater:boolean):boolean;
begin
   GetTile:=false;
   if (0<=cx)and(cx<MaxMapSizeCelln)
   and(0<=cy)and(cy<MaxMapSizeCelln)then
     with map_grid_graph[cx,cy] do
       if(crater)
       then GetTile:=tgca_tile_crater=val
       else GetTile:=tgca_tile_liquid=val;
end;
procedure AddDecor(N,depth,mx,my:integer);
begin
   with map_grid_graph[x,y] do
   if(tgca_decor_n>=0)then
   begin
      tgca_decor_n+=1;
      setlength(tgca_decor_l,tgca_decor_n);
      with tgca_decor_l[tgca_decor_n-1] do
      begin
         tgca_decorN    :=N;
         tgca_decorS    :=@theme_all_decor_l[tgca_decorN];
         tgca_decorA    :=@theme_anm_decors [tgca_decorN];
         tgca_decorDepth:=depth+my;
         tgca_decorTime :=DoodadAnimationTime(tgca_decorA^.tda_atime);
         tgca_decorX    :=mx;
         tgca_decorY    :=my;
      end;
   end;
end;
procedure SetDecal(N:integer);
begin
   with map_grid_graph[x,y] do
   begin
      tgca_decal_n+=1;
      setlength(tgca_decal_l,tgca_decal_n);
      with tgca_decal_l[tgca_decal_n-1] do
      begin
         tgca_decalS:=@theme_all_decal_l[N];
         tgca_decalX:=max2i(0,random(MapCellW-tgca_decalS^.w));
         tgca_decalY:=max2i(0,random(MapCellW-tgca_decalS^.h));
      end;
   end;
end;
procedure AddDecals;
begin
   with map_grid_graph[x,y] do
   if(tgca_decor_n>=0)and(theme_cur_decal_n>0)then
   begin
      i:=abs((x+1)*(y+1)) mod 12;
      if(i<=3)then
        while(i>0)do
        begin
           SetDecal(theme_cur_decal_l[abs((x+1)*(y+1)+i) mod theme_cur_decal_n]);
           i-=1;
        end;
   end;
end;
begin
   for x:=0 to MaxMapSizeCelln-1 do
   for y:=0 to MaxMapSizeCelln-1 do
   with map_grid      [x,y] do
   with map_grid_graph[x,y] do
   begin
      tgca_decor_n:=0;
      setlength(tgca_decor_l,tgca_decor_n);
      tgca_decal_n:=0;
      setlength(tgca_decal_l,tgca_decal_n);
   end;
   FillChar(map_grid_graph,SizeOf(map_grid_graph),0);

   for x:=0 to MaxMapSizeCelln-1 do
   for y:=0 to MaxMapSizeCelln-1 do
   with map_grid      [x,y] do
   with map_grid_graph[x,y] do
   begin
      mx:=x*MapCellW+MapCellHW;
      my:=y*MapCellW+MapCellHW;
      tgca_tile_liquid:=-1;
      tgca_tile_crater:=-1;
      case tgc_solidlevel of
mgsl_free   : begin
                 AddDecals;
              end;
mgsl_nobuild: begin
                 tgca_tile_crater:=0;
                 if(theme_cur_decor_n>0)then
                   for i:=1 to tGridDecorsMax do
                   begin
                      ddir:=((i*tGridDecorD)+(x*135)+(y*69))*degtorad;
                      AddDecor(theme_cur_decor_l[abs((x+1)*(y+1)+i) mod theme_cur_decor_n],
                               sd_ground,
                               mx+round(tGridDecorR*cos(ddir)),
                               my+round(tGridDecorR*sin(ddir)));
                   end;
                 AddDecals;
              end;
mgsl_liquid : begin
                 tgca_tile_liquid:=0;
                 tgca_tile_crater:=0;
              end;
mgsl_rocks  : begin
                 tgca_tile_crater:=0;

                 if(theme_cur_2rock_n>0)then
                   if ((x+1)<MaxMapSizeCelln)
                   and((y+1)<MaxMapSizeCelln)then
                     if (map_grid[x+1,y  ].tgc_solidlevel=mgsl_rocks)
                     and(map_grid[x+1,y+1].tgc_solidlevel=mgsl_rocks)
                     and(map_grid[x  ,y+1].tgc_solidlevel=mgsl_rocks)
                     then
                     begin
                        mx+=MapCellHW;
                        my+=MapCellHW;
                        i:=theme_cur_2rock_l[abs((x+1)*(y+1)) mod theme_cur_2rock_n];
                        AddDecor(i,sd_rocks,mx,my);
                        map_grid_graph[x+1,y  ].tgca_decor_n:=-1;
                        map_grid_graph[x+1,y+1].tgca_decor_n:=-1;
                        map_grid_graph[x  ,y+1].tgca_decor_n:=-1;
                        continue;
                     end;

                 if(theme_cur_1rock_n>0)then
                   AddDecor(theme_cur_1rock_l[abs((x+1)*(y+1)) mod theme_cur_1rock_n],
                            sd_rocks,
                            mx,my);
              end;
      end;
   end;

   for x:=0 to MaxMapSizeCelln-1 do
   for y:=0 to MaxMapSizeCelln-1 do
   with map_grid_graph[x,y] do
   begin
      tgca_tile_crater:=TileSetGetN(GetTile(x-1,y-1,0,true ),
                                    GetTile(x  ,y-1,0,true ),
                                    GetTile(x+1,y-1,0,true ),
                                    GetTile(x-1,y  ,0,true ),
                                    GetTile(x  ,y  ,0,true ),
                                    GetTile(x+1,y  ,0,true ),
                                    GetTile(x-1,y+1,0,true ),
                                    GetTile(x  ,y+1,0,true ),
                                    GetTile(x+1,y+1,0,true ));

      if(theme_cur_liquid_tes=tes_nature)then
      tgca_tile_liquid:=TileSetGetN(GetTile(x-1,y-1,0,false),
                                    GetTile(x  ,y-1,0,false),
                                    GetTile(x+1,y-1,0,false),
                                    GetTile(x-1,y  ,0,false),
                                    GetTile(x  ,y  ,0,false),
                                    GetTile(x+1,y  ,0,false),
                                    GetTile(x-1,y+1,0,false),
                                    GetTile(x  ,y+1,0,false),
                                    GetTile(x+1,y+1,0,false));
   end;
end;

{$ENDIF}

procedure map_RandomBaseVars;
begin
   g_random_i:= word(map_seed);
   g_random_p:= byte(map_seed);
end;

function map_GetSymmetryDir:integer;
begin
   case map_symmetry of
maps_lineV,
maps_lineH,
maps_lineL,
maps_lineR: begin
               case map_symmetry of
               maps_lineV: map_GetSymmetryDir:=90;
               maps_lineH: map_GetSymmetryDir:=180;
               maps_lineL: map_GetSymmetryDir:=225;
               maps_lineR: map_GetSymmetryDir:=135;
               end;
               if((map_seed mod 2)=0)
               then map_GetSymmetryDir:=DIR360(map_GetSymmetryDir+180);
            end;
   else
            map_GetSymmetryDir:=180;
   end;
end;

procedure map_Vars;
begin
   map_size        := mm3i(MinMapSize,map_size,MaxMapSize);
   map_RandomBaseVars;
   map_BuildBorder1:= map_size-map_BuildBorder0;
   map_hsize       := map_size div 2;
   map_symmetryDir := map_GetSymmetryDir;
   map_LastCell    := map_size div MapCellW;
   map_CenterCell  := map_hsize div MapCellW;

   {$IFDEF _FULLGAME}
   map_mm_cx   := (vid_panelw-2)/map_size;
   map_mm_CamW := trunc(vid_cam_w*map_mm_cx)+1;
   map_mm_CamH := trunc(vid_cam_h*map_mm_cx)+1;
   map_mm_gridW:= MapCellW*map_mm_cx;
   {$ENDIF}
end;

procedure SymmetryXY(basex,basey,msize:integer;resultx,resulty:pinteger;SymmetryType:byte);
begin
   case symmetryType of
maps_point: begin
            resultx^:=msize-basex;
            resulty^:=msize-basey;
            end;
maps_lineV: begin
            resultx^:=msize-basex;
            resulty^:=basey;
            end;
maps_lineH: begin
            resultx^:=basex;
            resulty^:=msize-basey;
            end;
maps_lineL: begin
            resultx^:=basey;
            resulty^:=basex;
            end;
maps_lineR: begin
            resultx^:=msize-basey;
            resulty^:=msize-basex;
            end;
   else
            resultx^:=NOTSET;
            resulty^:=NOTSET;
   end;
end;

procedure map_RemoveTeleports;
var x,y:byte;
begin
   for x:=0 to MaxMapSizeCelln-1 do
   for y:=0 to MaxMapSizeCelln-1 do
   with map_grid[x,y] do
   begin
      tgc_teleportx:=255;
      tgc_teleportx:=255;
   end;
end;

procedure map_ZonesClear;
var x,y:byte;
begin
   map_gridLastpZone:=0;
   map_gridLastsZone:=0;
   for x:=0 to MaxMapSizeCelln-1 do
   for y:=0 to MaxMapSizeCelln-1 do
   with map_grid[x,y] do
   begin
      tgc_parea:=0;
      tgc_sarea:=0;
   end;
end;

procedure map_ZoneFillPart(x,y:integer;zone:word;pzone:boolean);
begin
   if(x<0)
   or(y<0)
   or(x>=MaxMapSizeCelln)
   or(y>=MaxMapSizeCelln)then exit;

   with map_grid[x,y] do
   begin
      if(tgc_solidlevel>=mgsl_liquid)then exit;

      if(pzone)then
      begin
         if(tgc_parea>0)then exit;
         tgc_parea:=zone
      end
      else
      begin
         if(tgc_sarea>0)then exit;
         tgc_sarea:=zone;
      end;

      if(pzone)then
        if (tgc_teleportx<MaxMapSizeCelln)
        and(tgc_teleporty<MaxMapSizeCelln)then map_ZoneFillPart(tgc_teleportx,tgc_teleporty,zone,pzone);
   end;

   map_ZoneFillPart(x-1,y  ,zone,pzone);
   map_ZoneFillPart(x+1,y  ,zone,pzone);
   map_ZoneFillPart(x  ,y-1,zone,pzone);
   map_ZoneFillPart(x  ,y+1,zone,pzone);
end;

procedure map_ZonesFill;
var x,y:byte;
begin
   map_ZonesClear;
   for x:=0 to MaxMapSizeCelln-1 do
   for y:=0 to MaxMapSizeCelln-1 do
   with map_grid[x,y] do
   if(tgc_solidlevel<mgsl_liquid)then
   begin
      if(tgc_parea=0)then
      begin
         map_gridLastpZone+=1;
         map_ZoneFillPart(x,y,map_gridLastpZone,true );
      end;
      if(tgc_sarea=0)then
      begin
         map_gridLastsZone+=1;
         map_ZoneFillPart(x,y,map_gridLastsZone,false);
      end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  CHECKS

function CheckMapBorders(x,y,aborder:integer):boolean;
begin
   if(x=NOTSET)or(y=NOTSET)
   then CheckMapBorders:=true
   else CheckMapBorders:=(-aborder<=x)and(x<=(map_size+aborder))
                      and(-aborder<=y)and(y<=(map_size+aborder));
end;

function map_IfHereObjectCell(cx,cy:byte;baser:integer;players:boolean):byte;
var p:byte;
x0,y0,tr,
mx,my:integer;
begin
   map_IfHereObjectCell:=0;
   if(cx<=map_LastCell)and(cy<=map_LastCell)then
   begin
      x0:=cx*MapCellW;
      y0:=cy*MapCellW;
case players of
true : for p:=0 to MaxPlayers do
       begin
          mgcell2NearestXY(map_PlayerStartX[p],map_PlayerStartY[p],x0,y0,x0+MapCellW,y0+MapCellW,@mx,@my,0);
          if(point_dist_int(mx,my,map_PlayerStartX[p],map_PlayerStartY[p])<=baser)
          then map_IfHereObjectCell+=1;
       end;
false: for p:=1 to MaxCpoints do
        with g_cpoints[p] do
         if(cpCaptureR>0)then
         begin
            if(baser<0)
            then tr:=cpCaptureR//+MapCellhW
            else tr:=baser;
            mgcell2NearestXY(cpx,cpy,x0,y0,x0+MapCellW,y0+MapCellW,@mx,@my,0);
            if(point_dist_int(mx,my,cpx,cpy)<=tr)
            then map_IfHereObjectCell+=1;
         end;
end;
   end;
end;

function map_IfPlayerStartHere(basex,basey,symx,symy,r:integer):boolean;
var p:byte;
begin
   map_IfPlayerStartHere:=false;
   if(r<=0)then
   begin
      map_IfPlayerStartHere:=true;
      exit;
   end;

   if(point_dist_int(basex,basey,symx,symy)<(r+r))then
   begin
      map_IfPlayerStartHere:=true;
      exit;
   end;

   for p:=0 to MaxPlayers do
    if(point_dist_int(basex,basey,map_PlayerStartX[p],map_PlayerStartY[p])<r)
    or(point_dist_int(symx ,symy ,map_PlayerStartX[p],map_PlayerStartY[p])<r)then
    begin
       map_IfPlayerStartHere:=true;
       break;
    end;
end;

function map_IfCPointHere(basex,basey,symx,symy,r:integer):boolean;
var p:byte;
    t:integer;
begin
   if(r<=0)then
   begin
      map_IfCPointHere:=true;
      exit;
   end;
   map_IfCPointHere:=false;

   if(point_dist_int(basex,basey,symx,symy)<(r*2))then
   begin
      map_IfCPointHere:=true;
      exit;
   end;

   for p:=1 to MaxCpoints do
    with g_cpoints[p] do
     if(cpCaptureR>0)then
     begin
        t:=r+max2i(cpsolidr,cpCaptureR);
        if(point_dist_int(basex,basey,cpx,cpy)<t)
        or(point_dist_int(symx ,symy ,cpx,cpy)<t)then
        begin
           map_IfCPointHere:=true;
           break;
        end;
     end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//  CPOINTS

procedure map_CPoints_UpdatePFZone;
var pn:integer;
begin
   for pn:=1 to MaxCPoints do
    with g_cpoints[pn] do
     if(cpCaptureR>0)then cpzone:=pf_get_area(cpx,cpy);
end;

procedure map_CPoints_Default(num:byte;sr,cr,nr,energy,time:integer;lifetime:cardinal;newpoints:boolean);
var
basex,basey,
symx,symy,
i,u,b,c,
dst        :integer;
function setcpoint(px,py:integer):boolean;
var pn:byte;
begin
   for pn:=1 to MaxCPoints do
     if(g_cpoints[pn].cpCaptureR<=0)then break;

   if(pn>MaxCPoints)then
   begin
      setcpoint:=true;
      exit;
   end
   else setcpoint:=false;

   with g_cpoints[pn] do
   begin
      cpx          :=px;
      cpy          :=py;
      cp_ToCenterD :=point_dist_int(cpx,cpy,map_hsize,map_hsize);
      cpsolidr     :=sr;
      cpNoBuildR   :=nr;
      cpenergy     :=energy;
      cpCaptureR   :=cr;
      cpCaptureTime:=time;
      cplifetime   :=lifetime;
      {$IFDEF _FULLGAME}
      cpmx:=round(map_mm_cx*cpx);
      cpmy:=round(map_mm_cx*cpy);
      cpmr:=round(map_mm_cx*cpCaptureR);
      {$ENDIF}
   end;
end;
begin
   if(newpoints)then FillChar(g_cpoints,SizeOf(g_cpoints),0);
   u:=map_size div 50;
   b:=map_size-(u*2);

   i:=0;
   while(i<num)do
   begin
      i+=1+byte(map_symmetry);
      c:=0;
      dst:=max2i(base_1rh,map_size div 8);
      while(c<1000)do
      begin
         basex:=u+g_random(b);
         basey:=u+g_random(b);
         SymmetryXY(basex,basey,map_size,@symx,@symy,map_symmetry);

         c+=1;
         if(c>500)then dst-=1;

         if CheckMapBorders(symx,symy,0)then
           if (not map_IfPlayerStartHere(basex,basey,symx,symy,dst))
           and(not map_IfCPointHere     (basex,basey,symx,symy,dst))then
           begin
              if(setcpoint(basex,basey))then exit;
              if(symx<>NOTSET)then
                if(setcpoint(symx,symy))then exit;
              break;
           end;
      end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  PLAYER STARTS

procedure map_PlayerStartsCircle(r,sdir:integer);
const dstep = 360 div MaxPlayers;
var i:byte;
begin
   sdir:=abs(sdir mod 360)+(dstep div 2);
   for i:=1 to 3 do
   begin
      sdir+=dstep;
      map_PlayerStartX[i  ]:=map_hsize+round(r*cos(sdir*degtorad));
      map_PlayerStartY[i  ]:=map_hsize+round(r*sin(sdir*degtorad));
      map_PlayerStartX[i+3]:=map_size-map_PlayerStartX[i];
      map_PlayerStartY[i+3]:=map_size-map_PlayerStartY[i];
   end;
end;

procedure map_ShufflePlayerStarts;
var
x,y:byte;
i  :integer;
begin
   for x:=1 to MaxPlayers do
    for y:=1 to MaxPlayers do
     if(random(2)=0)and(x<>y)then
     begin
        i:=map_PlayerStartX[x];map_PlayerStartX[x]:=map_PlayerStartX[y];map_PlayerStartX[y]:=i;
        i:=map_PlayerStartY[x];map_PlayerStartY[x]:=map_PlayerStartY[y];map_PlayerStartY[y]:=i;
     end;
end;

procedure map_PlayerStartsDefault(FreeCenterR:integer);
var
basex,basey,
symx ,symy ,
i,r,c,
bb0,bb1,
dst    :integer;
begin
   bb0:=base_1r+(map_size-MinMapSize) div 9;
   bb1:=map_size-(bb0*2);
   dst:=base_1r+(map_size div 5);

   for i:=1 to MaxPlayers do
   begin
      if(map_symmetry>0)and(i>3)then break;
      c:=0;
      r:=dst;
      while true do
      begin
         basex:=bb0+g_random(bb1);
         basey:=bb0+g_random(bb1);
         SymmetryXY(basex,basey,map_size,@symx,@symy,map_symmetry);

         c+=1;
         if(c>500)then r-=1;

         if(CheckMapBorders(symx,symy,-bb0))then
           if(c>1000)
           or (not map_IfPlayerStartHere(basex,basey,symx,symy,r)
           and(point_dist_int(basex,basey,map_hsize,map_hsize)>FreeCenterR)
           and(point_dist_int(symx ,symy ,map_hsize,map_hsize)>FreeCenterR))then break;
      end;

      map_PlayerStartX[i]:=basex;
      map_PlayerStartY[i]:=basey;
      if(map_symmetry>0)then
      begin
         map_PlayerStartX[i+3]:=symx;
         map_PlayerStartY[i+3]:=symy;
      end;
   end;

   dst-=dst div 5;
   c:=0;
   for i:=1 to MaxPlayers do
   for r:=1 to MaxPlayers do
    if(i<>r)then
      if(point_dist_int(map_PlayerStartX[i],map_PlayerStartY[i],map_PlayerStartX[r],map_PlayerStartY[r])<dst)then c+=1;
   if(c>0)then map_PlayerStartsCircle(map_hsize-(map_size div 8),map_symmetryDir);
end;

procedure map_PlayerStarts;
var ix,iy,i,u,c:integer;
begin
   for i:=0 to MaxPlayers do
   begin
      map_PlayerStartX[i]:=-5000;
      map_PlayerStartY[i]:=-5000;
   end;

   case g_mode of
gm_3x3     :begin
               u :=map_hsize-(map_size div 7);
               c :=u+base_hr;
               i :=map_symmetryDir+90;

               case map_type of
               mapt_clake  : ix:=round(60*(MinMapSize/map_size))+round(3*(map_size/MinMapSize));
               mapt_shore : ix:=round(60*(MinMapSize/map_size))+round(5*(map_size/MinMapSize));
               else         ix:=round(65*(MinMapSize/map_size));
               end;

               map_PlayerStartX[1]:=round(map_hsize+cos( i    *degtorad)*u);
               map_PlayerStartY[1]:=round(map_hsize+sin( i    *degtorad)*u);
               map_PlayerStartX[2]:=round(map_hsize+cos((i-ix)*degtorad)*c);
               map_PlayerStartY[2]:=round(map_hsize+sin((i-ix)*degtorad)*c);
               map_PlayerStartX[3]:=round(map_hsize+cos((i+ix)*degtorad)*c);
               map_PlayerStartY[3]:=round(map_hsize+sin((i+ix)*degtorad)*c);

               map_PlayerStartX[4]:=map_size-map_PlayerStartX[1];
               map_PlayerStartY[4]:=map_size-map_PlayerStartY[1];
               map_PlayerStartX[5]:=map_size-map_PlayerStartX[2];
               map_PlayerStartY[5]:=map_size-map_PlayerStartY[2];
               map_PlayerStartX[6]:=map_size-map_PlayerStartX[3];
               map_PlayerStartY[6]:=map_size-map_PlayerStartY[3];
            end;
gm_2x2x2   :begin
               iy:=base_2r+(map_size div 30);
               u :=map_hsize-(map_hsize div 3);
               c :=map_symmetryDir;

               ix:=round(60*(MinMapSize/map_size));
               iy:=ix div 2;
               i:=1;
               while(i<MaxPlayers)do
               begin
               map_PlayerStartX[i  ]:=round(map_hsize+cos((c-iy)*degtorad)*u);
               map_PlayerStartY[i  ]:=round(map_hsize+sin((c-iy)*degtorad)*u);
               map_PlayerStartX[i+1]:=round(map_hsize+cos((c+iy)*degtorad)*u);
               map_PlayerStartY[i+1]:=round(map_hsize+sin((c+iy)*degtorad)*u);
               c+=120;
               i+=2;
               end;
            end;
gm_invasion:begin
               map_PlayerStartX[0]:=map_hsize;
               map_PlayerStartY[0]:=map_hsize;
               map_PlayerStartsCircle(base_2r,map_symmetryDir);
            end;
gm_KotH    :begin
               map_PlayerStartX[0]:=map_hsize;
               map_PlayerStartY[0]:=map_hsize;
               map_PlayerStartsCircle(map_hsize-(map_size div 8),map_symmetryDir);
            end;
gm_royale  :begin
               map_PlayerStartsCircle(map_hsize-(map_size div 5),map_symmetryDir);
            end;
gm_capture :begin
               map_PlayerStartsDefault(byte(map_type=mapt_clake)*(map_size div 3));
            end;
   else
               map_PlayerStartsDefault(byte(map_type=mapt_clake)*(map_size div 3));
   end;
end;

procedure map_CPoints;
begin
   FillChar(g_cpoints,SizeOf(g_cpoints),0);

   case g_mode of
gm_KotH   : with g_cpoints[1] do
            begin
               cpx:=map_hsize;
               cpy:=map_hsize;
               cpCaptureR   :=base_1r;
               cpCaptureTime:=fr_fps1*60;

               {$IFDEF _FULLGAME}
               cpmx:=round(cpx*map_mm_cx);
               cpmy:=round(cpy*map_mm_cx);
               cpmr:=round(cpCaptureR*map_mm_cx)+1;
               {$ENDIF}
            end;
gm_capture: map_CPoints_Default(4,0,gm_cptp_r,base_1r,0,gm_cptp_time,0,true);
   end;

   if(g_generators>1)then
     map_CPoints_Default(MaxCPoints,50,gm_cptp_r,gm_cptp_r div 2,g_cgenerators_energy,gm_cptp_gtime,g_cgenerators_ltime[g_generators],false);
end;

procedure map_GridCycleInit;
begin
   map_gcx:=0;
   map_gcy:=0;
   SymmetryXY(map_gcx,map_gcy,map_LastCell,@map_gcsx,@map_gcsy,map_symmetry);
end;

function map_GridCycleNext:boolean;
function Step(varx,vary,varsx,varsy:pinteger;lastx,lasty:integer):boolean;
begin
   Step:=false;
   varsx^:=NOTSET;
   varsy^:=NOTSET;
   if(vary^<=lasty)then
   begin
       varx^+=1;
       Step:=true;
       if(varx^>lastx)then
       begin
          varx^:=0;
          vary^+=1;
          if(vary^>lasty)then
          begin
             Step:=false;
             exit;
          end;
       end;
       SymmetryXY(varx^,vary^,map_LastCell,varsx,varsy,map_symmetry);
    end;
end;
begin
   map_GridCycleNext:=false;
   case map_symmetry of
maps_point,
maps_none : map_GridCycleNext:=Step(@map_gcx,@map_gcy,@map_gcsx,@map_gcsy,map_LastCell        ,map_LastCell  );
maps_lineV: map_GridCycleNext:=Step(@map_gcx,@map_gcy,@map_gcsx,@map_gcsy,map_CenterCell      ,map_LastCell  );
maps_lineH: map_GridCycleNext:=Step(@map_gcx,@map_gcy,@map_gcsx,@map_gcsy,map_LastCell        ,map_CenterCell);
maps_lineL: map_GridCycleNext:=Step(@map_gcx,@map_gcy,@map_gcsx,@map_gcsy,map_gcy             ,map_LastCell  );
maps_lineR: map_GridCycleNext:=Step(@map_gcx,@map_gcy,@map_gcsx,@map_gcsy,map_LastCell-map_gcy,map_LastCell  );
   end;
end;

procedure map_Fill(tx,ty,tr:integer;value,skipFactor:byte;startsR:integer;replace:boolean);
begin
   map_GridCycleInit;

   repeat
     if(map_grid[map_gcx,map_gcy].tgc_solidlevel=mgsl_free)or(replace)then
     begin
        if(skipFactor>0)then
          if(random_table[byte(byte(map_gcx+1)*byte(map_gcy+map_gcx+1)+byte(tx+ty+tr))] mod skipFactor)>0 then continue;

        if(tr>0)then
          if(point_dist_int(tx,ty,map_gcx,map_gcy)> tr)then continue;

        if(tr<0)then
          if(point_dist_int(tx,ty,map_gcx,map_gcy)<-tr)then continue;

        if (map_IfHereObjectCell(map_gcx,map_gcy,startsR,true )<>1)
        and(map_IfHereObjectCell(map_gcx,map_gcy,-1     ,false) =0)then
        begin
           map_grid[ map_gcx, map_gcy].tgc_solidlevel:=value;
           if(map_gcsx<>NOTSET)then
           map_grid[map_gcsx,map_gcsy].tgc_solidlevel:=value;
        end;
     end;
   until(not map_GridCycleNext)
end;

procedure map_ReMake;
var msrx,px,py:integer;
begin
   map_RandomBaseVars;
   map_CPoints;

   FillChar(map_grid,SizeOf(map_grid),0);
   map_RemoveTeleports;
   map_ZonesClear;

   msrx:=integer(map_seed);

   case map_type of
mapt_steppe : map_Fill(msrx,0,-1,mgsl_nobuild,7,base_1r,false);
mapt_canyon : begin
              map_Fill(msrx,1,-1,mgsl_rocks  , 7,base_1r,false);
              map_Fill(msrx,2,-1,mgsl_nobuild,25,base_1r,false);
              end;
mapt_clake,
mapt_ilake  : begin
              map_Fill(map_CenterCell,map_CenterCell,(map_LastCell div 3),mgsl_liquid ,0,base_1r,false);
              map_Fill(msrx,3,-1,mgsl_nobuild,18,base_1r,false);
              map_Fill(msrx,4,-1,mgsl_rocks  ,18,base_1r,false);
              end;
mapt_island : begin
              px:=map_CenterCell div 4;
              py:=map_LastCell div 4;
              map_Fill(map_CenterCell-px+integer(map_seed mod byte(py)),
                       map_CenterCell-px+integer(g_random_i mod py),
                       -round(map_LastCell/abs(2.5+(g_random_i mod 2))),mgsl_liquid ,0,base_1r,false);
              map_Fill(msrx,5,-1,mgsl_nobuild,18,base_1r,false);
              map_Fill(msrx,6,-1,mgsl_rocks  ,18,base_1r,false);
              end;
mapt_shore  : begin
              if(map_symmetry=maps_point)
              then map_Fill(map_CenterCell+round(map_LastCell*10.3*cos((map_seed mod 360)*degtorad)),
                            map_CenterCell+round(map_LastCell*10.3*sin((map_seed mod 360)*degtorad)),map_LastCell*10,mgsl_liquid ,0,base_1r,false)
              else map_Fill(map_CenterCell+round(map_LastCell*10  *cos(map_symmetryDir*degtorad)),
                            map_CenterCell+round(map_LastCell*10  *sin(map_symmetryDir*degtorad)),map_LastCell*10,mgsl_liquid ,0,base_1r,false);
              map_Fill(msrx,7,-1,mgsl_nobuild,16,base_1r,false);
              map_Fill(msrx,8,-1,mgsl_rocks  ,16,base_1r,false);
              map_Fill(msrx,1,-1,mgsl_rocks  ,64,base_1r,true );
              end;
mapt_sea    : begin
              map_Fill(msrx,9,-1,mgsl_liquid ,0,base_1r,false);
              map_Fill(msrx,0,-1,mgsl_nobuild,7,base_1r,false);
              map_Fill(msrx,1,-1,mgsl_rocks  ,64,base_1r,true );
              end;
   end;

   map_ZonesFill;

   map_CPoints_UpdatePFZone;
   {$IFDEF _FULLGAME}
   map_MakeVisGrid;
   vid_map_RedrawBack:=true;
   {$ENDIF}
end;

procedure Map_randomseed;
begin
   map_seed:=random($FFFFFFFF)+(SDL_GetTicks shl 5);
end;

procedure Map_randommap;
begin
   Map_randomseed;

   map_size    :=MinMapSize+round(random(MaxMapSize-MinMapSize)/StepMapSize)*StepMapSize;
   map_type    :=random(gms_m_types+1);
   map_symmetry:=random(gms_m_symm+1);
end;

procedure Map_premap;
begin
   map_Vars;
   map_PlayerStarts;
   {$IFDEF _FULLGAME}
   map_seed2theme;
   gfx_MakeThemeTiles;
   {$ENDIF}
   map_ReMake;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  map settings


function map_SetSetting(PlayerRequestor,setting:byte;newVal:cardinal;Check:boolean):boolean;
begin
   map_SetSetting:=false;

   if(G_Started)
   or(g_preset_cur>0)
   or((PlayerRequestor>0)and(PlayerLobby>0)and(PlayerLobby<>PlayerRequestor))
   then exit;

   case setting of
nmid_lobbby_mapseed  : begin
                          map_SetSetting:=true;
                          if(Check)then exit;
                          map_seed:=newVal;
                          map_premap;
                       end;
nmid_lobbby_mapsize  : begin
                          if(newVal<MinMapSize)or(MaxMapSize<newVal)then exit;
                          map_SetSetting:=true;
                          if(Check)then exit;
                          map_size:=integer(newVal);
                          map_premap;
                       end;
nmid_lobbby_type     : begin
                          newVal:=byte(newVal);
                          if(gms_m_types<newVal)then exit;
                          map_SetSetting:=true;
                          if(Check)then exit;
                          map_type:=newVal;
                          map_premap;
                       end;
nmid_lobbby_symmetry : begin
                          newVal:=byte(newVal);
                          if(gms_m_symm<newVal)then exit;
                          map_SetSetting:=true;
                          if(Check)then exit;
                          map_symmetry:=newVal;
                          map_premap;
                       end;
   end;
end;


