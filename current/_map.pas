{$IFDEF _FULLGAME}

procedure map_seed2theme;
var
theme,
terrain,
crater,
liquid :integer;
mseed  :cardinal;
function Pick(n:integer):integer;
begin
   if(n<=0)
   then Pick:=-1
   else
   begin
      Pick :=mseed mod cardinal(n);
      mseed:=mseed div cardinal(n);
   end;
end;
begin
   mseed  :=map_seed;

   theme  :=Pick(theme_n);

   SetTheme(theme);

   terrain:=Pick(theme_cur_terrain_n);
   crater :=Pick(theme_cur_crater_n );
   liquid :=Pick(theme_cur_liquid_n );
   SetTerrainIDs(-terrain,-crater,-liquid);
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
               maps_lineH: map_GetSymmetryDir:=0;
               maps_lineL: map_GetSymmetryDir:=45;
               maps_lineR: map_GetSymmetryDir:=135;
               end;
               if((map_seed mod 2)=0)
               then map_GetSymmetryDir:=_DIR360(map_GetSymmetryDir+180);
            end;
   else
            map_GetSymmetryDir:=integer(map_seed mod 360);
   end;
end;

procedure map_Vars;
begin
   map_size        := mm3i(MinMapSize,map_size,MaxMapDize);
   map_RandomBaseVars;
   map_BuildBorder1:= map_size-map_BuildBorder0;
   map_hsize       := map_size div 2;
   map_symmetryDir := map_GetSymmetryDir;
   map_LastCell    := map_size div MapCellW;
   map_CenterCell  := map_hsize div MapCellW;

   {$IFDEF _FULLGAME}
   map_mm_cx  := (vid_panelw-2)/map_size;
   map_mm_CamW:= trunc(vid_cam_w*map_mm_cx)+1;
   map_mm_CamH:= trunc(vid_cam_h*map_mm_cx)+1;
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

function map_PlayerStartsHereCell(cx,cy:byte;baser:integer):byte;
var p:byte;
x0,y0,
mx,my:integer;
begin
   map_PlayerStartsHereCell:=0;
   if(cx<=map_LastCell)and(cy<=map_LastCell)then
   begin
      x0:=cx*MapCellW;
      y0:=cy*MapCellW;
      for p:=0 to MaxPlayers do
      begin
         mgcell2NearestXY(cx,cy,x0,y0,x0+MapCellW,y0+MapCellW,@mx,@my);
         if(point_dist_int(mx,my,map_PlayerStartX[p],map_PlayerStartY[p])<=baser)
         then map_PlayerStartsHereCell+=1;
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
               mapt_lake  : ix:=round(60*(MinMapSize/map_size))+round(3*(map_size/MinMapSize));
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
               map_PlayerStartsDefault(byte(map_type=mapt_lake)*(map_size div 3));
            end;
   else
               map_PlayerStartsDefault(byte(map_type=mapt_lake)*(map_size div 3));
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

procedure map_Fill(tx,ty,tr:integer;value,skipFactor:byte;startsR:integer);
var x,y,sx,sy:integer;
procedure SetCell;
begin
   if(map_grid[x,y].tgc_solidlevel=mgsl_free)then
   begin
      if(skipFactor>0)then
        if(random_table[byte(byte(x+1+ty)*byte(y+x+1+tx+tr))] mod skipFactor)>0 then exit;

      if(tr>0)then
        if(point_dist_int(tx,ty,x,y)>tr)then exit;

      if (map_PlayerStartsHereCell(x,y,startsR)<>1)then
      begin
         map_grid[ x, y].tgc_solidlevel:=value;
         if(sx<>NOTSET)then
         map_grid[sx,sy].tgc_solidlevel:=value;
      end;
   end;
end;
begin
   sx:=NOTSET;
   sy:=NOTSET;
   case map_symmetry of
maps_none : for y:=0 to map_LastCell   do
            for x:=0 to map_LastCell   do
            SetCell;
maps_point,
maps_lineV: for x:=0 to map_CenterCell do
            for y:=0 to map_LastCell   do
            begin
            SymmetryXY(x,y,map_LastCell,@sx,@sy,map_symmetry);
            SetCell;
            end;
maps_lineH: for x:=0 to map_LastCell   do
            for y:=0 to map_CenterCell do
            begin
            SymmetryXY(x,y,map_LastCell,@sx,@sy,map_symmetry);
            SetCell;
            end;
maps_lineL: for y:=0 to map_LastCell   do
            for x:=0 to y              do
            begin
            SymmetryXY(x,y,map_LastCell,@sx,@sy,map_symmetry);
            SetCell;
            end;
maps_lineR: for y:=0 to map_LastCell   do
            for x:=0 to map_LastCell-y do
            begin
            SymmetryXY(x,y,map_LastCell,@sx,@sy,map_symmetry);
            SetCell;
            end;
   end;
end;

procedure map_ReMake;
begin
   FillChar(map_grid,SizeOf(map_grid),0);

   case map_type of
mapt_steppe : map_Fill(0,0,-1,mgsl_nobuild,7,base_1r);
mapt_cave   : begin
              map_Fill(0,0,-1,mgsl_rocks  ,5,base_1r);
              map_Fill(0,0,-1,mgsl_nobuild,7,base_1r);
              end;
mapt_lake   : begin
              map_Fill(map_CenterCell,map_CenterCell,map_LastCell div 3,mgsl_liquid ,0,base_1r);
              map_Fill(0,0,-1,mgsl_nobuild,7,base_1r);
              end;
mapt_shore  : begin
              //+ point симметрия = фигня
              map_Fill(map_CenterCell+round(map_LastCell*cos(map_symmetryDir*degtorad)),
                       map_CenterCell+round(map_LastCell*sin(map_symmetryDir*degtorad)),map_LastCell,mgsl_liquid ,0,base_1r);
              end;
mapt_sea    : begin
              map_Fill(0,0,-1,mgsl_liquid ,0,base_1r);
              map_Fill(0,0,-1,mgsl_nobuild,7,base_1r);
              end;
   end;

   {map_ddn:=0;
   FillChar(map_dds,SizeOf(map_dds),0);
   for ix:=0 to dcn do
   for iy:=0 to dcn do
   with map_dcell[ix,iy] do
   begin
      n:=0;
      setlength(l,n);
   end;

   map_ddn:=trunc(MaxDoodads*((sqr(map_size) div ddc_div)/ddc_cf))+1;

   if(map_symmetry>0)
   then map_ddn:=mm3i(1,round(map_ddn/1.5),MaxDoodads)
   else map_ddn:=mm3i(1,      map_ddn     ,MaxDoodads);

   case map_type of
mapt_steppe: begin
             map_DoodadNoise(0,0,0);
             end;
mapt_cave  : begin
             map_DoodadNoise(2,2,50);
             end;
mapt_lake  : begin
             ix:=round(map_size/2.9);
             map_DoodadFiledCircle(DID_LiquidR1,map_hsize,map_hsize,ix,map_symmetry);
             if(map_size<=3500)then
             begin
             //map_DoodadFiledCircle(DID_LiquidR2,map_hsize,map_hsize,ix,map_symmetry);
             map_DoodadFiledCircle(DID_LiquidR3,map_hsize,map_hsize,ix,map_symmetry);
             //map_DoodadFiledCircle(DID_LiquidR4,map_hsize,map_hsize,ix,map_symmetry);
             end;

             map_ddn:=map_ddn div 3;
             map_DoodadNoise(0,0,50);
             end;
mapt_shore: begin
             ix:=map_size*2;
             if(map_symmetry=1)
             then symmetry:=0
             else symmetry:=map_symmetry;

             map_DoodadFiledCircle(DID_LiquidR1,map_symmetryX1,map_symmetryY1,ix,symmetry);
             if(map_size<=3500)then
             begin
             //map_DoodadFiledCircle(DID_LiquidR2,map_symmetryX1,map_symmetryY1,ix,symmetry);
             map_DoodadFiledCircle(DID_LiquidR3,map_symmetryX1,map_symmetryY1,ix,symmetry);
            // map_DoodadFiledCircle(DID_LiquidR4,map_symmetryX1,map_symmetryY1,ix,symmetry);
             end;

             map_ddn:=map_ddn div 2;
             map_DoodadNoise(1,2,50);
             end;
mapt_sea   : begin
             ix:=map_size;
             map_DoodadFiledCircle(DID_LiquidR1,map_hsize,map_hsize,ix,map_symmetry);
             if(map_size<=3500)then
             begin
             //map_DoodadFiledCircle(DID_LiquidR2,map_hsize,map_hsize,ix,map_symmetry);
             map_DoodadFiledCircle(DID_LiquidR3,map_hsize,map_hsize,ix,map_symmetry);
             //map_DoodadFiledCircle(DID_LiquidR4,map_hsize,map_hsize,ix,map_symmetry);
             end;
             map_ddn:=map_ddn div 6;
             map_DoodadNoise(0,1,-50);
             end;
   end;

   map_RefreshDoodadsCells;  }
   map_RandomBaseVars;
   map_CPoints;
   pf_MakeZoneGrid;
   map_CPoints_UpdatePFZone;
   {$IFDEF _FULLGAME}
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

   map_size    :=MinMapSize+round(random(MaxMapDize-MinMapSize)/StepMapSize)*StepMapSize;
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
                          if(newVal<MinMapSize)or(MaxMapDize<newVal)then exit;
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


