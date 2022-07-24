{$IFDEF _FULLGAME}
procedure _unit_mmcoords(pu:PTUnit);
begin
   with pu^ do
   begin
      mmx:=trunc(x*map_mmcx);
      mmy:=trunc(y*map_mmcx);
   end;
end;

procedure _unit_PowerUpEff(pu:PTUnit;snd:PTSoundSet;vischeck:pboolean);
begin
   with pu^ do
   begin
      if(vischeck<>nil)then
      begin
         if(vischeck^=false)then exit
      end
      else
         if(PointInScreenP(vx,vy,player)=false)then exit;

      SoundPlayUnit(snd,pu,nil);
      _effect_add(vx,vy,_depth(vy+1,ukfly),EID_HUpgr);
   end;
end;

procedure _unit_HvisionEff(pu:PTUnit;vischeck:pboolean);
begin
   _unit_PowerUpEff(pu,snd_hell_eye,vischeck);
end;

procedure _uac_rocketl_eff(pu:PTUnit);
begin
   with pu^ do
   begin
      _effect_add(vx,vy-15,_depth(vy+10,ukfly),EID_Exp2);
      if(playeri=HPlayer)
      then SoundPlayUnit(snd_bomblaunch,nil,nil)
      else SoundPlayUnit(snd_bomblaunch,pu ,nil);
   end;
end;

procedure _unit_summon_effects(pu:PTUnit;vischeck:pboolean);
begin
   with pu^ do
   if(hits>0)and(bld)then
   with uid^ do
   begin
      if(vischeck<>nil)then
      begin
         if(vischeck^=false)then exit
      end
      else
         if(PointInScreenP(vx,vy,player)=false)then exit;

      SoundPlayUnit(un_eid_snd_summon[buff[ub_advanced]>0],nil,nil);
      _effect_add(vx,vy,_depth(vy+1,ukfly),un_eid_summon[buff[ub_advanced]>0]);

      if(playeri=HPlayer)then SoundPlayUnit(un_snd_ready[buff[ub_advanced]>0],nil,nil);
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
        if(PointInScreenP(vx,vy,player)=false)then exit;

      if(fastdeath)then
      begin
         _effect_add(vx,vy,_depth(vy+1,ukfly),un_eid_fdeath[buff[ub_advanced]>0]);
         SoundPlayUnit(un_eid_snd_fdeath[buff[ub_advanced]>0],nil,nil);
      end
      else
      begin
         _effect_add(vx,vy,vy+1,un_eid_death[buff[ub_advanced]>0]);
         SoundPlayUnit(un_eid_snd_death[buff[ub_advanced]>0],nil,nil);
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
        if(PointInScreenP(vx,vy,player)=false)then exit;

      _effect_add(vx,vy,_depth(vy+1,ukfly),un_eid_pain[buff[ub_advanced]>0]);
      SoundPlayUnit(un_eid_snd_pain[buff[ub_advanced]>0],nil,nil);
   end;
end;

procedure _pain_lost_fail(tx,ty,dy:integer;vischeck:pboolean);
begin
   if(vischeck<>nil)then
   begin
      if(vischeck^=false)then exit
   end
   else
     if(PointInScreenP(tx,ty,nil)=false)then exit;

   _effect_add(tx,ty,dy,UID_LostSoul);
   SoundPlayUnit(snd_pexp,nil,nil);
end;

procedure _unit_attack_effects(pu:PTUnit;start:boolean;vischeck:pboolean);
begin
   with pu^  do
   with uid^ do
   with _a_weap[a_weap] do
   begin
      if(vischeck<>nil)then
      begin
         if(vischeck^=false)then exit
      end
      else
        if(PointInScreenP(vx,vy,player)=false)then exit;

      if(start)then
      begin
         _effect_add(vx,vy,_depth(vy+1,ukfly),aw_eid_start);
         SoundPlayUnit(aw_snd_start,nil,nil);
      end
      else
      begin
         _effect_add(vx+aw_x,vy+aw_y,_depth(vy+1,ukfly),aw_eid_shot );
         SoundPlayUnit(aw_snd_shot,nil,nil);
      end;
   end;
end;

{$ENDIF}

function _canmove(pu:PTUnit):boolean;
begin
   with pu^ do
   with uid^ do
    if(ServerSide=false)and(speed>0)
    then _canmove:=(x<>uo_bx)or(y<>uo_by)
    else
    begin
       _canmove:=false;

       if(speed<=0)or(hits<=0)or(bld=false)then exit;

       if(a_rld>0)then
        if(a_weap_cl>MaxUnitWeapons)
        then exit
        else
         with _a_weap[a_weap_cl] do
          if(not cf(@aw_reqf,@wpr_move))then exit;

       if(_ukmech)then
       begin
         if(buff[ub_stun]>0)then exit;
       end
       else
         if(buff[ub_pain]>0)
         or(buff[ub_cast]>0)
         or(buff[ub_stun]>0)then exit;

       _canmove:=true;
    end;
end;

function _canattack(pu:PTUnit;check_buffs:boolean):boolean;
var tu:PTUnit;
begin
   _canattack:=false;
   with pu^  do
   with uid^ do
   begin
      if(bld=false)or(hits<=0)or(_attack=atm_none)then exit;

      if(check_buffs)then
      begin
         if(_ukmech)then
         begin
           if(buff[ub_stun]>0)then exit;
         end
         else
           if(buff[ub_pain]>0)
           or(buff[ub_cast]>0)
           or(buff[ub_stun]>0)then exit;
      end;

      case _attack of
   atm_bunker,
   atm_always  : if(_IsUnitRange(inapc,@tu))then
                 begin
                    if(_IsUnitRange(tu^.inapc,nil))then exit;
                    case tu^.uid^._attack of
                    atm_always,
                    atm_none,
                    atm_sturret: exit;
                    end;
                 end;
   atm_sturret : if(apcc <=0)then exit;
   atm_inapc   : if(inapc<=0)then exit;
      else exit;
      end;
   end;
   _canattack:=true;
end;

procedure _unit_correctXY(pu:PTUnit);
begin;
   with pu^ do
   begin
      x:=mm3(1,x,map_mw);
      y:=mm3(1,y,map_mw);
      pfzone:=pf_get_area(x,y);
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
const hpart = 3;
begin
   with tu^ do
    with player^ do rld:=max2( fr_fps , fr_3fps+(ur div hpart)*mm3(1,hpart-upgr[upgr_hell_teleport],hpart) );
end;

procedure _unit_teleport(pu:PTUnit;tx,ty:integer{$IFDEF _FULLGAME};eidstart,eidend:byte;snd:PTSoundSet{$ENDIF});
begin
   with pu^ do
   begin
      tx:=mm3(0,tx,map_mw);
      ty:=mm3(0,ty,map_mw);
      {$IFDEF _FULLGAME}
      teleport_effects(vx,vy,tx,ty,ukfly,eidstart,eidend,snd);
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
      if(zfall>1)then st*=2;
      if(x=uo_x)
     and(y=uo_y)then uo_y+=st;
      zfall-=st;
      y    +=st;
      vy   +=st;
      _unit_correctXY(pu);
   end;
end;

procedure _unit_movevis(pu:PTUnit);
begin
   if(ServerSide)then _unit_zfall(pu);
   with pu^ do
   if(vx<>x)or(vy<>y)then
    if(_IsUnitRange(inapc,nil))then
    begin
       vstp:=0;
       vx  :=x;
       vy  :=y;
    end
    else
    begin
       if(vstp>UnitStepTicks)and(ServerSide)then vstp:=UnitStepTicks;
       if(vstp<=0)then vstp:=UnitStepTicks;
       vx  +=(x-vx) div vstp;
       vy  +=(y-vy) div vstp;
       vstp-=1;
    end;
end;

function _unit_ability_uradar(pu:PTUnit;x0,y0:integer):boolean;
begin
   _unit_ability_uradar:=false;
   with pu^ do
    if(bld)and(rld<=0)then
    begin
       _unit_clear_order(pu,true);
       uo_x:=x0;
       uo_y:=y0;
       rld :=radar_reload;
       buff[ub_cast]:=fr_fps;
       _unit_ability_uradar:=true;

       {$IFDEF _FULLGAME}
       if(ServerSide)and(player^.team=_players[HPlayer].team)then SoundPlayUnit(snd_radar,nil,nil);
       {$ENDIF}
    end;
end;

function _unit_ability_hinvuln(pu:PTUnit;t:integer):boolean;
var tu:PTUnit;
begin
   // pu - caster
   // tu - target
   _unit_ability_hinvuln:=false;
   if(_IsUnitRange(t,@tu))then
   begin
      with tu^ do
       with uid^ do
        if(hits<=0)or(not bld)or(_ukbuilding)then exit;

      with pu^ do
       with player^ do
        if(team=tu^.player^.team)and(upgr[upgr_hell_invuln]>0)then
        begin
           tu^.buff[ub_invuln]:=invuln_time;
           upgr[upgr_hell_invuln]-=1;
           _unit_ability_hinvuln:=true;
           {$IFDEF _FULLGAME}
           _unit_PowerUpEff(tu,snd_hpower,nil);
           {$ENDIF}
        end;
   end;
end;

procedure _unit_umstrike_missile(pu:PTUnit);
begin
   with pu^ do
   begin
      _missile_add(uo_x,uo_y,vx,vy,0,MID_Blizzard,playeri,uf_ground,uf_ground,0);
      {$IFDEF _FULLGAME}
      _uac_rocketl_eff(pu);
      {$ENDIF}
   end;
end;

function _unit_ability_umstrike(pu:PTUnit;x0,y0:integer):boolean;
var i:byte;
begin
   _unit_ability_umstrike:=false;
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
         upgr[upgr_uac_rstrike]-=1;
         _unit_umstrike_missile(pu);
         buff[ub_cast]:=fr_fps;
         _unit_ability_umstrike:=true;
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
   r0+=1;
   r1+=1;
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



procedure _push_out(tx,ty,tr:integer;newx,newy:pinteger;_ukfly,check_doodads:boolean);
const nrl = 1;
var nrx,
    nry,
    nrd,
    nrt : array[0..nrl] of integer;
dx,dy,
o,u,d   : integer;

procedure add(ax,ay,ad,at:integer);
var i,n:integer;
begin
   // find insert i
   i:=0;
   while(i<=nrl)do
   begin
      if(ad<nrd[i])then break;
      i+=1;
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

   if(_ukfly)then check_doodads:=false;

   if(check_doodads)then
   begin
      tr-=bld_dec_mr;
      dx:=tx div dcw;
      dy:=ty div dcw;
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
      tr+=bld_dec_mr;
   end;

   if(_ukfly=false)and(g_mode=gm_cptp)then
    for u:=1 to MaxCPoints do
     with g_cpoints[u] do
     begin
        o:=base_r;
        d:=dist(px,py,tx,ty)-o;
        add(px,py,d,o);
     end;

   for u:=1 to MaxUnits do
    with _units[u] do
     with uid^ do
      if(hits>0)and(ukfly=_ukfly)then
       if(speed<=0)or(not bld)then
        if(not _IsUnitRange(inapc,nil))then
        begin
           o:=tr+_r;
           d:=dist(x,y,tx,ty);
           add(x,y,d-o,o);
        end;

   if(nrd[1]<=-1)
   then _2c_push(@tx,@ty,nrx[0],nry[0],nrt[0],nrx[1],nry[1],nrt[1])
   else
     if(nrd[0]<=-1)
     then _2c_push(@tx,@ty,nrx[0],nry[0],nrt[0],-2000,-2000,-2000);

   newx^:=tx;
   newy^:=ty;
end;


procedure _building_newplace(tx,ty:integer;buid,pl:byte;newx,newy:pinteger);
var
aukfly  :boolean;
dx,dy,o,
u,sr,dr :integer;
begin
   with _uids[buid] do
   begin
      aukfly:=_ukfly;
      _push_out(tx,ty,_r,@tx,@ty,aukfly,true);
   end;

   dx:=-2000;
   dy:=-2000;
   sr:=32000;
   dr:=32000;
   for u:=1 to MaxUnits do
    with _units[u] do
     with uid^ do
      if(hits>0)and(speed<=0)and(ukfly=aukfly)and(bld)and(playeri=pl)and(isbuildarea)then
       if(buid in ups_builder)and(not _IsUnitRange(inapc,nil))then
       begin
          o:=dist(x,y,tx,ty)-srange;
          if(o<dr)then
          begin
             dx:=x;
             dy:=y;
             dr:=o;
             sr:=srange;
          end;
       end;

   if(dr<32000)then
   begin
      o :=dist(dx,dy,tx,ty);
      dr:=o-sr;
      if(0<dr)then _1c_push(@tx,@ty,dx,dy,sr-1);
   end;

   tx:=mm3(map_b0,tx,map_b1);
   ty:=mm3(map_b0,ty,map_b1);
   newx^:=tx;
   newy^:=ty;
end;


function _collisionr(tx,ty,tr,skipunit:integer;flylevel,check_obstacles:boolean):byte;
var u,dx,dy:integer;
begin
   _collisionr:=0;

   for u:=1 to MaxUnits do
    if(u<>skipunit)then
     with _punits[u]^ do
      with uid^ do
       if(hits>0)and(ukfly=flylevel)and(_IsUnitRange(inapc,nil)=false)then
        if(speed<=0)or(not bld)then
         if(dist(x,y,tx,ty)<(tr+_r))then
         begin
            _collisionr:=2;
            exit;
         end;

   if(g_mode=gm_cptp)then
    for u:=1 to MaxCPoints do
     with g_cpoints[u] do
      if(dist(tx,ty,px,py)<base_r)then
      begin
         _collisionr:=3;
         exit;
      end;

   if(check_obstacles=false)or(flylevel)then exit;

   tr-=bld_dec_mr;

   dx:=tx div dcw;
   dy:=ty div dcw;

   if(0<=dx)and(dx<=dcn)and(0<=dy)and(dy<=dcn)then
    with map_dcell[dx,dy] do
     if(n>0)then
      for u:=0 to n-1 do
       with l[u]^ do
        if(r>0)and(t>0)then
         if(dist(x,y,tx,ty)<(tr+r))then
         begin
            _collisionr:=4;
            exit;
         end;
end;

function _InBuildArea(tx,ty,tr:integer;buid,pl:byte):byte;
var u:integer;
begin
   _InBuildArea:=0;

   if(pl<=MaxPlayers)then
    with _players[pl] do
     if(n_builders<=0)then
     begin
        _InBuildArea:=1; // no builders
        exit;
     end;

   if(tx<map_b0)or(map_b1<tx)
   or(ty<map_b0)or(map_b1<ty)then
   begin
      _InBuildArea:=2;  // out of bounds
      exit;
   end;

   tr+=_uids[buid]._r;

   _InBuildArea:=2;

   for u:=1 to MaxUnits do
    with _punits[u]^ do
     with uid^ do
      if(hits>0)and(bld)and(isbuildarea)and(playeri=pl)then
       if(abs(x-tx)<=srange)and(abs(y-ty)<=srange)then
        if(buid in ups_builder)and(_IsUnitRange(inapc,nil)=false)then
         if(dist(x,y,tx,ty)<srange)then
         begin
            _InBuildArea:=0; // inside build area
            break;
         end;
end;

function _CheckBuildPlace(tx,ty,tr,uskip:integer;playern,buid:byte;obstacles:boolean):byte;
var i:byte;
begin
   _CheckBuildPlace:=0;

   {
   0 :  m_brushc:=c_lime;
   1 :  m_brushc:=c_red;
   2 :  m_brushc:=c_blue;
   else m_brushc:=c_gray;
   }

   i:=_InBuildArea(tx,ty,0,buid,playern); // 0=inside; 1=outside; 2=no builders
   case i of
   0  : ;
   2  : begin _CheckBuildPlace:=2;exit;end;
   else begin _CheckBuildPlace:=3;exit;end;
   end;

   i:=_collisionr(tx,ty,tr+_uids[buid]._r,uskip,_uids[buid]._ukfly,obstacles);
   if(i>0)then _CheckBuildPlace:=1;
end;


function _unit_ability_hkteleport(pu:PTUnit;x0,y0:integer):boolean;
begin
   _unit_ability_hkteleport:=false;
   with pu^ do
    if(hits>0)and(bld)and(buff[ub_clcast]<=0)then
     with player^ do
      if(upgr[upgr_hell_hktele]>0)then
      begin
         _push_out(x0,y0,uid^._r,@x0,@y0,ukfly, (upgr[upgr_uac_ccldoodads]<=0)and(upgr[upgr_hell_hktdoodads]<=0)  );
         if(_collisionr(x0,y0,uid^._r,unum,ukfly, (upgr[upgr_uac_ccldoodads]<=0)and(upgr[upgr_hell_hktdoodads]<=0) )>0)then exit;

         upgr[upgr_hell_hktele]-=1;
         buff[ub_clcast]:=fr_fps;

         _unit_teleport(pu,x0,y0{$IFDEF _FULLGAME},EID_HKT_h,EID_HKT_s,snd_cube{$ENDIF});
         _unit_ability_hkteleport:=true;
      end;
end;


function _unit_ability_htteleport(pu:PTUnit;x0,y0:integer):boolean;
begin
   _unit_ability_htteleport:=false;
   with pu^ do
    if(hits>0)and(bld)and(buff[ub_clcast]<=0)then
     with player^ do
      if(upgr[upgr_hell_b478tel]>0)then
      begin
         if(srange<dist(x,y,x0,y0))then _1c_push(@x0,@y0,x,y,srange-1);
         _push_out(x0,y0,uid^._r,@x0,@y0,ukfly, true  );
         if(dist(x,y,x0,y0)>srange)then exit;
         if(_collisionr(x0,y0,uid^._r,unum,ukfly, true )>0)then exit;

         upgr[upgr_hell_b478tel]-=1;
         buff[ub_clcast]:=fr_2hfps;
         _unit_teleport(pu,x0,y0{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF});
         _unit_ability_htteleport:=true;
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
      a_rld    := 0;
      a_weap_cl:= 0;
      a_tar_cl := 0;

      aiu_alarm_timer:=0;
      aiu_alarm_d    :=32000;
      aiu_alarm_x    :=-1;
      aiu_alarm_y    :=0;
      aiu_need_detect:=32000;
      aiu_armyaround_ally :=0;
      aiu_armyaround_enemy:=0;


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
      if(_isbuilder)then n_builders+=1;
      if(_isbarrack)then
      begin
         n_barracks+=1;
         if(buff[ub_advanced]>0)
         then uprodm+=2
         else uprodm+=1;
      end;
      if(_issmith  )then
      begin
         n_smiths+=1;
         if(buff[ub_advanced]>0)
         then upprodm+=2
         else upprodm+=1;
      end;
   end;
end;
procedure _unit_done_dec_cntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(_isbuilder)then n_builders-=1;
      if(_isbarrack)then
      begin
         n_barracks-=1;
         if(buff[ub_advanced]>0)
         then uprodm-=2
         else uprodm-=1;
      end;
      if(_issmith  )then
      begin
         n_smiths-=1;
         if(buff[ub_advanced]>0)
         then upprodm-=2
         else upprodm-=1;
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
      if(ucl_x[_ukbuilding,_ucl]=unum)then ucl_x[_ukbuilding,_ucl]:=0;
      ucl_eb[_ukbuilding,_ucl]-=1;
      uid_eb[uidi            ]-=1;
      menergy-=_genergy;
      cenergy-=_genergy;
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
      if(ucl_x[_ukbuilding,_ucl]<=0)then ucl_x[_ukbuilding,_ucl]:=unum;
      ucl_eb[_ukbuilding,_ucl]+=1;
      uid_eb[uidi            ]+=1;
      menergy+=_genergy;
      cenergy+=_genergy;
      _unit_done_inc_cntrs(pu);
   end;
end;

procedure _unit_inc_cntrs(pu:PTUnit;ubld,summoned:boolean);
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      army+=1;
      armylimit+=_limituse;
      ucl_e[_ukbuilding,_ucl]+=1;
      ucl_c[_ukbuilding     ]+=1;
      uid_e[uidi            ]+=1;

      bld:=ubld;

      if(bld)
      then _unit_bld_inc_cntrs(pu)
      else
      begin
         hits  := 1;
         cenergy-=_renergy;
         {$IFDEF _FULLGAME}
         if(playeri=HPlayer)then SoundPlayAnoncer(snd_build_place[_urace],false);
         {$ENDIF}
      end;

      if(summoned)and(bld)then
      begin
         buff[ub_summoned]:=fr_fps;
         {$IFDEF _FULLGAME}
         _unit_summon_effects(_LastCreatedUnitP,nil);
         {$ENDIF}
      end;
   end;
end;

procedure _unit_add(ux,uy:integer;ui,pl:byte;ubld,summoned,advanced:boolean);
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
         i+=1;
      end;

      FillChar(_LastCreatedUnitP^,SizeOf(TUnit),0);
      if(_LastCreatedUnit>0)then
       with _LastCreatedUnitP^ do
       begin
          cycle_order:= _LastCreatedUnit mod order_period;
          unum    := _LastCreatedUnit;

          x       := ux;
          y       := uy;
          _unit_correctXY(_LastCreatedUnitP);
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
          _unit_apUID    (_LastCreatedUnitP,advanced);
          _unit_inc_cntrs(_LastCreatedUnitP,ubld,summoned);
       end;
   end;
end;

function _unit_start_build(bx,by:integer;buid,bp:byte):cardinal;
begin
   _unit_start_build:=_uid_conditionals(@_players[bp],buid);
   if(_unit_start_build=0)then
    with _players[bp] do
     if(_CheckBuildPlace(bx,by,0,0,bp,buid,true)=0)
     then _unit_add(bx,by,buid,bp,false,false,false)
     else _unit_start_build:=ureq_place;
end;


//////   Start unit prod
//
function _unit_straining_p(pu:PTUnit;puid:byte;pn:integer):boolean;
begin
   _unit_straining_p:=false;
   if(0<puid)and(puid<255)then
    with pu^ do
     with uid^ do
      if(hits>0)and(bld)and(_isbarrack)and(_ukbuilding)then
       if not (puid in ups_units)
       then PlayerSetProdError(playeri,glcp_unit,puid,ureq_barracks,pu)
       else
         if(uprod_r[pn]>0)
         then PlayerSetProdError(playeri,glcp_unit,puid,ureq_busy,pu)
         else
           if(not PlayerSetProdError(playeri,glcp_unit,puid,_uid_conditionals(pu^.player,puid),pu))then
            with player^ do
            begin
               uproda+=1;
               uprodl+=_uids[puid]._limituse;
               uprodc[_uids[puid]._ucl]+=1;
               uprodu[ puid           ]+=1;
               cenergy-=_uids[puid]._renergy;
               uprod_u[pn]:=puid;
               uprod_r[pn]:=_uids[puid]._tprod;

               _unit_straining_p:=true;
            end;
end;
function _unit_straining(pu:PTUnit;puid:byte):boolean;
var i:byte;
begin
   _unit_straining:=true;

   for i:=0 to MaxUnitProdsI do
   begin
      if(i>0)then
       if(pu^.buff[ub_advanced]<=0)then break;

      if(_unit_straining_p(pu,puid,i))then exit;
   end;

   _unit_straining:=false;
end;
/// Stop unit prod
function _unit_ctraining_p(pu:PTUnit;puid,pn:byte):boolean;
begin
   _unit_ctraining_p:=false;
   with pu^ do
   with uid^ do
    if(uprod_r[pn]>0)and(bld)and(_isbarrack)and(_ukbuilding)then
     if(puid=255)or(puid=uprod_u[pn])then
      with player^ do
      begin
         puid:=uprod_u[pn];

         uproda-=1;
         uprodl-=_uids[puid]._limituse;
         uprodc[_uids[puid]._ucl]-=1;
         uprodu[ puid           ]-=1;
         cenergy+=_uids[puid]._renergy;
         uprod_r[pn]:=0;

         _unit_ctraining_p:=true;
      end;
end;
function _unit_ctraining(pu:PTUnit;puid:byte):boolean;
var i:byte;
begin
   _unit_ctraining:=true;

   for i:=MaxUnitProdsI downto 0 do
    if(_unit_ctraining_p(pu,puid,i))and(puid<255)then exit;

   _unit_ctraining:=false;
end;


//////   Start upgrade production
//
function _unit_supgrade_p(pu:PTUnit;upid,pn:byte):boolean;
begin
   _unit_supgrade_p:=false;
   if(upid<255)then
    with pu^ do
     with uid^ do
      if(hits>0)and(bld)and(_issmith)and(_ukbuilding)then
       if not(upid in ups_upgrades)
       then PlayerSetProdError(playeri,glcp_upgr,upid,ureq_smiths,pu)
       else
         if(pprod_r[pn]>0)
         then PlayerSetProdError(playeri,glcp_upgr,upid,ureq_busy,pu)
         else
           if(not PlayerSetProdError(playeri,glcp_upgr,upid,_upid_conditionals(player,upid),pu))then
            with player^ do
             with _upids[upid] do
             begin
                upproda+=1;
                upprodu[upid]+=1;
                cenergy-=_up_renerg;
                pprod_r[pn]:=_up_time;
                pprod_u[pn]:=upid;

                _unit_supgrade_p:=true;
             end;
end;
function _unit_supgrade(pu:PTUnit;upid:integer):boolean;
var i:byte;
begin
   _unit_supgrade:=true;

   for i:=0 to MaxUnitProdsI do
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
    if(pprod_r[pn]>0)and(bld)and(_issmith)and(_ukbuilding)then
     if(upid=255)or(upid=pprod_u[pn])then
      with player^ do
      begin
         upid:=pprod_u[pn];

         upproda-=1;
         upprodu[upid]-=1;
         cenergy+=_upids[upid]._up_renerg;
         pprod_r[pn]:=0;

         _unit_cupgrade_p:=true;
       end;
end;
function _unit_cupgrade(pu:PTUnit;puid:byte):boolean;
var i:byte;
begin
   _unit_cupgrade:=true;

   for i:=MaxUnitProdsI downto 0 do
    if(_unit_cupgrade_p(pu,puid,i))and(puid<255)then exit;

   _unit_cupgrade:=false;
end;

procedure _unit_counters_inc_select(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      ucl_s [_ukbuilding,_ucl]+=1;
      ucl_cs[_ukbuilding     ]+=1;
      uid_s [uidi            ]+=1;
      if(_isbuilder)then s_builders+=1;
      if(_isbarrack)then s_barracks+=1;
      if(_issmith  )then s_smiths  +=1;
   end;
end;
procedure _unit_counters_dec_select(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      ucl_s [_ukbuilding,_ucl]-=1;
      ucl_cs[_ukbuilding     ]-=1;
      uid_s [uidi            ]-=1;
      if(_isbuilder)then s_builders-=1;
      if(_isbarrack)then s_barracks-=1;
      if(_issmith  )then s_smiths  -=1;
   end;
end;

procedure _unit_desel(pu:PTUnit);
begin
   with pu^ do
   begin
      if(sel)then _unit_counters_dec_select(pu);
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
      then cenergy+=_uids[uidi]._renergy
      else
      begin
         _unit_ctraining(pu,255);
         _unit_cupgrade (pu,255);

         ucl_eb[_ukbuilding,_ucl]-=1;
         uid_eb[uidi            ]-=1;
         menergy-=_genergy;
         cenergy-=_genergy;

         _unit_done_dec_cntrs(pu);
      end;

      if(ucl_x[_ukbuilding,_ucl]=unum)then ucl_x[_ukbuilding,_ucl]:=0;
      if(uid_x[uidi            ]=unum)then uid_x[uidi            ]:=0;
   end;
end;

procedure _unit_dec_Rcntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      army     -=1;
      armylimit-=_limituse;
      ucl_e[_ukbuilding,_ucl]-=1;
      ucl_c[_ukbuilding     ]-=1;
      uid_e[uidi            ]-=1;
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
      if(_uids[_uid]._ukfly=uf_fly)
      then sr:=0
      else sr:=_r;//+_uids[_uid]._r;

      for i:=0 to count do
      begin
         cd:=(dir+i*15)*degtorad;

         _unit_add(x+trunc(sr*cos(cd)),
                   y-trunc(sr*sin(cd)),_uid,playeri,true,false,false);
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
               if(SoundPlayUnit(snd_teleport,pu,nil))
               then _effect_add(_LastCreatedUnitP^.vx,_LastCreatedUnitP^.vy,_depth(_LastCreatedUnitP^.vy+1,_LastCreatedUnitP^.ukfly),EID_Teleport);
               {$ENDIF}
            end;
            GameLogUnitReady(_LastCreatedUnitP);
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
   for i:=0 to MaxUnitProdsI do
   if(uprod_r[i]>0)then
   begin
       _uid:=uprod_u[i];

      if((army     +uproda)>MaxPlayerUnits)
      or((armylimit+uprodl)>MaxPlayerLimit)
      or(cenergy<0)
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
  for i:=0 to MaxUnitProdsI do
  if(pprod_r[i]>0)then
  begin
      _uid:=pprod_u[i];
     if(cenergy<0)
     or(upgr[_uid]>=_upids[_uid]._up_max)
     or(upgr[_uid]>=a_upgrs[_uid])
     then _unit_cupgrade_p(pu,255,i)
     else
       if(pprod_r[i]=1){$IFDEF _FULLGAME}or(_warpten){$ENDIF}then
       begin
          upgr[_uid]+=1;
          _unit_cupgrade_p(pu,255,i);
          GameLogUpgradeComplete(playeri,_uid,x,y);
       end
       else pprod_r[i]:=max2(1,pprod_r[i]-1*(upgr[upgr_fast_product]+1) );
  end;
end;



procedure _unit_ability_spawn(pu:PTUnit;tx,ty:integer;auid:byte);
var tu:PTUnit;
begin
   with pu^ do
   with player^ do
   begin
      if(_uid_player_limit(player,auid)=false)
      then _LastCreatedUnit:=0
      else
        if(ServerSide)
        then _unit_add(tx,ty,auid,playeri,true,true,buff[ub_advanced]>0)
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
      end
      {$IFDEF _FULLGAME}
      else
        case auid of
UID_LostSoul: _pain_lost_fail(tx,ty,_depth(ty+1,ukfly),nil);
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
      _unit_ability_spawn(pu,x+dir_stepX[dd]*_r,y+dir_stepY[dd]*_r,auid);
   end;
end;


function _itcanapc(uu,tu:PTUnit):boolean;
begin
   //uu - transport
   //ru - target
   _itcanapc:=false;
   if(tu^.ukfly=uf_fly)or(uu=tu)then exit;

   if(uu^.player<>tu^.player)then
    if(uu^.player^.team<>tu^.player^.team)
    then exit;

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
        buff[i]-=1;

      for i:=0 to MaxPlayers do
      begin
         if(0<vsnt[i])and(vsnt[i]<_ub_infinity)then vsnt[i]-=1;
         if(0<vsni[i])and(vsni[i]<_ub_infinity)then vsni[i]-=1;
      end;

      if(bld)then
      begin
         if(  rld>0)then   rld-=1;
         if(a_rld>0)then a_rld-=1;
      end;
   end;
end;


procedure _unit_detect(uu,tu:PTUnit;ud:integer);
var td:integer;
begin
   // tu - unit-detector
   // uu - unit-target
   with uu^ do
   begin
      if(tu^.uid^._ability=uab_radar)and(tu^.rld>radar_btime)
      then td:=min2(ud,dist(x,y,tu^.uo_x,tu^.uo_y))
      else td:=ud;

      if(td<=(tu^.srange+uid^._r))then
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


procedure _unit_remove(pu:PTUnit);
begin
   with pu^ do
    with player^ do
    begin
       _unit_dec_Rcntrs(pu);

       //if(G_Status=gs_running)then
        if(playeri>0)or not(g_mode in [gm_inv])then
         if(army<=0)and(state>ps_none){$IFDEF _FULLGAME}and(menu_s2<>ms2_camp){$ENDIF}
         then GameLogPlayerDefeated(playeri);
    end;
end;

procedure _check_missiles(u:integer);
var i:integer;
begin
   for i:=1 to MaxUnits do
    with _missiles[i] do
     if(vstep>0)and(tar=u)then tar:=0;
end;

procedure _unit_kill(pu:PTUnit;instant,fastdeath,buildcd:boolean);
var i :integer;
    tu:PTunit;
begin
   with pu^ do
   if(hits>0)then
   with player^ do
   begin
      if(instant=false)then
      begin
         with uid^ do fastdeath:=(fastdeath)or(_fastdeath_hits[buff[ub_advanced]>0]>=0)or(_ukmech)or(_ukbuilding);
         buff[ub_pain]:=fr_fps; // prevent fast resurrecting

         {$IFDEF _FULLGAME}
         _unit_death_effects(pu,fastdeath,nil);
         {$ENDIF}
      end;

      {$IFDEF _FULLGAME}
      if(unum=ui_UnitSelectedPU)then ui_UnitSelectedPU:=0;
      {$ENDIF}

      _unit_dec_Kcntrs(pu);

      with uid^ do
      begin
         if(_ukbuilding)and(buildcd)then build_cd:=min2(build_cd+step_build_reload,max_build_reload);
         zfall:=_zfall;
      end;

      x      :=vx;
      y      :=vy;
      uo_x   :=x;
      uo_y   :=y;
      uo_bx  :=-1;
      uo_by  :=-1;
      uo_tar :=0;
      mv_x   :=x;
      mv_y   :=y;
      a_tar  :=0;
      rld    :=0;

      for i:=1 to MaxUnits do
      if(i<>unum)then
      begin
         tu:=@_units[i];
         if(tu^.hits>0)then
         begin
            if(tu^.uo_tar=unum)then tu^.uo_tar:=0;
            if(apcc>0)then
             if(tu^.inapc=unum)then
             begin
                if(ukfly<>uf_ground)or(inapc>0)
                then _unit_kill(tu,true,false,true)
                else
                begin
                   tu^.inapc:=0;
                   apcc-=tu^.uid^._apcs;
                   tu^.x+=_randomr(uid^._r);
                   tu^.y+=_randomr(uid^._r);
                   tu^.uo_x:=tu^.x;
                   tu^.uo_y:=tu^.y;
                   if(tu^.hits>apc_exp_damage)then
                   begin
                      tu^.hits-=apc_exp_damage;
                      tu^.buff[ub_invuln]:=10;
                   end
                   else _unit_kill(tu,true,false,true);
                end;
             end;
         end;
      end;
      _check_missiles(unum);

      if(instant)then
      begin
         hits:=ndead_hits;
         _unit_remove(pu);
      end
      else
        if(fastdeath)
        then hits:=fdead_hits
        else hits:=0;
   end;
end;


procedure _unit_upgr(pu:PTUnit);
var tu:PTUnit;
procedure SetSRange(newsr:integer);
begin
   with pu^ do
   if(srange<>newsr)then
   begin
      srange:=newsr;
      {$IFDEF _FULLGAME}
      _unit_fog_r(pu);
      {$ENDIF}
   end;
end;
begin
   with pu^ do
   with uid^ do
   with player^ do
   if(bld)and(hits>0)then
   begin
      // ABILITIES
      case _ability of
uab_radar        : SetSRange(radar_range[mm3(0,upgr[upgr_uac_radar_r],radar_upgr_levels)]);
uab_teleport     : buff[ub_advanced]:=b2ib[upgr[upgr_hell_revtele     ]>0];
uab_uac__unit_adv: buff[ub_advanced]:=b2ib[upgr[upgr_uac_6bld         ]>0];
uab_building_adv : buff[ub_advanced]:=b2ib[upgr[upgr_race_9bld[_urace]]>0];
      end;

      // DETECTION
      case uidi of
UID_HASymbol,
UID_UMine,
UID_URadar       : buff[ub_detect]:=b2ib[upgr[upgr_race_detect[_urace]]>0];
UID_HEye         : buff[ub_detect]:=_ub_infinity;
      end;
      if(buff[ub_hvision]>0)then
       if(buff[ub_detect]<buff[ub_hvision])then buff[ub_detect]:=buff[ub_hvision];

      // INVIS
      case uidi of
UID_HTotem       : buff[ub_invis]:=b2ib[upgr[upgr_hell_totminv]>0];
UID_Commando,
UID_Demon        : buff[ub_invis]:=buff[ub_advanced];
UID_HEye,
UID_UMine        : buff[ub_invis]:=_ub_infinity;
      end;

      // OTHER
      case uidi of
UID_LostSoul: begin
                 tu:=nil;
                 if(_IsUnitRange(a_tar,@tu))and(a_rld>0)then buff[ub_clcast]:=fr_2hfps;
                 if(buff[ub_clcast]>0)and(tu<>nil)then ukfly:=tu^.ukfly else ukfly:=_ukfly;
              end;
UID_Demon   : if(upgr[upgr_hell_pinkspd]>0)then
              begin
                 if(speed=_speed)then begin speed :=_speed+7;{$IFDEF _FULLGAME}animw :=_animw+4;{$ENDIF}end;
              end
              else
                if(speed<>_speed)then begin speed :=_speed;  {$IFDEF _FULLGAME}animw :=_animw;  {$ENDIF}end;
UID_HCommandCenter,
UID_UCommandCenter:
           if(buff[ub_advanced]>0)then
           begin
              if(ukfly<>uf_fly)then
              begin
                 {$IFDEF _FULLGAME}
                 SoundPlayUnit(snd_CCup ,pu,nil);
                 {$ENDIF}
                 ukfly:=uf_fly;
                 zfall:=zfall-fly_hz;
                 _unit_clear_order(pu,false);
              end;
              speed:=6;
           end
           else
           begin
              if(ukfly<>uf_ground)then
              begin
                 {$IFDEF _FULLGAME}
                 SoundPlayUnit(snd_inapc,pu,nil);
                 {$ENDIF}
                 zfall:=fly_hz;
                 ukfly:=uf_ground;
                 _unit_clear_order(pu,false);
              end;
              speed:=0;

              if(zfall<>0)then
               if(_collisionr(x,y+zfall,_r,unum,false, (upgr[upgr_uac_ccldoodads]<=0)and(upgr[upgr_hell_hktdoodads]<=0) )>0)then buff[ub_advanced]:=_ub_infinity;
           end;
UID_Major,
UID_ZMajor:
           if(buff[ub_advanced]>0)then
           begin
              if(ukfly<>uf_fly)then
              begin
                 {$IFDEF _FULLGAME}
                 SoundPlayUnit(snd_jetpon ,pu,nil);
                 {$ENDIF}
                 zfall:=-fly_height[uf_fly];
                 ukfly:=uf_fly;
                 speed:=_speed+_speed;
              end;
           end
           else
           begin
              if(ukfly<>uf_ground)then
              begin
                 {$IFDEF _FULLGAME}
                 SoundPlayUnit(snd_jetpoff,pu,nil);
                 {$ENDIF}
                 zfall:= fly_height[uf_fly];
                 ukfly:=uf_ground;
                 speed:=_speed;
              end;
           end;
UID_FAPC    : if(buff[ub_advanced]>0)
              then apcm:=_apcm+4
              else apcm:=_apcm;
UID_APC     : if(buff[ub_advanced]>0)
              then apcm:=_apcm+2
              else apcm:=_apcm;
UID_UGTurret: buff[ub_advanced]:=b2ib[upgr[upgr_uac_plasmt]>0];
      end;
      if(upgr[upgr_invuln]>0)then buff[ub_invuln]:=fr_fps;

      // BUILD AREA
      if(_isbuilder)then isbuildarea:=true;
      case uidi of
UID_HCommandCenter,
UID_UCommandCenter: isbuildarea:=not ukfly;
      end;

      // SRANGE
      case uidi of
UID_Cyberdemon,
UID_Mastermind,
UID_Engineer,
UID_Medic,
UID_BFG,
UID_ZBFG,
UID_Major,
UID_ZMajor   : if(buff[ub_advanced]>0)
               then SetSRange(_srange+50)
               else SetSRange(_srange   );
      else
        if(_upgr_srange>0)and(_upgr_srange_step>0)then SetSRange(_srange+(upgr[_upgr_srange]*_upgr_srange_step));
      end;
   end;
end;



