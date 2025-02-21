
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

function ai_checkCPNear(NoBuildRArea:integer):boolean;
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
       if(d<(cpNoBuildR+NoBuildRArea))then exit;

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
     if(SetBTA(aiucl_main0[race],aiucl_main1[race],4))then
     begin
        ddir:=-1;
        l:=pu^.srange;
     end;
end;
procedure BuildEnergy(a:integer); // Energy
begin
   a+=base_energy;
   if(g_generators=0)then
    with pu^.player^ do
     if(ai_enrg_pot<a)and(ai_enrg_pot<ai_maxcount_energy)and(ai_enrg_pot<ai_GeneratorsEnergy)and(ai_gen_limit<ai_GeneratorsLimit)then  //
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
   if(u_royal_d>base_6r)then
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
       l:=ai_towers_needl;
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
      {case race of
      r_uac : ai_need_energy:=mm3(600,(ai_unitp_cur+ai_upgrp_cur+upgr[_upgr_srange])*500+(ai_builders_count*600) ,ai_GeneratorsEnergy);
      r_hell: ai_need_energy:=mm3(600,(ai_unitp_cur+ai_upgrp_cur+upgr[_upgr_srange])*650+(ai_builders_count*750) ,ai_GeneratorsEnergy);
      end; }
      ai_need_energy:=mm3(600,(ai_unitp_cur+ai_upgrp_cur)*600,ai_GeneratorsEnergy);

      if((ai_flags and aif_base_smart_order)>0)then
      begin
         skip_energy_check:=false;
         BuildTower (ai_towers_need,ai_towers_need_type);
         BuildEnergy(ai_need_energy);
         BuildUProd (ai_unitp_need);
         BuildSmith (ai_upgrp_need);
         BuildDetect(ai_detect_need);
         if(ai_builders_count>1)
    then BuildTech  (1)
    else BuildMain  (ai_builders_need);
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
      case uclass of
uprod_smart: begin
                ai_UnitProduction:=true;

                if(ai_UnitProduction(pu,uprod_base,MaxUnits))then exit;

                if(g_mode=gm_invasion)and(g_inv_wave_n>9)then
                begin
                   case random(4) of
                   0: if(ai_UnitProduction(pu,UID_Cacodemon    ,MaxUnits))then exit;
                   1: if(ai_UnitProduction(pu,UID_Arachnotron  ,MaxUnits))then exit;
                   2: if(ai_UnitProduction(pu,UID_FPlasmagunner,MaxUnits))then exit;
                   3: if(ai_UnitProduction(pu,UID_UACDron      ,MaxUnits))then exit;
                   end;
                end;

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
                          13: ut:=UID_ZMedic;
                          14: ut:=UID_ZEngineer;
                          15: ut:=UID_ZSergant;
                          16: ut:=UID_ZSSergant;
                          17: ut:=UID_ZCommando;
                          18: ut:=UID_ZAntiaircrafter;
                          19: ut:=UID_ZSiegeMarine;
                          20: ut:=UID_ZFPlasmagunner;
                          21: ut:=UID_ZBFGMarine;
                          22: ut:=UID_Phantom;
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
             r_hell: case random(3) of
                          0 : ut:=UID_Cacodemon;
                          1 : ut:=UID_Pain;
                          2 : ut:=UID_ZFPlasmagunner;
                     end;
             r_uac : case random(3) of
                          0 : ut:=UID_FPlasmagunner;
                          1 : ut:=UID_Flyer;
                          2 : ut:=UID_UTransport;
                     end;
             end;
uprod_antiair
           : case pu^.player^.race of
             r_hell: case random(5) of
                          0 : ut:=UID_Cacodemon;
                          1 : ut:=UID_ZFPlasmagunner;
                          2 : ut:=UID_Revenant;
                          3 : ut:=UID_Imp;
                          4 : ut:=UID_ZAntiaircrafter;
                     end;
             r_uac : case random(3) of
                          0 : ut:=UID_FPlasmagunner;
                          1 : ut:=UID_Flyer;
                          2 : ut:=UID_Antiaircrafter;
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
UID_ZMedic,
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
var i:byte;
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
        //if(g_generators=0)then
        MakeUpgr(upgr_hell_buildr    ,2);
        MakeUpgr(upgr_hell_HKTeleport,1);
        MakeUpgr(upgr_hell_spectre   ,1);
        MakeUpgr(upgr_hell_paina     ,1);

        if(ai_maxcount_upgrlvl>0)then
        for i:=1 to ai_maxcount_upgrlvl do
        begin
        MakeUpgr(upgr_hell_pains     ,i);
        MakeUpgr(upgr_hell_heye      ,i);
        MakeUpgr(upgr_hell_regen     ,i);
        MakeUpgr(upgr_hell_vision    ,i);
        MakeUpgr(upgr_hell_t1attack  ,i);
        MakeUpgr(upgr_hell_t2attack  ,i);
        MakeUpgr(upgr_hell_mattack   ,i);
        MakeUpgr(upgr_hell_uarmor    ,i);
        MakeUpgr(upgr_hell_barmor    ,i);
        MakeUpgr(upgr_hell_regen     ,i);
        MakeUpgr(upgr_hell_vision    ,i);
        end;
        end;

        MakeUpgr(upgr_hell_t1attack+random(24),ai_maxcount_upgrlvl);
        end;
r_uac : begin
        if((ai_flags and aif_upgr_smart_opening)>0)then
        begin
        //if(g_generators=0)then
        MakeUpgr(upgr_uac_buildr     ,2);
        MakeUpgr(upgr_uac_CCFly      ,1);
        MakeUpgr(upgr_uac_commando   ,1);
        MakeUpgr(upgr_uac_ccturr     ,1);
        MakeUpgr(upgr_uac_botturret  ,1);
        MakeUpgr(upgr_uac_antiair    ,1);

        if(ai_maxcount_upgrlvl>0)then
        for i:=1 to ai_maxcount_upgrlvl do
        begin
        MakeUpgr(upgr_uac_vision     ,i);
        MakeUpgr(upgr_uac_attack     ,i);
        MakeUpgr(upgr_uac_uarmor     ,i);
        MakeUpgr(upgr_uac_mecharm    ,i);
        MakeUpgr(upgr_uac_barmor     ,i);
        MakeUpgr(upgr_uac_melee      ,i);
        MakeUpgr(upgr_uac_mechspd    ,i);
        MakeUpgr(upgr_uac_vision     ,i);
        end;
        end;

        MakeUpgr(upgr_uac_attack+random(24),ai_maxcount_upgrlvl);
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
UID_HSymbol1,
UID_HSymbol2,
UID_HSymbol3,
UID_HSymbol4,
UID_UGenerator1,
UID_UGenerator2,
UID_UGenerator3,
UID_UGenerator4: if(cenergy>_genergy)and(armylimit>ai_GeneratorsDestoryLimit)and(menergy>ai_GeneratorsDestroyEnergy)then exit; // ai_enrg_cur
      else
        if(uid_e[uidi]>1)then
         if(_isbarrack)or(_issmith)then
          if(ai_isnoprod(pu))then
          begin
             i:=level+1;

             if(_isbarrack)and(ai_unitp_cur>2)then
              if(ai_unitp_cur_na<=0)or((level=0)and(ai_unitp_cur_na>0))then
               if((ai_unitp_cur-i-5)>=ai_unitp_need)then exit;
             if(_issmith  )and(ai_upgrp_cur>1)then
              if(ai_upgrp_cur_na<=0)or((level=0)and(ai_upgrp_cur_na>0))then
               if((ai_upgrp_cur-i-3)>=ai_upgrp_need)then exit;
          end;
      end;

      if(ai_PhantomWantZombieMe)and(iscomplete)and(hits<=(_zombie_hits+BaseDamage4))then exit;

      case uidi of
UID_HTower,
UID_HTotem,
UID_UGTurret,
UID_UATurret       : if(ai_towers_cur_active>ai_mincount_towers)and(not ai_checkCPNear(50))then
                      if(aiu_alarm_d<base_1rh)or(aiu_alarm_timer=0)or(ai_nearest_builder_d<base_1rh)
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
UID_UGTurret      : if(ai_towers_near_air=0)then exit;
UID_UATurret      : if(ai_towers_near_grd=0)then exit;
        end;

      case uidi of
UID_HKeep,
UID_HCommandCenter,
UID_UCommandCenter:
                    begin
                      if((race=r_uac)and(u_royal_d>base_3r))
                      or(g_mode<>gm_royale)
                      or((race=r_hell)and(u_royal_d>base_5r))then
                        if(ai_inprogress_auid<2)and(ai_inprogress_uid=0)and(n_builders>1)and(ai_enemy_d>base_2r)and(ai_unitp_cur>0)and(ai_enrg_cur>=1800)then exit;
                    end;
UID_HSymbol1,
UID_UGenerator1   : if(cenergy>=300)and(ai_inprogress_uid=0){and(ai_enrg_cur<ai_maxcount_energy)}then exit;
UID_HSymbol2,
UID_UGenerator2,
UID_HSymbol3,
UID_UGenerator3   : if(cenergy>=600)and(ai_inprogress_uid=0){and(ai_enrg_cur<ai_maxcount_energy)}then exit;
      else
         if(_isbarrack)or(_issmith)then
           if(level<MaxUnitLevel)and(cenergy>=600)and(ai_isnoprod(pu))then exit;
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



      if(_N(@ai_builders_need,ai_maxcount_mains ))then ai_builders_need:=ai_builders_count+1;

      {prods:=400;
      if(race=r_uac)and(ai_builders_count>1)then prods-=100;
      if((ai_maxcount_tech0> 0)and((ai_tech0_cur=0)or(ai_tech1_cur=0)or(ai_tech2_cur=0)))
      or((ai_maxcount_mains>=8)and(ai_builders_count<8))
      then prods+=150;
      prods:=(menergy div prods); }
      prods:=(menergy div 500)-1+ai_builders_count+ai_tech1_cur+ai_tech2_cur;
      if(g_generators>0)then prods+=1;

      if(_N(@ai_upgrp_need   ,ai_maxcount_upgrps))then ai_upgrp_need   :=mm3(1,prods div 4        ,ai_maxcount_upgrps);
      if(_N(@ai_unitp_need   ,ai_maxcount_unitps))then ai_unitp_need   :=mm3(1,prods-ai_upgrp_need,ai_maxcount_unitps);

      if(ai_enemy_inv_u<>nil)
      then ai_detect_need:=ai_maxlimit_detect
      else
        if(_N(@ai_detect_need  ,ai_maxlimit_detect))then ai_detect_need  :=mm3(0,ai_armylimit_alive_u div 8,ai_maxlimit_detect);

      if(_N(@ai_towers_need  ,ai_maxcount_towers))then
      begin
         if(g_generators>0)then
         begin
            ai_towers_need :=min2(ucl_c[false],ai_maxcount_towers);
            ai_towers_needx:=random(map_mw);
            ai_towers_needy:=random(map_mw);
            ai_towers_needl:=srange;
         end
         else ai_towers_need:=0;

         if(ai_enemy_d<base_4r)then
         begin
            ai_towers_need     :=mm3(ai_mincount_towers,(aiu_limitaround_enemy-aiu_limitaround_ally+MinUnitLimit) div MinUnitLimit,ai_maxcount_towers);
            ai_towers_needx    :=ai_enemy_u^.x;
            ai_towers_needy    :=ai_enemy_u^.y;
            ai_towers_need_type:=0;
            ai_towers_needl    :=-1;
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
            ai_towers_needl    :=-1;
         end
         else
         if(ai_cpoint_d<srange)then
         begin
            ai_towers_need     :=3;
            ai_towers_needx    :=ai_cpoint_cp^.cpx;
            ai_towers_needy    :=ai_cpoint_cp^.cpy;
            ai_towers_need_type:=0;
            ai_towers_needl    :=-1;
         end
         else
         if(ai_choosen)and(g_mode=gm_royale)and(u_royal_cd<base_2r)then
         begin
            ai_towers_need:=ai_maxcount_towers;
            ai_towers_need_type:=0;
            ai_towers_needl    :=-1;
         end;
      end;

      if((ai_flags and aif_base_suicide)>0)then
        if(ai_buildings_need_suicide(pu))then
        begin
           _unit_kill(pu,false,true,true,false,true);
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
         else
           if((ai_flags and aif_army_smart_order)>0)
           then ai_UnitProduction(pu,uprod_smart,MaxUnits)
           else ai_UnitProduction(pu,uprod_any  ,MaxUnits);

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


function ai_TryTeleportF(pu,target:PTUnit):boolean;
var tt,td:integer;
begin
   ai_TryTeleportF:=false;
   if(ai_teleport_use)and(ai_teleporterF_u<>nil)then
     with ai_teleporterF_u^ do
     begin
        pu^.uo_x:=x;
        pu^.uo_y:=y;
        td:=point_dist_int(pu^.x,pu^.y,x,y);
        ai_TryTeleportF:=true;
        if(td<uid^._r)then
          if(target<>nil)then
          begin
             tt:=uo_tar;
             uo_tar:=target^.unum;
             _ability_teleport(pu,ai_teleporterF_u,td);
             uo_tar:=tt;
          end
          else
            if(_IsUnitRange(uo_tar,nil))then _ability_teleport(pu,ai_teleporterF_u,td);
     end;
end;
function ai_TryTeleportR(pu:PTUnit):boolean;
begin
   ai_TryTeleportR:=false;
   if(ai_teleport_use)and(ai_teleporterR_u<>nil)then
     with ai_teleporterR_u^ do
       if(rld<=0)and(player^.upgr[upgr_hell_rteleport]>0)then
       begin
          ai_TryTeleportR:=true;
          _ability_teleport(pu,ai_teleporterR_u,NOTSET);
       end;
end;

procedure ai_UnitBehaviour(pu:PTUnit;SmartMicro:boolean);
var d,
    tar_x,
    tar_y,
    tar_d      : integer;
    tar_z      : word;
    tar_weight : byte;
    tar_FollowCommander,
    tar_WaitAttack
               : boolean;
    commander_d: integer;
    commander_u: PTUnit;
procedure au_SetBusyGroup(tu:PTUnit);
begin
   with tu^ do
     case group of
     aio_home  : group:=aio_home_busy;
     aio_attack: group:=aio_attack_busy;
     end;
end;
function IfInsideCPoint(cp:PTCTPoint;cpd:integer):boolean;
begin
   IfInsideCPoint:=false;
   if(cpd<NOTSET)then
    with cp^ do
      if(ai_builders_count>0)
      or(ai_unitp_cur>0)
      or(cpenergy<=0)then
        if(cpd<cpCaptureR)then
        begin
           if(cpzone<>pu^.pfzone)and(not ai_cpoint_koth)and(not(pu^.ukfly or pu^.ukfloater))
           then ai_RunTo(pu,0,0,0,0,pu)
           else ai_RunTo(pu,0,cpx,cpy,cpCaptureR div 2,nil);
           au_SetBusyGroup(pu);
           IfInsideCPoint:=true;
        end;
end;
function IfAttackingWithHealWeapon:boolean;
begin
   IfAttackingWithHealWeapon:=false;
   with pu^ do
    with uid^ do
     if(a_rld>0)and(a_weap_cl<=MaxUnitWeapons)then
      with _a_weap[a_weap_cl] do
       IfAttackingWithHealWeapon:=(aw_type=wpt_heal)or(aw_type=wpt_resurect);
end;
procedure SetNearestTarget(tu:PTUnit;tx,ty,td:integer;tz:word;FollowCommander,WaitForAttack:boolean;tweight:byte);
begin
   if(tu<>nil)then
   begin
      tx:=tu^.x;
      ty:=tu^.y;
      tz:=tu^.pfzone;
   end;
   with pu^ do
   if(pfzone=tz)or(td<base_1r)or(ukfly)or(ukfloater)then
   begin
      if(tweight>tar_weight)
      then
      else
        if(tweight<tar_weight)
        then exit
        else
          if(td<tar_d)
          then
          else exit;

      tar_x:=tx;
      tar_y:=ty;
      tar_d:=td;
      tar_z:=tz;
      tar_weight:=tweight;
      tar_FollowCommander:=FollowCommander;
      tar_WaitAttack     :=WaitForAttack;
   end;
end;
function CheckReparTargets(tu:PTUnit;td:integer):boolean;
begin
   CheckReparTargets:=false;
   with pu^ do
     if(td<base_3r)then
     begin
        ai_RunTo(pu,td,0,0,0,tu);
        au_SetBusyGroup(pu);
        if(tu^.playeri=playeri)
        then au_SetBusyGroup(tu);
        CheckReparTargets:=true;
     end;
end;
function FollowCommander:boolean;
begin
   commander_d:=NOTSET;
   commander_u:=nil;
   if(pu^.ukfly)or(pu^.ukfloater)then
   begin
      commander_u:=ai_commander_fly_u;
      commander_d:=ai_commander_fly_d;
      if(ai_commander_grd_u<>nil)then
        if((tar_d<NOTSET)and(ai_commander_grd_u^.pfzone=tar_z))
        or(tar_d=NOTSET)then
        begin
           commander_u:=ai_commander_grd_u;
           commander_d:=ai_commander_grd_d;
        end
   end
   else
   begin
      commander_u:=ai_commander_grd_u;
      commander_d:=ai_commander_grd_d;
   end;
   if(commander_u=nil)
   then commander_u:=pu;

   FollowCommander:=(pu<>commander_u);
   if(FollowCommander)then
   begin
      ai_RunTo(pu,commander_d,0,0,-pu^.srange,commander_u);
      pu^.group:=commander_u^.group;
   end;
end;
function CheckScout:boolean;
begin
   CheckScout:=false;
   with pu^ do
   with player^ do
   if(unum=ai_scout_u_cur)and(ai_armylimit_alive_u>ai_MinArmyForScout)then
   begin
      if(group<>aio_scout)then
        if(ai_scout_timer<0)
        then group:=aio_scout;

      if(group<>aio_scout)
      then ai_BaseIdle(pu,ai_BasePatrolRange)
      else
        if(aiu_alarm_d<NOTSET)
        then ai_RunTo(pu,aiu_alarm_d,aiu_alarm_x,aiu_alarm_y,0,nil)
        else ai_DefaultIdle(pu);

      CheckScout:=true;
   end
   else
   begin
      if(group=aio_scout)then group:=aio_home;

      if(ai_alarm_d=NOTSET)and(ai_ReadyForAttack)and(ai_radars=0)then
        if(uidi=UID_LostSoul     )
        or(uidi=UID_Phantom      )
        or(uidi=UID_FPlasmagunner)
        or(uidi=UID_Flyer        )then
        begin
           ai_DefaultIdle(pu);
           CheckScout:=true;
        end;
   end;
end;
function SpecialMicro:boolean;
begin
   SpecialMicro:=false;
   with pu^ do
   with uid^ do
   if(transportM<=0)then
   begin
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
   end
   else
     if(_attack=atm_bunker)then
     begin
        if(smartmicro)then
          if(transportC=0)
          or(ai_enemy_d<150)then
          begin
             ai_RunFrom(pu,ai_enemy_u^.x,ai_enemy_u^.y);
             SpecialMicro:=true;
          end;
     end
     else
     begin
        if(transportC>0)then
          if(tar_d<200)
          or(ai_cpoint_d   <200)
          or(ai_generator_d<200)
          or(ai_alarm_d    <200)
          or(ai_enemy_d    <200)then uo_id:=ua_unload;

        if(transportC<=0)then
        begin
           if(ai_enemy_d<srange)
           then ai_RunFrom(pu,ai_enemy_u^.x,ai_enemy_u^.y)
           else ai_BaseIdle(pu,srange);
           SpecialMicro:=true;
        end
        else
          if(pf_IfObstacleZone(tar_z))then
          begin
             ai_RunTo(pu,tar_d,tar_x,tar_y,base_1r,nil);
             SpecialMicro:=true;
         end;
     end;
end;
procedure TeleportUsing;
begin
   with pu^ do
   if(not ukfly)and(not ukfloater)then
   begin
      if(ai_teleporterR_u<>nil)then
      begin
         if((ai_teleporterR_u^.pfzone<>pfzone)and(tar_d=NOTSET))then
           if(ai_TryTeleportR(pu))then exit;

         if(ai_alarm_d>base_2r)and(ai_teleporterR_u^.aiu_limitaround_ally<ai_teleporterR_u^.aiu_limitaround_enemy)then
           if(ai_TryTeleportR(pu))then exit;
      end;

      if(ai_teleporterF_u<>nil)then
      begin
         if(ai_teleporterF_d<base_2r)and(ai_abase_d<NOTSET)and(tar_d>base_2r)then  // проверить
           if((ai_abase_d>base_4r)and((cycle_order mod 5)=0) )or(ai_abase_u^.pfzone<>pfzone)then
            if(ai_TryTeleportF(pu,ai_abase_u))then exit;

         if(tar_d=NOTSET)and(g_mode<>gm_invasion)then
           if(group=aio_attack)or(g_mode=gm_koth)then
             if(ai_TryTeleportF(pu,nil))then exit;
      end;
   end;
end;
begin
   with pu^  do
   with uid^ do
   with player^ do
   begin
      uo_tar:=0;
      case group of
      aio_home_busy  : group:=aio_home;
      aio_attack_busy: group:=aio_attack;
      end;

      {#########   royale battle: escape from death circle  ###########}
      if(g_mode=gm_royale)and(u_royal_d<100)then
      begin
         ai_RunTo(pu,0,map_hmw,map_hmw,0,nil);
         au_SetBusyGroup(pu);
         if(u_royal_d<50)then
         begin
            a_tar:=0;
            uo_id:=ua_move;
         end;
         exit;
      end;

      {#########   Scout check                   ###########}
      if(g_mode<>gm_invasion)then
        if(CheckScout)then exit;

      {#########   already inside the point      ###########}
      if(transportM<=0)or(_attack=atm_bunker)then
        if IfInsideCPoint(ai_cpoint_cp   ,ai_cpoint_d   )
        or IfInsideCPoint(ai_generator_cp,ai_generator_d)then exit;

      {#########   repair/heal specialist        ###########}
      if(SmartMicro)then
        with pu^ do
          if(IfAttackingWithHealWeapon)
          then au_SetBusyGroup(pu)
          else
            case uidi of
UID_Engineer : if(CheckReparTargets(ai_mrepair_u,ai_mrepair_d))then exit;
UID_ZMedic,
UID_Medic    : if(CheckReparTargets(ai_urepair_u,ai_urepair_d))then exit;
            end;

      {#########   Define nearest basic target   ###########}
      tar_d:=NOTSET;
      tar_weight:=0;

      // common alarm
      if(ai_alarm_d<NOTSET)then SetNearestTarget(nil,ai_alarm_x,ai_alarm_y,ai_alarm_d,ai_alarm_zone,ai_alarm_d>base_1rh,(ai_alarm_d>base_1rh)and(g_mode<>gm_invasion),3*byte((playeri=0)and(g_mode=gm_invasion)));

      // base attacked alarm
      if(ai_abase_d<NOTSET)then
        if(base_1r<ai_abase_d)
        then SetNearestTarget(ai_abase_u,0,0,ai_abase_d,0,ai_abase_d>base_3r,false,2*byte((group=aio_home)or(group=aio_home_busy)))
        else SetNearestTarget(nil,ai_abase_u^.aiu_alarm_x,
                                  ai_abase_u^.aiu_alarm_y,
                                  0,pf_GetAreaZone(ai_abase_u^.aiu_alarm_x,
                                                   ai_abase_u^.aiu_alarm_y),false,false,2);

      if(ai_cpoint_d<NOTSET)then
        with ai_cpoint_cp^ do SetNearestTarget(nil,cpx,cpy,ai_cpoint_d,cpzone,ai_cpoint_d>base_3r,(ai_cpoint_d>base_3r)and(not ai_cpoint_koth),byte(ai_cpoint_koth or(g_mode=gm_capture)));

      if(ai_generator_d<NOTSET)then
        with ai_generator_cp^ do
          if((cycle_order mod 5)=0)
          then SetNearestTarget(nil,cpx,cpy,ai_generator_d,cpzone,false,false,1)
          else SetNearestTarget(nil,cpx,cpy,ai_generator_d,cpzone,ai_generator_d>base_3r,ai_generator_d>base_3r,0);

      {if(sel)then
      begin
         if(tar_d<NOTSET)then
         UnitsInfoAddLine(x+_randomr(2),y+_randomr(2),tar_x+_randomr(2),tar_y+_randomr(2),c_aqua);
         UnitsInfoAddText((x+tar_x)div 2,(y+tar_y)div 2,i2s(tar_d),c_white);
      end; }

      {#########   transport                        ###########}
      if(ai_transport_tar_d<NOTSET)then
        if(ai_transport_tar_d<tar_d)or(transportC<=0)then
        begin
           au_SetBusyGroup(pu);
           ai_RunTo(pu,ai_transport_tar_d,0,0,0,ai_transport_tar_u);
           d:=ai_transport_tar_d-(_r+ai_transport_tar_u^.uid^._r-aw_dmelee);
           if(d<=0)
           then uo_tar:=ai_transport_tar_u^.unum;
           exit;
        end;

      if(tar_d     <base_1rh)
      or(ai_alarm_d<base_1rh)
      or(ai_enemy_d<base_1rh)then au_SetBusyGroup(pu);

      {#########   follow basic target              ###########}
      if(tar_d<NOTSET)then
      begin
         if(tar_d<base_1rh)
         then ai_RunTo(pu,0,tar_x,tar_y,0,nil)
         else
         begin
            if(tar_FollowCommander)then
              if(FollowCommander)then
              begin
                 TeleportUsing;
                 SpecialMicro;
                 exit;
              end;

            if(tar_WaitAttack)and(group<>aio_attack)and(group<>aio_attack_busy)then
              if(not ai_ReadyForAttack)then
              begin
                 ai_BaseIdle(pu,ai_BasePatrolRange);
                 exit;
              end
              else
              begin
                 if(group=aio_home)
                 or(group=aio_home_busy)then
                   if(ai_attack_timer<0)then
                     case group of
                   aio_home     : group:=aio_attack;
                   aio_home_busy: group:=aio_attack_busy;
                     end;

                 if (group<>aio_attack)
                 and(group<>aio_attack_busy)then
                 begin
                    ai_BaseIdle(pu,ai_BasePatrolRange);
                    exit;
                 end;
              end;

            ai_RunTo(pu,0,tar_x,tar_y,0,nil);
         end;
      end
      else
        if(not FollowCommander)then
          if(ai_ReadyForAttack)and(g_mode<>gm_invasion)
          then ai_DefaultIdle(pu)
          else ai_BaseIdle(pu,ai_BasePatrolRange);

      TeleportUsing;
      SpecialMicro;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   BASE CODE
//

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
                  if(ai_base_d<base_1r)
                  or(ai_base_d=NOTSET)
                  then
                    if(not pf_IfObstacleZone(pfzone))
                    then _unit_sability(pu);
                  {with player^ do
                  with uid^ do
                    if(ai_base_d>0)then
                      if//(ai_base_d<base_1r)
                      (ai_base_d=NOTSET)
                      or(g_mode=gm_royale)
                      then
                        if(aiu_FiledSquareNear<=ai_FiledSquareBorder)
                        //or(ai_builders_count>=3)
                        or(g_mode=gm_royale)then
                          if(not pf_IfObstacleZone(pfzone))
                          then _unit_sability(pu);  }
               end;
      end
      else
        if(u_royal_d<base_1r)
        or((    ai_choosen)and(g_mode=gm_royale)and(u_royal_cd>=min2(g_royal_r div 7,base_2r)))
        or((    ai_choosen)and(ai_cpoint_koth)and(ai_cpoint_d>=base_1r))
        or((not ai_choosen)and(aiu_FiledSquareNear>ai_FiledSquareBorder)and(ai_builders_count<2))
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

function ai_uab_Rebuild2Turret(pu:PTUnit):boolean;
begin
   ai_uab_Rebuild2Turret:=true;
   with pu^  do
   with uid^ do
   with player^ do
   if(u_royal_d>base_1r)then
   begin
      if(unum=ai_scout_u_cur)and(ai_enemy_build_u<>nil)then
       if(ai_enemy_build_d<srange)and(ai_enemy_build_u^.speed=0)and(buff[ub_Damaged]<=0)then exit;

      if(ai_checkCPNear(25))then exit;
   end;
   ai_uab_Rebuild2Turret:=false;
end;
procedure ai_uab_HTowerBlink(pu:PTUnit);
var bx,by,bd:integer;
procedure SetBlinkTarget(x,y,d:integer;zone:word);
begin
   if(d<bd)then
   begin
      if(bd<NOTSET)then
        if(zone<>pu^.pfzone)then exit;
      bd:=d;
      bx:=x;
      by:=y;
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
        with ai_cpoint_cp^ do
          if(cpNoBuildR<cpCaptureR)then
            if(ai_cpoint_d<=cpCaptureR)
            then exit
            else SetBlinkTarget(cpx,cpy,ai_cpoint_d,cpzone);

      if(ai_generator_d<NOTSET)then
        with ai_generator_cp^ do
          if(cpNoBuildR<cpCaptureR)then
            if(ai_generator_d<=cpCaptureR)
            then exit
            else SetBlinkTarget(cpx,cpy,ai_generator_d,cpzone);

      if(srange<ai_alarm_d)and(ai_alarm_d<NOTSET)then
        SetBlinkTarget(ai_alarm_x,ai_alarm_y,ai_alarm_d,ai_alarm_zone);

      if(g_mode=gm_royale)then SetBlinkTarget(map_hmw,map_hmw,0,pf_get_area(map_hmw,map_hmw));

      if(bd=NOTSET)then exit;

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
   //if(pu^.sel)then writeln(ai_inprogress_auid);
end;

procedure ai_code(pu:PTUnit);
var alarmr:integer;
begin
   with pu^  do
   with uid^ do
   begin
      ai_timer(@aiu_alarm_timer,0);

      uo_id :=ua_amove;
      uo_tar:=0;

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
      if(_canAbility(pu)=0)then
      begin
         // other ability
         if((player^.ai_flags and aif_ability_other)>0)then
         begin
            case _ability of
uab_HTowerBlink      : ai_uab_HTowerBlink(pu);
uab_HInvulnerability : if(ai_invuln_tar_u<>nil)then _unit_ability_HInvuln  (pu,ai_invuln_tar_u^.unum);
uab_UACStrike        : if(ai_strike_tar_u<>nil)then _unit_ability_UACStrike(pu,ai_strike_tar_u^.x,ai_strike_tar_u^.y);
uab_SpawnLost        : if(ai_ZombieTarget_d<srange)and(player^.upgr[upgr_hell_phantoms]>0)then
                         if(srange<u_royal_d)or(g_royal_r<srange)then _unit_sability(pu);
            end;
            case uidi of
UID_UACDron           : if(ai_uab_Rebuild2Turret(pu))then
                          if(_unit_rebuild(pu))then exit;
            end;
         end;

         // MAIN relocation ability
         if((player^.ai_flags and aif_ability_mainsave)>0)then
           case _ability of
   uab_CCFly       : ai_SaveMain_CC(pu);
   uab_HKeepBlink  : ai_SaveMain_HK(pu);
           end;
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
                               ai_detection_pause:=fr_fps1;
                               ai_enemy_inv_u^.buff[ub_Scaned]:=fr_fps1;
                            end;
                          if(ai_alarm_d=NOTSET)and(g_mode<>gm_invasion)then
                           if(ai_choosen)or(ai_ReadyForAttack)then
                            if(_unit_ability_uradar(pu,_random(map_mw),_random(map_mw)))then ai_detection_pause:=fr_fps1;
                       end;
uab_HellVision       : if(ai_need_heye_u<>nil)then
                         if(_unit_ability_HellVision(pu,ai_need_heye_u^.unum))then ai_detection_pause:=fr_fps1;
            end;

      if(speed<=0)or(_ukbuilding)then exit;

      ai_UnitBehaviour(pu,(player^.ai_flags and aif_army_smart_micro)>0);

      if(sel)then
      begin

         {if(ai_teleporterR_u<>nil)then
         begin
         UnitsInfoAddLine(x,y,ai_teleporterR_u^.x,ai_teleporterR_u^.y,c_purple);
         //writeln(ai_teleporterR_d);
         end;

         if(ai_abase_d<NOTSET)then
         UnitsInfoAddLine(x,y,ai_abase_u^.x,ai_abase_u^.y,c_orange);

         UnitsInfoAddLine(x+_randomr(2),y+_randomr(2),uo_x+_randomr(2),uo_y+_randomr(2),c_white);
           }
         {writeln(ai_generator_d);
         if(ai_generator_d<NOTSET)then
         begin
            with ai_generator_cp^ do
              UnitsInfoAddLine(x,y,cpx,cpy,c_lime);
         end; }
      end;
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


