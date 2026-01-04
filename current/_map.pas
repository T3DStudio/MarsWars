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

   map_Size1       := mm3i(map_MinSize,map_Size1,map_MaxSize);
   map_Sizeh       := map_Size1 div 2;
   {$IFDEF _FULLGAME}
   map_MiniMap_cx  := (ui_CtrlPanelW-1)/map_Size1;
   map_MiniMap_CamW:= trunc(ui_cam_w*map_MiniMap_cx)+1;
   map_MiniMap_CamH:= trunc(ui_cam_h*map_MiniMap_cx)+1;
   units_UpdateMiniMapR;
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
   IfInMapRect:=(sideBorder<tx)and(tx<(map_Size1-sideBorder))
             and(sideBorder<ty)and(ty<(map_Size1-sideBorder));
end;

function map_IfPlayerStartHere(x,y,gap:integer):boolean;
var p:byte;
begin
   if(gap<=0)
   then map_IfPlayerStartHere:=true
   else
   begin
      map_IfPlayerStartHere:=false;

      for p:=0 to LastPlayer do
        if(point_dist_int(x,y,map_PlayerStartX[p],map_PlayerStartY[p])<gap)then
        begin
           map_IfPlayerStartHere:=true;
           break;
        end;
   end;
end;

function map_IfKeyPointHere(x,y,gap:integer):boolean;
var p:byte;
begin
   if(gap<=0)then
   begin
      map_IfKeyPointHere:=true;
      exit;
   end;
   map_IfKeyPointHere:=false;

   if(map_symmetry)then
     if(point_dist_int(x,y,map_Size1-x,map_Size1-y)<(gap*2))then
     begin
        map_IfKeyPointHere:=true;
        exit;
     end;

   for p:=0 to LastKeyPoint do
     with map_KeyPointsL[p] do
       if(kpCaptureR>0)then
         if(point_dist_int(x,y,kpx,kpy)<(gap+kpCaptureR))then
         begin
            map_IfKeyPointHere:=true;
            break;
         end;
end;

function map_IfObstacleHere(did:byte;ix,iy:integer):boolean;
var d:integer;
begin
   map_IfObstacleHere:=false;

   with map_ObstaclesL[0] do
     if(map_symmetry)then
     begin
        o_type:=did;
        o_r   :=DID_R[did];
        o_x   :=map_Size1-ix;
        o_y   :=map_Size1-iy;
     end
     else
     begin
        o_type:=0;
        o_x   :=o_x.MinValue;
        o_y   :=o_y.MinValue;
     end;

   for d:=0 to map_ObstaclesN do
     with map_ObstaclesL[d] do
       if(o_type>0)then
         if(point_dist_int(o_x,o_y,ix,iy)<(DID_R[o_type]+DID_R[did]+map_ObstaclesGap))then
         begin
            map_IfObstacleHere:=true;
            break;
         end;

   with map_ObstaclesL[0] do
   begin
      o_type:=0;
      o_x   :=o_x.MinValue;
      o_y   :=o_y.MinValue;
   end;
end;

function map_IfSomethingHere(did:byte;ix,iy,doodad_r:integer):boolean;
begin
   map_IfSomethingHere:=(map_IfObstacleHere(did,ix,iy))
                      or(map_IfPlayerStartHere(ix,iy,doodad_r));

end;

////////////////////////////////////////////////////////////////////////////////
//
//   KEY POINTS
//

procedure map_KeyPoints_UpdateZone;
var pn:integer;
begin
   for pn:=0 to LastKeyPoint do
     with map_KeyPointsL[pn] do
       if(kpCaptureR>0)then kpzone:=map_GetZone(kpx,kpy,kpCaptureR);
end;

function map_KeyPoints_Add(akpx,akpy,aCaptureR,aNoBuildR,aEnergy,aCaptureTime:integer;aLifeTime:cardinal):boolean;
var kp:integer;
begin
   map_KeyPoints_Add:=false;
   for kp:=0 to LastKeyPoint do
     with map_KeyPointsL[kp] do
       if(kpCaptureR<=0)then
       begin
          kpx          :=akpx;
          kpy          :=akpy;
          kpToCenterD  :=point_dist_int(kpx,kpy,map_Sizeh,map_Sizeh);
          kpNoBuildR   :=aNoBuildR;
          kpEnergy     :=aEnergy;
          kpCaptureR   :=aCaptureR;
          kpCaptureTime:=aCaptureTime;
          kplifetime   :=aLifeTime;
          {$IFDEF _FULLGAME}
          kpmmx        :=round(kpx*map_MiniMap_cx);
          kpmmy        :=round(kpy*map_MiniMap_cx);
          kpmmr        :=round(kpCaptureR*map_MiniMap_cx);
          {$ENDIF}
          map_KeyPoints_Add:=true;
          map_KeyPointsN+=1;
          break;
       end;
end;

procedure map_KeyPoints_Random(acount,aCaptureR,aNoBuildR,aEnergy,aCaptureTime:integer;aLifeTime:cardinal);
const max_attempts = 500;
var
ix,iy,
u,b,
attempts:integer;
begin
   u:=map_Size1 div 50;
   b:=map_Size1-(u*2);

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

         if(map_IfPlayerStartHere(ix,iy,base_1rh))
         or(map_IfKeyPointHere   (ix,iy,base_1rh))then continue;

         if(not map_KeyPoints_Add(ix,iy,aCaptureR,aNoBuildR,Aenergy,aCaptureTime,aLifeTime))then exit;
         if(map_Symmetry)then
           if(not map_KeyPoints_Add(map_Size1-ix,map_Size1-iy,aCaptureR,aNoBuildR,Aenergy,aCaptureTime,aLifeTime))then exit;
         break;
      end;
   end;
end;

procedure map_KeyPoints_AddAtStarts(aCaptureR,aNoBuildR,aEnergy,aCaptureTime:integer;aLifeTime:cardinal);
var   p:byte;
r,sx,sy:integer;
begin
   r:=round((aCaptureR+g_uids[uid_race_start_fbase[r_uac]].uid_r)/1.74);
   for p:=0 to LastPlayer do
     if(p<map_MaxPlayers)then
     begin
        sx:=sign(map_Sizeh-map_PlayerStartX[p]);
        sy:=sign(map_Sizeh-map_PlayerStartY[p]);
        if(sx=0)and(sy=0)then
        begin
           sx:=1;
           sy:=1;
        end;
        map_KeyPoints_Add(map_PlayerStartX[p]+r*sx,
                          map_PlayerStartY[p]+r*sy,aCaptureR,aNoBuildR,Aenergy,aCaptureTime,aLifeTime);
     end;
end;

procedure map_KeyPoints_Create;
begin
   KeyPoints_Clear;

   case map_scenario of
mc_KotH     : map_KeyPoints_Add(map_Sizeh,map_Sizeh,base_1r,0,0,keyPoint_CaptTime_KotH,0);
mc_KeyPoints: map_KeyPoints_Random(4,keyPoint_r,base_1r,0,keyPoint_CaptTime_Def,0);
   end;

   if(map_generators>0)then
   begin
      map_KeyPoints_AddAtStarts(keyPoint_GenR,keyPoint_GenR-25,map_generators_Energy,keyPoint_CaptTime_Gen,map_generators_LifeTime[map_generators]);
      map_KeyPoints_Random(MaxKeyPoints-byte(map_scenario=mc_KotH),keyPoint_GenR,keyPoint_GenR-25,map_generators_Energy,keyPoint_CaptTime_Gen,map_generators_LifeTime[map_generators]);
   end;
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
          if(teamShuffle)and(map_MaxPlayers>2)and(g_gplayers[x].team<>g_gplayers[y].team)then continue;
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

procedure map_Starts_Rect(cx,cy,cr,cdir:integer);
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
      project2rect(@map_PlayerStartX[p],@map_PlayerStartY[p],adir,cr);
      map_PlayerStartX[p]+=map_Sizeh;
      map_PlayerStartY[p]+=map_Sizeh;
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

procedure map_Starts_Random(freeZoneR:integer);
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

   bb0:=freeZoneR+(map_Size1-map_MinSize) div 7;
   bb1:=map_Size1-(bb0*2);
   gap:=(map_Size1 div 5)+freeZoneR;

   for p:=0 to map_MaxPlayers-1 do
   begin
      if(map_Symmetry)and(p>=ph)then break;
      attempts:=0;
      while true do
      begin
         ix:=bb0+g_random(bb1);
         iy:=bb0+g_random(bb1);
         attempts+=1;

         if(attempts>max_attempts)then break;

         if(map_Symmetry)then
           if(point_dist_int(ix,iy,map_Size1-ix,map_Size1-iy)<gap)then continue;

         if(not map_IfPlayerStartHere(ix,iy,gap))then break;
      end;

      map_PlayerStartX[p]:=ix;
      map_PlayerStartY[p]:=iy;
      if(map_Symmetry)then
      begin
         map_PlayerStartX[p+ph]:=map_Size1-map_PlayerStartX[p];
         map_PlayerStartY[p+ph]:=map_Size1-map_PlayerStartY[p];
      end;
   end;

   for ix:=0 to map_MaxPlayers-1 do
   for iy:=0 to map_MaxPlayers-1 do
     if(ix<>iy)then
       if(point_dist_int(map_PlayerStartX[ix],map_PlayerStartY[ix],
                         map_PlayerStartX[iy],map_PlayerStartY[iy])<base_3r)then
       begin
          map_Starts_Rect(map_Sizeh,map_Sizeh,map_Size1 div 3,integer(map_seed mod 360));
          exit;
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
   mc_4x4    : map_Starts_Teams (map_Sizeh,map_Sizeh,map_Size1 div 3,map_dir,2);
   mc_2x2x2  : map_Starts_Teams (map_Sizeh,map_Sizeh,map_Size1 div 3,map_dir,3);
   mc_2x2x2x2: map_Starts_Teams (map_Sizeh,map_Sizeh,map_Size1 div 3,map_dir,4);
   mc_KotH   : map_Starts_Circle(map_Sizeh,map_Sizeh,integer(map_seed),map_Sizeh-(map_Size1 div 8));
   mc_royale : map_Starts_Circle(map_Sizeh,map_Sizeh,integer(map_seed),map_Sizeh-(map_Size1 div 5));
   else        map_Starts_Random(base_1r);
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    GENERATOR
//


function map_TryAddObstacle(di:byte;ix,iy:integer;obstacleGapR:integer):boolean;
begin
   map_TryAddObstacle:=false;
   if (map_ObstaclesGap<(ix-DID_R[di]))and((ix+DID_R[di])<(map_Size1-map_ObstaclesGap))
   and(map_ObstaclesGap<(iy-DID_R[di]))and((iy+DID_R[di])<(map_Size1-map_ObstaclesGap))then
     if(not map_IfSomethingHere(di,ix,iy,obstacleGapR+DID_R[di]))then
     begin
        map_addObstacle(ix,iy,di);
        if(map_symmetry)then
          map_addObstacle(map_Size1-ix,map_Size1-iy,di);
        map_TryAddObstacle:=true;
     end;
end;

function map_PickAndAddObstacle(ix,iy:integer;n_liquids,n_rocks:pinteger;obstacleGapR:integer):boolean;
var di:byte;
begin
   map_PickAndAddObstacle:=false;
   for di:=DID_liquidR1 to DID_Other do
     case di of
     DID_LiquidR1,
     DID_LiquidR2,
     DID_LiquidR3,
     DID_LiquidR4: if(n_liquids^<=0)
                   then continue
                   else
                     if(map_TryAddObstacle(di,ix,iy,obstacleGapR))then
                     begin
                        map_PickAndAddObstacle:=true;
                        n_liquids^-=1;
                        break;
                     end
                     else continue;
     DID_SRock,
     DID_BRock   : if(n_rocks^<=0)
                   then continue
                   else
                     if(map_TryAddObstacle(di,ix,iy,obstacleGapR))then
                     begin
                        map_PickAndAddObstacle:=true;
                        n_rocks^-=1;
                        break;
                     end
                     else continue;
     else
       if(map_TryAddObstacle(di,ix,iy,obstacleGapR))then
       begin
          map_PickAndAddObstacle:=true;
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

procedure map_Obstacles_Create;
const attempts_max = 200;
var
i,ir,
ix,iy,
n_liquids,
n_rocks,
n_obstacles,
attempts:integer;
begin
   // clear
   map_ObstaclesN:=0;
   FillChar(map_ObstaclesL,SizeOf(map_ObstaclesL),0);
   for ix:=0 to MapObstaclesGridN do
   for iy:=0 to MapObstaclesGridN do
     with map_ObstaclesGrid[ix,iy] do
     begin
        oc_n:=0;
        setlength(oc_l,oc_n);
     end;

   // create
   n_obstacles:=trunc(MaxObstacles*((sqr(map_Size1) div ddc_div)/ddc_cf))+1;

   n_obstacles:=mm3i(4,n_obstacles,MaxObstacles);

   if(map_Symmetry)then
     n_obstacles:=n_obstacles div 2;

   n_rocks  :=0;
   n_liquids:=0;

   i  :=(n_obstacles div (map_MaxObstacles+2));
   ix :=i*map_ObstaclesF;
   n_liquids:=ix div 4;
   n_rocks  :=ix-n_liquids;

   ir :=base_1r+(map_Size1 div 100);
   ix :=map_seed;
   iy :=0;

   while(n_obstacles>0)do
   begin
      n_obstacles-=1;
      attempts:=0;
      while true do
      begin
         ix:=g_randomx(ix,map_Size1);
         iy:=g_randomx(iy,map_Size1);

         if(map_PickAndAddObstacle(ix,iy,@n_liquids,@n_rocks,ir))then break;

         attempts+=1;
         if(attempts>=attempts_max)then break;
      end;
   end;

   map_RefreshDoodadsCells;
end;

procedure map_CreateObjects;
begin
   map_Seed2RandomBase;
   map_Obstacles_Create;
   map_KeyPoints_Create;
   map_KeyPoints_UpdateZone;
   {$IFDEF _FULLGAME}
   map_DoodadsSetDrawData;
   map_Decals_Create;
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

   map_Size1     :=map_MinSize+round(random(map_MaxSize-map_MinSize)/map_SizeMenuStep)*map_SizeMenuStep;
   map_ObstaclesF:=random(map_MaxObstacles+1);
   map_Symmetry :=random(2)>0;
end;

procedure Map_Make;
begin
   {$IFDEF _FULLGAME}
   case g_type of //map_MaxPlayers
gt_none,
gt_scirmish: begin
   {$ENDIF}
             map_BaseVars;

             map_ObstaclesGap:=40;
             case map_scenario of
             mc_ffa3   : map_MaxPlayers:=3;
             mc_ffa4   : map_MaxPlayers:=4;
             mc_ffa5   : map_MaxPlayers:=5;
             mc_ffa6   : map_MaxPlayers:=6;
             mc_ffa7   : map_MaxPlayers:=7;
             mc_1x1    : map_MaxPlayers:=2;
             mc_2x2    : map_MaxPlayers:=4;
             mc_3x3    : map_MaxPlayers:=6;
             mc_4x4    : map_MaxPlayers:=8;
             mc_2x2x2  : map_MaxPlayers:=6;
             mc_2x2x2x2: map_MaxPlayers:=8;
             else        map_MaxPlayers:=MaxPlayers;
             end;
             GameRemoveAIObservers;

             map_PlayersStarts;
             {$IFDEF _FULLGAME}
             map_seed2theme;
             end;
gt_campaing: SetThemeCampaign(camp_sel,camp_mis_sel);
   end;

   map_MakeThemeSprites;
   {$ENDIF}
   map_CreateObjects;
   {$IFDEF _FULLGAME}
    map_RedrawMenuMinimap;
   {$ENDIF}
end;




