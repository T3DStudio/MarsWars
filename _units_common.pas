
function _calcMslPoint(sx:integer;tu:PTUnit;itx:boolean):integer;
begin
   with (tu^) do
    if(itx)
    then _calcMslPoint:=x+(sx mod puid^._r)-(puid^._r shr 1)
    else _calcMslPoint:=y+(sx mod puid^._r)-(puid^._r shr 1);
end;

procedure _unit_correctcoords(pu:PTUnit);
begin;
   with (pu^) do
   begin
      if(x<1)then x:=1;
      if(y<1)then y:=1;
      if(x>map_mw)then x:=map_mw;
      if(y>map_mw)then y:=map_mw;
   end;
end;

procedure _unit_uteleport(pu:PTUnit;tx,ty:integer);
begin
   with (pu^) do
    if(bld)then
     with (puid^) do
      with _players[player] do
      begin
         {$IFDEF _FULLGAME}
         _effect_uadd(pu,EID_Teleport);
         if(_nhp3(vx,vy,player) or _nhp3(tx,ty,player))then PlayUSND(snd_teleport);
         {$ENDIF}

         x :=tx;
         y :=ty;
         vx:=x;
         vy:=y;
         buff[ub_teleff]:=vid_h2fps;

         _unit_correctcoords(pu);
         {$IFDEF _FULLGAME}
         _effect_uadd(pu,EID_Teleport);
         _unit_sfog(pu);
         _unit_mmcoords(pu);
         {$ENDIF}
      end;
end;

function _canmove(pu:PTUnit):boolean;
begin
   with (pu^) do
   with (puid^) do
   begin
      _canmove:=false;

      if(speed=0)or(bld=false)or(hits<0)or(buff[ub_cast]>0)or(a_rld>0)then exit;

      if(_itmech)then
      begin

      end
      else
      begin
         if(buff[ub_pain]>0)then exit;
      end;
      {
      if(uo_tar=tar1)and(uo_tar>0)then
       if(melee=false)
       then exit
       else
         if(dtar<(r+_units[tar1].r+melee_r))then exit;

      case uid of
        UID_Terminator,
        UID_Tank : if(rld>0)
                   or(buff[ub_gear]>0)
                   then exit;
        UID_Flyer: if(buff[ub_gear]>0)
                   then exit
                   else
                     if(buff[ub_advanced]=0)then
                      if(rld>0)then exit;
        UID_UTransport,
        UID_Dron,
        UID_APC,
        UID_FAPC : if(buff[ub_gear]>0)then exit;
        UID_UCommandCenter : if(buff[ub_clcast]>0)then exit;
      else
        if(rld>0)
        or(buff[ub_pain ]>0)
        or(buff[ub_toxin]>0)
        or(buff[ub_gear]>0)
        then exit;
      end;
      }
      _canmove:=true;
   end;
end;

function _canattack(pu:PTUnit):boolean;
begin
   _canattack:=false;
   with(pu^)do
    if(bld)then
     with(puid^)do
      case _itattack of
    atm_none   : exit;
    atm_bunker,
    atm_stturr : if(apcc =0)then exit;
    atm_inapc  : if(inapc=0)then exit;
      else
         if(inapc>0)then
         begin
            if(_units[inapc].inapc>0)then exit;
            case _units[inapc].puid^._itattack of
          atm_none,
          atm_stturr: exit;
            end;
         end;
      end;
   _canattack:=true;
end;

function _unit_grbcol(tx,ty,tr:integer;pl,tuf:byte;doodc,chbuild:boolean):byte;
var u,
    dx,
    dy  :integer;
    nbld:boolean;
begin
   _unit_grbcol:=0;
   nbld:=(pl>MaxPlayers);

   if(race_pstyle[chbuild,_players[pl].race]=false)then nbld:=true;

   for u:=1 to MaxUnits do
    with _units[u] do
     if(hits>0)and(inapc=0)then
      if((speed=0)or(bld=false))and(uf=tuf)and(dist(x,y,tx,ty)<(tr+puid^._r))then
      begin
         _unit_grbcol:=1;
         break;
      end
      else
        if(nbld=false)and(player=pl)and(bld)then
        begin
           case chbuild of
           false: if(race_pstyle[chbuild,_players[pl].race])and(itwarea=false)then continue;
           true : if(race_pstyle[chbuild,_players[pl].race])and(itbarea=false)then continue;
           end;
           if(dist(x,y,tx,ty)<=srng)then nbld:=true;
        end;

   if(_unit_grbcol=0)then
   begin
      if(nbld=false)and(pl<=MaxPlayers)then
      begin
         _unit_grbcol:=2;
         exit;
      end;

      if(doodc=false)or(tuf>uf_ground)then exit;

      dec(tr,bld_dec_mr);

      dx:=(tx div dcw); if(dx<0)then dx:=0;if(dx>dcn)then dx:=dcn;
      dy:=(ty div dcw); if(dy<0)then dy:=0;if(dy>dcn)then dy:=dcn;

      with map_dcell[dx,dy] do
       for u:=1 to n do
        with map_dds[l[u-1]] do
         if(r>0)and(t>0)then
          if(dist(x,y,tx,ty)<(tr+r))then
          begin
             _unit_grbcol:=1;
             break;
          end;
   end;
end;


procedure _unit_def(pu:PTUnit);
begin
   with (pu^) do
   begin
      a_rld   := 0;

      {$IFDEF _FULLGAME}
      anim    := 0;

      _unit_mmcoords(pu);
      _unit_sfog(pu);
      {$ENDIF}
   end;
end;

/////////////////////////////////////////////////////////////////////////////////
////
////   COUNTERS
////
////////

procedure _unit_bldcntinc(pu:PTUnit);
begin
   with (pu^) do
    with (puid^) do
     with _players[player] do
     begin
        if(uid_u0[uid]=0)then uid_u0[uid]:=unum;
        inc(uid_eb[uid],1);
        if(_itbuilder)then inc(_bldrs,1);
        if(_itbarrack)then inc(_brcks,1);
        if(_itsmith  )then inc(_smths,1);
     end;
end;
procedure _unit_bldcntdec(pu:PTUnit);
begin
   with (pu^) do
    with (puid^) do
     with _players[player] do
     begin
        if(uid_u0[uid]=unum)then uid_u0[uid]:=0;
        dec(uid_eb[uid],1);
        if(_itbuilder)then dec(_bldrs,1);
        if(_itbarrack)then dec(_brcks,1);
        if(_itsmith  )then dec(_smths,1);
     end;
end;

procedure _unit_selcntinc(pu:PTUnit);
begin
   with (pu^) do
    with (puid^) do
     with _players[player] do
     begin
        inc(uid_s[uid],1);
        inc(sarmy,1);
        if(_itbuild)
        then inc(uid_sb,1)
        else inc(uid_su,1);
        if(_itbuilder)then inc(_sbldrs,1);
        if(_itbarrack)then inc(_sbrcks,1);
        if(_itsmith  )then inc(_ssmths,1);
     end;
end;
procedure _unit_selcntdec(pu:PTUnit);
begin
   with (pu^) do
    with (puid^) do
     with _players[player] do
     begin
        dec(uid_s[uid],1);
        dec(sarmy,1);
        if(_itbuild)
        then dec(uid_sb,1)
        else dec(uid_su,1);
        if(_itbuilder)then dec(_sbldrs,1);
        if(_itbarrack)then dec(_sbrcks,1);
        if(_itsmith  )then dec(_ssmths,1);
     end;
end;

/////////////////////////////////////////////////////////////////////////////////
////
////   CREATE
////
////////

procedure _unitCreate(ax,ay:integer;aid,apl:byte;abl:boolean=true;creff:boolean=false);
var u0,u1:integer;
begin
   _lcu :=0;
   _lcup:=@_units[_lcu];

   if not(apl in [1..MaxPlayers])then exit;

   u0:=MaxPlayerUnits*apl+1-MaxPlayerUnits;
   u1:=u0+MaxPlayerUnits;
   while (u0<u1) do
   begin
      with _units[u0] do
       if(hits<=dead_hits)then
       begin
          _lcu :=u0;
          _lcup:=@_units[u0];
          break;
       end;
      inc(u0,1);
   end;

   if(_lcu>0)then
    with _players[apl] do
    with _lcup^ do
    begin
       x       := ax;
       y       := ay;
       uid     := aid;
       player  := apl;
       _unit_correctcoords(_lcup);

       vx      := x;
       vy      := y;

       sel     := false;
       apcc    := 0;
       inapc   := 0;
       FillChar(buff,sizeof(buff),0);
       FillChar(vsnt,SizeOf(vsnt),0);
       FillChar(vsni,SizeOf(vsni),0);

       order   := 0;
       up_t    := 0;
       up_r    := 0;
       un_t    := 0;
       un_r    := 0;

       mdir    := 270;
       tdir    := mdir;
       pains   := 0;

       mv_x    := x;
       mv_y    := y;

       uo_id [0]:=0;
       uo_tar[0]:=0;
       uo_x  [0]:=0;
       uo_y  [0]:=0;
       uo_n     :=0;

       a_tar   := 0;
       zfall   := 0;

       _unit_sclass(_lcup);
       _unit_def(_lcup);

       vsnt[0]:=_bufinf;
       vsnt[_players[player].team]:=_bufinf;
       vsni:=vsnt;

       inc(army,1);
       inc(uid_e[uid],1);

       with(puid^)do
       begin
          un_rx   := x;
          if(_solid)
          then un_ry   := y+puid^._r+12
          else un_ry   := y;
          un_rtar := 0;

          if(_itbuild)
          then inc(uid_b,1)
          else inc(uid_u,1);

          if(abl)then
          begin
             bld := true;
             _unit_bldcntinc(_lcup);

             inc(menerg,_generg);
          end
          else
          begin
             bld  := false;
             hits := 10;

             inc(cenerg,_renerg);
          end;
       end;

       if(creff)then
       begin
          {$IFDEF _FULLGAME}
          _ueff_create(_lcup);
          {$ENDIF}
          buff[ub_born]:=vid_h2fps;
       end;
    end;
end;

/////////////////////////////////////////////////////////////////////////////////
////
////   REMOVE
////
////////

procedure _unit_remove(pu:PTUnit);
begin
   with (pu^) do
    with _players[player] do
    begin
       dec(army,1);
       dec(uid_e[uid],1);
       with (puid^) do
        if(_itbuild)
        then dec(uid_b,1)
        else dec(uid_u,1);

       {if(G_WTeam=255)then
        if(player<>0)then
         if(army=0)and(menu_s2<>ms2_camp)and(state>ps_none)then net_chat_add(chr(player)+name+str_player_def);}
    end;
end;

/////////////////////////////////////////////////////////////////////////////////
////
////   TRANSPORT
////
////////

procedure _unit_kickfromapc(pu,tu:PTUnit);
begin
   with (pu^) do
   with (puid^) do
   begin
      tu^.inapc:=0;
      dec(apcc,tu^.puid^._apcs);
      tu^.x:=tu^.x-(_r shr 1)+random(_r);
      tu^.y:=tu^.y-(_r shr 1)+random(_r);
      {tu^.uo_n     :=0;
      tu^.uo_id [0]:=0;
      tu^.uo_tar[0]:=0;
      tu^.uo_x  [0]:=tu^.x;
      tu^.uo_y  [0]:=tu^.y;  }
   end;
end;

procedure _unit_unload(pu:PTUnit);
var i:integer;
   tu:PTUnit;
begin
   {$IFDEF _FULLGAME}
   if(pu^.apcc>0)then PlayUSND(snd_inapc,pu);
   {$ENDIF}
   for i:=1 to MaxUnits do
    if(i<>pu^.unum)then
    begin
       tu:=@_units[i];
       if(tu^.hits>0)and(tu^.inapc=pu^.unum)then _unit_kickfromapc(pu,tu);
    end;
end;

function _itcanapc(uu,tu:PTUnit):boolean;
begin
   // uu - apc
   // tu - target unit
   _itcanapc:=false;

   if(tu^.player<>uu^.player)or(uu^.bld=false)or(tu^.bld=false)then exit;
   if(uu^.puid^._uf<tu^.puid^._uf)or(tu^.inapc>0)then exit;
   if not(tu^.uid in uu^.puid^._apcuids)then exit;
   if((uu^.puid^._apcm-uu^.apcc)<tu^.puid^._apcs)then exit;

   _itcanapc:=true;
end;

procedure _loadunit(uu,tu:PTUnit);
begin
   with (uu^  ) do
   with (puid^) do
   begin
      {$IFDEF _FULLGAME}
      PlayUSND(snd_inapc,uu);
      {$ENDIF}
      inc(apcc,tu^.puid^._apcs);
      if(tu^.sel)then
      begin
         _unit_selcntdec(tu);
         tu^.sel:=false;
      end;
      tu^.uo_n     :=0;
      tu^.uo_id [0]:=0;
      tu^.uo_tar[0]:=0;
      tu^.uo_x  [0]:=tu^.x;
      tu^.uo_y  [0]:=tu^.y;
      tu^.inapc :=unum;
   end;
end;

/////////////////////////////////////////////////////////////////////////////////
////
////   PRODUCTION
////
////////

function _unit_sunt(pu:PTUnit;ut:byte):boolean;
begin
   _unit_sunt:=false;
   with (pu^) do
   with (puid^) do
    if(un_r=0)and(bld)and(_itbarrack)then
     with _players[player] do
      if(_unitBC(player,ut)=false)then
       if(_tuids[ut]._ctime>0)then
       begin
          un_t:=ut;

          inc(uidip[un_t],1);
          inc(uidsip,1);
          inc(cenerg,_tuids[un_t]._renerg);
          un_r:=_tuids[un_t]._ctime;

          _unit_sunt:=true;
       end;
end;
function _unit_cunt(pu:PTUnit;ut:byte=0):boolean;
begin
   _unit_cunt:=false;
   with (pu^) do
    if(un_r>0)and(bld)and((ut=0)or(ut=un_t))then
     with _players[player] do
     begin
        dec(uidip[un_t],1);

        dec(uidsip,1);
        dec(cenerg,_tuids[un_t]._renerg);
        un_r:=0;
        un_t:=0;
        _unit_cunt:=true;
     end;
end;

function _unit_supt(pu:PTUnit;up:byte):boolean;
begin
   _unit_supt:=false;
   with (pu^) do
   with (puid^) do
    if(up_r=0)and(bld)and(_itsmith)then
     with _players[player] do
      if(_upgrBC(player,up)=false)then
       if(_tupids[up]._uptime>0)then
       begin
          up_t:=up;
          up_r:=_tupids[up_t]._uptime;
          inc(upgrip[up_t],1);
          inc(upgrsip,1);
          inc(cenerg,_tupids[up_t]._uprenerg);
          _unit_supt:=true;

       end;
end;
function _unit_cupt(pu:PTUnit;up:byte=0):boolean;
begin
   _unit_cupt:=false;
   with (pu^) do
    if(up_r>0)and(bld)and((up=0)or(up=up_t))then
     with _players[player] do
     begin
        dec(upgrip[up_t],1);
        dec(upgrsip,1);
        dec(cenerg,_tupids[up_t]._uprenerg);
        up_r:=0;
        up_t:=0;
        _unit_cupt:=true;
     end;
end;


/////////////////////////////////////////////////////////////////////////////////
////
////   ORDERS
////
////////

procedure _uordl_cut(pu:PTUnit;oi:byte);
var i:byte;
begin
   with (pu^) do
   if(oi<uo_n)then
   begin
      for i:=oi+1 to uo_n do
      begin
         uo_id [i-1]:=uo_id [i];
         uo_tar[i-1]:=uo_tar[i];
         uo_x  [i-1]:=uo_x  [i];
         uo_y  [i-1]:=uo_y  [i];
      end;
      dec(uo_n,1);
   end;
end;

procedure _uordl_roll(pu:PTUnit);
var i,
  uoid:byte;
  uotr,
  uox,
  uoy :integer;
begin
   with (pu^) do
   begin
      for i:=0 to uo_n do
       case i of
       0   :begin
               uoid:=uo_id [i];
               uotr:=uo_tar[i];
               uox :=uo_x  [i];
               uoy :=uo_y  [i];
            end;
       else
          uo_id [i-1]:=uo_id [i];
          uo_tar[i-1]:=uo_tar[i];
          uo_x  [i-1]:=uo_x  [i];
          uo_y  [i-1]:=uo_y  [i];
       end;
      uo_id [uo_n]:=uoid;
      uo_tar[uo_n]:=uotr;
      uo_x  [uo_n]:=uox;
      uo_y  [uo_n]:=uoy;
   end;
end;

function _uordl_find(pu:PTUnit;oid:byte):byte;
var i:byte;
begin
   _uordl_find:=255;
   with(pu^)do
    for i:=0 to uo_n do
     if(oid=uo_id[i])then
     begin
        _uordl_find:=i;
        break;
     end;
end;

procedure _uordl_insert(pu:PTUnit;pos,oi:byte;ox,oy,ot:integer);
var i:byte;
begin
   with(pu^)do
    if(uo_n<MaxOrderList)then
    begin
       if(pos>uo_n)
       then pos:=uo_n+1
       else
        for i:=uo_n downto pos do
        begin
           uo_x  [i+1]:=uo_x  [i];
           uo_y  [i+1]:=uo_y  [i];
           uo_tar[i+1]:=uo_tar[i];
           uo_id [i+1]:=uo_id [i];
        end;
       uo_id [pos]:=oi;
       uo_tar[pos]:=ot;
       uo_x  [pos]:=ox;
       uo_y  [pos]:=oy;
       inc(uo_n,1);
    end;
end;

procedure _uordl_check(pu:PTUnit;u:integer);
var i:byte;
begin
   with (pu^) do
   begin
      i:=0;
      while (i<=uo_n) do
       if(uo_tar[i]=u)
       then _uordl_cut(pu,i)
       else inc(i,1);
   end;
end;

/////////////////////////////////////////////////////////////////////////////////
////
////   KILL
////
////////

procedure _check_missiles(u:integer);
var i:integer;
begin
   for i:=1 to MaxMissiles do
    with _missiles[i] do
     if(vst>0)and(tar=u)then tar:=0;
end;

procedure _unit_kill(pu:PTUnit;fastdeath,remove:boolean);
var i :integer;
    tu:PTunit;
begin
   with (pu^) do
   with (puid^) do
    with _players[player] do
    begin
        if(remove=false)then
        begin
           if(_fdeath=false)then fastdeath:=false;
           if(_itmech)or(bld=false)then fastdeath:=true;

           {$IFDEF _FULLGAME}
           _ueff_death(pu,fastdeath);
           {$ENDIF}
        end;

        if(sel)then _unit_selcntdec(pu);
        sel:=false;

        _unit_cunt(pu);
        _unit_cupt(pu);

        if(bld)then
        begin
           dec(menerg,_generg);
           _unit_bldcntdec(pu);
        end
        else dec(cenerg,_renerg);

        x       := vx;
        y       := vy;
        mv_x    := x;
        mv_y    := y;

        un_rx   := x;
        un_ry   := y;
        un_rtar := unum;

        uo_id [0]:= 0;
        uo_tar[0]:= 0;
        uo_x  [0]:= x;
        uo_y  [0]:= y;
        uo_n    := 0;

        a_tar   := 0;
        a_rld   := 0;

        for i:=1 to MaxUnits do
         if(i<>unum)then
         begin
            tu:=@_units[i];
            if(tu^.hits>0)then
            begin
               _uordl_check(pu,unum);
               if(tu^.a_tar  =unum)then tu^.a_tar  :=0;
               if(tu^.un_rtar=unum)then tu^.un_rtar:=0;

               if(apcc>0)then
                if(tu^.inapc=unum)then
                begin
                   if(uf>uf_ground)or(inapc>0)
                   then _unit_kill(tu,false,true)
                   else
                   begin
                      _unit_kickfromapc(pu,tu);
                      if(bld)then
                       if(tu^.hits>apc_exp_damage)then
                       begin
                          dec(tu^.hits,apc_exp_damage);
                          tu^.buff[ub_invuln]:=10;
                       end
                       else _unit_kill(tu,false,true);
                   end;
                end;
            end;
         end;

        _check_missiles(unum);

        if(remove)then
        begin
           hits:=ndead_hits;
           _unit_remove(pu);
        end
        else
          if(fastdeath)
          then hits:=idead_hits
          else hits:=0;
     end;
end;

procedure _unit_damage(pu:PTUnit;damage,painr:integer);
begin
   if(OnlySVCode)then
   with (pu^) do
   with (puid^) do
   begin
      if(damage<0)then
      begin
         //dec(hits,damage);
         //if(hits>_mhits)then hits:=_mhits;
      end
      else
      begin
         // armor

         if(damage<=0)then
          if(random(abs(damage)+1)=0)
          then damage:=1
          else exit;

         dec(hits,damage);
         if(hits>0)then
         begin
            if(_itmech)
            then buff[ub_pain]:=vid_2fps
            else
             if(_painc>0)and(buff[ub_pain]=0)then
             begin
                if(painr>pains)
                then pains:=0
                else dec(pains,painr);

                if(pains=0)then
                begin
                   pains:=_painc;
                   buff[ub_pain]:=_uclord_p;
                   a_rld:=0;
                   {$IFDEF _FULLGAME}
                   _ueff_pain(pu);
                   {$ENDIF}
                end;
             end;

         end
         else _unit_kill(pu,(hits<gavno_hits),false);
      end;
   end;
end;

procedure _unit_counters(pu:PTUnit);
var i : byte;
begin
   with (pu^) do
   begin
      for i:=0 to _ubuffs do
       if(buff[i]<_bufinf)and(buff[i]>0)then dec(buff[i],1);

      if(a_rld>0)then dec(a_rld,1);

      for i:=0 to MaxPlayers do
      begin
         if(vsnt[i]<_bufinf)and(vsnt[i]>0)then dec(vsnt[i],1);
         if(vsni[i]<_bufinf)and(vsni[i]>0)then dec(vsni[i],1);
      end;
   end;
end;


procedure _unit_push(pu,pi:PTUnit;ud:integer);
var ix,iy,td:integer;
begin
   with (pu^) do
   begin
      td:=ud;
      if(pi^.speed=0)and(_players[player].team=_players[pi^.player].team)
      then dec(ud,pi^.puid^._r)
      else dec(ud,pi^.puid^._r+puid^._r);

      if(ud<0)then
      begin
         if(td<=0)then td:=1;

         ix:=trunc(ud*(pi^.x-x)/td)+1-random(2);
         iy:=trunc(ud*(pi^.y-y)/td)+1-random(2);

         inc(x,ix);
         inc(y,iy);

         vstp:=UnitStepNum;

         _unit_correctcoords(pu);
         {$IFDEF _FULLGAME}
         _unit_mmcoords(pu);
         _unit_sfog(pu);
         {$ENDIF}

         mdir:=(360+mdir-(dir_diff(mdir,p_dir(vx,vy,x,y)) div 2 )) mod 360;

         if(pi^.x=pi^.uo_x[0])and(pi^.y=pi^.uo_y[0])and(uo_tar[0]=0)then
         begin
            ud:=dist2(uo_x[0],uo_y[0],pi^.x,pi^.y)-puid^._r-pi^.puid^._r;
            if(ud<=0)then
            begin
               uo_x[0]:=x;
               uo_y[0]:=y;
            end;
         end;
      end;
   end;
end;

procedure _unit_dpush(pu:PTUnit;pd:PTDoodad);
var ix,iy,td,ud:integer;
begin
   with(pu^)do
   begin
      ud:=dist2(x,y,pd^.x,pd^.y);
      td:=ud;
      dec(ud,puid^._r+pd^.r);

      if(ud<0)then
      begin
         if(td<=0)then td:=1;
         ix:=trunc(ud*(pd^.x-x)/td);
         iy:=trunc(ud*(pd^.y-y)/td);

         inc(x,ix);
         inc(y,iy);

         vstp:=UnitStepNum;

         _unit_correctcoords(pu);
         {$IFDEF _FULLGAME}
         _unit_mmcoords(pu);
         _unit_sfog(pu);
         {$ENDIF}

         if(a_rld=0)then mdir:=p_dir(vx,vy,x,y);

         td:=dist2(uo_x[0],uo_y[0],pd^.x,pd^.y)-puid^._r-pd^.r;
         if(td<=2)then
         begin
            uo_x[0]:=x;
            uo_y[0]:=y;
         end;
      end;
   end;
end;

procedure _unit_npush(pu:PTUnit);
var i,dx,dy:integer;
begin
   dx:=pu^.x div dcw;if(dx<0)then dx:=0;if(dx>dcn)then dx:=dcn;
   dy:=pu^.y div dcw;if(dy<0)then dy:=0;if(dy>dcn)then dy:=dcn;

   with map_dcell[dx,dy] do
    for i:=1 to n do
     with map_dds[l[i-1]] do
      if(r>0)and(t>0)then
       _unit_dpush(pu,@map_dds[l[i-1]]);
end;

procedure _unit_upgr(pu:PTUnit);
begin
   with (pu^) do
   begin
     { case uid of
UID_Imp:      buff[ub_invis ]:=_bufinf;
UID_Sergant,
UID_LostSoul: buff[ub_detect]:=_bufinf;
      end; }
   end;
end;




