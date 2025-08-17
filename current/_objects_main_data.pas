
{$IFDEF _FULLGAME}
function unit_CalcShadowZ(pu:PTUnit):integer;
begin
   with pu^  do
    with uid^ do
     if(not uid_ukbuilding)
     then unit_CalcShadowZ:=fly_height[ukfly]
     else
       if(speed<=0)or(not iscomplete)
       then unit_CalcShadowZ:=-fly_hz   // no shadow
       else unit_CalcShadowZ:=0;
end;

procedure unit_CalcFogR(pu:PTUnit);
begin
   with pu^ do fsr:=mm3i(1,srange div fog_cw,MFogM);
end;
{$ENDIF}

procedure unit_ApplyUID(pu:PTUnit);
begin
   with pu^ do
   begin
      uid:=@g_uids[uidi];
      with uid^ do
      begin
         srange     :=uid_r+uid_r;
         speed      :=uid_speed;
         ukfly      :=uid_ukfly;
         transportM :=uid_TransportMax;
         pains      :=uid_PainC;
         solid      :=uid_issolid;

         if(uid_ukbuilding)and(uid_isbarrack)then
         begin
            uo_x:=x;
            uo_y:=y+uid_r;
         end;

         {$IFDEF _FULLGAME}
         mmr   := trunc(uid_r*map_mmcx)+1;
         animw := uid_AnimStepWalk;
         shadow:= unit_CalcShadowZ(pu);

         unit_CalcFogR(pu);
         {$ENDIF}
         hits:=uid_MaxHits1;
      end;
   end;
end;

procedure InitUIDS;
var i,u:byte;

procedure _weapon(aa,wtype:byte;max_range,min_range,count:integer;reload,oid,ruid,rupid,rupidl,dupgr:byte;dupgrs:integer;tarf,reqf:cardinal;uids,reload_s:TSoB;ax,ay:integer;atarprior:byte;afakeshots:byte;admod:byte);
begin
   with g_uids[i] do
   if(aa<=LastUnitArms)then
   with uid_arms[aa] do
   begin
      aw_type     :=wtype;
      aw_max_range:=max_range;
      aw_min_range:=min_range;
      aw_count    :=count;
      aw_rld      :=reload;
      aw_oid      :=oid;
      aw_ruid     :=ruid;
      aw_rupgr    :=rupid;
      aw_rupgr_l  :=rupidl;
      aw_dupgr    :=dupgr;
      aw_dupgr_s  :=dupgrs;
      aw_tarf     :=tarf;
      aw_reqf     :=reqf;
      aw_uids     :=uids;
      aw_x        :=ax;
      aw_y        :=ay;
      aw_tarprior :=atarprior;
      aw_fakeshots:=afakeshots;
      aw_dmod     :=admod;
      if(reload_s<>[])
      then aw_rld_s:=reload_s
      else aw_rld_s:=[aw_rld];
   end;
end;
begin
   FillChar(g_uids   ,SizeOf(g_uids   ),0);

   for i:=0 to 255 do
   with g_uids[i] do
   begin
      uid_MaxHits1     := 1000;
      uid_ProdTimeSec     := 1;
      uid_ukfly     := uf_ground;
      uid_class       := 255;
      uid_TransportSize:= 1;
      uid_race     := r_hell;
      uid_CanAttack    := false;
      uid_FastDeathHits:=-32000;
      uid_LimitUse  := MinUnitLimit;

      uid_ukbuilding:= false;
      uid_ukmech    := false;
      uid_uklight   := false;

      uid_detector  := false;

      uid_isbuilder := false;
      uid_issmith   := false;
      uid_isbarrack := false;
      uid_issolid   := true;
      uid_SlowTurn  := false;

      case i of
//         HELL BUILDINGS   ////////////////////////////////////////////////////
UID_HKeep,
UID_HAKeep:
begin
   uid_MaxHits1     := 17500;
   uid_EnergyReq   := 900;
   uid_r         := 66;
   uid_SightR    := 250;
   uid_class       := 0;
   uid_ProdTimeSec     := ptime3;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_isbuilder := true;
   uid_BaseRegen := BaseArmorBonus1;
   uid_prod_Buildings:= [UID_HKeep..UID_HFortress]-[UID_HSymbol2,UID_HAKeep,UID_HTotem];
   uid_upgr_SightR     :=upgr_hell_BuilderR;
   uid_SightRUpgrStep:=50;
   uid_ability         :=uab_HKeepBlink;
   uid_ability_ReqUpgr   :=upgr_hell_HKTeleport;
   if(i=UID_HAKeep)then
   begin
      uid_EnergyGen := 900;
      uid_EnergyReq := 300;
      //uid_ProdTimeSec   := uid_ProdTimeSec+(uid_ProdTimeSec div 2);
   end
   else
   begin
      uid_EnergyGen    := 300;
      uid_rebuild_uid:= UID_HAKeep;
   end;
end;

UID_HGate:
begin
   uid_MaxHits1     := 12500;
   uid_EnergyReq   := 300;
   uid_r         := 60;
   uid_class       := 1;
   uid_ProdTimeSec     := ptime2;
   uid_OutUnitsTeleBuff:=true;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_isbarrack := true;
   uid_BaseRegen := BaseArmorBonus1;
   uid_prod_Units  := [UID_Imp..UID_Archvile];
   uid_rebuild_uid  := i;
   uid_rebuild_ruid := UID_HFortress;
end;

UID_HSymbol1,
UID_HSymbol2,
UID_HSymbol3,
UID_HSymbol4:
begin
   uid_MaxHits1     := 1000;
   uid_EnergyGen   := 50;
   uid_EnergyReq   := 50;
   uid_r         := 22;
   uid_class       := 2;
   uid_ProdTimeSec     := ptime1;
   uid_ukbuilding:= true;
   uid_uklight   := true;
   uid_ukmech    := false;
   uid_SplashResist:=true;

   case i of
UID_HSymbol1: uid_rebuild_uid:=UID_HSymbol2;
UID_HSymbol2: begin
              //uid_ProdTimeSec  := uid_ProdTimeSec+(uid_ProdTimeSec div 4);
              uid_EnergyGen*= 2;
              uid_EnergyReq:= 0;
              uid_rebuild_uid:=UID_HSymbol3;
              end;
UID_HSymbol3: begin
              //uid_ProdTimeSec  := uid_ProdTimeSec+(uid_ProdTimeSec div 4);
              uid_EnergyGen*= 3;
              uid_EnergyReq:= 0;
              uid_rebuild_uid:=UID_HSymbol4;
              end;
UID_HSymbol4: begin
              //uid_ProdTimeSec  := uid_ProdTimeSec+(uid_ProdTimeSec div 4);
              uid_EnergyGen*= 4;
              uid_EnergyReq:= 0;
              end;
   end;
end;

UID_HPools:
begin
   uid_MaxHits1     := 12500;
   uid_EnergyReq   := 300;
   uid_r         := 53;
   uid_class       := 5;
   uid_ProdTimeSec     := ptime2;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_issmith   := true;
   uid_BaseRegen := BaseArmorBonus1;
   uid_prod_Upgrades := [];
   uid_rebuild_uid  := i;
   uid_rebuild_ruid := UID_HFortress;
end;

UID_HPentagram:
begin
   uid_MaxHits1     := 17500;
   uid_EnergyReq   := 1200;
   uid_r         := 65;
   uid_class       := 9;
   uid_ProdTimeSec     := ptime5;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_BaseRegen := BaseArmorBonus1;
   uid_issolid   := false;
   uid_req_uid1     := UID_HPools;
end;
UID_HMonastery:
begin
   uid_MaxHits1     := 17500;
   uid_EnergyReq   := 1200;
   uid_r         := 65;
   uid_class       := 10;
   uid_ProdTimeSec     := ptime5;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_BaseRegen := BaseArmorBonus1;
   uid_req_uid1     := UID_HPools;
end;
UID_HFortress:
begin
   uid_MaxHits1     := 17500;
   uid_EnergyReq   := 1200;
   uid_r         := 86;
   uid_class       := 11;
   uid_ProdTimeSec     := ptime5;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_BaseRegen := BaseArmorBonus1;
   uid_req_uid1     := UID_HPools;
end;

UID_HTeleport:
begin
   uid_MaxHits1     := 5000;
   uid_EnergyReq   := 400;
   uid_r         := 28;
   uid_SightR    := 100;
   uid_class       := 13;
   uid_ProdTimeSec     := ptime2;
   uid_LimitUse  := ul4;
   uid_ability   := uab_Teleport;
   //uid_ability_ReqUpgr:=
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_BaseRegen := BaseArmorBonus1;
   uid_issolid   := false;
   uid_req_uid1     := UID_HAKeep;
end;
UID_HAltar:
begin
   uid_MaxHits1     := 12500;
   uid_EnergyReq   := 2000;
   uid_r         := 50;
   uid_class       := 14;
   uid_LimitUse  := ul10;
   uid_ProdTimeSec     := ptime10;
   uid_req_uid1     := UID_HPentagram;
   uid_req_uid2     := UID_HMonastery;
   uid_req_uid3     := UID_HFortress;
   uid_BaseRegen := BaseArmorBonus1;
   uid_ukbuilding:= true;
   uid_ukmech    := false;
   uid_SplashResist:=true;
   uid_ability   := uab_HInvulnerability;
end;

UID_HTower:
begin
   uid_MaxHits1     := 6000;
   uid_EnergyReq   := 200;
   uid_r         := 20;
   uid_SightR    := 300;
   uid_class       := 6;
   uid_ProdTimeSec     := ptime1q;
   uid_CanAttack    := true;
   uid_ability   := uab_HTowerBlink;
   uid_ability_ReqUpgr:=upgr_hell_TowerBlink;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_uklight   := true;
   uid_upgr_SightR     :=upgr_hell_TowerR;
   uid_SightRUpgrStep:=25;
   uid_rebuild_uid :=UID_HTotem;
   uid_rebuild_ruid:=UID_HFortress;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpst,MID_Imp,0,0,0,upgr_hell_DistDamage1,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all-[UID_Imp],[],0,-26,wtp_UnitBioHeavy,0,dm_AntiUnitBioHeavy2);
end;
UID_HTotem:
begin
   uid_MaxHits1     := 4000;
   uid_EnergyReq   := 400;
   uid_r         := 20;
   uid_SightR    := 300;
   uid_class       := 7;
   uid_ProdTimeSec     := ptime2;
   uid_req_uid1     := UID_HFortress;
   uid_CanAttack    := true;
   uid_ability   := uab_HTowerBlink;
   uid_ability_ReqUpgr :=upgr_hell_TowerBlink;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_uklight   := true;
   uid_upgr_SightR     :=upgr_hell_TowerR;
   uid_SightRUpgrStep:=25;
   uid_rebuild_uid :=UID_HTower;
   uid_arms_BonusAntiUnitRange:=50;
   _weapon(0,wpt_missle,aw_fsr,0,0,fr_fps2,MID_ArchFire,0,0,0,0,0,wtrset_enemy_alive,wpr_any,uids_all,[fr_archvile_s],0,0,wtp_hits,0,0);
end;
UID_HEyeNest:
begin
   uid_MaxHits1     := 1000;
   uid_EnergyReq   := 100;
   uid_r         := 15;
   uid_SightR    := 300;
   uid_class       := 12;
   uid_ProdTimeSec     := ptime3;
   uid_ability   := uab_HellVision;
   uid_ukbuilding:= true;
   uid_issolid   := false;
   uid_uklight   := true;
   uid_ukmech    := false;
   uid_SplashResist:=true;
   uid_detector  := true;
   uid_upgr_SightR     :=upgr_hell_EvilEyeR;
   uid_SightRUpgrStep:=50;
end;

//////////////////////////////

{
0   0   28
0   200 0
0.5 100 28
0.5 200 14
1   200 28
2   400 28
2   200 56
2   300 42
}

UID_Imp       :
begin
   uid_MaxHits1     := 750;
   uid_EnergyReq   := 200;
   uid_r         := 11;
   uid_speed     := 10;
   uid_SightR    := 200;
   uid_class       := 0;
   uid_PainC     := 2;
   uid_ProdTimeSec     := ptimeq3;
   uid_CanAttack    := true;
   uid_uklight   := true;
   uid_FastDeathHits:=fdead_hits_border;
   uid_arms_BonusAntiFlyRange:=-50;
   _weapon(0,wpt_missle   ,aw_srange,0,0          ,fr_fps1,MID_Imp,0,0,0,upgr_hell_DistDamage1,BaseDamageBonus1,wtrset_enemy_alive       ,wpr_any,uids_all-[UID_Imp],[],0,-5,wtp_UnitBioHeavy,0,dm_AntiUnitBioHeavy2);
   _weapon(1,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fps1,0      ,0,0,0,upgr_hell_MeleeDamage ,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Imp],[],0, 0,wtp_distance    ,0,0);
end;
UID_Demon     :
begin
   uid_MaxHits1     := 1500;
   uid_EnergyReq   := 300;
   uid_r         := 14;
   uid_speed     := 16;
   uid_SightR    := 200;
   uid_class       := 1;
   uid_TransportSize:= 2;
   uid_PainC     := 8;
   uid_ProdTimeSec     := ptime1;
   uid_CanAttack    := true;
   _weapon(0,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fpst2,0,0,0,0,upgr_hell_MeleeDamage,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any ,uids_all,[],0,0,wtp_distance,0,dm_AntiUnitBioHeavy2);
end;
{
2 2000 2
2 2500 1.5
}
UID_Knight    :
begin
   uid_MaxHits1     := 2500;
   uid_EnergyReq   := 300;
   uid_r         := 14;
   uid_speed     := 10;
   uid_SightR    := 250;
   uid_class       := 2;
   uid_PainC     := 10;
   uid_ProdTimeSec     := ptime1h;
   uid_TransportSize:= 3;
   uid_LimitUse  := ul2;
   uid_CanAttack    := true;
   uid_uklight   := true;
   uid_req_uid1     := UID_HPools;
   _weapon(0,wpt_missle   ,aw_srange,0,0          ,fr_fps1  ,MID_Baron,0,0,0,upgr_hell_DistDamage1,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all-[UID_Knight,UID_Baron],[],0,0,wtp_UnitLight,0,dm_AntiUnitLight2);
   _weapon(1,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fps1  ,0        ,0,0,0,upgr_hell_MeleeDamage ,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Knight,UID_Baron],[],0,0,wtp_distance ,0,0);
end;
UID_Baron     :
begin
   {
   3 3000 3
   3 4000 2
   3 4500 1.5
   }
   uid_MaxHits1     := 4500;
   uid_EnergyReq   := 500;
   uid_r         := 14;
   uid_speed     := 10;
   uid_SightR    := 275;
   uid_class       := 3;
   uid_PainC     := 10;
   uid_ProdTimeSec     := ptime1h;
   uid_TransportSize:= 3;
   uid_LimitUse  := ul3;
   uid_CanAttack    := true;
   uid_uklight   := false;
   uid_req_uid1     := UID_HPools;
   _weapon(0,wpt_missle   ,aw_srange,0,0          ,fr_fps1   ,MID_Baron,0,0,0,upgr_hell_DistDamage1,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all-[UID_Knight,UID_Baron],[],0,0,wtp_UnitLight,0,dm_AntiUnitLight2);
   _weapon(1,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fps1   ,0        ,0,0,0,upgr_hell_MeleeDamage ,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Knight,UID_Baron],[],0,0,wtp_distance ,0,0);
end;
UID_Revenant   :
begin
   uid_MaxHits1     := 1500;
   uid_EnergyReq   := 300;
   uid_r         := 13;
   uid_speed     := 14;
   uid_SightR    := 225;
   uid_class       := 4;
   uid_PainC     := 5;
   uid_TransportSize:= 2;
   uid_ProdTimeSec     := ptime1;
   uid_req_uid1     := UID_HPools;
   uid_LimitUse  := ul1h;
   uid_CanAttack    := true;
   uid_uklight   := false;
   uid_arms_BonusAntiFlyRange:=100;
   _weapon(0,wpt_missle   ,aw_srange ,0,0          ,fr_fps1,MID_Revenant ,0,0,0,upgr_hell_DistDamage2,BaseDamageBonus1,wtrset_enemy_alive       ,wpr_any,uids_all-[UID_Revenant],[],0,-7,wtp_Fly     ,0,dm_AntiFly2);
   _weapon(1,wpt_directdmg,aw_dmelee ,0,BaseDamage1,fr_fps1,0            ,0,0,0,upgr_hell_MeleeDamage ,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Revenant],[],0, 0,wtp_distance,0,0);
end;
UID_Cacodemon :
begin
   uid_MaxHits1     := 2000;
   uid_EnergyReq   := 250;
   uid_r         := 14;
   uid_speed     := 10;
   uid_SightR    := 200;
   uid_class       := 5;
   uid_PainC     := 8;
   uid_ProdTimeSec     := ptime1q;
   uid_TransportSize:= 2;
   uid_LimitUse  := ul1h;
   uid_ukfly     := uf_fly;
   uid_req_uid1     := UID_HPools;
   uid_req_uid2     := UID_HAKeep;
   uid_CanAttack    := true;
   uid_zfall     := fly_height[uf_fly];
   uid_arms_BonusAntiFlyRange:=50;
   _weapon(0,wpt_missle   ,aw_srange ,0,0          ,fr_fps1   ,MID_Cacodemon,0,0,0,upgr_hell_DistDamage1,BaseDamageBonus1,wtrset_enemy_alive      ,wpr_any,uids_all-[UID_Cacodemon],[],0,0,wtp_UnitMech,0,dm_AntiUnitMech2);
   _weapon(1,wpt_directdmg,aw_dmelee ,0,BaseDamage1,fr_fps1   ,0            ,0,0,0,upgr_hell_MeleeDamage ,BaseDamageBonus1,wtrset_enemy_alive_fly  ,wpr_any,         [UID_Cacodemon],[],0,0,wtp_distance ,0,0);
end;
UID_Mastermind :
begin
   {
   ul10 = 10000hp + 520dps
          14000hp + 312dps
   }
   uid_MaxHits1     := 14000;
   uid_EnergyReq   := 1200;
   uid_r         := 28;
   uid_speed     := 14;
   uid_SightR    := 300;
   uid_class       := 6;
   uid_PainC     := 10;
   uid_ProdTimeSec     := ptime4;
   uid_TransportSize:= 12;
   uid_req_uid1     := UID_HPentagram;
   uid_CanAttack    := true;
   uid_LimitUse  := ul10;
   uid_ukmech    := true;
   uid_upgr_Regen:= upgr_race_regen_bio[r_hell];
   uid_upgr_Armor:= upgr_race_armor_bio[r_hell];
   uid_arms_BonusAntiUnitRange:=50;
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_fpss,MID_SChaingun,0,0,0,upgr_hell_DistDamage2,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_Bio,2,dm_AntiBio2);
end;
{
12000  18000  19000
x12    x6     x5

10000  15000
x10    x5

20     2000
200    200
100    1000
80     1200
}
UID_Cyberdemon :
begin
   uid_MaxHits1     := 15000;
   uid_EnergyReq   := 1200;
   uid_r         := 20;
   uid_speed     := 14;
   uid_SightR    := 275;
   uid_class       := 7;
   uid_PainC     := 10;
   uid_ProdTimeSec     := ptime4;
   uid_TransportSize:= 12;
   uid_req_uid1     := UID_HPentagram;
   uid_CanAttack    := true;
   uid_LimitUse  := ul10;
   uid_ukmech    := true;
   uid_upgr_Regen:= upgr_race_regen_bio[r_hell];
   uid_upgr_Armor:= upgr_race_armor_bio[r_hell];
   uid_arms_BonusAntiBuildingRange:=50;
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_fps1   ,MID_HRocket,0,0,0,upgr_hell_DistDamage2,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_Building,0,dm_Siege4);
end;
UID_Pain      :
begin
   uid_MaxHits1     := 1500;
   uid_EnergyReq   := 500;
   uid_r         := 15;
   uid_speed     := 7;
   uid_SightR    := 225;
   uid_class       := 8;
   uid_PainC     := 3;
   uid_ProdTimeSec     := ptime2;
   uid_TransportSize:= 2;
   uid_req_uid1     := UID_HMonastery;
   uid_req_uid2     := UID_HAKeep;
   uid_LimitUse  := ul1;
   uid_ukfly     := uf_fly;
   uid_CanAttack    := true;
   uid_ability   := uab_SpawnLost;
   uid_DeathUID := UID_LostSoul;
   uid_DeathUIDn:= 3;
   _weapon(0,wpt_unit,aw_fsr+50,0,0 ,fr_fps2,UID_Phantom ,0,upgr_hell_Phantoms,1,0,0,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_distance,0,0);
   _weapon(1,wpt_unit,aw_fsr+50,0,0 ,fr_fps2,UID_LostSoul,0,0                 ,0,0,0,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_distance,0,0);

   uid_FastDeathHits:=1;
end;

{
2.4 lim 2400hp 149 dps
3   lim 3600hp 149 dps
}
UID_Mancubus  :
begin
   uid_MaxHits1     := 4000;
   uid_EnergyReq   := 500;
   uid_r         := 17;
   uid_speed     := 8;
   uid_SightR    := 275;
   uid_class       := 9;
   uid_TransportSize:= 4;
   uid_PainC     := 7;
   uid_ProdTimeSec     := ptime1h;
   uid_req_uid1     := UID_HMonastery;
   uid_LimitUse  := ul3;
   uid_CanAttack    := true;
   uid_arms_BonusAntiBuildingRange:=50;
   _weapon(0,wpt_missle,aw_srange,0,-9,fr_mancubus_rld,MID_Mancubus,0,0,0,upgr_hell_DistDamage2,BaseDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all-[UID_Mancubus],[fr_mancubus_rld_s1,fr_mancubus_rld_s2,fr_mancubus_rld_s3],0,0,wtp_building,0,dm_Siege4);
end;
UID_Arachnotron:
begin
   uid_MaxHits1     := 3000;
   uid_EnergyReq   := 500;
   uid_r         := 17;
   uid_speed     := 11;
   uid_SightR    := 275;
   uid_class       := 10;
   uid_PainC     := 7;
   uid_TransportSize:= 4;
   uid_ProdTimeSec     := ptime1h;
   uid_req_uid1     := UID_HMonastery;
   uid_LimitUse  := ul3;
   uid_CanAttack    := true;
   uid_ukmech    := true;
   uid_upgr_Regen:= upgr_race_regen_bio[r_hell];
   uid_upgr_Armor:= upgr_race_armor_bio[r_hell];
   uid_arms_BonusAntiUnitRange:=50;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpst,MID_YPlasma,0,0,0,upgr_hell_DistDamage2,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all-[UID_Arachnotron],[],0,0,wtp_UnitMech,2,dm_AntiUnitMech2);
end;
UID_Archvile:
begin
   uid_MaxHits1     := 5000;
   uid_EnergyReq   := 700;
   uid_r         := 14;
   uid_speed     := 16;
   uid_SightR    := 300;
   uid_class       := 11;
   uid_PainC     := 12;
   uid_ProdTimeSec     := ptime1h;
   uid_TransportSize:= 4;
   uid_req_uid1     := UID_HMonastery;
   uid_LimitUse  := ul4;
   uid_CanAttack    := true;
   uid_uklight   := true;
   uid_arms_BonusAntiUnitRange:=50;
   _weapon(0,wpt_resurect,aw_dmelee,0,3  ,fr_fpsh,0           ,0,upgr_hell_Resurrect,1,0,0,wtrset_resurect   ,wpr_any,uids_arch_res,[             ],0,0,wtp_distance   ,0,0);
   _weapon(1,wpt_missle  ,aw_fsr   ,0,0  ,fr_fps2,MID_ArchFire,0,0                  ,0,0,0,wtrset_enemy_alive,wpr_any,uids_all     ,[fr_archvile_s],0,0,wtp_nolost_hits,0,0);
end;

UID_Phantom,
UID_LostSoul  :
begin
   uid_MaxHits1     := 1000;
   uid_EnergyReq   := 100;
   uid_r         := 10;
   uid_speed     := 24;
   uid_SightR    := 175;
   uid_class       := 12;
   uid_PainC     := 1;
   uid_ProdTimeSec     := ptimeh;
   uid_ukfly     := uf_fly;
   uid_CanAttack    := true;
   uid_uklight   := true;
   uid_FastDeathHits:=1;
   if(i=UID_Phantom)then
   begin
   uid_class       :=13;
   uid_EnergyReq   :=200;
   uid_ProdTimeSec     :=ptime1;
   _weapon(0,wpt_directdmgZ,aw_dmelee,0,BaseDamaget,fr_fps1,0,0,0,0,upgr_hell_MeleeDamage,BaseDamageBonus1,wtrset_all        ,wpr_any,uids_all,[],0,0,wtp_distance,0,dm_Lost);
   end;
   _weapon(1,wpt_directdmg ,aw_dmelee,0,BaseDamaget,fr_fps1,0,0,0,0,upgr_hell_MeleeDamage,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_Bio     ,0,dm_Lost);
end;
UID_ZMedic:
begin
   uid_MaxHits1     := 500;
   uid_EnergyReq   := 200;
   uid_r         := 11;
   uid_speed     := 14;
   uid_SightR    := 175;
   uid_class       := 14;
   uid_PainC     := 1;
   uid_ProdTimeSec     := ptime1;
   uid_CanAttack    := true;
   uid_uklight   := true;
   uid_FastDeathHits:=fdead_hits_border;
   _weapon(0,wpt_heal  ,aw_hmelee,0,BaseHeal1,fr_fpsh,0          ,0,0,0,0                 ,0               ,wtrset_heal              ,wpr_any,uids_all,[],0, 0,wtp_heal,0,0);
   _weapon(1,wpt_missle,aw_srange,0,0        ,fr_fpsh,MID_Bullet ,0,0,0,upgr_hell_DistDamage2,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,wtp_hits      ,0,0);
end;
UID_ZEngineer:
begin
   uid_MaxHits1     := 500;
   uid_EnergyReq   := 200;
   uid_r         := 11;
   uid_speed     := 14;
   uid_SightR    := 175;
   uid_class       := 15;
   uid_PainC     := 1;
   uid_ProdTimeSec     := ptime1;
   uid_CanAttack    := true;
   uid_uklight   := true;
   uid_FastDeathHits:=fdead_hits_border;
   _weapon(0,wpt_heal  ,aw_hmelee,0,BaseRepair1,fr_fpsh,0          ,0,0,0,0                 ,0               ,wtrset_repair     ,wpr_any,uids_all,[],0,0 ,wtp_heal,0,0);
   _weapon(1,wpt_missle,aw_srange,0,0          ,fr_fpsh,MID_Bullet ,0,0,0,upgr_hell_DistDamage2,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,-4,wtp_hits      ,0,0);
end;
UID_ZSergant :
begin
   uid_MaxHits1     := 750;
   uid_EnergyReq   := 200;
   uid_r         := 11;
   uid_speed     := 14;
   uid_SightR    := 175;
   uid_class       := 16;
   uid_PainC     := 2;
   uid_ProdTimeSec     := ptimeq3;
   uid_CanAttack    := true;
   uid_uklight   := true;
   uid_req_uid1     := UID_HBarracks;
   uid_req_uid1n    := 3;
   uid_FastDeathHits:=fdead_hits_border;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1,MID_SShot,0,0,0,upgr_hell_DistDamage2,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_UnitBioHeavy,0,dm_AntiUnitBioHeavy2);
end;
UID_ZSSergant:
begin
   uid_MaxHits1     := 750;
   uid_EnergyReq   := 250;
   uid_r         := 11;
   uid_speed     := 14;
   uid_SightR    := 175;
   uid_class       := 17;
   uid_PainC     := 2;
   uid_ProdTimeSec     := ptime1;
   uid_CanAttack    := true;
   uid_uklight   := false;
   uid_req_uid1     := UID_HBarracks;
   uid_req_uid1n    := 3;
   uid_FastDeathHits:=fdead_hits_border;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1h,MID_SSShot,0,0,0,upgr_hell_DistDamage2,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_UnitBioHeavy,0,dm_SSGShot2);
end;
UID_ZCommando:
begin
   uid_MaxHits1     := 750;
   uid_EnergyReq   := 200;
   uid_r         := 11;
   uid_speed     := 14;
   uid_SightR    := 200;
   uid_class       := 18;
   uid_PainC     := 4;
   uid_ProdTimeSec     := ptimeq3;
   uid_CanAttack    := true;
   uid_uklight   := false;
   uid_req_uid1     := UID_HBarracks;
   uid_req_uid1n    := 3;
   uid_FastDeathHits:=fdead_hits_border;
   uid_arms_BonusAntiFlyRange:=-50;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fpss,MID_Chaingun,0,0,0,upgr_hell_DistDamage2,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_UnitBioLight,6,dm_AntiUnitBioLight2);
end;
UID_ZAntiaircrafter:
begin
   uid_MaxHits1     := 750;
   uid_EnergyReq   := 200;
   uid_r         := 11;
   uid_speed     := 14;
   uid_SightR    := 175;
   uid_class       := 19;
   uid_PainC     := 4;
   uid_ProdTimeSec     := ptimeq3;
   uid_CanAttack    := true;
   uid_uklight   := true;
   uid_req_uid1     := UID_HBarracks;
   uid_req_uid1n    := 3;
   uid_FastDeathHits:=fdead_hits_border;
   uid_arms_BonusAntiFlyRange:=75;
   _weapon(0,wpt_missle,aw_srange,rocket_sr,0 ,fr_fps1,MID_URocketS,0,0,0,upgr_hell_DistDamage2,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,-4,wtp_Fly,0,dm_AntiFly2);
end;
UID_ZSiegeMarine:
begin
   uid_MaxHits1     := 1000;
   uid_EnergyReq   := 200;
   uid_r         := 11;
   uid_speed     := 14;
   uid_SightR    := 175;
   uid_class       := 20;
   uid_PainC     := 5;
   uid_ProdTimeSec     := ptime1;
   uid_CanAttack    := true;
   uid_uklight   := true;
   uid_req_uid1     := UID_HBarracks;
   uid_req_uid1n    := 3;
   uid_FastDeathHits:=fdead_hits_border;
   _weapon(0,wpt_missle,aw_srange,rocket_sr,0 ,fr_fps1,MID_Granade,0,0,0,upgr_hell_DistDamage2,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,wtp_building,0,dm_Siege4);
end;
UID_ZFPlasmagunner:
begin
   uid_MaxHits1     := 750;
   uid_EnergyReq   := 250;
   uid_r         := 11;
   uid_speed     := 14;
   uid_SightR    := 200;
   uid_class       := 21;
   uid_PainC     := 5;
   uid_ProdTimeSec     := ptime1;
   uid_CanAttack    := true;
   uid_LimitUse  := ul1h;
   uid_uklight   := true;
   uid_ukfly     := true;
   uid_req_uid1     := UID_HBarracks;
   uid_req_uid1n    := 3;
   uid_req_uid2     := UID_HACommandCenter;
   uid_FastDeathHits:=1;
   uid_arms_BonusAntiFlyRange:=50;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsq,MID_BPlasma,0,0,0,upgr_hell_DistDamage2,BaseDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all,[],0,0,wtp_UnitMech,2,dm_AntiUnitMech2);
end;
UID_ZBFGMarine:
begin
   uid_MaxHits1     := 1000;
   uid_EnergyReq   := 600;
   uid_r         := 11;
   uid_speed     := 12;
   uid_SightR    := 250;
   uid_class       := 22;
   uid_PainC     := 5;
   uid_ProdTimeSec     := ptime3;
   uid_CanAttack    := true;
   uid_uklight   := false;
   uid_TransportSize:= 2;
   uid_req_uid1     := UID_HBarracks;
   uid_req_uid1n    := 4;
   uid_req_uid2     := UID_HACommandCenter;
   uid_req_uid2n    := 2;
   uid_LimitUse  := ul5;
   uid_FastDeathHits:=fdead_hits_border;
   uid_arms_BonusAntiUnitRange:=50;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps2,MID_BFG,0,0,0,0,0,wtrset_enemy_alive,wpr_any,uids_all,[fr_fps1],0,0,wtp_limitaround,0,dm_BFG);
end;

//         UAC BUILDINGS   /////////////////////////////////////////////////////
UID_HCommandCenter,
UID_HACommandCenter,
UID_UCommandCenter,
UID_UACommandCenter:
begin
   uid_MaxHits1     := 15000;
   uid_EnergyReq   := 900;
   uid_speed     := 0;
   uid_r         := 66;
   uid_SightR    := 300;
   uid_class       := 0;
   uid_ProdTimeSec     := ptime3;
   uid_CanAttack    := true;
   uid_ability   := uab_CCFly;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_isbuilder := true;
   uid_SlowTurn  := false;
   uid_SightRUpgrStep:= 50;

   if(i=UID_HCommandCenter )
   or(i=UID_HACommandCenter)then
   begin
      uid_class             := 3;
      uid_prod_Buildings      :=[UID_HKeep,UID_HCommandCenter,UID_HSymbol1,UID_HTower,UID_HEyeNest,UID_HBarracks];
      ups_TransportUIDs    :=uids_demons;

      uid_upgr_SightR     :=upgr_hell_BuilderR;
      _weapon(0,wpt_missle,aw_srange,uid_r,0,fr_fpsh,MID_Imp,0,0,0,upgr_hell_DistDamage1,BaseDamageBonus1,wtrset_enemy_alive,wpr_any+wpr_move,uids_all-[UID_Imp],[],3,-65,wtp_UnitBioHeavy,0,dm_AntiUnitBioHeavy2);

      if(i=UID_HACommandCenter)then
      begin
         uid_EnergyGen := 900;
         uid_EnergyReq := 300;
         //uid_ProdTimeSec   := uid_ProdTimeSec+(uid_ProdTimeSec div 2);
      end
      else
      begin
         uid_EnergyGen    := 300;
         uid_rebuild_uid:= UID_HACommandCenter;
      end;
   end
   else
   begin
      uid_ability_ReqUpgr   := upgr_uac_CCFly;
      if(i=UID_UCommandCenter)
      then uid_ZombieUID := UID_HCommandCenter
      else uid_ZombieUID := UID_HACommandCenter;
      uid_prod_Buildings      :=[UID_UCommandCenter..UID_UComputerStation]-[UID_UGenerator2,UID_UACommandCenter];
      uid_upgr_SightR     := upgr_uac_BuilderR;
      _weapon(0,wpt_missle,aw_srange,uid_r,0 ,fr_fpsh,MID_BPlasma,0,upgr_uac_CCAttack,1,upgr_uac_DistDamage,BaseDamageBonus1,wtrset_enemy_alive,wpr_any+wpr_move,uids_all,[],3,-65,wtp_UnitMech,0,dm_AntiUnitMech2);

      if(i=UID_UACommandCenter)then
      begin
         uid_EnergyGen := 900;
         uid_EnergyReq := 300;
         //uid_ProdTimeSec   := uid_ProdTimeSec+(uid_ProdTimeSec div 2);
      end
      else
      begin
         uid_EnergyGen    := 300;
         uid_rebuild_uid:= UID_UACommandCenter;
      end;
   end;
end;

UID_HBarracks,
UID_UBarracks:
begin
   uid_MaxHits1     := 10000;
   uid_EnergyReq   := 300;
   uid_r         := 60;
   uid_class       := 1;
   uid_ProdTimeSec     := ptime2;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_isbarrack := true;
   uid_rebuild_uid  := i;

   if(i=UID_HBarracks)then
   begin
      uid_class         := 4;
      uid_prod_Units    := uids_zimbas+[UID_LostSoul,UID_Phantom];
      uid_rebuild_ruid:= UID_HACommandCenter;
   end
   else
   begin
      uid_prod_Units    := uids_marines;
      uid_ZombieUID  := UID_HBarracks;
      uid_rebuild_ruid:= UID_UComputerStation;
   end;
end;
UID_UFactory:
begin
   uid_MaxHits1     := 10000;
   uid_EnergyReq   := 300;
   uid_r         := 60;
   uid_class       := 4;
   uid_ProdTimeSec     := ptime2;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_isbarrack := true;
   uid_req_uid1     := UID_UWeaponFactory;
   uid_rebuild_uid  := i;
   uid_rebuild_ruid := UID_UComputerStation;

   uid_prod_Units:=[UID_APC,UID_UTransport,UID_UACDron,UID_Terminator,UID_Tank,UID_Flyer];
end;

UID_UGenerator1,
UID_UGenerator2,
UID_UGenerator3,
UID_UGenerator4:
begin
   uid_MaxHits1     := 2000;
   uid_EnergyGen   := 100;
   uid_EnergyReq   := 100;
   uid_r         := 38;
   uid_class       := 2;
   uid_ProdTimeSec     := ptime1;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_LimitUse  := ul2;
   case i of
UID_UGenerator1: uid_rebuild_uid:=UID_UGenerator2;
UID_UGenerator2: begin
                 //uid_ProdTimeSec  := uid_ProdTimeSec+(uid_ProdTimeSec div 4);
                 uid_EnergyGen*= 2;
                 uid_EnergyReq:= 0;
                 uid_rebuild_uid:=UID_UGenerator3;
                 end;
UID_UGenerator3: begin
                 //uid_ProdTimeSec  := uid_ProdTimeSec+(uid_ProdTimeSec div 4);
                 uid_EnergyGen*= 3;
                 uid_EnergyReq:= 0;
                 uid_rebuild_uid:=UID_UGenerator4;
                 end;
UID_UGenerator4: begin
                 //uid_ProdTimeSec  := uid_ProdTimeSec+(uid_ProdTimeSec div 4);
                 uid_EnergyGen*= 4;
                 uid_EnergyReq:= 0;
                 end;
   end;
end;

UID_UWeaponFactory:
begin
   uid_MaxHits1     := 10000;
   uid_EnergyReq   := 300;
   uid_r         := 62;
   uid_class       := 5;
   uid_ProdTimeSec     := ptime2;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_issmith   := true;

   uid_prod_Upgrades := [];

   uid_rebuild_uid  := i;
   uid_rebuild_ruid := UID_UComputerStation;
end;

UID_UTechCenter :
begin
   uid_MaxHits1     := 15000;
   uid_EnergyReq   := 1200;
   uid_r         := 86;
   uid_class       := 10;
   uid_ProdTimeSec     := ptime5;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_req_uid1     := UID_UWeaponFactory;
end;
UID_UComputerStation:
begin
   uid_MaxHits1     := 15000;
   uid_EnergyReq   := 1200;
   uid_r         := 70;
   uid_class       := 11;
   uid_ProdTimeSec     := ptime5;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_req_uid1     := UID_UWeaponFactory;
end;

UID_URadar:
begin
   uid_MaxHits1     := 3000;
   uid_EnergyReq   := 200;
   uid_r         := 35;
   uid_SightR    := 300;
   uid_class       := 12;
   uid_ProdTimeSec     := ptime2;
   uid_LimitUse  := ul2;
   uid_ability   := uab_UACScan;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_detector  := true;
   uid_upgr_SightR:=upgr_uac_RadarR;
   uid_SightRUpgrStep:=25;
   uid_req_uid1     := UID_UWeaponFactory;
end;
UID_URMStation:
begin
   uid_MaxHits1     := 10000;
   uid_EnergyReq   := 2000;
   uid_r         := 40;
   uid_class       := 14;
   uid_ProdTimeSec     := ptime10;
   uid_LimitUse  := ul10;
   uid_req_uid1     := UID_UTechCenter;
   uid_req_uid2     := UID_UComputerStation;
   uid_ability   := uab_UACStrike;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
end;

UID_UGTurret:
begin
   uid_MaxHits1     := 6000;
   uid_EnergyReq   := 250;
   uid_r         := 15;
   uid_SightR    := 300;
   uid_class       := 6;
   uid_ProdTimeSec     := ptime1;
   uid_CanAttack    := true;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_upgr_Armor:= upgr_uac_TurretArmor;
   uid_uklight   := true;
   uid_ability      := uab_ToUACDron;
   uid_ability_ReqUpgr:= upgr_uac_DronTurret;
   uid_upgr_SightR     := upgr_uac_TowerR;
   uid_SightRUpgrStep:= 25;
   uid_rebuild_uid     := UID_UATurret;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpss,MID_BPlasma ,0,upgr_uac_TurretPlasma,1,upgr_uac_DistDamage,BaseDamageBonus1,wtrset_enemy_alive_ground_mech,wpr_any,uids_all,[],0,-11,wtp_hits        ,2,dm_AntiUnitMech2  );
   _weapon(1,wpt_missle,aw_srange,0,0 ,fr_fpss,MID_Chaingun,0,0              ,0,upgr_uac_DistDamage,BaseDamageBonus1,wtrset_enemy_alive_ground     ,wpr_any,uids_all,[],0,-11,wtp_UnitBioLight,2,dm_AntiUnitBioLight2);
end;
UID_UATurret:
begin
   uid_MaxHits1     := 6000;
   uid_EnergyReq   := 250;
   uid_r         := 15;
   uid_SightR    := 300;
   uid_class       := 7;
   uid_ProdTimeSec     := ptime1;
   uid_CanAttack    := true;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_uklight   := true;
   uid_upgr_Armor:= upgr_uac_TurretArmor;
   uid_ability      := uab_ToUACDron;
   uid_ability_ReqUpgr:= upgr_uac_DronTurret;
   uid_rebuild_uid     := UID_UGTurret;
   uid_upgr_SightR     :=upgr_uac_TowerR;
   uid_SightRUpgrStep:=25;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpst,MID_URocket ,0,0,0,upgr_uac_DistDamage,BaseDamageBonus1,wtrset_enemy_alive_fly,wpr_any ,uids_all,[],0,-14,wtp_nolost_hits,0,dm_AntiFly2);
end;

UID_UMine:
begin
   uid_MaxHits1     := 100;
   uid_EnergyReq   := 50;
   uid_r         := 5;
   uid_SightR    := 100;
   uid_class       := 19;
   uid_ProdTimeSec     := 5;
   uid_CanAttack    := true;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_uklight   := true;
   uid_detector  := true;
   uid_issolid   := false;
   uid_DeathMissile:=MID_Mine;
   uid_FastDeathHits:=1;

   _weapon(0,wpt_suicide,-mine_r,0,0,fr_fps1,0,0,0,0,0,0,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_distance,0,0);
end;

///////////////////////////////////
UID_Sergant:
begin
   uid_MaxHits1     := 1000;
   uid_EnergyReq   := 200;
   uid_r         := 11;
   uid_speed     := 14;
   uid_SightR    := 175;
   uid_class       := 0;
   uid_ProdTimeSec     := ptime1;
   uid_CanAttack    := true;
   uid_ZombieUID:= UID_ZSergant;
   uid_uklight   := true;
   uid_FastDeathHits:=fdead_hits_border;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1,MID_SShot ,0,0,0,upgr_uac_DistDamage,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_UnitBioHeavy,0,dm_AntiUnitBioHeavy2);
end;
UID_SSergant:
begin
   uid_MaxHits1     := 1000;
   uid_EnergyReq   := 300;
   uid_r         := 11;
   uid_speed     := 14;
   uid_SightR    := 175;
   uid_class       := 1;
   uid_ProdTimeSec     := ptime1;
   uid_CanAttack    := true;
   uid_ZombieUID:= UID_ZSSergant;
   uid_uklight   := false;
   uid_LimitUse  := ul1h;
   uid_FastDeathHits:=fdead_hits_border;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1h,MID_SSShot,0,0,0,upgr_uac_DistDamage,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_UnitBioHeavy,0,dm_SSGShot2);
end;
UID_Commando:
begin
   uid_MaxHits1     := 1000;
   uid_EnergyReq   := 200;
   uid_r         := 11;
   uid_speed     := 12;
   uid_SightR    := 175;
   uid_class       := 2;
   uid_ProdTimeSec     := ptime1;
   uid_CanAttack    := true;
   uid_ZombieUID:= UID_ZCommando;
   uid_uklight   := true;
   uid_req_uid1     := UID_UWeaponFactory;
   uid_FastDeathHits:=fdead_hits_border;
   uid_arms_BonusAntiFlyRange:=-50;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fpss,MID_Chaingun,0,0,0,upgr_uac_DistDamage,BaseDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all,[],0,0,wtp_UnitBioLight,6,dm_AntiUnitBioLight2);
end;
UID_Antiaircrafter:
begin
   uid_MaxHits1     := 1000;
   uid_EnergyReq   := 200;
   uid_r         := 11;
   uid_speed     := 12;
   uid_SightR    := 175;
   uid_class       := 3;
   uid_ProdTimeSec     := ptime1;
   uid_CanAttack    := true;
   uid_ZombieUID:= UID_ZAntiaircrafter;
   uid_uklight   := false;
   uid_req_uid1     := UID_UWeaponFactory;
   uid_FastDeathHits:=fdead_hits_border;
   uid_arms_BonusAntiFlyRange:=75;
   _weapon(0,wpt_missle,aw_srange,rocket_sr,0 ,fr_fps1,MID_URocket ,0,0,0,upgr_uac_DistDamage,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_Fly ,0,dm_AntiFly2);
end;
UID_SiegeMarine:
begin
   uid_MaxHits1     := 1000;
   uid_EnergyReq   := 200;
   uid_r         := 11;
   uid_speed     := 10;
   uid_SightR    := 175;
   uid_class       := 4;
   uid_ProdTimeSec     := ptime1;
   uid_CanAttack    := true;
   uid_ZombieUID:= UID_ZSiegeMarine;
   uid_uklight   := false;
   uid_req_uid1     := UID_UWeaponFactory;
   uid_FastDeathHits:=fdead_hits_border;
   _weapon(0,wpt_missle,aw_srange,rocket_sr,0 ,fr_fps1,MID_Granade,0,0,0,upgr_uac_DistDamage,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,wtp_building,0,dm_Siege4);
end;
UID_FPlasmagunner:
begin
   uid_MaxHits1     := 1000;
   uid_EnergyReq   := 250;
   uid_r         := 11;
   uid_speed     := 14;
   uid_SightR    := 200;
   uid_class       := 5;
   uid_ProdTimeSec     := ptime1q;
   uid_CanAttack    := true;
   uid_ZombieUID:= UID_ZFPlasmagunner;
   uid_uklight   := false;
   uid_LimitUse  := ul1h;
   uid_ukfly     := true;
   uid_req_uid1     := UID_UWeaponFactory;
   uid_req_uid2     := UID_UACommandCenter;
   uid_FastDeathHits:=1;
   uid_arms_BonusAntiFlyRange:=50;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fpsq,MID_BPlasma,0,0,0,upgr_uac_DistDamage,BaseDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all,[],0,0,wtp_UnitMech,2,dm_AntiUnitMech2);
end;
UID_BFGMarine:
begin
   uid_MaxHits1     := 1000;
   uid_EnergyReq   := 600;
   uid_r         := 11;
   uid_speed     := 10;
   uid_SightR    := 250;
   uid_class       := 6;
   uid_TransportSize:= 2;
   uid_ProdTimeSec     := ptime3;
   uid_CanAttack    := true;
   uid_ZombieUID:= UID_ZBFGMarine;
   uid_uklight   := false;
   uid_LimitUse  := ul5;
   uid_req_uid1     := UID_UTechCenter;
   uid_req_uid2     := UID_UComputerStation;
   uid_FastDeathHits:=fdead_hits_border;
   uid_arms_BonusAntiUnitRange:=50;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fps2,MID_BFG,0,0,0,upgr_uac_DistDamage,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[fr_fps1],0,0,wtp_limitaround,0,dm_BFG);
end;
UID_Engineer:
begin
   uid_MaxHits1     := 1000;
   uid_EnergyReq   := 200;
   uid_r         := 11;
   uid_speed     := 12;
   uid_SightR    := 175;
   uid_class       := 7;
   uid_ProdTimeSec     := ptime1q;
   uid_CanAttack    := true;
   uid_ZombieUID:= UID_ZEngineer;
   uid_ability   := 0;
   uid_uklight   := true;
   uid_req_uid1     := UID_UWeaponFactory;
   uid_req_uid2     := UID_UACommandCenter;
   uid_FastDeathHits:=fdead_hits_border;
   _weapon(0,wpt_heal  ,aw_hmelee,0,BaseRepair1,fr_fpsh,0          ,0,0,0,upgr_uac_RepairTools,BaseRepairBonus1,wtrset_repair            ,wpr_any,uids_all,[],0,0 ,wtp_heal,0,0);
   _weapon(1,wpt_missle,aw_srange,0,0          ,fr_fpsh,MID_Bullet ,0,0,0,upgr_uac_DistDamage ,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,wtp_hits,0,0);
end;
UID_Medic:
begin
   uid_MaxHits1     := 1000;
   uid_EnergyReq   := 200;
   uid_r         := 11;
   uid_speed     := 12;
   uid_SightR    := 175;
   uid_class       := 8;
   uid_ProdTimeSec     := ptime1q;
   uid_CanAttack    := true;
   uid_ZombieUID:= UID_ZMedic;
   uid_uklight   := true;
   uid_req_uid1     := UID_UWeaponFactory;
   uid_req_uid2     := UID_UACommandCenter;
   uid_FastDeathHits:=fdead_hits_border;
   _weapon(0,wpt_heal  ,aw_hmelee,0,BaseHeal1,fr_fpsh,0          ,0,0,0,upgr_uac_RepairTools,BaseHealBonus1  ,wtrset_heal              ,wpr_any,uids_all,[],0, 0,wtp_heal,0,0);
   _weapon(1,wpt_missle,aw_srange,0,0        ,fr_fpsh,MID_Bullet ,0,0,0,upgr_uac_DistDamage ,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,wtp_hits,0,0);
end;
UID_UACDron:
begin
   uid_MaxHits1     := 2000;
   uid_EnergyReq   := 400;
   uid_r         := 14;
   uid_speed     := 15;
   uid_SightR    := 250;
   uid_class       := 9;
   uid_ProdTimeSec     := ptime1;
   uid_TransportSize:= 3;
   uid_LimitUse  := ul2;
   uid_CanAttack    := true;
   uid_ukmech    := true;
   uid_uklight   := true;
   uid_ability   := uab_RebuildInPoint;
   uid_rebuild_uid   :=UID_UGTurret;
   uid_rebuild_rupgr :=upgr_uac_DronTurret;
   uid_FastDeathHits:=1;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsq,MID_BPlasma,0,0,0,upgr_uac_DistDamage,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_UnitMech,2,dm_AntiUnitMech2);
end;
UID_UTransport:
begin
   uid_MaxHits1     := 2000;
   uid_EnergyReq   := 200;
   uid_r         := 33;
   uid_speed     := 18;
   uid_SightR    := 200;
   uid_class       := 10;
   uid_ProdTimeSec     := ptime1;
   uid_TransportMax:= 8;
   uid_TransportSize:= 8;
   uid_ukfly     := uf_fly;
   uid_CanAttack    := false;
   uid_ukmech    := true;
   uid_req_uid1     := UID_UACommandCenter;
   uid_FastDeathHits:=1;
   ups_TransportUIDs:=uids_marines+[UID_APC,UID_UACDron,UID_Terminator,UID_Tank];
end;
UID_Terminator:
begin
   uid_MaxHits1     := 2000;
   uid_EnergyReq   := 500;
   uid_r         := 16;
   uid_speed     := 12;
   uid_SightR    := 275;
   uid_class       := 11;
   uid_ProdTimeSec     := ptime1h;
   uid_TransportSize:= 4;
   uid_LimitUse  := ul3;
   uid_CanAttack    := true;
   uid_ukmech    := true;
   uid_req_uid1     := UID_UTechCenter;
   uid_FastDeathHits:=1;
   uid_uklight   := false;
   uid_arms_BonusAntiFlyRange:=-50;
   uid_arms_BonusAntiUnitRange:=50;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fpsq ,MID_SShot  ,0,0               ,0,upgr_uac_DistDamage,BaseDamageBonus1 ,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_UnitBio    ,0,dm_AntiUnitBio2);
   _weapon(1,wpt_missle,aw_srange,0,0,fr_fpst2,MID_URocket,0,upgr_uac_TerAAWeapon,1,upgr_uac_DistDamage,BaseDamageBonus1 ,wtrset_enemy_alive_fly   ,wpr_any,uids_all,[],0,0,wtp_nolost_hits,0,0    );
end;
UID_Tank:
begin
   uid_MaxHits1     := 5000;
   uid_EnergyReq   := 600;
   uid_r         := 20;
   uid_speed     := 8;
   uid_SightR    := 275;
   uid_class       := 12;
   uid_ProdTimeSec     := ptime2;
   uid_TransportSize:= 6;
   uid_LimitUse  := ul4;
   uid_CanAttack    := true;
   uid_ukmech    := true;
   uid_req_uid1     := UID_UTechCenter;
   uid_FastDeathHits:=1;
   uid_arms_BonusAntiBuildingRange:=50;
   _weapon(0,wpt_missle,aw_srange,rocket_sr,2 ,fr_fpst2,MID_Tank,0,0,0,upgr_uac_DistDamage,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_building,0,dm_Siege4);
end;
UID_Flyer:
begin
   uid_MaxHits1     := 4000;
   uid_EnergyReq   := 600;
   uid_r         := 18;
   uid_speed     := 17;
   uid_SightR    := 275;
   uid_class       := 13;
   uid_ProdTimeSec     := ptime2;
   uid_TransportSize:= 6;
   uid_ukfly     := uf_fly;
   uid_LimitUse  := ul4;
   uid_CanAttack    := true;
   uid_ukmech    := true;
   uid_req_uid1     := UID_UTechCenter;
   uid_req_uid2     := UID_UACommandCenter;
   uid_FastDeathHits:=1;
   uid_arms_BonusAntiUnitRange:=25;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsh,MID_Flyer  ,0,0,0,upgr_uac_DistDamage,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_GroundLight,0,dm_AntiGroundLight2);
end;

UID_APC:
begin
   uid_MaxHits1     := 3000;
   uid_EnergyReq   := 200;
   uid_r         := 25;
   uid_speed     := 15;
   uid_SightR    := 225;
   uid_class       := 14;
   uid_ProdTimeSec     := ptime2;
   uid_TransportMax:= 4;
   uid_TransportSize:= 10;
   uid_CanAttack    := false;
   uid_ukmech    := true;
   uid_SlowTurn  := true;
   uid_FastDeathHits:=1;
   ups_TransportUIDs    :=uids_marines;
end;

UID_USPort  ,
UID_UPortal :
begin
   uid_MaxHits1     := 20000;
   uid_EnergyReq   := 2000;
   uid_r         := 150;
   uid_class       := 20;
   uid_ProdTimeSec     := ptime5;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_issolid   := false;
end;

UID_UBaseMil,
UID_UBaseCom,
UID_UBaseRef,
UID_UBaseNuc,
UID_UBaseLab:
begin
   uid_MaxHits1     := 15000;
   uid_EnergyReq   := 1000;
   uid_r         := 100;
   uid_class       := 21;
   uid_ProdTimeSec     := ptime5;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
end;

UID_UBaseGen:
begin
   uid_MaxHits1     := 6000;
   uid_EnergyGen   := 1000;
   uid_EnergyReq   := 500;
   uid_r         := 55;
   uid_class       := 22;
   uid_ProdTimeSec     := ptime2;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
   uid_LimitUse  := ul1;
end;

UID_UCBuild0,
UID_UCBuild1,
UID_UCBuild2,
UID_UCBuild3:
begin
   uid_MaxHits1     := 15000;
   uid_EnergyReq   := 1000;
   uid_r         := 100;
   uid_class       := 23;
   uid_ProdTimeSec     := ptime5;
   uid_ukbuilding:= true;
   uid_ukmech    := true;
end;

      end;

      uid_square:=round(pi*uid_r*uid_r);

      if(uid_ability=0)and(uid_TransportMax>0)then uid_ability:=uab_Unload;

      if(i in uids_hell)then uid_race:=r_hell;
      if(i in uids_uac )then uid_race:=r_uac;

      if(uid_race=0)then uid_race:=r_hell;

      if(uid_req_uid1>0)and(uid_req_uid1n=0)then uid_req_uid1n:=1;
      if(uid_req_uid2>0)and(uid_req_uid2n=0)then uid_req_uid2n:=1;
      if(uid_req_uid3>0)and(uid_req_uid3n=0)then uid_req_uid3n:=1;
      if(uid_req_upgr>0)and(uid_req_upgrl=0)then uid_req_upgrl:=1;
      if(uid_ability_ReqUpgr>0)and(uid_ability_ReqUpgrl=0)then uid_ability_ReqUpgrl:=1;
      if(uid_rebuild_rupgr>0)and(uid_rebuild_rupgrl=0)then uid_rebuild_rupgrl:=1;

      if(uid_PainCUpgrStep=0)
      then uid_PainCUpgrStep:=(uid_PainC div 2)+(uid_PainC mod 2);

      uid_missileR:=trunc(uid_r/1.4);
      if(uid_MaxHits1<1)then uid_MaxHits1:=1;
      uid_MaxHitsh := uid_MaxHits1 div 2; if(uid_MaxHitsh <1)then uid_MaxHitsh :=1;
      uid_MaxHitsq:=uid_MaxHitsh div 2; if(uid_MaxHitsq<1)then uid_MaxHitsq:=1;

      if(uid_issmith)and(uid_prod_Upgrades=[])then
       for u:=1 to 255 do
        with g_upids[u] do
         if(upgr_time>0)and(uid_race=upgr_race)then uid_prod_Upgrades+=[u];

      if(uid_ukbuilding)then
      begin
         uid_ZombieHits:=uid_MaxHits1 div 4;
         uid_SightR:=max2i(uid_r+uid_r,uid_SightR);
      end;

      if(uid_LimitUse>=MinUnitLimit)then
      begin
      uid_LevelBonusDamage:=round(BaseDamageLevel1*uid_LimitUse/ul1);
      uid_LevelBonusArmor :=round(BaseArmorLevel1 *uid_LimitUse/ul1);
      end;

      uid_hits_li2si:=uid_MaxHits1/_mms;

      if(uid_ProdTimeSec> 0)then uid_ProdHitStep:=round((uid_MaxHits1/2)/uid_ProdTimeSec);
      if(uid_ProdHitStep<=0)then uid_ProdHitStep:=1;
      uid_ProdTick:=uid_ProdTimeSec*fr_fps1;
   end;
end;

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
MID_ArchFire,
MID_Mine           : mid_speed       :=32000;
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
MID_Mine           : mid_base_damage :=BaseDamage10;
MID_Blizzard       : mid_base_damage :=BaseDamage10*4;
end;

// splash R
case m of
MID_Blizzard       : mid_base_SplashR:=blizzard_sr;
MID_Mine           : mid_base_SplashR:=mine_sr;
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
MID_Imp            : mid_ImmuneUnits    :=[UID_Imp        ];
MID_Cacodemon      : mid_ImmuneUnits    :=[UID_Cacodemon  ];
MID_Baron          : mid_ImmuneUnits    :=[UID_Knight,
                                        UID_Baron      ];
MID_Revenant       : mid_ImmuneUnits    :=[UID_Revenant   ];
MID_Mancubus       : mid_ImmuneUnits    :=[UID_Mancubus   ];
MID_YPlasma        : mid_ImmuneUnits    :=[UID_Arachnotron];
MID_Mine           : mid_ImmuneUnits    :=[UID_UMine      ];
end;

// other
case m of
MID_Granade        : mid_ystep       :=3;
MID_Mine           : mid_size        :=25;
MID_URocketS,
MID_BFG            : begin
                     mid_TeamDamage  :=false;
                     mid_noFlyCheck  :=true;
                     end;
MID_Blizzard       : mid_noFlyCheck  :=true;
end;
   end;
end;

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

      dm_factor:=factor;
      dm_flags :=flags
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

procedure InitUpgrades;
var u:byte;
procedure setUPGR(rc,upcl,stime,stimeX,stimeA,max,enrg,enrgX,enrgA:integer;rupgr,ruid:byte;mfrg:boolean);
begin
   with g_upids[upcl] do
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
      upgr_mfrg      := mfrg;
      upgr_btni      := u;
      u+=1;
   end;
end;
begin
   FillChar(g_upids,SizeOf(g_upids),0);

   //                                  base X +
   //         race id                  time      lvl  enr  X +    rupgr         ruid                 multi
   u:=0;
   setUPGR(r_hell,upgr_hell_DistDamage1 ,60 ,0,35,5   ,600 ,0,700 ,0            ,0                   ,false);
   setUPGR(r_hell,upgr_hell_UnitArmor   ,60 ,0,35,5   ,600 ,0,700 ,0            ,0                   ,false);
   setUPGR(r_hell,upgr_hell_BuildArmor  ,60 ,0,20,5   ,600 ,0,800 ,0            ,0                   ,false);
   setUPGR(r_hell,upgr_hell_MeleeDamage ,60 ,0,30,5   ,600 ,0,400 ,0            ,0                   ,false);
   setUPGR(r_hell,upgr_hell_Regeneration,60 ,0,30,2   ,300 ,0,300 ,0            ,0                   ,false);
   setUPGR(r_hell,upgr_hell_PainFactor  ,60 ,0,0 ,2   ,300 ,0,300 ,0            ,0                   ,false);
   setUPGR(r_hell,upgr_hell_BuilderR    ,60 ,0,15,2   ,600 ,0,0   ,0            ,0                   ,false);
   setUPGR(r_hell,upgr_hell_HKTeleport  ,90 ,0,0 ,1   ,600 ,0,0   ,0            ,0                   ,false);
   setUPGR(r_hell,upgr_hell_DecayAura   ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HAKeep          ,false);
   setUPGR(r_hell,upgr_hell_TowerR      ,60 ,0,15,2   ,600 ,0,300 ,0            ,UID_HAKeep          ,false);

   setUPGR(r_hell,upgr_hell_Spectre     ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HAKeep          ,false);
   setUPGR(r_hell,upgr_hell_UnitSightR  ,60 ,0,30,2   ,600 ,0,300 ,0            ,UID_HMonastery      ,false);
   setUPGR(r_hell,upgr_hell_Phantoms    ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HMonastery      ,false);
   setUPGR(r_hell,upgr_hell_DistDamage2 ,60 ,0,35,5   ,600 ,0,700 ,0            ,UID_HMonastery      ,false);
   setUPGR(r_hell,upgr_hell_Resurrect   ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HMonastery      ,false);
   setUPGR(r_hell,upgr_hell_TeleportCD  ,60 ,0,30,2   ,400 ,0,200 ,0            ,UID_HFortress       ,false);
   setUPGR(r_hell,upgr_hell_Recall      ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HFortress       ,false);
   setUPGR(r_hell,upgr_hell_EvilEyeR    ,60 ,0,0 ,3   ,300 ,0,300 ,0            ,UID_HFortress       ,false);
   setUPGR(r_hell,upgr_hell_TotemInvis  ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HFortress       ,false);
   setUPGR(r_hell,upgr_hell_BuildRestore,60 ,0,0 ,5   ,600 ,0,300 ,0            ,UID_HFortress       ,false);
   setUPGR(r_hell,upgr_hell_TowerBlink  ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HFortress       ,false);


   u:=0;
   setUPGR(r_uac ,upgr_uac_DistDamage   ,60 ,0,35,5   ,600 ,0,700 ,0            ,0                   ,false);
   setUPGR(r_uac ,upgr_uac_BioArmor     ,60 ,0,35,5   ,600 ,0,700 ,0            ,0                   ,false);
   setUPGR(r_uac ,upgr_uac_BuildArmor   ,60 ,0,35,5   ,600 ,0,800 ,0            ,0                   ,false);
   setUPGR(r_uac ,upgr_uac_RepairTools  ,60 ,0,30,2   ,600 ,0,400 ,0            ,0                   ,false);
   setUPGR(r_uac ,upgr_uac_BioSpeed     ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,0                   ,false);
   setUPGR(r_uac ,upgr_uac_ssgup        ,60 ,0,0 ,1   ,300 ,0,0   ,0            ,0                   ,false);
   setUPGR(r_uac ,upgr_uac_BuilderR     ,60 ,0,15,2   ,600 ,0,0   ,0            ,0                   ,false);
   setUPGR(r_uac ,upgr_uac_CCFly        ,120,0,0 ,1   ,600 ,0,0   ,0            ,0                   ,false);
   setUPGR(r_uac ,upgr_uac_CCAttack     ,120,0,0 ,1   ,600 ,0,0   ,0            ,UID_UACommandCenter ,false);
   setUPGR(r_uac ,upgr_uac_TowerR       ,60 ,0,15,2   ,600 ,0,300 ,0            ,UID_UACommandCenter ,false);

   setUPGR(r_uac ,upgr_uac_DronTurret   ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UACommandCenter ,false);
   setUPGR(r_uac ,upgr_uac_UnitSightR   ,60 ,0,30,2   ,600 ,0,300 ,0            ,UID_UTechCenter     ,false);
   setUPGR(r_uac ,upgr_uac_CommandoInvis,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter     ,false);
   setUPGR(r_uac ,upgr_uac_AASplash     ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter     ,false);
   setUPGR(r_uac ,upgr_uac_MechSpeed    ,60 ,0,15,2   ,600 ,0,300 ,0            ,UID_UTechCenter     ,false);
   setUPGR(r_uac ,upgr_uac_MechArmor    ,60 ,0,35,5   ,600 ,0,700 ,0            ,UID_UTechCenter     ,false);
   setUPGR(r_uac ,upgr_uac_TerAAWeapon  ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter     ,false);
   setUPGR(r_uac ,upgr_uac_Transport    ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter     ,false);
   setUPGR(r_uac ,upgr_uac_RadarR       ,60 ,0,0 ,3   ,300 ,0,300 ,0            ,UID_UComputerStation,false);
   setUPGR(r_uac ,upgr_uac_TurretPlasma ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UComputerStation,false);
   setUPGR(r_uac ,upgr_uac_TurretArmor  ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UComputerStation,false);
end;

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
   InitUIDS;
   InitMIDs;
   InitDMODs;

   for u:=0 to MaxDIDs do DID_Square[u]:=round(pi*sqr(DID_R[u]));
end;
