{$IFDEF _FULLGAME}
procedure _dds_p(onlyspr:boolean);
var d,
    ro :integer;
begin
   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t>0)then
     begin
        ro:=0;
        if(0<=m_sbuild)and(m_sbuild<=_uts)then ro:=r-bld_dec_mr;

        if(t in dids_liquids)then
        begin
           if(onlyspr=false)then inc(a,1);
           a:=a mod vid_2fps;
           spr:=@spr_liquid[(a div vid_hfps)+1,t-DID_LiquidR1];
        end;

        if((vid_vx-spr^.hw+vid_panel)<x)and(x<(vid_vx+vid_mw+spr^.hw))and
          ((vid_vy-spr^.hh)          <y)and(y<(vid_vy+vid_mh+spr^.hh))then
           _sl_add(x-spr^.hw, y-spr^.hh,dpth,shh,0,0,false,spr^.surf,255,0,0,0,0,'',ro);
     end;
end;

procedure _bmm_draw(sd:TSob);
var d:integer;
begin
   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t in sd)then
      if(mmr>0)
      then FilledcircleColor(_bminimap,mmx,mmy,mmr,mmc)
      else pixelColor(_bminimap,mmx,mmy,mmc);
end;

procedure map_bminimap;
begin
   sdl_FillRect(_bminimap,nil,0);
   _bmm_draw(dids_liquids);
   _bmm_draw([DID_other,DID_srock,DID_brock]);
end;

procedure map_dstarts;
const start_char : char = '+';
var i  :byte;
    x,y:integer;
    c  :cardinal;
begin
   for i:=0 to MaxPlayers do
   begin
      if(g_mode=gm_inv)and(i=0)then continue;

      x:=trunc(map_psx[i]*map_mmcx);
      y:=trunc(map_psy[i]*map_mmcx);

      c:=plcolor[i];

      characterColor(_minimap,x-3,y-3,start_char,c);
      circleColor(_minimap,x,y,trunc(base_r*map_mmcx),c);

      if(g_mode=gm_ct)and(i>0)then
       with g_ct_pl[i] do
        filledcircleColor(_minimap,mpx,mpy,map_prmm,c_aqua);
   end;
end;

procedure _makeMMB;
begin
   sdl_FillRect(_minimap,nil,0);
   map_bminimap;
   _draw_surf(_minimap,0,0,_bminimap);
   if(g_shpos)or(g_mode in [gm_inv,gm_2fort,gm_3fort])then map_dstarts;
   _draw_surf(spr_mback,ui_menu_map_x0,ui_menu_map_y0,_minimap);
   rectangleColor(spr_mback,ui_menu_map_x0,ui_menu_map_y0,ui_menu_map_x0+_minimap^.w,ui_menu_map_y0+_minimap^.h,c_white);
   vid_mredraw:=true;
end;

procedure _dds_spr;
var d:integer;
begin
   for d:=1 to MaxDoodads do
    with map_dds[d] do
    begin
       spr :=@spr_dummy;

       case t of
       DID_other : if(map_hell)then begin if(spr_decshi  >0)then begin a := d mod spr_decshi;   spr := @spr_decsh  [a];end; end else if(spr_decsi  >0)then begin a := d mod spr_decsi;   spr := @spr_decs  [a];end;
       DID_Srock : if(map_hell)then begin if(spr_srockshi>0)then begin a := d mod spr_srockshi; spr := @spr_srocksh[a];end; end else if(spr_srocksi>0)then begin a := d mod spr_srocksi; spr := @spr_srocks[a];end;
       DID_Brock : if(map_hell)then begin if(spr_brockshi>0)then begin a := d mod spr_brockshi; spr := @spr_brocksh[a];end; end else if(spr_brocksi>0)then begin a := d mod spr_brocksi; spr := @spr_brocks[a];end;
       end;
    end;
end;

procedure Map_lqttrt;
begin
   map_hell:=false;
   map_trt :=1+(((map_seed and $0000FF00) shr 8 ) mod 23);
   map_crt :=  (((map_seed and $00FF0000) shr 16) mod 24);
   if(map_trt=7)
   then map_lqt:=map_seed mod 4
   else map_lqt:=map_seed mod 5;
   if(map_trt in [0,17])then
   begin
      map_lqt :=4;
      map_hell:=true;
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
               l[n-1]:=d;
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
        DID_Other,
        DID_LiquidR1,
        DID_LiquidR2,
        DID_LiquidR3,
        DID_LiquidR4,
        DID_Srock,
        DID_Brock     : begin
                           t := dt;
                           r := DID_R[t];
                        end;
        else break;
        end;

        x:=dx;
        y:=dy;

        {$IFDEF _FULLGAME}
        dpth:= y;
        shh := 0;
        a   := 0;

        case t of
        DID_other  :  begin
                         shh  := 1;
                         mmc  := c_gray;
                      end;
        DID_LiquidR1,
        DID_LiquidR2,
        DID_LiquidR3,
        DID_LiquidR4: begin
                         dpth := -5;
                         mmc  := map_mm_liqc;
                      end;
        DID_Srock  :  begin
                         dpth := 0;
                         mmc  := c_dgray;
                      end;
        DID_Brock  :  begin
                         dpth := 0;
                         mmc  := c_dgray;
                      end;
        end;

        mmx:=round(x*map_mmcx);
        mmy:=round(y*map_mmcx);
        if(r<20)
        then mmr:=1
        else mmr:=round(r*map_mmcx);
        {$ENDIF}

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
   map_cx      := map_mw div 2;
   {$IFDEF _FULLGAME}
   if(menu_s2<>ms2_camp)then
   begin
      if(map_mw<MinSMapW)then map_mw:=MinSMapW;
      if(map_mw>MaxSMapW)then map_mw:=MaxSMapW;
   end;
   map_flydpth[uf_ground ] := 0;
   map_flydpth[uf_soaring] := map_mw;
   map_flydpth[uf_fly    ] := map_mw*2;
   map_mmcx    := (vid_panel-2)/map_mw;
   map_mmvw    := trunc((vid_mw-vid_panel)*map_mmcx)+1;
   map_mmvh    := trunc( vid_mh*map_mmcx)+1;
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

procedure MCircleStarts(cx,cy,sdir,r:integer);
const dstep = 360 div MaxPlayers;
var i:byte;
begin
   for i:=1 to MaxPlayers do
   begin
      inc(sdir,dstep);
      map_psx[i]:=trunc(cx+r*cos(sdir*degtorad));
      map_psy[i]:=trunc(cy+r*sin(sdir*degtorad));
   end;
   for cx:=1 to 32 do
   begin
      i:=_genx(sdir,MaxPlayers,false)+1;
      r:=_genx(cx+i,MaxPlayers,false)+1;
      if(i=r)then continue;

      cy:=map_psx[i];map_psx[i]:=map_psx[r];map_psx[r]:=cy;
      cy:=map_psy[i];map_psy[i]:=map_psy[r];map_psy[r]:=cy;
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
         iy:=base_rr+(map_mw div 20);
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
         map_psx[0]:=map_cx;
         map_psy[0]:=map_cx;

         MCircleStarts(map_cx,map_cx,integer(map_seed),base_rr+100);
      end;
gm_royl:
      begin
         //map_psx[0]:=map_cx;
         //map_psy[0]:=map_cx;

         MCircleStarts(map_cx,map_cx,integer(map_seed),map_cx-(map_mw div 8));
      end;
gm_ct:begin
         MCircleStarts(map_cx,map_cx,integer(map_seed),map_cx-(map_mw div 8));

         c :=map_seed mod 360;
         ix:=map_mw div 2;
         iy:=360-(360 div MaxPlayers);
         u := map_mw div 5;

         for i:=1 to MaxPlayers do
         with g_ct_pl[i] do
         begin
            px:=trunc(ix+cos(c*degtorad)*u);
            py:=trunc(ix+sin(c*degtorad)*u);
            inc(c,iy);

            {$IFDEF _FULLGAME}
            mpx:=round(px*map_mmcx);
            mpy:=round(py*map_mmcx);
            {$ENDIF}
         end;
         map_psx[0]:=-5000;
         map_psy[0]:=-5000;
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


procedure Map_Make;
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
   _makeMMB;
   _dds_spr;
   {$ENDIF}
end;

procedure Map_randomseed;
begin
   map_seed :=random($FFFFFFFF)+SDL_GetTicks;
   {$IFDEF _FULLGAME}
   map_lqttrt;
   {$ENDIF}
end;

procedure Map_randommap;
begin
   map_randomseed;

   map_mw :=MinSMapW+round(random(MaxSMapW-MinSMapW)/500)*500;
   map_liq:=random(8);
   map_obs:=random(8);
end;

procedure Map_premap;
begin
   Map_Vars;
   MSkirmishStarts;
   {$IFDEF _FULLGAME}
   Map_lqttrt;
   MakeTerrain;
   MakeLiquid;
   {$ENDIF}
   Map_Make;
end;




