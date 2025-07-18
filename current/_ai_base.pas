
const

aiucl_main0      : array[1..race_num] of byte = (UID_HKeep          ,UID_UCommandCenter  );
aiucl_main1      : array[1..race_num] of byte = (UID_HCommandCenter ,0                   );
aiucl_generator  : array[1..race_num] of byte = (UID_HSymbol        ,UID_UGenerator      );
aiucl_barrack0   : array[1..race_num] of byte = (UID_HGate          ,UID_UBarracks       );
aiucl_barrack1   : array[1..race_num] of byte = (UID_HBarracks      ,UID_UFactory        );
aiucl_smith      : array[1..race_num] of byte = (UID_HPools         ,UID_UWeaponFactory  );
aiucl_tech0      : array[1..race_num] of byte = (UID_HMonastery     ,UID_UTechCenter     );
aiucl_tech1      : array[1..race_num] of byte = (UID_HFortress      ,UID_UComputerStation);
aiucl_tech2      : array[1..race_num] of byte = (UID_HPentagram     ,0                   );
aiucl_detect     : array[1..race_num] of byte = (UID_HEye           ,UID_URadar          );
aiucl_spec1      : array[1..race_num] of byte = (UID_HAltar         ,UID_URMStation      );
aiucl_spec2      : array[1..race_num] of byte = (UID_HTeleport      ,0                   );
aiucl_twr_air1   : array[1..race_num] of byte = (UID_HTower         ,UID_UATurret        );
aiucl_twr_air2   : array[1..race_num] of byte = (UID_HTotem         ,UID_UATurret        );
aiucl_twr_ground1: array[1..race_num] of byte = (UID_HTower         ,UID_UGTurret        );
aiucl_twr_ground2: array[1..race_num] of byte = (UID_HTotem         ,UID_UGTurret        );

ai_GeneratorsLimit        = ul1*50;
ai_GeneratorsEnergy       = 4500;
ai_GeneratorsDestoryLimit = ul1*70;
ai_GeneratorsDestroyEnergy= 4750;
ai_TowerLifeTime          = fr_fps1*60;
ai_MinArmyForScout        = 0;
ai_BasePatrolRange        = 100;
ai_MinBaseSaveCountBorder = 6;
ai_MinChoosenCount        = 6;
ai_FiledSquareBorder      = 145000;

// ai groups
aio_home       = 0;
aio_home_busy  = 1;
aio_attack     = 2;
aio_attack_busy= 3;
aio_scout      = 4;

var

ai_alarm_zone     : word;

ai_need_heye_u,
ai_commander_grd_u,
ai_commander_fly_u,
ai_transport_tar_u,
ai_abase_u,
ai_invuln_tar_u,
ai_strike_tar_u,
ai_teleporterF_u,
ai_teleporterR_u,
ai_teleporter_beacon_u,
ai_enemy_u,
ai_enemy_air_u,
ai_enemy_grd_u,
ai_enemy_inv_u,
ai_enemy_build_u,
ai_mrepair_u,
ai_urepair_u,
ai_nearest_buildersqr_u,
ai_nearest_builder_u,
ai_ZombieTarget_u,
ai_base_u         : PTUnit;
ai_generator_cp,
ai_cpoint_cp      : PTCTPoint;

ai_PhantomWantZombieMe,
ai_AdvancedBuild,
ai_TeleportUse,
ai_ischoosen,
ai_istransport,
ai_cpoint_koth    : boolean;

ai_generator_d,
ai_cpoint_d,
ai_cpoint_n,
ai_cpoint_r,
ai_alarm_d,
ai_alarm_x,
ai_alarm_y,
ai_commander_grd_d,
ai_commander_fly_d,
ai_need_heye_d,
ai_transport_tar_d,
ai_abase_d,
ai_base_d,
ai_enemy_d,
ai_enemy_air_d,
ai_enemy_grd_d,
ai_enemy_inv_d,
ai_enemy_build_d,
ai_mrepair_d,
ai_urepair_d,
ai_teleporterF_d,
ai_teleporterR_d,
ai_ZombieTarget_d,

ai_enrg_pot,
ai_enrg_cur,
ai_builders_count,
ai_builders_need,
ai_unitp_cur,
ai_unitp_cur_na,
ai_unitp_need,
ai_upgrp_cur,
ai_upgrp_cur_na,
ai_upgrp_need,
ai_tech0_cur,
ai_tech1_cur,
ai_tech2_cur,
ai_detect_cur,
ai_detect_near,
ai_detect_need,
ai_spec1_cur,
ai_spec2_cur,
ai_towers_cur,
ai_towers_cur_active,
ai_towers_near,
ai_towers_near_air,
ai_towers_near_grd,
ai_towers_need,
ai_towers_need_type,
ai_towers_needx,
ai_towers_needy,
ai_towers_needl,
ai_transport_cur,
ai_transport_need,
ai_inprogress_uid,
ai_radars,
ai_nearest_buildersqr_d,
ai_nearest_builder_d
                  : integer;

ai_gen_limit,
ai_nearest_buildersqr_square,
ai_armylimit_alive_u,
ai_armylimit_alive_b,
ai_limitaround_own,
ai_limitaround_enemy_fly,
ai_limitaround_enemy_grd,
ai_limitaround_teleports,
ai_limitaround_fly,
ai_limitaround_grd: longint;

procedure ai_PlayerSetAlarm(pplayer:PTPlayer;ax,ay:integer;alimit:longint;arange:integer;abase:boolean;apfzone:word);
var a,
anobase,
afree  : byte;
begin
   afree  :=255;
   anobase:=255;  //no base alarm, low priority, can be replaced by base alarm
   if(ax<0)or(map_psize<ax)
   or(ay<0)or(map_psize<ay)then exit;

   with pplayer^ do
    for a:=0 to LastPlayer do
     with ai_alarms[a] do
      if(alimit<=0)then
      begin
         if(aia_enemy_limit>0)then
          if(point_dist_rint(ax,ay,aia_x,aia_y)<arange)then aia_enemy_limit:=0
      end
      else
        if(aia_enemy_limit<=0)
        then afree:=a
        else
        begin
           if(not aia_enemy_base)then anobase:=a;
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

      with pplayer^.ai_alarms[a] do
      begin
         aia_x:=ax;
         aia_y:=ay;
         aia_enemy_limit:=alimit;
         aia_enemy_base :=abase;
         aia_zone       :=apfzone;
      end;
   end;
end;

procedure ai_MakeScirmishDefaultAlarms(p:byte);
var i: byte;
begin
   {for i:=1 to MaxPlayers do
    if(i<>p)then
     if((g_players[i].state>pt_none)and(g_players[i].team<>g_players[p].team))
     or(not g_fixed_positions)
     then ai_PlayerSetAlarm(@g_players[p],map_PlayerStartX[i],map_PlayerStartY[i],1,base_1r,true,pf_get_area(map_PlayerStartX[i],map_PlayerStartY[i]));}
end;

procedure  ai_PlayerSetSkirmishSettings(p:byte);
procedure SetBaseOpt(me,m,unp,upp,t0,t1,t2,dl,s1,s2,mint,maxt,atl,att,l:integer;mupl:byte;hpt:TSoB);
begin
   with g_players[p] do
   begin
      ai_maxcount_energy  :=me;
      ai_maxcount_mains   :=m;
      ai_maxcount_unitps  :=unp;
      ai_maxcount_upgrps  :=upp;
      ai_maxcount_tech0   :=t0;
      ai_maxcount_tech1   :=t1;
      ai_maxcount_tech2   :=t2;
      ai_maxlimit_detect  :=dl*MinUnitLimit;
      ai_maxcount_spec1   :=s1;
      ai_maxcount_spec2   :=s2;
      ai_mincount_towers  :=mint;
      ai_maxcount_towers  :=maxt;
      ai_attack_limit     :=atl*MinUnitLimit;
      ai_attack_delay     :=att;
      ai_maxlimit_blimit  :=l*MinUnitLimit;
      ai_maxcount_upgrlvl :=mupl;
      ai_hptargets        :=hpt;
   end;
end;
begin
   with g_players[p] do
   begin
      case ai_skill of
      //              energ buil uprod  pprod tech0 tech1 tech2 radar rsta    telepo  min    max    attack attack     max           upgr primary
      //                    ders                                heye  altar           towers towers limit  delay      army          lvl  targets
      //                                                        limit
      0  : SetBaseOpt(0    ,0   ,0     ,0    ,0    ,0    ,0    ,0    ,0      ,0       ,0    ,0     ,0     ,0          ,0             ,0  ,[]);
      1  : SetBaseOpt(300  ,1   ,1     ,0    ,0    ,0    ,0    ,0    ,0      ,0       ,1    ,1     ,12    ,fr_fps1*180,12            ,0  ,[]);
      2  : SetBaseOpt(1200 ,2   ,3     ,1    ,0    ,0    ,0    ,2    ,0      ,0       ,3    ,3     ,30    ,fr_fps1*150,30            ,0  ,[]);
      3  : SetBaseOpt(2400 ,4   ,4     ,1    ,0    ,0    ,0    ,6    ,0      ,1       ,6    ,6     ,45    ,fr_fps1*120,45            ,1  ,[]);
      4  : SetBaseOpt(3600 ,8   ,8     ,2    ,0    ,1    ,0    ,8    ,0      ,2       ,10   ,10    ,60    ,fr_fps1*90 ,60            ,2  ,[]);
      5  : SetBaseOpt(4200 ,12  ,12    ,3    ,0    ,1    ,1    ,10   ,1      ,2       ,10   ,14    ,70    ,fr_fps1*60 ,70            ,3  ,[UID_Pain,UID_ArchVile,UID_Medic]);
      6  : SetBaseOpt(4900 ,18  ,16    ,4    ,1    ,1    ,1    ,12   ,1      ,3       ,5    ,14    ,120   ,fr_fps1*30 ,MaxPlayerUnits,4  ,[UID_Pain,UID_ArchVile,UID_Medic,UID_BFGMarine,UID_ZBFGMarine]);
      else SetBaseOpt(6000 ,24  ,20    ,6    ,1    ,1    ,1    ,14   ,1      ,3       ,5    ,14    ,120   ,1          ,MaxPlayerUnits,15 ,[UID_Pain,UID_ArchVile,UID_Medic,UID_BFGMarine,UID_ZBFGMarine]);
      end;
      ai_max_specialist:=ai_skill-1;
      case ai_skill of
      0  :;
      1,
      2  : ai_flags:=aif_army_scout;
      3  : ai_flags:=aif_army_scout
                    +aif_base_smart_order
                    +aif_base_advance
                    +aif_army_smart_order
                    +aif_ability_mainsave
                    +aif_ability_detection;
      4  : ai_flags:=aif_army_scout
                    +aif_base_smart_order
                    +aif_base_advance   // это должно касаться только производственных зданий
                    +aif_base_suicide
                    +aif_army_smart_order
                    +aif_army_advance
                    +aif_army_teleport
                    +aif_ability_detection
                    +aif_ability_other
                    +aif_ability_mainsave;
      else ai_flags:=aif_base_smart_order
                    +aif_base_suicide
                    +aif_base_advance
                    +aif_army_smart_order
                    +aif_army_scout
                    +aif_army_advance
                    +aif_army_smart_micro
                    +aif_army_teleport
                    +aif_upgr_smart_opening
                    +aif_ability_detection
                    +aif_ability_other
                    +aif_ability_mainsave; //all
      end;
      if(player_type=pt_ai)then
      case ai_skill of
      8 : upgr[upgr_fog_vision  ]:=1;
      9 : begin
          upgr[upgr_fog_vision  ]:=1;
          upgr[upgr_mult_product]:=1;
          end;
      10: begin
          upgr[upgr_fog_vision  ]:=1;
          upgr[upgr_mult_product]:=1;
          upgr[upgr_fast_product]:=1;
          end;
      11: begin
          upgr[upgr_fog_vision  ]:=1;
          upgr[upgr_mult_product]:=1;
          upgr[upgr_fast_product]:=1;
          upgr[upgr_fast_build  ]:=1;
          end;
      end;
   end;
   ai_MakeScirmishDefaultAlarms(p);
end;

function ai_HighPriorityTarget(player:PTPlayer;tu:PTUnit):boolean;
begin
   ai_HighPriorityTarget:=false;
   if(player^.player_type=pt_ai)then
     ai_HighPriorityTarget:=tu^.uidi in player^.ai_hptargets;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   INIT AI DATA COLLECTION
//

function ai_BaseDestinationChecks(pu:PTUnit;azone:word):boolean;
begin
   with pu^ do
   with uid^ do
     ai_BaseDestinationChecks:=(ukfly)
                             or(ukfloater)
                             //or(pf_EqZones(azone,pfzone))
                             or(_isbarrack)
                             or(isbuildarea)
                             or(_ability=ua_UScan)
                             or(_ukbuilding and(_ability=ua_HShortBlink)and(_attack));
end;

procedure ai_SetCurrentAlarm(tu:PTUnit;x,y,ud:integer;zone:word);
begin
   if(ud<ai_alarm_d)then
   begin
      if(tu<>nil)then
      begin
         x   :=tu^.x;
         y   :=tu^.y;
         zone:=tu^.zone;
      end;
      ai_alarm_x   :=x;
      ai_alarm_y   :=y;
      ai_alarm_d   :=ud;
      ai_alarm_zone:=zone;
   end;
end;
procedure aiu_SetCurrentAlarm(pu,tu:PTUnit;ax,ay,aud:integer;azone:word);
begin
   if(tu<>nil)then
   begin
      ax   :=tu^.x;
      ay   :=tu^.y;
      azone:=tu^.zone;
   end;
   with pu^ do
   with uid^ do
     if(not ai_istransport)
     or(not map_IsObstacleZone(azone))then
       if(ai_BaseDestinationChecks(pu,azone))then
       begin
          if(aud<0)or(aud=NOTSET)
          then aud:=point_dist_int(ax,ay,x,y);
          ai_SetCurrentAlarm(nil,ax,ay,aud,azone);
       end;
end;


procedure ai_CollectDoodadsSquare(square:plongint;tx,ty,tr:integer);
var dx,dy,u,dist,dm:integer;
begin
   {dx:=tx div dcw;
   dy:=ty div dcw;

   if(0<=dx)and(dx<=dcn)and(0<=dy)and(dy<=dcn)then
    with map_dcell[dx,dy] do
     if(n>0)then
      for u:=0 to n-1 do
       with l[u]^ do
        if(r>0)and(t>0)then
        begin
           dist:=point_dist_int(x,y,tx,ty)+r-tr;
           dm:=r+r;

           if(dist<=dm)then
             if(dist<=0)
             then square^+=DID_Square[t]
             else square^+=DID_Square[t]-round(DID_Square[t]*(dist/dm));
        end; }
end;

procedure aiu_InitVars(pu:PTUnit);
var tx,ty:integer;
      srs:longint;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      aiu_alarm_d          :=NOTSET;
      aiu_alarm_x          :=-1;
      aiu_alarm_y          :=-1;
      aiu_need_detect      :=NOTSET;
      aiu_limitaround_ally :=0;
      aiu_limitaround_enemy:=0;
      aiu_FiledSquareNear  :=0;

      if(uidi=aiucl_main0 [race])
      or(uidi=aiucl_main1 [race])then
      begin
         //if(not ai_ExtBuildingUpgr)then ai_CollectDoodadsSquare(@aiu_FiledSquareNear,x,y,srange);

         tx:=min2i(x,map_psize-x);
         ty:=min2i(y,map_psize-y);
         if(tx<srange)or(ty<srange)then
         begin
            srs:=round(pi*sqr(srange));
            if(tx<srange)then aiu_FiledSquareNear+=srs-round(srs*(tx/srange));
            if(ty<srange)then aiu_FiledSquareNear+=srs-round(srs*(ty/srange));
         end;
      end;
   end;

   // alarm
   ai_alarm_zone     :=0;
   ai_alarm_d        :=NOTSET;
   ai_alarm_x        :=-1;
   ai_alarm_y        :=-1;
end;

procedure ai_InitVars(pu:PTUnit);
var i,d   :integer;
koth_point:boolean;
begin
   with pu^ do
    with uid^ do
     with player^ do
     begin
        ai_AdvancedBuild   :=(ai_flags and aif_base_advance )>0;
        ai_TeleportUse     :=(ai_flags and aif_army_teleport)>0;
        ai_ischoosen       :=(uid_eb[uidi]>ai_MinChoosenCount)and(unum=uid_x[uidi]);
        ai_istransport     :=(transportM>0);
     end;

   ai_limitaround_own      := 0;
   ai_limitaround_enemy_fly:= 0;
   ai_limitaround_enemy_grd:= 0;
   ai_limitaround_fly      := 0;
   ai_limitaround_grd      := 0;

   ai_armylimit_alive_u    := 0;
   ai_armylimit_alive_b    := 0;

   // transport
   ai_transport_cur        := 0;
   ai_transport_need       := 0;
   with pu^ do
    with player^ do
     for i:=1 to 255 do
      if(uprod_now_uid[i]>0)then
       with g_uids[i] do
        if(_ukfly)and(not _ukbuilding)and(_transportM>0)then ai_transport_cur+=_transportM*uprod_now_uid[i];

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
   ai_urepair_d      := NOTSET;

   // cpoints
   ai_cpoint_cp      := nil;
   ai_cpoint_d       := NOTSET;
   ai_cpoint_r       := 0;
   ai_cpoint_n       := 0;

   ai_generator_cp   := nil;
   ai_generator_d    := NOTSET;

   // energy
   ai_enrg_pot       := 0;
   ai_enrg_cur       := 0;

   ai_gen_limit      := 0;

   // nearest builder
   ai_nearest_buildersqr_u     := nil;
   ai_nearest_buildersqr_square:= longint.MaxValue;
   ai_nearest_buildersqr_d     := NOTSET;
   ai_nearest_builder_u        := nil;
   ai_nearest_builder_d        := NOTSET;
   with pu^ do
    if(isbuildarea)and(iscomplete)then
    begin
       ai_nearest_buildersqr_u     :=pu;
       ai_nearest_buildersqr_square:=0;
       ai_nearest_buildersqr_d     :=0;
    end;

   ai_PhantomWantZombieMe:=false;

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
   ai_radars          := 0;

   // who need invuln
   ai_invuln_tar_u    := nil;

   // uac strike target
   ai_strike_tar_u    := nil;

   // who need heye
   ai_need_heye_d     := NOTSET;
   ai_need_heye_u     := nil;

   // builds data
   ai_builders_count  :=0;  // base production
   ai_builders_need   :=0;

   ai_unitp_cur       :=0;  // unit production
   ai_unitp_cur_na    :=0;
   ai_unitp_need      :=0;

   ai_upgrp_cur       :=0;  // upgr production
   ai_upgrp_cur_na    :=0;
   ai_upgrp_need      :=0;

   ai_tech0_cur       :=0;  // tech 0
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

   with pu^ do
   with uid^ do
   with player^ do
   begin
      // get initial alarm point
      for i:=0 to LastPlayer do
       with ai_alarms[i] do
        if(aia_enemy_limit>0)then
         aiu_SetCurrentAlarm(pu,nil,aia_x,aia_y,-1,aia_zone);

      // nearest point/generator
      ai_cpoint_koth:=false;
      for i:=1 to LastKeyPoint do
       with g_KeyPoints[i] do
         if(kp_CaptureR>0)then
         begin
            if(kp_OwnerTeam=team)then
            begin
               if(kp_energy>0)then
               begin
                  ai_enrg_pot+=kp_energy;
                  ai_enrg_cur+=kp_energy;
               end
               else ai_cpoint_n+=1;
            end;

            if(map_scenario=ms_royale)then
              if(g_RoyalBattle_r<(kp_ToCenterD+100))then continue;

            if(kp_x<=0)
            or(kp_y<=0)
            or(kp_x>=map_psize)
            or(kp_y>=map_psize)then continue;

            if(ai_istransport)then
              if(map_IsObstacleZone(kp_Zone))
              or(kp_OwnerTeam=team)then continue;

            d:=point_dist_int(kp_x,kp_y,x,y);

            if(d>kp_CaptureR)then
              if ai_BaseDestinationChecks(pu,kp_Zone)
              then
              else continue;

            koth_point:=(i=1)and(map_scenario=ms_KotH)and(g_step>=g_step_koth_pause);

            if(not koth_point)then
              if((kp_TeamLimit_p[team]>=ul3)and(d> kp_CaptureR))
              or((kp_TeamLimit_p[team]>=ul6)and(d<=kp_CaptureR))then continue;

            if(kp_energy>0)and(not koth_point)then
            begin
               if(d<ai_generator_d)then
               begin
                  ai_generator_d :=d;
                  ai_generator_cp:=@g_KeyPoints[i];
               end;
            end
            else
              if(d<ai_cpoint_d)then
              begin
                 ai_cpoint_d   :=d;
                 ai_cpoint_r   :=kp_CaptureR;
                 ai_cpoint_cp  :=@g_KeyPoints[i];
                 ai_cpoint_koth:=koth_point;
              end;

            //if(d<kp_CaptureR)then break; ??????????
         end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   AI DATA COLLECTION
//

procedure aiu_CollectData(pu,tu:PTUnit;ud:integer;tu_transport:PTUnit;AttackableTarget:boolean);
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(tu^.hits>0)then          // alive
      begin
         if(tu_transport=nil)then // not in transport
         begin
            // buildings square nearest
            if(uidi=aiucl_main0 [race])
            or(uidi=aiucl_main1 [race])then
              if(ud<=srange)and(not tu^.ukfly)then
                if(tu^.speed<=0)or(not tu^.iscomplete)then aiu_FiledSquareNear+=tu^.uid^._square;

            if(team=tu^.player^.team)then    // alies
            begin
               if(not tu^.uid^._ukbuilding)then
                 if (ud<base_1rh)
                 and(tu^.uid^._attack)
                 and(tu^.iscomplete)
                 and(tu^.speed>0)
                 then aiu_limitaround_ally+=tu^.uid^._limituse;
            end
            else
              if(CheckUnitTeamVision(team,tu,true))then  // enemy in vision
              begin
                 if(tu^.buff[ub_invuln]<=0)and(AttackableTarget)then
                 begin
                    ai_SetCurrentAlarm(tu,0,0,ud,0);

                    if(ud<srange)then
                      if (tu^.buff[ub_Invis]>0)
                      and(tu^.TeamDetection[team]<=0)
                      and(tu^.a_reload>0)
                      and(tu^.uid^._attack)
                      then aiu_need_detect:=ud-srange-hits;
                 end;

                 if (ud<base_1rh)
                 and(tu^.uid^._attack)
                 then aiu_limitaround_enemy+=tu^.uid^._limituse;
              end;
         end;
      end;
   end;
end;

procedure ai_CollectData(pu,tu:PTUnit;ud:integer;tu_transport:PTUnit;AttackableTarget:boolean);
var pfcheck:boolean;
procedure _setCommander(pv:PPTUnit;pd:pinteger;d:integer);
begin
   if(pv^=nil)
   then
   else
     if(tu^.speed<pv^^.speed)
     then
     else
       if (tu^.speed=pv^^.speed)
       and(tu^.unum <pv^^.unum)
       then
       else exit;

   pv^:=tu;
   pd^:=d;
end;
procedure _setNearestTarget(ppu:PPTunit;pd:pinteger;newvalue:integer);
begin
   if(newvalue<pd^)then
   begin
      pd^ :=newvalue;
      ppu^:=tu;
   end;
end;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      pfcheck:=(ukfly)or(ukfloater){or pf_EqZones(pfzone,tu^.pfzone)};
      if(tu^.hits>0)then                         // alive
      begin
         if(tu_transport=nil)then                // not in transport
         begin
            if(team=tu^.player^.team)then        // alies
            begin
               if(tu^.uid^._attack)then        // can attack
               begin
                  // towers
                  if(tu^.uidi=aiucl_twr_air1[race])
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
                    end;
                  if(tu^.iscomplete)then
                  begin
                     // active detection: hell eye target
                     if(tu^.aiu_need_detect<ai_need_heye_d)then
                      if(tu^.buff[ub_Detect]<=0)and(tu^.buff[ub_HVision]<=0)then
                      begin
                         ai_need_heye_u:=tu;
                         ai_need_heye_d:=tu^.aiu_need_detect;
                      end;
                     // invuln target
                     if (tu^.aiu_alarm_d<=tu^.srange)
                     and(tu^.aiu_limitaround_enemy>tu^.aiu_limitaround_ally)
                     and(not tu^.uid^._ukbuilding)
                     and(IsIntUnitRange(tu^.a_tar,nil))
                     and(tu^.buff[ub_Invuln ]<=0)
                     and(tu^.buff[ub_Damaged]>0)then
                      if(ai_invuln_tar_u=nil)
                      then ai_invuln_tar_u:=tu
                      else
                        if(tu^.hits>ai_invuln_tar_u^.hits)then ai_invuln_tar_u:=tu;
                  end;
               end;
               if (not tu^.uid^._attack   )
               and(tu^.uid^._ukbuilding   )
               and(tu^.uidi<>UID_HEye     )
               and(tu^.aiu_alarm_d<base_1rh)then
                 if(tu^.aiu_limitaround_enemy>=tu^.aiu_limitaround_ally)
                 then _setNearestTarget(@ai_abase_u,@ai_abase_d,ud);

               // teleporter beacon
               if(tu^.aiu_alarm_d<base_1r)then
                 if(not map_IsObstacleZone(tu^.zone))then
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
                if(tu^.iscomplete)and(tu^.hits<tu^.uid^._mhits)and(tu^.buff[ub_Heal]<=0)then
                 if(tu^.uid^._ukmech)
                 then _setNearestTarget(@ai_mrepair_u,@ai_mrepair_d,ud)
                 else _setNearestTarget(@ai_urepair_u,@ai_urepair_d,ud);
            end
            else
             if(CheckUnitTeamVision(team,tu,false))then  // enemy in vision
             begin
                if(tu^.buff[ub_invuln]<=0)then
                begin
                   // enemy
                   _setNearestTarget(@ai_enemy_u,@ai_enemy_d,ud);
                   if(tu^.ukfly)
                   and(tu^.uidi<>UID_LostSoul)
                   and(tu^.uidi<>UID_Phantom)then
                   begin
                      _setNearestTarget(@ai_enemy_air_u,@ai_enemy_air_d,ud);
                      if(ud<base_1rh)and(tu^.uid^._attack)then ai_limitaround_enemy_fly+=tu^.uid^._limituse;
                   end
                   else
                   begin
                      _setNearestTarget(@ai_enemy_grd_u,@ai_enemy_grd_d,ud);
                      if(ud<base_1rh)and(tu^.uid^._attack)then ai_limitaround_enemy_grd+=tu^.uid^._limituse;
                   end;
                   if(tu^.uid^._ukbuilding)and(not tu^.ukfly)and(pfcheck)then _setNearestTarget(@ai_enemy_build_u,@ai_enemy_build_d,ud);

                   // uac strike target
                   if(tu^.speed<8)then
                    if(ai_strike_tar_u=nil)
                    then ai_strike_tar_u:=tu
                    else
                      if(tu^.uid^._ukbuilding)and(not ai_strike_tar_u^.uid^._ukbuilding)
                      then ai_strike_tar_u:=tu
                      else
                        if(tu^.hits>ai_strike_tar_u^.hits)
                        then ai_strike_tar_u:=tu;
                end;

                // nearest phantom
                if(not ai_PhantomWantZombieMe)and(_zombie_uid>0)then
                 if(tu^.uidi=UID_Phantom)and(tu^.a_tar=unum)then
                  if((ud-_r-tu^.uid^._r)<=melee_r)then ai_PhantomWantZombieMe:=true;
             end
             else
               if(CheckUnitTeamVision(team,tu,true))then
               begin
                  // invisible enemy unit
                  if(tu^.buff[ub_Invis]>0)and(tu^.TeamDetection[team]<=0)and(tu^.a_reload>0)and(tu^.buff[ub_Scaned]<=0)then
                    _setNearestTarget(@ai_enemy_inv_u,@ai_enemy_inv_d,ud);
               end;

            if(playeri=tu^.playeri)then
            begin
               if(tu^.iscomplete)then
               begin
                  // nearest teleport
                  if(not ukfly)and(tu^.uid^._ability=ua_HTeleport)then
                  begin
                     if(pfcheck)and(ud<base_3r)then _setNearestTarget(@ai_teleporterF_u,@ai_teleporterF_d,ud+(tu^.reload*20));
                     if(ud>=base_3r)or(not pfcheck)
                     then _setNearestTarget(@ai_teleporterR_u,@ai_teleporterR_d,tu^.reload)
                     else ai_limitaround_teleports+=tu^.uid^._limituse;
                  end;

                  if(tu^.unum<>ai_scout_u_cur)then

                  begin
                     // transport target
                     if(tu^.group<>aio_attack_busy)and(tu^.group<>aio_home_busy)then
                      if(transportC<transportM)and(ud<ai_transport_tar_d)then
                       if(tu^.aiu_alarm_d>base_1rh)then
                        if(tu^.transportC=tu^.transportM)or(armylimit>=ai_limit_border)or(armylimit>=ai_attack_limit)then
                         if(pfcheck)then
                          if(unit_TransportCheck(pu,tu))then _setNearestTarget(@ai_transport_tar_u,@ai_transport_tar_d,ud);

                     // commander
                     if(ud<base_2r)and(tu^.speed>0)and(not tu^.uid^._ukbuilding)then
                      if(tu^.ukfly=false)
                      then _setCommander(@ai_commander_grd_u,@ai_commander_grd_d,ud)
                      else _setCommander(@ai_commander_fly_u,@ai_commander_fly_d,ud);
                  end;

                  // builder

                  if(tu^.uidi=aiucl_main0 [race])
                  or(tu^.uidi=aiucl_main1 [race])then
                  begin
                     if(ai_nearest_buildersqr_square>0)then
                       if(tu^.aiu_FiledSquareNear<ai_nearest_buildersqr_square)then
                       begin
                          ai_nearest_buildersqr_square:=tu^.aiu_FiledSquareNear;
                          ai_nearest_buildersqr_u     :=pu;
                          ai_nearest_buildersqr_d     :=ud;
                       end;
                     _setNearestTarget(@ai_nearest_builder_u,@ai_nearest_builder_d,ud);
                  end;
               end;

               // nearest base
               if (tu^.uidi<>UID_HEye)
               and(tu^.aiu_alarm_d>base_2r)
               and(tu^.uid^._ukbuilding)
               and(tu^.speed<=0)
               and(pfcheck)then _setNearestTarget(@ai_base_u,@ai_base_d,ud-_r-tu^.uid^._r);
            end;
         end;

         if(player=tu^.player)then
         begin
            if(uid=tu^.uid)and(not iscomplete)then ai_inprogress_uid+=1;

            if(tu^.uid^._rebuild_uid>0)and(ai_AdvancedBuild)then
            begin
               if(not tu^.uid^._isbuilder)
               or((tu^.uid^._isbuilder)and(n_builders>1))
               then ai_enrg_pot+=g_uids[tu^.uid^._rebuild_uid]._genergy;
            end
            else ai_enrg_pot+=tu^.uid^._genergy;

            ai_enrg_cur+=tu^.uid^._genergy;

            if(tu^.iscomplete)then
            begin
               if(tu^.speed>0)and(tu^.uid^._attack)then
               begin
                  if(tu^.ukfly)
                  then ai_limitaround_fly+=tu^.uid^._limituse
                  else ai_limitaround_grd+=tu^.uid^._limituse;
                  if(ud<=base_1r)
                  then ai_limitaround_own+=tu^.uid^._limituse;
               end;
               if(tu^.uid^._ability=ua_UScan)then ai_radars+=1;
               // transport
               if(not tu^.uid^._ukbuilding)then
               begin
                  if(tu^.transportM>0)and(tu^.ukfly)then ai_transport_cur+=tu^.transportM;
                  if(tu^.transportM=tu^.transportC)and(not tu^.ukfly)and(tu^.uid^._attack)then ai_transport_need+=tu^.uid^._transportS;
               end;
            end;
            // armylimit
            if(tu^.uid^._ukbuilding)
            then ai_armylimit_alive_b+=tu^.uid^._limituse
            else ai_armylimit_alive_u+=tu^.uid^._limituse;

            // detection near
            if(ud<=srange)then
             if(tu^.buff[ub_Detect]>0)
             or(tu^.uid^._ability=ua_HellVision)
             or(tu^.uid^._ability=ua_UScan   )then ai_detect_near+=1;

            // generators limit
            if(tu^.uidi=aiucl_generator[race])then ai_gen_limit+=tu^.uid^._limituse;

            // unit productions
            if(tu^.uid^._isbarrack)then
             if(tu^.uidi=aiucl_barrack0[race])
             or(tu^.uidi=aiucl_barrack1[race])then
             begin
                ai_unitp_cur+=tu^.level+1;
                if(tu^.level=0)then
                ai_unitp_cur_na+=1;
             end;

            // upgrade productions
            if(tu^.uid^._issmith)then
             if(tu^.uidi=aiucl_smith[race])then
             begin
                ai_upgrp_cur+=tu^.level+1;
                if(tu^.level=0)then
                ai_upgrp_cur_na+=1;
             end;
         end;
      end;

      if(tu^.uid^._zombie_uid>0)and(pfcheck)then
        if(fdead_hits<tu^.hits)and(tu^.hits<=tu^.uid^._zombie_hits)then _setNearestTarget(@ai_ZombieTarget_u,@ai_ZombieTarget_d,ud);
   end;
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
   with g_players[playeri] do
   begin
      if(IsIntUnitRange(ai_scout_u_cur,@tu))
      then ai_scout_u_cur_w:=_unitWeaponPriority(tu,wtp_Scout,false)
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
      ai_scout_u_new_w:=0;

     if(map_scenario=ms_royale)then
      for a:=0 to LastPlayer do
       with ai_alarms[a] do
        if(aia_enemy_limit>0)then
         if(CheckRoyalBattleRadiusPoint(aia_x,aia_y,base_1r))then aia_enemy_limit:=0;

      if(ai_detection_pause>0)then ai_detection_pause-=1;

      if(g_timer_UnitCycle=pnum)then
      begin
         if(ai_scout_u_cur=0)
         then ai_scout_timer:=0
         else
           if(ai_scout_timer=0)
           then ai_scout_timer:=max2i(1,ai_attack_delay)
           else ai_timer(@ai_scout_timer,0);

         ai_ReadyForAttack:=(armylimit>=ai_limit_border)
                          or((ucl_l[false]+uprod_limit)>=ai_maxlimit_blimit)
                          or(ucl_l[true]<=0);

         if(not ai_ReadyForAttack)
         then ai_attack_timer:=0
         else
           if(ai_attack_timer=0)
           then ai_attack_timer:=max2i(1,ai_attack_delay)
           else ai_timer(@ai_attack_timer,fr_fps60);
      end;
   end;
end;

procedure ai_scout_pick(pu:PTUnit);
var w:integer;
   tu:PTUnit;
begin
   if(map_scenario=ms_KotH    )
   or(map_scenario=ms_capture )
   or(map_scenario=ms_royale  )then exit;

   with pu^ do
   begin
      if(hits<=0)
      or(speed<=0)
      or(uid^._ukbuilding)
      or(not iscomplete)
      or(transportM>0)then exit;

      if((player^.ai_flags and aif_army_scout)=0)then exit;

      if(IsIntUnitRange(transport,nil))then exit;
   end;

   w:=_unitWeaponPriority(pu,wtp_Scout,false);
   if(w>0)then
    with pu^.player^ do
     if(w>ai_scout_u_new_w)then
     begin
        ai_scout_u_new_w:=w;
        ai_scout_u_new  :=pu^.unum;
     end
     else
       if(w=ai_scout_u_new_w)then
        if(IsIntUnitRange(ai_scout_u_new,@tu))then
         if(pu^.speed>tu^.speed)then ai_scout_u_new:=pu^.unum;
end;


