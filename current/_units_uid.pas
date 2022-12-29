
{$IFDEF _FULLGAME}
function _unit_shadowz(pu:PTUnit):integer;
begin
   with pu^  do
    with uid^ do
     if(_ukbuilding=false)
     then _unit_shadowz:=fly_height[ukfly]
     else
       if(speed<=0)or(bld=false)
       then _unit_shadowz:=-fly_hz   // no shadow
       else _unit_shadowz:=0;
end;

procedure _unit_fog_r(pu:PTUnit);
begin
   with pu^ do fsr:=mm3(0,srange div fog_cw,MFogM);
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
         apcm       :=_apcm;
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
         shadow:= _unit_shadowz(pu);

         _unit_fog_r(pu);
         {$ENDIF}
         hits:=_mhits;
      end;
   end;
end;

procedure initUIDS;
var i,u:byte;

procedure _weapon(aa,wtype:byte;max_range,min_range,count:integer;reload,oid,ruid,rupid,rupidl,dupgr:byte;dupgrs:integer;tarf,reqf:cardinal;uids,reload_s:TSoB;ax,ay:integer;atarprior:byte;afakeshots:byte);
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
      if(reload_s<>[])
      then aw_rld_s:=reload_s
      else aw_rld_s:=[aw_rld];
   end;
end;

procedure _fdeathhits(dh:integer);
begin
   with _uids[i] do _fastdeath_hits:=dh;
end;

begin
   for i:=0 to 255 do
   with _uids[i] do
   begin
      _mhits     := 1000;
      _btime     := 1;
      _ukfly     := uf_ground;
      _ucl       := 255;
      _apcs      := 1;
      _urace     := r_hell;
      _attack    := atm_none;
      _fdeathhits(-32000);
      _limituse  := MinUnitLimit;

      _ukbuilding:= false;
      _ukmech    := false;
      _uklight   := false;

      _isbuilder := false;
      _issmith   := false;
      _isbarrack := false;
      _issolid   := true;
      _slowturn  := false;

      case i of
//         HELL BUILDINGS   ////////////////////////////////////////////////////
UID_HKeep:
begin
   _mhits     := 15000;
   _renergy   := 900;
   _genergy   := 300;
   _r         := 66;
   _srange    := 280;
   _ucl       := 0;
   _btime     := ptime3;
   _ukbuilding:= true;
   _isbuilder := true;
   ups_builder:= [UID_HKeep..UID_HFortress]-[UID_HASymbol];
   _upgr_srange     :=upgr_hell_buildr;
   _upgr_srange_step:=40;
   _ability         :=uab_HKeepBlink;
   _ability_rupgr   :=upgr_hell_HKTeleport;
   _ability_rupgrl  :=1;
end;

UID_HGate:
begin
   _mhits     := 10000;
   _renergy   := 300;
   _r         := 60;
   _ucl       := 1;
   _btime     := ptime2;
   _barrack_teleport:=true;
   _ukbuilding:= true;
   _isbarrack := true;
   ups_units  := [UID_Imp..UID_Archvile];
end;

UID_HSymbol,
UID_HASymbol:
begin
   _mhits     := 500;
   _genergy   := 25;
   _renergy   := 50;
   _r         := 22;  //1520
   _ucl       := 2;
   _btime     := ptime1;
   _ukbuilding:= true;

   if(i=UID_HASymbol)then
   begin
      _btime  := ptime1hh;
      _genergy:= _renergy;
      _renergy:= 0;
   end
   else _ability:=uab_rebuild;
end;

UID_HPools:
begin
   _mhits     := 10000;
   _renergy   := 300;
   _r         := 53;
   _ucl       := 5;
   _btime     := ptime2;
   _ukbuilding:= true;
   _issmith   := true;
   ups_upgrades := [];
end;

UID_HPentagram:
begin
   _mhits     := 15000;
   _renergy   := 900;
   _genergy   := 300;
   _r         := 65;
   _ucl       := 9;
   _btime     := ptime3;
   _ukbuilding:= true;
   _issolid   := false;
end;
UID_HMonastery:
begin
   _mhits     := 15000;
   _renergy   := 900;
   _genergy   := 300;
   _r         := 65;
   _ucl       := 10;
   _btime     := ptime3;
   _ukbuilding:= true;
end;
UID_HFortress:
begin
   _mhits     := 15000;
   _renergy   := 900;
   _genergy   := 300;
   _r         := 86;
   _ucl       := 11;
   _btime     := ptime3;
   _ukbuilding:= true;
   _ispadvancer:=true;
end;

UID_HTeleport:
begin
   _mhits     := 2500;
   _renergy   := 200;
   _r         := 28;
   _ucl       := 13;
   _btime     := ptime2;
   _limituse  := ul5;
   _ability   := uab_Teleport;
   _ukbuilding:= true;
   _issolid   := false;
   _ruid1     := UID_HPools;
end;
UID_HAltar:
begin
   _mhits     := 2500;
   _renergy   := 200;
   _r         := 50;
   _ucl       := 14;
   _btime     := ptime2;
   _ruid1     := UID_HPentagram;
   _ruid2     := UID_HMonastery;
   _ruid3     := UID_HFortress;
   _ukbuilding:= true;
   _ability   := uab_HInvulnerability;
end;

UID_HTower:
begin
   _mhits     := 5000;
   _renergy   := 100;
   _r         := 20;
   _srange    := 250;
   _ucl       := 6;
   _btime     := ptime1;
   _attack    := atm_always;
   _ability   := uab_HTowerBlink;
   _ukbuilding:= true;
   _upgr_srange     :=upgr_hell_towers;
   _upgr_srange_step:=25;

   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsh  ,MID_Imp      ,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all-[UID_Imp],[],0,-26,wtp_hits,0);
   _weapon(1,wpt_missle,aw_srange,0,0 ,fr_2h3fps,MID_Cacodemon,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,         [UID_Imp],[],0,-26,wtp_hits,0);
end;
UID_HTotem:
begin
   _mhits     := 3000;
   _renergy   := 300;
   _r         := 21;
   _srange    := 250;
   _ucl       := 7;
   _btime     := ptime1h;
   _ruid1     := UID_HFortress;
   _attack    := atm_always;
   _ability   := uab_HTowerBlink;
   _ukbuilding:= true;
   _upgr_srange     :=upgr_hell_towers;
   _upgr_srange_step:=25;
   _weapon(0,wpt_missle,aw_fsr,0,0,fr_fps2,MID_ArchFire,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive_nbuildings,wpr_any+wpr_tvis,uids_all,[fr_archvile_s],0,0,wtp_hits,0);
end;
UID_HEye:
begin
   _mhits     := 100;
   _renergy   := 50;
   _r         := 10;
   _srange    := 300;
   _ucl       := 12;
   _btime     := ptime1;
   _ability   := uab_hell_vision;
   _ukbuilding:= true;
   _issolid   := false;
   _upgr_srange     :=upgr_hell_heye;
   _upgr_srange_step:=50;

   ups_builder:=[UID_HEye];
end;

//////////////////////////////

UID_Imp        :
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 11;
   _speed     := 10;
   _srange    := 225;
   _ucl       := 0;
   _painc     := 3;
   _btime     := ptime1;
   _attack    := atm_always;
   _uklight   := true;
   _fdeathhits(fdead_hits_border);
   _weapon(0,wpt_missle    ,aw_srange ,0,0          ,fr_fps1,MID_Imp,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive       ,wpr_any,uids_all-[UID_Imp],[],0,-5,wtp_unit_bio_nlight,0);
   _weapon(2,wpt_directdmg ,aw_dmelee ,0,BaseDamage1,fr_fps1,0      ,0,0,0,upgr_hell_mattack ,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Imp],[],0, 0,wtp_distance       ,0);
end;
UID_Demon      :
begin
   _mhits     := 1500;
   _renergy   := 250;
   _r         := 14;
   _speed     := 14;
   _srange    := 200;
   _ucl       := 1;
   _painc     := 8;
   _btime     := ptime1hh;
   _limituse  := ul1h;
   _attack    := atm_always;
   _weapon(0,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fps2,0,0,0,0,upgr_hell_mattack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any ,uids_all,[],0,0,wtp_distance,0);
end;
UID_Cacodemon :
begin
   _mhits     := 1500;
   _renergy   := 250;
   _r         := 14;
   _speed     := 10;
   _srange    := 225;
   _ucl       := 2;
   _painc     := 7;
   _btime     := ptime1hh;
   _apcs      := 2;
   _limituse  := ul1h;
   _ukfly     := uf_fly;
   _ruid1     := UID_HGate;
   _ruid1n    := 2;
   _ruid2     := UID_HPools;
   _ruid2n    := 1;
   _attack    := atm_always;
   _zfall     := fly_height[uf_fly];
   a_BonusAntiFly_range:=50;
   _weapon(1,wpt_missle   ,aw_srange ,0,0          ,fr_fps1   ,MID_Cacodemon,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive      ,wpr_any,uids_all-[UID_Cacodemon],[],0,0,wtp_unit_mech,0);
   _weapon(2,wpt_directdmg,aw_dmelee ,0,BaseDamage1,fr_fps1   ,0            ,0,0,0,upgr_hell_mattack ,BaseDamageBonus1,wtrset_enemy_alive_fly  ,wpr_any,         [UID_Cacodemon],[],0,0,wtp_distance ,0);
end;
UID_Knight    :
begin
   _mhits     := 2000;
   _renergy   := 300;
   _r         := 14;
   _speed     := 10;
   _srange    := 225;
   _ucl       := 3;
   _painc     := 10;
   _btime     := ptime1h;
   _apcs      := 3;
   _limituse  := ul2;
   _attack    := atm_always;
   _uklight   := true;
   _ruid1     := UID_HPools;
   _weapon(0,wpt_missle   ,aw_srange,0,0          ,fr_fps1  ,MID_Baron,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all-[UID_Knight,UID_Baron],[],0,0,wtp_unit_light,0);
   _weapon(1,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fps1  ,0        ,0,0,0,upgr_hell_mattack ,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Knight,UID_Baron],[],0,0,wtp_distance  ,0);
end;
UID_Baron     :
begin
   _mhits     := 4000;
   _renergy   := 500;
   _r         := 14;
   _speed     := 10;
   _srange    := 225;
   _ucl       := 4;
   _painc     := 10;
   _btime     := ptime1h;
   _apcs      := 3;
   _limituse  := ul3;
   _attack    := atm_always;
   _uklight   := false;
   _ruid1     := UID_HPools;
   _weapon(0,wpt_missle   ,aw_srange,0,0          ,fr_fps1   ,MID_Baron,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all-[UID_Knight,UID_Baron],[],0,0,wtp_unit_light,0);
   _weapon(1,wpt_directdmg,aw_dmelee,0,BaseDamage1,fr_fps1   ,0        ,0,0,0,upgr_hell_mattack ,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Knight,UID_Baron],[],0,0,wtp_distance  ,0);
end;
{
ul10 = 10000hp + 700dps
       15000hp + 350dps
       16000hp + 280dps
}
UID_Cyberdemon :
begin
   _mhits     := 16000;
   _renergy   := 1200;
   _r         := 20;
   _speed     := 12;
   _srange    := 225;
   _ucl       := 5;
   _painc     := 10;
   _btime     := ptime4;
   _apcs      := 10;
   _ruid1     := UID_HPentagram;
   _attack    := atm_always;
   _limituse  := ul10;
   _splashresist:=true;
   _ukmech    := true;
   _upgr_regen:=upgr_race_regen_bio[r_hell];
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_fps1   ,MID_HRocket,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_building_nlight,0);
end;
UID_Mastermind :
begin
   _mhits     := 16000;
   _renergy   := 1200;
   _r         := 35;
   _speed     := 12;
   _srange    := 225;
   _ucl       := 6;
   _painc     := 10;
   _btime     := ptime4;
   _apcs      := 10;
   _ruid1     := UID_HPentagram;
   _attack    := atm_always;
   _limituse  := ul10;
   _splashresist:=true;
   _ukmech    := true;
   _upgr_regen:=upgr_race_regen_bio[r_hell];
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_fps1_8,MID_Chaingun,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_unit_bio_light,2);
end;
UID_Pain      :
begin
   _mhits     := 1500;
   _renergy   := 300;
   _r         := 14;
   _speed     := 7;
   _srange    := 250;
   _ucl       := 7;
   _painc     := 3;
   _btime     := ptime2;
   _apcs      := 2;
   _ruid1     := UID_HMonastery;
   _ukfly     := uf_fly;
   _attack    := atm_always;
   _ability   := uab_spawnlost;
   _weapon(0,wpt_unit,aw_srange,0,0 ,fr_fps1h,UID_Phantom ,0,upgr_hell_phantoms,1,0,0,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_distance,0);
   _weapon(1,wpt_unit,aw_srange,0,0 ,fr_fps1h,UID_LostSoul,0,0                 ,0,0,0,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_distance,0);

   _fdeathhits(1);
end;
UID_Revenant   :
begin
   _mhits     := 1500;
   _renergy   := 250;
   _r         := 13;
   _speed     := 12;
   _srange    := 225;
   _ucl       := 8;
   _painc     := 5;
   _btime     := ptime1hh;
   _ruid1     := UID_HMonastery;
   _limituse  := ul1h;
   _attack    := atm_always;
   _uklight   := false;
   _weapon(0,wpt_missle   ,aw_fsr+75 ,0,0          ,fr_fps1,MID_Revenant ,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive_fly   ,wpr_any,uids_all-[UID_Revenant],[],0,-7,wtp_fly     ,0);
   _weapon(1,wpt_missle   ,aw_srange ,0,0          ,fr_fps1,MID_Revenant ,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive       ,wpr_any,uids_all-[UID_Revenant],[],0,-7,wtp_fly     ,0);
   _weapon(2,wpt_directdmg,aw_dmelee ,0,BaseDamage1,fr_fps1,0            ,0,0,0,upgr_hell_mattack ,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,         [UID_Revenant],[],0, 0,wtp_distance,0);
end;
{
2.4 lim 2400hp 168 dps
3   lim 3750hp 168 dps
}
UID_Mancubus  :
begin
   _mhits     := 3750;
   _renergy   := 500;
   _r         := 20;
   _speed     := 7;
   _srange    := 225;
   _ucl       := 9;
   _painc     := 7;
   _btime     := ptime1h;
   _ruid1     := UID_HMonastery;
   _limituse  := ul3;
   _attack    := atm_always;
   _weapon(0,wpt_missle,aw_fsr+50,0,-8,fr_mancubus_rld,MID_Mancubus,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive_ground       ,wpr_any ,uids_all-[UID_Mancubus],[fr_mancubus_rld_s1,fr_mancubus_rld_s2,fr_mancubus_rld_s3],0,0,wtp_building,0);
end;
UID_Arachnotron:
begin
   _mhits     := 3000;
   _renergy   := 500;
   _r         := 20;
   _speed     := 10;
   _srange    := 225;
   _ucl       := 10;
   _painc     := 7;
   _btime     := ptime1h;
   _ruid1     := UID_HMonastery;
   _limituse  := ul3;
   _attack    := atm_always;
   _ukmech    := true;
   _upgr_regen:=upgr_race_regen_bio[r_hell];
   _weapon(0,wpt_missle,aw_fsr+50,0,0 ,fr_fps1_3,MID_YPlasma,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all-[UID_Arachnotron],[],0,0,wtp_unit_mech,0);
end;
UID_Archvile:
begin
   _mhits     := 4000;
   _renergy   := 800;
   _r         := 14;
   _speed     := 14;
   _srange    := 250;
   _ucl       := 11;
   _painc     := 10;
   _btime     := ptime2;
   _apcs      := 2;
   _ruid1     := UID_HMonastery;
   _limituse  := ul4;
   _attack    := atm_always;
   _weapon(0,wpt_resurect,aw_dmelee ,0,0  ,fr_fps1 ,0          ,0,upgr_hell_resurrect,1,0                 ,0               ,wtrset_resurect              ,wpr_any         ,uids_arch_res,[             ],0,0,wtp_hits,0);
   _weapon(1,wpt_missle  ,aw_fsr+100,0,0  ,fr_fps2,MID_ArchFire,0,0                  ,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive_nbuildings,wpr_any+wpr_tvis,uids_all     ,[fr_archvile_s],0,0,wtp_hits,0);
end;

UID_Phantom,
UID_LostSoul  :
begin
   _mhits     := 500;
   _renergy   := 100;
   _r         := 10;
   _speed     := 23;
   _srange    := 225;
   _ucl       := 12;
   _painc     := 1;
   _btime     := ptimeh;
   _ukfly     := uf_fly;
   _attack    := atm_always;
   _uklight   := true;
   _fdeathhits(1);
   if(i=UID_Phantom)then
   _weapon(0,wpt_directdmg,aw_dmelee,0,BaseDamageh,fr_fps1,0,0,0,0,upgr_hell_mattack,BaseDamageBonus1,wtrset_enemy      ,wpr_any+wpr_zombie,uids_all,[],0,0,wtp_distance,0);
   _weapon(1,wpt_directdmg,aw_dmelee,0,BaseDamageh,fr_fps1,0,0,0,0,upgr_hell_mattack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any           ,uids_all,[],0,0,wtp_bio     ,0);
end;
UID_ZFormer:
begin
   _mhits     := 500;
   _renergy   := 100;
   _r         := 12;
   _speed     := 12;
   _srange    := 225;
   _ucl       := 13;
   _painc     := 1;
   _btime     := ptimeh;
   _attack    := atm_always;
   _uklight   := true;
   _fdeathhits(fdead_hits_border);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1,MID_Bullet,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_unit_bio_light,0);
end;
UID_ZEngineer:
begin
   _mhits     := 1000;
   _renergy   := 600;
   _r         := 12;
   _speed     := 14;
   _srange    := 200;
   _ucl       := 14;
   _painc     := 3;
   _btime     := ptime1h;
   _attack    := atm_always;
   _uklight   := true;
   _death_missile:=MID_Mine;
   _ruid1     := UID_HBarracks;
   _ruid1n    := 4;
   _fdeathhits(1);
   _weapon(0,wpt_suicide,-_speed,0,0,fr_fps1,0,0,0,0,0,0,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_distance,0);
end;
UID_ZSergant :
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 12;
   _speed     := 10;
   _srange    := 225;
   _ucl       := 15;
   _painc     := 3;
   _btime     := ptime1;
   _attack    := atm_always;
   _uklight   := true;
   _ruid1     := UID_HBarracks;
   _ruid1n    := 3;
   _fdeathhits(fdead_hits_border);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1   ,MID_SShot ,0,0,0,upgr_hell_t1attack,BaseDamageBonus1 ,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_unit_bio_nlight,0);
end;
UID_ZSSergant:
begin
   _mhits     := 1000;
   _renergy   := 250;
   _r         := 12;
   _speed     := 8;
   _srange    := 225;
   _ucl       := 16;
   _painc     := 3;
   _btime     := ptime1hh;
   _attack    := atm_always;
   _uklight   := false;
   _ruid1     := UID_HBarracks;
   _ruid1n    := 3;
   _fdeathhits(fdead_hits_border);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1h,MID_SSShot,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_unit_bio_nlight,0);
end;
UID_ZCommando:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 12;
   _speed     := 10;
   _srange    := 225;
   _ucl       := 17;
   _painc     := 5;
   _btime     := ptime1;
   _attack    := atm_always;
   _uklight   := true;
   _ruid1     := UID_HBarracks;
   _ruid1n    := 3;
   _fdeathhits(fdead_hits_border);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1_6,MID_Chaingun,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[],0,0,wtp_unit_bio_light,6);
end;
UID_ZAntiaircrafter:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 12;
   _speed     := 8;
   _srange    := 225;
   _ucl       := 18;
   _painc     := 5;
   _btime     := ptime1;
   _attack    := atm_always;
   _uklight   := false;
   _ruid1     := UID_HBarracks;
   _ruid1n    := 3;
   _fdeathhits(fdead_hits_border);
   _weapon(1,wpt_missle,aw_srange,0        ,0 ,fr_fps1,MID_URocketS,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive_fly   ,wpr_any,uids_all,[],0,-4,wtp_hits,0);
   _weapon(2,wpt_missle,aw_srange,rocket_sr,0 ,fr_fps1,MID_URocketS,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,wtp_hits,0);
end;
UID_ZSiege:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 12;
   _speed     := 8;
   _srange    := 225;
   _ucl       := 19;
   _painc     := 5;
   _btime     := ptime1;
   _attack    := atm_always;
   _uklight   := false;
   _ruid1     := UID_HBarracks;
   _ruid1n    := 3;
   _fdeathhits(fdead_hits_border);
   _weapon(0,wpt_missle,aw_srange,rocket_sr,0 ,fr_fps1,MID_Granade,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,wtp_building,0);
end;
UID_ZMajor:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 12;
   _speed     := 8;
   _srange    := 225;
   _ucl       := 20;
   _painc     := 5;
   _btime     := ptime1;
   _attack    := atm_always;
   _uklight   := false;
   _ruid1     := UID_HBarracks;
   _ruid1n    := 3;
   _fdeathhits(fdead_hits_border);
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fps1_4,MID_BPlasma,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive       ,wpr_any ,uids_all,[],0,0,wtp_unit_mech,4);
end;
UID_ZFMajor:
begin
   _mhits     := 1000;
   _renergy   := 250;
   _r         := 12;
   _speed     := 16;
   _srange    := 225;
   _ucl       := 21;
   _painc     := 5;
   _btime     := ptime1hh;
   _attack    := atm_always;
   _uklight   := true;
   _ukfly     := true;
   _ruid1     := UID_HBarracks;
   _ruid1n    := 3;
   _fdeathhits(fdead_hits_border);
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fps1_4,MID_BPlasma,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive       ,wpr_any ,uids_all,[],0,0,wtp_unit_mech,4);
end;
UID_ZBFG:
begin
   _mhits     := 1000;
   _renergy   := 600;
   _r         := 12;
   _speed     := 6;
   _srange    := 225;
   _ucl       := 22;
   _painc     := 5;
   _btime     := ptime2;
   _attack    := atm_always;
   _uklight   := false;
   _ruid1     := UID_HBarracks;
   _ruid1n    := 4;
   _ruid2     := UID_HCommandCenter;
   _ruid2n    := 2;
   _limituse  := ul2;
   _fdeathhits(fdead_hits_border);
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fps2,MID_BFG,0,0,0,upgr_hell_t2attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all,[fr_fps1],0,0,wtp_rmhits,0);
end;

//         UAC BUILDINGS   /////////////////////////////////////////////////////
UID_HCommandCenter,
UID_UCommandCenter:
begin
   _mhits     := 15000;
   _renergy   := 900;
   _genergy   := 300;
   _speed     := 0;
   _r         := 66;
   _srange    := 280;
   _ucl       := 0;
   _btime     := ptime4;
   _attack    := atm_always;
   _ability   := uab_CCFly;
   _ukbuilding:= true;
   _isbuilder := true;
   _slowturn  := false;
   _upgr_srange_step:= 40;

   if(i=UID_HCommandCenter)then
   begin
      _ucl             := 3;
      _apcm            := 30;
      ups_builder      :=[UID_HCommandCenter,UID_HSymbol,UID_HTower,UID_HEye,UID_HBarracks];
      ups_apc          :=uids_demons;
      _ruid1           := UID_HCommandCenter;
      _upgr_srange     :=upgr_hell_buildr;
      _weapon(0,wpt_missle,_srange,_r,0,fr_fps1  ,MID_Imp      ,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any+wpr_move,uids_all-[UID_Imp],[],3,-65,wtp_unit_bio_nlight,0);
      _weapon(1,wpt_missle,_srange,_r,0,fr_fps1_4,MID_Cacodemon,0,0,0,upgr_hell_t1attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any+wpr_move,         [UID_Imp],[],3,-65,wtp_nolost_hits    ,0);
   end
   else
   begin
      _ability_rupgr   := upgr_uac_CCFly;
      _ability_rupgrl  := 1;
      _zombie_uid      := UID_HCommandCenter;
      ups_builder      :=[UID_UCommandCenter..UID_UNuclearPlant]-[UID_UAGenerator];
      _upgr_srange     := upgr_uac_buildr;
      _weapon(0,wpt_missle,_srange,_r,0 ,fr_fpsh,MID_BPlasma,0,upgr_uac_ccturr,1,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any+wpr_move,uids_all,[],3,-65,wtp_unit_mech,2);
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

   if(i=UID_HBarracks)then
   begin
      _ucl       := 4;
      ups_units  := uids_zimbas+[UID_LostSoul];
      _ruid1     := UID_HCommandCenter;
   end
   else
   begin
      ups_units  := uids_marines;
      _zombie_uid:= UID_HBarracks;
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

   ups_units:=[UID_APC,UID_FAPC,UID_UACBot,UID_Terminator,UID_Tank,UID_Flyer];
end;
//1 = 25
UID_UGenerator,
UID_UAGenerator:
begin
   _mhits     := 1000;
   _genergy   := 50;
   _renergy   := 100;
   _r         := 44;
   _ucl       := 2;
   _btime     := ptime1;
   _ukbuilding:= true;
   _limituse  := ul2;
   if(i=UID_UAGenerator)then
   begin
      _btime  := _btime+(_btime div 2);
      _genergy:=_renergy;
      _renergy:= 0;
   end
   else _ability:= uab_rebuild;
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
end;

UID_UTechCenter :
begin
   _mhits     := 15000;
   _renergy   := 900;
   _r         := 86;
   _ucl       := 10;
   _btime     := ptime3;
   _ukbuilding:= true;
end;
UID_UNuclearPlant:
begin
   _mhits     := 15000;
   _renergy   := 900;
   _genergy   := 900;
   _r         := 70;
   _ucl       := 11;
   _btime     := ptime3;
   _ukbuilding:= true;
   _ispadvancer:=true;
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
   _upgr_srange     :=upgr_uac_radar_r;
   _upgr_srange_step:=25;
   _ruid1     := UID_UWeaponFactory;
end;
UID_URMStation:
begin
   _mhits     := 2500;
   _renergy   := 200;
   _r         := 40;
   _ucl       := 14;
   _btime     := ptime2;
   _limituse  := ul2;
   _ruid1     := UID_UTechCenter;
   _ruid2     := UID_UNuclearPlant;
   _ability   := uab_UACStrike;
   _ukbuilding:= true;
end;

UID_UGTurret:
begin
   _mhits     := 4000;
   _renergy   := 75;
   _r         := 15;
   _srange    := 250;
   _ucl       := 6;
   _btime     := ptime2h3;
   _attack    := atm_always;
   _ukbuilding:= true;
   _upgr_armor:= upgr_uac_turarm;
   _ability   := uab_rebuild;
   _upgr_srange     :=upgr_uac_towers;
   _upgr_srange_step:=25;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fps1_4,MID_Chaingun,0,0              ,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground_light_bio,wpr_any,uids_all,[],0,-10,wtp_hits          ,2);
   _weapon(1,wpt_missle,aw_srange,0,0 ,fr_fps1_4,MID_BPlasma ,0,upgr_uac_plasmt,1,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground_mech     ,wpr_any,uids_all,[],0,-10,wtp_hits          ,2);
   _weapon(2,wpt_missle,aw_srange,0,0 ,fr_fps1_4,MID_Chaingun,0,0              ,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground          ,wpr_any,uids_all,[],0,-10,wtp_unit_bio_light,2);
end;
UID_UATurret:
begin
   _mhits     := 4000;
   _renergy   := 75;
   _r         := 15;
   _srange    := 250;
   _ucl       := 7;
   _btime     := ptime2h3;
   _attack    := atm_always;
   _ukbuilding:= true;
   _upgr_armor:= upgr_uac_turarm;
   _ability   := uab_rebuild;
   _upgr_srange     :=upgr_uac_towers;
   _upgr_srange_step:=25;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fpsh,MID_URocket,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_fly   ,wpr_any ,uids_all      ,[],0,-10,wtp_nolost_hits,0);
   //_weapon(1,wpt_missle,aw_srange,0,0 ,fr_fpsh,MID_URocket,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any ,[UID_LostSoul],[],0,-10,wtp_hits       ,0);
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
   _issolid   := false;
   _death_missile:=MID_Mine;
   _fdeathhits(1);

   _weapon(0,wpt_suicide,-mine_r,0,0,fr_fps1,0,0,0,0,0,0,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_distance,0);
end;

///////////////////////////////////
UID_Sergant:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 12;
   _speed     := 10;
   _srange    := 225;
   _ucl       := 0;
   _btime     := ptime1;
   _attack    := atm_always;
   _zombie_uid:= UID_ZSergant;
   _uklight   := true;
   _fdeathhits(fdead_hits_border);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1,MID_SShot ,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_unit_bio_nlight,0);
end;
UID_SSergant:
begin
   _mhits     := 1000;
   _renergy   := 250;
   _r         := 12;
   _speed     := 8;
   _srange    := 225;
   _ucl       := 1;
   _btime     := ptime1hh;
   _attack    := atm_always;
   _zombie_uid:= UID_ZSSergant;
   _uklight   := false;
   _limituse  := ul1h;
   _fdeathhits(fdead_hits_border);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1h,MID_SSShot,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_unit_bio_nlight,0);
end;
UID_Commando:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 12;
   _speed     := 8;
   _srange    := 225;
   _ucl       := 2;
   _btime     := ptime1;
   _attack    := atm_always;
   _zombie_uid:= UID_ZCommando;
   _uklight   := true;
   _ruid1     := UID_UWeaponFactory;
   _fdeathhits(fdead_hits_border);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1_6,MID_Chaingun,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all,[],0,0,wtp_unit_bio_light,4);
end;
UID_Antiaircrafter:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 12;
   _speed     := 8;
   _srange    := 225;
   _ucl       := 3;
   _btime     := ptime1;
   _attack    := atm_always;
   _zombie_uid:= UID_ZAntiaircrafter;
   _uklight   := false;
   _ruid1     := UID_UWeaponFactory;
   _fdeathhits(fdead_hits_border);
   _weapon(1,wpt_missle,aw_srange,0        ,0 ,fr_fps1,MID_URocket,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_fly   ,wpr_any,uids_all,[],0,0,wtp_hits,0);
   _weapon(2,wpt_missle,aw_srange,rocket_sr,0 ,fr_fps1,MID_URocket,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_hits,0);
end;
UID_Siege:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 12;
   _speed     := 8;
   _srange    := 225;
   _ucl       := 4;
   _btime     := ptime1;
   _attack    := atm_always;
   _zombie_uid:= UID_ZSiege;
   _uklight   := false;
   _ruid1     := UID_UWeaponFactory;
   _fdeathhits(fdead_hits_border);
   _weapon(0,wpt_missle,aw_srange,rocket_sr,0 ,fr_fps1,MID_Granade,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,-4,wtp_building,0);
end;
UID_Major:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 12;
   _speed     := 8;
   _srange    := 225;
   _ucl       := 5;
   _btime     := ptime1;
   _attack    := atm_always;
   _zombie_uid:= UID_ZMajor;
   _uklight   := false;
   _ruid1     := UID_UWeaponFactory;
   _fdeathhits(fdead_hits_border);
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fps1_4,MID_BPlasma,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all,[],0,0,wtp_unit_mech,4);
end;
UID_FMajor:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 12;
   _speed     := 14;
   _srange    := 225;
   _ucl       := 6;
   _btime     := ptime1hh;
   _attack    := atm_always;
   _zombie_uid:= UID_ZFMajor;
   _uklight   := true;
   _ukfly     := true;
   _ruid1     := UID_UWeaponFactory;
   _rupgr     := upgr_uac_jetpack;
   _fdeathhits(1);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1_4,MID_BPlasma,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any ,uids_all,[],0,0,wtp_unit_mech,4);
end;
UID_BFG:
begin
   _mhits     := 1000;
   _renergy   := 600;
   _r         := 12;
   _speed     := 6;
   _srange    := 225;
   _ucl       := 7;
   _btime     := ptime2;
   _attack    := atm_always;
   _zombie_uid:= UID_ZBFG;
   _uklight   := false;
   _limituse  := ul2;
   _ruid1     := UID_UTechCenter;
   _fdeathhits(fdead_hits_border);
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fps2,MID_BFG,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive,wpr_any,uids_all,[fr_fps1],0,0,wtp_rmhits,0);
end;
UID_Engineer:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 12;
   _speed     := 10;
   _srange    := 200;
   _ucl       := 8;
   _btime     := ptime1;
   _attack    := atm_always;
   _zombie_uid:= UID_ZEngineer;
   _ability   := 0;
   _uklight   := true;
   _ruid1     := UID_UFactory;
   _fdeathhits(fdead_hits_border);
   _weapon(0,wpt_heal  ,aw_hmelee,0,BaseRepair1,fr_fps1,0          ,0,0,0,upgr_uac_melee ,BaseRepairBonus1,wtrset_repair                 ,wpr_any,uids_all,[],0,0,wtp_hits            ,0);
   _weapon(1,wpt_missle,aw_srange,0,0          ,fr_fps1,MID_Bullet ,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive            ,wpr_any,uids_all,[],0,-4,wtp_unit_bio_light  ,0);
end;
UID_Medic:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 12;
   _speed     := 10;
   _srange    := 200;
   _ucl       := 9;
   _btime     := ptime1;
   _attack    := atm_always;
   _zombie_uid:= UID_ZFormer;
   _uklight   := true;
   _ruid1     := UID_UWeaponFactory;
   _fdeathhits(fdead_hits_border);
   _weapon(0,wpt_heal  ,aw_hmelee,0,BaseHeal1,fr_fps1,0          ,0,0,0,upgr_uac_melee ,BaseHealBonus1  ,wtrset_heal                  ,wpr_any,uids_all-[UID_Medic],[],0,0,wtp_notme_hits     ,0);
   _weapon(1,wpt_missle,aw_srange,0,0        ,fr_fps1,MID_Bullet ,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground    ,wpr_any,uids_all            ,[],0,-4,wtp_unit_bio_light ,0);
   _weapon(2,wpt_heal  ,aw_hmelee,0,BaseHeal1,fr_fps1,0          ,0,0,0,upgr_uac_melee ,BaseHealBonus1  ,wtrset_heal                  ,wpr_any,[UID_Medic]         ,[],0,0,wtp_notme_hits     ,0);
end;
UID_UACBot:
begin
   _mhits     := 2000;
   _renergy   := 300;
   _r         := 13;
   _speed     := 14;
   _srange    := 225;
   _ucl       := 10;
   _btime     := ptime1h;
   _apcs      := 2;
   _limituse  := ul2;
   _attack    := atm_always;
   _ukmech    := true;
   _uklight   := true;
   _ability   := uab_Rebuild2Turret;
   _ability_rupgr:=upgr_uac_botturret;
   _fdeathhits(1);
   _weapon(0,wpt_missle,aw_fsr+25,0,0 ,fr_fps1_4,MID_BPlasma,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_unit_mech,2);
end;
UID_FAPC:
begin
   _mhits     := 2000;
   _renergy   := 200;
   _r         := 33;
   _speed     := 19;
   _srange    := 225;
   _ucl       := 11;
   _btime     := ptime1;
   _apcm      := 8;
   _apcs      := 8;
   _ukfly     := uf_fly;
   _attack    := atm_none;
   _ukmech    := true;
   _slowturn  := true;
   _ruid1     := UID_UWeaponFactory;
   _fdeathhits(1);
   ups_apc    :=uids_marines+[UID_APC,UID_UACBot,UID_Terminator,UID_Tank];
end;
UID_Terminator:
begin
   _mhits     := 4000;
   _renergy   := 600;
   _r         := 16;
   _speed     := 14;
   _srange    := 225;
   _ucl       := 12;
   _btime     := ptime2;
   _apcs      := 3;
   _limituse  := ul4;
   _attack    := atm_always;
   _ukmech    := true;
   _ruid1     := UID_UTechCenter;
   _fdeathhits(1);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1_4,MID_SShot   ,0,0,0,upgr_uac_attack,BaseDamageBonus1 ,wtrset_enemy_alive_ground_nlight_bio,wpr_any,uids_all,[],0,0,wtp_unit_bio_nlight,0);
   _weapon(1,wpt_missle,aw_srange,0,0,fr_fps1_4,MID_Chaingun,0,0,0,upgr_uac_attack,BaseDamageBonus1 ,wtrset_enemy_alive_ground           ,wpr_any,uids_all,[],0,0,wtp_unit_light     ,0);      // wtp_max_hits
end;
UID_Tank:
begin
   _mhits     := 6000;
   _renergy   := 600;
   _r         := 20;
   _speed     := 12;
   _srange    := 225;
   _ucl       := 13;
   _btime     := ptime2;
   _apcs      := 4;
   _limituse  := ul4;
   _attack    := atm_always;
   _ukmech    := true;
   _splashresist:=true;
   _ruid1     := UID_UTechCenter;
   _fdeathhits(1);
   _weapon(0,wpt_missle,aw_fsr+75,rocket_sr,2 ,fr_fps1,MID_Tank,0,0,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_building,0);
end;
UID_Flyer:
begin
   _mhits     := 5000;
   _renergy   := 600;
   _r         := 18;
   _speed     := 20;
   _srange    := 225;
   _ucl       := 14;
   _btime     := ptime2;
   _apcs      := 8;
   _ukfly     := uf_fly;
   _limituse  := ul4;
   _attack    := atm_always;
   _ukmech    := true;
   _ruid1     := UID_UTechCenter;
   _fdeathhits(1);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_fps1_3,MID_URocket,0,0               ,0,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_fly   ,wpr_any,uids_all,[],0,0,wtp_nolost_hits,0);
   _weapon(1,wpt_missle,aw_srange,0,0,fr_fps1  ,MID_Flyer  ,0,upgr_uac_lturret,1,upgr_uac_attack,BaseDamageBonus1,wtrset_enemy_alive_ground,wpr_any,uids_all,[],0,0,wtp_hits       ,0);
end;

UID_APC:
begin
   _mhits     := 3000;
   _renergy   := 200;
   _r         := 25;
   _speed     := 15;
   _srange    := 225;
   _ucl       := 15;
   _btime     := ptime2;
   _apcm      := 4;
   _apcs      := 10;
   _attack    := atm_bunker;
   _ukmech    := true;
   _slowturn  := true;
   _splashresist:=true;
   _fdeathhits(1);
   ups_apc    :=uids_marines;
end;
UID_UTransport:
begin
   _mhits     := 5000;
   _renergy   := 100;
   _r         := 36;
   _speed     := 10;
   _srange    := 200;
   _ucl       := 16;
   _btime     := ptime2;
   _apcm      := 30;
   _apcs      := 10;
   _ruid1     := UID_UTechCenter;
   _ukfly     := uf_fly;
   _ukmech    := true;
   _slowturn  := true;
   _fdeathhits(1);
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

      if(i in uids_hell)then _urace:=r_hell;
      if(i in uids_uac )then _urace:=r_uac;

      if(_urace=0)then _urace:=r_hell;

      if(_ruid1>0)and(_ruid1n=0)then _ruid1n:=1;
      if(_ruid2>0)and(_ruid2n=0)then _ruid2n:=1;
      if(_ruid3>0)and(_ruid3n=0)then _ruid3n:=1;
      if(_rupgr>0)and(_rupgrn=0)then _rupgrn:=1;
      if(_ability_rupgr>0)and(_ability_rupgrl=0)then _ability_rupgrl:=1;

      _painc_upgr:=(_painc div 2)+(_painc mod 2);

      _missile_r:=trunc(_r/1.4);
      _hmhits:=_mhits div 2;

      if(_issmith)and(ups_upgrades=[])then
       for u:=1 to 255 do
        with _upids[u] do
         if(_up_time>0)and(_urace=_up_race)then ups_upgrades+=[u];

      if(_isbarrack)or(_issmith)then
      begin
         _ability     :=uab_prodlevelup;
         _ability_ruid:=uid_race_9bld[_urace];
      end;

      if(_ukbuilding)then
      begin
         _zombie_hits:=_mhits div 4;
         _ukmech     :=true;
         if(_base_armor=0)and(_attack>0)and(not _isbuilder)then _base_armor:=BaseArmorBonus2;
         _srange:=max2(_r+_r,_srange);
      end;

      if(_limituse>=MinUnitLimit)then
      begin
      _level_damage:=round(BaseDamageLevel1*_limituse/MinUnitLimit);
      _level_armor :=round(BaseArmorLevel1 *_limituse/MinUnitLimit);
      end;

      if(_base_armor<0)then  _base_armor:=0;

      _shcf:=_mhits/_mms;

      if(_btime> 0)then _bstep:=(_mhits div 2) div _btime;
      if(_bstep<=0)then _bstep:=1;
      _tprod:=_btime*fr_fps1;
   end;
end;


procedure ObjTbl;
var u:integer;
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
      _up_btni      := u;u+=1;
   end;
end;
begin
   for u:=0 to MaxUnits do _punits[u]:=@_units[u];

   FillChar(_upids,SizeOf(_upids),0);

   //                                  base X +
   //         race id                  time      lvl  enr  X +    rupgr         ruid                multi
   u:=0;
   _setUPGR(r_hell,upgr_hell_t1attack  ,60 ,0,45,5   ,600 ,0,600 ,0            ,0                  ,false);
   _setUPGR(r_hell,upgr_hell_uarmor    ,60 ,0,45,5   ,600 ,0,600 ,0            ,0                  ,false);
   _setUPGR(r_hell,upgr_hell_barmor    ,60 ,0,40,5   ,600 ,0,300 ,0            ,0                  ,false);
   _setUPGR(r_hell,upgr_hell_mattack   ,60 ,0,40,5   ,600 ,0,300 ,0            ,0                  ,false);
   _setUPGR(r_hell,upgr_hell_regen     ,60 ,0,30,2   ,300 ,0,300 ,0            ,0                  ,false);
   _setUPGR(r_hell,upgr_hell_pains     ,60 ,0,0 ,3   ,300 ,0,0   ,0            ,0                  ,false);
   _setUPGR(r_hell,upgr_hell_towers    ,60 ,0,15,3   ,600 ,0,300 ,0            ,0                  ,false);
   _setUPGR(r_hell,upgr_hell_HKTeleport,180,0,0 ,1   ,600 ,0,0   ,0            ,0                  ,false);
   _setUPGR(r_hell,upgr_hell_paina     ,60 ,0,0 ,2   ,300 ,0,0   ,0            ,0                  ,false);
   _setUPGR(r_hell,upgr_hell_buildr    ,60 ,0,0 ,2   ,600 ,0,0   ,0            ,0                  ,false);
   _setUPGR(r_hell,upgr_hell_extbuild  ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,0                  ,false);
   _setUPGR(r_hell,upgr_hell_pinkspd   ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,0                  ,false);

   _setUPGR(r_hell,upgr_hell_spectre   ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HMonastery     ,false);
   _setUPGR(r_hell,upgr_hell_vision    ,60 ,0,30,2   ,600 ,0,300 ,0            ,UID_HMonastery     ,false);
   _setUPGR(r_hell,upgr_hell_phantoms  ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HMonastery     ,false);
   _setUPGR(r_hell,upgr_hell_t2attack  ,60 ,0,45,5   ,600 ,0,600 ,0            ,UID_HMonastery     ,false);
   _setUPGR(r_hell,upgr_hell_teleport  ,60 ,0,30,2   ,400 ,0,200 ,0            ,UID_HFortress      ,false);
   _setUPGR(r_hell,upgr_hell_rteleport ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HFortress      ,false);
   _setUPGR(r_hell,upgr_hell_heye      ,60 ,0,0 ,3   ,300 ,0,300 ,0            ,UID_HFortress      ,false);
   _setUPGR(r_hell,upgr_hell_totminv   ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_HFortress      ,false);
   _setUPGR(r_hell,upgr_hell_bldrep    ,60 ,0,0 ,4   ,600 ,0,300 ,0            ,UID_HFortress      ,false);
   _setUPGR(r_hell,upgr_hell_b478tel   ,15 ,0,0 ,15  ,200 ,0,0   ,0            ,UID_HFortress      ,true );
   _setUPGR(r_hell,upgr_hell_resurrect ,60 ,0,0 ,1   ,900 ,0,0   ,0            ,UID_HAltar         ,false);
   _setUPGR(r_hell,upgr_hell_invuln    ,150,0,0 ,1   ,1200,0,0   ,0            ,UID_HAltar         ,true );


   u:=0;
   _setUPGR(r_uac ,upgr_uac_attack     ,60 ,0,45,5   ,600 ,0,600 ,0            ,0                  ,false);
   _setUPGR(r_uac ,upgr_uac_uarmor     ,60 ,0,45,5   ,600 ,0,600 ,0            ,0                  ,false);
   _setUPGR(r_uac ,upgr_uac_barmor     ,60 ,0,45,5   ,600 ,0,600 ,0            ,0                  ,false);
   _setUPGR(r_uac ,upgr_uac_melee      ,60 ,0,40,3   ,600 ,0,600 ,0            ,0                  ,false);
   _setUPGR(r_uac ,upgr_uac_mspeed     ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,0                  ,false);
   _setUPGR(r_uac ,upgr_uac_jetpack    ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,0                  ,false);
   _setUPGR(r_uac ,upgr_uac_towers     ,60 ,0,15,3   ,600 ,0,300 ,0            ,0                  ,false);
   _setUPGR(r_uac ,upgr_uac_CCFly      ,120,0,0 ,1   ,600 ,0,0   ,0            ,0                  ,false);
   _setUPGR(r_uac ,upgr_uac_ccturr     ,120,0,0 ,1   ,600 ,0,0   ,0            ,0                  ,false);
   _setUPGR(r_uac ,upgr_uac_buildr     ,60 ,0,0 ,2   ,600 ,0,0   ,0            ,0                  ,false);
   _setUPGR(r_uac ,upgr_uac_extbuild   ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,0                  ,false);
   _setUPGR(r_uac ,upgr_uac_float      ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,0                  ,false);

   _setUPGR(r_uac ,upgr_uac_botturret  ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter    ,false);
   _setUPGR(r_uac ,upgr_uac_vision     ,60 ,0,30,2   ,600 ,0,300 ,0            ,UID_UTechCenter    ,false);
   _setUPGR(r_uac ,upgr_uac_commando   ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter    ,false);
   _setUPGR(r_uac ,upgr_uac_airsp      ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter    ,false);
   _setUPGR(r_uac ,upgr_uac_mechspd    ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter    ,false);
   _setUPGR(r_uac ,upgr_uac_mecharm    ,60 ,0,45,5   ,600 ,0,600 ,0            ,UID_UTechCenter    ,false);
   _setUPGR(r_uac ,upgr_uac_lturret    ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter    ,false);
   _setUPGR(r_uac ,upgr_uac_transport  ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UTechCenter   ,false);
   _setUPGR(r_uac ,upgr_uac_radar_r    ,60 ,0,0 ,3   ,300 ,0,300 ,0            ,UID_UNuclearPlant  ,false);
   _setUPGR(r_uac ,upgr_uac_plasmt     ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UNuclearPlant  ,false);
   _setUPGR(r_uac ,upgr_uac_turarm     ,60 ,0,0 ,1   ,600 ,0,0   ,0            ,UID_UNuclearPlant  ,false);
   _setUPGR(r_uac ,upgr_uac_rstrike    ,150,0,0 ,3   ,1200,0,0   ,0            ,UID_URMStation     ,true );

   //                                      wtr_owner_p wtr_owner_a wtr_owner_e wtr_hits_h wtr_hits_d wtr_hits_a wtr_bio wtr_mech wtr_building wtr_bld wtr_nbld wtr_ground wtr_fly wtr_adv wtr_nadv wtr_light wtr_nlight wtr_stun wtr_nostun;
   wtrset_enemy                          :=                        wtr_owner_e+wtr_hits_h+wtr_hits_d+wtr_hits_a+wtr_bio+wtr_mech+wtr_building+wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive                    :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_building+wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_light              :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_building+wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+           wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground             :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_building+wtr_bld+wtr_nbld+wtr_ground        +wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_light       :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_building+wtr_bld+wtr_nbld+wtr_ground        +wtr_adv+wtr_nadv+wtr_light+           wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_nlight      :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_building+wtr_bld+wtr_nbld+wtr_ground        +wtr_adv+wtr_nadv+          wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_nlight_bio  :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+                      wtr_bld+wtr_nbld+wtr_ground        +wtr_adv+wtr_nadv+          wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_mech        :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+        wtr_mech             +wtr_bld+wtr_nbld+wtr_ground        +wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_fly                :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_building+wtr_bld+wtr_nbld+           wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_fly_mech           :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+        wtr_mech             +wtr_bld+wtr_nbld+           wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_mech               :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+        wtr_mech             +wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_mech_nstun         :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+        wtr_mech             +wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+         wtr_nostun;
   wtrset_enemy_alive_buildings          :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+                 wtr_building+wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_nbuildings         :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech             +wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_buildings   :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+                 wtr_building+wtr_bld+wtr_nbld+wtr_ground        +wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_bio                :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+                      wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_bio_nstun          :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+                      wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+         wtr_nostun;
   wtrset_enemy_alive_bio_light          :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+                      wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light           +wtr_stun+wtr_nostun;
   wtrset_enemy_alive_nlight_bio         :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+                      wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light           +wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_bio         :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+                      wtr_bld+wtr_nbld+wtr_ground+        wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_light_bio   :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+                      wtr_bld+wtr_nbld+wtr_ground+        wtr_adv+wtr_nadv+wtr_light           +wtr_stun+wtr_nostun;
   wtrset_heal                           :=wtr_owner_p+wtr_owner_a            +wtr_hits_h                      +wtr_bio+                      wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_repair                         :=wtr_owner_p+wtr_owner_a            +wtr_hits_h                              +wtr_mech+wtr_building+wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_resurect                       :=wtr_owner_p+wtr_owner_a                       +wtr_hits_d           +wtr_bio+wtr_mech+wtr_building+wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;


   FillChar(_uids   ,SizeOf(_uids   ),0);

   initUIDS;
end;
