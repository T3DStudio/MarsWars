
////////////////////////////////////////////////////////////////////////////////
//
//  COMMON

function map_InGridRange(a:integer):boolean;
begin
   map_InGridRange:=(0<=a)and(a<=map_csize); //MaxMapSizeCelln
end;


////////////////////////////////////////////////////////////////////////////////
//
//  VISUAL

{$IFDEF _FULLGAME}

procedure map_ThemeFromSeed;
var
theme,
terrain,
crater,
liquid  : integer;
mseed   : cardinal;
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
   // default
   theme_cur_tile_terrain_id :=-1;
   theme_cur_tile_crater_id  :=-1;
   theme_cur_tile_liquid_id  :=-1;

   // theme
   mseed  :=map_seed;
   theme  :=Pick(theme_n);
   SetTheme(theme);

   terrain :=Pick(theme_cur_terrain_n );
   crater  :=Pick(theme_cur_crater_n  );
   liquid  :=Pick(theme_cur_liquid_n  );

   if(terrain >=0)then theme_cur_tile_terrain_id :=theme_cur_terrain_l [terrain ];
   if(crater  >=0)then theme_cur_tile_crater_id  :=theme_cur_crater_l  [crater  ];
   if(liquid  >=0)then theme_cur_tile_liquid_id  :=theme_cur_liquid_l  [liquid  ];

   if(0<=theme_cur_tile_terrain_id)and(theme_cur_tile_terrain_id<theme_all_terrain_n)then
   begin
      theme_cur_liquid_mmcolor  :=theme_all_terrain_mmcolor  [theme_cur_tile_liquid_id];
      theme_cur_liquid_tas      :=theme_all_terrain_tas      [theme_cur_tile_liquid_id];
      theme_cur_liquid_tasPeriod:=theme_all_terrain_tasPeriod[theme_cur_tile_liquid_id];
   end
   else
   begin
      theme_cur_liquid_mmcolor  :=c_white;
      theme_cur_liquid_tas      :=tas_ice;
      theme_cur_liquid_tasPeriod:=fr_fpsd2;
   end;
end;

procedure map_VisGridMake;
var
 x, y,
mx,my,
o,i  :integer;
decal_i:byte;
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
procedure AddDecor(N,depth,ax,ay:integer);
begin
   with map_grid_graph[x,y] do
   if(tgca_decor_n>=0)then
   begin
      tgca_decor_n+=1;
      setlength(tgca_decor_l,tgca_decor_n);
      with tgca_decor_l[tgca_decor_n-1] do
      begin
         tgca_decorN    :=N;
         tgca_decorS    := theme_all_decor_l[tgca_decorN];
         tgca_decorA    :=@theme_anm_decors [tgca_decorN];
         tgca_decorDepth:=depth+my+ay;
         tgca_decorTime :=DoodadAnimationTime(tgca_decorA^.tda_atime);
         tgca_decorX    :=mx+ax;
         tgca_decorY    :=my+ay;
         tgca_decorF    :=random(2)=0;
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
         tgca_decalS:=theme_all_decal_l[N];
         tgca_decalX:=random(max2i(0,MapCellW-tgca_decalS^.w));
         tgca_decalY:=random(max2i(0,MapCellW-tgca_decalS^.h));
         tgca_decalF:=random(2)=0;
      end;
   end;
end;
procedure AddDecals;
begin
   with map_grid_graph[x,y] do
   if(tgca_decor_n>=0)and(theme_cur_decal_n>0)then
   begin
      decal_i+=1;
      i:=random_table[decal_i] mod 7;
      if(i=0)then
      begin
         decal_i+=1;
         SetDecal(theme_cur_decal_l[(random_table[decal_i]+x+y*2) mod theme_cur_decal_n]);
      end;
   end;
end;
function CheckDecorCell(cx,cy:integer):boolean;
begin
   CheckDecorCell:=false;
   if map_InGridRange(cx) and map_InGridRange(cy)then
     with map_grid      [cx,cy] do
     with map_grid_graph[cx,cy] do
       if(tgc_solidlevel=mgsl_rocks)and(tgca_decor_n=0)then
         CheckDecorCell:=true;
end;

begin
   draw_LoadingScreen(str_map_Proc4VisGrid,c_white);

   // clear visual data
   for x:=0 to MaxMapSizeCelln-1 do
   for y:=0 to MaxMapSizeCelln-1 do
   with map_grid_graph[x,y] do
   begin
      tgca_decor_n:=0;
      setlength(tgca_decor_l,tgca_decor_n);
      tgca_decal_n:=0;
      setlength(tgca_decal_l,tgca_decal_n);
   end;
   FillChar(map_grid_graph,SizeOf(map_grid_graph),0);

   decal_i:=0;

   for y:=0 to MaxMapSizeCelln-1 do
   for x:=0 to MaxMapSizeCelln-1 do
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
                      o:=(i*tGridDecorD)+(x*135)+(y*69);
                      ddir:=DIR360(o)*degtorad;
                      if((abs(o) mod tGridDecorSkipFactor)>0)then continue;
                      AddDecor(theme_cur_decor_l[abs((x+1)*(y+1)+i) mod theme_cur_decor_n],
                               sd_ground,
                               round(tGridDecorR*cos(ddir)),
                               round(tGridDecorR*sin(ddir)));
                   end;
                 AddDecals;
              end;
mgsl_liquid : begin
                 tgca_tile_liquid:=0;
                 tgca_tile_crater:=0;
              end;
mgsl_rocks  : begin
                 tgca_tile_crater:=0;

                 if(theme_cur_2rock_n>0)and(tgca_decor_n=0)then
                   if ((x+1)<MaxMapSizeCelln)
                   and((y+1)<MaxMapSizeCelln)then
                     //if (map_grid[x+1,y  ].tgc_solidlevel=mgsl_rocks)
                     //and(map_grid[x+1,y+1].tgc_solidlevel=mgsl_rocks)
                     //and(map_grid[x  ,y+1].tgc_solidlevel=mgsl_rocks)
                     if  CheckDecorCell(x+1,y  )
                     and CheckDecorCell(x+1,y+1)
                     and CheckDecorCell(x  ,y+1)
                     then
                     begin
                        mx+=MapCellHW;
                        my+=MapCellHW;
                        i:=theme_cur_2rock_l[abs((x+1)*(y+1)) mod theme_cur_2rock_n];
                        AddDecor(i,sd_rocks,0,0);
                        map_grid_graph[x+1,y  ].tgca_decor_n:=-1;
                        map_grid_graph[x+1,y+1].tgca_decor_n:=-1;
                        map_grid_graph[x  ,y+1].tgca_decor_n:=-1;
                        continue;
                     end;

                 if(theme_cur_1rock_n>0)then
                   AddDecor(theme_cur_1rock_l[abs((x+1)*(y+1)) mod theme_cur_1rock_n],
                            sd_ground,
                            0,0);
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

function x2CellCenter(x:integer):integer;
begin
   x2CellCenter:=(x div MapCellW)*MapCellW+MapCellhW;
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
               then map_GetSymmetryDir:=dir360(map_GetSymmetryDir+180);
            end;
   else
            map_GetSymmetryDir:=(dir360(map_seed) div 45)*45;
   end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//  MAP SYMMETRY

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

////////////////////////////////////////////////////////////////////////////////
//
//  MAP ZONES

function map_CellGetZone(cx,cy:integer):word;
begin
   if (0<=cx)and(cx<=map_csize)
   and(0<=cy)and(cy<=map_csize)
   then map_CellGetZone:=map_grid[cx,cy].tgc_pf_zone
   else map_CellGetZone:=map_CellGetZone.MaxValue;
end;
function map_MapGetZone(mx,my:integer):word;
begin
   map_MapGetZone:=map_CellGetZone(mx div MapCellW,my div MapCellW);
end;

function map_IsObstacleZone(zone:word):boolean;
begin
   map_IsObstacleZone:=(zone=0)or(zone>map_gridZone_n);
end;

function map_ZoneFillPart(x,y:integer;zone:word;Check:boolean):boolean;
begin
   map_ZoneFillPart:=false;

   if(x<0)
   or(y<0)
   or(x>map_csize)
   or(y>map_csize)then exit;

   with map_grid[x,y] do
   begin
      if(tgc_solidlevel>=mgsl_liquid)then exit;
      if(tgc_pf_zone>0)then exit;

      map_ZoneFillPart:=true;

      if(Check)then exit;

      tgc_pf_zone:=zone;
   end;

   map_ZoneFillPart(x-1,y  ,zone,false);
   map_ZoneFillPart(x+1,y  ,zone,false);
   map_ZoneFillPart(x  ,y-1,zone,false);
   map_ZoneFillPart(x  ,y+1,zone,false);
end;

procedure map_ZonesMake;
var x,y:integer;
begin
   {$IFDEF _FULLGAME}
   draw_LoadingScreen(str_map_Proc1Zones,c_white);
   {$ENDIF}
   map_gridZone_n:=0;
   for x:=0 to MaxMapSizeCelln-1 do
   for y:=0 to MaxMapSizeCelln-1 do
     with map_grid[x,y] do
       tgc_pf_zone:=0;

   for x:=0 to map_csize do
   for y:=0 to map_csize do
     with map_grid[x,y] do
       if(map_ZoneFillPart(x,y,0,true))then
       begin
          map_gridZone_n+=1;
          map_ZoneFillPart(x,y,map_gridZone_n,false);
       end;
   writeln('map_gridZone_n ',map_gridZone_n);
end;

////////////////////////////////////////////////////////////////////////////////
//
//  PATH FIND DATA

procedure map_pf_MarkSolidCells;
var x,y:integer;
function SolidLevel(cx,cy:integer):boolean;
begin
   if (0<=cx)and(cx<=map_csize)
   and(0<=cy)and(cy<=map_csize)
   then SolidLevel:=map_grid[cx,cy].tgc_solidlevel>=mgsl_liquid
   else SolidLevel:=false;
end;
function CheckNoSolidAround(cx0,cy0,cx1,cy1:integer):boolean;
var x,y:integer;
begin
   CheckNoSolidAround:=true;
   for x:=cx0 to cx1 do
   for y:=cy0 to cy1 do
     if(x=cx0)or(y=cy0)or(x=cx1)or(y=cy1)then
       if(SolidLevel(x,y))then
       begin
          CheckNoSolidAround:=false;
          exit;
       end;
end;
begin
   {$IFDEF _FULLGAME}
   draw_LoadingScreen(str_map_Proc2Solid,c_white);
   {$ENDIF}
   for x:=0 to map_csize do
   for y:=0 to map_csize do
     with map_grid[x,y] do
       if(SolidLevel(x,y))then
         tgc_pf_solid:= not(CheckNoSolidAround(x-1,y-1,x+1,y+1)
                         or CheckNoSolidAround(x-2,y-2,x+1,y+1)
                         or CheckNoSolidAround(x-1,y-2,x+2,y+1)
                         or CheckNoSolidAround(x-2,y-1,x+1,y+2)
                         or CheckNoSolidAround(x-1,y-1,x+2,y+2));
end;
{$IFDEF DTEST}
procedure debug_cell(cx,cy,cw:integer;color:TMWColor);
begin
   cx:=cx*MapCellw+cw;
   cy:=cy*MapCellw+cw;
   cw*=2;
  // UIInfoItemAddRect(cx,cy,cx+MapCellw-cw,cy+MapCellw-cw,color);
end;

procedure debug_AddDoaminCells;
var
sx0,sy0,
x0,y0,
gx,gy:integer;
begin
   if(map_gridDomain_n=0)then exit;

   sx0:=vid_cam_x div MapCellW;
   sy0:=vid_cam_y div MapCellW;

   for x0:=0 to ui_MapView_cw do
   for y0:=0 to ui_MapView_ch do
   begin
      gx:=x0+sx0;
      gy:=y0+sy0;
      if(not map_InGridRange(gx))
      or(not map_InGridRange(gy))then continue;
      with map_grid[gx,gy] do
        if(tgc_pf_domain>0)then
        begin
          // debug_cell(gx,gy,1,map_gridDomain_color[tgc_pf_domain-1]);
           with ui_UIItem_l[ui_UIItem_n-1] do
           begin
              text_lt :=b2s(tgc_solidlevel);
              text_lt2:=w2s(tgc_pf_domain)+' '+str_b2c[tgc_pf_solid];
              text_ld :=i2s(gx)+'_'+i2s(gy);
           end;
        end;
   end;
end;
procedure debug_SetDomainColors;
var w:word;
begin
   setlength(map_gridDomain_color,map_gridDomain_n);
   if(map_gridDomain_n>0)then
     for w:=0 to map_gridDomain_n-1 do
       map_gridDomain_color[w]:=gfx_MakeTMWColor(random(255),random(255),random(255));
end;


{$ENDIF}

function map_GridLineCollision(x0,y0,x1,y1:integer;domainCheck:word):boolean;
var
dx,dy,
px,py,
sx,sy:integer;
e1,e2:longint;
function map_CheckPFSolid(cx,cy:integer):boolean;
begin
   map_CheckPFSolid:=true;
   if (0<=cx)and(cx<=map_csize)
   and(0<=cy)and(cy<=map_csize)then
     with map_grid[cx,cy] do
       if(domainCheck>0)and(tgc_pf_domain>0)
       then map_CheckPFSolid:=tgc_pf_solid or (domainCheck<>tgc_pf_domain)
       else map_CheckPFSolid:=tgc_pf_solid;
end;
begin
   if(map_CheckPFSolid(x1,y1))then
   begin
      map_GridLineCollision:=true;
      exit;
   end;

   dx:= abs(x1-x0);
   dy:=-abs(y1-y0);
   e1:=dx+dy;
   if(x0<x1)then sx:=1 else sx:=-1;
   if(y0<y1)then sy:=1 else sy:=-1;

   map_GridLineCollision:=false;

   while(true)do
   begin
      if(map_CheckPFSolid(x0,y0))then
      begin
         map_GridLineCollision:=true;
         break;
      end;
      if(x0=x1)and(y0=y1)then break;
      px:=x0;
      py:=y0;
      e2:=e1+e1;
      if(e2>=dy)and(x0<>x1)then
      begin
          e1+=dy;
          x0+=sx;
      end;
      if(e2<=dx)and(y0<>y1)then
      begin
          e1+=dx;
          y0+=sy
      end;
      if(px<>x0)and(py<>y0)then
        if  map_CheckPFSolid(px,y0)
        and map_CheckPFSolid(x0,py) then
        begin
           map_GridLineCollision:=true;
           break;
        end;
   end;
end;

procedure map_pf_DomainsClear;
var d1,d2:word;
begin
   if(map_gridDomain_n>0)then
    for d1:=0 to map_gridDomain_n-1 do
    for d2:=0 to map_gridDomain_n-1 do
      with map_gridDomainMX[d1,d2] do
      begin
         setlength(edgeCells_l,0);
         edgeCells_n:=0;
         nextDomain :=0;
      end;
   for d1:=0 to map_csize do
   for d2:=0 to map_csize do
   with map_grid[d1,d2] do tgc_pf_domain:=0;

   map_gridDomain_n:=0;
   setlength(map_gridDomainMX,0,0);
   {$IFDEF DTEST}
   setlength(map_gridDomain_color,0);
   {$ENDIF}
end;

////////////////////////////////////////////////////////////////////////////////

procedure map_pf_DomainsFill;
var
x,y         :integer;
domain2count: array of word;
domain2point,
tmp_points_l: array of TPoint;
tmp_points_n,dn,
tmp_points_i: word;
function SetDomain(cx,cy:integer;newDomain:word):boolean;
var i:word;
begin
   SetDomain:=false;

   if(cx<0)
   or(cy<0)
   or(cx>map_csize)
   or(cy>map_csize)then exit;

   if(tmp_points_n=tmp_points_n.MaxValue)then exit;

   with map_grid[cx,cy] do
   begin
      if(tgc_solidlevel>=mgsl_liquid)
      or(tgc_pf_domain>0)
      or(tgc_pf_domain=newDomain)
      or(tgc_pf_solid)then exit;

      if(tmp_points_n>0)then
        for i:=0 to tmp_points_n-1 do
          with tmp_points_l[i] do
           if (map_GridLineCollision(cx,cy,p_x,p_y,newDomain)
           and map_GridLineCollision(p_x,p_y,cx,cy,newDomain))then exit;

      SetDomain:=true;

      tgc_pf_domain:=newDomain;
   end;

   tmp_points_n+=1;
   setlength(tmp_points_l,tmp_points_n);
   with tmp_points_l[tmp_points_n-1] do
   begin
      p_x:=cx;
      p_y:=cy;
   end;
end;
procedure StartFillDomain(sx,sy:integer);
begin
   tmp_points_i:=0;
   tmp_points_n:=0;
   setlength(tmp_points_l,0);

   if(map_gridDomain_n=map_gridDomain_n.MaxValue)then exit;

   if(not SetDomain(sx,sy,map_gridDomain_n+1))then exit;
   map_gridDomain_n+=1;

   setlength(domain2point,map_gridDomain_n);
   setlength(domain2count,map_gridDomain_n);
   domain2count[map_gridDomain_n-1]:=1;
   with domain2point[map_gridDomain_n-1] do
   begin
      p_x:=sx;
      p_y:=sy;
   end;

   while(tmp_points_i<tmp_points_n)do
   begin
      with tmp_points_l[tmp_points_i] do
      begin
         sx:=p_x;
         sy:=p_y;
      end;
      SetDomain(sx-1,sy  ,map_gridDomain_n);
      SetDomain(sx+1,sy  ,map_gridDomain_n);
      SetDomain(sx  ,sy-1,map_gridDomain_n);
      SetDomain(sx  ,sy+1,map_gridDomain_n);
      tmp_points_i+=1;
   end;
   domain2count[map_gridDomain_n-1]:=tmp_points_n;
end;
{procedure CheckDomainNeighbor(cx,cy:integer);
var d:word;
begin
   if(cx<0)
   or(cy<0)
   or(cx>map_csize)
   or(cy>map_csize)then exit;

   d:=map_grid[cx,cy].tgc_pf_domain;
   if(d>0)then
   begin
      d-=1;
      if(domain2count[d]<tmp_points_i)then
      begin
         tmp_points_i:=domain2count[d];
         dn:=d;
      end;
   end;
end; }

begin
   setlength(domain2point,0);
   setlength(domain2count,0);

   //for x:=0 to LastPlayer do
  //   StartFillDomain(map_PlayerStartX[x] div MapCellw,map_PlayerStartY[x] div MapCellw);

   //for x:=0 to map_csize do
   //for y:=0 to map_csize do StartFillDomain(x,y);

  { if(map_gridDomain_n>0)then
     for tmp_points_n:=0 to map_gridDomain_n-1 do
       if(domain2count[tmp_points_n]=1)then
       begin
          dn:=0;
          tmp_points_i:=tmp_points_i.MaxValue;
          with domain2point[tmp_points_n] do
          begin
             CheckDomainNeighbor(p_x-1,p_y);
             CheckDomainNeighbor(p_x+1,p_y);
             CheckDomainNeighbor(p_x,p_y-1);
             CheckDomainNeighbor(p_x,p_y+1);
             if(tmp_points_i<tmp_points_i.MaxValue)then
               map_grid[p_x,p_y].tgc_pf_domain:=dn+1;
          end;
       end;}

   writeln('map_gridDomain_n ',map_gridDomain_n);
   setlength(tmp_points_l,0);
   setlength(domain2point,0);
   setlength(domain2count,0);
   {$IFDEF DTEST}
   debug_SetDomainColors;
   {$ENDIF}
end;

function GetDomain(cx,cy:integer):word;
begin
   GetDomain:=GetDomain.MaxValue;
   if (0<=cx)and(cx<=map_csize)
   and(0<=cy)and(cy<=map_csize)then
    with map_grid[cx,cy] do
     if(tgc_pf_domain>0)
     then GetDomain:=tgc_pf_domain-1;
end;

procedure map_pf_DomainEdges; //////////////////////////////////////////////////
var
d1,d2:word;
x ,y :integer;
procedure CheckAddDomainEdge(cx,cy:integer);
begin
   d2:=GetDomain(cx,cy);
   if(d2<d2.MaxValue)and(d1<>d2)then
     with map_gridDomainMX[d1,d2] do
     begin
        edgeCells_n+=1;
        setlength(edgeCells_l,edgeCells_n);
        with edgeCells_l[edgeCells_n-1] do
        begin
           p_x:=cx;
           p_y:=cy;
        end;
     end;
end;
begin
   setlength(map_gridDomainMX,map_gridDomain_n,map_gridDomain_n);
   for d1:=0 to map_gridDomain_n-1 do
   for d2:=0 to map_gridDomain_n-1 do
     with map_gridDomainMX[d1,d2] do
     begin
        nextDomain :=0;
        edgeCells_n:=0;
        setlength(edgeCells_l,0);
     end;

   for x:=0 to map_csize do
   for y:=0 to map_csize do
     with map_grid[x,y] do
      if(tgc_pf_domain>0)and(tgc_pf_zone>0)then
      begin
         d1:=tgc_pf_domain-1;
         CheckAddDomainEdge(x-1,y);
         CheckAddDomainEdge(x+1,y);
         CheckAddDomainEdge(x,y-1);
         CheckAddDomainEdge(x,y+1);
      end;
end;

procedure map_pf_MakeNext;    //////////////////////////////////////////////////
type
TtmpGrid = array[0..MaxMapSizeCelln-1,0..MaxMapSizeCelln-1] of word;
ptmpGrid = ^TtmpGrid;
var
tmpGrid      : ptmpGrid;
d1,d2,dx,di,
wave_data_n,
wave_data_i  : word;
wave_data_dl : array of word;
wave_data_pl : array of TPoint;
pdx          : PTMapGridPFDomainData;
procedure WavePoint(cx,cy:integer;rootDomain,startDomain:word);
begin
   if(cx<0)
   or(cy<0)
   or(cx>map_csize)
   or(cy>map_csize)then exit;

   if(tmpGrid^[cx,cy]=startDomain)then exit;

   with map_grid[cx,cy] do
   begin
      if(rootDomain=0)then rootDomain:=tgc_pf_domain;

      if(tgc_pf_domain=0)
      or(tgc_pf_domain=startDomain)
      or(tgc_pf_solid)then exit;

      with map_gridDomainMX[startDomain-1,tgc_pf_domain-1] do
        if(nextDomain=0)then
          nextDomain:=rootDomain;
   end;
   tmpGrid^[cx,cy]:=startDomain;

   wave_data_n+=1;
   setlength(wave_data_pl,wave_data_n);
   setlength(wave_data_dl,wave_data_n);
   wave_data_dl[wave_data_n-1]:=rootDomain;
   with wave_data_pl[wave_data_n-1] do
   begin
      p_x:=cx;
      p_y:=cy;
   end;
end;
begin
   new(tmpGrid);
   FillChar(tmpGrid^,sizeOf(TtmpGrid),0);

   for d1:=0 to map_gridDomain_n-1 do
   begin
      di:=d1+1;
      wave_data_n:=0;
      wave_data_i:=0;
      setlength(wave_data_pl,0);
      setlength(wave_data_dl,0);

      for d2:=0 to map_gridDomain_n-1 do
        with map_gridDomainMX[d1,d2] do
          if(d1<>d2)and(edgeCells_n>0)then
            for dx:=0 to edgeCells_n-1 do
              with edgeCells_l[dx] do
                WavePoint(p_x,p_y,0,di);

      while(wave_data_i<wave_data_n)do
      begin
         with wave_data_pl[wave_data_i] do
         begin
            dx:=wave_data_dl[wave_data_i];
            WavePoint(p_x-1,p_y  ,dx,di);
            WavePoint(p_x+1,p_y  ,dx,di);
            WavePoint(p_x  ,p_y-1,dx,di);
            WavePoint(p_x  ,p_y+1,dx,di);
         end;
         wave_data_i+=1;
      end;
   end;

   dispose(tmpGrid);
   wave_data_n:=0;
   wave_data_i:=0;
   setlength(wave_data_pl,0);
   setlength(wave_data_dl,0);

   // add edgeCells
   for d1:=0 to map_gridDomain_n-1 do
   for d2:=0 to map_gridDomain_n-1 do
   begin
      pdx:=@map_gridDomainMX[d1,d2];
      if(pdx^.nextDomain>0)and(pdx^.edgeCells_n=0)then
        with map_gridDomainMX[d1,pdx^.nextDomain-1] do
          if(edgeCells_n>0)then
          begin
             pdx^.edgeCells_n:=edgeCells_n;
             setlength(pdx^.edgeCells_l,edgeCells_n);
             for di:=0 to edgeCells_n-1 do
               pdx^.edgeCells_l[di]:=edgeCells_l[di];
          end;
   end;
end;

procedure map_pf_DomainEdgesCX2MX;//////////////////////////////////////////////
const MapCellqW = MapCellW div 4;
var
d1,d2,w:word;
//d1x,d1y:integer;
{procedure SetD1XY(x,y,sx,sy:integer);
begin
   if(GetDomain(x+sx,y+sy)=d1)then
   begin
      d1x+=sx;
      d1y+=sy;
   end;
end; }
begin
   if(map_gridDomain_n>0)then
     for d1:=0 to map_gridDomain_n-1 do
     for d2:=0 to map_gridDomain_n-1 do
       with map_gridDomainMX[d1,d2] do
         if(edgeCells_n>0)then
           for w:=0 to edgeCells_n-1 do
             with edgeCells_l[w] do
             begin
                {d1x:=0;
                d1y:=0;
                SetD1XY(p_x,p_y,-1, 0);
                SetD1XY(p_x,p_y, 1, 0);
                SetD1XY(p_x,p_y, 0,-1);
                SetD1XY(p_x,p_y, 0, 1);   }
                p_x:=(p_x*MapCellW);//+MapCellhW+(d1x*MapCellqW);
                p_y:=(p_y*MapCellW);//+MapCellhW+(d1y*MapCellqW);
             end;
end;

procedure map_pf_MakeDomains;
var
time:cardinal;
begin
   {$IFDEF _FULLGAME}
   draw_LoadingScreen(str_map_Proc3Domains,c_white);
   {$ENDIF}
   // clear domains
   time:=sdl_GetTicks;
   map_pf_DomainsClear;
   writeln('Domains: clear ',sdl_GetTicks-time,'ms');

   // make domains
   time:=sdl_GetTicks;
   map_pf_DomainsFill;
   writeln('Domains: make ',sdl_GetTicks-time,'ms');

   if(map_gridDomain_n=0)then exit;

   // make domain edgeds
   time:=sdl_GetTicks;
   map_pf_DomainEdges;
   writeln('Domains: edges ',sdl_GetTicks-time,'ms');

   // make 'next' domain
   time:=sdl_GetTicks;
   map_pf_MakeNext;
   writeln('Domains: next ',sdl_GetTicks-time,'ms');

   // make edges cx to mx
   time:=sdl_GetTicks;
   map_pf_DomainEdgesCX2MX;
   writeln('cx to mx ',sdl_GetTicks-time,'ms');
end;

////////////////////////////////////////////////////////////////////////////////
//
//  CHECKS

function map_InMapRange(x,y,aborder:integer):boolean;
begin
   if(x=NOTSET)or(y=NOTSET)
   then map_InMapRange:=true
   else map_InMapRange:=(-aborder<=x)and(x<=(map_psize+aborder))
                     and(-aborder<=y)and(y<=(map_psize+aborder));
end;

function map_IfHereObjectCell(cx,cy,baser:integer;players:boolean):byte;
var p:byte;
x0,y0,tr,
mx,my:integer;
begin
   map_IfHereObjectCell:=0;
   if(cx=NOTSET)
   or(cy=NOTSET)then exit;
   if (0<=cx)and(cx<=map_csize)
   and(0<=cy)and(cy<=map_csize)then
   begin
      x0:=cx*MapCellW;
      y0:=cy*MapCellW;
      case players of
true : for p:=0 to LastPlayer do
         if (map_PlayerStartX[p]<>NOTSET)
         and(map_PlayerStartY[p]<>NOTSET)then
         begin
            mgcell2NearestXY(map_PlayerStartX[p],map_PlayerStartY[p],x0,y0,x0+MapCellW,y0+MapCellW,0,@mx,@my,nil);
            if(point_dist_int(mx,my,map_PlayerStartX[p],map_PlayerStartY[p])<=baser)
            then map_IfHereObjectCell+=1;
         end;
false: for p:=0 to LastKeyPoint do
        with g_KeyPoints[p] do
         if(kp_CaptureR>0)then
         begin
            if(baser<0)
            then tr:=kp_CaptureR//+MapCellhW
            else tr:=baser;
            mgcell2NearestXY(kp_x,kp_y,x0,y0,x0+MapCellW,y0+MapCellW,0,@mx,@my,nil);
            if(point_dist_int(mx,my,kp_x,kp_y)<=tr)
            then map_IfHereObjectCell+=1;
         end;
      end;
   end;
end;

function map_IfPlayerStartHere(basex,basey,symmx,symmy,r:integer):boolean;
var p:byte;
begin
   map_IfPlayerStartHere:=false;
   if(r<=0)then
   begin
      map_IfPlayerStartHere:=true;
      exit;
   end;

   if(map_InMapRange(symmx,symmy,0))then
     if(point_dist_int(basex,basey,symmx,symmy)<(r+r))then
     begin
        map_IfPlayerStartHere:=true;
        exit;
     end;

   for p:=0 to map_MaxPlayers-1 do
     if (map_PlayerStartX[p]<>NOTSET)
     and(map_PlayerStartY[p]<>NOTSET)then
     begin
        if(point_dist_int(basex,basey,map_PlayerStartX[p],map_PlayerStartY[p])<r)then
        begin
           map_IfPlayerStartHere:=true;
           break;
        end;
        if(map_InMapRange(symmx,symmy,0))then
          if(point_dist_int(symmx,symmy,map_PlayerStartX[p],map_PlayerStartY[p])<r)then
          begin
             map_IfPlayerStartHere:=true;
             break;
          end;
     end;
end;

function map_IfKeyPointHere(basex,basey,symx,symy,r:integer):boolean;
var p:byte;
    t:integer;
begin
   if(r<=0)then
   begin
      map_IfKeyPointHere:=true;
      exit;
   end;
   map_IfKeyPointHere:=false;

   if(point_dist_int(basex,basey,symx,symy)<(r*2))then
   begin
      map_IfKeyPointHere:=true;
      exit;
   end;

   for p:=0 to LastKeyPoint do
    with g_KeyPoints[p] do
     if(kp_CaptureR>0)then
     begin
        t:=r+max2i(kp_solidR,kp_CaptureR);
        if(point_dist_int(basex,basey,kp_x,kp_y)<t)
        or(point_dist_int(symx ,symy ,kp_x,kp_y)<t)then
        begin
           map_IfKeyPointHere:=true;
           break;
        end;
     end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//  Key Points

procedure map_KeyPoints_UpdatePFZone;
var pn:integer;
begin
   for pn:=0 to LastKeyPoint do
    with g_KeyPoints[pn] do
     if(kp_CaptureR>0)then kp_Zone:=map_MapGetZone(kp_x,kp_y);
end;

function map_KeyPoints_Add(akpx,akpy,asolidR,aNoBuildR,aenergy,aCaptureR,atime:integer;alifetime:cardinal):boolean;
var keyi:byte;
begin
   for keyi:=0 to LastKeyPoint do
     if(g_KeyPoints[keyi].kp_CaptureR<=0)then break;

   map_KeyPoints_Add:=false;

   if(keyi>LastKeyPoint)then exit;

   map_KeyPoints_Add:=true;

   with g_KeyPoints[keyi] do
   begin
      kp_x          :=akpx;
      kp_y          :=akpy;
      kp_ToCenterD  :=point_dist_int(kp_x,kp_y,map_phsize,map_phsize);
      kp_solidR     :=asolidR;
      kp_NoBuildR   :=aNoBuildR;
      kp_energy     :=aenergy;
      kp_CaptureR   :=aCaptureR;
      kp_CaptureTime:=atime;
      kp_lifeTime   :=alifetime;
      {$IFDEF _FULLGAME}
      kp_MiniMapX:=round(map_mm_cx*kp_x);
      kp_MiniMapY:=round(map_mm_cx*kp_y);
      kp_MiniMapR:=round(map_mm_cx*kp_CaptureR);
      {$ENDIF}
   end;
end;

procedure map_KeyPoints_Default(num:byte;sr,cr,nr,energy,time,freeCenterR:integer;lifetime:cardinal;newpoints:boolean);
var
basex,basey,
symx,symy,
i,u,b,c,
dst        :integer;
function setkpoint(px,py:integer):boolean;
var pn:byte;
begin

end;
begin
   if(newpoints)then FillChar(g_KeyPoints,SizeOf(g_KeyPoints),0);
   u:=map_psize div 50;
   b:=map_psize-(u*2);

  { i:=0;
   while(i<num)do
   begin
      i+=1+byte(map_symmetry);
      c:=0;
      dst:=max2i(base_1rh,map_psize div 8);
      while(c<1000)do
      begin
         basex:=x2CellCenter(u+g_random(b));
         basey:=x2CellCenter(u+g_random(b));
         SymmetryXY(basex,basey,map_psize,@symx,@symy,map_symmetry);

         c+=1;
         if(c>500)then dst-=1;

         if map_InMapRange(symx,symy,0)then
           if (not map_IfPlayerStartHere(basex,basey,symx,symy,dst))
           and(not map_IfKeyPointHere   (basex,basey,symx,symy,dst))then
           begin
              if(freeCenterR>0)then
                if(point_dist_int(basex,basey,map_phsize,map_phsize)<=freeCenterR)then continue;

              if(setkpoint(basex,basey))then exit;
              if(symx<>NOTSET)then
                if(setkpoint(symx,symy))then exit;
              break;
           end;
      end;
   end;  }
end;

procedure map_KeyPoints;
begin
   FillChar(g_KeyPoints,SizeOf(g_KeyPoints),0);

   case map_scenario of
ms_KotH   : with g_KeyPoints[0] do
            begin
               kp_x:=map_phsize;
               kp_y:=map_phsize;
               kp_CaptureR   :=base_1r;
               kp_CaptureTime:=fr_fps1*60;

               {$IFDEF _FULLGAME}
               kp_MiniMapX:=round(kp_x*map_mm_cx);
               kp_MiniMapY:=round(kp_y*map_mm_cx);
               kp_MiniMapR:=round(kp_CaptureR*map_mm_cx)+1;
               {$ENDIF}
            end;
ms_capture: map_KeyPoints_Default(4,0,gm_cptp_r,base_1r,0,gm_cptp_time,byte(map_type=mapt_clake)*(map_psize div 3),0,true);
   end;

   if(map_generators>0)then
     map_KeyPoints_Default(LastKeyPoint,50,gm_cptp_r,gm_cptp_r div 2,g_cgenerators_energy,gm_cptp_gtime,byte(map_type=mapt_clake)*(map_psize div 3),g_cgenerators_ltime[map_generators],false);
end;

////////////////////////////////////////////////////////////////////////////////
//
//  PLAYER STARTS

procedure map_PlayerStartsShuffle(teamShuffle:boolean);
var
x,y:byte;
i  :integer;
begin
   if(map_MaxPlayers>0)then
     for x:=0 to map_MaxPlayers-1 do
     for y:=0 to map_MaxPlayers-1 do
       if(random(2)=0)and(x<>y)then
       begin
          if(teamShuffle)and(g_players[x].team<>g_players[y].team)then continue;
          i:=map_PlayerStartX[x];map_PlayerStartX[x]:=map_PlayerStartX[y];map_PlayerStartX[y]:=i;
          i:=map_PlayerStartY[x];map_PlayerStartY[x]:=map_PlayerStartY[y];map_PlayerStartY[y]:=i;
       end;
end;

procedure map_PlayerStartsCircle(r:integer);
var
sdir,
pcount,
dstep:integer;
begin
   if(map_MaxPlayers<=0)then exit;
   pcount:=map_MaxPlayers;
   dstep:=360 div pcount;
   sdir:=abs(map_symmetryDir mod 360);
   while(pcount>0)do
   begin
      pcount-=1;
      map_PlayerStartX[pcount]:=map_phsize+round(r*cos(sdir*degtorad));
      map_PlayerStartY[pcount]:=map_phsize+round(r*sin(sdir*degtorad));
      sdir+=dstep;
   end;
end;

procedure project2rect(tarx,tary:pinteger;dir:single;rw:integer);
var
sn,cs:single;
rs   :integer;
begin
   cs:=cos(dir*degtorad);
   sn:=sin(dir*degtorad);
   rs:=round(rw*1.3); //1.414
   if(abs(cs)>=abs(sn))then
   begin
      if(cs<0)
      then tarx^:=-rw
      else tarx^:= rw;
      tary^:=round(rs*sn);
   end
   else
   begin
      tarx^:=round(rs*cs);
      if(sn<0)
      then tary^:=-rw
      else tary^:= rw;
   end;
end;

procedure map_PlayerStartsTeams;
var
playerPerTeam,
team,
player,p,
sideStep: integer;
sdirStep,
sdirStepT,
pdir,
sdir    : single;
begin
   if(map_maxTeams<=0)then exit;
   sideStep:=map_phsize-(map_phsize div 4);
   playerPerTeam:=map_MaxPlayers div map_maxTeams;
   if(playerPerTeam=0)then exit;
   sdirStep:=360/map_maxTeams;
   if(sdirStep<1)then sdirStep:=1;
   sdirStepT:=sdirStep/(playerPerTeam+1);
   sdir    :=map_symmetryDir+90-(sdirStepT/2)*(playerPerTeam-1);
   for team:=0 to map_maxTeams-1 do
   begin
      pdir:=sdir;
      for p:=0 to playerPerTeam-1 do
      begin
         player:=team*playerPerTeam+p;
         project2rect(@map_PlayerStartX[player],@map_PlayerStartY[player],sdir,sideStep);
         map_PlayerStartX[player]+=map_phsize;
         map_PlayerStartY[player]+=map_phsize;
         sdir+=sdirStepT;
      end;
      sdir:=pdir+sdirStep;
   end;
end;

function map_PlayerStartsRandom(FreeCenterR:integer):boolean;
var
i,playershn:byte;
basex,basey,
symx ,symy ,
r,c,
dst,
bb0,bb1:integer;
begin
   map_PlayerStartsRandom:=false;
   if(map_MaxPlayers=0)then exit;

   bb0:=base_1r+(map_psize-MinMapSize) div 9;
   bb1:=map_psize-(bb0*2);
   dst:=base_1r+(map_psize div 5);
   playershn:=(map_MaxPlayers div 2)+(map_MaxPlayers mod 2);

   for i:=0 to map_MaxPlayers-1 do
   begin
      if(map_symmetry>maps_none)and(i>=playershn)then break;
      r:=dst;
      c:=0;
      while true do
      begin
         c+=1;
         if(c>500)then break;
         if(c>100)and(r>base_2r)then r-=1;

         basex:=bb0+g_random(bb1);
         basey:=bb0+g_random(bb1);

         SymmetryXY(basex,basey,map_psize,@symx,@symy,map_symmetry);

         if(map_IfPlayerStartHere(basex,basey,symx,symy,r))then continue;

         if(point_dist_int(basex,basey,map_phsize,map_phsize)<=FreeCenterR)then continue;
         if(map_InMapRange(symx,symy,-bb0))then
           if(point_dist_int(symx ,symy ,map_phsize,map_phsize)<=FreeCenterR)then continue;

         map_PlayerStartX[i]:=basex;
         map_PlayerStartY[i]:=basey;
         if(map_symmetry>maps_none)then
         begin
            map_PlayerStartX[i+playershn]:=symx;
            map_PlayerStartY[i+playershn]:=symy;
         end;
         break;
      end;
      writeln(i,' ',c);
   end;

   for i:=0 to map_maxPlayers-1 do
     if(map_PlayerStartX[i]=NOTSET)
     or(map_PlayerStartY[i]=NOTSET)
     then exit;

   map_PlayerStartsRandom:=true;
end;

procedure map_SetEmptyPositions;
var p:byte;
basex,
basey,
//symx ,
//symy ,
c    :integer;
begin
   for p:=0 to LastPlayer do
     if(map_PlayerStartX[p]=NOTSET)
     and(p>=map_MaxPlayers)then
     begin
        c:=50;
        while(c>0)do
        begin
           c-=1;
           basex:=g_random(map_psize);
           basey:=g_random(map_psize);

           //SymmetryXY(basex,basey,map_psize,@symx,@symy,map_symmetry);

           if(map_IfPlayerStartHere(basex,basey,NOTSET,NOTSET,base_3r))then continue;
           if(point_dist_int(basex,basey,map_phsize,map_phsize)<=map_FreeCenterR)then continue;

           map_PlayerStartX[p]:=basex;
           map_PlayerStartY[p]:=basey;
           break;
        end;
     end;
end;

procedure map_PlayerStartsScirmish;
var p:byte;
begin
   for p:=0 to LastPlayer do
   begin
      map_PlayerStartX[p]:=NOTSET;
      map_PlayerStartY[p]:=NOTSET;
   end;

   case map_scenario of
ms_1x1,
ms_2x2,
ms_3x3,
ms_4x4,
ms_2x2x2,
ms_2x2x2x2   : map_PlayerStartsTeams;
ms_KotH      : map_PlayerStartsCircle(map_phsize-(map_psize div 8));
ms_royale    : map_PlayerStartsCircle(map_phsize-(map_psize div 5));
   else if(not map_PlayerStartsRandom(map_FreeCenterR))
          then map_PlayerStartsCircle(map_phsize-(map_psize div 6));
   end;
   map_SetEmptyPositions;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  GRID CYCLE

procedure map_GridCycleInit;
begin
   map_gcpx:=0;
   map_gcpy:=0;
   SymmetryXY(map_gcpx,map_gcpy,map_csize,@map_gcsx,@map_gcsy,map_symmetry);
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
       SymmetryXY(varx^,vary^,map_csize,varsx,varsy,map_symmetry);
    end;
end;
begin
   map_GridCycleNext:=false;
   case map_symmetry of
maps_none : map_GridCycleNext:=Step(@map_gcpx,@map_gcpy,@map_gcsx,@map_gcsy,map_csize         ,map_csize  );
maps_lineV: map_GridCycleNext:=Step(@map_gcpx,@map_gcpy,@map_gcsx,@map_gcsy,map_chsize        ,map_csize  );
maps_point,
maps_lineH: map_GridCycleNext:=Step(@map_gcpx,@map_gcpy,@map_gcsx,@map_gcsy,map_csize         ,map_chsize);
maps_lineL: map_GridCycleNext:=Step(@map_gcpx,@map_gcpy,@map_gcsx,@map_gcsy,map_gcpy          ,map_csize  );
maps_lineR: map_GridCycleNext:=Step(@map_gcpx,@map_gcpy,@map_gcsx,@map_gcsy,map_csize-map_gcpy,map_csize  );
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  MAP GENERATOR BASE

procedure map_GridFillR(tx,ty,tr:integer;value,skipFactor:byte;startsR:integer;replace,outLineR:boolean);
var d:integer;
begin
   map_GridCycleInit;

   d:=NOTSET;
   repeat
     if(map_grid[map_gcpx,map_gcpy].tgc_solidlevel=mgsl_free)or(replace)or(outLineR)then
     begin
        if(tr<>0)or(outLineR)then d:=point_dist_int(tx,ty,map_gcpx,map_gcpy);

        if(skipFactor>0)then
          if(random_table[byte(byte(map_gcpx+1)*byte(map_gcpy+map_gcpx+1)+byte(tx+ty+tr))] mod skipFactor)>0 then continue;

        if(tr>0)then
          if(outLineR)then
          begin if(abs(abs(tr)-d)>1 )then continue; end
          else  if(d> tr)then continue;

        if(tr<0)then
          if(outLineR)then
          begin if(abs(abs(tr)-d)<=1)then continue; end
          else  if(d<-tr)then continue;

        if (map_IfHereObjectCell(map_gcpx,map_gcpy,startsR,true )=0)
        and(map_IfHereObjectCell(map_gcsx,map_gcsy,startsR,true )=0)
        and(map_IfHereObjectCell(map_gcpx,map_gcpy,-1     ,false)=0)
        and(map_IfHereObjectCell(map_gcsx,map_gcsy,-1     ,false)=0)
        or (value=mgsl_free)then
        begin
           map_grid[ map_gcpx, map_gcpy].tgc_solidlevel:=value;
           if(map_gcsx<>NOTSET)then
           map_grid[map_gcsx,map_gcsy].tgc_solidlevel:=value;
        end;
     end;
   until(not map_GridCycleNext)
end;

procedure map_GridCutCanyonCircles;
var
t,d:integer;
procedure CircleBy2Points(tx0,ty0,tx1,ty1:integer);
begin
   tx0:=tx0 div MapCellW;
   ty0:=ty0 div MapCellW;
   tx1:=tx1 div MapCellW;
   ty1:=ty1 div MapCellW;
   map_GridFillR((tx0+tx1) div 2,
                 (ty0+ty1) div 2,
                 point_dist_int(tx0,ty0,tx1,ty1) div 2,
                 mgsl_free,0,0,true,true);
end;
begin
   if(map_MaxPlayers>0)then
     for t:=0 to map_MaxPlayers-1 do
     begin
        d:=g_random(map_phsize)+map_psize-point_dist_int(map_phsize,map_psize,map_PlayerStartX[t],map_PlayerStartY[t]);
        if(g_random(2)=0)then d:=-d;
        CircleBy2Points(map_PlayerStartX[t],
                        map_PlayerStartY[t],
                        map_phsize+round(d*cos(map_symmetryDir*degtorad)),
                        map_phsize+round(d*sin(map_symmetryDir*degtorad)));
     end;
   CircleBy2Points(0,map_phsize,map_psize,map_phsize);
   CircleBy2Points(map_phsize,
                   map_phsize,
                   map_phsize+round(map_psize*2*cos((map_symmetryDir+90)*degtorad)),
                   map_phsize+round(map_psize*2*sin((map_symmetryDir+90)*degtorad)));
   CircleBy2Points(map_phsize,
                   map_phsize,
                   map_phsize+round(map_psize*2*cos((map_symmetryDir-90)*degtorad)),
                   map_phsize+round(map_psize*2*sin((map_symmetryDir-90)*degtorad)));
end;

procedure map_MakeScirmishGrid;
var msrx,px,py:integer;
begin
   FillChar(map_grid,SizeOf(map_grid),0);

   {
   ffa 8
   own
   2822825217
   4200
   canyon
   \
   }

   msrx:=integer(map_seed);

   case map_type of
mapt_desert : begin
              map_GridFillR(msrx,2, 0,mgsl_liquid ,100,base_1r,false,false);
              map_GridFillR(msrx,1, 0,mgsl_rocks  ,80 ,base_1r,false,false);
              map_GridFillR(msrx,0, 0,mgsl_nobuild,60 ,base_1r,false,false);
              end;
mapt_steppe : begin
              map_GridFillR(msrx,2, 0,mgsl_liquid ,32,base_1r,false,false);
              map_GridFillR(msrx,1, 0,mgsl_rocks  ,24,base_1r,false,false);
              map_GridFillR(msrx,0, 0,mgsl_nobuild,2 ,base_1r,false,false);
              end;
mapt_canyon : begin
              map_GridFillR(msrx,0, 0,mgsl_liquid ,0 ,base_1r,false,false);
              map_GridFillR(msrx,1, 0,mgsl_rocks  ,14,base_1r,true ,false);
              map_GridFillR(msrx,2, 0,mgsl_nobuild,18,base_1r,false,false);
              map_GridCutCanyonCircles;
              end;
mapt_clake,
mapt_ilake  : begin
              map_GridFillR(map_chsize,map_chsize,map_csize div 3,mgsl_liquid ,0 ,base_1r,false,false);
              map_GridFillR(msrx      ,3         ,0              ,mgsl_nobuild,10,base_1r,false,false);
              map_GridFillR(msrx      ,4         ,0              ,mgsl_rocks  ,10,base_1r,false,false);
              end;
mapt_island : begin
              px:=map_chsize div 4;
              py:=map_csize div 4;
              if(map_symmetry=maps_point)then
                map_GridFillR(map_chsize,
                              map_chsize-px+integer(map_seed mod byte(py)),
                             -round(map_csize/abs(2.5+(g_random_i mod 2))),mgsl_liquid ,0,base_1r,false,false)
              else
                map_GridFillR(map_chsize-px+integer(map_seed mod byte(py)),
                              map_chsize-px+integer(g_random_i mod py),
                             -round(map_csize/abs(2.5+(g_random_i mod 2))),mgsl_liquid ,0,base_1r,false,false);
              map_GridFillR(msrx,5, 0,mgsl_nobuild,10,base_1r,false,false);
              map_GridFillR(msrx,6, 0,mgsl_rocks  ,10,base_1r,false,false);
              end;
mapt_shore  : begin
              if(map_symmetry=maps_point)then
              begin
                 px:=map_seed mod byte(map_csize);
                 map_GridFillR(px,(map_chsize-abs(map_chsize-px)) div -8,map_chsize,mgsl_liquid,0 ,base_1r,false,false);
              end
              else map_GridFillR(map_chsize+round(map_csize*10*cos(map_symmetryDir*degtorad)),
                                 map_chsize+round(map_csize*10*sin(map_symmetryDir*degtorad)),map_csize*10,mgsl_liquid ,0,base_1r,false,false);
              map_GridFillR(msrx,7, 0,mgsl_nobuild,10,base_1r,false,false);
              map_GridFillR(msrx,8, 0,mgsl_rocks  ,10,base_1r,false,false);
              map_GridFillR(msrx,1, 0,mgsl_rocks  ,32,base_1r,true ,false);
              end;
mapt_sea    : begin
              map_GridFillR(msrx,9, 0,mgsl_liquid ,0 ,base_1r,false,false);
              map_GridFillR(msrx,0, 0,mgsl_nobuild,7 ,base_1r,false,false);
              map_GridFillR(msrx,1, 0,mgsl_rocks  ,64,base_1r,true ,false);
              end;
   end;
end;

procedure Map_randomseed;
begin
   map_seed:=random($FFFFFFFF)+(SDL_GetTicks shl 5);
end;

procedure Map_randommap;
begin
   Map_randomseed;

   case random(2) of
   0: map_generators:=random(gms_g_maxgens)+1;
   1: map_generators:=0;
   end;
   map_psize   :=MinMapSize+round(random(MaxMapSize-MinMapSize)/StepMapSize)*StepMapSize;
   map_type    :=random(gms_m_types+1);
   map_symmetry:=random(gms_m_symm +1);
end;

procedure map_Make1Scirmish(skipPlayers:boolean=false);
begin
   g_randomFromMapSeed;
   map_psize      := mm3i(MinMapSize,map_psize,MaxMapSize);
   map_phsize     := map_psize div 2;
   map_symmetryDir:= map_GetSymmetryDir;
   map_csize      := map_psize div MapCellW;
   map_chsize     := map_phsize div MapCellW;

   map_FreeCenterR:=0;
   case map_type of
mapt_clake : map_FreeCenterR := map_psize div 3;
   end;

   case map_scenario of
   ms_ffa3   : map_MaxPlayers:=3;
   ms_ffa4   : map_MaxPlayers:=4;
   ms_ffa5   : map_MaxPlayers:=5;
   ms_ffa6   : map_MaxPlayers:=6;
   ms_ffa7   : map_MaxPlayers:=7;
   ms_1x1    : map_MaxPlayers:=2;
   ms_2x2    : map_MaxPlayers:=4;
   ms_2x2x2  : map_MaxPlayers:=6;
   ms_3x3    : map_MaxPlayers:=6;
   ms_4x4    : map_MaxPlayers:=8;
   ms_2x2x2x2: map_MaxPlayers:=8;
   else        map_MaxPlayers:=MaxPlayer;
   end;
   case map_scenario of
   ms_1x1,
   ms_2x2,
   ms_3x3,
   ms_4x4    : map_MaxTeams:=2;
   ms_2x2x2  : map_MaxTeams:=3;
   ms_2x2x2x2: map_MaxTeams:=4;
   else        map_MaxTeams:=map_MaxPlayers;
   end;

   PlayerSlotValidate;

   if(not skipPlayers)then
     map_PlayerStartsScirmish;

   map_KeyPoints;
   map_MakeScirmishGrid;
   {$IFDEF _FULLGAME}
   map_mm_cx   := ui_panel_pwi/map_psize;
   map_mm_CamW := trunc(vid_cam_w*map_mm_cx)+1;
   map_mm_CamH := trunc(vid_cam_h*map_mm_cx)+1;
   map_mm_gridW:= MapCellW*map_mm_cx;

   map_ThemeFromSeed;
   map_MinimapBackground;
   map_RedrawMenuMinimap;

   //gfx_MakeThemeTiles;
   {$ENDIF}
end;

procedure map_Make2;
begin
   map_ZonesMake;
   map_pf_MarkSolidCells;
   map_pf_MakeDomains;
   map_KeyPoints_UpdatePFZone;
   {$IFDEF _FULLGAME}
   gfx_MakeThemeTiles;
   map_VisGridMake;
   uids_RecalcMMR;
   {$ENDIF}
end;

////////////////////////////////////////////////////////////////////////////////
//
//  map settings


function map_SetSetting(PlayerRequestor,setting:byte;newVal:cardinal;Check:boolean):boolean;
begin
   map_SetSetting:=false;

   if(map_preset_cur>0)
   or(PlayerRequestor>LastPlayer)
   or((PlayerLobby  <=LastPlayer)and(PlayerLobby<>PlayerRequestor))
   or(g_Started)
   then exit;

   case setting of
nmid_loby_mapScenario  : if(map_preset_cur=0)then
                         begin
                            if not(NewVal in allmapscenarios)then exit;
                            map_SetSetting:=true;
                            if(Check)then exit;
                            map_scenario:=NewVal;
                         end;
nmid_loby_mapGenerators: begin
                            if(NewVal>gms_g_maxgens)then exit;
                            map_SetSetting:=true;
                            if(Check)then exit;
                            map_generators:=NewVal;
                         end;
nmid_loby_mapSeed      : begin
                            map_SetSetting:=true;
                            if(Check)then exit;
                            map_seed:=newVal;
                         end;
nmid_loby_mapSize      : begin
                            if(newVal<MinMapSize)or(MaxMapSize<newVal)then exit;
                            map_SetSetting:=true;
                            if(Check)then exit;
                            map_psize:=integer(newVal);
                         end;
nmid_loby_mapType      : begin
                            newVal:=byte(newVal);
                            if(gms_m_types<newVal)then exit;
                            map_SetSetting:=true;
                            if(Check)then exit;
                            map_type:=newVal;
                         end;
nmid_loby_mapSymmetry  : begin
                            newVal:=byte(newVal);
                            if(gms_m_symm<newVal)then exit;
                            map_SetSetting:=true;
                            if(Check)then exit;
                            map_symmetry:=newVal;
                         end;
   else exit;
   end;
   map_Make1Scirmish;
end;


