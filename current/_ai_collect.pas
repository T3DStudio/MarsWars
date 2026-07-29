
////////////////////////////////////////////////////////////////////////////////
//
//   AI DATA
//

function ai_VisionOnUnit(pDetector,pTarget:PTUnit;SkipInvisCheck:boolean):boolean;
begin
   ai_VisionOnUnit:=false;
   if(pDetector^.player^.state=ps_AI)then
     if(pTarget^.buffs[ub_Invisibility]<=0)
     or(pTarget^.hits<=0)
     or(SkipInvisCheck)then
       case pTarget^.uid^.uid_isbuilding of
       true : if((pDetector^.player^.aip_flags and aif_cheat_VisBuildings)>0)then begin ai_VisionOnUnit:=true;exit;end;
       false: if((pDetector^.player^.aip_flags and aif_cheat_VisUnits    )>0)then begin ai_VisionOnUnit:=true;exit;end;
       end;
   ai_VisionOnUnit:=CheckUnitTeamVision(pDetector^.player^.team,pTarget,SkipInvisCheck);
end;

procedure ai_Local_CollectData(pu,tu:PTUnit;ud:integer;tu_transport:PTUnit);
begin
   with pu^     do
   with uid^    do
   with player^ do
     if(tu^.hits>0)and(tu_transport=nil)then          // alive and not in transportU
       if(team=tu^.player^.team)then    // alies
       begin
          if (not tu^.uid^.uid_isbuilding)
          and(pu<>tu)then
            if (ud<base_r1)
            and(tu^.uid^.uid_CanAttack)
            and(tu^.iscomplete)
            and(tu^.speed>0)
            then aiu_limitaround_ally+=tu^.uid^.uid_LimitUse;
       end
       else
         if(tu^.buffs[ub_SphereInvuln]<=0)then
           if(ai_VisionOnUnit(pu,tu,ai_AvailableDetectors>0))then  // enemy in vision
           begin
              if((ud<srange)and not uid_AI_Melee)
              or(isfly)
              or(uid_isfly)
              or(mapZone=tu^.mapZone)then
                if(ud<ai_enemy_d)then
                begin
                   ai_enemy_u:=tu;
                   ai_enemy_d:=ud;
                end;

              if (ud<base_r1h)
              and(tu^.uid^.uid_CanAttack)then aiu_limitaround_enemy+=tu^.uid^.uid_LimitUse;

              if(ud<srange)
              //and(tu^.a_rld>0)
              //and(tu^.uid^.uid_CanAttack)
              then
                if (tu^.buffs[ub_Invisibility]>0)
                and(tu^.TeamDetection[team]<=0)
                then aiu_NeedDetect:=min2i(aiu_NeedDetect,ud-srange);
           end;
end;

procedure ai_Global_CollectData(pu,tu:PTUnit;ud:integer;tu_transport:PTUnit;isattackable:boolean);
var
busyHealer,
pfcheck:boolean;
tmpu   :PTUnit;
procedure setCommanderVar(pv:PPTUnit;pd:pinteger;d:integer);
begin
   if(pv^=nil)
   then
   else
     if(tu^.speed<pv^^.speed)
     then
     else
     if(tu^.speed>pv^^.speed)
     then exit
     else
       if(pu^.transportM>0)then
       begin
          if(tu^.transportC>0)and(pv^^.transportC<=0)
          then
          else
          if(tu^.transportC<=0)and(pv^^.transportC>0)
          then exit
          else
            if(tu^.transportC<pv^^.transportC)
            then
            else
            if(tu^.transportC>pv^^.transportC)
            then exit
            else
              if(tu^.unum <pv^^.unum)
              then
              else exit;
       end
       else
         if(tu^.unum <pv^^.unum)
         then
         else exit;

   pv^:=tu;
   pd^:=d;
end;
function setNearestTarget(ppu:PPTunit;pd:pinteger;newvalue:integer;halfValue:boolean=false):boolean;
begin
   setNearestTarget:=false;
   if(halfValue)then newvalue:=newvalue div 2;
   if(newvalue<pd^)then
   begin
      pd^ :=newvalue;
      ppu^:=tu;
      setNearestTarget:=true;
   end;
end;
procedure for_AliveOTransportAllies;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(tu^.uid^.uid_CanAttack)then // can attack
      begin
         // towers
         if (ud<srange)
         and(tu^.uid^.uid_isbuilding)
         and(not tu^.isfly)
         and(tu<>pu)then
         begin
            if(tu^.uid^.uid_CanAttackGround)then ai_towers_near_AG+=1;
            if(tu^.uid^.uid_CanAttackAir   )then ai_towers_near_AA+=1;
         end;
         // active detection
         // hell eye target
         if(tu^.iscomplete)then
           if (tu^.buffs[ub_Detector  ]<=0)
           and(tu^.buffs[ub_HellVision]<=0)then
             setNearestTarget(@ai_need_heye_u,@ai_need_heye_d,tu^.aiu_NeedDetect);
      end;

      // teleporter beacon
      if(tu^.aiu_alarm_d<NOTSET)
      and(tu^.mapZone=tu^.aiu_alarm_zone)
      and(tu^.mapZone<>mapZone)
      and(tu^.aiu_alarm_zone<>zone_solid)
      and(tu^.mapZone<>zone_solid)then
        setNearestTarget(@ai_HTeleportTarget_u,@ai_HTeleportTarget_d,tu^.aiu_alarm_d,(upgrs_cur[upgr_hell_T2TNoCD]>0)and(tu^.uidi=UID_HTeleport));

      // teleport beacon for KOTH
      if(map_scenario=mc_koth)then
        with map_KeyPointsL[0] do
          if (tu^.mapZone=kp_Zone)
          and(tu^.mapZone<>mapZone)
          and(kp_Zone<>zone_solid)then
            setNearestTarget(@ai_HTeleportTarKOTH_u,@ai_HTeleportTarKOTH_d,ud,(upgrs_cur[upgr_hell_T2TNoCD]>0)and(tu^.uidi=UID_HTeleport));

      // teleport beacon for generator capture
      if(ai_generator_d<NOTSET)then
        if (ai_generator_kp^.kp_Zone<>    mapZone)
        and(ai_generator_kp^.kp_Zone= tu^.mapZone)then
          if(ai_HTeleportTarGen_u=nil)
          then ai_HTeleportTarGen_u:=tu
          else
            if(tu^.aiu_alarm_d>ai_HTeleportTarGen_u^.aiu_alarm_d)
            then ai_HTeleportTarGen_u:=tu;

      // Alarmed base
      if (not tu^.uid^.uid_CanAttack)
      and(tu^.uid^.uid_isbuilding   )
      and(tu^.uidi<>UID_HEye )
      and(tu^.aiu_alarm_d<base_r1h)then
        ai_SetBDefend(pu,tu,ud);

      // nearest base
      if (tu^.uidi<>UID_HEye)
      and(tu^.uid^.uid_isbuilding)
      and( tu^.uid^.uid_isbuilder
        or tu^.uid^.uid_isbarrack
        or tu^.uid^.uid_isforge
        or (tu^.uid^.uid_gen_EnergyLevel>0))
      and(tu^.speed<=0)
      and(not tu^.isfly)
      and(pfcheck)
      and(tu<>pu)then
        if(playeri<>tu^.playeri)
        then setNearestTarget(@ai_BaseAlly_u,@ai_BaseAlly_d,ud-uid_r-tu^.uid^.uid_r)
        else setNearestTarget(@ai_BaseOwn_u ,@ai_BaseOwn_d ,ud-uid_r-tu^.uid^.uid_r);

      if(tu^.uidi=UID_HEye)
      or(tu^.uidi=UID_HEyeNest)then
        if(ud<tu^.srange)
        or(ud<    srange)then ai_near_HEye+=1;

      // magic targets
      case uidi of
      UID_UAcademy        : if(ability_CheckTarget_UACGeneral   (team,tu))then ai_SetTarget_UACGeneral   (tu);
      UID_UHPowerConductor: begin
                            if(ability_CheckTarget_SphereSoul   (team,tu))then ai_SetTarget_SphereSoul   (tu);
                            if(ability_CheckTarget_SphereInvis  (team,tu))then ai_SetTarget_SphereInvis  (tu);
                            end;
      end;

      if(tu^.group<>aic_group_Scout)
      or(tu^.player^.state<>ps_AI)then
        case uidi of
        UID_UHPowerConductor: if(ability_CheckTarget_SphereInvuln (team,tu))then ai_SetTarget_SphereInvuln (tu);
        UID_HAltar          : begin
                              if(ability_CheckTarget_SphereRDamage(team,tu))then ai_SetTarget_SphereRDamage(tu);
                              if(ability_CheckTarget_SphereDDamage(team,tu))then ai_SetTarget_SphereDDamage(tu);
                              if(ability_CheckTarget_SphereTurbo  (team,tu))then ai_SetTarget_SphereTurbo  (tu);
                              end;
        end;

      // repair/heal target
      if(uid_AI_Healer)then
        if(pfcheck)
        or(isattackable)then
          if (tu^.iscomplete)
          and(tu^.hits<tu^.uid^.uid_MaxHits1)
          and(tu^.uid^.uid_Regen_Base>=0)then
            if(speed>tu^.speed)
            or(ud<srange)then
              if(tu^.uid^.uid_ismech)
              then setNearestTarget(@ai_RepairTar_u,@ai_RepairTar_d,ud)
              else setNearestTarget(@ai_HealTar_u  ,@ai_HealTar_d  ,ud);
   end;
end;

procedure for_AliveOTransportEnemy;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(ai_VisionOnUnit(pu,tu,(ai_AvailableDetectors>0)or(uid_isbuilding)))then  // enemy in vision
      begin
         if(tu^.buffs[ub_SphereInvuln]<=0)then
         begin
            // enemy
            if(not tu^.isfly)
            or(tu^.uid^.uid_FlyLevelLikeTarget)then
            begin
               setNearestTarget(@ai_enemy_grd_u,@ai_enemy_grd_d,ud);
               if(tu^.uid^.uid_CanAttack)
               and(ud<base_r2)then ai_enemylimit_baseR2_grd+=tu^.uid^.uid_LimitUse;
            end
            else
            begin
               setNearestTarget(@ai_enemy_air_u,@ai_enemy_air_d,ud);
               if(tu^.uid^.uid_CanAttack)
               and(ud<base_r2)then ai_enemylimit_baseR2_fly+=tu^.uid^.uid_LimitUse;
            end;
            if(tu^.uid^.uid_isbuilding)and(pfcheck)then
              if(not tu^.isfly)
              or(isattackable)then setNearestTarget(@ai_enemy_build_u,@ai_enemy_build_d,ud);
            if(tu^.uid^.uid_CanAttack)then setNearestTarget(@ai_enemy_battle_u,@ai_enemy_battle_d,ud);

            // invis enemy in vision
            if (tu^.a_rld>0)
            and(tu^.buffs[ub_Invisibility]>0)
            and(tu^.TeamDetection[team]<=0)then
              setNearestTarget(@ai_enemy_inv_u,@ai_enemy_inv_d,ud);

            // uac strike target
            if(uidi=UID_URMStation)then
              ai_SetTarget_Strike(tu);
         end;

         if(tu^.uid^.uid_isbuilding)then
         begin
            if(tu^.isfly)
            then ai_enemyhits_fly   +=tu^.hits
            else ai_enemyhits_Towers+=tu^.hits*3;
         end
         else
           if(tu^.isfly)then
           begin
              ai_enemyhits_fly    +=tu^.hits;
              if(tu^.uid^.uid_ismech)then
              ai_enemyhits_flyMech+=tu^.hits;
           end
           else
             if(tu^.uid^.uid_ismech)
             then ai_enemyhits_groundMech+=tu^.hits
             else ai_enemyhits_groundBio +=tu^.hits;

         if(ud<srange)and(race=r_UAC)and(units_uid_c[UID_UAcademy]>0)then
           case tu^.uid^.uid_isbuilding of
           true : if(ability_CheckTarget_Bribe(team,tu,true ))then ai_SetTarget_Hack (tu);
           false: if(ability_CheckTarget_Bribe(team,tu,false))then ai_SetTarget_Bribe(tu);
           end;
      end;
   end;
end;

procedure for_AliveOTransportOwn;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(tu^.iscomplete)then
      begin
         // HEye
         if(tu^.uidi=UID_HEyeNest)then
           if(ai_HEyeNest_u=nil)
           then ai_HEyeNest_u:=tu
           else
             if(tu^.rld<ai_HEyeNest_u^.rld)
             then ai_HEyeNest_u:=tu;

         // target for hteleport recall
         if (not tu^.isfly)
         and(not tu^.uid^.uid_isbuilding)
         and(tu^.uid^.uid_CanAttack)
         and(tu^.group<>aic_group_GenGuard)then
           if(ai_HTeleportRecall_d=NOTSET)
           or(ai_HTeleportRecall_d>tu^.aiu_alarm_d)then
           begin
              ai_HTeleportRecall_u:=tu;
              ai_HTeleportRecall_d:=tu^.aiu_alarm_d;
           end;

         // commander
         if(tu^.group=group)
         and(pfcheck)
         and(ud<base_r2)
         and(tu^.speed>0)
         and(not busyHealer)
         and(not tu^.uid^.uid_isbuilding)then
           if(tu^.isfly)
           then setCommanderVar(@ai_commander_fly_u,@ai_commander_fly_d,ud)
           else setCommanderVar(@ai_commander_grd_u,@ai_commander_grd_d,ud);

         // scout candidate
         if(not busyHealer)then
           ai_SetTarget_Scout(tu);

         // transport target
         if (not tu^.isfly)
         and(tu^.aiu_alarm_d>base_r1h)
         and(not busyHealer)then
           if(unit_CheckTransport(pu,tu))then
           begin
              if(tu^.group=aic_group_Home      )
              or(tu^.group=aic_group_AttackNow )
              or(tu^.group=aic_group_AttackWait)
              or(tu^.group=aic_group_GenWait   )
              or(tu^.group=aic_group_GenAssault)then
                setNearestTarget(@ai_TransportTar_BDefend_u,@ai_TransportTar_BDefend_d,ud);

              if(tu^.group=aic_group_AttackWait)then
                setNearestTarget(@ai_TransportTar_Attack_u ,@ai_TransportTar_Attack_d ,ud);

              if(tu^.group=aic_group_GenWait   )then
                setNearestTarget(@ai_TransportTar_GenTeam_u,@ai_TransportTar_GenTeam_d,ud);
           end;
      end;

      // nearest teleport
      if(not isfly)and(tu^.uid^.uid_ability_isteleport)then
      begin
         if(pfcheck)and(ud<=base_r2)then
           ai_SetHTeleportNearest(tu,ud);

         if(not pfcheck)and(tu^.rld<=0)then
           if(tu^.aiu_alarm_d=NOTSET)
           then setNearestTarget(@ai_HTeleportRemote_u,@ai_HTeleportRemote_d,NOTSET-1)
           else setNearestTarget(@ai_HTeleportRemote_u,@ai_HTeleportRemote_d,tu^.aiu_alarm_d);
      end;
   end;
end;

procedure for_AliveOwn;
var l:byte;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(tu^.uid^.uid_AI_NextFormUID>0)and(not tu^.uid^.uid_isbuilder)and(ai_flags_BaseAOther)
      then ai_energy_future+=g_uids[tu^.uid^.uid_AI_NextFormUID].uid_gen_EnergyLevel
      else ai_energy_future+=tu^.uid^.uid_gen_EnergyLevel;

      if (tu^.uid^.uid_isbuilding)
      and(tu^.uid^.uid_CanAttack)
      and(not tu^.uid^.uid_isbuilder)then
        ai_curr_Towers+=1;

      if(tu^.iscomplete)then
      begin
         if (not tu^.uid^.uid_isbuilding)
         and(not tu^.uid^.uid_CanAttack)
         and(tu^.isfly)
         and(tu^.group=aic_group_AttackNow)then ai_AttackGroupFlyLimit+=tu^.uid^.uid_LimitUse;

         if(uidi=tu^.uidi)then
         begin
            l:=ai_GetLevel(tu);
            if(l<ai_selfUID_minLevel)then ai_selfUID_minLevel:=l;
         end;

         if(not tu^.isfly)and(tu^.uid^.uid_isbuilder)then
           if(tu^.aiu_BuildAttempts<ai_MinBuildAttempts)then
             ai_MinBuildAttempts:=tu^.aiu_BuildAttempts;

        { if(tu^.uid^.uid_ability=uab_UACScan)then ai_radars+=1;  }
         // transportU
         if (not tu^.uid^.uid_isbuilding)
         and(map_NeedTransport)then
         begin
            if (tu^.transportM>0)
            and(tu^.isfly)then ai_transport_cur+=tu^.transportM;

            if (tu^.transportM=tu^.transportC)
            and(not tu^.isfly)
            and(tu^.uid^.uid_CanAttack)then
              ai_transport_need+=tu^.uid^.uid_TransportSize;
         end;

         if(tu^.transformTimer>0)then
           if(g_uids[tu^.transformUID].uid_req_EnergyLevel>0)then
           begin
              ai_UnitsInTransform+=1;
              if(tu^.uid^.uid_isbuilder)then ai_BuildersInTransform+=1;
           end;
      end
      else
      begin
         if(tu^.uid^.uid_isbuilder)and(tu^.uid^.uid_req_EnergyLevel>0)then
           ai_BuildersInConstruction+=1;
         if(uidi=tu^.uidi)then ai_selfUID_nocomplete+=1;
      end;
      // armylimit
      {if(tu^.uid^.uid_isbuilding)
      then ai_armylimit_alive_b+=tu^.uid^.uid_LimitUse
      else ai_armylimit_alive_u+=tu^.uid^.uid_LimitUse;}

      // detection near
      if(ud<=srange)then
        if(tu^.buffs[ub_Detector]>0)then ai_near_detect+=1;

      // unit productions available
      if(tu^.uid^.uid_isbarrack)then ai_curr_UnitProds+=tu^.level+1;
      // upgrade productions available
      if(tu^.uid^.uid_isforge  )then ai_curr_UpgrProds+=tu^.level+1;

      if(not tu^.uid^.uid_isbuilding)then
      begin
         // units in groups
         if(tu^.group<=MaxAIGroups)then
         begin
            ai_GroupAll_ucount[tu^.group]+=1;
            ai_GroupAll_ulimit[tu^.group]+=tu^.uid^.uid_LimitUse;
         end;

         // limit of generator guards near
         if(ud<srange)then
           if(tu^.group=aic_group_GenGuard  )
           //or(tu^.group=aic_group_GenAssault)
           //or(tu^.group=aic_group_GenWait   )
           then ai_nearGenDudesLimit+=tu^.uid^.uid_LimitUse;
      end;
   end;
end;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      pfcheck   :=(isfly)or((mapZone=tu^.mapZone)and (mapZone<>zone_solid));
      busyHealer:=false;
      if(tu^.uid^.uid_AI_healer)and(isUnitRange(tu^.a_tar,@tmpu))then
        if(tmpu^.player^.team=team)then busyHealer:=true;

      if(tu^.hits>0)then
      begin
         if(tu_transport=nil)then
         begin
            if(team=tu^.player^.team)
            then for_AliveOTransportAllies
            else for_AliveOTransportEnemy;

            if(playeri=tu^.playeri)
            then for_AliveOTransportOwn;
         end
         else
           if (not tu^.uid^.uid_isbuilding)
           and(tu^.transportU=unum)
           and(tu^.group<=MaxAIGroups)then
             ai_GroupIn_ulimit[tu^.group]+=tu^.uid^.uid_LimitUse;

         if(player=tu^.player)then for_AliveOwn;
      end;

      if(tu^.uid^.uid_ZombieUID>0)and(pfcheck)then
        if(hits_fdead<tu^.hits)and(tu^.hits<=tu^.uid^.uid_ZombieHits)then
          if(ai_VisionOnUnit(pu,tu,false))then
            setNearestTarget(@ai_ZombieTarget_u,@ai_ZombieTarget_d,ud);
   end;
end;


