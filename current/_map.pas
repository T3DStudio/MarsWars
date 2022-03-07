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
      map_seed and $0000000F,
   -((map_seed and $00000FF0) shr 4 ),
   -((map_seed and $000FF000) shr 12),
   -((map_seed and $0FF00000) shr 20),
   -((map_seed and $F0000000) shr 28));
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
        dx0:=mm3(0,(x-r-dcw) div dcw,dcn);
        dy0:=mm3(0,(y-r-dcw) div dcw,dcn);
        dx1:=mm3(0,(x+r+dcw) div dcw,dcn);
        dy1:=mm3(0,(y+r+dcw) div dcw,dcn);
        while(dx0<=dx1)do
        begin
           for dy:=dy0 to dy1 do
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


procedure map_vars;
begin
   map_iseed   := word(map_seed);
   map_rpos    := byte(map_seed);
   map_b1      := map_mw-map_b0;
   map_hmw     := map_mw div 2;
   {$IFDEF _FULLGAME}
   if(menu_s2<>ms2_camp)then map_mw:=mm3(MinSMapW,map_mw,MaxSMapW);
   map_mmcx    := (vid_panelw-2)/map_mw;
   map_mmvw    := trunc(vid_cam_w*map_mmcx)+1;
   map_mmvh    := trunc(vid_cam_h*map_mmcx)+1;
   {$ENDIF}
end;

function _spch(x,y,m:integer;check_symmetry:boolean):boolean;
var p:byte;
begin
   if(m<=0)then
   begin
      _spch:=true;
      exit;
   end;
   _spch:=false;

   if(check_symmetry)then
    if(dist(x,y,map_mw-x,map_mw-y)<m)then
    begin
       _spch:=true;
       exit;
    end;

   for p:=0 to MaxPlayers do
   if(dist(x,y,map_psx[p],map_psy[p])<m)then
   begin
      _spch:=true;
      break;
   end;
end;

procedure MCircleStarts(cx,cy,sdir,r:integer);
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

procedure MSkirmishStarts;
var ix,iy,i,u,c,bb0,bb1,dst:integer;
begin
   for i:=0 to MaxPlayers do
   begin
      map_psx[i]:=-5000;
      map_psy[i]:=-5000;
   end;

   case g_mode of
gm_2fort :
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
gm_3fort:
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
gm_inv:
      begin
         map_psx[0]:=map_hmw;
         map_psy[0]:=map_hmw;

         MCircleStarts(map_hmw,map_hmw,integer(map_seed),base_rr);
      end;
gm_royl:
      MCircleStarts(map_hmw,map_hmw,integer(map_seed),map_hmw-(map_mw div 8));
gm_cptp:
      begin
         map_psx[0]:=map_hmw;
         map_psy[0]:=map_hmw;

         MCircleStarts(map_hmw,map_hmw,integer(map_seed),map_hmw-(map_mw div 9));

         c :=map_seed mod 360;
         u :=map_mw div 6;
         ix:=map_mw div 2;
         iy:=360-(360 div MaxCPoints);

         for i:=1 to MaxCPoints do
         with g_cpoints[i] do
         begin
            px:=trunc(ix+cos(c*degtorad)*u);
            py:=trunc(ix+sin(c*degtorad)*u);
            pr:=64+_random(256);
            c+=iy;

            {$IFDEF _FULLGAME}
            mpx:=round(px*map_mmcx);
            mpy:=round(py*map_mmcx);
            mpr:=round(pr*map_mmcx);
            {$ENDIF}
         end;
         map_psx[0]:=-5000;
         map_psy[0]:=-5000;
      end;
gm_aslt:
      begin
         c  :=map_seed mod 360;
         bb0:=base_rr-100;
         bb1:=map_hmw-(map_mw div 10);
         for i:=1 to 3 do
         begin
            map_psx[i  ]:=map_hmw+trunc(cos(c*degtorad)*bb0);
            map_psy[i  ]:=map_hmw+trunc(sin(c*degtorad)*bb0);
            c+=60;
            map_psx[i+3]:=map_hmw+trunc(cos(c*degtorad)*bb1);
            map_psy[i+3]:=map_hmw+trunc(sin(c*degtorad)*bb1);
            c+=60;
         end;
         map_psx[0]:=map_hmw;
         map_psy[0]:=map_hmw;
      end;
   else
      ix :=abs(integer(map_seed)) mod map_mw;
      iy :=0;
      bb0:=base_r+(map_mw-MinSMapW) div 6;
      bb1:=map_mw-(bb0*2);
      dst:=(map_mw div 5)+base_r;

      for i:=1 to MaxPlayers do
      begin
         if(map_sym)and(i>3)then break;
         c:=0;
         u:=dst;
         while true do
         begin
            ix:=bb0+_random(bb1);
            iy:=bb0+_random(bb1);
            c+=1;
            if(c>500 )then u-=1;

            if(c>1000)
            or(_spch(ix,iy,u,map_sym)=false)then break;
         end;

         map_psx[i]:=ix;
         map_psy[i]:=iy;
         if(map_sym)then
         begin
            map_psx[i+3]:=map_mw-map_psx[i];
            map_psy[i+3]:=map_mw-map_psy[i];
         end;
      end;
   end;
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
   if(map_sym)then
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
   if(dist2(x,y,ix^,iy^)<_dec_min_r(t,td))then
   begin
      _dnear:=true;
      break;
   end;
end;

function _checkPlace(di:byte;ix,iy,doodad_r:integer):boolean;
begin
   _checkPlace:=false;
   if(_dnear(di,@ix,@iy))
   or(_spch (ix,iy,doodad_r,false))
   then _checkPlace:=true
   else
     if(map_sym)then
     begin
        ix:=map_mw-ix;
        iy:=map_mw-iy;
        if(_dnear(di,@ix,@iy))
        or(_spch (ix,iy,doodad_r,false))then _checkPlace:=true;
     end;
end;

function _trysetdd(di:byte;ix,iy:pinteger;doodad_r:integer):boolean;
begin
   if(_checkPlace(di,ix^,iy^,doodad_r+(DID_R[di] div 2)))
   then _trysetdd:=false
   else
   begin
      _dds_a(ix^,iy^,di);
      if(map_sym)then _dds_a(map_mw-ix^,map_mw-iy^,di);
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

   if(map_sym)
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
   pf_make_grid;
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
   map_sym:=random(2)>0;
end;

procedure Map_premap;
begin
   map_vars;
   mSkirmishStarts;
   {$IFDEF _FULLGAME}
   map_seed2theme;
   map_tllbc;
   {$ENDIF}
   map_Make;
end;




