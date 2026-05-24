
////////////////////////////////////////////////////////////////////////////////
//
//   AI DATA
//

procedure ai_Local_CollectData(pu,tu:PTUnit;ud:integer;tu_transport:PTUnit);
begin
   with pu^     do
   with uid^    do
   with player^ do
     if(tu^.hits>0)and(tu_transport=nil)then          // alive and not in transportU
       if(team=tu^.player^.team)then    // alies
       begin
          if(not tu^.uid^.uid_isbuilding)then
            if (ud<base_r1h)
            and(tu^.uid^.uid_CanAttack)
            and(tu^.iscomplete)
            and(tu^.speed>0)
            then aiu_limitaround_ally+=tu^.uid^.uid_LimitUse;
       end
       else
         if(tu^.buffs[ub_SphereInvuln]<=0)then
           if(CheckUnitTeamVision(team,tu,ai_AvailableDetectors>0))
           or(((aip_flags and aif_cheat_VisBuildings)>0)and(    tu^.uid^.uid_isbuilding))
           or(((aip_flags and aif_cheat_VisUnits    )>0)and(not tu^.uid^.uid_isbuilding))then  // enemy in vision
           begin
              if(ud<srange)
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

              if(ud<srange)and(tu^.a_rld>0)then
                if (tu^.buffs[ub_Invisibility]>0)
                and(tu^.TeamDetection[team]<=0)
                and(tu^.uid^.uid_CanAttack)
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
function setNearestTarget(ppu:PPTunit;pd:pinteger;newvalue:integer):boolean;
begin
   setNearestTarget:=false;
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
      if(tu^.uid^.uid_CanAttack)then    // can attack
      begin
         // towers
         if(ud<srange)and(tu^.uid^.uid_isbuilding)and(not tu^.isfly)then
         begin
            if(tu^.uid^.uid_CanAttackGround)then ai_towers_near_AG+=1;
            if(tu^.uid^.uid_CanAttackAir   )then ai_towers_near_AA+=1;
         end;

         {if(tu^.uidi=aiucl_twr_air1[race])
         or(tu^.uidi=aiucl_twr_air2[race])then
         begin
            if(ud<srange)then
            begin
               ai_towers_near_air+=1;
               ai_towers_near    +=1;
            end;
            ai_towers_cur+=1;
            if(tu^.iscomplete)then ai_towers_cur_active+=1;
         end
         else
           if(tu^.uidi=aiucl_twr_ground1[race])
           or(tu^.uidi=aiucl_twr_ground2[race])then
           begin
              if(ud<srange)then
              begin
                 ai_towers_near_grd+=1;
                 ai_towers_near    +=1;
              end;
              ai_towers_cur+=1;
              if(tu^.iscomplete)then ai_towers_cur_active+=1;
           end;}
         if(tu^.iscomplete)then
         begin
            //// active detection
            // hell eye target

            if(tu^.buffs[ub_Detector]<=0)and(tu^.buffs[ub_HellVision]<=0)then
              setNearestTarget(@ai_need_heye_u,@ai_need_heye_d,tu^.aiu_NeedDetect);
              {if(tu^.aiu_NeedDetect<ai_need_heye_d)then
              begin
                 ai_need_heye_u:=tu;
                 ai_need_heye_d:=tu^.aiu_NeedDetect;
              end;  }
         end;
      end;

      // teleporter beacon
      if(tu^.aiu_alarm_d<NOTSET)
      and(tu^.mapZone=tu^.aiu_alarm_zone)
      and(not map_IfObstacleZone(tu^.aiu_alarm_zone))
      and(tu^.mapZone<>mapZone)
      and(not map_IfObstacleZone(tu^.mapZone))then
        setNearestTarget(@ai_HTeleportTarget_u,@ai_HTeleportTarget_d,tu^.aiu_alarm_d);
      // добавить условие на больший приоритет на телепорт с апгрейдом Portal Link
      // добавить поиск "удаленного" телепорта

      // teleport beacon for KOTH
      if(map_scenario=mc_koth)then
        with map_KeyPointsL[0] do
          if (not map_IfObstacleZone(kp_Zone))
          and(tu^.mapZone=kp_Zone)
          and(tu^.mapZone<>mapZone)then
            setNearestTarget(@ai_HTeleportTarKOTH_u,@ai_HTeleportTarKOTH_d,ud);

      // teleport beacon for generator capture
      if(ai_generator_d<NOTSET)then
        if (ai_generator_kp^.kp_Zone<>    mapZone)
        and(ai_generator_kp^.kp_Zone= tu^.mapZone)then
          if(ai_HTeleportTarGen_u=nil)
          then ai_HTeleportTarGen_u:=tu
          else
            if(tu^.aiu_alarm_d>ai_HTeleportTarGen_u^.aiu_alarm_d)
            then ai_HTeleportTarGen_u:=tu;

      //ai_HTeleportTarGen_d

      // Alarmed base
      if (not tu^.uid^.uid_CanAttack)
      and(tu^.uid^.uid_isbuilding   )
      and(tu^.uidi<>UID_HEye )
      and(tu^.aiu_alarm_d<base_r1h)then
        //if((tu^.aiu_limitaround_enemy-tu^.aiu_limitaround_ally)>=0)then
          ai_SetBDefend(pu,tu,ud);

      // nearest base
      if (tu^.uidi<>UID_HEye)
      and(tu^.uid^.uid_isbuilding)
      and(tu^.speed<=0)
      and(not tu^.isfly)
      and(pfcheck)then
        if(playeri<>tu^.playeri)
        then setNearestTarget(@ai_BaseAlly_u,@ai_BaseAlly_d,ud-uid_r-tu^.uid^.uid_r)
        else setNearestTarget(@ai_BaseOwn_u ,@ai_BaseOwn_d ,ud-uid_r-tu^.uid^.uid_r);

      if(tu^.uidi=UID_HEye)
      or(tu^.uidi=UID_HEyeNest)then
        if(ud<tu^.srange)
        or(ud<    srange)then ai_near_HEye+=1;

      // magic targets
      if(ability_CheckTarget_UACGeneral   (team,tu))then ai_SetTarget_UACGeneral   (tu);
      if(ability_CheckTarget_SphereSoul   (team,tu))then ai_SetTarget_SphereSoul   (tu);
      if(ability_CheckTarget_SphereInvis  (team,tu))then ai_SetTarget_SphereInvis  (tu);
      if(ability_CheckTarget_SphereInvuln (team,tu))then ai_SetTarget_SphereInvuln (tu);
      if(ability_CheckTarget_SphereRDamage(team,tu))then ai_SetTarget_SphereRDamage(tu);
      if(ability_CheckTarget_SphereDDamage(team,tu))then ai_SetTarget_SphereDDamage(tu);
      if(ability_CheckTarget_SphereTurbo  (team,tu))then ai_SetTarget_SphereTurbo  (tu);

      // repair/heal target
      if(pfcheck)
      or(ud<=srange)then
        if (tu^.iscomplete)
        and(tu^.hits<tu^.uid^.uid_MaxHits1)
        and(tu^.uid^.uid_Regen_Base>=0)then
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
      if(CheckUnitTeamVision(team,tu,false))
      or(((aip_flags and aif_cheat_VisBuildings)>0)and(    tu^.uid^.uid_isbuilding))
      or(((aip_flags and aif_cheat_VisUnits    )>0)and(not tu^.uid^.uid_isbuilding))then  // enemy in vision
      begin
         if(tu^.buffs[ub_SphereInvuln]<=0)then
         begin
            // enemy other
            if(not tu^.isfly)or(tu^.uid^.uid_FlyLevelLikeTarget)then
            begin
               setNearestTarget(@ai_enemy_grd_u,@ai_enemy_grd_d,ud);
               if(tu^.uid^.uid_CanAttack)then
               begin
                  if(ud<base_r2)then ai_enemylimit_baseR2_grd+=tu^.uid^.uid_LimitUse;
               end;
            end
            else
            begin
               setNearestTarget(@ai_enemy_air_u,@ai_enemy_air_d,ud);
               if(tu^.uid^.uid_CanAttack)then
               begin
                  if(ud<base_r2)then ai_enemylimit_baseR2_fly+=tu^.uid^.uid_LimitUse;
               end;
            end;
            if(tu^.uid^.uid_isbuilding)and(pfcheck)then
              if(not tu^.isfly)
              or(isattackable)then setNearestTarget(@ai_enemy_build_u,@ai_enemy_build_d,ud);
            if(tu^.uid^.uid_CanAttack)then setNearestTarget(@ai_enemy_battle_u,@ai_enemy_battle_d,ud);

            // uac strike target
            if(tu^.speed<11)then ai_SetTarget_Strike(tu);

            // Primary Target
            if(ud<=srange)and(isattackable)and(tu^.uid^.uid_AI_PrimaryTarget)then
              if(ai_PrimaryTarget_u=nil)
              then ai_PrimaryTarget_u:=tu
              else
                if(tu^.hits<ai_PrimaryTarget_u^.hits)
                then ai_PrimaryTarget_u:=tu;
         end;

         if(tu^.uid^.uid_isbuilding)then
         begin
            if(tu^.isfly)
            then ai_enemylimit_fly   +=tu^.uid^.uid_LimitUse
            else ai_enemylimit_Towers+=tu^.uid^.uid_LimitUse*3;
         end
         else
           if(tu^.isfly)then
           begin
              ai_enemylimit_fly    +=tu^.uid^.uid_LimitUse;
              if(tu^.uid^.uid_ismech)then
              ai_enemylimit_flyMech+=tu^.uid^.uid_LimitUse;
           end
           else
             if(tu^.uid^.uid_ismech)
             then ai_enemylimit_groundMech+=tu^.uid^.uid_LimitUse
             else ai_enemylimit_groundBio +=tu^.uid^.uid_LimitUse;

         if(ud<srange)then
           case tu^.uid^.uid_isbuilding of
           true : if(ability_CheckTarget_Bribe(team,tu,true ))then ai_SetTarget_Hack (tu);
           false: if(ability_CheckTarget_Bribe(team,tu,false))then ai_SetTarget_Bribe(tu);
           end;

         {// nearest phantom
         if(not ai_PhantomWantZombieMe)and(uid_ZombieUID>0)then
           if(tu^.uidi=UID_Phantom)and(tu^.a_tar=unum)then
             if((ud-uid_r-tu^.uid^.uid_r)<=melee_r)then ai_PhantomWantZombieMe:=true;  }
      end;

      if(CheckUnitTeamVision(team,tu,true))then    // invis enemy in vision
        if(tu^.a_rld>0){or(tu^.uo_bx>-1)or(tu^.uo_id=ua_hold)}then   // ????????
          if(tu^.buffs[ub_Invisibility]>0)and(tu^.TeamDetection[team]<=0){and(tu^.buffs[ub_Scaned]<=0)}then
            setNearestTarget(@ai_enemy_inv_u,@ai_enemy_inv_d,ud);
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
         and(tu^.uid^.uid_CanAttack)then
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

      ai_energy_current+=tu^.uid^.uid_gen_EnergyLevel;

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
         if(not tu^.uid^.uid_isbuilding)then
         begin
            if(tu^.transportM>0)and(tu^.isfly)then ai_transport_cur+=tu^.transportM;
            if(tu^.transportM=tu^.transportC)and(not tu^.isfly)and(tu^.uid^.uid_CanAttack)then
            begin
               ai_armylimit_ForTeleport+=tu^.uid^.uid_LimitUse;
               if(map_NeedTransport)then
               ai_transport_need       +=tu^.uid^.uid_TransportSize;
            end;
         end;

         if(tu^.transformTimer>0)then ai_UnitsInTransform+=1;
      end;

      // armylimit
      if(tu^.uid^.uid_isbuilding)
      then ai_armylimit_alive_b+=tu^.uid^.uid_LimitUse
      else ai_armylimit_alive_u+=tu^.uid^.uid_LimitUse;

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
         if(ud<srange)and(tu^.group=aic_group_GenGuard)then
           ai_nearGenGuards+=tu^.uid^.uid_LimitUse;
      end;
   end;
end;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      pfcheck   :=(isfly)or((mapZone=tu^.mapZone)and not map_IfObstacleZone(mapZone));
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

      if (playeri=tu^.playeri)
      and(tu^.isfly)
      and(not tu^.uid^.uid_isbuilding)
      and(tu^.uid^.uid_CanAttack)then
        ai_armylimit_fly+=tu^.uid^.uid_LimitUse;

      if(tu^.uid^.uid_ZombieUID>0)and(pfcheck)then
        if(hits_fdead<tu^.hits)and(tu^.hits<=tu^.uid^.uid_ZombieHits)then
          setNearestTarget(@ai_ZombieTarget_u,@ai_ZombieTarget_d,ud);
   end;
end;


