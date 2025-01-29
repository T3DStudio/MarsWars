
////////////////////////////////////////////////////////////////////////////////
//
//  COMMON

function map_InGridRange(a:integer):boolean;
begin
   map_InGridRange:=(0<=a)and(a<=map_LastCell); //MaxMapSizeCelln
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
liquid,
teleport: integer;
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
   theme_cur_tile_teleport_id:=-1;

   // theme
   mseed  :=map_seed;
   theme  :=Pick(theme_n);
   SetTheme(theme);

   terrain :=Pick(theme_cur_terrain_n );
   crater  :=Pick(theme_cur_crater_n  );
   liquid  :=Pick(theme_cur_liquid_n  );
   teleport:=Pick(theme_cur_teleport_n);

   if(terrain >=0)then theme_cur_tile_terrain_id :=theme_cur_terrain_l [terrain ];
   if(crater  >=0)then theme_cur_tile_crater_id  :=theme_cur_crater_l  [crater  ];
   if(liquid  >=0)then theme_cur_tile_liquid_id  :=theme_cur_liquid_l  [liquid  ];
   if(teleport>=0)then theme_cur_tile_teleport_id:=theme_cur_teleport_l[teleport];

   SetThemeTES;
end;

procedure map_VisGridMake;
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
         tgca_decorS    :=@theme_all_decor_l[tgca_decorN];
         tgca_decorA    :=@theme_anm_decors [tgca_decorN];
         tgca_decorDepth:=depth+my+ay;
         tgca_decorTime :=DoodadAnimationTime(tgca_decorA^.tda_atime);
         tgca_decorX    :=mx+ax;
         tgca_decorY    :=my+ay;
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
         tgca_decalX:=random(max2i(0,MapCellW-tgca_decalS^.w));
         tgca_decalY:=random(max2i(0,MapCellW-tgca_decalS^.h));
      end;
   end;
end;
procedure AddDecals;
begin
   with map_grid_graph[x,y] do
   if(tgca_decor_n>=0)and(theme_cur_decal_n>0)then
   begin
      i:=abs((x+1)*(y+1)+tgca_decal_n) mod 10;
      if(i=0)then
        //while(i>=0)do
        //begin
           SetDecal(theme_cur_decal_l[abs((x+1)*(y+1)+i) mod theme_cur_decal_n]);
           //i-=1;
        //end;
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
                      ddir:=((i*tGridDecorD)+(x*135)+(y*69))*degtorad;
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
               then map_GetSymmetryDir:=DIR360(map_GetSymmetryDir+180);
            end;
   else
            map_GetSymmetryDir:=(DIR360(map_seed) div 45)*45;
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
   if (0<=cx)and(cx<=map_LastCell)
   and(0<=cy)and(cy<=map_LastCell)
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
   or(x>map_LastCell)
   or(y>map_LastCell)then exit;

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
   map_gridZone_n:=0;
   for x:=0 to MaxMapSizeCelln-1 do
   for y:=0 to MaxMapSizeCelln-1 do
     with map_grid[x,y] do
       tgc_pf_zone:=0;

   for x:=0 to map_LastCell do
   for y:=0 to map_LastCell do
     with map_grid[x,y] do
       if(map_ZoneFillPart(x,y,0,true))then
       begin
          map_gridZone_n+=1;
          map_ZoneFillPart(x,y,map_gridZone_n,false);
       end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  PATH FIND DATA

procedure map_pf_MarkSolidCells;
var x,y:integer;
function SolidLevel(cx,cy:integer):boolean;
begin
   if (0<=cx)and(cx<=map_LastCell)
   and(0<=cy)and(cy<=map_LastCell)
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
   for x:=0 to map_LastCell do
   for y:=0 to map_LastCell do
     with map_grid[x,y] do
       if(SolidLevel(x,y))then
         tgc_pf_solid:= not(CheckNoSolidAround(x-1,y-1,x+1,y+1)
                         or CheckNoSolidAround(x-2,y-2,x+1,y+1)
                         or CheckNoSolidAround(x-1,y-2,x+2,y+1)
                         or CheckNoSolidAround(x-2,y-1,x+1,y+2)
                         or CheckNoSolidAround(x-1,y-1,x+2,y+2));
   {
    #      ##
           ##
   }
end;

procedure debug_cell(cx,cy,cw:integer;color:cardinal);
begin
   cx:=cx*MapCellw+cw;
   cy:=cy*MapCellw+cw;
   cw*=2;
   UnitsInfoAddRect(cx,cy,cx+MapCellw-cw,cy+MapCellw-cw,color);
end;

function map_GridLineCollision(x0,y0,x1,y1:integer;domainCheck:word):boolean;
var
dx,dy,
px,py,
sx,sy:integer;
e1,e2:longint;
function map_GetPFSolid(cx,cy:integer):boolean;
begin
   map_GetPFSolid:=true;
   if (0<=cx)and(cx<=map_LastCell)
   and(0<=cy)and(cy<=map_LastCell)then
     with map_grid[cx,cy] do
       if(domainCheck>0)and(tgc_pf_domain>0)
       then map_GetPFSolid:=tgc_pf_solid or (domainCheck<>tgc_pf_domain)
       else map_GetPFSolid:=tgc_pf_solid;
end;
begin
   if(map_GetPFSolid(x1,y1))then
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
      if(map_GetPFSolid(x0,y0))then
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
        if  map_GetPFSolid(px,y0)
        and map_GetPFSolid(x0,py) then
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
         nextDomain:=0;
      end;

   map_gridDomain_n:=0;
   setlength(map_gridDomainMX,0,0);
end;

procedure map_pf_DomainsFill;
var
x,y         :integer;
domain2count: array of word;
domain2point,
tmp_points_l: array of TPoint;
tmp_points_n,dn,
tmp_points_i: word;
function FillDomain(cx,cy:integer):boolean;
var i:word;
begin
   FillDomain:=false;

   if(cx<0)
   or(cy<0)
   or(cx>map_LastCell)
   or(cy>map_LastCell)then exit;

   with map_grid[cx,cy] do
   begin
      if(tgc_solidlevel>=mgsl_liquid)
      or(tgc_pf_domain>0)
      or(tgc_pf_domain=map_gridDomain_n)
      or(tgc_pf_solid)then exit;

      if(tmp_points_n>0)then
        for i:=0 to tmp_points_n-1 do
          with tmp_points_l[i] do
           if (map_GridLineCollision(cx,cy,p_x,p_y,map_gridDomain_n)
           and map_GridLineCollision(p_x,p_y,cx,cy,map_gridDomain_n))then exit;

      FillDomain:=true;

      tgc_pf_domain:=map_gridDomain_n;
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
procedure AddCount(px,py:integer);
begin
   domain2count[map_gridDomain_n-1]+=1;
   with domain2point[map_gridDomain_n-1] do
   begin
      p_x:=px;
      p_y:=py;
   end;
end;
begin
   tmp_points_i:=0;
   tmp_points_n:=0;
   setlength(tmp_points_l,0);

   if(map_gridDomain_n=65535)then exit;

   map_gridDomain_n+=1;
   if(not FillDomain(sx,sy))then
   begin
      map_gridDomain_n-=1;
      exit;
   end;

   setlength(domain2point,map_gridDomain_n);
   setlength(domain2count,map_gridDomain_n);
   domain2count[map_gridDomain_n-1]:=0;
   AddCount(sx,sy);

   while(tmp_points_i<tmp_points_n)do
   begin
      with tmp_points_l[tmp_points_i] do
      begin
         if(FillDomain(p_x-1,p_y))then AddCount(p_x-1,p_y);
         if(FillDomain(p_x+1,p_y))then AddCount(p_x+1,p_y);
         if(FillDomain(p_x,p_y-1))then AddCount(p_x,p_y-1);
         if(FillDomain(p_x,p_y+1))then AddCount(p_x,p_y+1);
      end;
      tmp_points_i+=1;
   end;
end;
procedure CheckDomainNeighbor(cx,cy:integer);
var d:word;
begin
   if(cx<0)
   or(cy<0)
   or(cx>map_LastCell)
   or(cy>map_LastCell)then exit;

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
end;

begin
   setlength(domain2point,0);
   setlength(domain2count,0);

   for x:=0 to LastPlayer do
     StartFillDomain(map_PlayerStartX[x] div MapCellw,map_PlayerStartY[x] div MapCellw);

   for x:=0 to map_LastCell do
   for y:=0 to map_LastCell do
     StartFillDomain(x,y);

   if(map_gridDomain_n>0)then
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
       end;

   writeln('map_gridDomain_n ',map_gridDomain_n);
   setlength(tmp_points_l,0);
   setlength(domain2point,0);
   setlength(domain2count,0);
end;

procedure map_pf_DomainEdges;
var
d1,d2:word;
x ,y :integer;
function GetDomain(cx,cy:integer):word;
begin
   GetDomain:=GetDomain.MaxValue;
   if (0<=cx)and(cx<=map_LastCell)
   and(0<=cy)and(cy<=map_LastCell)then
    with map_grid[cx,cy] do
     if(tgc_pf_domain>0)
     then GetDomain:=tgc_pf_domain-1;
end;
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

   for x:=0 to map_LastCell do
   for y:=0 to map_LastCell do
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

procedure map_pf_MakeNext;
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
   or(cx>map_LastCell)
   or(cy>map_LastCell)then exit;

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

procedure map_pf_MakeDomains;
var time:cardinal;
d1,d2,w:word;
begin
   // clear domains
   time:=sdl_GetTicks;
   map_pf_DomainsClear;
   writeln('Domains: clear ',sdl_GetTicks-time);

   // make domains
   time:=sdl_GetTicks;
   map_pf_DomainsFill;
   writeln('Domains: make ',sdl_GetTicks-time);

   if(map_gridDomain_n=0)then exit;

   // make domain edgeds
   time:=sdl_GetTicks;
   map_pf_DomainEdges;
   writeln('Domains: edges ',sdl_GetTicks-time);

   // make 'next' domain
   time:=sdl_GetTicks;
   map_pf_MakeNext;
   writeln('Domains: next ',sdl_GetTicks-time);

   // make edges cx to mx
   for d1:=0 to map_gridDomain_n-1 do
   for d2:=0 to map_gridDomain_n-1 do
     with map_gridDomainMX[d1,d2] do
       if(edgeCells_n>0)then
         for w:=0 to edgeCells_n-1 do
           with edgeCells_l[w] do
           begin
              p_x:=(p_x*MapCellW)+MapCellhW;
              p_y:=(p_y*MapCellW)+MapCellhW;
           end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  CHECKS

function map_InMapRange(x,y,aborder:integer):boolean;
begin
   if(x=NOTSET)or(y=NOTSET)
   then map_InMapRange:=true
   else map_InMapRange:=(-aborder<=x)and(x<=(map_size+aborder))
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
true : for p:=0 to LastPlayer do
       begin
          mgcell2NearestXY(map_PlayerStartX[p],map_PlayerStartY[p],x0,y0,x0+MapCellW,y0+MapCellW,0,@mx,@my,nil);
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
            mgcell2NearestXY(cpx,cpy,x0,y0,x0+MapCellW,y0+MapCellW,0,@mx,@my,nil);
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

   for p:=0 to LastPlayer do
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
     if(cpCaptureR>0)then cpZone:=map_MapGetZone(cpx,cpy);
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
         basex:=x2CellCenter(u+g_random(b));
         basey:=x2CellCenter(u+g_random(b));
         SymmetryXY(basex,basey,map_size,@symx,@symy,map_symmetry);

         c+=1;
         if(c>500)then dst-=1;

         if map_InMapRange(symx,symy,0)then
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

////////////////////////////////////////////////////////////////////////////////
//
//  PLAYER STARTS

procedure map_ShufflePlayerStarts(teamShuffle:boolean);
var
x,y:byte;
i  :integer;
begin
   for x:=0 to LastPlayer do
    for y:=0 to LastPlayer do
     if(random(2)=0)and(x<>y)then
     begin
        if(teamShuffle)and(g_players[x].team<>g_players[y].team)then continue;
        i:=map_PlayerStartX[x];map_PlayerStartX[x]:=map_PlayerStartX[y];map_PlayerStartX[y]:=i;
        i:=map_PlayerStartY[x];map_PlayerStartY[x]:=map_PlayerStartY[y];map_PlayerStartY[y]:=i;
     end;
end;

procedure map_PlayerStartsCircle(r,sdir,pcount:integer);
const dstep = 360 div MaxPlayer;
var i:byte;
begin
   if(pcount<=0)then exit;
   sdir:=abs(sdir mod 360)+(dstep div 2);
   for i:=0 to pcount-1 do
   begin
      sdir+=dstep;
      map_PlayerStartX[i       ]:=map_hsize+round(r*cos(sdir*degtorad));
      map_PlayerStartY[i       ]:=map_hsize+round(r*sin(sdir*degtorad));
      map_PlayerStartX[i+pcount]:=map_size-map_PlayerStartX[i];
      map_PlayerStartY[i+pcount]:=map_size-map_PlayerStartY[i];
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

   for i:=0 to LastPlayer do
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

         if(map_InMapRange(symx,symy,-bb0))then
           if(c>1000)
           or (not map_IfPlayerStartHere(basex,basey,symx,symy,r)
           and(point_dist_int(basex,basey,map_hsize,map_hsize)>FreeCenterR)
           and(point_dist_int(symx ,symy ,map_hsize,map_hsize)>FreeCenterR))then break;
      end;

      map_PlayerStartX[i]:=basex;
      map_PlayerStartY[i]:=basey;
      if(map_symmetry>0)then
      begin
         map_PlayerStartX[i+4]:=symx;
         map_PlayerStartY[i+4]:=symy;
      end;
   end;

   dst-=dst div 5;
   c:=0;
   for i:=0 to LastPlayer do
   for r:=0 to LastPlayer do
    if(i<>r)then
      if(point_dist_int(map_PlayerStartX[i],map_PlayerStartY[i],map_PlayerStartX[r],map_PlayerStartY[r])<dst)then c+=1;
   if(c>0)then map_PlayerStartsCircle(map_hsize-(map_size div 8),map_symmetryDir,4);
end;

procedure map_DefaultPlayerStarts;
var ix,iy,i,u,c:integer;
begin
   for i:=0 to LastPlayer do
   begin
      map_PlayerStartX[i]:=0;
      map_PlayerStartY[i]:=0;
   end;

   case g_mode of
gm_4x4     :begin
               c :=map_hsize-(map_size div 7);
               u :=c+base_1r;
               i :=map_symmetryDir+90;

               {case map_type of
               mapt_clake  : ix:=round(45*(MinMapSize/map_size))+round(3*(map_size/MinMapSize));
               mapt_shore  : ix:=round(45*(MinMapSize/map_size))+round(5*(map_size/MinMapSize));
               else          ix:=round(50*(MinMapSize/map_size));
               end;}
               ix:=round(45*(MinMapSize/map_size))+round(3*(map_size/MinMapSize));
               iy:=ix div 2;

               map_PlayerStartX[0]:=round(map_hsize+cos((i-iy*3)*degtorad)*u);
               map_PlayerStartY[0]:=round(map_hsize+sin((i-iy*3)*degtorad)*u);
               map_PlayerStartX[1]:=round(map_hsize+cos((i-iy  )*degtorad)*c);
               map_PlayerStartY[1]:=round(map_hsize+sin((i-iy  )*degtorad)*c);
               map_PlayerStartX[2]:=round(map_hsize+cos((i+iy  )*degtorad)*c);
               map_PlayerStartY[2]:=round(map_hsize+sin((i+iy  )*degtorad)*c);
               map_PlayerStartX[3]:=round(map_hsize+cos((i+iy*3)*degtorad)*u);
               map_PlayerStartY[3]:=round(map_hsize+sin((i+iy*3)*degtorad)*u);

               map_PlayerStartX[4]:=map_size-map_PlayerStartX[0];
               map_PlayerStartY[4]:=map_size-map_PlayerStartY[0];
               map_PlayerStartX[5]:=map_size-map_PlayerStartX[1];
               map_PlayerStartY[5]:=map_size-map_PlayerStartY[1];
               map_PlayerStartX[6]:=map_size-map_PlayerStartX[2];
               map_PlayerStartY[6]:=map_size-map_PlayerStartY[2];
               map_PlayerStartX[7]:=map_size-map_PlayerStartX[3];
               map_PlayerStartY[7]:=map_size-map_PlayerStartY[3];

            end;
gm_2x2x2x2 :begin
               iy:=base_2r+(map_size div 30);
               u :=map_hsize-(map_hsize div 3);
               c :=map_symmetryDir;

               ix:=round(50*(MinMapSize/map_size));
               iy:=ix div 2;
               i:=0;
               while(i<LastPlayer)do
               begin
               map_PlayerStartX[i  ]:=round(map_hsize+cos((c-iy)*degtorad)*u);
               map_PlayerStartY[i  ]:=round(map_hsize+sin((c-iy)*degtorad)*u);
               map_PlayerStartX[i+1]:=round(map_hsize+cos((c+iy)*degtorad)*u);
               map_PlayerStartY[i+1]:=round(map_hsize+sin((c+iy)*degtorad)*u);
               c+=90;
               i+=2;
               end;
            end;
gm_assault :begin
               map_PlayerStartsCircle(map_hsize-(map_size div 8),map_symmetryDir,3);
               map_PlayerStartX[6]:=map_hsize-base_1r;
               map_PlayerStartY[6]:=map_hsize-base_1r;
               map_PlayerStartX[7]:=map_hsize+base_1r;
               map_PlayerStartY[7]:=map_hsize+base_1r;
            end;
gm_KotH    :begin
               map_PlayerStartsCircle(map_hsize-(map_size div 8),map_symmetryDir,4);
            end;
gm_royale  :begin
               map_PlayerStartsCircle(map_hsize-(map_size div 5),map_symmetryDir,4);
            end;
gm_capture :begin
               map_PlayerStartsDefault(byte(map_type=mapt_clake)*(map_size div 3));
            end;
   else
               map_PlayerStartsDefault(byte(map_type=mapt_clake)*(map_size div 3));
   end;

   for i:=0 to LastPlayer do
   begin
      map_PlayerStartX[i]:=x2CellCenter(map_PlayerStartX[i]);
      map_PlayerStartY[i]:=x2CellCenter(map_PlayerStartY[i]);
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  GRID CYCLE

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
maps_none : map_GridCycleNext:=Step(@map_gcx,@map_gcy,@map_gcsx,@map_gcsy,map_LastCell        ,map_LastCell  );
maps_lineV: map_GridCycleNext:=Step(@map_gcx,@map_gcy,@map_gcsx,@map_gcsy,map_CenterCell      ,map_LastCell  );
maps_point,
maps_lineH: map_GridCycleNext:=Step(@map_gcx,@map_gcy,@map_gcsx,@map_gcsy,map_LastCell        ,map_CenterCell);
maps_lineL: map_GridCycleNext:=Step(@map_gcx,@map_gcy,@map_gcsx,@map_gcsy,map_gcy             ,map_LastCell  );
maps_lineR: map_GridCycleNext:=Step(@map_gcx,@map_gcy,@map_gcsx,@map_gcsy,map_LastCell-map_gcy,map_LastCell  );
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  MAP GENERATOR BASE

procedure map_GridFill(tx,ty,tr:integer;value,skipFactor:byte;startsR:integer;replace,outLineR:boolean);
var d:integer;
begin
   map_GridCycleInit;

   d:=NOTSET;
   repeat
     if(map_grid[map_gcx,map_gcy].tgc_solidlevel=mgsl_free)or(replace)or(outLineR)then
     begin
        if(tr<>0)or(outLineR)then d:=point_dist_int(tx,ty,map_gcx,map_gcy);

        if(skipFactor>0)then
          if(random_table[byte(byte(map_gcx+1)*byte(map_gcy+map_gcx+1)+byte(tx+ty+tr))] mod skipFactor)>0 then continue;

        if(tr>0)then
          if(outLineR)then
          begin if(abs(abs(tr)-d)>1 )then continue; end
          else  if(d> tr)then continue;

        if(tr<0)then
          if(outLineR)then
          begin if(abs(abs(tr)-d)<=1)then continue; end
          else  if(d<-tr)then continue;

        if (map_IfHereObjectCell(map_gcx,map_gcy,startsR,true )<>1)
        and(map_IfHereObjectCell(map_gcx,map_gcy,-1     ,false) =0)
        or (value=mgsl_free)then
        begin
           map_grid[ map_gcx, map_gcy].tgc_solidlevel:=value;
           if(map_gcsx<>NOTSET)then
           map_grid[map_gcsx,map_gcsy].tgc_solidlevel:=value;
        end;
     end;
   until(not map_GridCycleNext)
end;

procedure map_GridCutCanyonCircles;
var
tx,ty,d:integer;
procedure CircleBy2Points(tx0,ty0,tx1,ty1:integer);
begin
   tx0:=tx0 div MapCellW;
   ty0:=ty0 div MapCellW;
   tx1:=tx1 div MapCellW;
   ty1:=ty1 div MapCellW;
   map_GridFill((tx0+tx1) div 2,
                (ty0+ty1) div 2,
                point_dist_int(tx0,ty0,tx1,ty1) div 2,
                mgsl_free,0,0,true,true);
end;
begin
   CircleBy2Points(0         ,map_hsize,map_size          ,map_hsize);// center
   for tx:=0 to LastPlayer do
   begin
      d:=point_dist_int(map_PlayerStartX[tx],map_PlayerStartY[tx],map_hsize,map_hsize);
      if(d<=0)then continue;
      CircleBy2Points(map_PlayerStartX[tx],map_PlayerStartY[tx],
      map_hsize+round((map_PlayerStartX[tx]-map_hsize)/d*map_size),
      map_hsize+round((map_PlayerStartY[tx]-map_hsize)/d*map_size) );
   end;
   for tx:=0 to LastPlayer do
    for ty:=0 to tx do
     if(tx<>ty)and(abs(tx-ty)<2)then
      CircleBy2Points(map_PlayerStartX[tx],map_PlayerStartY[tx],
                      map_PlayerStartX[ty],map_PlayerStartY[ty]);
end;

procedure map_RandomBaseVars;
begin
   g_random_i:= word(map_seed);
   g_random_p:= byte(map_seed);
end;

procedure map_Vars;
begin
   map_RandomBaseVars;
   map_size        := mm3i(MinMapSize,map_size,MaxMapSize);
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

procedure map_MakeDeafultGrid;
var msrx,px,py:integer;
begin
   FillChar(map_grid,SizeOf(map_grid),0);

   msrx:=integer(map_seed);

   case map_type of
mapt_steppe : begin
              map_GridFill(msrx,0, 0,mgsl_nobuild, 7,base_1r,false,false);
              map_GridFill(msrx,1, 0,mgsl_rocks  ,24,base_1r,false,false);
              map_GridFill(msrx,2, 0,mgsl_liquid ,32,base_1r,false,false);
              end;
mapt_canyon : begin
              map_GridFill(msrx,0, 0,mgsl_liquid ,0 ,base_1r,false,false);
              map_GridFill(msrx,1, 0,mgsl_rocks  ,14,base_1r,true ,false);
              map_GridFill(msrx,2, 0,mgsl_nobuild,18,base_1r,false,false);
              map_GridCutCanyonCircles;
              end;
mapt_clake,
mapt_ilake  : begin
              map_GridFill(map_CenterCell,map_CenterCell,(map_LastCell div 3),mgsl_liquid ,0,base_1r,false,false);
              map_GridFill(msrx,3, 0,mgsl_nobuild,18,base_1r,false,false);
              map_GridFill(msrx,4, 0,mgsl_rocks  ,18,base_1r,false,false);
              end;
mapt_island : begin
              px:=map_CenterCell div 4;
              py:=map_LastCell div 4;
              if(map_symmetry=maps_point)then
                map_GridFill(map_CenterCell,
                             map_CenterCell-px+integer(map_seed mod byte(py)),
                             -round(map_LastCell/abs(2.5+(g_random_i mod 2))),mgsl_liquid ,0,base_1r,false,false)
              else
                map_GridFill(map_CenterCell-px+integer(map_seed mod byte(py)),
                             map_CenterCell-px+integer(g_random_i mod py),
                             -round(map_LastCell/abs(2.5+(g_random_i mod 2))),mgsl_liquid ,0,base_1r,false,false);
              map_GridFill(msrx,5, 0,mgsl_nobuild,18,base_1r,false,false);
              map_GridFill(msrx,6, 0,mgsl_rocks  ,18,base_1r,false,false);
              end;
mapt_shore  : begin
              if(map_symmetry=maps_point)then
              begin
                 px:=map_seed mod byte(map_LastCell);
                 map_GridFill(px,(map_CenterCell-abs(map_CenterCell-px)) div -8,map_CenterCell,mgsl_liquid,0 ,base_1r,false,false);
              end
              else map_GridFill(map_CenterCell+round(map_LastCell*10*cos(map_symmetryDir*degtorad)),
                                map_CenterCell+round(map_LastCell*10*sin(map_symmetryDir*degtorad)),map_LastCell*10,mgsl_liquid ,0,base_1r,false,false);
              map_GridFill(msrx,7, 0,mgsl_nobuild,16,base_1r,false,false);
              map_GridFill(msrx,8, 0,mgsl_rocks  ,16,base_1r,false,false);
              map_GridFill(msrx,1, 0,mgsl_rocks  ,64,base_1r,true ,false);
              end;
mapt_sea    : begin
              map_GridFill(msrx,9, 0,mgsl_liquid ,0 ,base_1r,false,false);
              map_GridFill(msrx,0, 0,mgsl_nobuild,7 ,base_1r,false,false);
              map_GridFill(msrx,1, 0,mgsl_rocks  ,64,base_1r,true ,false);
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

   map_size    :=MinMapSize+round(random(MaxMapSize-MinMapSize)/StepMapSize)*StepMapSize;
   map_type    :=random(gms_m_types+1);
   map_symmetry:=random(gms_m_symm +1);
end;

procedure map_Make1;
begin
   map_Vars;
   map_DefaultPlayerStarts;
   map_CPoints;
   map_MakeDeafultGrid;
   {$IFDEF _FULLGAME}
   map_ThemeFromSeed;
   map_MinimapBackground;
   map_RedrawMenuMinimap;
   {$ENDIF}
end;

procedure map_Make2;
begin
   map_ZonesMake;
   map_pf_MarkSolidCells;
   map_pf_MakeDomains;
   map_CPoints_UpdatePFZone;
   {$IFDEF _FULLGAME}
   gfx_MakeThemeTiles;
   map_VisGridMake;
   {$ENDIF}
end;

////////////////////////////////////////////////////////////////////////////////
//
//  map settings


function map_SetSetting(PlayerRequestor,setting:byte;newVal:cardinal;Check:boolean):boolean;
begin
   map_SetSetting:=false;

   if(g_preset_cur>0)
   or(PlayerRequestor>LastPlayer)
   or((PlayerLobby  <=LastPlayer)and(PlayerLobby<>PlayerRequestor))
   or(G_Started)
   then exit;

   case setting of
nmid_lobbby_mapseed  : begin
                          map_SetSetting:=true;
                          if(Check)then exit;
                          map_seed:=newVal;
                          map_Make1;
                       end;
nmid_lobbby_mapsize  : begin
                          if(newVal<MinMapSize)or(MaxMapSize<newVal)then exit;
                          map_SetSetting:=true;
                          if(Check)then exit;
                          map_size:=integer(newVal);
                          map_Make1;
                       end;
nmid_lobbby_type     : begin
                          newVal:=byte(newVal);
                          if(gms_m_types<newVal)then exit;
                          map_SetSetting:=true;
                          if(Check)then exit;
                          map_type:=newVal;
                          map_Make1;
                       end;
nmid_lobbby_symmetry : begin
                          newVal:=byte(newVal);
                          if(gms_m_symm<newVal)then exit;
                          map_SetSetting:=true;
                          if(Check)then exit;
                          map_symmetry:=newVal;
                          map_Make1;
                       end;
   end;
end;


