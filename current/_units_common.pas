

function unit_ProdStopUpgrade(uForge  :PTUnit;upid:byte;all,canceled,check:boolean):byte;forward;
function unit_ProdStopUnit   (uBarrack:PTUnit;puid:byte;all,canceled,check:boolean):byte;forward;

{$IFDEF _FULLGAME}
procedure unit_UpdateMiniMapXY(pu:PTUnit);
begin
   with pu^ do
   with g_unitsVis[unum] do
   begin
      mmx:=trunc(x*map_MiniMap_cx);
      mmy:=trunc(y*map_MiniMap_cx);
   end;
end;

procedure unit_UpdateFogXY(pu:PTUnit);
begin
   with pu^ do
   with g_unitsVis[unum] do
   begin
      fx :=x div fog_cw;
      fy :=y div fog_cw;
   end;
end;

procedure units_DefaultVisData;
var u :integer;
begin
   for u:=1 to MaxUnits do
     with g_units[u] do
     with uid^ do
     with g_unitsVis[u] do
     begin
        if(uid_AnimStepWalk>0) then animf:=random(uid_AnimStepWalk);

        unit_UpdateMiniMapXY(g_punits[u]);
        unit_UpdateFogXY(g_punits[u]);
        unit_UpdateStatusStrings(g_punits[u]);

        animw  := uid_AnimStepWalk;
        shadowz:= unit_CalcShadowZ(g_punits[u],false);
        unit_CalcFogR(g_punits[u]);
     end;
end;


procedure effect_Common(pu:PTUnit;etype:byte;pUIVision:pboolean);
begin
   if(pUIVision<>nil)then
   begin
      if(not pUIVision^)then exit;
   end
   else
      if(not ui_CheckUnitUIPlayerVision(pu,true))then exit;

   with pu^ do
     case etype of
     EID_PowerUp,
     EID_UnitCaptured,
     EID_HVision,
     EID_HLevelUp,
     EID_ULevelUp    : begin
                          case etype of
                          EID_HLevelUp,
                          EID_ULevelUp,
                          EID_PowerUp     : snd_SoundPlayUnit(snd_PowerUp        ,pu,nil);
                          EID_UnitCaptured: snd_SoundPlayUnit(snd_GeneratorCapture,pu,nil);
                          EID_HVision     : snd_SoundPlayUnit(snd_hell_eye       ,pu,nil);
                          end;

                          effect_add(vx,vy,draw_DefaultSpriteDepth(vy+1,isfly),etype);
                       end;
     else
               case uid^.uid_race of
               r_hell: begin
                          snd_SoundPlayUnit(snd_unit_adv[uid^.uid_race],pu,nil);
                          effect_add(vx,vy,draw_DefaultSpriteDepth(vy+1,isfly),EID_HLevelUp);
                       end;
               r_uac : begin
                          snd_SoundPlayUnit(snd_unit_adv[uid^.uid_race],pu,nil);
                          effect_add(vx,vy,draw_DefaultSpriteDepth(vy+1,isfly),EID_ULevelUp);
                       end;
               end;
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

          snd_SoundPlayUnit(uid_snd_Summon,nil,nil);
          effect_add(vx,vy,draw_DefaultSpriteDepth(vy+1,isfly),uid_eid_Summon[level]);

          if(playeri=UIPlayer)then snd_SoundPlayUnit(uid_snd_ready,nil,nil);
       end;
end;

procedure effect_UnitDeath(pu:PTUnit;fastdeath:boolean;pUIVision:pboolean);
begin
   with pu^ do
   with uid^ do
   begin
      if(not isfly)and(uid_eid_bcrater>0)and(uid_isbuilding)then
        effect_add(vx,vy+uid_eid_bcrater_y,sd_liquidFront+vy,uid_eid_bcrater);

      if(pUIVision<>nil)then
      begin
         if(not pUIVision^)then exit;
      end
      else
        if(not ui_CheckUnitUIPlayerVision(pu,true))then exit;

      if(fastdeath)then
      begin
         effect_add(vx,vy,draw_DefaultSpriteDepth(vy+1,isfly),uid_eid_DeathFast[level]);
         snd_SoundPlayUnit(uid_snd_DeathFast,nil,nil);
      end
      else
      begin
         effect_add(vx,vy,vy+1,uid_eid_DeathSlow[level]);
         snd_SoundPlayUnit(uid_snd_DeathSlow,nil,nil);
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

      if(uid_eid_Pain>0)then
        effect_add(vx-random(uid_missileR)+random(uid_missileR),
                   vy-random(uid_missileR)+random(uid_missileR),draw_DefaultSpriteDepth(vy+1,isfly),uid_eid_Pain);
      snd_SoundPlayUnit(uid_snd_Pain,nil,nil);
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
   snd_SoundPlayUnit(sound,nil,nil);
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
         effect_add(vx,vy,draw_DefaultSpriteDepth(vy+1,isfly),aw_eid_start);
         snd_SoundPlayUnit(aw_snd_start,nil,nil);
      end
      else
      begin
         effect_add(vx+aw_offset_x,vy+aw_offset_y,draw_DefaultSpriteDepth(vy+1,isfly),aw_eid_shot );
         snd_SoundPlayUnit(aw_snd_shot,nil,nil);
      end;
   end;
end;

procedure effect_ScanSound(pCaster:PTUnit);
begin
   if(UIPlayer<=LastPlayer)then
     if(pCaster^.player^.team<>g_PlayersGame[UIPlayer].team)then exit;
   snd_SoundPlayUnit(snd_RadarScan,nil,nil);
end;

{$ENDIF}

function unit_canMove(pu:PTUnit):boolean;
begin
   with pu^ do
   with uid^ do
     {$IFDEF _FULLGAME}
     if(not ServerSide)and(speed>0)
     then unit_canMove:=(x<>move_x)or(y<>move_y)
     else
     {$ENDIF}
     begin
        unit_canMove:=false;

        if(speed<=0)
        or(hits<=0)
        or(not iscomplete)
        or(transformTimer>0)then exit;

        if(a_rld>0)then
          if(a_weap_cl>LastUnitArms)
          then exit
          else
            with uid_arms[a_weap_cl] do
              if((aw_req_flags and wpr_move)=0)then exit;

        if(not uid_isbuilding)then
          if(buffs[ub_PainState]>0)
          or(buffs[ub_Cast     ]>0)then exit;

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
      or(transformTimer>0)
      or(hits<=0)
      or(not uid_CanAttack)then exit;

      if(check_buffs)then
        case uid_isbuilding of
        true : if(buffs[ub_SpecPause]>0)then exit;
        false: if(buffs[ub_PainState]>0)
               or(buffs[ub_Cast     ]>0)then exit;
        end;

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
      unit_UpdateMiniMapXY(pu);
      unit_UpdateFogXY(pu);
      {$ENDIF}
   end;
end;

procedure unit_SetXY(pu:PTUnit;ax,ay:integer;movevxy:byte;updateXY:boolean=true);
var _px,_py:integer;
begin
   with pu^ do
   begin
      _px:=x;
      _py:=y;
      x:=mm3i(1,ax,map_Size1);
      y:=mm3i(1,ay,map_Size1);
      if(x<>_px)or(y<>_py)then
      begin
         if(updateXY)then
           unit_UpdateXY(pu);
         case uo_id of
         ua_move,
         ua_hold,
         ua_amove: begin
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
           AddToInt(@TeamVision   [p],MinVisionTime);
           AddToInt(@TeamDetection[p],MinVisionTime);
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

procedure unit_OrderClear(pu:PTUnit;newID:byte);
begin
   with pu^ do
   begin
      if(newID<255)then uo_id :=newID;

      uo_tar:=0;
      uo_x  :=x;
      uo_y  :=y;
      uo_bx :=-1;
      uo_by :=-1;
   end;
end;
procedure unit_clear_tar(tar:integer);
var u:integer;
begin
   for u:=1 to MaxUnits do
     with g_punits[u]^ do
       if(uo_tar=tar)then uo_tar:=0;
end;
procedure missiles_clear_tar(u:integer;stop:boolean);
var i:integer;
begin
   for i:=0 to MaxUnits do
     with g_missiles[i] do
       if(m_vstep>0)and(m_tar=u)then
       begin
          m_tar:=0;
          if(stop)then
          begin
             m_tox:=m_x;
             m_toy:=m_y;
             m_vstep:=1;
          end;
       end;
end;

procedure teleport_CalcReload(pTeleporter:PTUnit;limit:integer);
begin
   with pTeleporter^ do
     with player^ do
       with g_aids[uab_Teleport] do
         rld:=integer(round(limit/MinUnitLimit*(ua_reload-(upgrs_cur[ua_rldDec_upgr]*ua_rldDec_upgrS))));
end;

procedure unit_Teleport2Point(pu:PTUnit;tx,ty:integer{$IFDEF _FULLGAME};eidstart,eidend:byte;snd:PTSoundSet{$ENDIF});
begin
   with pu^ do
   begin
      tx:=mm3i(0,tx,map_Size1);
      ty:=mm3i(0,ty,map_Size1);
      {$IFDEF _FULLGAME}
      effect_teleport(vx,vy,tx,ty,isfly,eidstart,eidend,snd,pu);
      {$ENDIF}
      buffs[ub_Teleported]:=fr_fps1;
      unit_SetXY(pu,tx,ty,mvxy_strict);
      unit_OrderClear(pu,255);
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
   {$IFDEF _FULLGAME}
   if(ServerSide)then
   {$ENDIF}
   unit_zfall(pu);

   with pu^ do
     if(vx<>x)or(vy<>y)then
     begin
        if(vstp>UnitStepTicks)
        {$IFDEF _FULLGAME}
        and(ServerSide)
        {$ENDIF}
        then vstp:=UnitStepTicks;
        if(vstp<=0)then vstp:=UnitStepTicks;
        vx  +=(x-vx) div vstp;
        vy  +=(y-vy) div vstp;
        vstp-=1;
     end;
end;

function unit_CheckActiveWeapons(pu:PTUnit):boolean;
var a:byte;
begin
   unit_CheckActiveWeapons:=false;
   with pu^ do
   with player^ do
   with uid^ do
     for a:=0 to LastUnitArms do
       with uid_arms[a] do
         if(aw_type>0)then
         begin
            if(aw_req_uid >0)and(units_uid_c[aw_req_uid ]<=0)then continue;
            if(aw_req_upgr>0)and(upgrs_cur  [aw_req_upgr] =0)then continue;
            unit_CheckActiveWeapons:=true;
            break;
         end;
end;

function unit_AddExp(pu:PTUnit;exp:cardinal;forceUp,check:boolean):byte;
begin
   unit_AddExp:=lmt_unit_MaxLevel;
   with pu^ do
     if(level<LastUnitLevel)then
       with uid^ do
       begin
          unit_AddExp:=0;
          if(check)then exit;

          game_ScoresAddC(playeri,psc_units_ExpTotal,exp);
          a_exp+=exp;
          if(a_exp>=uid_LevelUpTimeTicks)or(forceUp)then
          begin
             level+=1;
             a_exp:=0;
             GameLog_UnitPromoted(pu);
             {$IFDEF _FULLGAME}
             effect_Common(pu,0,nil);
             {$ENDIF}
          end;
       end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   ABILITY
//

function unit_Ability2Act(pu:PTUnit;aid:byte):byte;
begin
   with pu^.uid^ do
     if(uid_ability1=aid)
     then unit_Ability2Act:=ua_ability1
     else
       if(uid_ability2=aid)
       then unit_Ability2Act:=ua_ability2
       else
         if(uid_ability3=aid)
         then unit_Ability2Act:=ua_ability3
         else unit_Ability2Act:=0;
end;

////////////////////////////////////////////////////////////////////////////////

function ability_CheckTarget_HellVision(CasterTeam:byte;pTarget:PTUnit):boolean;
begin
   ability_CheckTarget_HellVision:=false;
   with pTarget^ do
     if(not iscomplete)
     or(IsUnitRange(TransportU,nil))
     or(hits<=0)
     or(player^.team<>CasterTeam)
     or(buffs[ub_HellVision]>0)
     or(buffs[ub_Detector  ]>0)
     or(uid^.uid_ismarker)then exit;
   ability_CheckTarget_HellVision:=true;
end;

function ability_CheckTarget_SphereSoul(CasterTeam:byte;pTarget:PTUnit):boolean;
begin
   ability_CheckTarget_SphereSoul:=false;
   with pTarget^ do
   with uid^ do
     if(hits<=0)
     or(hits>=uid_MaxHits1)
     or(player^.team<>CasterTeam)
     or(IsUnitRange(TransportU,nil))
     or(not iscomplete)
     or(uid_isbuilding)
     or(buffs[ub_SphereSoul]>0)
     or(uid_ismarker)then exit;
   ability_CheckTarget_SphereSoul:=true;
end;

function ability_CheckTarget_SphereInvis(CasterTeam:byte;pTarget:PTUnit):boolean;
begin
   ability_CheckTarget_SphereInvis:=false;

   with pTarget^ do
   with uid^ do
     if(hits<=0)
     or(IsUnitRange(TransportU,nil))
     or(player^.team<>CasterTeam)
     or(not iscomplete)
     or(uid_isbuilding)
     or(buffs[ub_SphereInvis ]>0)
     or(buffs[ub_Invisibility]>0)
     or(uid_ismarker)then exit;

   ability_CheckTarget_SphereInvis:=true;
end;

function ability_CheckTarget_SphereInvuln(CasterTeam:byte;pTarget:PTUnit):boolean;
begin
   ability_CheckTarget_SphereInvuln:=false;

   with pTarget^ do
   with uid^ do
     if(hits<=0)
     or(IsUnitRange(TransportU,nil))
     or(player^.team<>CasterTeam)
     or(not iscomplete)
     or(uid_isbuilding)
     or(buffs[ub_SphereInvuln]>0)
     or(uid_ismarker)then exit;

   ability_CheckTarget_SphereInvuln:=true;
end;

function ability_CheckTarget_SphereRDamage(CasterTeam:byte;pTarget:PTUnit):boolean;
begin
   ability_CheckTarget_SphereRDamage:=false;

   with pTarget^ do
   with uid^ do
     if(hits<=0)
     or(IsUnitRange(TransportU,nil))
     or(player^.team<>CasterTeam)
     or(buffs[ub_SphereRDamage]>0)
     or(buffs[ub_Heroic       ]>0)
     or(uid_ismarker)then exit;

   ability_CheckTarget_SphereRDamage:=true;
end;

function ability_CheckTarget_SphereDDamage(CasterTeam:byte;pTarget:PTUnit):boolean;
begin
   ability_CheckTarget_SphereDDamage:=false;

   with pTarget^ do
   with uid^ do
     if(hits<=0)
     or(IsUnitRange(TransportU,nil))
     or(player^.team<>CasterTeam)
     or(not iscomplete)
     or(transformTimer>0)
     or(not unit_CheckActiveWeapons(pTarget))
     or(buffs[ub_SphereDDamage]>0)
     or(buffs[ub_Heroic       ]>0)
     or(uid_ismarker)then exit;

   ability_CheckTarget_SphereDDamage:=true;
end;

function ability_CheckTarget_SphereTurbo(CasterTeam:byte;pTarget:PTUnit):boolean;
begin
   ability_CheckTarget_SphereTurbo:=false;

   with pTarget^ do
   with uid^ do
   begin
      if(hits<=0)
      or(IsUnitRange(TransportU,nil))
      or(buffs[ub_Heroic     ]>0)
      or(buffs[ub_SphereTurbo]>0)
      or(player^.team<>CasterTeam)
      or(uid_ismarker)then exit;

      if not(
      (unit_CheckActiveWeapons(pTarget))or
      (uid_MSpeed_Base>0)or
      ((uid_Regen_Base>0)and(hits<UID_MaxHits1))or
      (not iscomplete   )or
      (transformTimer<=0)or
      (unit_ProdStopUpgrade(pTarget,255,true,false,true)=0)or
      (unit_ProdStopUnit   (pTarget,255,true,false,true)=0)or
      (rld>0            )
      )then exit;
   end;

   ability_CheckTarget_SphereTurbo:=true;
end;

function ability_CheckTarget_UACGeneral(CasterTeam:byte;pTarget:PTUnit):boolean;
begin
   ability_CheckTarget_UACGeneral:=false;

   with pTarget^ do
   with uid^ do
     if(hits<=0)
     or(player^.team<>CasterTeam)
     or(IsUnitRange(TransportU,nil))
     or(uid_race<>r_uac)
     or(uid_isbuilding)
     or(buffs[ub_Heroic]>0)
     or(uid_ismarker)then exit;

   ability_CheckTarget_UACGeneral:=true;
end;

function ability_CheckTarget_Bribe(CasterTeam:byte;pTarget:PTUnit;target_building:boolean):boolean;
begin
   ability_CheckTarget_Bribe:=false;

   with pTarget^ do
   with uid^ do
     if(hits<=0)
     or(not iscomplete)
     or(transformTimer>0)
     or(player^.team=CasterTeam)
     or(IsUnitRange(TransportU,nil))
     or(uid_race<>r_uac)
     or(buffs[ub_Heroic]>0)
     or(uid_isbuilding<>target_building)
     or(uid_ismarker)then exit;

   ability_CheckTarget_Bribe:=true;
end;

function ability_CheckTarget_Recall(TeleporterPlayer:byte;pTarget:PTUnit):boolean;
begin
   ability_CheckTarget_Recall:=false;

   with pTarget^ do
   with uid^ do
     if(uid_isbuilding)
     or(not iscomplete)
     or(isfly)
     or(uid_isfly)
     or(hits<=0)
     or(buffs[ub_Teleported]>0)
     or(TeleporterPlayer<>playeri)
     or(uid_ismarker)
     then exit;

   ability_CheckTarget_Recall:=true;
end;

procedure ability_UACStrike_missile(playeri:byte;fromx,fromy,tox,toy:integer);
begin
   missile_add(tox,toy,fromx,fromy,0,MID_Blizzard,playeri,uf_ground,uf_ground,false,0,dm_RSMShot);
   {$IFDEF _FULLGAME}
   effect_add(fromx,fromy-15,draw_DefaultSpriteDepth(fromy+10,false),EID_Exp2);
   snd_SoundPlayUnit(snd_bomblaunch,nil,nil);
   {$ENDIF}
end;

procedure unit_ability_spawn(pSpawner:PTUnit;tx,ty:integer;auid:byte);
begin
   with pSpawner^ do
   with player^ do
   begin
      if(not player_UIDLimitCheck(player,auid))
      then LastCreatedUnit:=0
      else
        {$IFDEF _FULLGAME}
        if(not ServerSide)
        then LastCreatedUnit:=1
        else
        {$ENDIF}
          if(unit_add(tx,ty,-1,auid,playeri,true,true,0))then
            game_ScoresAddC(playeri,psc_units_summoned);

      if(LastCreatedUnit>0)then
      begin
         {$IFDEF _FULLGAME}
         if(not ServerSide)
         then LastCreatedUnit:=0
         else
         {$ENDIF}
         begin
            LastCreatedUnitP^.dir   :=dir;
            LastCreatedUnitP^.a_tar :=a_tar;
            LastCreatedUnitP^.uo_id :=ua_amove;
            LastCreatedUnitP^.uo_tar:=uo_tar;
            LastCreatedUnitP^.uo_x  :=uo_x;
            LastCreatedUnitP^.uo_y  :=uo_y;
         end;
      end
      {$IFDEF _FULLGAME}
      else
        with g_uids[auid] do
          effect_InPoint(tx,ty,draw_DefaultSpriteDepth(ty+1,isfly),nil,uid_eid_DeathFast[0],uid_snd_DeathFast);
      {$ENDIF};
   end;
end;

////////////////////////////////////////////////////////////////////////////////

function unit_ability_HellVision(pCaster:PTUnit;target:integer;check:boolean):byte;
var pTarget:PTUnit;
begin
   // pCaster - caster
   // pTarget - target
   unit_ability_HellVision:=lmt_Invalid_Order;
   with pCaster^     do
     if(not iscomplete)
     or(transformTimer>0)
     or(hits<=0)then exit;

   unit_ability_HellVision:=0;
   if(check)then exit;

   unit_ability_HellVision:=lmt_invalid_Target;
   if(not IsUnitRange(target,@pTarget))then exit;
   if(not ability_CheckTarget_HellVision(pCaster^.player^.team,pTarget))then exit;

   unit_ability_HellVision:=0;

   pTarget^.buffs[ub_HellVision]:=hell_vision_time;
   {$IFDEF _FULLGAME}
   effect_Common(pTarget,EID_Hvision,nil);
   {$ENDIF}
end;

function unit_ability_Recall(pTeleporter:PTUnit;tar,tard:integer;check:boolean):byte;
var pTarget:PTUnit;
begin
   // pTeleporter - teleporter
   with pTeleporter^ do
   begin
      unit_ability_Recall:=lmt_Invalid_Order;

      if(not iscomplete)
      or(transformTimer>0)
      or(hits<=0)then exit;

      unit_ability_Recall:=lmt_ability_reload;
      if(rld>0)then exit;
   end;

   unit_ability_Recall:=0;
   if(check)then exit;

   unit_ability_Recall:=lmt_invalid_Target;
   if(not IsUnitRange(tar,@pTarget))then exit;
   if(not ability_CheckTarget_Recall(pTeleporter^.playeri,pTarget))then exit;

   with pTeleporter^  do
   with uid^ do
   with player^ do
   begin
      if(tard=NOTSET)
      or(tard<0     )then tard:=point_dist_int(x,y,pTarget^.x,pTarget^.y);
      if(tard>base_r1)then
      begin
         unit_ability_Recall:=0;
         unit_Teleport2Point(pTarget,x,y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_Teleport{$ENDIF});
         teleport_CalcReload(pTeleporter,pTarget^.uid^.uid_LimitUse);

         pTarget^.uo_x  :=pTarget^.x;
         pTarget^.uo_y  :=pTarget^.y;
         pTarget^.uo_tar:=0;
      end
      else unit_ability_Recall:=lmt_ability_Tar2Close;
   end;
end;

function unit_ability_teleport(pTarget,pTeleporter:PTUnit;tard:integer):boolean;
var
pTBeacon:PTUnit;
begin
   // tard = dist2(pTarget,pTeleporter)
   if(tard=NOTSET)then tard:=point_dist_int(pTarget^.x,pTarget^.y,pTeleporter^.x,pTeleporter^.y);
   unit_ability_teleport:=false;
   with pTarget^  do
   with uid^ do
   begin
      if(uid_isbuilding)
      or(not iscomplete)
      or(isfly)
      or(uid_isfly)
      or(pTeleporter^.hits<=0)
      or(not pTeleporter^.iscomplete)
      or(pTeleporter^.transformTimer>0)
      or(playeri<>pTeleporter^.playeri)
      or(uid_ismarker)
      then exit;

      if(buffs[ub_Teleported]>0)
      or(tard>pTeleporter^.uid^.uid_r)
      or(pTeleporter^.rld>0)then exit;

      if(not IsUnitRange(pTeleporter^.rpoint_tar,@pTBeacon))then exit;
      if(pTeleporter^.player^.team<>pTBeacon^.player^.team)
      or(pTBeacon^.hits<=0)then exit;

      if(isfly=uf_ground)then
        if(pTBeacon^.mapZone=zone_solid)then exit;

      pTeleporter^.rpoint_x:=pTBeacon^.x;
      pTeleporter^.rpoint_y:=pTBeacon^.y;

      if(point_dist_int(pTeleporter^.x,
                        pTeleporter^.y,pTeleporter^.rpoint_x,pTeleporter^.rpoint_y)<base_r1)then exit;

      unit_Teleport2Point(pTarget,
      pTeleporter^.rpoint_x+g_random(uid_missileR),
      pTeleporter^.rpoint_y+g_random(uid_missileR)
      {$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_Teleport{$ENDIF});
      if(pTeleporter^.player^.upgrs_cur[upgr_hell_T2TNoCD]>0)and(pTBeacon^.uidi=pTeleporter^.uidi)
      then
      else teleport_CalcReload(pTeleporter,uid_LimitUse);

      unit_ability_teleport:=true;
   end;
end;

function unit_ability_UACScan(pRadar:PTUnit;x0,y0:integer;check:boolean):byte;
var
u:integer;
scanedPlayers:byte;
tu:PTUnit;
begin
   with pRadar^ do
   begin
      unit_ability_UACScan:=lmt_Invalid_Order;
      if(hits<=0)
      or(not iscomplete)
      or(not uid^.uid_ability_isradar)
      or(transformTimer>0)then exit;

      unit_ability_UACScan:=lmt_ability_Casting;
      if(buffs[ub_Cast]>0)then exit;

      unit_ability_UACScan:=0;
      if(check)then exit;

      uo_x:=x0;
      uo_y:=y0;
      buffs[ub_Cast]:=detection_time;

      scanedPlayers:=0;
      for u:=1 to MaxUnits do
      begin
         tu:=g_punits[u];
          if(tu^.hits>0)and(tu^.player^.team<>player^.team)and(not IsUnitRange(tu^.transportU,nil))then
            if(point_dist_int(tu^.x,tu^.y,uo_x,uo_y)<=srange)then
            begin
               scanedPlayers:=scanedPlayers or (1 shl tu^.playeri);
               if(scanedPlayers=255)then break;
            end;
      end;
      GameLog_UACScan(255,scanedPlayers,uo_x,uo_y);

      {$IFDEF _FULLGAME}
      effect_ScanSound(pRadar);
      {$ENDIF}
   end;
end;

function unit_ability_SphereSoul(pCaster:PTUnit;target:integer;check:boolean):byte;
var pTarget:PTUnit;
begin
   // pCaster - caster
   // pTarget - target
   unit_ability_SphereSoul:=lmt_Invalid_Order;
   with pCaster^ do
     if(not iscomplete)
     or(transformTimer>0)
     or(hits<=0)then exit;

   unit_ability_SphereSoul:=0;
   if(check)then exit;

   unit_ability_SphereSoul:=lmt_invalid_Target;
   if(not IsUnitRange(target,@pTarget))then exit;
   if(not ability_CheckTarget_SphereSoul(pCaster^.player^.team,pTarget))then exit;
   unit_ability_SphereSoul:=0;

   with pTarget^ do buffs[ub_SphereSoul]:=soul_time;

   {$IFDEF _FULLGAME}
   effect_Common(pTarget,EID_ULevelUp,nil);
   {$ENDIF}
end;

function unit_ability_SphereInvis(pCaster:PTUnit;target:integer;check:boolean):byte;
var pTarget:PTUnit;
begin
   // pCaster - caster
   // pTarget - target
   unit_ability_SphereInvis:=lmt_Invalid_Order;
   with pCaster^ do
     if(not iscomplete)
     or(transformTimer>0)
     or(hits<=0)then exit;

   unit_ability_SphereInvis:=0;
   if(check)then exit;

   unit_ability_SphereInvis:=lmt_invalid_Target;
   if(not IsUnitRange(target,@pTarget))then exit;
   if(not ability_CheckTarget_SphereInvis(pCaster^.player^.team,pTarget))then exit;

   unit_ability_SphereInvis:=0;

   with pTarget^ do
   begin
      buffs[ub_SphereInvis ]:=invis_time;
      buffs[ub_Invisibility]:=invis_time;
   end;
   {$IFDEF _FULLGAME}
   effect_Common(pTarget,EID_ULevelUp,nil);
   {$ENDIF}
end;

function unit_ability_SphereInvuln(pCaster:PTUnit;target:integer;check:boolean):byte;
var pTarget:PTUnit;
begin
   // pCaster - caster
   // pTarget - target
   unit_ability_SphereInvuln:=lmt_Invalid_Order;
   with pCaster^ do
     if(not iscomplete)
     or(transformTimer>0)
     or(hits<=0)then exit;

   unit_ability_SphereInvuln:=0;
   if(check)then exit;

   unit_ability_SphereInvuln:=lmt_invalid_Target;
   if(not IsUnitRange(target,@pTarget))then exit;
   if(not ability_CheckTarget_SphereInvuln(pCaster^.player^.team,pTarget))then exit;

   unit_ability_SphereInvuln:=0;

   with pTarget^ do buffs[ub_SphereInvuln]:=invuln_time;
   {$IFDEF _FULLGAME}
   effect_Common(pTarget,EID_ULevelUp,nil);
   {$ENDIF}
end;


function unit_ability_SphereRDamage(pCaster:PTUnit;target:integer;check:boolean):byte;
var pTarget:PTUnit;
begin
   // pCaster - caster
   // pTarget - target
   unit_ability_SphereRDamage:=lmt_Invalid_Order;
   with pCaster^ do
     if(not iscomplete)
     or(transformTimer>0)
     or(hits<=0)then exit;

   unit_ability_SphereRDamage:=0;
   if(check)then exit;

   unit_ability_SphereRDamage:=lmt_invalid_Target;
   if(not IsUnitRange(target,@pTarget))then exit;
   if(not ability_CheckTarget_SphereRDamage(pCaster^.player^.team,pTarget))then exit;

   unit_ability_SphereRDamage:=0;

   with pTarget^ do buffs[ub_SphereRDamage]:=rdamage_time;
   {$IFDEF _FULLGAME}
   effect_Common(pTarget,EID_HLevelUp,nil);
   {$ENDIF}
end;

function unit_ability_SphereDDamage(pCaster:PTUnit;target:integer;check:boolean):byte;
var pTarget:PTUnit;
begin
   // pCaster - caster
   // pTarget - target
   unit_ability_SphereDDamage:=lmt_Invalid_Order;
   with pCaster^ do
     if(not iscomplete)
     or(transformTimer>0)
     or(hits<=0)then exit;

   unit_ability_SphereDDamage:=0;
   if(check)then exit;

   unit_ability_SphereDDamage:=lmt_invalid_Target;
   pTarget:=nil;
   if(not IsUnitRange(target,@pTarget))then exit;
   if(not ability_CheckTarget_SphereDDamage(pCaster^.player^.team,pTarget))then exit;

   unit_ability_SphereDDamage:=0;

   with pTarget^ do buffs[ub_SphereDDamage]:=ddamage_time;
   {$IFDEF _FULLGAME}
   effect_Common(pTarget,EID_HLevelUp,nil);
   {$ENDIF}
end;

function unit_ability_SphereTurbo(pCaster:PTUnit;target:integer;check:boolean):byte;
var pTarget:PTUnit;
begin
   // pCaster - caster
   // pTarget - target
   unit_ability_SphereTurbo:=lmt_Invalid_Order;
   with pCaster^ do
     if(not iscomplete)
     or(transformTimer>0)
     or(hits<=0)then exit;

   unit_ability_SphereTurbo:=0;
   if(check)then exit;

   unit_ability_SphereTurbo:=lmt_invalid_Target;
   if(not IsUnitRange(target,@pTarget))then exit;
   if(not ability_CheckTarget_SphereTurbo(pCaster^.player^.team,pTarget))then exit;
   unit_ability_SphereTurbo:=0;

   with pTarget^ do buffs[ub_SphereTurbo]:=dturbo_time;
   {$IFDEF _FULLGAME}
   effect_Common(pTarget,EID_HLevelUp,nil);
   {$ENDIF}
end;

function unit_ability_UACGeneral(pCaster:PTUnit;target:integer;check:boolean):byte;
var pTarget:PTUnit;
u,n:integer;
begin
   // pCaster - caster
   // pTarget - target
   unit_ability_UACGeneral:=lmt_Invalid_Order;
   with pCaster^ do
     if(not iscomplete)
     or(transformTimer>0)
     or(hits<=0)then exit;

   unit_ability_UACGeneral:=0;
   if(check)then exit;

   unit_ability_UACGeneral:=lmt_invalid_Target;
   if(not IsUnitRange(target,@pTarget))then exit;
   if(not ability_CheckTarget_UACGeneral(pCaster^.player^.team,pTarget))then exit;

   unit_ability_UACGeneral:=lmt_Req_MaxCount;
   n:=0;
   for u:=1 to MaxUnits do
     with g_units[u] do
       if(hits>0)and(playeri=pTarget^.playeri)and(buffs[ub_Heroic]>0)then
       begin
          n+=1;
          if(n>=UACGeneralsMax)then exit;
       end;
   unit_ability_UACGeneral:=0;

   with pTarget^ do
   begin
      buffs[ub_SphereTurbo  ]:=0;
      buffs[ub_SphereDDamage]:=0;
      buffs[ub_SphereRDamage]:=0;
      buffs[ub_Heroic       ]:=ub_infinity;
   end;
   {$IFDEF _FULLGAME}
   effect_Common(pTarget,EID_PowerUp,nil);
   {$ENDIF}
end;

function unit_ability_Bribe(pCaster:PTUnit;target:integer;target_building,check:boolean):byte;
var
pTarget: PTUnit;
u      : integer;
begin
   // pCaster - caster
   // pTarget - target
   unit_ability_Bribe:=lmt_Invalid_Order;
   with pCaster^ do
     if(not iscomplete)
     or(transformTimer>0)
     or(hits<=0)then exit;

   unit_ability_Bribe:=0;
   if(check)then exit;

   unit_ability_Bribe:=lmt_invalid_Target;
   if(not IsUnitRange(target,@pTarget))then exit;
   if(not ability_CheckTarget_Bribe(pCaster^.player^.team,pTarget,target_building))then exit;

   unit_ability_Bribe:=lmt_ability_ReqUACNear;
   for u:=1 to MaxUnits do
     with g_units[u] do
       if(hits>0)and(player^.team=pCaster^.player^.team)and(uid^.uid_race=r_uac)then
         if(point_dist_int(x,y,pTarget^.x,pTarget^.y)<=(srange+uid^.uid_r+pTarget^.uid^.uid_r))then
         begin
            unit_ability_Bribe:=0;
            break;
         end;

   if(unit_ability_Bribe>0)then exit;

   unit_ability_Bribe:=unit_TryChangeOwner(pTarget,pCaster^.player,true,false);
end;

function unit_ability_UACStrike(pu:PTUnit;x0,y0:integer;check:boolean):byte;
var p:byte;
begin
   with pu^ do
   with player^ do
   begin
      unit_ability_UACStrike:=lmt_Invalid_Order;
      if(hits<0)
      or(not iscomplete)
      or(transformTimer>0)then

      unit_ability_UACStrike:=lmt_ability_reload;
      if(rld>0)then exit;

      unit_ability_UACStrike:=lmt_ability_Casting;
      if(buffs[ub_Cast]>0)then exit;

      unit_ability_UACStrike:=0;
      if(check)then exit;

      unit_OrderClear(pu,ua_amove);
      buffs[ub_Cast]:=UACStrike_Revealing;
      for p:=0 to LastPlayer do AddToInt(@TeamVision[p],buffs[ub_Cast]);
      ability_UACStrike_missile(playeri,x,y,x0,y0);
      GameLog_UACStrike(playeri,x,y,x0,y0);
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

function unit_ability_SpawnLost(pCaster:PTUnit;check:boolean):byte;
begin
   with pCaster^ do
   with uid^ do
   begin
      unit_ability_SpawnLost:=lmt_Invalid_Order;
      if(hits<=0)
      or(transformTimer>0)
      or(not iscomplete)then exit;

      unit_ability_SpawnLost:=lmt_ability_reload;
      if(rld>0)then exit;

      unit_ability_SpawnLost:=lmt_ability_Casting;
      if(buffs[ub_Cast]>0)then exit;

      unit_ability_SpawnLost:=0;
      if(check)then exit;

      case player^.upgrs_cur[upgr_hell_Phantoms]>0 of
      false: unit_ArmSpawnUnit(pCaster,UID_LostSoul);
      true : unit_ArmSpawnUnit(pCaster,UID_Phantom );
      end;
      rld:=uid_arms[0].aw_reload;
      buffs[ub_Cast]:=rld div 2;
   end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure math_1c_push(tx,ty:pinteger;x0,y0,r0:integer);
var vx,vy,a:single;
begin
   vx :=x0-tx^;
   vy :=y0-ty^;
   if(vx=0)and(vy=0)then exit;
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

procedure math_push_out(tx,ty,tr,ignore_unum:integer;newx,newy:pinteger;check_obstacles:boolean;VisionPlayer:byte=255);
const pout_max = 1;
var
pout_x,
pout_y,
pout_d,
pout_t    : array[0..pout_max] of integer;
pin_x,
pin_y,
pin_d,
dx,dy,
dx0,dy0,
dx1,dy1,
o,u,d     : integer;
VisionTeam: byte;
{$IFDEF _FULLGAME}
a       : byte;
{$ENDIF}
procedure POutAdd(ax,ay,ad,at:integer);
var i,n:integer;
begin
   // find insert i
   i:=0;
   while(i<=pout_max)do
   begin
      if(ad<pout_d[i])then break;
      i+=1;
   end;

   if(i>pout_max)then exit;

   if(i<>pout_max)then
     for n:=pout_max-1 downto i do
     begin
        pout_d[i+1]:=pout_d[i];
        pout_x[i+1]:=pout_x[i];
        pout_y[i+1]:=pout_y[i];
        pout_t[i+1]:=pout_t[i];
     end;

   pout_d[i]:=ad;
   pout_x[i]:=ax;
   pout_y[i]:=ay;
   pout_t[i]:=at;
end;
procedure PInAdd(ax,ay,ad:integer);
begin
   if(ad>=pin_d)then exit;

   pin_x:=ax;
   pin_y:=ay;
   pin_d:=ad;
end;
begin
   for u:=0 to pout_max do
   begin
      pout_d[u]:= NOTSET;
      pout_x[u]:=-2000;
      pout_y[u]:=-2000;
      pout_t[u]:=0;
   end;
   pin_x:=0;
   pin_y:=0;
   pin_d:=pin_d.MaxValue;

   VisionTeam:=255;
   if(VisionPlayer<MaxPlayers)then
     VisionTeam:=g_PlayersGame[VisionPlayer].team;

   if(check_obstacles)then
   begin
      dx0:=(tx-tr) div MapObstaclesGridW;
      dy0:=(ty-tr) div MapObstaclesGridW;
      dx1:=(tx+tr) div MapObstaclesGridW;
      dy1:=(ty+tr) div MapObstaclesGridW;
      for dx:=dx0 to dx1 do
      for dy:=dy0 to dy1 do
        if (0<=dx)and(dx<=MapObstaclesGridN)
        and(0<=dy)and(dy<=MapObstaclesGridN)then
          with map_ObstaclesGrid[dx,dy] do
            if(oc_n>0)then
              for u:=0 to oc_n-1 do
                with oc_l[u]^ do
                  if(o_rO>0)then
                  begin
                     o:=tr+o_rO;
                     d:=point_dist_int(o_x,o_y,tx,ty);
                     if(o_rI<=0)
                     or(o_rM<=d)then POutAdd(o_x,o_y,d-o,o);
                     if (o_rI>0)
                     and(o_rI<(d+tr))
                     and(o_rM>d)then PInAdd(o_x,o_y,o_rI-tr);
                  end;
   end;

   for u:=0 to LastKeyPoint do
     with map_KeyPointsL[u] do
     with kp_TeamData[min2i(VisionTeam,MaxPlayers)] do
       if(kptd_Active)and(kp_RNoBuild>0)then
       begin
          o:=kp_RNoBuild+tr;
          d:=point_dist_int(kp_x,kp_y,tx,ty)-o;
          POutAdd(kp_x,kp_y,d,o);
       end;

   for u:=1 to MaxUnits do
     with g_units[u] do
     with uid^ do
       if(hits>0)and(isfly=uid_isfly)and(unum<>ignore_unum)then
         if(speed<=0)or(not iscomplete)or(transformTimer>0)then
           if(not IsUnitRange(transportU,nil))then
           begin
              if(VisionTeam<=LastPlayer)then
                if(TeamVision[VisionTeam]<=0)then continue;

              o:=tr+uid_r+1;
              d:=point_dist_int(x,y,tx,ty);
              POutAdd(x,y,d-o,o);
           end;

   {$IFDEF _FULLGAME}
   for u:=1 to MaxUnits do
     with g_units[u] do
     with uid^ do
       if(hits>0)and(unum<>ignore_unum)and(iscomplete)and(transformTimer<=0)and(VisionPlayer=playeri)then
         if(not IsUnitRange(transportU,nil))then
           case uo_id of
           ua_ability1,
           ua_ability2,
           ua_ability3: begin
                           a:=unit_GetCastingAbility(g_punits[u]);
                           if(a>0)then
                             with g_aids[a] do
                               case ua_type of
                               uat_point    : begin
                                                 o:=ui_AbilityGetBrushR(a,g_punits[u]);
                                                 if(o>0)then
                                                 begin
                                                    o+=tr;
                                                    d:=point_dist_int(uo_x,uo_y,tx,ty);
                                                    POutAdd(uo_x,uo_y,d-o,o);
                                                 end;
                                              end;
                               end;
                        end;
           end;
   {$ENDIF}

   if(pout_d[1]<=-1)
   then math_2c_push(@tx,@ty,pout_x[0],pout_y[0],pout_t[0],pout_x[1],pout_y[1],pout_t[1])
   else
     if(pout_d[0]<=-1)
     then math_2c_push(@tx,@ty,pout_x[0],pout_y[0],pout_t[0],NOTSET,NOTSET,NOTSET)
     else
       if(pin_d<>NOTSET)then
         math_1c_push(@tx,@ty,pin_x,pin_y,pin_d);

   dx:=tr;
   dy:=map_Size1-dx;
   tx:=mm3i(dx,tx,dy);
   ty:=mm3i(dx,ty,dy);

   newx^:=tx;
   newy^:=ty;
end;


procedure BuildingFindNewPlace(tx,ty:integer;buid,pl:byte;newx,newy:pinteger);
var
dx,dy,o,
u,sr,dr :integer;
begin
   with g_uids[buid] do
   begin
      math_push_out(tx,ty,uid_r,0,@tx,@ty,true,pl);
   end;

   dx:=-2000;
   dy:=-2000;
   sr:=NOTSET;
   dr:=NOTSET;
   for u:=1 to MaxUnits do
     with g_units[u] do
       with uid^ do
         if (hits>0)
         and(speed<=0)
         and(not isfly)
         and(iscomplete)
         and(playeri=pl)
         and(uid_isbuilder)
         and(not isfly)
         and(zfall=0)then
           //if(player^.units_builders_s=0)or(isselected)then
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
      dy:=map_Size1-dx;
      tx:=mm3i(dx,tx,dy);
      ty:=mm3i(dx,ty,dy);
   end;
   newx^:=tx;
   newy^:=ty;
end;

function CheckCollisionR(tx,ty,tr,skipunit:integer;building,check_obstacles:boolean;checkTeamVisUI:byte;reveal_u:PTUnit=nil):TCheckCollisionR;
var u,
dx,dy,
dx0,dy0,
dx1,dy1:integer;
begin
   CheckCollisionR:=cbr_no;

   if(building)then
     if(tx<tr)or((map_Size1-tr)<tx)
     or(ty<tr)or((map_Size1-tr)<ty)then
     begin
        CheckCollisionR:=cbr_mapSide;  // out of map bounds
        exit;
     end;

   for u:=1 to MaxUnits do
     if(u<>skipunit)then
       with g_punits[u]^ do
         with uid^ do
           if(hits>0)and(not isfly)and(not IsUnitRange(transportU,nil))then
           begin
              if(checkTeamVisUI<=LastPlayer)then
                if(TeamVision[checkTeamVisUI]<=0)then continue;
              if(speed<=0)or(not iscomplete)or(transformTimer>0)or(uid_isbuilding)then
                if(point_dist_int(x,y,tx,ty)<(tr+uid_r))then
                begin
                   CheckCollisionR:=cbr_unit;
                   if(reveal_u<>nil)then
                   begin
                      AddToInt(@TeamVision   [reveal_u^.player^.team],MinVisionTime);
                      AddToInt(@TeamDetection[reveal_u^.player^.team],MinVisionTime);
                      AddToInt(@reveal_u^.TeamVision   [player^.team],MinVisionTime);
                      AddToInt(@reveal_u^.TeamDetection[player^.team],MinVisionTime);
                   end;
                   exit;
                end;
           end;

   if(building)then
     for u:=0 to LastKeyPoint do
       with map_KeyPointsL[u] do
       with kp_TeamData[min2i(checkTeamVisUI,MaxPlayers)] do
         if(kptd_Active)and(kp_RNoBuild>0)then
           if(point_dist_int(tx,ty,kp_x,kp_y)<(kp_RNoBuild+tr))then
           begin
              CheckCollisionR:=cbr_cpoint;
              exit;
           end;

   if(not check_obstacles)then exit;

   dx0:=(tx-tr) div MapObstaclesGridW;
   dy0:=(ty-tr) div MapObstaclesGridW;
   dx1:=(tx+tr) div MapObstaclesGridW;
   dy1:=(ty+tr) div MapObstaclesGridW;

   for dx:=dx0 to dx1 do
   for dy:=dy0 to dy1 do
     if (0<=dx)and(dx<=MapObstaclesGridN)
     and(0<=dy)and(dy<=MapObstaclesGridN)then
       with map_ObstaclesGrid[dx,dy] do
         if(oc_n>0)then
           for u:=0 to oc_n-1 do
             with oc_l[u]^ do
               if(o_rO>0)then
                 if(RingCollision(o_x,o_y,o_rO,o_rI,tx,ty,tr-1,0))then
                 begin
                    CheckCollisionR:=cbr_obstacle;
                    exit;
                 end;
end;

function CheckInBuildArea(tx,ty,tr:integer;buid,playerN:byte):TCheckBuildArea;
var u:integer;
 zone:word;
begin
   if(playerN<=LastPlayer)then
     with g_PlayersGame[playerN] do
       if(units_builders_e<=0)then
       begin
          CheckInBuildArea:=cba_noBuilders; // no builders
          exit;
       end;

   with g_uids[buid] do
     if(tx<uid_r)or((map_Size1-uid_r)<tx)
     or(ty<uid_r)or((map_Size1-uid_r)<ty)then
     begin
        CheckInBuildArea:=cba_outBuildArea;  // out of bounds
        exit;
     end;

   for u:=0 to LastKeyPoint do
     with map_KeyPointsL[u] do
     with kp_TeamData[KeyPoint_GetPlayerTeam(playerN)] do
       if(kptd_Active)and(kp_RNoBuild>0)then
         if(point_dist_int(tx,ty,kp_x,kp_y)<kp_RNoBuild)then
         begin
            CheckInBuildArea:=cba_NoBuildArea;
            exit;
         end;

   tr+=g_uids[buid].uid_r;

   CheckInBuildArea:=cba_outBuildArea;
   zone:=map_GetZone(tx,ty);

   for u:=1 to MaxUnits do
     with g_punits[u]^ do
     with uid^ do
       if(hits>0)and(iscomplete)and(uid_isbuilder)and(zfall=0)and(not isfly)and(playeri=playerN)then
         if(mapZone=zone)or(player^.state<>ps_AI)then
           //if(player^.units_builders_s=0)or(isselected)then
             if(abs(x-tx)<=srange)and(abs(y-ty)<=srange)then
               if(buid in uid_prod_Buildings)and(not IsUnitRange(transportU,nil))then
                 if(point_dist_int(x,y,tx,ty)<srange)then
                 begin
                    CheckInBuildArea:=cba_inBuildArea; // inside build area
                    break;
                 end;
end;

function CheckBuildPlace(tx,ty,tr,skip_unit:integer;playern,buid:byte):TCheckBuildPlace;
begin
   CheckBuildPlace:=cbp_good;
   {
   cbp_good   : m_brushc:=c_lime;
   cbp_noplace: m_brushc:=c_red;
   cbp_out    : m_brushc:=c_blue;
   else         m_brushc:=c_gray;
   }
   case CheckInBuildArea(tx,ty,0,buid,playern) of
cba_inBuildArea : with g_uids[buid] do
                    if(CheckCollisionR(tx,ty,tr+uid_r,skip_unit,uid_isbuilding,true,255)<>cbr_no)then
                      CheckBuildPlace:=cbp_noplace;
cba_NoBuildArea : CheckBuildPlace:=cbp_noplace;
cba_outBuildArea: CheckBuildPlace:=cbp_out;
   else           CheckBuildPlace:=cbp_unknown;
   end;
end;

function unit_ability_HKeepBlink(pu:PTUnit;x0,y0:integer;check:boolean):byte;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      unit_ability_HKeepBlink:=lmt_Invalid_Order;
      if(hits<=0)
      or(transformTimer>0)
      or(not iscomplete)
      or(buffs[ub_Cast]>0)then exit;

      unit_ability_HKeepBlink:=0;
      if(check)then exit;

      math_push_out(x0,y0,uid_r,unum,@x0,@y0,true,playeri );
      x0:=mm3i(1,x0,map_Size1);
      y0:=mm3i(1,y0,map_Size1);

      if(CheckCollisionR(x0,y0,uid_r,unum,uid_isbuilding,true,255,pu)<>cbr_no)then
      begin
         unit_ability_HKeepBlink:=lmt_ability_BadPlace;
         exit;
      end;

      buffs[ub_Cast]:=fr_fps1;

      case uidi of
      UID_HKeep : unit_Teleport2Point(pu,x0,y0{$IFDEF _FULLGAME},EID_HKeep_H ,EID_HKeep_S ,snd_IconOfSinCube{$ENDIF});
      UID_HAKeep: unit_Teleport2Point(pu,x0,y0{$IFDEF _FULLGAME},EID_HAKeep_H,EID_HAKeep_S,snd_IconOfSinCube{$ENDIF});
      end;
   end;
end;

function unit_ability_HTowerBlink(pCaster:PTUnit;x0,y0:integer;check:boolean):byte;
begin
   with pCaster^ do
   with uid^ do
   with player^ do
   begin
      unit_ability_HTowerBlink:=lmt_Invalid_Order;
      if(hits<=0)
      or(transformTimer>0)
      or(not iscomplete)then exit;

      unit_ability_HTowerBlink:=lmt_ability_reload;
      if(rld>0)then exit;

      if(srange<point_dist_int(x,y,x0,y0))then math_1c_push(@x0,@y0,x,y,srange-1);
      math_push_out(x0,y0,uid_r,unum,@x0,@y0,true ,playeri );
      x0:=mm3i(1,x0,map_Size1);
      y0:=mm3i(1,y0,map_Size1);

      unit_ability_HTowerBlink:=lmt_ability_BadPlace;
      if(point_dist_int(x,y,x0,y0)>srange)then exit;

      unit_ability_HTowerBlink:=0;
      if(check)then exit;

      if(CheckCollisionR(x0,y0,uid_r,unum,uid_isbuilding,true,255,pCaster )<>cbr_no)then
      begin
         unit_ability_HTowerBlink:=lmt_ability_BadPlace;
         exit;
      end;

      unit_Teleport2Point(pCaster,x0,y0{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_Teleport{$ENDIF});
   end;
end;

function unit_ability_SpawnEvilEye(pCaster:PTUnit;tx,ty:integer;check:boolean):byte;
const SpawnUID = UID_HEye;
var u:integer;
begin
   // pCaster - caster
   // pTarget - target
   with pCaster^     do
   begin
      unit_ability_SpawnEvilEye:=lmt_Invalid_Order;
      if(not iscomplete)
      or(transformTimer>0)
      or(hits<=0)then exit;

      unit_ability_SpawnEvilEye:=lmt_Req_Limit;
      with player^ do
        if((armylimit+g_uids[SpawnUID].uid_LimitUse+prod_unit_Limit)>MaxPlayerLimit)then exit;

      unit_ability_SpawnEvilEye:=0;
      if(check)then exit;

      unit_ability_SpawnEvilEye:=lmt_Invalid_Order;

      math_push_out(tx,ty,g_uids[SpawnUID].uid_r,0,@tx,@ty,true,playeri);
      tx:=mm3i(1,tx,map_Size1);
      ty:=mm3i(1,ty,map_Size1);

      with g_uids[SpawnUID] do
        if(CheckCollisionR(tx,ty,uid_r,0,uid_isbuilding,true,255,pCaster)<>cbr_no)then
        begin
           unit_ability_SpawnEvilEye:=lmt_ability_BadPlace;
           exit;
        end;
   end;

   unit_ability_SpawnEvilEye:=lmt_ability_ReqHelNear;
   for u:=1 to MaxUnits do
     with g_units[u] do
       if(hits>0)and(player^.team=pCaster^.player^.team)and(uid^.uid_race=r_hell)then
         if(point_dist_int(x,y,tx,ty)<=srange)then
         begin
            unit_ability_SpawnEvilEye:=0;
            break;
         end;
   if(unit_ability_SpawnEvilEye>0)then exit;

   unit_ability_SpawnEvilEye:=0;
   if(unit_add(tx,ty,0,SpawnUID,pCaster^.playeri,true,true,0))then
     if(g_uids[SpawnUID].uid_isbuilding)
     then game_ScoresAddC(pCaster^.playeri,psc_builds_summoned)
     else game_ScoresAddC(pCaster^.playeri,psc_units_summoned );
end;

////////////////////////////////////////////////////////////////////////////////

procedure unit_SetDefaults(pu:PTUnit;Client:boolean);
begin
   with pu^ do
   begin
      if(not Client)then
      begin
         transportU:= 0;
         a_tar     := 0;
         a_weap    := 0;
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

      transformTimer:=0;
      transformUID  :=0;

      aiu_BuildAttempts:=0;
      aiu_alarm_timer  :=0;
      aiu_alarm_d      :=NOTSET;
      aiu_alarm_x      :=-1;
      aiu_alarm_y      :=0;
      aiu_NeedDetect   :=NOTSET;
      aiu_limitaround_ally :=0;
      aiu_limitaround_enemy:=0;

      FillChar(uprod_r,SizeOf(uprod_r),0);
      FillChar(pprod_r,SizeOf(pprod_r),0);
      FillChar(pprod_e,SizeOf(pprod_e),0);
      FillChar(uprod_u,SizeOf(uprod_u),0);
      FillChar(pprod_u,SizeOf(pprod_u),0);

      {$IFDEF _FULLGAME}
      with g_unitsVis[unum] do
      begin
         wanim    := false;
         anim     := 0;
      end;
      unit_UpdateMiniMapXY(pu);
      unit_UpdateFogXY(pu);
      {$ENDIF}
   end;
end;

procedure unit_IncCounters_Prod(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(uid_isbuilder)then units_builders_c+=1;
      if(uid_isbarrack)then
      begin
         units_unitProds_c+=1;
         prod_unit_Max+=level+1;
      end;
      if(uid_isforge  )then
      begin
         units_upgrProds_c+=1;
         prod_upgr_Max+=level+1;
      end;
   end;
end;
procedure unit_DecCounters_Prod(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(uid_isbuilder)then units_builders_c-=1;
      if(uid_isbarrack)then
      begin
         units_unitProds_c-=1;
         prod_unit_Max-=level+1;
      end;
      if(uid_isforge  )then
      begin
         units_upgrProds_c-=1;
         prod_upgr_Max-=level+1;
      end;
   end;
end;

procedure unit_IncCounters_Complete(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(units_uid_u[uidi                    ]<=0)then units_uid_u[uidi                    ]:=unum;
      if(units_ucl_u[uid_isbuilding,uid_uibtn]<=0)then units_ucl_u[uid_isbuilding,uid_uibtn]:=unum;
      units_ucl_c[uid_isbuilding,uid_uibtn]+=1;
      units_uid_c[uidi                    ]+=1;
      units_bld_lc[uid_isbuilding         ]+=uid_LimitUse;
      units_all_c+=1;
      res_energyl_max +=uid_gen_EnergyLevel;
      res_energyl_cur +=uid_gen_EnergyLevel;
      unit_IncCounters_Prod(pu);
   end;
end;

procedure unit_IncCounters(pu:PTUnit;ucomplete,usummoned:boolean);
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      units_all_e+=1;
      armylimit+=uid_LimitUse;
      units_ucl_e[uid_isbuilding,uid_uibtn]+=1;
      units_bld_e[uid_isbuilding          ]+=1;
      units_bld_l[uid_isbuilding          ]+=uid_LimitUse;
      units_uid_e[uidi                    ]+=1;
      if(uid_isbuilder)then units_builders_e+=1;

      iscomplete:=ucomplete;

      if(iscomplete)
      then unit_IncCounters_Complete(pu)
      else
      begin
         hits  := 1;
         if(uid_gen_EnergyLevel>0)
         then energyCur_BldGens +=uid_req_EnergyLevel
         else energyCur_BldOther+=uid_req_EnergyLevel;
         res_energyl_cur -=uid_req_EnergyLevel;
         res_HellPower   -=uid_req_HellPower;
         res_UACLoot     -=uid_req_UACLoot;
         {$IFDEF _FULLGAME}
         if(playeri=UIPlayer)then snd_SoundPlayAnoncer(snd_build_place[uid_race],false,false);
         {$ENDIF}
      end;

      //g_PlayersScore

      if(usummoned)and(iscomplete)then
      begin
         buffs[ub_Summoned]:=fr_fps1;
         {$IFDEF _FULLGAME}
         effect_UnitSummon(LastCreatedUnitP,nil);
         {$ENDIF}
      end;
   end;
end;

function player_FindNotExistedUnit(playerN:byte):integer;
var i,m:integer;
begin
   player_FindNotExistedUnit:=0;
   if(playerN>LastPlayer)then exit;
   i:=MaxPlayerUnits*playerN+1;
   m:=i+MaxPlayerUnits;
   while(i<m)do
   begin
      with g_units[i] do
        if(hits<=hits_dead)then
        begin
           player_FindNotExistedUnit :=i;
           break;
        end;
      i+=1;
   end;
end;

procedure player_UpgradeFromPlayer(toPlayer,fromPlayer,upgr:byte;x,y:integer);
var pstate:byte;
begin
   with g_PlayersGame[toPlayer] do
   begin
      pstate:=upgrs_cur[upgr];
      upgrs_cur[upgr]:=max2b(upgrs_cur[upgr],g_PlayersGame[fromPlayer].upgrs_cur[upgr]);
      if(pstate<upgrs_cur[upgr])then GameLog_UpgradeComplete(toPlayer,upgr,x,y);
   end;
end;

function unit_TryChangeOwner(pTarget:PTUnit;newOwner:PTPlayerGameData;log,check:boolean):byte;
var
newPos:integer;
old_u :TUnit;
{$IFDEF _FULLGAME}
old_uv:TUnitVis;
{$ENDIF}
begin
   with pTarget^ do
   with uid^ do
   with newOwner^ do
   begin
      unit_TryChangeOwner:=lmt_Req_Limit;
      if((armylimit+uid_LimitUse+prod_unit_Limit)>MaxPlayerLimit)then exit;
      if(uid_isbuilder)and(units_builders_e>=PlayerMaxBuilders)then exit;

      newPos:=player_FindNotExistedUnit(pnum);
      if(newPos=0)then exit;
   end;

   unit_TryChangeOwner:=0;
   if(check)then exit;

   if(log)then GameLog_UnitLost(pTarget);

   old_u :=pTarget^;
   {$IFDEF _FULLGAME}
   old_uv:=g_unitsVis[pTarget^.unum];
   {$ENDIF}
   unit_kill(pTarget,true,false,false,true,false);

   g_units   [newPos]:=old_u;
   {$IFDEF _FULLGAME}
   g_unitsVis[newPos]:=old_uv;
   {$ENDIF}
   with g_units[newPos] do
   begin
      unum       :=newPos;
      cycle_order:=unum mod order_period;
      playeri    :=newOwner^.pnum;
      player     :=newOwner;
      isselected :=false;

      unit_TeamReveal (g_punits[newPos],true);
      unit_IncCounters(g_punits[newPos],iscomplete,false);

      with player^ do
      begin
         if(UIDHaveAbility(old_u.uidi,uab_UACCCLand  ))
         or(UIDHaveAbility(old_u.uidi,uab_UACCCLandTo))then player_UpgradeFromPlayer(playeri,old_u.playeri,g_aids[uab_UACCCLandTo].ua_req_upgr,x,y);
         if(old_u.uidi=UID_UTransport)then player_UpgradeFromPlayer(playeri,old_u.playeri,g_uids[old_u.uidi].uid_TransportMax_upgr,x,y);
      end;
   end;
   if(log)then
   begin
      GameLog_UnitCaptured(g_punits[newPos]);
      {$IFDEF _FULLGAME}
      effect_Common(g_punits[newPos],EID_UnitCaptured,nil);
      {$ENDIF}
   end;
end;

function unit_add(Ux,Uy,Uunum:integer;Uuid,UplayerN:byte;Ucomplete,Usummoned:boolean;Ulevel:byte;altMode:boolean=false):boolean;
procedure FindNotExistedUnit;
var u:integer;
begin
   u:=player_FindNotExistedUnit(UplayerN);
   if(u>0)then
   begin
      LastCreatedUnit :=u;
      LastCreatedUnitP:=g_punits[LastCreatedUnit];
   end;
end;
begin
   unit_add:=false;
   LastCreatedUnit :=0;
   LastCreatedUnitP:=g_punits[0];
   with g_PlayersGame[UplayerN] do
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
            unum       := LastCreatedUnit;
            cycle_order:= unum mod order_period;

            unit_SetXY(LastCreatedUnitP,Ux,Uy,mvxy_strict);
            uidi       := Uuid;
            playeri    := UplayerN;
            player     :=@g_PlayersGame[playeri];
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
            unit_IncCounters(LastCreatedUnitP,Ucomplete,Usummoned);
            unit_UpdateXY   (LastCreatedUnitP);

            if(altMode)then buffs[ub_altMode]:=ub_infinity;
         end;
      end;
   end;
end;

function unit_start_build(bx,by:integer;buid,bplayer:byte;skipReqCheck:boolean=false):byte;
begin
   if(skipReqCheck)
   then unit_start_build:=0
   else unit_start_build:=unit_CheckReqs(@g_PlayersGame[bplayer],buid);
   if(unit_start_build=0)then
     with g_PlayersGame[bplayer] do
       if(CheckBuildPlace(bx,by,0,0,bplayer,buid)=cbp_good)then
       begin
          if(not unit_add(bx,by,-1,buid,bplayer,false,false,0))then unit_start_build:=lmt_Invalid_Order;
       end
       else unit_start_build:=lmt_prod_BadPlace;
end;

function barrack_out_r(pu:PTUnit;_uid:byte):integer;
begin
   if(g_uids[_uid].uid_isfly=uf_fly)
   then barrack_out_r:=0
   else barrack_out_r:=pu^.uid^.uid_r;
end;

function barrack_out(pBarrack:PTUnit;_uid:byte;_sstep,_dir:integer):boolean;
var
cd    :single;
begin
   barrack_out:=false;
   with pBarrack^ do
   with uid^ do
   with player^ do
   begin
      cd:=_dir*degtorad;

      if(_sstep<0)
      then _sstep:=barrack_out_r(pBarrack,_uid);

      if(_sstep=0)
      then unit_add(x,y,-1,_uid,playeri,true,false,0)
      else unit_add(x+trunc(_sstep*cos(cd)),
                    y-trunc(_sstep*sin(cd)),-1,_uid,playeri,true,false,0);

      if(LastCreatedUnit>0)then
      begin
         game_ScoresAddC(playeri,psc_units_created);

         LastCreatedUnitP^.uo_x  :=rpoint_x;
         LastCreatedUnitP^.uo_y  :=rpoint_y;
         LastCreatedUnitP^.uo_tar:=rpoint_tar;
         LastCreatedUnitP^.uo_id :=ua_amove;
         LastCreatedUnitP^.dir   :=_dir;

         if(uid_OutUnitsTeleBuff)then
         begin
            LastCreatedUnitP^.buffs[ub_Teleported]:=fr_fps1;
            {$IFDEF _FULLGAME}
            if(snd_SoundPlayUnit(snd_Teleport,pBarrack,nil))
            then effect_add(LastCreatedUnitP^.vx,
                            LastCreatedUnitP^.vy,draw_DefaultSpriteDepth(LastCreatedUnitP^.vy+1,LastCreatedUnitP^.isfly),EID_Teleport);
            {$ENDIF}
         end;
         barrack_out:=true;
      end;
   end;
end;

procedure barrack_spawn(pu:PTUnit;_uid:byte);
var
sstep    :integer;
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

      announcer:=barrack_out(pu,_uid,sstep,dir) or announcer;

      if(announcer)
      then GameLog_UnitReady(LastCreatedUnitP);
   end;
end;

//////   Start unit prod
//
function unit_ProdStartUnitLine(uBarrack:PTUnit;puid,pn:byte;check:boolean):byte;
begin
   unit_ProdStartUnitLine:=0;
   if(pn>LastUnitLevel)
   then unit_ProdStartUnitLine:=lmt_Invalid_Order
   else
     with uBarrack^ do
     with uid^ do
     with player^ do
     begin
        unit_ProdStartUnitLine:=unit_CheckReqs(player,puid);
        if(unit_ProdStartUnitLine=0)then
          if(uprod_r[pn]>0)
          then unit_ProdStartUnitLine:=lmt_prod_AllBusy
          else
            with g_upgrs[puid] do
            begin
               if(check)then exit;

               prod_unit_Now+=1;
               prod_unit_Limit+=g_uids[puid].uid_LimitUse;
               prod_unit_ucl[g_uids[puid].uid_uibtn]+=1;
               prod_unit_uid[puid                  ]+=1;
               energyCur_units+=g_uids[puid].uid_req_EnergyLevel;
               res_energyl_cur-=g_uids[puid].uid_req_EnergyLevel;
               res_HellPower  -=g_uids[puid].uid_req_HellPower;
               res_UACLoot    -=g_uids[puid].uid_req_UACLoot;
               uprod_u[pn]:=puid;
               uprod_r[pn]:=g_uids[puid].uid_ProdTimeTick;
            end;
     end;
end;
function unit_ProdStartUnit(uBarrack:PTUnit;puid:byte;check:boolean):byte;  // main function
var pn:byte;
begin
   with uBarrack^ do
   with uid^ do
   begin
      unit_ProdStartUnit:=lmt_Invalid_Order;
      if(puid=255)
      or(puid=0  )
      or(hits<=0)
      or(not iscomplete)
      or(transformTimer>0)
      or(not uid_isbarrack)
      or(not uid_isbuilding)then exit;

      unit_ProdStartUnit:=lmt_unit_NeedProdUnit;
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
function unit_ProdStopUnitLine(uBarrack:PTUnit;puid,pn:byte;canceled,check:boolean):byte;
begin
   unit_ProdStopUnitLine:=lmt_Invalid_Order;
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
              prod_unit_ucl[g_uids[puid].uid_uibtn]-=1;
              prod_unit_uid[puid                  ]-=1;
              energyCur_units-=g_uids[puid].uid_req_EnergyLevel;
              res_energyl_cur+=g_uids[puid].uid_req_EnergyLevel;
              if(canceled)then
              begin
              res_HellPower  +=g_uids[puid].uid_req_HellPower;
              res_UACLoot    +=g_uids[puid].uid_req_UACLoot;
              end;
              uprod_r[pn]:=0;
           end;
end;
function unit_ProdStopUnit(uBarrack:PTUnit;puid:byte;all,canceled,check:boolean):byte;
var pn:byte;
begin
   with uBarrack^ do
   with uid^ do
   begin
      unit_ProdStopUnit:=lmt_Invalid_Order;
      if(puid=0 )
      or(hits<=0)
      or(not iscomplete)
      or(transformTimer>0)
      or(not uid_isbarrack)
      or(not uid_isbuilding)then exit;
   end;

   for pn:=LastUnitLevel downto 0 do
   begin
      unit_ProdStopUnit:=unit_ProdStopUnitLine(uBarrack,puid,pn,canceled,check);
      if(unit_ProdStopUnit>0)then continue;
      if(not all)or(check)then break;
   end;
end;


//////   Start upgrade production
//
function unit_ProdStartUpgradeLine(uForge:PTUnit;upid,pn:byte;check:boolean):byte;
begin
   unit_ProdStartUpgradeLine:=0;
   if(pn>LastUnitLevel)
   then unit_ProdStartUpgradeLine:=lmt_Invalid_Order
   else
     with uForge^ do
     with uid^ do
     with player^ do
     begin
        unit_ProdStartUpgradeLine:=upgrade_CheckReqs(player,upid);
        if(unit_ProdStartUpgradeLine=0)then
          if(pprod_r[pn]>0)
          then unit_ProdStartUpgradeLine:=lmt_prod_AllBusy
          else

            with g_upgrs[upid] do
            begin
               if(check)then exit;

               prod_upgr_Now+=1;
               prod_upgr_upid[upid]+=1;
               pprod_e[pn]:=upgrade_GetEnergy(upid,upgrs_cur[upid]+1);
               energyCur_upgrades+=pprod_e[pn];
               res_energyl_cur   -=pprod_e[pn];
               pprod_r[pn]:=upgrade_GetTime(upid,upgrs_cur[upid]+1);
               pprod_u[pn]:=upid;
            end;
     end;
end;
function unit_ProdStartUpgrade(uForge:PTUnit;upid:integer;check:boolean):byte;
var pn:byte;
begin
   with uForge^ do
   with uid^ do
   begin
      unit_ProdStartUpgrade:=lmt_Invalid_Order;
      if(upid=255)
      or(upid=0  )
      or(hits<=0)
      or(not iscomplete)
      or(transformTimer>0)
      or(not uid_isforge)
      or(not uid_isbuilding)then exit;

      unit_ProdStartUpgrade:=lmt_unit_NeedProdUnit;
      if not(upid in uid_prod_Upgrades)
      then exit;
   end;

   for pn:=0 to LastUnitLevel do
   begin
      if(pn>uForge^.level)then break;
      unit_ProdStartUpgrade:=unit_ProdStartUpgradeLine(uForge,upid,pn,check);
      if(unit_ProdStartUpgrade=0)then break;
   end;
end;
function unit_ProdStopUpgradeLine(uForge:PTUnit;upid:byte;pn:integer;check:boolean):byte;
begin
   unit_ProdStopUpgradeLine:=lmt_Invalid_Order;
   with uForge^ do
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
              energyCur_upgrades-=pprod_e[pn];
              res_energyl_cur   +=pprod_e[pn];
              pprod_r[pn]:=0;
           end;
end;
function unit_ProdStopUpgrade(uForge:PTUnit;upid:byte;all,canceled,check:boolean):byte;
var pn:byte;
begin
   with uForge^ do
   with uid^ do
   begin
      unit_ProdStopUpgrade:=lmt_Invalid_Order;
      if(upid=0 )
      or(hits<=0)
      or(not iscomplete)
      or(transformTimer>0)
      or(not uid_isforge)
      or(not uid_isbuilding)then exit;
   end;

   for pn:=LastUnitLevel downto 0 do
   begin
      unit_ProdStopUpgrade:=unit_ProdStopUpgradeLine(uForge,upid,pn,check);
      if(unit_ProdStopUpgrade>0)then continue;
      if(not all)or(check)then break;
   end;
end;

function unit_TransformStart(pu:PTUnit;tarUID:byte;check:boolean;halfTime:boolean=false):byte;
var ptarUID:PTUID;
begin
   with pu^ do
   with player^ do
   begin
      unit_TransformStart:=lmt_Invalid_Order;
      if(hits<=0)
      or(not iscomplete)
      or(transformTimer>0)
      or(isfly<>uid^.uid_isfly)then exit;

      ptarUID:=@g_uids[tarUID];
      if(ptarUID^.uid_ProdTimeTick<=0)then exit;

      if(tarUID=uidi)then
        if(level>=LastUnitLevel)then
        begin
           unit_TransformStart:=lmt_unit_MaxLevel;
           exit;
        end;

      if(units_uid_m[tarUID]<=0)then
      begin
         unit_TransformStart:=lmt_prod_Unavailable;
         exit;
      end;
      if(units_uid_e[tarUID]>=units_uid_m[tarUID])then
      begin
         unit_TransformStart:=lmt_Req_MaxCount;
         exit;
      end;

      if(res_HellPower  <ptarUID^.uid_req_HellPower  )then begin unit_TransformStart:=lmt_Req_HellPower;exit;end;
      if(res_UACLoot    <ptarUID^.uid_req_UACLoot    )then begin unit_TransformStart:=lmt_Req_UACLoot;  exit;end;

      //if(isselected)and(not check)then writeln((state=ps_AI)and(ptarUID^.uid_isbuilder),' ',energyCur_units+energyCur_upgrades,' ',ptarUID^.uid_req_EnergyLevel);

      case (state=ps_AI)and(ptarUID^.uid_isbuilder) of
      false: if(res_energyl_cur<ptarUID^.uid_req_EnergyLevel)then begin unit_TransformStart:=lmt_Req_Energy;exit;end;
      true : if((res_energyl_cur+energyCur_units+energyCur_upgrades)<ptarUID^.uid_req_EnergyLevel)
             or(res_energyl_max<ptarUID^.uid_req_EnergyLevel)
             then begin unit_TransformStart:=lmt_Req_Energy;exit;end;
      end;

      unit_TransformStart:=lmt_prod_AllBusy;
      if(state<>ps_AI)then
        with uid^ do
          if(uid_isbarrack)or(uid_isforge)then
            if(not unit_IsProducting(pu))
            or((units_all_s=1)and isselected)
            then
            else exit;

      unit_TransformStart:=0;

      if(check)then exit;

      vx:=x;
      vy:=y;

      energyCur_transforms+=ptarUID^.uid_req_EnergyLevel;
      res_energyl_cur     -=ptarUID^.uid_req_EnergyLevel;
      res_HellPower       -=ptarUID^.uid_req_HellPower;
      res_UACLoot         -=ptarUID^.uid_req_UACLoot;

      unit_ProdStopUnit   (pu,255,true,true,false);
      unit_ProdStopUpgrade(pu,255,true,true,false);

      transformUID  :=tarUID;
      transformTimer:=ptarUID^.uid_ProdTimeTick;
      if(halfTime)then transformTimer:=max2i(1,transformTimer div 2);

      {$IFDEF _FULLGAME}
      if(playeri=UIPlayer)then snd_SoundPlayAnoncer(snd_build_place[ptarUID^.uid_race],false,false);
      {$ENDIF}
   end;
end;
function unit_TransformStop(pu:PTUnit;check:boolean):byte;
begin
   with pu^ do
   with player^ do
   begin
      unit_TransformStop:=lmt_Invalid_Order;

      if(transformTimer<=0)
      or(hits<=0)
      or(not iscomplete)then exit;

      unit_TransformStop:=0;
      if(check)then exit;

      energyCur_transforms-=g_uids[transformUID].uid_req_EnergyLevel;
      res_energyl_cur     +=g_uids[transformUID].uid_req_EnergyLevel;
      res_HellPower       +=g_uids[transformUID].uid_req_HellPower;
      res_UACLoot         +=g_uids[transformUID].uid_req_UACLoot;
      transformTimer:=0;
   end;
end;

procedure unit_IncCounters_Select(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      units_ucl_s[uid_isbuilding,uid_uibtn  ]+=1;
      units_bld_s[uid_isbuilding            ]+=1;
      units_uid_s[uidi                      ]+=1;
      if(uid_isbuilder)then units_builders_s +=1;
      if(uid_isbarrack)then units_unitProds_s+=1;
      if(uid_isforge  )then units_upgrProds_s+=1;
      units_all_s+=1;
   end;
end;
procedure unit_DecCounters_Select(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      units_ucl_s[uid_isbuilding,uid_uibtn  ]-=1;
      units_bld_s[uid_isbuilding            ]-=1;
      units_uid_s[uidi                      ]-=1;
      if(uid_isbuilder)then units_builders_s -=1;
      if(uid_isbarrack)then units_unitProds_s-=1;
      if(uid_isforge  )then units_upgrProds_s-=1;
      units_all_s-=1;
   end;
end;

procedure unit_UnSelect(pu:PTUnit);
begin
   with pu^ do
   if(isselected)then
   begin
      unit_DecCounters_Select(pu);
      isselected:=false;
   end;
end;
procedure unit_Select(pu:PTUnit);
begin
   with pu^ do
   if(not isselected)then
   begin
      unit_IncCounters_Select(pu);
      isselected:=true;
   end;
end;

procedure unit_DecCounters_Kill(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      unit_UnSelect(pu);

      if(not iscomplete)then
      begin
         if(uid_gen_EnergyLevel>0)
         then energyCur_BldGens -=uid_req_EnergyLevel
         else energyCur_BldOther-=uid_req_EnergyLevel;
         res_energyl_cur +=uid_req_EnergyLevel;
         res_HellPower   +=round(uid_req_HellPower*(uid_MaxHits1-hits)/uid_MaxHits1);
         res_UACLoot     +=round(uid_req_UACLoot  *(uid_MaxHits1-hits)/uid_MaxHits1);
      end
      else
      begin
         unit_ProdStopUnit   (pu,255,true,true,false);
         unit_ProdStopUpgrade(pu,255,true,true,false);
         unit_TransformStop  (pu,false);

         units_ucl_c [uid_isbuilding,uid_uibtn]-=1;
         units_uid_c [uidi                    ]-=1;
         units_bld_lc[uid_isbuilding          ]-=uid_LimitUse;
         units_all_c-=1;
         res_energyl_max-=uid_gen_EnergyLevel;
         res_energyl_cur-=uid_gen_EnergyLevel;

         unit_DecCounters_Prod(pu);
      end;

      if(units_ucl_u[uid_isbuilding,uid_uibtn]=unum)then units_ucl_u[uid_isbuilding,uid_uibtn]:=0;
      if(units_uid_u[uidi                    ]=unum)then units_uid_u[uidi                    ]:=0;
   end;
end;

procedure unit_DecCounters_Remove(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      units_all_e-=1;
      armylimit  -=uid_LimitUse;
      units_ucl_e[uid_isbuilding,uid_uibtn]-=1;
      units_bld_e[uid_isbuilding          ]-=1;
      units_bld_l[uid_isbuilding          ]-=uid_LimitUse;
      units_uid_e[uidi                    ]-=1;
      if(uid_isbuilder)then units_builders_e-=1;
   end;
end;

procedure unit_end_UnitProd(pu:PTUnit);
var
i,puid:byte;
step  :integer;
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
            or(res_energyl_cur<0)
            or(units_uid_e[puid]>=units_uid_m[puid])
            then
            else
              if(uprod_r[i]=1){$IFDEF TESTMODE}or(test_InstaProd){$ENDIF}then
              begin
                 barrack_spawn(pu,uprod_u[i]);
                 unit_ProdStopUnitLine(pu,255,i,false,false);
              end
              else
              begin
                 step:=1;
                 if(buffs[ub_SphereTurbo]>0)then step+=1;
                 step+=upgrs_cur[upgr_fprod_unit];

                 uprod_r[i]:=max2i(1,uprod_r[i]-step);
              end;
         end;
end;

procedure unit_end_UpgrProd(pu:PTUnit);
var
i,tuid:byte;
step  :integer;
begin
   with pu^ do
   with uid^ do
   with player^ do
     if(uid_isforge)then
       for i:=0 to LastUnitLevel do
         if(pprod_r[i]>0)then
         begin
            tuid:=pprod_u[i];
            if(upgrs_cur[tuid]>=g_upgrs[tuid].upgr_max)
            or(upgrs_cur[tuid]>=upgrs_max[tuid])then
            begin
               unit_ProdStopUpgradeLine(pu,255,i,false);
               continue;
            end;

            if(res_energyl_cur<0)
            then
            else
              if(pprod_r[i]=1){$IFDEF TESTMODE}or(test_InstaProd){$ENDIF}then
              begin
                 upgrs_cur[tuid]+=1;
                 unit_ProdStopUpgradeLine(pu,255,i,false);
                 GameLog_UpgradeComplete(playeri,tuid,x,y);
                 game_ScoresAddC(playeri,psc_upgrades_level);
              end
              else
              begin
                 step:=1;
                 if(buffs[ub_SphereTurbo]>0)then step+=1;
                 step+=upgrs_cur[upgr_fprod_upgr];

                 pprod_r[i]:=max2i(1,pprod_r[i]-step);
              end;
         end;
end;


function unit_CheckTransport(pTransport,pPassenger:PTUnit):boolean;
begin
   unit_CheckTransport:=false;
   if(pPassenger^.isfly=uf_fly)
   or(pTransport=pPassenger)then exit;

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
         if(buffs[ub_SphereTurbo]>0)
         then i:=2
         else i:=1;

         if(  rld>=i)then   rld-=i else   rld:=0;
         if(a_rld>=i)then a_rld-=i else a_rld:=0;
      end;
   end;
end;


procedure unit_detect(uTarget,uDetector:PTUnit;udist:integer);
var td:integer;
scan_buff:byte;
begin
   scan_buff:=255;
   with uTarget^ do
   begin
      if(uDetector^.player^.isobserver)
      then td:=0
      else
        if (uDetector^.uid^.uid_ability_isradar)
        and(uDetector^.buffs[ub_Cast]>0)
        and(uDetector^.iscomplete)
        and(uDetector^.transformTimer<=0)then
        begin
           td:=point_dist_int(x,y,uDetector^.uo_x,uDetector^.uo_y);
           if(td<udist)
           then scan_buff:=ub_Scaned
           else td:=udist;
        end
        else td:=udist;

      if(td<=(uDetector^.srange+uid^.uid_r))then
        if(buffs[ub_Invisibility]<=0)or(hits<0)then
        begin
           AddToInt(@TeamVision[uDetector^.player^.team],MinVisionTime);
           if(scan_buff<=LastUnitBuff)and(player^.team<>uDetector^.player^.team)
           then AddToInt(@buffs[scan_buff],MinVisionTime);
        end
        else
          if(uDetector^.buffs[ub_Detector]>0)and(uDetector^.iscomplete)and(uDetector^.hits>0)then
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
      unit_DecCounters_Remove(pu);

      if(units_all_e<=0)then player_SetDefeat(player);
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
           buffs[ub_PainState]:=fr_fps1; // prevent fast resurrecting

           if(not suicide)then GameLog_UnitAttacked(pu);
           {$IFDEF _FULLGAME}
           effect_UnitDeath(pu,fastdeath,nil);
           {$ENDIF}
        end;

        unit_DecCounters_Kill(pu);

        with uid^ do
        begin
           if(uid_isbuilding)
           then game_ScoresAddC(playeri,psc_builds_lost)
           else game_ScoresAddC(playeri,psc_units_lost );

           if(uid_isbuilding)and(buildcd)then build_cd:=min2i(build_cd+step_build_reload,max_build_reload);
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
                 if(isfly<>uf_ground)or(transportU>0)or(KillAllInside)
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
                      if(tu^.hits>transport_exp_damage)
                      then tu^.hits-=transport_exp_damage
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
             if(uid_DeathUID>0)and(uid_DeathUIDn>0)then
               for i:=1 to uid_DeathUIDn do
                 if(player_UIDLimitCheck(player,uid_DeathUID))then
                   if(unit_add(x-g_randomr(uid_missileR),y-g_randomr(uid_missileR),0,uid_DeathUID,playeri,true,true,0))then
                     game_ScoresAddC(playeri,psc_units_summoned);

           if(units_all_c<=0)then player_SetDefeat(player);
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
var t :integer;
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
   begin
      // SPEED
      speed:=uid_MSpeed_Base;
      if(uid_MSpeed_upgr>0)then
        speed+=integer(upgrs_cur[uid_MSpeed_upgr])*uid_MSpeed_upgrV;
      if(buffs[ub_SphereTurbo]>0)then speed*=2;

      // TRANSPORT CAPASITY
      transportM:=uid_TransportMax_Base;
      if(uid_TransportMax_upgr>0)then
        transportM+=integer(upgrs_cur[uid_TransportMax_upgr])*uid_TransportMax_upgrV;

      // DETECTION
      if(uid_isdetector)or(buffs[ub_HellVision]>0)
      then buffs[ub_Detector]:=ub_infinity
      else buffs[ub_Detector]:=0;

      // INVIS
      if(buffs[ub_SphereInvis]>0)
      then buffs[ub_Invisibility]:=fr_fps1
      else
        case uidi of
        UID_HTotem  : buffs[ub_Invisibility]:=b2ib[upgrs_cur[upgr_hell_TotemInvis  ]>0];
        UID_Commando: buffs[ub_Invisibility]:=b2ib[upgrs_cur[upgr_uac_CommandoInvis]>0];
        UID_Demon   : buffs[ub_Invisibility]:=b2ib[upgrs_cur[upgr_hell_Spectre     ]>0];
        UID_HEye    : buffs[ub_Invisibility]:=ub_infinity;
        end;

      // OTHER
      if(upgrs_cur[upgr_invuln]>0)then buffs[ub_SphereInvuln]:=fr_fps1;

      case uidi of
      UID_UTransport: if(transportM>uid_TransportMax_Base)
                      then level:=1
                      else level:=0;
      UID_UGTurret  : if(upgrs_cur[upgr_uac_TurretPlasma]>0)
                      then level:=1
                      else level:=0;
      end;


      // SIGHT RANGE
      if(iscomplete)then
      begin
         t:=uid_SightR_Base;
         if(uid_SightR_upgr>0)then
           t+=integer(upgrs_cur[uid_SightR_upgr])*uid_SightR_upgrV;
      end
      else t:=uid_r+uid_r;
      SetSRange(t);
   end;
end;



