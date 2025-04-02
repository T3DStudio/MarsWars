
{$IFDEF _FULLGAME}
function _unit_CalcShadowZ(pu:PTUnit):integer;
begin
   with pu^  do
   with uid^ do
     if(not _ukbuilding)
     then _unit_CalcShadowZ:=fly_height[ukfly]
     else
       if(speed<=0)or(not iscomplete)
       then _unit_CalcShadowZ:=-fly_hz   // no shadow
       else _unit_CalcShadowZ:=0;
end;

procedure unit_CalcFogR(pu:PTUnit);
begin
   with pu^ do
   begin
      fsr :=mm3i(0,srange div fog_CellW,MFogM);
      //mmsr:=trunc(srange*map_mm_cx)+2;
   end;
end;

procedure uids_RecalcMMR;
var u:byte;
begin
   for u:=0 to 255 do
     with g_uids[u] do
       _mmr:= trunc(_missile_r*map_mm_cx)+1;
end;

{$ENDIF}

procedure unit_apllyUID(pu:PTUnit);
begin
   with pu^ do
   begin
      uid:=@g_uids[uidi];
      with uid^ do
      begin
         isbuildarea:=_isbuilder;
         srange     :=_srange_min;
         speed      :=_speed;
         ukfly      :=_ukfly;
         transportM :=_transportM;
         pains      :=_painc;
         solid      :=_issolid;
         hits       :=_mhits;

         if(_ukbuilding)and(_isbarrack)then
         begin
            ua_x:=x;
            ua_y:=y+_r;
         end;

         {$IFDEF _FULLGAME}

         animw := _animw;
         shadow:= _unit_CalcShadowZ(pu);

         unit_CalcFogR(pu);
         {$ENDIF}
      end;
   end;
end;

procedure InitUIDS;
var i,u:byte;

procedure _weapon(aa,wtype:byte;max_range,min_range,count:integer;reload,oid,ruid,rupid,rupidl,dupgr:byte;dupgrs:integer;tarf,reqf:cardinal;uids,reload_s:TSoB;ax,ay:integer;atarprior:byte;afakeshots:byte;admod:byte);
begin
   with g_uids[i] do
   if(aa<=MaxUnitWeapons)then
   with _a_weap[aa] do
   begin
      aw_type     :=wtype;
      aw_max_range:=max_range;
      aw_min_range:=min_range;
      aw_count    :=count;
      aw_reload      :=reload;
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
      else aw_rld_s:=[aw_reload];
   end;
end;
begin
   FillChar(g_uids   ,SizeOf(g_uids   ),0);

   for i:=0 to 255 do
   with g_uids[i] do
   begin
      _mhits         := 1000;
      _btime         := 1;
      _ukfly         := uf_ground;
      _ucl           := 255;
      _transportS    := 1;
      _urace         := r_hell;
      _attack        := false;
      _fastdeath_hits:=-32000;
      _limituse      := MinUnitLimit;

      _ukbuilding    := false;
      _ukmech        := false;
      _uklight       := false;

      _detector      := false;

      _isbuilder     := false;
      _issmith       := false;
      _isbarrack     := false;
      _issolid       := true;
      _slowturn      := false;

      case i of
//         HELL BUILDINGS   ////////////////////////////////////////////////////
UID_HKeep:
begin
   _mhits            := 15000;
   _renergy          := 800;
   _genergy          := 250;
   _r                := 66;
   _srange           := 275;
   _ucl              := 0;
   _btime            := ptime4;
   _ukbuilding       := true;
   _isbuilder        := true;
   _base_armor       := BaseArmorBonus2;
   _baseregen        := BaseArmorBonus1;
   ups_builder       := [UID_HKeep..UID_HFortress];
   _upgr_srange      := upgr_hell_buildr;
   _upgr_srange_step := 50;
   _ability          := ua_HKeepBlink;
   _ability_rupgr    := upgr_hell_HKTeleport;
   _rebuild_uid      := UID_HKeep;
end;

UID_HGate:
begin
   _mhits            := 10000;
   _renergy          := 300;
   _r                := 60;
   _ucl              := 1;
   _btime            := ptime3;
   _barrack_teleport :=true;
   _ukbuilding       := true;
   _isbarrack        := true;
   _base_armor       := BaseArmorBonus2;
   _baseregen        := BaseArmorBonus1;
   ups_units         := [UID_Imp..UID_Cyberdemon];
   _rebuild_uid      := i;
   _rebuild_level    := 1;
   _rebuild_ruid     := UID_HFortress;
end;

UID_HSymbol:
begin
   _mhits            := 1000;
   _genergy          := 50;
   _renergy          := 50;
   _r                := 38;
   _ucl              := 2;
   _btime            := ptime1hh;
   _ukbuilding       := true;
   _uklight          := true;
   _limituse         := ul1h;
   _rebuild_uid      := UID_HSymbol;
end;

UID_HPools:
begin
   _mhits            := 10000;
   _renergy          := 300;
   _r                := 53;
   _ucl              := 5;
   _btime            := ptime2;
   _ukbuilding       := true;
   _issmith          := true;
   _base_armor       := BaseArmorBonus2;
   _baseregen        := BaseArmorBonus1;
   ups_upgrades      := [];
   _rebuild_uid      := i;
   _rebuild_level    := 1;
   _rebuild_ruid     := UID_HFortress;
end;

UID_HMonastery:
begin
   _mhits            := 15000;
   _renergy          := 1200;
   _r                := 65;
   _ucl              := 9;
   _btime            := ptime4;
   _ukbuilding       := true;
   _base_armor       := BaseArmorBonus2;
   _baseregen        := BaseArmorBonus1;
   _issolid          := false;
   _ruid1            := UID_HPools;
end;
UID_HPentagram:
begin
   _mhits            := 15000;
   _renergy          := 1200;
   _r                := 65;
   _ucl              := 10;
   _btime            := ptime4;
   _ukbuilding       := true;
   _base_armor       := BaseArmorBonus2;
   _baseregen        := BaseArmorBonus1;
   _issolid          := false;
   _ruid1            := UID_HPools;
end;
UID_HFortress:
begin
   _mhits            := 15000;
   _renergy          := 1200;
   _r                := 86;
   _ucl              := 11;
   _btime            := ptime4;
   _ukbuilding       := true;
   _base_armor       := BaseArmorBonus2;
   _baseregen        := BaseArmorBonus1;
   _ruid1            := UID_HPools;
end;

UID_HTeleport:
begin
   _mhits            := 3000;
   _renergy          := 300;
   _r                := 28;
   _srange           := 100;
   _ucl              := 13;
   _btime            := ptime3;
   _limituse         := ul4;
   //_ability          := ua_Teleport;
   _ukbuilding       := true;
   _base_armor       := BaseArmorBonus2;
   _baseregen        := BaseArmorBonus1;
   _issolid          := false;
   _ruid1            := UID_HMonastery;
end;
UID_HAltar:
begin
   _mhits            := 3000;
   _renergy          := 300;
   _r                := 50;
   _ucl              := 14;
   _btime            := ptime2;
   _base_armor       := BaseArmorBonus2;
   _baseregen        := BaseArmorBonus1;
   _ruid1            := UID_HMonastery;
   _ukbuilding       := true;
   //_ability          := ua_HInvulnerability;
   //_ability_rupgr    := upgr_hell_invuln;
end;

UID_HTower:
begin
   _mhits            := 5000;
   _renergy          := 300;
   _r                := 20;
   _srange           := 300;
   _ucl              := 6;
   _btime            := ptime1h;
   _attack           := true;
   //_ability          := ua_HTowerBlink;
   _ability_rupgr    := upgr_hell_tblink;
   _ukbuilding       := true;
   _uklight          := true;
   _upgr_srange      := upgr_hell_towers;
   _upgr_srange_step := 25;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsd3,MID_Imp,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all-[UID_Imp],[],0,-26,wtp_UnitBioHeavy,0,dm_AntiUnitBioHeavy);
end;
UID_HTotem:
begin
   _mhits            := 3000;
   _renergy          := 600;
   _r                := 21;
   _srange           := 300;
   _ucl              := 7;
   _btime            := ptime1h;
   _ruid1            := UID_HFortress;
   _attack           := true;
   //_ability          := ua_HTowerBlink;
   _ability_rupgr    := upgr_hell_tblink;
   _ukbuilding       := true;
   _uklight          := true;
   _limituse         := ul2;
   _upgr_srange      := upgr_hell_towers;
   _upgr_srange_step := 25;
   _weapon(0,wpt_missle,aw_fsr+50,0,0,fr_fps2,MID_ArchFire,0,0,0,0,0,wtrset_enemy_alive_units,wpr_any+wpr_avis,uids_all,[fr_archvile_s],0,0,wtp_hits,0,0);
end;
UID_HEye:
begin
   _mhits            := BaseDamage1;
   _renergy          := 50;
   _r                := 10;
   _srange           := 300;
   _ucl              := 12;
   _btime            := ptime1;
   _ability          := ua_HellVision;
   _ukbuilding       := true;
   _issolid          := false;
   _uklight          := true;
   _detector         := true;
   _upgr_srange      := upgr_hell_heye;
   _upgr_srange_step := 50;
   _ruid1            := UID_HPools;

   ups_builder       := [UID_HEye];
end;

////////////////////////////// UNITS

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
   _mhits            := 750;
   _renergy          := 200;
   _r                := 10;
   _speed            := 10;
   _srange           := 200;
   _ucl              := 0;
   _painc            := 1;
   _btime            := ptime1-ptime2h;
   _attack           := true;
   _uklight          := true;
   _fastdeath_hits   := fdead_hits_border;
   _weapon(0,wpt_missle   ,aw_srange,0,0          ,fr_fps1,MID_Imp,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive       ,wpr_any,uids_all-[UID_Imp],[],0,-5,wtp_UnitBioHeavy,0,dm_AntiUnitBioHeavy);
   _weapon(1,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fps1,0      ,0,0,0,upgr_hell_mattack ,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Imp],[],0, 0,wtp_distance    ,0,0);
end;
UID_Demon     :
begin
   _mhits            := 1500;
   _renergy          := 200;
   _r                := 14;
   _speed            := 20;
   _srange           := 200;
   _ucl              := 1;
   _transportS       := 2;
   _painc            := 6;
   _btime            := ptime1;
   _limituse         := ul1;
   _attack           := true;
   _weapon(0,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fpsd2,0,0,0,0,upgr_hell_mattack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any ,uids_all,[],0,0,wtp_distance,0,dm_AntiHeavy);
end;
UID_Cacodemon :
begin
   _mhits            := 2000;
   _renergy          := 300;
   _r                := 14;
   _speed            := 10;
   _srange           := 200;
   _ucl              := 2;
   _painc            := 6;
   _btime            := ptime1h;
   _transportS       := 2;
   _limituse         := ul1h;
   _ukfly            := uf_fly;
   _ruid1            := UID_HMonastery;
   _attack           := true;
   _zfall            := fly_height[uf_fly];
   _weapon(0,wpt_missle   ,aw_srange ,0,0          ,fr_fps1   ,MID_Cacodemon,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive      ,wpr_any,uids_all-[UID_Cacodemon],[],0,0,wtp_UnitMech,0,dm_AntiUnitMech);
   _weapon(1,wpt_directdmg,aw_dmelee ,0,BaseDamage1,fr_fps1   ,0            ,0,0,0,upgr_hell_mattack ,BaseDamageBonus1,wtrset_enemy_alive_fly  ,wpr_any,         [UID_Cacodemon],[],0,0,wtp_distance ,0,0);
end;
{
ul1  1000  BaseDamage1
ul2  2000  BaseDamage2
ul2  2500  BaseDamage1.5
}
UID_Knight    :
begin
   _mhits            := 2500;
   _renergy          := 400;
   _r                := 14;
   _speed            := 10;
   _srange           := 275;
   _ucl              := 3;
   _painc            := 8;
   _btime            := ptime1;
   _transportS       := 3;
   _limituse         := ul2;
   _attack           := true;
   _uklight          := true;
   _weapon(0,wpt_missle   ,aw_srange,0,0          ,fr_fps1  ,MID_Baron,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all-[UID_Knight,UID_Baron],[],0,0,wtp_UnitLight,0,dm_AntiUnitLight);
   _weapon(1,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fps1  ,0        ,0,0,0,upgr_hell_mattack ,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Knight,UID_Baron],[],0,0,wtp_distance ,0,0);
end;
{
ul1  1000  BaseDamage1
ul3  3000  BaseDamage3
ul3  4000  BaseDamage2
ul2  4500  BaseDamage1.5
}
UID_Baron     :
begin
   _mhits            := 4500;
   _renergy          := 600;
   _r                := 14;
   _speed            := 10;
   _srange           := 275;
   _ucl              := 4;
   _painc            := 8;
   _btime            := ptime1;
   _transportS       := 3;
   _limituse         := ul3;
   _attack           := true;
   _uklight          := false;
   _ruid1            := UID_HPools;
   _weapon(0,wpt_missle   ,aw_srange,0,0          ,fr_fps1   ,MID_Baron,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all-[UID_Knight,UID_Baron],[],0,0,wtp_UnitLight,0,dm_AntiUnitLight);
   _weapon(1,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fps1   ,0        ,0,0,0,upgr_hell_mattack ,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Knight,UID_Baron],[],0,0,wtp_distance ,0,0);
end;
UID_Pain      :
begin
   _mhits            := 1500;
   _renergy          := 600;
   _r                := 15;
   _speed            := 7;
   _srange           := 200;
   _ucl              := 5;
   _painc            := 3;
   _btime            := ptime2;
   _transportS       := 2;
   _ruid1            := UID_HPentagram;
   _limituse         := ul1;
   _ukfly            := uf_fly;
   _attack           := true;
   //_ability          := ua_SpawnLost;
   _death_uid        := UID_LostSoul;
   _death_uidn       := 3;
   _fastdeath_hits   := 1;
   _weapon(0,wpt_unit,aw_fsr+50,0,0 ,fr_fps2,UID_Phantom ,0,upgr_hell_phantoms,1,0,0,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_distance,0,0);
   _weapon(1,wpt_unit,aw_fsr+50,0,0 ,fr_fps2,UID_LostSoul,0,0                 ,0,0,0,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_distance,0,0);

end;
UID_Revenant   :
begin
   _mhits            := 1500;
   _renergy          := 300;
   _r                := 13;
   _speed            := 12;
   _srange           := 200;
   _ucl              := 6;
   _painc            := 4;
   _transportS       := 2;
   _btime            := ptime1;
   _ruid1            := UID_HPentagram;
   _limituse         := ul1h;
   _attack           := true;
   _uklight          := false;
   _a_BonusRangeAntiFly:=50;
   _weapon(0,wpt_missle   ,aw_srange ,0,0          ,fr_fps1,MID_Revenant ,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive       ,wpr_any,uids_all-[UID_Revenant],[],0,-7,wtp_Fly     ,0,dm_AntiFly);
   _weapon(1,wpt_directdmg,aw_dmelee ,0,BaseDamage1,fr_fps1,0            ,0,0,0,upgr_hell_mattack ,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Revenant],[],0, 0,wtp_distance,0,0);
end;
{
2.4 lim 2400hp 149 dps
3   lim 3600hp 149 dps
}
UID_Mancubus  :
begin
   _mhits            := 3600;
   _renergy          := 500;
   _r                := 20;
   _speed            := 7;
   _srange           := 275;
   _ucl              := 7;
   _transportS       := 4;
   _painc            := 7;
   _btime            := ptime1h;
   _ruid1            := UID_HPentagram;
   _limituse         := ul3;
   _attack           := true;
   _a_BonusRangeAntiBuilding:=50;
   _weapon(0,wpt_missle,aw_srange,0,-9,fr_mancubus_rld,MID_Mancubus,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all-[UID_Mancubus],[fr_mancubus_rld_s1,fr_mancubus_rld_s2,fr_mancubus_rld_s3],0,0,wtp_building,0,dm_Siege);
end;
UID_Arachnotron:
begin
   _mhits            := 3000;
   _renergy          := 600;
   _r                := 20;
   _speed            := 10;
   _srange           := 250;
   _ucl              := 8;
   _painc            := 7;
   _transportS       := 4;
   _btime            := ptime1;
   _ruid1            := UID_HPentagram;
   _limituse         := ul3;
   _attack           := true;
   _ukmech           := true;
   _upgr_regen       := upgr_race_regen_bio[r_hell];
   _upgr_armor       := upgr_race_armor_bio[r_hell];
   _a_BonusRangeAntiUnit:=50;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsd3,MID_YPlasma,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all-[UID_Arachnotron],[],0,0,wtp_UnitMech,0,dm_AntiUnitMech);
end;
UID_Archvile:
begin
   _mhits            := 4000;
   _renergy          := 700;
   _r                := 14;
   _speed            := 14;
   _srange           := 300;
   _ucl              := 9;
   _painc            := 7;
   _btime            := ptime1h;
   _transportS       := 4;
   _ruid1            := UID_HPentagram;
   _limituse         := ul4;
   _attack           := true;
   _a_BonusRangeAntiUnit:=100;
   _weapon(0,wpt_resurect,aw_dmelee ,0,3  ,fr_fpsd2,0           ,0,upgr_hell_resurrect,1,0,0,wtrset_resurect         ,wpr_any+wpr_reload,uids_arch_res,[             ],0,0,wtp_hits,0,0);
   _weapon(1,wpt_missle  ,aw_srange ,0,0  ,fr_fps2 ,MID_ArchFire,0,0                  ,0,0,0,wtrset_enemy_alive_units,wpr_any+wpr_avis  ,uids_all     ,[fr_archvile_s],0,0,wtp_hits,0,0);
end;
{
ul10 = 10000hp + 620dps
       15000hp + 310dps
       14000hp + 372dps or 186*2
1      200      20
10     10       1
       1        10
       6        4
}
UID_Mastermind :
begin
   _mhits            := 14000;
   _renergy          := 1200;
   _r                := 35;
   _speed            := 12;
   _srange           := 300;
   _ucl              := 10;
   _painc            := 8;
   _btime            := ptime4;
   _transportS       := 12;
   _ruid1            := UID_HPentagram;
   _attack           := true;
   _limituse         := ul10;
   _splashresist     := true;
   _ukmech           := true;
   _upgr_regen       := upgr_race_regen_bio[r_hell];
   _upgr_armor       := upgr_race_armor_bio[r_hell];
   _a_BonusRangeAntiUnit:=50;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fpsd6,MID_MChaingun,0,0,0,0,0,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_Light,3,dm_AntiLight);
end;
{
ul10 = 10000hp + 620dps
       15000hp + 310dps
}
UID_Cyberdemon :
begin
   _mhits            := 15000;
   _renergy          := 1200;
   _r                := 20;
   _speed            := 12;
   _srange           := 300;
   _ucl              := 11;
   _painc            := 10;
   _btime            := ptime4;
   _transportS       := 12;
   _ruid1            := UID_HPentagram;
   _attack           := true;
   _limituse         := ul10;
   _splashresist     := true;
   _ukmech           := true;
   _upgr_regen       := upgr_race_regen_bio[r_hell];
   _upgr_armor       := upgr_race_armor_bio[r_hell];
   _a_BonusRangeAntiBuilding:=50;
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_fps1   ,MID_HRocket,0,0,0,0,0,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_Building,0,dm_Cyber);
end;

UID_Phantom,
UID_LostSoul  :
begin
   _mhits            := 1000;
   _renergy          := 100;
   _r                := 10;
   _speed            := 24;
   _srange           := 200;
   _ucl              := 12;
   _painc            := 1;
   _btime            := ptimeh;
   _ukfly            := uf_fly;
   _attack           := true;
   _uklight          := true;
   _fastdeath_hits   := 1;
   if(i=UID_Phantom)then
   begin
   _ucl              := 13;
   _renergy          := 200;
   _btime            := ptimeh;
   _weapon(0,wpt_directdmgZ,aw_dmelee,0,BaseDamageh4,fr_fps1,0,0,0,0,upgr_hell_mattack,BaseDamageBonus1,wtrset_all        ,wpr_any,uids_all,[],0,0,wtp_distance,0,dm_Lost);
   end;
   _weapon(1,wpt_directdmg ,aw_dmelee,0,BaseDamageh4,fr_fps1,0,0,0,0,upgr_hell_mattack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_Bio     ,0,dm_Lost);
end;
UID_ZMedic:
begin
   _mhits            := 500;
   _renergy          := 400;
   _r                := 10;
   _speed            := 12;
   _srange           := 200;
   _ucl              := 14;
   _painc            := 1;
   _btime            := ptime1;
   _attack           := true;
   _uklight          := true;
   _fastdeath_hits   := fdead_hits_border;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1,MID_Bullet,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_UnitBioLight,0,dm_AntiUnitBioLight);
end;
UID_ZEngineer:
begin
   _mhits            := 1000;
   _renergy          := 600;
   _r                := 10;
   _speed            := 14;
   _srange           := 200;
   _ucl              := 15;
   _painc            := 4;
   _transportS       := 2;
   _btime            := ptime1h;
   _attack           := true;
   _uklight          := false;
   _death_missile    := MID_Mine;
   _death_missile_dmod:=dm_Cyber;
   _ruid1            := UID_HBarracks;
   _ruid1n           := 4;
   _fastdeath_hits   := 1;
   _weapon(0,wpt_suicide,aw_dmelee,0,0,fr_fps1,0,0,0,0,0,0,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_distance,0,0);
end;
UID_ZSergant :
begin
   _mhits            := 750;
   _renergy          := 200;
   _r                := 10;
   _speed            := 12;
   _srange           := 200;
   _ucl              := 16;
   _painc            := 2;
   _btime            := ptime1-ptime1h;
   _attack           := true;
   _uklight          := true;
   _fastdeath_hits   := fdead_hits_border;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1,MID_SShot,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_UnitBioHeavy,0,dm_AntiUnitBioHeavy);
end;
UID_ZSSergant:
begin
   _mhits            := 750;
   _renergy          := 200;
   _r                := 10;
   _speed            := 10;
   _srange           := 200;
   _ucl              := 17;
   _painc            := 2;
   _btime            := ptime1;
   _limituse         := ul1h;
   _attack           := true;
   _uklight          := false;
   _fastdeath_hits   := fdead_hits_border;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1d2,MID_SSShot,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_UnitBioHeavy,0,dm_SSGShot);
end;
UID_ZCommando:
begin
   _mhits            := 750;
   _renergy          := 200;
   _r                := 10;
   _speed            := 10;
   _srange           := 200;
   _ucl              := 18;
   _painc            := 2;
   _btime            := ptime1-ptime1h;
   _attack           := true;
   _uklight          := false;
   _fastdeath_hits   := fdead_hits_border;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fpsd6,MID_Chaingun,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_UnitBioLight,6,dm_AntiUnitBioLight);
end;
UID_ZAntiaircrafter:
begin
   _mhits            := 750;
   _renergy          := 200;
   _r                := 10;
   _speed            := 8;
   _srange           := 200;
   _ucl              := 19;
   _painc            := 2;
   _btime            := ptime1-ptime1h;
   _attack           := true;
   _uklight          := true;
   _fastdeath_hits   := fdead_hits_border;
   _a_BonusRangeAntiFly:=50;
   _weapon(0,wpt_missle,aw_srange,rocket_sr,0 ,fr_fps1,MID_URocket,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,-4,wtp_Fly,0,dm_AntiFly);
end;
UID_ZSiegeMarine:
begin
   _mhits            := 750;
   _renergy          := 200;
   _r                := 10;
   _speed            := 8;
   _srange           := 200;
   _ucl              := 20;
   _painc            := 4;
   _btime            := ptime1;
   _attack           := true;
   _uklight          := true;
   _fastdeath_hits   := fdead_hits_border;
   _a_BonusRangeAntiBuilding:=50;
   _weapon(0,wpt_missle,aw_srange,rocket_sr,0 ,fr_fps1,MID_Granade,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,wtp_building,0,dm_Siege);
end;
UID_ZFPlasmagunner:
begin
   _mhits            := 750;
   _renergy          := 250;
   _r                := 10;
   _speed            := 14;
   _srange           := 200;
   _ucl              := 21;
   _painc            := 5;
   _btime            := ptime1;
   _attack           := true;
   _limituse         := ul1h;
   _uklight          := false;
   _ukfly            := true;
   _ruid1            := UID_HMonastery;
   _fastdeath_hits   := 1;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsd4,MID_BPlasma,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all,[],0,0,wtp_UnitMech,2,dm_AntiUnitMech);
end;
UID_ZBFGMarine:
begin
   _mhits            := 750;
   _renergy          := 600;
   _r                := 12;
   _speed            := 6;
   _srange           := 250;
   _ucl              := 22;
   _painc            := 5;
   _btime            := ptime2;
   _attack           := true;
   _uklight          := false;
   _transportS       := 2;
   _limituse         := ul3;
   _ruid1            := UID_HPentagram;
   _fastdeath_hits   := fdead_hits_border;
   _a_BonusRangeAntiUnit:=50;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps2,MID_BFG,0,0,0,0,0,wtrset_enemy_alive,wpr_any,uids_all,[fr_fps1],0,0,wtp_limit,0,wtp_limitaround);
end;

//         UAC BUILDINGS   /////////////////////////////////////////////////////
UID_HCommandCenter,
UID_UCommandCenter:
begin
   _mhits            := 15000;
   _renergy          := 800;
   _genergy          := 250;
   _speed            := 0;
   _r                := 66;
   _srange           := 275;
   _ucl              := 0;
   _btime            := ptime4;
   _attack           := true;
   //_ability          := ua_CCFly;
   _ukbuilding       := true;
   _isbuilder        := true;
   _slowturn         := false;
   _upgr_srange_step := 50;

   if(i=UID_HCommandCenter)then
   begin
      _ucl           := 3;
      _transportM    := 30;
      ups_builder    :=[UID_HCommandCenter,UID_HSymbol,UID_HTower,UID_HEye,UID_HBarracks];
      ups_transport  := uids_demons;
      _upgr_srange   := upgr_hell_buildr;
      _rebuild_uid   := UID_HCommandCenter;
      _weapon(0,wpt_missle,_srange,_r,0,fr_fps1,MID_Imp,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any+wpr_move,uids_all-[UID_Imp],[],3,-65,wtp_UnitBioHeavy,0,dm_AntiUnitBioHeavy);
   end
   else
   begin
      _ability_rupgr := upgr_uac_CCFly;
      _zombie_uid    := UID_HCommandCenter;
      ups_builder    :=[UID_UCommandCenter..UID_UComputerStation];
      _upgr_srange   := upgr_uac_buildr;
      _rebuild_uid   := UID_UCommandCenter;
      _weapon(0,wpt_missle,_srange,_r,0 ,fr_fps1,MID_BPlasma,0,upgr_uac_ccturr,1,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any+wpr_move,uids_all,[],3,-65,wtp_UnitMech,0,dm_AntiUnitMech);
   end;
end;

UID_HBarracks,
UID_UBarracks:
begin
   _mhits            := 10000;
   _renergy          := 300;
   _r                := 60;
   _ucl              := 1;
   _btime            := ptime2;
   _ukbuilding       := true;
   _isbarrack        := true;
   _rebuild_uid      := i;
   _rebuild_level    := 1;

   if(i=UID_HBarracks)then
   begin
      _ucl           := 4;
      ups_units      := uids_zimbas+[UID_LostSoul,UID_Phantom];
      _rebuild_ruid  := UID_HFortress;
   end
   else
   begin
      ups_units      := uids_marines;
      _zombie_uid    := UID_HBarracks;
      _rebuild_ruid  := UID_UComputerStation;
   end;
end;
UID_UFactory:
begin
   _mhits            := 10000;
   _renergy          := 300;
   _r                := 60;
   _ucl              := 4;
   _btime            := ptime2;
   _ukbuilding       := true;
   _isbarrack        := true;
   _ruid1            := UID_UWeaponFactory;
   _rebuild_uid      := i;
   _rebuild_level    := 1;
   _rebuild_ruid     := UID_UComputerStation;

   ups_units:=[UID_UTransport,UID_UACDron,UID_Terminator,UID_Tank,UID_Flyer];
end;

UID_UGenerator:
begin
   _mhits            := 2000;
   _genergy          := 100;
   _renergy          := 100;
   _r                := 48;
   _ucl              := 2;
   _btime            := ptime1hh;
   _ukbuilding       := true;
   _limituse         := ul3;
   _rebuild_uid      := UID_UGenerator;
end;

UID_UWeaponFactory:
begin
   _mhits            := 10000;
   _renergy          := 300;
   _r                := 62;
   _ucl              := 5;
   _btime            := ptime2;
   _ukbuilding       := true;
   _issmith          := true;

   ups_upgrades      := [];

   _rebuild_uid      := i;
   _rebuild_level    := 1;
   _rebuild_ruid     := UID_UComputerStation;
end;

UID_UTechCenter :
begin
   _mhits            := 15000;
   _renergy          := 1200;
   _r                := 86;
   _ucl              := 9;
   _btime            := ptime4;
   _ukbuilding       := true;
   _ruid1            := UID_UWeaponFactory;
end;
UID_UComputerStation:
begin
   _mhits            := 15000;
   _renergy          := 1200;
   _r                := 70;
   _ucl              := 10;
   _btime            := ptime4;
   _ukbuilding       := true;
   _ruid1            := UID_UWeaponFactory;
end;

UID_URadar:
begin
   _mhits            := 3000;
   _renergy          := 400;
   _r                := 35;
   _srange           := 300;
   _ucl              := 12;
   _btime            := ptime2;
   _limituse         := ul2;
   //_ability          := ua_UACScan;
   _ukbuilding       := true;
   _detector         := true;
   _upgr_srange      := upgr_uac_radar_r;
   _upgr_srange_step := 25;
   _ruid1            := UID_UWeaponFactory;   // need new tech building
end;
UID_URMStation:
begin
   _mhits            := 3000;
   _renergy          := 600;
   _r                := 40;
   _ucl              := 14;
   _btime            := ptime3;
   _limituse         := ul2;
   _ruid1            := UID_UComputerStation;
   //_ability          := ua_UACStrike;
   //_ability_rupgr    := upgr_uac_rstrike;
   _ukbuilding       := true;
end;

UID_UGTurret:
begin
   _mhits            := 5000;
   _renergy          := 300;
   _r                := 15;
   _srange           := 300;
   _ucl              := 6;
   _btime            := ptime1;
   _attack           := true;
   _ukbuilding       := true;
   _upgr_armor       := upgr_uac_turarm;
   _uklight          := true;
   _upgr_srange      := upgr_uac_towers;
   _upgr_srange_step := 25;
   _rebuild_uid      := UID_UATurret;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsd6,MID_BPlasma ,0,upgr_uac_plasmt,1,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground_mech,wpr_any,uids_all,[],0,-11,wtp_hits        ,2,dm_AntiUnitMech  );
   _weapon(1,wpt_missle,aw_srange,0,0 ,fr_fpsd6,MID_Chaingun,0,0              ,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground     ,wpr_any,uids_all,[],0,-11,wtp_UnitBioLight,2,dm_AntiUnitBioLight);
end;
UID_UATurret:
begin
   _mhits             := 5000;
   _renergy           := 300;
   _r                 := 15;
   _srange            := 300;
   _ucl               := 7;
   _btime             := ptime1;
   _attack            := true;
   _ukbuilding        := true;
   _uklight           := true;
   _upgr_armor        := upgr_uac_turarm;
   _rebuild_uid       := UID_UGTurret;
   _upgr_srange       := upgr_uac_towers;
   _upgr_srange_step  := 25;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsd3,MID_URocket ,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_fly,wpr_any ,uids_all,[],0,-14,wtp_nolost_hits,0,dm_AntiFly);
end;

///////////////////////////////////
UID_Sergant:
begin
   _mhits             := 1000;
   _renergy           := 200;
   _r                 := 10;
   _speed             := 15;
   _srange            := 175;
   _ucl               := 0;
   _btime             := ptime1;
   _attack            := true;
   _zombie_uid        := UID_ZSergant;
   _uklight           := true;
   _fastdeath_hits    := fdead_hits_border;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1,MID_SShot ,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_UnitBioHeavy,0,dm_AntiUnitBioHeavy);
end;
UID_SSergant:
begin
   _mhits             := 1000;
   _renergy           := 300;
   _r                 := 10;
   _speed             := 15;
   _srange            := 175;
   _ucl               := 1;
   _btime             := ptime1;
   _attack            := true;
   _zombie_uid        := UID_ZSSergant;
   _uklight           := false;
   _limituse          := ul1h;
   _fastdeath_hits    := fdead_hits_border;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1d2,MID_SSShot,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_UnitBioHeavy,0,dm_SSGShot);
end;
UID_Commando:
begin
   _mhits             := 1000;
   _renergy           := 200;
   _r                 := 10;
   _speed             := 12;
   _srange            := 200;
   _ucl               := 2;
   _btime             := ptime1;
   _attack            := true;
   _zombie_uid        := UID_ZCommando;
   _uklight           := true;
   _fastdeath_hits    := fdead_hits_border;
   _a_BonusRangeAntiFly:= -50;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fpsd6,MID_Chaingun,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all,[],0,0,wtp_UnitBioLight,6,dm_AntiUnitBioLight);
end;
UID_Antiaircrafter:
begin
   _mhits             := 1000;
   _renergy           := 200;
   _r                 := 10;
   _speed             := 12;
   _srange            := 200;
   _ucl               := 3;
   _btime             := ptime1;
   _attack            := true;
   _zombie_uid        := UID_ZAntiaircrafter;
   _uklight           := false;
   _fastdeath_hits    := fdead_hits_border;
   _a_BonusRangeAntiFly:=50;
   _weapon(0,wpt_missle,aw_srange,rocket_sr,0 ,fr_fps1,MID_URocket ,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_Fly ,0,dm_AntiFly);
end;
UID_SiegeMarine:
begin
   _mhits             := 1000;
   _renergy           := 200;
   _r                 := 12;
   _speed             := 10;
   _srange            := 200;
   _ucl               := 4;
   _btime             := ptime1;
   _attack            := true;
   _zombie_uid        := UID_ZSiegeMarine;
   _uklight           := false;
   _ruid1             := UID_UWeaponFactory;
   _fastdeath_hits    :=fdead_hits_border;
   _a_BonusRangeAntiBuilding:=50;
   _weapon(0,wpt_missle,aw_srange,rocket_sr,0 ,fr_fps1,MID_Granade,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,wtp_building,0,dm_Siege);
end;
UID_FPlasmagunner:
begin
   _mhits             := 1000;
   _renergy           := 300;
   _r                 := 10;
   _speed             := 15;
   _srange            := 200;
   _ucl               := 5;
   _btime             := ptime1h;
   _attack            := true;
   _zombie_uid        := UID_ZFPlasmagunner;
   _uklight           := false;
   _limituse          := ul1h;
   _ukfly             := true;
   _ruid1             := UID_UWeaponFactory;
   _fastdeath_hits    := 1;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fpsd4,MID_BPlasma,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all,[],0,0,wtp_UnitMech,2,dm_AntiUnitMech);
end;
UID_BFGMarine:
begin
   _mhits             := 1000;
   _renergy           := 800;
   _r                 := 12;
   _speed             := 10;
   _srange            := 250;
   _ucl               := 6;
   _transportS        := 2;
   _btime             := ptime3;
   _attack            := true;
   _zombie_uid        := UID_ZBFGMarine;
   _uklight           := false;
   _limituse          := ul3;
   _ruid1             := UID_UTechCenter;
   _fastdeath_hits    := fdead_hits_border;
   _a_BonusRangeAntiUnit:=50;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fps2,MID_BFG,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[fr_fps1],0,0,wtp_limit,0,wtp_limitaround);
end;
UID_Engineer:
begin
   _mhits             := 1000;
   _renergy           := 400;
   _r                 := 10;
   _speed             := 15;
   _srange            := 150;
   _ucl               := 7;
   _btime             := ptime1h;
   _attack            := true;
   _zombie_uid        := UID_ZEngineer;
   _ability           := 0;
   _uklight           := true;
   _ruid1             := UID_UTechCenter;
   _fastdeath_hits    := fdead_hits_border;
   _weapon(0,wpt_heal  ,aw_hmelee,0,BaseRepair1,fr_fpsd2,0          ,0,0,0,upgr_uac_melee ,BaseRepairBonus1,wtrset_repair     ,wpr_any,uids_all,[],0,0 ,wtp_notme_hits,0,0);
   _weapon(1,wpt_missle,aw_srange,0,0          ,fr_fpsd2,MID_Bullet ,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,-4,wtp_hits      ,0,0);
end;
UID_Medic:
begin
   _mhits             := 1000;
   _renergy           := 200;
   _r                 := 10;
   _speed             := 15;
   _srange            := 200;
   _ucl               := 8;
   _btime             := ptime1;
   _attack            := true;
   _zombie_uid        := UID_ZMedic;
   _uklight           := true;
   _ruid1             := UID_UTechCenter;
   _fastdeath_hits    := fdead_hits_border;
   _weapon(0,wpt_heal  ,aw_hmelee,0,BaseHeal1,fr_fpsd2,0          ,0,0,0,upgr_uac_melee ,BaseHealBonus1  ,wtrset_heal              ,wpr_any,uids_all,[],0, 0,wtp_notme_hits,0,0);
   _weapon(1,wpt_missle,aw_srange,0,0        ,fr_fpsd2,MID_Bullet ,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,wtp_hits      ,0,0);
end;

UID_UACDron:
begin
   _mhits             := 2000;
   _renergy           := 400;
   _r                 := 15;
   _speed             := 14;
   _srange            := 275;
   _ucl               := 9;
   _btime             := ptime1;
   _transportS        := 3;
   _limituse          := ul2;
   _attack            := true;
   _ukmech            := true;
   _uklight           := true;
   //_ability           := ua_RebuildInPoint;
   _rebuild_uid       := UID_UGTurret;
   _rebuild_rupgr     := upgr_uac_botturret;
   _fastdeath_hits    := 1;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsd4,MID_BPlasma,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_UnitMech,2,dm_AntiUnitMech);
end;
UID_UTransport:
begin
   _mhits             := 2000;
   _renergy           := 400;
   _r                 := 33;
   _speed             := 18;
   _srange            := 200;
   _ucl               := 10;
   _btime             := ptime1h;
   _transportM        := 8;
   _transportS        := 8;
   _ukfly             := uf_fly;
   _ukmech            := true;
   _splashresist      := true;
   _slowturn          := true;
   _ruid1             := 0;        ////////////
   _fastdeath_hits    := 1;
   ups_transport      := uids_marines+[UID_UACDron,UID_Terminator,UID_Tank];
end;
UID_Terminator:
begin
   _mhits             := 2000;
   _renergy           := 500;
   _r                 := 16;
   _speed             := 12;
   _srange            := 300;
   _ucl               := 11;
   _btime             := ptime1h;
   _transportS        := 4;
   _limituse          := ul3;
   _attack            := true;
   _ukmech            := true;
   _splashresist      := true;
   _ruid1             := UID_UTechCenter;
   _fastdeath_hits    := 1;
   _uklight           := false;
   _a_BonusRangeAntiUnit:=25;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fpsd4,MID_SShot  ,0,0               ,0,upgr_uac_attack,BaseDamageBonus1 ,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_UnitBio    ,0,dm_AntiUnitBio);
   _weapon(1,wpt_missle,aw_srange,0,0,fr_fps1 ,MID_URocket,0,upgr_uac_lturret,1,upgr_uac_attack,BaseDamageBonus1 ,wtrset_enemy_alive_fly   ,wpr_any,uids_all,[],0,0,wtp_nolost_hits,0,dm_AntiFly    );
end;
UID_Tank:
begin
   _mhits             := 6000;
   _renergy           := 600;
   _r                 := 20;
   _speed             := 8;
   _srange            := 275;
   _ucl               := 12;
   _btime             := ptime2;
   _transportS        := 6;
   _limituse          := ul4;
   _attack            := true;
   _ukmech            := true;
   _splashresist      := true;
   _ruid1             := UID_UTechCenter;
   _fastdeath_hits    := 1;
   _a_BonusRangeAntiBuilding:=50;
   _weapon(0,wpt_missle,aw_srange,rocket_sr,2 ,fr_fps1,MID_Tank,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_building,0,dm_Siege);
end;
UID_Flyer:
begin
   _mhits             := 4000;
   _renergy           := 600;
   _r                 := 18;
   _speed             := 16;
   _srange            := 300;
   _ucl               := 13;
   _btime             := ptime2;
   _transportS        := 6;
   _ukfly             := uf_fly;
   _limituse          := ul4;
   _attack            := true;
   _ukmech            := true;
   _splashresist      := true;
   _ruid1             := UID_UTechCenter;
   _fastdeath_hits    := 1;
   _a_BonusRangeAntiUnit:=25;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsd2,MID_Flyer  ,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_hits,0,0);
end;

UID_UBaseMil:
begin
end;
UID_UBaseCom:
begin
end;
UID_UBaseGen:
begin
end;
UID_UBaseRef:
begin
end;
UID_UBaseNuc:
begin
end;
UID_UBaseLab:
begin
end;
UID_UCBuild:
begin
end;
UID_USPort:
begin
end;
UID_UPortal:
begin
end;
      end;

      _square:=round(pi*_r*_r);

      if(i in uids_hell)then _urace:=r_hell;
      if(i in uids_uac )then _urace:=r_uac;

      if(_urace=0)then _urace:=r_hell;

      if(_ruid1>0)and(_ruid1n=0)then _ruid1n:=1;
      if(_ruid2>0)and(_ruid2n=0)then _ruid2n:=1;
      if(_ruid3>0)and(_ruid3n=0)then _ruid3n:=1;
      if(_rupgr>0)and(_rupgrl=0)then _rupgrl:=1;
      if(_ability_rupgr>0)and(_ability_rupgrl=0)then _ability_rupgrl:=1;
      if(_rebuild_rupgr>0)and(_rebuild_rupgrl=0)then _rebuild_rupgrl:=1;

      if(_painc_upgr_step=0)
      then _painc_upgr_step:=(_painc div 2)+(_painc mod 2);

      _missile_r:=trunc(_r/1.4);
      if(_mhits<1)then _mhits:=1;
      _hmhits := _mhits div 2; if(_hmhits <1)then _hmhits :=1;
      _hhmhits:=_hmhits div 2; if(_hhmhits<1)then _hhmhits:=1;

      if(_issmith)and(ups_upgrades=[])then
       for u:=1 to 255 do
        with g_upids[u] do
         if(_up_time>0)and(_urace=_up_race)then ups_upgrades+=[u];

      _srange_min:=_r+_r+25;
      if(_ukbuilding)then
      begin
         _zombie_hits:=_mhits div 4;
         _ukmech     :=true;
         _srange:=max2i(_srange_min,_srange);
      end;

      if(_limituse>=MinUnitLimit)then
      begin
      _level_damage:=round(BaseDamageLevel1*_limituse/ul1);
      _level_armor :=round(BaseArmorLevel1 *_limituse/ul1);
      end;

      if(_base_armor<0)then _base_armor:=0;

      _shcf:=_mhits/_mms;

      if(_btime> 0)then _bstep:=round((_mhits/2)/_btime);
      if(_bstep<=0)then _bstep:=1;
      _tprod:=_btime*fr_fps1;
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
      mid_teamdamage:= true;

// speed
case m of
MID_ArchFire,
MID_Mine           : mid_speed       :=32000;
MID_Tank           : mid_speed       :=100;
MID_MChaingun,
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
MID_YPlasma,
MID_BPlasma,
MID_Chaingun,
MID_Granade,
MID_Cacodemon,
MID_Tank,
MID_SShot          : mid_base_damage :=BaseDamage1;
MID_Baron,
MID_Revenant       : mid_base_damage :=BaseDamage1h;
MID_Flyer          : mid_base_damage :=BaseDamage2;
MID_SSShot,
MID_MChaingun      : mid_base_damage :=BaseDamage3;
MID_HRocket        : mid_base_damage :=BaseDamage5;
MID_BFG            : mid_base_damage :=BaseDamage6;
MID_ArchFire       : mid_base_damage :=BaseDamage8;
MID_Mine,
MID_Blizzard       : mid_base_damage :=BaseDamage10;
end;

// splash R
case m of
MID_URocketS,
MID_ArchFire       : mid_base_splashr:=tank_sr;
MID_HRocket        : mid_base_splashr:=rocket_sr;
MID_Mine           : mid_base_splashr:=mine_sr;
MID_BFG,
MID_Blizzard       : mid_base_splashr:=blizzard_sr;
end;

// homing
case m of
MID_Revenant,
MID_URocket,
MID_URocketS       : mid_homing      :=mh_homing;
MID_BFG            : mid_homing      :=mh_none;
else                 mid_homing      :=mh_magnetic;
end;

// nodamage uids
case m of
MID_Imp            : mid_nodamage    :=[UID_Imp        ];
MID_Cacodemon      : mid_nodamage    :=[UID_Cacodemon  ];
MID_Baron          : mid_nodamage    :=[UID_Knight,
                                        UID_Baron      ];
MID_Revenant       : mid_nodamage    :=[UID_Revenant   ];
MID_Mancubus       : mid_nodamage    :=[UID_Mancubus   ];
MID_YPlasma        : mid_nodamage    :=[UID_Arachnotron];
end;

// other
case m of
MID_Granade        : mid_ystep       :=3;
MID_Mine           : mid_size        :=25;
MID_URocketS,
MID_BFG            : begin
                     mid_teamdamage  :=false;
                     mid_noflycheck  :=true;
                     end;
MID_Blizzard       : mid_noflycheck  :=true;
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
   with g_dmods[dm][n] do
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
   FillChar(g_dmods,SizeOf(g_dmods),0);

   SetDMOD(dm_AntiUnitBioHeavy ,0,150,wtr_unit    +wtr_bio +wtr_heavy           );
   SetDMOD(dm_SSGShot          ,0,150,wtr_unit    +wtr_bio +wtr_heavy           );
   SetDMOD(dm_SSGShot          ,1, 50,             wtr_mech                     );
   SetDMOD(dm_AntiUnitBioLight ,0,150,wtr_unit    +wtr_bio +wtr_light           );
   SetDMOD(dm_AntiUnitBio      ,0,150,wtr_unit    +wtr_bio                      );
   SetDMOD(dm_AntiUnitBio      ,1, 50,wtr_building                              );
   SetDMOD(dm_AntiUnitMech     ,0,150,wtr_unit    +wtr_mech                     );
   SetDMOD(dm_AntiUnitLight    ,0,150,wtr_unit             +wtr_light           );
   SetDMOD(dm_AntiFly          ,0,150,                                wtr_fly   );
   SetDMOD(dm_AntiHeavy        ,0,150,                      wtr_heavy           );
   SetDMOD(dm_AntiLight        ,0,150,                      wtr_light           );
   SetDMOD(dm_AntiBuildingLight,0,150,wtr_building+         wtr_light           );
   SetDMOD(dm_Cyber            ,0,300,wtr_building                              );
   SetDMOD(dm_Cyber            ,1, 50,wtr_unit+             wtr_light           );
   SetDMOD(dm_Siege            ,0,300,wtr_building                              );
   SetDMOD(dm_Blizzard         ,0,500,wtr_building                              );
   SetDMOD(dm_Blizzard         ,1, 50,wtr_unit+             wtr_light           );
   SetDMOD(dm_Lost             ,0, 50,             wtr_mech                     );
end;

procedure InitUpgrades;
var u:byte;
procedure setUPGR(rc,upcl,stime,stimeX,stimeA,max,enrg,enrgX,enrgA:integer;rupgr,ruid1,ruid2,ruid3:byte;mfrg:boolean);
begin
   with g_upids[upcl] do
   begin
      _up_ruid1     := ruid1;
      _up_ruid2     := ruid2;
      _up_ruid3     := ruid3;
      _up_rupgr     := rupgr;
      _up_race      := rc;
      _up_time      := stime*fr_fps1;
      _up_time_xpl  := stimeX;
      _up_time_apl  := stimeA*fr_fps1;
      _up_renerg    := enrg;
      _up_renerg_xpl:= enrgX;
      _up_renerg_apl:= enrgA;
      _up_max       := max;
      _up_mfrg      := mfrg;
      _up_btni      := u;
      u+=1;
   end;
end;
begin
   FillChar(g_upids,SizeOf(g_upids),0);

   //                                  base X +
   //         race id                  time      lvl  enr  X +    rupgr         ruid1                    multi
   u:=0;
   setUPGR(r_hell,upgr_hell_t1attack  ,60 ,0,45,5   ,600 ,0,600 ,0            ,0                   ,0,0,false);
   setUPGR(r_hell,upgr_hell_uarmor    ,60 ,0,45,5   ,600 ,0,600 ,0            ,0                   ,0,0,false);
   setUPGR(r_hell,upgr_hell_barmor    ,60 ,0,40,5   ,600 ,0,300 ,0            ,0                   ,0,0,false);
   setUPGR(r_hell,upgr_hell_mattack   ,60 ,0,40,5   ,600 ,0,300 ,0            ,0                   ,0,0,false);
   setUPGR(r_hell,upgr_hell_regen     ,60 ,0,30,2   ,300 ,0,300 ,0            ,0                   ,0,0,false);
   setUPGR(r_hell,upgr_hell_pains     ,60 ,0,0 ,2   ,600 ,0,0   ,0            ,0                   ,0,0,false);
   setUPGR(r_hell,upgr_hell_buildr    ,60 ,0,15,2   ,600 ,0,0   ,0            ,0                   ,0,0,false);
   setUPGR(r_hell,upgr_hell_HKTeleport,120,0,0 ,1   ,300 ,0,0   ,0            ,0                   ,0,0,false);
   setUPGR(r_hell,upgr_hell_spectre   ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HPentagram      ,0,0,false);

   setUPGR(r_hell,upgr_hell_vision    ,60 ,0,30,2   ,600 ,0,300 ,0            ,UID_HPentagram      ,0,0,false);
   setUPGR(r_hell,upgr_hell_phantoms  ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HPentagram      ,0,0,false);
   setUPGR(r_hell,upgr_hell_t2attack  ,60 ,0,45,5   ,600 ,0,600 ,0            ,UID_HPentagram      ,0,0,false);
   setUPGR(r_hell,upgr_hell_resurrect ,90 ,0,0 ,1   ,900 ,0,0   ,0            ,UID_HPentagram      ,0,0,false);
   setUPGR(r_hell,upgr_hell_paina     ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HFortress       ,0,0,false);
   setUPGR(r_hell,upgr_hell_towers    ,60 ,0,15,2   ,600 ,0,300 ,0            ,UID_HFortress       ,0,0,false);
   setUPGR(r_hell,upgr_hell_teleport  ,60 ,0,30,2   ,300 ,0,300 ,0            ,UID_HFortress       ,0,0,false);
   setUPGR(r_hell,upgr_hell_rteleport ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HFortress       ,0,0,false);
   setUPGR(r_hell,upgr_hell_heye      ,60 ,0,0 ,3   ,300 ,0,300 ,0            ,UID_HFortress       ,0,0,false);
   setUPGR(r_hell,upgr_hell_totminv   ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HFortress       ,0,0,false);
   setUPGR(r_hell,upgr_hell_bldrep    ,60 ,0,0 ,5   ,600 ,0,300 ,0            ,UID_HFortress       ,0,0,false);
   setUPGR(r_hell,upgr_hell_tblink    ,30 ,0,0 ,15  ,200 ,0,0   ,0            ,UID_HFortress       ,0,0,true );
   setUPGR(r_hell,upgr_hell_invuln    ,180,0,0 ,2   ,1200,0,0   ,0            ,UID_HAltar          ,0,0,true );    //


   u:=0;
   setUPGR(r_uac ,upgr_uac_attack     ,60 ,0,45,5   ,600 ,0,600 ,0            ,0                   ,0,0,false);
   setUPGR(r_uac ,upgr_uac_uarmor     ,60 ,0,45,5   ,600 ,0,600 ,0            ,0                   ,0,0,false);
   setUPGR(r_uac ,upgr_uac_barmor     ,60 ,0,45,5   ,600 ,0,600 ,0            ,0                   ,0,0,false);
   setUPGR(r_uac ,upgr_uac_melee      ,60 ,0,45,2   ,600 ,0,300 ,0            ,0                   ,0,0,false);
   setUPGR(r_uac ,upgr_uac_mspeed     ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,0                   ,0,0,false);
   setUPGR(r_uac ,upgr_uac_ssgup      ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,0                   ,0,0,false);
   setUPGR(r_uac ,upgr_uac_buildr     ,60 ,0,15,2   ,600 ,0,0   ,0            ,0                   ,0,0,false);
   setUPGR(r_uac ,upgr_uac_CCFly      ,120,0,0 ,1   ,600 ,0,0   ,0            ,0                   ,0,0,false);
   setUPGR(r_uac ,upgr_uac_botturret  ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter     ,0,0,false);

   setUPGR(r_uac ,upgr_uac_vision     ,60 ,0,30,2   ,600 ,0,300 ,0            ,UID_UTechCenter     ,0,0,false);
   setUPGR(r_uac ,upgr_uac_commando   ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter     ,0,0,false);
   setUPGR(r_uac ,upgr_uac_airsp      ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter     ,0,0,false);
   setUPGR(r_uac ,upgr_uac_mechspd    ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter     ,0,0,false);
   setUPGR(r_uac ,upgr_uac_mecharm    ,60 ,0,45,5   ,600 ,0,600 ,0            ,UID_UTechCenter     ,0,0,false);
   setUPGR(r_uac ,upgr_uac_lturret    ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter     ,0,0,false);
   setUPGR(r_uac ,upgr_uac_transport  ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter     ,0,0,false);
   setUPGR(r_uac ,upgr_uac_ccturr     ,120,0,0 ,1   ,600 ,0,0   ,0            ,UID_UComputerStation,0,0,false);
   setUPGR(r_uac ,upgr_uac_towers     ,60 ,0,15,2   ,600 ,0,300 ,0            ,UID_UComputerStation,0,0,false);
   setUPGR(r_uac ,upgr_uac_radar_r    ,60 ,0,0 ,3   ,300 ,0,300 ,0            ,UID_UComputerStation,0,0,false);
   setUPGR(r_uac ,upgr_uac_plasmt     ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UComputerStation,0,0,false);
   setUPGR(r_uac ,upgr_uac_turarm     ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UComputerStation,0,0,false);
   setUPGR(r_uac ,upgr_uac_rstrike    ,180,0,0 ,2   ,1200,0,0   ,0            ,UID_URMStation      ,0,0,true );
end;

{
ua_type    : TUnitAbilityType;       // 0-passive, 1-no target, 2-need to go point and self cast, 3-point/unit target require
ua_morphUID,   // if >0 then ability - transformation to uid
ua_rupgr,
ua_rupgrl,
ua_ruid    : byte;
}

procedure InitUAbilities;
var a:byte;
begin
   for a:=0 to 255 do
   with g_uability[a] do
   begin
      ua_type:=uat_passive;

      case a of
ua_amove,
ua_move,
ua_apatrol,
ua_patrol,
ua_unloadto
           : ua_type:=uat_point;
ua_astay,
ua_stay,
ua_destroy,
ua_unload,
ua_Upgrade
           : ua_type:=uat_notarget;
      end;

   end;

  {
  ua_amove               = 0;
  ua_move                = 1;
  ua_apatrol             = 2;
  ua_patrol              = 3;
  ua_astay               = 4;
  ua_stay                = 5;
  ua_destroy             = 6;

  ua_unload              = 10;
  ua_unloadto            = 11;

  ua_Upgrade             = 15;

  ua_HKeepPainAura       = 16;
  ua_HKeepBlink          = 17;
  ua_HR2Totem        = 18;
  ua_HR2Tower        = 19;
  ua_HShortBlink         = 20;
  ua_HTeleport           = 21;
  ua_HRecall             = 22;
  ua_HellVision          = 23;
  ua_HSphereArmor        = 24;
  ua_HSphereDamage       = 25;
  ua_HSphereHaste        = 26;

  ua_HSpawnLost          = 27;
  ua_HSpawnLostTo        = 28;

  ua_UCCUp               = 30;
  ua_UCCLand             = 31;
  ua_UTurretG2A          = 32;
  ua_UTurretA2G          = 33;
  ua_UTurret2Drone       = 34;
  ua_UScan               = 35;
  ua_UStrike             = 36;
  ua_USphereSoul         = 37;
  ua_USphereInvis        = 38;
  ua_USphereInvuln       = 39;
  }
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
   wtrset_heal                           :=wtr_owner_p+wtr_owner_a            +wtr_hits_h                      +wtr_bio+         wtr_unit+             wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_repair                         :=wtr_owner_p+wtr_owner_a            +wtr_hits_h                              +wtr_mech+wtr_unit+wtr_building+wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_resurect                       :=wtr_owner_p+wtr_owner_a                       +wtr_hits_d           +wtr_bio+wtr_mech+wtr_unit+wtr_building+wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+wtr_heavy+wtr_stun+wtr_nostun;

   InitUpgrades;
   InitUIDS;
   InitUAbilities;
   InitMIDs;
   InitDMODs;
end;
