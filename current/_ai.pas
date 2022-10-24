
const

aiucl_main0      : array[1..r_cnt] of byte = (UID_HKeep          ,UID_UCommandCenter);
aiucl_main1      : array[1..r_cnt] of byte = (UID_HCommandCenter ,0                 );
aiucl_generator  : array[1..r_cnt] of byte = (UID_HSymbol        ,UID_UGenerator    );
aiucl_barrack0   : array[1..r_cnt] of byte = (UID_HGate          ,UID_UMilitaryUnit );
aiucl_barrack1   : array[1..r_cnt] of byte = (UID_HMilitaryUnit  ,UID_UFactory      );
aiucl_smith      : array[1..r_cnt] of byte = (UID_HPools         ,UID_UWeaponFactory);
aiucl_tech0      : array[1..r_cnt] of byte = (UID_HMonastery     ,UID_UTechCenter   );
aiucl_tech1      : array[1..r_cnt] of byte = (UID_HFortress      ,UID_UNuclearPlant );
aiucl_spec0      : array[1..r_cnt] of byte = (UID_HEyeNest       ,UID_URadar        );
aiucl_spec1      : array[1..r_cnt] of byte = (UID_HAltar         ,UID_URMStation    );
aiucl_spec2      : array[1..r_cnt] of byte = (UID_HTeleport      ,0                 );
aiucl_twr_air1   : array[1..r_cnt] of byte = (UID_HTower         ,UID_UATurret      );
aiucl_twr_air2   : array[1..r_cnt] of byte = (UID_HTotem         ,UID_UATurret      );
aiucl_twr_ground1: array[1..r_cnt] of byte = (UID_HTower         ,UID_UGTurret      );
aiucl_twr_ground2: array[1..r_cnt] of byte = (UID_HTotem         ,UID_UGTurret      );

generators_energy   = 3000;
ai_tower_life_time  = fr_fps*60;
scout_minarmy       = MinUnitLimit*3;
ai_gendestroy_armylimit = MinUnitLimit*80;

ai_unit_base_idle_r = 100;
ai_base_save_border = 6;

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
ai_hadv_u,
ai_uadv_u,
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

ai_cpoint_x,
ai_cpoint_y,
ai_cpoint_d,
ai_alarm_d,
ai_alarm_x,
ai_alarm_y,
ai_grd_commander_d,
ai_fly_commander_d,
ai_need_heye_d,
ai_uadv_d,
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
ai_tech0_need,
ai_tech1_cur,
ai_spec0_cur,
ai_spec0_need,
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
ai_inprogress_uid
                 : integer;

procedure ai_set_alarm(pplayer:PTPlayer;ax,ay,ae,sr:integer;abase:boolean;pfzone:word);
var a,
nobasea,
freea:byte;
begin
   freea  :=255;
   nobasea:=255;
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
     if(g_show_positions)then
     begin
        if(_players[i].state>ps_none)then
         if(_players[i].team<>_players[p].team)then
          ai_set_alarm(@_players[p],map_psx[i],map_psy[i],1,base_r,true,pf_get_area(map_psx[i],map_psy[i]));
     end;
     //else ai_set_alarm(@_players[p],map_psx[i],map_psy[i],1,base_r,true,pf_get_area(map_psx[i],map_psy[i]));
end;

procedure  PlayerSetSkirmishAIParams(p:byte);
procedure SetBaseOpt(me,m,unp,upp,t0,t1,s0,s1,s2,mint,maxt,atl,att,l:integer;mupl:byte;hpt:TSoB);
begin
   with _players[p] do
   begin
      ai_max_energy  :=me;
      ai_max_mains   :=m;
      ai_max_unitps  :=unp;
      ai_max_upgrps  :=upp;
      ai_max_tech0   :=t0;
      ai_max_tech1   :=t1;
      ai_max_spec0   :=s0;
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
      //              energ buil uprod  pprod tech1 tech2 radar         hdetect min    max    attack attack     max           upgr first
      //                    ders                          tlprt altr            towers towers limit  delay      army          lvl  targets
      0  : ; // nothing
      1  : SetBaseOpt(300  ,1   ,1     ,0    ,0    ,0    ,0    ,0      ,0       ,1    ,1     ,10    ,fr_fps*180,10            ,0  ,[]);
      2  : SetBaseOpt(600  ,1   ,2     ,1    ,0    ,0    ,0    ,0      ,0       ,3    ,3     ,15    ,fr_fps*150,20            ,0  ,[]);
      3  : SetBaseOpt(1200 ,3   ,4     ,1    ,0    ,0    ,0    ,0      ,0       ,6    ,6     ,30    ,fr_fps*120,30            ,1  ,[]);
      4  : SetBaseOpt(2500 ,7   ,6     ,1    ,1    ,0    ,1    ,0      ,2       ,10   ,10    ,60    ,fr_fps*90 ,40            ,2  ,[]);
      5  : SetBaseOpt(4500 ,10  ,10    ,2    ,2    ,1    ,3    ,1      ,4       ,10   ,14    ,90    ,fr_fps*60 ,50            ,3  ,[UID_Pain,UID_ArchVile,UID_Medic]);
      6  : SetBaseOpt(5000 ,14  ,14    ,6    ,5    ,1    ,4    ,1      ,4       ,2    ,14    ,120   ,fr_fps*30 ,MaxPlayerUnits,4  ,[UID_Pain,UID_ArchVile,UID_Medic,UID_BFG,UID_ZBFG]);
      else SetBaseOpt(6000 ,17  ,20    ,6    ,5    ,1    ,5    ,1      ,5       ,2    ,14    ,120   ,1         ,MaxPlayerUnits,15 ,[UID_Pain,UID_ArchVile,UID_Medic,UID_BFG,UID_ZBFG]);
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
   {
   aif_base_smart_opening : cardinal = 1;
   aif_base_smart_order   : cardinal = 1 shl 1;
   aif_base_suicide       : cardinal = 1 shl 2;
   aif_base_advance       : cardinal = 1 shl 3;
   aif_army_smart_order   : cardinal = 1 shl 4;
   aif_army_scout         : cardinal = 1 shl 5;
   aif_army_advance       : cardinal = 1 shl 6;
   aif_army_smart_micro   : cardinal = 1 shl 7;
   aif_army_teleport      : cardinal = 1 shl 8;
   aif_upgr_smart_opening : cardinal = 1 shl 9;
   aif_ability_detection  : cardinal = 1 shl 10;
   aif_ability_other      : cardinal = 1 shl 11;
   aif_ability_mainsave   : cardinal = 1 shl 12;
   }
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
var i,d:integer;
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
          or(aia_zone=pfzone)then ai_set_nearest_alarm(nil,aia_x,aia_y,point_dist_rint(aia_x,aia_y,x,y),aia_zone);

       for i:=1 to MaxCPoints do
        with g_cpoints[i] do
         if(cpcapturer>0)then
          if(_players[cpowner].team<>player^.team)
          or(cptimer>0)then
          begin
             d:=point_dist_rint(cpx,cpy,x,y);
             if(d<ai_cpoint_d)then
             begin
                ai_cpoint_x   :=cpx;
                ai_cpoint_y   :=cpy;
                ai_cpoint_d   :=d;
                ai_cpoint_zone:=cpzone;

                ai_set_nearest_alarm(nil,ai_cpoint_x,ai_cpoint_y,ai_cpoint_d,ai_cpoint_zone);
             end;
          end;
    end;

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

   // adv
   ai_uadv_d        := notset;
   ai_uadv_u        := nil;
   ai_hadv_u        := nil;

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

   ai_tech0_cur     :=0;  // tech 1 (unit adv)
   ai_tech0_need    :=0;

   ai_tech1_cur     :=0;  // tech 2 (build adv)

   ai_spec0_cur     :=0;  // radar/teleport
   ai_spec0_need    :=0;

   ai_spec1_cur     :=0;  // rocket station/altar

   ai_spec2_cur     :=0;  // heye nest

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
procedure _setNearestPU(ppu:PPTunit;pd:pinteger;d:integer);
begin
   if(ud<pd^)then
   begin
      pd^ :=d;
      ppu^:=tu;
   end;
end;
function _HellAdvPrio(new,cur:PTUnit):boolean;
begin
   _HellAdvPrio:=false;

   if(new=nil)then exit;

   with new^ do
    if(uid^._ukbuilding)
    or(buff[ub_advanced]>0)
    or(uid^._ability=uab_Advance)then exit;

   if(cur<>nil)then
   begin
      if(new^.uidi=UID_LostSoul)then
       if(pu^.player^.uid_e[UID_Pain]>0)then exit;

      if(cur^.hits>new^.hits)then exit;
   end;

   _HellAdvPrio:=true;
end;
begin
   with pu^     do
   with player^ do
   begin
      if(tu^.hits>0)then
      begin
         if(not _IsUnitRange(tu^.inapc,nil))then // not inapc
         begin
            if(team=tu^.player^.team)then
            begin
               if(tu^.uid^._attack>0)then
               begin
                  if(tu^.speed<=0)then
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
                     if(tu^.aiu_need_detect<ai_need_heye_d)then
                      if(tu^.buff[ub_detect]<=0)and(tu^.buff[ub_hvision]<=0)then
                      begin
                         ai_need_heye_u:=tu;
                         ai_need_heye_d:=tu^.aiu_need_detect;
                      end;
                     if(tu^.aiu_alarm_d<=tu^.srange)and(_IsUnitRange(tu^.a_tar,nil))and(tu^.buff[ub_damaged]>0)then
                      if(ai_invuln_tar_u=nil)
                      then ai_invuln_tar_u:=tu
                      else
                        if(tu^.hits>ai_invuln_tar_u^.hits)then ai_invuln_tar_u:=tu;
                  end;
                  if(ud<base_ir)and(not tu^.uid^._ukbuilding)then aiu_armyaround_ally+=tu^.uid^._limituse;
               end;
               if(tu^.uid^._attack=0 )
               or(tu^.uid^._isbuilder)
               or(tu^.uid^._isbarrack)
               or(tu^.uid^._issmith  )then
                if (tu^.uid^._ukbuilding)
                and(tu^.aiu_alarm_d<base_ir)
                and(tu^.aiu_armyaround_ally <tu^.aiu_armyaround_enemy)
                and(tu^.aiu_armyaround_enemy>ul1)then _setNearestPU(@ai_abase_u,@ai_abase_d,ud);

               if(uid^._ability=uab_teleport)then
                if(tu^.aiu_alarm_d<base_r)then
                 if(tu^.ukfly)and(pf_isobstacle_zone(tu^.pfzone))
                 then
                 else
                   if(ai_teleporter_beacon_u=nil)
                   then ai_teleporter_beacon_u:=tu
                   else
                     if(tu^.aiu_armyaround_ally>ai_teleporter_beacon_u^.aiu_armyaround_ally)
                     then ai_teleporter_beacon_u:=tu;

               if(tu^.bld)and(tu^.hits<tu^.uid^._mhits)and(tu^.buff[ub_heal]<=0)then
                if(tu^.pfzone=pfzone)or(ud<=srange)then
                 if(tu^.uid^._ukmech)
                 then _setNearestPU(@ai_mrepair_u,@ai_mrepair_d,ud)
                 else _setNearestPU(@ai_urepair_u,@ai_urepair_d,ud);
            end
            else
             if(_uvision(team,tu,true))then
             begin
                ai_set_nearest_alarm(tu,0,0,ud,0);

                _setNearestPU(@ai_enemy_u,@ai_enemy_d,ud);
                if(tu^.ukfly)and(tu^.uidi<>UID_LostSoul)then
                begin
                   _setNearestPU(@ai_enemy_air_u,@ai_enemy_air_d,ud);
                   if(ud<base_rr)and(tu^.uid^._attack>0)then ai_armyaround_enemy_fly+=tu^.uid^._limituse;
                end
                else
                begin
                   _setNearestPU(@ai_enemy_grd_u,@ai_enemy_grd_d,ud);
                   if(ud<base_rr)then ai_armyaround_enemy_grd+=tu^.uid^._limituse;
                end;
                if(tu^.buff[ub_invis]>0)and(tu^.vsni[team]<=0)then
                begin
                   _setNearestPU(@ai_enemy_inv_u,@ai_enemy_inv_d,ud);
                   if(ud<srange)and(tu^.uid^._attack>0)then aiu_need_detect:=ud-srange-hits;
                end;
                if(ud<base_ir)and(tu^.uid^._attack>0)then aiu_armyaround_enemy+=tu^.uid^._limituse;


                if(tu^.uid^._ukbuilding)then
                 if(ai_strike_tar_u=nil)
                 then ai_strike_tar_u:=tu
                 else
                   if(tu^.hits>ai_strike_tar_u^.hits)
                   then ai_strike_tar_u:=tu;
             end;

            if(player=tu^.player)then
            begin
               if(tu^.bld)then
               begin
                  if(uid^._urace=tu^.uid^._urace)then
                  begin
                     if(tu^.uid^._ability=uab_uac__unit_adv)and(tu^.rld<=0)then _setNearestPU(@ai_uadv_u,@ai_uadv_d,ud);

                     if(uid^._ability=uab_hell_unit_adv)then
                      if(_HellAdvPrio(tu,ai_hadv_u))then ai_hadv_u:=tu;
                  end;

                  if(tu^.uid^._ability=uab_teleport)then
                  begin
                     _setNearestPU(@ai_teleporter_u,@ai_teleporter_d,ud+tu^.rld);
                     if(ud<base_rr)and(pfzone=tu^.pfzone)then ai_teleports_near+=1;
                  end;

                  if(ud<ai_inapc_d)and(tu^.group<>aio_busy)and(tu^.unum<>ai_scout_u_cur)then
                   if(tu^.aiu_alarm_d>base_ir)or(uid^._attack=atm_bunker)then
                    if(tu^.apcc=tu^.apcm)or(armylimit>=ai_limit_border)then
                     if(ukfly)or(pfzone=tu^.pfzone)then
                      if(_itcanapc(pu,tu))then _setNearestPU(@ai_inapc_u,@ai_inapc_d,ud);

                  if(ud<base_rr)and(tu^.speed>0)and(not tu^.uid^._ukbuilding)then
                  begin
                     if(tu^.ukfly=false)
                     then _setCommanderVar(@ai_grd_commander_u,@ai_grd_commander_d,ud)
                     else _setCommanderVar(@ai_fly_commander_u,@ai_fly_commander_d,ud);
                  end;
               end;

               if(ud<ai_base_d)and(tu^.aiu_alarm_d>base_rr)and(tu^.uid^._ukbuilding)and(tu^.speed<=0)then _setNearestPU(@ai_base_u,@ai_base_d,ud);
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

            if(tu^.bld)and(tu^.speed>0)and(tu^.uid^._attack>0)then ai_armyaround_own+=tu^.uid^._limituse;

            if(tu^.uid^._isbarrack)then
             if(tu^.uidi=aiucl_barrack0[race])or(tu^.uidi=aiucl_barrack1[race])then
              if(tu^.buff[ub_advanced]>0)
              then ai_unitp_cur+=MaxUnitProdsN
              else
              begin
                 ai_unitp_cur   +=1;
                 ai_unitp_cur_na+=1;
              end;

            if(tu^.uid^._issmith)then
             if(tu^.uidi=aiucl_smith[race])then
              if(tu^.buff[ub_advanced]>0)
              then ai_upgrp_cur+=MaxUnitProdsN
              else
              begin
                 ai_upgrp_cur   +=1;
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
         if(_RoyalBattleOut(aia_x,aia_y,base_r))then aia_enemy_count:=0;
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
   for i:=0 to MaxUnitProdsI do
   begin
      if(i>0)then
       if(buff[ub_advanced]<=0)then break;
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
procedure SetBT(buid:byte);
var _c:cardinal;
begin
  if(bt=0)then
   if(buid in pu^.uid^.ups_builder)then
   begin
      _c:=_uid_conditionals(pu^.player,buid);
      if(_c=0)or((_c=ureq_energy)and(nocheck_energy))then bt:=buid;
   end;
end;

procedure SetBTX(buid1,buid2:byte;x:integer);
begin
   if(bt=0)then
     with pu^.player^ do
     begin
        if(uid_e[buid1]>=x)then exit;
        if(buid2>0)then
        if(uid_e[buid2]>=x)then exit;

        bt:=buid1;
     end;
end;

procedure SetBTA(b0,b1:byte);
begin
   if(bt=0)then
    if(b0=b1)or(b1=0)
    then SetBT(b0)
    else
    begin
       with pu^.player^ do
        if(uid_e[b0]<=0)
        then SetBT(b0)
        else
          if(uid_e[b1]<=0)
          then SetBT(b1)
          else
            if(uid_e[b1]<(uid_e[b0] div 2))then SetBT(b1);
       SetBT(b0);
       if(bt=0)then SetBT(b1);
    end;
end;

procedure BuildMain(x:integer);   // Builders
begin
   with pu^.player^ do
    if(ai_basep_builders<x)and(ai_basep_builders<ai_max_mains)
    then SetBTA(aiucl_main0[race],aiucl_main1[race]);
   ddir:=-1;
end;
procedure BuildEnergy(x:integer); // Energy
begin
   x+=base_energy;
   with pu^.player^ do
    if(ai_enrg_pot<x)and(ai_enrg_pot<ai_max_energy)and(ai_enrg_pot<generators_energy)
    then SetBTA(aiucl_generator[race],0);
   ddir:=-1;
end;
procedure BuildUProd(x:integer);  // Barracks
begin
   with pu^.player^ do
    if(ai_unitp_cur<x)and(ai_unitp_cur<ai_max_unitps)then
     if(ai_tech1_cur<=0)or(ai_unitp_cur_na=0)or(ai_unitp_cur<6)then
      SetBTA(aiucl_barrack0[race],aiucl_barrack1[race]);
   ddir:=-1;
end;
procedure BuildSmith(x:integer);  // Smiths
begin
   with pu^.player^ do
    if(ai_upgrp_cur<x)and(ai_upgrp_cur<ai_max_upgrps)then
     if(ai_tech1_cur<=0)or(ai_upgrp_cur_na=0)or(ai_upgrp_cur<2)then
      SetBTA(aiucl_smith[race],0);
   ddir:=-1;
end;
procedure BuildTech0(x:integer);  // Tech0  TechCenter, HellMonastery
begin
   with pu^.player^ do
    if(ai_tech0_cur<x)and(ai_tech0_cur<ai_max_tech0)
    then SetBTA(aiucl_tech0[race],0);
   ddir:=-1;
end;
procedure BuildTech1(x:integer);  // Tech1
begin
   with pu^.player^ do
    if(ai_tech1_cur<x)and(ai_tech1_cur<ai_max_tech1)
    then SetBTA(aiucl_tech1[race],0);
   ddir:=-1;
end;
procedure BuildSpec0(x:integer);  // Radar,  Heye Nest
begin
   with pu^.player^ do
    if(ai_spec0_cur<x)and(ai_spec0_cur<ai_max_spec0)
    then SetBTA(aiucl_spec0[race],0);
   ddir:=-1;
end;
procedure BuildSpec1(x:integer);  // RStation, Altar
begin
   with pu^.player^ do
    if(ai_spec1_cur<x)and(ai_spec1_cur<ai_max_spec1)
    then SetBTA(aiucl_spec1[race],0);
   ddir:=-1;
end;
procedure BuildSpec2(x:integer);  // Teleport
begin
   with pu^.player^ do
    if(ai_spec2_cur<x)and(ai_spec2_cur<ai_max_spec2)
    then SetBTA(aiucl_spec2[race],0);
   ddir:=-1;
end;
procedure BuildTower(x,t:integer);  // Towers
begin
    with pu^.player^ do
     if(ai_towers_cur<x)and(ai_towers_cur<ai_max_towers)then
      if(t>0)
      then SetBTA(aiucl_twr_air1[race],aiucl_twr_air2[race])
      else
       if(t<0)
       then SetBTA(aiucl_twr_ground1[race],aiucl_twr_ground2[race])
       else
       begin
          if(ai_towers_near_air<ai_towers_near_ground)
          then SetBTA(aiucl_twr_air1   [race],aiucl_twr_air2   [race])
          else SetBTA(aiucl_twr_ground1[race],aiucl_twr_ground2[race]);
          if(bt=0)
          then SetBTA(aiucl_twr_ground1[race],aiucl_twr_air1   [race])
          else SetBTA(aiucl_twr_ground2[race],aiucl_twr_air2   [race]);
       end;

   if(bt>0)then
   with pu^ do
   begin
      if(ai_towers_needx=-1)then
       if(aiu_alarm_d<notset)then
       begin
          ai_towers_needx:=aiu_alarm_x;
          ai_towers_needy:=aiu_alarm_y;
       end;
      if(ai_towers_needx>-1)
      then ddir:=(point_dir(x,y,ai_towers_needx,ai_towers_needy)+_randomr(90));
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
         base_energy:=200*upgr[_upgr_srange];

         if(ai_towers_need>ai_min_towers)then
         BuildTower (ai_towers_need,ai_towers_need_type);

         BuildEnergy(350 );
         BuildUProd (1   );
         BuildEnergy(850 );
         BuildTower (2   ,ai_towers_need_type);
         BuildSmith (1   );
         BuildEnergy(1250);
         BuildUProd (2   );
         BuildSpec0 (1   );
         BuildMain  (2   );
         BuildUProd (3   );
         BuildEnergy(1350);
         BuildTower (ai_towers_need,ai_towers_need_type);
         BuildSpec2 (1   );
         BuildEnergy(1550);
         BuildUProd (4   );
         BuildEnergy(1750);
         BuildMain  (3   );
         BuildEnergy(1950);
         BuildMain  (4   );
         BuildEnergy(2050);
         BuildTech0 (1   );
         BuildTech1 (1   );
         BuildSpec1 (1   );
      end;

      // common
      if(cf(@ai_flags,@aif_base_smart_order))then
      begin
         nocheck_energy:=false;
         BuildUProd(ai_unitp_need);
         BuildSmith(ai_upgrp_need);
         BuildTech0(ai_tech0_need);
         BuildSpec0(ai_spec0_need);
         BuildSpec1(ai_max_spec1 );
         BuildSpec2(ai_max_spec2 );
         BuildTower(ai_towers_need,ai_towers_need_type);
         nocheck_energy:=true;
         BuildEnergy(generators_energy);
         BuildMain (ai_basep_need);
      end
      else
        case random(9) of
        0:BuildEnergy(generators_energy);
        1:BuildSmith (ai_upgrp_need);
        2:BuildTech0 (ai_tech0_need);
        3:BuildSpec0 (ai_spec0_need);
        4:BuildSpec1 (ai_max_spec1 );
        5:BuildSpec2 (ai_max_spec2 );
        6:BuildUProd (ai_unitp_need);
        7:BuildMain  (ai_basep_need);
        8:BuildTower (ai_towers_need,ai_towers_need_type);
        end;

     // if(sel)then writeln(bt,' ',ai_unitp_need);

      if(bt=0)then exit;

      if(ddir<=0)then
      begin
         ddir:=random(360);
         if(g_mode=gm_royale)then
         begin
            if(_RoyalBattleOut(x,y,g_royal_r div 6))
            or(bt=aiucl_main0[race])
            or(bt=aiucl_main1[race])
            then ddir:=point_dir(x,y,map_hmw,map_hmw)-_randomr(100);
         end;
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

uprod_smart = 0;
uprod_any   = 1;
uprod_base  = 2;
uprod_air   = 3;


function ai_UnitProduction(pu:PTUnit;uclass:byte):boolean;
var ut  :byte;
    up_m,
    up_n:integer;
procedure pick_any;
begin
   case pu^.player^.race of
r_hell: case random(20) of
0 : ut:=UID_LostSoul;
1 : ut:=UID_Imp;
2 : ut:=UID_Demon;
3 : ut:=UID_Cacodemon;
4 : ut:=UID_Knight;
5 : ut:=UID_Cyberdemon;
6 : ut:=UID_Mastermind;
7 : ut:=UID_Pain;
8 : ut:=UID_Revenant;
9 : ut:=UID_Mancubus;
10: ut:=UID_Arachnotron;
11: ut:=UID_Archvile;
12: ut:=UID_ZFormer;
13: ut:=UID_ZEngineer;
14: ut:=UID_ZSergant;
15: ut:=UID_ZCommando;
16: ut:=UID_ZAntiaircrafter;
17: ut:=UID_ZSiege;
18: ut:=UID_ZMajor;
19: ut:=UID_ZBFG;
        end;
r_uac : case random(14) of
0 : ut:=UID_Medic;
1 : ut:=UID_Scout;
2 : ut:=UID_Sergant;
3 : ut:=UID_Commando;
4 : ut:=UID_Antiaircrafter;
5 : ut:=UID_Siege;
6 : ut:=UID_Major;
7 : ut:=UID_BFG;
8 : ut:=UID_APC;
9 : ut:=UID_FAPC;
10: ut:=UID_UACBot;
11: ut:=UID_Terminator;
12: ut:=UID_Tank;
13: ut:=UID_Flyer;
        end;
   end;
end;
procedure pick_air;
begin
   case pu^.player^.race of
r_hell: case random(7) of
0 : ut:=UID_LostSoul;
1 : ut:=UID_Cacodemon;
2 : ut:=UID_Cacodemon;
3 : ut:=UID_Cacodemon;
4 : ut:=UID_Cacodemon;
5 : ut:=UID_Pain;
6 : ut:=UID_ZMajor;
        end;
r_uac : case random(5) of
0 : ut:=UID_Major;
1 : ut:=UID_Flyer;
2 : ut:=UID_Flyer;
3 : ut:=UID_FAPC;
4 : ut:=UID_FAPC;
        end;
   end;
end;
procedure pick_base;
function _su(__uid:byte;__mx:integer):boolean;
begin
   with pu^.player^ do
    if(a_units[__uid]>=__mx)then
     if((uprodu[__uid]+uid_e[__uid])<__mx)then
     begin
        _su:=true;
        ut:=__uid;
     end
     else _su:=false;
end;
begin
   with pu^.player^ do
   case race of
r_hell: if(not _su(UID_LostSoul,3))then
         if(not _su(UID_Cacodemon,3))then
          _su(UID_ZCommando,3);
r_uac : _su(UID_Commando,3);
   end;
end;
begin
   ai_UnitProduction:=false;
   ut:=0;

   with pu^     do
   with player^ do
   if((ucl_l[false]+uprodl)<ai_max_blimit)then
   begin
      if(not cf(@ai_flags,@aif_army_smart_order))
      then pick_any
      else
        case uclass of
uprod_smart: begin
                ai_UnitProduction:=ai_UnitProduction(pu,uprod_base);
                if(ai_UnitProduction)
                then exit
                else
                  if(aiu_alarm_d>=notset)
                  then pick_any
                  else
                    if(ai_alarm_zone<>pfzone)and
                    ( ((race=r_hell)and(uid_e[UID_FAPC]<=0))
                    or((race=r_uac )and(random(ai_teleports_near+2)>0) ))
                    then pick_air
                    else pick_any;
             end;
uprod_any  : pick_any;
uprod_base : pick_base;
uprod_air  : pick_air;
        end;

      up_n:=uid_e[ut]+uprodu[ut];

      case ut of
UID_Mastermind,
UID_Cyberdemon   : up_m:=ai_max_specialist-(uid_e[UID_Mastermind]+uprodu[UID_Mastermind]
                                           +uid_e[UID_Cyberdemon]+uprodu[UID_Cyberdemon]);
UID_APC,
UID_FAPC,
UID_Pain         : up_m:=ai_max_specialist;
UID_Medic,
UID_Scout        : if(uprodm>1)then up_m:=ai_max_specialist;
      else         up_m:=10000;
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
        MakeUpgr(upgr_hell_mainr ,1);
        MakeUpgr(upgr_hell_hktele,1);
        MakeUpgr(upgr_hell_mainr ,2);
        MakeUpgr(upgr_hell_heye  ,1);
        MakeUpgr(upgr_hell_pains ,1);
        MakeUpgr(upgr_hell_9bld  ,1);
        MakeUpgr(upgr_hell_6bld  ,2);
        end;

        MakeUpgr(random(30),ai_max_upgrlvl);
        end;
r_uac : begin
        if(cf(@ai_flags,@aif_upgr_smart_opening))then
        begin
        MakeUpgr(upgr_uac_mainr  ,1);
        MakeUpgr(upgr_uac_mainm  ,1);
        MakeUpgr(upgr_uac_mainr  ,2);
        MakeUpgr(upgr_uac_float  ,1);
        MakeUpgr(upgr_uac_9bld   ,1);
        MakeUpgr(upgr_uac_6bld   ,1);
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
UID_UAGenerator: if(armylimit>ai_gendestroy_armylimit)and(cenergy>_genergy)and(menergy>generators_energy)then exit; // ai_enrg_cur
      else
        if(_isbarrack)or(_issmith)then
         if(ai_isnoprod(pu))then
         begin
            if(buff[ub_advanced]>0)
            then i:=MaxUnitProdsN
            else i:=1;

            if(_isbarrack)and(ai_unitp_cur>6)then
             if(ai_unitp_cur_na<=0)or((buff[ub_advanced]<=0)and(ai_unitp_cur_na>0))then
              if((ai_unitp_cur-i)>=ai_unitp_need)then exit;
            if(_issmith  )and(ai_upgrp_cur>3)then
             if(ai_upgrp_cur_na<=0)or((buff[ub_advanced]<=0)and(ai_upgrp_cur_na>0))then
              if((ai_upgrp_cur-i)>=ai_upgrp_need)then exit;
         end;
      end;

      case uidi of
UID_UMilitaryUnit,
UID_UCommandCenter : if(ai_enemy_d<srange)and(hits<=_zombie_hits)then
                      if(ai_enemy_u^.uidi=UID_LostSoul)and(ai_enemy_u^.buff[ub_advanced]>0)and(ai_enemy_u^.a_tar=unum)then exit;
UID_HTower,
UID_HTotem,
UID_UGTurret,
UID_UATurret       : if(ai_towers_cur_active>ai_min_towers)then
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
      if(ai_enemy_u<>nil)and(ai_enemy_d<base_rr)and(buff[ub_damaged]<=0)and(a_rld<=0)then
       if(not ai_enemy_u^.uidi in [UID_LostSoul,UID_Major,UID_ZMajor])then
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
          if(buff[ub_advanced]<=0)and(ai_isnoprod(pu))then exit;
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
      ai_basep_builders:=uid_e[aiucl_main0[race]]
                        +uid_e[aiucl_main1[race]];
      ai_tech0_cur     :=uid_e[aiucl_tech0[race]];
      ai_tech1_cur     :=uid_e[aiucl_tech1[race]];
      ai_spec0_cur     :=uid_e[aiucl_spec0[race]];
      ai_spec1_cur     :=uid_e[aiucl_spec1[race]];
      ai_spec2_cur     :=uid_e[aiucl_spec2[race]];

      if(_N(@ai_basep_need ,ai_max_mains ))then ai_basep_need:=ai_max_mains;
      if(_N(@ai_unitp_need ,ai_max_unitps))then ai_unitp_need:=mm3(1,ai_basep_builders+1    ,ai_max_unitps);
      if(_N(@ai_upgrp_need ,ai_max_upgrps))then ai_upgrp_need:=mm3(1,round(ai_unitp_cur/2.5),ai_max_upgrps);
      if(_N(@ai_tech0_need ,ai_max_tech0 ))then ai_tech0_need:=mm3(0,ai_unitp_cur div 3     ,ai_max_tech0 );
      if(_N(@ai_spec0_need ,ai_max_spec0 ))then ai_spec0_need:=mm3(0,ai_unitp_cur div 2     ,ai_max_spec0 );
      if(_N(@ai_towers_need,ai_max_towers))then
       if(ai_enemy_d<base_3r) then
       begin
          ai_towers_need :=mm3(0,(aiu_armyaround_enemy-aiu_armyaround_ally+MinUnitLimit) div MinUnitLimit,ai_max_towers);
          ai_towers_needx:=aiu_alarm_x;
          ai_towers_needy:=aiu_alarm_y;
          ai_towers_need_type:=0;
          if(ai_armyaround_enemy_fly<=0)and(ai_armyaround_enemy_grd>0)
          then ai_towers_need_type:= 1
          else
            if(ai_armyaround_enemy_fly>0)and(ai_armyaround_enemy_grd<=0)
            then ai_towers_need_type:=-1;
       end
       else ai_towers_need:=ai_min_towers;

      if(cf(@ai_flags,@aif_base_suicide))then
       if(ai_buildings_need_suicide(pu))then
       begin
          _unit_kill(pu,false,true,true);
          exit;
       end;

      if(cf(@ai_flags,@aif_base_advance))then
       if(ai_buildings_need_ability(pu))then _unit_action(pu);

      if(hits<=0)or(not bld)then exit;

      // build
      if(n_builders>0)and(isbuildarea)then ai_builder(pu);

      // production
      if(_isbarrack)then
      begin
         if(cenergy<0)
         then _unit_ctraining(pu,255)
         else ai_UnitProduction(pu,uprod_smart);

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
           uo_x:=ox+(sign(ox-x)*_random(-ow));
           uo_y:=oy+(sign(oy-y)*_random(-ow));
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
      or(_RoyalBattleOut(uo_x,uo_y,base_r))
      then ai_set_uo(pu,-1,random(map_mw),random(map_mw),0,nil);
   end;
end;
procedure ai_outfrom(pu:PTUnit;ax,ay:integer);
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
procedure ai_outfromenemy(pu:PTUnit;ud:integer);
begin
   if(ai_enemy_u<>nil)and(ai_enemy_d<ud)then ai_outfrom(pu,ai_enemy_u^.x,ai_enemy_u^.y);
end;


procedure ai_flytransport(pu:PTUnit;smartmicro:boolean);
begin
   if(ai_enemy_u<>nil)then
    with pu^  do
    begin
       if(smartmicro)then
        if(apcc=0)
        then ai_outfrom(pu,ai_enemy_u^.x,ai_enemy_u^.y)
        else
          if(pf_isobstacle_zone(ai_enemy_u^.pfzone))
          then ai_set_uo(pu,ai_enemy_d,0,0,base_r,ai_enemy_u)
          else ;//go to alarm
       if(ai_enemy_d<200)and(apcc>0)then uo_id:=ua_unload;
    end;
end;
procedure ai_apc(pu:PTUnit;smartmicro:boolean);
begin
   if(ai_enemy_u<>nil)then
    with pu^  do
     if(smartmicro)then
      if(apcc=0)
      or(ai_enemy_d<150)
      then ai_outfrom(pu,ai_enemy_u^.x,ai_enemy_u^.y);
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
      if(ai_teleporter_u^.buff[ub_advanced]>0)and(ai_teleporter_u^.rld<=0)
      then _ability_teleport(pu,ai_teleporter_u,ai_teleporter_d);
end;

function ai_CheckCPoint(pu:PTUnit;checkalarm:boolean):boolean;
begin
   ai_CheckCPoint:=false;
   with pu^ do
    if(ukfly)or(ai_cpoint_zone=pfzone)then
     if(checkalarm)then
     begin
        if(g_mode=gm_koth)
        then ai_CheckCPoint:=(ai_cpoint_d<notset)
        else
          if(ai_cpoint_d<aiu_alarm_d)and(ai_cpoint_d<base_rr)then ai_CheckCPoint:=true;
     end
     else
       if(ai_cpoint_d<notset)then ai_CheckCPoint:=true;
end;

function ai_CheckKotH(pu:PTUnit):boolean;
begin
   ai_CheckKotH:=false;
   if(g_mode=gm_koth)then
    with g_cpoints[1] do
     if(cpcapturer>0)and(cptimer>0)then
      with pu^ do
      begin
         uo_x:=ai_cpoint_x;
         uo_y:=ai_cpoint_y;
         ai_try_teleport(pu,nil);
         ai_CheckKotH:=true;
      end;
end;

procedure ai_unit_target(pu:PTUnit;smartmicro:boolean);
var d,
commander_d :integer;
commander_u,
tu          :PTUnit;
function _AttackWithHealWeapon:boolean;
begin
   _AttackWithHealWeapon:=false;
   with pu^ do
    with uid^ do
     if(a_rld>0)and(a_weap_cl<=MaxUnitWeapons)then
      if(_a_weap[a_weap_cl].aw_type=wpt_heal)then _AttackWithHealWeapon:=true;
end;
begin
   pu^.uo_tar:=0;

   if(pu^.ukfly)then
   begin
      commander_u:=ai_fly_commander_u;
      commander_d:=ai_fly_commander_d;
      if(ai_grd_commander_u<>nil)then
       if((pu^.aiu_alarm_d<notset)and(ai_grd_commander_u^.pfzone=ai_alarm_zone))
       or(pu^.aiu_alarm_d=notset)then
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

   // base
   with pu^  do
   with uid^ do
   begin
      if(group=aio_busy)then group:=aio_home;

      if(_RoyalBattleOut(x,y,srange))then
      begin
         ai_set_uo(pu,0,map_hmw,map_hmw,0,nil);
         exit;
      end
      else
        if(aiu_alarm_d<base_ir)then
        begin
           ai_set_uo(pu,aiu_alarm_d,aiu_alarm_x,aiu_alarm_y,-srange,nil);
           if(apcm>0)then
             case _attack of
atm_bunker     : ai_apc(pu,smartmicro);
             else  ai_flytransport(pu,smartmicro);
             end;

           if(smartmicro)then
            case uidi of
UID_Antiaircrafter,
UID_ZAntiaircrafter : if(ai_enemy_d<notset)then
                       if(not ai_enemy_u^.ukfly)then ai_outfromenemy(pu,srange);
UID_Pain,
UID_ArchVile        : ai_outfromenemy(pu,base_r);
            end;
        end
        else
          if(unum=player^.ai_scout_u_cur)and(player^.ucl_l[false]>scout_minarmy)then
          begin
             if(group<>aio_scout)then
              if(aiu_attack_timer<0)
              then group:=aio_scout
              else
                if(aiu_attack_timer=0)then aiu_attack_timer:=max2(1,player^.ai_attack_pause div 2);

             if(group<>aio_scout)
             then ai_BaseIdle(pu,ai_unit_base_idle_r)
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

             if((ai_abase_d<aiu_alarm_d)and(group=aio_attack))
             or((ai_abase_d<notset     )and(group=aio_home  ))then
             begin
                ai_set_uo(pu,ai_abase_d,0,0,-base_r,ai_abase_u);

                if(not ukfly)then
                  if(ai_abase_d>base_4r)or(pfzone<>ai_abase_u^.pfzone)
                  then ai_try_teleport(pu,ai_abase_u);
             end
             else
               if((cycle_order<4)or(player^.ucl_l[false]<10))and(ai_CheckCPoint(pu,false))then
               begin
                  uo_x:=ai_cpoint_x;
                  uo_y:=ai_cpoint_y;
                  group:=aio_busy;
               end
               else
               begin
                  if(group=aio_home)then
                    with player^ do
                      if(ai_armyaround_own>ai_attack_limit)
                      or(ucl_l[false]>=ai_max_blimit) //uprodl
                      or(armylimit>=ai_limit_border)  //uprodl
                      or(ucl_c[true]<=0)then
                      begin
                         group:=aio_attack;
                         if(pu=commander_u)then aiu_attack_timer:=player^.ai_attack_pause;
                      end
                      else ai_BaseIdle(pu,ai_unit_base_idle_r);

                  if(group=aio_attack)then
                    if(commander_u=nil)
                    then ai_BaseIdle(pu,ai_unit_base_idle_r)
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
                        then ai_BaseIdle(pu,ai_unit_base_idle_r)
                        else
                          if(aiu_alarm_d<notset)then
                          begin
                             ai_set_uo(pu,aiu_alarm_d,aiu_alarm_x,aiu_alarm_y,0,nil);
                             if(not ukfly)then
                              if(pfzone<>ai_alarm_zone)or((ai_alarm_d>base_6r)and(ai_armyaround_own<=30))
                              then ai_try_teleport(pu,nil);
                          end
                          else ai_default_idle(pu);
              end;
          end;


      if(not _ukbuilding)and(_ability<>uab_Advance)then
       if(ai_uadv_u<>nil)and(ai_uadv_d<base_ir)and(ai_uadv_d<aiu_alarm_d)then
        if(cf(@player^.ai_flags,@aif_army_advance))and(buff[ub_advanced]<=0)then
        begin
           if(group<>aio_attack)then group:=aio_busy;
           ai_set_uo(pu,ai_uadv_d,0,0,0,ai_uadv_u);
           d:=ai_uadv_d-(_r+ai_uadv_u^.uid^._r-aw_dmelee);
           if(d<=0)
           then uo_tar:=ai_uadv_u^.unum;
           exit;
        end;

      if(smartmicro)then
       case uidi of
UID_Scout : if(buff[ub_advanced]>0)then
             if(_AttackWithHealWeapon)then
             begin
                group:=aio_busy;
                exit;
             end
             else
               if(ai_mrepair_d<base_rr)then
               begin
                  ai_set_uo(pu,ai_mrepair_d,0,0,0,ai_mrepair_u);
                  group:=aio_busy;
                  exit;
               end;
UID_Medic : if(_AttackWithHealWeapon)then
            begin
               group:=aio_busy;
               exit;
            end
            else
              if(ai_urepair_d<base_rr)then
              begin
                 ai_set_uo(pu,ai_urepair_d,0,0,0,ai_urepair_u);
                 group:=aio_busy;
                 exit;
              end;
       end;


      if(ai_inapc_d<notset)then
       if((ai_inapc_d<ai_abase_d)and(apcc>0))or(apcc<=0)then
        if(ai_inapc_d<base_ir)or( ukfly and ((apcc<=0)or(group<>aio_attack)) )then  //or(ai_inapc_d<base_ir)
        begin
           group:=aio_busy;
           ai_set_uo(pu,ai_inapc_d,0,0,0,ai_inapc_u);
           d:=ai_inapc_d-(_r+ai_inapc_u^.uid^._r-aw_dmelee);
           if(d<=0)
           then uo_tar:=ai_inapc_u^.unum;
           exit;
        end;

      if(ai_CheckCPoint(pu,true))then
      begin
         uo_x:=ai_cpoint_x;
         uo_y:=ai_cpoint_y;
      end;
   end;
end;

procedure ai_SaveMain_CC(pu:PTUnit);
begin
   with pu^ do
     if(ukfly)then
     begin
        if(_RoyalBattleOut(x,y,base_rr))
        then ai_set_uo(pu,0,map_hmw,map_hmw,0,nil)
        else
          if(ai_enemy_d<=base_rr)
          then ai_outfrom(pu,ai_enemy_u^.x,ai_enemy_u^.y)
          else
            if(g_mode=gm_royale)and(ai_basep_builders>ai_base_save_border)and(unum=player^.uid_x[uidi])then
            begin
               ai_set_uo(pu,0,map_hmw,map_hmw,0,nil);
               if(point_dist_int(x,y,map_hmw,map_hmw)<min2(g_royal_r div 7,base_rr))
               then _unit_action(pu);
            end
            else
            begin
               ai_BaseIdle(pu,srange);
               if(ai_base_d<base_r)or(ai_base_d=notset)
               then _unit_action(pu);
            end;
     end
     else
       if(_RoyalBattleOut(x,y,base_r))
       or((g_mode=gm_royale)and(unum=player^.uid_x[uidi])and(ai_basep_builders>6))
       then _unit_action(pu)
       else
         if(aiu_armyaround_enemy>aiu_armyaround_ally)and(buff[ub_damaged]>0)then
          if(hits<uid^._hmhits)or(aiu_armyaround_enemy>15)then _unit_action(pu);
end;
procedure ai_SaveMain_HK(pu:PTUnit);
var w:integer;
begin
   with pu^ do
   begin
      if(g_mode=gm_royale)then
       if((ai_basep_builders>ai_base_save_border)and(unum=player^.uid_x[uidi]))
       or(_RoyalBattleOut(x,y,base_rr))then
       begin
          w:=min2(g_royal_r div 4,base_rr);
          if(_unit_ability_hkteleport(pu,map_hmw+_random(w),map_hmw+_random(w)))then exit;
       end;

      if((aiu_alarm_d<base_rr)and(ai_basep_builders<=ai_base_save_border)and(hits<uid^._hmhits))then
       if(g_mode=gm_royale)then
       begin
          w:=g_royal_r div 2;
          _unit_ability_hkteleport(pu,map_hmw+_random(w),map_hmw+_random(w));
       end
       else _unit_ability_hkteleport(pu,random(map_mw),random(map_mw));
   end;
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
      ai_unit_timer(@aiu_alarm_timer);
      ai_unit_timer(@aiu_attack_timer);

      uo_id :=ua_amove;
      uo_tar:=0;

      // nearest alarm
      if(ai_alarm_d<notset)then
      begin
         aiu_alarm_d  :=ai_alarm_d;
         aiu_alarm_x  :=ai_alarm_x;
         aiu_alarm_y  :=ai_alarm_y;
      end;

      //if(sel)then writeln('2 ',aiu_alarm_d);

      {if(playeri=HPlayer)and(sel)then
      begin
         //if(aiu_alarm_x      >-1)then UnitsInfoAddLine(x,y,aiu_alarm_x,aiu_alarm_y,c_red);
         //if(ai_alarm_invis_x>-1)then UnitsInfoAddLine(x,y,ai_alarm_invis_x+1,ai_alarm_invis_y+1,c_aqua);

         //if(ai_uadv_u<>nil)then UnitsInfoAddLine(x,y,ai_uadv_u^.x,ai_uadv_u^.y,c_red);
      end; }

      if(_ukbuilding)then ai_buildings(pu);

      if(hits<=0)or(not bld)then exit;

      case _ability of
uab_hell_unit_adv: if(cf(@player^.ai_flags,@aif_army_advance))then
                    if(ai_hadv_u<>nil)then uo_tar:=ai_hadv_u^.unum;
uab_teleport     : if(ai_teleporter_beacon_u<>nil)
                   then uo_tar:=ai_teleporter_beacon_u^.unum
                   else uo_tar:=0;
      end;

      // abilities
      if(cf(@player^.ai_flags,@aif_ability_other))then
       case _ability of
uab_htowertele   : if(aiu_alarm_d<notset)and(a_rld<=0)and(ai_alarm_zone=pfzone)then _unit_ability_htteleport(pu,aiu_alarm_x,aiu_alarm_y);
uab_hinvuln      : if(ai_invuln_tar_u<>nil)then _unit_ability_hinvuln(pu,ai_invuln_tar_u^.unum);
uab_uac_rstrike  : if(ai_strike_tar_u<>nil)then _unit_ability_umstrike(pu,ai_strike_tar_u^.x,ai_strike_tar_u^.y);
uab_buildturret  : if(aiu_armyaround_ally>ul10)and(ai_enemy_u<>nil)then
                    if(ai_enemy_d<srange)and(ai_enemy_u^.uid^._ukbuilding)and(ai_enemy_u^.speed=0)and(buff[ub_damaged]<=0)then
                     if(_unit_action(pu))then exit;
{uab_advance      : case uidi of
      UID_ZMajor,
      UID_Major         : if(a_rld<=0)then
                           if(ai_enemy_u<>nil)and(ai_enemy_d<srange)then
                           begin
                              if(ukfly<>ai_enemy_u^.ukfly)then _unit_action(pu);
                           end
                           else
                             if(not ukfly)then _unit_action(pu);

                   end;  }
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
uab_hell_vision  : if(player^.ai_detection_pause=0)then
                    if(ai_need_heye_u<>nil)then
                     if(_ability_hell_vision(ai_need_heye_u,pu))then player^.ai_detection_pause:=fr_fps;
       end;

      if(speed<=0)or(_ukbuilding)then exit;

      ai_unit_target(pu,cf(@player^.ai_flags,@aif_army_smart_micro));

      if(ai_enemy_d>srange)
      then ai_set_alarm(player,x,y,0,srange,false,0)
      else ai_set_alarm(player,ai_enemy_u^.x,ai_enemy_u^.y,aiu_armyaround_enemy,srange,ai_enemy_u^.uid^._ukbuilding,ai_enemy_u^.pfzone);
   end;
end;



