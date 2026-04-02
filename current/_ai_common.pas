
const

aic_GeneratorsLimit        = ul1*30;
aic_GeneratorsEnergy       = 9000;
aic_GeneratorsDestroyEnergy= 10000;
aic_GeneratorsDestoryLimit = ul1*35;

aic_TowerLifeTime          = fr_fps1*60;

var

{ai_alarm_zone     : word;
ai_alarm_d,
ai_alarm_x,
ai_alarm_y        : integer;   }

ai_choosen,
ai_flags_BaseAdvance
                  : boolean;

ai_generator_kp,
ai_keypoint_kp    : pTKeyPoint;
ai_keypoint_koth  : boolean;

ai_generators_limit,
ai_enemylimit_baseR2_grd,
ai_enemylimit_baseR2_fly,

ai_enemy_grd,
ai_enemy_fly,

ai_armylimit_ForTeleport,
ai_armylimit_siedge,
ai_armylimit_alive_u,
ai_armylimit_alive_b,

ai_curr_detect,
ai_need_detect,

ai_transport_cur,
ai_transport_need

                  : longint;

ai_UpgradesLeft,
ai_AvailableDetectors,
ai_generator_d,
ai_keypoint_d,
ai_keypoint_n,
ai_keypoint_r,

ai_base_d,
ai_abase_d,

ai_enemy_d,
ai_enemy_air_d,
ai_enemy_grd_d,
ai_enemy_inv_d,
ai_enemy_build_d,

ai_need_heye_d,

ai_energy_future,
ai_energy_current,

ai_curr_Builders,
ai_curr_UnitProds,
ai_curr_UpgrProds,
ai_curr_Towers,

ai_near_detect,

ai_need_Energy,
ai_need_UnitProds,
ai_need_UpgrProds,
ai_need_Teleports,

ai_near_HEye,

ai_HTeleportAlarmed_d,
ai_HTeleportNearest_d,

ai_selfUID_nocomplete,
ai_selfUID_minLevel,

ai_UnitsInTransform

                  : integer;

ai_MinBuildAttempts:byte;

ai_base_u,
ai_abase_u,

ai_enemy_u,
ai_enemy_air_u,
ai_enemy_grd_u,
ai_enemy_inv_u,
ai_enemy_build_u,
ai_invuln_tar_u,

ai_need_heye_u,

ai_HEyeNest_u,

ai_Strike_u,
ai_Bribe_u,
ai_Heroic_u,

ai_SphereSoul_u,
ai_SphereInvis_u,
ai_SphereInvul_u,

ai_SphereRDamage_u,
ai_SphereDDamage_u,
ai_SphereTurbo_u,

ai_HTeleportAlarmed_u,
ai_HTeleportNearest_u

                  : PTUnit;

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
           if(g_gplayers[i].state=ps_None)then continue;
           if(g_gplayers[i].team=g_gplayers[p].team)then continue;
        end;
        ai_Alarm_SetForTeam(g_gplayers[p].team,map_PlayerStartX[i],map_PlayerStartY[i],1,base_r1,true,map_GetZone(map_PlayerStartX[i],map_PlayerStartY[i]));
     end;
end;

function ai_alarm_CheckPoint(pu:PTUnit;tx,ty,tr:integer):boolean;
var a:byte;
begin
   ai_alarm_CheckPoint:=false;
   with pu^ do
   begin
      if(aiu_alarm_d<NOTSET)then
        if(point_dist_rint(tx,ty,aiu_alarm_x,aiu_alarm_y)<tr)then exit;

      for a:=0 to ai_LastAlarm do
        with ai_TeamAlarms[player^.team,a] do
          if(aia_limit>0)then
            if(point_dist_rint(tx,ty,aia_x,aia_y)<tr)then exit;
   end;
   ai_alarm_CheckPoint:=true;
end;

////////////////////////////////////////////////////////////////////////////////

procedure  ai_PlayerSetSkirmishSettings(p:byte);
procedure SetBaseOpt(aMaxEnergy,aMaxBuilders,aMaxBarracks,aMaxForges,aMaxDetectors,aMinTowers,aMaxTowers,aMaxArmyLimit,aDetectionPause,aSpecialPause:integer);
begin
   with g_gplayers[p] do
   begin
      aip_MaxEnergy     :=aMaxEnergy;
      aip_MaxBuilders   :=aMaxBuilders;
      aip_MaxBarracks   :=aMaxBarracks;
      aip_MaxForges     :=aMaxForges;
      aip_MaxDetectors  :=aMaxDetectors*ul1;
      aip_MinTowers     :=aMinTowers;
      aip_MaxTowers     :=aMaxTowers;
      aip_MaxArmyLimit  :=aMaxArmyLimit*ul1;
      aip_pause_detection  :=max2i(fr_fps1,fr_fps1*aDetectionPause);
      aip_pause_magic      :=max2i(fr_fps1,fr_fps1*aSpecialPause);
      aip_pause_superweapon:=max2i(fr_fps1,fr_fps1*aSpecialPause);
      {
      ai_attack_limit     :=atl*MinUnitLimit;
      ai_attack_delay     :=att;
      ai_maxlimit_blimit  :=l*MinUnitLimit;
      ai_maxcount_upgrlvl :=mupl;
      ai_hptargets        :=hpt;

      ,t0,t1,t2,dl,s1,s2,mint,maxt,atl,att,l:integer;mupl:byte;hpt:TSoB
      }
   end;
end;
begin
   with g_gplayers[p] do
   begin
      case aip_skill of
      //              energy buil bar   forges dete  min   max       pause
      //                     ders racks        ctors tower tower     dtct spec
      0  : SetBaseOpt(0     ,0   ,0    ,0     ,0    ,0    ,0    ,0  ,0   ,0   );//,0    ,0    ,0    ,0    ,0      ,0       ,0    ,0     ,0     ,0          ,0             ,0  ,[]);
      1  : SetBaseOpt(600   ,1   ,1    ,0     ,0    ,1    ,1    ,10 ,60  ,180 );//,0    ,0    ,0    ,0    ,0      ,0       ,1    ,1     ,10    ,fr_fps1*120,12            ,0  ,[]);
      2  : SetBaseOpt(3000  ,2   ,5    ,1     ,3    ,6    ,6    ,40 ,20  ,120 );//,0    ,0    ,0    ,6    ,0      ,1       ,6    ,6     ,40    ,fr_fps1*40 ,45            ,1  ,[]);
      3  : SetBaseOpt(6000  ,3   ,12   ,3     ,8    ,6    ,10   ,65 ,10  ,60  );//,0    ,1    ,1    ,10   ,1      ,2       ,10   ,14    ,65    ,1          ,70            ,3  ,[UID_Pain,UID_ArchVile,UID_Medic,UID_ZMedic,UID_Engineer,UID_ZEngineer,UID_BFGMarine,UID_ZBFGMarine]);
      4  : SetBaseOpt(7500  ,4   ,16   ,4     ,10   ,6    ,12   ,125,0   ,30  );//,1    ,1    ,1    ,12   ,1      ,2       ,5    ,14    ,120   ,1          ,MaxPlayerUnits,4  ,[UID_Pain,UID_ArchVile,UID_Medic,UID_ZMedic,UID_Engineer,UID_ZEngineer,UID_BFGMarine,UID_ZBFGMarine]);
      else SetBaseOpt(9400  ,4   ,20   ,6     ,12   ,6    ,14   ,125,0   ,0   );//,1    ,1    ,1    ,12   ,2      ,2       ,5    ,14    ,120   ,1          ,MaxPlayerUnits,15 ,[UID_Pain,UID_ArchVile,UID_Medic,UID_ZMedic,UID_Engineer,UID_ZEngineer,UID_BFGMarine,UID_ZBFGMarine]);
      end;
      //ai_max_specialist:=aip_skill-1;
      if(aip_skill>1)
      then aip_MaxUpgradeLevel:=aip_skill
      else aip_MaxUpgradeLevel:=0;

      {

      }

      case aip_skill of
      0  :;
      1  : aip_flags:=aif_allies_help;
      2  : aip_flags:=aif_army_scout
                     +aif_allies_help;
      3  : aip_flags:=aif_army_scout
                     +aif_base_smart_order
                     +aif_base_advance
                     +aif_ability_detection
                     +aif_allies_help;
      4  : aip_flags:=aif_army_scout
                     +aif_army_smart_order
                     +aif_base_smart_order
                     +aif_base_advance
                     +aif_base_BuilderMove
                     +aif_ability_detection
                     +aif_ability_other
                     +aif_allies_help;
      else aip_flags:=aif_base_smart_order
                     +aif_base_suicide
                     +aif_base_advance
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
      aiu_NeedDetect       :=NOTSET;
      aiu_limitaround_ally :=0;
      aiu_limitaround_enemy:=0;
      // aiu_alarm_timer ?
   end;

   ai_enemy_u:= nil;
   ai_enemy_d:= NOTSET;
end;


procedure ai_Local_SetCurrentAlarm(pu,tar_u:PTUnit;tar_x,tar_y,tar_dist:integer);
begin
   with pu^ do
     if(tar_dist<aiu_alarm_d)then
     begin
        if(tar_u<>nil)then
        begin
           tar_x:=tar_u^.x;
           tar_y:=tar_u^.y;
        end;
        aiu_alarm_x:=tar_x;
        aiu_alarm_y:=tar_y;
        aiu_alarm_d:=tar_dist;
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

procedure ai_Global_InitVars(pu:PTUnit);
var i,d   :integer;
koth_point:boolean;
begin
   // common alarm
   {ai_alarm_zone     :=0;
   ai_alarm_d        :=NOTSET;
   ai_alarm_x        :=-1;
   ai_alarm_y        :=-1; }

   with pu^ do
   with uid^ do
   with player^ do
   begin
      ai_flags_BaseAdvance:=(aip_flags and aif_base_advance )>0;
      //ai_teleport_use    :=(ai_flags and aif_army_teleport)>0;
      ai_choosen          :=(units_uid_c[uidi]>1)and(unum=units_uid_u[uidi]);
      ai_AvailableDetectors:= units_uid_e[UID_HEye]+units_uid_e[UID_URadar];

      ai_UpgradesLeft :=ai_CalcUpgradesLeft(player);
   end;

   //ai_limitaround_own      := 0;
   ai_armylimit_ForTeleport:= 0;
   ai_enemylimit_baseR2_fly:= 0;
   ai_enemylimit_baseR2_grd:= 0;
   //ai_limitaround_fly      := 0;
   //ai_limitaround_grd      := 0;

   ai_armylimit_siedge     := 0;
   ai_armylimit_alive_u    := 0;
   ai_armylimit_alive_b    := 0;

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
             if(uid_isfly)and(not uid_isbuilding)and(uid_TransportMax_Base>0)then ai_transport_cur+=uid_TransportMax_Base*prod_unit_uid[i];
             if(uid_AI_Siedge)then ai_armylimit_siedge+=uid_LimitUse;
          end;
        if(units_uid_c[i]>0)then
          if(g_uids[i].uid_AI_Siedge)then
            with g_uids[i] do ai_armylimit_siedge+=uid_LimitUse*units_uid_c[i];
     end;
   //if(pu^.isselected)then writeln(ai_armylimit_siedge);


   // enemy
   ai_enemy_air_u    := nil;
   ai_enemy_air_d    := NOTSET;
   ai_enemy_grd_u    := nil;
   ai_enemy_grd_d    := NOTSET;
   ai_enemy_inv_u    := nil;
   ai_enemy_inv_d    := NOTSET;
   ai_enemy_build_u  := nil;
   ai_enemy_build_d  := NOTSET;
   ai_enemy_grd      := 0;
   ai_enemy_fly      := 0;

{   // repair/heal target
   ai_mrepair_u      := nil;
   ai_mrepair_d      := NOTSET;
   ai_urepair_u      := nil;
   ai_urepair_d      := NOTSET; }

   // key points
   ai_keypoint_kp    := nil;
   ai_keypoint_d     := NOTSET;
   ai_keypoint_r     := 0;
   ai_keypoint_n     := 0;

   ai_generator_kp   := nil;
   ai_generator_d    := NOTSET;

   // energy
   ai_energy_future  := 0;
   ai_energy_current := 0;

   ai_generators_limit:=0;

  {
   // nearest builder
   ai_nearest_builder_u:=nil;
   ai_nearest_builder_d:= NOTSET;
   with pu^ do
     if(uid^.uid_isbuilder)and(not ukfly)and(iscomplete)then
     begin
        ai_nearest_builder_u:=pu;
        ai_nearest_builder_d:=0;
     end;
         }
   with pu^ do
   with uid^ do
   with player^ do
   begin
      // nearest point/generator
      ai_keypoint_koth:=false;
      for i:=0 to LastKeyPoint do
        with map_KeyPointsL[i] do
        with kp_TeamData[MaxPlayers] do
          if(kptd_Active)then
          begin
             if(kptd_OwnerPlayer=playeri)then
             begin
                if(kp_Energy>0)then
                begin
                   ai_energy_future+=kp_Energy;
                   ai_energy_current+=kp_Energy;
                end
                else ai_keypoint_n+=1;
             end;

             if(map_scenario=mc_royale)then
               if(g_royal_r<(kp_ToCenterD+kp_RCapture))then continue;

             if(kp_x<=0)
             or(kp_y<=0)
             or(kp_x>=map_Size1)
             or(kp_y>=map_Size1)then continue;

             if(transportM>0)then
               if(map_IfObstacleZone(kp_zone))
               or(kptd_OwnerTeam=team)then continue;

             koth_point:=(i=0)and(map_scenario=mc_KotH)and(g_tick>=keyPoint_KotH_pause);


             //if(kptd_OwnerTeam<>team)then
             //  if(kptd_Timer>0)and(kptd_TimerOwnerTeam=team)and(kptd_TimerOwnerPlayer<>playeri)then continue;    // ??
             if(not koth_point)then
             begin
                if(kptd_OwnerTeam=team)and(kptd_OwnerPlayer<>playeri)then continue;
                if(kptd_Timer>0)then
                  if(kptd_TimerOwnerTeam=team)and(kptd_TimerOwnerPlayer<>playeri)then continue;
             end;

             d:=point_dist_int(kp_x,kp_y,x,y)-uid_r;

             if(d>kp_RCapture)and(mapZone<>kp_zone)then
               if not( isfly
                    or uid_isbarrack)
                    then continue;

             if(not koth_point)then
               if((kp_LimitTeamP[team]>=ul3)and(d> kp_RCapture))
               or((kp_LimitTeamP[team]>=ul6)and(d<=kp_RCapture))then continue;

             if(kp_Energy>0)and(not koth_point)then
             begin
                if(d<ai_generator_d)then
                begin
                   ai_generator_d :=d;
                   ai_generator_kp:=@map_KeyPointsL[i];
                end;
             end
             else
               if(d<ai_keypoint_d)then
               begin
                  ai_keypoint_d   :=d;
                  ai_keypoint_r   :=kp_RCapture;
                  ai_keypoint_kp  :=@map_KeyPointsL[i];
                  ai_keypoint_koth:=koth_point;
               end;

             if(d<kp_RCapture)then break;
          end;
   end;

  { ai_PhantomWantZombieMe:=false;

   ai_ZombieTarget_u  := nil;
   ai_ZombieTarget_d  := NOTSET;

   // commander
   ai_commander_grd_u := nil;
   ai_commander_fly_u := nil;
   ai_commander_grd_d := NOTSET;
   ai_commander_fly_d := NOTSET;  }

   // nearest own building
   ai_base_d          := NOTSET;
   ai_base_u          := nil;

   // nearest own building with alarm
   ai_abase_d         := NOTSET;
   ai_abase_u         := nil;

 {  // transport target
   ai_transport_tar_d := NOTSET;
   ai_transport_tar_u := nil;   }

   // teleporter
   ai_HTeleportAlarmed_d:= NOTSET;
   ai_HTeleportAlarmed_u:= nil;
   ai_HTeleportNearest_d:= NOTSET;
   ai_HTeleportNearest_u:= nil;
   //ai_limitaround_teleports:= 0;

   {// teleporter beacon
   ai_teleporter_beacon_u
                      := nil;

   // radars
   ai_radars          := 0;   }

   // who need sphere of invulnerability
   ai_invuln_tar_u    := nil;

   // 'Magic' targets
   ai_Strike_u        := nil;
   ai_Bribe_u         := nil;
   ai_Heroic_u

   ai_SphereSoul_u    := nil;
   ai_SphereInvis_u   := nil;
   ai_SphereInvul_u   := nil;

   ai_SphereRDamage_u := nil;
   ai_SphereDDamage_u := nil;
   ai_SphereTurbo_u   := nil;

   // Hell Vision target
   ai_need_heye_d     := NOTSET;
   ai_need_heye_u     := nil;

   ai_near_HEye       := 0;
   ai_HEyeNest_u      := nil;

   ai_curr_Builders   := pu^.player^.units_builders_e;

   ai_curr_UnitProds  := 0;  // unit production
   ai_need_UnitProds  := 0;

   ai_curr_UpgrProds  := 0;  // upgrade production
   ai_need_UpgrProds  := 0;

   ai_curr_Towers     := 0;  // towers

   with pu^.player^ do
   ai_curr_detect     :=(units_uid_e[UID_URadar  ]*g_uids[UID_URadar  ].uid_LimitUse)+
                        (units_uid_e[UID_HEyeNest]*g_uids[UID_HEyeNest].uid_LimitUse);
   ai_near_detect     := 0;
   ai_need_detect     := 0;

   ai_need_Teleports  := 0;

  { ai_tech0_cur       :=0;  // tech 0
   ai_tech1_cur       :=0;  // tech 1
   ai_tech2_cur       :=0;  // tech 1

   ai_spec1_cur       :=0;  // rocket station/altar
   ai_spec2_cur       :=0;

   ai_towers_cur_active
                      :=0;

   ai_towers_near     :=0;
   ai_towers_near_air :=0;
   ai_towers_near_grd :=0;
   ai_towers_needx    :=-1;
   ai_towers_needy    :=-1;
   ai_towers_needl    :=-1;

   ai_towers_need_type:=0;  }

   ai_MinBuildAttempts:=255;

   ai_UnitsInTransform:=0;

   ai_selfUID_minLevel:=LastUnitLevel;
   with pu^ do
   with player^ do
   ai_selfUID_nocomplete:=units_uid_e[uidi]-units_uid_c[uidi];
end;

function ai_UnitAbility(pCaster:PTUnit;aid:byte;atar,ax,ay:integer):boolean;
begin
   unit_SetAbilityOrder(pCaster,aid,atar,ax,ay,false);
   ai_UnitAbility:=unit_AbilityExec(pCaster,aid)=0;
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

procedure ai_player_code(playeri:byte);
var tu:PTunit;
    a :byte;
begin
   with g_gplayers[playeri] do
   begin
      {if(IsUnitRange(ai_scout_u_cur,@tu))
      then ai_scout_u_cur_w:=GetWeaponPriority(tu,wtp_Scout,false)
      else
      begin
         ai_scout_u_cur_w:=0;
         ai_scout_u_cur  :=0;
      end;
      if(ai_scout_u_new>0)then
      begin
         if(ai_scout_u_new_w>ai_scout_u_cur_w)then
         begin
            ai_scout_u_cur_w:=ai_scout_u_new_w;
            ai_scout_u_cur  :=ai_scout_u_new  ;
         end;
      end;
      ai_scout_u_new  :=0;
      ai_scout_u_new_w:=0; }

      if(aip_timer_detection  >0)then aip_timer_detection  -=1;
      if(aip_timer_magic      >0)then aip_timer_magic      -=1;
      if(aip_timer_superweapon>0)then aip_timer_superweapon-=1;

      if(g_cycle_order=pnum)then
      begin
         if(map_scenario=mc_royale)then
           for a:=0 to ai_LastAlarm do
             with ai_TeamAlarms[team,a] do
               if(aia_limit>0)then
                 if(g_CheckRoyalBattlePoint(aia_x,aia_y,base_r1))then aia_limit:=0;

         {if(ai_scout_u_cur=0)
         then ai_scout_timer:=0
         else
           if(ai_scout_timer=0)
           then ai_scout_timer:=max2i(1,ai_attack_delay)
           else ai_timer(@ai_scout_timer,0);

         ai_ReadyForAttack:=(armylimit>=ai_limit_border)
                          or((units_bld_l[false]+prod_unit_Limit)>=ai_maxlimit_blimit)
                          or(units_bld_l[true]<=0);

         if(not ai_ReadyForAttack)
         then ai_attack_timer:=0
         else
           if(ai_attack_timer=0)
           then ai_attack_timer:=max2i(1,ai_attack_delay)
           else ai_timer(@ai_attack_timer,fr_fps60); }
      end;
   end;
end;

{procedure ai_GoTo(pu:PTUnit;ux,uy,ud,ur:integer);
begin
   with pu^ do
   begin
      if(ud=NOTSET)then ud:=point_dist_int(x,y,ux,uy);
      if(ud>ur)then
      begin
         uo_x:=ux;
         uo_y:=uy;
      end
      else
      begin
         uo_x:=ux-g_randomr(ur);
         uo_y:=uy-g_randomr(ur);
      end;
   end;
end;  }

