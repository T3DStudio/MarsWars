
////////////////////////////////////////////////////////////////////////////////
//
//  COMMON
//

procedure ai_Suicide(pu:PTUnit);
begin
   unit_kill(pu,false,false,true,false,true);
end;

procedure ai_RunTo(pu,otar:PTUnit;ox,oy,odist,ow:integer);
begin
   with pu^  do
   begin
      if(otar<>nil)then
      begin
         ox:=otar^.x;
         oy:=otar^.y;
      end;
      if(odist<0)
      or(odist=NOTSET)then odist:=point_dist_int(x,y,ox,oy);
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
      then ai_RunTo(pu,nil,g_random(map_Size1),
                           g_random(map_Size1),NOTSET,0);
   end;
end;

procedure ai_BaseIdle(pu:PTUnit;idle_r:integer);
var
base_u:PTUnit;
base_d:integer;
begin
   if(ai_BaseOwn_d=NOTSET)then
   begin
      base_u:=ai_BaseAlly_u;
      base_d:=ai_BaseAlly_d;
   end
   else
   begin
      base_u:=ai_BaseOwn_u;
      base_d:=ai_BaseOwn_d;
   end;

   if(base_d=NOTSET)
   then ai_DefaultIdle(pu)
   else
     if(idle_r<base_d)and(base_d<NOTSET)
     then ai_RunTo(pu,base_u,0,0,base_d,base_r1)
     else
       with pu^ do
         if(aiu_alarm_d<NOTSET)
         then ai_RunTo(pu,nil,aiu_alarm_x,aiu_alarm_y,aiu_alarm_d,0)
         else
           if(point_dist_rint(x,y,uo_x,uo_y)<idle_r)then
             ai_RunTo(pu,nil,g_random(map_Size1),
                             g_random(map_Size1),NOTSET,0);
end;

procedure ai_RunFrom(pu,tu:PTUnit;tx,ty,td:integer);
var
px,py:integer;
begin
   if(tu<>nil)then
   begin
      tx:=tu^.x;
      ty:=tu^.y;
   end;
   with pu^ do
     if(min2i(x,abs(map_Size1-x))<srange)
     or(min2i(y,abs(map_Size1-y))<srange)
     then ai_DefaultIdle(pu)
     else
     begin
        if(td<0)
        or(td=NOTSET)then td:=point_dist_int(x,y,tx,ty);
        if(td<1)then td:=1;
        px:=round(((tx-x)/td)*srange);
        py:=round(((ty-y)/td)*srange);

        uo_x:=x-px;
        uo_y:=y-py;
     end;
end;

procedure ai_CalcBuildNeed(pu:PTUnit);
begin
   with pu^  do
   with player^ do
   begin
      ai_need_Energy:=1250+ai_curr_UnitProds*650;

      // upgrade prods
      ai_need_UpgrProds:=0;
      if(aip_MaxForges>0)
      and(not ai_earlyAttack)then
      begin
         ai_need_UpgrProds:=res_energyl_max div 2500;

         if(ai_need_UpgrProds> ai_UpgradesLeft  )then ai_need_UpgrProds:=ai_UpgradesLeft;
         if(ai_need_UpgrProds> aip_MaxForges    )then ai_need_UpgrProds:=aip_MaxForges;
         if(ai_need_UpgrProds>=ai_curr_UnitProds)then ai_need_UpgrProds:=ai_curr_UnitProds-1;

         if(ai_need_UpgrProds<1)and(res_energyl_max>1200)then ai_need_UpgrProds:=1;
      end;

      // unit prods
      ai_need_UnitProds:=0;
      if(aip_MaxBarracks>0)then
      begin
         case race of
         r_hell: ai_need_UnitProds:=(res_energyl_max div 500);
         r_uac : ai_need_UnitProds:=(res_energyl_max div 425);
         end;

         ai_need_UnitProds+=ai_curr_Builders;
         if(ai_UpgradesLeft>0)then ai_need_UnitProds-=ai_need_UpgrProds;
         if(ai_need_UnitProds<1)then ai_need_UnitProds:=1;
         if(ai_need_UnitProds>aip_MaxBarracks)then ai_need_UnitProds:=aip_MaxBarracks;
      end;

      // teleport
      ai_need_Teleports:=(ai_armylimit_ForTeleport div ul12)+1;

      // DETECTORS
      if(ai_enemy_inv_u<>nil)
      or(ai_need_heye_u<>nil)
      then ai_need_detect:=aip_MaxDetectors
      else
      begin
         ai_need_detect:=ai_armylimit_alive_u div 8;
         //if(ai_need_detect<ul1)then ai_need_detect:=ul1;
         if(ai_need_detect>aip_MaxDetectors)then
           ai_need_detect:=aip_MaxDetectors;
      end;

      // ai_TechPriority
      case race of
      r_hell: ;
      r_uac : ;
      end;

      if(isselected)then
      begin
         //writeln('ai_need_detect=',ai_need_detect,' ai_curr_Detect=',ai_curr_Detect);
         //writeln('ai_need_Energy=',ai_need_Energy,' ai_need_UnitProds=',ai_need_UnitProds,' ai_need_UpgrProds=',ai_need_UpgrProds,' ',ai_UpgradesLeft);
         //writeln('ai_need_UnitProds=',ai_need_UnitProds,' ai_curr_UnitProds=',ai_curr_UnitProds);
        // writeln('ai_need_UpgrProds=',ai_need_UpgrProds,' ai_curr_UpgrProds=',ai_curr_UpgrProds);
         //writeln('ai_need_UpgrProds ',ai_need_UpgrProds);
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
         if(CheckUnitReqs(pBuilder^.player,buid,checkExtraEnergy)=0)then
         begin
            if(pBuilder^.player^.res_UACLoot<1000)and(g_uids[buid].uid_req_UACLoot>0)then exit;

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
   with player^ do         //((aip_flags and aif_army_early_attack0)=0)
   begin
      if(units_bld_l[false]<aip_MaxUnitMinPart)
      then checkExtraEnergy:=500
      else checkExtraEnergy:=0;
      if (ai_curr_Builders<needN)
      and(ai_curr_Builders<aip_MaxBuilders )
      and(ai_curr_Builders<PlayerMaxBuilders)
      and(ai_curr_UnitProds>=2)
      and((units_builders_e-units_builders_c)=0)
      and(not ai_earlyAttack)then
      begin
         case race of
         r_hell: if(ai_available_HKeep)
                and(units_builders_e=(aip_MaxBuilders-1))
                and((units_uid_e[UID_HKeep]+units_uid_e[UID_HAKeep])=0)
                 then SetBuildUID1(UID_HKeep)
                 else SetBuildUID2(UID_HKeep,UID_HCommandCenter);
         r_uac : SetBuildUID1(UID_UCommandCenter);
         end;
      end;
      checkExtraEnergy:=0;
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
     NeedMaxTowers:=((aiu_alarm_d<base_r2)and(aiu_limitaround_ally<aiu_limitaround_enemy))
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
         //SetDetectors (aip_MaxDetectors );
      end
      else
        case g_random(9) of
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
        8 : SetDetectors (ai_need_Detect   );
        end;

      if(build_uid=0)then exit;

      if(isselected)then writeln('build_dir=',build_dir,' build_step=',build_step);

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
                      if((units_bld_l[false]+prod_unit_Limit)>=aip_MaxUnitMinPart)and(ai_enemy_d>base_r2)then
                      begin
                         if(ai_Barrack(pBarrack,uprod_Transport))then exit;

                         if(ai_armylimit_siedge<=ul10)and(ai_BaseDef_d=NOTSET)then
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

////////////////////////////////////////////////////////////////////////////////
//
//    OTHER
//

function ai_IsTowerUsefull(pTower:PTUnit):boolean;
begin
   ai_IsTowerUsefull:=true;
   with pTower^ do
   with player^ do
     if (aiu_alarm_timer<0)
     and(-aiu_alarm_timer>aic_TowerLifeTime)then
       if(ai_curr_Towers>aip_MinTowers)
       or((ai_BaseAlly_d>base_r1)and(ai_BaseOwn_d>base_r1))then
         ai_IsTowerUsefull:=false;
end;

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

       UID_UWeaponFactory,
       UID_HPools,
       UID_UBarracks,
       UID_UFactory,
       UID_HBarracks,
       UID_HGate          : if(not unit_IsProducting(pu))then
                            begin
                               if(units_uid_c[uidi]>1)and(ai_selfUID_minLevel=level)then
                               begin
                                  i:=ai_GetLevel(pu)+1;
                                  if(uid_isbarrack)and((ai_curr_UnitProds-i)>ai_need_UnitProds)then ai_NeedSuicide:=true;
                                  if(uid_isforge  )and((ai_curr_UpgrProds-i)>ai_need_UpgrProds)then ai_NeedSuicide:=true;
                               end;
                               // destroy redundance barracks
                            end;
       UID_HFTower,
       UID_HTotem         : if (not ai_IsTowerUsefull(pu))then ai_NeedSuicide:=true;
       UID_UGTurret,
       UID_UATurret       : if (upgrs_cur[upgr_uac_DronTurret]=0)
                            and(not ai_IsTowerUsefull(pu))then ai_NeedSuicide:=true;
       else
          //if(not uid_isbuilding)then
          //  if((MaxPlayerLimit-armylimit-prod_unit_Limit-ai_ownDead_limit)<ai_NeedFreeLimit)and(ai_enemy_d>base_r2)and(a_rld=0)then ai_NeedSuicide:=true;
       end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    UPGRADE/TRANSFORM ABILITIES
//

function ai_AbilitiesTransformIf(pu:PTUnit):boolean;
begin
   with pu^ do
     ai_AbilitiesTransformIf:=(buffs[ub_damaged]<=0)
                           and(hits>uid^.uid_MaxHitsh);
end;

procedure ai_AbilitiesTransform(pu:PTUnit);
begin
   with pu^     do
   with uid^    do
   with player^ do
     case uidi of
UID_HSymbol1,
UID_HSymbol2,
UID_HSymbol3,
UID_UGenerator1,
UID_UGenerator2,
UID_UGenerator3   : if((res_energyl_cur-g_uids[uid_AI_NextFormUID].uid_req_EnergyLevel)>=400)
                    or((ai_curr_UnitProds>1)and(ai_armylimit_alive_u>aip_MaxUnitMinPart))then
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
                      if(ai_curr_UnitProds>1) //ai_need_UnitProds
                      and((aip_flags and aif_army_early_attack0)=0)
                      then
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
                      if(not unit_IsProducting(pu))then
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
      if(ai_UnitAbility(pCaster,uab_HTowerBlink,0,tx,ty))then aiu_alarm_timer:=0;
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
      //if(isselected)then writeln('ai_ability_CCLift');
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

function ai_AbilityDronToTower:boolean;
begin
   ai_AbilityDronToTower:=false;
   if(u_royal_d>base_r1)then
   begin
      if(ai_generator_d<NOTSET)then
        if (ai_generator_d<ai_generator_kp^.kp_RCapture)
        and(ai_generator_d>ai_generator_kp^.kp_RNoBuild)then ai_AbilityDronToTower:=true;
      if(ai_keypoint_d <NOTSET)and(map_scenario=mc_koth)then
        if(ai_keypoint_d <ai_keypoint_kp^.kp_RCapture)then ai_AbilityDronToTower:=true;
   end;
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
     UID_HFTower,
     UID_HTotem      : if(a_rld<=0)and(aiu_alarm_d>srange)then
                       begin
                          if(ai_keypoint_d<NOTSET)then
                            with ai_keypoint_kp^ do
                              if(kp_zone=mapZone)then
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
                              if(kp_zone=mapZone)then
                              begin
                                 if(ai_generator_d<=kp_RCapture)then exit;
                                 if(ai_generator_d<cd)then
                                 begin
                                    cx:=kp_x;
                                    cy:=kp_y;
                                    cd:=ai_generator_d;
                                 end;
                              end;
                          if(aiu_alarm_d<cd)and(aiu_alarm_d<NOTSET)then
                            if(aiu_alarm_d<base_r2)
                            or((aip_flags and aif_ability_TowerRush)>0)then
                            begin
                               cx:=aiu_alarm_x;
                               cy:=aiu_alarm_y;
                               cd:=aiu_alarm_d;
                            end;


                          if(cd<NOTSET)
                          then ai_ability_TowerBlink2Dir(pCaster,cx,cy,cd,g_randomr(30))  //srange
                          else
                            if(srange<ai_BaseOwn_d)and(ai_BaseOwn_d<NOTSET)then
                              if(aiu_alarm_d=NOTSET)then
                                ai_ability_TowerBlink2Dir(pCaster,ai_BaseOwn_u^.x,ai_BaseOwn_u^.y,min2i(cd,srange),g_randomr(30));
                       end;
     UID_HTeleport   : if(ai_enemy_battle_d<base_r1h)and(ai_HTeleportRecall_u<>nil)then
                         if(ai_HTeleportRecall_u^.aiu_alarm_d>base_r2)then
                           ai_UnitAbility(pCaster,uab_Recall,ai_HTeleportRecall_u^.unum,0,0);
     UID_HAltar      : if(aip_timer_magic=0)then
                       begin
                          if(ai_AbilityMagic(pCaster,ai_SphereTurbo_u  ,uab_SphereTurbo  ))
                          then aip_timer_magic:=aip_pause_magic
                          else
                            if(ai_AbilityMagic(pCaster,ai_SphereDDamage_u,uab_SphereDDamage))
                            then aip_timer_magic:=aip_pause_magic
                            else
                              if(ai_AbilityMagic(pCaster,ai_SphereRDamage_u,uab_SphereRDamage))
                              then aip_timer_magic:=aip_pause_magic;
                       end;
     UID_UHPowerConductor
                     : if(aip_timer_magic=0)then
                       begin
                          if(ai_AbilityMagic(pCaster,ai_SphereInvuln_u,uab_SphereInvuln))
                          then aip_timer_magic:=aip_pause_magic
                          else
                            if(ai_AbilityMagic(pCaster,ai_SphereSoul_u,uab_SphereSoul))
                            then aip_timer_magic:=aip_pause_magic
                            else
                              if(ai_SphereInvis_u<>ai_SphereInvuln_u)then
                                if(ai_AbilityMagic(pCaster,ai_SphereInvis_u,uab_SphereInvis))
                                then aip_timer_magic:=aip_pause_magic;
                       end;
     UID_UAcademy    : if(aip_timer_magic=0)then
                         if(ai_AbilityMagic(pCaster,ai_Heroic_u,uab_UACGeneral))then aip_timer_magic:=aip_pause_magic;
     UID_URMStation  : if(aip_timer_superweapon=0)then
                         if(ai_AbilityMagic(pCaster,ai_Strike_u,uab_UACStrike ))then aip_timer_superweapon:=aip_pause_superweapon;

     UID_Pain        : if ((units_bld_l[false]+prod_unit_Limit)<aip_MaxUnitLimit)
                       and((MaxPlayerLimit-armylimit)>ul1)then
                         if((upgrs_cur[upgr_hell_Phantoms]=0)and(units_uid_e[UID_LostSoul]<units_uid_m[UID_LostSoul]))
                         or((upgrs_cur[upgr_hell_Phantoms]>0)and(units_uid_e[UID_Phantom ]<units_uid_m[UID_Phantom ]))then
                           if((base_r1h<ai_enemy_battle_d)and(ai_enemy_battle_d<base_r2))
                           or((ai_ZombieTarget_d<base_r1h)and(upgrs_cur[upgr_hell_Phantoms]>0))then
                             ai_UnitAbility(pCaster,uab_SpawnLost,0,0,0);
     UID_UACDron     : if(ai_enemy_d>base_r1)and(ai_AbilityDronToTower)then
                         if(ai_towers_near_AG<=ai_towers_near_AA)
                         then ai_UnitAbility(pCaster,uab_ToUGTurretTo,0,x,y)
                         else ai_UnitAbility(pCaster,uab_ToUATurretTo,0,x,y);

     UID_UGTurret,
     UID_UATurret    : if (upgrs_cur[upgr_uac_DronTurret]>0)
                       and(not ai_IsTowerUsefull(pCaster))
                       then ai_UnitAbility(pCaster,uab_ToUACDron,0,0,0)
                       else
                         if(ai_enemy_d>base_r2)then
                           case uidi of
                           UID_UGTurret: if(ai_towers_near_AG>0)and(ai_towers_near_AA=0)then ai_UnitAbility(pCaster,uab_ToUAATurret,0,0,0);
                           UID_UATurret: if(ai_towers_near_AA>0)and(ai_towers_near_AG=0)then ai_UnitAbility(pCaster,uab_ToUAGTurret,0,0,0);
                           end;

     end;

   with pCaster^ do
     with player^ do
       if(ai_HEyeNest_u<>nil)and(ai_near_HEye<=0)and(ai_need_heye_u=nil)and(aip_timer_magic=0)then
         if(not map_IfObstacleZone(mapZone))then
           if(ai_UnitAbility(ai_HEyeNest_u,uab_HEyeSpawn,0,x,y))then aip_timer_magic:=aip_pause_magic;

   if(ai_Bribe_u<>nil)
   or(ai_Hack_u <>nil)then
     if(IsUnitRange(pCaster^.player^.units_uid_u[UID_UAcademy],@pCaster))then
       with pCaster^.player^ do
       begin
          if(ai_Bribe_u<>nil)and(aip_timer_magic=0)then
            if(ai_UnitAbility(pCaster,uab_Bribe,ai_Bribe_u^.unum,0,0))then aip_timer_magic:=aip_pause_magic;
          if(ai_Hack_u <>nil)and(aip_timer_magic=0)then
            if(ai_UnitAbility(pCaster,uab_Hack ,ai_Hack_u^ .unum,0,0))then aip_timer_magic:=aip_pause_magic;
       end;
end;


procedure ai_AbilitiesDetection(pCaster:PTunit);
begin
   with pCaster^ do
   with uid^    do
   with player^ do
     case uidi of
     UID_HEyeNest: begin
                      //if(isselected)then writeln('ai_need_heye_d ',ai_need_heye_d,' ai_AvailableDetectors ',ai_AvailableDetectors);
                      if(ai_need_heye_d<NOTSET)then
                        if(ai_UnitAbility(pCaster,uab_HEyeVision,ai_need_heye_u^.unum,0,0))then
                          aip_timer_detection:=aip_pause_detection;
                   end;
     UID_URadar  : begin
                      if(ai_enemy_inv_d<NOTSET)then
                        if(ai_UnitAbility(pCaster,uab_UACScan   ,0,ai_enemy_inv_u^.x,ai_enemy_inv_u^.y))then
                          aip_timer_detection:=aip_pause_detection;
                      if(ai_need_heye_u<>nil)then
                        if(ai_UnitAbility(pCaster,uab_UACScan   ,0,ai_need_heye_u^.x,ai_need_heye_u^.y))then
                          aip_timer_detection:=aip_pause_detection;

                      if(map_generators<mapg_inf)and(ai_choosen)and(units_uid_e[uidi]>1)and(ai_generator_d<NOTSET)
                      then with ai_generator_kp^ do ai_UnitAbility(pCaster,uab_UACScan   ,0,kp_x,kp_y)
                      else
                        if(aiu_alarm_d=NOTSET)then
                          ai_UnitAbility(pCaster,uab_UACScan   ,0,g_random(map_Size1),g_random(map_Size1));
                   end;
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
function RoyalCR:integer;
begin
   RoyalCR:=min2i(g_royal_RCur div 3,base_r1h);
end;

function moveEventType:byte;
begin
   moveEventType:=0;
   case map_scenario of
   mc_koth  : if(ai_choosen)and(map_scenario=mc_koth)and(ai_keypoint_d<NOTSET)then
                with ai_keypoint_kp^ do
                  if(kp_RCapture<ai_keypoint_d)or(pBuilder^.isfly)then
                  begin
                     moveEventType:=met_koth;
                     exit;
                  end;
   mc_royale: case pBuilder^.isfly of
              true : if(u_royal_d<base_r1h)then
                     begin
                        moveEventType:=met_royale;
                        exit;
                     end;
              false: if(u_royal_d<base_r1)then
                     begin
                        moveEventType:=met_royale;
                        exit;
                     end;
              end;

   end;

   with pBuilder^ do
     if(not (map_scenario=mc_koth))
     or(ai_keypoint_d>keyPoint_KotR)then
       if (ai_enemy_d<base_r2)
       and(hits<uid^.uid_MaxHitsh)then
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
      if(map_scenario=mc_royale)then
        if(base_r1h>(g_royal_RCur-point_dist_int(uo_x,uo_y,map_sizeH,map_sizeH)))then exit;
      if(CheckCollisionR(uo_x,uo_y,uid_r,unum,uid_isbuilding,true,255,pBuilder)<>cbr_no)then exit;
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
       if(checkLandingPlace(uo_x,uo_y,lr))then
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
          math_push_out(uo_x,uo_y,uid_r,unum,@uo_x,@uo_y,true,playeri );
       end;
end;
begin
   if((pBuilder^.player^.aip_flags and aif_base_BuilderMove )>0)
   then alarmType:=moveEventType
   else alarmType:=0;
   {if(pBuilder^.isselected)then
   begin
      writeln('alarmType ',alarmType,' ',ai_choosen,' ',u_royal_d,' ',base_r1h,' ',(u_royal_d<base_r1h));
      //writeln('ai_choosen ',ai_choosen,' (map_scenario=mc_koth)=',(map_scenario=mc_koth),' ai_keypoint_d=',ai_keypoint_d);
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
                                         lx:=RoyalCR;
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
                                                  lx:=min2i(g_royal_RCur div 3,base_r1h);
                                                  setLandingPlace(map_sizeH,map_sizeH,u_royal_cd,lx);
                                               end;
                                   met_hits  : ai_RunFrom(pBuilder,ai_enemy_u,0,0,ai_enemy_d);
                                   // met_build
                                   else
                                      if(ai_BaseOwn_d<NOTSET)
                                      then setLandingPlace(ai_BaseOwn_u^.x,ai_BaseOwn_u^.y,ai_BaseOwn_d,base_r1)
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
          if(uid_isforge)then unit_ProdStopUpgrade(pu,255,false,true,false);
       end
       else
         if(ai_UnitsInTransform>0)then
         begin
            if(transformTimer>0)then unit_TransformStop(pu,false);
         end
         else
           if(not iscomplete)then
             if((uid_req_EnergyLevel>0)and(energyCur_BldGens >0))
             or((uid_req_EnergyLevel=0)and(energyCur_BldOther>0))
             then ai_Suicide(pu);
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
      ai_CalcBuildNeed(pu);

      if(uid_isbuilder)and(not isfly)and(zfall=0)and(build_cd<=0)then ai_Builder(pu);

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

      if(uid_isbarrack)and(prod_unit_Now>0)and((armylimit+prod_unit_Limit)>MaxPlayerLimit)then
        unit_ProdStopUnit(pu,255,false,true,false);

      if(not iscomplete)then exit;

      if(uid_isforge  )and(aip_MaxUpgradeLevel>0)then ai_Forge(pu);
      if(uid_isbarrack)and(aip_MaxUnitLimit   >0)then
        if((aip_flags and aif_army_smart_order)>0)
        then ai_Barrack(pu,uprod_base  )
        else ai_Barrack(pu,uprod_random);

      // Transformation
      //if(isselected)then writeln(aiu_alarm_d);
        {writeln(ai_AbilitiesTransformIf(pu),' ',
                aiu_limitaround_ally,' ',
                aiu_limitaround_enemy,' ',
                (buffs[ub_damaged]<=0),' ',
                (hits>uid^.uid_MaxHitsh),' ',
                ai_flags_BaseAMain,' ',
                (res_energyl_max-energyCur_builds-energyCur_transforms),' ',uid_req_EnergyLevel);   }

      case ai_AbilitiesTransformIf(pu) of
      true : case uid_isbuilder of
             true : if(ai_flags_BaseAMain)then
                    begin
                       if(transformTimer<=0)then
                         ai_AbilitiesTransform(pu);
                       if(transformTimer>0)then exit;
                    end;
             false: if(ai_flags_BaseAOther)then
                    begin
                       if(transformTimer<=0)then
                         ai_AbilitiesTransform(pu);
                       if(transformTimer>0)then exit;
                    end;
             end;
      false: if(transformTimer>0)then unit_TransformStop(pu,false);
      end;

      {if(isselected)and(ai_enemy_inv_d<NOTSET)then
      begin
         UnitsInfo_AddLine(x,y,ai_enemy_inv_u^.x,ai_enemy_inv_u^.y+1,c_blue);
         UnitsInfo_AddLine(x+2,y,uo_x,uo_y+2,c_yellow);
      end; }

      if(aip_timer_detection=0)then
        if((aip_flags and aif_ability_detection)>0)then ai_AbilitiesDetection(pu);
      if(uid_isbuilder)then                             ai_AbilitiesBuilderMove(pu);
      if((aip_flags and aif_ability_other      )>0)then ai_AbilitiesCommon(pu);
   end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//    UNITS AI
//

{$include _ai_main_units.pas}

////////////////////////////////////////////////////////////////////////////////
//
//    MAIN
//

procedure ai_Local_Code(pu:PTUnit);
var i:integer;
    l:longint;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      {if(isselected)and(ai_enemy_d<NOTSET)then
      begin
         UnitsInfo_AddLine(x+1,y,ai_enemy_u^.x,ai_enemy_u^.y+1,c_orange);
         writeln('ai_enemy_d ',ai_enemy_d,' srange',srange,' ai_enemy_z ',ai_enemy_u^.mapZone);
      end;}

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
            or(uid_isbarrack)
            or(uid_ability_isradar)then
              ai_Local_SetCurrentAlarm(pu,nil,aia_x,aia_y,point_dist_int(aia_x,aia_y,x,y),aia_zone);

      case(aiu_alarm_d<base_r2)of
      true : if(aiu_alarm_timer<0)
             then aiu_alarm_timer:=0
             else
               if(aiu_alarm_timer<(aiu_alarm_timer.MaxValue-order_period))
               then aiu_alarm_timer+=order_period;
      false: if(aiu_alarm_timer>0)
             then aiu_alarm_timer:=0
             else
               if(aiu_alarm_timer>(aiu_alarm_timer.MinValue+order_period))
               then aiu_alarm_timer-=order_period;
      end;
   end;
end;

procedure ai_Global_Code(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   begin
      //if(isselected)then
      //  if(ai_HTeleportNearest_u<>nil)then UnitsInfo_AddLine(x,y,ai_HTeleportNearest_u^.x,ai_HTeleportNearest_u^.y,c_lime);
      //if(isselected)then writeln('ai_selfUID_minLevel=',ai_selfUID_minLevel,'  ai_selfUID_nocomplete=',ai_selfUID_nocomplete);
      {if(isselected)then
      begin
         //writeln(aiu_alarm_timer,' ',aic_TowerLifeTime);
         {writeln((ai_generator_d<NOTSET),' ',(ai_keypoint_d<NOTSET));
         if(ai_generator_d<NOTSET)then
           with ai_generator_kp^ do UnitsInfo_AddLine(x,y,kp_x,kp_y,c_blue);
         if(ai_keypoint_d<NOTSET)then
           with ai_keypoint_kp^ do UnitsInfo_AddLine(x+2,y,kp_x,kp_y,c_green);
         //if(ai_BaseOwn_d<NOTSET)then UnitsInfo_AddLine(x,y,ai_BaseOwn_u^.x,ai_BaseOwn_u^.y,c_lime); }

         writeln((ai_need_heye_u<>nil),' ',(ai_enemy_inv_u<>nil));
         if(ai_need_heye_u<>nil)then UnitsInfo_AddLine(x,y,ai_need_heye_u^.x,ai_need_heye_u^.y,c_lime);
         if(ai_enemy_inv_u<>nil)then UnitsInfo_AddLine(x,y,ai_enemy_inv_u^.x,ai_enemy_inv_u^.y,c_aqua);
      end; }
      if(isselected)then
      with player^ do
      begin
        { writeln('res_energyl_max=',res_energyl_max,
                ' units=',energyCur_units,
                ' upgrades=',energyCur_upgrades,
                ' transforms=',energyCur_transforms,
                ' BldOther=',energyCur_BldOther,
                ' BldGens=',energyCur_BldGens,
                ' ',res_energyl_max-energyCur_units-energyCur_upgrades-energyCur_transforms-energyCur_BldOther); }

        { writeln({ai_curr_Towers,' ',
                 aip_MinTowers,' ',
                 ai_IsTowerUsefull(pu),' ',
                 ai_BaseAlly_d,' ',ai_BaseOwn_d,' ',
                 (upgrs_cur[upgr_uac_DronTurret]>0),' ',
                 aiu_alarm_timer,' ',
                 aic_TowerLifeTime}
                 (upgrs_cur[upgr_uac_DronTurret]>0)
                                        and(not ai_IsTowerUsefull(pu))
                 );}
      end;

      if(uid_isbuilding)
      then ai_Global_Buildings(pu)
      else ai_Global_Units    (pu);
   end;
end;


