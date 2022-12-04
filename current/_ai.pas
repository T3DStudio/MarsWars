
const

aiucl_main0      : array[1..r_cnt] of byte = (UID_HKeep          ,UID_UCommandCenter);
aiucl_main1      : array[1..r_cnt] of byte = (UID_HCommandCenter ,0                 );
aiucl_generator  : array[1..r_cnt] of byte = (UID_HSymbol        ,UID_UGenerator    );
aiucl_barrack0   : array[1..r_cnt] of byte = (UID_HGate          ,UID_UBarracks     );
aiucl_barrack1   : array[1..r_cnt] of byte = (UID_HBarracks      ,UID_UFactory      );
aiucl_smith      : array[1..r_cnt] of byte = (UID_HPools         ,UID_UWeaponFactory);
aiucl_tech0      : array[1..r_cnt] of byte = (UID_HMonastery     ,UID_UTechCenter   );
aiucl_tech1      : array[1..r_cnt] of byte = (UID_HFortress      ,UID_UNuclearPlant );
aiucl_detect     : array[1..r_cnt] of byte = (UID_HEye           ,UID_URadar        );
aiucl_spec1      : array[1..r_cnt] of byte = (UID_HAltar         ,UID_URMStation    );
aiucl_spec2      : array[1..r_cnt] of byte = (UID_HTeleport      ,0                 );
aiucl_twr_air1   : array[1..r_cnt] of byte = (UID_HTower         ,UID_UATurret      );
aiucl_twr_air2   : array[1..r_cnt] of byte = (UID_HTotem         ,UID_UATurret      );
aiucl_twr_ground1: array[1..r_cnt] of byte = (UID_HTower         ,UID_UGTurret      );
aiucl_twr_ground2: array[1..r_cnt] of byte = (UID_HTotem         ,UID_UGTurret      );

ai_generators_energy    = 3000;
ai_tower_life_time      = fr_fps*60;
ai_MinArmyForScout      = MinUnitLimit*3;
ai_gendestroy_armylimit = MinUnitLimit*80;
ai_cp_go_r              = base_3r;
ai_BaseIDLERange        = 100;
ai_base_save_border     = 6;
ai_choosen_border       = 6;
ai_min_scout_pause      = fr_fps*30;

aio_home   = 0;
aio_scout  = 1;
aio_busy   = 2;
aio_attack = 3;

notset     = 32000;

var

ai_cpoint_zone,
ai_alarm_zone    : word;
ai_alarm_unit,

ai_need_heye_u,
ai_grd_commander_u,
ai_fly_commander_u,
ai_inapc_u,
ai_abase_u,
ai_invuln_tar_u,
ai_strike_tar_u,
ai_teleporter_u,
ai_teleporter_beacon_u,
ai_enemy_u,
ai_enemy_air_u,
ai_enemy_grd_u,
ai_enemy_inv_u,
ai_mrepair_u,
ai_urepair_u,
ai_base_u         : PTUnit;

ai_LostWantZombieMe,
ai_choosen,
ai_cpoint_koth    : boolean;
ai_cpoint_x,
ai_cpoint_y,
ai_cpoint_d,
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
ai_mrepair_d,
ai_urepair_d,
ai_teleporter_d,
ai_armyaround_own,
ai_armyaround_enemy_fly,
ai_armyaround_enemy_grd,
ai_teleports_near,

ai_enrg_pot,
ai_enrg_cur,
ai_basep_builders,
ai_basep_need,
ai_unitp_cur,
ai_unitp_cur_na,
ai_unitp_need,
ai_upgrp_cur,
ai_upgrp_cur_na,
ai_upgrp_need,
ai_tech0_cur,
ai_tech1_cur,
ai_detect_cur,
ai_detect_need,
ai_spec1_cur,
ai_spec2_cur,
ai_towers_cur,
ai_towers_cur_active,
ai_towers_near,
ai_towers_near_air,
ai_towers_near_ground,
ai_towers_need,
ai_towers_need_type,
ai_towers_needx,
ai_towers_needy,
ai_inprogress_uid,
ai_army_air,
ai_army_ground
                 : integer;

procedure ai_set_alarm(pplayer:PTPlayer;ax,ay,ae,sr:integer;abase:boolean;pfzone:word);
var a,
nobasea,
freea:byte;
begin
   freea  :=255;
   nobasea:=255;
   ax:=mm3(1,ax,map_mw);
   ay:=mm3(1,ay,map_mw);
   with pplayer^ do
    for a:=0 to MaxPlayers do
     with ai_alarms[a] do
     if(ae<=0)then
     begin
        if(aia_enemy_count>0)then
         if(point_dist_rint(ax,ay,aia_x,aia_y)<sr)then aia_enemy_count:=0
     end
     else
       if(aia_enemy_count<=0)
       then freea:=a
       else
       begin
          if(not aia_enemy_base)then nobasea:=a;
          if(point_dist_rint(ax,ay,aia_x,aia_y)<sr)then exit;
       end;

   if(ae>0)then
   begin
      a:=255;
      if(freea<255)
      then a:=freea
      else
        if(nobasea<255)
        then a:=nobasea
        else exit;

      with pplayer^.ai_alarms[a] do
      begin
         aia_x:=ax;
         aia_y:=ay;
         aia_enemy_count:=ae;
         aia_enemy_base :=abase;
         aia_zone:=pfzone;
      end;
   end;
end;

procedure ai_make_scirmish_start_alarms(p:byte);
var i:byte;
begin
   for i:=1 to MaxPlayers do
    if(i<>p)then
     if(g_fixed_positions)then
     begin
        if(_players[i].state>ps_none)then
         if(_players[i].team<>_players[p].team)then
          ai_set_alarm(@_players[p],map_psx[i],map_psy[i],1,base_r,true,pf_get_area(map_psx[i],map_psy[i]));
     end;
     //else ai_set_alarm(@_players[p],map_psx[i],map_psy[i],1,base_r,true,pf_get_area(map_psx[i],map_psy[i]));
end;

procedure  PlayerSetSkirmishAIParams(p:byte);
procedure SetBaseOpt(me,m,unp,upp,t0,t1,dl,s1,s2,mint,maxt,atl,att,l:integer;mupl:byte;hpt:TSoB);
begin
   with _players[p] do
   begin
      ai_max_energy  :=me;
      ai_max_mains   :=m;
      ai_max_unitps  :=unp;
      ai_max_upgrps  :=upp;
      ai_max_tech0   :=t0;
      ai_max_tech1   :=t1;
      ai_max_detect  :=dl;
      ai_max_spec1   :=s1;
      ai_max_spec2   :=s2;
      ai_min_towers  :=mint;
      ai_max_towers  :=maxt;
      ai_attack_limit:=atl*MinUnitLimit;
      ai_attack_pause:=att;
      ai_max_blimit  :=l*MinUnitLimit;
      ai_max_upgrlvl :=mupl;
      ai_hptargets   :=hpt;
   end;
end;
begin
   with _players[p] do
   begin
      case ai_skill of
      //              energ buil uprod  pprod tech1 tech2 radar rsta    telepo  min    max    attack attack     max           upgr first
      //                    ders                          heye  altr            towers towers limit  delay      army          lvl  targets
      0  : ; // nothing
      1  : SetBaseOpt(300  ,1   ,1     ,0    ,0    ,0    ,0    ,0      ,0       ,1    ,1     ,10    ,fr_fps*180,10            ,0  ,[]);
      2  : SetBaseOpt(600  ,1   ,2     ,1    ,0    ,0    ,2    ,0      ,0       ,3    ,3     ,15    ,fr_fps*150,20            ,0  ,[]);
      3  : SetBaseOpt(1200 ,3   ,4     ,1    ,0    ,0    ,4    ,0      ,0       ,6    ,6     ,30    ,fr_fps*120,30            ,1  ,[]);
      4  : SetBaseOpt(2500 ,7   ,6     ,1    ,1    ,0    ,6    ,0      ,2       ,10   ,10    ,60    ,fr_fps*90 ,40            ,2  ,[]);
      5  : SetBaseOpt(4500 ,10  ,10    ,2    ,1    ,1    ,8    ,1      ,4       ,10   ,14    ,90    ,fr_fps*60 ,50            ,3  ,[UID_Pain,UID_ArchVile,UID_Medic]);
      6  : SetBaseOpt(5000 ,14  ,14    ,6    ,1    ,1    ,10   ,1      ,4       ,2    ,14    ,120   ,fr_fps*30 ,MaxPlayerUnits,4  ,[UID_Pain,UID_ArchVile,UID_Medic,UID_BFG,UID_ZBFG]);
      else SetBaseOpt(6000 ,17  ,20    ,6    ,1    ,1    ,12   ,1      ,5       ,2    ,14    ,120   ,1         ,MaxPlayerUnits,15 ,[UID_Pain,UID_ArchVile,UID_Medic,UID_BFG,UID_ZBFG]);
      end;
      ai_max_specialist:=ai_skill;
      case ai_skill of
      0  :;
      1,
      2  : ai_flags:=aif_army_scout;
      3  : ai_flags:=aif_army_scout
                    +aif_base_smart_opening
                    +aif_base_advance
                    +aif_army_smart_order;
      4  : ai_flags:=aif_army_scout
                    +aif_base_smart_opening
                    +aif_base_smart_order
                    +aif_base_advance
                    +aif_base_suicide
                    +aif_army_smart_order
                    +aif_army_advance
                    +aif_army_teleport
                    +aif_ability_detection
                    +aif_ability_other;
      else ai_flags:=aif_base_smart_opening
                    +aif_base_smart_order
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
   ai_make_scirmish_start_alarms(p);
end;

function ai_HighPrioTarget(player:PTPlayer;tu:PTUnit):boolean;
begin
   ai_HighPrioTarget:=false;
   if(player^.state=ps_comp)then
    ai_HighPrioTarget:=tu^.uidi in player^.ai_hptargets;
end;

////////////////////////////////////////////////////////////////////////////////

procedure ai_set_nearest_alarm(tu:PTUnit;x,y,ud:integer;zone:word);
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

procedure ai_clear_vars(pu:PTUnit);
var i,d,ds:integer;
begin
   with pu^ do
   begin
      aiu_alarm_d    :=notset;
      aiu_alarm_x    :=-1;
      aiu_alarm_y    :=-1;
      aiu_need_detect:=notset;
      aiu_armyaround_ally :=0;
      aiu_armyaround_enemy:=0;
   end;
   ai_armyaround_own      :=0;
   ai_armyaround_enemy_fly:=0;
   ai_armyaround_enemy_grd:=0;
   ai_army_air            :=0;
   ai_army_ground         :=0;

   // alarm
   ai_alarm_zone     :=0;
   ai_alarm_d        :=notset;
   ai_alarm_x        :=-1;
   ai_alarm_y        :=-1;
   ai_alarm_unit     :=nil;

   // enemy
   ai_enemy_u        :=nil;
   ai_enemy_d        :=notset;
   ai_enemy_air_u    :=nil;
   ai_enemy_air_d    :=notset;
   ai_enemy_grd_u    :=nil;
   ai_enemy_grd_d    :=notset;
   ai_enemy_inv_u    :=nil;
   ai_enemy_inv_d    :=notset;

   // repair
   ai_mrepair_u      := nil;
   ai_mrepair_d      := notset;
   ai_urepair_u      := nil;
   ai_urepair_d      := notset;

   // cpoints
   ai_cpoint_x       :=0;
   ai_cpoint_y       :=0;
   ai_cpoint_d       :=notset;
   ai_cpoint_zone    :=0;

   // get default alarm point
   with pu^ do
    with player^ do
    begin
       for i:=0 to MaxPlayers do
        with ai_alarms[i] do
         if(aia_enemy_count>0)then
          if(ukfly)
          or(ukfloater)
          or(aia_zone=pfzone)then ai_set_nearest_alarm(nil,aia_x,aia_y,point_dist_int(aia_x,aia_y,x,y),aia_zone);

       ai_cpoint_koth:=false;
       for i:=1 to MaxCPoints do
        with g_cpoints[i] do
         if(cpCapturer>0)then
          if(cpOwnerTeam<>team)
          or((cpTimer>0)and(cpTimerOwnerTeam<>team))then
          begin
             d:=point_dist_int(cpx,cpy,x,y);

             ds:=d;
             if(i=1)and(g_mode=gm_koth)then ds:=max2(d div 3,ai_cp_go_r);
             if(cpOwnerTeam=0)and(cpTimer<=0)then ds:=d div 2;

             if(pfzone=cpzone)
             or(ukfly)
             or(ukfloater)
             or(d<gm_cptp_r)then
              if(ds<ai_cpoint_d)then
              begin
                 ai_cpoint_x   :=cpx;
                 ai_cpoint_y   :=cpy;
                 ai_cpoint_d   :=ds;
                 ai_cpoint_zone:=cpzone;

                 ai_cpoint_koth:=(i=1)and(g_mode=gm_koth);
              end;
          end;
    end;

   ai_LostWantZombieMe:=false;

   // commander
   ai_grd_commander_u:=nil;
   ai_fly_commander_u:=nil;
   ai_grd_commander_d:=notset;
   ai_fly_commander_d:=notset;

   // nearest own building
   ai_base_d        := notset;
   ai_base_u        := nil;

   // nearest own building with alarm
   ai_abase_d       := notset;
   ai_abase_u       := nil;

   // transport target
   ai_inapc_d       := notset;
   ai_inapc_u       := nil;

   // nearest teleporter
   ai_teleporter_d  := notset;
   ai_teleporter_u  := nil;
   ai_teleports_near:= 0;

   // teleporter beacon
   ai_teleporter_beacon_u
                    := nil;

   // who need invuln
   ai_invuln_tar_u  := nil;

   // uac strike target
   ai_strike_tar_u  := nil;

   // who need heye
   ai_need_heye_d   := notset;
   ai_need_heye_u   := nil;

   // builds data
   ai_enrg_pot      :=0;
   ai_enrg_cur      :=0;

   ai_basep_builders:=0;  // base production
   ai_basep_need    :=0;

   ai_unitp_cur     :=0;  // unit production
   ai_unitp_cur_na  :=0;
   ai_unitp_need    :=0;

   ai_upgrp_cur     :=0;  // upgr production
   ai_upgrp_cur_na  :=0;
   ai_upgrp_need    :=0;

   ai_tech0_cur     :=0;  // tech 1
   ai_tech1_cur     :=0;  // tech 2

   ai_detect_cur    :=0;  // radar/heye
   ai_detect_need   :=0;

   ai_spec1_cur     :=0;  // rocket station/altar
   ai_spec2_cur     :=0;

   ai_towers_cur_active
                    :=0;
   ai_towers_cur    :=0;
   ai_towers_near   :=0;
   ai_towers_near_air   :=0;
   ai_towers_near_ground:=0;
   ai_towers_needx  :=-1;
   ai_towers_needy  :=-1;
   ai_towers_need   :=0;
   ai_towers_need_type
                    :=0;

   ai_inprogress_uid:=0;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   AI DATA
//

procedure ai_collect_data(pu,tu:PTUnit;ud:integer);
var pfcheck:boolean;
procedure _setCommanderVar(pv:PPTUnit;pd:pinteger;d:integer);
begin
   if(pv^=nil)
   then begin pv^:=tu;pd^:=d;end
   else
     if(tu^.speed<pv^^.speed)
     then begin pv^:=tu;pd^:=d;end
     else
       if (tu^.speed=pv^^.speed)
       and(tu^.unum <pv^^.unum)
       then begin pv^:=tu;pd^:=d;end;
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
      if(tu^.hits>0)then
      begin
         if(not _IsUnitRange(tu^.inapc,nil))then // not inapc
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
                     if(tu^.bld)then ai_towers_cur_active+=1;
                  end
                  else
                    if(tu^.uidi=aiucl_twr_ground1[race])
                    or(tu^.uidi=aiucl_twr_ground2[race])then
                    begin
                       if(ud<srange)then
                       begin
                          ai_towers_near_ground+=1;
                          ai_towers_near       +=1;
                       end;
                       ai_towers_cur+=1;
                       if(tu^.bld)then ai_towers_cur_active+=1;
                    end;
                  if(tu^.bld)then
                  begin
                     //// active detection
                     // hell eye target
                     if(tu^.aiu_need_detect<ai_need_heye_d)then
                      if(tu^.buff[ub_detect]<=0)and(tu^.buff[ub_hvision]<=0)then
                      begin
                         ai_need_heye_u:=tu;
                         ai_need_heye_d:=tu^.aiu_need_detect;
                      end;
                     // uac radar target
                     if(tu^.aiu_alarm_d<=tu^.srange)and(_IsUnitRange(tu^.a_tar,nil))and(tu^.buff[ub_damaged]>0)then
                      if(ai_invuln_tar_u=nil)
                      then ai_invuln_tar_u:=tu
                      else
                        if(tu^.hits>ai_invuln_tar_u^.hits)then ai_invuln_tar_u:=tu;
                  end;
                  if(ud<base_ir)and(not tu^.uid^._ukbuilding)then aiu_armyaround_ally+=tu^.uid^._limituse;
               end;
               // attacked town
               if (tu^.uid^._attack=0 )
               and(tu^.uid^._ukbuilding)
               and(tu^.aiu_alarm_d<base_ir)then
                 if(tu^.aiu_armyaround_ally<=tu^.aiu_armyaround_enemy)
                 or(ud<base_r)
                 or((ud<base_rr)and pfcheck)then _setNearestTarget(@ai_abase_u,@ai_abase_d,ud);

               // and(tu^.aiu_armyaround_enemy>ul1)

               // teleporter target
               if(_ability=uab_teleport)then
                if(tu^.aiu_alarm_d<base_r)then
                 if(not pf_isobstacle_zone(tu^.pfzone))then
                  if(ai_teleporter_beacon_u=nil)
                  then ai_teleporter_beacon_u:=tu
                  else
                    if(ai_teleporter_beacon_u^.ukfly)and(not tu^.ukfly)
                    then ai_teleporter_beacon_u:=tu
                    else
                      if(tu^.aiu_armyaround_ally>ai_teleporter_beacon_u^.aiu_armyaround_ally)
                      then ai_teleporter_beacon_u:=tu;

               // repair/heal target
               if(tu^.bld)and(tu^.hits<tu^.uid^._mhits)and(tu^.buff[ub_heal]<=0)then
                if(pfcheck)or(ud<=srange)then
                 if(tu^.uid^._ukmech)
                 then _setNearestTarget(@ai_mrepair_u,@ai_mrepair_d,ud)
                 else _setNearestTarget(@ai_urepair_u,@ai_urepair_d,ud);
            end
            else
             if(_uvision(team,tu,true))then  // enemy in vision
             begin
                ai_set_nearest_alarm(tu,0,0,ud,0);

                _setNearestTarget(@ai_enemy_u,@ai_enemy_d,ud);
                if(tu^.ukfly)and(tu^.uidi<>UID_LostSoul)then
                begin
                   _setNearestTarget(@ai_enemy_air_u,@ai_enemy_air_d,ud);
                   if(ud<base_ir)and(tu^.uid^._attack>0)then ai_armyaround_enemy_fly+=tu^.uid^._limituse;
                end
                else
                begin
                   _setNearestTarget(@ai_enemy_grd_u,@ai_enemy_grd_d,ud);
                   if(ud<base_ir)and(tu^.uid^._attack>0)then ai_armyaround_enemy_grd+=tu^.uid^._limituse;
                end;

                // need detection
                if(tu^.buff[ub_invis]>0)and(tu^.vsni[team]<=0)then
                begin
                   _setNearestTarget(@ai_enemy_inv_u,@ai_enemy_inv_d,ud);
                   if(ud<srange)and(tu^.uid^._attack>0)then aiu_need_detect:=ud-srange-hits;
                end;
                if(ud<base_ir)and(tu^.uid^._attack>0)then aiu_armyaround_enemy+=tu^.uid^._limituse;

                // uac strike target
                if(tu^.uid^._ukbuilding)then
                 if(ai_strike_tar_u=nil)
                 then ai_strike_tar_u:=tu
                 else
                   if(tu^.hits>ai_strike_tar_u^.hits)
                   then ai_strike_tar_u:=tu;

                if(not ai_LostWantZombieMe)then
                 if((ud-_r-tu^.uid^._r)<melee_r)then
                  if(tu^.uidi=UID_Phantom)and(tu^.a_tar=unum)then ai_LostWantZombieMe:=true;
             end;

            if(player=tu^.player)then
            begin
               if(tu^.bld)then
               begin
                  // teleports near
                  if(tu^.uid^._ability=uab_teleport)then
                  begin
                     _setNearestTarget(@ai_teleporter_u,@ai_teleporter_d,ud+tu^.rld);
                     if(ud<base_rr)and(pfzone=tu^.pfzone)then ai_teleports_near+=1;
                  end;

                  if(tu^.unum<>ai_scout_u_cur)then
                  begin
                     // transport target
                     if(apcc<apcm)and(ud<ai_inapc_d)and(tu^.group<>aio_busy)then
                      if(tu^.aiu_alarm_d>base_ir)or(_attack=atm_bunker)then
                       if(tu^.apcc=tu^.apcm)or(armylimit>=ai_limit_border)or(armylimit>=ai_attack_limit)then
                        if(pfcheck)then
                         if(_itcanapc(pu,tu))then _setNearestTarget(@ai_inapc_u,@ai_inapc_d,ud);

                     // commander
                     if(ud<base_rr)and(tu^.speed>0)and(not tu^.uid^._ukbuilding)then
                      if(tu^.ukfly=false)
                      then _setCommanderVar(@ai_grd_commander_u,@ai_grd_commander_d,ud)
                      else _setCommanderVar(@ai_fly_commander_u,@ai_fly_commander_d,ud);
                  end;
               end;

               // nearest base
               if(ud<ai_base_d)and(tu^.aiu_alarm_d>base_rr)and(tu^.uid^._ukbuilding)and(tu^.speed<=0)and(pfcheck)then _setNearestTarget(@ai_base_u,@ai_base_d,ud);
            end;
         end;

         if(player=tu^.player)then
         begin
            if(uid=tu^.uid)and(not bld)then ai_inprogress_uid+=1;

            case tu^.uidi of
            UID_HSymbol   : if(a_units[UID_HASymbol   ]>0)and(cf(@ai_flags,@aif_base_advance))then ai_enrg_pot+=_uids[UID_HASymbol   ]._genergy else ai_enrg_pot+=tu^.uid^._genergy;
            UID_UGenerator: if(a_units[UID_UAGenerator]>0)and(cf(@ai_flags,@aif_base_advance))then ai_enrg_pot+=_uids[UID_UAGenerator]._genergy else ai_enrg_pot+=tu^.uid^._genergy;
            else            ai_enrg_pot+=tu^.uid^._genergy;
            end;
            ai_enrg_cur+=tu^.uid^._genergy;

            if(tu^.bld)and(tu^.speed>0)and(tu^.uid^._attack>0)then
            begin
               if(tu^.ukfly)
               then ai_army_air   +=tu^.uid^._limituse
               else ai_army_ground+=tu^.uid^._limituse;
               ai_armyaround_own+=tu^.uid^._limituse;
            end;

            if(tu^.uid^._isbarrack)then
             if(tu^.uidi=aiucl_barrack0[race])
             or(tu^.uidi=aiucl_barrack1[race])then
             begin
                ai_unitp_cur+=tu^.level+1;
                if(tu^.level=0)then
                ai_unitp_cur_na+=1;
             end;

            if(tu^.uid^._issmith)then
             if(tu^.uidi=aiucl_smith[race])then
             begin
                ai_upgrp_cur+=tu^.level+1;
                if(tu^.level=0)then
                ai_upgrp_cur_na+=1;
             end;
         end;
      end;
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
        if(aia_enemy_count>0)then
         if(_CheckRoyalBattleR(aia_x,aia_y,base_r))then aia_enemy_count:=0;
   end;
end;

procedure ai_scout_pick(pu:PTUnit);
var w:integer;
   tu:PTUnit;
begin
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

////////////////////////////////////////////////////////////////////////////////
//
//   BUILD BASE
//

procedure ai_builder(pu:PTUnit);
var  bt : byte;
   ddir,
   rdir : single;
base_energy,
bx,by,l : integer;
nocheck_energy:boolean;

function SetBT(buid:byte):boolean;
var _c:cardinal;
begin
   SetBT:=false;
  if(bt=0)then
   if(buid in pu^.uid^.ups_builder)then
   begin
      _c:=_uid_conditionals(pu^.player,buid);
      if(_c=0)or((_c=ureq_energy)and(nocheck_energy))then
      begin
         bt   :=buid;
         SetBT:=true;
      end;
   end;
end;

function SetBTX(buid1,buid2:byte;x:integer):boolean;
begin
   SetBTX:=false;
   if(bt=0)then
     with pu^.player^ do
     begin
        if(uid_e[buid1]>=x)then exit;
        if(buid2>0)then
        if(uid_e[buid2]>=x)then exit;

        bt:=buid1;
        SetBTX:=true;
     end;
end;

function SetBTA(b0,b1:byte):boolean;
begin
   SetBTA:=false;
   if(bt=0)then
    if(b0=b1)or(b1=0)
    then SetBTA:=SetBT(b0)
    else
    begin
       with pu^.player^ do
        if(uid_e[b0]<4)
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

procedure BuildMain(x:integer);   // Builders
begin
   with pu^.player^ do
    if(ai_basep_builders<x)and(ai_basep_builders<ai_max_mains)then
     if(SetBTA(aiucl_main0[race],aiucl_main1[race]))then ddir:=-1;
end;
procedure BuildEnergy(x:integer); // Energy
begin
   x+=base_energy;
   with pu^.player^ do
    if(ai_enrg_pot<x)and(ai_enrg_pot<ai_max_energy)and(ai_enrg_pot<ai_generators_energy)then
     if(SetBTA(aiucl_generator[race],0))then ddir:=-1;
end;
procedure BuildUProd(x:integer);  // Barracks
begin
   with pu^.player^ do
    if(ai_unitp_cur<x)and(ai_unitp_cur<ai_max_unitps)then
     if(ai_tech1_cur<=0)or(ai_unitp_cur_na=0)or(ai_unitp_cur<6)then
      if(SetBTA(aiucl_barrack0[race],aiucl_barrack1[race]))then ddir:=-1;
end;
procedure BuildSmith(x:integer);  // Smiths
begin
   with pu^.player^ do
    if(ai_upgrp_cur<x)and(ai_upgrp_cur<ai_max_upgrps)then
     if(ai_tech1_cur<=0)or(ai_upgrp_cur_na=0)or(ai_upgrp_cur<2)then
      if(SetBTA(aiucl_smith[race],0))then ddir:=-1;
end;
procedure BuildTech0(x:integer);  // Tech0  TechCenter, HellMonastery
begin
   with pu^.player^ do
    if(ai_tech0_cur<x)and(ai_tech0_cur<ai_max_tech0)then
     if(SetBTA(aiucl_tech0[race],0))then ddir:=-1;
end;
procedure BuildTech1(x:integer);  // Tech1
begin
   with pu^.player^ do
    if(ai_tech1_cur<x)and(ai_tech1_cur<ai_max_tech1)then
     if(SetBTA(aiucl_tech1[race],0))then ddir:=-1;
end;
procedure BuildDetect(x:integer);  // Radar,  Heye Nest
begin
   with pu^.player^ do
    if(ai_detect_cur<x)and(ai_detect_cur<ai_max_detect)then
     if(SetBTA(aiucl_detect[race],0))then ddir:=-1;
end;
procedure BuildSpec1(x:integer);  // RStation, Altar
begin
   with pu^.player^ do
    if(ai_spec1_cur<x)and(ai_spec1_cur<ai_max_spec1)then
     if(SetBTA(aiucl_spec1[race],0))then ddir:=-1;
end;
procedure BuildSpec2(x:integer);  // Teleport
begin
   with pu^.player^ do
    if(ai_spec2_cur<x)and(ai_spec2_cur<ai_max_spec2)then
     if(SetBTA(aiucl_spec2[race],0))then ddir:=-1;
end;
function BuildTower(x,tower_kind:integer):boolean;  // Towers
begin
    with pu^.player^ do
     if(ai_towers_cur<x)and(ai_towers_cur<ai_max_towers)then
      if(tower_kind>0)
      then BuildTower:=SetBTA(aiucl_twr_air1[race],aiucl_twr_air2[race])
      else
       if(tower_kind<0)
       then BuildTower:=SetBTA(aiucl_twr_ground1[race],aiucl_twr_ground2[race])
       else
       begin
          if(ai_towers_near_air<ai_towers_near_ground)
          then BuildTower:=SetBTA(aiucl_twr_air1   [race],aiucl_twr_air2   [race])
          else BuildTower:=SetBTA(aiucl_twr_ground1[race],aiucl_twr_ground2[race]);
          if(not BuildTower)then BuildTower:=SetBTA(aiucl_twr_ground1[race],aiucl_twr_air1[race]);
          if(not BuildTower)then BuildTower:=SetBTA(aiucl_twr_ground2[race],aiucl_twr_air2[race]);
       end;

   if(BuildTower)then
    with pu^ do
    begin
       if(ai_towers_needx<0)then
        if(aiu_alarm_d<notset)then
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
   bt  :=0;
   ddir:=-1;
   rdir:=0;
   nocheck_energy:=true;
   base_energy:=0;

   with pu^     do
   with uid^    do
   with player^ do
   if(build_cd<=0)then
   begin
      // opening
      if(cf(@ai_flags,@aif_base_smart_opening))then
      begin
         case race of
         r_hell: base_energy:=350*upgr[_upgr_srange];
         r_uac : base_energy:=300*upgr[_upgr_srange];
         end;

         if(ai_towers_need>0)then //ai_min_towers
         BuildTower(ai_towers_need,ai_towers_need_type);

if(random(2)=0)
then     BuildEnergy(600 );
         BuildUProd (1   );
         BuildEnergy(900 );
         BuildSmith (1   );
         BuildEnergy(1400);
         BuildUProd (4   );
         BuildDetect(2   );
         BuildSpec2 (1   );
         BuildMain  (2   );
         BuildEnergy(1650);
         BuildUProd (5   );
         BuildDetect(4   );
         BuildSpec2 (3   );
         BuildEnergy(1750);
         BuildUProd (6   );
         BuildDetect(6   );
         BuildEnergy(1950);
         BuildMain  (3   );
         BuildEnergy(2050);
         BuildMain  (4   );
         BuildEnergy(2550);
         BuildTech0 (1   );
         BuildTech1 (1   );
         BuildSpec1 (1   );
      end;

      // common
      if(bt=0)then
       if(cf(@ai_flags,@aif_base_smart_order))then
       begin
          nocheck_energy:=false;
          BuildUProd (ai_unitp_need);
          BuildSmith (ai_upgrp_need);
          BuildTech0 (1);
          BuildTech1 (1);
          BuildDetect(ai_detect_need);
          BuildSpec1 (ai_max_spec1 );
          BuildSpec2 (ai_max_spec2 );
          BuildTower (ai_towers_need,ai_towers_need_type);
          BuildMain  (ai_basep_need);
          nocheck_energy:=true;
          BuildEnergy(ai_generators_energy);
       end
       else
         case random(10) of
        0:BuildEnergy(ai_generators_energy);
        1:BuildSmith (ai_upgrp_need);
        2:BuildTech0 (1);
        3:BuildTech1 (1);
        4:BuildDetect(ai_detect_need);
        5:BuildSpec1 (ai_max_spec1 );
        6:BuildSpec2 (ai_max_spec2 );
        7:BuildUProd (ai_unitp_need);
        8:BuildMain  (ai_basep_need);
        9:BuildTower (ai_towers_need,ai_towers_need_type);
         end;

      if(bt=0)then exit;

      if(ddir<=0)then
      begin
         ddir:=random(360);
         if(g_mode=gm_royale)then
           if(_CheckRoyalBattleR(x,y,g_royal_r div 6))
           or(bt=aiucl_main0[race])
           or(bt=aiucl_main1[race])
           then ddir:=point_dir(x,y,map_hmw,map_hmw)-_randomr(100);
      end;
      rdir:=ddir*degtorad;
      l   :=_r+random(srange-_r);
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

uprod_smart = -1;
uprod_any   = -2;
uprod_base  = -3;
uprod_air   = -4;


function ai_UnitProduction(pu:PTUnit;uclass,count:integer):boolean;
var ut  :byte;
    up_m,
    up_n:integer;
function tryTransport:boolean;
begin
   tryTransport:=false;
   with pu^.player^ do
     if((armylimit+uprodl)>ul20)and(uid_eb[UID_FAPC]<=0)then
      tryTransport:=ai_UnitProduction(pu,UID_FAPC,1);
end;

begin
   ai_UnitProduction:=false;
   ut:=0;

   with pu^     do
   with player^ do
   if((ucl_l[false]+uprodl)<ai_max_blimit)then
   begin
      if(not cf(@ai_flags,@aif_army_smart_order))then uclass:=uprod_any;

      case uclass of
uprod_smart: begin
                ai_UnitProduction:=true;
                if(ai_UnitProduction(pu,uprod_base,MaxUnits))then exit;

                if(aiu_alarm_d>=notset)then
                begin
                   if(ai_UnitProduction(pu,uprod_any,MaxUnits))then exit;
                end
                else
                begin
                   if(ai_alarm_zone<>pfzone)then
                     if((race=r_uac )and(uid_e[UID_FAPC]<=0))
                     or (race=r_hell)then
                       if(ai_UnitProduction(pu,uprod_air,MaxUnits))then exit;
                   if(ai_UnitProduction(pu,uprod_any,MaxUnits))then exit;
                end;
                ai_UnitProduction:=false;
                exit;
             end;

uprod_base : begin
                ai_UnitProduction:=true;
                case pu^.player^.race of
             r_hell: begin
                        if(ai_UnitProduction(pu,UID_Imp           ,3))then exit;
                        if(ai_UnitProduction(pu,UID_Cacodemon     ,3))then exit;
                        if(ai_UnitProduction(pu,UID_ZSergant      ,3))then exit;
                        if(ai_UnitProduction(pu,UID_ZCommando     ,3))then exit;
                     end;
             r_uac : begin
                        if(ai_UnitProduction(pu,UID_Antiaircrafter,3))then exit;
                        if(ai_UnitProduction(pu,UID_Sergant       ,3))then exit;
                        if(ai_UnitProduction(pu,UID_Commando      ,3))then exit;
                        if(ai_UnitProduction(pu,UID_Medic         ,3))then exit;
                        if(ai_UnitProduction(pu,UID_Engineer      ,3))then exit;
                     end;
                end;
                ai_UnitProduction:=false;
                exit;
             end;
uprod_any  : case pu^.player^.race of
             r_hell: case random(23) of
                          0 : ut:=UID_LostSoul;
                          1 : ut:=UID_Imp;
                          2 : ut:=UID_Demon;
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
                          19: ut:=UID_ZSiege;
                          20: ut:=UID_ZMajor;
                          21: ut:=UID_ZFMajor;
                          22: ut:=UID_ZBFG;
                     end;
             r_uac : begin
                     if(tryTransport)then exit;
                     case random(16) of
                          0 : ut:=UID_Medic;
                          1 : ut:=UID_Engineer;
                          2 : ut:=UID_Sergant;
                          3 : ut:=UID_SSergant;
                          4 : ut:=UID_Commando;
                          5 : ut:=UID_Antiaircrafter;
                          6 : ut:=UID_Siege;
                          7 : ut:=UID_Major;
                          8 : ut:=UID_FMajor;
                          9 : ut:=UID_BFG;
                          10: ut:=UID_APC;
                          11: ut:=UID_FAPC;
                          12: ut:=UID_UACBot;
                          13: ut:=UID_Terminator;
                          14: ut:=UID_Tank;
                          15: ut:=UID_Flyer;
                     end;
                     end;
             end;
uprod_air  : case pu^.player^.race of
             r_hell: case random(4) of
                          0 : ut:=UID_LostSoul;
                          1 : ut:=UID_Cacodemon;
                          2 : ut:=UID_Pain;
                          3 : ut:=UID_ZFMajor;
                     end;
             r_uac : case random(3) of
                          0 : ut:=UID_FMajor;
                          1 : ut:=UID_Flyer;
                          2 : ut:=UID_FAPC;
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
UID_FAPC,
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
        if(uip<lvl)and(uip<ai_max_upgrlvl)then _unit_supgrade(pu,upid);
     end;
end;
begin
   with pu^     do
    with player^ do
     if(ai_max_upgrlvl>0)then
      case race of
r_hell: begin
        if(cf(@ai_flags,@aif_upgr_smart_opening))then
        begin
        MakeUpgr(upgr_hell_buildr    ,2);
        MakeUpgr(upgr_hell_HKTeleport,1);
        MakeUpgr(upgr_hell_spectre   ,1);
        MakeUpgr(upgr_hell_pinkspd   ,1);
        MakeUpgr(upgr_hell_9bld      ,1);
        MakeUpgr(upgr_hell_heye      ,1);
        MakeUpgr(upgr_hell_vision    ,1);
        MakeUpgr(upgr_hell_pains     ,1);
        end;

        MakeUpgr(random(30)   ,ai_max_upgrlvl);
        end;
r_uac : begin
        if(cf(@ai_flags,@aif_upgr_smart_opening))then
        begin
        MakeUpgr(upgr_uac_buildr     ,2);
        MakeUpgr(upgr_uac_mainm      ,1);
        MakeUpgr(upgr_uac_commando   ,1);
        MakeUpgr(upgr_uac_jetpack    ,1);
        MakeUpgr(upgr_uac_float      ,1);
        MakeUpgr(upgr_uac_botturret  ,1);
        MakeUpgr(upgr_uac_lturret    ,1);
        MakeUpgr(upgr_uac_vision     ,1);
        MakeUpgr(upgr_uac_9bld       ,1);
        end;

        MakeUpgr(30+random(30),ai_max_upgrlvl);
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
       if(upproda<=0)and(uproda<=0)and(not bld)then exit;

      if((ai_inprogress_uid=0)and(    bld))
      or((ai_inprogress_uid>0)and(not bld))then
      case uidi of
UID_HSymbol,
UID_HASymbol,
UID_UGenerator,
UID_UAGenerator: if(armylimit>ai_gendestroy_armylimit)and(cenergy>_genergy)and(menergy>ai_generators_energy)then exit; // ai_enrg_cur
      else
        if(_isbarrack)or(_issmith)then
         if(ai_isnoprod(pu))then
         begin
            i:=level+1;

            if(_isbarrack)and(ai_unitp_cur>6)then
             if(ai_unitp_cur_na<=0)or((level=0)and(ai_unitp_cur_na>0))then
              if((ai_unitp_cur-i)>=ai_unitp_need)then exit;
            if(_issmith  )and(ai_upgrp_cur>3)then
             if(ai_upgrp_cur_na<=0)or((level=0)and(ai_upgrp_cur_na>0))then
              if((ai_upgrp_cur-i)>=ai_upgrp_need)then exit;
         end;
      end;

      if(ai_LostWantZombieMe)and(_zombie_uid>0)and(bld)and(hits<=_zombie_hits)then exit;

      case uidi of
UID_HTower,
UID_HTotem,
UID_UGTurret,
UID_UATurret       : if(ai_towers_cur_active>ai_min_towers)and(ai_cpoint_d>gm_cptp_r)then
                      if(aiu_alarm_d<base_ir)or(aiu_alarm_timer=0)
                      then aiu_alarm_timer:=ai_tower_life_time
                      else
                        if(aiu_alarm_timer<0)
                        then exit;
      end;
   end;
   ai_buildings_need_suicide:=false;
end;

function ai_buildings_need_ability(pu:PTUnit):boolean;
begin
   ai_buildings_need_ability:=true;
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(ai_enemy_u<>nil)and(ai_enemy_d<base_3r)and(buff[ub_damaged]<=0)and(a_rld<=0)then
       if(ai_enemy_u^.uidi=UID_LostSoul)then
        case uidi of
UID_UGTurret   : if(    ai_enemy_u^.ukfly)and(ai_enemy_grd_d>srange)then exit;
UID_UATurret   : if(not ai_enemy_u^.ukfly)and(ai_enemy_air_d>srange)then exit;
        end;

      if(ai_unitp_cur>=1)then
       case uidi of
UID_HSymbol,
UID_UGenerator : if(ai_enrg_cur<ai_max_energy)then exit;
       else
          if(_isbarrack)or(_issmith)then
           if(level=0)and(ai_isnoprod(pu))then exit;
       end;
   end;
   ai_buildings_need_ability:=false;
end;

procedure ai_buildings(pu:PTUnit);
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
      ai_basep_builders:=uid_e[aiucl_main0 [race]]
                        +uid_e[aiucl_main1 [race]];
      ai_tech0_cur     :=uid_e[aiucl_tech0 [race]];
      ai_tech1_cur     :=uid_e[aiucl_tech1 [race]];
      ai_detect_cur    :=uid_e[aiucl_detect[race]]*_uids[aiucl_detect[race]]._limituse;
      ai_spec1_cur     :=uid_e[aiucl_spec1 [race]];
      ai_spec2_cur     :=uid_e[aiucl_spec2 [race]];

      if(_N(@ai_basep_need ,ai_max_mains ))then ai_basep_need :=ai_max_mains;
      if(_N(@ai_unitp_need ,ai_max_unitps))then ai_unitp_need :=mm3(1,ai_basep_builders+1    ,ai_max_unitps);
      if(_N(@ai_upgrp_need ,ai_max_upgrps))then ai_upgrp_need :=mm3(1,round(ai_unitp_cur/2.5),ai_max_upgrps);
      if(_N(@ai_detect_need,ai_max_detect))then ai_detect_need:=mm3(0,ai_unitp_cur           ,ai_max_detect);
      if(_N(@ai_towers_need,ai_max_towers))then
      begin
         ai_towers_need:=0;
         if(ai_enemy_d<base_4r)then
         begin
            ai_towers_need     :=mm3(ai_min_towers,(aiu_armyaround_enemy-aiu_armyaround_ally+MinUnitLimit) div MinUnitLimit,ai_max_towers);
            ai_towers_needx    :=ai_enemy_u^.x;
            ai_towers_needy    :=ai_enemy_u^.y;
            ai_towers_need_type:=0;
            if(ai_armyaround_enemy_fly<=0)and(ai_armyaround_enemy_grd>0)
            then ai_towers_need_type:=-1
            else
              if(ai_armyaround_enemy_fly>0)and(ai_armyaround_enemy_grd<=0)
              then ai_towers_need_type:= 1;
         end;
         if(ai_cpoint_d<base_r)and(ai_cpoint_koth)then
         begin
            ai_towers_need     :=ai_max_towers;
            ai_towers_needx    :=ai_cpoint_x;
            ai_towers_needy    :=ai_cpoint_y;
            ai_towers_need_type:=0;
         end;
      end;


      if(cf(@ai_flags,@aif_base_suicide))then
       if(ai_buildings_need_suicide(pu))then
       begin
          _unit_kill(pu,false,true,true);
          exit;
       end;

      if(cf(@ai_flags,@aif_base_advance))then
       if(ai_buildings_need_ability(pu))then
        _unit_action(pu);


      if(hits<=0)or(not bld)then exit;

      // build  (ucl_l[false]+uprodl)>0
      if(uproda>0)or(n_barracks<=0)then
       if(n_builders>0)and(isbuildarea)then ai_builder(pu);

      // production
      if(_isbarrack)then
      begin
         if(cenergy<0)
         then _unit_ctraining(pu,255)
         else ai_UnitProduction(pu,uprod_smart,MaxUnits);

         if(aiu_alarm_d<notset)and(speed<=0)then
         begin
            uo_x:=aiu_alarm_x;
            uo_y:=aiu_alarm_y;
         end;
      end;
      if(_issmith  )then
       if(cenergy<0)and(uproda<=0)
       then _unit_cupgrade(pu,255)
       else ai_UpgrProduction(pu);
   end;
end;

procedure ai_set_uo(pu:PTUnit;odist,ox,oy,ow:integer;tarpu:PTUnit);
begin
   with pu^  do
   begin
      if(tarpu<>nil)then
      begin
         ox:=tarpu^.x;
         oy:=tarpu^.y;
      end;
      if(odist<0)then odist:=point_dist_int(x,y,ox,oy);
      if(ow=0)or(odist>base_r)then
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
procedure ai_default_idle(pu:PTUnit);
begin
   with pu^ do
   begin
      uo_x:=mm3(1,uo_x,map_mw);
      uo_y:=mm3(1,uo_y,map_mw);
      if(point_dist_rint(x,y,uo_x,uo_y)<srange)
      or(not ukfly and (pfzone<>pf_get_area(uo_x,uo_y)))
      or(_CheckRoyalBattleR(uo_x,uo_y,base_r))
      then ai_set_uo(pu,-1,random(map_mw),random(map_mw),0,nil);
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
      then ai_default_idle(pu)
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

procedure ai_TransportMicro(pu:PTUnit;smartmicro:boolean);
begin
   if(ai_enemy_u<>nil)then
    with pu^  do
     with uid^ do
      if(_attack=atm_bunker)then
      begin
         if(smartmicro)then
           if(apcc=0)
           or(ai_enemy_d<150)
           then ai_RunFrom(pu,ai_enemy_u^.x,ai_enemy_u^.y);
      end
      else
      begin
         if(smartmicro)then
           if(apcc=0)
           then ai_RunFrom(pu,ai_enemy_u^.x,ai_enemy_u^.y)
           else
             if(pf_isobstacle_zone(ai_enemy_u^.pfzone))
             then ai_set_uo(pu,ai_enemy_d,0,0,base_r,ai_enemy_u)
             else ;//go to alarm

        if(ai_enemy_d<200)and(apcc>0)then uo_id:=ua_unload;
      end;
end;
procedure ai_BaseIdle(pu:PTUnit;idle_r:integer);
begin
   if(ai_base_u=nil)
   then ai_default_idle(pu)
   else
     if(idle_r<ai_base_d)and(ai_base_d<notset)
     then ai_set_uo(pu,ai_base_d,0,0,base_r,ai_base_u)
     else ai_default_idle(pu);
end;

procedure ai_try_teleport(pu,target:PTUnit);
var tt:integer;
begin
   if(ai_teleporter_u<>nil)and(cf(@pu^.player^.ai_flags,@aif_army_teleport))then
    if(ai_teleporter_d<base_rr)and(ai_teleporter_u^.pfzone=pu^.pfzone)then
    begin
       pu^.uo_x:=ai_teleporter_u^.x;
       pu^.uo_y:=ai_teleporter_u^.y;
       if(ai_teleporter_d<ai_teleporter_u^.uid^._r)then
        if(target<>nil)then
        begin
           if(target^.player^.team<>pu^.player^.team)then exit;
           tt:=ai_teleporter_u^.uo_tar;
           ai_teleporter_u^.uo_tar:=target^.unum;
           _ability_teleport(pu,ai_teleporter_u,ai_teleporter_d);
           ai_teleporter_u^.uo_tar:=tt;
        end
        else
         if(_IsUnitRange(ai_teleporter_u^.uo_tar,nil))then _ability_teleport(pu,ai_teleporter_u,ai_teleporter_d);
    end
    else
      if(ai_teleporter_u^.player^.upgr[upgr_hell_rteleport]>0)and(ai_teleporter_u^.rld<=0)
      then _ability_teleport(pu,ai_teleporter_u,ai_teleporter_d);
end;

function ai_CheckCPoint(pu:PTUnit):boolean;
begin
   ai_CheckCPoint:=false;
   with pu^ do
   with player^ do
    if(ai_cpoint_d<notset)then
     if(cycle_order<5)
     or(ai_cpoint_d<base_r)
     or(player^.menergy<1000)
     or((ukfly or ukfloater)and(uid_e[uidi]>0)and(unum=uid_x[uidi]))then
     begin
        if(apcm>0)and(unum<>uid_x[uidi])then
         if(apcc<=0)or(pf_isobstacle_zone(ai_cpoint_zone))
         then exit;

        if(apcc>0)and(ai_cpoint_d<base_r)
        then uo_id:=ua_unload;

        group:=aio_busy;
        uo_x:=ai_cpoint_x;
        uo_y:=ai_cpoint_y;
        ai_CheckCPoint:=true;
     end;
end;

procedure ai_unit_target(pu:PTUnit;smartmicro:boolean);
var d,
commander_d :integer;
commander_u,
tu          :PTUnit;
function _IfAttackWithHealWeapon:boolean;
begin
   _IfAttackWithHealWeapon:=false;
   with pu^ do
    with uid^ do
     if(a_rld>0)and(a_weap_cl<=MaxUnitWeapons)then
      with _a_weap[a_weap_cl] do
       _IfAttackWithHealWeapon:=(aw_type=wpt_heal)or(aw_type=wpt_resurect);
end;
begin
   with pu^  do
   with uid^ do
   with player^ do
   begin
      uo_tar:=0;

      if(group=aio_busy)then group:=aio_home;

      if(_CheckRoyalBattleR(x,y,srange))then
      begin
         ai_set_uo(pu,0,map_hmw,map_hmw,0,nil);
         group:=aio_busy;
         exit;
      end
      else
        if(aiu_alarm_d<base_ir)then
        begin
           ai_set_uo(pu,aiu_alarm_d,aiu_alarm_x,aiu_alarm_y,-srange,nil);
           if(apcm>0)then ai_TransportMicro(pu,smartmicro);

           if(smartmicro)then
             case uidi of
UID_Pain       : begin
                 ai_RunFromEnemy(pu,base_r);
                 if(base_r<aiu_alarm_d)
                 and(aiu_alarm_d<base_ir)then _unit_action(pu);
                 end;
UID_ArchVile   : ai_RunFromEnemy(pu,base_r);
             end;
        end
        else
         if((ai_abase_d<aiu_alarm_d)and(group=aio_attack))
         or((ai_abase_d<notset     )and(group=aio_home  ))then
         begin
            ai_set_uo(pu,ai_abase_d,0,0,-base_r,ai_abase_u);

            if(not ukfly)and(not ukfloater)then
              if(ai_abase_d>base_4r)or(pfzone<>ai_abase_u^.pfzone)
              then ai_try_teleport(pu,ai_abase_u);
         end
         else
          if(unum=ai_scout_u_cur)and(ucl_l[false]>ai_MinArmyForScout)then
          begin
             if(group<>aio_scout)then
              if(aiu_attack_timer<0)
              then group:=aio_scout
              else
                if(aiu_attack_timer=0)then aiu_attack_timer:=max2(ai_min_scout_pause,ai_attack_pause div 2);

             if(not ai_CheckCPoint(pu))then
               if(group<>aio_scout)
               then ai_BaseIdle(pu,ai_BaseIDLERange)
               else
                 if(aiu_alarm_d<notset)
                 then ai_set_uo(pu,aiu_alarm_d,aiu_alarm_x,aiu_alarm_y,0,nil)
                 else ai_default_idle(pu);
          end
          else
          begin
             if(group=aio_scout)then
             begin
                group:=aio_home;
                aiu_attack_timer:=0;
             end;

             {if((ai_abase_d<aiu_alarm_d)and(group=aio_attack))
             or((ai_abase_d<notset     )and(group=aio_home  ))then
             begin
                ai_set_uo(pu,ai_abase_d,0,0,-base_r,ai_abase_u);

                if(not ukfly)and(not ukfloater)then
                  if(ai_abase_d>base_4r)or(pfzone<>ai_abase_u^.pfzone)
                  then ai_try_teleport(pu,ai_abase_u);
             end
             else }
               if(not ai_CheckCPoint(pu))then
               begin
                  if(ukfly)then
                  begin
                     commander_u:=ai_fly_commander_u;
                     commander_d:=ai_fly_commander_d;
                     if(ai_grd_commander_u<>nil)then
                      if((aiu_alarm_d<notset)and(ai_grd_commander_u^.pfzone=ai_alarm_zone))
                      or(aiu_alarm_d=notset)then
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

                  if(group=aio_home)then
                    if(ai_armyaround_own>ai_attack_limit)
                    or(armylimit>=ai_attack_limit)
                    or(armylimit>=ai_limit_border)
                    or(ucl_l[false]>=ai_max_blimit)
                    or(ucl_c[true]<=0)then
                    begin
                       group:=aio_attack;
                       if(pu=commander_u)then aiu_attack_timer:=ai_attack_pause;
                    end
                    else ai_BaseIdle(pu,ai_BaseIDLERange);

                  if(group=aio_attack)then
                    if(commander_u=nil)
                    then ai_BaseIdle(pu,ai_BaseIDLERange)
                    else
                      if(pu<>commander_u)then
                      begin
                         if(aiu_attack_timer<>0)and(aiu_attack_timer<commander_u^.aiu_attack_timer)
                         then commander_u^.aiu_attack_timer:=aiu_attack_timer;
                         aiu_attack_timer:=0;

                         ai_set_uo(pu,commander_d,0,0,-srange,commander_u);

                         if(_IsUnitRange(commander_u^.uo_tar,@tu))then
                          if(tu^.uid^._ability=uab_teleport)then ai_try_teleport(pu,nil);
                      end
                      else
                        if(aiu_attack_timer<>0)
                        then ai_BaseIdle(pu,ai_BaseIDLERange)
                        else
                          if(aiu_alarm_d<notset)then
                          begin
                             ai_set_uo(pu,aiu_alarm_d,aiu_alarm_x,aiu_alarm_y,0,nil);
                             if(not ukfly)then
                              if(pfzone<>ai_alarm_zone)
                              or((ai_alarm_d>base_6r)and(ai_armyaround_own<=ul30))
                              then ai_try_teleport(pu,nil);
                          end
                          else ai_default_idle(pu);
              end;
          end;

      if(smartmicro)then
       if(_IfAttackWithHealWeapon)
       then group:=aio_busy
       else
         case uidi of
UID_Engineer : if(ai_mrepair_d<base_rr)and(ai_mrepair_d<ai_cpoint_d)then
               begin
                  ai_set_uo(pu,ai_mrepair_d,0,0,0,ai_mrepair_u);
                  group:=aio_busy;
                  if(ai_mrepair_u^.playeri=playeri)
                  then ai_mrepair_u^.group:=aio_busy;
               end;
UID_Medic    : if(ai_urepair_d<base_rr)and(ai_urepair_d<ai_cpoint_d)then
               begin
                  ai_set_uo(pu,ai_urepair_d,0,0,0,ai_urepair_u);
                  group:=aio_busy;
                  if(ai_urepair_u^.playeri=playeri)
                  then ai_urepair_u^.group:=aio_busy;
               end;
         end;

      if(group<>aio_busy)and(ai_inapc_d<notset)then
       if((ai_inapc_d<ai_abase_d)and(apcc>0))or(apcc<=0)then
        if(ai_inapc_d<base_ir)or( ukfly and ((apcc<=0)or(group<>aio_attack)) )then
        begin
           group:=aio_busy;
           ai_set_uo(pu,ai_inapc_d,0,0,0,ai_inapc_u);
           d:=ai_inapc_d-(_r+ai_inapc_u^.uid^._r-aw_dmelee);
           if(d<=0)
           then uo_tar:=ai_inapc_u^.unum;
        end;
   end;
end;

procedure ai_SaveMain_CC(pu:PTUnit);
var td:integer;
begin
   with pu^ do
   begin
      if(ukfly)then
      begin
         if(_CheckRoyalBattleR(x,y,base_rr))
         then ai_set_uo(pu,0,map_hmw,map_hmw,0,nil)
         else
           if(ai_choosen)and(g_mode=gm_royale)then
           begin
              td:=point_dist_int(x,y,map_hmw,map_hmw);
              ai_set_uo(pu,td,map_hmw,map_hmw,base_r,nil);
              if(td<min2(g_royal_r div 7,base_rr))
              then _unit_action(pu);
           end
           else
             if(ai_choosen)and(ai_cpoint_koth)then
             begin
                ai_set_uo(pu,ai_cpoint_d,ai_cpoint_x,ai_cpoint_y,base_r,nil);
                if(ai_cpoint_d<base_r)
                then _unit_action(pu);
             end
             else
               if(ai_enemy_d<=base_3r)
               then ai_RunFrom(pu,ai_enemy_u^.x,ai_enemy_u^.y)
               else
               begin
                  ai_BaseIdle(pu,srange);
                  if(ai_base_d<base_r)or(ai_base_d=notset)
                  then _unit_action(pu);
               end;
      end
      else
        if(_CheckRoyalBattleR(x,y,base_r))
        or((ai_choosen)and(g_mode=gm_royale))
        or((ai_choosen)and(ai_cpoint_koth)and(ai_cpoint_d>=base_r))
        then _unit_action(pu)
        else
          if(aiu_armyaround_enemy>aiu_armyaround_ally)and(buff[ub_damaged]>0)then
           if(hits<uid^._hmhits)or(aiu_armyaround_enemy>15)then _unit_action(pu);
   end;
end;
procedure ai_SaveMain_HK(pu:PTUnit);
var w:integer;
begin
   with pu^ do
   begin
      if(aiu_alarm_d<base_rr)and(ai_basep_builders<=ai_base_save_border)and(hits<uid^._hmhits)then
      begin
         if(g_mode=gm_royale)
         then w:=g_royal_r div 2
         else w:=map_hmw;
         if(_unit_ability_hkteleport(pu,map_hmw+_random(w),map_hmw+_random(w)))then exit;
      end;

      case g_mode of
gm_koth  : if(ai_choosen)and(base_r<ai_cpoint_d)and(ai_cpoint_d<notset)and(ai_cpoint_koth)then
           begin
              w:=base_r;
              _unit_ability_hkteleport(pu,map_hmw+_random(w),map_hmw+_random(w));
           end;
gm_royale: if(ai_choosen)
           or(_CheckRoyalBattleR(x,y,base_rr))then
           begin
              w:=min2(g_royal_r div 4,base_rr);
              _unit_ability_hkteleport(pu,map_hmw+_random(w),map_hmw+_random(w));
           end;
      end;
   end;
end;

function ai_uab_buildturret(pu:PTUnit):boolean;
begin
   ai_uab_buildturret:=true;
   with pu^  do
   with uid^ do
   begin
      if(aiu_armyaround_ally>ul10)and(ai_enemy_u<>nil)then
       if(ai_enemy_d<srange)and(ai_enemy_u^.uid^._ukbuilding)and(ai_enemy_u^.speed=0)and(buff[ub_damaged]<=0)then exit;

      if(ai_cpoint_d<gm_cptp_r)then exit;
   end;
   ai_uab_buildturret:=false;
end;


procedure ai_code(pu:PTUnit);
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
      ai_choosen:=(player^.uid_eb[uidi]>ai_choosen_border)and(unum=player^.uid_x[uidi]);

      // nearest alarm from global to local unit data
      if(ai_alarm_d<notset)then
      begin
         aiu_alarm_d:=ai_alarm_d;
         aiu_alarm_x:=ai_alarm_x;
         aiu_alarm_y:=ai_alarm_y;
      end;

      //if(sel)then writeln('2 ',aiu_alarm_d);

      {if(playeri=HPlayer)and(sel)then
      begin
         //if(aiu_alarm_x      >-1)then UnitsInfoAddLine(x,y,aiu_alarm_x,aiu_alarm_y,c_red);
         //if(ai_alarm_invis_x>-1)then UnitsInfoAddLine(x,y,ai_alarm_invis_x+1,ai_alarm_invis_y+1,c_aqua);

         //if(ai_uadv_u<>nil)then UnitsInfoAddLine(x,y,ai_uadv_u^.x,ai_uadv_u^.y,c_red);
      end; }

     { if(sel)then
      begin
         writeln(ai_cp_go_r,' ',ai_cpoint_d);
         UnitsInfoAddLine(x,y,ai_cpoint_x,ai_cpoint_y,c_aqua);
      end;  }

      if(_ukbuilding)then ai_buildings(pu);

      if(hits<=0)or(not bld)then exit;

      if(ai_enemy_d>srange)
      then ai_set_alarm(player,x,y,0,srange,false,0)
      else ai_set_alarm(player,ai_enemy_u^.x+sign(ai_enemy_u^.x-x)*100,
                               ai_enemy_u^.y+sign(ai_enemy_u^.y-y)*100,aiu_armyaround_enemy,srange,ai_enemy_u^.uid^._ukbuilding,ai_enemy_u^.pfzone);

      case _ability of
uab_teleport     : if(ai_teleporter_beacon_u<>nil)
                   then uo_tar:=ai_teleporter_beacon_u^.unum
                   else uo_tar:=0;
      end;

      // abilities
      if(cf(@player^.ai_flags,@aif_ability_other))then
       case _ability of
uab_htowertele   : if(aiu_alarm_d<notset)
                  and(ai_cpoint_d>gm_cptp_r)
                  and(a_rld<=0)
                  and(ai_alarm_zone=pfzone)then _unit_ability_htteleport(pu,aiu_alarm_x,aiu_alarm_y);
uab_hinvuln      : if(ai_invuln_tar_u<>nil)then _unit_ability_hinvuln (pu,ai_invuln_tar_u^.unum);
uab_uac_rstrike  : if(ai_strike_tar_u<>nil)then _unit_ability_umstrike(pu,ai_strike_tar_u^.x,ai_strike_tar_u^.y);
uab_buildturret  : if(ai_uab_buildturret(pu))then
                    if(_unit_action(pu))then exit;
       end;

      // MAIN save
      if(cf(@player^.ai_flags,@aif_ability_mainsave))then
       case _ability of
uab_advance: case uidi of
  UID_HCommandCenter,
  UID_UCommandCenter: ai_SaveMain_CC(pu);
             end;
uab_hkeeptele       : ai_SaveMain_HK(pu);
       end;

      // active detection
      if(cf(@player^.ai_flags,@aif_ability_detection))then
       case _ability of
uab_radar        : if(player^.ai_detection_pause=0)and(ai_enemy_inv_u<>nil)then
                    if(_unit_ability_uradar(pu,ai_enemy_inv_u^.x,ai_enemy_inv_u^.y))then player^.ai_detection_pause:=fr_fps;
uab_hell_vision  : if(player^.ai_detection_pause=0)and(ai_need_heye_u<>nil)then
                    if(_ability_hell_vision(ai_need_heye_u,pu))then player^.ai_detection_pause:=fr_fps;
       end;

      if(speed<=0)or(_ukbuilding)then exit;

      ai_unit_target(pu,cf(@player^.ai_flags,@aif_army_smart_micro));
   end;
end;



