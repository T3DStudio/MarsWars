
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

generators_energy   = 2500;
ai_tower_life_time  = fr_fps*60;
scout_minarmy       = MinUnitLimit*3;

aio_home   = 0;
aio_scout  = 1;
aio_busy   = 2;
aio_attack = 3;

nodist     = 32000;

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
ai_teleporter_d,
ai_armyaround_own,
ai_teleports_near,

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
     end
     else ai_set_alarm(@_players[p],map_psx[i],map_psy[i],1,base_r,true,pf_get_area(map_psx[i],map_psy[i]));
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
      2  : SetBaseOpt(600  ,1   ,2     ,0    ,0    ,0    ,0    ,0      ,0       ,3    ,3     ,15    ,fr_fps*150,20            ,0  ,[]);
      3  : SetBaseOpt(1200 ,2   ,3     ,1    ,0    ,0    ,0    ,0      ,0       ,6    ,6     ,30    ,fr_fps*120,30            ,1  ,[]);
      4  : SetBaseOpt(2500 ,5   ,4     ,1    ,1    ,0    ,1    ,0      ,1       ,10   ,10    ,60    ,fr_fps*90 ,40            ,2  ,[]);
      5  : SetBaseOpt(4500 ,8   ,8     ,2    ,2    ,1    ,3    ,1      ,4       ,10   ,14    ,90    ,fr_fps*60 ,50            ,3  ,[UID_Pain,UID_ArchVile]);
      6  : SetBaseOpt(5000 ,12  ,14    ,6    ,5    ,1    ,4    ,1      ,4       ,2    ,14    ,120   ,1         ,MaxPlayerUnits,4  ,[UID_Pain,UID_ArchVile,UID_Medic,UID_Engineer,UID_BFG,UID_ZBFG]);
      else SetBaseOpt(6000 ,16  ,20    ,6    ,5    ,1    ,4    ,1      ,4       ,2    ,14    ,120   ,1         ,MaxPlayerUnits,5  ,[UID_Pain,UID_ArchVile,UID_Medic,UID_Engineer,UID_BFG,UID_ZBFG]);
      end;
   end;
   ai_make_scirmish_start_alarms(p);
end;

function ai_HighTarget(player:PTPlayer;tu:PTUnit):boolean;
begin
   ai_HighTarget:=false;
   if(player^.state=ps_comp)then
    ai_HighTarget:=tu^.uidi in player^.ai_hptargets;
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
      aiu_alarm_d    :=nodist;
      aiu_alarm_x    :=-1;
      aiu_alarm_y    :=-1;
      aiu_need_detect:=nodist;
      aiu_armyaround_ally :=0;
      aiu_armyaround_enemy:=0;
   end;
   ai_armyaround_own:=0;

   // alarm
   ai_alarm_zone     :=0;
   ai_alarm_d        :=nodist;
   ai_alarm_x        :=-1;
   ai_alarm_y        :=-1;
   ai_alarm_unit     :=nil;

   // enemy
   ai_enemy_u        :=nil;
   ai_enemy_d        :=nodist;
   ai_enemy_air_u    :=nil;
   ai_enemy_air_d    :=nodist;
   ai_enemy_grd_u    :=nil;
   ai_enemy_grd_d    :=nodist;
   ai_enemy_inv_u    :=nil;
   ai_enemy_inv_d    :=nodist;

   // cpoints
   ai_cpoint_x       :=0;
   ai_cpoint_y       :=0;
   ai_cpoint_d       :=nodist;
   ai_cpoint_zone    :=0;


   // get default alarm point
   with pu^ do
   with player^ do
    for i:=0 to MaxPlayers do
     with ai_alarms[i] do
      if(aia_enemy_count>0)then
       if(ukfly)or(aia_zone=pfzone)then ai_set_nearest_alarm(nil,aia_x,aia_y,point_dist_rint(aia_x,aia_y,x,y),aia_zone);

   with pu^ do
    for i:=1 to MaxCPoints do
     with g_cpoints[i] do
      if(cpcapturer>0)then
      begin
         d:=point_dist_rint(cpx,cpy,x,y);
         if(_players[cpowner].team=player^.team)then
           if(d>cpcapturer)or(cpunitst_pstate[player^.team]>10)then continue;

         if(d<ai_cpoint_d)then
         begin
            ai_cpoint_x   :=cpx;
            ai_cpoint_y   :=cpy;
            ai_cpoint_d   :=d;
            ai_cpoint_zone:=cpzone;
         end;

         ai_set_nearest_alarm(nil,cpx,cpy,d,cpzone);
      end;

   // commander
   ai_grd_commander_u:=nil;
   ai_fly_commander_u:=nil;
   ai_grd_commander_d:=nodist;
   ai_fly_commander_d:=nodist;

   // nearest own building
   ai_base_d        := nodist;
   ai_base_u        := nil;

   // nearest own building with alarm
   ai_abase_d       := nodist;
   ai_abase_u       := nil;

   // transport target
   ai_inapc_d       := nodist;
   ai_inapc_u       := nil;

   // adv
   ai_uadv_d        := nodist;
   ai_uadv_u        := nil;
   ai_hadv_u        := nil;

   // nearest teleporter
   ai_teleporter_d  := nodist;
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
   ai_need_heye_d   := nodist;
   ai_need_heye_u   := nil;

   // builds data
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
               if(tu^.uid^._ukbuilding)and(tu^.aiu_alarm_d<base_ir)then _setNearestPU(@ai_abase_u,@ai_abase_d,ud);
               if(tu^.uid^._attack>0)then
               begin
                  if(ud<srange)and(tu^.speed<=0)then //then
                   if(tu^.uidi=aiucl_twr_air1[race])
                   or(tu^.uidi=aiucl_twr_air2[race])then
                   begin
                      ai_towers_near_air+=1;
                      ai_towers_near    +=1;
                   end
                   else
                     if(tu^.uidi=aiucl_twr_ground1[race])
                     or(tu^.uidi=aiucl_twr_ground2[race])then
                     begin
                        ai_towers_near_ground+=1;
                        ai_towers_near       +=1;
                     end;

                  if(ud<base_ir)and(not tu^.uid^._ukbuilding)then aiu_armyaround_ally+=tu^.uid^._limituse;
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
            end
            else
             if(_uvision(team,tu,true))then
             begin
                ai_set_nearest_alarm(tu,0,0,ud,0);

                _setNearestPU(@ai_enemy_u,@ai_enemy_d,ud);
                if(tu^.ukfly)
                then _setNearestPU(@ai_enemy_air_u,@ai_enemy_air_d,ud)
                else _setNearestPU(@ai_enemy_grd_u,@ai_enemy_grd_d,ud);
                if(tu^.buff[ub_invis]>0)and(tu^.vsni[team]<=0)then
                begin
                   _setNearestPU(@ai_enemy_inv_u,@ai_enemy_inv_d,ud);
                   if(ud<srange)then aiu_need_detect:=ud-srange-hits;
                end;
                if(ud<base_ir)then
                 if(tu^.uid^._attack>0)then
                  aiu_armyaround_enemy+=tu^.uid^._limituse;

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

                  if(ud<ai_inapc_d)and(tu^.aiu_alarm_d>base_ir)and(tu^.order<>aio_busy)then
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

               if(ud<ai_base_d)and(tu^.uid^._ukbuilding)and(tu^.speed<=0)then _setNearestPU(@ai_base_u,@ai_base_d,ud);
            end;
         end;


         if(player=tu^.player)then
         begin
            if(uid=tu^.uid)and(not bld)then ai_inprogress_uid+=1;

            case tu^.uidi of
            UID_HSymbol   : if(a_units[UID_HASymbol   ]>0)then ai_enrg_cur+=_uids[UID_HASymbol   ]._genergy else ai_enrg_cur+=tu^.uid^._genergy;
            UID_UGenerator: if(a_units[UID_UAGenerator]>0)then ai_enrg_cur+=_uids[UID_UAGenerator]._genergy else ai_enrg_cur+=tu^.uid^._genergy;
            else            ai_enrg_cur+=tu^.uid^._genergy;
            end;

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
bx,by,l : integer;
procedure SetBT(buid:byte);
var _c:cardinal;
begin
  if(bt=0)then
  begin
     _c:=_uid_conditionals(pu^.player,buid);
     if(_c=0)or(_c=ureq_energy)then bt:=buid;
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
end;
procedure BuildEnergy(x:integer); // Energy
begin
   with pu^.player^ do
    if(ai_enrg_cur<x)and(ai_enrg_cur<ai_max_energy)
    then SetBTA(aiucl_generator[race],0);
end;
procedure BuildUProd(x:integer);  // Barracks
begin
    with pu^.player^ do
     if(ai_unitp_cur<x)and(ai_unitp_cur<ai_max_unitps)then
      if(ai_tech1_cur<=0)or(ai_unitp_cur_na=0)or(ai_unitp_cur<6)then
       SetBTA(aiucl_barrack0[race],aiucl_barrack1[race]);
end;
procedure BuildSmith(x:integer);  // Smiths
begin
    with pu^.player^ do
     if(ai_upgrp_cur<x)and(ai_upgrp_cur<ai_max_upgrps)then
      if(ai_tech1_cur<=0)or(ai_upgrp_cur_na=0)or(ai_upgrp_cur<2)then
       SetBTA(aiucl_smith[race],0);
end;
procedure BuildTech0(x:integer);  // Tech0  TechCenter, HellMonastery
begin
    with pu^.player^ do
     if(ai_tech0_cur<x)and(ai_tech0_cur<ai_max_tech0)
     then SetBTA(aiucl_tech0[race],0);
end;
procedure BuildTech1(x:integer);  // Tech1
begin
    with pu^.player^ do
     if(ai_tech1_cur<x)and(ai_tech1_cur<ai_max_tech1)
     then SetBTA(aiucl_tech1[race],0);
end;
procedure BuildSpec0(x:integer);  // Radar,  Heye Nest
begin
    with pu^.player^ do
     if(ai_spec0_cur<x)and(ai_spec0_cur<ai_max_spec0)
     then SetBTA(aiucl_spec0[race],0);
end;
procedure BuildSpec1(x:integer);  // RStation, Altar
begin
    with pu^.player^ do
     if(ai_spec1_cur<x)and(ai_spec1_cur<ai_max_spec1)
     then SetBTA(aiucl_spec1[race],0);
end;
procedure BuildSpec2(x:integer);  // Teleport
begin
    with pu^.player^ do
     if(ai_spec2_cur<x)and(ai_spec2_cur<ai_max_spec2)
     then SetBTA(aiucl_spec2[race],0);
end;
procedure BuildTower(x,t:integer);  // Towers
begin
    with pu^.player^ do
     if(ai_towers_near<x)and(ai_towers_near<ai_max_towers)then
      if(t>0)
      then SetBTA(aiucl_twr_air1[race],aiucl_twr_air2[race])
      else
       if(t<=0)
       then SetBTA(aiucl_twr_ground1[race],aiucl_twr_ground2[race]);
   if(bt>0)then
   with pu^ do
   begin
      if(ai_towers_needx=-1)then
       if(aiu_alarm_d<nodist)then
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

   with pu^     do
   with uid^    do
   with player^ do
   if(build_cd<=0)then
   begin
      if(false)then
      begin
         if(ai_towers_need>ai_min_towers)then
         BuildTower (ai_towers_need,ai_towers_need_type);

         // fixed opening
         BuildEnergy(300 );
         BuildUProd (1   );
         BuildEnergy(800 );
         BuildTower (2   ,ai_towers_need_type);
         BuildSmith (1   );
         BuildEnergy(1100);
         BuildSpec0 (1   );
         BuildMain  (2   );
         BuildUProd (2   );
         BuildEnergy(1300);
         BuildTower (ai_towers_need,ai_towers_need_type);
         BuildSpec2 (1   );
         BuildEnergy(1400);
         BuildUProd (3   );
         BuildEnergy(1600);
         BuildMain  (3   );
         BuildEnergy(1800);
         BuildMain  (4   );
         BuildEnergy(2000);
         BuildTech0 (1   );
         BuildTech1 (1   );
         BuildSpec1 (1   );

         //if(sel)then writeln(bt);

         // common
         BuildEnergy(generators_energy);
         BuildSmith(ai_upgrp_need);
         BuildTech0(ai_tech0_need);
         BuildSpec0(ai_spec0_need);
         BuildSpec1(ai_max_spec1 );
         BuildSpec2(ai_max_spec2 );
         BuildUProd(ai_unitp_need);
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

      if(sel)then writeln(bt,' ',ai_unitp_need);

      if(bt=0)then exit;

      if(ddir<=0)
      then ddir:=random(360);
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
r_hell: case random(19) of
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
16: ut:=UID_ZBomber;
17: ut:=UID_ZMajor;
18: ut:=UID_ZBFG;
        end;
r_uac : case random(13) of
0 : ut:=UID_Medic;
1 : ut:=UID_Engineer;
2 : ut:=UID_Sergant;
3 : ut:=UID_Commando;
4 : ut:=UID_Bomber;
5 : ut:=UID_Major;
6 : ut:=UID_BFG;
7 : ut:=UID_APC;
8 : ut:=UID_FAPC;
9 : ut:=UID_UACBot;
10: ut:=UID_Terminator;
11: ut:=UID_Tank;
12: ut:=UID_Flyer;
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
r_hell: if(not _su(UID_LostSoul,3))
        then _su(UID_Cacodemon,3);
r_uac : _su(UID_Commando,3);
   end;
end;
begin
   ai_UnitProduction:=false;
   with pu^     do
   with player^ do
   if((ucl_l[false]+uprodl)<ai_max_blimit)then
   begin
      case uclass of
uprod_smart: begin
                if(not ai_UnitProduction(pu,uprod_base))then
                 if(aiu_alarm_d=nodist)
                 then ai_UnitProduction:=ai_UnitProduction(pu,uprod_any)
                 else
                   if(ai_alarm_zone<>pfzone)and
                   ( ((race=r_hell)and(uid_e[UID_FAPC]<=0))
                   or((race=r_uac )and(random(ai_teleports_near+2)>0) ))
                   then ai_UnitProduction:=ai_UnitProduction(pu,uprod_air)
                   else ai_UnitProduction:=ai_UnitProduction(pu,uprod_any);
                exit;
             end;
uprod_any  : pick_any;
uprod_base : pick_base;
uprod_air  : pick_air;
      end;

      up_n:=uid_e[ut]+uprodu[ut];

      case ut of
UID_Mastermind,
UID_Cyberdemon   : up_m:=ai_skill-2-(uid_e[UID_Mastermind]+uprodu[UID_Mastermind]
                                    +uid_e[UID_Cyberdemon]+uprodu[UID_Cyberdemon]);
UID_APC,
UID_FAPC         : up_m:=ai_skill+2;
UID_Pain         : up_m:=ai_skill+2;
      else up_m:=10000;
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
begin
   if(upid>0)then
    with pu^     do
     with player^ do
      if(upgr[upid]<lvl)and(upgr[upid]<ai_max_upgrlvl)then _unit_supgrade(pu,upid);
end;
begin
   with pu^     do
   with player^ do
   begin
      case race of
r_hell: begin
        MakeUpgr(upgr_hell_mainr ,1);
        MakeUpgr(upgr_hell_hktele,1);
        MakeUpgr(upgr_hell_mainr ,2);
        MakeUpgr(upgr_hell_heye  ,1);
        MakeUpgr(upgr_hell_9bld  ,1);
        MakeUpgr(upgr_hell_heye  ,3);
        MakeUpgr(upgr_hell_6bld  ,1);

        _unit_supgrade(pu,random(30));
        end;
r_uac : begin
        MakeUpgr(upgr_uac_mainr  ,1);
        MakeUpgr(upgr_uac_mainm  ,1);
        MakeUpgr(upgr_uac_mainr  ,2);
        MakeUpgr(upgr_uac_9bld   ,1);
        MakeUpgr(upgr_uac_6bld   ,1);
        MakeUpgr(upgr_uac_srange ,1);

        _unit_supgrade(pu,30+random(30));
        end;
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
UID_UAGenerator: if(cenergy>_genergy)and(menergy>generators_energy)then exit;
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
UID_HTower,
UID_HTotem,
UID_UGTurret,
UID_UATurret    : if(ai_towers_cur_active>ai_min_towers)then
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
          if(buff[ub_advanced]<=0)then exit;
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
      ai_towers_cur    :=uid_e[aiucl_twr_air1   [race]]
                        +uid_e[aiucl_twr_air2   [race]]
                        +uid_e[aiucl_twr_ground1[race]]
                        +uid_e[aiucl_twr_ground2[race]];
      ai_towers_cur_active:=
                         uid_eb[aiucl_twr_air1   [race]]
                        +uid_eb[aiucl_twr_air2   [race]]
                        +uid_eb[aiucl_twr_ground1[race]]
                        +uid_eb[aiucl_twr_ground2[race]];

      if(_N(@ai_basep_need ,ai_max_mains ))then ai_basep_need :=ai_max_mains;//mm3(1,ai_basep_builders+1           ,ai_max_mains );
      if(_N(@ai_unitp_need ,ai_max_unitps))then ai_unitp_need :=mm3(1,ai_basep_builders+1    ,ai_max_unitps);
      if(_N(@ai_upgrp_need ,ai_max_upgrps))then ai_upgrp_need :=mm3(1,round(ai_unitp_cur/2.5),ai_max_upgrps);
      if(_N(@ai_tech0_need ,ai_max_tech0 ))then ai_tech0_need :=mm3(0,ai_unitp_cur div 3     ,ai_max_tech0 );
      if(_N(@ai_spec0_need ,ai_max_spec0 ))then ai_spec0_need :=mm3(0,ai_unitp_cur div 3     ,ai_max_spec0 );
      if(_N(@ai_towers_need,ai_max_towers))then
       if(ai_enemy_d<base_3r) then
       begin
          //ai_enemy_d
          ai_towers_need :=mm3(0,(aiu_armyaround_enemy-aiu_armyaround_ally+MinUnitLimit) div MinUnitLimit,ai_max_towers);
          if(sel)then writeln(aiu_armyaround_enemy,' ',aiu_armyaround_ally,' ',ai_towers_need);
          ai_towers_needx:=aiu_alarm_x;
          ai_towers_needy:=aiu_alarm_y;
          ai_towers_need_type:=0;
          if(ai_enemy_grd_d<base_rr)then ai_towers_need_type:=-1;
          if(ai_enemy_air_d<base_rr)then ai_towers_need_type:= 1;
       end
       else ai_towers_need:=ai_min_towers;

      if(ai_buildings_need_suicide(pu))then
      begin
         _unit_kill(pu,false,true,true);
         exit;
      end;

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

         if(aiu_alarm_d<nodist)and(speed<=0)then
         begin
            uo_x:=aiu_alarm_x;
            uo_y:=aiu_alarm_y;
         end;
      end;
      if(_issmith  )then
       if(cenergy<0)
       then _unit_cupgrade(pu,255)
       else ai_UpgrProduction(pu);
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
   begin
      uo_x:=x-(ax-x)*10;
      uo_y:=y-(ay-y)*10;
   end;
end;
procedure ai_outfromenemy(pu:PTUnit;ud:integer);
begin
   if(ai_enemy_u<>nil)and(ai_enemy_d<ud)then ai_outfrom(pu,ai_enemy_u^.x,ai_enemy_u^.y);
 end;

procedure ai_flytransport(pu:PTUnit);
begin
   if(ai_enemy_u<>nil)then
    with pu^  do
     if(apcc=0)or (pf_isobstacle_zone(ai_enemy_u^.pfzone))
     then ai_outfrom(pu,ai_enemy_u^.x,ai_enemy_u^.y)
     else
       if(ai_enemy_d<200)then uo_id:=ua_unload;
end;
procedure ai_apc(pu:PTUnit);
begin
   if(ai_enemy_u<>nil)then
    with pu^  do
     if(apcc=0)
     or(ai_enemy_d<150)
     then ai_outfrom(pu,ai_enemy_u^.x,ai_enemy_u^.y);
end;

procedure ai_set_uo(pu:PTUnit;ox,oy,ow:integer;tarpu:PTUnit);
begin
   with pu^  do
   begin
      if(tarpu<>nil)then
      begin
         ox:=tarpu^.x;
         oy:=tarpu^.y;
      end;
      if(ow=0)then
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
    if(point_dist_rint(x,y,uo_x,uo_y)<srange)or(not ukfly and (pfzone<>pf_get_area(uo_x,uo_y)))
    then ai_set_uo(pu,random(map_mw),random(map_mw),0,nil);
end;
procedure ai_BaseIdle(pu:PTUnit);
begin
   if(ai_base_d<nodist)then
     if(ai_base_d>base_r)
     then ai_set_uo(pu,0,0,0     ,ai_base_u)
     else ai_set_uo(pu,0,0,base_r,ai_base_u)
   else ai_default_idle(pu);
end;

procedure ai_try_teleport(pu,target:PTUnit);
var tt:integer;
begin
   if(ai_teleporter_u<>nil)then
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

procedure ai_GoToUnit(pu,tu:PTUnit;ud,dforward:integer);
begin
   if(ud>dforward)
   then ai_set_uo(pu,0,0,0          ,tu)
   else ai_set_uo(pu,0,0,-pu^.srange,tu);
end;

procedure ai_unit_target(pu:PTUnit);
var d,
commander_d :integer;
commander_u :PTUnit;
begin
   pu^.uo_tar:=0;

   if(pu^.ukfly)then
   begin
      commander_u:=ai_fly_commander_u;
      commander_d:=ai_fly_commander_d;
      if(ai_grd_commander_u<>nil)then
       if((pu^.aiu_alarm_d<nodist)and(ai_grd_commander_u^.pfzone<>ai_alarm_zone))
       or(pu^.aiu_alarm_d=nodist)then
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
      if(order=aio_busy)then order:=aio_home;

      if(aiu_alarm_d<base_ir)then
      begin
         ai_set_uo(pu,aiu_alarm_x,aiu_alarm_y,-100,nil);
         if(apcm>0)then
           case _attack of
atm_bunker : ai_apc(pu);
           else  ai_flytransport(pu);
           end;
      end
      else
        if(unum=player^.ai_scout_u_cur)and(player^.ucl_l[false]>scout_minarmy)then
        begin
           if(order<>aio_scout)then
            if(aiu_attack_timer<0)
            then order:=aio_scout
            else
              if(aiu_attack_timer=0)then aiu_attack_timer:=max2(1,player^.ai_attack_pause div 2);

           if(order<>aio_scout)
           then ai_BaseIdle(pu)
           else
            if(aiu_alarm_d<nodist)
            then ai_set_uo(pu,aiu_alarm_x,aiu_alarm_y,0,nil)
            else ai_default_idle(pu);
        end
        else
        begin
           if(order=aio_scout)then
           begin
              order:=aio_home;
              aiu_attack_timer:=0;
           end;

           if((ai_abase_d<aiu_alarm_d)and(order=aio_attack))
           or((ai_abase_d<nodist     )and(order=aio_home  ))then
           begin
              if(ai_abase_d>base_r)
              then ai_set_uo(pu,0,0, 0     ,ai_abase_u)
              else ai_set_uo(pu,0,0,-base_r,ai_abase_u);

              if(not ukfly)then
                if(ai_abase_d>base_4r)or(pfzone<>ai_abase_u^.pfzone)
                then ai_try_teleport(pu,ai_abase_u);
           end
           else
           begin
              if(order=aio_home)then
                with player^ do
                  if(ai_armyaround_own>ai_attack_limit)
                  or((ucl_l[false]+uprodl)>=ai_max_blimit)
                  or((armylimit+uprodl)>=ai_limit_border)
                  or(ucl_c[true]<=0)then
                  begin
                     order:=aio_attack;
                     if(pu=commander_u)then aiu_attack_timer:=player^.ai_attack_pause;
                  end
                  else ai_BaseIdle(pu);

              if(order=aio_attack)then
                if(commander_u=nil)then
                begin
                   if(ai_base_d<nodist)then
                     if(ai_base_d>base_r)
                     then ai_set_uo(pu,0,0,0     ,ai_base_u)
                     else ai_set_uo(pu,0,0,base_r,ai_base_u)
                   else ai_default_idle(pu);
                   ai_try_teleport(pu,nil);
                end
                else
                  if(pu<>commander_u)then
                  begin
                     if(aiu_attack_timer<>0)and(aiu_attack_timer<commander_u^.aiu_attack_timer)
                     then commander_u^.aiu_attack_timer:=aiu_attack_timer;
                     aiu_attack_timer:=0;

                     if(commander_d>srange)
                     then ai_set_uo(pu,0,0,0      ,commander_u)
                     else ai_set_uo(pu,0,0,-srange,commander_u);
                     if(sel)then writeln('no commander');
                  end
                  else
                    if(aiu_attack_timer<>0)
                    then ai_BaseIdle(pu)
                    else
                      if(aiu_alarm_d<nodist)then
                      begin
                         ai_set_uo(pu,aiu_alarm_x,aiu_alarm_y,0,nil);
                         if(not ukfly)then
                          if(pfzone<>ai_alarm_zone)or(ai_alarm_d>base_4r)or((ai_teleporter_d<ai_alarm_d)and(ai_teleporter_d<base_rr))
                          then ai_try_teleport(pu,nil);
                      end
                      else ai_default_idle(pu);
           end;
        end;

      if(ai_uadv_u<>nil)and(ai_uadv_d<base_ir)and(ai_uadv_d<aiu_alarm_d)then
      begin
         if(not _ukbuilding)and(buff[ub_advanced]<=0)and(_ability<>uab_Advance)then
         begin
            if(order<>aio_attack)then order:=aio_busy;
            ai_set_uo(pu,0,0,0,ai_uadv_u);
            d:=ai_uadv_d-(_r+ai_uadv_u^.uid^._r-aw_dmelee);
            if(d<=0)
            then uo_tar:=ai_uadv_u^.unum;
            exit;
         end;
      end;

     // if(sel)then writeln(ai_inapc_d);

      if(ai_inapc_d<nodist)then
       if((ai_inapc_d<ai_abase_d)and(apcc>0))or(apcc<=0)then
        if(ai_inapc_d<base_ir)or(ukfly and ((apcc<=0)or(order<>aio_attack)or(ai_inapc_d<base_ir)) )then
         with pu^  do
         begin
            order:=aio_busy;
            ai_set_uo(pu,0,0,0,ai_inapc_u);
            d:=ai_inapc_d-(_r+ai_inapc_u^.uid^._r-aw_dmelee);
            if(d<=0)
            then uo_tar:=ai_inapc_u^.unum;
            exit;
         end;
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
      if(ai_alarm_d<nodist)then
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
uab_hell_unit_adv: if(ai_hadv_u<>nil)then uo_tar:=ai_hadv_u^.unum;
uab_radar        : if(player^.ai_detection_pause=0)and(ai_enemy_inv_u<>nil)then
                   begin
                      _unit_ability_uradar(pu,ai_enemy_inv_u^.x,ai_enemy_inv_u^.y);
                      player^.ai_detection_pause:=fr_fps;
                   end;
uab_htowertele   : if(aiu_alarm_d<nodist)and(a_rld<=0)and(ai_alarm_zone=pfzone)then _unit_ability_htteleport(pu,aiu_alarm_x,aiu_alarm_y);
uab_hkeeptele    : if(aiu_alarm_d<nodist)and(ai_basep_builders<5)and(hits<2000)then _unit_ability_hkteleport(pu,random(map_mw),random(map_mw));
uab_hell_vision  : if(player^.ai_detection_pause=0)then
                    if(ai_need_heye_u<>nil)then
                    begin
                       _ability_hell_vision(ai_need_heye_u,pu);
                       player^.ai_detection_pause:=fr_fps;
                    end;
uab_teleport     : if(ai_teleporter_beacon_u<>nil)
                   then uo_tar:=ai_teleporter_beacon_u^.unum
                   else uo_tar:=0;
uab_hinvuln      : if(ai_invuln_tar_u<>nil)then _unit_ability_hinvuln(pu,ai_invuln_tar_u^.unum);
uab_uac_rstrike  : if(ai_strike_tar_u<>nil)then _unit_ability_umstrike(pu,ai_strike_tar_u^.x,ai_strike_tar_u^.y);
uab_advance      : case uidi of
      UID_ZMajor,
      UID_Major         : if(a_rld<=0)then
                           if(ai_enemy_u<>nil)then
                           begin
                              if(ukfly<>ai_enemy_u^.ukfly)then _unit_action(pu);
                           end
                           else
                             if(not ukfly)then _unit_action(pu);
      UID_HCommandCenter,
      UID_UCommandCenter: if(ukfly)then
                          begin
                             ai_default_idle(pu);
                             if(ai_enemy_d<=base_ir)
                             then ai_outfrom(pu,ai_enemy_u^.x,ai_enemy_u^.y)
                             else
                               if(ai_base_d<nodist)then
                               begin
                                  if(ai_base_d<srange)
                                  then _unit_action(pu)
                                  else ai_set_uo(pu,0,0,srange,ai_base_u);
                               end
                               else
                               begin
                                  _unit_action(pu);
                                  //aiu_alarm_timer:=fr_2fps;
                               end;
                          end
                          else
                            if(aiu_armyaround_enemy>aiu_armyaround_ally)and(buff[ub_damaged]>0)then
                             if(hits<2000)or(aiu_armyaround_enemy>15)then _unit_action(pu);
                   end;
      end;
      case uidi of
UID_Pain,
UID_ArchVile   : ai_outfromenemy(pu,base_r);
      end;

      if(speed<=0)or(_ukbuilding)then exit;

      ai_unit_target(pu);

      if(ai_enemy_d>srange)
      then ai_set_alarm(player,x,y,0,srange,false,0)
      else ai_set_alarm(player,ai_enemy_u^.x,ai_enemy_u^.y,aiu_armyaround_enemy,srange,ai_enemy_u^.uid^._ukbuilding,ai_enemy_u^.pfzone);
   end;
end;



