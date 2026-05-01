
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
              or(mapZone=tu^.mapZone)
              or(uid_isbarrack)then
                if(ud<ai_enemy_d)then
                begin
                   ai_enemy_u:=tu;
                   ai_enemy_d:=ud;
                end;

              //ai_Local_SetCurrentAlarm(pu,tu,0,0,ud);

              if (ud<base_r1h)
              and(tu^.uid^.uid_CanAttack)then aiu_limitaround_enemy+=tu^.uid^.uid_LimitUse;

              if(ud<srange)then
                if{(ai_generator_d<keyPoint_genr)   //??????
                or(ai_keypoint_d <keyPoint_DefR)
                or}(tu^.a_rld>0)then
                  if (tu^.buffs[ub_Invisibility]>0)
                  and(tu^.TeamDetection[team]<=0)
                  //and(tu^.buffs[ub_Scaned]<=0)
                  and(tu^.uid^.uid_CanAttack)
                  then aiu_NeedDetect:=min2i(aiu_NeedDetect,ud-srange);
           end;
end;

procedure ai_Global_CollectData(pu,tu:PTUnit;ud:integer;tu_transport:PTUnit);
var pfcheck:boolean;
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
            if(tu^.aiu_NeedDetect<ai_need_heye_d)then
              if(tu^.buffs[ub_Detector]<=0)and(tu^.buffs[ub_HellVision]<=0)then
              begin
                 ai_need_heye_u:=tu;
                 ai_need_heye_d:=tu^.aiu_NeedDetect;
              end;
         end;
      end;

      // teleport target
      if(tu^.aiu_alarm_d<NOTSET)
      and(mapZone<>tu^.mapZone)
      and(not map_IfObstacleZone(tu^.mapZone))then
        setNearestTarget(@ai_HTeleportTarget_u,@ai_HTeleportTarget_d,tu^.aiu_alarm_d);

      // Alarmed base
      if (not tu^.uid^.uid_CanAttack)
      and(tu^.uid^.uid_isbuilding   )
      and(tu^.uidi<>UID_HEye )
      and(tu^.aiu_alarm_d<base_r1h)then
        //if((tu^.aiu_limitaround_enemy-tu^.aiu_limitaround_ally)>=0)then
          ai_SetBDefend(pu,tu,ud);

      if(tu^.uidi=UID_HEye)then
        if(ud<srange)then ai_near_HEye+=1;

      // magic targets
      if(ability_CheckTarget_UACHeroic    (team,tu))then ai_SetTarget_Heroic       (tu);
      if(ability_CheckTarget_SphereSoul   (team,tu))then ai_SetTarget_SphereSoul   (tu);
      if(ability_CheckTarget_SphereInvis  (team,tu))then ai_SetTarget_SphereInvis  (tu);
      if(ability_CheckTarget_SphereInvuln (team,tu))then ai_SetTarget_SphereInvuln (tu);
      if(ability_CheckTarget_SphereRDamage(team,tu))then ai_SetTarget_SphereRDamage(tu);
      if(ability_CheckTarget_SphereDDamage(team,tu))then ai_SetTarget_SphereDDamage(tu);
      if(ability_CheckTarget_SphereTurbo  (team,tu))then ai_SetTarget_SphereTurbo  (tu);

      {// teleporter beacon
      if(tu^.aiu_alarm_d<base_r1)then
        if(not map_IfObstacleZone(tu^.mapZone))then
          if(ai_teleporter_beacon_u=nil)
          then ai_teleporter_beacon_u:=tu
          else
            if(ai_teleporter_beacon_u^.ukfly)and(not tu^.ukfly)
            then ai_teleporter_beacon_u:=tu
            else
              if(tu^.aiu_limitaround_ally>ai_teleporter_beacon_u^.aiu_limitaround_ally)
              then ai_teleporter_beacon_u:=tu;

      // repair/heal target
      if(pfcheck)or(ud<=srange)then
       if(tu^.iscomplete)and(tu^.hits<tu^.uid^.uid_MaxHits1)and(tu^.buffs[ub_Heal]<=0)then
        if(tu^.uid^.uid_ismech)
        then _setNearestTarget(@ai_mrepair_u,@ai_mrepair_d,ud)
        else _setNearestTarget(@ai_urepair_u,@ai_urepair_d,ud);}
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
                  if(not tu^.uid^.uid_isbuilding)then ai_enemy_grd+=tu^.uid^.uid_LimitUse;
               end;
            end
            else
            begin
               setNearestTarget(@ai_enemy_air_u,@ai_enemy_air_d,ud);
               if(tu^.uid^.uid_CanAttack)then
               begin
                  if(ud<base_r2)then ai_enemylimit_baseR2_fly+=tu^.uid^.uid_LimitUse;
                  if(not tu^.uid^.uid_isbuilding)then ai_enemy_fly+=tu^.uid^.uid_LimitUse;
               end;
            end;
            if(tu^.uid^.uid_isbuilding)and(not tu^.isfly)and(pfcheck)then setNearestTarget(@ai_enemy_build_u,@ai_enemy_build_d,ud);
            if(tu^.uid^.uid_CanAttack)then setNearestTarget(@ai_enemy_battle_u,@ai_enemy_battle_d,ud);

            // uac strike target
            if(tu^.speed<11)then ai_SetTarget_Strike(tu);
         end;

         if(not tu^.uid^.uid_isbuilding)then
           if (tu^.isfly)then
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
      end
      else
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

         // nearest teleport
         if(not isfly)and(tu^.uid^.uid_ability_isteleport)then
         begin
            if(tu^.aiu_alarm_d<base_r1)then setNearestTarget(@ai_HTeleportAlarmed_u,@ai_HTeleportAlarmed_d,ud);

            {if(pfcheck)and(ud<base_r3)then setNearestTarget(@ai_teleporterF_u,@ai_teleporterF_d,ud+(tu^.rld*20));
            if(ud>=base_r3)or(not pfcheck)
            then setNearestTarget(@ai_teleporterR_u,@ai_teleporterR_d,tu^.rld)
            else ai_limitaround_teleports+=tu^.uid^.uid_LimitUse;   }
            //if(ud<base_r3)and(pfcheck)then ai_limitaround_teleports+=tu^.uid^.uid_LimitUse;
         end;

         // commander
         if(tu^.group=group)and(pfcheck)and(ud<base_r2)and(tu^.speed>0)and(not tu^.uid^.uid_isbuilding)then
           if(tu^.isfly)
           then setCommanderVar(@ai_commander_fly_u,@ai_commander_fly_d,ud)
           else setCommanderVar(@ai_commander_grd_u,@ai_commander_grd_d,ud);

         ai_SetTarget_Scout(tu);

         if (not tu^.isfly)
         and(tu^.aiu_alarm_d>base_r1h)then
           if(unit_CheckTransport(pu,tu))then
           begin
              if(tu^.group=aic_group_base)
              or(tu^.group=aic_group_AttackNow)
              or(tu^.group=aic_group_AttackWait)then
                setNearestTarget(@ai_TransportTar_BDefend_u,@ai_TransportTar_BDefend_d,ud);

              if(tu^.group=aic_group_AttackWait)then
                setNearestTarget(@ai_TransportTar_Attack_u,@ai_TransportTar_Attack_d,ud);
           end;

      {   if(tu^.unum<>ai_scout_u_cur)then
         begin
            // transportU target
            if(tu^.group<>aio_attack_busy)and(tu^.group<>aio_home_busy)then
             if(transportC<transportM)and(ud<ai_transport_tar_d)then
              if(tu^.aiu_alarm_d>base_r1h)then
               if(tu^.transportC=tu^.transportM)or(armylimit>=ai_limit_border)or(armylimit>=ai_attack_limit)then
                if(pfcheck)then
                 if(unit_CheckTransport(pu,tu))then _setNearestTarget(@ai_transport_tar_u,@ai_transport_tar_d,ud);
         end;

         // builder
         if(ai_nearest_builder_square>0)then
           if(tu^.uidi=aiucl_main0 [race])
           or(tu^.uidi=aiucl_main0A[race])
           or(tu^.uidi=aiucl_main1 [race])
           or(tu^.uidi=aiucl_main1A[race])then
             if(tu^.aiu_FiledSquareNear<ai_nearest_builder_square)then
             begin
                ai_nearest_builder_square:=tu^.aiu_FiledSquareNear;
                ai_nearest_builder_u     :=pu;
                ai_nearest_builder_d     :=ud;
             end;    }
      end;

      // nearest teleport
      if(pfcheck)and(not isfly)and(tu^.uid^.uid_ability_isteleport)and(ud<=base_r2)then
        if(setNearestTarget(@ai_HTeleportNearest_u,@ai_HTeleportNearest_rld,tu^.rld))then
          ai_HTeleportNearest_d:=ud;

      // nearest base
      if (tu^.uidi<>UID_HEye)
      and(tu^.aiu_alarm_d>base_r2)
      and(tu^.uid^.uid_isbuilding)
      and(tu^.speed<=0)
      and((not uid_isbuilding)or(uid_isbuilding and(tu^.uid^.uid_gen_EnergyLevel>0)))
      and(pfcheck)then setNearestTarget(@ai_base_u,@ai_base_d,ud-uid_r-tu^.uid^.uid_r);
   end;
end;


procedure for_AliveOwn;
var l:byte;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(tu^.uid^.uid_AI_NextFormUID>0)and(not tu^.uid^.uid_isbuilder)and(ai_flags_BaseAdvance)then
      begin
         {if(not tu^.uid^.uid_isbuilder)                         //????????
         or((tu^.uid^.uid_isbuilder)and(units_builders_ec>1))
         then }
         ai_energy_future+=g_uids[tu^.uid^.uid_AI_NextFormUID].uid_gen_EnergyLevel;
      end
      else ai_energy_future+=tu^.uid^.uid_gen_EnergyLevel;

      ai_energy_current+=tu^.uid^.uid_gen_EnergyLevel;

      if(tu^.iscomplete)then
      begin
         if(uidi=tu^.uidi)then
         begin
            l:=ai_GetLevel(tu);
            if(l<ai_selfUID_minLevel)then ai_selfUID_minLevel:=l;
         end;

         if(not tu^.isfly)and(tu^.uid^.uid_isbuilder)then
           if(tu^.aiu_BuildAttempts<ai_MinBuildAttempts)then
             ai_MinBuildAttempts:=tu^.aiu_BuildAttempts;

         if(tu^.speed>0)and(tu^.uid^.uid_CanAttack)then
         begin
           { if(tu^.ukfly)
            then ai_limitaround_fly+=tu^.uid^.uid_LimitUse
            else ai_limitaround_grd+=tu^.uid^.uid_LimitUse;
            if(ud<=base_r1)
            then ai_limitaround_own+=tu^.uid^.uid_LimitUse;  }
         end;
        { if(tu^.uid^.uid_ability=uab_UACScan)then ai_radars+=1;  }
         // transportU
         if(not tu^.uid^.uid_isbuilding)then
         begin
            if(tu^.transportM>0)and(tu^.isfly)then ai_transport_cur+=tu^.transportM;
            if(tu^.transportM=tu^.transportC)and(not tu^.isfly)and(tu^.uid^.uid_CanAttack)then
            begin
               ai_armylimit_ForTeleport+=tu^.uid^.uid_LimitUse;
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

      // generators limit
      if (not tu^.uid^.uid_isbuilder)
      and(tu^.uid^.uid_gen_EnergyLevel>0)then
        ai_generators_limit+=tu^.uid^.uid_LimitUse;

      // towers
      if(tu^.uid^.uid_isbuilding)and(tu^.uid^.uid_CanAttack)then
        if(not tu^.uid^.uid_isbuilder)then
          ai_curr_Towers+=1;

      // unit productions
      if(tu^.uid^.uid_isbarrack)then ai_curr_UnitProds+=tu^.level+1;
      // upgrade productions
      if(tu^.uid^.uid_isforge  )then ai_curr_UpgrProds+=tu^.level+1;

      // units in groups
      if(not tu^.uid^.uid_isbuilding)then
        if(tu^.group<=MaxUnitGroups)then
        begin
           ai_group_ucount[tu^.group]+=1;
           ai_group_ulimit[tu^.group]+=tu^.uid^.uid_LimitUse;
        end;
   end;
end;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      pfcheck:=(isfly)or(mapZone=tu^.mapZone);
      if(tu^.hits>0)then
      begin
         if(tu_transport=nil)then
         begin
            if(team=tu^.player^.team)
            then for_AliveOTransportAllies
            else for_AliveOTransportEnemy;

            if(playeri=tu^.playeri)
            then for_AliveOTransportOwn;
         end;

         if(player=tu^.player)then for_AliveOwn;
      end
      else
        if(player=tu^.player)then
          ai_ownDead_limit+=tu^.uid^.uid_LimitUse;

     {
     if(tu^.uid^.uid_ZombieUID>0)and(pfcheck)then
       if(hits_fdead<tu^.hits)and(tu^.hits<=tu^.uid^.uid_ZombieHits)then _setNearestTarget(@ai_ZombieTarget_u,@ai_ZombieTarget_d,ud);
     }
   end;
end;
{


procedure ai_Global_ScoutPick(pu:PTUnit);
var w:integer;
   tu:PTUnit;
begin
   if(map_scenario=mc_KotH    )
   or(map_scenario=mc_KeyPoints)
   or(map_scenario=mc_royale  )then exit;

   with pu^ do
   begin
      if(hits<=0)
      or(speed<=0)
      or(uid^.uid_isbuilding)
      or(not iscomplete)
      or(transportM>0)then exit;

      if((player^.ai_flags and aif_army_scout)=0)then exit;

      if(IsUnitRange(transportU,nil))then exit;
   end;

   w:=GetWeaponPriority(pu,wtp_Scout,false);
   if(w>0)then
    with pu^.player^ do
     if(w>ai_scout_u_new_w)then
     begin
        ai_scout_u_new_w:=w;
        ai_scout_u_new  :=pu^.unum;
     end
     else
       if(w=ai_scout_u_new_w)then
        if(IsUnitRange(ai_scout_u_new,@tu))then
         if(pu^.speed>tu^.speed)then ai_scout_u_new:=pu^.unum;
end;
                   }


