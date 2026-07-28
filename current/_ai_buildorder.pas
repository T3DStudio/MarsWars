


procedure ai_CalcBuildNeed(pu:PTUnit);
begin
   with pu^  do
   with player^ do
   begin
      // upgrade prods
      ai_need_UpgrProds:=0;
      if(aip_MaxForges>0)
      and(not ai_earlyAttack)then
      begin
         ai_need_UpgrProds:=res_energyl_max div 2500;

         if(ai_need_UpgrProds> ai_UpgradesLeft  )then ai_need_UpgrProds:=ai_UpgradesLeft;
         if(ai_need_UpgrProds> aip_MaxForges    )then ai_need_UpgrProds:=aip_MaxForges;
         if(ai_need_UpgrProds>=ai_curr_UnitProds)then ai_need_UpgrProds:=ai_curr_UnitProds-1;

         if(ai_need_UpgrProds<1)and(res_energyl_max>1500)then ai_need_UpgrProds:=1;
      end;

      // unit prods
      ai_need_UnitProds:=0;
      if(aip_MaxBarracks>0)then
      begin
         case race of
         r_hell: ai_need_UnitProds:=(res_energyl_max div 500);
         r_uac : ai_need_UnitProds:=(res_energyl_max div 425);
         end;

         // добавлять еще один барак если у игрока только один тип бараков?

         if(ai_UpgradesLeft>0)then ai_need_UnitProds-=ai_need_UpgrProds;
         if(ai_need_UnitProds<2)then ai_need_UnitProds:=2;
         if(ai_need_UnitProds>aip_MaxBarracks)then ai_need_UnitProds:=aip_MaxBarracks;
      end;

      // teleport
      ai_need_Teleports:=(ai_armylimit_ForTeleport div ul12)+3;

      // DETECTORS
      ai_need_detect:=0;
      if(ai_enemy_inv_u<>nil)
      or(ai_need_heye_u<>nil)
      then ai_need_detect:=aip_MaxDetectors
      else
      begin
         ai_need_detect:=ai_armylimit_alive_u div 8;
         if(ai_need_detect>aip_MaxDetectors)then
           ai_need_detect:=aip_MaxDetectors;
         if(g_tick<ai_DetectionBuildDelay)and(ai_need_detect>ul1)then ai_need_detect:=ul1;
      end;

      // ai_TechPriority
      {case race of
      r_hell: ;
      r_uac : ;
      end;   }

      {if(isselected)then
      begin
         writeln('ai_need_UnitProds=',ai_need_UnitProds,' ai_curr_UnitProds=',ai_curr_UnitProds)
         //writeln('ai_need_detect=',ai_need_detect,' ai_curr_Detect=',ai_curr_Detect);
         //writeln('ai_need_Energy=',ai_need_Energy,' ai_need_UnitProds=',ai_need_UnitProds,' ai_need_UpgrProds=',ai_need_UpgrProds,' ',ai_UpgradesLeft);
         //writeln('ai_need_UnitProds=',ai_need_UnitProds,' ai_curr_UnitProds=',ai_curr_UnitProds);
        // writeln('ai_need_UpgrProds=',ai_need_UpgrProds,' ai_curr_UpgrProds=',ai_curr_UpgrProds);
         //writeln('ai_need_UpgrProds ',ai_need_UpgrProds);
      end; }
   end;
end;

// new

{const
bot_unit     = 0;
bot_building = 1;
bot_upgrade  = 2;
bot_transform= 3;

var
bo_id   : byte = 0;
bo_count: byte = 0;
bo_type : byte = 0;

procedure ai_buildorder_common;
begin

end;

procedure ai_Production(pUProd:PTUnit);
procedure ProdUpgrade(upid,lvl:byte);
var uip:integer;
begin
   with pUProd^ do
   with player^ do
   begin
      uip:=upgrs_cur[upid]+prod_upgr_upid[upid];
      if(uip<lvl)and(uip<aip_MaxUpgradeLevel)then unit_ProdStartUpgrade(pUProd,upid,false);
   end;
end;
procedure ProdUnit(u_id,u_count:integer);
begin
   with pUProd^ do
   with uid^ do
   with player^ do
     if((units_bld_l[false]+prod_unit_Limit)<aip_MaxUnitLimit)then
     begin

     end;
end;
procedure ProdBuilding(uid,count:byte);
begin

end;
procedure ProdTransform(uid,count:byte);
begin

end;
begin
   ai_buildorder_common;

   if(bo_id>0)then
     with pUProd^ do
     with uid^ do
     with player^ do
       case bo_type of
       bot_unit     : if(uid_isbuilder)then ProdBuilding (bo_id,bo_count);
       bot_building : if(uid_isbarrack)then ProdUnit     (bo_id,bo_count);
       bot_upgrade  : if(uid_isforge  )then ProdUpgrade  (bo_id,bo_count);
       bot_transform:                       ProdTransform(bo_id,bo_count);
       end;
end;}

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
checkExtraEnergy:integer;

procedure ClearBuildDir;
begin
   build_dir :=-1;
   build_dirs:= 0;
   build_step:=-1;
end;

function SetBuildUID1(buid:byte;count:integer=MaxPlayerUnits):boolean;
begin
   SetBuildUID1:=false;
   if(build_uid=0)then
     if(pBuilder^.player^.units_uid_e[buid]<count)then
       if(buid in pBuilder^.uid^.uid_prod_Buildings)then
         if(unit_CheckReqs(pBuilder^.player,buid,checkExtraEnergy)=0)then
         begin
            if(pBuilder^.player^.res_UACLoot<600)and(g_uids[buid].uid_req_UACLoot>0)then exit;

            SetBuildUID1:=true;
            build_uid   :=buid;
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

procedure SetTowers(needN:integer);
begin
   if(build_uid>0)then exit;

   with pBuilder^  do
   with player^ do
   begin
      if(needN        <=ai_curr_Towers)
      or(aip_MaxTowers<=ai_curr_Towers)then exit;
      if(aiu_alarm_d=NOTSET)then exit;

      case race of
      r_hell: SetBuildUID2(UID_HFTower,UID_HTotem);
      r_uac : begin
                 if(aiu_alarm_d<base_r2)then
                   if(ai_enemylimit_baseR2_grd>0)
                   or(ai_enemylimit_baseR2_fly>0)then
                     if(ai_enemylimit_baseR2_grd>=ai_enemylimit_baseR2_fly)
                     then SetBuildUID1(UID_UGTurret)
                     else SetBuildUID1(UID_UATurret);

                 if(build_uid=0)then SetBuildUID2(UID_UGTurret,UID_UATurret);
              end;
      end;

      if(build_uid=0)then exit;

      if((map_scenario=mc_koth) and(ai_keypoint_d<=keyPoint_KotR))
      or((map_scenario=mc_royale)and(u_royal_cd<base_r1h))then
      begin
         // default
         build_step:=-1;//srange-g_random(g_uids[build_uid].uid_r);
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
          if(aiu_alarm_d<base_r2)then
          begin
             build_dir :=point_dir(x,y,aiu_alarm_x,aiu_alarm_y);
             build_dirs:=22;
             build_step:=srange-g_random(g_uids[build_uid].uid_r);
          end;
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
       end
     else
       case race of
       r_hell: if(not SetBuildUID1(UID_HGate   ,1))then SetBuildUID1(UID_HBarracks,1);
       r_uac : if(not SetBuildUID1(UID_UFactory,1))then SetBuildUID1(UID_UBarracks,1);
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
      if (units_builders_e<needN)
      and(units_builders_e<aip_MaxBuilders )
      and(units_builders_e<PlayerMaxBuilders)
      and(ai_curr_UnitProds>=2)
      and(units_bld_l[false]>=aip_MaxUnitMinPart)
      and(ai_BuildersInTransform   =0)
      and(ai_BuildersInConstruction=0)
      and(units_bld_l[false]>=aip_MaxUnitMinPart)
      and(not ai_earlyAttack)then
      begin
         checkExtraEnergy:=550;
         case race of
         r_hell: if(ai_available_HKeep)
                and(units_builders_e=(aip_MaxBuilders-1))
                and((units_uid_e[UID_HKeep]+units_uid_e[UID_HAKeep])=0)
                 then SetBuildUID1(UID_HKeep)
                 else
                 begin
                    if (units_uid_e[UID_HKeep]+units_uid_e[UID_HAKeep])>(units_uid_e[UID_HCommandCenter]+units_uid_e[UID_HACommandCenter])then
                      SetBuildUID1(UID_HCommandCenter);
                    SetBuildUID1(UID_HKeep)
                 end;
                 //SetBuildUID2(UID_HKeep,UID_HCommandCenter);
         r_uac : SetBuildUID1(UID_UCommandCenter);
         end;
         checkExtraEnergy:=0;
      end;
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
        if(build_uid>0)then build_step:=srange;
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
   if(build_uid>0)
   or(not map_NeedTransport)then exit;

   with pBuilder^  do
   with player^ do
     case race of
     r_hell: if(units_uid_e[UID_HTeleport]<ai_need_Teleports)then
               if(SetBuildUID1(UID_HTeleport))then
                 if(ai_HTeleportNearest_d<base_r3)then
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
     r_hell: SetBuildUID1(UID_HAltar,aip_MaxSuper);
     r_uac : begin
                if(res_UACLoot  >1000)then SetBuildUID1(UID_UAcademy        ,1);
                if(res_HellPower>1000)then SetBuildUID1(UID_UHPowerConductor,1);
                SetBuildUID1(UID_URMStation,aip_MaxSuper);
             end;
     end;
end;
function NeedMaxTowers:boolean;
begin
   with pBuilder^  do
     NeedMaxTowers:=((ai_enemy_d<base_r2)and(aiu_limitaround_ally<aiu_limitaround_enemy))
                  or((map_scenario=mc_koth) and(ai_keypoint_d<=keyPoint_KotR))
                  or((map_scenario=mc_royale)and(u_royal_cd<base_r1h));
end;

begin
   build_uid:=0;
   build_x  :=0;
   build_y  :=0;
   ClearBuildDir;
   checkExtraEnergy:=0;

   with pBuilder^  do
   with player^ do
   begin
      // Define UID to build
      if((aip_flags and aif_base_smart_order)>0)then
      begin
         if(NeedMaxTowers)then
           SetTowers(aip_MaxTowers);
         SetDetectors(ai_need_detect);
         if(aiu_alarm_d=NOTSET)then
           SetTeleport;
         SetBarracks  (1);
         SetBuilders  (aip_MaxBuilders  );
         SetTeleport;
         SetTech;
         SetSpecial;
         SetForges    (ai_need_UpgrProds);
         SetBarracks  (ai_need_UnitProds);
         SetTowers    (aip_MinTowers    );
         //SetDetectors (aip_MaxDetectors );
      end
      else
        case g_random(8) of
        0 : if(NeedMaxTowers)
            then SetTowers(aip_MaxTowers)
            else SetTowers(aip_MinTowers);
        1 : SetBarracks  (ai_need_UnitProds);
        2 : SetForges    (ai_need_UpgrProds);
        3 : SetBuilders  (aip_MaxBuilders  );
        4 : SetTeleport;
        5 : SetTech;
        6 : SetSpecial;
        7 : SetDetectors (ai_need_Detect   );
        end;

      if(build_uid=0)then exit;

     // if(isselected)then writeln('build_dir=',build_dir,' build_step=',build_step);

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
     with pFroge^ do
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
                   SetUpgrade(upgr_hell_ADetection  ,1);
                   SetUpgrade(upgr_hell_HKeepShift  ,1);
                   SetUpgrade(upgr_hell_BuilderR    ,2);
                   SetUpgrade(upgr_hell_Spectre     ,1);
                   SetUpgrade(upgr_hell_DecayAura   ,1);
                   SetUpgrade(upgr_hell_Resurrect   ,1);
                   SetUpgrade(upgr_hell_Phantoms    ,1);

                   for i:=1 to aip_MaxUpgradeLevel do
                   begin
                      if(map_NeedTransport)then
                        SetUpgrade(upgr_hell_TeleportCD,i);
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

                SetUpgrade(upgr_hell_DistDamage1+g_random(22),aip_MaxUpgradeLevel);
             end;
     r_uac : begin
                if((aip_flags and aif_upgr_smart_order)>0)then
                begin
                   SetUpgrade(upgr_uac_BuilderR     ,1);
                   SetUpgrade(upgr_uac_ADetection   ,1);
                   SetUpgrade(upgr_uac_CCFly        ,1);
                   SetUpgrade(upgr_uac_BuilderR     ,2);
                   SetUpgrade(upgr_uac_SSMWeapon    ,1);
                   SetUpgrade(upgr_uac_CommandoInvis,1);
                   SetUpgrade(upgr_uac_CCAttack     ,1);
                   if(map_NeedTransport)then
                     SetUpgrade(upgr_uac_Transport  ,1);
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

                SetUpgrade(upgr_uac_DistDamage  +g_random(21),aip_MaxUpgradeLevel);
             end;
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    BARRACKS
//

const

uprod_smart       = -1;
uprod_base        = -2;
uprod_random      = -3;
uprod_randomFly   = -4;
uprod_AflyMech    = -5;
uprod_AFly        = -6;
uprod_AgroundMech = -7;
uprod_AgroundBio  = -8;
uprod_Sidge       = -9;
uprod_Transport   = -10;
uprod_Special     = -11;


function ai_Barrack(pBarrack:PTUnit;utype:integer;ucount:integer=MaxPlayerUnits):boolean;
var
tuid  :byte;
tuid_n,
tuid_m:integer;
tlimit:longint;
procedure SmartSet(alimit:longint;autype:integer;agroup:byte);
begin
   if(alimit>tlimit)then
   begin
      tlimit:=alimit;
      utype :=autype;
      pBarrack^.group :=agroup;
   end;
end;
{function remoteKpExists:boolean;
begin
   remoteKpExists:=false;
   with pBarrack^ do
   begin
      if(ai_generator_d<NOTSET)then
        if(ai_generator_kp^.kp_zone<>mapZone)then remoteKpExists:=true;
      if(ai_keypoint_d<NOTSET)then
        if(ai_keypoint_kp^.kp_zone<>mapZone)then remoteKpExists:=true;
   end;
end;}
begin
   ai_Barrack:=false;
   tuid:=0;
   with pBarrack^ do
   with uid^    do
   with player^ do
   if((units_bld_l[false]+prod_unit_Limit)<aip_MaxUnitLimit)then
   begin
      if(aiu_alarm_d<NOTSET)then
      begin
         rpoint_x:=aiu_alarm_x;
         rpoint_y:=aiu_alarm_y;
      end;

      case utype of
uprod_smart      : begin
                      tlimit:=0;
                      case group of
                      6  : utype :=uprod_AflyMech;
                      7  : utype :=uprod_Afly;
                      8  : utype :=uprod_AgroundMech;
                      9  : utype :=uprod_AgroundBio;
                      else utype :=uprod_random;
                      end;

                      SmartSet(ai_enemyhits_flyMech   ,uprod_AflyMech   ,6);
                      SmartSet(ai_enemyhits_fly       ,uprod_Afly       ,7);
                      SmartSet(ai_enemyhits_groundMech,uprod_AgroundMech,8);
                      SmartSet(ai_enemyhits_groundBio ,uprod_AgroundBio ,9);
                      if(ai_armylimit_siedge<=ul15)then
                      SmartSet(ai_enemyhits_Towers    ,uprod_Sidge      ,0);

                      //if(isselected)then writeln('utype=',utype,' ',ul10,' ai_armylimit_siedge=',ai_armylimit_siedge);
                      ai_Barrack:=ai_Barrack(pBarrack,utype);
                      if(not ai_Barrack)and(aiu_BuildAttempts>30)then
                        ai_Barrack:=ai_Barrack(pBarrack,uprod_random);
                      exit;
                   end;
uprod_base       : begin
                      if(map_scenario=mc_royale)and(map_BusyCenter)then
                        if(ai_armylimit_fly<ul30)then
                          if(ai_Barrack(pBarrack,uprod_randomFly))then exit;

                      if((units_bld_l[false]+prod_unit_Limit)>=aip_MaxUnitMinPart)and(ai_enemy_d>base_r2)then
                      begin
                         if(ai_Barrack(pBarrack,uprod_Transport))then exit;

                         if(ai_armylimit_siedge<=ul10)and(ai_BaseDef_d=NOTSET)and(map_scenario<>mc_koth)then
                           if(ai_Barrack(pBarrack,uprod_Sidge))then exit;

                         if(ai_Barrack(pBarrack,uprod_Special))then exit;

                         if(ai_armylimit_fly<ul20)then
                           if(ai_Barrack(pBarrack,uprod_randomFly))then exit;
                      end;

                      ai_Barrack(pBarrack,uprod_smart);
                      exit;
                   end;
uprod_AflyMech   : begin
                      case race of
                      r_hell: if(not ai_Barrack(pBarrack,UID_Arachnotron    ))then
                              if(not ai_Barrack(pBarrack,UID_ZFPlasmagunner ))then
                              if(not ai_Barrack(pBarrack,UID_Cacodemon      ))then
                              if(not ai_Barrack(pBarrack,UID_ZAntiaircrafter))then
                              if(    ai_Barrack(pBarrack,UID_Revenant       ))then exit;
                      r_uac : if(not ai_Barrack(pBarrack,UID_FPlasmagunner  ))then
                              if(    ai_Barrack(pBarrack,UID_Antiaircrafter ))then exit;
                      end;
                      ai_Barrack(pBarrack,uprod_random);
                      exit;
                   end;
uprod_AFly       : begin
                      case race of
                      r_hell: if(not ai_Barrack(pBarrack,UID_ZAntiaircrafter))then
                              if(    ai_Barrack(pBarrack,UID_Revenant       ))then exit;
                      r_uac : if(not ai_Barrack(pBarrack,UID_Antiaircrafter ))then
                              if(    ai_Barrack(pBarrack,UID_FPlasmagunner  ))then exit;
                      end;
                      ai_Barrack(pBarrack,uprod_random);
                      exit;
                   end;
uprod_AgroundMech: begin
                      case race of
                      r_hell: if(not ai_Barrack(pBarrack,UID_Arachnotron    ))then
                              if(not ai_Barrack(pBarrack,UID_ZFPlasmagunner ))then
                              if(    ai_Barrack(pBarrack,UID_Cacodemon      ))then exit;
                      r_uac : if(not ai_Barrack(pBarrack,UID_FPlasmagunner  ))then
                              if(    ai_Barrack(pBarrack,UID_UACDron        ))then exit;
                      end;
                      ai_Barrack(pBarrack,uprod_random);
                      exit;
                   end;
uprod_AgroundBio :    case race of
                      r_hell: if(not ai_Barrack(pBarrack,UID_Mastermind))then
                                case g_random(5) of
                                0: tuid:=UID_Imp;
                                1: tuid:=UID_Demon;
                                2: tuid:=UID_Knight;
                                3: tuid:=UID_Baron;
                                4: tuid:=UID_ZBFGMarine;
                                end;
                      r_uac : if(not ai_Barrack(pBarrack,UID_Terminator))then
                                case g_random(5) of
                                0: tuid:=UID_Sergant;
                                1: tuid:=UID_SSergant;
                                2: tuid:=UID_Commando;
                                3: if(upgrs_cur[upgr_uac_SSMWeapon]>0)
                                   then tuid:=UID_Antiaircrafter
                                   else tuid:=UID_Commando;
                                4: tuid:=UID_BFGMarine;
                                end;
                      end;

uprod_Sidge      :    case race of
                      r_hell:   case g_random(3) of
                                0: tuid:=UID_Cyberdemon;
                                1: tuid:=UID_Mancubus;
                                2: tuid:=UID_ZSiegeMarine;
                                end;
                      r_uac :   case g_random(2) of
                                0: tuid:=UID_SiegeMarine;
                                1: tuid:=UID_Tank;
                                end;
                      end;
uprod_Transport  :    case race of
                      r_hell: ;
                      r_uac : if(ai_transport_cur<ai_transport_need)then tuid:=UID_UTransport;
                      end;
uprod_Special    : begin
                      tuid_n:=(units_bld_l[false]+prod_unit_Limit) div aip_MaxUnitMinPart;
                      ai_Barrack:=true;
                      case race of
                      r_hell: begin
                                 if(ai_Barrack(pBarrack,UID_Pain          ,tuid_n))then exit;
                                 if(ai_Barrack(pBarrack,UID_Archvile      ,3     ))then exit;
                                 if(ai_Barrack(pBarrack,UID_ZMedic        ,tuid_n))then exit;
                                 if(ai_Barrack(pBarrack,UID_ZEngineer     ,tuid_n))then exit;
                                 if(ai_Barrack(pBarrack,UID_ZBFGMarine    ,3     ))then exit;
                              end;
                      r_uac : begin
                                 if(ai_Barrack(pBarrack,UID_Medic         ,tuid_n))then exit;
                                 if(ai_Barrack(pBarrack,UID_Engineer      ,tuid_n))then exit;
                                 if(ai_Barrack(pBarrack,UID_BFGMarine     ,3     ))then exit;
                              end;
                      end;
                      ai_Barrack:=false;
                      exit;
                   end;
uprod_randomFly  :    case race of
                      r_hell: case g_random(5) of
                              0: tuid:=UID_Cacodemon;
                              1: tuid:=UID_Pain;
                              2: tuid:=UID_ZFPlasmagunner;
                              3: tuid:=UID_LostSoul;
                              4: tuid:=UID_Phantom;
                              end;
                      r_uac : case g_random(2) of
                              0: tuid:=UID_FPlasmagunner;
                              1: tuid:=UID_Flyer;
                              end;
                      end;
uprod_random     :    case race of
                      r_hell: if(ai_Barrack(pBarrack,uprod_randomFly))
                              then exit
                              else
                                case g_random(23) of
                                     0 : tuid:=UID_Imp;
                                     1 : tuid:=UID_Demon;
                                     2 : tuid:=UID_Cacodemon;
                                     3 : tuid:=UID_Knight;
                                     4 : tuid:=UID_Baron;
                                     5 : tuid:=UID_Cyberdemon;
                                     6 : tuid:=UID_Mastermind;
                                     7 : tuid:=UID_Pain;
                                     8 : tuid:=UID_Revenant;
                                     9 : tuid:=UID_Mancubus;
                                     10: tuid:=UID_Arachnotron;
                                     11: tuid:=UID_Archvile;
                                     12: tuid:=UID_ZMedic;
                                     13: tuid:=UID_ZEngineer;
                                     14: tuid:=UID_ZSergant;
                                     15: tuid:=UID_ZSSergant;
                                     16: tuid:=UID_ZCommando;
                                     17: tuid:=UID_ZAntiaircrafter;
                                     18: tuid:=UID_ZSiegeMarine;
                                     19: tuid:=UID_ZFPlasmagunner;
                                     20: tuid:=UID_ZBFGMarine;
                                     21: tuid:=UID_LostSoul;
                                     22: tuid:=UID_Phantom;
                                end;
                      r_uac : if(ai_Barrack(pBarrack,uprod_Transport))
                              then exit
                              else
                                if(ai_Barrack(pBarrack,uprod_randomFly))
                                then exit
                                else
                                case g_random(13) of
                                     0 : tuid:=UID_Medic;
                                     1 : tuid:=UID_Engineer;
                                     2 : tuid:=UID_Sergant;
                                     3 : tuid:=UID_SSergant;
                                     4 : tuid:=UID_Commando;
                                     5 : if(upgrs_cur[upgr_uac_SSMWeapon]>0)
                                         then tuid:=UID_Antiaircrafter
                                         else tuid:=UID_Commando;
                                     6 : tuid:=UID_SiegeMarine;
                                     7 : tuid:=UID_FPlasmagunner;
                                     8 : tuid:=UID_BFGMarine;
                                     9 : tuid:=UID_UACDron;
                                     10: tuid:=UID_Terminator;
                                     11: tuid:=UID_Tank;
                                     12: tuid:=UID_Flyer;
                                end;
                      end;
1..255           :    tuid:=utype;
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
      UID_Engineer  : tuid_m:=min2i(aip_skill,aic_max_SpecUID);
      else            tuid_m:=MaxUnits;
      end;

      if(tuid_n<tuid_m)then ai_Barrack:=unit_ProdStartUnit(pBarrack,tuid,false)=0;
      if(ai_Barrack)
      then aiu_BuildAttempts:=0
      else
        if(aiu_BuildAttempts<aiu_BuildAttempts.MaxValue)
        then aiu_BuildAttempts+=1;
   end;
end;

