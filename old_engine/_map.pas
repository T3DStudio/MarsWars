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
   map_seed and 15,
   -((map_seed and $00000FF0) shr 4 ),
   -((map_seed and $000FF000) shr 12),
   -((map_seed and $0FF00000) shr 20),
   -((map_seed and $F0000000) shr 28));
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
   if(map_ddn>=MaxDoodads)then exit;

   inc(map_ddn,1);

   with map_dds[map_ddn] do
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
      else exit;
      end;

      x:=dx;
      y:=dy;
   end;

   {for d:=1 to MaxDoodads do
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
                           inc(map_ddn,1);
                        end;
        else break;
        end;

        x:=dx;
        y:=dy;

        break;
     end;}
end;


procedure map_vars;
begin
   map_seed2   := map_seed;
   map_b1      := map_mw-map_b0;
   map_hmw     := map_mw div 2;
   {$IFDEF _FULLGAME}
   if(menu_s2<>ms2_camp)then map_mw:=mm3(MinSMapW,map_mw,MaxSMapW);
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
   gm_aslt,
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
         map_psx[0]:=map_hmw;
         map_psy[0]:=map_hmw;

         MCircleStarts(map_hmw,map_hmw,integer(map_seed),base_rr);
      end;
   gm_ct:
      begin
         map_psx[0]:=map_hmw;
         map_psy[0]:=map_hmw;

         MCircleStarts(map_hmw,map_hmw,integer(map_seed),map_hmw-(map_mw div 8));

         c :=map_seed mod 360;
         ix:=map_mw div 2;
         iy:=360-(360 div MaxCPoints);
         u := map_mw div 5;

         for i:=1 to MaxCPoints do
         with g_cpt_pl[i] do
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
      if(map_sym)
      then MCircleStarts(map_hmw,map_hmw,integer(map_seed),map_hmw-(map_mw div 8))
      else
      begin
      ix :=integer(map_seed) mod map_mw;
      iy :=(map_seed2*2+integer(map_seed)) mod map_mw;
      bb0:=base_r+(map_mw-MinSMapW) div 5;
      bb1:=map_mw-(bb0*2);
      dst:=(map_mw div 5)+base_r;

      for i:=1 to MaxPlayers do
      begin
         c:=0;
         u:=dst;
         while true do
         begin
           ix:=bb0+_gen(bb1);
           iy:=bb0+_gen(bb1);
           inc(c,1);
           inc(map_seed2,1);
           if(c>500 )then dec(u,1);
           if(c>1000)or(_spch(ix,iy,u)=false)then break;
         end;

         map_psx[i]:=ix;
         map_psy[i]:=iy;
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
      _dec_min_r:=max2(DID_R[t1],DID_R[t2])+64;
      exit;
   end;
   if(t2 in [DID_SRock,DID_BRock])then
   begin
      if(t1 in [DID_SRock,DID_BRock])then _dec_min_r:=DID_R[t1]+DID_R[t2]-20;
      if(t1 in dids_liquids         )then _dec_min_r:=max2(DID_R[t1],DID_R[t2]);
   end;
end;

function _dnear(td:byte;ix,iy:pinteger):boolean;
var d,ir:integer;
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

function _trysetdd(di:byte;ix,iy:pinteger):boolean;
begin
   if(_dnear(di,ix,iy))or(_spch(ix^,iy^,base_ir))
   then _trysetdd:=false
   else
   begin
      _dds_a(ix^,iy^,di);
      if(map_sym)then _dds_a(map_mw-ix^,map_mw-iy^,di);
      _trysetdd:=true;
   end;
end;

function _pickdds(ix,iy,lqs,rks:pinteger):boolean;
var di:byte;
begin
   _pickdds:=false;
   for di:=DID_liquidR1 to DID_Other do
    case di of
    DID_LiquidR1,
    DID_LiquidR2,
    DID_LiquidR3,
    DID_LiquidR4  : if(lqs^<=0)
                    then continue
                    else
                      if(_trysetdd(di,ix,iy))then
                      begin
                         _pickdds:=true;
                         dec(lqs^,1);
                         break;
                      end
                      else continue;
    DID_SRock,
    DID_BRock     : if(rks^<=0)
                    then continue
                    else
                      if(_trysetdd(di,ix,iy))then
                      begin
                         _pickdds:=true;
                         dec(rks^,1);
                         break;
                      end
                      else continue;
    else
      if(_trysetdd(di,ix,iy))then
      begin
         _pickdds:=true;
         break;
      end
      else continue;
    end;
end;

procedure map_make;
const dpostime = 400;
var i,ix,iy,lqs,rks,ddc,cnt:integer;
begin
   {$IFDEF _FULLGAME}
   Map_tdmake;
   {$ENDIF}

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
   if(ddc>MaxDoodads)then ddc:=MaxDoodads;

   if(map_sym)then ddc:=ddc div 3;

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
   else lqs:=(ddc div 80)*map_liq;

   ix :=map_seed*map_obs*map_liq;
   iy :=0;

   for i:=1 to ddc do
   begin
      cnt:=0;
      while true do
      begin
         if(map_sym)
         then ix:=_genx(ix,map_hmw,false)
         else ix:=_genx(ix,map_mw ,false);
         iy:=_genx(iy+ix*cnt,map_mw,true);

         if(_pickdds(@ix,@iy,@lqs,@rks))then break;

         inc(cnt,1);
         if(cnt>=dpostime)then break;
      end;
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




