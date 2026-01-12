{$IFDEF _FULLGAME}

procedure map_MakeThemeSprites;
begin
   gfx_MapMakeTerrain;
   gfx_MapMakeCrater;
   gfx_MapMakeLiquidFront;
   gfx_MapMakeLiquidBack;
   gfx_MapMakeRBattleFront;
end;

procedure map_seed2theme;
begin
   SetTheme(
      map_seed and $0000000F,            // theme number
   -((map_seed and $00000FF0) shr 4 ),   // terrain
   -((map_seed and $000FF000) shr 12),   // liquid front
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
       if(o_rO>0)then
       begin
          dx0:=(o_x-o_rO) div MapObstaclesGridW;
          dy0:=(o_y-o_rO) div MapObstaclesGridW;
          dx1:=(o_x+o_rO) div MapObstaclesGridW;
          dy1:=(o_y+o_rO) div MapObstaclesGridW;
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

function map_ObstacleR(obs_f:byte):integer;
begin
   map_ObstacleR:=ObstaclesRMin;
   case obs_f of
   0  : ;
   1  : map_ObstacleR+=ObstaclesRStep;
   2  : map_ObstacleR+=ObstaclesRStep*2;
   else map_ObstacleR+=integer(obs_f*obs_f*ObstaclesRStep)
   end;
end;

function map_IfObstacleZone(zone:word):boolean;
begin
   map_IfObstacleZone:=(zone=zone_solid);
end;

function map_GetZone(mx,my:integer;mr:integer=0):word;
var
i    :word;
d,orm,
dx,dy:integer;
begin
   map_GetZone:=0;

   dx:=mx div MapObstaclesGridW;
   dy:=my div MapObstaclesGridW;
   orm:=orm.MaxValue;

   if(0<=dx)and(dx<=MapObstaclesGridN)and(0<=dy)and(dy<=MapObstaclesGridN)then
     with map_ObstaclesGrid[dx,dy] do
       if(oc_n>0)then
         for i:=0 to oc_n-1 do
           with oc_l[i]^ do
             if(o_rO>0)and(mr<=o_rO)then
             begin
                d:=point_dist_int(mx,my,o_x,o_y);
                if(d>o_rO)then continue;
                if(o_rI<d)and(d<o_rO)then
                begin
                   map_GetZone:=zone_solid;
                   exit;
                end;

                if(o_rO>=orm)then continue;
                orm:=o_rO;
                map_GetZone:=o_zone;
             end;
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

procedure map_Obstacle_Add(ox,oy,orO,orI:integer);
begin
   if(map_ObstaclesN<0)then map_ObstaclesN:=0;
   if(map_ObstaclesN>=MaxObstacles)then exit;

   map_ObstaclesN+=1;
   with map_ObstaclesL[map_ObstaclesN] do
   begin
      o_rO  :=orO;
      o_rI  :=orI;
      o_rM  :=(orO+orI) div 2;
      o_x   :=ox;
      o_y   :=oy;
      o_zone:=word(map_ObstaclesN);
   end;

   {case otype of
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
   end; }
end;

////////////////////////////////////////////////////////////////////////////////
//
//   BASE CHECKS
//

{function IfInMapRect(tx,ty,sideBorder:integer):boolean;
begin
   IfInMapRect:=(sideBorder<tx)and(tx<(map_Size1-sideBorder))
             and(sideBorder<ty)and(ty<(map_Size1-sideBorder));
end; }

function map_IfPlayerStartHere(x,y,rO,rI,pStartR:integer):boolean;
var p:byte;
begin
   map_IfPlayerStartHere:=false;

   for p:=0 to LastPlayer do
     if(RingCollision(map_PlayerStartX[p],map_PlayerStartY[p],pStartR,0,x,y,rO,rI))then
     begin
        map_IfPlayerStartHere:=true;
        break;
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
     with kp_TeamData[MaxPlayers] do
       if(kptd_Active)then
         if(point_dist_int(x,y,kp_x,kp_y)<(gap+kp_RCapture))then
         begin
            map_IfKeyPointHere:=true;
            break;
         end;
end;

function map_IfObstacleHere(ix,iy,irO,irI:integer):boolean;
var d:integer;
procedure Clear0;
begin
   with map_ObstaclesL[0] do
   begin
      o_rO:=0;
      o_rI:=0;
      o_x :=o_x.MinValue;
      o_y :=o_y.MinValue;
   end;
end;
begin
   map_IfObstacleHere:=false;

   with map_ObstaclesL[0] do
     if(map_symmetry)then
     begin
        o_rO:=irO;
        o_rI:=irI;
        o_x :=map_Size1-ix;
        o_y :=map_Size1-iy;
     end
     else Clear0;

   for d:=0 to map_ObstaclesN do
     with map_ObstaclesL[d] do
       if(o_rO>0)then
         if(RingCollision(ix,iy,irO,irI,o_x,o_y,o_rO,o_rI))then
         begin
            map_IfObstacleHere:=true;
            break;
         end;

   Clear0;
end;

function map_PointInObsN(x,y:integer):boolean;
var d:integer;
begin
   map_PointInObsN:=false;
   for d:=0 to map_ObstaclesN do
     with map_ObstaclesL[d] do
       if(o_rO>0)then
         if(point_dist_int(x,y,o_x,o_y)<o_rO)then
         begin
            map_PointInObsN:=true;
            break;
         end;
end;

function map_IfObsObsStartHere(x,y,rO,rI,pStartR:integer):boolean;
begin
   map_IfObsObsStartHere:=(map_IfObstacleHere   (x,y,rO,rI))
                        or(map_IfPlayerStartHere(x,y,rO,rI,pStartR));
   if(map_symmetry)and(not map_IfObsObsStartHere)then
   map_IfObsObsStartHere:=(map_IfPlayerStartHere(map_size1-x,map_size1-y,rO,rI,pStartR));
end;

////////////////////////////////////////////////////////////////////////////////
//
//   KEY POINTS
//

procedure map_KeyPoints_UpdateZone;
var kpi:byte;
begin
   for kpi:=0 to LastKeyPoint do
     with map_KeyPointsL[kpi] do
       kp_Zone:=map_GetZone(kp_x,kp_y,kp_RCapture);
end;

procedure map_KeyPoints_UpdateTeamData;
var
kpi,t:byte;
pkptv:PTKeyPointTeamData;
begin
   for kpi:=0 to LastKeyPoint do
     with map_KeyPointsL[kpi] do
     begin
        pkptv:=@kp_TeamData[MaxPlayers];
        for t:=0 to LastPlayer do
          with kp_TeamData[t] do
          begin
             kptd_Active          :=pkptv^.kptd_Active;
             kptd_TimerOwnerTeam  :=pkptv^.kptd_TimerOwnerTeam;
             kptd_TimerOwnerPlayer:=pkptv^.kptd_TimerOwnerPlayer;
             kptd_OwnerPlayer     :=pkptv^.kptd_OwnerPlayer;
             kptd_OwnerTeam       :=pkptv^.kptd_OwnerTeam;
             kptd_Timer           :=pkptv^.kptd_Timer;
             kptd_lifeTime        :=pkptv^.kptd_lifeTime;
          end;
     end;
end;

function map_KeyPoints_Add(akpx,akpy,aCaptureR,aNoBuildR,aEnergy,aCaptureTime:integer;aLifeTime:cardinal):boolean;
var kp:integer;
begin
   map_KeyPoints_Add:=false;
   for kp:=0 to LastKeyPoint do
     with map_KeyPointsL  [kp] do
     {$IFDEF _FULLGAME}
     with map_KeyPointsVis[kp] do
     {$ENDIF}
       with kp_TeamData[MaxPlayers] do
       if(not kptd_Active)then
       begin
          kp_x          :=akpx;
          kp_y          :=akpy;
          kp_ToCenterD  :=point_dist_int(kp_x,kp_y,map_Sizeh,map_Sizeh);
          kp_RNoBuild   :=aNoBuildR;
          kp_Energy     :=aEnergy;
          kp_RCapture   :=aCaptureR;
          kp_CaptureTime:=aCaptureTime;
          kptd_Active   :=true;
          kptd_lifeTime :=aLifeTime;
          {$IFDEF _FULLGAME}
          kpmmx         :=round(map_MiniMap_cx*kp_x);
          kpmmy         :=round(map_MiniMap_cx*kp_y);
          kpmmr         :=round(map_MiniMap_cx*kp_RCapture);
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

         if(map_IfPlayerStartHere(ix,iy,base_1rh,0,map_PStartsGap))
         or(map_IfKeyPointHere   (ix,iy,base_1rh  ))then continue;

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

   map_KeyPoints_UpdateZone;
   map_KeyPoints_UpdateTeamData;
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
      map_PlayerStartX[p]+=cx;
      map_PlayerStartY[p]+=cy;
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

         if(not map_IfPlayerStartHere(ix,iy,gap,0,gap))then break;
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

procedure map_Obstacles_Create;
const attempts_max = 3;
var
n_obstacles,
obs_f,
irO,
ix,iy,
edgeDist,
attempts:integer;
function TryAddObstacle:boolean;
var irI:integer;
begin
   TryAddObstacle:=false;
   attempts:=attempts_max;
   while(attempts>0)do
   begin
      attempts-=1;
      ix:=g_randomx(ix,map_Size1);
      iy:=g_randomx(iy,map_Size1);
      edgeDist:=min2i(min2i(ix-irO,map_size1-(ix+irO)),min2i(iy-irO,map_size1-(iy+irO)));
      if(0<=edgeDist)and(edgeDist<=map_ObstaclesGap)then continue;
      irI:=0;
      if((map_ObstaclesN mod 2)=0)then
        if(not map_PointInObsN(ix,iy))then
          if(irO>=base_2r)then irI:=irO-min2i(base_2r,irO div 4);
      if(map_IfObsObsStartHere(ix,iy,irO+map_ObstaclesGap,irI,map_PStartsGap))then continue;
      map_Obstacle_Add(ix,iy,irO,irI);
      if(map_symmetry)then
        map_Obstacle_Add(map_size1-ix,map_size1-iy,irO,irI);
      TryAddObstacle:=true;
      break;
   end;
end;

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

   n_obstacles:=trunc(MaxObstacles*map_Size1/map_MaxSize);

   ix :=integer(map_seed);
   iy :=0;

   while(n_obstacles>0)do
   begin
      n_obstacles-=1;
      obs_f:=map_ObstaclesS;
      irO  :=map_ObstacleR(obs_f);

      while(obs_f>=0)do
      begin
         irO:=map_ObstacleR(obs_f);
         if(TryAddObstacle)
         then break
         else obs_f-=1;
      end;
   end;

   map_RefreshDoodadsCells;
end;

procedure map_CreateObjects;
begin
   map_Seed2RandomBase;
   map_Obstacles_Create;
   map_KeyPoints_Create;
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
   map_ObstaclesS:=random(map_MaxObstacles+1);
   map_Symmetry  :=random(2)>0;
end;

procedure Map_SetScenarioMaxPlayers;
begin
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
end;

procedure Map_Make;
begin
   {$IFDEF _FULLGAME}
   case g_type of
gt_none,
gt_scirmish: begin
   {$ENDIF}
             map_BaseVars;

             map_ObstaclesGap:=50;
             map_PStartsGap  := base_1r;
             Map_SetScenarioMaxPlayers;
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




