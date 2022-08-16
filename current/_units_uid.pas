
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

procedure _unit_apUID(pu:PTUnit;advanced:boolean);
begin
   with pu^ do
   begin
      uid:=@_uids[uidi];
      with uid^ do
      begin
         isbuildarea:=_isbuilder;
         srange     :=_srange;
         speed      :=_speed;
         ukfly      :=_ukfly;
         apcm       :=_apcm;
         painc      :=_painc;
         solid      :=_issolid;

         if(_ukbuilding)and(_isbarrack)then
         begin
            uo_x:=x;
            uo_y:=y+_r;
         end;

         if(_bornadvanced[g_addon])or(advanced)then buff[ub_advanced]:=_ub_infinity;
         //_unit_upgr(pu);

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

procedure _weapon(aa,wtype:byte;max_range,min_range,count:integer;reload,oid,ruid,rupid,rupidl,dupgr:byte;dupgrs:integer;tarf,reqf:cardinal;uids,reload_s:TSoB;ax,ay:integer;atarprior:byte);
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
      if(reload_s<>[])
      then aw_rld_s:=reload_s
      else aw_rld_s:=[aw_rld];
   end;
end;

procedure _fdeathhits(dh:integer);
begin
   with _uids[i] do
   begin
      _fastdeath_hits[false]:=dh;
      _fastdeath_hits[true ]:=dh;
   end;
end;

begin
   for i:=0 to 255 do
   with _uids[i] do
   begin
      _mhits     := 100;
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
      _ukfloater := false;

      _isbuilder := false;
      _issmith   := false;
      _isbarrack := false;
      _issolid   := true;
      _slowturn  := false;

      case i of
//         HELL BUILDINGS   ////////////////////////////////////////////////////
UID_HKeep:
begin
   _mhits     := 3500;
   _renergy   := 800;
   _genergy   := 300;
   _r         := 66;
   _srange    := 280;
   _ucl       := 0;
   _btime     := 90;
   _ukbuilding:= true;
   _isbuilder := true;
   ups_builder:= [UID_HKeep..UID_HFortress,UID_HCommandCenter]-[UID_HASymbol];
   _upgr_srange     :=upgr_hell_mainr;
   _upgr_srange_step:=40;
   _ability         :=uab_hkeeptele;
   _ability_rupgr   :=upgr_hell_hktele;
   _ability_rupgrl  :=1;
end;

UID_HGate:
begin
   _mhits     := 2500;
   _renergy   := 200;
   _r         := 60;
   _ucl       := 1;
   _btime     := 60;
   _barrack_teleport:=true;
   _ukbuilding:= true;
   _isbarrack := true;
   ups_units  := [UID_LostSoul..UID_Archvile];
end;

UID_HSymbol,
UID_HASymbol:
begin
   _mhits     := 200;
   _genergy   := 10;
   _renergy   := _genergy*2;
   _r         := 22;
   _ucl       := 2;
   _btime     := 15;
   _ukbuilding:= true;

   if(i=UID_HASymbol)then
   begin
      _renergy:=0;
      _btime  :=_btime*2;
      _genergy:=_genergy*2;
      _ucl    :=5;
      _srange :=250;
   end
   else _ability:= uab_rebuild;
end;

UID_HPools:
begin
   _mhits     := 2500;
   _renergy   := 200;
   _r         := 53;
   _ucl       := 9;
   _btime     := 60;
   _ukbuilding:= true;
   _issmith   := true;
   ups_upgrades := [];
end;

UID_HMonastery:
begin
   _mhits     := 2500;
   _renergy   := 600;
   _r         := 65;
   _ucl       := 10;
   _btime     := 60;
   _ability   := uab_hell_unit_adv;
   _ukbuilding:= true;
end;
UID_HFortress:
begin
   _mhits     := 4000;
   _renergy   := 600;
   _genergy   := 300;
   _r         := 86;
   _ucl       := 11;
   _btime     := 60;
   _ability   := uab_building_adv;
   _addon     := true;
   _ukbuilding:= true;
end;

UID_HEyeNest:
begin
   _mhits     := 200;
   _renergy   := 200;
   _r         := 20;
   _srange    := 100;
   _ucl       := 12;
   _btime     := 60;
   _limituse  := 200;
   _rupgr     := upgr_hell_heye;
   _ability   := uab_hell_vision;
   _ukbuilding:= true;
   _upgr_srange     :=upgr_hell_towers;
   _upgr_srange_step:=25;
end;
UID_HTeleport:
begin
   _mhits     := 500;
   _renergy   := 200;
   _r         := 28;
   _ucl       := 13;
   _btime     := 60;
   _limituse  := 500;
   _ability   := uab_teleport;
   _ukbuilding:= true;
   _issolid   := false;
end;
UID_HAltar:
begin
   _mhits     := 500;
   _renergy   := 200;
   _r         := 50;
   _ucl       := 14;
   _btime     := 60;
   _ruid1     := UID_HMonastery;
   _ruid2     := UID_HFortress;
   _ukbuilding:= true;
   _addon     := true;
   _ability   := uab_hinvuln;
end;

UID_HTower:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 20;
   _srange    := 250;
   _ucl       := 6;
   _btime     := 20;
   _attack    := atm_always;
   _ability   := uab_htowertele;
   _ukbuilding:= true;
   _upgr_srange     :=upgr_hell_towers;
   _upgr_srange_step:=25;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_3h2fps,MID_Revenant ,0,0,0,upgr_hell_dattack,2,wtrset_enemy_alive_fly,wpr_any,uidall,[],0,-26,wtp_hits);
   _weapon(1,wpt_missle,aw_srange,0,0 ,fr_3h2fps,MID_Cacodemon,0,0,0,upgr_hell_dattack,2,wtrset_enemy_alive    ,wpr_any,uidall,[],0,-26,wtp_hits);
end;
UID_HTotem:
begin
   _mhits     := 500;
   _renergy   := 300;
   _r         := 21;
   _srange    := 250;
   _ucl       := 7;
   _btime     := 20;
   _ruid1     := UID_HAltar;
   _attack    := atm_always;
   _ability   := uab_htowertele;
   _ukbuilding:= true;
   _addon     := true;
   _upgr_srange     :=upgr_hell_towers;
   _upgr_srange_step:=25;
   _weapon(0,wpt_missle,aw_fsr+100,0,0,140,MID_ArchFire,0,0,0,upgr_hell_dattack,5,wtrset_enemy_alive_nbuildings,wpr_any+wpr_tvis,uidall,[65],0,0,wtp_hits);
end;

UID_HEye:
begin
   _mhits     := 1;
   _renergy   := 10;
   _r         := 5;
   _srange    := 300;
   _ucl       := 21;
   _btime     := 1;
   _rupgr     := upgr_hell_heye;
   _ukbuilding:= true;
   _issolid   := false;
end;

//////////////////////////////

UID_LostSoul   :
begin
   _mhits     := 200;
   _renergy   := 50;
   _r         := 10;
   _speed     := 23;
   _srange    := 250;
   _ucl       := 0;
   _painc     := 1;
   _btime     := 10;
   _ukfly     := uf_fly;
   _attack    := atm_always;
   _uklight   := true;
   _ukfloater := true;
   _fdeathhits(1);
   _weapon(0,wpt_directdmg,aw_dmelee,0,10,fr_3h2fps,0,0,0,0,upgr_hell_mattack,4,wtrset_enemy      ,wpr_adv+wpr_zombie,uidall,[],0,0,wtp_distance);
   _weapon(1,wpt_directdmg,aw_dmelee,0,10,fr_3h2fps,0,0,0,0,upgr_hell_mattack,4,wtrset_enemy_alive,wpr_any           ,uidall,[],0,0,wtp_bio     );
end;
UID_Imp        :
begin
   _mhits     := 200;
   _renergy   := 100;
   _r         := 11;
   _speed     := 9;
   _srange    := 250;
   _ucl       := 1;
   _painc     := 3;
   _btime     := 20;
   _attack    := atm_always;
   _uklight   := true;
   _fdeathhits(-30);
   _weapon(0,wpt_missle    ,_srange+50,0,0 ,fr_4h3fps,MID_Imp,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_ground,wpr_adv ,uidall-[UID_Imp],[],0,-5,wtp_unit_bio_nlight);
   _weapon(1,wpt_missle    ,aw_srange ,0,0 ,fr_4h3fps,MID_Imp,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_ground,wpr_nadv,uidall-[UID_Imp],[],0,-5,wtp_unit_bio_nlight);
   _weapon(2,wpt_directdmg ,aw_dmelee ,0,20,fr_fps   ,0      ,0,0,0,upgr_hell_mattack,3,wtrset_enemy_alive_ground,wpr_any,        [UID_Imp],[],0, 0,wtp_distance       );
end;
UID_Demon      :
begin
   _mhits     := 300;
   _renergy   := 200;
   _r         := 14;
   _speed     := 14;
   _srange    := 200;
   _ucl       := 2;
   _painc     := 8;
   _btime     := 30;
   _limituse  := 150;
   _attack    := atm_always;
   _weapon(0,wpt_directdmg,aw_dmelee,0,40,fr_2hfps,0      ,0,upgr_hell_pinkspd,1,upgr_hell_mattack,3,wtrset_enemy_alive_ground,wpr_any ,uidall,[],0,0,wtp_distance);
   _weapon(1,wpt_directdmg,aw_dmelee,0,40,fr_fps  ,0      ,0,0                ,0,upgr_hell_mattack,3,wtrset_enemy_alive_ground,wpr_any ,uidall,[],0,0,wtp_distance);
end;
UID_Cacodemon  :
begin
   _mhits     := 300;
   _renergy   := 200;
   _r         := 14;
   _speed     := 9;
   _srange    := 250;
   _ucl       := 3;
   _painc     := 6;
   _btime     := 30;
   _apcs      := 2;
   _limituse  := 125;
   _ukfly     := uf_fly;
   _ruid1     := UID_HPools;
   _attack    := atm_always;
   _zfall     := fly_height[uf_fly];
   _weapon(0,wpt_missle   ,_srange+50,0,0 ,fr_fps   ,MID_Cacodemon,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive      ,wpr_adv ,uidall-[UID_Cacodemon],[],0,0,wtp_unit_light);
   _weapon(1,wpt_missle   ,aw_srange ,0,0 ,fr_fps   ,MID_Cacodemon,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive      ,wpr_nadv,uidall-[UID_Cacodemon],[],0,0,wtp_unit_light);
   _weapon(2,wpt_directdmg,aw_dmelee ,0,20,fr_fps   ,0            ,0,0,0,upgr_hell_mattack,3,wtrset_enemy_alive_fly  ,wpr_any ,       [UID_Cacodemon],[],0,0,wtp_distance  );
end;
UID_Knight      :
begin
   _mhits     := 400;
   _renergy   := 200;
   _r         := 14;
   _speed     := 9;
   _srange    := 250;
   _ucl       := 4;
   _painc     := 10;
   _btime     := 45;
   _apcs      := 3;
   _limituse  := 200;
   _ruid1     := UID_HPools;
   _attack    := atm_always;
   _bornadvanced[false]:=true;
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_fps   ,MID_Baron,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_ground,wpr_any ,uidall-[UID_Knight],[],0,0,wtp_hits    );
   _weapon(1,wpt_directdmg,aw_dmelee,0,40,fr_fps   ,0        ,0,0,0,upgr_hell_mattack,3,wtrset_enemy_alive_ground,wpr_any ,       [UID_Knight],[],0,0,wtp_distance);
end;
UID_Cyberdemon :
begin
   _mhits     := 4000;
   _renergy   := 600;
   _r         := 20;
   _speed     := 11;
   _srange    := 250;
   _ucl       := 5;
   _painc     := 15;
   _btime     := 120;
   _apcs      := 10;
   _ruid1     := UID_HPools;
   _ruid2     := UID_HMonastery;
   _attack    := atm_always;
   _limituse  := 1000;
   _base_armor:= 2;
   _splashresist:=true;
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_fps   ,MID_HRocket,0,0,0,upgr_hell_dattack,5,wtrset_enemy_alive,wpr_any,uidall,[],0,0,wtp_building_nlight);
end;
UID_Mastermind :
begin
   _mhits     := 4000;
   _renergy   := 600;
   _r         := 35;
   _speed     := 11;
   _srange    := 275;
   _ucl       := 6;
   _painc     := 15;
   _btime     := 120;
   _apcs      := 10;
   _ruid1     := UID_HPools;
   _ruid2     := UID_HMonastery;
   _attack    := atm_always;
   _limituse  := 1000;
   _base_armor:= 2;
   _splashresist:=true;
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_7hfps,MID_Bulletx2,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive,wpr_any,uidall,[],0,0,wtp_unit_bio_light);
end;
UID_Pain      :
begin
   _mhits     := 300;
   _renergy   := 200;
   _r         := 14;
   _speed     := 9;
   _srange    := 250;
   _ucl       := 7;
   _painc     := 3;
   _btime     := 45;
   _apcs      := 2;
   _ruid1     := UID_HMonastery;
   _ukfly     := uf_fly;
   _attack    := atm_always;
   _ability   := uab_spawnlost;
   _addon     := true;
   _weapon(0,wpt_unit,aw_fsr+100,0,0 ,fr_2h3fps,UID_LostSoul,0,0,0,0,0,wtrset_enemy_alive,wpr_any,uidall,[],0,0,wtp_distance);
   _fdeathhits(1);
end;
UID_Revenant   :
begin
   _mhits     := 300;
   _renergy   := 200;
   _r         := 13;
   _speed     := 12;
   _srange    := 250;
   _ucl       := 8;
   _painc     := 7;
   _btime     := 30;
   _ruid1     := UID_HMonastery;
   _limituse  := 150;
   _attack    := atm_always;
   _uklight   := false;
   _addon     := true;
   _weapon(0,wpt_missle   ,aw_fsr+100,0,0 ,fr_fps   ,MID_Revenant ,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_fly   ,wpr_adv,uidall-[UID_Revenant],[],0,-7,wtp_hits);
   _weapon(1,wpt_missle   ,aw_srange ,0,0 ,fr_fps   ,MID_Revenant ,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive       ,wpr_any,uidall-[UID_Revenant],[],0,-7,wtp_hits);
   _weapon(2,wpt_directdmg,aw_dmelee ,0,20,fr_3h2fps,0            ,0,0,0,upgr_hell_mattack,3,wtrset_enemy_alive_ground,wpr_any,       [UID_Revenant],[],0, 0,wtp_distance);
end;
UID_Mancubus   :
begin
   _mhits     := 600;
   _renergy   := 400;
   _r         := 20;
   _speed     := 6;
   _srange    := 250;
   _ucl       := 9;
   _painc     := 4;
   _btime     := 45;
   _ruid1     := UID_HFortress;
   _limituse  := 300;
   _attack    := atm_always;
   _addon     := true;
   _weapon(0,wpt_missle,aw_fsr+50,0,-8,fr_mancubus_r,MID_Mancubus,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive,wpr_any ,uidall-[UID_Mancubus],[110,70,30],0,0,wtp_building);
end;
UID_Arachnotron:
begin
   _mhits     := 600;
   _renergy   := 400;
   _r         := 20;
   _speed     := 8;
   _srange    := 250;
   _ucl       := 10;
   _painc     := 4;
   _btime     := 45;
   _ruid1     := UID_HFortress;
   _limituse  := 300;
   _attack    := atm_always;
   _addon     := true;
   _weapon(0,wpt_missle,aw_fsr+100,0,0 ,fr_4hfps,MID_YPlasma,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive,wpr_adv ,uidall-[UID_Arachnotron],[],0,0,wtp_unit_mech);
   _weapon(1,wpt_missle,aw_srange ,0,0 ,fr_4hfps,MID_YPlasma,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive,wpr_nadv,uidall-[UID_Arachnotron],[],0,0,wtp_unit_mech);
end;
UID_Archvile:
begin
   _mhits     := 600;
   _renergy   := 600;
   _r         := 14;
   _speed     := 15;
   _srange    := 250;
   _ucl       := 11;
   _painc     := 12;
   _btime     := 60;
   _apcs      := 2;
   _ruid1     := UID_HAltar;
   _limituse  := 300;
   _attack    := atm_always;
   _addon     := true;
   _weapon(0,wpt_resurect,aw_dmelee,0,0  ,fr_fps,0           ,0,0,0,0                ,0,wtrset_resurect              ,wpr_adv         ,arch_res,[  ],0,0,wtp_hits);
   _weapon(1,wpt_missle  ,500      ,0,0  ,140   ,MID_ArchFire,0,0,0,upgr_hell_dattack,5,wtrset_enemy_alive_nbuildings,wpr_any+wpr_tvis,uidall  ,[65],0,0,wtp_hits);
end;

UID_ZFormer:
begin
   _mhits     := 100;
   _renergy   := 50;
   _r         := 12;
   _speed     := 13;
   _srange    := 250;
   _ucl       := 12;
   _painc     := 1;
   _btime     := 10;
   _attack    := atm_always;
   _uklight   := true;
   _fdeathhits(-25);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_2hfps ,MID_Bullet,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive,wpr_adv ,uidall,[],0,0,wtp_unit_bio_light);
   _weapon(1,wpt_missle,aw_srange,0,0,fr_3h2fps,MID_Bullet,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive,wpr_nadv,uidall,[],0,0,wtp_unit_bio_light);
end;
UID_ZEngineer:
begin
   _mhits     := 200;
   _renergy   := 200;
   _r         := 12;
   _speed     := 14;
   _srange    := 200;
   _ucl       := 13;
   _painc     := 4;
   _btime     := 30;
   _attack    := atm_always;
   _uklight   := true;
   _fdeathhits(1);
   _weapon(0,wpt_missle,-12,0,0,3,MID_Mine,0,0,0,upgr_hell_dattack,5,wtrset_enemy_alive_ground,wpr_sspos+wpr_suicide,uidall,[],0,0,wtp_distance);
end;
UID_ZSergant:
begin
   _mhits     := 200;
   _renergy   := 100;
   _r         := 12;
   _speed     := 13;
   _srange    := 250;
   _ucl       := 14;
   _painc     := 4;
   _btime     := 30;
   _attack    := atm_always;
   _uklight   := true;
   _fdeathhits(-30);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_2h3fps,MID_SSShot,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_ground,wpr_adv ,uidall,[],0,0,wtp_unit_bio_nlight);
   _weapon(1,wpt_missle,aw_srange,0,0,fr_fps   ,MID_SShot ,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_ground,wpr_nadv,uidall,[],0,0,wtp_unit_bio_nlight);
end;
UID_ZCommando:
begin
   _mhits     := 200;
   _renergy   := 200;
   _r         := 12;
   _speed     := 11;
   _srange    := 250;
   _ucl       := 15;
   _painc     := 4;
   _btime     := 30;
   _attack    := atm_always;
   _uklight   := true;
   _fdeathhits(-30);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_8hfps,MID_Bullet,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive,wpr_adv ,uidall,[],0,0,wtp_unit_bio_light);
   _weapon(1,wpt_missle,aw_srange,0,0,fr_7hfps,MID_Bullet,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive,wpr_nadv,uidall,[],0,0,wtp_unit_bio_light);
end;
UID_ZBomber:
begin
   _mhits     := 200;
   _renergy   := 200;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 16;
   _painc     := 4;
   _btime     := 45;
   _attack    := atm_always;
   _uklight   := true;
   _fdeathhits(-30);
   _weapon(0,wpt_missle,aw_srange,rocket_sr,0 ,fr_2h3fps,MID_Granade,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_ground_buildings,wpr_adv ,uidall,[],0,-4,wtp_hits);
   _weapon(1,wpt_missle,aw_srange,0        ,0 ,fr_2h3fps,MID_URocket,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_fly             ,wpr_any ,uidall,[],0,-4,wtp_hits);
   _weapon(2,wpt_missle,aw_srange,rocket_sr,0 ,fr_2h3fps,MID_Granade,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_ground          ,wpr_adv ,uidall,[],0,-4,wtp_hits);
   _weapon(3,wpt_missle,aw_srange,rocket_sr,0 ,fr_2h3fps,MID_URocket,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_ground          ,wpr_nadv,uidall,[],0,-4,wtp_hits);
end;
UID_ZMajor:
begin
   _mhits     := 200;
   _renergy   := 200;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 17;
   _painc     := 4;
   _btime     := 30;
   _attack    := atm_always;
   _uklight   := true;
   _ability   := uab_Advance;
   _ability_no_obstacles:=true;
   _fastdeath_hits[false]:=-30;
   _fastdeath_hits[true ]:=1;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_4hfps,MID_BPlasma,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive_fly   ,wpr_adv +wpr_air   ,uidall,[],0,0,wtp_unit_mech);
   _weapon(1,wpt_missle,aw_srange,0,0 ,fr_4hfps,MID_BPlasma,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive_ground,wpr_nadv+wpr_ground,uidall,[],0,0,wtp_unit_mech);
end;
UID_ZBFG:
begin
   _mhits     := 200;
   _renergy   := 400;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 18;
   _painc     := 4;
   _btime     := 60;
   _attack    := atm_always;
   _uklight   := true;
   _limituse  := 200;
   _fdeathhits(-30);
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_2fps,MID_BFG,0,0,0,upgr_hell_dattack,5,wtrset_enemy_alive,wpr_any ,uidall,[fr_fps],0,0,wtp_rmhits);
end;


//         UAC BUILDINGS   /////////////////////////////////////////////////////
UID_HCommandCenter,
UID_UCommandCenter:
begin
   _mhits     := 3500;
   _renergy   := 800;
   _genergy   := 300;
   _speed     := 0;
   _r         := 66;
   _srange    := 280;
   _ucl       := 0;
   _btime     := 90;
   _attack    := atm_always;
   _ability   := uab_advance;
   _ukbuilding:= true;
   _isbuilder := true;
   _slowturn  := false;

   if(i=UID_HCommandCenter)then
   begin
      _ucl             := 3;
      _apcm            := 30;
      ups_builder      :=[UID_HCommandCenter,UID_HSymbol,UID_HTower,UID_HMilitaryUnit];
      ups_apc          :=demons;
      _ruid1           := UID_HCommandCenter;
      _upgr_srange     :=upgr_hell_mainr;
      _upgr_srange_step:=40;
      _weapon(0,wpt_missle,_srange,_r,0,fr_2hfps,MID_Imp      ,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive,wpr_any+wpr_move,uidall-[UID_Imp],[],3,-65,wtp_unit_bio_nlight);
      _weapon(1,wpt_missle,_srange,_r,0,fr_fps  ,MID_Cacodemon,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive,wpr_any+wpr_move,       [UID_Imp],[],3,-65,wtp_hits );
   end
   else
   begin
      _ability_rupgr   :=upgr_uac_mainm;
      _ability_rupgrl  :=1;
      _zombie_uid      := UID_HCommandCenter;
      ups_builder      :=[UID_UCommandCenter..UID_UNuclearPlant]-[UID_UAGenerator];
      _upgr_srange     :=upgr_uac_mainr;
      _upgr_srange_step:=40;
      _weapon(0,wpt_missle,_srange,_r,0 ,fr_2hfps,MID_BPlasma,0,upgr_uac_ccturr,1,upgr_uac_attack,1,wtrset_enemy_alive     ,wpr_any+wpr_move,uidall,[],3,-65,wtp_unit_mech);
   end;
end;

UID_HMilitaryUnit,
UID_UMilitaryUnit:
begin
   _mhits     := 2500;
   _renergy   := 200;
   _r         := 66;
   _ucl       := 1;
   _btime     := 60;
   _ukbuilding:= true;
   _isbarrack := true;

   if(i=UID_HMilitaryUnit)then
   begin
      _ucl       := 4;
      ups_units  := zimbas;
      _ruid1     := UID_HCommandCenter;
   end
   else
   begin
      ups_units  := marines;
      _zombie_uid:= UID_HMilitaryUnit;
   end;
end;
UID_UFactory:
begin
   _mhits     := 2500;
   _renergy   := 200;
   _r         := 66;
   _ucl       := 4;
   _btime     := 60;
   _ukbuilding:= true;
   _isbarrack := true;

   ups_units:=[UID_APC,UID_FAPC,UID_UACBot,UID_Terminator,UID_Tank,UID_Flyer];
end;

UID_UGenerator,
UID_UAGenerator:
begin
   _mhits     := 400;
   _genergy   := 20;
   _renergy   := _genergy*2;
   _r         := 42;
   _ucl       := 2;
   _btime     := 30;
   _ukbuilding:= true;
   if(i=UID_UAGenerator)then
   begin
      _renergy:=0;
      _btime :=_btime+(_btime div 2);
      _genergy:=_genergy*2;
      _ucl   :=5;
   end
   else _ability   := uab_rebuild;
end;

UID_UWeaponFactory:
begin
   _mhits     := 2500;
   _renergy   := 200;
   _r         := 62;
   _ucl       := 9;
   _btime     := 60;
   _ukbuilding:= true;
   _issmith   := true;

   ups_upgrades := [];
end;

UID_UTechCenter :
begin
   _mhits     := 2500;
   _renergy   := 600;
   _r         := 62;
   _ucl       := 10;
   _btime     := 60;
   _ability   := uab_uac__unit_adv;
   _ukbuilding:= true;
end;
UID_UNuclearPlant:
begin
   _mhits     := 3500;
   _renergy   := 600;
   _genergy   := 300;
   _r         := 70;
   _ucl       := 11;
   _btime     := 60;
   _ability   := uab_building_adv;
   _ukbuilding:= true;
   _addon     := true;
end;

UID_URadar:
begin
   _mhits     := 500;
   _renergy   := 200;
   _r         := 35;
   _srange    := 200;
   _ucl       := 12;
   _btime     := 60;
   _limituse  := 400;
   _ability   := uab_radar;
   _ukbuilding:= true;
end;
UID_URMStation:
begin
   _mhits     := 500;
   _renergy   := 200;
   _r         := 40;
   _ucl       := 13;
   _btime     := 60;
   _limituse  := 200;
   _ruid1     := UID_UTechCenter;
   _ruid2     := UID_UNuclearPlant;
   _ability   := uab_uac_rstrike;
   _ukbuilding:= true;
   _addon     := true;
end;

UID_UGTurret:
begin
   _mhits     := 750;
   _renergy   := 100;
   _r         := 15;
   _srange    := 250;
   _ucl       := 6;
   _btime     := 15;
   _attack    := atm_always;
   _ukbuilding:= true;
   _upgr_armor:= upgr_uac_turarm;
   _ability   := uab_rebuild;
   _upgr_srange     :=upgr_uac_towers;
   _upgr_srange_step:=25;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_4hfps,MID_Bulletx2,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground_light_bio,wpr_any,uidall,[],0, 0,wtp_hits);
   _weapon(1,wpt_missle,aw_srange,0,0 ,fr_4hfps,MID_BPlasma ,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground_mech     ,wpr_adv,uidall,[],0,-8,wtp_hits);
   _weapon(2,wpt_missle,aw_srange,0,0 ,fr_4hfps,MID_Bulletx2,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground          ,wpr_any,uidall,[],0, 0,wtp_unit_bio_light);
end;
UID_UATurret:
begin
   _mhits     := 750;
   _renergy   := 100;
   _r         := 15;
   _srange    := 250;
   _ucl       := 7;
   _btime     := 15;
   _attack    := atm_always;
   _ukbuilding:= true;
   _upgr_armor:= upgr_uac_turarm;
   _ability   := uab_rebuild;
   _upgr_srange     :=upgr_uac_towers;
   _upgr_srange_step:=25;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_fps  ,MID_URocket,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_fly,wpr_any ,uidall,[],0,-8,wtp_hits);
end;

UID_UMine:
begin
   _mhits     := 25;
   _renergy   := 10;
   _r         := 5;
   _srange    := 100;
   _ucl       := 21;
   _btime     := 2;
   _ucl       := 21;
   _attack    := atm_always;
   _ukbuilding:= true;
   _issolid   := false;

   _weapon(0,wpt_missle,350,0,0 ,fr_4fps,MID_StunMine,0,0,0,0,0,wtrset_enemy_alive_ground,wpr_sspos,uidall-[UID_UMine],[fr_4fps-fr_fps],0,0,wtp_distance);
end;

///////////////////////////////////
UID_Engineer:
begin
   _mhits     := 200;
   _renergy   := 200;
   _r         := 12;
   _speed     := 13;
   _srange    := 200;
   _ucl       := 0;
   _btime     := 30;
   _attack    := atm_always;
   _zombie_uid:= UID_ZEngineer;
   _ability   := 0;
   _uklight   := true;
   _fdeathhits(-30);
   _weapon(0,wpt_heal  ,aw_hmelee,0,8 ,fr_fps,0          ,0,0,0,upgr_uac_melee ,4,wtrset_repair                 ,wpr_any,uidall,[],0,0,wtp_hits            );
   _weapon(1,wpt_missle,aw_srange,0,0 ,fr_fps,MID_MBullet,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground_mech,wpr_adv,uidall,[],0,0,wtp_unit_mech_nostun);
   _weapon(2,wpt_missle,aw_srange,0,0 ,fr_fps,MID_Bullet ,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground     ,wpr_any,uidall,[],0,0,wtp_unit_bio_light  );
end;
UID_Medic:
begin
   _mhits     := 200;
   _renergy   := 200;
   _r         := 12;
   _speed     := 13;
   _srange    := 200;
   _ucl       := 1;
   _btime     := 30;
   _attack    := atm_always;
   _zombie_uid:= UID_ZFormer;
   _uklight   := true;
   _fdeathhits(-30);
   _weapon(0,wpt_heal  ,aw_hmelee,0,8,fr_fps,0          ,0,0,0,upgr_uac_melee ,4,wtrset_heal                  ,wpr_any,uidall,[],0,0,wtp_hits           );
   _weapon(1,wpt_missle,aw_srange,0,0,fr_fps,MID_TBullet,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground_bio,wpr_adv,uidall,[],0,0,wtp_unit_bio_nostun);
   _weapon(2,wpt_missle,aw_srange,0,0,fr_fps,MID_Bullet ,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground    ,wpr_any,uidall,[],0,0,wtp_unit_bio_light );
end;
UID_Sergant:
begin
   _mhits     := 200;
   _renergy   := 100;
   _r         := 12;
   _speed     := 12;
   _srange    := 241;
   _ucl       := 2;
   _btime     := 30;
   _attack    := atm_always;
   _zombie_uid:= UID_ZSergant;
   _uklight   := true;
   _fdeathhits(-30);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_2h3fps,MID_SSShot,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground,wpr_adv ,uidall,[],0,0,wtp_unit_bio_nlight);
   _weapon(1,wpt_missle,aw_srange,0,0,fr_fps   ,MID_SShot ,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground,wpr_nadv,uidall,[],0,0,wtp_unit_bio_nlight);
end;
UID_Commando:
begin
   _mhits     := 200;
   _renergy   := 100;
   _r         := 12;
   _speed     := 11;
   _srange    := 250;
   _ucl       := 3;
   _btime     := 30;
   _attack    := atm_always;
   _zombie_uid:= UID_ZCommando;
   _uklight   := true;
   _fdeathhits(-30);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_8hfps,MID_Bullet,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive,wpr_any ,uidall,[],0,0,wtp_unit_bio_light);
end;
UID_Bomber:
begin
   _mhits     := 200;
   _renergy   := 200;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 4;
   _btime     := 45;
   _attack    := atm_always;
   _zombie_uid:= UID_ZBomber;
   _uklight   := true;
   _ruid1     := UID_UWeaponFactory;
   _fdeathhits(-30);
   _weapon(0,wpt_missle,aw_srange,rocket_sr,0 ,fr_2h3fps,MID_Granade,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground_buildings,wpr_adv ,uidall,[],0,-4,wtp_hits);
   _weapon(1,wpt_missle,aw_srange,0        ,0 ,fr_2h3fps,MID_URocket,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_fly             ,wpr_any ,uidall,[],0,-4,wtp_hits);
   _weapon(2,wpt_missle,aw_srange,rocket_sr,0 ,fr_2h3fps,MID_Granade,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground          ,wpr_adv ,uidall,[],0,-4,wtp_hits);
   _weapon(3,wpt_missle,aw_srange,rocket_sr,0 ,fr_2h3fps,MID_URocket,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground          ,wpr_nadv,uidall,[],0,-4,wtp_hits);
end;
UID_Major:
begin
   _mhits     := 200;
   _renergy   := 200;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 5;
   _btime     := 30;
   _attack    := atm_always;
   _zombie_uid:= UID_ZMajor;
   _uklight   := true;
   _ruid1     := UID_UWeaponFactory;
   _ability   := uab_advance;
   _ability_no_obstacles:=true;
   _ability_rupgr :=upgr_uac_jetpack;
   _ability_rupgrl:=1;
   _fastdeath_hits[false]:=-30;
   _fastdeath_hits[true ]:=1;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_4hfps,MID_BPlasma,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive_fly   ,wpr_adv +wpr_air   ,uidall,[],0,0,wtp_unit_mech);
   _weapon(1,wpt_missle,aw_srange,0,0 ,fr_4hfps,MID_BPlasma,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive_ground,wpr_nadv+wpr_ground,uidall,[],0,0,wtp_unit_mech);
end;
UID_BFG:
begin
   _mhits     := 200;
   _renergy   := 400;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 6;
   _btime     := 60;
   _attack    := atm_always;
   _zombie_uid:= UID_ZBFG;
   _uklight   := true;
   _limituse  := 200;
   _ruid1     := UID_UTechCenter;
   _fdeathhits(-30);
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_2fps,MID_BFG,0,0,0,upgr_uac_attack,5,wtrset_enemy_alive,wpr_any,uidall,[fr_fps],0,0,wtp_rmhits);
end;
UID_FAPC:
begin
   _mhits     := 400;
   _renergy   := 100;
   _r         := 33;
   _speed     := 22;
   _srange    := 250;
   _ucl       := 7;
   _btime     := 30;
   _apcm      := 10;
   _apcs      := 8;
   _ukfly     := uf_fly;
   _attack    := atm_none;
   _ukmech    := true;
   _slowturn  := true;

   ups_apc    :=marines+[UID_APC,UID_UACBot,UID_Terminator,UID_Tank];
end;
UID_APC:
begin
   _mhits     := 600;
   _renergy   := 100;
   _r         := 25;
   _speed     := 15;
   _srange    := 250;
   _ucl       := 8;
   _btime     := 30;
   _apcm      := 4;
   _apcs      := 10;
   _attack    := atm_bunker;
   _ukmech    := true;
   _slowturn  := true;
   _splashresist:=true;

   ups_apc    :=marines;
end;
UID_UACBot:
begin
   _mhits     := 600;
   _renergy   := 200;
   _r         := 15;
   _speed     := 14;
   _srange    := 250;
   _ucl       := 9;
   _btime     := 30;
   _apcs      := 2;
   _limituse  := 300;
   _attack    := atm_always;
   _ukmech    := true;
   _uklight   := true;
   _ukfloater := true;
   _addon     := true;
   _ability   := uab_buildturret;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_4hfps,MID_BPlasma,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground,wpr_any,uidall,[],0,0,wtp_unit_mech);
end;
UID_Terminator:
begin
   _mhits     := 800;
   _renergy   := 300;
   _r         := 16;
   _speed     := 14;
   _srange    := 250;
   _ucl       := 10;
   _btime     := 45;
   _apcs      := 3;
   _limituse  := 400;
   _attack    := atm_always;
   _ukmech    := true;
   _addon     := true;
   _ruid1     := UID_UWeaponFactory;
   _weapon(0,wpt_missle,aw_srange,0,0,fr_4hfps ,MID_Bulletx2,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground,wpr_adv ,uidall,[],0,0,wtp_unit_bio_light );
   _weapon(1,wpt_missle,aw_srange,0,0,fr_2h3fps,MID_SSShot  ,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground,wpr_adv ,uidall,[],0,0,wtp_unit_bio_nlight);
   _weapon(2,wpt_missle,aw_srange,0,0,fr_7hfps ,MID_Bullet  ,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground,wpr_nadv,uidall,[],0,0,wtp_unit_bio_light );
   _weapon(3,wpt_missle,aw_srange,0,0,fr_fps   ,MID_SShot   ,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground,wpr_nadv,uidall,[],0,0,wtp_unit_bio_nlight);
end;
UID_Tank:
begin
   _mhits     := 1000;
   _renergy   := 400;
   _r         := 20;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 11;
   _btime     := 45;
   _apcs      := 7;
   _limituse  := 500;
   _attack    := atm_always;
   _ukmech    := true;
   _addon     := true;
   _splashresist:=true;
   _ruid1     := UID_UWeaponFactory;
   _weapon(0,wpt_missle,aw_fsr+100,rocket_sr,2 ,fr_2h3fps,MID_Tank,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground,wpr_adv ,uidall,[],0,0,wtp_building);
   _weapon(1,wpt_missle,aw_srange ,rocket_sr,2 ,fr_2h3fps,MID_Tank,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground,wpr_nadv,uidall,[],0,0,wtp_building);
end;
UID_Flyer:
begin
   _mhits     := 800;
   _renergy   := 400;
   _r         := 18;
   _speed     := 20;
   _srange    := 300;
   _ucl       := 12;
   _btime     := 45;
   _apcs      := 7;
   _ukfly     := uf_fly;
   _limituse  := 400;
   _attack    := atm_always;
   _ukmech    := true;
   _addon     := true;
   _ruid1     := UID_UTechCenter;
   _weapon(0,wpt_missle   ,aw_srange ,0,0 ,fr_2hfps ,MID_Flyer  ,0,0,0,upgr_uac_attack,2,wtrset_enemy_alive_fly   ,wpr_any,uidall,[],0,0,wtp_hits    );
   _weapon(1,wpt_missle   ,aw_fsr-100,0,0 ,fr_2h3fps,MID_Granade,0,0,0,upgr_uac_attack,4,wtrset_enemy_alive_ground,wpr_adv,uidall,[],0,0,wtp_building);
end;


UID_UTransport:
begin
   _mhits     := 1000;
   _renergy   := 200;
   _r         := 36;
   _speed     := 10;
   _srange    := 200;
   _ucl       := 13;
   _btime     := 60;
   _apcm      := 30;
   _apcs      := 10;
   _ruid1     := UID_UTechCenter;
   _ukfly     := uf_fly;
   _ukmech    := true;
   _slowturn  := true;
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

      _missile_r:=trunc(_r/1.4);

      if(_issmith)and(ups_upgrades=[])then
       for u:=1 to 255 do
        with _upids[u] do
         if(_up_time>0)and(_urace=_up_race)then ups_upgrades+=[u];

      if(_ukbuilding)then
      begin
         _zombie_hits:=_mhits div 2;
         _ukmech     :=true;
         if(_base_armor<=0)then _base_armor:=5;
         if(_srange    <=0)then _srange:=150;
      end
      else
      begin
         if(_base_armor<=0)and(_ukmech)then _base_armor:=3;
      end;

      _shcf:=_mhits/_mms;

      if(_btime> 0)then _bstep:=(_mhits div 2) div _btime;
      if(_bstep<=0)then _bstep:=1;
      _tprod:=_btime*fr_fps;

      //if(_limituse<10)then
   end;
end;


procedure _setUPGR(rc,upcl,stime,max,enrg:integer;rupgr,ruid:byte;mfrg,addon:boolean);
begin
   with _upids[upcl] do
   begin
      _up_ruid  := ruid;
      _up_rupgr := rupgr;
      _up_race  := rc;
      _up_time  := stime*fr_fps;
      _up_renerg:= enrg;
      _up_max   := max;
      _up_mfrg  := mfrg;
      _up_addon := addon;
   end;
end;


procedure ObjTbl;
var u:integer;
begin
   for u:=0 to MaxUnits do _punits[u]:=@_units[u];

   FillChar(_upids,SizeOf(_upids),0);

   //         race id                  time lvl  enr  rupgr         ruid                multi doom2
   _setUPGR(r_hell,upgr_hell_dattack   ,180,3   ,500 ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_uarmor    ,180,3   ,500 ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_barmor    ,180,3   ,400 ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_mattack   ,60 ,3   ,400 ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_regen     ,60 ,2   ,300 ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_pains     ,30 ,3   ,100 ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_heye      ,30 ,3   ,50  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_towers    ,60 ,3   ,200 ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_teleport  ,120,2   ,200 ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_hktele    ,180,1   ,200 ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_paina     ,60 ,2   ,100 ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_mainr     ,60 ,2   ,200 ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_hktdoodads,60 ,1   ,100 ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_pinkspd   ,60 ,1   ,200 ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_revtele   ,60 ,1   ,200 ,0            ,UID_HMonastery     ,false,false);
   _setUPGR(r_hell,upgr_hell_6bld      ,20 ,15  ,200 ,0            ,UID_HMonastery     ,true ,false);
   _setUPGR(r_hell,upgr_hell_9bld      ,60 ,1   ,200 ,0            ,UID_HMonastery     ,false,true );
   _setUPGR(r_hell,upgr_hell_revmis    ,30 ,1   ,200 ,0            ,UID_HMonastery     ,false,true );
   _setUPGR(r_hell,upgr_hell_totminv   ,60 ,1   ,200 ,0            ,UID_HAltar         ,false,true );
   _setUPGR(r_hell,upgr_hell_bldrep    ,60 ,3   ,200 ,0            ,UID_HAltar         ,false,true );
   _setUPGR(r_hell,upgr_hell_b478tel   ,30 ,15  ,50  ,0            ,UID_HAltar         ,true ,true );
   _setUPGR(r_hell,upgr_hell_invuln    ,180,1   ,400 ,0            ,UID_HAltar         ,true ,true );

   _setUPGR(r_uac ,upgr_uac_attack     ,180,3   ,500 ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_uarmor     ,120,4   ,400 ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_barmor     ,180,3   ,400 ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_melee      ,60 ,2   ,300 ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_mspeed     ,60 ,1   ,300 ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_plasmt     ,60 ,1   ,100 ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_detect     ,30 ,1   ,50  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_towers     ,60 ,3   ,200 ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_radar_r    ,60 ,3   ,100 ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_mainm      ,120,1   ,200 ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_ccturr     ,120,1   ,200 ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_mainr      ,60 ,2   ,200 ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_ccldoodads ,60 ,1   ,100 ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_airsp      ,60 ,1   ,200 ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_jetpack    ,60 ,1   ,200 ,0            ,UID_UTechCenter    ,false,false);
   _setUPGR(r_uac ,upgr_uac_6bld       ,120,1   ,200 ,0            ,UID_UTechCenter    ,false,false);
   _setUPGR(r_uac ,upgr_uac_9bld       ,60 ,1   ,200 ,0            ,UID_UTechCenter    ,false,true );
   _setUPGR(r_uac ,upgr_uac_mechspd    ,60 ,1   ,200 ,0            ,UID_UTechCenter    ,false,true );
   _setUPGR(r_uac ,upgr_uac_mecharm    ,180,3   ,300 ,0            ,UID_UTechCenter    ,false,true );
   _setUPGR(r_uac ,upgr_uac_turarm     ,60 ,2   ,200 ,0            ,UID_UTechCenter    ,false,true );
   _setUPGR(r_uac ,upgr_uac_rstrike    ,120,3   ,300 ,0            ,UID_UTechCenter    ,true ,true );

   //                                      wtr_owner_p wtr_owner_a wtr_owner_e wtr_hits_h wtr_hits_d wtr_hits_a wtr_bio wtr_mech wtr_building wtr_bld wtr_nbld wtr_ground wtr_fly wtr_adv wtr_nadv wtr_light wtr_nlight wtr_stun wtr_nostun;
   wtrset_enemy                          :=                        wtr_owner_e+wtr_hits_h+wtr_hits_d+wtr_hits_a+wtr_bio+wtr_mech+wtr_building+wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive                    :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_building+wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_light              :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_building+wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+           wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground             :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_building+wtr_bld+wtr_nbld+wtr_ground        +wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
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
