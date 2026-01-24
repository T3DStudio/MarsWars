
////////////////////////////////////////////////////////////////////////////////
//
//   UNITS CONSTANT DATA FUNCTIONS
//

procedure unit_ApplyUID(pu:PTUnit);
begin
   with pu^ do
   begin
      uid:=@g_uids[uidi];
      with uid^ do
      begin
         srange     :=uid_r+uid_r;
         speed      :=uid_MSpeed_Base;
         isfly      :=uid_isfly;
         transportM :=uid_TransportMax_Base;
         pains      :=uid_Pain;

         if(uid_isbuilding)and(uid_isbarrack)then
           rpoint_y:=y+uid_r;

         {$IFDEF _FULLGAME}
         animw  := uid_AnimStepWalk;
         shadowz:= unit_CalcShadowZ(pu,true);
         unit_CalcFogR(pu);
         {$ENDIF}
         hits:=uid_MaxHits1;
      end;
   end;
end;

function UIDHaveAbility(uid,aid:byte):boolean;
begin
   with g_uids[uid] do
     UIDHaveAbility:=(uid_ability1=aid)
                   or(uid_ability2=aid)
                   or(uid_ability3=aid);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   UNITS CONSTANT DATA
//

procedure InitUIDS;
var i,u,p:byte;
procedure SetWeapon(wid,wtype:byte;wmax_range,wmin_range,wcount:integer;wreload,woid,wreq_ruid,wreq_rupid,wdupgr:byte;wdupgrs:integer;wtarf,wreq_flags:cardinal;wuids,wShotPoints:TSoB;wax,way:integer;wafakeshots,wadmod:byte);
begin
   with g_uids[i] do
     if(wid<=LastUnitArms)then
       with uid_arms[wid] do
       begin
          aw_type           :=wtype;
          aw_max_range      :=wmax_range;
          aw_min_range      :=wmin_range;
          aw_reload         :=wreload;
          aw_object_count   :=wcount;
          aw_object_id      :=woid;
          aw_req_uid        :=wreq_ruid;
          aw_req_upgr       :=wreq_rupid;
          aw_req_flags      :=wreq_flags;
          aw_impact_upgr    :=wdupgr;
          aw_impact_upgrStep:=wdupgrs;
          aw_impact_dmod    :=wadmod;
          aw_tar_Flags      :=wtarf;
          aw_tar_uids       :=wuids;
          aw_offset_x       :=wax;
          aw_offset_y       :=way;
          aw_FakeShotsN     :=wafakeshots;
          if(wShotPoints<>[])
          then aw_ShotPoints:=wShotPoints
          else aw_ShotPoints:=[aw_reload];
       end;
end;
begin
   FillChar(g_uids,SizeOf(g_uids),0);

   for i:=0 to 255 do
   with g_uids[i] do
   begin
      uid_MaxHits1     := 0;
      uid_ProdTimeSec  := 1;
      uid_uibtn        := 255;
      uid_race         := r_hell;
      uid_CanAttack    := false;
      uid_FastDeathHits:=-32000;
      uid_LimitUse     := MinUnitLimit;

      uid_isfly        := uf_ground;
      uid_isbuilding   := false;
      uid_ismech       := false;
      uid_islight      := false;

      uid_isdetector   := false;

      uid_isbuilder    := false;
      uid_isforge      := false;
      uid_isbarrack    := false;
      uid_issolid      := true;

      case i of
//         HELL BUILDINGS   ////////////////////////////////////////////////////

// BUILDERS
UID_HKeep,
UID_HAKeep:
begin
   uid_MaxHits1        := 12000;
   uid_req_EnergyLevel := 1000;
   uid_r               := 66;
   uid_uibtn           := 0;
   uid_ProdTimeSec     := ptime3;
   uid_SightR_Base     := 250;
   uid_SightR_upgr     := upgr_hell_BuilderR;
   uid_SightR_upgrV    := 50;
   uid_Regen_Base      := BaseRegen1;
   uid_Regen_Upgr      := upgr_hell_BuildRestore;
   uid_Armor_upgr1     := upgr_hell_BuildArmor;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_isbuilder       := true;
   uid_prod_Buildings  := [UID_HKeep..UID_HCommandCenter]-[UID_HAKeep,UID_HSymbol2,UID_HSymbol3,UID_HSymbol4,UID_HACommandCenter,UID_HBarracks];
   uid_ability1        := uab_HKeepShift;
   uid_ability2        := uab_HKeepAura;

   case i of
UID_HKeep : begin
               uid_gen_EnergyLevel:= 400;
               uid_ability3       := uab_ToHAKeep;
               uid_AI_NextFormUID := UID_HAKeep;
            end;
UID_HAKeep: begin
               uid_gen_EnergyLevel:= 1000;
               uid_req_EnergyLevel:= 400;
            end;
   end;
end;

// UNIT&UPGRADES PRODS
UID_HGate:
begin
   uid_MaxHits1        := 8000;
   uid_req_EnergyLevel := 400;
   uid_r               := 60;
   uid_uibtn           := 1;
   uid_ProdTimeSec     := ptime2;
   uid_Regen_Base      := BaseRegen1;
   uid_Regen_Upgr      := upgr_hell_BuildRestore;
   uid_Armor_upgr1     := upgr_hell_BuildArmor;
   uid_OutUnitsTeleBuff:= true;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_isbarrack       := true;
   uid_prod_Units      := [UID_Imp..UID_Mastermind];
   uid_ability3        := uab_ToHGate;
   uid_AI_NextFormUID  := i;
end;

UID_HPools:
begin
   uid_MaxHits1        := 8000;
   uid_req_EnergyLevel := 400;
   uid_r               := 53;
   uid_uibtn           := 5;
   uid_ProdTimeSec     := ptime2;
   uid_Regen_Base      := BaseRegen1;
   uid_Regen_Upgr      := upgr_hell_BuildRestore;
   uid_Armor_upgr1     := upgr_hell_BuildArmor;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_isforge         := true;
   uid_ability3        := uab_ToHPool;
   uid_AI_NextFormUID  := i;
end;

// ENERGY PROD
UID_HSymbol1,
UID_HSymbol2,
UID_HSymbol3,
UID_HSymbol4:
begin
   uid_MaxHits1        := 1000;
   uid_gen_EnergyLevel := 50;
   uid_req_EnergyLevel := 50;
   uid_r               := 22;
   uid_uibtn           := 2;
   uid_ProdTimeSec     := ptime1;
   uid_Regen_Base      := BaseRegen1;
   uid_isbuilding      := true;
   uid_islight         := true;
   uid_ismech          := false;
   uid_Armor_upgr1     := upgr_hell_BuildArmor;
   uid_Regen_Upgr      := upgr_hell_BuildRestore;

   case i of
UID_HSymbol1: begin
              uid_ability3       := uab_ToHSymbol2;
              uid_AI_NextFormUID := UID_HSymbol2;
              end;
UID_HSymbol2: begin
              uid_gen_EnergyLevel*= 2;
              uid_req_EnergyLevel:= 0;
              uid_ability3       := uab_ToHSymbol3;
              uid_AI_NextFormUID := UID_HSymbol3;
              end;
UID_HSymbol3: begin
              uid_gen_EnergyLevel*= 3;
              uid_req_EnergyLevel:= 0;
              uid_ability3       := uab_ToHSymbol4;
              uid_AI_NextFormUID := UID_HSymbol4;
              end;
UID_HSymbol4: begin
              uid_gen_EnergyLevel*= 4;
              uid_req_EnergyLevel:= 0;
              end;
   end;
end;

// TECH
UID_HMonastery:
begin
   uid_MaxHits1        := 12000;
   uid_req_EnergyLevel := 1200;
   uid_r               := 65;
   uid_uibtn           := 9;
   uid_ProdTimeSec     := ptime5;
   uid_Regen_Base      := BaseRegen1;
   uid_Regen_Upgr      := upgr_hell_BuildRestore;
   uid_Armor_upgr1     := upgr_hell_BuildArmor;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_req_uid1        := UID_HPools;
end;
UID_HPentagram:
begin
   uid_MaxHits1        := 12000;
   uid_req_EnergyLevel := 1200;
   uid_r               := 65;
   uid_uibtn           := 10;
   uid_ProdTimeSec     := ptime5;
   uid_Regen_Base      := BaseRegen1;
   uid_Regen_Upgr      := upgr_hell_BuildRestore;
   uid_Armor_upgr1     := upgr_hell_BuildArmor;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_issolid         := false;
   uid_req_uid1        := UID_HPools;
end;
UID_HFortress:
begin
   uid_MaxHits1        := 12000;
   uid_req_EnergyLevel := 1200;
   uid_r               := 86;
   uid_uibtn           := 11;
   uid_ProdTimeSec     := ptime5;
   uid_Regen_Base      := BaseRegen1;
   uid_Regen_Upgr      := upgr_hell_BuildRestore;
   uid_Armor_upgr1     := upgr_hell_BuildArmor;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_req_uid1        := UID_HPools;
end;

// SPECIAL

UID_HEye:
begin
   uid_MaxHits1        := 50;
   uid_req_EnergyLevel := 50;
   uid_r               := 10;
   uid_SightR_Base     := 300;
   uid_SightR_upgr     := upgr_hell_EvilEyeR;
   uid_SightR_upgrV    := 50;
   uid_uibtn           := 12;
   uid_ProdTimeSec     := ptime1h;
   uid_Regen_Base      := BaseRegen1;
   uid_Regen_Upgr      := upgr_hell_BuildRestore;
   uid_Armor_upgr1     := upgr_hell_BuildArmor;
   uid_isbuilding      := true;
   uid_issolid         := false;
   uid_islight         := true;
   uid_ismech          := false;
   uid_isdetector      := true;
   uid_ability1        := uab_HEyeBlink;
   uid_ability2        := uab_HEyeVision;
end;
UID_HTeleport:
begin
   uid_MaxHits1        := 5000;
   uid_req_EnergyLevel := 400;
   uid_r               := 28;
   uid_SightR_Base     := 100;
   uid_uibtn           := 13;
   uid_ProdTimeSec     := ptime2;
   uid_Regen_Base      := BaseRegen1;
   uid_Regen_Upgr      := upgr_hell_BuildRestore;
   uid_Armor_upgr1     := upgr_hell_BuildArmor;
   uid_LimitUse        := ul3;
   uid_ability1        := uab_Teleport;
   uid_ability2        := uab_Recall;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_issolid         := false;
   uid_req_uid1        := UID_HAKeep;
end;
UID_HAltar:
begin
   uid_MaxHits1        := 8000;
   uid_req_EnergyLevel := 1200;
   uid_r               := 50;
   uid_uibtn           := 14;
   uid_LimitUse        := ul10;
   uid_ProdTimeSec     := ptime4;
   uid_Regen_Base      := BaseRegen1;
   uid_Regen_Upgr      := upgr_hell_BuildRestore;
   uid_Armor_upgr1     := upgr_hell_BuildArmor;
   uid_req_uid1        := UID_HFortress;
   uid_isbuilding      := true;
   uid_ismech          := false;
   uid_ability1        := uab_SphereRDamage;
   uid_ability2        := uab_SphereDDamage;
   uid_ability3        := uab_SphereTurbo;
end;

// STAT DEF

UID_HFTower:
begin
   uid_MaxHits1        := 3000;
   uid_req_EnergyLevel := 400;
   uid_r               := 20;
   uid_SightR_Base     := 300;
   uid_SightR_upgr     := upgr_hell_TowerR;
   uid_SightR_upgrV    := 25;
   uid_uibtn           := 6;
   uid_ProdTimeSec     := ptime2;
   uid_Regen_Base      := BaseRegen1;
   uid_Regen_Upgr      := upgr_hell_BuildRestore;
   uid_Armor_upgr1     := upgr_hell_BuildArmor;
   uid_ability1        := uab_HTowerBlink;
   uid_ability2        := uab_ToHSTower;
   uid_ability3        := uab_ToHTotem;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_islight         := true;

   SetWeapon(0,wpt_missle,aw_srange,0,0 ,fr_fpst,MID_Imp,0,0,upgr_hell_DistDamage1,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all-[UID_Imp],[],0,-26,0,dm_AntiUnitBioHeavy2);
end;
UID_HSTower:
begin
   uid_MaxHits1        := 3000;
   uid_req_EnergyLevel := 400;
   uid_r               := 20;
   uid_SightR_Base     := 300;
   uid_SightR_upgr     := upgr_hell_TowerR;
   uid_SightR_upgrV    := 25;
   uid_uibtn           := 7;
   uid_ProdTimeSec     := ptime2;
   uid_Regen_Base      := BaseRegen1;
   uid_Regen_Upgr      := upgr_hell_BuildRestore;
   uid_Armor_upgr1     := upgr_hell_BuildArmor;
   uid_ability1        := uab_HTowerBlink;
   uid_ability2        := uab_ToHFTower;
   uid_ability3        := uab_ToHTotem;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_islight         := true;

   SetWeapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsh,MID_Baron,0,0,upgr_hell_DistDamage1,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all-[UID_Baron,UID_Knight],[],0,-20,0,dm_AntiUnitLight2);
end;
UID_HTotem:
begin
   uid_MaxHits1        := 2000;
   uid_req_EnergyLevel := 600;
   uid_r               := 20;
   uid_SightR_Base     := 350;
   uid_SightR_upgr     := upgr_hell_TowerR;
   uid_SightR_upgrV    := 25;
   uid_uibtn           := 8;
   uid_ProdTimeSec     := ptime2;
   uid_req_uid1        := UID_HFortress;
   uid_ability1        := uab_HTowerBlink;
   uid_ability2        := uab_ToHFTower;
   uid_ability3        := uab_ToHSTower;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_islight         := true;
   uid_Regen_upgr      := upgr_hell_BuildRestore;
   uid_Armor_upgr1     := upgr_hell_BuildArmor;
   SetWeapon(0,wpt_missle,aw_srange,0,0,fr_fps2,MID_ArchFire,0,0,0,0,wtrset_enemy_alive,wpr_any,uids_all,[fr_archvile_s],0,0,0,0);
end;


//////////////////////////////

UID_Imp       :
begin
   uid_MaxHits1        := 1000;
   uid_req_EnergyLevel := 200;
   uid_r               := 11;
   uid_MSpeed_Base     := 10;
   uid_Armor_upgr1     := upgr_hell_UnitArmor;
   uid_Regen_Upgr      := upgr_hell_Regeneration;
   uid_SightR_Base     := 200;
   uid_SightR_upgr     := upgr_hell_UnitSightR;
   uid_uibtn           := 0;
   uid_PainState_Base  := 2;
   uid_PainState_upgr  := upgr_hell_PainFactor;
   uid_ProdTimeSec     := ptime1;
   uid_islight         := true;
   uid_FastDeathHits   := hits_fdead_border;
   uid_arms_BonusAntiFlyRange:=-50;
   SetWeapon(0,wpt_missle   ,aw_srange,0,0          ,fr_fps1,MID_Imp,0,0,upgr_hell_DistDamage1,UpgradeDamageBonus1,wtrset_enemy_alive       ,wpr_any,uids_all-[UID_Imp],[],0,-5,0,dm_AntiUnitBioHeavy2);
   SetWeapon(1,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fps1,0      ,0,0,upgr_hell_MeleeDamage,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Imp],[],0, 0,0,0);
end;
UID_Demon     :
begin
   uid_MaxHits1        := 1500;
   uid_req_EnergyLevel := 300;
   uid_r               := 14;
   uid_MSpeed_Base     := 16;
   uid_Armor_upgr1     := upgr_hell_UnitArmor;
   uid_Regen_Upgr      := upgr_hell_Regeneration;
   uid_SightR_Base     := 200;
   uid_SightR_upgr     := upgr_hell_UnitSightR;
   uid_uibtn           := 1;
   uid_PainState_Base  := 6;
   uid_PainState_upgr  := upgr_hell_PainFactor;
   uid_ProdTimeSec     := ptime1;
   SetWeapon(0,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fpst2,0,0,0,upgr_hell_MeleeDamage,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any ,uids_all,[],0,0,0,dm_AntiUnitBioHeavy2);
end;
{
2 2000 2
2 2500 1.5
}
UID_Knight    :
begin
   uid_MaxHits1        := 2500;
   uid_req_EnergyLevel := 300;
   uid_r               := 14;
   uid_MSpeed_Base     := 10;
   uid_Armor_upgr1     := upgr_hell_UnitArmor;
   uid_Regen_Upgr      := upgr_hell_Regeneration;
   uid_SightR_Base     := 250;
   uid_SightR_upgr     := upgr_hell_UnitSightR;
   uid_uibtn           := 2;
   uid_PainState_Base  := 6;
   uid_PainState_upgr  := upgr_hell_PainFactor;
   uid_ProdTimeSec     := ptime1h;
   uid_LimitUse        := ul2;
   uid_islight         := true;
   SetWeapon(0,wpt_missle   ,aw_srange,0,0          ,fr_fps1  ,MID_Baron,0,0,upgr_hell_DistDamage1,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all-[UID_Knight,UID_Baron],[],0,0,0,dm_AntiUnitLight2);
   SetWeapon(1,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fps1  ,0        ,0,0,upgr_hell_MeleeDamage,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Knight,UID_Baron],[],0,0,0,dm_AntiUnitLight2);
end;
UID_Baron     :
begin
   {
   3 3000 3
   3 4000 2
   3 4500 1.5
   }
   uid_MaxHits1        := 4500;
   uid_req_EnergyLevel := 500;
   uid_r               := 14;
   uid_MSpeed_Base     := 10;
   uid_Armor_upgr1     := upgr_hell_UnitArmor;
   uid_Regen_Upgr      := upgr_hell_Regeneration;
   uid_SightR_Base     := 275;
   uid_SightR_upgr     := upgr_hell_UnitSightR;
   uid_uibtn           := 3;
   uid_PainState_Base  := 8;
   uid_PainState_upgr  := upgr_hell_PainFactor;
   uid_ProdTimeSec     := ptime1h;
   uid_LimitUse        := ul3;
   uid_islight         := false;
   SetWeapon(0,wpt_missle   ,aw_srange,0,0          ,fr_fps1   ,MID_Baron,0,0,upgr_hell_DistDamage1,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all-[UID_Knight,UID_Baron],[],0,0,0,dm_AntiUnitLight2);
   SetWeapon(1,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fps1   ,0        ,0,0,upgr_hell_MeleeDamage,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Knight,UID_Baron],[],0,0,0,dm_AntiUnitLight2);
end;
UID_Revenant   :
begin
   uid_MaxHits1        := 1500;
   uid_req_EnergyLevel := 300;
   uid_r               := 13;
   uid_MSpeed_Base     := 14;
   uid_Armor_upgr1     := upgr_hell_UnitArmor;
   uid_Regen_Upgr      := upgr_hell_Regeneration;
   uid_SightR_Base     := 225;
   uid_SightR_upgr     := upgr_hell_UnitSightR;
   uid_uibtn           := 4;
   uid_PainState_Base  := 4;
   uid_PainState_upgr  := upgr_hell_PainFactor;
   uid_ProdTimeSec     := ptime1;
   uid_LimitUse        := ul1h;
   uid_islight         := false;
   uid_arms_BonusAntiFlyRange:=100;
   SetWeapon(0,wpt_missle   ,aw_srange ,0,0          ,fr_fps1,MID_Revenant ,0,0,upgr_hell_DistDamage2,UpgradeDamageBonus1,wtrset_enemy_alive       ,wpr_any,uids_all-[UID_Revenant],[],0,-7,0,dm_AntiFly2);
   SetWeapon(1,wpt_directdmg,aw_dmelee ,0,BaseDamage1,fr_fps1,0            ,0,0,upgr_hell_MeleeDamage,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Revenant],[],0, 0,0,0);
end;
UID_Cacodemon :
begin
   uid_MaxHits1        := 2000;
   uid_req_EnergyLevel := 250;
   uid_r               := 14;
   uid_MSpeed_Base     := 10;
   uid_Armor_upgr1     := upgr_hell_UnitArmor;
   uid_Regen_Upgr      := upgr_hell_Regeneration;
   uid_SightR_Base     := 200;
   uid_SightR_upgr     := upgr_hell_UnitSightR;
   uid_uibtn           := 5;
   uid_PainState_Base  := 4;
   uid_PainState_upgr  := upgr_hell_PainFactor;
   uid_ProdTimeSec     := ptime1q;
   uid_LimitUse        := ul1h;
   uid_isfly           := uf_fly;
   uid_req_uid1        := UID_HAKeep;
   uid_zfall           := fly_height[uf_fly];
   uid_arms_BonusAntiFlyRange:=50;
   SetWeapon(0,wpt_missle   ,aw_srange ,0,0          ,fr_fps1   ,MID_Cacodemon,0,0,upgr_hell_DistDamage1,UpgradeDamageBonus1,wtrset_enemy_alive      ,wpr_any,uids_all-[UID_Cacodemon],[],0,0,0,dm_AntiUnitMech2);
   SetWeapon(1,wpt_directdmg,aw_dmelee ,0,BaseDamage1,fr_fps1   ,0            ,0,0,upgr_hell_MeleeDamage,UpgradeDamageBonus1,wtrset_enemy_alive_fly  ,wpr_any,         [UID_Cacodemon],[],0,0,0,0);
end;

// 'T2' bio
uid_Pain      :
begin
   uid_MaxHits1        := 2000;
   uid_req_EnergyLevel := 600;
   uid_r               := 15;
   uid_MSpeed_Base     := 7;
   uid_Armor_upgr1     := upgr_hell_UnitArmor;
   uid_Regen_Upgr      := upgr_hell_Regeneration;
   uid_SightR_Base     := 225;
   uid_SightR_upgr     := upgr_hell_UnitSightR;
   uid_uibtn           := 6;
   uid_PainState_Base  := 3;
   uid_PainState_upgr  := upgr_hell_PainFactor;
   uid_ProdTimeSec     := ptime2;
   uid_req_uid1        := UID_HMonastery;
   uid_req_uid2        := UID_HAKeep;
   uid_LimitUse        := ul1;
   uid_isfly           := uf_fly;
   uid_ability1        := uab_SpawnLost;
   uid_ability2        := uab_SpawnLostTo;
   uid_LevelBonusDamage:= -1;
   uid_DeathUID        := UID_LostSoul;
   uid_DeathUIDn       := 3;
   SetWeapon(0,wpt_unit,aw_fsr+50,0,0 ,fr_fps2,UID_Phantom ,0,upgr_hell_Phantoms,0,0,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,0,0);
   SetWeapon(1,wpt_unit,aw_fsr+50,0,0 ,fr_fps2,UID_LostSoul,0,0                 ,0,0,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,0,0);

   uid_FastDeathHits:=1;
end;

{
2.4 lim 2400hp 149 dps
3   lim 3600hp 149 dps
}
UID_Mancubus  :
begin
   uid_MaxHits1        := 4000;
   uid_req_EnergyLevel := 500;
   uid_r               := 17;
   uid_MSpeed_Base     := 8;
   uid_Armor_upgr1     := upgr_hell_UnitArmor;
   uid_Regen_Upgr      := upgr_hell_Regeneration;
   uid_SightR_Base     := 275;
   uid_SightR_upgr     := upgr_hell_UnitSightR;
   uid_uibtn           := 7;
   uid_PainState_Base  := 8;
   uid_PainState_upgr  := upgr_hell_PainFactor;
   uid_ProdTimeSec     := ptime1h;
   uid_req_uid1        := UID_HMonastery;
   uid_LimitUse        := ul3;
   uid_arms_BonusAntiBuildingRange:=50;
   SetWeapon(0,wpt_missle,aw_srange,0,-9,fr_mancubus_rld,MID_Mancubus,0,0,upgr_hell_DistDamage2,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all-[UID_Mancubus],[fr_mancubus_rld_s1,fr_mancubus_rld_s2,fr_mancubus_rld_s3],0,0,0,dm_Siege4);
end;
UID_Archvile:
begin
   uid_MaxHits1        := 5000;
   uid_req_EnergyLevel := 700;
   uid_r               := 14;
   uid_MSpeed_Base     := 16;
   uid_Armor_upgr1     := upgr_hell_UnitArmor;
   uid_Regen_Upgr      := upgr_hell_Regeneration;
   uid_SightR_Base     := 350;
   uid_SightR_upgr     := upgr_hell_UnitSightR;
   uid_uibtn           := 8;
   uid_PainState_Base  := 10;
   uid_PainState_upgr  := upgr_hell_PainFactor;
   uid_ProdTimeSec     := ptime1h;
   uid_req_uid1        := UID_HMonastery;
   uid_LimitUse        := ul4;
   uid_islight         := true;
   SetWeapon(0,wpt_resurect,aw_dmelee,0,3  ,fr_fpsh,0           ,0,upgr_hell_Resurrect,0,0,wtrset_resurect   ,wpr_any,uids_arch_res,[             ],0,0,0,0);
   SetWeapon(1,wpt_missle  ,aw_fsr   ,0,0  ,fr_fps2,MID_ArchFire,0,0                  ,0,0,wtrset_enemy_alive,wpr_any,uids_all     ,[fr_archvile_s],0,0,0,0);
end;

// 'T2' mech
UID_Arachnotron:
begin
   uid_MaxHits1        := 3000;
   uid_req_EnergyLevel := 500;
   uid_r               := 17;
   uid_MSpeed_Base     := 11;
   uid_Armor_upgr1     := upgr_hell_UnitArmor;
   uid_Regen_Upgr      := upgr_hell_Regeneration;
   uid_SightR_Base     := 275;
   uid_SightR_upgr     := upgr_hell_UnitSightR;
   uid_uibtn           := 9;
   uid_PainState_Base  := 8;
   uid_PainState_upgr  := upgr_hell_PainFactor;
   uid_ProdTimeSec     := ptime1h;
   uid_req_uid1        := UID_HPentagram;
   uid_LimitUse        := ul3;
   uid_ismech          := true;
   uid_arms_BonusAntiUnitRange:=50;
   SetWeapon(0,wpt_missle,aw_srange,0,0 ,fr_fpst,MID_YPlasma,0,0,upgr_hell_DistDamage2,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all-[UID_Arachnotron],[],0,0,2,dm_AntiUnitMech2);
end;
UID_Mastermind :
begin
   uid_MaxHits1        := 14000;
   uid_req_EnergyLevel := 1200;
   uid_r               := 28;
   uid_MSpeed_Base     := 14;
   uid_Armor_upgr1     := upgr_hell_UnitArmor;
   uid_Regen_Upgr      := upgr_hell_Regeneration;
   uid_SightR_Base     := 300;
   uid_SightR_upgr     := upgr_hell_UnitSightR;
   uid_uibtn           := 10;
   uid_PainState_Base  := 12;
   uid_PainState_upgr  := upgr_hell_PainFactor;
   uid_ProdTimeSec     := ptime4;
   uid_req_uid1        := UID_HPentagram;
   uid_LimitUse        := ul10;
   uid_ismech          := true;
   uid_arms_BonusAntiUnitRange:=50;
   SetWeapon(0,wpt_missle   ,aw_srange,0,0 ,fr_fpss,MID_SChaingun,0,0,upgr_hell_DistDamage2,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,2,dm_AntiBio2);
end;
UID_Cyberdemon :
begin
   uid_MaxHits1        := 15000;
   uid_req_EnergyLevel := 1200;
   uid_r               := 20;
   uid_MSpeed_Base     := 14;
   uid_Armor_upgr1     := upgr_hell_UnitArmor;
   uid_Regen_Upgr      := upgr_hell_Regeneration;
   uid_SightR_Base     := 275;
   uid_SightR_upgr     := upgr_hell_UnitSightR;
   uid_uibtn           := 11;
   uid_PainState_Base  := 12;
   uid_PainState_upgr  := upgr_hell_PainFactor;
   uid_ProdTimeSec     := ptime4;
   uid_req_uid1        := UID_HPentagram;
   uid_LimitUse        := ul10;
   uid_ismech          := true;
   uid_arms_BonusAntiBuildingRange:=50;
   SetWeapon(0,wpt_missle   ,aw_srange,0,0 ,fr_fps1   ,MID_HRocket,0,0,upgr_hell_DistDamage2,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,0,dm_Siege4);
end;

UID_Phantom,
UID_LostSoul  :
begin
   uid_MaxHits1        := 1000;
   uid_r               := 10;
   uid_MSpeed_Base     := 24;
   uid_Armor_upgr1     := upgr_hell_UnitArmor;
   uid_Regen_Upgr      := upgr_hell_Regeneration;
   uid_SightR_Base     := 175;
   uid_SightR_upgr     := upgr_hell_UnitSightR;
   uid_PainState_Base  := 1;
   uid_PainState_upgr  := upgr_hell_PainFactor;
   uid_isfly           := uf_fly;
   uid_islight         := true;
   uid_FastDeathHits   := 1;
   uid_FlyLevelLikeTarget:=true;
   case i of
UID_LostSoul: begin
              uid_uibtn          := 12;
              uid_req_EnergyLevel:= 100;
              uid_ProdTimeSec    := ptimeh;
              end;
UID_Phantom : begin
              uid_uibtn          := 13;
              uid_req_EnergyLevel:= 200;
              uid_ProdTimeSec    := ptime1;
              SetWeapon(0,wpt_directdmgZ,aw_dmelee,0,BaseDamaget,fr_fps1,0,0,upgr_hell_Phantoms,upgr_hell_MeleeDamage,UpgradeDamageBonus1,wtrset_all,wpr_any,uids_all,[],0,0,0,dm_Lost);
              end;
   end;
   SetWeapon(1,wpt_directdmg ,aw_dmelee,0,BaseDamaget,fr_fps1,0,0,0                 ,upgr_hell_MeleeDamage,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0   ,0,dm_Lost);
end;

// ZOMBIE/UAC INFANTRY
UID_Sergant,
UID_ZSergant :
begin
   uid_MaxHits1        := 1000;

   uid_r               := 11;
   uid_SightR_Base     := 175;
   uid_ProdTimeSec     := ptime1;
   uid_islight         := true;
   uid_FastDeathHits   := hits_fdead_border;

   case i of
UID_Sergant : begin
              uid_uibtn          := 0;
              uid_req_EnergyLevel:= 200;
              uid_MSpeed_Base    := 12;
              uid_MSpeed_Upgr    := upgr_uac_BioSpeed;
              uid_Armor_upgr1    := upgr_uac_BioArmor;
              uid_SightR_upgr    := upgr_uac_UnitSightR;
              uid_ZombieUID      := UID_ZSergant;
              SetWeapon(0,wpt_missle,aw_srange,0,0,fr_fps1,MID_SShot,0,0,upgr_uac_DistDamage  ,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,0,dm_AntiUnitBioHeavy2);
              end;
UID_ZSergant: begin
              uid_uibtn          := 14;
              uid_req_UACLoot    := 100;
              uid_ProdTimeSec    -= uid_ProdTimeSec div 4;
              uid_MSpeed_Base    := 14;
              uid_Armor_upgr1    := upgr_hell_UnitArmor;
              uid_Regen_Upgr     := upgr_hell_Regeneration;
              uid_SightR_upgr    := upgr_hell_UnitSightR;
              uid_PainState_Base := 1;
              uid_PainState_upgr := upgr_hell_PainFactor;
              SetWeapon(0,wpt_missle,aw_srange,0,0,fr_fps1,MID_SShot,0,0,upgr_hell_DistDamage2,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,0,dm_AntiUnitBioHeavy2);
              end;
   end;
end;

UID_SSergant,
UID_ZSSergant:
begin
   uid_MaxHits1        := 1000;
   uid_r               := 11;
   uid_SightR_Base     := 175;
   uid_ProdTimeSec     := ptime1q;
   uid_LimitUse        := ul1h;
   uid_islight         := false;
   uid_FastDeathHits   := hits_fdead_border;

   case i of
UID_SSergant : begin
               uid_uibtn          := 1;
               uid_req_EnergyLevel:= 250;
               uid_MSpeed_Base    := 12;
               uid_MSpeed_Upgr    := upgr_uac_BioSpeed;
               uid_Armor_upgr1    := upgr_uac_BioArmor;
               uid_SightR_upgr    := upgr_uac_UnitSightR;
               uid_ZombieUID      := UID_ZSSergant;
               SetWeapon(0,wpt_missle,aw_srange,0,0,fr_fps1h,MID_SSShot,0,0,upgr_uac_DistDamage  ,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,0,dm_SSGShot2);
               end;
UID_ZSSergant: begin
               uid_uibtn         := 15;
               uid_req_UACLoot   := 150;
               uid_ProdTimeSec   -= uid_ProdTimeSec div 4;
               uid_MSpeed_Base   := 14;
               uid_Armor_upgr1   := upgr_hell_UnitArmor;
               uid_Regen_Upgr    := upgr_hell_Regeneration;
               uid_SightR_upgr   := upgr_hell_UnitSightR;
               uid_PainState_Base:= 1;
               uid_PainState_upgr:= upgr_hell_PainFactor;
               SetWeapon(0,wpt_missle,aw_srange,0,0,fr_fps1h,MID_SSShot,0,0,upgr_hell_DistDamage2,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,0,dm_SSGShot2);
               end;
   end;
end;

UID_Commando,
UID_ZCommando:
begin
   uid_MaxHits1        := 1000;
   uid_r               := 11;
   uid_SightR_Base     := 200;
   uid_ProdTimeSec     := ptime1q;
   uid_LimitUse        := ul1h;
   uid_FastDeathHits   := hits_fdead_border;
   uid_arms_BonusAntiFlyRange:=-50;
   case i of
UID_Commando : begin
               uid_uibtn          := 2;
               uid_req_EnergyLevel:= 250;
               uid_MSpeed_Base    := 12;
               uid_MSpeed_Upgr    := upgr_uac_BioSpeed;
               uid_Armor_upgr1    := upgr_uac_BioArmor;
               uid_SightR_upgr    := upgr_uac_UnitSightR;
               uid_ZombieUID      := UID_ZCommando;
               uid_islight        := true;
               SetWeapon(0,wpt_missle,aw_srange,0,0,fr_fpss,MID_Chaingun,0,0,upgr_uac_DistDamage  ,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,3,dm_AntiUnitBioLight2);
               end;
UID_ZCommando: begin
               uid_uibtn          := 16;
               uid_req_UACLoot    := 150;
               uid_ProdTimeSec    -= uid_ProdTimeSec div 4;
               uid_MSpeed_Base    := 14;
               uid_Armor_upgr1    := upgr_hell_UnitArmor;
               uid_Regen_Upgr     := upgr_hell_Regeneration;
               uid_SightR_upgr    := upgr_hell_UnitSightR;
               uid_PainState_Base := 1;
               uid_PainState_upgr := upgr_hell_PainFactor;
               uid_islight        := false;
               SetWeapon(0,wpt_missle,aw_srange,0,0,fr_fpss,MID_Chaingun,0,0,upgr_hell_DistDamage2,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,3,dm_AntiUnitBioLight2);
               end;
   end;
end;

UID_Antiaircrafter,
UID_ZAntiaircrafter:
begin
   uid_MaxHits1        := 1000;
   uid_r               := 11;
   uid_SightR_Base     := 175;
   uid_ProdTimeSec     := ptime1;
   uid_FastDeathHits   := hits_fdead_border;
   uid_arms_BonusAntiFlyRange:=75;
   case i of
UID_Antiaircrafter : begin
                     uid_uibtn          := 3;
                     uid_req_EnergyLevel:= 200;
                     uid_MSpeed_Base    := 12;
                     uid_MSpeed_Upgr    := upgr_uac_BioSpeed;
                     uid_Armor_upgr1    := upgr_uac_BioArmor;
                     uid_SightR_upgr    := upgr_uac_UnitSightR;
                     uid_ZombieUID      := UID_ZAntiaircrafter;
                     uid_islight        := false;
                     SetWeapon(0,wpt_missle,aw_srange,0,0,fr_fps1,MID_URocket ,0,0                 ,upgr_uac_DistDamage  ,UpgradeDamageBonus1,wtrset_enemy_alive_fly   ,wpr_any,uids_all,[],0,-4,0,dm_AntiFly2);
                     SetWeapon(1,wpt_missle,aw_srange,0,0,fr_fps1,MID_URocket ,0,upgr_uac_SSMWeapon,upgr_uac_DistDamage  ,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,0,dm_AntiUnitBioLight2);
                     end;
UID_ZAntiaircrafter: begin
                     uid_uibtn          := 17;
                     uid_req_UACLoot    := 100;
                     uid_ProdTimeSec    -= uid_ProdTimeSec div 4;
                     uid_MSpeed_Base    := 14;
                     uid_Armor_upgr1    := upgr_hell_UnitArmor;
                     uid_Regen_Upgr     := upgr_hell_Regeneration;
                     uid_SightR_upgr    := upgr_hell_UnitSightR;
                     uid_PainState_Base := 1;
                     uid_PainState_upgr := upgr_hell_PainFactor;
                     uid_islight        := true;
                     SetWeapon(0,wpt_missle,aw_srange,0,0 ,fr_fps1,MID_URocketS,0,0,upgr_hell_DistDamage2,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,-4,0,dm_AntiFly2);
                     end;
   end;
end;

UID_SiegeMarine,
UID_ZSiegeMarine:
begin
   uid_MaxHits1        := 1000;
   uid_r               := 11;
   uid_SightR_Base     := 175;
   uid_ProdTimeSec     := ptime1;
   uid_FastDeathHits   := hits_fdead_border;
   case i of
UID_SiegeMarine : begin
                  uid_uibtn          := 4;
                  uid_req_EnergyLevel:= 200;
                  uid_MSpeed_Base    := 10;
                  uid_MSpeed_Upgr    := upgr_uac_BioSpeed;
                  uid_Armor_upgr1    := upgr_uac_BioArmor;
                  uid_SightR_upgr    := upgr_uac_UnitSightR;
                  uid_ZombieUID      := UID_ZSiegeMarine;
                  uid_islight        := false;
                  uid_req_uid1       := UID_UWeaponFactory;
                  SetWeapon(0,wpt_missle,aw_srange,rocket_sr,0 ,fr_fps1,MID_Granade,0,0,upgr_uac_DistDamage  ,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,0,dm_Siege4);
                  end;
UID_ZSiegeMarine: begin
                  uid_uibtn          := 18;
                  uid_req_UACLoot    := 100;
                  uid_ProdTimeSec    -= uid_ProdTimeSec div 4;
                  uid_MSpeed_Base    := 12;
                  uid_Armor_upgr1    := upgr_hell_UnitArmor;
                  uid_Regen_Upgr     := upgr_hell_Regeneration;
                  uid_SightR_upgr    := upgr_hell_UnitSightR;
                  uid_PainState_Base := 1;
                  uid_PainState_upgr := upgr_hell_PainFactor;
                  uid_islight        := true;
                  SetWeapon(0,wpt_missle,aw_srange,rocket_sr,0 ,fr_fps1,MID_Granade,0,0,upgr_hell_DistDamage2,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,0,dm_Siege4);
                  end;
   end;

end;

UID_FPlasmagunner,
UID_ZFPlasmagunner:
begin
   uid_MaxHits1        := 1000;
   uid_r               := 11;
   uid_SightR_Base     := 200;
   uid_ProdTimeSec     := ptime1q;
   uid_LimitUse        := ul1h;
   uid_FastDeathHits   := 1;
   uid_isfly           := uf_fly;
   uid_arms_BonusAntiFlyRange:=50;

   case i of
UID_FPlasmagunner : begin
                    uid_uibtn          := 5;
                    uid_req_EnergyLevel:= 250;
                    uid_MSpeed_Base    := 12;
                    uid_MSpeed_Upgr    := upgr_uac_BioSpeed;
                    uid_Armor_upgr1    := upgr_uac_BioArmor;
                    uid_SightR_upgr    := upgr_uac_UnitSightR;
                    uid_ZombieUID      := UID_ZFPlasmagunner;
                    uid_ZombieHits     := uid_MaxHits1 div 10;
                    uid_islight        := false;
                    uid_req_uid1       := UID_UACommandCenter;
                    SetWeapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsq,MID_BPlasma,0,0,upgr_uac_DistDamage  ,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all,[],0,0,2,dm_AntiUnitMech2);
                    end;
UID_ZFPlasmagunner: begin
                    uid_uibtn          := 19;
                    uid_req_UACLoot    := 150;
                    uid_ProdTimeSec    -= uid_ProdTimeSec div 4;
                    uid_MSpeed_Base    := 14;
                    uid_Armor_upgr1    := upgr_hell_UnitArmor;
                    uid_Regen_Upgr     := upgr_hell_Regeneration;
                    uid_SightR_upgr    := upgr_hell_UnitSightR;
                    uid_PainState_Base := 1;
                    uid_PainState_upgr := upgr_hell_PainFactor;
                    uid_islight        := true;
                    uid_req_uid2       := UID_HACommandCenter;
                    SetWeapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsq,MID_BPlasma,0,0,upgr_hell_DistDamage2,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all,[],0,0,2,dm_AntiUnitMech2);
                    end;
   end;
end;


UID_BFGMarine,
UID_ZBFGMarine:
begin
   uid_MaxHits1        := 1000;
   uid_r               := 11;
   uid_SightR_Base     := 250;
   uid_ProdTimeSec     := ptime3;
   uid_LimitUse        := ul5;
   uid_islight         := false;
   uid_FastDeathHits   := hits_fdead_border;
   uid_arms_BonusAntiUnitRange:=50;

   case i of
UID_BFGMarine : begin
                uid_uibtn          := 6;
                uid_req_EnergyLevel:= 600;
                uid_MSpeed_Base    := 10;
                uid_MSpeed_Upgr    := upgr_uac_BioSpeed;
                uid_Armor_upgr1    := upgr_uac_BioArmor;
                uid_SightR_upgr    := upgr_uac_UnitSightR;
                uid_ZombieUID      := UID_ZBFGMarine;
                uid_req_uid1       := UID_UTechCenter;
                uid_req_uid2       := UID_UComputerStation;
                SetWeapon(0,wpt_missle,aw_srange,0,0,fr_fps2,MID_BFG,0,0,upgr_uac_DistDamage  ,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[fr_fps1],0,0,0,dm_BFG);
                end;
UID_ZBFGMarine: begin
                uid_uibtn          := 20;
                uid_req_UACLoot    := 500;
                uid_ProdTimeSec    -= uid_ProdTimeSec div 4;
                uid_MSpeed_Base    := 12;
                uid_Armor_upgr1    := upgr_hell_UnitArmor;
                uid_Regen_Upgr     := upgr_hell_Regeneration;
                uid_SightR_upgr    := upgr_hell_UnitSightR;
                uid_PainState_Base := 1;
                uid_PainState_upgr := upgr_hell_PainFactor;
                uid_req_uid2       := UID_HACommandCenter;
                uid_req_uid2n      := 2;
                SetWeapon(0,wpt_missle,aw_srange,0,0,fr_fps2,MID_BFG,0,0,upgr_hell_DistDamage2,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[fr_fps1],0,0,0,dm_BFG);
                end;
   end;
end;

UID_Medic,
UID_ZMedic:
begin
   uid_MaxHits1        := 1000;
   uid_r               := 11;
   uid_SightR_Base     := 175;
   uid_ProdTimeSec     := ptime1q;
   uid_islight         := true;
   uid_FastDeathHits   := hits_fdead_border;

   case i of
UID_Medic : begin
            uid_uibtn          := 7;
            uid_req_EnergyLevel:= 200;
            uid_MSpeed_Base    := 12;
            uid_MSpeed_Upgr    := upgr_uac_BioSpeed;
            uid_Armor_upgr1    := upgr_uac_BioArmor;
            uid_SightR_upgr    := upgr_uac_UnitSightR;
            uid_ZombieUID      := UID_ZMedic;
            uid_req_uid1       := UID_UWeaponFactory;
            SetWeapon(0,wpt_heal  ,aw_hmelee,0,BaseHeal1,fr_fpsh,0          ,0,0,upgr_uac_RepairTools ,BaseHealBonus1     ,wtrset_heal              ,wpr_any,uids_all,[],0, 0,0,0);
            SetWeapon(1,wpt_missle,aw_srange,0,0        ,fr_fpsh,MID_Bullet ,0,0,upgr_uac_DistDamage  ,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,0,0);
            end;
UID_ZMedic: begin
            uid_uibtn          := 21;
            uid_req_UACLoot    := 100;
            uid_ProdTimeSec    -= uid_ProdTimeSec div 4;
            uid_MSpeed_Base    := 14;
            uid_Armor_upgr1    := upgr_hell_UnitArmor;
            uid_Regen_Upgr     := upgr_hell_Regeneration;
            uid_SightR_upgr    := upgr_hell_UnitSightR;
            uid_PainState_Base := 1;
            uid_PainState_upgr := upgr_hell_PainFactor;
            uid_req_uid1       := UID_HACommandCenter;
            SetWeapon(0,wpt_heal  ,aw_hmelee,0,BaseHeal1,fr_fpsh,0          ,0,0,0                    ,0                  ,wtrset_heal              ,wpr_any,uids_all,[],0, 0,0,0);
            SetWeapon(1,wpt_missle,aw_srange,0,0        ,fr_fpsh,MID_Bullet ,0,0,upgr_hell_DistDamage2,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,0,0);
            end;
   end;
end;

UID_Engineer,
UID_ZEngineer:
begin
   uid_MaxHits1        := 1000;
   uid_r               := 11;
   uid_SightR_Base     := 175;
   uid_ProdTimeSec     := ptime1q;
   uid_islight         := true;
   uid_FastDeathHits   := hits_fdead_border;

   case i of
UID_Engineer : begin
               uid_uibtn          := 8;
               uid_req_EnergyLevel:= 200;
               uid_MSpeed_Base    := 12;
               uid_MSpeed_Upgr    := upgr_uac_BioSpeed;
               uid_Armor_upgr1    := upgr_uac_BioArmor;
               uid_SightR_upgr    := upgr_uac_UnitSightR;
               uid_ZombieUID      := UID_ZEngineer;
               uid_req_uid1       := UID_UWeaponFactory;
               SetWeapon(0,wpt_heal  ,aw_hmelee,0,BaseRepair1,fr_fpsh,0         ,0,0,upgr_uac_RepairTools ,BaseRepairBonus1,wtrset_repair            ,wpr_any,uids_all,[],0,0 ,0,0);
               SetWeapon(1,wpt_missle,aw_srange,0,0          ,fr_fpsh,MID_Bullet,0,0,upgr_uac_DistDamage  ,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,0,0);
               end;
UID_ZEngineer: begin
               uid_uibtn          := 22;
               uid_req_UACLoot    := 100;
               uid_ProdTimeSec    -= uid_ProdTimeSec div 4;
               uid_MSpeed_Base    := 14;
               uid_Armor_upgr1    := upgr_hell_UnitArmor;
               uid_Regen_Upgr     := upgr_hell_Regeneration;
               uid_SightR_upgr    := upgr_hell_UnitSightR;
               uid_PainState_Base := 1;
               uid_PainState_upgr := upgr_hell_PainFactor;
               uid_req_uid1       := UID_HACommandCenter;
               SetWeapon(0,wpt_heal  ,aw_hmelee,0,BaseRepair1,fr_fpsh,0         ,0,0,0                    ,0               ,wtrset_repair            ,wpr_any,uids_all,[],0,0 ,0,0);
               SetWeapon(1,wpt_missle,aw_srange,0,0          ,fr_fpsh,MID_Bullet,0,0,upgr_hell_DistDamage2,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,0,0);
               end;
   end;
end;

//         UAC BUILDINGS   /////////////////////////////////////////////////////

// BUILDERS
UID_HCommandCenter,
UID_HACommandCenter,
UID_UCommandCenter,
UID_UACommandCenter:
begin
   uid_MaxHits1        := 12000;
   uid_MSpeed_Base     := 5;
   uid_r               := 66;
   uid_SightR_Base     := 300;
   uid_ProdTimeSec     := ptime3;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_isbuilder       := true;
   uid_SightR_upgrV    := 50;

   case i of
UID_UCommandCenter : begin
                     uid_gen_EnergyLevel := 400;
                     uid_req_EnergyLevel := 1000;
                     uid_uibtn           := 0;
                     uid_ZombieUID       := UID_HCommandCenter;
                     uid_ability1        := uab_UACCCLand;
                     uid_ability2        := uab_UACCCLandTo;
                     uid_ability3        := uab_ToUACommandCenter;
                     uid_AI_NextFormUID  := UID_UACommandCenter;
                     uid_prod_Buildings  :=[UID_UCommandCenter..UID_URMStation]-[UID_UGenerator2,UID_UGenerator3,UID_UGenerator4,UID_UACommandCenter];
                     uid_SightR_upgr     := upgr_uac_BuilderR;
                     uid_Armor_upgr1     := upgr_uac_BuildArmor;
                     SetWeapon(0,wpt_missle,aw_srange,uid_r,0,fr_fpsh,MID_BPlasma,0,upgr_uac_CCAttack,upgr_uac_DistDamage,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any+wpr_move,uids_all,[],3,-65,0,dm_AntiUnitMech2);
                     end;
UID_UACommandCenter: begin
                     uid_gen_EnergyLevel := 1000;
                     uid_req_EnergyLevel := 400;
                     uid_uibtn           := 0;
                     uid_ZombieUID       := UID_HACommandCenter;
                     uid_ability1        := uab_UACCCLand;
                     uid_ability2        := uab_UACCCLandTo;
                     uid_prod_Buildings  :=[UID_UCommandCenter..UID_URMStation]-[UID_UGenerator2,UID_UGenerator3,UID_UGenerator4,UID_UACommandCenter];
                     uid_SightR_upgr     := upgr_uac_BuilderR;
                     uid_Armor_upgr1     := upgr_uac_BuildArmor;
                     SetWeapon(0,wpt_missle,aw_srange,uid_r,0,fr_fpsh,MID_BPlasma,0,upgr_uac_CCAttack,upgr_uac_DistDamage,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any+wpr_move,uids_all,[],3,-65,0,dm_AntiUnitMech2);
                     end;
UID_HCommandCenter : begin
                     uid_gen_EnergyLevel := 400;
                     uid_req_UACLoot     := 5000;
                     uid_ProdTimeSec     -= uid_ProdTimeSec div 4;
                     uid_uibtn           := 3;
                     uid_ability1        := uab_HellCCLand;
                     uid_ability2        := uab_HellCCLandTo;
                     uid_ability3        := uab_ToHACommandCenter;
                     uid_AI_NextFormUID  := UID_HACommandCenter;
                     uid_prod_Buildings  :=[UID_HKeep,UID_HCommandCenter,UID_HSymbol1,UID_HFTower,UID_HEye,UID_HBarracks];
                     uid_Regen_Base      := BaseRegen1;
                     uid_Regen_Upgr      := upgr_hell_BuildRestore;
                     uid_Armor_upgr1     := upgr_hell_BuildArmor;
                     uid_SightR_upgr     := upgr_hell_BuilderR;
                     SetWeapon(0,wpt_missle,aw_srange,uid_r,0,fr_fpsh,MID_Imp,0,0,upgr_hell_DistDamage1,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any+wpr_move,uids_all-[UID_Imp],[],3,-65,0,dm_AntiUnitBioHeavy2);
                     end;
UID_HACommandCenter: begin
                     uid_gen_EnergyLevel := 1000;
                     uid_req_UACLoot     := 5000;
                     uid_ProdTimeSec     -= uid_ProdTimeSec div 4;
                     uid_uibtn           := 3;
                     uid_ability1        := uab_HellCCLand;
                     uid_ability2        := uab_HellCCLandTo;
                     uid_prod_Buildings  :=[UID_HKeep,UID_HCommandCenter,UID_HSymbol1,UID_HFTower,UID_HEye,UID_HBarracks];
                     uid_Regen_Base      := BaseRegen1;
                     uid_Regen_Upgr      := upgr_hell_BuildRestore;
                     uid_Armor_upgr1     := upgr_hell_BuildArmor;
                     uid_SightR_upgr     := upgr_hell_BuilderR;
                     SetWeapon(0,wpt_missle,aw_srange,uid_r,0,fr_fpsh,MID_Imp,0,0,upgr_hell_DistDamage1,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any+wpr_move,uids_all-[UID_Imp],[],3,-65,0,dm_AntiUnitBioHeavy2);
                     end;
   end;
end;

// BASE PROD
UID_HBarracks,
UID_UBarracks:
begin
   uid_MaxHits1        := 8000;
   uid_r               := 60;
   uid_ProdTimeSec     := ptime2;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_isbarrack       := true;

   case i of
UID_HBarracks: begin
                  uid_uibtn          := 4;
                  uid_req_UACLoot    := 1000;
                  uid_Regen_Base     := BaseRegen1;
                  uid_Regen_Upgr     := upgr_hell_BuildRestore;
                  uid_Armor_upgr1    := upgr_hell_BuildArmor;
                  uid_prod_Units     := uids_zimbas+[UID_LostSoul,UID_Phantom];
                  uid_ability3       := uab_ToHBarracks;
                  uid_AI_NextFormUID := i;
               end;
UID_UBarracks: begin
                  uid_uibtn          := 1;
                  uid_req_EnergyLevel:= 400;
                  uid_Armor_upgr1    := upgr_uac_BuildArmor;
                  uid_prod_Units     := uids_marines;
                  uid_ZombieUID      := UID_HBarracks;
                  uid_ability3       := uab_ToUBarracks;
                  uid_AI_NextFormUID := i;
               end;
   end;
end;
UID_UFactory:
begin
   uid_MaxHits1        := 8000;
   uid_req_EnergyLevel := 400;
   uid_r               := 60;
   uid_uibtn           := 4;
   uid_ProdTimeSec     := ptime2;
   uid_Armor_upgr1     := upgr_uac_BuildArmor;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_isbarrack       := true;
   uid_ability3        := uab_ToUFactory;
   uid_AI_NextFormUID  := i;
   uid_prod_Units      :=[UID_UTransport,UID_UACDron,UID_Terminator,UID_Tank,UID_Flyer];
end;
UID_UWeaponFactory:
begin
   uid_MaxHits1        := 8000;
   uid_req_EnergyLevel := 400;
   uid_r               := 62;
   uid_uibtn           := 5;
   uid_ProdTimeSec     := ptime2;
   uid_Armor_upgr1     := upgr_uac_BuildArmor;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_isforge         := true;
   uid_ability3        := uab_ToUWeaponFactory;
   uid_AI_NextFormUID  := i;
   uid_prod_Upgrades   := [];
end;

// ENERGY PROD
UID_UGenerator1,
UID_UGenerator2,
UID_UGenerator3,
UID_UGenerator4:
begin
   uid_MaxHits1        := 2000;
   uid_gen_EnergyLevel := 100;
   uid_req_EnergyLevel := 100;
   uid_r               := 38;
   uid_uibtn           := 2;
   uid_ProdTimeSec     := ptime1;
   uid_Armor_upgr1     := upgr_uac_BuildArmor;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_LimitUse        := ul2;

   case i of
UID_UGenerator1: begin
                 uid_ability3       := uab_ToUGenerator2;
                 uid_AI_NextFormUID := UID_UGenerator2;
                 end;
UID_UGenerator2: begin
                 uid_gen_EnergyLevel*= 2;
                 uid_req_EnergyLevel:= 0;
                 uid_ability3       := uab_ToUGenerator3;
                 uid_AI_NextFormUID := UID_UGenerator3;
                 end;
UID_UGenerator3: begin
                 uid_gen_EnergyLevel*= 3;
                 uid_req_EnergyLevel:= 0;
                 uid_ability3       := uab_ToUGenerator4;
                 uid_AI_NextFormUID := UID_UGenerator4;
                 end;
UID_UGenerator4: begin
                 uid_gen_EnergyLevel*= 4;
                 uid_req_EnergyLevel:= 0;
                 end;
   end;
end;


// BASE TECH
UID_UTechCenter :
begin
   uid_MaxHits1        := 12000;
   uid_req_EnergyLevel := 1200;
   uid_r               := 86;
   uid_uibtn           := 10;
   uid_ProdTimeSec     := ptime5;
   uid_Armor_upgr1     := upgr_uac_BuildArmor;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_req_uid1        := UID_UWeaponFactory;
end;
UID_UComputerStation:
begin
   uid_MaxHits1        := 12000;
   uid_req_EnergyLevel := 1200;
   uid_r               := 70;
   uid_uibtn           := 11;
   uid_ProdTimeSec     := ptime5;
   uid_Armor_upgr1     := upgr_uac_BuildArmor;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_req_uid1        := UID_UWeaponFactory;
end;

// SPECIAL
UID_URadar:
begin
   uid_MaxHits1        := 4000;
   uid_req_EnergyLevel := 200;
   uid_r               := 35;
   uid_SightR_Base     := 300;
   uid_SightR_upgr     := upgr_uac_RadarR;
   uid_SightR_upgrV    := 25;
   uid_uibtn           := 12;
   uid_ProdTimeSec     := ptime2;
   uid_Armor_upgr1     := upgr_uac_BuildArmor;
   uid_LimitUse        := ul2;
   uid_ability1        := uab_UACScan;
   uid_ability3        := uab_URadarLvlUp;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_isdetector      := true;
   uid_req_uid1        := UID_UWeaponFactory;
end;
UID_UAcademy:
begin
   uid_MaxHits1        := 8000;
   uid_req_EnergyLevel := 1000;
   uid_r               := 76;
   uid_uibtn           := 13;
   uid_ProdTimeSec     := ptime4;
   uid_Armor_upgr1     := upgr_uac_BuildArmor;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_req_uid1        := UID_UWeaponFactory;
   uid_ability1        := uab_PretorEquip;
   uid_ability2        := uab_Bribe;
   uid_ability3        := uab_Hack;
end;
UID_UHPowerConductor:
begin
   uid_MaxHits1        := 8000;
   uid_req_EnergyLevel := 1000;
   uid_r               := 68;
   uid_uibtn           := 14;
   uid_ProdTimeSec     := ptime4;
   uid_Armor_upgr1     := upgr_uac_BuildArmor;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_req_uid1        := UID_UWeaponFactory;
   uid_ability1        := uab_SphereSoul;
   uid_ability2        := uab_SphereInvis;
   uid_ability3        := uab_SphereInvuln;
end;
UID_URMStation:
begin
   uid_MaxHits1        := 8000;
   uid_req_EnergyLevel := 2000;
   uid_r               := 40;
   uid_uibtn           := 15;
   uid_ProdTimeSec     := ptime10;
   uid_Armor_upgr1     := upgr_uac_BuildArmor;
   uid_LimitUse        := ul10;
   uid_req_uid1        := UID_UComputerStation;
   uid_ability1        := uab_UACStrike;
   uid_ability3        := uab_URMStationLvlUp;
   uid_isbuilding      := true;
   uid_ismech          := true;
end;

// STAT DEF
UID_UGTurret:
begin
   uid_MaxHits1        := 3000;
   uid_req_EnergyLevel := 400;
   uid_r               := 15;
   uid_SightR_Base     := 300;
   uid_SightR_upgr     := upgr_uac_TowerR;
   uid_SightR_upgrV    := 25;
   uid_uibtn           := 6;
   uid_ProdTimeSec     := ptime2;
   uid_Armor_upgr1     := upgr_uac_BuildArmor;
   uid_Armor_upgr2     := upgr_uac_TurretArmor;
   uid_CanAttack       := true;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_islight         := true;
   uid_ability1        := uab_ToUACDron;
   uid_ability2        := 0;
   uid_ability3        := uab_ToUAATurret;

   SetWeapon(0,wpt_missle,aw_srange,0,0 ,fr_fpss,MID_BPlasma ,0,upgr_uac_TurretPlasma,upgr_uac_DistDamage,UpgradeDamageBonus1,wtrset_enemy_alive_ground_mech,wpr_any,uids_all,[],0,-11,2,dm_AntiUnitMech2  );
   SetWeapon(1,wpt_missle,aw_srange,0,0 ,fr_fpss,MID_Chaingun,0,0                    ,upgr_uac_DistDamage,UpgradeDamageBonus1,wtrset_enemy_alive_ground     ,wpr_any,uids_all,[],0,-11,2,dm_AntiUnitBioLight2);
end;
UID_UATurret:
begin
   uid_MaxHits1        := 3000;
   uid_req_EnergyLevel := 400;
   uid_r               := 15;
   uid_SightR_Base     := 300;
   uid_SightR_upgr     := upgr_uac_TowerR;
   uid_SightR_upgrV    := 25;
   uid_uibtn           := 7;
   uid_ProdTimeSec     := ptime2;
   uid_Armor_upgr1     := upgr_uac_BuildArmor;
   uid_Armor_upgr2     := upgr_uac_TurretArmor;
   uid_CanAttack       := true;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_islight         := true;
   uid_ability1        := uab_ToUACDron;
   uid_ability2        := 0;
   uid_ability3        := uab_ToUAGTurret;
   SetWeapon(0,wpt_missle,aw_fsr+(uid_r*2),0,0 ,fr_fpst,MID_URocket ,0,0,upgr_uac_DistDamage,UpgradeDamageBonus1,wtrset_enemy_alive_fly,wpr_any ,uids_all,[],0,-14,0,dm_AntiFly2);
end;

//  UAC MECH UNITS ///////////////////////////////////////////////////

UID_UACDron:
begin
   uid_MaxHits1        := 1000;
   uid_req_EnergyLevel := 200;
   uid_r               := 14;
   uid_MSpeed_Base     := 15;
   uid_MSpeed_Upgr     := upgr_uac_MechSpeed;
   uid_Armor_upgr1     := upgr_uac_MechArmor;
   uid_SightR_upgr     := upgr_uac_UnitSightR;
   uid_SightR_Base     := 200;
   uid_uibtn           := 9;
   uid_ProdTimeSec     := ptime1;
   uid_CanAttack       := true;
   uid_ismech          := true;
   uid_islight         := true;
   uid_ability1        := uab_ToUGTurretTo;
   uid_ability2        := uab_ToUATurretTo;
   uid_FastDeathHits   := 1;
   SetWeapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsh,MID_BPlasma,0,0,upgr_uac_DistDamage,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,2,dm_AntiUnitMech2);
end;
UID_UTransport:
begin
   uid_MaxHits1        := 2000;
   uid_req_EnergyLevel := 200;
   uid_r               := 33;
   uid_MSpeed_Base     := 18;
   uid_MSpeed_Upgr     := upgr_uac_MechSpeed;
   uid_Armor_upgr1     := upgr_uac_MechArmor;
   uid_SightR_upgr     := upgr_uac_UnitSightR;
   uid_SightR_Base     := 200;
   uid_uibtn           := 10;
   uid_ProdTimeSec     := ptime1;
   uid_TransportMax_Base:=8;
   uid_TransportMax_Upgr:=upgr_uac_Transport;
   uid_TransportMax_UpgrV:=4;
   uid_isfly           := uf_fly;
   uid_CanAttack       := false;
   uid_ismech          := true;
   uid_req_uid1        := UID_UACommandCenter;
   uid_FastDeathHits   := 1;
   ups_TransportUIDs   := uids_marines+[UID_UACDron,UID_Terminator,UID_Tank];
end;
UID_Terminator:
begin
   uid_MaxHits1        := 2000;
   uid_req_EnergyLevel := 500;
   uid_r               := 16;
   uid_MSpeed_Base     := 12;
   uid_MSpeed_Upgr     := upgr_uac_MechSpeed;
   uid_Armor_upgr1     := upgr_uac_MechArmor;
   uid_SightR_upgr     := upgr_uac_UnitSightR;
   uid_SightR_Base     := 275;
   uid_uibtn           := 11;
   uid_ProdTimeSec     := ptime1h;
   uid_LimitUse        := ul3;
   uid_CanAttack       := true;
   uid_ismech          := true;
   uid_req_uid1        := UID_UTechCenter;
   uid_FastDeathHits   :=1;
   uid_islight         := false;
   uid_arms_BonusAntiFlyRange :=-50;
   uid_arms_BonusAntiUnitRange:=50;
   SetWeapon(0,wpt_missle,aw_srange,0,0,fr_fpsq ,MID_SShot  ,0,0                   ,upgr_uac_DistDamage,UpgradeDamageBonus1 ,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,0,dm_AntiUnitBio2);
   SetWeapon(1,wpt_missle,aw_srange,0,0,fr_fpst2,MID_URocket,0,upgr_uac_TerAAWeapon,upgr_uac_DistDamage,UpgradeDamageBonus1 ,wtrset_enemy_alive_fly   ,wpr_any,uids_all,[],0,0,0,0    );
end;
UID_Tank:
begin
   uid_MaxHits1        := 5000;
   uid_req_EnergyLevel := 600;
   uid_r               := 20;
   uid_MSpeed_Base     := 8;
   uid_MSpeed_Upgr     := upgr_uac_MechSpeed;
   uid_Armor_upgr1     := upgr_uac_MechArmor;
   uid_SightR_upgr     := upgr_uac_UnitSightR;
   uid_SightR_Base     := 275;
   uid_uibtn           := 12;
   uid_ProdTimeSec     := ptime2;
   uid_LimitUse        := ul4;
   uid_CanAttack       := true;
   uid_ismech          := true;
   uid_req_uid1        := UID_UTechCenter;
   uid_FastDeathHits   :=1;
   uid_arms_BonusAntiBuildingRange:=50;
   SetWeapon(0,wpt_missle,aw_srange,rocket_sr,2 ,fr_fpst2,MID_Tank,0,0,upgr_uac_DistDamage,UpgradeDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,0,dm_Siege4);
end;
UID_Flyer:
begin
   uid_MaxHits1        := 4000;
   uid_req_EnergyLevel := 600;
   uid_r               := 18;
   uid_MSpeed_Base     := 17;
   uid_MSpeed_Upgr     := upgr_uac_MechSpeed;
   uid_Armor_upgr1     := upgr_uac_MechArmor;
   uid_SightR_upgr     := upgr_uac_UnitSightR;
   uid_SightR_Base     := 275;
   uid_uibtn           := 13;
   uid_ProdTimeSec     := ptime2;
   uid_isfly           := uf_fly;
   uid_LimitUse        := ul4;
   uid_CanAttack       := true;
   uid_ismech          := true;
   uid_req_uid1        := UID_UTechCenter;
   uid_req_uid2        := UID_UACommandCenter;
   uid_FastDeathHits   := 1;
   uid_arms_BonusAntiUnitRange:=25;
   SetWeapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsh,MID_Flyer  ,0,0,upgr_uac_DistDamage,UpgradeDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,0,dm_AntiGroundLight2);
end;

UID_USPort  ,
UID_UPortal :
begin
   uid_MaxHits1        := 20000;
   uid_req_EnergyLevel := 2000;
   uid_r               := 150;
   uid_uibtn           := 20;
   uid_ProdTimeSec     := ptime10;
   uid_isbuilding      := true;
   uid_ismech          := true;
   uid_issolid         := false;
end;

UID_UBaseMil,
UID_UBaseCom,
UID_UBaseRef,
UID_UBaseNuc,
UID_UBaseLab:
begin
   uid_MaxHits1        := 15000;
   uid_req_EnergyLevel := 1000;
   uid_r               := 100;
   uid_uibtn           := 21;
   uid_ProdTimeSec     := ptime10;
   uid_isbuilding      := true;
   uid_ismech          := true;
end;

UID_UBaseGen:
begin
   uid_MaxHits1        := 6000;
   uid_gen_EnergyLevel := 1000;
   uid_req_EnergyLevel := 500;
   uid_r               := 55;
   uid_uibtn           := 22;
   uid_ProdTimeSec     := ptime10;
   uid_isbuilding      := true;
   uid_ismech          := true;
end;

UID_UCBuild0,
UID_UCBuild1,
UID_UCBuild2,
UID_UCBuild3:
begin
   uid_MaxHits1        := 15000;
   uid_req_EnergyLevel := 1000;
   uid_r               := 100;
   uid_uibtn           := 23;
   uid_ProdTimeSec     := ptime10;
   uid_isbuilding      := true;
   uid_ismech          := true;
end;

      end;

      uid_square:=round(pi*uid_r*uid_r);

      if(uid_TransportMax_Base>0)then
      begin
         uid_ability1:=uab_Unload;
         uid_ability2:=uab_UnloadTo;
      end;

      if(i in uids_hell)then uid_race:=r_hell;
      if(i in uids_uac )then uid_race:=r_uac;

      if(uid_race=0)then uid_race:=r_hell;

      if(uid_req_uid1>0)and(uid_req_uid1n=0)then uid_req_uid1n:=1;
      if(uid_req_uid2>0)and(uid_req_uid2n=0)then uid_req_uid2n:=1;
      if(uid_req_uid3>0)and(uid_req_uid3n=0)then uid_req_uid3n:=1;

      // default upgrade bonuses
      if(uid_PainState_upgr>0)then
        if(uid_PainState_upgrV=0)then
          uid_PainState_upgrV:=(uid_PainState_Base div 2)+(uid_PainState_Base mod 2);
      if(uid_Armor_upgr1>0)or(uid_Armor_upgr2>0)then
        if(uid_Armor_upgrV=0)then
          if(uid_isbuilding)
          then uid_Armor_upgrV:=UpgradeBuildArmorBonus
          else uid_Armor_upgrV:=UpgradeUnitArmorBonus;
      if(uid_SightR_upgr>0)then
        if(uid_SightR_upgrV=0)then
          uid_SightR_upgrV:=25;
      if(uid_MSpeed_upgr>0)then
        if(uid_MSpeed_upgrV=0)then
          uid_MSpeed_upgrV:=UpgradeUnitSpeedBonus;

      uid_missileR:=trunc(uid_r/1.41);
      if(uid_MaxHits1<1)then uid_MaxHits1:=1;
      uid_MaxHitsh:=uid_MaxHits1 div 2; if(uid_MaxHitsh<1)then uid_MaxHitsh:=1;
      uid_MaxHitsq:=uid_MaxHitsh div 2; if(uid_MaxHitsq<1)then uid_MaxHitsq:=1;

      if(uid_isforge)and(uid_prod_Upgrades=[])then
        for u:=1 to 255 do
          with g_upgrs[u] do
            if(upgr_time>0)and(uid_race=upgr_race)then uid_prod_Upgrades+=[u];

      if(uid_isbuilding)then
      begin
         uid_ZombieHits :=uid_MaxHits1 div 4;
         uid_SightR_Base:=max2i(uid_r+uid_r,uid_SightR_Base);
         if(uid_race=r_hell)and(uid_bounty_HellPower=0)then uid_bounty_HellPower:=round(uid_MaxHits1/HellPower_PerHP);
         if(uid_race=r_uac )and(uid_bounty_UACLoot  =0)then uid_bounty_UACLoot  :=round(uid_MaxHits1/HellPower_PerHP);
      end
      else
      begin
         if(uid_race=r_hell)and(uid_bounty_HellPower=0)then uid_bounty_HellPower:=round(uid_LimitUse/ul1*HellPower_PerLimit);
         if(uid_race=r_uac )and(uid_bounty_UACLoot  =0)then uid_bounty_UACLoot  :=round(uid_LimitUse/ul1*HellPower_PerLimit);
      end;

      if(uid_TransportSize=0)then
        if(uid_isbuilding)
        then uid_TransportSize:=1
        else uid_TransportSize:=round(uid_LimitUse/ul1);

      uid_hits_li2si:=uid_MaxHits1/sintMaxHits;

      if(uid_ProdTimeSec> 0)then uid_ProdHitStep:=round((uid_MaxHits1/2)/uid_ProdTimeSec);
      if(uid_ProdHitStep<=0)then uid_ProdHitStep:=1;
      uid_ProdTimeTick:=uid_ProdTimeSec*fr_fps1;

      uid_CanAttack:=false;
      for u:=0 to LastUnitArms do
        with uid_arms[u] do
          if(aw_reload>0)and(aw_type>0)then
          begin
             uid_CanAttack:=true;
               for p:=1 to aw_reload do
                 if(p in aw_ShotPoints)then aw_ShotPoints+=[p-1];
          end;

      if(uid_LimitUse>=MinUnitLimit)and(not uid_isbuilding)then
      begin
         if(uid_CanAttack)and(uid_LevelBonusDamage=0)then
         uid_LevelBonusDamage:=round(BaseDamageLevel1*uid_LimitUse/ul1);
         uid_LevelBonusArmor :=round(BaseArmorLevel1 *uid_LimitUse/ul1);
         uid_LevelBonusPainC :=round(uid_LimitUse/ul1);
      end;
      if(uid_LevelBonusDamage<0)then uid_LevelBonusDamage:=0;
      if(uid_LevelBonusArmor <0)then uid_LevelBonusArmor :=0;
      if(uid_LevelBonusPainC <0)then uid_LevelBonusPainC :=0;

      uid_HaveAbility        :=(uid_ability1>0)
                             or(uid_ability2>0)
                             or(uid_ability3>0);
      uid_NoOrderWhenCast    :=UIDHaveAbility(i,uab_UACScan     )
                            or UIDHaveAbility(i,uab_UACStrike   );
      uid_ability_HKeepShift :=UIDHaveAbility(i,uab_HKeepShift  );
      uid_ability_isteleport :=UIDHaveAbility(i,uab_Teleport    );
      uid_ability_isradar    :=UIDHaveAbility(i,uab_UACScan     );
      uid_ability_isCanLiftUp:=UIDHaveAbility(i,uab_UACCCLand   )
                            or UIDHaveAbility(i,uab_UACCCLandTo );
      uid_ability_RldReducByLvl:=((g_aids[uid_ability1].ua_reload>0)and(g_aids[uid_ability1].ua_rldDec_level>0))
                               or((g_aids[uid_ability2].ua_reload>0)and(g_aids[uid_ability2].ua_rldDec_level>0))
                               or((g_aids[uid_ability3].ua_reload>0)and(g_aids[uid_ability3].ua_rldDec_level>0));

      uid_HaveRallyPoint     :=(uid_isbarrack)or(UIDHaveAbility(i,uab_Teleport));
      uid_client_WReload     :=(g_aids[uid_ability1].ua_reload>0)
                             or(g_aids[uid_ability2].ua_reload>0)
                             or(g_aids[uid_ability3].ua_reload>0);
      uid_client_WCastTarget :=UIDHaveAbility(i,uab_UACScan     )
                            or UIDHaveAbility(i,uab_UACStrike   );
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   MISSILES CONSTANT DATA
//

procedure InitMIDs;
var m:byte;
begin
   FillChar(g_mids,SizeOf(g_mids),0);

   for m:=0 to 255 do
   with g_mids[m] do
   begin
      mid_size      := 0;
      mid_homing    := mh_magnetic;
      mid_TeamDamage:= true;

// speed
case m of
MID_ArchFire       : mid_speed       :=32000;
MID_Tank           : mid_speed       :=100;
MID_SChaingun,
MID_Chaingun,
MID_SShot,
MID_SSShot,
MID_Bullet         : mid_speed       :=60;
MID_Flyer          : mid_speed       :=30;
MID_Imp,
MID_Cacodemon,
MID_Baron,
MID_Mancubus,
MID_YPlasma,
MID_BPlasma,
MID_HRocket        : mid_speed       :=15;
MID_Revenant,
MID_URocketS,
MID_URocket,
MID_BFG,
MID_Granade        : mid_speed       :=12;
MID_Blizzard       : mid_speed       :=-fr_fps1; // special
end;

// damage
case m of
MID_Bullet         : mid_base_damage :=BaseDamageh;
MID_Imp,
MID_URocketS,
MID_URocket,
MID_Mancubus,
MID_BPlasma,
MID_Chaingun,
MID_Granade,
MID_Cacodemon,
MID_Tank,
MID_SShot          : mid_base_damage :=BaseDamage1;
MID_Revenant,
MID_Baron          : mid_base_damage :=BaseDamage1h;
MID_SChaingun,
MID_YPlasma,
MID_Flyer          : mid_base_damage :=BaseDamage2;
MID_SSShot         : mid_base_damage :=BaseDamage3;
MID_HRocket        : mid_base_damage :=BaseDamage5;
MID_BFG            : mid_base_damage :=BaseDamage6;
MID_ArchFire       : mid_base_damage :=BaseDamage6;
MID_Blizzard       : mid_base_damage :=BaseDamage10*4;
end;

// splash R
case m of
MID_Blizzard       : mid_base_SplashR:=blizzard_sr;
MID_HRocket        : mid_base_SplashR:=rocket_sr;
MID_URocketS,
MID_ArchFire,
MID_Tank           : mid_base_SplashR:=tank_sr;
MID_BFG            : mid_base_SplashR:=bfg_sr;
end;

// homing
case m of
MID_Revenant,
MID_URocket,
MID_URocketS       : mid_homing      :=mh_homing;
MID_BFG            : mid_homing      :=mh_none;
end;

// nodamage uids
case m of
MID_Imp            : mid_ImmuneUnits:=[UID_Imp        ];
MID_Cacodemon      : mid_ImmuneUnits:=[UID_Cacodemon  ];
MID_Baron          : mid_ImmuneUnits:=[UID_Knight,
                                       UID_Baron      ];
MID_Revenant       : mid_ImmuneUnits:=[UID_Revenant   ];
MID_Mancubus       : mid_ImmuneUnits:=[UID_Mancubus   ];
MID_YPlasma        : mid_ImmuneUnits:=[UID_Arachnotron];
end;

// other
case m of
MID_Granade        : mid_ystep       :=3;
MID_URocketS,
MID_BFG            : begin
                     mid_TeamDamage  :=false;
                     mid_noFlyCheck  :=true;
                     end;
MID_Blizzard       : begin
                     mid_noFlyCheck  :=true;
                     mid_size        :=mid_base_SplashR div 2;
                     end;
end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   DAMAGE MODS  CONSTANT DATA
//

procedure InitDMODs;
procedure SetDMOD(dm,n:byte;factor:integer;flags:cardinal);
procedure CorrentFlags(f1,f2:cardinal);
begin
  if ((flags and f1)=0)
  and((flags and f2)=0)then flags:=flags or f1 or f2;
end;
begin
   with g_DamageMods[dm][n] do
   begin
      CorrentFlags(wtr_unit ,wtr_building);
      CorrentFlags(wtr_bio  ,wtr_mech    );
      CorrentFlags(wtr_light,wtr_heavy   );
      CorrentFlags(wtr_fly  ,wtr_ground  );

      dm_Factor:=factor;
      dm_TargetFlags :=flags
   end;
end;
begin
   FillChar(g_DamageMods,SizeOf(g_DamageMods),0);

   SetDMOD(dm_AntiUnitBioHeavy2,0,200,wtr_unit    +wtr_bio +wtr_heavy           );
   SetDMOD(dm_SSGShot2         ,0,200,wtr_unit    +wtr_bio +wtr_heavy           );
   SetDMOD(dm_SSGShot2         ,1, 50,             wtr_mech                     );
   SetDMOD(dm_AntiUnitBioLight2,0,200,wtr_unit    +wtr_bio +wtr_light           );
   SetDMOD(dm_AntiUnitBio2     ,0,200,wtr_unit    +wtr_bio                      );
   SetDMOD(dm_AntiUnitMech2    ,0,200,wtr_unit    +wtr_mech                     );
   SetDMOD(dm_AntiUnitLight2   ,0,200,wtr_unit             +wtr_light           );
   SetDMOD(dm_AntiFly2         ,0,200,                                wtr_fly   );
   SetDMOD(dm_AntiGroundLight2 ,0,200,                      wtr_light+wtr_ground);
   SetDMOD(dm_RSMShot          ,0,400,wtr_building                              );
   SetDMOD(dm_Siege4           ,0,400,wtr_building                              );
   SetDMOD(dm_Lost             ,0, 50,             wtr_mech                     );
   SetDMOD(dm_BFG              ,0, 50,wtr_building                              );
   SetDMOD(dm_AntiBio2         ,0,200,             wtr_bio                      );
   SetDMOD(dm_AntiBio2         ,1, 50,wtr_building                              );
end;

////////////////////////////////////////////////////////////////////////////////
//
//   UPGRADES CONSTANT DATA
//

procedure InitUpgrades;
var u:byte;
procedure setUPGR(rc,upgr,stime,stimeX,stimeA,max,enrg,enrgX,enrgA:integer;rupgr,ruid:byte);
begin
   with g_upgrs[upgr] do
   begin
      upgr_ruid      := ruid;
      upgr_rupgr     := rupgr;
      upgr_race      := rc;
      upgr_time      := stime*fr_fps1;
      upgr_time_xpl  := stimeX;
      upgr_time_apl  := stimeA*fr_fps1;
      upgr_renerg    := enrg;
      upgr_renerg_xpl:= enrgX;
      upgr_renerg_apl:= enrgA;
      upgr_max       := max;
      upgr_btni      := u;
      u+=1;
   end;
end;
begin
   FillChar(g_upgrs,SizeOf(g_upgrs),0);

   //                                   base X +
   //       race id                     time      lvl  enr  X +    rupgr         ruid
   u:=0;
   setUPGR(r_hell,upgr_hell_DistDamage1 ,60 ,0,35,5   ,600 ,0,700 ,0            ,0                   );
   setUPGR(r_hell,upgr_hell_UnitArmor   ,60 ,0,35,5   ,600 ,0,700 ,0            ,0                   );
   setUPGR(r_hell,upgr_hell_BuildArmor  ,60 ,0,20,5   ,600 ,0,800 ,0            ,0                   );
   setUPGR(r_hell,upgr_hell_MeleeDamage ,60 ,0,30,5   ,600 ,0,400 ,0            ,0                   );
   setUPGR(r_hell,upgr_hell_Regeneration,60 ,0,30,2   ,300 ,0,300 ,0            ,0                   );
   setUPGR(r_hell,upgr_hell_PainFactor  ,60 ,0,0 ,2   ,300 ,0,300 ,0            ,0                   );
   setUPGR(r_hell,upgr_hell_BuilderR    ,60 ,0,15,2   ,600 ,0,0   ,0            ,0                   );
   setUPGR(r_hell,upgr_hell_HKeepShift  ,90 ,0,0 ,1   ,600 ,0,0   ,0            ,0                   );
   setUPGR(r_hell,upgr_hell_DecayAura   ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HAKeep          );
   setUPGR(r_hell,upgr_hell_TowerR      ,60 ,0,15,2   ,600 ,0,300 ,0            ,UID_HAKeep          );

   setUPGR(r_hell,upgr_hell_Spectre     ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HAKeep          );
   setUPGR(r_hell,upgr_hell_UnitSightR  ,60 ,0,30,2   ,600 ,0,300 ,0            ,UID_HMonastery      );
   setUPGR(r_hell,upgr_hell_Phantoms    ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HMonastery      );
   setUPGR(r_hell,upgr_hell_DistDamage2 ,60 ,0,35,5   ,600 ,0,700 ,0            ,UID_HMonastery      );
   setUPGR(r_hell,upgr_hell_Resurrect   ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HMonastery      );
   setUPGR(r_hell,upgr_hell_TeleportCD  ,60 ,0,30,2   ,400 ,0,200 ,0            ,UID_HFortress       );
   setUPGR(r_hell,upgr_hell_T2TNoCD     ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HFortress       );
   setUPGR(r_hell,upgr_hell_EvilEyeR    ,60 ,0,0 ,3   ,300 ,0,300 ,0            ,UID_HFortress       );
   setUPGR(r_hell,upgr_hell_TotemInvis  ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HFortress       );
   setUPGR(r_hell,upgr_hell_BuildRestore,60 ,0,0 ,5   ,600 ,0,300 ,0            ,UID_HFortress       );
   setUPGR(r_hell,upgr_hell_TowerBlink  ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HFortress       );

   u:=0;
   setUPGR(r_uac ,upgr_uac_DistDamage   ,60 ,0,35,5   ,600 ,0,700 ,0            ,0                   );
   setUPGR(r_uac ,upgr_uac_BioArmor     ,60 ,0,35,5   ,600 ,0,700 ,0            ,0                   );
   setUPGR(r_uac ,upgr_uac_BuildArmor   ,60 ,0,35,5   ,600 ,0,800 ,0            ,0                   );
   setUPGR(r_uac ,upgr_uac_RepairTools  ,60 ,0,30,2   ,600 ,0,400 ,0            ,0                   );
   setUPGR(r_uac ,upgr_uac_BioSpeed     ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,0                   );
   setUPGR(r_uac ,upgr_uac_SSMWeapon    ,60 ,0,0 ,1   ,300 ,0,0   ,0            ,0                   );
   setUPGR(r_uac ,upgr_uac_BuilderR     ,60 ,0,15,2   ,600 ,0,0   ,0            ,0                   );
   setUPGR(r_uac ,upgr_uac_CCFly        ,120,0,0 ,1   ,600 ,0,0   ,0            ,0                   );
   setUPGR(r_uac ,upgr_uac_CCAttack     ,120,0,0 ,1   ,600 ,0,0   ,0            ,UID_UACommandCenter );
   setUPGR(r_uac ,upgr_uac_TowerR       ,60 ,0,15,2   ,600 ,0,300 ,0            ,UID_UACommandCenter );

   setUPGR(r_uac ,upgr_uac_DronTurret   ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UACommandCenter );
   setUPGR(r_uac ,upgr_uac_UnitSightR   ,60 ,0,30,2   ,600 ,0,300 ,0            ,UID_UTechCenter     );
   setUPGR(r_uac ,upgr_uac_CommandoInvis,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter     );
   setUPGR(r_uac ,upgr_uac_AASplash     ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter     );
   setUPGR(r_uac ,upgr_uac_MechSpeed    ,60 ,0,15,2   ,600 ,0,300 ,0            ,UID_UTechCenter     );
   setUPGR(r_uac ,upgr_uac_MechArmor    ,60 ,0,35,5   ,600 ,0,700 ,0            ,UID_UTechCenter     );
   setUPGR(r_uac ,upgr_uac_TerAAWeapon  ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter     );
   setUPGR(r_uac ,upgr_uac_Transport    ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter     );
   setUPGR(r_uac ,upgr_uac_RadarR       ,60 ,0,0 ,3   ,300 ,0,300 ,0            ,UID_UComputerStation);
   setUPGR(r_uac ,upgr_uac_TurretPlasma ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UComputerStation);
   setUPGR(r_uac ,upgr_uac_TurretArmor  ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UComputerStation);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   ABILITIES CONSTANT DATA
//

procedure InitAIDs;
var a:byte;
begin
   for a:=0 to 255 do
   with g_aids[a] do
   begin
      ua_type        :=uat_none;
      ua_reload      :=0;
      ua_req_upgr    :=0;
      ua_req_uid     :=0;
      ua_rldDec_level:=0;

      case a of
uab_Teleport        : begin
                         ua_type        := uat_passive;
                         ua_reload      := 5*fr_fps1;
                         ua_rldDec_upgr := upgr_hell_TeleportCD;
                         ua_rldDec_upgrS:= fr_fps1;
                      end;
uab_Recall          : begin
                         ua_type        := uat_UnitOwn;
                         ua_reload      := 5*fr_fps1;
                         ua_rldDec_upgr := upgr_hell_TeleportCD;
                         ua_rldDec_upgrS:= fr_fps1;
                      end;
uab_UACScan         : begin
                         ua_type        := uat_Point;
                         ua_reload      := 60*fr_fps1;
                         ua_rldDec_level:= 5*fr_fps1;
                         ua_req_uid     := UID_UACommandCenter;
                      end;
uab_UACStrike       : begin
                         ua_type        := uat_Point;
                         ua_reload      := 60*fr_fps1;
                         ua_rldDec_level:= 5*fr_fps1;
                      end;

uab_HEyeVision      : begin
                         ua_type        := uat_UnitAlly;
                         ua_reload      := 30*fr_fps1;
                         ua_req_uid     := UID_HAKeep;
                      end;
uab_HEyeBlink       : begin
                         ua_type        := uat_Point;
                         ua_reload      := 30*fr_fps1;
                      end;
uab_HTowerBlink     : begin
                         ua_type        := uat_Point;
                         ua_reload      := 30*fr_fps1;
                         ua_req_upgr    := upgr_hell_TowerBlink;
                      end;
uab_HKeepAura       : begin
                         ua_type        := uat_Passive;
                         ua_req_upgr    := upgr_hell_DecayAura;
                      end;
uab_HKeepShift      : begin
                         ua_type        := uat_Point;
                         ua_req_upgr    := upgr_hell_HKeepShift;
                      end;

uab_SphereSoul      : begin
                         ua_type        := uat_UnitAlly;
                         ua_req_HellPower:= 500;
                      end;
uab_SphereInvis     : begin
                         ua_type        := uat_UnitAlly;
                         ua_req_HellPower:= 1000;
                      end;
uab_SphereInvuln    : begin
                         ua_type        := uat_UnitAlly;
                         ua_req_HellPower:= 5000;
                      end;
uab_SphereRDamage   : begin
                         ua_type        := uat_UnitAlly;
                         ua_req_HellPower:= 6000;
                      end;
uab_SphereDDamage   : begin
                         ua_type        := uat_UnitAlly;
                         ua_req_HellPower:= 9000;
                      end;
uab_SphereTurbo     : begin
                         ua_type        := uat_UnitAlly;
                         ua_req_HellPower:= 12000;
                      end;

uab_PretorEquip     : begin
                         ua_type        := uat_UnitAlly;
                         ua_req_UACLoot := 6000;
                      end;
uab_Bribe           : begin
                         ua_type        := uat_UnitEnemy;
                         ua_req_UACLoot := 6000;
                      end;
uab_Hack            : begin
                         ua_type        := uat_UnitEnemy;
                         ua_req_UACLoot := 10000;
                      end;

uab_SpawnLost       : begin
                         ua_type        := uat_NoTarget;
                      end;
uab_SpawnLostTo     : begin
                         ua_type        := uat_Point;
                      end;

uab_UACCCLand       : begin
                         ua_type        := uat_NoTarget;
                         ua_req_upgr    := upgr_uac_CCFly;
                      end;
uab_UACCCLandTo     : begin
                         ua_type        := uat_Point;
                         ua_req_upgr    := upgr_uac_CCFly;
                      end;

uab_HellCCLand      : begin
                         ua_type        := uat_NoTarget;
                      end;
uab_HellCCLandTo    : begin
                         ua_type        := uat_Point;
                      end;


uab_Unload          : begin
                         ua_type        := uat_NoTarget;
                      end;
uab_UnloadTo        : begin
                         ua_type        := uat_Point;
                      end;

uab_ToUACDron       : begin
                         ua_type        := uat_NoTarget;
                         ua_req_upgr    := upgr_uac_DronTurret;
                      end;

uab_ToUGTurretTo    : begin
                         ua_type        := uat_Point;
                         ua_req_upgr    := upgr_uac_DronTurret;
                      end;
uab_ToUATurretTo    : begin
                         ua_type        := uat_Point;
                         ua_req_upgr    := upgr_uac_DronTurret;
                      end;

uab_ToHAKeep,
uab_ToHSymbol2,
uab_ToHSymbol3,
uab_ToHSymbol4,
uab_ToHACommandCenter,
uab_ToHSTower,
uab_ToHFTower        : ua_type        := uat_NoTarget;

uab_ToHGate,
uab_ToHPool,
uab_ToHBarracks,
uab_ToHTotem        : begin
                         ua_type     := uat_NoTarget;
                         ua_req_uid  := UID_HFortress;
                      end;

uab_ToUACommandCenter,
uab_ToUGenerator2,
uab_ToUGenerator3,
uab_ToUGenerator4,
uab_ToUAGTurret,
uab_ToUAATurret     : ua_type        := uat_NoTarget;

uab_ToUBarracks,
uab_ToUFactory,
uab_ToUWeaponFactory: begin
                         ua_type     := uat_NoTarget;
                         ua_req_uid  := UID_UComputerStation;
                      end;
uab_URadarLvlUp     : begin
                         ua_type     := uat_NoTarget;
                         ua_req_uid  := UID_UACommandCenter;
                         ua_req_UACLoot:=1000;
                      end;
uab_URMStationLvlUp : begin
                         ua_type     := uat_NoTarget;
                         ua_req_uid  := UID_UComputerStation;
                         ua_req_UACLoot:=2000;
                      end;
      end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   UNIT BALANCE DATA
//

function DamageFactor_UWeapon2UID(pweap:PTUnitArm;uid_tar:byte):single;  forward;

function CheckUIDBaseFlags(uid_tar:byte;flags:cardinal):boolean;
var tu:TUnit;
begin
   tu.uidi:=uid_tar;
   unit_ApplyUID(@tu);

   with g_uids[uid_tar] do
     CheckUIDBaseFlags:=CheckUnitBaseFlags(@tu,flags,uid_FlyLevelLikeTarget or uid_ability_isCanLiftUp);
end;

function DamageFactor_UID2UID(uid_src,uid_tar:byte):single;
var arm:byte;
   tfac:single;
begin
   DamageFactor_UID2UID:=0;
   with g_uids[uid_src] do
     if(uid_CanAttack)then
       for arm:=0 to LastUnitArms do
       begin
          tfac:=DamageFactor_UWeapon2UID(@uid_arms[arm],uid_tar);
          if(tfac>DamageFactor_UID2UID)then DamageFactor_UID2UID:=tfac;

          if(g_uids[uid_tar].uid_MSpeed_Base<=0)and(g_uids[uid_tar].uid_CanAttack)then
            if(uid_SightR_Base>g_uids[uid_tar].uid_SightR_Base)then
              if(2>DamageFactor_UID2UID)then DamageFactor_UID2UID:=2;
       end;
end;

function DamageFactor_UWeapon2UID(pweap:PTUnitArm;uid_tar:byte):single;
var dm:byte;
begin
   DamageFactor_UWeapon2UID:=0;

   with pweap^ do
     if(CheckUIDBaseFlags(uid_tar,aw_tar_Flags))and(uid_tar in aw_tar_uids)then
       case aw_type of
       wpt_missle,
       wpt_directdmg : begin
                          DamageFactor_UWeapon2UID:=1;
                          if(aw_impact_dmod>0)then
                            for dm:=0 to LastDamageModFactor do
                              with g_DamageMods[aw_impact_dmod][dm] do
                                if(dm_TargetFlags<>0)then
                                  if(CheckUIDBaseFlags(uid_tar,dm_TargetFlags))then DamageFactor_UWeapon2UID*=(dm_factor/100);
                       end;
       wpt_directdmgZ: if(g_uids[uid_tar].uid_ZombieUID>0)then DamageFactor_UWeapon2UID:=2;
       wpt_unit      : DamageFactor_UWeapon2UID:=DamageFactor_UID2UID(aw_object_id,uid_tar);
       end;
end;


procedure InitUnitBalanceData;
var
uid_src,
uid_tar   :byte;
armfactor1,
armfactor2:single;
begin
   for uid_src in [1..255] do
     if(g_uids[uid_src].uid_r>0)then
       for uid_tar in [1..255] do
         if(g_uids[uid_tar].uid_r>0)then
         begin
            armfactor1:=DamageFactor_UID2UID(uid_src,uid_tar);
            armfactor2:=DamageFactor_UID2UID(uid_tar,uid_src);
            if(armfactor1>armfactor2)then
            begin
               if(not g_uids[uid_tar].uid_isbuilding)or(armfactor1>1)
               then g_uids[uid_src].uid_balance_Good+=[uid_tar];
            end
            else
              if((armfactor1=0)and(armfactor2>0))
              or((armfactor1=0)and(armfactor2=0))
              then g_uids[uid_src].uid_balance_Useless+=[uid_tar]
              else
                if(armfactor1<armfactor2)
                then g_uids[uid_src].uid_balance_Bad+=[uid_tar];
         end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure GameObjectsInit;
var u:integer;
begin
   for u:=0 to MaxUnits do g_punits[u]:=@g_units[u];

   // weapon target requirements set
   //                                      wtr_owner_p wtr_owner_a wtr_owner_e wtr_hits_h wtr_hits_d wtr_hits_a wtr_bio wtr_mech wtr_unit wtr_building wtr_complete wtr_ncomplete wtr_ground wtr_fly wtr_light wtr_heavy wtr_stun wtr_nostun;
   wtrset_all                            :=wtr_owner_p+wtr_owner_a+wtr_owner_e+wtr_hits_h+wtr_hits_d+wtr_hits_a+wtr_bio+wtr_mech+wtr_unit+wtr_building+wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_enemy                          :=                        wtr_owner_e+wtr_hits_h+wtr_hits_d+wtr_hits_a+wtr_bio+wtr_mech+wtr_unit+wtr_building+wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_enemy_alive                    :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_unit+wtr_building+wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_light              :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_unit+wtr_building+wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+          wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground             :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_unit+wtr_building+wtr_complete+wtr_ncomplete+wtr_ground        +wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_light       :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_unit+wtr_building+wtr_complete+wtr_ncomplete+wtr_ground        +wtr_light+          wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_heavy       :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_unit+wtr_building+wtr_complete+wtr_ncomplete+wtr_ground        +          wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_heavy_bio   :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio         +wtr_unit+             wtr_complete+wtr_ncomplete+wtr_ground        +          wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_mech        :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+        wtr_mech+wtr_unit             +wtr_complete+wtr_ncomplete+wtr_ground        +wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_fly                :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_unit+wtr_building+wtr_complete+wtr_ncomplete+           wtr_fly+wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_fly_mech           :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+        wtr_mech+wtr_unit             +wtr_complete+wtr_ncomplete+           wtr_fly+wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_mech               :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+        wtr_mech+wtr_unit             +wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_mech_nstun         :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+        wtr_mech+wtr_unit             +wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+wtr_heavy+         wtr_nostun;
   wtrset_enemy_alive_buildings          :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+                 wtr_unit+wtr_building+wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_units              :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_unit             +wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_buildings   :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+                 wtr_unit+wtr_building+wtr_complete+wtr_ncomplete+wtr_ground        +wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_bio                :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+         wtr_unit+             wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_bio_nstun          :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+         wtr_unit+             wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+wtr_heavy+         wtr_nostun;
   wtrset_enemy_alive_bio_light          :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+         wtr_unit+             wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light          +wtr_stun+wtr_nostun;
   wtrset_enemy_alive_heavy_bio          :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+         wtr_unit+             wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light          +wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_bio         :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+         wtr_unit+             wtr_complete+wtr_ncomplete+wtr_ground+        wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_light_bio   :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+         wtr_unit+             wtr_complete+wtr_ncomplete+wtr_ground+        wtr_light          +wtr_stun+wtr_nostun;
   wtrset_heal                           :=wtr_owner_p+wtr_owner_a            +wtr_hits_h                      +wtr_bio+         wtr_unit+wtr_building+wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_repair                         :=wtr_owner_p+wtr_owner_a            +wtr_hits_h                              +wtr_mech+wtr_unit+wtr_building+wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_resurect                       :=wtr_owner_p+wtr_owner_a+wtr_owner_e+           wtr_hits_d           +wtr_bio+wtr_mech+wtr_unit+wtr_building+wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+wtr_heavy+wtr_stun+wtr_nostun;

   InitUpgrades;
   InitAIDs;
   InitUIDS;
   InitMIDs;
   InitDMODs;

   InitUnitBalanceData;
end;
