{$IFDEF _FULLGAME}

procedure _dds_anim(d:integer;sprl:PTUSpriteList;anml:PTThemeAnimL;lst:PTIntList;lstn:pinteger;first:boolean);
begin
   if(lstn^>0)then
    with map_dds[d] do
     if(animt>0)or(first)then
     begin
        dec(animt,1);
        if(animt<=0)then
        begin
           if(animn<0)or(first)then
           begin
              animn:= d mod lstn^;
              animn:= lst^[animn];
           end
           else
           begin
              animn:=anml^[animn].anext;
           end;
           animt:=_theme_anim_time(anml^[animn].atime);
           shh  := anml^[animn].sh;
           ox   := anml^[animn].xo;
           oy   := anml^[animn].yo;
           spr  :=@sprl^[animn];
           case anml^[animn].depth of
           0    : dpth :=y;
           else   dpth :=anml^[animn].depth;
           end;
        end;
     end;
end;

procedure _dds_p(onlyspr:boolean);
var d,
    ro :integer;
begin
   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t>0)then
     begin
        if(_rectvis(x,y,255,255)=false)then continue;

        ro:=0;
        if(0<=m_brush)and(m_brush<=255)then ro:=r-bld_dec_mr;

        if(onlyspr=false)or(spr=pspr_dummy)then
        case t of
        DID_LiquidR1,
        DID_LiquidR2,
        DID_LiquidR3,
        DID_LiquidR4 : begin
                          if(theme_liquid_animt<2)
                          then spr:=@spr_liquid[((G_Step div theme_liquid_animm) mod LiquidAnim)+1,animn]
                          else spr:=@spr_liquid[1,animn];
                       end;
        DID_Other    : _dds_anim(d,@theme_spr_decors,@theme_anm_decors,@theme_decors,@theme_decorn,false);
        DID_SRock    : _dds_anim(d,@theme_spr_srocks,@theme_anm_srocks,@theme_srocks,@theme_srockn,false);
        DID_BRock    : _dds_anim(d,@theme_spr_brocks,@theme_anm_brocks,@theme_brocks,@theme_brockn,false);
        end;

        if(_rectvis(x+ox,y+oy,spr^.hw,spr^.hh))then
        begin
           _sl_add_dec(x,y,dpth,shh,spr,255,ro,ox,oy);
           if(pspr<>nil)then _sl_add_dec(x,y,-10000,0,pspr,255,ro,ox,oy);
        end;
     end;
end;

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
   map_seed and 15,
   -((map_seed and $00000FF0) shr 4 ),
   -((map_seed and $000FF000) shr 12),
   -((map_seed and $0FF00000) shr 20),
   -((map_seed and $F0000000) shr 28));
end;

procedure _map_dds;
var d:integer;
begin
   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t>0)then
     begin
        dpth := y;
        shh  := 0;
        animn:= -1;
        animt:= 0;
        spr  := pspr_dummy;
        pspr := nil;
        ox   := 0;
        oy   := 0;

        case t of
        DID_LiquidR1,
        DID_LiquidR2,
        DID_LiquidR3,
        DID_LiquidR4: begin
                         dpth := -5;
                         mmc  := theme_liquid_color;
                         animn:= t;
                         pspr := @spr_liquidb[animn];
                      end;
        DID_other  :  begin
                         shh  := 1;
                         mmc  := c_gray;
                         _dds_anim(d,@theme_spr_decors,@theme_anm_decors,@theme_decors,@theme_decorn,true);
                      end;

        DID_Srock  :  begin
                         mmc  := c_dgray;
                         _dds_anim(d,@theme_spr_srocks,@theme_anm_srocks,@theme_srocks,@theme_srockn,true);
                      end;
        DID_Brock  :  begin
                         mmc  := c_dgray;
                         _dds_anim(d,@theme_spr_brocks,@theme_anm_brocks,@theme_brocks,@theme_brockn,true);
                      end;
        end;

        mmx:=round(x*map_mmcx);
        mmy:=round(y*map_mmcx);
        mmr:=max2(1,round(r*map_mmcx));
     end;
end;

{$ENDIF}

procedure _refresh_dmcells;
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
        dx0:=(x-r-dcw) div dcw;if(dx0<0)then dx0:=0;if(dx0>dcn)then dx0:=dcn;
        dy0:=(y-r-dcw) div dcw;if(dy0<0)then dy0:=0;if(dy0>dcn)then dy0:=dcn;
        dx1:=(x+r+dcw) div dcw;if(dx1<0)then dx1:=0;if(dx1>dcn)then dx1:=dcn;
        dy1:=(y+r+dcw) div dcw;if(dy1<0)then dy1:=0;if(dy1>dcn)then dy1:=dcn;
        while(dx0<=dx1)do
        begin
           for dy:=dy0 to dy1 do
            with map_dcell[dx0,dy] do
            begin
               inc(n,1);
               setlength(l,n);
               l[n-1]:=@map_dds[d];
            end;
           inc(dx0,1);
        end;
     end;
end;


procedure _dds_a(dx,dy:integer;dt:byte);
var d:integer;
begin
   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t=0)then
     begin
        case dt of
        DID_LiquidR1,
        DID_LiquidR2,
        DID_LiquidR3,
        DID_LiquidR4,
        DID_Brock,
        DID_Srock,
        DID_Other     : begin
                           t := dt;
                           r := DID_R[t];
                        end;
        else break;
        end;

        x:=dx;
        y:=dy;

        break;
     end;
end;


procedure map_vars;
begin
   map_seed2   := map_seed;
   if(g_mode=gm_inv)
   then map_aifly := false
   else map_aifly := ((map_liq+map_obs)>6)and(map_obs>2)and(map_liq>1);
   map_b1      := map_mw-build_b;
   {$IFDEF _FULLGAME}
   if(menu_s2<>ms2_camp)then
   begin
      if(map_mw<MinSMapW)then map_mw:=MinSMapW;
      if(map_mw>MaxSMapW)then map_mw:=MaxSMapW;
   end;
   map_flydpth[uf_ground ] := 0;
   map_flydpth[uf_soaring] := map_mw;
   map_flydpth[uf_fly    ] := map_mw*2;
   map_mmcx    := (vid_panelw-2)/map_mw;
   map_mmvw    := trunc(vid_sw*map_mmcx)+1;
   map_mmvh    := trunc(vid_sh*map_mmcx)+1;
   map_prmm    := round(g_ct_pr*map_mmcx);
   {$ENDIF}
end;

function _spch(x,y,m:integer):boolean;
var p:byte;
begin
   if(m<=0)then
   begin
      _spch:=true;
      exit;
   end;
   _spch:=false;

   for p:=0 to MaxPlayers do
    if(dist2(x,y,map_psx[p],map_psy[p])<m)then
    begin
       _spch:=true;
       break;
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
         inc(i,105);
         map_psx[2]:=map_psx[1]+trunc(cos(i*degtorad)*iy);
         map_psy[2]:=map_psy[1]+trunc(sin(i*degtorad)*iy);
         dec(i,210);
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

         inc(c,120);
         map_psx[3]:=trunc(ix+cos(c*degtorad)*u);
         map_psy[3]:=trunc(ix+sin(c*degtorad)*u);
         i:=c+100;
         map_psx[4]:=map_psx[3]+trunc(cos(i*degtorad)*iy);
         map_psy[4]:=map_psy[3]+trunc(sin(i*degtorad)*iy);

         inc(c,120);
         map_psx[5]:=trunc(ix+cos(c*degtorad)*u);
         map_psy[5]:=trunc(ix+sin(c*degtorad)*u);
         i:=c+100;
         map_psx[6]:=map_psx[5]+trunc(cos(i*degtorad)*iy);
         map_psy[6]:=map_psy[5]+trunc(sin(i*degtorad)*iy);
      end;
   gm_inv:
      begin
         map_psx[0]:=map_mw div 2;
         map_psy[0]:=map_psx[0];

         u :=base_ir;
         ix:=u div 4;
         iy:=ix div 2;
         i:=map_mw div 2;
         map_psx[1]:=i+u+iy;
         map_psy[1]:=i-ix;
         map_psx[2]:=i-u-iy;
         map_psy[2]:=i+ix;
         map_psx[3]:=i+ix;
         map_psy[3]:=i-u-iy;
         map_psx[4]:=i-ix;
         map_psy[4]:=i+u+iy;
         map_psx[5]:=i+u;
         map_psy[5]:=i+u;
         map_psx[6]:=i-u;
         map_psy[6]:=i-u;
      end;
   gm_coop:
      begin
         map_psx[0]:=map_mw div 2;
         map_psy[0]:=map_psx[0];

         u :=map_mw div 5;
         ix:=map_mw div 8;
         iy:=map_mw-ix;
         map_psx[1]:=ix;
         map_psy[1]:=ix+u;
         map_psx[2]:=ix;
         map_psy[2]:=iy-u;
         map_psx[3]:=iy;
         map_psy[3]:=iy-u;
         map_psx[4]:=iy;
         map_psy[4]:=ix+u;
         map_psx[5]:=map_psx[0];
         map_psy[5]:=ix;
         map_psx[6]:=map_psx[0];
         map_psy[6]:=map_mw-ix;
      end;
   else
      ix :=integer(map_seed) mod map_mw;
      iy :=(map_seed2*2+integer(map_seed)) mod map_mw;
      bb0:=base_r+(map_mw-MinSMapW) div 5;
      bb1:=map_mw-(bb0*2);
      dst:=(map_mw div 5)+base_r;

      for i:=1 to MaxPlayers do
      begin
         c:=0;
         u:=dst;
         repeat
           ix:=bb0+_gen(bb1);
           iy:=bb0+_gen(bb1);
           inc(c,1);
           inc(map_seed2,1);
           if(c>500 )then dec(u,1);
           if(c>1000)then break;
         until (_spch(ix,iy,u)=false)and(c<=2000);

         map_psx[i]:=ix;
         map_psy[i]:=iy;
      end;

      if(g_mode=gm_ct)then
      begin
         dst:=map_mw div 10;
         u:=map_mw-dst;
         for i:=1 to MaxPlayers do
          with g_ct_pl[i] do
          begin
             px:=i*102;
             py:=i*151;
             c:=0;
             repeat
               px:=_genx(px+py,map_mw,true);
               py:=_genx(py+px+c,map_mw,true);
               inc(c,1);
             until (_spch(px,py,base_rr-c)=false)and(px>dst)and(py>dst)and(px<u)and(py<u);

             {$IFDEF _FULLGAME}
             mpx:=round(px*map_mmcx);
             mpy:=round(py*map_mmcx);
             {$ENDIF}
          end;
      end;
   end;
end;

function _dnear(td:byte; ix,iy,md:integer):boolean;
var d,ir:integer;
begin
   _dnear:=false;
   for d:=1 to md do
    with map_dds[d] do
     if(t>0)then
     begin
        ir:=0;
        if(td in dids_liquids)and(t in dids_liquids)then ir:=DID_R[td] div 2;
        if(td in [DID_SRock,DID_BRock])then
        begin
           if(t in [DID_SRock,DID_BRock])then ir:= DID_R[td]-20;
           if(t in dids_liquids         )then ir:=-DID_R[td];
        end;

        if(dist2(x,y,ix,iy)<=(r+ir))then
        begin
           _dnear:=true;
           break;
        end;
     end;
end;


procedure map_make;
const dpostime = 300;
var i,ix,iy,lqs,rks,hrks,ddc,cnt:integer;
    di: byte;
begin
   {$IFDEF _FULLGAME}
   Map_tdmake;
   {$ENDIF}

   FillChar(map_dds,SizeOf(map_dds),0);
   for ix:=0 to dcn do
    for iy:=0 to dcn do
     with map_dcell[ix,iy] do
     begin
        n:=0;
        setlength(l,n);
     end;

   ddc:=trunc(MaxDoodads*((sqr(map_mw) div ddc_div)/ddc_cf));
   if(ddc>MaxDoodads)then ddc:=MaxDoodads;

   rks :=0;
   lqs :=0;

   if(map_obs>0)then
   begin
      i  :=(ddc div 8);
      if(map_liq>0)then
      begin
         ix:=(i*map_obs);
         lqs:=(ix div 8)*map_liq;
         rks:=ix-lqs;
      end
      else
      begin
         lqs:=0;
         rks:=(i*map_obs);
      end;
   end
   else
   begin
      lqs:=(ddc div 80)*map_liq;
   end;
   inc(ddc,50);
   if(ddc>MaxDoodads)then ddc:=MaxDoodads;

   hrks:=rks div 2;

   ix :=map_seed;
   iy :=0;

   for i:=1 to ddc do
   begin
      di:=0;
      if(lqs>0)then
      begin
         case i mod 12 of
         0..2 : di:=DID_liquidR1;
         3..5 : di:=DID_liquidR2;
         6..8 : di:=DID_liquidR3;
         9..11: di:=DID_liquidR4;
         end;
         dec(lqs,1);
      end
      else
        if(rks>0)then
        begin
           if(rks>hrks)
           then di:=DID_SRock
           else di:=DID_BRock;
           dec(rks,1);
        end
        else di:=DID_other;

      if(di=0)then continue;

      cnt:=0;
      repeat
         ix:=_genx(ix            ,map_mw,false);
         iy:=_genx(iy+sqr(cnt+ix),map_mw,true );
         inc(cnt,1);
         if(cnt>=dpostime)then break;
      until (_spch(ix,iy,base_r+200)=false)and(_dnear(di,ix,iy,i)=false)and(ix>=0)and(iy>=0)and(ix<=map_mw)and(iy<=map_mw);
      if(cnt>=dpostime)then continue;

      _dds_a(ix,iy,di);
   end;

   _refresh_dmcells;
   {$IFDEF _FULLGAME}
   _map_dds;
   _makeMMB;
   {$ENDIF}
end;

procedure Map_randomseed;
begin
   map_seed :=random($FFFFFFFF)+(SDL_GetTicks shl 5);
end;

procedure Map_randommap;
begin
   Map_randomseed;

   map_mw :=MinSMapW+round(random(MaxSMapW-MinSMapW)/500)*500;
   map_liq:=random(8);
   map_obs:=random(8);
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




