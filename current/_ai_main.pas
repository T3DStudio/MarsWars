
////////////////////////////////////////////////////////////////////////////////
//
//  COMMON
//

procedure ai_Suicide(pu:PTUnit);
begin
   unit_kill(pu,false,false,true,false,true);
end;

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
      if(ow=0)or(odist>base_r1)then
      begin
         uo_x:=ox;
         uo_y:=oy;
      end
      else
        if(ow<0)then
        begin
           if(ox=x)
           then uo_x:=ox+g_randomr(-ow)
           else uo_x:=ox+(sign(ox-x)*g_random(-ow));
           if(oy=y)
           then uo_x:=oy+g_randomr(-ow)
           else uo_y:=oy+(sign(oy-y)*g_random(-ow));
        end
        else
        begin
           uo_x:=ox-g_randomr(ow);
           uo_y:=oy-g_randomr(ow);
        end;
      uo_tar:=0;
   end;
end;

procedure ai_DefaultIdle(pu:PTUnit;force:boolean=false);
begin
   with pu^ do
   begin
      uo_x:=mm3i(1,uo_x,map_Size1);
      uo_y:=mm3i(1,uo_y,map_Size1);
      if(point_dist_rint(x,y,uo_x,uo_y)<srange)
      or(force)
      or(not isfly and (mapZone<>map_GetZone(uo_x,uo_y)))
      or(g_CheckRoyalBattlePoint(uo_x,uo_y,base_r1))
      then ai_RunTo(pu,-1,g_random(map_Size1),
                          g_random(map_Size1),0,nil);
   end;
end;

procedure ai_BaseIdle(pu:PTUnit;idle_r:integer);
begin
   if(ai_base_d=NOTSET)
   then ai_DefaultIdle(pu)
   else
     if(idle_r<ai_base_d)and(ai_base_d<NOTSET)
     then ai_RunTo(pu,ai_base_d,0,0,base_r1,ai_base_u)
     else
       with pu^ do
         if(point_dist_rint(x,y,uo_x,uo_y)<srange)then
           ai_RunTo(pu,-1,g_random(map_Size1),
                          g_random(map_Size1),0,nil);
end;

procedure ai_RunFrom(pu,tu:PTUnit;tx,ty:integer);
var
pdir,
px,py:integer;
begin
   if(tu<>nil)then
   begin
      tx:=tu^.x;
      ty:=tu^.y;
   end;
   with pu^ do
   begin
      pdir:=dir_MOD360(point_dir(tx,ty,x,y)+23) div 45;
      uo_x:=x+dir_stepX[pdir]*base_r1;
      uo_y:=y+dir_stepY[pdir]*base_r1;
   end;
end;

procedure ai_BuildOrder(pu:PTUnit);
begin
   with pu^  do
   with player^ do
   begin
      // energy
      ai_need_Energy:=1150+ai_curr_UnitProds*625;

      // upgrade prods
      ai_need_UpgrProds:=0;
      if(aip_MaxForges>0)then
      begin
         ai_need_UpgrProds:=res_energyl_max div 1500;

         if(ai_need_UpgrProds>ai_UpgradesLeft)then ai_need_UpgrProds:=ai_UpgradesLeft;
         if(ai_need_UpgrProds>aip_MaxForges  )then ai_need_UpgrProds:=aip_MaxForges;
      end;

      // unit prods
      ai_need_UnitProds:=0;
      if(aip_MaxBarracks>0)then
      begin
         ai_need_UnitProds:=(res_energyl_max div 425)-ai_need_UpgrProds;
         if(ai_need_UnitProds<1)then ai_need_UnitProds:=1;
         if(ai_need_UnitProds>aip_MaxBarracks)then ai_need_UnitProds:=aip_MaxBarracks;
      end;

      // teleport
      ai_need_Teleports:=(ai_armylimit_ForTeleport div ul15)+1;

      // DETECTORS
      if(ai_enemy_inv_u<>nil)
      then ai_need_detect:=aip_MaxDetectors
      else
      begin
         ai_need_detect:=ai_armylimit_alive_u div 8;
         if(ai_need_detect>aip_MaxDetectors)then
           ai_need_detect:=aip_MaxDetectors;
      end;

      if(isselected)then
      begin
         //writeln('ai_need_Energy=',ai_need_Energy,' ai_need_UnitProds=',ai_need_UnitProds,' ai_need_UpgrProds=',ai_need_UpgrProds);
         //writeln('ai_need_UnitProds=',ai_need_UnitProds,' ai_curr_UnitProds=',ai_curr_UnitProds);
        // writeln('ai_need_UpgrProds=',ai_need_UpgrProds,' ai_curr_UpgrProds=',ai_curr_UpgrProds);
      end;

   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  BUILDER
//

procedure ai_Builder(pBuilder:PTUnit);
var
build_uid : byte;
build_x,
build_y,
build_dir,
build_dirs,
build_step: integer;
rad_dir   : single;
skipEnergyCheck :boolean;
ckeckExtraEnergy:integer;

procedure ClearBuildDir;
begin
   build_dir :=-1;
   build_dirs:= 0;
   build_step:=-1;
end;

function SetBuildUID1(buid:byte;count:integer=MaxPlayerUnits):boolean;
var t:byte;
begin
   SetBuildUID1:=false;
   if(build_uid=0)then
     if(pBuilder^.player^.units_uid_e[buid]<count)then
       if(buid in pBuilder^.uid^.uid_prod_Buildings)then
       begin
          t:=CheckUnitReqs(pBuilder^.player,buid,ckeckExtraEnergy);
          if(t=0)or((t=lmt_Req_Energy)and(skipEnergyCheck))then
          begin
             SetBuildUID1:=true;
             build_uid  :=buid;
          end;
       end;
end;
function SetBuildUID2(buid1,buid2:byte):boolean;
begin
   with pBuilder^.player^  do
     if(units_uid_e[buid2]>=units_uid_e[buid1])
     then SetBuildUID1(buid1)
     else SetBuildUID1(buid2);

   if(build_uid=0)then
     if(not SetBuildUID1(buid1))
     then SetBuildUID1(buid2);

   SetBuildUID2:=build_uid<>0;
end;
function SetBuildUID3(buid1,buid2,buid3:byte):boolean;
begin
   with pBuilder^.player^  do
     if (units_uid_e[buid1]<=units_uid_e[buid2])
     and(units_uid_e[buid1]<=units_uid_e[buid3])
     then SetBuildUID1(buid1)
     else
       if (units_uid_e[buid2]<=units_uid_e[buid1])
       and(units_uid_e[buid2]<=units_uid_e[buid3])
       then SetBuildUID1(buid2)
       else SetBuildUID1(buid3);

   if(build_uid=0)then
     if(not SetBuildUID1(buid1))then
     if(not SetBuildUID1(buid2))then
            SetBuildUID1(buid3);

   SetBuildUID3:=build_uid<>0;
end;

procedure SetTowers(needN:integer);
begin
   if(build_uid>0)then exit;

   with pBuilder^  do
   with player^ do
   begin
      if(needN        <=ai_curr_Towers)
      or(aip_MaxTowers<=ai_curr_Towers)then exit;

      case race of
      r_hell: SetBuildUID3(UID_HFTower,UID_HSTower,UID_HTotem);
      r_uac : begin
                 if(aiu_alarm_d<base_r2)
                 and(ai_enemylimit_baseR2_grd>0)
                 and(ai_enemylimit_baseR2_fly>0)then
                   if(ai_enemylimit_baseR2_grd>=ai_enemylimit_baseR2_fly)
                   then SetBuildUID1(UID_UGTurret)
                   else SetBuildUID1(UID_UATurret);

                 if(build_uid=0)then SetBuildUID2(UID_UGTurret,UID_UATurret);
              end;
      end;

      if(build_uid=0)then exit;

      if(ai_keypoint_koth and(ai_keypoint_d<=keyPoint_KotR))
      or((map_scenario=mc_royale)and(u_royal_cd<base_r1h))then
      begin
         // default
      end
      else
        if(ai_generator_d<srange)then
        begin
           with ai_generator_kp^ do
           begin
              build_x:=kp_x-g_randomr(kp_RCapture);
              build_y:=kp_y-g_randomr(kp_RCapture);
           end;
        end
        else
          if(aiu_alarm_d<base_r2)then  // or KoTH or generator nearest
          begin
             build_dir :=point_dir(x,y,aiu_alarm_x,aiu_alarm_y);
             build_dirs:=22;
             build_step:=srange-g_random(g_uids[build_uid].uid_r);
          end;

   end;
end;
procedure SetGenerators(needL:integer);
begin
   if(build_uid>0)
   or(map_generators>0)then exit;

   with pBuilder^  do
   with player^ do
     if (ai_energy_future   <needL)
     and(ai_energy_future   <aip_MaxEnergy)
     and(ai_energy_future   <aic_GeneratorsEnergy)
     and(ai_generators_limit<aic_GeneratorsLimit)then
       case race of
       r_hell: SetBuildUID1(UID_HSymbol1);
       r_uac : SetBuildUID1(UID_UGenerator1);
       end;
end;

procedure SetBarracks(needN:integer);
begin
   if(build_uid>0)then exit;

   with pBuilder^  do
   with player^ do
     if (ai_curr_UnitProds<needN)
     and(ai_curr_UnitProds<aip_MaxBarracks)then
       case race of
       r_hell: SetBuildUID2(UID_HGate    ,UID_HBarracks);
       r_uac : SetBuildUID2(UID_UBarracks,UID_UFactory );
       end;
end;
procedure SetForges(needN:integer); //
begin
   if(build_uid>0)then exit;

   with pBuilder^  do
   with player^ do
     if (ai_curr_UnitProds>0)
     and(ai_curr_UpgrProds<needN)
     and(ai_curr_UpgrProds<aip_MaxForges)then
       case race of
       r_hell: SetBuildUID1(uid_HPools);
       r_uac : SetBuildUID1(UID_UWeaponFactory);
       end;
end;
procedure SetBuilders(needN:integer);
begin
   if(build_uid>0)then exit;

   with pBuilder^  do
   with player^ do
   begin
      if(units_bld_l[false]<aip_MaxArmyMinPart)
      then ckeckExtraEnergy:=400
      else ckeckExtraEnergy:=400;
      if (ai_curr_Builders<needN)
      and(ai_curr_Builders<aip_MaxBuilders )
      and(ai_curr_Builders<PlayerMaxBuilders)then
        case race of
        r_hell: if(ai_available_HKeep)
               and(units_builders_e=(aip_MaxBuilders-1))
               and((units_uid_e[UID_HKeep]+units_uid_e[UID_HAKeep])=0)
                then SetBuildUID1(UID_HKeep)
                else SetBuildUID2(UID_HKeep,UID_HCommandCenter);
        r_uac : SetBuildUID1(UID_UCommandCenter);
        end;
      ckeckExtraEnergy:=0;
   end;
end;
procedure SetDetectors(needL:longint);
begin
   if(build_uid>0)then exit;

   with pBuilder^  do
   with player^ do
     if (ai_curr_Detect<needL)
     and(ai_curr_Detect<aip_MaxDetectors)then
     begin
        case race of
        r_hell: SetBuildUID1(UID_HEyeNest);
        r_uac : SetBuildUID1(UID_URadar  );
        end;
        build_step:=srange;
     end;
end;
procedure SetTech;
begin
   if(build_uid>0)then exit;

   with pBuilder^  do
   with player^ do
     case race of
     r_hell: case g_random(3) of
             0: SetBuildUID1(UID_HPentagram,1);
             1: SetBuildUID1(UID_HMonastery,1);
             2: SetBuildUID1(UID_HFortress ,1);
             end;
     r_uac : case g_random(2) of
             0: SetBuildUID1(UID_UScienceCenter  ,1);
             1: SetBuildUID1(UID_UComputerStation,1);
             end;
     end;
end;
procedure SetTeleport;
begin
   if(build_uid>0)then exit;

   with pBuilder^  do
   with player^ do
     case race of
     r_hell: if(units_uid_e[UID_HTeleport]<ai_need_Teleports)then
               if(SetBuildUID1(UID_HTeleport))then
                 if(ai_HTeleportNearest_d<srange)then
                 begin
                    build_dir :=point_dir(x,y,ai_HTeleportNearest_u^.x,ai_HTeleportNearest_u^.y);
                    build_dirs:=20;
                 end;
     end;
end;
procedure SetSpecial;
begin
   if(build_uid>0)then exit;

   with pBuilder^  do
   with player^ do
     case race of
     r_hell: SetBuildUID1(UID_HAltar,1);
     r_uac : begin
                if(res_UACLoot  >1000)then SetBuildUID1(UID_UAcademy        ,1);
                if(res_HellPower>1000)then SetBuildUID1(UID_UHPowerConductor,1);
                SetBuildUID1(UID_URMStation,1);
             end;
     end;
end;
function NeedMaxTowers:boolean;
begin
   with pBuilder^  do
     NeedMaxTowers:=((aiu_alarm_d<base_r2)and(aiu_limitaround_ally<aiu_limitaround_enemy))
                  or(ai_keypoint_koth and(ai_keypoint_d<=keyPoint_KotR))
                  or((map_scenario=mc_royale)and(u_royal_cd<base_r1h));
end;

begin
   build_uid:=0;
   build_x  :=0;
   build_y  :=0;
   ClearBuildDir;
   skipEnergyCheck:=false;
   ckeckExtraEnergy:=0;

   with pBuilder^  do
   with player^ do
   begin
      // Define UID to build

      if((aip_flags and aif_base_smart_order)>0)then
      begin
         if(NeedMaxTowers)then
           SetTowers(aip_MaxTowers);
         if(ai_enemy_inv_u<>nil)then
           SetDetectors(aip_MaxDetectors);
         SetGenerators(500);
         if(aiu_alarm_d=NOTSET)then
           SetTeleport;
         SetBarracks  (1);
         SetBuilders  (aip_MaxBuilders  );
         SetGenerators(ai_need_Energy   );
         SetTeleport;
         SetTech;
         SetSpecial;
         SetForges    (ai_need_UpgrProds);
         SetBarracks  (ai_need_UnitProds);
         SetTowers    (aip_MinTowers    );
         SetDetectors (ai_need_Detect   );
      end
      else
        case g_random(8) of
        0 : if(NeedMaxTowers)
            then SetTowers(aip_MaxTowers)
            else SetTowers(aip_MinTowers);
        1 : SetGenerators(ai_need_Energy   );
        2 : SetBarracks  (ai_need_UnitProds);
        3 : SetForges    (ai_need_UpgrProds);
        4 : SetBuilders  (aip_MaxBuilders  );
        5 : SetTeleport;
        6 : SetTech;
        7 : SetSpecial;
        end;

      if(build_uid=0)then exit;

      // build
      if(build_x=0)then
      begin
         if(build_dir <0)then build_dir :=g_random(360);
         if(build_step<0)then build_step:=g_random(min2i(uid^.uid_r+(aiu_BuildAttempts div 5)*35,srange));

         if(build_dirs>0)then
           build_dir+=g_randomr(build_dirs);

         rad_dir:=build_dir*degtorad;
         build_x:=x+trunc(build_step*cos(rad_dir));
         build_y:=y-trunc(build_step*sin(rad_dir));
      end;
      BuildingFindNewPlace(build_x,build_y,build_uid,playeri,@build_x,@build_y);

      {if(isselected)then
      begin
         writeln('build_uid=',build_uid,' build_step=',build_step,' build_dir=',build_dir,' aiu_BuildAttempts=',aiu_BuildAttempts);
         UnitsInfo_AddLine(x,y,build_x,build_y,c_orange);
      end;  }

      if(unit_start_build(build_x,build_y,build_uid,playeri,true)<>lmt_prod_BadPlace)then
      begin
         if(ai_MinBuildAttempts=aiu_BuildAttempts)
         then ai_MinBuildAttempts:=0;
         aiu_BuildAttempts:=0;
      end
      else
        if(aiu_BuildAttempts<aiu_BuildAttempts.MaxValue)then
        begin
           if(ai_MinBuildAttempts=aiu_BuildAttempts)
           then ai_MinBuildAttempts+=1;
           aiu_BuildAttempts+=1;
        end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    FORGE
//

procedure ai_Forge(pFroge:PTUnit);
var i:byte;
procedure SetUpgrade(upid,lvl:byte);
var uip:integer;
begin
   if(upid>0)then
     with pFroge^     do
     with player^ do
     begin
        uip:=upgrs_cur[upid]+prod_upgr_upid[upid];
        if(uip<lvl)and(uip<aip_MaxUpgradeLevel)then unit_ProdStartUpgrade(pFroge,upid,false);
     end;
end;
begin
   with pFroge^ do
   with uid^    do
   with player^ do
     case uid_race of
     r_hell: begin
                if((aip_flags and aif_upgr_smart_order)>0)then
                begin
                   SetUpgrade(upgr_hell_BuilderR    ,1);
                   SetUpgrade(upgr_hell_HKeepShift  ,1);
                   SetUpgrade(upgr_hell_BuilderR    ,2);
                   SetUpgrade(upgr_hell_Spectre     ,1);
                   SetUpgrade(upgr_hell_DecayAura   ,1);
                   SetUpgrade(upgr_hell_Resurrect   ,1);
                   SetUpgrade(upgr_hell_Phantoms    ,1);

                   for i:=1 to aip_MaxUpgradeLevel do
                   begin
                      SetUpgrade(upgr_hell_PainFactor  ,i);
                      SetUpgrade(upgr_hell_EvilEyeR    ,i);
                      SetUpgrade(upgr_hell_Regeneration,i);
                      SetUpgrade(upgr_hell_UnitSightR  ,i);
                      SetUpgrade(upgr_hell_DistDamage1 ,i);
                      SetUpgrade(upgr_hell_DistDamage2 ,i);
                      SetUpgrade(upgr_hell_MeleeDamage ,i);
                      SetUpgrade(upgr_hell_UnitArmor   ,i);
                      SetUpgrade(upgr_hell_BuildArmor  ,i);
                   end;
                end;

                SetUpgrade(upgr_hell_DistDamage1+random(21),aip_MaxUpgradeLevel);
             end;
     r_uac : begin
                if((aip_flags and aif_upgr_smart_order)>0)then
                begin
                   SetUpgrade(upgr_uac_BuilderR     ,1);
                   SetUpgrade(upgr_uac_CCFly        ,1);
                   SetUpgrade(upgr_uac_BuilderR     ,2);
                   SetUpgrade(upgr_uac_SSMWeapon    ,1);
                   SetUpgrade(upgr_uac_CommandoInvis,1);
                   SetUpgrade(upgr_uac_CCAttack     ,1);
                   SetUpgrade(upgr_uac_DronTurret   ,1);
                   SetUpgrade(upgr_uac_TerAAWeapon  ,1);

                   for i:=1 to aip_MaxUpgradeLevel do
                   begin
                      SetUpgrade(upgr_uac_UnitSightR ,i);
                      SetUpgrade(upgr_uac_DistDamage ,i);
                      SetUpgrade(upgr_uac_BioArmor   ,i);
                      SetUpgrade(upgr_uac_MechArmor  ,i);
                      SetUpgrade(upgr_uac_RepairTools,i);
                      SetUpgrade(upgr_uac_MechSpeed  ,i);
                      SetUpgrade(upgr_uac_BuildArmor ,i);
                   end;
                end;

                SetUpgrade(upgr_uac_DistDamage  +random(21),aip_MaxUpgradeLevel);
             end;
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    BARRACKS
//

const

uprod_smart       = -1;
uprod_random      = -2;
uprod_AflyMech    = -3;
uprod_AFly        = -4;
uprod_AgroundMech = -5;
uprod_AgroundBio  = -6;


function ai_Barrack(pBarrack:PTUnit;utype,ucount:integer):boolean;
var
tuid,c:byte;
tuid_n,
tuid_m:integer;
tlimit:longint;
function CheckReq(auid:byte):boolean;
begin
   c:=CheckUnitReqs(pBarrack^.player,auid);
   CheckReq:=(c=0)or(c=lmt_Req_Energy);
end;
function tryUID(auid:byte;skipEnergyCheck:boolean=false):boolean;
begin
   c:=CheckUnitReqs(pBarrack^.player,auid);
   tryUID:=(c=0)or((c=lmt_Req_Energy)and(not skipEnergyCheck));
   if(tryUID)then tuid:=auid;
end;

function tryTransport:boolean;
begin
   tryTransport:=false;
   with pBarrack^ do
   with player^ do
     if(unum=units_uid_u[uidi])then
       if(CheckReq(UID_UTransport)and(ai_transport_cur<ai_transport_need))then
         tryTransport:=ai_Barrack(pBarrack,UID_UTransport,255);
end;
begin
   ai_Barrack:=false;
   tuid:=0;
   with pBarrack^ do
   with uid^    do
   with player^ do
   if((ai_armylimit_alive_u+prod_unit_Limit)<aip_MaxArmyLimit)then
   begin
      case utype of
uprod_smart      : begin
                      tlimit:=0;
                      utype :=0;
                      if(ai_enemylimit_flyMech   >tlimit)then begin tlimit:=ai_enemylimit_flyMech;   utype:=uprod_AflyMech;   end;
                      if(ai_enemylimit_fly       >tlimit)then begin tlimit:=ai_enemylimit_fly;       utype:=uprod_Afly;       end;
                      if(ai_enemylimit_groundMech>tlimit)then begin tlimit:=ai_enemylimit_groundMech;utype:=uprod_AgroundMech;end;
                      if(ai_enemylimit_groundBio >tlimit)then begin tlimit:=ai_enemylimit_groundBio; utype:=uprod_AgroundBio; end;

                      case utype of
                      uprod_AflyMech,
                      uprod_AFly,
                      uprod_AgroundMech,
                      uprod_AgroundBio : if(ai_Barrack(pBarrack,utype       ,255))then exit;
                      else               if(ai_Barrack(pBarrack,uprod_random,255))then exit;
                      end;

                      exit;
                   end;
uprod_AflyMech   : case race of
                   r_hell: if(not tryUID(UID_Arachnotron    ))then
                           if(not tryUID(UID_ZFPlasmagunner ))then
                           if(not tryUID(UID_Cacodemon      ))then
                           if(not tryUID(UID_ZAntiaircrafter))then
                           if(not tryUID(UID_Revenant       ))then exit;
                   r_uac : if(not tryUID(UID_Arachnotron    ))then exit;

                   end;
uprod_AFly       : case race of
                   r_hell: if(not tryUID(UID_ZAntiaircrafter))then
                           if(not tryUID(UID_Revenant       ))then exit;
                   r_uac : if(not tryUID(UID_Antiaircrafter ))then
                           if(not tryUID(UID_FPlasmagunner  ))then exit;
                   end;
uprod_AgroundMech: case race of
                   r_hell: if(not tryUID(UID_Arachnotron    ))then
                           if(not tryUID(UID_ZFPlasmagunner ))then
                           if(not tryUID(UID_Cacodemon      ))then exit;
                   r_uac : if(not tryUID(UID_FPlasmagunner  ))then
                           if(not tryUID(UID_UACDron        ))then exit;
                   end;
uprod_AgroundBio : case race of
                   r_hell: if(not tryUID(UID_Mastermind,true))then
                             case random(4) of
                             0: tuid:=UID_Imp;
                             1: tuid:=UID_Demon;
                             2: tuid:=UID_Knight;
                             3: tuid:=UID_Baron;
                             end;
                   r_uac : if(not tryUID(UID_Terminator,true))then
                             case random(5) of
                             0: tuid:=UID_Sergant;
                             1: tuid:=UID_SSergant;
                             2: tuid:=UID_Commando;
                             3: tuid:=UID_ZAntiaircrafter;
                             end;
                   end;
uprod_random     : case race of
                   r_hell: case random(23) of
                                0 : tuid:=UID_LostSoul;
                                1 : tuid:=UID_Imp;
                                2 : tuid:=UID_Demon;
                                3 : tuid:=UID_Cacodemon;
                                4 : tuid:=UID_Knight;
                                5 : tuid:=UID_Baron;
                                6 : tuid:=UID_Cyberdemon;
                                7 : tuid:=UID_Mastermind;
                                8 : tuid:=UID_Pain;
                                9 : tuid:=UID_Revenant;
                                10: tuid:=UID_Mancubus;
                                11: tuid:=UID_Arachnotron;
                                12: tuid:=UID_Archvile;
                                13: tuid:=UID_ZMedic;
                                14: tuid:=UID_ZEngineer;
                                15: tuid:=UID_ZSergant;
                                16: tuid:=UID_ZSSergant;
                                17: tuid:=UID_ZCommando;
                                18: tuid:=UID_ZAntiaircrafter;
                                19: tuid:=UID_ZSiegeMarine;
                                20: tuid:=UID_ZFPlasmagunner;
                                21: tuid:=UID_ZBFGMarine;
                                22: tuid:=UID_Phantom;
                           end;
                   r_uac : if(tryTransport)
                           then exit
                           else
                             case random(14) of
                                  0 : tuid:=UID_Medic;
                                  1 : tuid:=UID_Engineer;
                                  2 : tuid:=UID_Sergant;
                                  3 : tuid:=UID_SSergant;
                                  4 : tuid:=UID_Commando;
                                  5 : tuid:=UID_Antiaircrafter;
                                  6 : tuid:=UID_SiegeMarine;
                                  7 : tuid:=UID_FPlasmagunner;
                                  8 : tuid:=UID_BFGMarine;
                                  9 : tuid:=UID_UTransport;
                                  10: tuid:=UID_UACDron;
                                  11: tuid:=UID_Terminator;
                                  12: tuid:=UID_Tank;
                                  13: tuid:=UID_Flyer;
                             end;
                   end;
1..255           : tuid:=utype;
      end;

      tuid_n:=units_uid_e[tuid]+prod_unit_uid[tuid];

      if(tuid_n>=ucount)then exit;

      case tuid of
      UID_UTransport,
      UID_Pain,
      UID_BFGMarine,
      UID_ZBFGMarine,
      UID_ZMedic,
      UID_Medic,
      UID_ZEngineer,
      UID_Engineer  : tuid_m:=aic_max_SpecUID;
      else            tuid_m:=MaxUnits;
      end;

      if(tuid_n<tuid_m)then ai_Barrack:=unit_ProdStartUnit(pBarrack,tuid,false)=0;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    OTHER
//

function ai_NeedSuicide(pu:PTUnit):boolean;
var i:integer;
begin
   ai_NeedSuicide:=false;

   with pu^     do
   with uid^    do
   with player^ do
     if((ai_selfUID_nocomplete=0)and(    iscomplete))
     or((ai_selfUID_nocomplete>0)and(not iscomplete))then
       case uidi of
       UID_HSymbol1,
       UID_HSymbol2,
       UID_HSymbol3,
       UID_HSymbol4,
       UID_UGenerator1,
       UID_UGenerator2,
       UID_UGenerator3,
       UID_UGenerator4    : if (res_energyl_cur>uid_req_EnergyLevel)
                            and(res_energyl_max>aic_GeneratorsDestroyEnergy)
                            and(armylimit      >aic_GeneratorsDestoryLimit )then ai_NeedSuicide:=true;
       UID_HCommandCenter,
       UID_HACommandCenter: if ((units_uid_e[UID_HCommandCenter]+units_uid_e[UID_HACommandCenter])>=PlayerMaxBuilders)
                            and(ai_available_HKeep)then ai_NeedSuicide:=true;

       UID_UBarracks,
       UID_UFactory,
       UID_HBarracks,
       UID_HGate          : if(not ai_IsProducting(pu))then
                            begin
                               if(units_uid_c[uidi]>1)and(ai_selfUID_minLevel=level)then
                               begin
                                  i:=ai_GetLevel(pu)+1;
                                  if(uid_isbarrack)and((ai_curr_UnitProds-i)>ai_need_UnitProds)then ai_NeedSuicide:=true;
                                  if(uid_isforge  )and((ai_curr_UpgrProds-i)>ai_need_UpgrProds)then ai_NeedSuicide:=true;
                               end;
                               // destroy redundance barracks
                            end;
       else
          if(not uid_isbuilding)then
            if((MaxPlayerLimit-armylimit-prod_unit_Limit-ai_ownDead_limit)<ai_NeedFreeLimit)and(ai_enemy_d>base_r2)and(a_rld=0)then ai_NeedSuicide:=true;
       end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    UPGRADE/TRANSFORM ABILITIES
//

procedure ai_UpgradeAbilities(pu:PTUnit);
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      case uidi of
UID_HSymbol1,
UID_HSymbol2,
UID_HSymbol3,
UID_UGenerator1,
UID_UGenerator2,
UID_UGenerator3   : if(res_energyl_cur>=400)and(ai_curr_UnitProds>0)then
                    //or((prod_unit_Max>0)and(prod_unit_Max=prod_unit_Now)and(prod_upgr_Max=prod_upgr_Now))then
                      case uidi of
                      UID_HSymbol1   : ai_UnitAbility(pu,uab_ToHSymbol2   ,0,0,0);
                      UID_HSymbol2   : ai_UnitAbility(pu,uab_ToHSymbol3   ,0,0,0);
                      UID_HSymbol3   : ai_UnitAbility(pu,uab_ToHSymbol4   ,0,0,0);
                      UID_UGenerator1: ai_UnitAbility(pu,uab_ToUGenerator2,0,0,0);
                      UID_UGenerator2: ai_UnitAbility(pu,uab_ToUGenerator3,0,0,0);
                      UID_UGenerator3: ai_UnitAbility(pu,uab_ToUGenerator4,0,0,0);
                      end;
UID_HKeep,
UID_HCommandCenter,
UID_UCommandCenter: if(u_royal_d>base_r3)
                    or(map_scenario<>mc_royale)then
                      if (units_builders_c>1)
                      and(ai_curr_UnitProds>0)
                      and(res_energyl_cur>=1500)then
                        case uidi of
                        UID_HKeep         : ai_UnitAbility(pu,uab_ToHAKeep         ,0,0,0);
                        UID_HCommandCenter: ai_UnitAbility(pu,uab_ToHACommandCenter,0,0,0);
                        UID_UCommandCenter: ai_UnitAbility(pu,uab_ToUACommandCenter,0,0,0);
                        end;
UID_HGate,
UID_HBarracks,
UID_UBarracks,
UID_UFactory,
UID_HPools,
UID_UWeaponFactory: if(u_royal_d>base_r3)
                    or(map_scenario<>mc_royale)then
                      if(not ai_IsProducting(pu))then
                        case uidi of
                        UID_HGate         : ai_UnitAbility(pu,uab_ToHGate         ,0,0,0);
                        UID_HBarracks     : ai_UnitAbility(pu,uab_ToHBarracks     ,0,0,0);
                        UID_UBarracks     : ai_UnitAbility(pu,uab_ToUBarracks     ,0,0,0);
                        UID_UFactory      : ai_UnitAbility(pu,uab_ToUFactory      ,0,0,0);
                        UID_HPools        : ai_UnitAbility(pu,uab_ToHPools        ,0,0,0);
                        UID_UWeaponFactory: ai_UnitAbility(pu,uab_ToUWeaponFactory,0,0,0);
                        end;

UID_URadar        : ai_UnitAbility(pu,uab_LvlUpURadar    ,0,0,0);
UID_URMStation    : ai_UnitAbility(pu,uab_LvlUpURMStation,0,0,0);
      end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    OTHER ABILITIES
//

procedure ai_ability_TowerBlink2Dir(pCaster:PTunit;tx,ty,tStep,tdirSpread:integer);
var tdir:integer;
begin
   with pCaster^ do
   begin
      tdir:=point_dir(x,y,tx,ty)+tdirSpread;
      tx:=x+trunc(tStep*cos(tdir*DEGTORAD));
      ty:=y-trunc(tStep*sin(tdir*DEGTORAD));
      ai_UnitAbility(pCaster,uab_HTowerBlink,0,tx,ty);
   end;
end;
function ai_ability_KeepShift(pCaster:PTunit;tx,ty:integer):boolean;
begin
   with pCaster^ do
   begin
      ai_ability_KeepShift:=ai_UnitAbility(pCaster,uab_HKeepShift,0,tx,ty);
      aiu_BuildAttempts:=0;
   end;
end;

function ai_ability_CCLift(pCaster:PTunit):boolean;
begin
   ai_ability_CCLift:=false;
   with pCaster^ do
   begin
      case uidi of
      UID_HCommandCenter,
      UID_HACommandCenter: ai_ability_CCLift:=ai_UnitAbility(pCaster,uab_HellCCLand,0,0,0);
      UID_UCommandCenter,
      UID_UACommandCenter: ai_ability_CCLift:=ai_UnitAbility(pCaster,uab_UACCCLand ,0,0,0);
      end;
      aiu_BuildAttempts:=0;
   end;
end;

function ai_AbilityMagic(pCaster,pTarget:PTUnit;aid:byte):boolean;
begin
   ai_AbilityMagic:=false;
   if(pTarget<>nil)then
     with pTarget^ do
       ai_AbilityMagic:=ai_UnitAbility(pCaster,aid,unum,x,y);
end;

procedure ai_AbilitiesCommon(pCaster:PTunit);
var
cx,cy,cd:integer;
begin
   cd:=NOTSET;
   with pCaster^ do
   with uid^    do
   with player^ do
     case uidi of
     UID_HFTower,             //ai_generator_d
     UID_HSTower,
     UID_HTotem      : if(a_rld<=0)then
                       begin
                          if(ai_keypoint_d<NOTSET)and(ai_keypoint_koth)then
                            with ai_keypoint_kp^ do
                            begin
                               if(ai_keypoint_d<kp_RCapture)then exit;
                               if(ai_keypoint_d<cd)then
                               begin
                                  cx:=kp_x;
                                  cy:=kp_y;
                                  cd:=ai_keypoint_d;
                               end;
                            end;
                          if(ai_generator_d<NOTSET)then
                            with ai_generator_kp^ do
                            begin
                               if(ai_generator_d<=kp_RCapture)then exit;
                               if(ai_generator_d<cd)then
                               begin
                                  cx:=kp_x;
                                  cy:=kp_y;
                                  cd:=ai_generator_d;
                               end;
                            end;
                          if(aiu_alarm_d<NOTSET)then
                          begin
                             if(aiu_alarm_d<srange)then exit;
                             if(aiu_alarm_d<cd)then
                               if(aiu_alarm_d<base_r2)
                               or((aip_flags and aif_ability_TowerRush)>0)then
                               begin
                                  cx:=aiu_alarm_x;
                                  cy:=aiu_alarm_y;
                                  cd:=aiu_alarm_d;
                               end;
                          end;

                          if(cd<NOTSET)
                          then ai_ability_TowerBlink2Dir(pCaster,cx,cy,cd,g_randomr(30))  //srange
                          else
                            if(srange<ai_base_d)and(ai_base_d<NOTSET)then
                              if(aiu_alarm_d=NOTSET)then
                                ai_ability_TowerBlink2Dir(pCaster,ai_base_u^.x,ai_base_u^.y,min2i(cd,srange),g_randomr(30));
                       end;
     UID_HAltar      : if(aip_timer_magic=0)then
                       begin
                          if(ai_AbilityMagic(pCaster,ai_SphereTurbo_u  ,uab_SphereTurbo  ))then aip_timer_magic:=aip_pause_magic;
                          if(ai_AbilityMagic(pCaster,ai_SphereDDamage_u,uab_SphereDDamage))then aip_timer_magic:=aip_pause_magic;
                          if(ai_AbilityMagic(pCaster,ai_SphereRDamage_u,uab_SphereRDamage))then aip_timer_magic:=aip_pause_magic;
                       end;
     UID_UHPowerConductor
                     : if(aip_timer_magic=0)then
                       begin
                          if(ai_AbilityMagic(pCaster,ai_SphereInvuln_u ,uab_SphereInvuln ))then aip_timer_magic:=aip_pause_magic;
                          if(ai_AbilityMagic(pCaster,ai_SphereSoul_u   ,uab_SphereSoul   ))then aip_timer_magic:=aip_pause_magic;
                          if(ai_AbilityMagic(pCaster,ai_SphereInvis_u  ,uab_SphereInvis  ))then aip_timer_magic:=aip_pause_magic;
                       end;
     UID_UAcademy    : if(aip_timer_magic=0)then
                       begin
                          if(ai_AbilityMagic(pCaster,ai_Heroic_u       ,uab_PretorEquip  ))then aip_timer_magic:=aip_pause_magic;
                       end;
     UID_URMStation  : if(aip_timer_superweapon=0)then
                       begin
                          if(ai_AbilityMagic(pCaster,ai_Strike_u       ,uab_UACStrike    ))then aip_timer_superweapon:=aip_pause_superweapon;
                       end;
     end;

   if(ai_Bribe_u<>nil)
   or(ai_Hack_u <>nil)then
     if(IsUnitRange(pCaster^.player^.units_uid_u[UID_UAcademy],@pCaster))then
       with pCaster^.player^ do
       begin
          if(ai_Bribe_u<>nil)then
            if(ai_UnitAbility(pCaster,uab_Bribe,ai_Bribe_u^.unum,0,0))then aip_timer_magic:=aip_pause_magic;
          if(ai_Hack_u <>nil)then
            if(ai_UnitAbility(pCaster,uab_Hack ,ai_Hack_u^ .unum,0,0))then aip_timer_magic:=aip_pause_magic;
       end;

   if(ai_HEyeNest_u<>nil)and(ai_near_HEye=0)then
     with pCaster^ do
     with player^ do
       if(ai_UnitAbility(ai_HEyeNest_u,uab_HEyeSpawn,0,x,y))then aip_timer_magic:=aip_pause_magic;
end;


procedure ai_AbilitiesDetection(pCaster:PTunit);
begin
   with pCaster^ do
   with uid^    do
   with player^ do
     case uidi of
     UID_HEyeNest: begin
                      if(ai_need_heye_d<NOTSET)then
                        if(ai_UnitAbility(pCaster,uab_HEyeVision,ai_need_heye_u^.unum,0,0))then
                          aip_timer_detection:=aip_pause_detection;
                      // ai_HEyeNest_u
                   end;
     UID_URadar  : if(ai_enemy_inv_d<NOTSET)then
                     if(ai_UnitAbility(pCaster,uab_UACScan   ,0,ai_enemy_inv_u^.x,ai_enemy_inv_u^.y))then
                       aip_timer_detection:=aip_pause_detection;
     end;
end;

procedure ai_AbilitiesBuilderMove(pBuilder:PTUnit);
const
met_koth   = 1;
met_royale = 2;
met_hits   = 3;
met_build  = 4;
var
ldir,lx,ly:integer;
alarmType :byte;
function moveEventType:byte;
begin
   moveEventType:=0;
   case map_scenario of
   mc_koth  : if(ai_choosen)and(ai_keypoint_koth)and(ai_keypoint_d<NOTSET)then
                with ai_keypoint_kp^ do
                  if(kp_RCapture<ai_keypoint_d)or(pBuilder^.isfly)then
                  begin
                     moveEventType:=met_koth;
                     exit;
                  end;
   mc_royale: case pBuilder^.isfly of
              true : if(ai_choosen)
                     or(u_royal_d<base_r1h)then
                     begin
                        moveEventType:=met_royale;
                        exit;
                     end;
              false: if(ai_choosen)
                     or(u_royal_d<base_r1)then
                     begin
                        moveEventType:=met_royale;
                        exit;
                     end;
              end;
   end;

   with pBuilder^ do
     if(not ai_keypoint_koth)
     or(ai_keypoint_d>keyPoint_KotR)then
       if(aiu_alarm_d<base_r2)and(ai_curr_Builders<PlayerMaxBuilders)and(hits<uid^.uid_MaxHitsh)then
       begin
          moveEventType:=met_hits;
          exit;
       end;

   with pBuilder^ do
     if(not pBuilder^.isfly)then
       if(ai_MinBuildAttempts>50)and(ai_MinBuildAttempts=aiu_BuildAttempts)then
       begin
          moveEventType:=met_build;
          exit;
       end;
end;
function checkLandingPlace(lx,ly,lr:integer):boolean;
begin
   checkLandingPlace:=false;
   with pBuilder^ do
   with uid^ do
   begin
      if(point_dist_int(uo_x,uo_y,lx,ly)>=lr)then exit;
      if(CheckCollisionR(uo_x,uo_y,uid_r,unum,uid_isbuilding,false,true,255,pBuilder)<>cbr_no)then exit;
   end;
   checkLandingPlace:=true;
end;
procedure setLandingPlace(lx,ly,ld,lr:integer);
begin
   with pBuilder^ do
   with uid^ do
     if(ld>lr)then
     begin
        uo_x:=lx;
        uo_y:=ly;
     end
     else
       if(checkLandingPlace(lx,ly,lr))then
       begin
          if(point_dist_int(x,y,uo_x,uo_y)<uid_r)then
          begin
             uo_id :=ua_ability2;
             uo_tar:=0;
          end
          else uo_id:=ua_amove;
       end
       else
       begin
          uo_x:=lx-g_randomr(lr);
          uo_y:=ly-g_randomr(lr);
          math_push_out(uo_x,uo_y,uid_r,unum,@uo_x,@uo_y,false,true,playeri );
       end;
end;

begin
   alarmType:=moveEventType;
   {if(pBuilder^.isselected)then
   begin
      writeln('alarmType ',alarmType,' ai_base_d=',ai_base_d,' base_r1=',base_r1);
      //writeln('ai_choosen ',ai_choosen,' ai_keypoint_koth=',ai_keypoint_koth,' ai_keypoint_d=',ai_keypoint_d);
   end;}
   with pBuilder^ do
   with uid^    do
   with player^ do
     case uidi of
     UID_HKeep,
     UID_HAKeep         : case alarmType of
                          met_koth  : with ai_keypoint_kp^ do
                                        ai_ability_KeepShift(pBuilder,kp_x+g_randomr(keyPoint_KotRW),
                                                                      kp_y+g_randomr(keyPoint_KotRW));
                          met_royale: begin
                                         lx:=min2i(g_royal_r div 4,base_r1h);
                                         ai_ability_KeepShift(pBuilder,map_sizeH+g_randomr(lx),
                                                                       map_sizeH+g_randomr(lx));
                                      end;
                          met_hits  : begin
                                         lx:=g_random(map_size1);
                                         ly:=g_random(map_size1);
                                         if(not ai_alarm_CheckPoint(pBuilder,lx,ly,base_r2))then
                                           ai_ability_KeepShift(pBuilder,lx,ly);
                                      end;
                          met_build : begin
                                         if(aiu_alarm_d<base_r4)
                                         then ldir:=point_dir(aiu_alarm_x,aiu_alarm_y,x,y)-g_randomr(45)
                                         else ldir:=g_random(360);
                                         ai_ability_KeepShift(pBuilder,
                                            x+trunc((srange+uid_r)*cos(ldir*degtorad)),
                                            y-trunc((srange+uid_r)*sin(ldir*degtorad)));
                                      end;
                          end;
     UID_HCommandCenter,
     UID_HACommandCenter,
     UID_UCommandCenter,
     UID_UACommandCenter: if(zfall=0)then
                            case isfly of
                            true : case alarmType of
                                   met_koth  : with ai_keypoint_kp^ do
                                                 setLandingPlace(kp_x,kp_y,ai_keypoint_d,keyPoint_KotRW);
                                   met_royale: begin
                                                  lx:=min2i(g_royal_r div 4,base_r1h);
                                                  setLandingPlace(map_sizeH,map_sizeH,u_royal_d,lx);
                                               end;
                                   met_hits  : ai_RunFrom(pBuilder,nil,aiu_alarm_x,aiu_alarm_y);
                                   // met_build
                                   else
                                      if(ai_base_d<NOTSET)
                                      then setLandingPlace(ai_base_u^.x,ai_base_u^.y,ai_base_d,base_r1)
                                      else setLandingPlace(x,y,0,base_r1h);
                                   end;
                            false: if(alarmType>0)then ai_ability_CCLift(pBuilder);
                            end;
     end;
end;

procedure ai_Cancel_Prod(pu:PTUnit);
begin
   with pu^     do
   with uid^    do
   with player^ do
     if(prod_unit_Now>0)then
     begin
        if(uid_isbarrack)then unit_ProdStopUnit(pu,255,false,true,false);
     end
     else
       if(prod_upgr_Now>0)then
       begin
          if(uid_isforge)then unit_ProdStopUpgrade(pu,255,false,false);
       end
       else
         if(ai_UnitsInTransform>0)then
         begin
            if(transformTimer>0)then unit_TransformStop(pu,false);
         end
         else
           if(not iscomplete)
           then ai_Suicide(pu);
end;

procedure ai_Local_Code(pu:PTUnit);
var i:integer;
    l:longint;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      //if(isselected)and(ai_enemy_d<NOTSET)then UnitsInfo_AddLine(x+1,y,ai_enemy_u^.x,ai_enemy_u^.y+1,c_orange);

      // correct alarm in position
      i:=max2i(200,srange);
      if(ai_enemy_d>=srange)then ai_Alarm_SetForTeam(team,x,y,0,i,false,0);// erase alarm point here
      if(ai_enemy_d<NOTSET)then
      begin
         with ai_enemy_u^ do
         begin
            l:=uid^.uid_LimitUse;
            if(ai_enemy_d<srange)then l+=aiu_limitaround_enemy;
            ai_Alarm_SetForTeam(team,x,y,l,i,uid^.uid_isbuilding,mapZone);
         end;
         ai_Local_SetCurrentAlarm(pu,ai_enemy_u,0,0,ai_enemy_d,0);
      end;

      // base alarm
      for i:=0 to ai_LastAlarm do
        with ai_TeamAlarms[team,i] do
          if(aia_limit>0)then
            if(uid_isfly)
            or(isfly)
            or(aia_zone=mapZone)
            or(uid_isbarrack)then ai_Local_SetCurrentAlarm(pu,nil,aia_x,aia_y,point_dist_int(aia_x,aia_y,x,y),aia_zone);

      //aiu_alarm_timer
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    BUILDINGS AI
//

procedure ai_Global_Buildings(pu:PTUnit);
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      ai_BuildOrder(pu);

      if(uid_isbuilder)and(not isfly)and(zfall=0)then ai_Builder(pu);

      //if(isselected)then
      //  if(ai_HTeleportNearest_u<>nil)then UnitsInfo_AddLine(x,y,ai_HTeleportNearest_u^.x,ai_HTeleportNearest_u^.y,c_lime);
      //if(isselected)then writeln('ai_selfUID_minLevel=',ai_selfUID_minLevel,'  ai_selfUID_nocomplete=',ai_selfUID_nocomplete);
      {if(isselected)then
      begin
         if(ai_generator_d<NOTSET)then
           with ai_generator_kp^ do UnitsInfo_AddLine(x,y,kp_x,kp_y,c_blue);
         if(ai_keypoint_d<NOTSET)then
           with ai_keypoint_kp^ do UnitsInfo_AddLine(x+2,y,kp_x,kp_y,c_green);
         //if(ai_base_d<NOTSET)then UnitsInfo_AddLine(x,y,ai_base_u^.x,ai_base_u^.y,c_lime);
      end;}

      if((aip_flags and aif_base_suicide)>0)then
        if(ai_NeedSuicide(pu))then
        begin
           ai_Suicide(pu);
           exit;
        end;

      if(res_energyl_cur<0)then
      begin
         ai_Cancel_Prod(pu);
         exit;
      end;

      if(not iscomplete)then exit;

      if(uid_isforge  )and(aip_MaxUpgradeLevel>0)then ai_Forge  (pu);
      if(uid_isbarrack)and(aip_MaxArmyLimit   >0)then
        if((aip_flags and aif_army_smart_order)>0)
        then ai_Barrack(pu,uprod_smart,255)
        else ai_Barrack(pu,uprod_random  ,255);

      // Transformation
      if(ai_flags_BaseAdvance)then
      begin
         if(transformTimer<=0)then
           ai_UpgradeAbilities(pu);
         if(transformTimer>0)then exit;
      end;

      {if(isselected)and(ai_enemy_inv_d<NOTSET)then
      begin
         UnitsInfo_AddLine(x,y,ai_enemy_inv_u^.x,ai_enemy_inv_u^.y+1,c_blue);
         UnitsInfo_AddLine(x+2,y,uo_x,uo_y+2,c_yellow);
      end; }

      if(aip_timer_detection=0)then
        if((aip_flags and aif_ability_detection)>0)then ai_AbilitiesDetection(pu);
      if(uid_isbuilder)then
      if((aip_flags and aif_base_BuilderMove )>0)then ai_AbilitiesBuilderMove(pu);
      if((aip_flags and aif_ability_other    )>0)then ai_AbilitiesCommon(pu);
   end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//    UNITS AI
//

procedure ai_Global_Units(pu:PTUnit);
var
tar_dist,
tar_x,
tar_y,
tar_r     :integer;
tar_weight:byte;
tar_zone  :word;
////  GROUP ACTIONS
procedure MainTargetClear;
begin
   tar_weight:=0;
   tar_dist  :=NOTSET;
end;
procedure MainTargetSet(tu:PTUnit;tx,ty,tdist:integer;tz:word;tweight:byte;tr:integer=0);
begin
   if(tu<>nil)then
   begin
      tx:=tu^.x;
      ty:=tu^.y;
      tz:=tu^.mapZone;
   end;
   with pu^ do
     if(mapZone=tz)or(tdist<base_r1)or(isfly)then
     begin
        if(tweight>tar_weight)
        then
        else
          if(tweight<tar_weight)
          then exit
          else
            if(tdist<tar_dist)
            then
            else exit;

        tar_x     :=tx;
        tar_y     :=ty;
        tar_r     :=tr;
        tar_dist  :=tdist;
        tar_zone  :=tz;
        tar_weight:=tweight;
     end;
end;
function MainTargetGo(wrect:integer):boolean;
begin
   MainTargetGo:=false;
   if(tar_dist<NOTSET)then
   begin
      MainTargetGo:=true;
      ai_RunTo(pu,tar_dist,tar_x,tar_y,wrect,nil);
   end;
end;
function FollowCommander(onlyMyLevel:boolean=false):boolean;
var
commander_d:integer;
commander_u:PTUnit;
begin
   commander_d:=NOTSET;
   commander_u:=nil;
   if(pu^.isfly)then
   begin
      commander_u:=ai_commander_fly_u;
      commander_d:=ai_commander_fly_d;
      if(ai_commander_grd_u<>nil)and(not onlyMyLevel)then
        if(ai_commander_grd_u^.group<>aic_group_AttackWait)then
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
     ai_RunTo(pu,commander_d,0,0,-pu^.srange,commander_u);

   //with pu^ do if(isselected)then writeln('FollowCommander ',FollowCommander,' ',commander_u=pu,' ',ai_commander_fly_u<>nil,' ',ai_commander_grd_u<>nil,' ',commander_u=ai_commander_fly_u,' ',commander_u=ai_commander_grd_u);
end;
function TryTeleporting(toU:PTUnit):boolean;
begin
   TryTeleporting:=false;
   if(ai_HTeleportNearest_d<base_r2)then
   begin
      TryTeleporting:=true;
      pu^.uo_x:=ai_HTeleportNearest_u^.x;
      pu^.uo_y:=ai_HTeleportNearest_u^.y;
      if(ai_HTeleportNearest_d<ai_HTeleportNearest_u^.uid^.uid_r)then
      begin
         ai_HTeleportNearest_u^.rpoint_tar:=toU^.unum;
         unit_ability_teleport(pu,ai_HTeleportNearest_u,ai_HTeleportNearest_d);
      end;
   end;
end;
function DefendBase:boolean;
begin
   DefendBase:=false;

   if(ai_BDefend_d<NOTSET)then
     with ai_BDefend_u^ do
     begin
        DefendBase:=true;
        if(pu^.isfly)
        then ai_RunTo(pu,ai_BDefend_d,aiu_alarm_x,aiu_alarm_y,0,nil)
        else
          if(pu^.mapZone=mapZone)then
          begin
             if(ai_BDefend_d>base_r6)then
                if(TryTeleporting(ai_BDefend_u))then exit;
             ai_RunTo(pu,ai_BDefend_d,aiu_alarm_x,aiu_alarm_y,0,nil)
          end
          else DefendBase:=TryTeleporting(ai_BDefend_u);
     end;
end;
function TransportLoadForDefend:boolean;
begin
   TransportLoadForDefend:=false;
   with pu^ do
     if(ai_TransportTar_BDefend_d<NOTSET)then
       if(pu^.mapZone<>ai_BDefend_u^.mapZone)or(ai_BDefend_d>base_r5)then
         if(ai_TransportTar_BDefend_d<ai_BDefend_d)
         or(transportC<=0)then
         begin
            TransportLoadForDefend:=true;
            uo_x:=ai_TransportTar_BDefend_u^.x;
            uo_y:=ai_TransportTar_BDefend_u^.y;
            if(ai_TransportTar_BDefend_d<50)
            then uo_tar:=ai_TransportTar_BDefend_u^.unum
            else uo_tar:=0;
         end;
end;
function TransportDefendBase:boolean;
begin
   TransportDefendBase:=false;
   if(ai_BDefend_d<NOTSET)then
     if(not TransportLoadForDefend)then
       if(pu^.transportC>0)then
       begin
          ai_RunTo(pu,ai_BDefend_d,0,0,pu^.srange,ai_BDefend_u);
          TransportDefendBase:=true;
       end;
   //with pu^ do if(isselected)then writeln('TransportDefendBase ',TransportDefendBase);
end;
function TransportAttackCommon(load_u:PTUnit;load_d:integer;myGroup:byte):boolean;
begin
   TransportAttackCommon:=false;
   with pu^ do
     if(tar_dist<NOTSET)then
       if(myGroup=255)
       or(myGroup=group)then
         if(load_d=NOTSET)
         or((tar_dist<load_d)and(transportC>0))then
         begin
            if(transportC>0)then
              if(tar_dist<base_r1)then
              begin
                 uo_id:=unit_Ability2Act(pu,uab_Unload);
                 if(not FollowCommander(true))then
                   MainTargetGo(base_r1);
                 TransportAttackCommon:=true;
              end
              else
              begin
                 if(not FollowCommander(true))then
                   MainTargetGo(base_r1);
                 TransportAttackCommon:=true;
              end;
         end
         else
         begin
            uo_x:=load_u^.x;
            uo_y:=load_u^.y;
            if(load_d<50)
            then uo_tar:=load_u^.unum
            else uo_tar:=0;
            TransportAttackCommon:=true;
         end;
   {with pu^ do
     if(isselected)then
     begin
        writeln('TransportAttackCommon ',load_d,' ',myGroup);
        if(ai_commander_fly_d<NOTSET)then
          UnitsInfo_AddLine(x,y,ai_commander_fly_u^.x,ai_commander_fly_u^.y,c_aqua);
     end; }
end;
function TransportDropAndRunOut:boolean;
begin
   TransportDropAndRunOut:=false;
   with pu^ do
     case(transportC>0)of
     true : if(tar_dist<base_r1)and(tar_zone=mapZone)then
            begin
               MainTargetGo(-base_r1);
               uo_id:=unit_Ability2Act(pu,uab_Unload);
               TransportDropAndRunOut:=true;
            end;
     false: if(ai_enemy_d<base_r1)then
            begin
               ai_RunFrom(pu,ai_enemy_u,0,0);
               TransportDropAndRunOut:=true;
            end;
     end;
   //with pu^ do if(isselected)then writeln('TransportDropAndRunOut ',TransportDropAndRunOut);
end;
////  SET GROUPS
procedure SetGroupsForBase;
var tlimit:longint;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if ((aip_flags and aif_army_scout)>0)
      and(ai_group_ucount[aic_group_Scout]=0)
      and(ai_scout_u=pu)
      and(ai_enemy_d>base_r2)
      then
      begin
         group:=aic_group_Scout;
         exit;
      end;

      if(transportM<=0)and(ai_generator_d<NOTSET)and(uid_LimitUse<=ul10)then
      begin
         tlimit:=ai_group_ulimit[aic_group_base]+ai_group_ulimit[aic_group_KeyPointAssault];
         if (tlimit>=aip_MaxArmyMinPart)
         and(ai_group_ulimit[aic_group_KeyPointAssault]<aip_MaxArmyMinPart)then
         begin
            group:=aic_group_KeyPointAssault;
            exit;
         end;
      end;

      if(units_bld_l[true]<=0)then group:=aic_group_AttackNow;
   end;
end;
////
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      uo_id :=ua_amove;
      uo_tar:=0;

      if(res_energyl_cur<0)then
      begin
         ai_Cancel_Prod(pu);
         exit;
      end;

      //if(isselected)then writeln(ai_NeedLimitForTransport,' ',ai_enemy_d>base_r2,' ',-ai_ownDead_limit,' ',(armylimit+prod_unit_Limit)>(MaxPlayerLimit-g_uids[UID_HTeleport].uid_LimitUse));

      if(ai_NeedSuicide(pu))then
      begin
         ai_Suicide(pu);
         exit;
      end;

      if(not iscomplete)then exit;

      MainTargetClear;

      // SET GROUP
      if(transportM>0)then
        if(ai_group_ucount[aic_group_AttackNow ]>0)
        or(ai_group_ucount[aic_group_AttackWait]>0)
        then group:=aic_group_TransportAttack
        else group:=aic_group_TransportBase;
      case group of
      aic_group_base           : SetGroupsForBase;
      aic_group_AttackNow,
      aic_group_AttackWait     : if (aiu_alarm_d   =NOTSET)
                                 and(ai_generator_d=NOTSET)
                                 and(ai_keypoint_d =NOTSET)
                                 then group:=aic_group_AttackWait
                                 else group:=aic_group_AttackNow;
      aic_group_Scout          : if((aip_flags and aif_army_scout)=0)
                                 then group:=aic_group_base
                                 else
                                   if(ai_scout_u<>pu)and(ai_base_d<base_r1)
                                   then group:=aic_group_base;
      aic_group_KeyPointAssault,
      aic_group_KeyPointGuard  : if((ai_generator_d=NOTSET)
                                 and(ai_keypoint_d =NOTSET))
                                 or(uid_LimitUse>ul10)
                                 then group:=aic_group_base;
      aic_group_TransportAttack,
      aic_group_TransportBase  : if(transportM<=0)then group:=aic_group_base;
      else  group:= aic_group_base;
      end;

      // GROUP ACTIONS
      case group of
      aic_group_TransportBase,
      aic_group_TransportAttack: begin
                                    if(ai_keypoint_d<NOTSET)then
                                      with ai_keypoint_kp^ do
                                        MainTargetSet(nil,kp_x,kp_y,ai_keypoint_d ,kp_zone,1,kp_RCapture);
                                    MainTargetSet(nil,aiu_alarm_x,aiu_alarm_y,aiu_alarm_d,aiu_alarm_zone,1);

                                    if(not TransportDropAndRunOut)then
                                      if(not TransportDefendBase)then
                                        if(not TransportAttackCommon(ai_TransportTar_Attack_u,ai_TransportTar_Attack_d,aic_group_TransportAttack))then
                                          if(not TransportAttackCommon(ai_TransportTar_BDefend_u,ai_TransportTar_BDefend_d,255))then
                                            if(not FollowCommander)then
                                            begin
                                               ai_BaseIdle(pu,aic_BaseIdle_r);
                                               if(ai_Base_d<srange)
                                               or(ai_Base_d=NOTSET)
                                               then uo_id:=unit_Ability2Act(pu,uab_Unload);
                                            end;
                                 end;
      aic_group_KeyPointGuard,
      aic_group_KeyPointAssault: begin
                                    if(ai_generator_d<NOTSET)then
                                      with ai_generator_kp^ do
                                        MainTargetSet(nil,kp_x,kp_y,ai_generator_d,kp_zone,1,round(kp_RCapture*0.6));
                                    if(ai_keypoint_d<NOTSET)then
                                      with ai_keypoint_kp^ do
                                        MainTargetSet(nil,kp_x,kp_y,ai_keypoint_d ,kp_zone,1,round(kp_RCapture*0.6));

                                    if(tar_dist=NOTSET)
                                    then group:=aic_group_base
                                    else
                                      case group of
                                      aic_group_KeyPointGuard  : if(tar_dist>srange)then
                                                                 begin
                                                                    group:=aic_group_KeyPointAssault;
                                                                    MainTargetGo(0);
                                                                 end
                                                                 else MainTargetGo(tar_r);
                                      aic_group_KeyPointAssault: if(tar_dist<tar_r)then
                                                                 begin
                                                                    group:=aic_group_KeyPointGuard;
                                                                    MainTargetGo(0);
                                                                 end
                                                                 else
                                                                   if(not FollowCommander)then
                                                                     MainTargetGo(0);
                                      end;
                                 end;
      aic_group_base           : if(not DefendBase)then
                                   if(not FollowCommander)then
                                   begin
                                      MainTargetSet(nil,aiu_alarm_x,aiu_alarm_y,aiu_alarm_d,aiu_alarm_zone,1);
                                      if(tar_dist<srange)
                                      then MainTargetGo(0)
                                      else ai_BaseIdle(pu,aic_BaseIdle_r);
                                   end;
      aic_group_AttackNow      : begin
                                    if(ai_keypoint_d<NOTSET)then
                                      with ai_keypoint_kp^ do
                                        MainTargetSet(nil,kp_x,kp_y,ai_keypoint_d ,kp_zone,1,round(kp_RCapture*0.6));
                                    MainTargetSet(nil,aiu_alarm_x,aiu_alarm_y,aiu_alarm_d,aiu_alarm_zone,1);

                                    if(tar_dist<=base_r1h)
                                    then MainTargetGo(0)
                                    else
                                      if(not FollowCommander)then
                                        MainTargetGo(0);
                                 end;
      aic_group_AttackWait     : if(not DefendBase)then
                                   if(ai_HTeleportNearest_u<>nil)then
                                   begin
                                      if(isselected)then
                                      begin
                                         if(ai_HTeleportTarget_u<>nil)then
                                           UnitsInfo_AddLine(x,y,ai_HTeleportTarget_u^.x,ai_HTeleportTarget_u^.y,c_aqua);

                                         UnitsInfo_AddLine(x,y,ai_HTeleportNearest_u^.x,ai_HTeleportNearest_u^.y,c_orange);

                                      end;
                                      if(ai_HTeleportTarget_u<>nil)
                                      then TryTeleporting(ai_HTeleportTarget_u)
                                      else ai_RunTo(pu,ai_HTeleportNearest_d,0,0,aic_BaseIdle_r,ai_HTeleportNearest_u);
                                   end
                                   else
                                     if(not FollowCommander)then
                                       ai_BaseIdle(pu,aic_BaseIdle_r);
      aic_group_Scout          : begin
                                    uo_id:=ua_move;
                                    if(ai_enemy_battle_u<>nil)and(ai_enemy_battle_d<srange)
                                    then ai_RunFrom(pu,ai_enemy_battle_u,0,0)
                                    else ai_DefaultIdle(pu);
                                 end;
      end;

      if((aip_flags and aif_ability_other    )>0)then ai_AbilitiesCommon(pu);
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    MAIN
//

procedure ai_Global_Code(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   begin
      if(uid_isbuilding)
      then ai_Global_Buildings(pu)
      else ai_Global_Units    (pu);
   end;
end;


