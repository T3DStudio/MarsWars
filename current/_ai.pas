
const

aiucl_main0      : array[1..r_cnt] of byte = (UID_HKeep          ,UID_UCommandCenter);
aiucl_main1      : array[1..r_cnt] of byte = (UID_HCommandCenter ,0);
aiucl_generator  : array[1..r_cnt] of byte = (UID_HSymbol        ,UID_UGenerator    );
aiucl_barrack0   : array[1..r_cnt] of byte = (UID_HGate          ,UID_UMilitaryUnit );
aiucl_barrack1   : array[1..r_cnt] of byte = (UID_HMilitaryUnit  ,UID_UFactory      );
aiucl_smith      : array[1..r_cnt] of byte = (UID_HPools         ,UID_UWeaponFactory);
aiucl_tech0      : array[1..r_cnt] of byte = (UID_HMonastery     ,UID_UTechCenter   );
aiucl_tech1      : array[1..r_cnt] of byte = (UID_HFortress      ,UID_UNuclearPlant );
aiucl_spec0      : array[1..r_cnt] of byte = (UID_HTeleport      ,UID_URadar        );
aiucl_spec1      : array[1..r_cnt] of byte = (UID_HAltar         ,UID_URMStation    );
aiucl_spec2      : array[1..r_cnt] of byte = (UID_HEyeNest       ,0                 );
aiucl_twr_air1   : array[1..r_cnt] of byte = (UID_HTower         ,UID_UATurret      );
aiucl_twr_air2   : array[1..r_cnt] of byte = (UID_HTotem         ,UID_UATurret      );
aiucl_twr_ground1: array[1..r_cnt] of byte = (UID_HTower         ,UID_UGTurret      );
aiucl_twr_ground2: array[1..r_cnt] of byte = (UID_HTotem         ,UID_UGTurret      );

del_generators_energy = 2500;
towers_limit_border   = 300;
ai_tower_life_time    = fr_fps*60;

aia_l = 3;

aia_common = 0;
aia_ground = 1;
aia_fly    = 2;
aia_invis  = 3;

aio_home   = 0;
aio_scout  = 1;
aio_busy   = 2;
aio_attack = 3;

type TAIUnitAlarm = record
   aiau:PTUnit;
   aiax,
   aiay,
   aiad:integer;
   aiazone:word;
end;

var

ai_alarm : array[0..aia_l] of TAIUnitAlarm;

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
ai_base_u         : PTUnit;
ai_grd_commander_d,
ai_fly_commander_d,
ai_need_heye_d,
ai_uadv_d,
ai_inapc_d,
ai_abase_d,
ai_base_d,
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
ai_towers_near,
ai_towers_near_air,
ai_towers_near_ground,
ai_towers_need,
ai_towers_need_type,
ai_towers_needx,
ai_towers_needy,
ai_inprogress_uid
                 : integer;
ai_alarm_zone    : word;
ai_alarm_unit    : PTUnit;


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
         if(dist2(ax,ay,aia_x,aia_y)<sr)then aia_enemy_count:=0
     end
     else
       if(aia_enemy_count<=0)
       then freea:=a
       else
       begin
          if(not aia_enemy_base)then nobasea:=a;
          if(dist2(ax,ay,aia_x,aia_y)<sr)then exit;
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

procedure ai_make_start_alarms(p:byte);
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
procedure SetBaseOpt(me,m,unp,upp,t0,t1,s0,s1,s2,t,atl,att,l:integer);
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
      ai_max_towers  :=t;
      ai_attack_limit:=atl*MinUnitLimit;
      ai_attack_pause:=att;
      ai_max_blimit  :=l;
   end;
end;
begin
   with _players[p] do
   begin
      case ai_skill of
      //              energ buil uprod  pprod tech1 tech2 radar         hdetect
      //                    ders                          tlprt altr          towers
      0  : SetBaseOpt(600  ,1   ,1     ,0    ,0    ,0    ,0    ,0      ,0    ,0      ,15  ,fr_fps*240,2000 );
      1  : SetBaseOpt(1000 ,2   ,2     ,1    ,0    ,0    ,0    ,0      ,0    ,6      ,30  ,fr_fps*240,4000 );
      2  : SetBaseOpt(2500 ,4   ,4     ,1    ,1    ,0    ,1    ,0      ,1    ,10     ,60  ,fr_fps*120,8000 );
      3  : SetBaseOpt(4500 ,7   ,8     ,2    ,2    ,1    ,3    ,1      ,2    ,14     ,90  ,fr_fps*60 ,10000);
      4  : SetBaseOpt(5000 ,11  ,14    ,4    ,4    ,1    ,4    ,1      ,3    ,14     ,120 ,1         ,32000);
      else SetBaseOpt(5000 ,14  ,20    ,6    ,5    ,1    ,4    ,1      ,4    ,14     ,120 ,1         ,32000);
      end;
   end;
   ai_make_start_alarms(p);
end;

////////////////////////////////////////////////////////////////////////////////

procedure ai_alarm_target(aid:byte;tu:PTUnit;x,y,ud:integer);
begin
   with ai_alarm[aid] do
   if(ud<aiad)then
   begin
      if(tu<>nil)then
      begin
         aiax :=tu^.x;
         aiay :=tu^.y;
         aiau :=tu;
      end
      else
      begin
         aiax :=x;
         aiay :=y;
         aiau :=nil;
      end;
      aiad:=ud;
   end;
end;

procedure ai_clear_vars(pu:PTUnit);
var i,d:integer;
begin
   with pu^ do
   begin
      aiu_alarm_d    :=32000;
      aiu_alarm_x    :=-1;
      aiu_alarm_y    :=-1;
      aiu_need_detect:=32000;
      aiu_armyaround_ally :=0;
      aiu_armyaround_enemy:=0;
   end;

   ai_alarm_zone:=0;
   ai_alarm_unit:=nil;

   ai_armyaround_own:=0;

   for i:=0 to aia_l do
    with ai_alarm[i] do
    begin
       aiau:=nil;
       aiax:=-1;
       aiay:=0;
       aiad:=32000;
    end;

   // get default alarm point
   with pu^ do
   with player^ do
    for i:=0 to MaxPlayers do
     with ai_alarms[i] do
      if(aia_enemy_count>0)then
       if(ukfly)or(aia_zone=pfzone)then ai_alarm_target(aia_common,nil,aia_x,aia_y,dist2(aia_x,aia_y,x,y));

   with pu^ do
    for i:=1 to MaxCPoints do
     with g_cpoints[i] do
      if(cpcapturer>0)then
      begin
         d:=dist2(cpx,cpy,x,y);
         if(_players[cpowner].team=player^.team)then
           if(d>cpcapturer)or(cpunitst_pstate[player^.team]>10)then continue;
         ai_alarm_target(aia_common,nil,cpx,cpy,d);
      end;


   ai_grd_commander_u:=nil;
   ai_fly_commander_u:=nil;
   ai_grd_commander_d:=32000;
   ai_fly_commander_d:=32000;

   // nearest own building
   ai_base_d        := 32000;
   ai_base_u        := nil;

   // nearest own building with alarm
   ai_abase_d       := 32000;
   ai_abase_u       := nil;

   // transport target
   ai_inapc_d       := 32000;
   ai_inapc_u       := nil;

   // adv
   ai_uadv_d        := 32000;
   ai_uadv_u        := nil;
   ai_hadv_u        := nil;

   // nearest teleporter
   ai_teleporter_d  := 32000;
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
   ai_need_heye_d   := 32000;
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

   ai_spec2_cur     := 0; // heye nest

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
procedure _setNearestPU(ppu:PPTunit;pd:pinteger);
begin
   if(ud<pd^)then
   begin
      pd^ :=ud;
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
               if(tu^.uid^._ukbuilding)and(tu^.aiu_alarm_d<base_r)then _setNearestPU(@ai_abase_u,@ai_abase_d);
               if(tu^.uid^._attack>0)then
               begin
                  if(ud<srange)and(tu^.speed=0)and(tu^.uid^._ukbuilding)then
                  begin
                     ai_towers_near+=1;
                     if(uidi=aiucl_twr_air1   [race])
                     or(uidi=aiucl_twr_air2   [race])then ai_towers_near_air   +=1;
                     if(uidi=aiucl_twr_ground1[race])
                     or(uidi=aiucl_twr_ground2[race])then ai_towers_near_ground+=1;
                  end;
                  if(ud<base_ir)then aiu_armyaround_ally+=tu^.uid^._limituse;
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
                 if(ai_teleporter_beacon_u=nil)
                 then ai_teleporter_beacon_u:=tu
                 else
                   if(tu^.aiu_armyaround_ally>ai_teleporter_beacon_u^.aiu_armyaround_ally)
                   then ai_teleporter_beacon_u:=tu;
            end
            else
             if(_uvision(team,tu,true))then
             begin
                ai_alarm_target(aia_common,tu,0,0,ud);
                if(tu^.ukfly)
                then ai_alarm_target(aia_fly   ,tu,0,0,ud)
                else ai_alarm_target(aia_ground,tu,0,0,ud);
                if(tu^.buff[ub_invis]>0)and(tu^.vsni[team]<=0)then
                begin
                   ai_alarm_target(aia_invis,tu,0,0,ud);
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
                     if(tu^.uid^._ability=uab_uac__unit_adv)and(tu^.rld<=0)then _setNearestPU(@ai_uadv_u,@ai_uadv_d);

                     if(uid^._ability=uab_hell_unit_adv)then
                      if(_HellAdvPrio(tu,ai_hadv_u))then ai_hadv_u:=tu;
                  end;

                  if(uid^._ability=uab_teleport)then
                  begin
                     if(tu^.rld<=0)then _setNearestPU(@ai_teleporter_u,@ai_teleporter_d);
                     if(ud<base_rr)and(pfzone=tu^.pfzone)then ai_teleports_near+=1;
                  end;

                  if(ud<ai_inapc_d)and(tu^.aiu_alarm_d>base_ir)and(tu^.order<>aio_busy)then
                   if(tu^.apcc=tu^.apcm)or(armylimit>=ai_limit_border)then
                    if(ukfly)or(pfzone=tu^.pfzone)then
                     if(_itcanapc(pu,tu))then _setNearestPU(@ai_inapc_u,@ai_inapc_d);

                  if(ud<base_rr)and(tu^.speed>0)then
                  begin
                     if(tu^.ukfly=false)
                     then _setCommanderVar(@ai_grd_commander_u,@ai_grd_commander_d,ud)
                     else _setCommanderVar(@ai_fly_commander_u,@ai_fly_commander_d,ud);
                  end;
               end;

               if(ud<ai_base_d)and(tu^.uid^._ukbuilding)and(tu^.speed<=0)then _setNearestPU(@ai_base_u,@ai_base_d);
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
      then ai_scout_u_cur_w:=_unitWeaponPriority(tu,wtp_scout)
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
   w:=_unitWeaponPriority(pu,wtp_scout);
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
var  bt:byte;
   ddir,
   rdir:single;
bx,by,l:integer;
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
procedure BuildSpec0(x:integer);  // Radar, Teleport
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
procedure BuildSpec2(x:integer);  // Heye Nest
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
      BuildTower (ai_towers_need,ai_towers_need_type);
      if(bt>0)and(ai_towers_needx>-1)
      then ddir:=(p_dir(x,y,ai_towers_needx,ai_towers_needy)+_randomr(90));

      // fixed opening
      BuildEnergy(300 );
      BuildUProd (1   );
if(race=r_uac)
then  BuildEnergy(1000)
else  BuildEnergy(900 );
      BuildSmith (1   );
if(race=r_uac)
then  BuildSpec0 (1   )
else  BuildSpec2 (1   );
      BuildMain  (2   );
      BuildUProd (2   );
      BuildEnergy(1100);
      BuildSpec0 (1   );
      BuildEnergy(1300);
      BuildUProd (3   );
      BuildMain  (4   );
      BuildTech0 (1   );
      BuildTech1 (1   );
      BuildSpec1 (1   );

      // common
      BuildSmith(ai_upgrp_need);
      BuildTech0(ai_tech0_need);
      BuildSpec0(ai_spec0_need);
      BuildSpec2(ai_max_spec2 );
      BuildUProd(ai_unitp_need);
      BuildMain (ai_basep_need);

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



//ai_alarm_zone
procedure ai_UnitProduction(pu:PTUnit);
var ut:byte;
    up_m,
    up_n:integer;
function pick_hell_any:byte;
begin
   case random(19) of
0 : pick_hell_any:=UID_LostSoul;
1 : pick_hell_any:=UID_Imp;
2 : pick_hell_any:=UID_Demon;
3 : pick_hell_any:=UID_Cacodemon;
4 : pick_hell_any:=UID_Knight;
5 : pick_hell_any:=UID_Cyberdemon;
6 : pick_hell_any:=UID_Mastermind;
7 : pick_hell_any:=UID_Pain;
8 : pick_hell_any:=UID_Revenant;
9 : pick_hell_any:=UID_Mancubus;
10: pick_hell_any:=UID_Arachnotron;
11: pick_hell_any:=UID_Archvile;
12: pick_hell_any:=UID_ZFormer;
13: pick_hell_any:=UID_ZEngineer;
14: pick_hell_any:=UID_ZSergant;
15: pick_hell_any:=UID_ZCommando;
16: pick_hell_any:=UID_ZBomber;
17: pick_hell_any:=UID_ZMajor;
18: pick_hell_any:=UID_ZBFG;
   end;
end;
function pick_hell_fly:byte;
begin
   case random(7) of
0 : pick_hell_fly:=UID_LostSoul;
1 : pick_hell_fly:=UID_Cacodemon;
2 : pick_hell_fly:=UID_Cacodemon;
3 : pick_hell_fly:=UID_Cacodemon;
4 : pick_hell_fly:=UID_Cacodemon;
5 : pick_hell_fly:=UID_Pain;
6 : pick_hell_fly:=UID_ZMajor;
   end;
end;
function pick_uac_any:byte;
begin
   case random(13) of
0 : pick_uac_any:=UID_Medic;
1 : pick_uac_any:=UID_Engineer;
2 : pick_uac_any:=UID_Sergant;
3 : pick_uac_any:=UID_Commando;
4 : pick_uac_any:=UID_Bomber;
5 : pick_uac_any:=UID_Major;
6 : pick_uac_any:=UID_BFG;
7 : pick_uac_any:=UID_APC;
8 : pick_uac_any:=UID_FAPC;
9 : pick_uac_any:=UID_UACBot;
10: pick_uac_any:=UID_Terminator;
11: pick_uac_any:=UID_Tank;
12: pick_uac_any:=UID_Flyer;
   end;
end;
function pick_uac_fly:byte;
begin
   case random(5) of
0 : pick_uac_fly:=UID_Major;
1 : pick_uac_fly:=UID_Flyer;
2 : pick_uac_fly:=UID_Flyer;
3 : pick_uac_fly:=UID_FAPC;
4 : pick_uac_fly:=UID_FAPC;
   end;
end;

begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if((armylimit+uprodl)>=ai_max_blimit)then exit;

      case _urace of
r_hell: if(aiu_alarm_d=32000)
        then ut:=pick_hell_any
        else
          if(ai_alarm_zone<>pfzone)and(random(ai_teleports_near)=0)
          then ut:=pick_hell_fly
          else ut:=pick_hell_any;
r_uac : if(aiu_alarm_d=32000)
        then ut:=pick_uac_any
        else
          if(ai_alarm_zone<>pfzone)and(uid_e[UID_FAPC]<=0)
          then ut:=pick_uac_fly
          else ut:=pick_uac_any;
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

      if(up_n<up_m)then _unit_straining(pu,ut);
   end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//   UPGRADE PRODUCTION
//

{
upgr_hell_dattack      = 1;  // distance attacks damage
upgr_hell_uarmor       = 2;  // base unit armor
upgr_hell_barmor       = 3;  // base building armor
upgr_hell_mattack      = 4;  // melee attack damage
upgr_hell_regen        = 5;  // regeneration
upgr_hell_pains        = 6;  // pain state
upgr_hell_heye         = 7;  // hell Eye
upgr_hell_towers       = 8;  // towers range
upgr_hell_teleport     = 9;  // Teleport reload
upgr_hell_hktele       = 10; // HK teleportation
upgr_hell_paina        = 11; // decay aura
upgr_hell_mainr        = 12; // main range
upgr_hell_hktdoodads   = 13; // HK on doodabs
upgr_hell_pinkspd      = 14; // demon speed
upgr_hell_revtele      = 15; // revers teleport
upgr_hell_6bld         = 16; // Souls
upgr_hell_9bld         = 17; // 9 class building reload time
upgr_hell_revmis       = 18; // revenant missile
upgr_hell_totminv      = 19; // totem and eye invisible
upgr_hell_bldrep       = 20; // build restoration
upgr_hell_b478tel      = 21; // teleport towers
upgr_hell_invuln       = 22; // hell invuln powerup


upgr_uac_attack        = 31; // distance attack
upgr_uac_uarmor        = 32; // base armor
upgr_uac_barmor        = 33; // base b armor
upgr_uac_melee         = 34; // repair/health upgr
upgr_uac_mspeed        = 35; // infantry speed
upgr_uac_plasmt        = 36; // turrent for apcs
upgr_uac_detect        = 37; // detectors
upgr_uac_towers        = 38; // towers sr
upgr_uac_radar_r       = 39; // Radar
upgr_uac_mainm         = 40; // Main b move
upgr_uac_ccturr        = 41; // CC turret
upgr_uac_mainr         = 42; // main sr
upgr_uac_ccldoodads    = 43; // main on doodabs
upgr_uac_mines         = 44; // mines for engineers
upgr_uac_jetpack       = 45; // jetpack for plasmagunner
upgr_uac_6bld          = 46; // adv
upgr_uac_9bld          = 47; // 9 class building reload time
upgr_uac_mechspd       = 48; // mech speed
upgr_uac_mecharm       = 49; // mech arm
upgr_uac_turarm        = 50; // turrets armor
upgr_uac_rstrike       = 51; // rstrike launch
}

procedure ai_UpgrProduction(pu:PTUnit);
procedure MakeUpgr(upid,lvl:byte);
begin
   if(upid>0)then
   with pu^     do
   with player^ do
   if(upgr[upid]<lvl)then _unit_supgrade(pu,upid);
end;
begin
   with pu^     do
   with player^ do
   begin
      case race of
r_hell: begin
        MakeUpgr(upgr_hell_heye  ,1);
        MakeUpgr(upgr_hell_mainr ,1);
        MakeUpgr(upgr_hell_hktele,1);
        MakeUpgr(upgr_hell_9bld  ,1);
        MakeUpgr(upgr_hell_heye  ,3);
        MakeUpgr(upgr_hell_6bld  ,1);

        _unit_supgrade(pu,random(30));
        end;
r_uac : begin
        MakeUpgr(upgr_uac_detect ,1);
        MakeUpgr(upgr_uac_mainr  ,1);
        MakeUpgr(upgr_uac_mainm  ,1);
        MakeUpgr(upgr_uac_9bld   ,1);
        MakeUpgr(upgr_uac_6bld   ,1);

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
      if((ai_inprogress_uid=0)and(    bld))
      or((ai_inprogress_uid>0)and(not bld))then
      case uidi of
UID_HSymbol,
UID_HASymbol,
UID_UGenerator,
UID_UAGenerator: if(cenergy>_genergy)and(menergy>del_generators_energy)then exit;
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
UID_UATurret    : if(aiu_alarm_d<base_ir)
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
      with ai_alarm[aia_common] do
       if(aiau<>nil)and(aiad<base_3r)and(buff[ub_damaged]<=0)and(a_rld<=0)then   //?????????????????????????
        case uidi of
UID_UGTurret   : if(    aiau^.ukfly)and(ai_alarm[aia_ground].aiad>srange)then exit;
UID_UATurret   : if(not aiau^.ukfly)and(ai_alarm[aia_fly   ].aiad>srange)then exit;
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

      if(_N(@ai_basep_need ,ai_max_mains ))then ai_basep_need :=ai_max_mains;//mm3(1,ai_basep_builders+1           ,ai_max_mains );
      if(_N(@ai_unitp_need ,ai_max_unitps))then ai_unitp_need :=mm3(1,ai_basep_builders      ,ai_max_unitps);
      if(_N(@ai_upgrp_need ,ai_max_upgrps))then ai_upgrp_need :=mm3(1,round(ai_unitp_cur/2.5),ai_max_upgrps);
      if(_N(@ai_tech0_need ,ai_max_tech0 ))then ai_tech0_need :=mm3(0,ai_unitp_cur div 3     ,ai_max_tech0 );
      if(_N(@ai_spec0_need ,ai_max_spec0 ))then ai_spec0_need :=mm3(0,ai_unitp_cur div 3     ,ai_max_spec0 );
      if(_N(@ai_towers_need,ai_max_towers))then
       if(aiu_alarm_d<base_3r) then
       begin
          ai_towers_need :=mm3(0,(towers_limit_border-aiu_armyaround_ally) div 10,ai_max_towers);
          ai_towers_needx:=aiu_alarm_x;
          ai_towers_needy:=aiu_alarm_y;
          ai_towers_need_type:=0;
          if(ai_alarm[aia_ground].aiad<base_rr)then ai_towers_need_type:=-1;
          if(ai_alarm[aia_fly   ].aiad<base_rr)then ai_towers_need_type:= 1;
       end;

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
         ai_UnitProduction(pu);
         if(aiu_alarm_d<32000)then
         begin
            uo_x:=aiu_alarm_x;
            uo_y:=aiu_alarm_y;
         end;
      end;
      if(_issmith  )then ai_UpgrProduction(pu);
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

procedure ai_flytransport(pu:PTUnit);
begin
   with pu^  do
    if(apcc=0)
    then ai_outfrom(pu,aiu_alarm_x,aiu_alarm_y)
    else
      if(aiu_alarm_d<200)then uo_id:=ua_unload;
end;
procedure ai_apc(pu:PTUnit);
begin
   with pu^  do
    if(apcc=0)
    or(aiu_alarm_d<150)
    then ai_outfrom(pu,aiu_alarm_x,aiu_alarm_y) ;
end;

procedure ai_unit_target(pu:PTUnit);
var d,
commander_d :integer;
commander_u,
uo_tarpu    :PTUnit;
procedure set_uo(ox,oy,ow:integer;tarpu:PTUnit);
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
           uo_x:=ox+(sign(ox-x)*_randomr(-ow));
           uo_y:=oy+(sign(oy-y)*_randomr(-ow));
        end
        else
        begin
           uo_x:=ox-_randomr(ow);
           uo_y:=oy-_randomr(ow);
        end;
      uo_tar:=0;
   end;
   uo_tarpu:=tarpu;
end;
begin
   uo_tarpu:=nil;
   pu^.uo_tar:=0;

   commander_u:=nil;
   if(ai_alarm_zone<>pu^.pfzone)and(pu^.aiu_alarm_d<32000)
   then begin commander_u:=ai_fly_commander_u;commander_d:=ai_fly_commander_d;end
   else begin commander_u:=ai_grd_commander_u;commander_d:=ai_grd_commander_d;end;

   //_ability_teleport

   // base
   with pu^  do
   with uid^ do
   begin
      if(order=aio_busy)then order:=aio_home;

      if(aiu_alarm_d<base_ir)then
      begin
         set_uo(aiu_alarm_x,aiu_alarm_y,-100,nil);
         if(apcm>0)then
          case _attack of
atm_bunker : ai_apc(pu);
          else  ai_flytransport(pu);
          end;
      end
      else
        if(unum=player^.ai_scout_u_cur)then
        begin
           order:=aio_scout;

           if(dist2(x,y,uo_x,uo_y)<srange)or(not ukfly and (pfzone<>pf_get_area(uo_x,uo_y)))
           then set_uo(random(map_mw),random(map_mw),0,nil);
        end
        else
        begin
           if(order=aio_scout)then order:=aio_home;

           if(ai_abase_d<aiu_alarm_d)then
             if(ai_abase_d>base_r)
             then set_uo(0,0, 0     ,ai_abase_u)
             else set_uo(0,0,-base_r,ai_abase_u)
           else
             if(order=aio_home)then
             begin
                if(ai_base_d<32000)then
                 if(ai_base_d>base_r)
                 then set_uo(0,0,0     ,ai_base_u)
                 else set_uo(0,0,base_r,ai_base_u);

                with player^ do
                 if(ai_armyaround_own>ai_attack_limit)
                 or(ucl_l[false]>=ai_max_blimit)
                 or((armylimit+uprodl)>=ai_limit_border)then
                 begin
                    order:=aio_attack;
                    if(pu=commander_u)then aiu_attack_timer:=player^.ai_attack_pause;
                 end;
             end;

           if(commander_u<>nil)and(sel)then
           begin
              if(k_alt>0)then MoveCamToPoint(commander_u^.x,commander_u^.y);
           end;

           if(order=aio_attack)then
            if(commander_u<>nil)then
             if(pu<>commander_u)then
             begin
                aiu_attack_timer:=0;
                if(commander_d>srange)
                then set_uo(0,0,0      ,commander_u)
                else set_uo(0,0,-srange,commander_u);
                  //if(srange<60)then ai_outfrom(pu,commander_u^.x,commander_u^.y);
             end
             else
               //if(aiu_attack_timer=0)then
                 if(aiu_alarm_d<32000)then
                  set_uo(aiu_alarm_x,aiu_alarm_y,0,nil);
        end;

      if(ai_uadv_u<>nil)and(ai_uadv_d<base_ir)then
      begin
         if(not _ukbuilding)and(buff[ub_advanced]<=0)and(_ability<>uab_Advance)then
         begin
            order:=aio_busy;
            set_uo(0,0,0,ai_uadv_u);
            d:=ai_uadv_d-(_r+ai_uadv_u^.uid^._r-aw_dmelee);
            if(d<=0)
            then uo_tar:=ai_uadv_u^.unum;
            exit;
         end;
      end;

      if(ai_inapc_d<32000)then
       if(ai_inapc_d<base_ir)or(ukfly)then
        with pu^  do
        begin
           order:=aio_busy;
           set_uo(0,0,0,ai_inapc_u);
           d:=ai_inapc_d-(_r+ai_inapc_u^.uid^._r-aw_dmelee);
           if(d<=0)
           then uo_tar:=ai_inapc_u^.unum;
           exit;
        end;
   end;
    {

      //if(aiu_alarm_d<ai_uo_d)then
       if(aiu_alarm_d<base_ir)or((pu=commander)and(order=2))then
        if(pfzone=ai_alarm_zone)or(ukfly)then
        begin
           uo_x:=aiu_alarm_x;
           uo_y:=aiu_alarm_y;
           if(apcm>0)then
            case _attack of
    atm_bunker : ai_apc(pu);
            else  ai_flytransport(pu);
            end;
        end; }
end;

procedure ai_code(pu:PTUnit);
var i :byte;
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
      for i:=0 to aia_l do
       with ai_alarm[i] do
        if(aiad<32000)then
         if(aiau<>nil)
         then aiazone:=aiau^.pfzone
         else aiazone:=pf_get_area(aiax,aiay);

      ai_unit_timer(@aiu_alarm_timer);
      ai_unit_timer(@aiu_attack_timer);

      uo_id :=ua_amove;
      uo_tar:=0;

      // nearest alarm
      with ai_alarm[aia_common] do
      begin
         aiu_alarm_d  :=aiad;
         aiu_alarm_x  :=aiax;
         aiu_alarm_y  :=aiay;
         ai_alarm_zone:=aiazone;
         ai_alarm_unit:=aiau;
      end;

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
uab_radar        : if(player^.ai_detection_pause=0)then
                    with ai_alarm[aia_invis] do
                     if(aiau<>nil)then
                     begin
                        _unit_ability_uradar(pu,aiax,aiay);
                        player^.ai_detection_pause:=fr_fps;
                     end;
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
      UId_Major    : if(ai_alarm_unit<>nil)then
                     begin
                        if(ukfly<>ai_alarm_unit^.ukfly)then _unit_action(pu);
                     end
                     else
                       if(not ukfly)then _unit_action(pu);
                   end;
      end;

      if(speed<=0)then exit;

      ai_unit_target(pu);

      if(ai_alarm_unit<>nil)
      then ai_set_alarm(player,x,y,aiu_armyaround_enemy,srange,ai_alarm_unit^.uid^._ukbuilding,ai_alarm_unit^.pfzone)
      else ai_set_alarm(player,x,y,0,srange,false,0);
   end;
end;



