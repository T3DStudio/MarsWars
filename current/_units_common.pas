{$IFDEF _FULLGAME}
procedure unit_MiniMapXY(pu:PTUnit);
begin
   with pu^ do
   begin
      mmx:=trunc(x*map_mmcx);
      mmy:=trunc(y*map_mmcx);
   end;
end;

procedure effect_LevelUp(pu:PTUnit;etype:byte;vischeck:pboolean);
begin
   with pu^ do
   begin
      if(vischeck<>nil)then
      begin
         if(vischeck^=false)then exit
      end
      else
         if(not CheckUnitUIVisionScreen(pu))then exit;

      case etype of
EID_HVision : begin
              SoundPlayUnit(snd_hell_eye,pu,nil);
              effect_add(vx,vy,_SpriteDepth(vy+1,ukfly),EID_HVision);
              end;
EID_Invuln  : begin
              SoundPlayUnit(snd_hell_invuln,pu,nil);
              effect_add(vx,vy,_SpriteDepth(vy+1,ukfly),EID_Invuln);
              end;
      else
         case uid^._urace of
r_hell : begin
            SoundPlayUnit(snd_unit_adv[uid^._urace],pu,nil);
            effect_add(vx,vy,_SpriteDepth(vy+1,ukfly),EID_HLevelUp);
         end;
r_uac  : begin
            SoundPlayUnit(snd_unit_adv[uid^._urace],pu,nil);
            effect_add(vx,vy,_SpriteDepth(vy+1,ukfly),EID_ULevelUp);
         end;
         end;
      end;
   end;
end;

procedure effect_RStationShot(pu:PTUnit);
begin
   with pu^ do
   begin
      effect_add(vx,vy-15,_SpriteDepth(vy+10,ukfly),EID_Exp2);
      SoundPlayUnit(snd_bomblaunch,nil,nil)
   end;
end;

procedure effect_CPExplode(vx,vy:integer);
begin
   effect_add(vx,vy,sd_liquid+vy,EID_db_u0);
   if(MapPointInScreenP(vx,vy,true))then
   begin
      effect_add(vx,vy,_SpriteDepth(vy+1,false),EID_BBExp);
      SoundPlayUnit(snd_exp,nil,nil);
   end;
end;

procedure effect_UnitSummon(pu:PTUnit;vischeck:pboolean);
begin
   with pu^ do
   if(hits>0)and(iscomplete)then
   with uid^ do
   begin
      if(vischeck<>nil)then
      begin
         if(vischeck^=false)then exit
      end
      else
         if(not CheckUnitUIVisionScreen(pu))then exit;
      //writeln(uid^.un_txt_name);

      SoundPlayUnit(un_eid_snd_summon,nil,nil);
      effect_add(vx,vy,_SpriteDepth(vy+1,ukfly),un_eid_summon[level]);

      if(playeri=UIPlayer)then SoundPlayUnit(un_snd_ready,nil,nil);
   end;
end;

procedure effect_UnitDeath(pu:PTUnit;fastdeath:boolean;vischeck:pboolean);
begin
   with pu^ do
   with uid^ do
   begin
      if(not ukfly)then
      effect_add(vx,vy+un_eid_bcrater_y,sd_liquid+vy,un_eid_bcrater);

      if(vischeck<>nil)then
      begin
         if(vischeck^=false)then exit
      end
      else
        if(not CheckUnitUIVisionScreen(pu))then exit;

      if(fastdeath)then
      begin
         effect_add(vx,vy,_SpriteDepth(vy+1,ukfly),un_eid_fdeath[level]);
         SoundPlayUnit(un_eid_snd_fdeath,nil,nil);
      end
      else
      begin
         effect_add(vx,vy,vy+1,un_eid_death[level]);
         SoundPlayUnit(un_eid_snd_death,nil,nil);
      end;
   end;
end;

procedure effect_UnitPain(pu:PTUnit;vischeck:pboolean);
begin
   with pu^ do
   with uid^ do
   begin
      if(vischeck<>nil)then
      begin
         if(vischeck^=false)then exit
      end
      else
        if(not CheckUnitUIVisionScreen(pu))then exit;

      effect_add(vx,vy,_SpriteDepth(vy+1,ukfly),un_eid_pain[level]);
      SoundPlayUnit(un_eid_snd_pain,nil,nil);
   end;
end;

procedure effect_InPoint(tx,ty,dy:integer;vischeck:pboolean;effect:byte;sound:PTSoundSet);
begin
   if(vischeck<>nil)then
   begin
      if(vischeck^=false)then exit
   end
   else
     if(MapPointInScreenP(tx,ty,true)=false)then exit;

   effect_add(tx,ty,dy,effect);
   SoundPlayUnit(sound,nil,nil);
end;

procedure effect_UnitAttack(pu:PTUnit;start:boolean;vischeck:pboolean);
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
        if(not CheckUnitUIVisionScreen(pu))then exit;

      if(start)then
      begin
         effect_add(vx,vy,_SpriteDepth(vy+1,ukfly),aw_eid_start);
         SoundPlayUnit(aw_snd_start,nil,nil);
      end
      else
      begin
         effect_add(vx+aw_x,vy+aw_y,_SpriteDepth(vy+1,ukfly),aw_eid_shot );
         SoundPlayUnit(aw_snd_shot,nil,nil);
      end;
   end;
end;

{$ENDIF}

function unit_canMove(pu:PTUnit):boolean;
begin
   with pu^ do
   with uid^ do
    if(not ServerSide)and(speed>0)
    then unit_canMove:=(x<>mv_x)or(y<>mv_y)
    else
    begin
       unit_canMove:=false;

       if(speed<=0)
       or(hits<=0)
       or(not iscomplete)then exit;

       if(a_rld>0)then
        if(a_weap_cl>MaxUnitWeapons)
        then exit
        else
         with _a_weap[a_weap_cl] do
          if((aw_reqf and wpr_move)=0)then exit;

       if(not _ukbuilding)then
         if(buff[ub_Pain]>0)
         or(buff[ub_Cast]>0)then exit;

       unit_canMove:=true;
    end;
end;

function unit_canAttack(pu:PTUnit;check_buffs:boolean):boolean;
var tu:PTUnit;
begin
   unit_canAttack:=false;
   with pu^  do
   with uid^ do
   begin
      if(iscomplete=false)or(hits<=0)or(_attack=atm_none)then exit;

      if(check_buffs)then
      begin
         if(not _ukbuilding)then
           if(buff[ub_Pain]>0)
           or(buff[ub_Cast]>0)then exit;
      end;

      case _attack of
   atm_bunker,
   atm_always  : if(IsUnitRange(transport,@tu))then
                 begin
                    if(IsUnitRange(tu^.transport,nil))then exit;
                    case tu^.uid^._attack of
                    atm_always,
                    atm_none,
                    atm_sturret: exit;
                    end;
                 end;
   atm_sturret : if(transportC<=0)then exit;
   atm_inapc   : if(transport <=0)then exit;
      else exit;
      end;
   end;
   unit_canAttack:=true;
end;

procedure unit_update_xy(pu:PTUnit);
var newzone:word;
begin
   with pu^ do
   begin
      newzone:=pf_get_area(x,y);
      if(ukfly)or(ukfloater)
      then pfzone:=newzone
      else
        if(not pf_IfObstacleZone(newzone))then pfzone:=newzone;

      {$IFDEF _FULLGAME}
      unit_MiniMapXY(pu);
      unit_FogXY(pu);
      {$ENDIF}
   end;
end;

procedure unit_SetXY(pu:PTUnit;ax,ay:integer;movevxy:byte);
var _px,_py:integer;
begin
   with pu^ do
   begin
      _px:=x;
      _py:=y;
      x:=mm3(1,ax,map_mw);
      y:=mm3(1,ay,map_mw);
      if(x<>_px)or(y<>_py)then
      begin
         unit_update_xy(pu);
         if(_px=uo_x)
        and(_py=uo_y)then
        begin
           uo_x:=x;
           uo_y:=y;
        end;
      end;
      case movevxy of
mvxy_relative: begin
                  vx+=x-_px;
                  vy+=y-_py;
               end;
mvxy_strict  : begin
                  vx:=x;
                  vy:=y;
               end;
      end;
   end;
end;

procedure unit_reveal(pu:PTUnit;reset:boolean);
var t:byte;
begin
   with pu^ do
    with player^ do
    begin
       if(reset)then
       begin
          FillChar(vsnt,SizeOf(vsnt),0);
          FillChar(vsni,SizeOf(vsni),0);
       end;
       _AddToInt(@vsnt[team],vistime);
       _AddToInt(@vsni[team],vistime);

       if(revealed)then
        for t:=0 to MaxPlayers do
        begin
           _AddToInt(@vsnt[t],fr_fps1);
           _AddToInt(@vsni[t],fr_fps1);
        end;
    end;
end;
procedure unit_UpdateVision(pu:PTUnit);
var t:byte;
begin
   with pu^ do
    for t:=0 to MaxPlayers do
    begin
       if(vsnt[t]>0)then _AddToInt(@vsnt[t],vistime);
       if(vsni[t]>0)then _AddToInt(@vsni[t],vistime);
    end;
end;

procedure unit_clear_order(pu:PTUnit;clearid:boolean);
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
procedure unit_clear_tar(tar:integer);
var u:integer;
begin
   for u:=1 to MaxUnits do
     with g_punits[u]^ do
       if(uo_tar=tar)then uo_tar:=0;
end;
procedure missiles_clear_tar(u:integer;ResetTarget:boolean);
var i:integer;
begin
   for i:=1 to MaxUnits do
    with g_missiles[i] do
     if(vstep>0)and(tar=u)then
     begin
        tar:=0;
        if(ResetTarget)then
        begin
           x:=vx;
           y:=vy;
           vstep:=1;
        end;
     end;
end;

procedure teleport_CalcReload(tu:PTUnit;limit:integer);
begin
   // tu - teleporter
   with tu^ do
    with player^ do rld:=integer(round(fr_fps1*limit/MinUnitLimit))*(hteleport_rldPerLimit-mm3(0,upgr[upgr_hell_teleport],hteleport_rldPerLimit));
end;

procedure unit_teleport(pu:PTUnit;tx,ty:integer{$IFDEF _FULLGAME};eidstart,eidend:byte;snd:PTSoundSet{$ENDIF});
begin
   with pu^ do
   begin
      tx:=mm3(0,tx,map_mw);
      ty:=mm3(0,ty,map_mw);
      {$IFDEF _FULLGAME}
      effect_teleport(vx,vy,tx,ty,ukfly,eidstart,eidend,snd);
      {$ENDIF}
      buff[ub_Teleport]:=fr_fps1;
      unit_SetXY(pu,tx,ty,mvxy_strict);
      unit_clear_order(pu,false);
      unit_clear_tar(unum);
      missiles_clear_tar(unum,false);
      unit_UpdateVision(pu);
   end;
end;

procedure unit_zfall(pu:PTUnit);
var st:integer;
begin
   with pu^ do
   if(zfall<>0)then
   begin
      st:=sign(zfall);
      if(zfall>1)then st*=2;
      zfall-=st;
      unit_SetXY(pu,x,y+st,mvxy_relative);
   end;
end;

procedure unit_MoveVis(pu:PTUnit);
begin
   if(ServerSide)then unit_zfall(pu);
   with pu^ do
   if(vx<>x)or(vy<>y)then
    if(IsUnitRange(transport,nil))then
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

function unit_ability_UACScan(pu:PTUnit;x0,y0:integer;check:boolean):cardinal;
begin
   unit_ability_UACScan:=ureq_unknown;
   with pu^ do
    if(iscomplete)and(rld<=0)then
    begin
       unit_ability_UACScan:=0;

       if(check)then exit;

       unit_clear_order(pu,true);
       uo_x:=x0;
       uo_y:=y0;
       rld :=radar_reload;
       buff[ub_Cast]:=fr_fps1;

       {$IFDEF _FULLGAME}
       if(ServerSide)and(player^.team=g_players[UIPlayer].team)then SoundPlayUnit(snd_radar,nil,nil);
       {$ENDIF}
    end;
end;

function unit_ability_HInvuln(pu:PTUnit;taru:integer;check:boolean):cardinal;
var tu:PTUnit;
begin
   // pu - caster
   // tu - target
   with pu^ do
   begin
      unit_ability_HInvuln:=ureq_unknown;
      if(not iscomplete)
      or(hits<=0)then exit;

      unit_ability_HInvuln:=ureq_reloading;
      if(rld>0)then exit;
   end;

   unit_ability_HInvuln:=ureq_invalidtar;
   if(not IsUnitRange(taru,@tu))
   then exit;

   if(tu^.hits<=0)then exit;

   with pu^ do
   with player^ do
   begin
      if(team<>tu^.player^.team)
      or(tu^.buff[ub_Invuln]>0)then exit;

      unit_ability_HInvuln:=0;

      if(check)then exit;

      tu^.buff[ub_Invuln]:=invuln_time;
      pu^.rld:=haltar_reload;
      {$IFDEF _FULLGAME}
      effect_LevelUp(tu,EID_Invuln,nil);
      {$ENDIF}
   end;
end;

procedure unit_UACStrike_missile(pu:PTUnit);
begin
   with pu^ do
   begin
      missile_add(uo_x,uo_y,vx,vy,0,MID_Blizzard,playeri,uf_ground,uf_ground,false,0,dm_RSMShot);
      {$IFDEF _FULLGAME}
      effect_RStationShot(pu);
      {$ENDIF}
   end;
end;

function unit_ability_UACStrike(pu:PTUnit;x0,y0:integer;check:boolean):cardinal;
var i:byte;
begin
   unit_ability_UACStrike:=ureq_unknown;
   with pu^ do
    if(iscomplete)and(rld<=0)then
     with player^ do
     begin
        unit_ability_UACStrike:=0;
        if(check)then exit;
        unit_clear_order(pu,true);
        uo_x:=x0;
        uo_y:=y0;
        for i:=0 to MaxPlayers do _addtoint(@vsnt[i],fr_fps2);
        rld:=mstrike_reload;
        unit_UACStrike_missile(pu);
        buff[ub_Cast]:=fr_fps1;
     end;
end;



procedure msth_1c_push(tx,ty:pinteger;x0,y0,r0:integer);
var vx,vy,a:single;
begin
   vx :=x0-tx^;
   vy :=y0-ty^;
   a  :=sqrt(sqr(vx)+sqr(vy));
   if(a=0)then exit;
   vx :=vx/a;
   vy :=vy/a;
   tx^:=x0-trunc(r0*vx);
   ty^:=y0-trunc(r0*vy);
end;

procedure math_2c_push(tx,ty:pinteger;x0,y0,r0,x1,y1,r1:integer);
var d:integer;
vx,vy,
  a,h:single;
begin
   r0+=1;
   r1+=1;
   d:=point_dist_int(x0,y0,x1,y1);
   if(abs(r0-r1)<=d)and(d<=(r0+r1))and(d>0)then
   begin
      a:=(sqr(r0)-sqr(r1)+sqr(d))/(2*d);
      h:=sqrt(sqr(r0)-sqr(a));

      vx:=(x1-x0)/d;
      vy:=(y1-y0)/d;

      if( trunc(-vy*(x0-tx^)+vx*(y0-ty^)) <= 0 )then
      begin
         tx^:=trunc( x0+a*vx-(h*vy) );
         ty^:=trunc( y0+a*vy+(h*vx) );
      end
      else
      begin
         tx^:=trunc( x0+a*vx+(h*vy) );
         ty^:=trunc( y0+a*vy-(h*vx) );
      end;
   end
   else msth_1c_push(tx,ty,x0,y0,r0);
end;

procedure math_push_out(tx,ty,tr,ignore_unum:integer;newx,newy:pinteger;_ukfly,check_obstacles:boolean;UnitObsTeamVis:byte=255);
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
      nrd[u]:= NOTSET;
      nrx[u]:=-2000;
      nry[u]:=-2000;
      nrt[u]:=0;
   end;

   if(_ukfly)then check_obstacles:=false;

   if(check_obstacles)then
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
              d:=point_dist_int(x,y,tx,ty)-o;
              add(x,y,d,o);
           end;
      tr+=bld_dec_mr;
   end;

   if(_ukfly=false)then
    for u:=1 to MaxCPoints do
     with g_cpoints[u] do
      if(cpCaptureR>0)and(cpNoBuildR>0)then
      begin
         o:=cpNoBuildR;
         d:=point_dist_int(cpx,cpy,tx,ty)-o;
         add(cpx,cpy,d,o);
      end;

   for u:=1 to MaxUnits do
    with g_units[u] do
     with uid^ do
      if(hits>0)and(ukfly=_ukfly)and(unum<>ignore_unum)then
       if(speed<=0)or(not iscomplete)then
        if(not IsUnitRange(transport,nil))then
        begin
           if(UnitObsTeamVis<=MaxPlayers)then
             if(vsnt[UnitObsTeamVis]<=0)then continue;

           o:=tr+_r;
           d:=point_dist_int(x,y,tx,ty);
           add(x,y,d-o,o);
        end;

   for u:=1 to MaxUnits do
    with g_units[u] do
     with uid^ do
      if(hits>0)and(unum<>ignore_unum)and(iscomplete)then
       if(not IsUnitRange(transport,nil))then
        if(uo_id=ua_psability)then
        begin
           if(UnitObsTeamVis<=MaxPlayers)then
             if(vsnt[UnitObsTeamVis]<=0)then continue;

           case _ability of
     uab_RebuildInPoint: begin
                         o:=tr+g_uids[_rebuild_uid]._r;
                         d:=point_dist_int(uo_x,uo_y,tx,ty);
                         add(uo_x,uo_y,d-o,o);
                         end;
           uab_CCFly   : begin
                         o:=tr+_r;
                         d:=point_dist_int(uo_x,uo_y+fly_hz,tx,ty);
                         add(uo_x,uo_y+fly_hz,d-o,o);
                         end;
           end;
        end;

   if(nrd[1]<=-1)
   then math_2c_push(@tx,@ty,nrx[0],nry[0],nrt[0],nrx[1],nry[1],nrt[1])
   else
     if(nrd[0]<=-1)
     then math_2c_push(@tx,@ty,nrx[0],nry[0],nrt[0],-2000,-2000,-2000);

   newx^:=tx;
   newy^:=ty;
end;


procedure BuildingFindNewPlace(tx,ty:integer;buid,pl:byte;newx,newy:pinteger;UnitObsTeamVis:byte=255);
var
aukfly  :boolean;
dx,dy,o,
u,sr,dr :integer;
begin
   with g_uids[buid] do
   begin
      aukfly:=_ukfly;
      with g_players[pl] do
       math_push_out(tx,ty,_r,0,@tx,@ty,aukfly,true,UnitObsTeamVis);
   end;

   dx:=-2000;
   dy:=-2000;
   sr:=NOTSET;
   dr:=NOTSET;
   for u:=1 to MaxUnits do
    with g_units[u] do
     with uid^ do
      if(hits>0)and(speed<=0)and(ukfly=aukfly)and(iscomplete)and(playeri=pl)and(_isbuilder)and(not ukfly)then
       if(player^.s_builders=0)or(sel)then
        if(buid in ups_builder)and(not IsUnitRange(transport,nil))then
        begin
           o:=point_dist_int(x,y,tx,ty)-srange;
           if(o<dr)then
           begin
              dx:=x;
              dy:=y;
              dr:=o;
              sr:=srange;
           end;
        end;

   if(dr<NOTSET)then
   begin
      o :=point_dist_int(dx,dy,tx,ty);
      dr:=o-sr;
      if(0<dr)then msth_1c_push(@tx,@ty,dx,dy,sr-1);
   end;

   tx:=mm3(map_b0,tx,map_b1);
   ty:=mm3(map_b0,ty,map_b1);
   newx^:=tx;
   newy^:=ty;
end;


function CheckCollisionR(tx,ty,tr,skipunit:integer;building,flylevel,check_obstacles:boolean;reveal_u:PTUnit=nil):byte;
var u,dx,dy:integer;
begin
   CheckCollisionR:=0;

   for u:=1 to MaxUnits do
    if(u<>skipunit)then
     with g_punits[u]^ do
      with uid^ do
       if(hits>0)and(ukfly=flylevel)and(IsUnitRange(transport,nil)=false)then
        if(speed<=0)or(not iscomplete)then
         if(point_dist_int(x,y,tx,ty)<(tr+_r))then
         begin
            CheckCollisionR:=2;
            if(reveal_u<>nil)then
            begin
               _AddToInt(@vsnt[reveal_u^.player^.team],vistime);
               _AddToInt(@vsni[reveal_u^.player^.team],vistime);
               _AddToInt(@reveal_u^.vsnt[player^.team],vistime);
               _AddToInt(@reveal_u^.vsni[player^.team],vistime);
            end;
            exit;
         end;

   if(flylevel)then exit;

   for u:=1 to MaxCPoints do
    with g_cpoints[u] do
     if(cpCaptureR>0)then
     begin
        if(building)
        then dx:=max2(cpsolidr,cpNoBuildR)
        else dx:=cpsolidr;
        if(dx<=0)then continue;
        if(point_dist_int(tx,ty,cpx,cpy)<dx)then
        begin
           CheckCollisionR:=3;
           exit;
        end;
     end;

   if(check_obstacles=false)then exit;

   tr-=bld_dec_mr;

   dx:=tx div dcw;
   dy:=ty div dcw;

   if(0<=dx)and(dx<=dcn)and(0<=dy)and(dy<=dcn)then
    with map_dcell[dx,dy] do
     if(n>0)then
      for u:=0 to n-1 do
       with l[u]^ do
        if(r>0)and(t>0)then
         if(point_dist_int(x,y,tx,ty)<(tr+r))then
         begin
            CheckCollisionR:=4;
            exit;
         end;
end;

function CheckInBuildArea(tx,ty,tr:integer;buid,pl:byte):byte;
var u:integer;
begin
   CheckInBuildArea:=0;

   if(pl<=MaxPlayers)then
    with g_players[pl] do
     if(e_builders<=0)then
     begin
        CheckInBuildArea:=1; // no builders
        exit;
     end;

   if(tx<map_b0)or(map_b1<tx)
   or(ty<map_b0)or(map_b1<ty)then
   begin
      CheckInBuildArea:=2;  // out of bounds
      exit;
   end;

   for u:=1 to MaxCPoints do
    with g_cpoints[u] do
     if(cpCaptureR>0)and(cpNoBuildR>0)then
      if(point_dist_int(tx,ty,cpx,cpy)<cpNoBuildR)then
      begin
         CheckInBuildArea:=2;
         exit;
      end;

   tr+=g_uids[buid]._r;

   CheckInBuildArea:=2;

   for u:=1 to MaxUnits do
    with g_punits[u]^ do
     with uid^ do
      if(hits>0)and(iscomplete)and(_isbuilder)and(not ukfly)and(playeri=pl)then
       if(player^.s_builders=0)or(sel)then
        if(abs(x-tx)<=srange)and(abs(y-ty)<=srange)then
         if(buid in ups_builder)and(IsUnitRange(transport,nil)=false)then
          if(point_dist_int(x,y,tx,ty)<srange)then
          begin
             CheckInBuildArea:=0; // inside build area
             break;
          end;
end;

function CheckBuildPlace(tx,ty,tr,uskip:integer;playern,buid:byte):byte;
var i:byte;
obstacles:boolean;
begin
   CheckBuildPlace:=0;

   {
   0 :  m_brushc:=c_lime;
   1 :  m_brushc:=c_red;
   2 :  m_brushc:=c_blue;
   else m_brushc:=c_gray;
   }
   obstacles:=true;
   if(playern<=MaxPlayers)then
   begin
      obstacles:=true;

      if(obstacles)and(g_players[playern].state=ps_comp)then
        if(pf_IfObstacleZone(pf_get_area(tx,ty)))then begin CheckBuildPlace:=2;exit;end;
   end;


   i:=CheckInBuildArea(tx,ty,0,buid,playern); // 0=inside; 1=outside; 2=no builders
   case i of
   0  : ;
   2  : begin CheckBuildPlace:=2;exit;end;
   else begin CheckBuildPlace:=3;exit;end;
   end;

   with g_uids[buid] do
    i:=CheckCollisionR(tx,ty,tr+_r,uskip,_ukbuilding,_ukfly,obstacles);
   if(i>0)then CheckBuildPlace:=1;
end;

function unit_ability_HKeepBlink(pu:PTUnit;x0,y0:integer;check:boolean):cardinal;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      unit_ability_HKeepBlink:=ureq_unknown;
      if(hits<=0)
      or(not iscomplete)then exit;

      unit_ability_HKeepBlink:=ureq_reloading;
      if(buff[ub_CCast]>0)
      or(rld>0)then exit;

      unit_ability_HKeepBlink:=ureq_rupid;
      if(upgr[upgr_hell_HKTeleport]<=0)
      then exit;

      math_push_out(x0,y0,_r,unum,@x0,@y0,ukfly, true, team );
      x0:=mm3(1,x0,map_mw);
      y0:=mm3(1,y0,map_mw);

      unit_ability_HKeepBlink:=0;
      if(check)then exit;

      if(CheckCollisionR(x0,y0,_r,unum,_ukbuilding,ukfly, true,pu)>0)then
      begin
         unit_ability_HKeepBlink:=ureq_landplace;
         rld:=fr_fps1*2;
         exit;
      end;

      upgr[upgr_hell_HKTeleport]-=1;
      buff[ub_CCast]:=fr_fps1;

      case uidi of
      UID_HKeep : unit_teleport(pu,x0,y0{$IFDEF _FULLGAME},EID_HKeep_H ,EID_HKeep_S ,snd_cube{$ENDIF});
      UID_HAKeep: unit_teleport(pu,x0,y0{$IFDEF _FULLGAME},EID_HAKeep_H,EID_HAKeep_S,snd_cube{$ENDIF});
      end;
   end;
end;


function unit_ability_HTowerBlink(pu:PTUnit;x0,y0:integer;check:boolean):cardinal;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      unit_ability_HTowerBlink:=ureq_unknown;
      if(hits<=0)
      or(not iscomplete)then exit;

      unit_ability_HTowerBlink:=ureq_reloading;
      if(buff[ub_CCast]>0)
      or(rld>0)then exit;

      unit_ability_HTowerBlink:=ureq_rupid;
      if(upgr[upgr_hell_tblink]<=0)
      then exit;

      if(srange<point_dist_int(x,y,x0,y0))then msth_1c_push(@x0,@y0,x,y,srange-1);
      math_push_out(x0,y0,_r,unum,@x0,@y0,ukfly, true ,team );
      x0:=mm3(1,x0,map_mw);
      y0:=mm3(1,y0,map_mw);

      unit_ability_HTowerBlink:=ureq_landplace;
      if(point_dist_int(x,y,x0,y0)>srange)then exit;

      unit_ability_HTowerBlink:=0;
      if(check)then exit;

      if(CheckCollisionR(x0,y0,_r,unum,_ukbuilding,ukfly,true,pu )>0)then
      begin
         unit_ability_HTowerBlink:=ureq_landplace;
         rld:=fr_fps1*2;
         exit;
      end;

      upgr[upgr_hell_tblink]-=1;
      buff[ub_CCast]:=fr_fpsd2;
      unit_teleport(pu,x0,y0{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF});
   end;
end;

procedure unit_SetDefaults(pu:PTUnit;Client:boolean);
begin
   with pu^ do
   begin
      if(not Client)then
      begin
         transport:= 0;
         a_tar    := 0;
         a_weap   := 0;
      end;

      uo_id    := ua_amove;
      uo_tar   := 0;
      uo_x     := x;
      uo_y     := y;
      rld      := 0;
      pains    := 0;
      dir      := 270;
      group    := 0;
      a_rld    := 0;
      a_shots  := 0;
      a_weap_cl:= 0;
      a_tar_cl := 0;
      a_exp    := 0;
      a_exp_next:=ExpLevel1;

      aiu_alarm_timer :=0;
      aiu_alarm_d     :=NOTSET;
      aiu_alarm_x     :=-1;
      aiu_alarm_y     :=0;
      aiu_need_detect :=NOTSET;
      aiu_limitaround_ally :=0;
      aiu_limitaround_enemy:=0;
      aiu_FiledSquareNear  :=0;

      FillChar(uprod_r,SizeOf(uprod_r),0);
      FillChar(pprod_r,SizeOf(pprod_r),0);
      FillChar(pprod_e,SizeOf(pprod_e),0);
      FillChar(uprod_u,SizeOf(uprod_u),0);
      FillChar(pprod_u,SizeOf(pprod_u),0);

      {$IFDEF _FULLGAME}
      wanim    := false;
      anim     := 0;
      unit_MiniMapXY(pu);
      unit_FogXY    (pu);
      {$ENDIF}
   end;
end;

procedure unit_done_inc_cntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(_isbuilder  )then n_builders  +=1;
      if(_isbarrack  )then
      begin
         n_barracks+=1;
         uprodm+=level+1;
      end;
      if(_issmith    )then
      begin
         n_smiths+=1;
         upprodm+=level+1;
      end;
   end;
end;
procedure unit_done_dec_cntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(_isbuilder  )then n_builders  -=1;
      if(_isbarrack  )then
      begin
         n_barracks-=1;
         uprodm-=level+1;
      end;
      if(_issmith    )then
      begin
         n_smiths-=1;
         upprodm-=level+1;
      end;
   end;
end;

procedure unit_bld_inc_cntrs(pu:PTUnit);
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
      unit_done_inc_cntrs(pu);
   end;
end;

procedure unit_inc_cntrs(pu:PTUnit;ubld,summoned:boolean);
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      army+=1;
      armylimit+=_limituse;
      ucl_e[_ukbuilding,_ucl]+=1;
      ucl_c[_ukbuilding     ]+=1;
      ucl_l[_ukbuilding     ]+=_limituse;
      uid_e[uidi            ]+=1;
      if(_isbuilder)then e_builders+=1;

      iscomplete:=ubld;

      if(iscomplete)
      then unit_bld_inc_cntrs(pu)
      else
      begin
         hits  := 1;
         cenergy-=_renergy;
         {$IFDEF _FULLGAME}
         if(playeri=UIPlayer)then SoundPlayAnoncer(snd_build_place[_urace],false,false);
         {$ENDIF}
      end;

      if(summoned)and(iscomplete)then
      begin
         buff[ub_Summoned]:=fr_fps1;
         {$IFDEF _FULLGAME}
         effect_UnitSummon(LastCreatedUnitP,nil);
         {$ENDIF}
      end;
   end;
end;

function unit_add(ux,uy,aunum:integer;ui,pl:byte;ubld,summoned:boolean;ulevel:byte):boolean;
var m,i:integer;
procedure FindNotExistedUnit;
begin
   i:=MaxPlayerUnits*pl+1;
   m:=i+MaxPlayerUnits;
   while(i<m)do
   begin
      with g_units[i] do
       if(hits<=dead_hits)then
       begin
          LastCreatedUnit :=i;
          LastCreatedUnitP:=g_punits[i];
          break;
       end;
      i+=1;
   end;
end;
begin
   unit_add:=false;
   LastCreatedUnit :=0;
   LastCreatedUnitP:=g_punits[0];
   with g_players[pl] do
   begin
      if(ui=0)then exit;

      if(not IsUnitRange(aunum,nil))
      then FindNotExistedUnit
      else
        if(g_units[aunum].hits>dead_hits)
        then FindNotExistedUnit
        else
        begin
           LastCreatedUnit :=aunum;
           LastCreatedUnitP:=@g_units[LastCreatedUnit];
        end;

      if(LastCreatedUnit>0)then
      begin
         unit_add:=true;
         FillChar(LastCreatedUnitP^,SizeOf(TUnit),0);

         with LastCreatedUnitP^ do
         begin
            cycle_order:= LastCreatedUnit mod order_period;
            unum       := LastCreatedUnit;

            unit_SetXY(LastCreatedUnitP,ux,uy,mvxy_strict);
            uidi    := ui;
            playeri := pl;
            player  :=@g_players[playeri];
            uo_x    := x;
            uo_y    := y;
            uo_bx   := -1;
            uo_by   := -1;
            mv_x    := x;
            mv_y    := y;
            sel     := false;
            transportC:= 0;

            FillChar(buff,sizeof(buff),0);
            FillChar(vsnt,SizeOf(vsnt),0);
            FillChar(vsni,SizeOf(vsni),0);

            if(ulevel>MaxUnitLevel)
            then ulevel:=MaxUnitLevel;
            level:=ulevel;

            unit_SetDefaults  (LastCreatedUnitP,false);
            unit_reveal   (LastCreatedUnitP,false);
            _unit_apUID    (LastCreatedUnitP);
            unit_inc_cntrs(LastCreatedUnitP,ubld,summoned);
         end;
      end;
   end;
end;

function unit_start_build(bx,by:integer;buid,bp:byte):cardinal;
begin
   unit_start_build:=CheckUnitReqs(@g_players[bp],buid);
   if(unit_start_build=0)then
    with g_players[bp] do
     if(CheckBuildPlace(bx,by,0,0,bp,buid)=0)
     then unit_add(bx,by,-1,buid,bp,false,false,0)
     else unit_start_build:=ureq_place;
end;

function barrack_out_r(pu:PTUnit;_uid:byte):integer;
begin
   if(g_uids[_uid]._ukfly=uf_fly)
   then barrack_out_r:=0
   else barrack_out_r:=pu^.uid^._r;//+g_uids[_uid]._r;
end;

function barrack_out(pu:PTUnit;_uid:byte;_sstep,_dir:integer):boolean;
var
cd    :single;
begin
   barrack_out:=false;
   with pu^ do
   with uid^ do
   begin
      cd:=_dir*degtorad;

      if(_sstep<0)
      then _sstep:=barrack_out_r(pu,_uid);

      if(_sstep=0)
      then unit_add(x,y,-1,_uid,playeri,true,false,0)
      else unit_add(x+trunc(_sstep*cos(cd)),
                     y-trunc(_sstep*sin(cd)),-1,_uid,playeri,true,false,0);

      if(LastCreatedUnit>0)then
      begin
         LastCreatedUnitP^.uo_x  :=uo_x;
         LastCreatedUnitP^.uo_y  :=uo_y;
         LastCreatedUnitP^.uo_id :=uo_id;
         LastCreatedUnitP^.uo_tar:=uo_tar;
         LastCreatedUnitP^.dir   :=dir;

         if(_barrack_teleport)then
         begin
            LastCreatedUnitP^.buff[ub_Teleport]:=fr_fps1;
            {$IFDEF _FULLGAME}
            if(SoundPlayUnit(snd_teleport,pu,nil))
            then effect_add(LastCreatedUnitP^.vx,
                             LastCreatedUnitP^.vy,_SpriteDepth(LastCreatedUnitP^.vy+1,LastCreatedUnitP^.ukfly),EID_Teleport);
            {$ENDIF}
         end;
         barrack_out:=true;
      end;
   end;
end;

procedure barrack_spawn(pu:PTUnit;_uid,count:byte);
var sstep,i  :integer;
    announcer:boolean;
begin
   with pu^ do
   with uid^ do
   begin
      dir:=point_dir(x,y,uo_x,uo_y);
      sstep:=barrack_out_r(pu,_uid);

      announcer:=false;

      for i:=0 to count do announcer:=barrack_out(pu,_uid,sstep,dir+i*15) or announcer;

      if(announcer)
      then GameLogUnitReady(LastCreatedUnitP);
   end;
end;

//////   Start unit prod
//
function unit_ProdStartUnitLine(uBarrack:PTUnit;puid,pn:byte;check:boolean):cardinal;
begin
   unit_ProdStartUnitLine:=0;
   if(pn>MaxUnitLevel)
   then unit_ProdStartUnitLine:=ureq_unknown
   else
     with uBarrack^ do
     with uid^ do
       if(uprod_r[pn]>0)
       then unit_ProdStartUnitLine:=ureq_busy
       else
       begin
          unit_ProdStartUnitLine:=CheckUnitReqs(player,puid);
          if(unit_ProdStartUnitLine=0)then
            with player^ do
            with g_upids[puid] do
            begin
               if(check)then exit;

               uproda+=1;
               uprodl+=g_uids[puid]._limituse;
               uprodc[g_uids[puid]._ucl]+=1;
               uprodu[puid             ]+=1;
               cenergy-=g_uids[puid]._renergy;
               uprod_u[pn]:=puid;
               uprod_r[pn]:=g_uids[puid]._tprod;
            end;
       end;
end;
function unit_ProdStartUnit(uBarrack:PTUnit;puid:byte;check:boolean):cardinal;  // main function
var pn:byte;
begin
   with uBarrack^ do
   with uid^ do
   begin
      unit_ProdStartUnit:=ureq_unknown;
      if(puid=255)
      or(puid=0  )
      or(hits<=0)
      or(not iscomplete)
      or(not _isbarrack)
      or(not _ukbuilding)then exit;

      unit_ProdStartUnit:=ureq_barracks;
      if not(puid in ups_units)
      then exit;
   end;

   for pn:=0 to MaxUnitLevel do
   begin
      if(pn>uBarrack^.level)then break;
      unit_ProdStartUnit:=unit_ProdStartUnitLine(uBarrack,puid,pn,check);
      if(unit_ProdStartUnit=0)then break;
   end;
end;
/// Stop unit prod
function unit_ProdStopUnitLine(uBarrack:PTUnit;puid,pn:byte;check:boolean):cardinal;
begin
   unit_ProdStopUnitLine:=ureq_unknown;
   with uBarrack^ do
   with uid^ do
     if(pn<=MaxUnitLevel)then
       if(uprod_r[pn]>0)then
         if(puid=255)or(puid=uprod_u[pn])then
           with player^ do
           begin
              unit_ProdStopUnitLine:=0;
              if(check)then exit;

              puid:=uprod_u[pn];

              uproda-=1;
              uprodl-=g_uids[puid]._limituse;
              uprodc[ g_uids[puid]._ucl]-=1;
              uprodu[ puid           ]-=1;
              cenergy+=g_uids[puid]._renergy;
              uprod_r[pn]:=0;
           end;
end;
function unit_ProdStopUnit(uBarrack:PTUnit;puid:byte;all,check:boolean):cardinal;
var pn:byte;
begin
   with uBarrack^ do
   with uid^ do
   begin
      unit_ProdStopUnit:=ureq_unknown;
      if(puid=0 )
      or(hits<=0)
      or(not iscomplete)
      or(not _isbarrack)
      or(not _ukbuilding)then exit;
   end;

   for pn:=MaxUnitLevel downto 0 do
   begin
      unit_ProdStopUnit:=unit_ProdStopUnitLine(uBarrack,puid,pn,check);
      if(unit_ProdStopUnit>0)then continue;
      if(not all)or(check)then break;
   end;
end;


//////   Start upgrade production
//
function unit_ProdStartUpgradeLine(uSmith:PTUnit;upid,pn:byte;check:boolean):cardinal;
begin
   unit_ProdStartUpgradeLine:=0;
   if(pn>MaxUnitLevel)
   then unit_ProdStartUpgradeLine:=ureq_unknown
   else
     with uSmith^ do
     with uid^ do
       if(pprod_r[pn]>0)
       then unit_ProdStartUpgradeLine:=ureq_busy
       else
       begin
          unit_ProdStartUpgradeLine:=CheckUpgradeReqs(player,upid);
          if(unit_ProdStartUpgradeLine=0)then
            with player^ do
            with g_upids[upid] do
            begin
               if(check)then exit;

               upproda+=1;
               upprodu[upid]+=1;
               pprod_e[pn]:=GetUpgradeEnergy(upid,upgr[upid]+1);
               cenergy-=pprod_e[pn];
               pprod_r[pn]:=GetUpgradeTime(upid,upgr[upid]+1);
               pprod_u[pn]:=upid;
            end;
       end;
end;
function unit_ProdStartUpgrade(uSmith:PTUnit;upid:integer;check:boolean):cardinal;
var pn:byte;
begin
   with uSmith^ do
   with uid^ do
   begin
      unit_ProdStartUpgrade:=ureq_unknown;
      if(upid=255)
      or(upid=0  )
      or(hits<=0)
      or(not iscomplete)
      or(not _issmith)
      or(not _ukbuilding)then exit;

      unit_ProdStartUpgrade:=ureq_smiths;
      if not(upid in ups_upgrades)
      then exit;
   end;

   for pn:=0 to MaxUnitLevel do
   begin
      if(pn>uSmith^.level)then break;
      unit_ProdStartUpgrade:=unit_ProdStartUpgradeLine(uSmith,upid,pn,check);
      if(unit_ProdStartUpgrade=0)then break;
   end;
end;
function unit_ProdStopUpgradeLine(uSmith:PTUnit;upid:byte;pn:integer;check:boolean):cardinal;
begin
   unit_ProdStopUpgradeLine:=ureq_unknown;
   with uSmith^ do
   with uid^ do
     if(pn<=MaxUnitLevel)then
       if(pprod_r[pn]>0)then
         if(upid=255)or(upid=pprod_u[pn])then
           with player^ do
           begin
              unit_ProdStopUpgradeLine:=0;
              if(check)then exit;

              upid:=pprod_u[pn];

              upproda-=1;
              upprodu[upid]-=1;
              cenergy+=pprod_e[pn];
              pprod_r[pn]:=0;
           end;
end;
function unit_ProdStopUpgrade(uSmith:PTUnit;upid:byte;all:boolean;check:boolean):cardinal;
var pn:byte;
begin
   with uSmith^ do
   with uid^ do
   begin
      unit_ProdStopUpgrade:=ureq_unknown;
      if(upid=0 )
      or(hits<=0)
      or(not iscomplete)
      or(not _issmith)
      or(not _ukbuilding)then exit;
   end;

   for pn:=MaxUnitLevel downto 0 do
   begin
      unit_ProdStopUpgrade:=unit_ProdStopUpgradeLine(uSmith,upid,pn,check);
      if(unit_ProdStopUpgrade>0)then continue;
      if(not all)or(check)then break;
   end;
end;

procedure unit_counters_inc_select(pu:PTUnit);
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
      s_all+=1;
   end;
end;
procedure unit_counters_dec_select(pu:PTUnit);
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
      s_all-=1;
   end;
end;

procedure unit_UnSelect(pu:PTUnit);
begin
   with pu^ do
   if(sel)then
   begin
      unit_counters_dec_select(pu);
      sel:=false;
   end;
end;
procedure unit_Select(pu:PTUnit);
begin
   with pu^ do
   if(not sel)then
   begin
      unit_counters_inc_select(pu);
      sel:=true;
   end;
end;

procedure unit_dec_Kcntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      unit_UnSelect(pu);

      if(not iscomplete)
      then cenergy+=g_uids[uidi]._renergy
      else
      begin
         unit_ProdStopUnit   (pu,255,true,false);
         unit_ProdStopUpgrade(pu,255,true,false);

         ucl_eb[_ukbuilding,_ucl]-=1;
         uid_eb[uidi            ]-=1;
         menergy-=_genergy;
         cenergy-=_genergy;

         unit_done_dec_cntrs(pu);
      end;

      if(ucl_x[_ukbuilding,_ucl]=unum)then ucl_x[_ukbuilding,_ucl]:=0;
      if(uid_x[uidi            ]=unum)then uid_x[uidi            ]:=0;
   end;
end;

procedure unit_dec_Rcntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      army     -=1;
      armylimit-=_limituse;
      ucl_e[_ukbuilding,_ucl]-=1;
      ucl_c[_ukbuilding     ]-=1;
      ucl_l[_ukbuilding     ]-=_limituse;
      uid_e[uidi            ]-=1;
      if(_isbuilder)then e_builders-=1;
   end;
end;

procedure unit_end_uprod(pu:PTUnit);
var i,_uid:byte;
begin
   with pu^ do
   with uid^ do
   if(_isbarrack)then
   with player^ do
   for i:=0 to MaxUnitLevel do
   if(uprod_r[i]>0)then
   begin
       _uid:=uprod_u[i];

      if((army     +uproda)>MaxPlayerUnits)
      or((armylimit+uprodl)>MaxPlayerLimit)
      or(cenergy<0)
      or(uid_e[_uid]>=a_units[_uid])
      then
      else
        if(uprod_r[i]=1){$IFDEF DEBUG0}or(_warpten){$ENDIF}then
        begin
           barrack_spawn(pu,uprod_u[i],upgr[upgr_mult_product]);
           unit_ProdStopUnitLine(pu,255,i,false);
        end
        else uprod_r[i]:=max2(1,uprod_r[i]-1*(upgr[upgr_fast_product]+1) );
   end;
end;

procedure unit_end_pprod(pu:PTUnit);
var i,_uid:byte;
begin
   with pu^ do
   with uid^ do
   if(_issmith)then
   with player^ do
   for i:=0 to MaxUnitLevel do
   if(pprod_r[i]>0)then
   begin
       _uid:=pprod_u[i];
      if(cenergy<0)
      or(upgr[_uid]>=g_upids[_uid]._up_max)
      or(upgr[_uid]>=a_upgrs[_uid])
      then
      else
        if(pprod_r[i]=1){$IFDEF DEBUG0}or(_warpten){$ENDIF}then
        begin
           upgr[_uid]+=1;
           unit_ProdStopUpgradeLine(pu,255,i,false);
           GameLogUpgradeComplete(playeri,_uid,x,y);
        end
        else pprod_r[i]:=max2(1,pprod_r[i]-1*(upgr[upgr_fast_product]+1) );
   end;
end;

procedure unit_ability_spawn(pu:PTUnit;tx,ty:integer;auid:byte);
var tu:PTUnit;
begin
   with pu^ do
   with player^ do
   begin
      if(not _uid_player_limit(player,auid))
      then LastCreatedUnit:=0
      else
        if(not ServerSide)
        then LastCreatedUnit:=1
        else unit_add(tx,ty,-1,auid,playeri,true,true,0);

      if(LastCreatedUnit>0)then
      begin
         if(ServerSide)then
         begin
            LastCreatedUnitP^.dir   :=dir;
            LastCreatedUnitP^.a_tar :=a_tar;
            LastCreatedUnitP^.uo_id :=uo_id;
            LastCreatedUnitP^.uo_tar:=uo_tar;
            if(IsUnitRange(a_tar,@tu))then
            begin
               LastCreatedUnitP^.uo_x :=tu^.x;
               LastCreatedUnitP^.uo_y :=tu^.y;
            end
            else
             if(uo_x<>x)or(uo_y<>y)then
             begin
                LastCreatedUnitP^.uo_x:=uo_x;
                LastCreatedUnitP^.uo_y:=uo_y;
             end;
         end
         else LastCreatedUnit:=0;
      end
      {$IFDEF _FULLGAME}
      else
        case auid of
UID_Phantom : effect_InPoint(tx,ty,_SpriteDepth(ty+1,ukfly),nil,auid,snd_pexp);
UID_LostSoul: effect_InPoint(tx,ty,_SpriteDepth(ty+1,ukfly),nil,auid,snd_pexp);
        end;
      {$ENDIF};
   end;
end;


procedure ability_unit_spawn(pu:PTUnit;auid:byte);
var dd:integer;
begin
   with pu^ do
   with uid^ do
   begin
      dd:=_DIR360(dir+23) div 45;
      unit_ability_spawn(pu,x+dir_stepX[dd]*_r,y+dir_stepY[dd]*_r,auid);
   end;
end;


function unit_CheckTransport(uTransport,uTarget:PTUnit):boolean;
begin
   unit_CheckTransport:=false;
   if(uTarget^.ukfly=uf_fly)or(uTransport=uTarget)then exit;

   if(uTransport^.player<>uTarget^.player)then
    if(uTransport^.player^.team<>uTarget^.player^.team)
    then exit;

   if((uTransport^.transportM-uTransport^.transportC)>=uTarget^.uid^._transportS)then
    if(uTarget^.uidi in uTransport^.uid^.ups_transport)then unit_CheckTransport:=true;
end;


procedure unit_counters(pu:PTUnit);
var i:byte;
begin
   with pu^ do
   begin
      for i:=0 to MaxUnitBuffs do
       if(0<buff[i])and(buff[i]<_ub_infinity)then buff[i]-=1;

      for i:=0 to MaxPlayers do
      begin
         if(0<vsnt[i])and(vsnt[i]<_ub_infinity)then vsnt[i]-=1;
         if(0<vsni[i])and(vsni[i]<_ub_infinity)then vsni[i]-=1;
      end;

      if(iscomplete)then
      begin
         if(  rld>0)then   rld-=1;
         if(a_rld>0)then a_rld-=1;
      end;
   end;
end;


procedure unit_detect(uTarget,uDetector:PTUnit;ud:integer);
var td:integer;
scan_buff:byte;
begin
   scan_buff:=255;
   with uTarget^ do
   begin
      if(uDetector^.player^.observer)
      then td:=0
      else
        if(uDetector^.uid^._ability=uab_UACScan)and(uDetector^.rld>radar_vision_time)then
        begin
           td:=point_dist_int(x,y,uDetector^.uo_x,uDetector^.uo_y);
           if(td<ud)
           then scan_buff:=ub_Scaned
           else td:=ud;
        end
        else td:=ud;

      if(td<=(uDetector^.srange+uid^._r))then
       if(buff[ub_Invis]<=0)then
       begin
          _AddToInt(@vsnt[uDetector^.player^.team],vistime);
          if(scan_buff<=MaxUnitBuffs)and(player^.team<>uDetector^.player^.team)
          then _AddToInt(@buff[scan_buff],vistime);
       end
       else
         if(uDetector^.buff[ub_Detect]>0)and(uDetector^.iscomplete)and(uDetector^.hits>0)then
         begin
            _AddToInt(@vsnt[uDetector^.player^.team],vistime);
            _AddToInt(@vsni[uDetector^.player^.team],vistime);
            if(scan_buff<=MaxUnitBuffs)and(player^.team<>uDetector^.player^.team)
            then _AddToInt(@buff[scan_buff],vistime);
         end;
   end;
end;


procedure unit_remove(pu:PTUnit);
begin
   with pu^ do
    with player^ do
    begin
       unit_dec_Rcntrs(pu);

       if(playeri>0)or(g_mode<>gm_invasion)then
         if(army<=0)and(state>ps_none){$IFDEF _FULLGAME}and(menu_s2<>ms2_camp){$ENDIF}
         then GameLogPlayerDefeated(playeri);
    end;
end;

procedure unit_kill(pu:PTUnit;instant,fastdeath,buildcd,KillAllInside,suicide:boolean);
var i :integer;
    tu:PTunit;
begin
   with pu^ do
   if(hits>0)then
   with player^ do
   begin
      if(not instant)then
      begin
         with uid^ do fastdeath:=(fastdeath)or(_fastdeath_hits>=0)or(_ukbuilding);
         buff[ub_Pain]:=fr_fps1; // prevent fast resurrecting

         if(not suicide)then GameLogUnitAttacked(pu);
         {$IFDEF _FULLGAME}
         effect_UnitDeath(pu,fastdeath,nil);
         {$ENDIF}
      end;

      {$IFDEF _FULLGAME}
      if(unum=ui_UnitSelectedPU)then ui_UnitSelectedPU:=0;
      {$ENDIF}

      unit_dec_Kcntrs(pu);

      with uid^ do
      begin
         if(_ukbuilding)and(buildcd)then
           if(_ability<>uab_HellVision)or(not iscomplete)then build_cd:=min2(build_cd+step_build_reload,max_build_reload);
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
         tu:=@g_units[i];
         if(tu^.hits>0)then
         begin
            if(tu^.uo_tar=unum)then tu^.uo_tar:=0;
            if(transportC>0)then
             if(tu^.transport=unum)then
             begin
                if(ukfly<>uf_ground)or(transport>0)or(KillAllInside)
                then unit_kill(tu,true,false,true,KillAllInside,suicide)
                else
                begin
                   tu^.transport:=0;
                   transportC-=tu^.uid^._transportS;
                   tu^.x+=_randomr(uid^._r);
                   tu^.y+=_randomr(uid^._r);
                   tu^.uo_x:=tu^.x;
                   tu^.uo_y:=tu^.y;
                   if(tu^.hits>apc_exp_damage)
                   then tu^.hits-=apc_exp_damage
                   else unit_kill(tu,true,false,true,false,suicide);
                end;
             end;
         end
         else tu^.transport:=0;
      end;
      missiles_clear_tar(unum,false);

      if(instant)then
      begin
         hits:=ndead_hits;
         unit_remove(pu);
      end
      else
      begin
         if(fastdeath)
         then hits:=fdead_hits
         else hits:=0;

         with uid^ do
         begin
            if(_death_missile>0)
            then missile_add(x,y,x,y,0,_death_missile,playeri,ukfly,ukfly,false,0,_death_missile_dmod);
            if(_death_uid>0)and(_death_uidn>0)then
             for i:=1 to _death_uidn do
              if(_uid_player_limit(player,_death_uid))then
               unit_add(x-_randomr(_missile_r),y-_randomr(_missile_r),0,_death_uid,playeri,true,true,0);
         end;
      end;
   end
   else
     if(hits>dead_hits)then
     begin
        hits:=ndead_hits;
        unit_remove(pu);
     end;
end;


procedure unit_Bonuses(pu:PTUnit);
var tu:PTUnit;
    t :integer;
procedure SetSRange(newsr:integer);
begin
   with pu^ do
   if(srange<>newsr)then
   begin
      srange:=newsr;
      {$IFDEF _FULLGAME}
      _unit_CalcForR(pu);
      {$ENDIF}
   end;
end;
begin
   with pu^ do
   with uid^ do
   with player^ do
   if(iscomplete)and(hits>0)then
   begin
      speed:=_speed;
      // ABILITIES
      case _ability of
uab_Teleport      : level:=byte(upgr[upgr_hell_rteleport]>0);
uab_CCFly         : if(level>0)then
                    begin
                       if(ukfly<>uf_fly)then
                       begin
                          {$IFDEF _FULLGAME}
                          SoundPlayUnit(snd_CCup ,pu,nil);
                          {$ENDIF}
                          ukfly:=uf_fly;
                          if(ServerSide)then zfall:=zfall-fly_hz;
                          if(uo_id<>ua_psability)
                          then unit_clear_order(pu,false);
                       end;
                       speed:=5;
                    end
                    else
                    begin
                       if(ukfly<>uf_ground)then
                       begin
                          {$IFDEF _FULLGAME}
                          SoundPlayUnit(snd_transport,pu,nil);
                          {$ENDIF}
                          if(ServerSide)then zfall:=fly_hz;
                          ukfly:=uf_ground;
                          unit_clear_order(pu,false);
                       end;
                       speed:=0;

                       if(ServerSide)and(zfall<>0)then
                        if(CheckCollisionR(x,y+zfall,_r,unum,_ukbuilding,false,true,pu )>0)then
                        begin
                           level:=1;
                           buff[ub_CCast]:=fr_fps2;
                           PlayerSetProdError(playeri,lmt_argt_abil,255,ureq_landplace,pu);
                        end;
                    end;
      end;

      // DETECTION
      if(_detector)or(buff[ub_HVision]>0)
      then buff[ub_Detect]:=_ub_infinity
      else buff[ub_Detect]:=0;

      // INVIS
      case uidi of
UID_HTotem        : buff[ub_Invis]:=b2ib[upgr[upgr_hell_totminv]>0];
UID_Commando      : buff[ub_Invis]:=b2ib[upgr[upgr_uac_commando]>0];
UID_Demon         : buff[ub_Invis]:=b2ib[upgr[upgr_hell_spectre]>0];
UID_UMine         : buff[ub_Invis]:=_ub_infinity;
      end;

      // OTHER
      case uidi of
UID_UGTurret      : level:=byte(upgr[upgr_uac_plasmt]>0);
UID_Phantom,
UID_LostSoul      : begin
                       tu:=nil;
                       if(IsUnitRange(a_tar,@tu))and(a_rld>0)then buff[ub_CCast]:=fr_fpsd2;
                       if(buff[ub_pain]<=0)then
                         if(buff[ub_CCast]>0)and(tu<>nil)then ukfly:=tu^.ukfly else ukfly:=_ukfly;
                       ukfloater:=not ukfly;
                    end;
UID_UTransport    : begin level:=min2(upgr[upgr_uac_transport],MaxUnitLevel);transportM:=_transportM+4*level;end;
UID_APC           : begin level:=min2(upgr[upgr_uac_transport],MaxUnitLevel);transportM:=_transportM+2*level;end;
      end;
      if(upgr[upgr_invuln]>0)then buff[ub_Invuln]:=fr_fps1;
      if(playeri=0)and(g_mode=gm_invasion)then
      begin
         ukfloater:=true;
         if(cycle_order<4 )
         or(cycle_order=11)
         or(cycle_order=21)then buff[ub_HVision]:=_ub_infinity else buff[ub_HVision]:=0;
         if(g_inv_wave_n>3)then
           if(cycle_order<2 )
           or(cycle_order=10)
           or(cycle_order=20)then buff[ub_Invis]:=_ub_infinity else buff[ub_Invis]:=0;
      end;

      // SRANGE
      t:=_srange;
      if(_upgr_srange>0)and(_upgr_srange_step>0)
      then t+=upgr[_upgr_srange]*_upgr_srange_step;
      if(not _ukbuilding)
      then t+=upgr[upgr_race_unit_srange[_urace]]*upgr_race_srange_unit_bonus[_urace];
      SetSRange(t);
   end;
end;



