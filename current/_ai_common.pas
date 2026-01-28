
const

aic_GeneratorsLimit        = ul1*35;
aic_GeneratorsEnergy       = 8000;
aic_GeneratorsDestroyEnergy= 9300;
aic_GeneratorsDestoryLimit = ul1*60;

aic_TowerLifeTime          = fr_fps1*60;

var

ai_alarm_zone     : word;
ai_alarm_d,
ai_alarm_x,
ai_alarm_y        : integer;


ai_generator_kp,
ai_keypoint_kp    : pTKeyPoint;

ai_keypoint_koth  : boolean;

ai_generators_limit
                  : longint;

ai_curr_UnitMinLvl,
ai_curr_UpgrMinLvl: byte;

ai_UpgradesLeft,
ai_AvailableDetectors,
ai_generator_d,
ai_keypoint_d,
ai_keypoint_n,
ai_keypoint_r,

ai_energy_future,
ai_energy_current,

ai_curr_Builders,
ai_curr_UnitProds,
ai_curr_UpgrProds,
ai_curr_Towers,

ai_need_Energy,
ai_need_Builders,
ai_need_UnitProds,
ai_need_UpgrProds,
ai_need_Towers

                  : integer;

ai_invuln_tar_u
                  : PTUnit;


procedure ai_PlayerSetAlarm(pplayer:PTPlayerGameData;ax,ay:integer;alimit:longint;arange:integer;abase:boolean;apfzone:word);
var a,
anobase,
afree  :byte;
begin
   afree  :=255;
   anobase:=255;  //no base alarm, low priority, can be replaced by base alarm
   ax     :=mm3i(1,ax,map_Size1);
   ay     :=mm3i(1,ay,map_Size1);
   with pplayer^ do
     for a:=0 to LastPlayer do
       with aip_alarms[a] do
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
      if(afree<255)
      then a:=afree
      else
        if(anobase<255)
        then a:=anobase
        else exit;

      with pplayer^.aip_alarms[a] do
      begin
         aia_x:=ax;
         aia_y:=ay;
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
        ai_PlayerSetAlarm(@g_gplayers[p],map_PlayerStartX[i],map_PlayerStartY[i],1,base_r1,true,map_GetZone(map_PlayerStartX[i],map_PlayerStartY[i]));
     end;
end;

procedure  ai_PlayerSetSkirmishSettings(p:byte);
procedure SetBaseOpt(aMaxEnergy,aMaxBuilders,aMaxBarracks,aMaxForges,aMaxDetectors,aMinTowers,aMaxTowers,aMaxArmyLimit:integer);
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
      //              energy buil bar   forges dete  min   max
      //                     ders racks        ctors tower tower
      0  : SetBaseOpt(0     ,0   ,0    ,0     ,0    ,0    ,0    ,0  );//,0    ,0    ,0    ,0    ,0      ,0       ,0    ,0     ,0     ,0          ,0             ,0  ,[]);
      1  : SetBaseOpt(400   ,1   ,1    ,0     ,0    ,0    ,0    ,10 );//,0    ,0    ,0    ,0    ,0      ,0       ,1    ,1     ,10    ,fr_fps1*120,12            ,0  ,[]);
      2  : SetBaseOpt(1500  ,1   ,3    ,1     ,1    ,0    ,4    ,25 );//,0    ,0    ,0    ,2    ,0      ,0       ,3    ,3     ,25    ,fr_fps1*80 ,30            ,0  ,[]);
      3  : SetBaseOpt(3000  ,2   ,5    ,1     ,3    ,6    ,6    ,40 );//,0    ,0    ,0    ,6    ,0      ,1       ,6    ,6     ,40    ,fr_fps1*40 ,45            ,1  ,[]);
      4  : SetBaseOpt(4500  ,3   ,8    ,2     ,6    ,6    ,8    ,55 );//,0    ,1    ,0    ,8    ,0      ,1       ,10   ,10    ,55    ,1          ,60            ,2  ,[]);
      5  : SetBaseOpt(6000  ,3   ,12   ,3     ,8    ,6    ,10   ,65 );//,0    ,1    ,1    ,10   ,1      ,2       ,10   ,14    ,65    ,1          ,70            ,3  ,[UID_Pain,UID_ArchVile,UID_Medic,UID_ZMedic,UID_Engineer,UID_ZEngineer,UID_BFGMarine,UID_ZBFGMarine]);
      6  : SetBaseOpt(7500  ,4   ,16   ,4     ,10   ,6    ,12   ,125);//,1    ,1    ,1    ,12   ,1      ,2       ,5    ,14    ,120   ,1          ,MaxPlayerUnits,4  ,[UID_Pain,UID_ArchVile,UID_Medic,UID_ZMedic,UID_Engineer,UID_ZEngineer,UID_BFGMarine,UID_ZBFGMarine]);
      else SetBaseOpt(9000  ,4   ,20   ,6     ,12   ,6    ,14   ,125);//,1    ,1    ,1    ,12   ,2      ,2       ,5    ,14    ,120   ,1          ,MaxPlayerUnits,15 ,[UID_Pain,UID_ArchVile,UID_Medic,UID_ZMedic,UID_Engineer,UID_ZEngineer,UID_BFGMarine,UID_ZBFGMarine]);
      end;
      //ai_max_specialist:=aip_skill-1;
      if(aip_skill>1)
      then aip_MaxUpgradeLevel:=aip_skill-1
      else aip_MaxUpgradeLevel:=0;

      case aip_skill of
      0  :;
      1,
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
                     +aif_base_SaveBuilder
                     +aif_ability_detection
                     +aif_ability_other
                     +aif_allies_help;
      else aip_flags:=aif_base_smart_order
                     +aif_base_suicide
                     +aif_base_advance
                     +aif_base_SaveBuilder
                     +aif_army_scout
                     +aif_army_smart_order
                     +aif_army_smart_micro
                     +aif_army_smart_Target
                     +aif_upgr_smart_order
                     +aif_ability_detection
                     +aif_ability_other
                     +aif_allies_help;
           if(aip_skill>7)then
           aip_flags+=aif_cheat_VisBuildings;

           if(aip_skill>8)then
           aip_flags+=aif_cheat_VisUnits;
      end;
      case aip_skill of
      9 : upgrs_cur[upgr_mult_product]:=1;
      10: begin
          upgrs_cur[upgr_mult_product]:=1;
          upgrs_cur[upgr_fast_product]:=1;
          end;
      11: begin
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
end;

procedure ai_Global_SetCurrentAlarm(tu:PTUnit;x,y,ud:integer;zone:word);
begin
   if(ud<ai_alarm_d)then
   begin
      if(tu<>nil)then
      begin
         x   :=tu^.x;
         y   :=tu^.y;
         zone:=tu^.mapZone;
      end;
      ai_alarm_x   :=x;
      ai_alarm_y   :=y;
      ai_alarm_d   :=ud;
      ai_alarm_zone:=zone;
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
            if(upgr_max<aip_MaxUpgradeLevel)
            then upgr_max:=aip_MaxUpgradeLevel;

            if(upgrs_cur[u]<maxLvl)then
              ai_CalcUpgradesLeft+=maxLvl-upgrs_cur[u];
         end;
end;

procedure ai_Global_InitVars(pu:PTUnit);
var i,d   :integer;
koth_point:boolean;
begin
   // common alarm
   ai_alarm_zone     :=0;
   ai_alarm_d        :=NOTSET;
   ai_alarm_x        :=-1;
   ai_alarm_y        :=-1;

   with pu^ do
   with uid^ do
   with player^ do
   begin
     { ai_advanced_bld    :=(ai_flags and aif_base_advance )>0;
      ai_teleport_use    :=(ai_flags and aif_army_teleport)>0;
      ai_choosen         :=(units_uid_c[uidi]>ai_MinChoosenCount)and(unum=units_uid_u[uidi]); }
      ai_AvailableDetectors:= units_uid_e[UID_HEye]+units_uid_e[UID_URadar];

      ai_UpgradesLeft :=ai_CalcUpgradesLeft(player);
   end;

 {  ai_limitaround_own      := 0;
   ai_limitaround_enemy_fly:= 0;
   ai_limitaround_enemy_grd:= 0;
   ai_limitaround_fly      := 0;
   ai_limitaround_grd      := 0;
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
             if(uid_isfly)and(not uid_isbuilding)and(uid_TransportMax>0)then ai_transport_cur+=uid_TransportMax*prod_unit_uid[i];
             if(i in siedge_uids)then ai_armylimit_siedge+=uid_LimitUse;
          end;
        if(units_uid_c[i]>0)then
          if(i in siedge_uids)then
            with g_uids[i] do ai_armylimit_siedge+=uid_LimitUse*units_uid_c[i];
     end;
   //if(pu^.isselected)then writeln(ai_armylimit_siedge);


   // enemy
   ai_enemy_u        := nil;
   ai_enemy_d        := NOTSET;
   ai_enemy_air_u    := nil;
   ai_enemy_air_d    := NOTSET;
   ai_enemy_grd_u    := nil;
   ai_enemy_grd_d    := NOTSET;
   ai_enemy_inv_u    := nil;
   ai_enemy_inv_d    := NOTSET;
   ai_enemy_build_u  := nil;
   ai_enemy_build_d  := NOTSET;

   // repair/heal target
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
      // get initial alarm point
      for i:=0 to LastPlayer do
        with aip_alarms[i] do
          if(aia_limit>0)then
            if(uid_isfly)
            or(isfly)
            or(aia_zone=mapZone)
            or(uid^.uid_isbarrack)then ai_Global_SetCurrentAlarm(nil,aia_x,aia_y,point_dist_int(aia_x,aia_y,x,y),aia_zone);

      // nearest point/generator
      ai_keypoint_koth:=false;
      if(map_KeyPointsN>0)then
        for i:=0 to map_KeyPointsN-1 do
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
                 if(g_royal_r<(kp_ToCenterD+100))then continue;

               if(kp_x<=0)
               or(kp_y<=0)
               or(kp_x>=map_Size1)
               or(kp_y>=map_Size1)then continue;

               if(transportM>0)then
                 if(map_IfObstacleZone(kp_zone))
                 or(kptd_OwnerPlayer=playeri)then continue;

               if(kptd_OwnerPlayer<>playeri)then
                 if(kptd_Timer>0)and(kptd_TimerOwnerTeam=team)and(kptd_TimerOwnerPlayer<>playeri)then continue;

               d:=point_dist_int(kp_x,kp_y,x,y);

               if(d>kp_RCapture)and(mapZone<>kp_zone)then
                 if not( isfly
                      or uid_isbarrack)
                      then continue;

               koth_point:=(i=0)and(map_scenario=mc_KotH)and(g_tick>=keyPoint_KotH_pause);

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
   ai_commander_fly_d := NOTSET;

   // nearest own building
   ai_base_d          := NOTSET;
   ai_base_u          := nil;

   // nearest own building with alarm
   ai_abase_d         := NOTSET;
   ai_abase_u         := nil;

   // transport target
   ai_transport_tar_d := NOTSET;
   ai_transport_tar_u := nil;

   // nearest teleporter
   ai_teleporterF_d   := NOTSET;
   ai_teleporterF_u   := nil;
   ai_teleporterR_d   := NOTSET;
   ai_teleporterR_u   := nil;
   ai_limitaround_teleports:= 0;

   // teleporter beacon
   ai_teleporter_beacon_u
                      := nil;

   // radars
   ai_radars          := 0;   }

   // who need sphere of invulnerability
   ai_invuln_tar_u    := nil;

 {  // uac strike target
   ai_strike_tar_u    := nil;

   // who need heye
   ai_need_heye_d     := NOTSET;
   ai_need_heye_u     := nil;
   }

   ai_curr_Builders   := pu^.player^.units_builders_e;
   ai_need_Builders   := 0;  // buildings production

   ai_curr_UnitProds  := 0;  // unit production
   ai_curr_UnitMinLvl := MaxUnitLevel;
   ai_need_UnitProds  := 0;

   ai_curr_UpgrProds  := 0;  // upgrade production
   ai_curr_UpgrMinLvl := MaxUnitLevel;
   ai_need_UpgrProds  := 0;

   ai_curr_Towers     := 0;  // towers
   ai_need_Towers     := 0;

  { ai_tech0_cur       :=0;  // tech 0
   ai_tech1_cur       :=0;  // tech 1
   ai_tech2_cur       :=0;  // tech 1

   ai_detect_cur      :=0;  // radar/heye
   ai_detect_near     :=0;
   ai_detect_need     :=0;

   ai_spec1_cur       :=0;  // rocket station/altar
   ai_spec2_cur       :=0;

   ai_towers_cur_active
                      :=0;
   ai_towers_cur      :=0;
   ai_towers_near     :=0;
   ai_towers_near_air :=0;
   ai_towers_near_grd :=0;
   ai_towers_needx    :=-1;
   ai_towers_needy    :=-1;
   ai_towers_needl    :=-1;
   ai_towers_need     :=0;
   ai_towers_need_type:=0;

   ai_inprogress_uid  :=0;
   ai_inprogress_auid :=0;  }
end;


