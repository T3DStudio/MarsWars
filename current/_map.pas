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
var dx0,dy0,dx1,dy1,d,dy:integer;
begin
   for dx0:=0 to MapObstaclesGridN do
   for dy0:=0 to MapObstaclesGridN do
   with map_ObstaclesGrid[dx0,dy0] do
   begin
      n:=0;
      setlength(l,n);
   end;

   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t>0)then
     begin
        dx0:=(x-r-MapObstaclesGridW) div MapObstaclesGridW;
        dy0:=(y-r-MapObstaclesGridW) div MapObstaclesGridW;
        dx1:=(x+r+MapObstaclesGridW) div MapObstaclesGridW;
        dy1:=(y+r+MapObstaclesGridW) div MapObstaclesGridW;
        while(dx0<=dx1)do
        begin
           for dy:=dy0 to dy1 do
            if(0<=dx0)and(dx0<=MapObstaclesGridN)and(0<=dy)and(dy<=MapObstaclesGridN)then
             with map_ObstaclesGrid[dx0,dy] do
             begin
                n+=1;
                setlength(l,n);
                l[n-1]:=@map_dds[d];
             end;
           dx0+=1;
        end;
     end;
end;

procedure map_addObstacle(dx,dy:integer;dt:byte);
begin
   if(map_ddn<0)then map_ddn:=0;
   if(map_ddn>=MaxDoodads)then exit;

   case dt of
   DID_LiquidR1,
   DID_LiquidR2,
   DID_LiquidR3,
   DID_LiquidR4,
   DID_Brock,
   DID_Srock,
   DID_Other     : begin
                      map_ddn+=1;
                      with map_dds[map_ddn] do
                      begin
                         t:=dt;
                         r:=DID_R[t];
                         x:=dx;
                         y:=dy;
                      end;
                   end;
   else
   end;
end;

procedure map_Seed2RandomBase;
begin
   g_random_i:= word(map_seed);
   g_random_p:= byte(map_seed);
end;

procedure map_vars;
begin
   map_Seed2RandomBase;

   map_b1      := map_Size-map_b0;
   map_hmw     := map_Size div 2;
   {$IFDEF _FULLGAME}
   if(g_type<>gt_campaing)then
   map_Size    := mm3i(map_MinSize,map_Size,map_MaxSize);

   map_mmcx    := (ui_CtrlPanelW-2)/map_Size;
   map_mmvw    := trunc(ui_cam_w*map_mmcx)+1;
   map_mmvh    := trunc(ui_cam_h*map_mmcx)+1;
   {$ENDIF}
end;

function map_IfPlayerStartHere(x,y,m:integer;check_symmetry:boolean):boolean;
var p:byte;
begin
   if(m<=0)then
   begin
      map_IfPlayerStartHere:=true;
      exit;
   end;
   map_IfPlayerStartHere:=false;

   if(check_symmetry)then
     if(point_dist_int(x,y,map_Size-x,map_Size-y)<m)then
     begin
        map_IfPlayerStartHere:=true;
        exit;
     end;

   for p:=0 to LastPlayer do
     if(point_dist_int(x,y,map_psx[p],map_psy[p])<m)then
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
       if(cpCaptureR>0)then
         if(point_dist_int(x,y,cpx,cpy)<(m+max2i(cpsolidr,cpCaptureR)))then
         begin
            map_IfKeyPointHere:=true;
            break;
         end;
end;

procedure map_Starts_Circle(cx,cy,sdir,r:integer);
const dstep = 360 div MaxPlayers;
var p:byte;
begin
   sdir :=abs(sdir mod 360);
   for p:=0 to LastPlayer do
   begin
      sdir+=dstep;
      map_psx[p]:=cx+trunc(r*cos(sdir*degtorad));
      map_psy[p]:=cy+trunc(r*sin(sdir*degtorad));
   end;
end;

procedure map_Starts_Default;
var ix,iy,p,u,c,bb0,bb1,dst:integer;
begin
   bb0:=base_1r+(map_Size-map_MinSize) div 7;
   bb1:=map_Size-(bb0*2);
   dst:=(map_Size div 5)+base_1r;

   for p:=0 to LastPlayer do
   begin
      if(map_Symmetry)and(p>3)then break;
      c:=0;
      u:=dst;
      while true do
      begin
         ix:=bb0+g_random(bb1);
         iy:=bb0+g_random(bb1);
         c+=1;
         if(c>500 )then u-=1;

         if(c>1000)
         or(not map_IfPlayerStartHere(ix,iy,u,map_Symmetry))then break;
      end;

      map_psx[p]:=ix;
      map_psy[p]:=iy;
      if(map_Symmetry)then
      begin
         map_psx[p+4]:=map_Size-map_psx[p];
         map_psy[p+4]:=map_Size-map_psy[p];
      end;
   end;
end;

procedure map_ShuffleStarts(teamShuffle:boolean);
var
x,y:byte;
  i:integer;
begin
   for x:=0 to LastPlayer do
   for y:=0 to LastPlayer do
     if(random(2)=0)and(x<>y)then
     begin
        if(teamShuffle)and(g_players[x].team<>g_players[y].team)then continue;
        i:=map_psx[x];map_psx[x]:=map_psx[y];map_psx[y]:=i;
        i:=map_psy[x];map_psy[x]:=map_psy[y];map_psy[y]:=i;
     end;
end;

procedure map_KeyPoints_UpdatePFZone;
var pn:integer;
begin
   for pn:=0 to LastKeyPoint do
     with g_KeyPoints[pn] do
       if(cpCaptureR>0)then cpzone:=pf_get_area(cpx,cpy);
end;

procedure map_KeyPoints_Default(num:byte;sr,cr,nr,energy,time:integer;lifetime:cardinal;newpoints:boolean);
var ix,iy,i,u,b,c:integer;
function setKeyPoint(px,py:integer):boolean;
var pn:byte;
begin
   for pn:=0 to LastKeyPoint do
    if(g_KeyPoints[pn].cpCaptureR<=0)then break;

   if(pn>LastKeyPoint)then
   begin
      setKeyPoint:=true;
      exit;
   end
   else setKeyPoint:=false;

   with g_KeyPoints[pn] do
   begin
      cpx          :=px;
      cpy          :=py;
      cp_ToCenterD :=point_dist_int(cpx,cpy,map_hmw,map_hmw);
      cpsolidr     :=sr;
      cpNoBuildR   :=nr;
      cpenergy     :=energy;
      cpCaptureR   :=cr;
      cpCaptureTime:=time;
      cplifetime   :=lifetime;
      {$IFDEF _FULLGAME}
      cpmx:=round(cpx*map_mmcx);
      cpmy:=round(cpy*map_mmcx);
      cpmr:=round(cpCaptureR*map_mmcx);
      {$ENDIF}
   end;
end;
begin
   if(newpoints)then FillChar(g_KeyPoints,SizeOf(g_KeyPoints),0);
   u:=map_Size div 50;
   b:=map_Size-(u*2);

   i:=0;
   while(i<num)do
   begin
      i+=1+byte(map_Symmetry);
      c:=0;
      while(c<1000)do
      begin
         ix:=u+g_random(b);
         iy:=u+g_random(b);

         if (not map_IfPlayerStartHere(ix,iy,base_1rh,map_Symmetry))
         and(not map_IfKeyPointHere   (ix,iy,base_1rh,map_Symmetry))then
         begin
            if(setKeyPoint(ix,iy))then exit;
            if(map_Symmetry)then
              if(setKeyPoint(map_Size-ix,map_Size-iy))then exit;
            break;
         end;
         c+=1;
      end;
   end;
end;

procedure map_PlayersStart;
var ix,iy,i,u,c:integer;
begin
   for i:=0 to LastPlayer do
   begin
      map_psx[i]:=-5000;
      map_psy[i]:=-5000;
   end;

   case map_scenario of
mc_4x4    : begin
               ix:=map_Size div 2;
               u :=ix-(map_Size div 7);
               i :=map_seed mod 360;
               c :=35+round(35*(map_MinSize/map_seed));

               for iy:=0 to 3 do
               begin
                  map_psx[iy]:=trunc(ix+cos(i*degtorad)*u);
                  map_psy[iy]:=trunc(ix+sin(i*degtorad)*u);
                  i+=c;
               end;
               {u-=base_2r;
               map_psx[3]:=trunc(ix+cos(i*degtorad)*u);
               map_psy[3]:=trunc(ix+sin(i*degtorad)*u);
               u+=base_2r;
               i+=105;
               map_psx[1]:=map_psx[1]+trunc(cos(i*degtorad)*iy);
               map_psy[1]:=map_psy[1]+trunc(sin(i*degtorad)*iy);
               i-=210;
               map_psx[2]:=map_psx[1]+trunc(cos(i*degtorad)*iy);
               map_psy[2]:=map_psy[1]+trunc(sin(i*degtorad)*iy); }

               map_psx[4]:=map_Size-map_psx[0];
               map_psy[4]:=map_Size-map_psy[0];
               map_psx[5]:=map_Size-map_psx[1];
               map_psy[5]:=map_Size-map_psy[1];
               map_psx[6]:=map_Size-map_psx[2];
               map_psy[6]:=map_Size-map_psy[2];
               map_psx[7]:=map_Size-map_psx[3];
               map_psy[7]:=map_Size-map_psy[3];
            end;
mc_2x2x2x2: begin
               ix:=map_Size div 2;
               iy:=base_2r+(map_Size div 30);
               u :=ix-(ix div 3);
               c :=map_seed mod 360;

               map_psx[0]:=trunc(ix+cos(c*degtorad)*u);
               map_psy[0]:=trunc(ix+sin(c*degtorad)*u);
               i:=c+100;
               map_psx[1]:=map_psx[0]+trunc(cos(i*degtorad)*iy);
               map_psy[1]:=map_psy[0]+trunc(sin(i*degtorad)*iy);

               c+=90;
               map_psx[2]:=trunc(ix+cos(c*degtorad)*u);
               map_psy[2]:=trunc(ix+sin(c*degtorad)*u);
               i:=c+100;
               map_psx[3]:=map_psx[2]+trunc(cos(i*degtorad)*iy);
               map_psy[3]:=map_psy[2]+trunc(sin(i*degtorad)*iy);

               c+=90;
               map_psx[4]:=trunc(ix+cos(c*degtorad)*u);
               map_psy[4]:=trunc(ix+sin(c*degtorad)*u);
               i:=c+100;
               map_psx[5]:=map_psx[4]+trunc(cos(i*degtorad)*iy);
               map_psy[5]:=map_psy[4]+trunc(sin(i*degtorad)*iy);

               c+=90;
               map_psx[6]:=trunc(ix+cos(c*degtorad)*u);
               map_psy[6]:=trunc(ix+sin(c*degtorad)*u);
               i:=c+100;
               map_psx[7]:=map_psx[6]+trunc(cos(i*degtorad)*iy);
               map_psy[7]:=map_psy[6]+trunc(sin(i*degtorad)*iy);
            end;
mc_KotH   : map_Starts_Circle(map_hmw,map_hmw,integer(map_seed),map_hmw-(map_Size div 8));
mc_royale : map_Starts_Circle(map_hmw,map_hmw,integer(map_seed),map_hmw-(map_Size div 5));
mc_capture: map_Starts_Default;
   else
            map_Starts_Default;
   end;
   if(not g_FixedPositions)then map_ShuffleStarts(map_scenario in mc_fixed_teams);
end;

procedure map_KeyPoints;
begin
   KeyPoints_Clear;

   case map_scenario of
mc_KotH   : with g_KeyPoints[0] do
            begin
               cpx:=map_hmw;
               cpy:=map_hmw;
               cpCaptureR   :=base_1r;
               cpCaptureTime:=ptime3*fr_fps1;

               {$IFDEF _FULLGAME}
               cpmx:=round(cpx*map_mmcx);
               cpmy:=round(cpy*map_mmcx);
               cpmr:=round(cpCaptureR*map_mmcx)+1;
               {$ENDIF}
            end;
mc_capture: map_KeyPoints_Default(4,0,gm_cptp_r,base_1r,0,gm_cptp_time,0,true);
   end;

   if(map_generators>0)then
     map_KeyPoints_Default(LastKeyPoint,50,gm_cptp_gr,gm_cptp_gr-25,map_generators_Energy,gm_cptp_gtime,map_generators_LifeTime[map_generators],false);
end;

function map_IfObstacleHere(td:byte;ix,iy:pinteger):boolean;
var d:integer;
begin
   map_IfObstacleHere:=false;

   with map_dds[0] do
     if(map_Symmetry)then
     begin
        t:=td;
        r:=DID_R[td];
        x:=map_Size-ix^;
        y:=map_Size-iy^;
     end
     else
     begin
        t:=0;
        x:=-32000;
        y:=-32000;
     end;

   for d:=0 to map_ddn do
     with map_dds[d] do
       if(t>0)then
         if(point_dist_int(x,y,ix^,iy^)<(DID_R[t]+DID_R[td]+map_decor_gap))then         //_dec_min_r(t,td)
         begin
            map_IfObstacleHere:=true;
            break;
         end;
end;

function map_IfSomethingHere(di:byte;ix,iy,doodad_r:integer):boolean;
begin
   map_IfSomethingHere:=false;
   if(map_IfObstacleHere(di,@ix,@iy))
   or(map_IfPlayerStartHere (ix,iy,doodad_r,false))
   then map_IfSomethingHere:=true
   else
     if(map_Symmetry)then
     begin
        ix:=map_Size-ix;
        iy:=map_Size-iy;
        if(map_IfObstacleHere(di,@ix,@iy))
        or(map_IfPlayerStartHere (ix,iy,doodad_r,false))then map_IfSomethingHere:=true;
     end;
end;

function map_TryAddObstacle(di:byte;ix,iy:integer;doodad_r:integer):boolean;
begin
   if(map_IfSomethingHere(di,ix,iy,doodad_r+DID_R[di]))
   then map_TryAddObstacle:=false
   else
   begin
      map_addObstacle(ix,iy,di);
      if(map_Symmetry)then map_addObstacle(map_Size-ix,map_Size-iy,di);
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

function map_FillSea:integer;
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

   cx:=(map_hmw mod cellw);
   if(cx>=cellhw)then cx-=cellw;
   cx:=map_Size-cx;
   odd:=false;

   iy:=map_hmw;

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
end;

procedure map_make;
const dpostime = 200;
var i,ix,iy,lqs,rks,ddc,cnt,ir:integer;
begin
   map_ddn:=0;
   FillChar(map_dds,SizeOf(map_dds),0);
   for ix:=0 to MapObstaclesGridN do
   for iy:=0 to MapObstaclesGridN do
   with map_ObstaclesGrid[ix,iy] do
   begin
      n:=0;
      setlength(l,n);
   end;

   ddc:=trunc(MaxDoodads*((sqr(map_Size) div ddc_div)/ddc_cf))+1;

   if(map_Symmetry)
   then ddc:=mm3i(1,round(ddc/2),MaxDoodads)
   else ddc:=mm3i(1,      ddc   ,MaxDoodads);

   //if(map_Obstacles=7)then ddc-=map_FillSea;
   //if(ddc<1)then ddc:=1;

   rks :=0;
   lqs :=0;

   i  :=(ddc div 11);
   ix :=i*map_Obstacles;
   lqs:=ix div 4;
   rks:=ix-lqs;

   ir :=base_1r+(map_Size div 100);
   ix :=map_seed;
   iy :=0;

   for i:=1 to ddc do
   begin
      cnt:=0;
      while true do
      begin
         ix:=g_randomx(ix,map_Size);
         iy:=g_randomx(iy,map_Size); //+ix*cnt

         if(map_PickDoodad(@ix,@iy,@lqs,@rks,ir))then break;

         cnt+=1;
         if(cnt>=dpostime)then break;
      end;
   end;

   map_RefreshDoodadsCells;

   map_Seed2RandomBase;
   map_KeyPoints;
   pf_MakeZoneGrid;
   map_KeyPoints_UpdatePFZone;
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
   map_Obstacles:=random(map_MaxObstacles+1);
   map_Symmetry :=random(2)>0;
end;

procedure Map_premap({$IFDEF _FULLGAME}camp_theme:boolean=false{$ENDIF});
begin
   {$IFDEF _FULLGAME}
   if(not camp_theme)then
   {$ENDIF}
   begin
   map_decor_gap:=40;
   map_vars;
   map_PlayersStart;
   end;

   {$IFDEF _FULLGAME}
   if(not camp_theme)
   then map_seed2theme
   else SetThemeCampaing(cmp_sel);

   map_MakeThemeSprites;
   {$ENDIF}
   map_Make;
end;




