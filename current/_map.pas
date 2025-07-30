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

procedure _dds_a(dx,dy:integer;dt:byte);
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

procedure map_RandomBase;
begin
   g_random_i:= word(map_seed);
   g_random_p:= byte(map_seed);
end;

procedure map_vars;
begin
   map_RandomBase;

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

function _PlayerStartHere(x,y,m:integer;check_symmetry:boolean):boolean;
var p:byte;
begin
   if(m<=0)then
   begin
      _PlayerStartHere:=true;
      exit;
   end;
   _PlayerStartHere:=false;

   if(check_symmetry)then
    if(point_dist_int(x,y,map_Size-x,map_Size-y)<m)then
    begin
       _PlayerStartHere:=true;
       exit;
    end;

   for p:=0 to LastPlayer do
    if(point_dist_int(x,y,map_psx[p],map_psy[p])<m)then
    begin
       _PlayerStartHere:=true;
       break;
    end;
end;

function _CPointHere(x,y,m:integer;check_symmetry:boolean):boolean;
var p:byte;
begin
   if(m<=0)then
   begin
      _CPointHere:=true;
      exit;
   end;
   _CPointHere:=false;

   if(check_symmetry)then
    if(point_dist_int(x,y,map_Size-x,map_Size-y)<(m*2))then
    begin
       _CPointHere:=true;
       exit;
    end;

   for p:=0 to LastKeyPoint do
    with g_KeyPoints[p] do
     if(cpCaptureR>0)then
      if(point_dist_int(x,y,cpx,cpy)<(m+max2i(cpsolidr,cpCaptureR)))then
      begin
         _CPointHere:=true;
         break;
      end;
end;

procedure map_Starts_Circle(cx,cy,sdir,r:integer);
const dstep =360 div LastPlayer;
var i:byte;
begin
   sdir :=abs(sdir mod 360);
   for i:=1 to LastPlayer do
   begin
      sdir+=dstep;
      map_psx[i]:=cx+trunc(r*cos(sdir*degtorad));
      map_psy[i]:=cy+trunc(r*sin(sdir*degtorad));
   end;
end;

procedure map_Starts_Default;
var ix,iy,i,u,c,bb0,bb1,dst:integer;
begin
   bb0:=base_1r+(map_Size-map_MinSize) div 7;
   bb1:=map_Size-(bb0*2);
   dst:=(map_Size div 5)+base_1r;

   for i:=1 to LastPlayer do
   begin
      if(map_Symmetry)and(i>3)then break;
      c:=0;
      u:=dst;
      while true do
      begin
         ix:=bb0+g_random(bb1);
         iy:=bb0+g_random(bb1);
         c+=1;
         if(c>500 )then u-=1;

         if(c>1000)
         or(_PlayerStartHere(ix,iy,u,map_Symmetry)=false)then break;
      end;

      map_psx[i]:=ix;
      map_psy[i]:=iy;
      if(map_Symmetry)then
      begin
         map_psx[i+3]:=map_Size-map_psx[i];
         map_psy[i+3]:=map_Size-map_psy[i];
      end;
   end;
end;

procedure map_ShuffleStarts(teamShuffle:boolean);
var
x,y:byte;
  i:integer;
begin
   for x:=1 to LastPlayer do
   for y:=1 to LastPlayer do
     if(random(2)=0)and(x<>y)then
     begin
        if(teamShuffle)and(g_players[x].team<>g_players[y].team)then continue;
        i:=map_psx[x];map_psx[x]:=map_psx[y];map_psx[y]:=i;
        i:=map_psy[x];map_psy[x]:=map_psy[y];map_psy[y]:=i;
     end;
end;

procedure map_CPoints_UpdatePFZone;
var pn:integer;
begin
   for pn:=0 to LastKeyPoint do
    with g_KeyPoints[pn] do
     if(cpCaptureR>0)then cpzone:=pf_get_area(cpx,cpy);
end;

procedure map_CPoints_Default(num:byte;sr,cr,nr,energy,time:integer;lifetime:cardinal;newpoints:boolean);
var ix,iy,i,u,b,c:integer;
function _setcpoint(px,py:integer):boolean;
var pn:byte;
begin
   for pn:=0 to LastKeyPoint do
    if(g_KeyPoints[pn].cpCaptureR<=0)then break;

   if(pn>LastKeyPoint)then
   begin
      _setcpoint:=true;
      exit;
   end
   else _setcpoint:=false;

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

         if (not _PlayerStartHere(ix,iy,base_1rh,map_Symmetry))
         and(not _CPointHere(ix,iy,base_1rh,map_Symmetry))then
         begin
            if(_setcpoint(ix,iy))then exit;
            if(map_Symmetry)then
             if(_setcpoint(map_Size-ix,map_Size-iy))then exit;
            break;
         end;
         c+=1;
      end;
   end;
end;

procedure map_Starts;
var ix,iy,i,u,c:integer;
begin
   for i:=0 to LastPlayer do
   begin
      map_psx[i]:=-5000;
      map_psy[i]:=-5000;
   end;

   case map_scenario of
mc_3x3 :
      begin
         ix:=map_Size div 2;
         iy:=base_2r+(map_Size div 25);
         u :=ix-(map_Size div 7);
         i :=map_seed mod 360;

         map_psx[1]:=trunc(ix+cos(i*degtorad)*u);
         map_psy[1]:=trunc(ix+sin(i*degtorad)*u);
         i+=105;
         map_psx[2]:=map_psx[1]+trunc(cos(i*degtorad)*iy);
         map_psy[2]:=map_psy[1]+trunc(sin(i*degtorad)*iy);
         i-=210;
         map_psx[3]:=map_psx[1]+trunc(cos(i*degtorad)*iy);
         map_psy[3]:=map_psy[1]+trunc(sin(i*degtorad)*iy);

         map_psx[4]:=map_Size-map_psx[1];
         map_psy[4]:=map_Size-map_psy[1];
         map_psx[5]:=map_Size-map_psx[2];
         map_psy[5]:=map_Size-map_psy[2];
         map_psx[6]:=map_Size-map_psx[3];
         map_psy[6]:=map_Size-map_psy[3];
      end;
mc_2x2x2:
      begin
         ix:=map_Size div 2;
         iy:=base_2r+(map_Size div 30);
         u :=ix-(ix div 3);
         c :=map_seed mod 360;

         map_psx[1]:=trunc(ix+cos(c*degtorad)*u);
         map_psy[1]:=trunc(ix+sin(c*degtorad)*u);
         i:=c+100;
         map_psx[2]:=map_psx[1]+trunc(cos(i*degtorad)*iy);
         map_psy[2]:=map_psy[1]+trunc(sin(i*degtorad)*iy);

         c+=120;
         map_psx[3]:=trunc(ix+cos(c*degtorad)*u);
         map_psy[3]:=trunc(ix+sin(c*degtorad)*u);
         i:=c+100;
         map_psx[4]:=map_psx[3]+trunc(cos(i*degtorad)*iy);
         map_psy[4]:=map_psy[3]+trunc(sin(i*degtorad)*iy);

         c+=120;
         map_psx[5]:=trunc(ix+cos(c*degtorad)*u);
         map_psy[5]:=trunc(ix+sin(c*degtorad)*u);
         i:=c+100;
         map_psx[6]:=map_psx[5]+trunc(cos(i*degtorad)*iy);
         map_psy[6]:=map_psy[5]+trunc(sin(i*degtorad)*iy);
      end;
mc_invasion:
      begin
         map_psx[0]:=map_hmw;
         map_psy[0]:=map_hmw;
         map_Starts_Circle(map_hmw,map_hmw,integer(map_seed),base_2r);
      end;
mc_KotH:
      begin
         map_psx[0]:=map_hmw;
         map_psy[0]:=map_hmw;
         map_Starts_Circle(map_hmw,map_hmw,integer(map_seed),map_hmw-(map_Size div 8));
      end;
mc_royale :
      begin
         map_Starts_Circle(map_hmw,map_hmw,integer(map_seed),map_hmw-(map_Size div 5));
      end;
mc_capture:
      begin
         map_Starts_Default;
      end;
   else
         map_Starts_Default;
   end;
   if(not g_FixedPositions)then map_ShuffleStarts(map_scenario in mc_fixed_teams);
end;

procedure map_CPoints;
begin
   FillChar(g_KeyPoints,SizeOf(g_KeyPoints),0);

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
mc_capture: map_CPoints_Default(4,0,gm_cptp_r,base_1r,0,gm_cptp_time,0,true);
   end;

   if(map_generators>0)then
    map_CPoints_Default(LastKeyPoint,50,gm_cptp_gr,gm_cptp_gr-25,map_generators_Energy,gm_cptp_gtime,map_generators_LifeTime[map_generators],false);
end;

function _dnear(td:byte;ix,iy:pinteger):boolean;
var d:integer;
begin
   _dnear:=false;

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
      _dnear:=true;
      break;
   end;
end;

function _checkPlace(di:byte;ix,iy,doodad_r:integer):boolean;
begin
   _checkPlace:=false;
   if(_dnear(di,@ix,@iy))
   or(_PlayerStartHere (ix,iy,doodad_r,false))
   then _checkPlace:=true
   else
     if(map_Symmetry)then
     begin
        ix:=map_Size-ix;
        iy:=map_Size-iy;
        if(_dnear(di,@ix,@iy))
        or(_PlayerStartHere (ix,iy,doodad_r,false))then _checkPlace:=true;
     end;
end;

function _trysetdd(di:byte;ix,iy:pinteger;doodad_r:integer):boolean;
begin
   if(_checkPlace(di,ix^,iy^,doodad_r+DID_R[di]))
   then _trysetdd:=false
   else
   begin
      _dds_a(ix^,iy^,di);
      if(map_Symmetry)then _dds_a(map_Size-ix^,map_Size-iy^,di);
      _trysetdd:=true;
   end;
end;

function _PickDoodad(ix,iy,lqs,rks:pinteger;doodad_r:integer):boolean;
var di:byte;
begin
   _PickDoodad:=false;
   for di:=DID_liquidR1 to DID_Other do
    case di of
    DID_LiquidR1,
    DID_LiquidR2,
    DID_LiquidR3,
    DID_LiquidR4  : if(lqs^<=0)
                    then continue
                    else
                      if(_trysetdd(di,ix,iy,doodad_r))then
                      begin
                         _PickDoodad:=true;
                         lqs^-=1;
                         break;
                      end
                      else continue;
    DID_SRock,
    DID_BRock     : if(rks^<=0)
                    then continue
                    else
                      if(_trysetdd(di,ix,iy,doodad_r))then
                      begin
                         _PickDoodad:=true;
                         rks^-=1;
                         break;
                      end
                      else continue;
    else
      if(_trysetdd(di,ix,iy,doodad_r))then
      begin
         _PickDoodad:=true;
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
         if(not _PlayerStartHere(ix,iy,base_1r+cellw,map_Symmetry))then
         begin
            _dds_a(ix,iy,1);
            map_FillSea+=1;
         end;
         if(iy<>0)then
           if(not _PlayerStartHere(map_Size-ix,map_Size-iy,base_1r+cellw,map_Symmetry))then
           begin
              _dds_a(map_Size-ix,map_Size-iy,1);
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

         if(_PickDoodad(@ix,@iy,@lqs,@rks,ir))then break;

         cnt+=1;
         if(cnt>=dpostime)then break;
      end;
   end;

   map_RefreshDoodadsCells;

   map_RandomBase;
   map_CPoints;
   pf_MakeZoneGrid;
   map_CPoints_UpdatePFZone;
   {$IFDEF _FULLGAME}
   map_DoodadsDrawData;
   map_RedrawMenuMinimap;
   map_MakeDecals;
   {$ENDIF}
end;

procedure Map_randomseed;
begin
   map_seed:=random($FFFFFFFF)+(SDL_GetTicks shl 5);
   {$IFDEF _FULLGAME}
   menu_mseed:=c2s(map_seed);
   {$ENDIF}
end;

procedure Map_randommap;
begin
   Map_randomseed;

   map_Size :=map_MinSize+round(random(map_MaxSize-map_MinSize)/map_SizeMenuStep)*map_SizeMenuStep;
   map_Obstacles:=random(8);
   map_Symmetry:=random(2)>0;
end;

procedure Map_premap({$IFDEF _FULLGAME}camp_theme:boolean=false{$ENDIF});
begin
   {$IFDEF _FULLGAME}
   if(not camp_theme)then
   {$ENDIF}
   begin
   map_decor_gap:=40;
   map_vars;
   map_Starts;
   end;

   {$IFDEF _FULLGAME}
   if(not camp_theme)
   then map_seed2theme
   else SetThemeCampaing(cmp_sel);

   map_MakeThemeSprites;
   {$ENDIF}
   map_Make;
end;




