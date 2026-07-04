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

procedure map_RefreshObstaclesGrid;
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

procedure project2rect(tarx,tary:pinteger;dir:single;rw:integer);
var
sn,cs:single;
rs   :integer;
begin
   cs:= cos(dir*degtorad);
   sn:=-sin(dir*degtorad);
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

procedure map_SymmetryPoints(startx,starty:integer;resultx,resulty:pinteger);
begin
   case map_Symmetry of
   maps_point: begin
                  resultx^:=map_size1-startx;
                  resulty^:=map_size1-starty;
               end;
   maps_lineV: begin
                  resultx^:=map_size1-startx;
                  resulty^:=starty;
               end;
   maps_lineH: begin
                  resultx^:=startx;
                  resulty^:=map_size1-starty;
               end;
   maps_lineL: begin
                  resultx^:=starty;
                  resulty^:=startx;
               end;
   maps_lineR: begin
                  resultx^:=map_size1-starty;
                  resulty^:=map_size1-startx;
               end;
   else
                  resultx^:=NOTSET;
                  resulty^:=NOTSET;
   end;
end;

procedure map_SymmetryPoints2(startx,starty,resultx,resulty:pinteger;gapR:integer);
begin
   map_symmetryPoints(startx^,starty^,resultx,resulty);
   if(resultx^<>NOTSET)then
     if(point_dist_int(startx^,starty^,resultx^,resulty^)<gapR)then
     begin
        startx^ :=(startx^+resultx^)div 2;
        starty^ :=(starty^+resulty^)div 2;
        resultx^:=NOTSET;
        resulty^:=NOTSET;
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

procedure map_DataForAI;
var d:integer;
begin
   map_NeedTransport:=false;
   for d:=1 to MaxObstacles do
     with map_ObstaclesL[d] do
       if(o_rO>0)and(o_rI>0)then
       begin
          map_NeedTransport:=true;
          exit;
       end;

   map_BusyCenter:=map_IfObstacleZone(map_GetZone(map_SizeH,map_SizeH));
end;

function map_ObstacleR(obs_f:byte):integer;
begin
   map_ObstacleR:=ObstaclesRMin;
   case obs_f of
   0  : ;
   1  : map_ObstacleR+=ObstaclesRStep;
   2  : map_ObstacleR+=ObstaclesRStep*2;
   else map_ObstacleR+=integer(obs_f*obs_f*ObstaclesRStep)
   end;
   if(map_ObstacleR>map_Sizeh)then map_ObstacleR:=map_Sizeh;
end;



procedure map_Seed2RandomBase;
begin
   g_random_i:= word(map_seed);
   g_random_p:= byte(map_seed);
end;

procedure map_BaseVars(setRandom:boolean=true);
begin
   if(setRandom)then
     map_Seed2RandomBase;

   map_Size1   := mm3i(map_MinSize,map_Size1,map_MaxSize);
   map_Sizeh   := map_Size1 div 2;
   map_SizeKPCR:= map_Sizeh-(map_Sizeh div 3);
   g_royal_Rmax:= round(map_SizeH*1.41);
   case map_symmetry of
   maps_lineV: if((map_seed mod 2)=0)
               then map_SymmetryDir:=90
               else map_SymmetryDir:=270;
   maps_lineH: if((map_seed mod 2)=0)
               then map_SymmetryDir:=0
               else map_SymmetryDir:=180;
   maps_lineL: if((map_seed mod 2)=0)
               then map_SymmetryDir:=135
               else map_SymmetryDir:=315;
   maps_lineR: if((map_seed mod 2)=0)
               then map_SymmetryDir:=45
               else map_SymmetryDir:=225;
   else             map_SymmetryDir:= integer(map_seed mod 360);
   end;

   {$IFDEF _FULLGAME}
   map_MiniMap_cx  := (ui_CtrlPanelW-1)/map_Size1;
   map_MiniMap_CamW:= trunc(ui_cam_w*map_MiniMap_cx)+1;
   map_MiniMap_CamH:= trunc(ui_cam_h*map_MiniMap_cx)+1;
   map_fog_ex      := map_size1 div fog_cw;
   map_fog_ey      := map_size1 div fog_cw;
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
      if(orI<0)then orI+=orO;
      if(orI<0)then orI:=0;
      if(abs(orO-orI)<ObstacleMinInnerR)then orI:=orO-ObstacleMinInnerR;
      o_rO  :=orO;
      o_rI  :=orI;
      o_rM  :=(orO+orI) div 2;
      o_x   :=ox;
      o_y   :=oy;
      o_zone:=word(map_ObstaclesN);
   end;
end;

procedure map_Obstacle_Remove(ox,oy,orO,orI:integer);
var o:integer;
begin
   for o:=0 to MaxObstacles do
     with map_ObstaclesL[o]  do
       if(o_rO>0)then
         if(RingCollision(ox,oy,orO,orI,o_x,o_y,o_rO,o_rI))then
         begin
            o_x :=0;
            o_y :=0;
            o_rO:=0;
            o_rI:=0;
         end;
end;

procedure map_CalcLakeR(ro,ri:pinteger);
var t0,t1:integer;
begin
   t0:=round(map_size1/3  );
   t1:=round(map_size1/2.6);
   ro^:=t1;//t0+g_random(t1-t0);
   t0:=round(map_size1/5  );
   t1:=round(map_size1/3.5);
   ri^:=t0+g_random(t1-t0);
end;


////////////////////////////////////////////////////////////////////////////////
//
//   BASE CHECKS
//

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
begin
   map_IfObstacleHere:=false;

   for d:=1 to map_ObstaclesN do
     with map_ObstaclesL[d] do
       if(o_rO>0)then
         if(RingCollision(ix,iy,irO,irI,o_x,o_y,o_rO,o_rI))then
         begin
            map_IfObstacleHere:=true;
            break;
         end;
end;

function map_DistToObstacleEdge(x,y,r:integer):integer;
var
dx0,dy0,
dx1,dy1,
ix ,iy,
i,d,o:integer;
begin
   map_DistToObstacleEdge:=NOTSET;
   dx0:=(x-r) div MapObstaclesGridW;
   dy0:=(y-r) div MapObstaclesGridW;
   dx1:=(x+r) div MapObstaclesGridW;
   dy1:=(y+r) div MapObstaclesGridW;
   for ix:=dx0 to dx1 do
   for iy:=dy0 to dy1 do
     if (0<=ix)and(ix<=MapObstaclesGridN)
     and(0<=iy)and(iy<=MapObstaclesGridN)then
       with map_ObstaclesGrid[ix,iy] do
         if(oc_n>0)then
           for i:=0 to oc_n-1 do
             with oc_l[i]^ do
               if(o_rO>0)then
               begin
                  d:=point_dist_int(o_x,o_y,x,y);
                  o:=abs(d-o_rO);
                  map_DistToObstacleEdge:=min2i(o,map_DistToObstacleEdge);
                  if(o_ri<=0)then continue;
                  o:=abs(d-o_ri);
                  map_DistToObstacleEdge:=min2i(o,map_DistToObstacleEdge);
               end;
end;

function map_RObstaclePointIn(x,y:integer):integer;
var d:integer;
begin
   map_RObstaclePointIn:=0;
   for d:=0 to map_ObstaclesN do
     with map_ObstaclesL[d] do
       if(o_rO>0)then
         if(point_dist_int(x,y,o_x,o_y)<o_rO)then
         begin
            map_RObstaclePointIn:=o_rO;
            break;
         end;
end;

function map_IsObstacleTouchEdges(x,y,rO:integer):byte;
begin
   map_IsObstacleTouchEdges:=0;

   if((x-rO)<=0)then map_IsObstacleTouchEdges+=1;
   if((y-rO)<=0)then map_IsObstacleTouchEdges+=1;
   if((x+rO)>=map_Size1)then map_IsObstacleTouchEdges+=1;
   if((y+rO)>=map_Size1)then map_IsObstacleTouchEdges+=1;
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

procedure map_KeyPoints_UpdatePos;
var
kpi  : byte;
cd,
cx,cy: integer;
cdir,
odir : single;
stick,
itick: cardinal;
function circleI(i,m:integer):integer;
begin
   if(i<0)
   then circleI:=-i mod m
   else
     if(i>m)
     then circleI:=m-(i mod m)
     else circleI:=i;
end;
begin
   stick:=g_tick;
   itick:=stick div 3;
   if(longint(itick)<map_SizeKPCR)
   then cd:=integer(itick)
   else cd:=map_SizeKPCR;
   cdir:=(stick mod 109000)/400+(map_seed mod 360);
   cx  :=map_sizeH+round(cd*cos(cdir*DEGTORAD));
   cy  :=map_sizeH+round(cd*sin(cdir*DEGTORAD));
   odir:=map_SymmetryDir+(stick mod 119000)/600;
   for kpi:=0 to keyPoint_mcN-1 do
     with map_KeyPointsL[kpi] do
     begin
        odir+=keyPoint_mcDirStep;
        kp_x   :=circleI(cx+round(map_SizeKPCR*cos(odir*DEGTORAD)),map_size1);
        kp_y   :=circleI(cy-round(map_SizeKPCR*sin(odir*DEGTORAD)),map_size1);
        kp_Zone:=map_GetZone(kp_x,kp_y,kp_RCapture);
        {$IFDEF _FULLGAME}
        with map_KeyPointsVis[kpi] do
        begin
           kpmmx:=round(map_MiniMap_cx*kp_x);
           kpmmy:=round(map_MiniMap_cx*kp_y);
           kpmmr:=round(map_MiniMap_cx*kp_RCapture);
        end;
        {$ENDIF}
     end;
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
begin
   map_KeyPoints_Add:=false;
   if(map_KeyPointsN>=MaxKeyPoints)then exit;

   with map_KeyPointsL  [map_KeyPointsN] do
   {$IFDEF _FULLGAME}
   with map_KeyPointsVis[map_KeyPointsN] do
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
     end;
end;

function map_KeyPoints_CheckPos(ix,iy,aCaptureR:integer):boolean;
begin
   map_KeyPoints_CheckPos:=(map_IfPlayerStartHere (ix,iy,base_r1,0,map_PStartsGap))
                         or(map_IfKeyPointHere    (ix,iy,base_r1  ))
                         or(map_DistToObstacleEdge(ix,iy,aCaptureR)<aCaptureR);
end;

{procedure map_KeyPoints_Rect(cx,cy,cr,cdir,acount,aCaptureR,aNoBuildR,aEnergy,aCaptureTime:integer;aLifeTime:cardinal);
var
adir,
astep: single;
ix,iy,
sx,sy: integer;
p,ph,
pn   :byte;
begin
   if(acount<=0)then exit;
   ph:=(acount div 2)+(acount mod 2);
   pn:=acount+(acount mod 2);

   astep:=360/pn;
   adir :=dir_MOD360(cdir);
   adir -=astep/2;
   for p:=0 to acount-1 do
   begin
      if(map_Symmetry>maps_none)and(p>=ph)then break;

      adir+=astep;
      project2rect(@ix,@iy,adir,cr);
      ix+=cx;
      iy+=cy;
      map_SymmetryPoints2(@ix,@iy,@sx,@sy,base_r1h);

      if(map_IfKeyPointHere(ix,iy,base_r1h))then continue;

      if(sx<>NOTSET)then
        if(map_IfKeyPointHere(sx,sy,base_r1h))then continue;

      if(not map_KeyPoints_Add(ix,iy,aCaptureR,aNoBuildR,Aenergy,aCaptureTime,aLifeTime))then exit;
      if(sx<>NOTSET)then
        if(not map_KeyPoints_Add(sx,sy,aCaptureR,aNoBuildR,Aenergy,aCaptureTime,aLifeTime))then exit;
   end;
end;}

procedure map_KeyPoints_Random(acount,aCaptureR,aNoBuildR,aEnergy,aCaptureTime:integer;aLifeTime:cardinal);
const max_attempts = 500;
var
ix,iy,
sx,sy,
u,b,
success,
attempts:integer;
begin
   u:=aCaptureR;
   b:=map_Size1-(u*2);
   success:=0;

   while(acount>0)do
   begin
      if(map_Symmetry>maps_none)
      then acount-=2
      else acount-=1;

      attempts:=0;
      while(attempts<max_attempts)do
      begin
         attempts+=1;
         ix:=u+g_random(b);
         iy:=u+g_random(b);

         map_symmetryPoints2(@ix,@iy,@sx,@sy,base_r1);

         if(map_KeyPoints_CheckPos(ix,iy,aCaptureR))then continue;
         if(sx<>NOTSET)then
           if(map_KeyPoints_CheckPos(sx,sy,aCaptureR))then continue;

         if(not map_KeyPoints_Add(ix,iy,aCaptureR,aNoBuildR,Aenergy,aCaptureTime,aLifeTime))
         then exit
         else success+=1;

         if(sx<>NOTSET)then
           if(not map_KeyPoints_Add(sx,sy,aCaptureR,aNoBuildR,Aenergy,aCaptureTime,aLifeTime))
           then exit
           else success+=1;

         break;
      end;
   end;

   {if(success<map_MaxPlayers)and(map_MaxPlayers>0)then
   begin
      b:=map_MaxPlayers-success;
      map_KeyPoints_Rect(map_SizeH,map_SizeH,map_SizeH-u,map_SymmetryDir+((360 div map_MaxPlayers) div 2),b,aCaptureR,aNoBuildR,Aenergy,aCaptureTime,aLifeTime);
   end;  }
end;

procedure map_KeyPoints_Create;
var i:byte;
begin
   KeyPoints_Clear;

   case map_scenario of
mc_KotH     : map_KeyPoints_Add(map_Sizeh,map_Sizeh,keyPoint_KotR,0,0,keyPoint_CaptTime_KotH,0);
mc_KeyPoints: begin
                 for i:=1 to keyPoint_mcN do map_KeyPoints_Add(map_Sizeh,map_Sizeh,keyPoint_DefR,0,0,keyPoint_CaptTime_Def,0);
                 map_KeyPoints_UpdatePos;
              end;
   end;

   if(map_generators>0)then
   begin
      if(map_MaxPlayers>0)then
        for i:=0 to map_MaxPlayers-1 do
          map_KeyPoints_Add(map_PlayerStartX[i]+(sign(map_sizeh-map_PlayerStartX[i])*keyPoint_GenR),
                            map_PlayerStartY[i]+(sign(map_sizeh-map_PlayerStartY[i])*keyPoint_GenR),
                            keyPoint_GenR,keyPoint_GenR-25,map_generators_Energy,keyPoint_CaptTime_Gen,map_generators_LFTicks[map_generators]);

      map_KeyPoints_Random(MaxKeyPoints-byte(map_scenario=mc_KotH),keyPoint_GenR,keyPoint_GenR-25,map_generators_Energy,keyPoint_CaptTime_Gen,map_generators_LFTicks[map_generators]);
   end;

   map_KeyPoints_UpdateZone;
   map_KeyPoints_UpdateTeamData;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    PLAYER STARTS
//

procedure map_ShuffleStarts(trueRandom,teamShuffle:boolean);
var
x,y:byte;
  i:integer;
begin
   if(map_MaxPlayers>0)then
     for x:=0 to map_MaxPlayers-1 do
     for y:=0 to map_MaxPlayers-1 do
       if(x<>y)then
       begin
          case trueRandom of
          true : if(random(2)=0)then continue;
          false: if((abs(integer(map_seed)+x+y) mod 3)=0)then continue;
          end;

          if(teamShuffle)and(map_MaxPlayers>2)and(g_PlayersMain[x].team<>g_PlayersMain[y].team)then continue;
          i:=map_PlayerStartX[x];map_PlayerStartX[x]:=map_PlayerStartX[y];map_PlayerStartX[y]:=i;
          i:=map_PlayerStartY[x];map_PlayerStartY[x]:=map_PlayerStartY[y];map_PlayerStartY[y]:=i;
       end;
end;

procedure map_Starts_Circle(cx,cy,sdir,r:integer);   //map_MaxPlayers
var
p,ph,pn:byte;
dstep  :integer;
begin
   if(map_MaxPlayers=0)then exit;
   ph:=(map_MaxPlayers div 2)+(map_MaxPlayers mod 2);
   pn:=map_MaxPlayers+(map_MaxPlayers mod 2);

   dstep:=360 div pn;
   sdir -=dstep div 2;
   sdir :=dir_MOD360(sdir);
   for p:=0 to map_MaxPlayers-1 do
   begin
      if(map_Symmetry>maps_none)and(p>=ph)then break;

      sdir+=dstep;
      map_PlayerStartX[p]:=cx+trunc(r*cos(sdir*degtorad));
      map_PlayerStartY[p]:=cy-trunc(r*sin(sdir*degtorad));
      if(map_Symmetry>maps_none)then
        map_symmetryPoints(map_PlayerStartX[p   ], map_PlayerStartY[p   ],
                          @map_PlayerStartX[p+ph],@map_PlayerStartY[p+ph]);
   end;
end;

procedure map_Starts_Rect(cx,cy,cr,cdir:integer);
var
adir,
astep: single;
p,ph,
pn   :byte;
begin
   if(map_MaxPlayers=0)then exit;
   ph:=(map_MaxPlayers div 2)+(map_MaxPlayers mod 2);
   pn:=map_MaxPlayers+(map_MaxPlayers mod 2);

   astep:=360/pn;
   adir :=dir_MOD360(cdir);
   adir -=astep/2;
   for p:=0 to map_MaxPlayers-1 do
   begin
      if(map_Symmetry>maps_none)and(p>=ph)then break;

      adir+=astep;
      project2rect(@map_PlayerStartX[p],@map_PlayerStartY[p],adir,cr);
      map_PlayerStartX[p]+=cx;
      map_PlayerStartY[p]+=cy;
      if(map_Symmetry>maps_none)then
        map_symmetryPoints(map_PlayerStartX[p   ], map_PlayerStartY[p   ],
                          @map_PlayerStartX[p+ph],@map_PlayerStartY[p+ph]);
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
   cdir+=round(tdirStep/2);
   if(tdirStep<1)then tdirStep:=1;
   pdirStep:=tdirStep/(playerPerTeam+0.6);
   if(playerPerTeam>1)then
   cdir-=round(pdirStep*(playerPerTeam-1)/2);

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

function map_Starts_Random(minObstacleDist,StartSize,freex,freey,freeOr,freeOi:integer):boolean;
const max_attempts = 500;
var
p,ph   : byte;
ix,iy,
sx,sy,
attempts,
success,
startsGap,
bb0,bb1: integer;
begin
   map_Starts_Random:=false;

   if(map_MaxPlayers=0)then exit;
   ph:=(map_MaxPlayers div 2)+(map_MaxPlayers mod 2);

   bb0:=minObstacleDist;
   bb1:=map_Size1-(bb0*2);
   startsGap:=StartSize*2;

   success:=map_MaxPlayers;

   for p:=0 to map_MaxPlayers-1 do
   begin
      if(map_Symmetry>maps_none)and(p>=ph)then break;

      attempts:=0;
      while(true)do
      begin
         attempts+=1;
         if(attempts>=max_attempts)then exit;

         ix:=bb0+g_random(bb1);
         iy:=bb0+g_random(bb1);

         map_symmetryPoints(ix,iy,@sx,@sy);

         if(map_IfPlayerStartHere(ix,iy,StartSize,0,StartSize))then continue;
         if(freeOr>0)then
           if(RingCollision(ix,iy,minObstacleDist,0,freex,freey,freeOr,freeOi))then continue;

         if(sx<>NOTSET)then
         begin
            if(point_dist_int(ix,iy,sx,sy)<startsGap)then continue;

            if(freeOr>0)then
              if(RingCollision(sx,sy,minObstacleDist,0,freex,freey,freeOr,freeOi))then continue;
            if(map_IfPlayerStartHere(sx,sy,StartSize,0,StartSize))then continue;
         end;
         break;
      end;

      map_PlayerStartX[p]:=ix;
      map_PlayerStartY[p]:=iy;
      success-=1;
      if(sx<>NOTSET)then
      begin
         map_PlayerStartX[p+ph]:=sx;
         map_PlayerStartY[p+ph]:=sy;
         success-=1;
      end;
   end;

   map_Starts_Random:=success<=0;
end;

procedure map_PlayersStarts;
var p,
io,ii:integer;
begin
   for p:=0 to LastPlayer do
   begin
      map_PlayerStartX[p]:=NOTSET;
      map_PlayerStartY[p]:=NOTSET;
   end;

   case map_template of
   mapt_lake,
   mapt_island : begin
                    map_CalcLakeR(@io,@ii);
                    case map_scenario of
                    mc_1x1,
                    mc_2x2,
                    mc_3x3,
                    mc_4x4    : map_Starts_Teams (map_Sizeh,map_Sizeh,io+base_rh,map_SymmetryDir,2);
                    mc_2x2x2  : map_Starts_Teams (map_Sizeh,map_Sizeh,io+base_rh,map_SymmetryDir,3);
                    mc_2x2x2x2: map_Starts_Teams (map_Sizeh,map_Sizeh,io+base_rh,map_SymmetryDir,4);
                    mc_KotH,
                    mc_royale : map_Starts_Circle(map_Sizeh,map_Sizeh,map_SymmetryDir,io+base_rh);
                    else        if(not map_Starts_Random(base_r1,base_r1+(map_Size1 div 12),map_Sizeh,map_Sizeh,io-base_rh,0))then
                                  map_Starts_Circle(map_Sizeh,map_Sizeh,map_SymmetryDir,io+base_rh);
                    end;
                 end;
   mapt_temple : case map_scenario of
                 mc_1x1,
                 mc_2x2,
                 mc_3x3,
                 mc_4x4    : map_Starts_Teams (map_Sizeh,map_Sizeh,map_SizeH-(map_SizeH div 5),map_SymmetryDir,2);
                 mc_2x2x2  : map_Starts_Teams (map_Sizeh,map_Sizeh,map_SizeH-(map_SizeH div 5),map_SymmetryDir,3);
                 mc_2x2x2x2: map_Starts_Teams (map_Sizeh,map_Sizeh,map_SizeH-(map_SizeH div 5),map_SymmetryDir,4);
                 mc_KotH,
                 mc_royale : map_Starts_Circle(map_Sizeh,map_Sizeh,map_SymmetryDir,map_Sizeh-(map_Size1 div 8));
                 else        if(not map_Starts_Random(base_r1,base_r1+(map_Size1 div 12),map_Sizeh,map_Sizeh,(map_Size1 div 4)-base_rh,0))then
                               map_Starts_Rect  (map_Sizeh,map_Sizeh,map_SizeH-(map_SizeH div 5),map_SymmetryDir);
                 end;
   mapt_cave,
   mapt_steppe,
   mapt_canyon : case map_scenario of
                 mc_1x1,
                 mc_2x2,
                 mc_3x3,
                 mc_4x4    : map_Starts_Teams (map_Sizeh,map_Sizeh,map_Size1 div 3,map_SymmetryDir,2);
                 mc_2x2x2  : map_Starts_Teams (map_Sizeh,map_Sizeh,map_Size1 div 3,map_SymmetryDir,3);
                 mc_2x2x2x2: map_Starts_Teams (map_Sizeh,map_Sizeh,map_Size1 div 3,map_SymmetryDir,4);
                 mc_KotH   : map_Starts_Circle(map_Sizeh,map_Sizeh,map_SymmetryDir,map_Sizeh-(map_Size1 div 8));
                 mc_royale : map_Starts_Circle(map_Sizeh,map_Sizeh,map_SymmetryDir,map_Sizeh-(map_Size1 div 5));
                 else        if(not map_Starts_Random(base_r1,base_r1+(map_Size1 div 12),0,0,0,0))then
                               map_Starts_Circle(map_Sizeh,map_Sizeh,map_SymmetryDir,map_Sizeh-(map_Size1 div 8));
                 end;
   end;

   if(g_FixedPositions)then map_ShuffleStarts(false,map_scenario in mc_fixed_teams);
end;

////////////////////////////////////////////////////////////////////////////////
//
//    GENERATOR
//

procedure map_Obstacles_Noise(n_obstacles,min_f,max_f,iRPart:integer;allowInInR:boolean=false);
const attempts_max = 3;
var
obs_f,
irO,
ix,iy,
sx,sy,
borderDist,
attempts:integer;
function TryAddObstacle:boolean;
var
dR,
irI:integer;
begin
   TryAddObstacle:=false;
   attempts:=attempts_max;
   while(attempts>0)do
   begin
      attempts-=1;
      ix:=g_randomx(ix,map_Size1);
      iy:=g_randomx(iy,map_Size1);
      borderDist:=min2i(min2i(ix-irO,map_size1-(ix+irO)),min2i(iy-irO,map_size1-(iy+irO)));
      if(0<=borderDist)and(borderDist<=map_ObstaclesGap)then continue;

      map_symmetryPoints(ix,iy,@sx,@sy);

      if(sx<>NOTSET)then
        if(point_dist_int(ix,iy,sx,sy)<(irO*2+map_ObstaclesGap))then
        begin
           ix:=(ix+sx)div 2;
           iy:=(iy+sy)div 2;
           sx:=NOTSET;
           sy:=NOTSET;
        end;

      if(map_IsObstacleTouchEdges(ix,iy,irO+map_ObstaclesGap)>1)then continue;

      irI:=0;
      dR:=map_RObstaclePointIn(ix,iy);
      if(dR=0)or(allowInInR)then
      begin
         if(irO>=base_r1)and(iRPart<>0)then
         begin
            if(iRPart>1 )then irI:=min2i(base_r2,irO div iRPart);
            if(iRPart<-1)then
              if(map_ObstaclesN mod 2)=0 then
                irI:=min2i(base_r2,irO div -iRPart);

            if(irI<ObstacleMinInnerR)then irI:=ObstacleMinInnerR;
            irI:=irO-ObstacleMinInnerR;
         end;
      end
      else
        if(irO>=(dR div 3))then continue;

      if(map_IfObstacleHere(ix,iy,irO+map_ObstaclesGap,irI))then continue;
      if(map_IfPlayerStartHere(ix,iy,irO+map_ObstaclesGap,irI,map_PStartsGap))then continue;
      if(sx<>NOTSET)then
      begin
         if(map_IfObstacleHere(sx,sy,irO+map_ObstaclesGap,irI))then continue;
         if(map_IfPlayerStartHere(sx,sy,irO+map_ObstaclesGap,irI,map_PStartsGap))then continue;
       end;

      map_Obstacle_Add(ix,iy,irO,irI);
      if(sx<>NOTSET)then
      map_Obstacle_Add(sx,sy,irO,irI);

      TryAddObstacle:=true;
      break;
   end;
end;
begin
   if(n_obstacles<=0)then exit;

   ix :=integer(map_seed);
   iy :=0;

   while(n_obstacles>0)do
   begin
      n_obstacles-=1;
      obs_f:=max_f;
      irO  :=map_ObstacleR(obs_f);

      while(obs_f>=min_f)do
      begin
         irO:=map_ObstacleR(obs_f);
         if(TryAddObstacle)
         then break
         else obs_f-=1;
      end;
   end;
end;

{procedure map_Obstacles_FillSea(obR,playerStartGap:integer);
var
odd:boolean;
cellw,
cellhw,
ix,iy,cx
     :integer;
begin
   cellhw:=round(obR/1.27);
   cellw :=cellhw*2;

   cx:=(map_Sizeh mod cellw);
   if(cx>=cellhw)then cx-=cellw;
   cx:=map_Size1-cx;
   odd:=false;

   iy:=map_SizeH;

   while(iy>-cellhw)do
   begin
      if(odd)
      then ix:=cx
      else ix:=cx-cellhw;
      odd:=not odd;
      while(ix>-cellhw)do
      begin
         if(not map_IfPlayerStartHere(ix,iy,obR,0,playerStartGap))then
           map_Obstacle_Add(ix,iy,obR,0);

         if(iy<>0)then
           if(not map_IfPlayerStartHere(map_Size1-ix,map_Size1-iy,obR,0,playerStartGap))then
             map_Obstacle_Add(map_Size1-ix,map_Size1-iy,obR,0);

         ix-=cellw;
      end;
      iy-=cellw;
   end;
end; }

procedure map_Obstacles_Temple(irI,irO,playerR:integer);
var p,i,
tx,ty,
rx,ry,
sx,sy,
ro,ri,
dir  :integer;
begin
   for i:=0 to LastPlayer do
   begin
      dir:=map_SymmetryDir+i*mapt_ltemple_dstep2;
      for p:=0 to LastPlayer do
      begin
         dir+=mapt_ltemple_dstep1;
         tx:=map_sizeH+round(irI*cos(dir*DEGTORAD));
         ty:=map_sizeH-round(irI*sin(dir*DEGTORAD));
         project2rect(@rx,@ry,dir,irO);
         rx+=map_SizeH;
         ry+=map_SizeH;
         ro:=point_dist_int(tx,ty,rx,ry) div 2;
         ri:=ro-ObstacleMinInnerR;
         tx:=(tx+rx) div 2;
         ty:=(ty+ry) div 2;

         map_SymmetryPoints2(@tx,@ty,@sx,@sy,ro*2+map_ObstaclesGap);

         if(map_IfPlayerStartHere(tx,ty,ro,ri,playerR))then continue;
         if(sx<>NOTSET)then
           if(map_IfPlayerStartHere(sx,sy,ro,ri,playerR))then continue;

         if(map_IfObstacleHere(tx,ty,ro+map_ObstaclesGap,ri))then continue;
         if(sx<>NOTSET)then
           if(map_IfObstacleHere(sx,sy,ro+map_ObstaclesGap,ri))then continue;

         map_Obstacle_Add(tx,ty,ro,ri);
         if(sx<>NOTSET)then
           map_Obstacle_Add(sx,sy,ro,ri);
      end;
   end;
end;

procedure map_Obstacles_Create;
var
ix,iy,
io,ii,
obs_n:integer;
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
   obs_n:=trunc(MaxObstacles*map_Size1/map_MaxSize);
   case map_template of
   mapt_lake   : begin
                    map_CalcLakeR(@io,@ii);
                    if(map_scenario=mc_koth)
                    then map_Obstacle_Add(map_SizeH,map_SizeH,io,keyPoint_KotR)
                    else map_Obstacle_Add(map_SizeH,map_SizeH,io,0            );
                    map_Obstacles_Noise(obs_n div 3,0,2,0);
                 end;
   mapt_island   : begin
                    map_CalcLakeR(@io,@ii);
                    map_Obstacle_Add(map_SizeH,map_SizeH,io,ii);
                    map_Obstacles_Noise(obs_n div 4,0,3,0);
                 end;
   mapt_temple : begin
                    io:=map_Size1 div 4;
                    if(map_scenario=mc_koth)
                    then map_Obstacle_Add(map_SizeH,map_SizeH,io,keyPoint_KotR)
                    else map_Obstacle_Add(map_SizeH,map_SizeH,io,0            );

                    map_Obstacles_Temple(io+map_obstaclesGap*2,map_sizeh+base_r1,base_r1);
                    map_Obstacles_Noise(obs_n,0,4,0);
                 end;
   mapt_cave   : begin
                 map_Obstacles_Noise(obs_n,3,10,0);
                 map_Obstacles_Noise(obs_n,2,10,0);
                 end;
   mapt_steppe : map_Obstacles_Noise(obs_n,0,2 ,0);
   mapt_canyon : begin
                 map_Obstacles_Noise(obs_n,3,10,15,true);
                 map_Obstacles_Noise(obs_n,3,10,15,true);
                 map_Obstacles_Noise(obs_n,0,2 ,0);
                 end;
   end;

   if(map_scenario=mc_koth)then
      map_Obstacle_Remove(map_SizeH,map_SizeH,keyPoint_KotR-1,0);

   map_RefreshObstaclesGrid;
   map_DataForAI;
end;

procedure map_CreateObjects;
begin
   map_Seed2RandomBase;
   map_Obstacles_Create;
   map_KeyPoints_Create;
   {$IFDEF _FULLGAME}
   map_Obstacles_SetDrawData;
   map_Decals_Create;
   {$ENDIF}
end;

procedure map_RandomSeed;
begin
   map_seed:=random($FFFFFFFF)+(SDL_GetTicks shl 5);
   {$IFDEF _FULLGAME}
   menu_mseed:=c2s(map_seed);
   {$ENDIF}
end;

procedure Map_randommap(minMapSize:integer=map_MinSize;maxMapSize:integer=map_MaxSize);
begin
   map_RandomSeed;

   map_Size1   :=minMapSize+round(random(maxMapSize-minMapSize)/map_SizeMenuStep)*map_SizeMenuStep;
   map_Template:=random(mapt_last+1);
   map_Symmetry:=random(maps_last+1);
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
             Game_ShuffleAINames;
             map_BaseVars;

             map_ObstaclesGap:= 50;
             map_PStartsGap  := base_r1;
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




