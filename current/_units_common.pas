{$IFDEF _FULLGAME}
procedure _unit_mmcoords(pu:PTUnit);
begin
   with pu^ do
   begin
      mmx:=trunc(x*map_mmcx);
      mmy:=trunc(y*map_mmcx);
   end;
end;

{procedure _unit_snd_ready(uid:byte;adv:boolean);
begin
   with _uids[uid] do
   begin
      PlaySND(un_snd_ready[adv],nil,nil);
   end;
end; }

procedure _unit_PowerUpEff(pu:PTUnit;snd:PTSoundSet);
begin
   with pu^ do
   begin
      PlaySND(snd,pu,nil);
      _effect_add(vx,vy,_depth(vy+1,uf),EID_HUpgr);
   end;
end;

procedure _unit_painsnd(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   begin
      PlaySND(un_eid_snd_pain[buff[ub_advanced]>0],nil,nil);
      _effect_add(vx,vy,vy+1,un_eid_pain[buff[ub_advanced]>0]);
   end;
end;

procedure _uac_rocketl_eff(pu:PTUnit);
begin
   with pu^ do
   begin
      _effect_add(vx,vy-15,vy+10,EID_Exp2);
      if(playeri=HPlayer)
      then PlaySND(snd_exp,nil,nil)
      else PlaySND(snd_exp,pu ,nil);
   end;
end;

procedure _unit_ready_effects(pu:PTUnit;vischeck:pboolean);
begin
   with pu^ do
   if(hits>0)then
   with uid^ do
   begin
      if(playeri=HPlayer)then
       if(bld)
       then PlayInGameAnoncer(un_snd_ready[buff[ub_advanced]>0])
       else PlayInGameAnoncer(snd_build_place[_urace]);

      if(bld=false)then exit;

      if(vischeck<>nil)then
      begin
         if(vischeck^=false)then exit
      end
      else
         if(_nhp3(vx,vy,@_players[HPlayer])=false)then exit;

      PlaySND(un_eid_snd_ready[buff[ub_advanced]>0],nil,nil);
      _effect_add(vx,vy,vy+1,un_eid_ready[buff[ub_advanced]>0]);
   end;
end;

procedure _unit_death_effects(pu:PTUnit;fastdeath:boolean;vischeck:pboolean);
begin
   with pu^ do
   with uid^ do
   begin
      _effect_add(vx,vy+un_eid_bcrater_y,-5,un_eid_bcrater);

      if(vischeck<>nil)then
      begin
         if(vischeck^=false)then exit
      end
      else
        if(_nhp3(vx,vy,@_players[HPlayer])=false)then exit;

      if(fastdeath)then
      begin
         _effect_add(vx,vy,vy+1,un_eid_fdeath[buff[ub_advanced]>0]);
         PlaySND(un_eid_snd_fdeath[buff[ub_advanced]>0],nil,nil);
      end
      else
      begin
         _effect_add(vx,vy,vy+1,un_eid_death[buff[ub_advanced]>0]);
         PlaySND(un_eid_snd_death[buff[ub_advanced]>0],nil,nil);
      end;
   end;
end;

procedure _unit_pain_effects(pu:PTUnit;vischeck:pboolean);
begin
   with pu^ do
   with uid^ do
   begin
      if(vischeck<>nil)then
      begin
         if(vischeck^=false)then exit
      end
      else
        if(_nhp3(vx,vy,@_players[HPlayer])=false)then exit;

      _effect_add(vx,vy,vy+1,un_eid_pain[buff[ub_advanced]>0]);
      PlaySND(un_eid_snd_pain[buff[ub_advanced]>0],nil,nil);
   end;
end;

procedure _pain_lost_fail(tx,ty,dy:integer;vischeck:pboolean);
begin
   if(vischeck<>nil)then
   begin
      if(vischeck^=false)then exit
   end
   else
     if(_nhp3(tx,ty,@_players[HPlayer])=false)then exit;

   _effect_add(tx,ty,dy,UID_LostSoul);
   PlaySND(snd_pexp,nil,nil);
end;

procedure _unit_attack_effects(pu:PTUnit;start:boolean;vischeck:pboolean);
begin
   with pu^ do
   with uid^ do
   with _a_weap[a_weap] do
   begin
      if(vischeck<>nil)then
      begin
         if(vischeck^=false)then exit
      end
      else
        if(_nhp3(vx,vy,@_players[HPlayer])=false)then exit;

      if(start)then
      begin
         _effect_add(vx,vy,vy+1,aw_eid_start);
         PlaySND(aw_snd_start,nil,nil);
      end
      else
      begin
         _effect_add(vx,vy,vy+1,aw_eid_shot );
         PlaySND(aw_snd_shot,nil,nil);
      end;
   end;
end;

{$ENDIF}

procedure _unit_asapc(pu,apc:PTUnit);
begin
   pu^.x  :=apc^.x;
   pu^.y  :=apc^.y;
   {$IFDEF _FULLGAME}
   pu^.fx :=apc^.fx;
   pu^.fy :=apc^.fy;
   pu^.mmx:=apc^.mmx;
   pu^.mmy:=apc^.mmy;
   {$ENDIF}
end;

procedure _unit_correctXY(pu:PTUnit);
begin;
   with pu^ do
   begin
      x:=mm3(1,x,map_mw);
      y:=mm3(1,y,map_mw);
   end;
end;

procedure _unit_clear_order(pu:PTUnit;clearid:boolean);
begin
   with pu^ do
   begin
      if(clearid)
      then uo_id :=ua_amove;
      uo_tar:=0;
      uo_x  :=x;
      uo_y  :=y;
      uo_bx :=-1;
   end;
end;

procedure _teleport_rld(tu:PTUnit;ur:integer);
begin
   with tu^ do
    with player^ do rld:=max2(fr_hhfps, ur-((ur div 3)*upgr[upgr_hell_teleport]) );
end;

procedure _unit_teleport(pu:PTUnit;tx,ty:integer);
begin
   with pu^ do
   begin
      tx:=mm3(0,tx,map_mw);
      ty:=mm3(0,ty,map_mw);
      {$IFDEF _FULLGAME}
      if _nhp3(vx,vy,@_players[HPlayer])
      or _nhp3(tx,ty,@_players[HPlayer]) then PlaySND(snd_teleport,nil,nil);
      _effect_add(vx,vy,_depth(vy+1,uf),EID_Teleport);
      _effect_add(tx,ty,_depth(ty+1,uf),EID_Teleport);
      {$ENDIF}
      buff[ub_teleeff]:=fr_fps;
      x     :=tx;
      y     :=ty;
      vx    :=x;
      vy    :=y;
      _unit_correctXY(pu);
      _unit_clear_order(pu,false);
      {$IFDEF _FULLGAME}
      _unit_mmcoords(pu);
      _unit_sfog(pu);
      {$ENDIF}
   end;
end;

procedure _unit_zfall(pu:PTUnit);
var st:integer;
begin
   with pu^ do
   if(zfall<>0)then
   begin
      st:=sign(zfall);
      dec(zfall,st);
      inc(y    ,st);
      inc(vy   ,st);
      _unit_correctXY(pu);
   end;
end;

procedure _unit_movevis(pu:PTUnit);
begin
   if(ServerSide)then _unit_zfall(pu);
   with pu^ do
   if(vx<>x)or(vy<>y)then
    if(inapc>0)then
    begin
       vstp:=0;
       vx  :=x;
       vy  :=y;
    end
    else
    begin
       if(vstp<=0)then vstp:=UnitStepNum;
       inc(vx,(x-vx) div vstp);
       inc(vy,(y-vy) div vstp);
       dec(vstp,1);
    end;
end;


procedure _unit_turn(pu:PTUnit);
begin
   with pu^ do
    if(uid^._slowturn=false)then
     if(_canmove(pu))then
      dir:=p_dir(x,y,uo_x,uo_y);
end;

procedure _unit_uradar(pu:PTUnit;x0,y0:integer);
begin
   with pu^ do
   if(bld)and(rld<=0)then
   begin
      _unit_clear_order(pu,true);
      uo_x:=x0;
      uo_y:=y0;
      rld :=radar_reload;
      buff[ub_cast]:=fr_fps;

      {$IFDEF _FULLGAME}
      if(ServerSide)and(player^.team=_players[HPlayer].team)then PlaySND(snd_radar,nil,nil);
      {$ENDIF}
   end;
end;

procedure _unit_umstrike_create(pu:PTUnit);
begin
   with pu^ do
   begin
      _missile_add(uo_x,uo_y,vx,vy,0,MID_Blizzard,playeri,uf_soaring,uf_soaring,0);
      {$IFDEF _FULLGAME}
      _uac_rocketl_eff(pu);
      {$ENDIF}
   end;
end;

procedure _unit_umstrike(pu:PTUnit;x0,y0:integer);
var i:byte;
begin
   with pu^ do
   if(bld)and(rld<=0)then
   with player^ do
   if(upgr[upgr_uac_rstrike]>0)then
   begin
      _unit_clear_order(pu,true);
      uo_x:=x0;
      uo_y:=y0;
      for i:=0 to MaxPlayers do _addtoint(@vsnt[i],fr_2fps);
      rld:=mstrike_reload;
      dec(upgr[upgr_uac_rstrike],1);
      _unit_umstrike_create(pu);
      buff[ub_cast]:=fr_fps;
   end;
end;


procedure _unit_htteleport(pu:PTUnit;x0,y0:integer);
begin
   with pu^ do
   if(bld)and(buff[ub_clcast]<=0)then
   with player^ do
   if(upgr[upgr_hell_b478tel]>0)then
   if(dist(x,y,x0,y0)<srange)then
   begin
      dec(upgr[upgr_hell_b478tel],1);
      buff[ub_clcast]:=fr_hfps;
      _unit_teleport(pu,x0,y0);
   end;
end;

procedure _1c_push(tx,ty:pinteger;x0,y0,r0:integer);
var vx,vy,a:single;
begin
   vx :=x0-tx^;
   vy :=y0-ty^;
   a  :=sqrt(sqr(vx)+sqr(vy));
   if(a=0)then exit;
   vx :=vx/a;
   vy :=vy/a;
   tx^:=x0-round(r0*vx);
   ty^:=y0-round(r0*vy);
end;

procedure _2c_push(tx,ty:pinteger;x0,y0,r0,x1,y1,r1:integer);
var d:integer;
vx,vy,
  a,h:single;
begin
   inc(r0,1);
   inc(r1,1);
   d:=dist(x0,y0,x1,y1);
   if(abs(r0-r1)<=d)and(d<=(r0+r1))and(d>0)then
   begin
      a:=(sqr(r0)-sqr(r1)+sqr(d))/(2*d);
      h:=sqrt(sqr(r0)-sqr(a));

      vx:=(x1-x0)/d;
      vy:=(y1-y0)/d;

      if( round(-vy*(x0-tx^)+vx*(y0-ty^)) <= 0 )then
      begin
         tx^:=round( x0+a*vx-(h*vy) );
         ty^:=round( y0+a*vy+(h*vx) );
      end
      else
      begin
         tx^:=round( x0+a*vx+(h*vy) );
         ty^:=round( y0+a*vy-(h*vx) );
      end;
   end
   else _1c_push(tx,ty,x0,y0,r0);
end;

procedure _building_newplace(tx,ty:integer;buid,pl:byte;newx,newy:pinteger);
const nrl = 1;
var nrx,
    nry,
    nrd,
    nrt: array[0..nrl] of integer;
dx,dy,o,
u,d,tr,
sr,dr  : integer;

procedure add(ax,ay,ad,at:integer);
var i,n:integer;
begin
   // find insert i
   i:=0;
   while(i<=nrl)do
   begin
      if(ad<nrd[i])then break;
      inc(i,1);
   end;

   if(i>nrl)then exit;

   if(i<>nrl)then
    for n:=nrl-1 downto i do
    begin
       nrd[i+1]:=nrd[i];
       nrx[i+1]:=nrx[i];
       nry[i+1]:=nry[i];
       nrt[i+1]:=nrt[i];
    end;

   nrd[i]:=ad;
   nrx[i]:=ax;
   nry[i]:=ay;
   nrt[i]:=at;
end;

begin
   for u:=0 to nrl do
   begin
      nrd[u]:= 32000;
      nrx[u]:=-2000;
      nry[u]:=-2000;
      nrt[u]:=0;
   end;
   tr :=_uids[buid]._r;

   dx:=tx div dcw;
   dy:=ty div dcw;
   dec(tr,bld_dec_mr);
   if(0<=dx)and(dx<=dcn)and(0<=dy)and(dy<=dcn)then
    with map_dcell[dx,dy] do
     if(n>0)then
      for u:=0 to n-1 do
       with l[u]^ do
        if(r>0)and(t>0)then
        begin
           o:=tr+r;
           d:=dist(x,y,tx,ty)-o;
           add(x,y,d,o);
        end;
   inc(tr,bld_dec_mr);

   for u:=1 to MaxCPoints do
    with g_cpoints[u] do
    begin
       o:=base_r;
       d:=dist(px,py,tx,ty)-o;
       add(px,py,d,o);
    end;

   dx:=-2000;
   dy:=-2000;
   sr:=32000;
   dr:=32000;
   for u:=1 to MaxUnits do
    with _units[u] do
     with uid^ do
     if(hits>0)and(speed<=0)and(uf=uf_ground)and(inapc<=0)then
     begin
        o:=tr+_r;
        d:=dist(x,y,tx,ty);
        add(x,y,d-o,o);

        if(buid>0)then
        if(_isbuilding)and(bld)and(_isbuilder)and(playeri=pl)then
        begin
           if not(buid in uid^.ups_builder)then continue;

           o:=d-srange;
           if(o<dr)then
           begin
              dx:=x;
              dy:=y;
              dr:=o;
              sr:=srange;
           end;
        end;
     end;

   if(nrd[1]<=-1)
   then _2c_push(@tx,@ty,nrx[0],nry[0],nrt[0],nrx[1],nry[1],nrt[1])
   else
     if(nrd[0]<=-1)
     then _2c_push(@tx,@ty,nrx[0],nry[0],nrt[0],-2000,-2000,-2000);

   if(dr<32000)then
   begin
      d :=dist(dx,dy,tx,ty);
      dr:=d-sr;
      if(0<dr)then _1c_push(@tx,@ty,dx,dy,sr-1);
   end;

   newx^:=tx;
   newy^:=ty;
end;

function _unit_grbcol(tx,ty,tr:integer;pl,buid:byte;doodc:boolean):byte;
var u,dx,dy:integer;
   bl:boolean;
begin
   if(pl<=MaxPlayers)then
   begin
      bl:=false;
      if(tx<map_b0)or(map_b1<tx)
      or(ty<map_b0)or(map_b1<ty)then
      begin
         _unit_grbcol:=2;
         exit;
      end;
   end
   else bl:=true;
   _unit_grbcol:=0;

   for u:=1 to MaxUnits do
    with _units[u] do
     with uid^ do
     if(hits>0)and(speed=0)and(uf=uf_ground)and(inapc=0)then
      if(dist(x,y,tx,ty)<(tr+_r))then
      begin
         _unit_grbcol:=1;
         break;
      end
      else
       if(bl=false)then
        if(_isbuilding)and(bld)and(_isbuilder)and(playeri=pl)then
        begin
           if(buid>0)then
            if not(buid in uid^.ups_builder)then continue;
           if(dist(x,y,tx,ty)<srange)then bl:=true;
        end;

   if(_unit_grbcol=0)then
   begin
      if(bl=false)and(pl<=MaxPlayers)then
      begin
         _unit_grbcol:=2;
         exit;
      end;

      if(g_mode=gm_ct)then
       for u:=1 to MaxCPoints do
        with g_cpoints[u] do
         if(dist(tx,ty,px,py)<base_r)then
         begin
            _unit_grbcol:=2;
            exit;
         end;

      if(doodc=false)then exit;

      dec(tr,bld_dec_mr);

      dx:=tx div dcw;
      dy:=ty div dcw;

      if(0<=dx)and(dx<=dcn)and(0<=dy)and(dy<=dcn)then
      with map_dcell[dx,dy] do
       for u:=0 to n-1 do
        with l[u]^ do
         if(r>0)and(t>0)then
          if(dist(x,y,tx,ty)<(tr+r))then
          begin
             _unit_grbcol:=1;
             break;
          end;
   end;
end;

procedure _unit_default(pu:PTUnit);
begin
   with pu^ do
   begin
      inapc    := 0;
      uo_id    := ua_amove;
      uo_tar   := 0;
      rld      := 0;
      pains    := 0;
      dir      := 270;
      order    := 0;
      a_tar    := 0;
      a_weap   := 0;
      //a_tard   := 32000;
      {alrm_x   := 0;
      alrm_y   := 0;
      alrm_r   := 32000;
      alrm_b   := false; }

      FillChar(uprod_r,SizeOf(uprod_r),0);
      FillChar(pprod_r,SizeOf(pprod_r),0);
      FillChar(uprod_u,SizeOf(uprod_u),0);
      FillChar(pprod_u,SizeOf(pprod_u),0);

      {$IFDEF _FULLGAME}
      wanim    := false;
      anim     := 0;
      _unit_mmcoords(pu);
      _unit_sfog    (pu);
      {$ENDIF}
   end;
end;

procedure _unit_done_inc_cntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(_isbuilder)then inc(n_builders,1);
      if(_isbarrack)then
      begin
         inc(n_barracks,1);
         if(buff[ub_advanced]>0)
         then inc(uprodm,2)
         else inc(uprodm,1);
      end;
      if(_issmith  )then
      begin
         inc(n_smiths  ,1);
         if(buff[ub_advanced]>0)
         then inc(pprodm,2)
         else inc(pprodm,1);
      end;
   end;
end;
procedure _unit_done_dec_cntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(_isbuilder)then dec(n_builders,1);
      if(_isbarrack)then
      begin
         dec(n_barracks,1);
         if(buff[ub_advanced]>0)
         then dec(uprodm,2)
         else dec(uprodm,1);
      end;
      if(_issmith  )then
      begin
         dec(n_smiths  ,1);
         if(buff[ub_advanced]>0)
         then dec(pprodm,2)
         else dec(pprodm,1);
      end;
   end;
end;

procedure _unit_bld_dec_cntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(uid_x[uidi            ]=unum)then uid_x[uidi            ]:=0;
      if(ucl_x[_isbuilding,_ucl]=unum)then ucl_x[_isbuilding,_ucl]:=0;
      dec(ucl_eb[_isbuilding,_ucl],1);
      dec(uid_eb[uidi            ],1);
      dec(menerg,_generg);
      dec(cenerg,_generg);
      _unit_done_dec_cntrs(pu);
   end;
end;

procedure _unit_bld_inc_cntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(uid_x[uidi            ]<=0)then uid_x[uidi            ]:=unum;
      if(ucl_x[_isbuilding,_ucl]<=0)then ucl_x[_isbuilding,_ucl]:=unum;
      inc(ucl_eb[_isbuilding,_ucl],1);
      inc(uid_eb[uidi            ],1);
      inc(menerg,_generg);
      inc(cenerg,_generg);
      _unit_done_inc_cntrs(pu);
   end;
end;

procedure _unit_inc_cntrs(pu:PTUnit;ubld,born:boolean);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      inc(army,1);
      inc(ucl_e[_isbuilding,_ucl],1);
      inc(ucl_c[_isbuilding],1);

      inc(uid_e[uidi],1);

      bld:=ubld;

      if(ubld)
      then _unit_bld_inc_cntrs(pu)
      else
      begin
         hits:= 1;
         dec(cenerg,_renerg);
      end;

      if(born)then
      begin
         buff[ub_born]:=fr_fps;
         {$IFDEF _FULLGAME}
         _unit_ready_effects(_LastCreatedUnitP,nil);
         {$ENDIF}
      end;
   end;
end;

procedure _unit_add(ux,uy:integer;ui,pl:byte;ubld,born:boolean);
var m,i:integer;
begin
   _LastCreatedUnit :=0;
   _LastCreatedUnitP:=@_units[_LastCreatedUnit];
   with _players[pl] do
   begin
      if(ui=0)then exit;
      i:=MaxPlayerUnits*pl+1;
      m:=i+MaxPlayerUnits;
      while(i<m)do
      begin
         with _units[i] do
          if(hits<=dead_hits)then
          begin
             _LastCreatedUnit :=i;
             _LastCreatedUnitP:=@_units[i];
             break;
          end;
         inc(i,1);
      end;

      FillChar(_LastCreatedUnitP^,SizeOf(TUnit),0);
      if(_LastCreatedUnit>0)then
       with _LastCreatedUnitP^ do
       begin
          uclord  := _LastCreatedUnit mod _uclord_p;
          unum    := _LastCreatedUnit;

          x       := ux;
          y       := uy;
          uidi    := ui;
          playeri := pl;
          player  :=@_players[playeri];
          vx      := x;
          vy      := y;
          uo_x    := x;
          uo_y    := y;
          uo_bx   := -1;
          uo_by   := -1;
          mv_x    := x;
          mv_y    := y;
          sel     := false;
          apcc    := 0;

          FillChar(buff,sizeof(buff),0);
          FillChar(vsnt,SizeOf(vsnt),0);
          FillChar(vsni,SizeOf(vsni),0);

          _unit_default  (_LastCreatedUnitP);
          _unit_apUID    (_LastCreatedUnitP);
          _unit_inc_cntrs(_LastCreatedUnitP,ubld,born);
       end;
   end;
end;

procedure _unit_startb(bx,by:integer;buid,bp:byte);
begin
   if(_uid_cndt(@_players[bp],buid)=0)then
    with _players[bp] do
     if(_unit_grbcol(bx,by,_uids[buid]._r,bp,buid,true)=0)then
      _unit_add(bx,by,buid,bp,false,true);
end;


//////   Start unit prod
//
function _unit_straining_p(pu:PTUnit;puid:byte;pn:integer):boolean;
begin
   _unit_straining_p:=false;
   if(puid<255)then
    with pu^ do
    with uid^ do
     if(uprod_r[pn]=0)and(bld)and(_isbarrack)and(_isbuilding)then
      if(puid in ups_units)and(_uid_cndt(pu^.player,puid)=0)then
       with player^ do
       begin
          inc(uproda,1);
          inc(uprodc[_uids[puid]._ucl],1);
          inc(uprodu[ puid],1);
          dec(cenerg,_uids[puid]._renerg);
          uprod_u[pn]:=puid;
          uprod_r[pn]:=_uids[puid]._tprod;

          _unit_straining_p:=true;
       end;
end;
function _unit_straining(pu:PTUnit;puid:byte):boolean;
var i:byte;
begin
   _unit_straining:=true;

   for i:=0 to MaxUnitProds do
   begin
      if(i>0)then
       if(pu^.buff[ub_advanced]<=0)then break;

      if(_unit_straining_p(pu,puid,i))then exit;
   end;

   _unit_straining:=false;
end;
/// Stop unit prod
function _unit_ctraining_p(pu:PTUnit;puid:byte;pn:integer):boolean;
begin
   _unit_ctraining_p:=false;
   with pu^ do
   with uid^ do
    if(uprod_r[pn]>0)and(bld)and(_isbarrack)and(_isbuilding)then
     if(puid=255)or(puid=uprod_u[pn])then
      with player^ do
      begin
         puid:=uprod_u[pn];

         dec(uproda,1);
         dec(uprodc[_uids[puid]._ucl],1);
         dec(uprodu[ puid],1);
         inc(cenerg,_uids[puid]._renerg);
         uprod_r[pn]:=0;

         _unit_ctraining_p:=true;
      end;
end;
function _unit_ctraining(pu:PTUnit;puid:byte):boolean;
var i:byte;
begin
   _unit_ctraining:=true;

   for i:=MaxUnitProds downto 0 do
    if(_unit_ctraining_p(pu,puid,i))and(puid<255)then exit;

   _unit_ctraining:=false;
end;


//////   Start upgrade production
//
function _unit_supgrade_p(pu:PTUnit;upid:byte;pn:integer):boolean;
begin
   _unit_supgrade_p:=false;
   if(upid<255)then
    with pu^ do
    with uid^ do
     if(pprod_r[pn]=0)and(bld)and(_issmith)and(_isbuilding)then
      if(_upid_cndt(player,upid)=0)then
       with player^ do
       with _upids[upid] do
       begin
          inc(pproda,1);
          inc(pprodu[upid],1);
          dec(cenerg,_up_renerg);
          pprod_r[pn]:=_up_time;
          pprod_u[pn]:=upid;

          _unit_supgrade_p:=true;
       end;
end;
function _unit_supgrade(pu:PTUnit;upid:integer):boolean;
var i:byte;
begin
   _unit_supgrade:=true;

   for i:=0 to MaxUnitProds do
   begin
      if(i>0)then
       if(pu^.buff[ub_advanced]<=0)then break;

      if(_unit_supgrade_p(pu,upid,i))then exit;
   end;

   _unit_supgrade:=false;
end;
function _unit_cupgrade_p(pu:PTUnit;upid:byte;pn:integer):boolean;
begin
   _unit_cupgrade_p:=false;
   with pu^ do
   with uid^ do
    if(pprod_r[pn]>0)and(bld)and(_issmith)and(_isbuilding)then
     if(upid=255)or(upid=pprod_u[pn])then
      with player^ do
      begin
         upid:=pprod_u[pn];

         dec(pproda,1);
         dec(pprodu[upid],1);
         inc(cenerg,_upids[upid]._up_renerg);
         pprod_r[pn]:=0;

         _unit_cupgrade_p:=true;
       end;
end;
function _unit_cupgrade(pu:PTUnit;puid:byte):boolean;
var i:byte;
begin
   _unit_cupgrade:=true;

   for i:=MaxUnitProds downto 0 do
    if(_unit_cupgrade_p(pu,puid,i))and(puid<255)then exit;

   _unit_cupgrade:=false;
end;

procedure _unit_inc_selc(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      inc(ucl_s [_isbuilding,_ucl],1);
      inc(ucl_cs[_isbuilding     ],1);
      inc(uid_s [uidi],1);
      if(_isbuilder)then inc(s_builders,1);
      if(_isbarrack)then inc(s_barracks,1);
      if(_issmith  )then inc(s_smiths  ,1);
   end;
end;
procedure _unit_dec_selc(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      dec(ucl_s [_isbuilding,_ucl],1);
      dec(ucl_cs[_isbuilding     ],1);
      dec(uid_s [uidi],1);
      if(_isbuilder)then dec(s_builders,1);
      if(_isbarrack)then dec(s_barracks,1);
      if(_issmith  )then dec(s_smiths  ,1);
   end;
end;

procedure _unit_desel(pu:PTUnit);
begin
   with pu^ do
   begin
      if(sel)then _unit_dec_selc(pu);
      sel:=false;
   end;
end;

procedure _unit_dec_Kcntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      _unit_desel(pu);

      if(bld=false)
      then inc(cenerg,_uids[uidi]._renerg)
      else
      begin
         _unit_ctraining(pu,255);
         _unit_cupgrade (pu,255);

         dec(ucl_eb[_isbuilding,_ucl],1);
         dec(uid_eb[uidi],1);
         dec(menerg,_generg);
         dec(cenerg,_generg);

         _unit_done_dec_cntrs(pu);
      end;

      if(ucl_x[_isbuilding,_ucl]=unum)then ucl_x[_isbuilding,_ucl]:=0;
      if(uid_x[uidi            ]=unum)then uid_x[uidi            ]:=0;
   end;
end;

procedure _unit_dec_Rcntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      dec(army,1);
      dec(ucl_e[_isbuilding,_ucl],1);
      dec(ucl_c[_isbuilding     ],1);
      dec(uid_e[uidi],1);
   end;
end;

procedure _u1_spawn(pu:PTUnit;_uid,count:byte);
var
sr,i  :integer;
cd    :single;
begin
   with pu^ do
   with uid^ do
   begin
      dir:=p_dir(x,y,uo_x,uo_y);
      if(_uids[_uid]._uf>uf_ground)
      then sr:=0
      else sr:=_r;//+_uids[_uid]._r;

      for i:=0 to count do
      begin
         cd:=(dir+i*15)*degtorad;

         _unit_add(x+trunc(sr*cos(cd)),
                   y-trunc(sr*sin(cd)),_uid,playeri,true,true);
         if(_LastCreatedUnit>0)then
         begin
            _LastCreatedUnitP^.uo_x  :=uo_x;
            _LastCreatedUnitP^.uo_y  :=uo_y;
            _LastCreatedUnitP^.uo_id :=uo_id;
            _LastCreatedUnitP^.uo_tar:=uo_tar;
            _LastCreatedUnitP^.dir   :=dir;
            if(_barrack_teleport)then
            begin
               _LastCreatedUnitP^.buff[ub_teleeff]:=fr_fps;
               {$IFDEF _FULLGAME}
               if _nhp3(_LastCreatedUnitP^.vx,_LastCreatedUnitP^.vy,@_players[HPlayer])then PlaySND(snd_teleport,nil,nil);
               _effect_add(_LastCreatedUnitP^.vx,_LastCreatedUnitP^.vy,_depth(_LastCreatedUnitP^.vy+1,_LastCreatedUnitP^.uf),EID_Teleport);
               {$ENDIF}
            end;
         end;
      end;
   end;
end;

procedure _unit_end_uprod(pu:PTUnit);
var i,_uid:byte;
begin
   with pu^ do
   with uid^ do
   if(_isbarrack)then
   with player^ do
   for i:=0 to MaxUnitProds do
   if(uprod_r[i]>0)then
   begin
       _uid:=uprod_u[i];

      if((army+uproda)>MaxPlayerUnits)
      or(cenerg<0)
      or(uid_e[_uid]>=_uids[_uid]._max)
      or(uid_e[_uid]>=a_units[_uid])
      then _unit_ctraining_p(pu,255,i)
      else
        if(uprod_r[i]=1){$IFDEF _FULLGAME}or(_warpten){$ENDIF}then
        begin
           _u1_spawn(pu,uprod_u[i],upgr[upgr_mult_product]);

           _unit_ctraining_p(pu,255,i);
        end
        else uprod_r[i]:=max2(1,uprod_r[i]-1*(upgr[upgr_fast_product]+1) );
   end;
end;

procedure _unit_end_pprod(pu:PTUnit);
var i,_uid:byte;
begin
  with pu^ do
  with uid^ do
  if(_issmith)then
  with player^ do
  for i:=0 to MaxUnitProds do
  if(pprod_r[i]>0)then
  begin
      _uid:=pprod_u[i];
     if(cenerg<0)
     or(upgr[_uid]>=_upids[_uid]._up_max)
     or(upgr[_uid]>=a_upgrs[_uid])
     then _unit_cupgrade_p(pu,255,i)
     else
       if(pprod_r[i]=1){$IFDEF _FULLGAME}or(_warpten){$ENDIF}then
       begin
          inc(upgr[_uid],1);
          _unit_cupgrade_p(pu,255,i);
          {$IFDEF _FULLGAME}
          if(playeri=HPlayer)then PlayInGameAnoncer(snd_upgrade_complete[_urace]);
          {$ENDIF}
       end
       else pprod_r[i]:=max2(1,pprod_r[i]-1*(upgr[upgr_fast_product]+1) );
  end;
end;



procedure _unit_spawn(pu:PTUnit;tx,ty:integer;auid:byte);
var tu:PTUnit;
begin
   with pu^ do
   with player^ do
   begin
      if((army+uproda)>=MaxPlayerUnits)
      then _LastCreatedUnit:=0
      else
        if(ServerSide)
        then _unit_add(tx,ty,auid,playeri,true,true)
        else exit;

      if(_LastCreatedUnit>0)then
      begin
         _LastCreatedUnitP^.dir   :=dir;
         _LastCreatedUnitP^.a_tar :=a_tar;
         _LastCreatedUnitP^.uo_id :=uo_id;
         _LastCreatedUnitP^.uo_tar:=uo_tar;
         if(_IsUnitRange(a_tar,@tu))then
         begin
            _LastCreatedUnitP^.uo_x  :=tu^.x;
            _LastCreatedUnitP^.uo_y  :=tu^.y;
         end
         else
          if(uo_x<>x)or(uo_y<>y)then
          begin
             _LastCreatedUnitP^.uo_x  :=uo_x;
             _LastCreatedUnitP^.uo_y  :=uo_y;
          end;
         _LastCreatedUnitP^.buff[ub_advanced]:=buff[ub_advanced];
      end
      {$IFDEF _FULLGAME}
      else
        case auid of
UID_LostSoul: _pain_lost_fail(tx,ty,_depth(ty+1,uf),nil);
        end;
      {$ENDIF};
   end;
end;


procedure _ability_unit_spawn(pu:PTUnit;auid:byte);
var dd:integer;
begin
   with pu^ do
   with uid^ do
   begin
      dd:=_DIR360(dir+23) div 45;
      _unit_spawn(pu,x+dir_stepX[dd]*_r,y+dir_stepY[dd]*_r,auid);
   end;
end;


function _itcanapc(uu,tu:PTUnit):boolean;
begin
   _itcanapc:=false;
   if(tu^.uf>uf_ground)then exit;
   if((uu^.apcm-uu^.apcc)>=tu^.uid^._apcs)then
    if(tu^.uidi in uu^.uid^.ups_apc)then _itcanapc:=true;
end;


procedure _unit_counters(pu:PTUnit);
var i:byte;
begin
   with pu^ do
   begin
      for i:=0 to MaxUnitBuffs do
       if(0<buff[i])and(buff[i]<_ub_infinity)then
       begin
          dec(buff[i],1);
          {if(i=ub_stopattack)and(ServerSide)then
           if(bld)and(speed>0)and(tar1=0)then
            if(buff[i]=0)then
             if(x<>uo_x)or(y<>uo_y)then dir:=p_dir(x,y,uo_x,uo_y);}
       end;

      for i:=0 to MaxPlayers do
      begin
         if(0<vsnt[i])and(vsnt[i]<_ub_infinity)then dec(vsnt[i],1);
         if(0<vsni[i])and(vsni[i]<_ub_infinity)then dec(vsni[i],1);
      end;

      if(a_rld>0)then dec(a_rld,1);

      if(bld)then
       if(rld>0)then dec(rld,1);
   end;
end;


procedure _unit_detect(uu,tu:PTUnit;ud:integer);
var td:integer;
begin
   with uu^ do
   begin
      if(tu^.uid^._ability=uab_radar)and(tu^.rld>radar_btime)
      then td:=min2(ud,dist2(x,y,tu^.uo_x,tu^.uo_y))
      else td:=ud;

      if(td<=(tu^.srange+uid^._r))then
      begin
         if(buff[ub_invis]<=0)
         then _AddToInt(@vsnt[tu^.player^.team],vistime)
         else
           if(tu^.buff[ub_detect]>0)and(tu^.bld)and(tu^.hits>0)then
           begin
              _AddToInt(@vsnt[tu^.player^.team],vistime);
              _AddToInt(@vsni[tu^.player^.team],vistime);
           end;
      end;
   end;
end;


procedure _unit_upgr(pu:PTUnit);
var i:integer;
begin
   with pu^ do
   with uid^ do
   with player^ do
   if(bld)then
   begin
      // ABILITIES
      case _ability of
uab_radar: begin
              i:=radar_range[mm3(0,upgr[upgr_uac_radar_r],radar_upgr_levels)];
              if(srange<>i)then
              begin
                 srange:=i;
                 {$IFDEF _FULLGAME}
                 _unit_fog_r(pu);
                 {$ENDIF}
              end;
           end;
uab_uac__unit_adv:
           if(upgr[upgr_uac_6bld]>0)then buff[ub_advanced]:=_ub_infinity;
      end;

      // DETECTION
      case uidi of
UID_HEye: buff[ub_detect]:=b2ib[upgr[upgr_hell_heye]>0];
      end;

      // INVIS
      case uidi of
UID_HEye,
UID_HTotem: buff[ub_invis]:=b2ib[upgr[upgr_hell_totminv]>0];
UID_Commando,
UID_Demon : buff[ub_invis]:=buff[ub_advanced];
UID_UMine : buff[ub_invis]:=_ub_infinity;
      end;

      // OTHER HARDCODE
      case uidi of
UID_Demon: if(upgr[upgr_hell_pinkspd]>0)then
           begin
              if(speed=_speed)then
              begin
                 speed :=_speed+7;
                 {$IFDEF _FULLGAME}
                 //animw:=20;
                 {$ENDIF}
              end;
           end
           else
             if(speed<>_speed)then
             begin
                speed :=_speed;
                {$IFDEF _FULLGAME}
                //animw:=20;
                {$ENDIF}
             end;
UID_Major,
UID_ZMajor:
           if(buff[ub_advanced]>0)then
           begin
              if(uf<>uf_fly)then
              begin
                 {$IFDEF _FULLGAME}
                 PlaySND(snd_jetpon ,pu,nil);
                 {$ENDIF}
                 zfall:=-fly_height[uf_fly];
              end;
              uf   :=uf_fly;
              speed:=_speed+4;
           end
           else
           begin
              if(uf<>uf_ground)then
              begin
                 {$IFDEF _FULLGAME}
                 PlaySND(snd_jetpoff,pu,nil);
                 {$ENDIF}
                 zfall:= fly_height[uf_ground];
              end;
              uf   :=uf_ground;
              speed:=_speed;
           end;
UID_HEye:  begin
              i:=eye_range[mm3(0,upgr[upgr_hell_heye],5)];
              if(srange<>i)then
              begin
                 srange:=i;
                 {$IFDEF _FULLGAME}
                 _unit_fog_r(pu);
                 {$ENDIF}
              end;
           end;
UID_UMine: if(upgr[upgr_uac_mines]>1)and(srange<250)then
           begin
              srange:=250;
              {$IFDEF _FULLGAME}
              _unit_fog_r(pu);
              {$ENDIF}
           end;
      end;

      // REGENERATION
      if(ServerSide)then
      if(uclord=_uregen_c)then
      begin
         if(_isbuilding)
         then i:= upgr[upgr_race_build_regen[_urace]]
         else
          if(_ismech)
          then i:= upgr[upgr_race_mech_regen[_urace]]
          else i:= upgr[upgr_race_bio_regen [_urace]];

         if(i>0)then hits:=min2(hits+i,_mhits);
      end;
   end;
end;



