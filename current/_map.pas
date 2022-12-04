{$IFDEF _FULLGAME}

procedure map_tllbc;
begin
   MakeTerrain;
   MakeCrater;
   MakeLiquid;
   MakeLiquidBack;
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

procedure map_doodads_cells_refresh;
var dx0,dy0,dx1,dy1,d,dy:integer;
begin
   for dx0:=0 to dcn do
   for dy0:=0 to dcn do
   with map_dcell[dx0,dy0] do
   begin
      n:=0;
      setlength(l,n);
   end;

   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t>0)then
     begin
        dx0:=(x-r-dcw) div dcw;
        dy0:=(y-r-dcw) div dcw;
        dx1:=(x+r+dcw) div dcw;
        dy1:=(y+r+dcw) div dcw;
        while(dx0<=dx1)do
        begin
           for dy:=dy0 to dy1 do
            if(0<=dx0)and(dx0<=dcn)and(0<=dy)and(dy<=dcn)then
             with map_dcell[dx0,dy] do
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
   map_iseed   := word(map_seed);
   map_rpos    := byte(map_seed);
end;

procedure map_vars;
begin
   map_RandomBase;
   map_b1      := map_mw-map_b0;
   map_hmw     := map_mw div 2;
   //if(g_mode in gm_fixed_positions)then g_fixed_positions:=true;
   {$IFDEF _FULLGAME}
   if(menu_s2<>ms2_camp)then map_mw:=mm3(MinSMapW,map_mw,MaxSMapW);
   map_mmcx    := (vid_panelw-2)/map_mw;
   map_mmvw    := trunc(vid_cam_w*map_mmcx)+1;
   map_mmvh    := trunc(vid_cam_h*map_mmcx)+1;
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
    if(point_dist_int(x,y,map_mw-x,map_mw-y)<m)then
    begin
       _PlayerStartHere:=true;
       exit;
    end;

   for p:=0 to MaxPlayers do
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
    if(point_dist_int(x,y,map_mw-x,map_mw-y)<(m*2))then
    begin
       _CPointHere:=true;
       exit;
    end;

   for p:=1 to MaxCpoints do
    with g_cpoints[p] do
     if(cpCapturer>0)then
      if(point_dist_int(x,y,cpx,cpy)<(m+max2(cpsolidr,cpCapturer)))then
      begin
         _CPointHere:=true;
         break;
      end;
end;

procedure map_Starts_Circle(cx,cy,sdir,r:integer);
const dstep = 360 div MaxPlayers;
var i:byte;
begin
   sdir:=abs(sdir mod 360);
   for i:=1 to MaxPlayers do
   begin
      sdir+=dstep;
      map_psx[i]:=cx+trunc(r*cos(sdir*degtorad));
      map_psy[i]:=cy+trunc(r*sin(sdir*degtorad));
   end;
end;

procedure map_Starts_Default;
var ix,iy,i,u,c,bb0,bb1,dst:integer;
begin
   bb0:=base_r+(map_mw-MinSMapW) div 7;
   bb1:=map_mw-(bb0*2);
   dst:=(map_mw div 5)+base_r;

   for i:=1 to MaxPlayers do
   begin
      if(map_symmetry)and(i>3)then break;
      c:=0;
      u:=dst;
      while true do
      begin
         ix:=bb0+_random(bb1);
         iy:=bb0+_random(bb1);
         c+=1;
         if(c>500 )then u-=1;

         if(c>1000)
         or(_PlayerStartHere(ix,iy,u,map_symmetry)=false)then break;
      end;

      map_psx[i]:=ix;
      map_psy[i]:=iy;
      if(map_symmetry)then
      begin
         map_psx[i+3]:=map_mw-map_psx[i];
         map_psy[i+3]:=map_mw-map_psy[i];
      end;
   end;
end;

procedure map_ShuffleStarts;
var x,y:byte;
    i:integer;
begin
   for x:=1 to MaxPlayers do
    for y:=1 to MaxPlayers do
     if((byte(x*y+map_seed+g_mode) mod 3)=0)then
     begin
        i:=map_psx[x];map_psx[x]:=map_psx[y];map_psx[y]:=i;
        i:=map_psy[x];map_psy[x]:=map_psy[y];map_psy[y]:=i;
     end;
end;

procedure map_CPoints_UpdatePFZone;
var pn:integer;
begin
   for pn:=1 to MaxCPoints do
    with g_cpoints[pn] do
     if(cpCapturer>0)then cpzone:=pf_get_area(cpx,cpy);
end;

procedure map_CPoints_Default(num:byte;sr,cr,nr,energy,time:integer;lifetime:cardinal;newpoints:boolean);
var ix,iy,i,u,b,c:integer;
function _setcpoint(px,py:integer):boolean;
var pn:byte;
begin
   for pn:=1 to MaxCPoints do
    if(g_cpoints[pn].cpCapturer<=0)then break;

   if(pn>MaxCPoints)then
   begin
      _setcpoint:=true;
      exit;
   end
   else _setcpoint:=false;

   with g_cpoints[pn] do
   begin
      cpx       :=px;
      cpy       :=py;
      cpsolidr  :=sr;
      cpnobuildr:=nr;
      cpenergy  :=energy;
      cpCapturer:=cr;
      cpCaptureTime:=time;
      cplifetime   :=lifetime;
      {$IFDEF _FULLGAME}
      cpmx:=round(cpx*map_mmcx);
      cpmy:=round(cpy*map_mmcx);
      cpmr:=round(cpCapturer*map_mmcx);
      {$ENDIF}
   end;
end;
begin
   if(newpoints)then FillChar(g_cpoints,SizeOf(g_cpoints),0);
   u:=map_mw div 50;
   b:=map_mw-(u*2);

   i:=0;
   while(i<num)do
   begin
      i+=1+byte(map_symmetry);
      c:=0;
      while(c<1000)do
      begin
         ix:=u+_random(b);
         iy:=u+_random(b);

         if (not _PlayerStartHere(ix,iy,base_ir,map_symmetry))
         and(not _CPointHere(ix,iy,base_ir,map_symmetry))then
         begin
            if(_setcpoint(ix,iy))then exit;
            if(map_symmetry)then
             if(_setcpoint(map_mw-ix,map_mw-iy))then exit;
            break;
         end;
         c+=1;
      end;
   end;
end;

procedure map_Starts;
var ix,iy,i,u,c:integer;
begin
   for i:=0 to MaxPlayers do
   begin
      map_psx[i]:=-5000;
      map_psy[i]:=-5000;
   end;

   case g_mode of
gm_3x3 :
      begin
         ix:=map_mw div 2;
         iy:=base_rr+(map_mw div 25);
         u :=ix-(map_mw div 7);
         i :=map_seed mod 360;

         map_psx[1]:=trunc(ix+cos(i*degtorad)*u);
         map_psy[1]:=trunc(ix+sin(i*degtorad)*u);
         i+=105;
         map_psx[2]:=map_psx[1]+trunc(cos(i*degtorad)*iy);
         map_psy[2]:=map_psy[1]+trunc(sin(i*degtorad)*iy);
         i-=210;
         map_psx[3]:=map_psx[1]+trunc(cos(i*degtorad)*iy);
         map_psy[3]:=map_psy[1]+trunc(sin(i*degtorad)*iy);

         map_psx[4]:=map_mw-map_psx[1];
         map_psy[4]:=map_mw-map_psy[1];
         map_psx[5]:=map_mw-map_psx[2];
         map_psy[5]:=map_mw-map_psy[2];
         map_psx[6]:=map_mw-map_psx[3];
         map_psy[6]:=map_mw-map_psy[3];
      end;
gm_2x2x2:
      begin
         ix:=map_mw div 2;
         iy:=base_rr+(map_mw div 30);
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
gm_invasion:
      begin
         map_psx[0]:=map_hmw;
         map_psy[0]:=map_hmw;
         map_Starts_Circle(map_hmw,map_hmw,integer(map_seed),base_rr);
      end;
gm_KotH:
      begin
         map_psx[0]:=map_hmw;
         map_psy[0]:=map_hmw;
         map_Starts_Circle(map_hmw,map_hmw,integer(map_seed),map_hmw-(map_mw div 8));
         if(not g_fixed_positions)then map_ShuffleStarts;
      end;
gm_royale :
      begin
         map_Starts_Circle(map_hmw,map_hmw,integer(map_seed),map_hmw-(map_mw div 8));
         if(not g_fixed_positions)then map_ShuffleStarts;
      end;
gm_capture:
      begin
         map_Starts_Default;
         if(not g_fixed_positions)then map_ShuffleStarts;
      end;
   else
         map_Starts_Default;
         if(not g_fixed_positions)then map_ShuffleStarts;
   end;
end;

procedure map_CPoints;
begin
   FillChar(g_cpoints,SizeOf(g_cpoints),0);

   case g_mode of
gm_KotH   : with g_cpoints[1] do
            begin
               cpx:=map_hmw;
               cpy:=map_hmw;
               cpCapturer   :=base_r;
               cpCaptureTime:=fr_fps*60;

               {$IFDEF _FULLGAME}
               cpmx:=round(cpx*map_mmcx);
               cpmy:=round(cpy*map_mmcx);
               cpmr:=round(cpCapturer*map_mmcx)+1;
               {$ENDIF}
            end;
gm_capture: map_CPoints_Default(4,0,gm_cptp_r,base_r,0,gm_cptp_time,0,true);
   end;

   if(g_cgenerators>0)then
    map_CPoints_Default(MaxCPoints,50,gm_cptp_r,gm_cptp_r,500,gm_cptp_time,g_cgenerators_ltime[g_cgenerators],false);
end;

function _dec_min_r(t1,t2:byte):integer;
begin
   _dec_min_r:=DID_R[t1];
   if(t2 in dids_liquids)
  and(t1 in dids_liquids)then
   begin
      _dec_min_r:=DID_R[t1]+DID_R[t2]-(DID_R[t1] div 6)-(DID_R[t2] div 6);//max2(DID_R[t1],DID_R[t2])+64;
      exit;
   end;
   if(t2 in [DID_SRock,DID_BRock])then
   begin
      if(t1 in [DID_SRock,DID_BRock])then _dec_min_r:=     DID_R[t1]+DID_R[t2]-20;
      if(t1 in dids_liquids         )then _dec_min_r:=max2(DID_R[t1],DID_R[t2]);
   end;
end;

function _dnear(td:byte;ix,iy:pinteger):boolean;
var d:integer;
begin
   _dnear:=false;

   with map_dds[0] do
   if(map_symmetry)then
   begin
      t:=td;
      r:=DID_R[td];
      x:=map_mw-ix^;
      y:=map_mw-iy^;
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
   if(point_dist_rint(x,y,ix^,iy^)<_dec_min_r(t,td))then
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
     if(map_symmetry)then
     begin
        ix:=map_mw-ix;
        iy:=map_mw-iy;
        if(_dnear(di,@ix,@iy))
        or(_PlayerStartHere (ix,iy,doodad_r,false))then _checkPlace:=true;
     end;
end;

function _trysetdd(di:byte;ix,iy:pinteger;doodad_r:integer):boolean;
begin
   if(_checkPlace(di,ix^,iy^,doodad_r+(DID_R[di] div 2)))
   then _trysetdd:=false
   else
   begin
      _dds_a(ix^,iy^,di);
      if(map_symmetry)then _dds_a(map_mw-ix^,map_mw-iy^,di);
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

procedure map_make;
const dpostime = 400;
var i,ix,iy,lqs,rks,ddc,cnt,ir:integer;
begin
   map_ddn:=0;
   FillChar(map_dds,SizeOf(map_dds),0);
   for ix:=0 to dcn do
   for iy:=0 to dcn do
   with map_dcell[ix,iy] do
   begin
      n:=0;
      setlength(l,n);
   end;

   ddc:=trunc(MaxDoodads*((sqr(map_mw) div ddc_div)/ddc_cf))+1;

   if(map_symmetry)
   then ddc:=mm3(1,round(ddc/2),MaxDoodads)
   else ddc:=mm3(1,      ddc   ,MaxDoodads);

   rks :=0;
   lqs :=0;

   if(map_obs>0)then
   begin
      i:=(ddc div 8);
      if(map_liq>0)then
      begin
         ix :=(i*map_obs);
         lqs:=max2(map_liq,(ix div 8)*map_liq);
         rks:=max2(map_obs,ix-lqs);
      end
      else rks:=max2(map_obs,i*map_obs);
   end
   else lqs:=max2(map_liq,(ddc div 80)*map_liq);

   ir :=base_r+(map_mw div 100);
   ix :=map_seed;
   iy :=0;

   for i:=1 to ddc do
   begin
      cnt:=0;
      while true do
      begin
         ix:=_randomx(ix,map_mw);
         iy:=_randomx(iy,map_mw); //+ix*cnt

         if(_PickDoodad(@ix,@iy,@lqs,@rks,ir))then break;

         cnt+=1;
         if(cnt>=dpostime)then break;
      end;
   end;

   map_doodads_cells_refresh;

   map_RandomBase;
   map_CPoints;
   pf_make_grid;
   map_CPoints_UpdatePFZone;
   {$IFDEF _FULLGAME}
   map_DoodadsDrawData;
   map_RedrawMenuMinimap;
   map_tdmake;
   {$ENDIF}
end;

procedure Map_randomseed;
begin
   map_seed:=random($FFFFFFFF)+(SDL_GetTicks shl 5);
end;

procedure Map_randommap;
begin
   Map_randomseed;

   map_mw :=MinSMapW+round(random(MaxSMapW-MinSMapW)/StepSMap)*StepSMap;
   map_liq:=random(8);
   map_obs:=random(8);
   map_symmetry:=random(2)>0;
end;

procedure Map_premap;
begin
   map_vars;
   map_Starts;
   {$IFDEF _FULLGAME}
   map_seed2theme;
   map_tllbc;
   {$ENDIF}
   map_Make;
end;




