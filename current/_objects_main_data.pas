
{$IFDEF _FULLGAME}
function _unit_CalcShadowZ(pu:PTUnit):integer;
begin
   with pu^  do
    with uid^ do
     if(_ukbuilding=false)
     then _unit_CalcShadowZ:=fly_height[ukfly]
     else
       if(speed<=0)or(iscomplete=false)
       then _unit_CalcShadowZ:=-fly_hz   // no shadow
       else _unit_CalcShadowZ:=0;
end;

procedure _unit_CalcForR(pu:PTUnit);
begin
   with pu^ do fsr:=mm3(1,srange div fog_cw,MFogM);
end;
{$ENDIF}

procedure _unit_apUID(pu:PTUnit);
begin
   with pu^ do
   begin
      uid:=@_uids[uidi];
      with uid^ do
      begin
         isbuildarea:=_isbuilder;
         srange     :=_r+_r; //_srange;
         speed      :=_speed;
         ukfly      :=_ukfly;
         transportM :=_transportM;
         pains      :=_painc;
         solid      :=_issolid;

         if(_ukbuilding)and(_isbarrack)then
         begin
            uo_x:=x;
            uo_y:=y+_r;
         end;

         {$IFDEF _FULLGAME}
         mmr   := trunc(_r*map_mmcx)+1;
         animw := _animw;
         shadow:= _unit_CalcShadowZ(pu);

         _unit_CalcForR(pu);
         {$ENDIF}
         hits:=_mhits;
      end;
   end;
end;

procedure InitUIDS;
var i,u:byte;

procedure _weapon(aa,wtype:byte;max_range,min_range,count:integer;reload,oid,ruid,rupid,rupidl,dupgr:byte;dupgrs:integer;tarf,reqf:cardinal;uids,reload_s:TSoB;ax,ay:integer;atarprior:byte;afakeshots:byte;admod:byte);
begin
   with _uids[i] do
   if(aa<=MaxUnitWeapons)then
   with _a_weap[aa] do
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
   FillChar(_uids   ,SizeOf(_uids   ),0);

   for i:=0 to 255 do
   with _uids[i] do
   begin
      _mhits     := 1000;
      _btime     := 1;
      _ukfly     := uf_ground;
      _ucl       := 255;
      _transportS:= 1;
      _urace     := r_hell;
      _attack    := atm_none;
      _fastdeath_hits:=-32000;
      _limituse  := MinUnitLimit;

      _ukbuilding:= false;
      _ukmech    := false;
      _uklight   := false;

      _detector  := false;

      _isbuilder := false;
      _issmith   := false;
      _isbarrack := false;
      _issolid   := true;
      _slowturn  := false;

      case i of
//         HELL BUILDINGS   ////////////////////////////////////////////////////
UID_HKeep,
UID_HAKeep:
begin
   _mhits     := 17500;
   _renergy   := 900;
   _r         := 66;
   _srange    := 250;
   _ucl       := 0;
   _btime     := ptime3;
   _ukbuilding:= true;
   _isbuilder := true;
   _baseregen := BaseArmorBonus1;
   ups_builder:= [UID_HKeep..UID_HFortress]-[UID_HSymbol2,UID_HAKeep,UID_HTotem];
   _upgr_srange     :=upgr_hell_buildr;
   _upgr_srange_step:=50;
   _ability         :=uab_HKeepBlink;
   _ability_rupgr   :=upgr_hell_HKTeleport;
   if(i=UID_HAKeep)then
   begin
      _genergy := 900;
      _renergy := 300;
      _btime   := _btime+(_btime div 2);
   end
   else
   begin
      _genergy    := 300;
      _rebuild_uid:= UID_HAKeep;
   end;
end;

UID_HGate:
begin
   _mhits     := 12500;
   _renergy   := 300;
   _r         := 60;
   _ucl       := 1;
   _btime     := ptime2;
   _barrack_teleport:=true;
   _ukbuilding:= true;
   _isbarrack := true;
   _baseregen := BaseArmorBonus1;
   ups_units  := [UID_Imp..UID_Archvile];
   _rebuild_uid  := i;
   _rebuild_ruid := UID_HFortress;
end;

UID_HSymbol1,
UID_HSymbol2,
UID_HSymbol3,
UID_HSymbol4:
begin
   _mhits     := 1000;
   _genergy   := 50;
   _renergy   := 50;
   _r         := 22;  //1520
   _ucl       := 2;
   _btime     := ptime1;
   _ukbuilding:= true;
   _uklight   := true;

   case i of
UID_HSymbol1: _rebuild_uid:=UID_HSymbol2;
UID_HSymbol2: begin
              _btime  := _btime+(_btime div 4);
              _genergy*= 2;
              _renergy:= 0;
              _rebuild_uid:=UID_HSymbol3;
              end;
UID_HSymbol3: begin
              _btime  := _btime+(_btime div 4);
              _genergy*= 3;
              _renergy:= 0;
              _rebuild_uid:=UID_HSymbol4;
              end;
UID_HSymbol4: begin
              _btime  := _btime+(_btime div 4);
              _genergy*= 4;
              _renergy:= 0;
              end;
   end;
end;

UID_HPools:
begin
   _mhits     := 12500;
   _renergy   := 300;
   _r         := 53;
   _ucl       := 5;
   _btime     := ptime2;
   _ukbuilding:= true;
   _issmith   := true;
   _baseregen := BaseArmorBonus1;
   ups_upgrades := [];
   _rebuild_uid  := i;
   _rebuild_ruid := UID_HFortress;
end;

UID_HPentagram:
begin
   _mhits     := 17500;
   _renergy   := 1200;
   _r         := 65;
   _ucl       := 9;
   _btime     := ptime5;
   _ukbuilding:= true;
   _baseregen := BaseArmorBonus1;
   _issolid   := false;
   _ruid1     := UID_HPools;
end;
UID_HMonastery:
begin
   _mhits     := 17500;
   _renergy   := 1200;
   _r         := 65;
   _ucl       := 10;
   _btime     := ptime5;
   _ukbuilding:= true;
   _baseregen := BaseArmorBonus1;
   _ruid1     := UID_HPools;
end;
UID_HFortress:
begin
   _mhits     := 17500;
   _renergy   := 1200;
   _r         := 86;
   _ucl       := 11;
   _btime     := ptime5;
   _ukbuilding:= true;
   _baseregen := BaseArmorBonus1;
   _ruid1     := UID_HPools;
end;

UID_HTeleport:
begin
   _mhits     := 5000;
   _renergy   := 400;
   _r         := 28;
   _srange    := 100;
   _ucl       := 13;
   _btime     := ptime2;
   _limituse  := ul4;
   _ability   := uab_Teleport;
   _ukbuilding:= true;
   _baseregen := BaseArmorBonus1;
   _issolid   := false;
   _ruid1     := UID_HAKeep;
end;
UID_HAltar:
begin
   _mhits     := 12500;
   _renergy   := 800;
   _r         := 50;
   _ucl       := 14;
   _limituse  := ul10;
   _btime     := ptime6;
   _ruid1     := UID_HPentagram;
   _ruid2     := UID_HMonastery;
   _ruid3     := UID_HFortress;
   _baseregen := BaseArmorBonus1;
   _ukbuilding:= true;
   _ability      := uab_HInvulnerability;
end;

UID_HTower:
begin
   _mhits     := 6000;
   _renergy   := 200;
   _r         := 20;
   _srange    := 300;
   _ucl       := 6;
   _btime     := ptime1hh;
   _attack    := atm_always;
   _ability   := uab_HTowerBlink;
   _ability_rupgr:=upgr_hell_tblink;
   _ukbuilding:= true;
   _uklight   := true;
   _upgr_srange     :=upgr_hell_towers;
   _upgr_srange_step:=25;
   _rebuild_uid :=UID_HTotem;
   _rebuild_ruid:=UID_HFortress;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsd3,MID_Imp,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all-[UID_Imp],[],0,-26,wtp_UnitBioHeavy,0,dm_AntiUnitBioHeavy2);
end;
UID_HTotem:
begin
   _mhits     := 3000;
   _renergy   := 400;
   _r         := 20;
   _srange    := 300;
   _ucl       := 7;
   _btime     := ptime2;
   _ruid1     := UID_HFortress;
   _attack    := atm_always;
   _ability   := uab_HTowerBlink;
   _ability_rupgr :=upgr_hell_tblink;
   _ukbuilding:= true;
   _uklight   := true;
   _upgr_srange     :=upgr_hell_towers;
   _upgr_srange_step:=25;
   _rebuild_uid :=UID_HTower;
   _weapon(0,wpt_missle,aw_fsr+50,0,0,fr_fps2,MID_ArchFire,0,0,0,0,0,wtrset_enemy_alive_units,wpr_any+wpr_avis,uids_all,[fr_archvile_s],0,0,wtp_max_hits,0,0);
end;
UID_HEye:
begin
   _mhits     := 100;
   _renergy   := 50;
   _r         := 10;
   _srange    := 300;
   _ucl       := 12;
   _btime     := ptime1;
   _ability   := uab_HellVision;
   _ukbuilding:= true;
   _issolid   := false;
   _uklight   := true;
   _detector  := true;
   _upgr_srange     :=upgr_hell_heye;
   _upgr_srange_step:=50;

   ups_builder:=[UID_HEye];
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
   _mhits     := 750;
   _renergy   := 200;
   _r         := 11;
   _speed     := 10;
   _srange    := 200;
   _ucl       := 0;
   _painc     := 2;
   _btime     := ptime1mh;
   _attack    := atm_always;
   _uklight   := true;
   _fastdeath_hits:=fdead_hits_border;
   _a_BonusAntiFlyRange:=-50;
   _weapon(0,wpt_missle   ,aw_srange,0,0          ,fr_fps1,MID_Imp,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive       ,wpr_any,uids_all-[UID_Imp],[],0,-5,wtp_UnitBioHeavy,0,dm_AntiUnitBioHeavy2);
   _weapon(1,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fps1,0      ,0,0,0,upgr_hell_mattack ,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Imp],[],0, 0,wtp_distance    ,0,0);
end;
UID_Demon     :
begin
   _mhits     := 1500;
   _renergy   := 300;
   _r         := 14;
   _speed     := 20;
   _srange    := 200;
   _ucl       := 1;
   _transportS:= 2;
   _painc     := 8;
   _btime     := ptime1;
   //_limituse  := ul1h;
   //_ruid1     := UID_HPools;
   _attack    := atm_always;
   _weapon(0,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fps2d3,0,0,0,0,upgr_hell_mattack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any ,uids_all,[],0,0,wtp_distance,0,dm_AntiUnitHeavy2);
end;
UID_Cacodemon :
begin
   _mhits     := 2000;
   _renergy   := 250;
   _r         := 14;
   _speed     := 10;
   _srange    := 200;
   _ucl       := 2;
   _painc     := 8;
   _btime     := ptime1hh;
   _transportS:= 2;
   _limituse  := ul1h;
   _ukfly     := uf_fly;
   _ruid1     := UID_HPools;
   _ruid2     := UID_HAKeep;
   _attack    := atm_always;
   _zfall     := fly_height[uf_fly];
   _a_BonusAntiFlyRange:=50;
   _weapon(0,wpt_missle   ,aw_srange ,0,0          ,fr_fps1   ,MID_Cacodemon,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive      ,wpr_any,uids_all-[UID_Cacodemon],[],0,0,wtp_UnitMech,0,dm_AntiUnitMech2);
   _weapon(1,wpt_directdmg,aw_dmelee ,0,BaseDamage1,fr_fps1   ,0            ,0,0,0,upgr_hell_mattack ,BaseDamageBonus1,wtrset_enemy_alive_fly  ,wpr_any,         [UID_Cacodemon],[],0,0,wtp_distance ,0,0);
end;
{
2 2000 2
2 2500 1.5
2 3000 1
}
UID_Knight    :
begin
   _mhits     := 2500;
   _renergy   := 300;
   _r         := 14;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 3;
   _painc     := 10;
   _btime     := ptime1h;
   _transportS:= 3;
   _limituse  := ul2;
   _attack    := atm_always;
   _uklight   := true;
   _ruid1     := UID_HPools;
   _weapon(0,wpt_missle   ,aw_srange,0,0          ,fr_fps1  ,MID_Baron,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all-[UID_Knight,UID_Baron],[],0,0,wtp_UnitLight,0,dm_AntiUnitLight2);
   _weapon(1,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fps1  ,0        ,0,0,0,upgr_hell_mattack ,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Knight,UID_Baron],[],0,0,wtp_distance ,0,0);
end;
{
3 3000 3
3 4000 2
3 4500 1.5
}
UID_Baron     :
begin
   _mhits     := 4500;
   _renergy   := 500;
   _r         := 14;
   _speed     := 10;
   _srange    := 275;
   _ucl       := 4;
   _painc     := 10;
   _btime     := ptime1h;
   _transportS:= 3;
   _limituse  := ul3;
   _attack    := atm_always;
   _uklight   := false;
   _ruid1     := UID_HPools;
   _weapon(0,wpt_missle   ,aw_srange,0,0          ,fr_fps1   ,MID_Baron,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all-[UID_Knight,UID_Baron],[],0,0,wtp_UnitLight,0,dm_AntiUnitLight2);
   _weapon(1,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fps1   ,0        ,0,0,0,upgr_hell_mattack ,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Knight,UID_Baron],[],0,0,wtp_distance ,0,0);
end;
{
ul10 = 10000hp + 620dps
       15000hp + 310dps
}
UID_Mastermind :
begin
   _mhits     := 15000;
   _renergy   := 1200;
   _r         := 35;
   _speed     := 12;
   _srange    := 300;
   _ucl       := 5;
   _painc     := 10;
   _btime     := ptime4;
   _transportS:= 12;
   _ruid1     := UID_HPentagram;
   _attack    := atm_always;
   _limituse  := ul10;
   _splashresist:=true;
   _ukmech    := true;
   _upgr_regen:= upgr_race_regen_bio[r_hell];
   _upgr_armor:= upgr_race_armor_bio[r_hell];
   _a_BonusAntiUnitRange:=50;
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_fpsd6,MID_SChaingun,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_Light,2,dm_AntiLight2);
end;
{
12000  18000  19000
x12    x6     x5

10000  15000
x10    x5
}
UID_Cyberdemon :
begin
   _mhits     := 15000;
   _renergy   := 1200;
   _r         := 20;
   _speed     := 12;
   _srange    := 275;
   _ucl       := 6;
   _painc     := 10;
   _btime     := ptime4;
   _transportS:= 12;
   _ruid1     := UID_HPentagram;
   _attack    := atm_always;
   _limituse  := ul10;
   _splashresist:=true;
   _ukmech    := true;
   _upgr_regen:= upgr_race_regen_bio[r_hell];
   _upgr_armor:= upgr_race_armor_bio[r_hell];
   _a_BonusAntiBuildingRange:=50;
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_fps1   ,MID_HRocket,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_Building,0,dm_Siege3);
end;
UID_Pain      :
begin
   _mhits     := 1500;
   _renergy   := 500;
   _r         := 15;
   _speed     := 7;
   _srange    := 225;
   _ucl       := 7;
   _painc     := 3;
   _btime     := ptime2;
   _transportS:= 2;
   _ruid1     := UID_HMonastery;
   _ruid2     := UID_HAKeep;
   _limituse  := ul1;
   _ukfly     := uf_fly;
   _attack    := atm_always;
   _ability   := uab_SpawnLost;
   _death_uid := UID_LostSoul;
   _death_uidn:= 3;
   _weapon(0,wpt_unit,aw_fsr+50,0,0 ,fr_fps2,UID_Phantom ,0,upgr_hell_phantoms,1,0,0,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_distance,0,0);
   _weapon(1,wpt_unit,aw_fsr+50,0,0 ,fr_fps2,UID_LostSoul,0,0                 ,0,0,0,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_distance,0,0);

   _fastdeath_hits:=1;
end;
UID_Revenant   :
begin
   _mhits     := 1500;
   _renergy   := 300;
   _r         := 13;
   _speed     := 14;
   _srange    := 225;
   _ucl       := 8;
   _painc     := 5;
   _transportS:= 2;
   _btime     := ptime1;
   _ruid1     := UID_HMonastery;
   _limituse  := ul1h;
   _attack    := atm_always;
   _uklight   := false;
   _a_BonusAntiFlyRange:=100;
   _weapon(0,wpt_missle   ,aw_srange ,0,0          ,fr_fps1,MID_Revenant ,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive       ,wpr_any,uids_all-[UID_Revenant],[],0,-7,wtp_Fly     ,0,dm_AntiFly2);
   _weapon(1,wpt_directdmg,aw_dmelee ,0,BaseDamage1,fr_fps1,0            ,0,0,0,upgr_hell_mattack ,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Revenant],[],0, 0,wtp_distance,0,0);
end;
{
2.4 lim 2400hp 149 dps
3   lim 3600hp 149 dps
}
UID_Mancubus  :
begin
   _mhits     := 4000;
   _renergy   := 500;
   _r         := 20;
   _speed     := 8;
   _srange    := 275;
   _ucl       := 9;
   _transportS:= 4;
   _painc     := 7;
   _btime     := ptime1h;
   _ruid1     := UID_HMonastery;
   _limituse  := ul3;
   _attack    := atm_always;
   _a_BonusAntiBuildingRange:=50;
   _weapon(0,wpt_missle,aw_srange,0,-9,fr_mancubus_rld,MID_Mancubus,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all-[UID_Mancubus],[fr_mancubus_rld_s1,fr_mancubus_rld_s2,fr_mancubus_rld_s3],0,0,wtp_building,0,dm_Siege4);
end;
UID_Arachnotron:
begin
   _mhits     := 3000;
   _renergy   := 500;
   _r         := 20;
   _speed     := 11;
   _srange    := 275;
   _ucl       := 10;
   _painc     := 7;
   _transportS:= 4;
   _btime     := ptime1h;
   _ruid1     := UID_HMonastery;
   _limituse  := ul3;
   _attack    := atm_always;
   _ukmech    := true;
   _upgr_regen:= upgr_race_regen_bio[r_hell];
   _upgr_armor:= upgr_race_armor_bio[r_hell];
   _a_BonusAntiUnitRange:=50;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsd3,MID_YPlasma,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all-[UID_Arachnotron],[],0,0,wtp_UnitMech,2,dm_AntiUnitMech2);
end;
UID_Archvile:
begin
   _mhits     := 4000;
   _renergy   := 700;
   _r         := 14;
   _speed     := 16;
   _srange    := 300;
   _ucl       := 11;
   _painc     := 7;
   _btime     := ptime1h;
   _transportS:= 4;
   _ruid1     := UID_HMonastery;
   _limituse  := ul4;
   _attack    := atm_always;
   _weapon(0,wpt_resurect,aw_dmelee ,0,3  ,fr_fpsd2,0           ,0,upgr_hell_resurrect,1,0,0,wtrset_resurect         ,wpr_any           ,uids_arch_res,[             ],0,0,wtp_distance,0,0);
   _weapon(1,wpt_missle  ,aw_fsr+100,0,0  ,fr_fps2 ,MID_ArchFire,0,0                  ,0,0,0,wtrset_enemy_alive_units,wpr_any+wpr_avis  ,uids_all     ,[fr_archvile_s],0,0,wtp_max_hits,0,0);
end;

UID_Phantom,
UID_LostSoul  :
begin
   _mhits     := 1000;
   _renergy   := 100;
   _r         := 10;
   _speed     := 24;
   _srange    := 175;
   _ucl       := 12;
   _painc     := 1;
   _btime     := ptimeh;
   _ukfly     := uf_fly;
   _attack    := atm_always;
   _uklight   := true;
   _fastdeath_hits:=1;
   if(i=UID_Phantom)then
   begin
   _ucl       :=13;
   _renergy   :=200;
   _btime     :=ptime1;
   _weapon(0,wpt_directdmgZ,aw_dmelee,0,BaseDamageh4,fr_fps1,0,0,0,0,upgr_hell_mattack,BaseDamageBonus1,wtrset_all        ,wpr_any,uids_all,[],0,0,wtp_distance,0,dm_Lost);
   end;
   _weapon(1,wpt_directdmg ,aw_dmelee,0,BaseDamageh4,fr_fps1,0,0,0,0,upgr_hell_mattack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_Bio     ,0,dm_Lost);
end;
UID_ZMedic:
begin
   _mhits     := 500;
   _renergy   := 200;
   _r         := 11;
   _speed     := 14;
   _srange    := 175;
   _ucl       := 14;
   _painc     := 1;
   _btime     := ptime1;
   _attack    := atm_always;
   _uklight   := true;
   _fastdeath_hits:=fdead_hits_border;
   _weapon(0,wpt_heal  ,aw_hmelee,0,BaseHeal1,fr_fpsd2  ,0,0,0,0,0,0                              ,wtrset_healu      ,wpr_any,uids_demons,[],0,0,wtp_notme_hits  ,0,0);
   _weapon(1,wpt_missle,aw_srange,0,0,fr_fps1,MID_Bullet,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all   ,[],0,0,wtp_UnitBioLight,0,0);
end;
UID_ZEngineer:
begin
   _mhits     := 1000;
   _renergy   := 600;
   _r         := 11;
   _speed     := 15;
   _srange    := 175;
   _ucl       := 15;
   _painc     := 2;
   _transportS:= 2;
   _btime     := ptime1h;
   _attack    := atm_always;
   _uklight   := true;
   _death_missile     :=MID_Mine;
   _death_missile_dmod:=dm_Siege3;
   _ruid1     := UID_HBarracks;
   _ruid1n    := 4;
   _fastdeath_hits:=1;
   _weapon(0,wpt_suicide,aw_dmelee,0,0,fr_fps1,0,0,0,0,0,0,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_distance,0,0);
end;
UID_ZSergant :
begin
   _mhits     := 750;
   _renergy   := 200;
   _r         := 11;
   _speed     := 14;
   _srange    := 175;
   _ucl       := 16;
   _painc     := 2;
   _btime     := ptime1mh;
   _attack    := atm_always;
   _uklight   := true;
   _ruid1     := UID_HBarracks;
   _ruid1n    := 3;
   _fastdeath_hits:=fdead_hits_border;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1,MID_SShot,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_UnitBioHeavy,0,dm_AntiUnitBioHeavy2);
end;
UID_ZSSergant:
begin
   _mhits     := 750;
   _renergy   := 250;
   _r         := 11;
   _speed     := 14;
   _srange    := 175;
   _ucl       := 17;
   _painc     := 2;
   _btime     := ptime1;
   _attack    := atm_always;
   _uklight   := false;
   _ruid1     := UID_HBarracks;
   _ruid1n    := 3;
   _fastdeath_hits:=fdead_hits_border;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1d2,MID_SSShot,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_UnitBioHeavy,0,dm_SSGShot2);
end;
UID_ZCommando:
begin
   _mhits     := 750;
   _renergy   := 200;
   _r         := 11;
   _speed     := 10;
   _srange    := 175;
   _ucl       := 18;
   _painc     := 4;
   _btime     := ptime1mh;
   _attack    := atm_always;
   _uklight   := false;
   _ruid1     := UID_HBarracks;
   _ruid1n    := 3;
   _fastdeath_hits:=fdead_hits_border;
   _a_BonusAntiFlyRange:=-50;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fpsd6,MID_Chaingun,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_UnitBioLight,6,dm_AntiUnitBioLight2);
end;
UID_ZAntiaircrafter:
begin
   _mhits     := 750;
   _renergy   := 200;
   _r         := 11;
   _speed     := 8;
   _srange    := 175;
   _ucl       := 19;
   _painc     := 4;
   _btime     := ptime1mh;
   _attack    := atm_always;
   _uklight   := true;
   _ruid1     := UID_HBarracks;
   _ruid1n    := 3;
   _fastdeath_hits:=fdead_hits_border;
   _a_BonusAntiFlyRange:=75;
   _weapon(0,wpt_missle,aw_srange,rocket_sr,0 ,fr_fps1,MID_URocket,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,-4,wtp_Fly,0,dm_AntiFly2);
end;
UID_ZSiegeMarine:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 11;
   _speed     := 8;
   _srange    := 175;
   _ucl       := 20;
   _painc     := 5;
   _btime     := ptime1;
   _attack    := atm_always;
   _uklight   := true;
   _ruid1     := UID_HBarracks;
   _ruid1n    := 3;
   _fastdeath_hits:=fdead_hits_border;
   //_a_BonusAntiBuildingRange:=50;
   _weapon(0,wpt_missle,aw_srange,rocket_sr,0 ,fr_fps1,MID_Granade,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,wtp_building,0,dm_Siege4);
end;
UID_ZFPlasmagunner:
begin
   _mhits     := 750;
   _renergy   := 250;
   _r         := 11;
   _speed     := 14;
   _srange    := 200;
   _ucl       := 21;
   _painc     := 5;
   _btime     := ptime1;
   _attack    := atm_always;
   _limituse  := ul1h;
   _uklight   := true;
   _ukfly     := true;
   _ruid1     := UID_HBarracks;
   _ruid1n    := 3;
   _ruid2     := UID_HACommandCenter;
   _fastdeath_hits:=1;
   _a_BonusAntiFlyRange:=50;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsd4,MID_BPlasma,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all,[],0,0,wtp_UnitMech,2,dm_AntiUnitMech2);
end;
UID_ZBFGMarine:
begin
   _mhits     := 1000;
   _renergy   := 600;
   _r         := 11;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 22;
   _painc     := 5;
   _btime     := ptime3;
   _attack    := atm_always;
   _uklight   := false;
   _transportS:= 2;
   _ruid1     := UID_HBarracks;
   _ruid1n    := 4;
   _ruid2     := UID_HACommandCenter;
   _ruid2n    := 2;
   _limituse  := ul5;
   _fastdeath_hits:=fdead_hits_border;
   _a_BonusAntiUnitRange:=50;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps2,MID_BFG,0,0,0,0,0,wtrset_enemy_alive,wpr_any,uids_all,[fr_fps1],0,0,wtp_limitaround,0,dm_BFG);
end;

//         UAC BUILDINGS   /////////////////////////////////////////////////////
UID_HCommandCenter,
UID_HACommandCenter,
UID_UCommandCenter,
UID_UACommandCenter:
begin
   _mhits     := 15000;
   _renergy   := 900;
   _speed     := 0;
   _r         := 66;
   _srange    := 250;
   _ucl       := 0;
   _btime     := ptime3;
   _attack    := atm_always;
   _ability   := uab_CCFly;
   _ukbuilding:= true;
   _isbuilder := true;
   _slowturn  := false;
   _upgr_srange_step:= 50;

   if(i=UID_HCommandCenter )
   or(i=UID_HACommandCenter)then
   begin
      _ucl             := 3;
      ups_builder      :=[UID_HCommandCenter,UID_HSymbol1,UID_HTower,UID_HEye,UID_HBarracks]-[UID_HACommandCenter];
      ups_transport    :=uids_demons;

      _upgr_srange     :=upgr_hell_buildr;
      _weapon(0,wpt_missle,_srange,_r,0,fr_fps1,MID_Imp,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any+wpr_move,uids_all-[UID_Imp],[],3,-65,wtp_UnitBioHeavy,0,dm_AntiUnitBioHeavy2);

      if(i=UID_HACommandCenter)then
      begin
         _genergy := 900;
         _renergy := 300;
         _btime   := _btime+(_btime div 2);
      end
      else
      begin
         _genergy    := 300;
         _rebuild_uid:= UID_HACommandCenter;
      end;
   end
   else
   begin
      _ability_rupgr   := upgr_uac_CCFly;
      if(i=UID_UCommandCenter)
      then _zombie_uid := UID_HCommandCenter
      else _zombie_uid := UID_HACommandCenter;
      ups_builder      :=[UID_UCommandCenter..UID_UComputerStation]-[UID_UGenerator2,UID_UACommandCenter];
      _upgr_srange     := upgr_uac_buildr;
      _weapon(0,wpt_missle,_srange,_r,0 ,fr_fps1,MID_BPlasma,0,upgr_uac_ccturr,1,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any+wpr_move,uids_all,[],3,-65,wtp_UnitMech,0,dm_AntiUnitMech2);

      if(i=UID_UACommandCenter)then
      begin
         _genergy := 900;
         _renergy := 300;
         _btime   := _btime+(_btime div 2);
      end
      else
      begin
         _genergy    := 300;
         _rebuild_uid:= UID_UACommandCenter;
      end;
   end;
end;

UID_HBarracks,
UID_UBarracks:
begin
   _mhits     := 10000;
   _renergy   := 300;
   _r         := 60;
   _ucl       := 1;
   _btime     := ptime2;
   _ukbuilding:= true;
   _isbarrack := true;
   _rebuild_uid  := i;

   if(i=UID_HBarracks)then
   begin
      _ucl         := 4;
      ups_units    := uids_zimbas+[UID_LostSoul,UID_Phantom];
      _rebuild_ruid:= UID_HACommandCenter;
   end
   else
   begin
      ups_units    := uids_marines;
      _zombie_uid  := UID_HBarracks;
      _rebuild_ruid:= UID_UComputerStation;
   end;
end;
UID_UFactory:
begin
   _mhits     := 10000;
   _renergy   := 300;
   _r         := 60;
   _ucl       := 4;
   _btime     := ptime2;
   _ukbuilding:= true;
   _isbarrack := true;
   _ruid1     := UID_UWeaponFactory;
   _rebuild_uid  := i;
   _rebuild_ruid := UID_UComputerStation;

   ups_units:=[UID_APC,UID_UTransport,UID_UACDron,UID_Terminator,UID_Tank,UID_Flyer];
end;

UID_UGenerator1,
UID_UGenerator2,
UID_UGenerator3,
UID_UGenerator4:
begin
   _mhits     := 2000;
   _genergy   := 100;
   _renergy   := 100;
   _r         := 44;
   _ucl       := 2;
   _btime     := ptime1;
   _ukbuilding:= true;
   _limituse  := ul2;
   case i of
UID_UGenerator1: _rebuild_uid:=UID_UGenerator2;
UID_UGenerator2: begin
                 _btime  := _btime+(_btime div 4);
                 _genergy*= 2;
                 _renergy:= 0;
                 _rebuild_uid:=UID_UGenerator3;
                 end;
UID_UGenerator3: begin
                 _btime  := _btime+(_btime div 4);
                 _genergy*= 3;
                 _renergy:= 0;
                 _rebuild_uid:=UID_UGenerator4;
                 end;
UID_UGenerator4: begin
                 _btime  := _btime+(_btime div 4);
                 _genergy*= 4;
                 _renergy:= 0;
                 end;
   end;
end;

UID_UWeaponFactory:
begin
   _mhits     := 10000;
   _renergy   := 300;
   _r         := 62;
   _ucl       := 5;
   _btime     := ptime2;
   _ukbuilding:= true;
   _issmith   := true;

   ups_upgrades := [];

   _rebuild_uid  := i;
   _rebuild_ruid := UID_UComputerStation;
end;

UID_UTechCenter :
begin
   _mhits     := 15000;
   _renergy   := 1200;
   _r         := 86;
   _ucl       := 10;
   _btime     := ptime5;
   _ukbuilding:= true;
   _ruid1     := UID_UWeaponFactory;
end;
UID_UComputerStation:
begin
   _mhits     := 15000;
   _renergy   := 1200;
   _r         := 70;
   _ucl       := 11;
   _btime     := ptime5;
   _ukbuilding:= true;
   _ruid1     := UID_UWeaponFactory;
end;

UID_URadar:
begin
   _mhits     := 3000;
   _renergy   := 200;
   _r         := 35;
   _srange    := 300;
   _ucl       := 12;
   _btime     := ptime2;
   _limituse  := ul2;
   _ability   := uab_UACScan;
   _ukbuilding:= true;
   _detector  := true;
   _upgr_srange     :=upgr_uac_radar_r;
   _upgr_srange_step:=25;
   _ruid1     := UID_UWeaponFactory;
end;
UID_URMStation:
begin
   _mhits     := 10000;
   _renergy   := 800;
   _r         := 40;
   _ucl       := 14;
   _btime     := ptime6;
   _limituse  := ul10;
   _ruid1     := UID_UTechCenter;
   _ruid2     := UID_UComputerStation;
   _ability   := uab_UACStrike;
   _ukbuilding:= true;
end;

UID_UGTurret:
begin
   _mhits     := 6000;
   _renergy   := 200;
   _r         := 15;
   _srange    := 300;
   _ucl       := 6;
   _btime     := ptime1hh;
   _attack    := atm_always;
   _ukbuilding:= true;
   _upgr_armor:= upgr_uac_turarm;
   _uklight   := true;
   _ability      := uab_ToUACDron;
   _ability_rupgr:= upgr_uac_botturret;
   _upgr_srange     := upgr_uac_towers;
   _upgr_srange_step:= 25;
   _rebuild_uid     := UID_UATurret;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsd6,MID_BPlasma ,0,upgr_uac_plasmt,1,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground_mech,wpr_any,uids_all,[],0,-11,wtp_hits        ,2,dm_AntiUnitMech2  );
   _weapon(1,wpt_missle,aw_srange,0,0 ,fr_fpsd6,MID_Chaingun,0,0              ,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground     ,wpr_any,uids_all,[],0,-11,wtp_UnitBioLight,2,dm_AntiUnitBioLight2);
end;
UID_UATurret:
begin
   _mhits     := 6000;
   _renergy   := 200;
   _r         := 15;
   _srange    := 300;
   _ucl       := 7;
   _btime     := ptime1hh;
   _attack    := atm_always;
   _ukbuilding:= true;
   _uklight   := true;
   _upgr_armor:= upgr_uac_turarm;
   _ability      := uab_ToUACDron;
   _ability_rupgr:= upgr_uac_botturret;
   _rebuild_uid     := UID_UGTurret;
   _upgr_srange     :=upgr_uac_towers;
   _upgr_srange_step:=25;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsd3,MID_URocket ,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_fly,wpr_any ,uids_all,[],0,-14,wtp_nolost_hits,0,dm_AntiFly2);
end;

UID_UMine:
begin
   _mhits     := 100;
   _renergy   := 10;
   _r         := 5;
   _srange    := 100;
   _ucl       := 21;
   _btime     := 2;
   _ucl       := 21;
   _attack    := atm_always;
   _ukbuilding:= true;
   _uklight   := true;
   _detector  := true;
   _issolid   := false;
   _death_missile:=MID_Mine;
   _fastdeath_hits:=1;

   _weapon(0,wpt_suicide,-mine_r,0,0,fr_fps1,0,0,0,0,0,0,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_distance,0,0);
end;

///////////////////////////////////
UID_Sergant:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 11;
   _speed     := 14;
   _srange    := 175;
   _ucl       := 0;
   _btime     := ptime1;
   _attack    := atm_always;
   _zombie_uid:= UID_ZSergant;
   _uklight   := true;
   _fastdeath_hits:=fdead_hits_border;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1,MID_SShot ,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_UnitBioHeavy,0,dm_AntiUnitBioHeavy2);
end;
UID_SSergant:
begin
   _mhits     := 1000;
   _renergy   := 300;
   _r         := 11;
   _speed     := 14;
   _srange    := 175;
   _ucl       := 1;
   _btime     := ptime1;
   _attack    := atm_always;
   _zombie_uid:= UID_ZSSergant;
   _uklight   := false;
   _limituse  := ul1h;
   _fastdeath_hits:=fdead_hits_border;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1d2,MID_SSShot,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_UnitBioHeavy,0,dm_SSGShot2);
end;
UID_Commando:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 11;
   _speed     := 12;
   _srange    := 175;
   _ucl       := 2;
   _btime     := ptime1;
   _attack    := atm_always;
   _zombie_uid:= UID_ZCommando;
   _uklight   := true;
   _ruid1     := UID_UWeaponFactory;
   _fastdeath_hits:=fdead_hits_border;
   _a_BonusAntiFlyRange:=-50;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fpsd6,MID_Chaingun,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all,[],0,0,wtp_UnitBioLight,6,dm_AntiUnitBioLight2);
end;
UID_Antiaircrafter:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 11;
   _speed     := 12;
   _srange    := 175;
   _ucl       := 3;
   _btime     := ptime1;
   _attack    := atm_always;
   _zombie_uid:= UID_ZAntiaircrafter;
   _uklight   := false;
   _ruid1     := UID_UWeaponFactory;
   _fastdeath_hits:=fdead_hits_border;
   _a_BonusAntiFlyRange:=75;
   _weapon(0,wpt_missle,aw_srange,rocket_sr,0 ,fr_fps1,MID_URocket ,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_Fly ,0,dm_AntiFly2);
end;
UID_SiegeMarine:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 11;
   _speed     := 10;
   _srange    := 175;
   _ucl       := 4;
   _btime     := ptime1;
   _attack    := atm_always;
   _zombie_uid:= UID_ZSiegeMarine;
   _uklight   := false;
   _ruid1     := UID_UWeaponFactory;
   _fastdeath_hits:=fdead_hits_border;
   //_a_BonusAntiBuildingRange:=50;
   _weapon(0,wpt_missle,aw_srange,rocket_sr,0 ,fr_fps1,MID_Granade,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,wtp_building,0,dm_Siege4);
end;
UID_FPlasmagunner:
begin
   _mhits     := 1000;
   _renergy   := 250;
   _r         := 11;
   _speed     := 14;
   _srange    := 200;
   _ucl       := 5;
   _btime     := ptime1hh;
   _attack    := atm_always;
   _zombie_uid:= UID_ZFPlasmagunner;
   _uklight   := false;
   _limituse  := ul1h;
   _ukfly     := true;
   _ruid1     := UID_UWeaponFactory;
   _ruid2     := UID_UACommandCenter;
   _fastdeath_hits:=1;
   _a_BonusAntiFlyRange:=50;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fpsd4,MID_BPlasma,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all,[],0,0,wtp_UnitMech,2,dm_AntiUnitMech2);
end;
UID_BFGMarine:
begin
   _mhits     := 1000;
   _renergy   := 600;
   _r         := 11;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 6;
   _transportS:= 2;
   _btime     := ptime3;
   _attack    := atm_always;
   _zombie_uid:= UID_ZBFGMarine;
   _uklight   := false;
   _limituse  := ul5;
   _ruid1     := UID_UTechCenter;
   _ruid2     := UID_UComputerStation;
   _fastdeath_hits:=fdead_hits_border;
   _a_BonusAntiUnitRange:=50;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fps2,MID_BFG,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[fr_fps1],0,0,wtp_limitaround,0,dm_BFG);
end;
UID_Engineer:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 11;
   _speed     := 12;
   _srange    := 175;
   _ucl       := 7;
   _btime     := ptime1hh;
   _attack    := atm_always;
   _zombie_uid:= UID_ZEngineer;
   _ability   := 0;
   _uklight   := true;
   _ruid1     := UID_UWeaponFactory;
   _ruid2     := UID_UACommandCenter;
   _fastdeath_hits:=fdead_hits_border;
   _weapon(0,wpt_heal  ,aw_hmelee,0,BaseRepair1,fr_fpsd2,0          ,0,0,0,upgr_uac_melee ,BaseRepairBonus1,wtrset_repair     ,wpr_any,uids_all,[],0,0 ,wtp_notme_hits,0,0);
   _weapon(1,wpt_missle,aw_srange,0,0          ,fr_fpsd2,MID_Bullet ,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,-4,wtp_hits      ,0,0);
end;
UID_Medic:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 11;
   _speed     := 12;
   _srange    := 175;
   _ucl       := 8;
   _btime     := ptime1hh;
   _attack    := atm_always;
   _zombie_uid:= UID_ZMedic;
   _uklight   := true;
   _ruid1     := UID_UWeaponFactory;
   _ruid2     := UID_UACommandCenter;
   _fastdeath_hits:=fdead_hits_border;
   _weapon(0,wpt_heal  ,aw_hmelee,0,BaseHeal1,fr_fpsd2,0          ,0,0,0,upgr_uac_melee ,BaseHealBonus1  ,wtrset_heal              ,wpr_any,uids_all,[],0, 0,wtp_notme_hits,0,0);
   _weapon(1,wpt_missle,aw_srange,0,0        ,fr_fpsd2,MID_Bullet ,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,wtp_hits      ,0,0);
end;
UID_UACDron:
begin
   _mhits     := 2000;
   _renergy   := 400;
   _r         := 15;
   _speed     := 14;
   _srange    := 250;
   _ucl       := 9;
   _btime     := ptime1;
   _transportS:= 3;
   _limituse  := ul2;
   _attack    := atm_always;
   _ukmech    := true;
   _uklight   := true;
   _ability   := uab_RebuildInPoint;
   _rebuild_uid   :=UID_UGTurret;
   _rebuild_rupgr :=upgr_uac_botturret;
   _fastdeath_hits:=1;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsd4,MID_BPlasma,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_UnitMech,2,dm_AntiUnitMech2);
end;
UID_UTransport:
begin
   _mhits     := 2000;
   _renergy   := 200;
   _r         := 33;
   _speed     := 18;
   _srange    := 200;
   _ucl       := 10;
   _btime     := ptime1;
   _transportM:= 8;
   _transportS:= 8;
   _ukfly     := uf_fly;
   _attack    := atm_none;
   _ukmech    := true;
   _splashresist:=true;
   _ruid1     := UID_UACommandCenter;
   _fastdeath_hits:=1;
   ups_transport:=uids_marines+[UID_APC,UID_UACDron,UID_Terminator,UID_Tank];
end;
UID_Terminator:
begin
   _mhits     := 2000;
   _renergy   := 500;
   _r         := 16;
   _speed     := 12;
   _srange    := 275;
   _ucl       := 11;
   _btime     := ptime1h;
   _transportS:= 4;
   _limituse  := ul3;
   _attack    := atm_always;
   _ukmech    := true;
   _splashresist:=true;
   _ruid1     := UID_UTechCenter;
   _fastdeath_hits:=1;
   _uklight   := false;
   _a_BonusAntiFlyRange:=-50;
   _a_BonusAntiUnitRange:=50;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fpsd4,MID_SSShot ,0,0               ,0,upgr_uac_attack,BaseDamageBonus1 ,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_UnitBio    ,3,dm_AntiUnitBio2);
   _weapon(1,wpt_missle,aw_srange,0,0,fr_fps1 ,MID_URocket,0,upgr_uac_antiair,1,upgr_uac_attack,BaseDamageBonus1 ,wtrset_enemy_alive_fly   ,wpr_any,uids_all,[],0,0,wtp_nolost_hits,0,0    );
end;
UID_Tank:
begin
   _mhits     := 6000;
   _renergy   := 600;
   _r         := 20;
   _speed     := 8;
   _srange    := 275;
   _ucl       := 12;
   _btime     := ptime2;
   _transportS:= 6;
   _limituse  := ul4;
   _attack    := atm_always;
   _ukmech    := true;
   _splashresist:=true;
   _ruid1     := UID_UTechCenter;
   _fastdeath_hits:=1;
   _a_BonusAntiBuildingRange:=75;
   _weapon(0,wpt_missle,aw_srange,rocket_sr,2 ,fr_fps1,MID_Tank,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_building,0,dm_Siege4);
end;
UID_Flyer:
begin
   _mhits     := 4000;
   _renergy   := 600;
   _r         := 18;
   _speed     := 16;
   _srange    := 275;
   _ucl       := 13;
   _btime     := ptime2;
   _transportS:= 6;
   _ukfly     := uf_fly;
   _limituse  := ul4;
   _attack    := atm_always;
   _ukmech    := true;
   _splashresist:=true;
   _ruid1     := UID_UTechCenter;
   _ruid2     := UID_UACommandCenter;
   _fastdeath_hits:=1;
   _a_BonusAntiUnitRange:=25;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsd2,MID_Flyer  ,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_GroundLight,0,dm_AntiGroundLight2);
end;

UID_APC:
begin
   _mhits     := 3000;
   _renergy   := 200;
   _r         := 25;
   _speed     := 15;
   _srange    := 225;
   _ucl       := 14;
   _btime     := ptime2;
   _transportM:= 4;
   _transportS:= 10;
   _attack    := atm_bunker;
   _ukmech    := true;
   _slowturn  := true;
   _splashresist:=true;
   _fastdeath_hits:=1;
   ups_transport    :=uids_marines;
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

      if(_ability=0)and(_transportM>0)then _ability:=uab_Unload;

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
        with _upids[u] do
         if(_up_time>0)and(_urace=_up_race)then ups_upgrades+=[u];

      if(_ukbuilding)then
      begin
         _zombie_hits:=_mhits div 4;
         _ukmech     :=true;
         _srange:=max2(_r+_r,_srange);
      end;

      if(_limituse>=MinUnitLimit)then
      begin
      _level_damage:=round(BaseDamageLevel1*_limituse/ul1);
      _level_armor :=round(BaseArmorLevel1 *_limituse/ul1);
      end;

      _shcf:=_mhits/_mms;

      if(_btime> 0)then _bstep:=round((_mhits/2)/_btime);
      if(_bstep<=0)then _bstep:=1;
      _tprod:=_btime*fr_fps1;
   end;
end;

procedure InitMIDs;
var m:byte;
begin
   FillChar(_mids,SizeOf(_mids),0);

   for m:=0 to 255 do
   with _mids[m] do
   begin
      mid_size      := 0;
      mid_homing    := mh_magnetic;
      mid_teamdamage:= true;

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
MID_ArchFire       : mid_base_damage :=BaseDamage8;
MID_Mine           : mid_base_damage :=BaseDamage10;
MID_Blizzard       : mid_base_damage :=BaseDamage10*2;
end;

// splash R
case m of
MID_Blizzard       : mid_base_splashr:=blizzard_sr;
MID_Mine           : mid_base_splashr:=mine_sr;
MID_HRocket        : mid_base_splashr:=rocket_sr;
MID_URocketS,
MID_ArchFire,
MID_Tank           : mid_base_splashr:=tank_sr;
MID_BFG            : mid_base_splashr:=blizzard_sr;
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
MID_Imp            : mid_nodamage    :=[UID_Imp        ];
MID_Cacodemon      : mid_nodamage    :=[UID_Cacodemon  ];
MID_Baron          : mid_nodamage    :=[UID_Knight,
                                        UID_Baron      ];
MID_Revenant       : mid_nodamage    :=[UID_Revenant   ];
MID_Mancubus       : mid_nodamage    :=[UID_Mancubus   ];
MID_YPlasma        : mid_nodamage    :=[UID_Arachnotron];
MID_Mine           : mid_nodamage    :=[UID_UMine      ];
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
   with _dmods[dm][n] do
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
   FillChar(_dmods,SizeOf(_dmods),0);

   SetDMOD(dm_AntiUnitBioHeavy2,0,200,wtr_unit    +wtr_bio +wtr_heavy           );
   SetDMOD(dm_SSGShot2         ,0,200,wtr_unit    +wtr_bio +wtr_heavy           );
   SetDMOD(dm_SSGShot2         ,1, 50,             wtr_mech                     );
   SetDMOD(dm_AntiUnitBioLight2,0,200,wtr_unit    +wtr_bio +wtr_light           );
   SetDMOD(dm_AntiUnitBio2     ,0,200,wtr_unit    +wtr_bio                      );
   SetDMOD(dm_AntiUnitBio2     ,1, 50,             wtr_mech                     );
   SetDMOD(dm_AntiUnitMech2    ,0,200,wtr_unit    +wtr_mech                     );
   SetDMOD(dm_AntiUnitLight2   ,0,200,wtr_unit             +wtr_light           );
   SetDMOD(dm_AntiFly2         ,0,200,                                wtr_fly   );
   SetDMOD(dm_AntiUnitHeavy2   ,0,200,wtr_unit             +wtr_heavy           );
   SetDMOD(dm_AntiLight2       ,0,200,                      wtr_light           );
   SetDMOD(dm_AntiGroundLight2 ,0,200,                      wtr_light+wtr_ground);
   SetDMOD(dm_RSMShot          ,0,300,wtr_building                              );
   SetDMOD(dm_Siege3           ,0,300,wtr_building                              );
   SetDMOD(dm_Siege4           ,0,400,wtr_building                              );
   SetDMOD(dm_Lost             ,0, 50,             wtr_mech                     );
   SetDMOD(dm_BFG              ,0, 50,wtr_building                              );

end;

procedure InitUpgrades;
var u:byte;
procedure _setUPGR(rc,upcl,stime,stimeX,stimeA,max,enrg,enrgX,enrgA:integer;rupgr,ruid:byte;mfrg:boolean);
begin
   with _upids[upcl] do
   begin
      _up_ruid      := ruid;
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
   FillChar(_upids,SizeOf(_upids),0);

   //                                  base X +
   //         race id                  time      lvl  enr  X +    rupgr         ruid                 multi
   u:=0;
   _setUPGR(r_hell,upgr_hell_t1attack  ,60 ,0,45,5   ,600 ,0,600 ,0            ,0                   ,false);
   _setUPGR(r_hell,upgr_hell_uarmor    ,60 ,0,45,5   ,600 ,0,600 ,0            ,0                   ,false);
   _setUPGR(r_hell,upgr_hell_barmor    ,60 ,0,40,5   ,600 ,0,300 ,0            ,0                   ,false);
   _setUPGR(r_hell,upgr_hell_mattack   ,60 ,0,40,5   ,600 ,0,300 ,0            ,0                   ,false);
   _setUPGR(r_hell,upgr_hell_regen     ,60 ,0,30,2   ,300 ,0,300 ,0            ,0                   ,false);
   _setUPGR(r_hell,upgr_hell_pains     ,60 ,0,0 ,2   ,300 ,0,300 ,0            ,0                   ,false);
   _setUPGR(r_hell,upgr_hell_buildr    ,60 ,0,15,2   ,600 ,0,0   ,0            ,0                   ,false);
   _setUPGR(r_hell,upgr_hell_HKTeleport,60 ,0,0 ,1   ,300 ,0,0   ,0            ,0                   ,false);
   _setUPGR(r_hell,upgr_hell_paina     ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HAKeep          ,false);
   _setUPGR(r_hell,upgr_hell_towers    ,60 ,0,15,2   ,600 ,0,300 ,0            ,UID_HAKeep          ,false);

   _setUPGR(r_hell,upgr_hell_spectre   ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HAKeep          ,false);
   _setUPGR(r_hell,upgr_hell_vision    ,60 ,0,30,2   ,600 ,0,300 ,0            ,UID_HMonastery      ,false);
   _setUPGR(r_hell,upgr_hell_phantoms  ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HMonastery      ,false);
   _setUPGR(r_hell,upgr_hell_t2attack  ,60 ,0,45,5   ,600 ,0,600 ,0            ,UID_HMonastery      ,false);
   _setUPGR(r_hell,upgr_hell_resurrect ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HMonastery      ,false);
   _setUPGR(r_hell,upgr_hell_teleport  ,60 ,0,30,2   ,400 ,0,200 ,0            ,UID_HFortress       ,false);
   _setUPGR(r_hell,upgr_hell_rteleport ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HFortress       ,false);
   _setUPGR(r_hell,upgr_hell_heye      ,60 ,0,0 ,3   ,300 ,0,300 ,0            ,UID_HFortress       ,false);
   _setUPGR(r_hell,upgr_hell_totminv   ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HFortress       ,false);
   _setUPGR(r_hell,upgr_hell_bldrep    ,60 ,0,0 ,5   ,600 ,0,300 ,0            ,UID_HFortress       ,false);
   _setUPGR(r_hell,upgr_hell_tblink    ,30 ,0,0 ,15  ,200 ,0,0   ,0            ,UID_HFortress       ,true );


   u:=0;
   _setUPGR(r_uac ,upgr_uac_attack     ,60 ,0,45,5   ,600 ,0,600 ,0            ,0                   ,false);
   _setUPGR(r_uac ,upgr_uac_uarmor     ,60 ,0,45,5   ,600 ,0,600 ,0            ,0                   ,false);
   _setUPGR(r_uac ,upgr_uac_barmor     ,60 ,0,45,5   ,600 ,0,600 ,0            ,0                   ,false);
   _setUPGR(r_uac ,upgr_uac_melee      ,60 ,0,45,2   ,600 ,0,300 ,0            ,0                   ,false);
   _setUPGR(r_uac ,upgr_uac_mspeed     ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,0                   ,false);
   _setUPGR(r_uac ,upgr_uac_ssgup      ,60 ,0,0 ,1   ,300 ,0,0   ,0            ,0                   ,false);
   _setUPGR(r_uac ,upgr_uac_buildr     ,60 ,0,15,2   ,600 ,0,0   ,0            ,0                   ,false);
   _setUPGR(r_uac ,upgr_uac_CCFly      ,120,0,0 ,1   ,600 ,0,0   ,0            ,0                   ,false);
   _setUPGR(r_uac ,upgr_uac_ccturr     ,120,0,0 ,1   ,600 ,0,0   ,0            ,UID_UACommandCenter ,false);
   _setUPGR(r_uac ,upgr_uac_towers     ,60 ,0,15,2   ,600 ,0,300 ,0            ,UID_UACommandCenter ,false);

   _setUPGR(r_uac ,upgr_uac_botturret  ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UACommandCenter ,false);
   _setUPGR(r_uac ,upgr_uac_vision     ,60 ,0,30,2   ,600 ,0,300 ,0            ,UID_UTechCenter     ,false);
   _setUPGR(r_uac ,upgr_uac_commando   ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter     ,false);
   _setUPGR(r_uac ,upgr_uac_airsp      ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter     ,false);
   _setUPGR(r_uac ,upgr_uac_mechspd    ,60 ,0,15,2   ,600 ,0,300 ,0            ,UID_UTechCenter     ,false);
   _setUPGR(r_uac ,upgr_uac_mecharm    ,60 ,0,45,5   ,600 ,0,600 ,0            ,UID_UTechCenter     ,false);
   _setUPGR(r_uac ,upgr_uac_antiair    ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter     ,false);
   _setUPGR(r_uac ,upgr_uac_transport  ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter     ,false);
   _setUPGR(r_uac ,upgr_uac_radar_r    ,60 ,0,0 ,3   ,300 ,0,300 ,0            ,UID_UComputerStation,false);
   _setUPGR(r_uac ,upgr_uac_plasmt     ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UComputerStation,false);
   _setUPGR(r_uac ,upgr_uac_turarm     ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UComputerStation,false);
end;

procedure GameObjectsInit;
var u:integer;
begin
   for u:=0 to MaxUnits do _punits[u]:=@_units[u];

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
   wtrset_healu                          :=wtr_owner_p+wtr_owner_a            +wtr_hits_h                      +wtr_bio+wtr_mech+wtr_unit+             wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_repair                         :=wtr_owner_p+wtr_owner_a            +wtr_hits_h                              +wtr_mech+wtr_unit+wtr_building+wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+wtr_heavy+wtr_stun+wtr_nostun;
   wtrset_resurect                       :=wtr_owner_p+wtr_owner_a+wtr_owner_e+           wtr_hits_d           +wtr_bio+wtr_mech+wtr_unit+wtr_building+wtr_complete+wtr_ncomplete+wtr_ground+wtr_fly+wtr_light+wtr_heavy+wtr_stun+wtr_nostun;

   InitUpgrades;
   InitUIDS;
   InitMIDs;
   InitDMODs;

   for u:=0 to MaxDIDs do DID_Square[u]:=round(pi*sqr(DID_R[u]));
end;
