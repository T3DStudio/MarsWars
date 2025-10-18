{$IFDEF _FULLGAME}
procedure unit_MiniMapXY(pu:PTUnit);
begin
   with pu^ do
   begin
      mmx:=trunc(x*map_mmcx);
      mmy:=trunc(y*map_mmcx);
   end;
end;

procedure effect_LevelUp(pu:PTUnit;etype:byte;pUIVision:pboolean);
begin
   with pu^ do
   begin
      if(pUIVision<>nil)then
      begin
         if(not pUIVision^)then exit;
      end
      else
         if(not ui_CheckUnitUIPlayerVision(pu,true))then exit;

      case etype of
EID_HVision : begin
              SoundPlayUnit(snd_hell_eye,pu,nil);
              effect_add(vx,vy,draw_SpriteDepth(vy+1,ukfly),EID_HVision);
              end;
EID_Invuln  : begin
              SoundPlayUnit(snd_hell_invuln,pu,nil);
              effect_add(vx,vy,draw_SpriteDepth(vy+1,ukfly),EID_Invuln);
              end;
      else
               case uid^.uid_race of
      r_hell : begin
                  SoundPlayUnit(snd_unit_adv[uid^.uid_race],pu,nil);
                  effect_add(vx,vy,draw_SpriteDepth(vy+1,ukfly),EID_HLevelUp);
               end;
      r_uac  : begin
                  SoundPlayUnit(snd_unit_adv[uid^.uid_race],pu,nil);
                  effect_add(vx,vy,draw_SpriteDepth(vy+1,ukfly),EID_ULevelUp);
               end;
               end;
      end;
   end;
end;

procedure effect_RStationShot(pu:PTUnit);
begin
   with pu^ do
   begin
      effect_add(vx,vy-15,draw_SpriteDepth(vy+10,ukfly),EID_Exp2);
      SoundPlayUnit(snd_bomblaunch,nil,nil)
   end;
end;

procedure effect_KPointExplode(vx,vy:integer);
begin
   effect_add(vx,vy,sd_liquid+vy,EID_db_u0);
   if(ui_CheckMapPointFogVision(vx,vy,true))then
   begin
      effect_add(vx,vy,draw_SpriteDepth(vy+1,false),EID_BBExp);
      SoundPlayUnit(snd_exp,nil,nil);
   end;
end;

procedure effect_UnitSummon(pu:PTUnit;pUIVision:pboolean);
begin
   with pu^ do
     if(hits>0)and(iscomplete)then
       with uid^ do
       begin
          if(pUIVision<>nil)then
          begin
             if(not pUIVision^)then exit;
          end
          else
             if(not ui_CheckUnitUIPlayerVision(pu,true))then exit;

          SoundPlayUnit(uid_snd_Summon,nil,nil);
          effect_add(vx,vy,draw_SpriteDepth(vy+1,ukfly),uid_eid_Summon[level]);

          if(playeri=UIPlayer)then SoundPlayUnit(uid_snd_ready,nil,nil);
       end;
end;

procedure effect_UnitDeath(pu:PTUnit;fastdeath:boolean;pUIVision:pboolean);
begin
   with pu^ do
   with uid^ do
   begin
      if(not ukfly)and(uid_eid_bcrater>0)then
        effect_add(vx,vy+uid_eid_bcrater_y,sd_liquid+vy,uid_eid_bcrater);

      if(pUIVision<>nil)then
      begin
         if(not pUIVision^)then exit;
      end
      else
        if(not ui_CheckUnitUIPlayerVision(pu,true))then exit;

      if(fastdeath)then
      begin
         effect_add(vx,vy,draw_SpriteDepth(vy+1,ukfly),uid_eid_DeathFast[level]);
         SoundPlayUnit(uid_snd_DeathFast,nil,nil);
      end
      else
      begin
         effect_add(vx,vy,vy+1,uid_eid_DeathSlow[level]);
         SoundPlayUnit(uid_snd_DeathSlow,nil,nil);
      end;
   end;
end;

procedure effect_UnitPain(pu:PTUnit;pUIVision:pboolean);
begin
   with pu^ do
   with uid^ do
   begin
      if(pUIVision<>nil)then
      begin
         if(not pUIVision^)then exit;
      end
      else
        if(not ui_CheckUnitUIPlayerVision(pu,true))then exit;

      effect_add(vx,vy,draw_SpriteDepth(vy+1,ukfly),uid_eid_Pain[level]);
      SoundPlayUnit(uid_snd_Pain,nil,nil);
   end;
end;

procedure effect_InPoint(tx,ty,dy:integer;pUIVision:pboolean;effect:byte;sound:PTSoundSet);
begin
   if(pUIVision<>nil)then
   begin
      if(not pUIVision^)then exit
   end
   else
     if(not ui_CheckMapPointFogVision(tx,ty,true))then exit;

   effect_add(tx,ty,dy,effect);
   SoundPlayUnit(sound,nil,nil);
end;

procedure effect_UnitAttack(pu:PTUnit;start:boolean;pUIVision:pboolean);
begin
   with pu^  do
   with uid^ do
   with uid_arms[a_weap] do
   begin
      if(pUIVision<>nil)then
      begin
         if(not pUIVision^)then exit;
      end
      else
        if(not ui_CheckUnitUIPlayerVision(pu,true))then exit;

      if(start)then
      begin
         effect_add(vx,vy,draw_SpriteDepth(vy+1,ukfly),aw_eid_start);
         SoundPlayUnit(aw_snd_start,nil,nil);
      end
      else
      begin
         effect_add(vx+aw_offset_x,vy+aw_offset_y,draw_SpriteDepth(vy+1,ukfly),aw_eid_shot );
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
     then unit_canMove:=(x<>move_x)or(y<>move_y)
     else
     begin
        unit_canMove:=false;

        if(speed<=0)
        or(hits<=0)
        or(not iscomplete)then exit;

        if(a_rld>0)then
          if(a_weap_cl>LastUnitArms)
          then exit
          else
            with uid_arms[a_weap_cl] do
              if((aw_req_flags and wpr_move)=0)then exit;

        if(not uid_isbuilding)then
          if(buffs[ub_Pain]>0)
          or(buffs[ub_Cast]>0)then exit;

        unit_canMove:=true;
     end;
end;

function unit_canAttack(pu:PTUnit;check_buffs:boolean):boolean;
begin
   unit_canAttack:=false;
   with pu^  do
   with uid^ do
   begin
      if(not iscomplete)
      or(hits<=0)
      or(not uid_CanAttack)then exit;

      if(check_buffs)then
        if(not uid_isbuilding)then
          if(buffs[ub_Pain]>0)
          or(buffs[ub_Cast]>0)then exit;

      if(IsUnitRange(transportU,nil))then exit;
   end;
   unit_canAttack:=true;
end;

procedure unit_UpdateXY(pu:PTUnit);
begin
   with pu^ do
   begin
      if(uid<>nil)then
        mapZone:=map_GetZone(x,y,uid^.uid_r);
      {$IFDEF _FULLGAME}
      unit_MiniMapXY(pu);
      unit_UpdateFogXY(pu);
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
      x:=mm3i(1,ax,map_Size);
      y:=mm3i(1,ay,map_Size);
      if(x<>_px)or(y<>_py)then
      begin
         unit_UpdateXY(pu);
         if(_px=uo_x)
        and(_py=uo_y)then
        begin
           uo_x:=x;
           uo_y:=y;
        end;
         if(_px=rpoint_x)
        and(_py=rpoint_y)then
        begin
           rpoint_x:=x;
           rpoint_y:=y;
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

procedure unit_TeamReveal(pu:PTUnit;reset:boolean);
var p:byte;
begin
   with pu^ do
   with player^ do
   begin
      if(reset)then
      begin
         FillChar(TeamVision   ,SizeOf(TeamVision   ),0);
         FillChar(TeamDetection,SizeOf(TeamDetection),0);
      end;
      AddToInt(@TeamVision   [team],MinVisionTime);
      AddToInt(@TeamDetection[team],MinVisionTime);

      if(isrevealed)then
        for p:=0 to LastPlayer do
        begin
           AddToInt(@TeamVision   [p],fr_fps1);
           AddToInt(@TeamDetection[p],fr_fps1);
        end;
   end;
end;
procedure unit_UpdateVision(pu:PTUnit);
var p:byte;
begin
   with pu^ do
     for p:=0 to LastPlayer do
     begin
        if(TeamVision   [p]>0)then AddToInt(@TeamVision   [p],MinVisionTime);
        if(TeamDetection[p]>0)then AddToInt(@TeamDetection[p],MinVisionTime);
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
   for i:=0 to MaxUnits do
     with g_missiles[i] do
       if(m_vstep>0)and(m_tar=u)then
       begin
          m_tar:=0;
          if(ResetTarget)then
          begin
             m_x:=m_vx;
             m_y:=m_vy;
             m_vstep:=1;
          end;
       end;
end;

procedure teleport_CalcReload(pTeleporter:PTUnit;limit:integer);
begin
   with pTeleporter^ do
     with player^ do rld:=integer(round(fr_fps1*limit/MinUnitLimit))*(hteleport_rldPerLimit-mm3i(0,upgrs_cur[upgr_hell_TeleportCD],hteleport_rldPerLimit));
end;

procedure unit_teleport(pu:PTUnit;tx,ty:integer{$IFDEF _FULLGAME};eidstart,eidend:byte;snd:PTSoundSet{$ENDIF});
begin
   with pu^ do
   begin
      tx:=mm3i(0,tx,map_Size);
      ty:=mm3i(0,ty,map_Size);
      {$IFDEF _FULLGAME}
      effect_teleport(vx,vy,tx,ty,ukfly,eidstart,eidend,snd);
      {$ENDIF}
      buffs[ub_Teleport]:=fr_fps1;
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
       if(IsUnitRange(transportU,nil))then
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
   unit_ability_UACScan:=ureq_other;
   with pu^ do
     if(iscomplete)and(rld<=0)then
     begin
        unit_ability_UACScan:=0;

        if(check)then exit;

        unit_clear_order(pu,true);
        uo_x:=x0;
        uo_y:=y0;
        rld :=radar_reload;
        buffs[ub_Cast]:=fr_fps1;

        {$IFDEF _FULLGAME}
        if(ServerSide)then
        begin
           if(UIPlayer<=LastPlayer)then
             if(player^.team<>g_gplayers[UIPlayer].team)then exit;
          SoundPlayUnit(snd_radar,nil,nil);
        end;
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
      unit_ability_HInvuln:=ureq_other;
      if(not iscomplete)
      or(hits<=0)then exit;

      unit_ability_HInvuln:=ureq_reloading;
      if(rld>0)then exit;
   end;

   unit_ability_HInvuln:=ureq_InvalidTarget;
   if(not IsUnitRange(taru,@tu))
   then exit;

   if(tu^.hits<=0)then exit;

   with pu^ do
   with player^ do
   begin
      if(team<>tu^.player^.team)
      or(tu^.buffs[ub_Invuln]>0)then exit;

      unit_ability_HInvuln:=0;

      if(check)then exit;

      tu^.buffs[ub_Invuln]:=invuln_time;
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
var p:byte;
begin
   unit_ability_UACStrike:=ureq_other;
   with pu^ do
     if(iscomplete)and(rld<=0)then
       with player^ do
       begin
          unit_ability_UACStrike:=0;
          if(check)then exit;
          unit_clear_order(pu,true);
          uo_x:=x0;
          uo_y:=y0;
          for p:=0 to LastPlayer do AddToInt(@TeamVision[p],fr_fps2);
          rld:=mstrike_reload;
          unit_UACStrike_missile(pu);
          buffs[ub_Cast]:=fr_fps1;
       end;
end;



procedure math_1c_push(tx,ty:pinteger;x0,y0,r0:integer);
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
   else math_1c_push(tx,ty,x0,y0,r0);
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
      dx:=tx div MapObstaclesGridW;
      dy:=ty div MapObstaclesGridW;
      if(0<=dx)and(dx<=MapObstaclesGridN)and(0<=dy)and(dy<=MapObstaclesGridN)then
       with map_ObstaclesGrid[dx,dy] do
        if(oc_n>0)then
         for u:=0 to oc_n-1 do
          with oc_l[u]^ do
           if(o_r>0)and(o_type>0)then
           begin
              o:=tr+o_r;
              d:=point_dist_int(o_x,o_y,tx,ty)-o;
              add(o_x,o_y,d,o);
           end;
      tr+=bld_dec_mr;
   end;

   if(not _ukfly)then
    for u:=0 to LastKeyPoint do
     with g_KeyPoints[u] do
      if(kpCaptureR>0)and(kpNoBuildR>0)then
      begin
         o:=kpNoBuildR+tr;
         d:=point_dist_int(kpx,kpy,tx,ty)-o;
         add(kpx,kpy,d,o);
      end;

   for u:=1 to MaxUnits do
    with g_units[u] do
     with uid^ do
      if(hits>0)and(ukfly=uid_isfly)and(unum<>ignore_unum)then
       if(speed<=0)or(not iscomplete)then
        if(not IsUnitRange(transportU,nil))then
        begin
           if(UnitObsTeamVis<=LastPlayer)then
             if(TeamVision[UnitObsTeamVis]<=0)then continue;

           o:=tr+uid_r;
           d:=point_dist_int(x,y,tx,ty);
           add(x,y,d-o,o);
        end;

   for u:=1 to MaxUnits do
    with g_units[u] do
     with uid^ do
      if(hits>0)and(unum<>ignore_unum)and(iscomplete)then
       if(not IsUnitRange(transportU,nil))then
        if(uo_id=ua_psability)then
        begin
           if(UnitObsTeamVis<=LastPlayer)then
             if(TeamVision[UnitObsTeamVis]<=0)then continue;

           case uid_ability of
     uab_RebuildInPoint: begin
                         o:=tr+g_uids[uid_rebuild_uid].uid_r;
                         d:=point_dist_int(uo_x,uo_y,tx,ty);
                         add(uo_x,uo_y,d-o,o);
                         end;
           uab_UACCCLand   : begin
                         o:=tr+uid_r;
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

   if(not _ukfly)then
   begin
      dx:=tr;
      dy:=map_size-dx;
      tx:=mm3i(dx,tx,dy);
      ty:=mm3i(dx,ty,dy);
   end;

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
      aukfly:=uid_isfly;
      with g_gplayers[pl] do
        math_push_out(tx,ty,uid_r,0,@tx,@ty,aukfly,true,UnitObsTeamVis);
   end;

   dx:=-2000;
   dy:=-2000;
   sr:=NOTSET;
   dr:=NOTSET;
   for u:=1 to MaxUnits do
    with g_units[u] do
     with uid^ do
      if(hits>0)and(speed<=0)and(ukfly=aukfly)and(iscomplete)and(playeri=pl)and(uid_isbuilder)and(not ukfly)then
       if(player^.units_builders_s=0)or(isselected)then
        if(buid in uid_prod_Buildings)and(not IsUnitRange(transportU,nil))then
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
      if(0<dr)then math_1c_push(@tx,@ty,dx,dy,sr-1);
   end;

   with g_uids[buid] do
   begin
      dx:=uid_r;
      dy:=map_size-dx;
      tx:=mm3i(dx,tx,dy);
      ty:=mm3i(dx,ty,dy);
   end;
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
       if(hits>0)and(ukfly=flylevel)and(IsUnitRange(transportU,nil)=false)then
        if(speed<=0)or(not iscomplete)then
         if(point_dist_int(x,y,tx,ty)<(tr+uid_r))then
         begin
            CheckCollisionR:=2;
            if(reveal_u<>nil)then
            begin
               AddToInt(@TeamVision[reveal_u^.player^.team],MinVisionTime);
               AddToInt(@TeamDetection[reveal_u^.player^.team],MinVisionTime);
               AddToInt(@reveal_u^.TeamVision[player^.team],MinVisionTime);
               AddToInt(@reveal_u^.TeamDetection[player^.team],MinVisionTime);
            end;
            exit;
         end;

   if(flylevel)then exit;

   for u:=0 to LastKeyPoint do
    with g_KeyPoints[u] do
     if(kpCaptureR>0)then
     begin
        if(building)
        then dx:=max2i(kpSolidr,kpNoBuildR)
        else dx:=kpSolidr;
        if(dx<=0)then continue;
        if(point_dist_int(tx,ty,kpx,kpy)<dx)then
        begin
           CheckCollisionR:=3;
           exit;
        end;
     end;

   if(building)then
     if(tx<tr)or((map_size-tr)<tx)
     or(ty<tr)or((map_size-tr)<ty)then
     begin
        CheckCollisionR:=5;  // out of bounds
        exit;
     end;

   if(not check_obstacles)then exit;

   tr-=bld_dec_mr;

   dx:=tx div MapObstaclesGridW;
   dy:=ty div MapObstaclesGridW;

   if(0<=dx)and(dx<=MapObstaclesGridN)and(0<=dy)and(dy<=MapObstaclesGridN)then
    with map_ObstaclesGrid[dx,dy] do
     if(oc_n>0)then
      for u:=0 to oc_n-1 do
       with oc_l[u]^ do
        if(o_r>0)and(o_type>0)then
         if(point_dist_int(o_x,o_y,tx,ty)<(tr+o_r))then
         begin
            CheckCollisionR:=4;
            exit;
         end;
end;

function CheckInBuildArea(tx,ty,tr:integer;buid,pl:byte):byte;
var u:integer;
begin
   CheckInBuildArea:=0;

   if(pl<=LastPlayer)then
     with g_gplayers[pl] do
       if(units_builders_e<=0)then
       begin
          CheckInBuildArea:=1; // no builders
          exit;
       end;

   with g_uids[buid] do
     if(tx<uid_r)or((map_size-uid_r)<tx)
     or(ty<uid_r)or((map_size-uid_r)<ty)then
     begin
        CheckInBuildArea:=2;  // out of bounds
        exit;
     end;

   for u:=0 to LastKeyPoint do
     with g_KeyPoints[u] do
       if(kpCaptureR>0)and(kpNoBuildR>0)then
         if(point_dist_int(tx,ty,kpx,kpy)<kpNoBuildR)then
         begin
            CheckInBuildArea:=2;
            exit;
         end;

   tr+=g_uids[buid].uid_r;

   CheckInBuildArea:=2;

   for u:=1 to MaxUnits do
    with g_punits[u]^ do
     with uid^ do
      if(hits>0)and(iscomplete)and(uid_isbuilder)and(not ukfly)and(playeri=pl)then
       if(player^.units_builders_s=0)or(isselected)then
        if(abs(x-tx)<=srange)and(abs(y-ty)<=srange)then
         if(buid in uid_prod_Buildings)and(IsUnitRange(transportU,nil)=false)then
          if(point_dist_int(x,y,tx,ty)<srange)then
          begin
             CheckInBuildArea:=0; // inside build area
             break;
          end;
end;

function CheckBuildPlace(tx,ty,tr,uskip:integer;playern,buid:byte):byte;
var i:byte;
begin
   CheckBuildPlace:=0;

   {
   0 :  m_brushc:=c_lime;
   1 :  m_brushc:=c_red;
   2 :  m_brushc:=c_blue;
   else m_brushc:=c_gray;
   }

   if(playern<=LastPlayer)then
     if(g_gplayers[playern].state=ps_AI)then
       if(map_IfObstacleZone(map_GetZone(tx,ty)))then begin CheckBuildPlace:=2;exit;end;

   i:=CheckInBuildArea(tx,ty,0,buid,playern); // 0=inside; 1=outside; 2=no builders
   case i of
   0  : ;
   2  : begin CheckBuildPlace:=2;exit;end;
   else begin CheckBuildPlace:=3;exit;end;
   end;

   with g_uids[buid] do
    i:=CheckCollisionR(tx,ty,tr+uid_r,uskip,uid_isbuilding,uid_isfly,true);
   if(i>0)then CheckBuildPlace:=1;
end;

function unit_ability_SpecReload(pu:PTUnit;ability:byte;newReload:integer):integer;
var u:integer;
begin
   unit_ability_SpecReload:=0;
   for u:=1 to MaxUnits do
     with g_punits[u]^ do
       if(hits>0)and(playeri=pu^.playeri)and(uid^.uid_ability=ability)then
         if(newReload>0)
         then rld:=newReload
         else
           if(rld>0)
           then unit_ability_SpecReload:=max2i(rld,unit_ability_SpecReload);
end;

function unit_ability_HKeepBlink(pu:PTUnit;x0,y0:integer;check:boolean):cardinal;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      unit_ability_HKeepBlink:=ureq_other;
      if(hits<=0)
      or(not iscomplete)then exit;

      rld:=max2i(unit_ability_SpecReload(pu,uid_ability,-1),rld);
      unit_ability_HKeepBlink:=ureq_reloading;
      if(buffs[ub_CCast]>0)
      or(rld>0)then exit;

      math_push_out(x0,y0,uid_r,unum,@x0,@y0,ukfly, true, team );
      x0:=mm3i(1,x0,map_Size);
      y0:=mm3i(1,y0,map_Size);

      unit_ability_HKeepBlink:=0;
      if(check)then exit;

      if(CheckCollisionR(x0,y0,uid_r,unum,uid_isbuilding,ukfly, true,pu)>0)then
      begin
         unit_ability_HKeepBlink:=ureq_landplace;
         rld:=fr_fps1*2;
         exit;
      end;

      buffs[ub_CCast]:=fr_fps1;
      unit_ability_SpecReload(pu,uid_ability,hkeep_reload);

      case uidi of
      UID_HKeep : unit_teleport(pu,x0,y0{$IFDEF _FULLGAME},EID_HKeep_H ,EID_HKeep_S ,snd_cube{$ENDIF});   // нет эффекта когда телепортируемся в неразведанную область
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
      unit_ability_HTowerBlink:=ureq_other;
      if(hits<=0)
      or(not iscomplete)then exit;

      unit_ability_HTowerBlink:=ureq_reloading;
      if(buffs[ub_CCast]>0)
      or(rld>0)then exit;

      if(srange<point_dist_int(x,y,x0,y0))then math_1c_push(@x0,@y0,x,y,srange-1);
      math_push_out(x0,y0,uid_r,unum,@x0,@y0,ukfly, true ,team );
      x0:=mm3i(1,x0,map_Size);
      y0:=mm3i(1,y0,map_Size);

      unit_ability_HTowerBlink:=ureq_landplace;
      if(point_dist_int(x,y,x0,y0)>srange)then exit;

      unit_ability_HTowerBlink:=0;
      if(check)then exit;

      if(CheckCollisionR(x0,y0,uid_r,unum,uid_isbuilding,ukfly,true,pu )>0)then
      begin
         unit_ability_HTowerBlink:=ureq_landplace;
         rld:=fr_fps1*2;
         exit;
      end;

      rld:=hblink_reload;
      buffs[ub_CCast]:=fr_fpsh;
      unit_teleport(pu,x0,y0{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF});  // нет эффекта когда телепортируемся в неразведанную область
   end;
end;

procedure unit_SetDefaults(pu:PTUnit;Client:boolean);
begin
   with pu^ do
   begin
      if(not Client)then
      begin
         transportU:= 0;
         a_tar    := 0;
         a_weap   := 0;
      end;

      uo_id    := ua_amove;
      uo_tar   := 0;
      uo_x     := x;
      uo_y     := y;
      rpoint_x := x;
      rpoint_y := y;
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
      unit_UpdateFogXY(pu);
      {$ENDIF}
   end;
end;

procedure unit_done_inc_cntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(uid_isbuilder  )then units_builders_ec  +=1;
      if(uid_isbarrack  )then
      begin
         units_unitProds_ec+=1;
         prod_unit_Max+=level+1;
      end;
      if(uid_issmith    )then
      begin
         units_upgrProds_ec+=1;
         prod_upgr_Max+=level+1;
      end;
   end;
end;
procedure unit_done_dec_cntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(uid_isbuilder  )then units_builders_ec  -=1;
      if(uid_isbarrack  )then
      begin
         units_unitProds_ec-=1;
         prod_unit_Max-=level+1;
      end;
      if(uid_issmith    )then
      begin
         units_upgrProds_ec-=1;
         prod_upgr_Max-=level+1;
      end;
   end;
end;

procedure unit_bld_inc_cntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(units_uid_u[uidi                    ]<=0)then units_uid_u[uidi                    ]:=unum;
      if(units_ucl_u[uid_isbuilding,uid_class]<=0)then units_ucl_u[uid_isbuilding,uid_class]:=unum;
      units_ucl_c[uid_isbuilding,uid_class]+=1;
      units_uid_c[uidi            ]+=1;
      energyl_max+=uid_EnergyGen;
      energyl_cur+=uid_EnergyGen;
      unit_done_inc_cntrs(pu);
   end;
end;

procedure unit_inc_cntrs(pu:PTUnit;ubld,summoned:boolean);
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      units_all_e+=1;
      armylimit+=uid_LimitUse;
      units_ucl_e[uid_isbuilding,uid_class]+=1;
      units_bld_e[uid_isbuilding          ]+=1;
      units_bld_l[uid_isbuilding          ]+=uid_LimitUse;
      units_uid_e[uidi                    ]+=1;
      if(uid_isbuilder)then units_builders_e+=1;

      iscomplete:=ubld;

      if(iscomplete)
      then unit_bld_inc_cntrs(pu)
      else
      begin
         hits  := 1;
         energyl_cur-=uid_EnergyReq;
         {$IFDEF _FULLGAME}
         if(playeri=UIPlayer)then SoundPlayAnoncer(snd_build_place[uid_race],false,false);
         {$ENDIF}
      end;

      if(summoned)and(iscomplete)then
      begin
         buffs[ub_Summoned]:=fr_fps1;
         {$IFDEF _FULLGAME}
         effect_UnitSummon(LastCreatedUnitP,nil);
         {$ENDIF}
      end;
   end;
end;

function unit_add(Ux,Uy,Uunum:integer;Uuid,UplayerN:byte;Ucomplete,Usummoned:boolean;Ulevel:byte;altMode:boolean=false):boolean;
var m,i:integer;
procedure FindNotExistedUnit;
begin
   i:=MaxPlayerUnits*UplayerN+1;
   m:=i+MaxPlayerUnits;
   while(i<m)do
   begin
      with g_units[i] do
        if(hits<=hits_dead)then
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
   with g_gplayers[UplayerN] do
   begin
      if(Uuid=0)then exit;

      if(not IsUnitRange(Uunum,nil))
      then FindNotExistedUnit
      else
        if(g_units[Uunum].hits>hits_dead)
        then FindNotExistedUnit
        else
        begin
           LastCreatedUnit :=Uunum;
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

            unit_SetXY(LastCreatedUnitP,Ux,Uy,mvxy_strict);
            uidi       := Uuid;
            playeri    := UplayerN;
            player     :=@g_gplayers[playeri];
            uo_x       := x;
            uo_y       := y;
            uo_bx      := -1;
            uo_by      := -1;
            move_x     := x;
            move_y     := y;
            isselected := false;
            transportC := 0;

            FillChar(buffs,sizeof(buffs),0);
            FillChar(TeamVision   ,SizeOf(TeamVision   ),0);
            FillChar(TeamDetection,SizeOf(TeamDetection),0);

            if(Ulevel>LastUnitLevel)then Ulevel:=LastUnitLevel;
            level:=Ulevel;

            unit_SetDefaults(LastCreatedUnitP,false);
            unit_TeamReveal (LastCreatedUnitP,false);
            unit_ApplyUID   (LastCreatedUnitP);
            unit_inc_cntrs  (LastCreatedUnitP,Ucomplete,Usummoned);
            unit_UpdateXY   (LastCreatedUnitP);

            if(altMode)then buffs[ub_altMode]:=ub_infinity;
         end;
      end;
   end;
end;

function unit_start_build(bx,by:integer;buid,bp:byte):cardinal;
begin
   unit_start_build:=CheckUnitReqs(@g_gplayers[bp],buid);
   if(unit_start_build=0)then
     with g_gplayers[bp] do
       if(CheckBuildPlace(bx,by,0,0,bp,buid)=0)
       then unit_add(bx,by,-1,buid,bp,false,false,0)
       else unit_start_build:=ureq_place;
end;

function barrack_out_r(pu:PTUnit;_uid:byte):integer;
begin
   if(g_uids[_uid].uid_isfly=uf_fly)
   then barrack_out_r:=0
   else barrack_out_r:=pu^.uid^.uid_r;//+g_uids[_uid].uid_r;
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
         LastCreatedUnitP^.uo_x  :=rpoint_x;
         LastCreatedUnitP^.uo_y  :=rpoint_y;
         LastCreatedUnitP^.uo_tar:=rpoint_tar;
         LastCreatedUnitP^.uo_id :=ua_amove;
         LastCreatedUnitP^.dir   :=dir;

         if(uid_OutUnitsTeleBuff)then
         begin
            LastCreatedUnitP^.buffs[ub_Teleport]:=fr_fps1;
            {$IFDEF _FULLGAME}
            if(SoundPlayUnit(snd_teleport,pu,nil))
            then effect_add(LastCreatedUnitP^.vx,
                            LastCreatedUnitP^.vy,draw_SpriteDepth(LastCreatedUnitP^.vy+1,LastCreatedUnitP^.ukfly),EID_Teleport);
            {$ENDIF}
         end;
         barrack_out:=true;
      end;
   end;
end;

procedure barrack_spawn(pu:PTUnit;_uid,count:byte);
var
sstep,i  :integer;
announcer:boolean;
begin
   with pu^ do
   with uid^ do
   begin
      if(x=rpoint_x)and(y=rpoint_y)
      then dir:=270
      else dir:=point_dir(x,y,rpoint_x,rpoint_y);
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
   if(pn>LastUnitLevel)
   then unit_ProdStartUnitLine:=ureq_other
   else
     with uBarrack^ do
     with uid^ do
     with player^ do
     begin
        unit_ProdStartUnitLine:=CheckUnitReqs(player,puid);
        if(unit_ProdStartUnitLine=0)then
          if(uprod_r[pn]>0)
          then unit_ProdStartUnitLine:=ureq_busy
          else
            with g_upids[puid] do
            begin
               if(check)then exit;

               prod_unit_Now+=1;
               prod_unit_Limit+=g_uids[puid].uid_LimitUse;
               prod_unit_ucl[g_uids[puid].uid_class]+=1;
               prod_unit_uid[puid             ]+=1;
               energyl_cur-=g_uids[puid].uid_EnergyReq;
               uprod_u[pn]:=puid;
               uprod_r[pn]:=g_uids[puid].uid_ProdTimeTick;
            end;
     end;
end;
function unit_ProdStartUnit(uBarrack:PTUnit;puid:byte;check:boolean):cardinal;  // main function
var pn:byte;
begin
   with uBarrack^ do
   with uid^ do
   begin
      unit_ProdStartUnit:=ureq_other;
      if(puid=255)
      or(puid=0  )
      or(hits<=0)
      or(not iscomplete)
      or(not uid_isbarrack)
      or(not uid_isbuilding)then exit;

      unit_ProdStartUnit:=ureq_barracks;
      if not(puid in uid_prod_Units)
      then exit;
   end;

   for pn:=0 to LastUnitLevel do
   begin
      if(pn>uBarrack^.level)then break;
      unit_ProdStartUnit:=unit_ProdStartUnitLine(uBarrack,puid,pn,check);
      if(unit_ProdStartUnit=0)then break;
   end;
end;
/// Stop unit prod
function unit_ProdStopUnitLine(uBarrack:PTUnit;puid,pn:byte;check:boolean):cardinal;
begin
   unit_ProdStopUnitLine:=ureq_other;
   with uBarrack^ do
   with uid^ do
     if(pn<=LastUnitLevel)then
       if(uprod_r[pn]>0)then
         if(puid=255)or(puid=uprod_u[pn])then
           with player^ do
           begin
              unit_ProdStopUnitLine:=0;
              if(check)then exit;

              puid:=uprod_u[pn];

              prod_unit_Now-=1;
              prod_unit_Limit-=g_uids[puid].uid_LimitUse;
              prod_unit_ucl[ g_uids[puid].uid_class]-=1;
              prod_unit_uid[ puid           ]-=1;
              energyl_cur+=g_uids[puid].uid_EnergyReq;
              uprod_r[pn]:=0;
           end;
end;
function unit_ProdStopUnit(uBarrack:PTUnit;puid:byte;all,check:boolean):cardinal;
var pn:byte;
begin
   with uBarrack^ do
   with uid^ do
   begin
      unit_ProdStopUnit:=ureq_other;
      if(puid=0 )
      or(hits<=0)
      or(not iscomplete)
      or(not uid_isbarrack)
      or(not uid_isbuilding)then exit;
   end;

   for pn:=LastUnitLevel downto 0 do
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
   if(pn>LastUnitLevel)
   then unit_ProdStartUpgradeLine:=ureq_other
   else
     with uSmith^ do
     with uid^ do
     with player^ do
     begin
        unit_ProdStartUpgradeLine:=CheckUpgradeReqs(player,upid);
        if(unit_ProdStartUpgradeLine=0)then
          if(pprod_r[pn]>0)
          then unit_ProdStartUpgradeLine:=ureq_busy
          else

            with g_upids[upid] do
            begin
               if(check)then exit;

               prod_upgr_Now+=1;
               prod_upgr_upid[upid]+=1;
               pprod_e[pn]:=GetUpgradeEnergy(upid,upgrs_cur[upid]+1);
               energyl_cur-=pprod_e[pn];
               pprod_r[pn]:=GetUpgradeTime(upid,upgrs_cur[upid]+1);
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
      unit_ProdStartUpgrade:=ureq_other;
      if(upid=255)
      or(upid=0  )
      or(hits<=0)
      or(not iscomplete)
      or(not uid_issmith)
      or(not uid_isbuilding)then exit;

      unit_ProdStartUpgrade:=ureq_smiths;
      if not(upid in uid_prod_Upgrades)
      then exit;
   end;

   for pn:=0 to LastUnitLevel do
   begin
      if(pn>uSmith^.level)then break;
      unit_ProdStartUpgrade:=unit_ProdStartUpgradeLine(uSmith,upid,pn,check);
      if(unit_ProdStartUpgrade=0)then break;
   end;
end;
function unit_ProdStopUpgradeLine(uSmith:PTUnit;upid:byte;pn:integer;check:boolean):cardinal;
begin
   unit_ProdStopUpgradeLine:=ureq_other;
   with uSmith^ do
   with uid^ do
     if(pn<=LastUnitLevel)then
       if(pprod_r[pn]>0)then
         if(upid=255)or(upid=pprod_u[pn])then
           with player^ do
           begin
              unit_ProdStopUpgradeLine:=0;
              if(check)then exit;

              upid:=pprod_u[pn];

              prod_upgr_Now-=1;
              prod_upgr_upid[upid]-=1;
              energyl_cur+=pprod_e[pn];
              pprod_r[pn]:=0;
           end;
end;
function unit_ProdStopUpgrade(uSmith:PTUnit;upid:byte;all:boolean;check:boolean):cardinal;
var pn:byte;
begin
   with uSmith^ do
   with uid^ do
   begin
      unit_ProdStopUpgrade:=ureq_other;
      if(upid=0 )
      or(hits<=0)
      or(not iscomplete)
      or(not uid_issmith)
      or(not uid_isbuilding)then exit;
   end;

   for pn:=LastUnitLevel downto 0 do
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
      units_ucl_s [uid_isbuilding,uid_class]+=1;
      units_bld_s[uid_isbuilding     ]+=1;
      units_uid_s [uidi            ]+=1;
      if(uid_isbuilder)then units_builders_s+=1;
      if(uid_isbarrack)then units_unitProds_s+=1;
      if(uid_issmith  )then units_upgrProds_s  +=1;
      units_all_s+=1;
   end;
end;
procedure unit_counters_dec_select(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      units_ucl_s [uid_isbuilding,uid_class]-=1;
      units_bld_s[uid_isbuilding     ]-=1;
      units_uid_s [uidi            ]-=1;
      if(uid_isbuilder)then units_builders_s-=1;
      if(uid_isbarrack)then units_unitProds_s-=1;
      if(uid_issmith  )then units_upgrProds_s  -=1;
      units_all_s-=1;
   end;
end;

procedure unit_UnSelect(pu:PTUnit);
begin
   with pu^ do
   if(isselected)then
   begin
      unit_counters_dec_select(pu);
      isselected:=false;
   end;
end;
procedure unit_Select(pu:PTUnit);
begin
   with pu^ do
   if(not isselected)then
   begin
      unit_counters_inc_select(pu);
      isselected:=true;
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
      then energyl_cur+=g_uids[uidi].uid_EnergyReq
      else
      begin
         unit_ProdStopUnit   (pu,255,true,false);
         unit_ProdStopUpgrade(pu,255,true,false);

         units_ucl_c[uid_isbuilding,uid_class]-=1;
         units_uid_c[uidi            ]-=1;
         energyl_max-=uid_EnergyGen;
         energyl_cur-=uid_EnergyGen;

         unit_done_dec_cntrs(pu);
      end;

      if(units_ucl_u[uid_isbuilding,uid_class]=unum)then units_ucl_u[uid_isbuilding,uid_class]:=0;
      if(units_uid_u[uidi                    ]=unum)then units_uid_u[uidi                    ]:=0;
   end;
end;

procedure unit_dec_Rcntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      units_all_e     -=1;
      armylimit-=uid_LimitUse;
      units_ucl_e[uid_isbuilding,uid_class]-=1;
      units_bld_e[uid_isbuilding     ]-=1;
      units_bld_l[uid_isbuilding     ]-=uid_LimitUse;
      units_uid_e[uidi            ]-=1;
      if(uid_isbuilder)then units_builders_e-=1;
   end;
end;

procedure unit_end_uprod(pu:PTUnit);
var
i,puid:byte;
begin
   with pu^ do
   with uid^ do
   with player^ do
     if(uid_isbarrack)then
       for i:=0 to LastUnitLevel do
         if(uprod_r[i]>0)then
         begin
            puid:=uprod_u[i];

            if((units_all_e+prod_unit_Now)>MaxPlayerUnits)
            or((armylimit+prod_unit_Limit)>MaxPlayerLimit)
            or(energyl_cur<0)
            or(units_uid_e[puid]>=units_uid_m[puid])
            then
            else
              if(uprod_r[i]=1){$IFDEF DEBUG0}or(test_InstaProd){$ENDIF}then
              begin
                 barrack_spawn(pu,uprod_u[i],upgrs_cur[upgr_mult_product]);
                 unit_ProdStopUnitLine(pu,255,i,false);
              end
              else uprod_r[i]:=max2i(1,uprod_r[i]-1*(upgrs_cur[upgr_fast_product]+1) );
         end;
end;

procedure unit_end_pprod(pu:PTUnit);
var i,tuid:byte;
begin
   with pu^ do
   with uid^ do
   with player^ do
     if(uid_issmith)then
       for i:=0 to LastUnitLevel do
         if(pprod_r[i]>0)then
         begin
            tuid:=pprod_u[i];
            if(energyl_cur<0)
            or(upgrs_cur[tuid]>=g_upids[tuid].upgr_max)
            or(upgrs_cur[tuid]>=upgrs_max[tuid])
            then
            else
              if(pprod_r[i]=1){$IFDEF DEBUG0}or(test_InstaProd){$ENDIF}then
              begin
                 upgrs_cur[tuid]+=1;
                 unit_ProdStopUpgradeLine(pu,255,i,false);
                 GameLogUpgradeComplete(playeri,tuid,x,y);
              end
              else pprod_r[i]:=max2i(1,pprod_r[i]-1*(upgrs_cur[upgr_fast_product]+1) );
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
            LastCreatedUnitP^.uo_x  :=uo_x;
            LastCreatedUnitP^.uo_y  :=uo_y;
            {if(IsUnitRange(a_tar,@tu))then
            begin
               LastCreatedUnitP^.uo_x  :=tu^.x;
               LastCreatedUnitP^.uo_y  :=tu^.y;
               LastCreatedUnitP^.uo_tar:=tu^.unum;
            end
            else
              if(uo_x<>x)or(uo_y<>y)then
              begin
                 LastCreatedUnitP^.uo_x:=uo_x;
                 LastCreatedUnitP^.uo_y:=uo_y;
              end; }
         end
         else LastCreatedUnit:=0;
      end
      {$IFDEF _FULLGAME}
      else
        with g_uids[auid] do
          effect_InPoint(tx,ty,draw_SpriteDepth(ty+1,ukfly),nil,uid_eid_DeathFast[0],uid_snd_DeathFast);

        {case auid of
//UID_Phantom : effect_InPoint(tx,ty,draw_SpriteDepth(ty+1,ukfly),nil,auid,snd_pexp);
UID_LostSoul:
        end; } //
      {$ENDIF};
   end;
end;

procedure unit_ArmSpawnUnit(pu:PTUnit;auid:byte);
var dd:integer;
begin
   with pu^ do
   with uid^ do
   begin
      dd:=dir_MOD360(dir+23) div 45;
      unit_ability_spawn(pu,x+dir_stepX[dd]*uid_r,y+dir_stepY[dd]*uid_r,auid);
   end;
end;

function unit_CheckTransport(pTransport,pPassenger:PTUnit):boolean;
begin
   unit_CheckTransport:=false;
   if(pPassenger^.ukfly=uf_fly)or(pTransport=pPassenger)then exit;

   if(pTransport^.player<>pPassenger^.player)then
     if(pTransport^.player^.team<>pPassenger^.player^.team)then exit;

   if((pTransport^.transportM-pTransport^.transportC)>=pPassenger^.uid^.uid_TransportSize)then
     if(pPassenger^.uidi in pTransport^.uid^.ups_TransportUIDs)then unit_CheckTransport:=true;
end;

procedure unit_BaseTimers(pu:PTUnit);
var i:byte;
begin
   with pu^ do
   begin
      for i:=0 to LastUnitBuff do
        if(0<buffs[i])and(buffs[i]<ub_infinity)then buffs[i]-=1;

      for i:=0 to LastPlayer do
      begin
         if(0<TeamVision   [i])and(TeamVision   [i]<ub_infinity)then TeamVision   [i]-=1;
         if(0<TeamDetection[i])and(TeamDetection[i]<ub_infinity)then TeamDetection[i]-=1;
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
      if(uDetector^.player^.isobserver)
      then td:=0
      else
        if(uDetector^.uid^.uid_ability_isradar)and(uDetector^.rld>radar_vision_time)then
        begin
           td:=point_dist_int(x,y,uDetector^.uo_x,uDetector^.uo_y);
           if(td<ud)
           then scan_buff:=ub_Scaned
           else td:=ud;
        end
        else td:=ud;

      if(td<=(uDetector^.srange+uid^.uid_r))then
        if(buffs[ub_Invis]<=0)then
        begin
           AddToInt(@TeamVision[uDetector^.player^.team],MinVisionTime);
           if(scan_buff<=LastUnitBuff)and(player^.team<>uDetector^.player^.team)
           then AddToInt(@buffs[scan_buff],MinVisionTime);
        end
        else
          if(uDetector^.buffs[ub_Detect]>0)and(uDetector^.iscomplete)and(uDetector^.hits>0)then
          begin
             AddToInt(@TeamVision   [uDetector^.player^.team],MinVisionTime);
             AddToInt(@TeamDetection[uDetector^.player^.team],MinVisionTime);
             if(scan_buff<=LastUnitBuff)and(player^.team<>uDetector^.player^.team)
             then AddToInt(@buffs[scan_buff],MinVisionTime);
          end;
   end;
end;


procedure unit_remove(pu:PTUnit);
begin
   with pu^ do
   with player^ do
   begin
      unit_dec_Rcntrs(pu);

      if(units_all_e<=0)and(state>ps_None){$IFDEF _FULLGAME}and(g_type<>gt_campaing){$ENDIF}then
      begin
         isdefeated:=true;
         GameLogPlayerDefeated(playeri);
         if(g_DefeatedObs)and(state=ps_human)then isobserver:=true;
      end;
   end;
end;

procedure unit_kill(pu:PTUnit;instant,fastdeath,buildcd,KillAllInside,suicide:boolean);
var i :integer;
    tu:PTunit;
begin
   with pu^ do
   with player^ do
     if(hits>0)then
     begin
        if(not instant)then
        begin
           with uid^ do fastdeath:=(fastdeath)or(uid_FastDeathHits>=0)or(uid_isbuilding);
           buffs[ub_Pain]:=fr_fps1; // prevent fast resurrecting

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
           if(uid_isbuilding)and(buildcd)then
             if(uid_ability<>uab_HEyeVision)or(not iscomplete)then build_cd:=min2i(build_cd+step_build_reload,max_build_reload);
           zfall:=uid_zfall;
        end;

        x       :=vx;
        y       :=vy;
        uo_x    :=x;
        uo_y    :=y;
        rpoint_x:=x;
        rpoint_y:=y+uid^.uid_r;
        uo_bx   :=-1;
        uo_by   :=-1;
        uo_tar  :=0;
        move_x  :=x;
        move_y  :=y;
        a_tar   :=0;
        rld     :=0;

        for i:=1 to MaxUnits do
          if(i<>unum)then
          begin
             tu:=@g_units[i];
             if(tu^.uo_tar    =unum)then tu^.uo_tar    :=0;
             if(tu^.rpoint_tar=unum)then tu^.rpoint_tar:=0;
             if(tu^.hits<=0)
             then tu^.transportU:=0
             else
               if(transportC>0)and(tu^.transportU=unum)then
                 if(ukfly<>uf_ground)or(transportU>0)or(KillAllInside)
                   then unit_kill(tu,true,false,true,KillAllInside,suicide)
                   else
                   begin
                      transportC-=tu^.uid^.uid_TransportSize;
                      tu^.transportU:=0;
                      tu^.x     :=x-g_randomr(uid^.uid_missileR);
                      tu^.y     :=y-g_randomr(uid^.uid_missileR);
                      tu^.uo_x  :=tu^.x;
                      tu^.uo_y  :=tu^.y;
                      tu^.uo_tar:=0;
                      if(tu^.hits>apc_exp_damage)
                      then tu^.hits-=apc_exp_damage
                      else unit_kill(tu,true,false,true,false,suicide);
                   end;
          end;
        missiles_clear_tar(unum,false);

        if(instant)then
        begin
           hits:=hits_ndead;
           unit_remove(pu);
        end
        else
        begin
           if(fastdeath)
           then hits:=hits_fdead
           else hits:=0;

           with uid^ do
           begin
              if(uid_DeathMissile>0)then
                missile_add(x,y,x,y,0,uid_DeathMissile,playeri,ukfly,ukfly,false,0,uid_DeathMissile_dmod);
              if(uid_DeathUID>0)and(uid_DeathUIDn>0)then
                for i:=1 to uid_DeathUIDn do
                  if(_uid_player_limit(player,uid_DeathUID))then
                    unit_add(x-g_randomr(uid_missileR),y-g_randomr(uid_missileR),0,uid_DeathUID,playeri,true,true,0);
           end;
        end;
     end
     else
       if(hits>hits_dead)then
       begin
          hits:=hits_ndead;
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
      unit_CalcFogR(pu);
      {$ENDIF}
   end;
end;
begin
   with pu^ do
   with uid^ do
   with player^ do
   if(iscomplete)and(hits>0)then
   begin
      speed:=uid_BaseSpeed;
      // ABILITIES


      // DETECTION
      if(uid_isdetector)or(buffs[ub_HVision]>0)
      then buffs[ub_Detect]:=ub_infinity
      else buffs[ub_Detect]:=0;

      // INVIS
      case uidi of
UID_HTotem        : buffs[ub_Invis]:=b2ib[upgrs_cur[upgr_hell_TotemInvis  ]>0];
UID_Commando      : buffs[ub_Invis]:=b2ib[upgrs_cur[upgr_uac_CommandoInvis]>0];
UID_Demon         : buffs[ub_Invis]:=b2ib[upgrs_cur[upgr_hell_Spectre     ]>0];
UID_UMine         : buffs[ub_Invis]:=ub_infinity;
      end;

      // OTHER
      case uidi of
UID_Phantom,
UID_LostSoul      : begin
                       tu:=nil;
                       if(IsUnitRange(a_tar,@tu))and(a_rld>0)then buffs[ub_CCast]:=fr_fpsh;
                       if(buffs[ub_pain]<=0)then
                         if(buffs[ub_CCast]>0)and(tu<>nil)then ukfly:=tu^.ukfly else ukfly:=uid_isfly;
                       ukfloater:=not ukfly;
                    end;
//UID_UTransport    : begin level:=min2i(upgrs_cur[upgr_uac_Transport],LastUnitLevel);transportM:=uid_TransportMax+4*level;end;
//UID_APC           : begin level:=min2i(upgrs_cur[upgr_uac_Transport],LastUnitLevel);transportM:=uid_TransportMax+2*level;end;
      end;
      if(upgrs_cur[upgr_invuln]>0)then buffs[ub_Invuln]:=fr_fps1;

      // SRANGE
      t:=uid_BaseSightR;
      if(uid_upgr_SightR>0)and(uid_upgr_SightStep>0)
      then t+=upgrs_cur[uid_upgr_SightR]*uid_upgr_SightStep;
      if(not uid_isbuilding)
      then t+=upgrs_cur[upgr_race_unit_srange[uid_race]]*upgr_race_srange_unit_bonus[uid_race];
      SetSRange(t);
   end;
end;



