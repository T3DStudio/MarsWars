{$IFDEF _FULLGAME}

{$ENDIF}

procedure _dds_a2cell(ix,iy,id:integer);
var dx0,dy0,dx1,dy1,dy:integer;
begin
   with map_dds[id] do
   begin
      x:=ix;
      y:=iy;

      {$IFDEF _FULLGAME}
      shd:=0;
      xas:=abs((x+y+id) mod 2)>0;

      case t of
      DID_LiquidR1,
      DID_LiquidR2,
      DID_LiquidR3,
      DID_LiquidR4 : begin
                        a    := t;
                        mmc  := map_Liquidc[map_lqt];
                        dpth := -10000-y;
                     end;
      DID_BRock  :
                     begin
                        with map_themes[map_themec] do a    := _brcks[id mod _brckn];
                        mmc  := c_dgray;
                        dpth := y;
                     end;
      DID_SRock  :
                     begin
                        with map_themes[map_themec] do a    := _srcks[id mod _srckn];
                        mmc  := c_dgray;
                        dpth := y;
                     end;
      DID_Other  :
                     begin
                        with map_themes[map_themec] do a    := _tdecs[id mod _tdecn];
                        mmc  := c_gray;
                        dpth := y+r;
                        if(shd_TDecs[a]>0)
                        then shd  := 1
                        else shd  := 0;
                     end;
      else
      end;

      mmx:=round(x*map_mmcx);
      mmy:=round(y*map_mmcx);
      mmr:=round(r*map_mmcx);
      if(mmr<=0)then mmr:=1;

      {$ENDIF}

      dx0:=(x-r-100) div dcw;if(dx0<0)then dx0:=0;if(dx0>dcn)then dx0:=dcn;
      dy0:=(y-r-100) div dcw;if(dy0<0)then dy0:=0;if(dy0>dcn)then dy0:=dcn;
      dx1:=(x+r+100) div dcw;if(dx1<0)then dx1:=0;if(dx1>dcn)then dx1:=dcn;
      dy1:=(y+r+100) div dcw;if(dy1<0)then dy1:=0;if(dy1>dcn)then dy1:=dcn;

      while(dx0<=dx1)do
      begin
         for dy:=dy0 to dy1 do
          with map_dcell[dx0,dy] do
          begin
             inc(n,1);
             setlength(l,n);
             l[n-1]:=id;
          end;
         inc(dx0,1);
      end;
   end;
end;

function _dds_a(dt:integer):integer;
var d:integer;
begin
   _dds_a:=0;
   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t=0)then
     begin
        case dt of
        DID_LiquidR1,
        DID_LiquidR2,
        DID_LiquidR3,
        DID_LiquidR4,
        DID_BRock,
        DID_SRock,
        DID_Other    : r := DID_R[dt];
        else exit;
        end;

        t:=dt;

        _dds_a:=d;

        break;
     end;
end;


procedure map_vars;
begin
   map_seed2   := map_seed;
   if(map_mw<MinSMapW)then map_mw:=MinSMapW;
   if(map_mw>MaxSMapW)then map_mw:=MaxSMapW;
   if(map_liq>4)then map_liq:=4;
   if(map_obs>4)then map_obs:=4;
   {$IFDEF _FULLGAME}
   map_mmcx    := ui_mmwidth/map_mw;
   map_mmvw    := trunc(vid_mw*map_mmcx);
   map_mmvh    := trunc(ui_panely*map_mmcx);
   map_mmsp    := trunc(base_1r*map_mmcx);
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
var ix,iy,i,u,c,dst,bb0,bb1:integer;
begin
   for i:=0 to MaxPlayers do
   begin
      map_psx[i]:=-5000;
      map_psy[i]:=-5000;
   end;

   case g_mode of
   gm_tdm2 :
      begin
         ix:=map_mw div 2;
         iy:=base_yr+100;
         u :=ix-(ix div 3);
         i :=map_seed mod 360;

         map_psx[1]:=trunc(ix+cos(i*degtorad)*u);
         map_psy[1]:=trunc(ix+sin(i*degtorad)*u);
         inc(i,100);
         map_psx[2]:=map_psx[1]+trunc(cos(i*degtorad)*iy);
         map_psy[2]:=map_psy[1]+trunc(sin(i*degtorad)*iy);
         dec(i,200);
         map_psx[3]:=map_psx[1]+trunc(cos(i*degtorad)*iy);
         map_psy[3]:=map_psy[1]+trunc(sin(i*degtorad)*iy);

         map_psx[4]:=map_mw-map_psx[2];
         map_psy[4]:=map_mw-map_psy[2];
         map_psx[6]:=map_mw-map_psx[1];
         map_psy[6]:=map_mw-map_psy[1];
         map_psx[5]:=map_mw-map_psx[3];
         map_psy[5]:=map_mw-map_psy[3];
      end;
   gm_tdm3 :
      begin
         ix:=map_mw div 2;
         iy:=base_yr;
         u :=ix-(ix div 3);
         i :=map_seed mod 360;

         map_psx[1]:=trunc(ix+cos(i*degtorad)*u);
         map_psy[1]:=trunc(ix+sin(i*degtorad)*u);
         inc(i,100);
         map_psx[2]:=map_psx[1]+trunc(cos(i*degtorad)*iy);
         map_psy[2]:=map_psy[1]+trunc(sin(i*degtorad)*iy);

         inc(i,20);
         map_psx[3]:=trunc(ix+cos(i*degtorad)*u);
         map_psy[3]:=trunc(ix+sin(i*degtorad)*u);
         inc(i,100);
         map_psx[4]:=map_psx[3]+trunc(cos(i*degtorad)*iy);
         map_psy[4]:=map_psy[3]+trunc(sin(i*degtorad)*iy);

         inc(i,20);
         map_psx[5]:=trunc(ix+cos(i*degtorad)*u);
         map_psy[5]:=trunc(ix+sin(i*degtorad)*u);
         inc(i,100);
         map_psx[6]:=map_psx[5]+trunc(cos(i*degtorad)*iy);
         map_psy[6]:=map_psy[5]+trunc(sin(i*degtorad)*iy);
      end;
   else
      ix :=integer(map_seed) mod map_mw;
      iy :=(map_seed2*2+integer(map_seed)) mod map_mw;
      bb0:=base_1r+(map_mw-MinSMapW) div 5;
      bb1:=map_mw-(bb0*2);
      dst:=(map_mw div 5)+base_1r;

      for i:=1 to MaxPlayers do
      begin
         c:=0;
         u:=dst;
         repeat
           ix:=bb0+_gen(bb1);
           iy:=bb0+_gen(bb1);
           inc(c,1);
           inc(map_seed2,1);
           if(c>1000)then dec(u,1);
         until (_spch(ix,iy,u)=false)and(c<=2000);

         map_psx[i]:=ix;
         map_psy[i]:=iy;
      end;
   end;
end;

function _dnear(ix,iy,id:integer):boolean;
var d,ir:integer;
begin
   _dnear:=false;
   for d:=1 to MaxDoodads do
    if(d<>id)then
     with map_dds[d] do
      if(t>0)then
      begin
         ir:=0;
         if(map_dds[id].t in [DID_LiquidR1..DID_LiquidR4])and(t in [DID_LiquidR1..DID_LiquidR4])then ir:=map_dds[id].r div 2;
         if(map_dds[id].t in [DID_SRock,DID_BRock])then
         begin
            if(t in [DID_SRock,DID_BRock])then ir:=map_dds[id].r-20;
            if(t in [DID_LiquidR1..DID_LiquidR4])then ir:=-map_dds[id].r;
         end;

         if(dist2(x,y,ix,iy)<=(r+ir))then
         begin
            _dnear:=true;
            break;
         end;
      end;
end;

procedure Map_Make;
const _mcntt = 250;
      _mcntp = 1500;
var i,ix,iy,lqs,rks,rks2,ddc,cnt,ds,id:integer;
begin
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
   rks2:=0;
   lqs :=0;

   if(map_obs>0)then
   begin
      i  :=(ddc div 4);
      if(map_liq>0)then
      begin
         ix:=(i*map_obs);
         lqs:=(ix div 5)*map_liq;
         rks:=ix-lqs;
      end
      else
      begin
         lqs:=0;
         rks:=(i*map_obs);
      end;
      rks2:=rks div 2;
      rks :=rks-rks2;
   end
   else
   begin
      lqs:=(ddc div 20)*map_liq;
      inc(ddc,50);
      if(ddc>MaxDoodads)then ddc:=MaxDoodads;
   end;

   ix :=integer(map_seed)+map_mw;
   iy :=0;

   for i:=1 to ddc do
   begin
      id:=0;
      if(lqs>0)then
      begin
         case i mod 12 of
         0..2 : id:=_dds_a(DID_liquidR1);
         3..5 : id:=_dds_a(DID_liquidR2);
         6..8 : id:=_dds_a(DID_liquidR3);
         9..11: id:=_dds_a(DID_liquidR4);
         end;
         dec(lqs,1);
      end
      else
        if(rks>0)then
        begin
           id:=_dds_a(DID_SRock);
           dec(rks,1);
        end
        else
          if(rks2>0)then
          begin
             id:=_dds_a(DID_BRock);
             dec(rks2,1);
          end
          else id:=_dds_a(DID_Other);

      if(id=0)then break;

      cnt:=0;
      while (cnt<_mcntp) do
      begin
         ix:=_genx(ix,map_mw,false);
         iy:=_genx(iy+sqr(cnt+ix),map_mw,true);
         inc(cnt,1);

         case map_dds[id].t of
         DID_liquidR1,
         DID_liquidR2,
         DID_liquidR3,
         DID_liquidR4,
         DID_SRock,
         DID_BRock  : ds:=base_ir;
         else         ds:=base_hr;
         end;

         if((ix>=0)and(iy>=0)and(ix<=map_mw)and(iy<=map_mw))then
          if(cnt<_mcntt)then
          begin
             if(_spch(ix,iy,ds)=false)and(_dnear(ix,iy,id)=false)then break;
          end
          else
            if(_spch(ix,iy,ds)=false)then break;
      end;
      if(cnt>=_mcntp)
      then map_dds[id].t:=0
      else _dds_a2cell(ix,iy,id);
   end;
   {$IFDEF _FULLGAME}
   Map_tdmake;
   Map_minimapUPD;
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

   map_mw:=MinSMapW+round(random(MaxSMapW-MinSMapW)/500)*500;
   map_liq:=random(5);
   map_obs:=random(5);
end;

procedure Map_premap;
begin
   Map_Vars;
   MSkirmishStarts;
   {$IFDEF _FULLGAME}
   Map_lqttrt;
   MakeTerrain;
   MakeLiquid;
   MakeLiquidBack;
   {$ENDIF}
   Map_Make;
end;





