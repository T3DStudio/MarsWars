{$IFDEF _FULLGAME}

procedure map_MakeThemeSprites;
begin
   gfx_MapMakeTerrain;
   gfx_MapMakeCrater;
   gfx_MapMakeLiquid;
   gfx_MapMakeLiquidBack;
end;

procedure map_seed2theme;
begin
   SetTheme(
      map_seed and $0000000F,            // theme number
   -((map_seed and $00000FF0) shr 4 ),   // terrain
   -((map_seed and $000FF000) shr 12),   // liquid
   -((map_seed and $0FF00000) shr 20),   // liquid back
   -((map_seed and $F0000000) shr 28));  // crater
end;

{$ENDIF}

procedure map_RefreshDoodadsCells;
var d,
dx0,dy0,
dx1,dy1,
dx,dy:integer;
begin
   for dx0:=0 to MapObstaclesGridN do
   for dy0:=0 to MapObstaclesGridN do
   with map_ObstaclesGrid[dx0,dy0] do
   begin
      oc_n:=0;
      setlength(oc_l,oc_n);
   end;

   for d:=1 to MaxObstacles do
     with map_ObstaclesL[d] do
     if(o_type>0)then
       begin
          dx0:=(o_x-o_r-MapObstaclesGridW) div MapObstaclesGridW;
          dy0:=(o_y-o_r-MapObstaclesGridW) div MapObstaclesGridW;
          dx1:=(o_x+o_r+MapObstaclesGridW) div MapObstaclesGridW;
          dy1:=(o_y+o_r+MapObstaclesGridW) div MapObstaclesGridW;
          for dx:=dx0 to dx1 do
            if(0<=dx)and(dx<=MapObstaclesGridN)then
              for dy:=dy0 to dy1 do
                if(0<=dy)and(dy<=MapObstaclesGridN)then
                  with map_ObstaclesGrid[dx,dy] do
                  begin
                     oc_n+=1;
                     setlength(oc_l,oc_n);
                     oc_l[oc_n-1]:=@map_ObstaclesL[d];
                  end;
       end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   COMMON
//

function map_IfObstacleZone(zone:word):boolean;
begin
   map_IfObstacleZone:=(zone=zone_solid);
end;

function map_GetZone(mx,my:integer;mr:integer=0):word;
var
i,dx,dy:integer;
begin
   map_GetZone:=zone_solid;

   dx:=mx div MapObstaclesGridW;
   dy:=my div MapObstaclesGridW;

   if(0<=dx)and(dx<=MapObstaclesGridN)and(0<=dy)and(dy<=MapObstaclesGridN)then
    with map_ObstaclesGrid[dx,dy] do
     if(oc_n>0)then
      for i:=0 to oc_n-1 do
       with oc_l[i]^ do
        if(o_r>0)and(o_type>0)then
          if(point_dist_int(mx,my,o_x,o_y)<=o_r)and(mr<=o_r)then exit;

   map_GetZone:=0;
end;

procedure map_Seed2RandomBase;
begin
   g_random_i:= word(map_seed);
   g_random_p:= byte(map_seed);
end;

procedure map_BaseVars;
begin
   map_Seed2RandomBase;

   map_Size    := mm3i(map_MinSize,map_Size,map_MaxSize);
   map_hSize   := map_Size div 2;
   {$IFDEF _FULLGAME}
   map_mmcx    := (ui_CtrlPanelW-2)/map_Size;
   map_mmvw    := trunc(ui_cam_w*map_mmcx)+1;
   map_mmvh    := trunc(ui_cam_h*map_mmcx)+1;
   {$ENDIF}
end;

procedure map_addObstacle(ox,oy:integer;otype:byte);
begin
   if(map_ObstaclesN<0)then map_ObstaclesN:=0;
   if(map_ObstaclesN>=MaxObstacles)then exit;

   case otype of
   DID_LiquidR1,
   DID_LiquidR2,
   DID_LiquidR3,
   DID_LiquidR4,
   DID_Brock,
   DID_Srock,
   DID_Other     : begin
                      map_ObstaclesN+=1;
                      with map_ObstaclesL[map_ObstaclesN] do
                      begin
                         o_type:=otype;
                         o_r   :=DID_R[o_type];
                         o_x   :=ox;
                         o_y   :=oy;
                      end;
                   end;
   else
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   BASE CHECKS
//

function IfInMapRect(tx,ty,sideBorder:integer):boolean;
begin
   IfInMapRect:=(sideBorder<tx)and(tx<(map_size-sideBorder))
             and(sideBorder<ty)and(ty<(map_size-sideBorder));
end;

function map_IfPlayerStartHere(x,y,m:integer;check_symmetry:boolean):boolean;
var p:byte;
begin
   if(m<=0)then
   begin
      map_IfPlayerStartHere:=true;
      exit;
   end;
   if(not IfInMapRect(x,y,-base_1r))then exit;
   map_IfPlayerStartHere:=false;

   if(check_symmetry)then
     if(point_dist_int(x,y,map_Size-x,map_Size-y)<m)then
     begin
        map_IfPlayerStartHere:=true;
        exit;
     end;

   for p:=0 to LastPlayer do
     if(IfInMapRect(map_PlayerStartX[p],map_PlayerStartY[p],-base_1r))then
       if(point_dist_int(x,y,map_PlayerStartX[p],map_PlayerStartY[p])<m)then
       begin
          map_IfPlayerStartHere:=true;
          break;
       end;
end;

function map_IfKeyPointHere(x,y,m:integer;check_symmetry:boolean):boolean;
var p:byte;
begin
   if(m<=0)then
   begin
      map_IfKeyPointHere:=true;
      exit;
   end;
   map_IfKeyPointHere:=false;

   if(check_symmetry)then
     if(point_dist_int(x,y,map_Size-x,map_Size-y)<(m*2))then
     begin
        map_IfKeyPointHere:=true;
        exit;
     end;

   for p:=0 to LastKeyPoint do
     with g_KeyPoints[p] do
       if(kpCaptureR>0)then
         if(point_dist_int(x,y,kpx,kpy)<(m+max2i(kpSolidr,kpCaptureR)))then
         begin
            map_IfKeyPointHere:=true;
            break;
         end;
end;

function map_IfObstacleHere(td:byte;ix,iy:integer):boolean;
var d:integer;
begin
   map_IfObstacleHere:=false;

   with map_ObstaclesL[0] do
     if(map_Symmetry)then
     begin
        o_type:=td;
        o_r:=DID_R[td];
        o_x:=map_Size-ix;
        o_y:=map_Size-iy;
     end
     else
     begin
        o_type:=0;
        o_x:=-32000;
        o_y:=-32000;
     end;

   for d:=0 to map_ObstaclesN do
     with map_ObstaclesL[d] do
       if(o_type>0)then
         if(point_dist_int(o_x,o_y,ix,iy)<(DID_R[o_type]+DID_R[td]+map_ObstaclesGap))then         //_dec_min_r(o_type,td)
         begin
            map_IfObstacleHere:=true;
            break;
         end;
end;

function map_IfSomethingHere(di:byte;ix,iy,doodad_r:integer):boolean;
begin
   map_IfSomethingHere:=false;
   if(map_IfObstacleHere(di,ix,iy))
   or(map_IfPlayerStartHere(ix,iy,doodad_r,false))
   then map_IfSomethingHere:=true
   else
     if(map_Symmetry)then
     begin
        ix:=map_Size-ix;
        iy:=map_Size-iy;
        if(map_IfObstacleHere(di,ix,iy))
        or(map_IfPlayerStartHere(ix,iy,doodad_r,false))then map_IfSomethingHere:=true;
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   KEY POINTS
//

procedure map_KeyPoints_UpdateZone;
var pn:integer;
begin
   for pn:=0 to LastKeyPoint do
     with g_KeyPoints[pn] do
       if(kpCaptureR>0)then kpzone:=map_GetZone(kpx,kpy,kpCaptureR);
end;

procedure map_KeyPoints_Default(acount,aSolidR,aCaptureR,aNoBuildR,aEnergy,aCaptureTime:integer;aLifeTime:cardinal);
const max_attempts = 500;
var
ix,iy,
u,b,
attempts:integer;
function setKeyPoint(px,py:integer):boolean;
var pn:byte;
begin
   setKeyPoint:=false;
   for pn:=0 to LastKeyPoint do
     with g_KeyPoints[pn] do
       if(kpCaptureR<=0)then
       begin
          kpx          :=px;
          kpy          :=py;
          kpToCenterD  :=point_dist_int(kpx,kpy,map_hSize,map_hSize);
          kpSolidr     :=aSolidR;
          kpNoBuildR   :=aNoBuildR;
          kpEnergy     :=aEnergy;
          kpCaptureR   :=aCaptureR;
          kpCaptureTime:=aCaptureTime;
          kplifetime   :=aLifeTime;
          {$IFDEF _FULLGAME}
          kpmmx        :=round(kpx*map_mmcx);
          kpmmy        :=round(kpy*map_mmcx);
          kpmmr        :=round(kpCaptureR*map_mmcx);
          {$ENDIF}
          setKeyPoint:=true;
          break;
       end;
end;
begin
   u:=map_Size div 50;
   b:=map_Size-(u*2);

   while(acount>0)do
   begin
      if(map_Symmetry)
      then acount-=2
      else acount-=1;

      attempts:=0;
      while(attempts<max_attempts)do
      begin
         attempts+=1;
         ix:=u+g_random(b);
         iy:=u+g_random(b);

         if(map_IfPlayerStartHere(ix,iy,base_1rh,map_Symmetry))
         or(map_IfKeyPointHere   (ix,iy,base_1rh,map_Symmetry))then continue;

         if(map_Symmetry)then
           if(map_IfPlayerStartHere(map_Size-ix,map_Size-iy,base_1rh,map_Symmetry))
           or(map_IfKeyPointHere   (map_Size-ix,map_Size-iy,base_1rh,map_Symmetry))then continue;

         if(not setKeyPoint(ix,iy))then exit;
         if(map_Symmetry)then
           setKeyPoint(map_Size-ix,map_Size-iy);
         break;
      end;
   end;
end;

procedure map_KeyPoints;
begin
   KeyPoints_Clear;

   case map_scenario of
mc_KotH   : with g_KeyPoints[0] do
            begin
               kpx:=map_hSize;
               kpy:=map_hSize;
               kpCaptureR   :=base_1r;
               kpCaptureTime:=ptime3*fr_fps1;

               {$IFDEF _FULLGAME}
               kpmmx:=round(kpx*map_mmcx);
               kpmmy:=round(kpy*map_mmcx);
               kpmmr:=round(kpCaptureR*map_mmcx)+1;
               {$ENDIF}
            end;
mc_capture: map_KeyPoints_Default(4,0,gm_cptp_r,base_1r,0,gm_cptp_time,0);
   end;

   if(map_generators>0)then
     map_KeyPoints_Default(MaxKeyPoints-byte(map_scenario=mc_KotH),50,gm_cptp_gr,gm_cptp_gr-25,map_generators_Energy,gm_cptp_gtime,map_generators_LifeTime[map_generators]);
end;

////////////////////////////////////////////////////////////////////////////////
//
//    PLAYER STARTS
//

procedure map_ShuffleStarts(teamShuffle:boolean);
var
x,y:byte;
  i:integer;
begin
   if(map_MaxPlayers>0)then
     for x:=0 to map_MaxPlayers-1 do
     for y:=0 to map_MaxPlayers-1 do
       if(random(2)=0)and(x<>y)then
       begin
          if(teamShuffle)and(map_MaxPlayers>2)and(g_players[x].team<>g_players[y].team)then continue;
          i:=map_PlayerStartX[x];map_PlayerStartX[x]:=map_PlayerStartX[y];map_PlayerStartX[y]:=i;
          i:=map_PlayerStartY[x];map_PlayerStartY[x]:=map_PlayerStartY[y];map_PlayerStartY[y]:=i;
       end;
end;

procedure map_Starts_Circle(cx,cy,sdir,r:integer);   //map_MaxPlayers
var p:byte;
dstep:integer;
begin
   if(map_MaxPlayers=0)then exit;

   dstep:=360 div map_MaxPlayers;
   sdir :=dir_MOD360(sdir);
   for p:=0 to map_MaxPlayers-1 do
   begin
      sdir+=dstep;
      map_PlayerStartX[p]:=cx+trunc(r*cos(sdir*degtorad));
      map_PlayerStartY[p]:=cy+trunc(r*sin(sdir*degtorad));
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

procedure map_Starts_Rect(cx,cy,cr,cdir:integer;pInCenter:byte);
var
adir,
astep: single;
p    : byte;
begin
   if(map_MaxPlayers=0)then exit;

   astep:=360/map_MaxPlayers;
   adir :=dir_MOD360(cdir);
   for p:=0 to map_MaxPlayers-1 do
   begin
      adir+=astep;
      if(p=pInCenter)then continue;
      project2rect(@map_PlayerStartX[p],@map_PlayerStartY[p],adir,cr);
      map_PlayerStartX[p]+=map_hSize;
      map_PlayerStartY[p]+=map_hSize;
   end;
   if(pInCenter>LastPlayer)then exit;
   map_PlayerStartX[pInCenter]:=cx;
   map_PlayerStartY[pInCenter]:=cy;
end;

procedure map_Starts_Default;
const max_attempts = 500;
var
p,ph   : byte;
ix,iy,
attempts,
bb0,bb1,
gap: integer;
begin
   if(map_MaxPlayers=0)then exit;
   ph:=(map_MaxPlayers div 2)+(map_MaxPlayers mod 2);

   bb0:=base_1r+(map_Size-map_MinSize) div 7;
   bb1:=map_Size-(bb0*2);
   gap:=(map_Size div 5)+base_1r;

   for p:=0 to map_MaxPlayers-1 do
   begin
      if(map_Symmetry)and(p>=ph)then break;
      attempts:=0;
      while true do
      begin
         ix:=bb0+g_random(bb1);
         iy:=bb0+g_random(bb1);
         attempts+=1;

         if(attempts>max_attempts)
         or(not map_IfPlayerStartHere(ix,iy,gap,map_Symmetry))then break;
      end;

      map_PlayerStartX[p]:=ix;
      map_PlayerStartY[p]:=iy;
      if(map_Symmetry)then
      begin
         map_PlayerStartX[p+ph]:=map_Size-map_PlayerStartX[p];
         map_PlayerStartY[p+ph]:=map_Size-map_PlayerStartY[p];
      end;
   end;

   for ix:=0 to map_MaxPlayers-1 do
   for iy:=0 to map_MaxPlayers-1 do
     if(ix<>iy)then
       if(point_dist_int(map_PlayerStartX[ix],map_PlayerStartY[ix],
                         map_PlayerStartX[iy],map_PlayerStartY[iy])<base_3r)then
       begin
          map_Starts_Rect(map_hSize,map_hSize,map_size div 3,integer(map_seed mod 360),map_seed mod (MaxPlayers*2));
          exit;
       end;
end;

procedure map_Starts_Teams(cx,cy,cr,cdir,teamN:integer);
var
playerPerTeam,
t,p,player
       : integer;
tdirStep,
pdirStep,
tdir
       : single;
begin
   if(map_MaxPlayers=0)
   or(teamN<=0)then exit;
   playerPerTeam:=map_MaxPlayers div teamN;
   if(playerPerTeam=0)then exit;
   tdirStep:=360/teamN;
   if(tdirStep<1)then tdirStep:=1;
   pdirStep:=tdirStep/(playerPerTeam+2);

   for t:=0 to teamN-1 do
   begin
      tdir:=cdir;
      for p:=0 to playerPerTeam-1 do
      begin
         player:=t*playerPerTeam+p;
         project2rect(@map_PlayerStartX[player],@map_PlayerStartY[player],tdir,cr);
         map_PlayerStartX[player]+=cx;
         map_PlayerStartY[player]+=cy;
         tdir+=pdirStep;
      end;
      cdir+=round(tdirStep);
   end;
end;

procedure map_PlayersStarts;
var
map_dir,i:integer;
begin
   for i:=0 to LastPlayer do
   begin
      map_PlayerStartX[i]:=-5000;
      map_PlayerStartY[i]:=-5000;
   end;
   map_dir:=integer(map_seed mod 360);

   case map_scenario of
mc_1x1,
mc_2x2,
mc_3x3,
mc_4x4    : map_Starts_Teams(map_hSize,map_hSize,map_size div 3,map_dir,2);
mc_2x2x2  : map_Starts_Teams(map_hSize,map_hSize,map_size div 3,map_dir,3);
mc_2x2x2x2: map_Starts_Teams(map_hSize,map_hSize,map_size div 3,map_dir,4);
mc_KotH   : map_Starts_Circle(map_hSize,map_hSize,integer(map_seed),map_hSize-(map_Size div 8));
mc_royale : map_Starts_Circle(map_hSize,map_hSize,integer(map_seed),map_hSize-(map_Size div 5));
   else     map_Starts_Default;
   end;

end;

////////////////////////////////////////////////////////////////////////////////
//
//    GENERATOR
//


function map_TryAddObstacle(di:byte;ix,iy:integer;doodad_r:integer):boolean;
begin
   if(map_IfSomethingHere(di,ix,iy,doodad_r+DID_R[di]))
   then map_TryAddObstacle:=false
   else
   begin
      map_addObstacle(ix,iy,di);
      if(map_Symmetry)then
        map_addObstacle(map_Size-ix,map_Size-iy,di);
      map_TryAddObstacle:=true;
   end;
end;

function map_PickDoodad(ix,iy,lqs,rks:pinteger;doodad_r:integer):boolean;
var di:byte;
begin
   map_PickDoodad:=false;
   for di:=DID_liquidR1 to DID_Other do
     case di of
     DID_LiquidR1,
     DID_LiquidR2,
     DID_LiquidR3,
     DID_LiquidR4  : if(lqs^<=0)
                     then continue
                     else
                       if(map_TryAddObstacle(di,ix^,iy^,doodad_r))then
                       begin
                          map_PickDoodad:=true;
                          lqs^-=1;
                          break;
                       end
                       else continue;
     DID_SRock,
     DID_BRock     : if(rks^<=0)
                     then continue
                     else
                       if(map_TryAddObstacle(di,ix^,iy^,doodad_r))then
                       begin
                          map_PickDoodad:=true;
                          rks^-=1;
                          break;
                       end
                       else continue;
     else
       if(map_TryAddObstacle(di,ix^,iy^,doodad_r))then
       begin
          map_PickDoodad:=true;
          break;
       end
       else continue;
     end;
end;

{function map_FillSea:integer;
var
odd:boolean;
cellw,
cellhw,
ix,iy,cx
     :integer;
begin
   map_FillSea:=0;
   cellhw:=round(did_r[1]/1.27);
   cellw :=cellhw*2;

   cx:=(map_hSize mod cellw);
   if(cx>=cellhw)then cx-=cellw;
   cx:=map_Size-cx;
   odd:=false;

   iy:=map_hSize;

   while(iy>-cellhw)do
   begin
      if(odd)
      then ix:=cx
      else ix:=cx-cellhw;
      odd:=not odd;
      while(ix>-cellhw)do
      begin
         if(not map_IfPlayerStartHere(ix,iy,base_1r+cellw,map_Symmetry))then
         begin
            map_addObstacle(ix,iy,1);
            map_FillSea+=1;
         end;
         if(iy<>0)then
           if(not map_IfPlayerStartHere(map_Size-ix,map_Size-iy,base_1r+cellw,map_Symmetry))then
           begin
              map_addObstacle(map_Size-ix,map_Size-iy,1);
              map_FillSea+=1;
           end;
         ix-=cellw;
      end;

      iy-=cellw;
   end;
end; }

procedure map_make;
const attempts_max = 200;
var
i,ir,
ix,iy,
lqs,
rks,
ddc,
attempts:integer;
begin
   map_ObstaclesN:=0;
   FillChar(map_ObstaclesL,SizeOf(map_ObstaclesL),0);
   for ix:=0 to MapObstaclesGridN do
   for iy:=0 to MapObstaclesGridN do
     with map_ObstaclesGrid[ix,iy] do
     begin
        oc_n:=0;
        setlength(oc_l,oc_n);
     end;

   ddc:=trunc(MaxObstacles*((sqr(map_Size) div ddc_div)/ddc_cf))+1;

   if(map_Symmetry)
   then ddc:=mm3i(1,round(ddc/2),MaxObstacles)
   else ddc:=mm3i(1,      ddc   ,MaxObstacles);

   rks :=0;
   lqs :=0;

   i  :=(ddc div 11);
   ix :=i*map_ObstaclesF;
   lqs:=ix div 4;
   rks:=ix-lqs;

   ir :=base_1r+(map_Size div 100);
   ix :=map_seed;
   iy :=0;

   for i:=1 to ddc do
   begin
      attempts:=0;
      while true do
      begin
         ix:=g_randomx(ix,map_Size);
         iy:=g_randomx(iy,map_Size); //+ix*attempts

         if(map_PickDoodad(@ix,@iy,@lqs,@rks,ir))then break;

         attempts+=1;
         if(attempts>=attempts_max)then break;
      end;
   end;

   map_RefreshDoodadsCells;

   map_Seed2RandomBase;
   map_KeyPoints;
   map_KeyPoints_UpdateZone;
   {$IFDEF _FULLGAME}
   map_DoodadsDrawData;
   map_RedrawMenuMinimap;
   map_MakeDecals;
   {$ENDIF}
end;

procedure Map_RandomSeed;
begin
   map_seed:=random($FFFFFFFF)+(SDL_GetTicks shl 5);
   {$IFDEF _FULLGAME}
   menu_mseed:=c2s(map_seed);
   {$ENDIF}
end;

procedure Map_randommap;
begin
   Map_RandomSeed;

   map_Size     :=map_MinSize+round(random(map_MaxSize-map_MinSize)/map_SizeMenuStep)*map_SizeMenuStep;
   map_ObstaclesF:=random(map_MaxObstacles+1);
   map_Symmetry :=random(2)>0;
end;

procedure Map_premap;
begin                //map_MaxPlayers
   case g_type of
gt_none,
gt_scirmish: begin
             map_BaseVars;

             map_ObstaclesGap:=40;
             case map_scenario of
             mc_ffa3     : map_MaxPlayers:=3;
             mc_ffa4     : map_MaxPlayers:=4;
             mc_ffa5     : map_MaxPlayers:=5;
             mc_ffa6     : map_MaxPlayers:=6;
             mc_ffa7     : map_MaxPlayers:=7;
             mc_1x1      : map_MaxPlayers:=2;
             mc_2x2      : map_MaxPlayers:=4;
             mc_3x3      : map_MaxPlayers:=6;
             mc_4x4      : map_MaxPlayers:=8;
             mc_2x2x2    : map_MaxPlayers:=6;
             mc_2x2x2x2  : map_MaxPlayers:=8;
             else          map_MaxPlayers:=MaxPlayers;
             end;
             GameRemoveAIObservers;

             map_PlayersStarts;
             map_seed2theme;
             end;
{$IFDEF _FULLGAME}
gt_campaing: SetThemeCampaing(cmp_sel);
{$ENDIF}
   end;

   {$IFDEF _FULLGAME}
   map_MakeThemeSprites;
   {$ENDIF}
   map_Make;
end;




