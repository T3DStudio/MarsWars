
const

aic_MaxLimitBorder         = MaxPlayerLimit-ul5;

aic_GeneratorsLimit        = ul1*30;
aic_GeneratorsEnergy       = 9000;
aic_GeneratorsDestroyEnergy= 10000;
aic_GeneratorsDestoryLimit = ul1*35;

aic_TowerLifeTime          = fr_fps1*60;/// ???????

aic_BaseIdle_r             = 50;

aic_max_SpecUID            = 5;

aic_group_Home             = 0;
aic_group_AttackNow        = 1;
aic_group_AttackWait       = 2;
aic_group_Scout            = 3;
aic_group_Transport        = 4;
aic_group_GenAssault       = 5;
aic_group_GenGuard         = 6;
aic_group_GenWait          = 7;

MaxAIGroups                = 7;

var

ai_GroupAll_ucount   : array[0..MaxAIGroups] of integer;
ai_GroupAll_ulimit   : array[0..MaxAIGroups] of longint;
ai_GroupIn_ulimit    : array[0..MaxAIGroups] of longint;


ai_choosen,
ai_flags_BaseAMain,
ai_flags_BaseAOther,
ai_available_HKeep
                     : boolean;

ai_generator_kp,
ai_keypoint_kp       : pTKeyPoint;

ai_generators_limit,
ai_enemylimit_baseR2_grd,
ai_enemylimit_baseR2_fly,

ai_enemylimit_flyMech,
ai_enemylimit_fly,
ai_enemylimit_groundMech,
ai_enemylimit_groundBio,
ai_enemylimit_Towers,

ai_armylimit_ForTeleport,
ai_armylimit_siedge,
ai_armylimit_alive_u,
ai_armylimit_alive_b,
ai_armylimit_fly,

ai_AttackGroupFlyLimit,

ai_curr_detect,
ai_need_detect,

ai_transport_cur,
ai_transport_need,

ai_nearGenGuards

                     : longint;

ai_UpgradesLeft,
ai_AvailableDetectors,
ai_generator_d,
ai_generator_n,
ai_keypoint_d,
ai_keypoint_n,


ai_commander_grd_d,
ai_commander_fly_d,

ai_BaseOwn_d,
ai_BaseAlly_d,
ai_BaseDef_d,

ai_HealTar_d,
ai_RepairTar_d,

ai_enemy_d,
ai_enemy_air_d,
ai_enemy_grd_d,
ai_enemy_inv_d,
ai_enemy_build_d,
ai_enemy_battle_d,

ai_ZombieTarget_d,

ai_need_heye_d,

ai_energy_future,
ai_energy_current,

ai_curr_Builders,
ai_curr_UnitProds,
ai_curr_UpgrProds,
ai_curr_Towers,

ai_towers_near_AG,
ai_towers_near_AA,

ai_near_detect,

ai_need_Energy,
ai_need_UnitProds,
ai_need_UpgrProds,
ai_need_Teleports,

ai_near_HEye,

ai_HTeleportRecall_d,
ai_HTeleportNearest_d,
ai_HTeleportRemote_d,
ai_HTeleportTarget_d,
ai_HTeleportTarKOTH_d,

ai_TransportTar_Attack_d,
ai_TransportTar_BDefend_d,
ai_TransportTar_GenTeam_d,

ai_selfUID_nocomplete,
ai_selfUID_minLevel,

ai_UnitsInTransform
                     : integer;

ai_MinBuildAttempts:byte;

ai_commander_grd_u,
ai_commander_fly_u,

ai_BaseOwn_u,
ai_BaseAlly_u,
ai_BaseDef_u,

ai_HealTar_u,
ai_RepairTar_u,

ai_enemy_u,
ai_enemy_air_u,
ai_enemy_grd_u,
ai_enemy_inv_u,
ai_enemy_build_u,
ai_enemy_battle_u,

ai_ZombieTarget_u,

ai_need_heye_u,

ai_HEyeNest_u,

ai_Strike_u,
ai_Bribe_u,
ai_Hack_u,
ai_Heroic_u,

ai_SphereSoul_u,
ai_SphereInvis_u,
ai_SphereInvuln_u,

ai_SphereRDamage_u,
ai_SphereDDamage_u,
ai_SphereTurbo_u,

ai_HTeleportRecall_u,
ai_HTeleportNearest_u,
ai_HTeleportRemote_u,
ai_HTeleportTarget_u,
ai_HTeleportTarKOTH_u,
ai_HTeleportTarGen_u,

ai_ScoutCandidate_u,

ai_TransportTar_Attack_u,
ai_TransportTar_BDefend_u,
ai_TransportTar_GenTeam_u,

ai_PrimaryTarget_u

                  : PTUnit;



ai_Strike_w
                  : byte;

////////////////////////////////////////////////////////////////////////////////
//
//   AI OTHER COMMON
//

function ai_IsAvailableUID(player:PTPlayerGameData;uid:byte):boolean;
begin
   case CheckUnitReqs(player,uid) of
   0,
   lmt_Req_Limit,
   lmt_Req_HellPower,
   lmt_Req_UACLoot,
   lmt_Req_Energy,
   lmt_Req_MaxCount : ai_IsAvailableUID:=(player^.aip_MaxEnergy  >=g_uids[uid].uid_req_EnergyLevel)
                                       or(player^.res_energyl_max>=g_uids[uid].uid_req_EnergyLevel);
   else               ai_IsAvailableUID:=false;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   AI ALARMS DATA
//

procedure ai_Alarm_SetForTeam(team:byte;ax,ay:integer;alimit:longint;arange:integer;abase:boolean;apfzone:word);
var a,
anobase,
afree  :byte;
begin
   afree  :=255;
   anobase:=255;  //no base alarm, low priority, can be replaced by base alarm
   ax     :=mm3i(1,ax,map_Size1);
   ay     :=mm3i(1,ay,map_Size1);
   for a:=0 to ai_LastAlarm do
     with ai_TeamAlarms[team,a] do
       if(alimit<=0)then
       begin
          if(aia_limit>0)then
            if(point_dist_rint(ax,ay,aia_x,aia_y)<arange)then aia_limit:=0
       end
       else
         if(aia_limit<=0)
         then afree:=a
         else
         begin
            if(not aia_base)then anobase:=a;
            if(point_dist_rint(ax,ay,aia_x,aia_y)<arange)then exit;
         end;

   if(alimit>0)then
   begin
      a:=255;
      if(afree<=ai_LastAlarm)
      then a:=afree
      else
        if(anobase<=ai_LastAlarm)
        then a:=anobase
        else exit;

      with ai_TeamAlarms[team,a] do
      begin
         aia_x    :=ax;
         aia_y    :=ay;
         aia_limit:=alimit;
         aia_base :=abase;
         aia_zone :=apfzone;
      end;
   end;
end;

procedure ai_SetScirmishStartAlarms(p:byte);
var i:byte;
begin
   for i:=0 to map_MaxPlayers-1 do
     if(i<>p)then
     begin
        if(g_FixedPositions)then
        begin
           if(g_PlayersMain[i].state=ps_None)then continue;
           if(g_PlayersMain[i].team=g_PlayersMain[p].team)then continue;
        end;
        ai_Alarm_SetForTeam(g_PlayersMain[p].team,map_PlayerStartX[i],map_PlayerStartY[i],1,base_r1,true,map_GetZone(map_PlayerStartX[i],map_PlayerStartY[i]));
     end;
end;

function ai_alarm_CheckPoint(pu:PTUnit;tx,ty,tr:integer):boolean;
var a:byte;
begin
   ai_alarm_CheckPoint:=true;
   with pu^ do
   begin
      if(aiu_alarm_d<NOTSET)then
        if(point_dist_rint(tx,ty,aiu_alarm_x,aiu_alarm_y)<tr)then exit;

      for a:=0 to ai_LastAlarm do
        with ai_TeamAlarms[player^.team,a] do
          if(aia_limit>0)then
            if(point_dist_rint(tx,ty,aia_x,aia_y)<tr)then exit;
   end;
   ai_alarm_CheckPoint:=false;
end;

////////////////////////////////////////////////////////////////////////////////

procedure  ai_PlayerSetSkirmishSettings(p:byte);
procedure SetBaseOpt(aMaxEnergy,aMaxBuilders,aMaxBarracks,aMaxForges,aMaxDetectors,aMinTowers,aMaxTowers,aMaxSuper,aMaxArmyLimit,aAttackPause,aDetectionPause,aSpecialPause:integer);
begin
   with g_PlayersMain[p] do
   begin
      aip_MaxEnergy        :=aMaxEnergy;
      aip_MaxBuilders      :=aMaxBuilders;
      aip_MaxBarracks      :=aMaxBarracks;
      aip_MaxForges        :=aMaxForges;
      aip_MaxDetectors     :=aMaxDetectors*ul1;
      aip_MinTowers        :=aMinTowers;
      aip_MaxTowers        :=aMaxTowers;
      aip_MaxSuper         :=random(aMaxSuper+1);
      aip_MaxUnitLimit     :=aMaxArmyLimit*ul1;
      aip_pause_attack     :=max2i(fr_fps1,fr_fps1*aAttackPause   );
      aip_pause_detection  :=max2i(fr_fps1,fr_fps1*aDetectionPause);
      aip_pause_magic      :=max2i(fr_fps1,fr_fps1*aSpecialPause  );
      aip_pause_superweapon:=max2i(fr_fps1,fr_fps1*aSpecialPause  );

      aip_MaxUnitMinPart   :=mm3i(keyPoint_MinLimit,aip_MaxUnitLimit div 4,keyPoint_MaxLimitAI);
   end;
end;
begin
   with g_PlayersMain[p] do
   begin
      case aip_skill of
      //              energy buil bar   forges dete  min   max            pause
      //                     ders racks        ctors tower tower     army  atta det  spec
      0  : SetBaseOpt(0     ,0   ,0    ,0     ,0    ,0    ,0    ,0  ,0    ,0   ,0   ,0   );//,0    ,0    ,0    ,0    ,0      ,0       ,0    ,0     ,0     ,0          ,0             ,0  ,[]);
      1  : SetBaseOpt(600   ,1   ,1    ,0     ,0    ,1    ,1    ,0  ,10   ,150 ,60  ,240 );//,0    ,0    ,0    ,0    ,0      ,0       ,1    ,1     ,10    ,fr_fps1*120,12            ,0  ,[]);
      2  : SetBaseOpt(3000  ,2   ,5    ,1     ,3    ,6    ,6    ,0  ,40   ,100 ,30  ,180 );//,0    ,0    ,0    ,6    ,0      ,1       ,6    ,6     ,40    ,fr_fps1*40 ,45            ,1  ,[]);
      3  : SetBaseOpt(6000  ,3   ,12   ,3     ,8    ,6    ,10   ,1  ,65   ,50  ,20  ,120 );//,0    ,1    ,1    ,10   ,1      ,2       ,10   ,14    ,65    ,1          ,70            ,3  ,[UID_Pain,UID_ArchVile,UID_Medic,UID_ZMedic,UID_Engineer,UID_ZEngineer,UID_BFGMarine,UID_ZBFGMarine]);
      4  : SetBaseOpt(7500  ,4   ,16   ,4     ,10   ,6    ,12   ,2  ,125  ,0   ,10  ,80  );//,1    ,1    ,1    ,12   ,1      ,2       ,5    ,14    ,120   ,1          ,MaxPlayerUnits,4  ,[UID_Pain,UID_ArchVile,UID_Medic,UID_ZMedic,UID_Engineer,UID_ZEngineer,UID_BFGMarine,UID_ZBFGMarine]);
      else SetBaseOpt(9400  ,4   ,20   ,6     ,12   ,6    ,14   ,3  ,125  ,0   ,0   ,0   );//,1    ,1    ,1    ,12   ,2      ,2       ,5    ,14    ,120   ,1          ,MaxPlayerUnits,15 ,[UID_Pain,UID_ArchVile,UID_Medic,UID_ZMedic,UID_Engineer,UID_ZEngineer,UID_BFGMarine,UID_ZBFGMarine]);
      end;
      //aic_max_SpecUID:=aip_skill-1;
      if(aip_skill>1)
      then aip_MaxUpgradeLevel:=aip_skill
      else aip_MaxUpgradeLevel:=0;

      case aip_skill of
      0  :;
      1  : aip_flags:=aif_allies_help;
      2  : aip_flags:=aif_army_scout
                     +aif_base_advanceMain
                     +aif_allies_help;
      3  : aip_flags:=aif_army_scout
                     +aif_base_smart_order
                     +aif_base_advanceOther
                     +aif_base_advanceMain
                     +aif_ability_detection
                     +aif_allies_help;
      4  : aip_flags:=aif_army_scout
                     +aif_army_smart_order
                     +aif_base_suicide
                     +aif_base_smart_order
                     +aif_base_advanceOther
                     +aif_base_advanceMain
                     +aif_base_BuilderMove
                     +aif_ability_detection
                     +aif_ability_other
                     +aif_allies_help;
      else aip_flags:=aif_base_smart_order
                     +aif_base_suicide
                     +aif_base_advanceOther
                     +aif_base_advanceMain
                     +aif_base_BuilderMove
                     +aif_army_scout
                     +aif_army_smart_order
                     +aif_army_smart_micro
                     +aif_army_smart_Target
                     +aif_upgr_smart_order
                     +aif_ability_detection
                     +aif_ability_other
                     +aif_ability_TowerRush
                     +aif_allies_help;
      end;
      case aip_skill of
      6 : begin
          aip_flags+=aif_cheat_VisBuildings;
          end;
      7 : begin
          aip_flags+=aif_cheat_VisBuildings;
          aip_flags+=aif_cheat_VisUnits;
          upgrs_cur[upgr_mult_product]:=1;
          end;
      8 : begin
          aip_flags+=aif_cheat_VisBuildings;
          aip_flags+=aif_cheat_VisUnits;
          upgrs_cur[upgr_mult_product]:=1;
          upgrs_cur[upgr_fast_product]:=1;
          end;
      9 : begin
          aip_flags+=aif_cheat_VisBuildings;
          aip_flags+=aif_cheat_VisUnits;
          upgrs_cur[upgr_mult_product]:=1;
          upgrs_cur[upgr_fast_product]:=1;
          upgrs_cur[upgr_fast_build  ]:=1;
          end;
      end;
   end;
   ai_SetScirmishStartAlarms(p);
end;

{function ai_HighPriorityTarget(player:PTPlayerGameData;tu:PTUnit):boolean;
begin
   ai_HighPriorityTarget:=false;
   if(player^.state=ps_AI)then
     if(player^.aip_flags and aif_army_smart_prio)>0 then
       ai_HighPriorityTarget:=(tu^.uidi in player^.ai_hptargets)or(tu^.uid^.uid_gen_EnergyLevel>0);
end;   }


////////////////////////////////////////////////////////////////////////////////
//
//   INIT VARS
//

procedure ai_Local_InitVars(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      aiu_alarm_d          :=NOTSET;
      aiu_alarm_x          :=-1;
      aiu_alarm_y          :=-1;
      aiu_alarm_zone       := 0;
      aiu_NeedDetect       :=NOTSET;
      aiu_limitaround_ally :=0;
      aiu_limitaround_enemy:=0;
   end;

   ai_enemy_u:= nil;
   ai_enemy_d:= NOTSET;
end;


procedure ai_Local_SetCurrentAlarm(pu,tar_u:PTUnit;tar_x,tar_y,tar_dist:integer;tar_zone:word);
begin
   with pu^ do
     if(tar_dist<aiu_alarm_d)then
     begin
        if(tar_u<>nil)then
        begin
           tar_x   :=tar_u^.x;
           tar_y   :=tar_u^.y;
           tar_zone:=tar_u^.mapZone;
        end;
        aiu_alarm_x   :=tar_x;
        aiu_alarm_y   :=tar_y;
        aiu_alarm_d   :=tar_dist;
        aiu_alarm_zone:=tar_zone;
     end;
end;

function ai_CalcUpgradesLeft(pPlayer:PTPlayerGameData):integer;
var u,maxLvl:byte;
begin
   ai_CalcUpgradesLeft:=0;
   with pPlayer^ do
     for u:=1 to 255 do
       with g_upgrs[u] do
         if(upgr_max>0)and(upgr_race=race)then
         begin
            if(upgr_max<upgrs_max[u])
            then maxLvl:=upgr_max
            else maxLvl:=upgrs_max[u];
            if(upgr_max>aip_MaxUpgradeLevel)
            then maxLvl:=aip_MaxUpgradeLevel;

            if(upgrs_cur[u]<maxLvl)then
              ai_CalcUpgradesLeft+=1;
         end;
end;

procedure ai_SetKeyPoint(pcurkp:ppTKeyPoint;pcurd:pinteger;newkp:pTKeyPoint;newd:integer;tu:PTUnit);
begin
   if(pcurkp^=nil)
   then
   else
     if((newkp^.kp_Zone=tu^.mapZone)or tu^.isfly)>((pcurkp^^.kp_Zone=tu^.mapZone)or tu^.isfly)
     then
     else
     if((newkp^.kp_Zone=tu^.mapZone)or tu^.isfly)<((pcurkp^^.kp_Zone=tu^.mapZone)or tu^.isfly)
     then exit
     else
       if(newd<pcurd^)
       then
       else
       if(newd>pcurd^)
       then exit;

   pcurkp^:=newkp;
   pcurd^ :=newd;
end;

procedure ai_Global_InitVars(pu:PTUnit);
var i,d   :integer;
koth_point:boolean;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      ai_flags_BaseAMain   :=(aip_flags and aif_base_advanceMain )>0;
      ai_flags_BaseAOther  :=(aip_flags and aif_base_advanceOther)>0;
      ai_choosen           :=(units_uid_c[uidi]>1)and(unum=units_uid_u[uidi]);
      ai_AvailableDetectors:= units_uid_e[UID_HEyeNest]+units_uid_e[UID_URadar];
      ai_UpgradesLeft      := ai_CalcUpgradesLeft(player);

      ai_available_HKeep   := ai_IsAvailableUID(player,UID_HKeep);
   end;

   FillChar(ai_GroupAll_ucount,SizeOf(ai_GroupAll_ucount),0);
   FillChar(ai_GroupAll_ulimit,SizeOf(ai_GroupAll_ulimit),0);
   FillChar(ai_GroupIn_ulimit ,SizeOf(ai_GroupIn_ulimit ),0);

   ai_enemylimit_baseR2_fly:= 0;
   ai_enemylimit_baseR2_grd:= 0;
   ai_enemylimit_flyMech   := 0;
   ai_enemylimit_fly       := 0;
   ai_enemylimit_groundMech:= 0;
   ai_enemylimit_groundBio := 0;
   ai_enemylimit_Towers    := 0;

   ai_armylimit_ForTeleport:= 0;
   ai_armylimit_siedge     := 0;
   ai_armylimit_alive_u    := 0;
   ai_armylimit_alive_b    := 0;
   ai_armylimit_fly        := 0;

   ai_nearGenGuards        := 0;

   ai_AttackGroupFlyLimit  := 0;

   // transport
   ai_transport_cur        := 0;
   ai_transport_need       := 0;
   with pu^ do
   with player^ do
     for i:=1 to 255 do
     begin
        if(prod_unit_uid[i]>0)then
          with g_uids[i] do
          begin
             // transportU in production
             if(uid_isfly)
             and(not uid_isbuilding)then
             begin
                if(uid_TransportMax_Base>0)then ai_transport_cur+=uid_TransportMax_Base*prod_unit_uid[i];
                if(uid_CanAttack)then ai_armylimit_fly+=uid_LimitUse*prod_unit_uid[i];
             end;

             if(uid_AI_Siedge)then ai_armylimit_siedge+=uid_LimitUse*prod_unit_uid[i];
          end;
        if(units_uid_c[i]>0)then
          with g_uids[i] do
            if(uid_AI_Siedge)then
              ai_armylimit_siedge+=uid_LimitUse*units_uid_c[i];
     end;

   // scout candidate
   ai_ScoutCandidate_u:= nil;

   // enemy
   ai_enemy_air_u    := nil;
   ai_enemy_air_d    := NOTSET;
   ai_enemy_grd_u    := nil;
   ai_enemy_grd_d    := NOTSET;
   ai_enemy_inv_u    := nil;
   ai_enemy_inv_d    := NOTSET;
   ai_enemy_build_u  := nil;
   ai_enemy_build_d  := NOTSET;
   ai_enemy_battle_u := nil;
   ai_enemy_battle_d := NOTSET;

   ai_PrimaryTarget_u:= nil;

   // repair/heal target
   ai_HealTar_u      := nil;
   ai_HealTar_d      := NOTSET;
   ai_RepairTar_u    := nil;
   ai_RepairTar_d    := NOTSET;

   // key points
   ai_keypoint_kp    := nil;
   ai_keypoint_d     := NOTSET;
   ai_keypoint_n     := 0;

   ai_generator_kp   := nil;
   ai_generator_d    := NOTSET;
   ai_generator_n    := 0;

   // energy
   ai_energy_future  := 0;
   ai_energy_current := 0;

   ai_generators_limit:=0;
   // generators limit
   with pu^.player^ do
     for i:=1 to 255 do
       with g_uids[i] do
         if(not uid_isbuilder)and(uid_gen_EnergyLevel>0)then
           ai_generators_limit+=units_uid_e[i]*uid_LimitUse;

   // nearest point/generator
   with pu^ do
   with uid^ do
   with player^ do
     if(map_KeyPointsN>0)then
       for i:=0 to map_KeyPointsN-1 do
         with map_KeyPointsL[i] do
         with kp_TeamData[team] do
          if(kptd_Active)then
          begin
             if(kptd_OwnerPlayer=playeri)then
             begin
                if(kp_Energy>0)then
                begin
                   ai_energy_future +=kp_Energy;
                   ai_energy_current+=kp_Energy;
                   ai_generator_n   +=1;
                end
                else ai_keypoint_n+=1;
             end;

             if(map_scenario=mc_royale)then
               if(g_royal_r<(kp_ToCenterD+kp_RCapture))then continue;
             if(kp_x<=0)
             or(kp_y<=0)
             or(kp_x>=map_Size1)
             or(kp_y>=map_Size1)then continue;

             if(transportM>0)
             or(not isfly)then
               if(map_IfObstacleZone(kp_zone))then continue;

             if((kptd_OwnerTeam     <=LastPlayer)and(kptd_OwnerTeam     <>team))
             or((kptd_TimerOwnerTeam<=LastPlayer)and(kptd_TimerOwnerTeam<>team)and(kptd_Timer>0))then
               if(isfly)
               or(kp_zone=mapZone)then
                 ai_Local_SetCurrentAlarm(pu,nil,kp_x,kp_y,point_dist_int(kp_x,kp_y,x,y),kp_zone);

             koth_point:=(i=0)and(map_scenario=mc_KotH)and(g_tick>=keyPoint_KotH_pause);

             if(not koth_point)then
             begin
                if(kptd_OwnerTeam=team)and(kptd_OwnerPlayer<>playeri)then continue;
                if(kptd_Timer>0)then
                  if(kptd_TimerOwnerTeam=team)and(kptd_TimerOwnerPlayer<>playeri)then continue;
             end;

             d:=point_dist_int(kp_x,kp_y,x,y);

             if(not koth_point)then
               if((kp_LimitTeamP[team]>=(keyPoint_MinLimit  +uid_LimitUse))and(d> kp_RCapture))
               or((kp_LimitTeamP[team]> (keyPoint_MaxLimitAI+uid_LimitUse))and(d<=kp_RCapture))then continue;

             case(kp_Energy>0)and(not koth_point)of
             true : ai_SetKeyPoint(@ai_generator_kp,@ai_generator_d,@map_KeyPointsL[i],d,pu);
             false: ai_SetKeyPoint(@ai_keypoint_kp ,@ai_keypoint_d ,@map_KeyPointsL[i],d,pu);
             end;
          end;

  { ai_PhantomWantZombieMe:=false; }

   ai_ZombieTarget_d        := NOTSET;
   ai_ZombieTarget_u        := nil;

   // commander
   ai_commander_grd_d       := NOTSET;
   ai_commander_grd_u       := nil;
   ai_commander_fly_d       := NOTSET;
   ai_commander_fly_u       := nil;

   // nearest own building
   ai_BaseOwn_d             := NOTSET;
   ai_BaseOwn_u             := nil;

   // nearest ally building
   ai_BaseAlly_d            := NOTSET;
   ai_BaseAlly_u            := nil;

   // nearest own building with alarm
   ai_BaseDef_d             := NOTSET;
   ai_BaseDef_u             := nil;

   // transport target
   ai_TransportTar_Attack_d :=NOTSET;
   ai_TransportTar_Attack_u :=nil;
   ai_TransportTar_BDefend_d:=NOTSET;
   ai_TransportTar_BDefend_u:=nil;
   ai_TransportTar_GenTeam_d:=NOTSET;
   ai_TransportTar_GenTeam_u:=nil;

   // teleporter
   ai_HTeleportRecall_d     := NOTSET;
   ai_HTeleportRecall_u     := nil;
   ai_HTeleportNearest_d    := NOTSET;
   ai_HTeleportNearest_u    := nil;
   ai_HTeleportRemote_d     := NOTSET;
   ai_HTeleportRemote_u     := nil;
   ai_HTeleportTarget_d     := NOTSET;
   ai_HTeleportTarget_u     := nil;
   ai_HTeleportTarKOTH_d    := NOTSET;
   ai_HTeleportTarKOTH_u    := nil;
   ai_HTeleportTarGen_u     := nil;

   // 'Magic' targets
   ai_Strike_u              := nil;
   ai_Strike_w              := 0;
   ai_Bribe_u               := nil;
   ai_Hack_u                := nil;
   ai_Heroic_u              := nil;

   ai_SphereSoul_u          := nil;
   ai_SphereInvis_u         := nil;
   ai_SphereInvuln_u        := nil;

   ai_SphereRDamage_u       := nil;
   ai_SphereDDamage_u       := nil;
   ai_SphereTurbo_u         := nil;

   // Hell Vision target
   ai_need_heye_d           := NOTSET;
   ai_need_heye_u           := nil;

   ai_near_HEye             := 0;
   ai_HEyeNest_u            := nil;

   // build needs
   ai_curr_Builders         := pu^.player^.units_builders_e;

   ai_curr_UnitProds        := 0;  // unit production
   ai_need_UnitProds        := 0;

   ai_curr_UpgrProds        := 0;  // upgrade production
   ai_need_UpgrProds        := 0;

   ai_curr_Towers           := 0;  // towers
   with pu^.player^ do
     for i:=1 to 255 do
       with g_uids[i] do
         if(uid_isbuilding)and(uid_CanAttack)and(not uid_isbuilder)then
           ai_curr_Towers+=units_uid_e[i];

   ai_towers_near_AG        := 0;
   ai_towers_near_AA        := 0;


   with pu^.player^ do
   ai_curr_detect           :=(units_uid_e[UID_URadar  ]*g_uids[UID_URadar  ].uid_LimitUse)+
                              (units_uid_e[UID_HEyeNest]*g_uids[UID_HEyeNest].uid_LimitUse);
   ai_near_detect           := 0;
   ai_need_detect           := 0;

   ai_need_Teleports        := 0;

   ai_MinBuildAttempts      := 255;

   ai_UnitsInTransform      := 0;

   ai_selfUID_minLevel:=LastUnitLevel;
   with pu^ do
   with player^ do
     ai_selfUID_nocomplete  := units_uid_e[uidi]-units_uid_c[uidi];
end;

////////////////////////////////////////////////////////////////////////////////
//
//   COMMON AI FUNCS
//

function ai_UnitAbility(pCaster:PTUnit;aid:byte;atar,ax,ay:integer):boolean;
begin
   unit_SetAbilityOrder(pCaster,aid,atar,ax,ay,false);
   ai_UnitAbility:=unit_AbilityExec(pCaster,aid)=0;
   //with pCaster^ do
   //  if(isselected)and(aid=uab_ToUACommandCenter)then writeln('uab_ToUACommandCenter ',t);
   if(pCaster^.buffs[ub_Cast]<=0)then
     unit_OrderClear(pCaster,ua_amove);
end;

function ai_IsProducting(pu:PTUnit):boolean;
var i:byte;
begin
   ai_IsProducting:=false;
   with pu^  do
   with uid^ do
     for i:=0 to LastUnitLevel do
     begin
        if(i>level)then break;
        if((uid_isbarrack)and(uprod_r[i]>0))
        or((uid_isforge  )and(pprod_r[i]>0))then
        begin
           ai_IsProducting:=true;
           exit;
        end;
     end;
end;

function ai_GetLevel(pu:PTUnit):byte;
begin
   with pu^ do
     if(transformTimer>0)and(transformUID=uidi)and(level<MaxUnitLevel)
     then ai_GetLevel:=level+1
     else ai_GetLevel:=level;
end;


procedure ai_timer(y:pinteger;RepeatValue:integer);
begin
   if(y^>0)then
   begin
      y^-=order_period;
      if(y^=0)then y^:=-1;
   end
   else
     if(y^<0)then y^:=RepeatValue;
end;

////  'MAGIC' targets


procedure ai_SetTarget_Strike(newu:PTUnit);
var weight:byte;
begin
   with newu^ do
   with uid^ do
   begin
      if((uo_x=x)and(uo_y=y))
      or(speed<10)
      then
      else exit;

      weight:=0;

      if(iscomplete    )then weight+=128;
      if(uid_isBuilder )then weight+=64;
      if(uid_isBuilding)then weight+=32;
      if(uid_CanAttack )then weight+=16;
   end;

   if(ai_Strike_u=nil)
   then
   else
     if(weight>ai_Strike_w)
     then
     else
       if(weight<ai_Strike_w)
       then exit
       else
         if(newu^.hits>ai_Strike_u^.hits)
         then
         else exit;

   ai_Strike_w:=weight;
   ai_Strike_u:=newu;
end;

// UAC Academy
procedure ai_SetTarget_Bribe(newu:PTUnit);
begin
   if(ai_Bribe_u=nil)
   then
   else
     if(newu^.uid^.uid_LimitUse>ai_Bribe_u^.uid^.uid_LimitUse)
     then
     else
       if(newu^.uid^.uid_LimitUse<ai_Bribe_u^.uid^.uid_LimitUse)
       then exit
       else
         if(newu^.hits>ai_Bribe_u^.hits)
         then
         else exit;

   ai_Bribe_u:=newu;
end;
procedure ai_SetTarget_Hack(newu:PTUnit);
begin
   with newu^ do
   with uid^ do
     if(uid_CanAttack)
     or(uid_gen_EnergyLevel<=0)
     then
     else exit;

   if(ai_Hack_u=nil)
   then
   else
     if(newu^.uid^.uid_isbuilder>ai_Hack_u^.uid^.uid_isbuilder)
     then
     else
     if(newu^.uid^.uid_isbuilder<ai_Hack_u^.uid^.uid_isbuilder)
     then exit
     else
       if(newu^.uid^.uid_CanAttack>ai_Hack_u^.uid^.uid_CanAttack)
       then
       else
       if(newu^.uid^.uid_CanAttack<ai_Hack_u^.uid^.uid_CanAttack)
       then exit
       else
         if(newu^.hits>ai_Hack_u^.hits)
         then
         else exit;

   ai_Hack_u:=newu;
end;
procedure ai_SetTarget_UACGeneral(newu:PTUnit);
begin
   if(ai_Heroic_u=nil)
   then
   else
     if(newu^.uid^.uid_CanAttack>ai_Heroic_u^.uid^.uid_CanAttack)
     then
     else
     if(newu^.uid^.uid_CanAttack<ai_Heroic_u^.uid^.uid_CanAttack)
     then exit
     else
       if(newu^.uid^.uid_LimitUse>ai_Heroic_u^.uid^.uid_LimitUse)
       then
       else
       if(newu^.uid^.uid_LimitUse<ai_Heroic_u^.uid^.uid_LimitUse)
       then exit
       else
         if(newu^.hits>ai_Heroic_u^.hits)
         then
         else exit;

   ai_Heroic_u:=newu;
end;

// Hellpower conductor
procedure ai_SetTarget_SphereSoul(newu:PTUnit);
begin
   with newu^ do
   with uid^ do
     if((uid_MaxHits1-hits)<1000)then exit;

   if(ai_SphereSoul_u=nil)
   then
   else
     if(newu^.uid^.uid_CanAttack>ai_SphereSoul_u^.uid^.uid_CanAttack)
     then
     else
       if(newu^.uid^.uid_CanAttack<ai_SphereSoul_u^.uid^.uid_CanAttack)
       then exit
       else
         if(newu^.uid^.uid_LimitUse>ai_SphereSoul_u^.uid^.uid_LimitUse)
         then
         else
           if(newu^.uid^.uid_LimitUse<ai_SphereSoul_u^.uid^.uid_LimitUse)
           then exit
           else
             if(newu^.hits<ai_SphereSoul_u^.hits)
             then
             else exit;

   ai_SphereSoul_u:=newu;
end;

procedure ai_SetTarget_SphereInvis(newu:PTUnit);
begin
   with newu^ do
   with uid^ do
     if(aiu_limitaround_enemy<aiu_limitaround_ally)
     or(aiu_alarm_d>srange)
     or(not newu^.uid^.uid_CanAttack and (newu^.buffs[ub_damaged]<=0))
     or(buffs[ub_SphereInvuln]>0)
     then exit;

   // scout or harrasment groups in first
   if(ai_SphereInvis_u=nil)
   then
   else
     if(newu^.uid^.uid_CanAttack>ai_SphereInvis_u^.uid^.uid_CanAttack)
     then
     else
       if(newu^.uid^.uid_CanAttack<ai_SphereInvis_u^.uid^.uid_CanAttack)
       then exit
       else
         if(newu^.uid^.uid_LimitUse>ai_SphereInvis_u^.uid^.uid_LimitUse)
         then
         else
           if(newu^.uid^.uid_LimitUse<ai_SphereInvis_u^.uid^.uid_LimitUse)
           then exit
           else
             if(newu^.hits<ai_SphereInvis_u^.hits)
             then
             else exit;

   ai_SphereInvis_u:=newu;
end;

procedure ai_SetTarget_SphereInvuln(newu:PTUnit);
begin
   with newu^ do
   with uid^ do
     if(aiu_limitaround_enemy<aiu_limitaround_ally)
     or(aiu_alarm_d>srange)
     or(not uid_CanAttack)
     then exit;

   if(ai_SphereInvuln_u=nil)
   then
   else
     if(newu^.uid^.uid_LimitUse>ai_SphereInvuln_u^.uid^.uid_LimitUse)
     then
     else
       if(newu^.uid^.uid_LimitUse<ai_SphereInvuln_u^.uid^.uid_LimitUse)
       then exit
       else
         if(newu^.hits<ai_SphereInvuln_u^.hits)
         then
         else exit;

   ai_SphereInvuln_u:=newu;
end;

// Hell altar
procedure ai_SetTarget_SphereRDamage(newu:PTUnit);
begin
   with newu^ do
   with uid^ do
     if(aiu_limitaround_enemy<aiu_limitaround_ally)
     or(aiu_alarm_d>srange)
     or(not uid_CanAttack)
     or(buffs[ub_damaged]<=0)
     then exit;

   if(ai_SphereRDamage_u=nil)
   then
   else
     if(newu^.uid^.uid_LimitUse>ai_SphereRDamage_u^.uid^.uid_LimitUse)
     then
     else
       if(newu^.uid^.uid_LimitUse<ai_SphereRDamage_u^.uid^.uid_LimitUse)
       then exit
       else
         if(newu^.hits<ai_SphereRDamage_u^.hits)
         then
         else exit;

   ai_SphereRDamage_u:=newu;
end;

procedure ai_SetTarget_SphereDDamage(newu:PTUnit);
begin
   with newu^ do
   with uid^ do
     if(aiu_limitaround_enemy<aiu_limitaround_ally)
     or(aiu_alarm_d>srange)
     or(not uid_CanAttack)
     or(buffs[ub_damaged]<=0)
     then exit;

   if(ai_SphereDDamage_u=nil)
   then
   else
     if(newu^.uid^.uid_LimitUse>ai_SphereDDamage_u^.uid^.uid_LimitUse)
     then
     else
       if(newu^.uid^.uid_LimitUse<ai_SphereDDamage_u^.uid^.uid_LimitUse)
       then exit
       else
         if(newu^.hits<ai_SphereDDamage_u^.hits)
         then
         else exit;

   ai_SphereDDamage_u:=newu;
end;

procedure ai_SetTarget_SphereTurbo(newu:PTUnit);
begin
   with newu^ do
   with uid^ do
     if(aiu_limitaround_enemy<aiu_limitaround_ally)
     or(aiu_alarm_d>srange)
     or(not uid_CanAttack)
     then exit;

   if(ai_SphereTurbo_u=nil)
   then
   else
     if(newu^.uid^.uid_LimitUse>ai_SphereTurbo_u^.uid^.uid_LimitUse)
     then
     else
       if(newu^.uid^.uid_LimitUse<ai_SphereTurbo_u^.uid^.uid_LimitUse)
       then exit
       else
         if(newu^.hits<ai_SphereTurbo_u^.hits)
         then
         else exit;

   ai_SphereTurbo_u:=newu;
end;

////////////////////////////////////////////////////////////////////////////////

procedure ai_SetTarget_Scout(newu:PTUnit);
begin
   with newu^ do
   with uid^ do
     if(speed<11)
     or(uid_LimitUse>ul2)
     or(transportM>0)
     or(aiu_alarm_d<base_r2)
     then exit;

   if(ai_ScoutCandidate_u=nil)
   then
   else
     if(newu^.isfly>ai_ScoutCandidate_u^.isfly)
     then
     else
     if(newu^.isfly<ai_ScoutCandidate_u^.isfly)
     then exit
     else
       if(newu^.buffs[ub_Invisibility]=ub_infinity)>(ai_ScoutCandidate_u^.buffs[ub_Invisibility]=ub_infinity)
       then
       else
       if(newu^.buffs[ub_Invisibility]=ub_infinity)<(ai_ScoutCandidate_u^.buffs[ub_Invisibility]=ub_infinity)
       then exit
       else
         if(newu^.speed>ai_ScoutCandidate_u^.speed)
         then
         else
         if(newu^.speed<ai_ScoutCandidate_u^.speed)
         then exit
         else
           if(newu^.group=aic_group_Scout)>(ai_ScoutCandidate_u^.group=aic_group_Scout)
           then
           else
           if(newu^.group=aic_group_Scout)<(ai_ScoutCandidate_u^.group=aic_group_Scout)
           then exit
           else
               if(newu^.unum<ai_ScoutCandidate_u^.unum)
               then
               else exit;

   ai_ScoutCandidate_u:=newu;
end;

procedure ai_SetBDefend(pu,newu:PTUnit;ud:integer);
begin
   if(ai_BaseDef_u=nil)
   then
   else
     {if(pu^.playeri=newu^.playeri)>(pu^.playeri=ai_BaseDef_u^.playeri)
     then
     else
     if(pu^.playeri=newu^.playeri)<(pu^.playeri=ai_BaseDef_u^.playeri)
     then exit
     else }
       if(pu^.mapZone=newu^.mapZone)>(pu^.mapZone=ai_BaseDef_u^.mapZone)
       then
       else
       if(pu^.mapZone=newu^.mapZone)<(pu^.mapZone=ai_BaseDef_u^.mapZone)
       then exit
       else
         if(ud<ai_BaseDef_d)
         then
         else exit;

   ai_BaseDef_u:=newu;
   ai_BaseDef_d:=ud;
end;

procedure ai_SetHTeleportNearest(newu:PTUnit;ud:integer);
begin
   if(ai_HTeleportNearest_u=nil)
   then
   else
     if(newu^.rld<ai_HTeleportNearest_u^.rld)
     then
     else
     if(newu^.rld>ai_HTeleportNearest_u^.rld)
     then exit
     else
       if(ud<ai_HTeleportNearest_d)
       then
       else
       if(ud>ai_HTeleportNearest_d)
       then exit;

   ai_HTeleportNearest_u  :=newu;
   ai_HTeleportNearest_d  :=ud;
end;

procedure ai_player_code(playerN:byte);
var
u:integer;
limit_Attack,
limit_Base:longint;
begin
   with g_PlayersMain[playerN] do
   begin
      if(aip_timer_detection  >0)then aip_timer_detection  -=1;
      if(aip_timer_magic      >0)then aip_timer_magic      -=1;
      if(aip_timer_superweapon>0)then aip_timer_superweapon-=1;

      {if(g_cycle_order=playerN)and(playerN=LocalPlayer)then
      begin
         //writeln(playerN,' ',aip_pause_attack,' ',aip_timer_attack);
         //writeln(aip_timer_detection);
      end; }

      if(aip_timer_attack<0)then
      begin
         aip_timer_attack+=1;
         if(aip_timer_attack>=0)then
         begin
            limit_Attack:=0;
            limit_Base  :=0;
            for u:=1 to MaxUnits do
              with g_punits[u]^ do
              with uid^ do
                if(hits>0)and(playerN=playeri)and(not uid_isbuilding)then
                  case group of
                  aic_group_Home      : limit_Base  +=uid_LimitUse;
                  aic_group_AttackNow,
                  aic_group_AttackWait: limit_Attack+=uid_LimitUse;
                  end;

            if(limit_Attack<=aip_MaxUnitMinPart)or(limit_Attack<limit_Base)
            then aip_timer_attack:=0
            else aip_timer_attack:=hits_ndead
         end;
      end
      else
        if(aip_timer_attack=0)then
        begin
           if(armylimit>=aic_MaxLimitBorder)
           or((units_bld_l[false]+prod_unit_Limit)>=aip_MaxUnitLimit)then
             aip_timer_attack:=aip_pause_attack+1;
        end
        else
        begin
           aip_timer_attack-=1;
           if(aip_timer_attack<=0)then
           begin
              limit_Attack:=0;
              for u:=1 to MaxUnits do
                with g_punits[u]^ do
                with uid^ do
                  if(hits>0)and(playerN=playeri)and(not uid_isbuilding)and(group=aic_group_Home)then
                  begin
                     limit_Attack+=uid_LimitUse;
                     group:=aic_group_AttackNow;
                     if(limit_Attack>=aip_MaxUnitLimit)then break;
                  end;
              aip_timer_attack:=hits_ndead;
           end;
        end;
   end;
end;

