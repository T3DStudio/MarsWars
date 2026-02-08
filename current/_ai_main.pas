
////////////////////////////////////////////////////////////////////////////////
//
//  COMMON
//

procedure ai_ProdRequirements(pu:PTUnit);
var i:integer;
begin
   with pu^  do
   with player^ do
   begin
      // energy
      ai_need_Energy:=600+ai_curr_UnitProds*600;

      ai_need_Builders:=ai_curr_Builders+1;

      // upgrade prods
      ai_need_UpgrProds:=0;
      i:=res_energyl_max-400;
      if(aip_MaxForges>0)and(i>600)then
      begin
         ai_need_UpgrProds:=i div 1500;

         if(ai_need_UpgrProds>ai_UpgradesLeft)then ai_need_UpgrProds:=ai_UpgradesLeft;
         if(ai_need_UpgrProds>aip_MaxForges  )then ai_need_UpgrProds:=aip_MaxForges;
      end;

      // unit prods
      ai_need_UnitProds:=0;
      if(aip_MaxBarracks>0)then
      begin
         ai_need_UnitProds:=(res_energyl_max div 400)-ai_need_UpgrProds;
         if(ai_need_UnitProds<1)then ai_need_UnitProds:=1;
         if(ai_need_UnitProds>aip_MaxBarracks)then ai_need_UnitProds:=aip_MaxBarracks;
      end;

      // static defense
      if(aip_MaxTowers>0)then
      begin

      end;

      // DETECTORS
      if(ai_enemy_inv_u<>nil)
      then ai_need_detect:=aip_MaxDetectors
      else
      begin
         ai_need_detect:=ai_armylimit_alive_u div 8;
         if(ai_need_detect>aip_MaxDetectors)then
           ai_need_detect:=aip_MaxDetectors;
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
build_step: integer;
rad_dir   : single;
skipEnergyCheck:boolean;

function SetBuildUID(buid:byte;count:integer=MaxPlayerUnits):boolean;
var t:cardinal;
begin
   SetBuildUID:=false;
   if(build_uid=0)then
     if(pBuilder^.player^.units_uid_e[buid]<count)then
       if(buid in pBuilder^.uid^.uid_prod_Buildings)then
       begin
          t:=CheckUnitReqs(pBuilder^.player,buid);
          if(t=0)or((t=ureq_energy)and(skipEnergyCheck))then
          begin
             SetBuildUID:=true;
             build_uid  :=buid;
          end;
       end;
end;
function SetBuildUIDs(buid1,buid2:byte):boolean;
begin
   with pBuilder^.player^  do
     if(units_uid_e[buid2]>=units_uid_e[buid1])
     then SetBuildUID(buid1)
     else SetBuildUID(buid2);

   if(build_uid=0)then
     if(not SetBuildUID(buid1))
     then SetBuildUID(buid2);

   SetBuildUIDs:=build_uid<>0;
end;

procedure SetTowers;
begin
   if(build_uid>0)then exit;

   if(ai_need_Towers<=ai_curr_Towers)then exit;


end;
procedure SetGenerators;
begin
   if(build_uid>0)then exit;

   if(map_generators=0)then
     with pBuilder^  do
     with player^ do
       if (ai_energy_future   <ai_need_Energy)
       and(ai_energy_future   <aip_MaxEnergy)
       and(ai_energy_future   <aic_GeneratorsEnergy)
       and(ai_generators_limit<aic_GeneratorsLimit)then
         case race of
         r_hell: SetBuildUID(UID_HSymbol1);
         r_uac : SetBuildUID(UID_UGenerator1);
         end;
end;

procedure SetBarracks;
begin
   if(build_uid>0)then exit;

   with pBuilder^  do
   with player^ do
     if (ai_curr_UnitProds<ai_need_UnitProds)
     and(ai_curr_UnitProds<aip_MaxBarracks  )then
       case race of
       r_hell: SetBuildUIDs(UID_HGate    ,UID_HBarracks);
       r_uac : SetBuildUIDs(UID_UBarracks,UID_UFactory );
       end;
end;
procedure SetForges;
begin
   if(build_uid>0)then exit;

   with pBuilder^  do
   with player^ do
     if (ai_curr_UpgrProds<ai_need_UpgrProds)
     and(ai_curr_UpgrProds<aip_MaxForges    )then
       case race of
       r_hell: SetBuildUID(uid_HPools);
       r_uac : SetBuildUID(UID_UWeaponFactory);
       end;
end;
procedure SetBuilders(needN:integer);
begin
   if(build_uid>0)then exit;

   with pBuilder^  do
   with player^ do
     if (ai_curr_Builders<needN)
     and(ai_curr_Builders<aip_MaxBuilders )
     and(ai_curr_Builders<PlayerMaxBuilders)then
       case race of
       r_hell: SetBuildUIDs(UID_HKeep,UID_HCommandCenter);
       r_uac : SetBuildUID (UID_UCommandCenter);
       end;
end;
procedure SetDetectors;
begin
   if(build_uid>0)then exit;

   with pBuilder^  do
   with player^ do
     if (ai_curr_Detect>ai_need_Detect)
     and(ai_curr_Detect>aip_MaxDetectors)then
     begin
        case race of
        r_hell: SetBuildUID(UID_HEyeNest);
        r_uac : SetBuildUID(UID_URadar  );
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
             0: SetBuildUID(UID_HPentagram,1);
             1: SetBuildUID(UID_HMonastery,1);
             2: SetBuildUID(UID_HFortress ,1);
             end;
     r_uac : case g_random(2) of
             0: SetBuildUID(UID_UScienceCenter  ,1);
             1: SetBuildUID(UID_UComputerStation,1);
             end;
     end;
end;
procedure SetSpecial;
begin
   if(build_uid>0)then exit;

   with pBuilder^  do
   with player^ do
     case race of
     r_hell: case g_random(2) of
             0: SetBuildUID(UID_HTeleport,1);
             1: SetBuildUID(UID_HAltar   ,1);
             end;
     r_uac : case g_random(3) of
             0: if(res_UACLoot  >0)then SetBuildUID(UID_UAcademy        ,1);
             1: if(res_HellPower>0)then SetBuildUID(UID_UHPowerConductor,1);
             2: SetBuildUID(UID_URMStation,1);
             end;
     end;
end;

begin
   build_uid :=0;
   build_x   :=0;
   build_y   :=0;
   build_dir :=-1;
   build_step:=-1;
   skipEnergyCheck:=false;

   with pBuilder^  do
   with player^ do
   begin
      // Define UID to build

      if((aip_flags and aif_base_smart_order)>0)then
      begin
         SetTowers;
         if(ai_enemy_inv_u<>nil)
    then SetDetectors;
         SetGenerators;
         SetBarracks;
         if(map_generators>0)
    then SetBuilders(ai_need_Builders);
         SetForges;
         SetDetectors;
         SetBuilders(2);
         SetTech;
         SetSpecial;
         if(map_generators=0)
    then SetBuilders(ai_need_Builders);
      end
      else
        case g_random(5) of
        0 : SetTowers;
        1 : SetGenerators;
        2 : SetBarracks;
        3 : SetForges;
        4 : SetBuilders(ai_need_Builders);
        end;

      if(build_uid=0)then exit;

      // build

      if(build_dir <0)then build_dir :=g_random(360);
      if(build_step<0)then build_step:=g_random(min2i(uid^.uid_r+(aiu_BuildAttempts div 4)*25,srange));

      if(isselected)then writeln(build_uid,' ',build_step,' ',ai_energy_future,' ',ai_need_Energy,' ',aiu_BuildAttempts);

      rad_dir:=build_dir*degtorad;
      build_x:=x+trunc(build_step*cos(rad_dir));
      build_y:=y-trunc(build_step*sin(rad_dir));

      BuildingFindNewPlace(build_x,build_y,build_uid,playeri,@build_x,@build_y);

      if(unit_start_build(build_x,build_y,build_uid,playeri,true)<>ureq_place)
      then aiu_BuildAttempts:=0
      else
        if(aiu_BuildAttempts<aiu_BuildAttempts.MaxValue)then aiu_BuildAttempts+=1;
   end;
end;

function ai_NeedSuicide(pu:PTUnit):boolean;
begin
   ai_NeedSuicide:=false;
end;

function ai_UpgradeAbilities(pu:PTUnit):boolean;
begin
   ai_UpgradeAbilities:=false;
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
UID_UGenerator3   : if(res_energyl_cur>=400)
                    or((prod_unit_Max=prod_unit_Now)and(prod_upgr_Max=prod_upgr_Now))then
                      case uidi of
                      UID_HSymbol1   : ai_UpgradeAbilities:=ai_UnitAbility(pu,uab_ToHSymbol2   ,0,0,0);
                      UID_HSymbol2   : ai_UpgradeAbilities:=ai_UnitAbility(pu,uab_ToHSymbol3   ,0,0,0);
                      UID_HSymbol3   : ai_UpgradeAbilities:=ai_UnitAbility(pu,uab_ToHSymbol4   ,0,0,0);
                      UID_UGenerator1: ai_UpgradeAbilities:=ai_UnitAbility(pu,uab_ToUGenerator2,0,0,0);
                      UID_UGenerator2: ai_UpgradeAbilities:=ai_UnitAbility(pu,uab_ToUGenerator3,0,0,0);
                      UID_UGenerator3: ai_UpgradeAbilities:=ai_UnitAbility(pu,uab_ToUGenerator4,0,0,0);
                      end;
UID_HKeep,
UID_HCommandCenter,
UID_UCommandCenter: if((race=r_uac)and(u_royal_d>base_r3))
                      or(map_scenario<>mc_royale)
                      or((race=r_hell)and(u_royal_d>base_r5))then
                        if//(ai_inprogress_auid<2)and(ai_inprogress_uid=0)and
                        (units_builders_ec>1)and(ai_enemy_d>base_r2)and(ai_curr_UnitProds>0)and(res_energyl_cur>=1500)then
                          case uidi of
                          UID_HKeep         : ai_UpgradeAbilities:=ai_UnitAbility(pu,uab_ToHAKeep         ,0,0,0);
                          UID_HCommandCenter: ai_UpgradeAbilities:=ai_UnitAbility(pu,uab_ToHACommandCenter,0,0,0);
                          UID_UCommandCenter: ai_UpgradeAbilities:=ai_UnitAbility(pu,uab_ToUACommandCenter,0,0,0);
                          end;

      end;
   end;
end;

procedure ai_Local_Code(pu:PTUnit);
begin
   with pu^  do
     if(ai_alarm_d<NOTSET)then
     begin
        aiu_alarm_d:=ai_alarm_d;
        aiu_alarm_x:=ai_alarm_x;
        aiu_alarm_y:=ai_alarm_y;
     end;
   //if(pu^.isselected)then writeln(ai_inprogress_auid);
end;

procedure ai_Global_Code(pu:PTUnit);
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
     ai_ProdRequirements(pu);

     if(uid_isbuilder)then ai_Builder(pu);

     if((aip_flags and aif_base_suicide)>0)then
       if(ai_NeedSuicide(pu))then
       begin
          unit_kill(pu,false,true,true,false,true);
          exit;
       end;

     if(ai_UpgradeAbilities(pu))then exit;

   end;
end;


