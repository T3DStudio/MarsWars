
const

aiucl_main0      : array[1..r_cnt] of byte = (UID_HKeep          ,UID_UCommandCenter );
aiucl_main0A     : array[1..r_cnt] of byte = (UID_HAKeep         ,UID_UACommandCenter);
aiucl_main1      : array[1..r_cnt] of byte = (UID_HCommandCenter ,0                  );
aiucl_main1A     : array[1..r_cnt] of byte = (UID_HACommandCenter,0                  );
aiucl_generator  : array[1..r_cnt] of byte = (UID_HSymbol        ,UID_UGenerator     );
aiucl_barrack0   : array[1..r_cnt] of byte = (UID_HGate          ,UID_UBarracks      );
aiucl_barrack1   : array[1..r_cnt] of byte = (UID_HBarracks      ,UID_UFactory       );
aiucl_smith      : array[1..r_cnt] of byte = (UID_HPools         ,UID_UWeaponFactory );
aiucl_tech0      : array[1..r_cnt] of byte = (UID_HPentagram     ,UID_UComputerStation  );
aiucl_tech1      : array[1..r_cnt] of byte = (UID_HMonastery     ,UID_UTechCenter    );
aiucl_tech2      : array[1..r_cnt] of byte = (UID_HFortress      ,UID_UComputerStation  );
aiucl_detect     : array[1..r_cnt] of byte = (UID_HEye           ,UID_URadar         );
aiucl_spec1      : array[1..r_cnt] of byte = (UID_HAltar         ,UID_URMStation     );
aiucl_spec2      : array[1..r_cnt] of byte = (UID_HTeleport      ,0                  );
aiucl_twr_air1   : array[1..r_cnt] of byte = (UID_HTower         ,UID_UATurret       );
aiucl_twr_air2   : array[1..r_cnt] of byte = (UID_HTotem         ,UID_UATurret       );
aiucl_twr_ground1: array[1..r_cnt] of byte = (UID_HTower         ,UID_UGTurret       );
aiucl_twr_ground2: array[1..r_cnt] of byte = (UID_HTotem         ,UID_UGTurret       );

ai_GeneratorsEnergy       = 3500;
ai_GeneratorsDestroyEnergy= 4250;
ai_GeneratorsDestoryLimit = MinUnitLimit*80;
ai_TowerLifeTime          = fr_fps1*60;
ai_MinArmyForScout        = 0;
ai_MinScoutDelay          = fr_fps1*ptime1;
ai_BaseIDLERange          = 100;
ai_MinBaseSaveCountBorder = 6;
ai_MinChoosenCount        = 6;
ai_FiledSquareBorder      = 150000;

aio_home   = 0;
aio_scout  = 1;
aio_busy   = 2;
aio_attack = 3;

var

ai_alarm_zone    : word;
ai_alarm_unit,

ai_need_heye_u,
ai_grd_commander_u,
ai_fly_commander_u,
ai_inapc_u,
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
ai_nearest_builder_u,
ai_ZombieTarget_u,
ai_base_u         : PTUnit;
ai_generator_cp,
ai_cpoint_cp      : PTCTPoint;

ai_ReadyForAttack,
ai_extbuilding,
ai_PhantomWantZombieMe,
ai_advanced_bld,
ai_teleport_use,
ai_choosen,
ai_cpoint_koth    : boolean;

ai_generator_d,
ai_generator_r,
ai_cpoint_d,
ai_cpoint_n,
ai_cpoint_r,
ai_alarm_d,
ai_alarm_x,
ai_alarm_y,
ai_grd_commander_d,
ai_fly_commander_d,
ai_need_heye_d,
ai_inapc_d,
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
ai_transport_cur,
ai_transport_need,
ai_inprogress_uid,
ai_radars
                        : integer;

ai_nearest_builder_square,
ai_armylimit_alive_u,
ai_armylimit_alive_b,
ai_limitaround_own,
ai_limitaround_enemy_fly,
ai_limitaround_enemy_grd,
ai_limitaround_teleports,
ai_limitaround_air,
ai_limitaround_ground   : longint;

procedure ai_PlayerSetAlarm(pplayer:PTPlayer;ax,ay:integer;alimit:longint;arange:integer;abase:boolean;apfzone:word);
var a,
anobase,
afree  :byte;
begin
   afree  :=255;
   anobase:=255;  //no base alarm, low priority, can be replaced by base alarm
   ax:=mm3(1,ax,map_mw);
   ay:=mm3(1,ay,map_mw);
   with pplayer^ do
    for a:=0 to MaxPlayers do
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
         aia_zone:=apfzone;
      end;
   end;
end;

procedure ai_MakeScirmishStartAlarms(p:byte);
var i:byte;
begin
   if(not g_fixed_positions)then
   begin
      if(map_symmetry)then ai_PlayerSetAlarm(@_players[p],map_mw-map_psx[p],map_mw-map_psy[p],1,base_1r,true,pf_get_area(map_mw-map_psx[p],map_mw-map_psy[p]));
   end
   else
      for i:=1 to MaxPlayers do
       if(i<>p)then
        if(_players[i].state>ps_none)then
         if(_players[i].team<>_players[p].team)then
          ai_PlayerSetAlarm(@_players[p],map_psx[i],map_psy[i],1,base_1r,true,pf_get_area(map_psx[i],map_psy[i]));
end;

procedure  ai_PlayerSetSkirmishSettings(p:byte);
procedure SetBaseOpt(me,m,unp,upp,t0,t1,t2,dl,s1,s2,mint,maxt,atl,att,l:integer;mupl:byte;hpt:TSoB);
begin
   with _players[p] do
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
      ai_attack_pause     :=att;
      ai_maxlimit_blimit  :=l*MinUnitLimit;
      ai_maxcount_upgrlvl :=mupl;
      ai_hptargets        :=hpt;
   end;
end;
begin
   with _players[p] do
   begin
      case ai_skill of
      //              energ buil uprod  pprod tech0 tech1 tech2 radar rsta    telepo  min    max    attack attack     max           upgr first
      //                    ders                                heye                  towers towers limit  delay      army          lvl  targets
      0  : ; // nothing                                         limit
      1  : SetBaseOpt(300  ,1   ,1     ,0    ,0    ,0    ,0    ,0    ,0      ,0       ,1    ,1     ,12    ,fr_fps1*180,12            ,0  ,[]);
      2  : SetBaseOpt(1200 ,1   ,2     ,1    ,0    ,0    ,0    ,2    ,0      ,0       ,3    ,3     ,25    ,fr_fps1*150,25            ,0  ,[]);
      3  : SetBaseOpt(2400 ,3   ,4     ,1    ,0    ,0    ,0    ,6    ,0      ,1       ,6    ,6     ,40    ,fr_fps1*120,40            ,1  ,[]);
      4  : SetBaseOpt(3600 ,7   ,8     ,2    ,0    ,1    ,0    ,8    ,0      ,2       ,10   ,10    ,60    ,fr_fps1*90 ,60            ,2  ,[]);
      5  : SetBaseOpt(4200 ,12  ,11    ,3    ,0    ,1    ,1    ,10   ,1      ,2       ,10   ,14    ,70    ,fr_fps1*60 ,70            ,3  ,[UID_Pain,UID_ArchVile,UID_Medic]);
      6  : SetBaseOpt(4900 ,18  ,14    ,4    ,1    ,1    ,1    ,12   ,1      ,3       ,2    ,14    ,120   ,fr_fps1*30 ,MaxPlayerUnits,4  ,[UID_Pain,UID_ArchVile,UID_Medic,UID_BFGMarine,UID_ZBFGMarine]);
      else SetBaseOpt(6000 ,24  ,20    ,6    ,1    ,1    ,1    ,14   ,1      ,3       ,2    ,14    ,120   ,1          ,MaxPlayerUnits,15 ,[UID_Pain,UID_ArchVile,UID_Medic,UID_BFGMarine,UID_ZBFGMarine]);
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
                    +aif_ability_mainsave;
      4  : ai_flags:=aif_army_scout
                    +aif_base_smart_order
                    +aif_base_advance
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
   ai_MakeScirmishStartAlarms(p);
end;

function ai_HighPriorityTarget(player:PTPlayer;tu:PTUnit):boolean;
begin
   ai_HighPriorityTarget:=false;
   if(player^.state=ps_comp)then
    ai_HighPriorityTarget:=tu^.uidi in player^.ai_hptargets;
end;

////////////////////////////////////////////////////////////////////////////////

procedure ai_SetAlarm(tu:PTUnit;x,y,ud:integer;zone:word);
begin
   if(ud<ai_alarm_d)then
   begin
      if(tu<>nil)then
      begin
         x   :=tu^.x;
         y   :=tu^.y;
         zone:=tu^.pfzone;
      end;
      ai_alarm_x   :=x;
      ai_alarm_y   :=y;
      ai_alarm_d   :=ud;
      ai_alarm_zone:=zone;
      ai_alarm_unit:=tu;
   end;
end;

procedure ai_CollectDIDSquare(square:plongint;tx,ty,tr:integer);
var dx,dy,u,dist,dm:integer;
begin
   dx:=tx div dcw;
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
        end;
end;

procedure aiu_InitVars(pu:PTUnit);
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

      ai_extbuilding       :=(upgr[upgr_race_extbuilding[_urace]]>0);

      if(not ai_extbuilding)then
        if(uidi=aiucl_main0 [race])
        or(uidi=aiucl_main0A[race])
        or(uidi=aiucl_main1 [race])
        or(uidi=aiucl_main1A[race])
        then ai_CollectDIDSquare(@aiu_FiledSquareNear,x,y,srange);
   end;

   // alarm
   ai_alarm_zone     :=0;
   ai_alarm_d        :=NOTSET;
   ai_alarm_x        :=-1;
   ai_alarm_y        :=-1;
   ai_alarm_unit     :=nil;
end;

procedure ai_InitVars(pu:PTUnit);
var i,d,ds:integer;
koth_point:boolean;
begin
   with pu^ do
    with uid^ do
     with player^ do
     begin
        ai_advanced_bld   :=(ai_flags and aif_base_advance )>0;
        ai_teleport_use   :=(ai_flags and aif_army_teleport)>0;
        ai_choosen        :=(uid_eb[uidi]>ai_MinChoosenCount)and(unum=uid_x[uidi]);
     end;

   ai_limitaround_own      :=0;
   ai_limitaround_enemy_fly:=0;
   ai_limitaround_enemy_grd:=0;
   ai_limitaround_air      :=0;
   ai_limitaround_ground   :=0;

   ai_armylimit_alive_u    :=0;
   ai_armylimit_alive_b    :=0;

   // transport
   ai_transport_cur        := 0;
   ai_transport_need       := 0;
   with pu^ do
    with player^ do
     for i:=1 to 255 do
      if(uprodu[i]>0)then
       with _uids[i] do
        if(_ukfly)and(not _ukbuilding)and(_apcm>0)then ai_transport_cur+=_apcm*uprodu[i];


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
   ai_generator_r    := 0;

   // energy
   ai_enrg_pot       :=0;
   ai_enrg_cur       :=0;

   // nearest builder
   ai_nearest_builder_u     :=nil;
   ai_nearest_builder_square:=longint.MaxValue;
   with pu^ do
    if(isbuildarea)and(iscomplete)then
    begin
       ai_nearest_builder_u     :=pu;
       ai_nearest_builder_square:=0;
    end;

   with pu^ do
   with uid^ do
   with player^ do
   begin
      // get initial alarm point
      for i:=0 to MaxPlayers do
       with ai_alarms[i] do
        if(aia_enemy_limit>0)then
         if(ukfly)
         or(ukfloater)
         or(aia_zone=pfzone)
         or(uid^._isbarrack)then ai_SetAlarm(nil,aia_x,aia_y,point_dist_int(aia_x,aia_y,x,y),aia_zone);

      ai_cpoint_koth:=false;
      for i:=1 to MaxCPoints do
       with g_cpoints[i] do
         if(cpCapturer>0)then
         begin
            if(cpOwnerTeam=team)then
            begin
               if(cpenergy>0)then
               begin
                  ai_enrg_pot+=cpenergy;
                  ai_enrg_cur+=cpenergy;
               end
               else ai_cpoint_n+=1;
            end;

            d:=point_dist_int(cpx,cpy,x,y);

            if(d>cpCapturer)and(pfzone<>cpzone)then
              if not(ukfly
                  or ukfloater
                  or(ai_extbuilding and _ukbuilding)
                  or(_isbarrack) )then continue;

            if(apcm>0)and(_attack<>atm_bunker)then
              if(pf_IfObstacleZone(cpzone))
              or(cpOwnerTeam=team)then continue;

            koth_point:=(i=1)and(g_mode=gm_koth)and(g_step>=g_step_koth_pause);

            if(not koth_point)then
              if((cpunitst_pstate[team]>ul3)and(d> cpCapturer))
              or((cpunitst_pstate[team]>ul6)and(d<=cpCapturer))then continue;

            if(cpenergy>0)and(not koth_point)then
            begin
               ds:=d;
               if(menergy<2000)
               then ds:=d div 4;
               if(cpOwnerTeam=0)
               or(cpOwnerPlayer=0)then ds:=d div 4;

               if(ds<ai_generator_d)then
               begin
                  ai_generator_d :=ds;
                  ai_generator_r :=cpCapturer;
                  ai_generator_cp:=@g_cpoints[i];
               end;
            end
            else
              if(d<ai_cpoint_d)then
              begin
                 ai_cpoint_d   :=d;
                 ai_cpoint_r   :=cpCapturer;
                 ai_cpoint_cp  :=@g_cpoints[i];
                 ai_cpoint_koth:=koth_point;
              end;
         end;
   end;

   ai_PhantomWantZombieMe:=false;

   ai_ZombieTarget_u  := nil;
   ai_ZombieTarget_d  := NOTSET;

   // commander
   ai_grd_commander_u := nil;
   ai_fly_commander_u := nil;
   ai_grd_commander_d := NOTSET;
   ai_fly_commander_d := NOTSET;

   // nearest own building
   ai_base_d          := NOTSET;
   ai_base_u          := nil;

   // nearest own building with alarm
   ai_abase_d         := NOTSET;
   ai_abase_u         := nil;

   // transport target
   ai_inapc_d         := NOTSET;
   ai_inapc_u         := nil;

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
   ai_towers_need     :=0;
   ai_towers_need_type:=0;

   ai_inprogress_uid:=0;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   AI DATA
//

procedure aiu_CollectData(pu,tu:PTUnit;ud:integer;tu_transport:PTUnit);
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
            or(uidi=aiucl_main0A[race])
            or(uidi=aiucl_main1 [race])
            or(uidi=aiucl_main1A[race])then
              if(ud<=srange)and(tu^.speed<=0)and(not tu^.ukfly)then aiu_FiledSquareNear+=tu^.uid^._square;

            if(team=tu^.player^.team)then    // alies
            begin
               if(not tu^.uid^._ukbuilding)then
                if (ud<base_1rh)
                and(tu^.uid^._attack>0)
                and(tu^.iscomplete)
                and(tu^.speed>0)
                then aiu_limitaround_ally+=tu^.uid^._limituse;
           end
           else
             if(CheckUnitTeamVision(team,tu,true))then  // enemy in vision
               if(tu^.buff[ub_invuln]<=0)then
               begin
                  ai_SetAlarm(tu,0,0,ud,0);

                  if (ud<base_1rh)
                  and(tu^.uid^._attack>0)then aiu_limitaround_enemy+=tu^.uid^._limituse;

                  if(tu^.buff[ub_Invis]>0)and(tu^.vsni[team]<=0)and(tu^.a_rld>0)and(tu^.buff[ub_Scaned]<=0)then
                    if(ud<srange)and(tu^.uid^._attack>0)then aiu_need_detect:=ud-srange-hits;
               end;
         end;
      end;
   end;
end;

procedure ai_CollectData(pu,tu:PTUnit;ud:integer;tu_transport:PTUnit);
var pfcheck:boolean;
procedure _setCommanderVar(pv:PPTUnit;pd:pinteger;d:integer);
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
procedure _setNearestTarget(ppu:PPTunit;pd:pinteger;d:integer);
begin
   if(ud<pd^)then
   begin
      pd^ :=d;
      ppu^:=tu;
   end;
end;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      pfcheck:=(ukfly)or(ukfloater)or(pfzone=tu^.pfzone);
      if(tu^.hits>0)then                         // alive
      begin
         if(tu_transport=nil)then                // not in transport
         begin
            if(team=tu^.player^.team)then        // alies
            begin
               if(tu^.uid^._attack>0)then        // can attack
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
                     //// active detection
                     // hell eye target
                     if(tu^.aiu_need_detect<ai_need_heye_d)then
                      if(tu^.buff[ub_Detect]<=0)and(tu^.buff[ub_HVision]<=0)then
                      begin
                         ai_need_heye_u:=tu;
                         ai_need_heye_d:=tu^.aiu_need_detect;
                      end;
                     // invuln target
                     if (tu^.aiu_alarm_d<=tu^.srange)
                     and(tu^.aiu_limitaround_enemy>=tu^.aiu_limitaround_ally)
                     and(not tu^.uid^._ukbuilding)
                     and(_IsUnitRange(tu^.a_tar,nil))
                     and(tu^.buff[ub_Invuln]<=0)
                     and(tu^.buff[ub_Damaged]>0)then
                      if(ai_invuln_tar_u=nil)
                      then ai_invuln_tar_u:=tu
                      else
                        if(tu^.hits>ai_invuln_tar_u^.hits)then ai_invuln_tar_u:=tu;
                  end;
               end;
               if (tu^.uid^._attack=0     )
               and(tu^.uid^._ukbuilding   )
               and(tu^.uidi<>UID_HEye     )
               and(tu^.aiu_alarm_d<base_1rh)then
                 if((tu^.aiu_limitaround_ally-ul5)<=tu^.aiu_limitaround_enemy)
                 or(g_mode=gm_invasion)
                 then _setNearestTarget(@ai_abase_u,@ai_abase_d,ud);

               // teleporter beacon
               if(tu^.aiu_alarm_d<base_1r)then
                 if(not pf_IfObstacleZone(tu^.pfzone))then
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
             if(CheckUnitTeamVision(team,tu,true))then  // enemy in vision
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
                      if(ud<base_1rh)and(tu^.uid^._attack>0)then ai_limitaround_enemy_fly+=tu^.uid^._limituse;
                   end
                   else
                   begin
                      _setNearestTarget(@ai_enemy_grd_u,@ai_enemy_grd_d,ud);
                      if(ud<base_1rh)and(tu^.uid^._attack>0)then ai_limitaround_enemy_grd+=tu^.uid^._limituse;
                   end;
                   if(tu^.uid^._ukbuilding)and(not tu^.ukfly)and(pfcheck)then _setNearestTarget(@ai_enemy_build_u,@ai_enemy_build_d,ud);


                   // invisible enemy unit
                   if(tu^.buff[ub_Invis]>0)and(tu^.vsni[team]<=0)and(tu^.a_rld>0)and(tu^.buff[ub_Scaned]<=0)then
                     _setNearestTarget(@ai_enemy_inv_u,@ai_enemy_inv_d,ud);

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
             end;

            if(playeri=tu^.playeri)then
            begin
               if(tu^.iscomplete)then
               begin
                  // nearest teleport
                  if(not ukfly)and(tu^.uid^._ability=uab_Teleport)then
                  begin
                     if(pfcheck)and(ud<base_3r)then _setNearestTarget(@ai_teleporterF_u,@ai_teleporterF_d,ud+(tu^.rld*20));
                     if(ud>=base_3r)
                     then _setNearestTarget(@ai_teleporterR_u,@ai_teleporterR_d,tu^.rld)
                     else ai_limitaround_teleports+=tu^.uid^._limituse;
                  end;

                  if(tu^.unum<>ai_scout_u_cur)and(tu^.group<>aio_busy)then
                  begin
                     // transport target
                     if(apcc<apcm)and(ud<ai_inapc_d)then
                      if(tu^.aiu_alarm_d>base_1rh)or(_attack=atm_bunker)then
                       if(tu^.apcc=tu^.apcm)or(armylimit>=ai_limit_border)or(armylimit>=ai_attack_limit)then
                        if(pfcheck)then
                         if(_itcanapc(pu,tu))then _setNearestTarget(@ai_inapc_u,@ai_inapc_d,ud);

                     // commander
                     if(ud<base_2r)and(tu^.speed>0)and(not tu^.uid^._ukbuilding)then
                      if(tu^.ukfly=false)
                      then _setCommanderVar(@ai_grd_commander_u,@ai_grd_commander_d,ud)
                      else _setCommanderVar(@ai_fly_commander_u,@ai_fly_commander_d,ud);
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

            if(tu^.uid^._rebuild_uid>0)and(ai_advanced_bld)then
            begin
               if(not tu^.uid^._isbuilder)
               or((tu^.uid^._isbuilder)and(n_builders>1))
               then ai_enrg_pot+=_uids[tu^.uid^._rebuild_uid]._genergy;
            end
            else ai_enrg_pot+=tu^.uid^._genergy;

            ai_enrg_cur+=tu^.uid^._genergy;

            if(tu^.iscomplete)then
            begin
               if(tu^.speed>0)and(tu^.uid^._attack>0)then
               begin
                  if(tu^.ukfly)
                  then ai_limitaround_air   +=tu^.uid^._limituse
                  else ai_limitaround_ground+=tu^.uid^._limituse;
                  if(ud<=base_1r)then
                  ai_limitaround_own  +=tu^.uid^._limituse;
               end;
               if(tu^.uid^._ability=uab_UACScan)then ai_radars+=1;
               // transport
               if(not tu^.uid^._ukbuilding)then
               begin
                  if(tu^.apcm>0)and(tu^.ukfly)then ai_transport_cur+=tu^.apcm;
                  if(tu^.apcm=tu^.apcc)and(not tu^.ukfly)and(tu^.uid^._attack>0)then ai_transport_need+=tu^.uid^._apcs;
               end;
            end;
            // armylimit
            if(tu^.uid^._ukbuilding)
            then ai_armylimit_alive_b+=tu^.uid^._limituse
            else ai_armylimit_alive_u+=tu^.uid^._limituse;

            // detection near
            if(ud<=srange)then
             if(tu^.buff[ub_Detect]>0)
             or(tu^.uid^._ability=uab_HellVision)
             or(tu^.uid^._ability=uab_UACScan   )then ai_detect_near+=1;

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

procedure ai_player_code(playeri:byte);
var tu:PTunit;
    a :byte;
begin
   with _players[playeri] do
   begin
      if(ai_detection_pause>0)then ai_detection_pause-=1;

      if(_IsUnitRange(ai_scout_u_cur,@tu))
      then ai_scout_u_cur_w:=_unitWeaponPriority(tu,wtp_scout,false)
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

     if(g_mode=gm_royale)then
      for a:=0 to MaxPlayers do
       with ai_alarms[a] do
        if(aia_enemy_limit>0)then
         if(_CheckRoyalBattlePoint(aia_x,aia_y,base_1r))then aia_enemy_limit:=0;
   end;
end;

procedure ai_scout_pick(pu:PTUnit);
var w:integer;
   tu:PTUnit;
begin
   if(pu^.playeri=0)and(g_mode=gm_invasion)then exit;

   w:=_unitWeaponPriority(pu,wtp_scout,false);
   if(w>0)then
    with pu^.player^ do
     if(w>ai_scout_u_new_w)then
     begin
        ai_scout_u_new_w:=w;
        ai_scout_u_new  :=pu^.unum;
     end
     else
       if(w=ai_scout_u_new_w)then
        if(_IsUnitRange(ai_scout_u_new,@tu))then
         if(pu^.speed>tu^.speed)then ai_scout_u_new:=pu^.unum;
end;

function ai_isnoprod(pu:PTUnit):boolean;
var i:integer;
begin
   ai_isnoprod:=true;
   with pu^  do
   with uid^ do
   for i:=0 to MaxUnitLevel do
   begin
      if(i>level)then break;
      if((_isbarrack)and(uprod_r[i]>0))
      or((_issmith  )and(pprod_r[i]>0))then
      begin
         ai_isnoprod:=false;
         exit;
      end;
   end;
end;

function ai_checkCPNear(nobuildr:integer):boolean;
var cp:PTCTPoint;
    d :integer;
begin
   ai_checkCPNear:=true;

   cp:=nil;
   d :=NOTSET;
   if(ai_cpoint_d<d)then
   begin
      cp:=ai_cpoint_cp;
      d :=ai_cpoint_d;
   end;
   if(ai_generator_d<d)then
   begin
      cp:=ai_generator_cp;
      d :=ai_generator_d;
   end;

   if(cp<>nil)then
    with cp^ do
    begin
       if(d<(cpnobuildr+nobuildr))then exit;

       if(d<=cpCaptureR)then exit;
    end;
   ai_checkCPNear:=false;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   BUILD BASE
//

procedure ai_builder(pu:PTUnit);
var  bt : byte;
   ddir,
   rdir : single;
base_energy,
ai_need_energy,
bx,by,l : integer;
skip_energy_check:boolean;

function SetBT(buid:byte):boolean;
var _c:cardinal;
begin
   SetBT:=false;
   if(bt=0)then
    if(buid in pu^.uid^.ups_builder)then
    begin
       _c:=_uid_conditionals(pu^.player,buid);
       if(_c=0)or((_c=ureq_energy)and(skip_energy_check))then
       begin
          bt   :=buid;
          SetBT:=true;
       end;
    end;
end;
function SetBTA(b0,b1:byte;b0c:integer):boolean;
begin
   SetBTA:=false;
   if(bt=0)then
    if(b0=b1)or(b1=0)
    then SetBTA:=SetBT(b0)
    else
    begin
       with pu^.player^ do
        if(uid_e[b0]<b0c)
        then SetBTA:=SetBT(b0)
        else
          if(uid_e[b1]<=0)
          then SetBTA:=SetBT(b1)
          else
            if(uid_e[b1]<(uid_e[b0] div 2))then SetBTA:=SetBT(b1);
       if(not SetBTA)then SetBTA:=SetBT(b0);
       if(not SetBTA)then SetBTA:=SetBT(b1);
    end;
end;

procedure BuildMain(a:integer);   // Builders
begin
   with pu^.player^ do
    if(ai_builders_count<a)and(ai_builders_count<ai_maxcount_mains)then
     if(SetBTA(aiucl_main0[race],aiucl_main1[race],4))then ddir:=-1;
end;
procedure BuildEnergy(a:integer); // Energy
begin
   a+=base_energy;
   if(g_cgenerators=0)then
    with pu^.player^ do
     if(ai_enrg_pot<a)and(ai_enrg_pot<ai_maxcount_energy)and(ai_enrg_pot<ai_GeneratorsEnergy)then
      if(SetBTA(aiucl_generator[race],0,4))then ddir:=-1;
end;
procedure BuildUProd(a:integer);  // Barracks
begin
   with pu^ do
    with player^ do
     if(ai_unitp_cur<a)and(ai_unitp_cur<ai_maxcount_unitps)then
      if(ai_tech1_cur<=0)or(ai_unitp_cur_na=0)or(ai_unitp_cur<4)then
       if(SetBTA(aiucl_barrack0[race],aiucl_barrack1[race],3))then ddir:=-1;
end;
procedure BuildSmith(a:integer);  // Smiths
begin
   with pu^.player^ do
    if(ai_upgrp_cur<a)and(ai_upgrp_cur<ai_maxcount_upgrps)then
     if(ai_tech1_cur<=0)or(ai_upgrp_cur_na=0)or(ai_upgrp_cur<2)then
      if(SetBTA(aiucl_smith[race],0,4))then ddir:=-1;
end;
procedure BuildTech(a:integer);   // Tech
function BT(cur,max:pinteger):boolean;
begin BT:=(cur^<a)and(cur^<max^);end;
begin
   with pu^.player^ do
   case random(3) of
   0: if(BT(@ai_tech0_cur,@ai_maxcount_tech0))then if(SetBTA(aiucl_tech0[race],0,4))then ddir:=-1;
   1: if(BT(@ai_tech1_cur,@ai_maxcount_tech1))then if(SetBTA(aiucl_tech1[race],0,4))then ddir:=-1;
   2: if(BT(@ai_tech2_cur,@ai_maxcount_tech2))then if(SetBTA(aiucl_tech2[race],0,4))then ddir:=-1;
   end;
end;
procedure BuildDetect(da:integer);  // Radar,  Heye Nest
begin
   with pu^ do
    with player^ do
    if(ai_detect_cur<da)and(ai_detect_cur<ai_maxlimit_detect)then
    begin
       if(race=r_hell)and(ai_detect_near>1)then exit;
       if(SetBTA(aiucl_detect[race],0,4))then
       begin
          ddir:=-1;
          if(aiu_alarm_d<NOTSET)then
           case race of
           r_hell: ddir:=point_dir(x,y,ai_alarm_x,ai_alarm_y)+_randomr(45);
           r_uac : ddir:=point_dir(ai_alarm_x,ai_alarm_y,x,y)+_randomr(45);
           end;
          l:=srange-_uids[aiucl_detect[race]]._r;
       end;
    end;
end;
procedure BuildSpec1(a:integer);  // RStation, Altar
begin
   with pu^.player^ do
    if(ai_spec1_cur<a)and(ai_spec1_cur<ai_maxcount_spec1)then
     if(SetBTA(aiucl_spec1[race],0,4))then ddir:=-1;
end;
procedure BuildSpec2(a:integer);  // Teleport
begin
   with pu^.player^ do
    if(ai_spec2_cur<a)and(ai_spec2_cur<ai_maxcount_spec2)then
     if(SetBTA(aiucl_spec2[race],0,4))then ddir:=-1;
end;
function BuildTower(a,tower_kind:integer):boolean;  // Towers
begin
   BuildTower:=false;
   with pu^.player^ do
     if(ai_towers_cur<a)and(ai_towers_cur<ai_maxcount_towers)then
      if(tower_kind>0)
      then BuildTower:=SetBTA(aiucl_twr_air1[race],aiucl_twr_air2[race],2)
      else
       if(tower_kind<0)
       then BuildTower:=SetBTA(aiucl_twr_ground1[race],aiucl_twr_ground2[race],2)
       else
       begin
          if(ai_towers_near_air<ai_towers_near_grd)
          then BuildTower:=SetBTA(aiucl_twr_air1   [race],aiucl_twr_air2   [race],2)
          else BuildTower:=SetBTA(aiucl_twr_ground1[race],aiucl_twr_ground2[race],2);
          if(not BuildTower)then BuildTower:=SetBTA(aiucl_twr_ground1[race],aiucl_twr_air1[race],2);
          if(not BuildTower)then BuildTower:=SetBTA(aiucl_twr_ground2[race],aiucl_twr_air2[race],2);
       end;

   if(BuildTower)then
    with pu^ do
    begin
       if(ai_towers_needx<0)then
         if(aiu_alarm_d<NOTSET)then
         begin
            ai_towers_needx:=ai_alarm_x;
            ai_towers_needy:=ai_alarm_y;
         end;
       if(ai_towers_needx>-1)
       then ddir:=point_dir(x,y,ai_towers_needx,ai_towers_needy)+_randomr(45)
       else ddir:=-1;
    end;
end;
begin
   bt  := 0;
   l   :=-1;
   ddir:=-1;
   skip_energy_check:=true;
   base_energy:=0;

   with pu^     do
   with uid^    do
   with player^ do
   if(build_cd<=0)then
   begin
      ai_need_energy:=mm3(600,(ai_unitp_cur+ai_upgrp_cur+upgr[_upgr_srange])*500+(ai_builders_count*600) ,ai_GeneratorsEnergy);

      if((ai_flags and aif_base_smart_order)>0)then
      begin
         skip_energy_check:=false;
         BuildTower (ai_towers_need,ai_towers_need_type);
         BuildUProd (ai_unitp_need);
         BuildSmith (ai_upgrp_need);
         BuildDetect(ai_detect_need);
         if(ai_builders_count>1)then
         BuildTech  (1);
         BuildSpec1 (ai_maxcount_spec1 );
         BuildSpec2 (ai_maxcount_spec2 );
         BuildMain  (ai_builders_need);
         skip_energy_check:=true;
         BuildEnergy(ai_need_energy);
      end
      else
        case random(9) of
        0:BuildEnergy(ai_need_energy);
        1:BuildSmith (ai_upgrp_need);
        2:BuildTech  (1);
        3:BuildDetect(ai_detect_need);
        4:BuildSpec1 (ai_maxcount_spec1 );
        5:BuildSpec2 (ai_maxcount_spec2 );
        6:BuildUProd (ai_unitp_need);
        7:BuildMain  (ai_builders_need);
        8:BuildTower (ai_towers_need,ai_towers_need_type);
        end;

      {if(sel)then
      begin
         writeln(ai_need_energy,' ',ai_maxcount_energy,' ',ai_detect_need,' ',bt);
         writeln(ai_unitp_need,' ',ai_upgrp_need);
      end; }

      if(bt=0)then exit;

      if(ddir<=0)then
      begin
         ddir:=random(360);
         if(g_mode=gm_royale)then
           if(u_royal_d<(g_royal_r div 6))
           or(bt=aiucl_main0 [race])
           or(bt=aiucl_main0A[race])
           or(bt=aiucl_main1 [race])
           or(bt=aiucl_main1A[race])
           then ddir:=point_dir(x,y,map_hmw,map_hmw)-_randomr(100);
      end;
      rdir:=ddir*degtorad;
      if(l<0)
      then l:=_r+random(srange-_r);
      bx  :=x+trunc(l*cos(rdir));
      by  :=y-trunc(l*sin(rdir));

      _building_newplace(bx,by,bt,playeri,@bx,@by);

      _unit_start_build(bx,by,bt,playeri);
   end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//   UNIT PRODUCTION
//

const

uprod_smart  = -1;
uprod_any    = -2;
uprod_base   = -3;
uprod_air    = -4;
uprod_antiair= -5;


function ai_UnitProduction(pu:PTUnit;uclass,count:integer):boolean;
var ut,i:byte;
    up_m,
    up_n:integer;
smart   : boolean;
function CheckReq(_uid:byte):boolean;
var c:cardinal;
begin
   c:=_uid_conditionals(pu^.player,_uid);
   CheckReq:=(c=0)or(c=ureq_energy);
end;
function tryTransport:boolean;
begin
   tryTransport:=false;
   with pu^ do
    with player^ do
     if(unum=uid_x[uidi])then
      if(CheckReq(UID_UTransport)and(ai_transport_cur<ai_transport_need))then
       tryTransport:=ai_UnitProduction(pu,UID_UTransport,ai_max_specialist);
end;
function CheckAIRTarget:boolean;
begin
   CheckAIRTarget:=true;
   if(ai_alarm_d<NOTSET)and(ai_alarm_zone<>pu^.pfzone)then exit;
   if(ai_generator_d<NOTSET)then
    if(ai_generator_cp^.cpzone<>pu^.pfzone)then exit;
   CheckAIRTarget:=false;
end;

begin
   ai_UnitProduction:=false;
   ut:=0;

   with pu^     do
   with player^ do
   if((ai_armylimit_alive_u+uprodl)<ai_maxlimit_blimit)then
   begin
      smart:=(ai_flags and aif_army_smart_order)>0;
      if(not smart)and(uclass<0)then uclass:=uprod_any;

      case uclass of
uprod_smart: begin
                ai_UnitProduction:=true;
                if(ai_UnitProduction(pu,uprod_base,MaxUnits))then exit;

                if(not CheckAIRTarget)then
                begin
                   if(ai_UnitProduction(pu,uprod_any,MaxUnits))then exit;
                end
                else
                   case race of
                   r_uac : if(not tryTransport)then
                           begin
                              if(ai_UnitProduction(pu,uprod_air,MaxUnits))then exit;
                           end
                           else if(ai_UnitProduction(pu,uprod_antiair,MaxUnits))then exit;
                   r_hell: if(ai_UnitProduction(pu,uprod_air,MaxUnits))then exit;
                   end;

                ai_UnitProduction:=false;
                exit;
             end;

uprod_base : begin
                ai_UnitProduction:=true;
                for i:=1 to 3 do
                case pu^.player^.race of
             r_hell: begin
                        if(ai_UnitProduction(pu,UID_Imp           ,i))then exit;
                        if(ai_UnitProduction(pu,UID_Cacodemon     ,i))then exit;
                        if(ai_UnitProduction(pu,UID_Knight        ,i))then exit;
                        if(ai_UnitProduction(pu,UID_Baron         ,i))then exit;
                        if(ai_UnitProduction(pu,UID_ZSergant      ,i))then exit;
                        if(ai_UnitProduction(pu,UID_ZCommando     ,i))then exit;
                     end;
             r_uac : begin
                        if(tryTransport)then exit;
                        if(ai_UnitProduction(pu,UID_Antiaircrafter,i))then exit;
                        if(ai_UnitProduction(pu,UID_FPlasmagunner ,i))then exit;
                        if(ai_UnitProduction(pu,UID_Sergant       ,i))then exit;
                        if(ai_UnitProduction(pu,UID_Commando      ,i))then exit;
                        if(ai_UnitProduction(pu,UID_Medic         ,i))then exit;
                        if(ai_UnitProduction(pu,UID_SSergant      ,i))then exit;
                        if(ai_UnitProduction(pu,UID_Engineer      ,i))then exit;
                     end;
                end;
                ai_UnitProduction:=false;
                exit;
             end;
uprod_any  : case pu^.player^.race of
             r_hell: case random(22) of
                          0 : ut:=UID_LostSoul;
                          1 : ut:=UID_Imp;
                          2 : if(upgr[upgr_hell_spectre]>0)and(smart)then ut:=UID_Demon else ut:=UID_Imp;
                          3 : ut:=UID_Cacodemon;
                          4 : ut:=UID_Knight;
                          5 : ut:=UID_Baron;
                          6 : ut:=UID_Cyberdemon;
                          7 : ut:=UID_Mastermind;
                          8 : ut:=UID_Pain;
                          9 : ut:=UID_Revenant;
                          10: ut:=UID_Mancubus;
                          11: ut:=UID_Arachnotron;
                          12: ut:=UID_Archvile;
                          13: ut:=UID_ZFormer;
                          14: ut:=UID_ZEngineer;
                          15: ut:=UID_ZSergant;
                          16: ut:=UID_ZSSergant;
                          17: ut:=UID_ZCommando;
                          18: ut:=UID_ZAntiaircrafter;
                          19: ut:=UID_ZSiegeMarine;
                          20: ut:=UID_ZFPlasmagunner;
                          21: ut:=UID_ZBFGMarine;
                     end;
             r_uac : begin
                     if(tryTransport)then exit;
                     case random(15) of
                          0 : ut:=UID_Medic;
                          1 : ut:=UID_Engineer;
                          2 : ut:=UID_Sergant;
                          3 : ut:=UID_SSergant;
                          4 : ut:=UID_Commando;
                          5 : ut:=UID_Antiaircrafter;
                          6 : ut:=UID_SiegeMarine;
                          7 : ut:=UID_FPlasmagunner;
                          8 : ut:=UID_BFGMarine;
                          9 : ut:=UID_APC;
                          10: ut:=UID_UTransport;
                          11: ut:=UID_UACDron;
                          12: ut:=UID_Terminator;
                          13: ut:=UID_Tank;
                          14: ut:=UID_Flyer;
                     end;
                     end;
             end;
uprod_air  : case pu^.player^.race of
             r_hell: case random(4) of
                          0 : ut:=UID_LostSoul;
                          1 : ut:=UID_Cacodemon;
                          2 : ut:=UID_Pain;
                          3 : ut:=UID_ZFPlasmagunner;
                     end;
             r_uac : case random(3) of
                          0 : ut:=UID_FPlasmagunner;
                          1 : ut:=UID_Flyer;
                          2 : ut:=UID_UTransport;
                     end;
             end;
uprod_antiair
           : case pu^.player^.race of
             r_hell: case random(7) of
                          0 : ut:=UID_LostSoul;
                          1 : ut:=UID_Cacodemon;
                          2 : ut:=UID_Pain;
                          3 : ut:=UID_ZFPlasmagunner;
                          4 : ut:=UID_Revenant;
                          5 : ut:=UID_Imp;
                          6 : ut:=UID_ZAntiaircrafter;
                     end;
             r_uac : case random(3) of
                          0 : ut:=UID_FPlasmagunner;
                          1 : ut:=UID_Flyer;
                          2 : ut:=UID_Antiaircrafter;
                          3 : ut:=UID_Commando;
                     end;
             end;
1..255     : ut:=uclass;
      end;

      up_n:=uid_e[ut]+uprodu[ut];

      if(up_n>=count)then exit;

      case ut of
UID_Mastermind,
UID_Cyberdemon   : up_m:=ai_max_specialist-(uid_e[UID_Mastermind]+uprodu[UID_Mastermind]
                                           +uid_e[UID_Cyberdemon]+uprodu[UID_Cyberdemon]);
UID_APC,
UID_UTransport,
UID_Pain,
UID_Medic,
UID_Engineer     : up_m:=ai_max_specialist;
      else         up_m:=MaxUnits;
      end;

      if(up_n<up_m)then ai_UnitProduction:=_unit_straining(pu,ut);
   end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//   UPGRADE PRODUCTION
//

procedure ai_UpgrProduction(pu:PTUnit);
procedure MakeUpgr(upid,lvl:byte);
var uip:integer;
begin
   if(upid>0)then
    with pu^     do
     with player^ do
     begin
        uip:=upgr[upid]+upprodu[upid];
        if(uip<lvl)and(uip<ai_maxcount_upgrlvl)then _unit_supgrade(pu,upid);
     end;
end;
begin
   with pu^     do
    with player^ do
     if(ai_maxcount_upgrlvl>0)then
      case race of
r_hell: begin
        if((ai_flags and aif_upgr_smart_opening)>0)then
        begin
        MakeUpgr(upgr_hell_buildr    ,2);
        MakeUpgr(upgr_hell_HKTeleport,1);
        MakeUpgr(upgr_hell_extbuild  ,1);
        MakeUpgr(upgr_hell_spectre   ,1);
        MakeUpgr(upgr_hell_pinkspd   ,1);
        MakeUpgr(upgr_hell_pains     ,3);
        MakeUpgr(upgr_hell_heye      ,1);
        MakeUpgr(upgr_hell_vision    ,1);
        end;

        MakeUpgr(random(30)   ,ai_maxcount_upgrlvl);
        end;
r_uac : begin
        if((ai_flags and aif_upgr_smart_opening)>0)then
        begin
        MakeUpgr(upgr_uac_buildr     ,2);
        MakeUpgr(upgr_uac_CCFly      ,1);
        MakeUpgr(upgr_uac_extbuild   ,1);
        MakeUpgr(upgr_uac_commando   ,1);
        MakeUpgr(upgr_uac_soaring    ,1);
        MakeUpgr(upgr_uac_botturret  ,1);
        MakeUpgr(upgr_uac_lturret    ,1);
        MakeUpgr(upgr_uac_vision     ,1);
        end;

        MakeUpgr(30+random(30),ai_maxcount_upgrlvl);
        end;
      end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   BUILDINGS CODE
//

function ai_buildings_need_suicide(pu:PTUnit):boolean;
var   i:integer;
begin
   ai_buildings_need_suicide:=true;
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(cenergy<0)then
       if(upproda<=0)and(uproda<=0)and(not iscomplete)then exit;

      if((ai_inprogress_uid=0)and(    iscomplete))
      or((ai_inprogress_uid>0)and(not iscomplete))then
      case uidi of
UID_HSymbol,
UID_HASymbol,
UID_UGenerator,
UID_UAGenerator   : if(armylimit>ai_GeneratorsDestoryLimit)and(cenergy>_genergy)and(menergy>ai_GeneratorsDestroyEnergy)then exit; // ai_enrg_cur
      else
        if(_isbarrack)or(_issmith)then
         if(ai_isnoprod(pu))then
         begin
            i:=level+1;

            if(_isbarrack)and(ai_unitp_cur>2)then
             if(ai_unitp_cur_na<=0)or((level=0)and(ai_unitp_cur_na>0))then
              if((ai_unitp_cur-i-4)>=ai_unitp_need)then exit;
            if(_issmith  )and(ai_upgrp_cur>1)then
             if(ai_upgrp_cur_na<=0)or((level=0)and(ai_upgrp_cur_na>0))then
              if((ai_upgrp_cur-i-2)>=ai_upgrp_need)then exit;
         end;
      end;

      if(ai_PhantomWantZombieMe)and(iscomplete)and(hits<=(_zombie_hits+BaseDamage4))then exit;

      case uidi of
UID_HTower,
UID_HTotem,
UID_UGTurret,
UID_UATurret       : if(ai_towers_cur_active>ai_mincount_towers)and(ai_checkCPNear(50))then
                      if(aiu_alarm_d<base_1rh)or(aiu_alarm_timer=0)
                      then aiu_alarm_timer:=ai_TowerLifeTime
                      else
                        if(aiu_alarm_timer<0)
                        then exit;
      end;
   end;
   ai_buildings_need_suicide:=false;
end;

function ai_buildings_need_rebuild(pu:PTUnit):boolean;
begin
   ai_buildings_need_rebuild:=true;
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(base_1rh<ai_enemy_d)and(ai_enemy_d<base_3r)and(buff[ub_Damaged]<=0)and(a_rld<=0)then
       if(ai_towers_near>1)then
        case uidi of
UID_UGTurret   : if(ai_towers_near_air=0)then exit; // if(ai_towers_near_grd<ai_towers_near_air)then exit;
UID_UATurret   : if(ai_towers_near_grd=0)then exit; // if(ai_towers_near_grd<ai_towers_near_air)then exit;
        end;
      // if(    ai_enemy_u^.ukfly)and(srange<ai_enemy_grd_d)and(ai_enemy_grd_d<base_3r)then exit;

      case uidi of
UID_HKeep,
UID_HCommandCenter,
UID_UCommandCenter: if(n_builders>1)and(ai_enemy_d>base_2r)and(ai_enrg_cur>1200)then exit;
UID_HSymbol,
UID_UGenerator    : if(ai_enrg_cur<ai_maxcount_energy)then exit;
      else
         if(_isbarrack)or(_issmith)then
          if(level=0)and(ai_isnoprod(pu))then exit;
      end;
   end;
   ai_buildings_need_rebuild:=false;
end;

procedure ai_buildings(pu:PTUnit);
var prods:integer;
function _N(pn:pinteger;mx:integer):boolean;
begin
   _N:=false;
   if(mx<1)
   then pn^:=0
   else if(mx=1)
        then pn^:=1
        else _N:=true;
end;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      group:=0;

      ai_builders_count:=uid_e[aiucl_main0 [race]]
                        +uid_e[aiucl_main0A[race]]*2
                        +uid_e[aiucl_main1 [race]]
                        +uid_e[aiucl_main1A[race]]*2;
      ai_tech0_cur     :=uid_e[aiucl_tech0 [race]];
      ai_tech1_cur     :=uid_e[aiucl_tech1 [race]];
      ai_tech2_cur     :=uid_e[aiucl_tech2 [race]];
      ai_detect_cur    :=uid_e[aiucl_detect[race]]*_uids[aiucl_detect[race]]._limituse;
      ai_spec1_cur     :=uid_e[aiucl_spec1 [race]];
      ai_spec2_cur     :=uid_e[aiucl_spec2 [race]];

      //if(sel)then writeln(ai_transport_cur,' ',ai_transport_need);

      if(_N(@ai_builders_need,ai_maxcount_mains ))then ai_builders_need:=ai_builders_count+1;//ai_unitp_cur+1;

      prods:=400;
      if(race=r_uac)and(ai_builders_count>1)then prods-=100;
      if((ai_maxcount_tech0> 0)and((ai_tech0_cur=0)or(ai_tech1_cur=0)or(ai_tech2_cur=0)))
      or((ai_maxcount_mains>=8)and(ai_builders_count<8))
      then prods+=150;
      prods:=(menergy div prods);
      if(g_cgenerators>0)then prods+=2;

      if(_N(@ai_upgrp_need   ,ai_maxcount_upgrps))then ai_upgrp_need   :=mm3(1,prods div 4        ,ai_maxcount_upgrps);
      if(_N(@ai_unitp_need   ,ai_maxcount_unitps))then ai_unitp_need   :=mm3(1,prods-ai_upgrp_need,ai_maxcount_unitps);

      if(_N(@ai_detect_need  ,ai_maxlimit_detect))then ai_detect_need  :=mm3(0,ai_armylimit_alive_u div 8,ai_maxlimit_detect);
      if(ai_enemy_inv_u<>nil)then ai_detect_need:=ai_maxlimit_detect;

      if(_N(@ai_towers_need  ,ai_maxcount_towers))then
      begin
         ai_towers_need:=0;
         if(ai_enemy_d<base_4r)then
         begin
            ai_towers_need     :=mm3(ai_mincount_towers,(aiu_limitaround_enemy-aiu_limitaround_ally+MinUnitLimit) div MinUnitLimit,ai_maxcount_towers);
            ai_towers_needx    :=ai_enemy_u^.x;
            ai_towers_needy    :=ai_enemy_u^.y;
            ai_towers_need_type:=0;
            if(ai_limitaround_enemy_fly<=0)and(ai_limitaround_enemy_grd>0)
            then ai_towers_need_type:=-1
            else
              if(ai_limitaround_enemy_fly>0)and(ai_limitaround_enemy_grd<=0)
              then ai_towers_need_type:= 1;
         end
         else
         if(ai_cpoint_d<base_2r)and(ai_cpoint_koth)then
         begin
            ai_towers_need     :=ai_maxcount_towers;
            ai_towers_needx    :=ai_cpoint_cp^.cpx;
            ai_towers_needy    :=ai_cpoint_cp^.cpy;
            ai_towers_need_type:=0;
         end
         else
         if(ai_cpoint_d<srange)then
         begin
            ai_towers_need     :=3;
            ai_towers_needx    :=ai_cpoint_cp^.cpx;
            ai_towers_needy    :=ai_cpoint_cp^.cpy;
            ai_towers_need_type:=0;
         end;
      end;

      if((ai_flags and aif_base_suicide)>0)then
       if(ai_buildings_need_suicide(pu))then
       begin
          _unit_kill(pu,false,true,true,false);
          exit;
       end;

      if(ai_advanced_bld)then
       if(ai_buildings_need_rebuild(pu))then
        _unit_rebuild(pu);

      if(hits<=0)or(not iscomplete)then exit;

      if(n_builders>0)and(ai_nearest_builder_u<>nil)then ai_builder(ai_nearest_builder_u);

      // production
      if(_isbarrack)then
      begin
         if(cenergy<0)
         then _unit_ctraining(pu,255,false)
         else ai_UnitProduction(pu,uprod_smart,MaxUnits);

         if(aiu_alarm_d<NOTSET)and(speed<=0)then
         begin
            uo_x:=aiu_alarm_x;
            uo_y:=aiu_alarm_y;
         end;
      end;
      if(_issmith  )then
       if(cenergy<0)and(uproda<=0)
       then _unit_cupgrade(pu,255,false)
       else ai_UpgrProduction(pu);
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   UNITS CODE
//

procedure ai_RunTo(pu:PTUnit;odist,ox,oy,ow:integer;otar:PTUnit);
begin
   with pu^  do
   begin
      if(otar<>nil)then
      begin
         ox:=otar^.x;
         oy:=otar^.y;
      end;
      if(odist<0)then odist:=point_dist_int(x,y,ox,oy);
      if(ow=0)or(odist>base_1r)then
      begin
         uo_x:=ox;
         uo_y:=oy;
      end
      else
        if(ow<0)then
        begin
           if(ox=x)
           then uo_x:=ox+_randomr(-ow)
           else uo_x:=ox+(sign(ox-x)*_random(-ow));
           if(oy=y)
           then uo_x:=oy+_randomr(-ow)
           else uo_y:=oy+(sign(oy-y)*_random(-ow));
        end
        else
        begin
           uo_x:=ox-_randomr(ow);
           uo_y:=oy-_randomr(ow);
        end;
      uo_tar:=0;
   end;
end;
procedure ai_DefaultIdle(pu:PTUnit);
begin
   with pu^ do
   begin
      uo_x:=mm3(1,uo_x,map_mw);
      uo_y:=mm3(1,uo_y,map_mw);
      if(point_dist_rint(x,y,uo_x,uo_y)<srange)
      or(not ukfly and not ukfloater and (pfzone<>pf_get_area(uo_x,uo_y)))
      or(_CheckRoyalBattlePoint(uo_x,uo_y,base_1r))
      then ai_RunTo(pu,-1,random(map_mw),random(map_mw),0,nil);
   end;
end;
procedure ai_RunFrom(pu:PTUnit;ax,ay:integer);
begin
   with pu^  do
    if(x=ax)and(y=ay)then
    begin
       uo_x:=x-_random(2);
       uo_y:=y-_random(2);
    end
    else
      if(min2(x,abs(map_mw-x))<srange)
      or(min2(y,abs(map_mw-y))<srange)
      then ai_DefaultIdle(pu)
      else
      begin
         uo_x:=x-(ax-x)*10;
         uo_y:=y-(ay-y)*10;
      end;
end;
procedure ai_RunFromEnemy(pu:PTUnit;ud:integer);
begin
   if(ai_enemy_u<>nil)and(ai_enemy_d<ud)then ai_RunFrom(pu,ai_enemy_u^.x,ai_enemy_u^.y);
end;

procedure ai_BaseIdle(pu:PTUnit;idle_r:integer);
begin
   if(idle_r<ai_base_d)and(ai_base_d<NOTSET)
   then ai_RunTo(pu,ai_base_d,0,0,base_1r,ai_base_u)
   else ai_DefaultIdle(pu);
end;
function ai_TransportMicro(pu:PTUnit;smartmicro:boolean):boolean;
begin
   ai_TransportMicro:=true;
   if(ai_enemy_u<>nil)then
    with pu^  do
     with uid^ do
      if(_attack=atm_bunker)then
      begin
         if(smartmicro)then
           if(apcc=0)
           or(ai_enemy_d<150)then
           begin
              ai_RunFrom(pu,ai_enemy_u^.x,ai_enemy_u^.y);
              exit;
           end;
      end
      else
      begin
         if(ai_enemy_d<200)and(apcc>0)then uo_id:=ua_unload;

        // if(smartmicro)then
           if(apcc=0)then
           begin
              if(ai_enemy_d<srange)
              then ai_RunFrom(pu,ai_enemy_u^.x,ai_enemy_u^.y)
              else ai_BaseIdle(pu,srange);
              exit;
           end
           else
             if(pf_IfObstacleZone(ai_enemy_u^.pfzone))then
             begin
                ai_RunTo(pu,ai_enemy_d,0,0,base_1r,ai_enemy_u);
                exit;
             end;
      end;

   ai_TransportMicro:=false;
end;


{function ai_DistanceDiv(d1,d2:integer):integer;
begin
   if(d2<=0)then d2:=1;
   ai_DistanceDiv:=d1 div d2;
end;    }

function ai_TryTeleportF(pu,target:PTUnit):boolean;
var tt:integer;
begin
   ai_TryTeleportF:=false;
   if(ai_teleport_use)and(ai_teleporterF_u<>nil)then
     with ai_teleporterF_u^ do
     begin
        pu^.uo_x:=x;
        pu^.uo_y:=y;
        if(ai_teleporterF_d<uid^._r)then
          if(target<>nil)then
          begin
             tt:=uo_tar;
             uo_tar:=target^.unum;
             _ability_teleport(pu,ai_teleporterF_u,ai_teleporterF_d);
             uo_tar:=tt;
             ai_TryTeleportF:=true;
          end
          else
            if(_IsUnitRange(uo_tar,nil))then
            begin
               _ability_teleport(pu,ai_teleporterF_u,ai_teleporterF_d);
               ai_TryTeleportF:=true;
            end;
     end;
end;
function ai_TryTeleportR(pu:PTUnit):boolean;
begin
   ai_TryTeleportR:=false;
   if(ai_teleport_use)and(ai_teleporterR_u<>nil)then
    with ai_teleporterR_u^ do
     if(rld<=0)and(player^.upgr[upgr_hell_rteleport]>0)then
     begin
        _ability_teleport(pu,ai_teleporterR_u,ai_teleporterR_d);
        ai_TryTeleportR:=true;
     end;
end;

procedure ai_THINK(pu:PTUnit;smartmicro:boolean);
var d,
commander_d : integer;
commander_u : PTUnit;
function _IfAttackingWithHealWeapon:boolean;
begin
   _IfAttackingWithHealWeapon:=false;
   with pu^ do
    with uid^ do
     if(a_rld>0)and(a_weap_cl<=MaxUnitWeapons)then
      with _a_weap[a_weap_cl] do
       _IfAttackingWithHealWeapon:=(aw_type=wpt_heal)or(aw_type=wpt_resurect);
end;
procedure THINK_PickCommander(target_d:integer;target_zone:word);
begin
   with pu^  do
   with uid^ do
   with player^ do
   begin
      commander_d:=NOTSET;
      commander_u:=nil;
      if(ukfly)or(ukfloater)then
      begin
         commander_u:=ai_fly_commander_u;
         commander_d:=ai_fly_commander_d;
         if(ai_grd_commander_u<>nil)then
           if((target_d<NOTSET)and(ai_grd_commander_u^.pfzone=target_zone))
           or(target_d=NOTSET)then
           begin
              commander_u:=ai_grd_commander_u;
              commander_d:=ai_grd_commander_d;
           end
      end
      else
      begin
         commander_u:=ai_grd_commander_u;
         commander_d:=ai_grd_commander_d;
      end;
      if(commander_u=nil)
      then commander_u:=pu;

      if(pu<>commander_u)then ai_RunTo(pu,commander_d,0,0,-srange,commander_u);
   end;
end;
function THINK_RoyalBattleBorders:boolean;
begin
   THINK_RoyalBattleBorders:=false;
   with pu^  do
   if(u_royal_d<srange)then
   begin
      ai_RunTo(pu,0,map_hmw,map_hmw,0,nil);
      group:=aio_busy;

      if(u_royal_d<50)then
      begin
         a_tar:=0;
         uo_id:=ua_move;
      end;

      THINK_RoyalBattleBorders:=true;
   end;
   //if(pu^.sel)then writeln('THINK_RoyalBattleBorders ',THINK_RoyalBattleBorders);
end;
function THINK_Battle:boolean;
begin
   THINK_Battle:=false;
   with pu^  do
   with uid^ do
   with player^ do
   if(aiu_alarm_d<base_1rh)then
     if(aiu_alarm_d<=ai_cpoint_d)
     or(ai_cpoint_d<=ai_cpoint_r)then
     begin
        ai_RunTo(pu,aiu_alarm_d,aiu_alarm_x,aiu_alarm_y,-srange,nil);
        if(apcm>0)then ai_TransportMicro(pu,smartmicro);

        if(smartmicro)then
          case uidi of
UID_Pain       : begin
                 ai_RunFromEnemy(pu,base_1r);
                 if (base_1r<aiu_alarm_d)
                 and(aiu_alarm_d<base_1rh)then _unit_sability(pu);
                 end;
UID_ArchVile   : ai_RunFromEnemy(pu,base_1r);
UID_SiegeMarine,
UID_ZSiegeMarine,
UID_Tank,
UID_Mancubus,
UID_Cyberdemon : if(srange<ai_enemy_build_d)and(ai_enemy_build_d<base_1rh)then
                 begin
                    uo_id:=ua_move;
                    ai_RunTo(pu,0,0,0,0,ai_enemy_build_u);
                 end;
          end;

        THINK_Battle:=true;
     end;
   //if(pu^.sel)then writeln('THINK_Battle ',THINK_Battle);
end;
function THINK_Generator:boolean;
begin
   THINK_Generator:=false;
   with pu^ do
   with uid^ do
   with player^ do
     if (ai_generator_d<NOTSET)
     and(ai_generator_d<ai_alarm_d)
     and(ai_generator_d<ai_abase_d)
     and(ai_generator_d<ai_cpoint_d)then
       if(ai_builders_count>0)
       or(ai_unitp_cur>0)then
        with ai_generator_cp^ do
        begin
           if(menergy>7000)and(ai_generator_d>srange)then exit;

           if(apcc>0)and(_attack<>atm_bunker)and(ai_generator_d<=ai_generator_r)
           then uo_id:=ua_unload;

           if((apcm<=0)and((cpOwnerPlayer=0)or(ai_generator_d<base_2r)or(cycle_order=0)) )
           or((apcm<=0)and(ukfly or ukfloater)and(uid_e[uidi]>1)and(unum=uid_x[uidi]))
           or(menergy<900)
           or((apcc>0)and(ai_generator_d<base_2r))then
           begin
              ai_RunTo(pu,0,cpx,cpy,cpCaptureR div 2,nil);
              THINK_Generator:=true;
           end;
        end;
  // if(pu^.sel)then writeln('THINK_Generator ',THINK_Generator);
end;
function THINK_CPoint:boolean;
begin
   THINK_CPoint:=false;
   with pu^ do
   with uid^ do
    with player^ do
     if(ai_cpoint_d<NOTSET)then
      if(ai_cpoint_d<ai_abase_d)
      or(ai_cpoint_koth)
      or(ai_alarm_d=NOTSET)then
       with ai_cpoint_cp^ do
       begin
          if(apcc>0)and(_attack<>atm_bunker)and(ai_cpoint_d<=ai_cpoint_r)
          then uo_id:=ua_unload;

          THINK_PickCommander(ai_cpoint_d,cpzone);

          if((pu=commander_u)and((ai_cpoint_n=0)or(ai_cpoint_d<base_2r))and((ai_limitaround_own>=ul4)or ai_ReadyForAttack))
          or(apcc>0)
          or(ai_alarm_d=NOTSET)
          or((cpOwnerPlayer=0)and(not ai_cpoint_koth))
          or(ai_cpoint_d<base_1r)then
          begin
             ai_RunTo(pu,0,cpx,cpy,ai_cpoint_r div 2,nil);
             THINK_CPoint:=true;
          end
          else THINK_CPoint:=(pu<>commander_u);
       end;
   //if(pu^.sel)then writeln('THINK_CPoint ',THINK_CPoint,' ',pu=commander_u,' ',(ai_limitaround_own/ul1):3:3,' ',ai_ReadyForAttack);
end;
function THINK_BaseAlarm:boolean;
begin
   THINK_BaseAlarm:=false;
   with pu^  do
   with uid^ do
   with player^ do
   begin
      if(ai_teleporterR_u<>nil)then
        if(ai_teleporterR_u^.aiu_alarm_d<base_1rh)and(ai_teleporterR_u^.aiu_limitaround_ally<=ai_teleporterR_u^.aiu_limitaround_enemy)then
          if(ai_TryTeleportR(pu))then exit;

      if(ai_abase_d<ai_cpoint_d)then
       if((ai_abase_d<aiu_alarm_d)and(group=aio_attack))
       or((ai_abase_d<NOTSET     )and(group=aio_home  ))then
       begin
          THINK_BaseAlarm:=true;

          if(not ukfly)and(not ukfloater)then
            if(ai_teleporterF_d<base_2r)and(ai_abase_d>base_4r)then
            begin
               ai_TryTeleportF(pu,ai_abase_u);
               exit;
            end;
          ai_RunTo(pu,ai_abase_d,0,0,-base_1r,ai_abase_u);
       end;
   end;
   //if(pu^.sel)then writeln('THINK_BaseAlarm ',THINK_BaseAlarm);
end;
function THINK_Scout:boolean;
begin
   THINK_Scout:=false;
   with pu^  do
   with uid^ do
   with player^ do
   if(unum=ai_scout_u_cur)and(ai_armylimit_alive_u>ai_MinArmyForScout)and(g_mode<>gm_invasion)then
   begin
      if(group<>aio_scout)then
        if(aiu_attack_timer<0)
        then group:=aio_scout
        else
          if(aiu_attack_timer=0)then aiu_attack_timer:=max2(ai_MinScoutDelay,ai_attack_pause div 2);

      if(group<>aio_scout)
      then ai_BaseIdle(pu,ai_BaseIDLERange)
      else
        if(aiu_alarm_d<NOTSET)
        then ai_RunTo(pu,aiu_alarm_d,aiu_alarm_x,aiu_alarm_y,0,nil)
        else ai_DefaultIdle(pu);

      THINK_Scout:=true;
   end
   else
   begin
      if(group=aio_scout)then
      begin
         group:=aio_home;
         aiu_attack_timer:=0;
      end;
      if(ai_alarm_d=NOTSET)and(ai_ReadyForAttack)and(ai_radars=0)then
        if(uidi=UID_LostSoul     )
        or(uidi=UID_Phantom      )
        or(uidi=UID_FPlasmagunner)
        or(uidi=UID_Flyer        )then
        begin
           ai_DefaultIdle(pu);
           THINK_Scout:=true;
        end;
   end;
   //if(pu^.sel)then writeln('THINK_Scout ',THINK_Scout);
end;
function THINK_DefaultAttack:boolean;
begin
   THINK_DefaultAttack:=false;
   with pu^  do
   with uid^ do
   with player^ do
   begin
      THINK_PickCommander(aiu_alarm_d,ai_alarm_zone);

      if(group=aio_home)then
        if(ai_ReadyForAttack)then
        begin
           group:=aio_attack;
           if(pu=commander_u)then aiu_attack_timer:=ai_attack_pause;
        end
        else ai_BaseIdle(pu,ai_BaseIDLERange);

      if(pu<>commander_u)then
      begin
         if(aiu_attack_timer<>0)and(aiu_attack_timer<commander_u^.aiu_attack_timer)
         then commander_u^.aiu_attack_timer:=aiu_attack_timer;
         aiu_attack_timer:=0;
      end
      else
        if(group=aio_attack)then
          if(aiu_attack_timer<>0)
          or((playeri>0)and(g_mode=gm_invasion))
          then ai_BaseIdle(pu,ai_BaseIDLERange)
          else
            if(aiu_alarm_d<NOTSET)
            then ai_RunTo(pu,aiu_alarm_d,aiu_alarm_x,aiu_alarm_y,0,nil)
            else ai_DefaultIdle(pu);

      if(not ukfly)and(not ukfloater)and(group=aio_attack)and(aiu_alarm_d<NOTSET)and(ai_teleporterF_d<NOTSET)then
        if(pfzone<>ai_alarm_zone)
        or((ai_teleporterF_d<base_2r)and(aiu_alarm_d>base_4r)and(ai_limitaround_own<=(ai_limitaround_teleports+ai_limitaround_teleports) ))then
        begin
           ai_TryTeleportF(pu,nil);
          // if(sel)then writeln(ai_teleporterF_d,' ',aiu_alarm_d,' ',ai_limitaround_own,' ',ai_limitaround_teleports);
        end;

      THINK_DefaultAttack:=true;
   end;
  // if(pu^.sel)then writeln('THINK_DefaultAttack ',THINK_DefaultAttack,' ',(pu<>commander_u));
end;
function THINK_Repair:boolean;
begin
   THINK_Repair:=false;
   if(smartmicro)then
   with pu^  do
   with uid^ do
   with player^ do
    if(_IfAttackingWithHealWeapon)then
    begin
       group:=aio_busy;
       THINK_Repair:=true;
    end
    else
      case uidi of
UID_Engineer : if(ai_mrepair_d<base_2r)and(ai_mrepair_d<ai_cpoint_d)then
            begin
               ai_RunTo(pu,ai_mrepair_d,0,0,0,ai_mrepair_u);
               group:=aio_busy;
               if(ai_mrepair_u^.playeri=playeri)
               then ai_mrepair_u^.group:=aio_busy;

               THINK_Repair:=true;
            end;
UID_Medic    : if(ai_urepair_d<base_2r)and(ai_urepair_d<ai_cpoint_d)then
            begin
               ai_RunTo(pu,ai_urepair_d,0,0,0,ai_urepair_u);
               group:=aio_busy;
               if(ai_urepair_u^.playeri=playeri)
               then ai_urepair_u^.group:=aio_busy;

               THINK_Repair:=true;
            end;
      end;
   //if(pu^.sel)then writeln('THINK_Repair ',THINK_Repair);
end;
function THINK_Transport:boolean;
begin
   THINK_Transport:=false;
   with pu^  do
   with uid^ do
   with player^ do
   if(group<>aio_busy)and(ai_inapc_d<NOTSET)then
     if(ai_cpoint_d>ai_cpoint_r)then
       if(apcc<=0)
       or((apcc>0)and(ai_inapc_d<ai_abase_d))then
         if(ai_inapc_d<base_1rh)
         or( ukfly and ((apcc<=0)or(group<>aio_attack)) )then
         begin
            group:=aio_busy;
            ai_RunTo(pu,ai_inapc_d,0,0,0,ai_inapc_u);
            d:=ai_inapc_d-(_r+ai_inapc_u^.uid^._r-aw_dmelee);
            if(d<=0)
            then uo_tar:=ai_inapc_u^.unum;

            THINK_Transport:=true;
         end;
   //if(pu^.sel)then writeln('THINK_Transport ',THINK_Transport);
end;
begin
   with pu^  do
   with uid^ do
   with player^ do
   begin
      uo_tar:=0;

      if(group=aio_busy)then group:=aio_home;

      if(playeri=0)and(g_mode=gm_invasion)
      then THINK_DefaultAttack
      else
      begin
         if(apcm<=0)then
           if(ai_builders_count>0)
           or(ai_unitp_cur>0)then
             if(ai_cpoint_d<ai_cpoint_r)
             or(ai_generator_d<ai_generator_r)
             then group:=aio_busy;

         if(not THINK_RoyalBattleBorders)then
          if(not THINK_Generator        )then
           if(not THINK_Repair          )then
            if(not THINK_Battle         )then
             if(not THINK_Transport     )then
              if(not THINK_BaseAlarm    )then
               if(not THINK_Scout       )then
                if(ai_ZombieTarget_d<base_2r)and(uidi=UID_Phantom)then
                begin
                   group:=aio_busy;
                   ai_RunTo(pu,ai_ZombieTarget_d,0,0,0,ai_ZombieTarget_u);
                end
                else
                  if(not THINK_CPoint)
                  then THINK_DefaultAttack;
      end;
      //if(sel)then writeln(ai_cpoint_d);
   end;
end;

procedure ai_SaveMain_CC(pu:PTUnit);
begin
   with pu^ do
   begin
      if(ukfly)then
      begin
         if(u_royal_d<base_2r)
         then ai_RunTo(pu,0,map_hmw,map_hmw,0,nil)
         else
           if(ai_choosen)and(g_mode=gm_royale)then
           begin
              ai_RunTo(pu,u_royal_cd,map_hmw,map_hmw,base_1r,nil);
              if(u_royal_cd<min2(g_royal_r div 7,base_2r))
              then _unit_sability(pu);
           end
           else
             if(ai_choosen)and(ai_cpoint_koth)then
             begin
                ai_RunTo(pu,ai_cpoint_d,ai_cpoint_cp^.cpx,ai_cpoint_cp^.cpy,base_1r,nil);
                if(ai_cpoint_d<ai_cpoint_r)
                then _unit_sability(pu);
             end
             else
               if(ai_enemy_d<=base_3r)
               then ai_RunFrom(pu,ai_enemy_u^.x,ai_enemy_u^.y)
               else
               begin
                  ai_BaseIdle(pu,base_hr+uid^._r);
                  with player^ do
                  with uid^ do
                    if(ai_base_d>0)then
                      if(ai_base_d<base_1r)
                      or(ai_base_d=NOTSET)
                      or(g_mode=gm_royale)
                      then
                        if(aiu_FiledSquareNear<=ai_FiledSquareBorder)
                        or(ai_builders_count>=3)
                        or(g_mode=gm_royale)then
                          if(not pf_IfObstacleZone(pfzone))
                          or(ai_extbuilding)
                          then _unit_sability(pu);
               end;
      end
      else
        if(u_royal_d<base_1r)
        or((ai_choosen)and(g_mode=gm_royale))
        or((ai_choosen)and(ai_cpoint_koth)and(ai_cpoint_d>=base_1r))
        or((aiu_FiledSquareNear>ai_FiledSquareBorder)and(ai_builders_count<3))
        then _unit_sability(pu)
        else
         if(not ai_cpoint_koth)or(ai_cpoint_d>base_1r)then
          if(aiu_limitaround_enemy>aiu_limitaround_ally)and(buff[ub_Damaged]>0)then
           if(hits<uid^._hmhits)or(aiu_limitaround_enemy>ul15)then _unit_sability(pu);
   end;
end;
procedure ai_SaveMain_HK(pu:PTUnit);
var w:integer;
    d:single;
begin
   with pu^ do
   begin
      if(not ai_cpoint_koth)
      or(ai_cpoint_d>base_1r)then
        if(aiu_alarm_d<base_2r)and(ai_builders_count<=ai_MinBaseSaveCountBorder)and(hits<uid^._hmhits)then
        begin
           if(g_mode=gm_royale)
           then w:=g_royal_r div 2
           else w:=map_hmw;
           if(_unit_ability_HKeepBlink(pu,map_hmw+_random(w),map_hmw+_random(w)))then exit;
        end;

      case g_mode of
gm_koth  : if(ai_choosen)and(base_1r<ai_cpoint_d)and(ai_cpoint_d<NOTSET)and(ai_cpoint_koth)then
           begin
              w:=base_1r;
              _unit_ability_HKeepBlink(pu,ai_cpoint_cp^.cpx+_random(w),ai_cpoint_cp^.cpx+_random(w));
              exit;
           end;
gm_royale: if(ai_choosen)
           or(u_royal_d<base_2r)then
           begin
              w:=min2(g_royal_r div 4,base_2r);
              _unit_ability_HKeepBlink(pu,map_hmw+_random(w),map_hmw+_random(w));
              exit;
           end;
      end;

      if(aiu_FiledSquareNear>ai_FiledSquareBorder)and(ai_builders_count<3)then
      begin
         if(aiu_alarm_d<base_4r)
         then w:=point_dir(aiu_alarm_x,aiu_alarm_y,x,y)
         else w:=random(360);
         d:=w*degtorad;
         _unit_ability_HKeepBlink(pu,
         x+trunc(srange*cos(d)),
         y-trunc(srange*sin(d)));
      end;
   end;
end;

function ai_uab_buildturret(pu:PTUnit):boolean;
begin
   ai_uab_buildturret:=true;
   with pu^  do
   with uid^ do
   with player^ do
   if(u_royal_d>base_1r)then
   begin
      if(unum=ai_scout_u_cur)and(ai_enemy_build_u<>nil)then
       if(ai_enemy_build_d<srange)and(ai_enemy_build_u^.speed=0)and(buff[ub_Damaged]<=0)then exit;

      if(ai_checkCPNear(25))then exit;
   end;
   ai_uab_buildturret:=false;
end;
procedure ai_uab_HTowerBlink(pu:PTUnit);
var bx,by,bd:integer;
    bz:word;
procedure SetBlinkTarget(x,y,d:integer;zone:word);
begin
   if(d<bd)then
   begin
      bd:=d;
      bx:=x;
      by:=y;
      bz:=zone;
   end;
end;
begin
   with pu^  do
   with uid^ do
   with player^ do
   begin
      if(a_rld>0)then exit;

      bd:=NOTSET;

      if(ai_cpoint_d<NOTSET)then
       if(ai_cpoint_cp^.cpnobuildR<ai_cpoint_r)then
        if(ai_cpoint_d<=ai_cpoint_cp^.cpCapturer)
        then exit
        else
          with ai_cpoint_cp^ do SetBlinkTarget(cpx,cpy,ai_cpoint_d,cpzone);

      if(ai_generator_d<NOTSET)then
       if(ai_generator_cp^.cpnobuildR<ai_generator_r)then
        if(ai_generator_d<=ai_generator_r)
        then exit
        else
          with ai_generator_cp^ do SetBlinkTarget(cpx,cpy,ai_generator_d,cpzone);

      if(srange<ai_alarm_d)and(ai_alarm_d<NOTSET)then
       SetBlinkTarget(ai_alarm_x,ai_alarm_y,ai_alarm_d,ai_alarm_zone);

      if(g_mode=gm_royale)then SetBlinkTarget(map_hmw,map_hmw,0,pf_get_area(map_hmw,map_hmw));

      if(bd=NOTSET)then exit;

      if(upgr[upgr_race_extbuilding[race]]=0)then
       if(bz<>pfzone)then exit;

      _unit_ability_HTowerBlink(pu,bx,by);
   end;
end;

procedure aiu_code(pu:PTUnit);
begin
   with pu^  do
   if(ai_alarm_d<NOTSET)then
   begin
      aiu_alarm_d:=ai_alarm_d;
      aiu_alarm_x:=ai_alarm_x;
      aiu_alarm_y:=ai_alarm_y;
   end;
end;

procedure ai_code(pu:PTUnit);
var alarmr:integer;
procedure ai_unit_timer(y:pinteger);
begin
   if(y^>0)then
   begin
      y^-=order_period;
      if(y^=0)then y^:=-1;
   end
   else
    if(y^<0)then y^:=0;
end;
begin
   with pu^  do
   with uid^ do
   begin
      ai_unit_timer(@aiu_alarm_timer );
      ai_unit_timer(@aiu_attack_timer);

      uo_id :=ua_amove;
      uo_tar:=0;

      with player^ do
        ai_ReadyForAttack :=(ai_limitaround_own>ai_attack_limit)
                          or(armylimit>=ai_attack_limit)
                          or(armylimit>=ai_limit_border)
                          or(ai_armylimit_alive_u>=ai_maxlimit_blimit)
                          or(ai_armylimit_alive_b<=0);

      if(_ukbuilding)then ai_buildings(pu);

      if(hits<=0)then exit;

      // correct Player's alarm
      alarmr:=max2(200,srange);
      if(ai_enemy_d>srange)then ai_PlayerSetAlarm(player,x,y,0,alarmr,false,0);
      if(ai_enemy_d<NOTSET)then
        if(ai_enemy_d<=srange)
        then ai_PlayerSetAlarm(player,ai_enemy_u^.x,ai_enemy_u^.y,aiu_limitaround_enemy     ,alarmr,ai_enemy_u^.uid^._ukbuilding,ai_enemy_u^.pfzone)
        else ai_PlayerSetAlarm(player,ai_enemy_u^.x,ai_enemy_u^.y,ai_enemy_u^.uid^._limituse,alarmr,ai_enemy_u^.uid^._ukbuilding,ai_enemy_u^.pfzone);

      if(not iscomplete)then exit;

      // abilities
      case _ability of
uab_Teleport         : if(ai_teleporter_beacon_u<>nil)
                       then uo_tar:=ai_teleporter_beacon_u^.unum
                       else uo_tar:=0;
      end;
      if((player^.ai_flags and aif_ability_other)>0)then
      begin
         case _ability of
uab_HTowerBlink      : ai_uab_HTowerBlink(pu);
uab_HInvulnerability : if(ai_invuln_tar_u<>nil  )then _unit_ability_HInvuln    (pu,ai_invuln_tar_u^.unum);
uab_UACStrike        : if(ai_strike_tar_u<>nil  )then _unit_ability_UACStrike  (pu,ai_strike_tar_u^.x,ai_strike_tar_u^.y);
uab_SpawnLost        : if(ai_ZombieTarget_d<base_1r)and(player^.upgr[upgr_hell_phantoms]>0)then
                         if(u_royal_d>srange)or(g_royal_r<srange)then _unit_sability(pu);
         end;
         case uidi of
UID_UACDron           : if(ai_uab_buildturret(pu))then
                          if(_unit_rebuild(pu))then exit;
         end;
      end;

      // MAIN move
      if((player^.ai_flags and aif_ability_mainsave)>0)then
       case _ability of
uab_CCFly       : ai_SaveMain_CC(pu);
uab_HKeepBlink  : ai_SaveMain_HK(pu);
       end;

      // active detection
      with player^ do
       if(ai_detection_pause=0)then
        if((ai_flags and aif_ability_detection)>0)then
         case _ability of
uab_UACScan          : begin
                          if(ai_enemy_inv_u<>nil)then
                            if(_unit_ability_uradar(pu,ai_enemy_inv_u^.x,ai_enemy_inv_u^.y))then
                            begin
                               player^.ai_detection_pause     :=fr_fps1;
                               ai_enemy_inv_u^.buff[ub_Scaned]:=fr_fps1;
                            end;
                          if(ai_alarm_d=NOTSET)then
                           if(ai_choosen)or(ai_ReadyForAttack)then
                            if(_unit_ability_uradar(pu,random(map_mw),random(map_mw)))then player^.ai_detection_pause:=fr_fps1;
                       end;
uab_HellVision       : if(ai_need_heye_u<>nil)then
                         if(_unit_ability_HellVision(pu,ai_need_heye_u^.unum))then ai_detection_pause:=fr_fps1;
        end;

      if(speed<=0)or(_ukbuilding)then exit;

      ai_THINK(pu,(player^.ai_flags and aif_army_smart_micro)>0);
   end;
end;

//if(sel)then writeln('2 ',aiu_alarm_d);

{ if(playeri=HPlayer)and(sel)then
begin
   //if(aiu_alarm_x      >-1)then UnitsInfoAddLine(x,y,aiu_alarm_x,aiu_alarm_y,c_red);
   //if(ai_alarm_invis_x>-1)then UnitsInfoAddLine(x,y,ai_alarm_invis_x+1,ai_alarm_invis_y+1,c_aqua);

   //if(ai_uadv_u<>nil)then UnitsInfoAddLine(x,y,ai_uadv_u^.x,ai_uadv_u^.y,c_red);

   if(ai_teleporter_d<NOTSET)and(ai_teleporter_u<>nil)then UnitsInfoAddLine(x,y,ai_teleporter_u^.x,ai_teleporter_u^.y,c_lime);
end; }

{ if(sel)then
begin
   writeln(ai_cp_go_r,' ',ai_cpoint_d);
   UnitsInfoAddLine(x,y,ai_cpoint_x,ai_cpoint_y,c_aqua);
end;  }


