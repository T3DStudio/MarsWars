
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

         if(_bornadvanced[g_addon])then buff[ub_advanced]:=_ub_infinity;

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
const aw_srange =  0;  // attack range = sight range
      aw_dmelee = -8;  // default melee range
      aw_hmelee = -64; // default heal/reapir melee range
var i,a:byte;

procedure _weapon(aa,wtype:byte;max_range,min_range,count:integer;reload,oid,ruid,rupid,rupidl,dupgr:byte;dupgrs:integer;tarf,reqf:cardinal;uids,reload_s:TSoB;ax,ay:integer);
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
      _max       := 32000;
      _btime     := 1;
      _ukfly     := uf_ground;
      _ucl       := 255;
      _apcs      := 1;
      _urace     := r_hell;
      _attack    := atm_none;
      _srange    := 250;
      _fdeathhits(-32000);

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
   _mhits     := 5000;
   _renerg    := 200;
   _generg    := 100;
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
   _mhits     := 3000;
   _renerg    := 200;
   _r         := 60;
   _srange    := 150;
   _ucl       := 1;
   _btime     := 45;
   _barrack_teleport:=true;
   _ukbuilding:= true;
   _isbarrack := true;
   ups_units  := [UID_LostSoul..UID_Archvile];
end;

UID_HSymbol,
UID_HASymbol:
begin
   _mhits     := 200;
   _renerg    := 10;
   _generg    := 10;
   _r         := 22;
   _srange    := 150;
   _ucl       := 2;
   _btime     := 10;
   _ukbuilding:= true;

   if(i=UID_HASymbol)then
   begin
      _renerg:=0;
      _btime :=_btime*2;
      _generg:=_generg*2;
      _ucl   :=5;
   end
   else _ability:= uab_rebuild;
end;

UID_HPools:
begin
   _mhits     := 3000;
   _renerg    := 200;
   _r         := 53;
   _srange    := 150;
   _ucl       := 9;
   _btime     := 45;
   _ukbuilding:= true;
   _issmith   := true;
   ups_upgrades := [];
end;

UID_HMonastery:
begin
   _mhits     := 3000;
   _renerg    := 200;
   _generg    := 200;
   _r         := 65;
   _srange    := 150;
   _ucl       := 10;
   _btime     := 60;
   _max       := 1;
   _ability   := uab_hell_unit_adv;
   _ruid1     := UID_HPools;
   _ukbuilding:= true;
end;
UID_HFortress:
begin
   _mhits     := 6000;
   _renerg    := 300;
   _generg    := 300;
   _r         := 86;
   _srange    := 300;
   _ucl       := 11;
   _btime     := 90;
   _max       := 1;
   _ability   := uab_building_adv;
   _ruid1     := UID_HPools;
   _ukbuilding:= true;
end;

UID_HTeleport:
begin
   _mhits     := 1000;
   _renerg    := 200;
   _r         := 28;
   _srange    := 150;
   _ucl       := 12;
   _btime     := 30;
   _limituse  := 3;
   _ability   := uab_teleport;
   _ukbuilding:= true;
   _issolid   := false;
end;
UID_HAltar:
begin
   _mhits     := 1000;
   _renerg    := 200;
   _r         := 50;
   _srange    := 150;
   _ucl       := 13;
   _btime     := 30;
   _max       := 1;
   _ruid1     := UID_HMonastery;
   _ruid2     := UID_HFortress;
   _ukbuilding:= true;
   _addon     := true;
   _ability   := uab_hinvuln;
end;

UID_HTower:
begin
   _mhits     := 1500;
   _renerg    := 50;
   _r         := 20;
   _srange    := 250;
   _ucl       := 6;
   _btime     := 20;
   _attack    := atm_always;
   _ability   := uab_htowertele;
   _ukbuilding:= true;
   _upgr_srange     :=upgr_hell_towers;
   _upgr_srange_step:=25;
   _weapon(0,wpt_missle,aw_srange,0,0 ,fr_3h2fps,MID_Revenant ,0,0,0,upgr_hell_dattack,2,wtrset_enemy_alive_fly,wpr_any,uidall,[],0,-26);
   _weapon(1,wpt_missle,aw_srange,0,0 ,fr_3h2fps,MID_Cacodemon,0,0,0,upgr_hell_dattack,2,wtrset_enemy_alive    ,wpr_any,uidall,[],0,-26);

end;
UID_HTotem:
begin
   _mhits     := 1500;
   _renerg    := 200;
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
   _weapon(0,wpt_missle,aw_srange,0,0,140,MID_ArchFire,0,0,0,upgr_hell_dattack,5,wtrset_enemy_alive_nbuildings,wpr_any+wpr_tvis,uidall,[65],0,0);
end;

UID_HEye:
begin
   _mhits     := (fr_fps*60) div regen_period;
   _renerg    := 10;
   _r         := 5;
   _srange    := 150;
   _ucl       := 21;
   _btime     := 1;
   _rupgr     := upgr_hell_heye;
   _ukbuilding:= true;
   _issolid   := false;
   _upgr_srange     :=upgr_hell_heye;
   _upgr_srange_step:=100;
   _baseregen :=-1;
end;

//////////////////////////////

UID_LostSoul   :
begin
   _mhits     := 200;
   _renerg    := 50;
   _r         := 10;
   _speed     := 23;
   _srange    := 250;
   _ucl       := 0;
   _painc     := 1;
   _btime     := 10;
   _ukfly     := uf_fly;
   _attack    := atm_always;
   _ability   := uab_morph2heye;
   _ability_rupgr :=upgr_hell_heye;
   _ability_rupgrl:=1;
   _uklight   := true;
   _fdeathhits(1);
   _weapon(0,wpt_directdmg,aw_dmelee,0,20,fr_3h2fps,0,0,0,0,upgr_hell_mattack,3,wtrset_enemy          ,wpr_adv+wpr_zombie,uidall,[],0,0);
   _weapon(1,wpt_directdmg,aw_dmelee,0,20,fr_3h2fps,0,0,0,0,upgr_hell_mattack,3,wtrset_enemy_alive_bio,wpr_any           ,uidall,[],0,0);
   _weapon(2,wpt_directdmg,aw_dmelee,0,20,fr_3h2fps,0,0,0,0,upgr_hell_mattack,3,wtrset_enemy_alive    ,wpr_any           ,uidall,[],0,0);
end;
UID_Imp        :
begin
   _mhits     := 200;
   _renerg    := 100;
   _r         := 11;
   _speed     := 9;
   _srange    := 250;
   _ucl       := 1;
   _painc     := 3;
   _btime     := 20;
   _attack    := atm_always;
   _uklight   := true;
   _fdeathhits(-30);
   _weapon(0,wpt_missle    ,aw_srange,0,0 ,fr_3h2fps,MID_Imp,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_nlight_bio,wpr_adv ,uidall-[UID_Imp],[],0,-5);
   _weapon(1,wpt_missle    ,aw_srange,0,0 ,fr_3h2fps,MID_Imp,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive           ,wpr_adv ,uidall-[UID_Imp],[],0,-5);
   _weapon(2,wpt_missle    ,aw_srange,0,0 ,fr_fps   ,MID_Imp,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_nlight_bio,wpr_nadv,uidall-[UID_Imp],[],0,-5);
   _weapon(3,wpt_missle    ,aw_srange,0,0 ,fr_fps   ,MID_Imp,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive           ,wpr_nadv,uidall-[UID_Imp],[],0,-5);
   _weapon(4,wpt_directdmg ,aw_dmelee,0,10,fr_fps   ,0      ,0,0,0,upgr_hell_mattack,3,wtrset_enemy_alive_ground    ,wpr_any,        [UID_Imp],[],0, 0);
end;
UID_Demon      :
begin
   _mhits     := 400;
   _renerg    := 200;
   _r         := 14;
   _speed     := 14;
   _srange    := 200;
   _ucl       := 2;
   _painc     := 8;
   _btime     := 20;
   _attack    := atm_always;
   _weapon(0,wpt_directdmg,aw_dmelee,0,35,fr_2hfps,0      ,0,upgr_hell_pinkspd,1,upgr_hell_mattack,3,wtrset_enemy_alive_ground,wpr_any ,uidall,[],0,0);
   _weapon(1,wpt_directdmg,aw_dmelee,0,35,fr_fps  ,0      ,0,0                ,0,upgr_hell_mattack,3,wtrset_enemy_alive_ground,wpr_any ,uidall,[],0,0);
end;
UID_Cacodemon  :
begin
   _mhits     := 400;
   _renerg    := 200;
   _r         := 14;
   _speed     := 9;
   _srange    := 250;
   _ucl       := 3;
   _painc     := 6;
   _btime     := 20;
   _apcs      := 2;
   _ukfly     := uf_fly;
   _ruid1     := UID_HPools;
   _attack    := atm_always;
   _zfall     := fly_height[uf_fly];
   _weapon(0,wpt_missle   ,300      ,0,0 ,fr_fps   ,MID_Cacodemon,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive    ,wpr_adv ,uidall-[UID_Cacodemon],[],0,0);
   _weapon(1,wpt_missle   ,aw_srange,0,0 ,fr_fps   ,MID_Cacodemon,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive    ,wpr_nadv,uidall-[UID_Cacodemon],[],0,0);
   _weapon(2,wpt_directdmg,aw_dmelee,0,20,fr_fps   ,0            ,0,0,0,upgr_hell_mattack,3,wtrset_enemy_alive_fly,wpr_any ,       [UID_Cacodemon],[],0,0);
end;
UID_Baron      :
begin
   _mhits     := 600;
   _renerg    := 200;
   _r         := 14;
   _speed     := 9;
   _srange    := 250;
   _ucl       := 4;
   _painc     := 8;
   _btime     := 20;
   _apcs      := 3;
   _limituse  := 2;
   _ruid1     := UID_HPools;
   _attack    := atm_always;
   _bornadvanced[false]:=true;
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_fps   ,MID_Baron,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_ground,wpr_any ,uidall-[UID_Baron],[],0,0);
   _weapon(2,wpt_directdmg,aw_dmelee,0,40,fr_fps   ,0        ,0,0,0,upgr_hell_mattack,3,wtrset_enemy_alive_ground,wpr_any ,       [UID_Baron],[],0,0);
end;
UID_Cyberdemon :
begin
   _mhits     := 4000;
   _renerg    := 300;
   _max       := 1;
   _r         := 20;
   _speed     := 11;
   _srange    := 250;
   _ucl       := 5;
   _painc     := 15;
   _btime     := 90;
   _apcs      := 10;
   _ruid1     := UID_HPools;
   _ruid2     := UID_HMonastery;
   _attack    := atm_always;
   _splashresist:=true;
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_fps   ,MID_HRocket,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_buildings,wpr_any,uidall,[],0,0);
   _weapon(1,wpt_missle   ,aw_srange,0,0 ,fr_fps   ,MID_HRocket,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive          ,wpr_any,uidall,[],0,0);
end;
UID_Mastermind :
begin
   _mhits     := 4000;
   _renerg    := 300;
   _max       := 1;
   _r         := 35;
   _speed     := 11;
   _srange    := 275;
   _ucl       := 6;
   _painc     := 15;
   _btime     := 90;
   _apcs      := 10;
   _ruid1     := UID_HPools;
   _ruid2     := UID_HMonastery;
   _attack    := atm_always;
   _splashresist:=true;
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_7hfps,MID_Bulletx2,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive_bio,wpr_any,uidall,[],0,0);
   _weapon(1,wpt_missle   ,aw_srange,0,0 ,fr_7hfps,MID_Bulletx2,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive    ,wpr_any,uidall,[],0,0);
end;
UID_Pain      :
begin
   _mhits     := 400;
   _renerg    := 200;
   _r         := 14;
   _speed     := 9;
   _srange    := 250;
   _ucl       := 7;
   _painc     := 3;
   _btime     := 40;
   _apcs      := 2;
   _ruid1     := UID_HMonastery;
   _ukfly     := uf_fly;
   _attack    := atm_always;
   _ability   := uab_spawnlost;
   _addon     := true;
   _weapon(0,wpt_unit,_srange+100,0,0 ,fr_2h3fps,UID_LostSoul,0,0,0,0,0,wtrset_enemy_alive,wpr_any,uidall,[],0,0);
   _fdeathhits(1);
end;
UID_Revenant   :
begin
   _mhits     := 400;
   _renerg    := 200;
   _r         := 13;
   _speed     := 12;
   _srange    := 250;
   _ucl       := 8;
   _painc     := 7;
   _btime     := 20;
   _ruid1     := UID_HMonastery;
   _limituse  := 2;
   _attack    := atm_always;
   _uklight   := true;
   _addon     := true;
   _weapon(0,wpt_missle   ,_srange+100,0,0 ,fr_fps   ,MID_Revenant ,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_fly   ,wpr_adv ,uidall-[UID_Revenant],[],0,-7);
   _weapon(1,wpt_missle   ,aw_srange  ,0,0 ,fr_fps   ,MID_Revenant ,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_fly   ,wpr_nadv,uidall-[UID_Revenant],[],0,-7);
   _weapon(2,wpt_missle   ,aw_srange  ,0,0 ,fr_fps   ,MID_Revenant ,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_ground,wpr_any ,uidall-[UID_Revenant],[],0,-7);
   _weapon(4,wpt_directdmg,aw_dmelee  ,0,20,fr_3h2fps,0            ,0,0,0,upgr_hell_mattack,3,wtrset_enemy_alive_ground,wpr_any ,       [UID_Revenant],[],0, 0);
end;
UID_Mancubus   :
begin
   _mhits     := 600;
   _renerg    := 200;
   _r         := 20;
   _speed     := 6;
   _srange    := 250;
   _ucl       := 9;
   _painc     := 4;
   _btime     := 60;
   _ruid1     := UID_HFortress;
   _limituse  := 3;
   _attack    := atm_always;
   _addon     := true;
   _weapon(0,wpt_missle   ,_srange+50,0,-8,fr_mancubus_r,MID_Mancubus,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_buildings,wpr_any ,uidall-[UID_Mancubus],[110,70,30],0,0);
   _weapon(1,wpt_missle   ,_srange+50,0,-8,fr_mancubus_r,MID_Mancubus,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive          ,wpr_any ,uidall-[UID_Mancubus],[110,70,30],0,0);
end;
UID_Arachnotron:
begin
   _mhits     := 600;
   _renerg    := 200;
   _r         := 20;
   _speed     := 8;
   _srange    := 250;
   _ucl       := 10;
   _painc     := 4;
   _btime     := 60;
   _ruid1     := UID_HFortress;
   _limituse  := 3;
   _attack    := atm_always;
   _addon     := true;
   _weapon(0,wpt_missle   ,_srange+75,0,0 ,fr_4hfps,MID_YPlasma,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive_mech  ,wpr_adv ,uidall-[UID_Arachnotron],[],0,0);
   _weapon(1,wpt_missle   ,_srange   ,0,0 ,fr_4hfps,MID_YPlasma,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive_mech  ,wpr_nadv,uidall-[UID_Arachnotron],[],0,0);
   _weapon(2,wpt_missle   ,_srange+75,0,0 ,fr_4hfps,MID_YPlasma,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive       ,wpr_adv ,uidall-[UID_Arachnotron],[],0,0);
   _weapon(3,wpt_missle   ,_srange   ,0,0 ,fr_4hfps,MID_YPlasma,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive       ,wpr_nadv,uidall-[UID_Arachnotron],[],0,0);
end;
UID_Archvile:
begin
   _mhits     := 600;
   _renerg    := 200;
   _r         := 14;
   _speed     := 15;
   _srange    := 250;
   _ucl       := 11;
   _painc     := 12;
   _btime     := 90;
   _apcs      := 2;
   _ruid1     := UID_HAltar;
   _limituse  := 3;
   _attack    := atm_always;
   _addon     := true;
   _weapon(0,wpt_resurect,aw_dmelee,0,0  ,fr_fps,0           ,0,0,0,0                ,0,wtrset_resurect              ,wpr_adv         ,arch_res,[  ],0,0);
   _weapon(1,wpt_missle  ,450      ,0,0  ,140   ,MID_ArchFire,0,0,0,upgr_hell_dattack,5,wtrset_enemy_alive_nbuildings,wpr_any+wpr_tvis,uidall  ,[65],0,0);
end;

UID_ZFormer:
begin
   _mhits     := 100;
   _renerg    := 50;
   _r         := 12;
   _speed     := 13;
   _srange    := 250;
   _ucl       := 12;
   _painc     := 1;
   _btime     := 10;
   _attack    := atm_always;
   _uklight   := true;
   _fdeathhits(-25);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_2hfps ,MID_Bullet,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive,wpr_adv ,uidall,[],0,0);
   _weapon(1,wpt_missle,aw_srange,0,0,fr_3h2fps,MID_Bullet,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive,wpr_nadv,uidall,[],0,0);
end;
UID_ZEngineer:
begin
   _mhits     := 200;
   _renerg    := 100;
   _r         := 12;
   _speed     := 14;
   _srange    := 200;
   _ucl       := 13;
   _painc     := 4;
   _btime     := 20;
   _attack    := atm_always;
   _uklight   := true;
   _fdeathhits(1);
   _weapon(0,wpt_missle,-12,0,0,3,MID_Mine,0,0,0,upgr_uac_attack,5,wtrset_enemy_alive_ground,wpr_sspos+wpr_suicide,uidall,[],0,0);
end;
UID_ZSergant:
begin
   _mhits     := 150;
   _renerg    := 100;
   _r         := 12;
   _speed     := 13;
   _srange    := 241;
   _ucl       := 14;
   _painc     := 4;
   _btime     := 20;
   _attack    := atm_always;
   _uklight   := true;
   _fdeathhits(-30);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_2h3fps,MID_SSShot,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground_nlight_bio,wpr_adv ,uidall,[],0,0);
   _weapon(1,wpt_missle,aw_srange,0,0,fr_2h3fps,MID_SSShot,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground_bio       ,wpr_adv ,uidall,[],0,0);
   _weapon(2,wpt_missle,aw_srange,0,0,fr_2h3fps,MID_SSShot,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground           ,wpr_adv ,uidall,[],0,0);
   _weapon(3,wpt_missle,aw_srange,0,0,fr_fps   ,MID_SShot ,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground_nlight_bio,wpr_nadv,uidall,[],0,0);
   _weapon(4,wpt_missle,aw_srange,0,0,fr_fps   ,MID_SShot ,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground_bio       ,wpr_nadv,uidall,[],0,0);
   _weapon(5,wpt_missle,aw_srange,0,0,fr_fps   ,MID_SShot ,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground           ,wpr_nadv,uidall,[],0,0);
end;
UID_ZCommando:
begin
   _mhits     := 200;
   _renerg    := 100;
   _r         := 12;
   _speed     := 11;
   _srange    := 250;
   _ucl       := 15;
   _painc     := 4;
   _btime     := 20;
   _attack    := atm_always;
   _uklight   := true;
   _fdeathhits(-30);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_8hfps,MID_Bullet,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive,wpr_adv ,uidall,[],0,0);
   _weapon(1,wpt_missle,aw_srange,0,0,fr_7hfps,MID_Bullet,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive,wpr_nadv,uidall,[],0,0);
end;
UID_ZBomber:
begin
   _mhits     := 200;
   _renerg    := 200;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 16;
   _painc     := 4;
   _btime     := 20;
   _attack    := atm_always;
   _uklight   := true;
   _fdeathhits(-30);
   _weapon(0,wpt_missle   ,aw_srange,rocket_sr,0 ,fr_2h3fps,MID_Granade,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground_buildings,wpr_adv ,uidall,[],0,-4);
   _weapon(1,wpt_missle   ,aw_srange,rocket_sr,0 ,fr_2h3fps,MID_URocket,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_fly             ,wpr_any ,uidall,[],0,-4);
   _weapon(2,wpt_missle   ,aw_srange,rocket_sr,0 ,fr_2h3fps,MID_Granade,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground          ,wpr_adv ,uidall,[],0,-4);
   _weapon(3,wpt_missle   ,aw_srange,rocket_sr,0 ,fr_2h3fps,MID_URocket,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground          ,wpr_nadv,uidall,[],0,-4);
end;
UID_ZMajor:
begin
   _mhits     := 200;
   _renerg    := 200;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 17;
   _painc     := 4;
   _btime     := 20;
   _attack    := atm_always;
   _uklight   := true;
   _ability   := uab_Advance;
   _ability_no_obstacles:=true;
   _fastdeath_hits[false]:=-30;
   _fastdeath_hits[true ]:=1;
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_4hfps,MID_BPlasma,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_fly_mech     ,wpr_adv +wpr_air   ,uidall,[],0,0);
   _weapon(1,wpt_missle   ,aw_srange,0,0 ,fr_4hfps,MID_BPlasma,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_fly          ,wpr_adv +wpr_air   ,uidall,[],0,0);
   _weapon(2,wpt_missle   ,aw_srange,0,0 ,fr_4hfps,MID_BPlasma,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground_mech  ,wpr_nadv+wpr_ground,uidall,[],0,0);
   _weapon(3,wpt_missle   ,aw_srange,0,0 ,fr_4hfps,MID_BPlasma,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground       ,wpr_nadv+wpr_ground,uidall,[],0,0);
end;
UID_ZBFG:
begin
   _mhits     := 200;
   _renerg    := 200;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 18;
   _painc     := 4;
   _btime     := 60;
   _attack    := atm_always;
   _uklight   := true;
   _limituse  := 2;
   _fdeathhits(-30);
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_2fps,MID_BFG,0,0,0,upgr_uac_attack,5,wtrset_enemy_alive,wpr_any ,uidall,[fr_fps],0,0);
end;


//         UAC BUILDINGS   /////////////////////////////////////////////////////
UID_HCommandCenter,
UID_UCommandCenter:
begin
   _mhits     := 5000;
   _renerg    := 200;
   _generg    := 100;
   _speed     := 6;
   _r         := 66;
   _srange    := 280;
   _ucl       := 0;
   _btime     := 80;
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
      _upgr_srange     :=upgr_hell_mainr;
      _upgr_srange_step:=40;
      _weapon(0,wpt_missle,aw_srange,_r,0 ,fr_2hfps,MID_Imp,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive,wpr_any+wpr_move,uidall-[UID_Imp],[],3,-65);
      _weapon(1,wpt_missle,aw_srange,_r,0 ,fr_2hfps,MID_Imp,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive,wpr_any+wpr_move,uidall-[UID_Imp],[],3,-65);
   end
   else
   begin
      _ability_rupgr   :=upgr_uac_mainm;
      _ability_rupgrl  :=1;
      _zombie_uid      := UID_HCommandCenter;
      ups_builder      :=[UID_UCommandCenter..UID_UNuclearPlant]-[UID_UAGenerator];
      _upgr_srange     :=upgr_uac_mainr;
      _upgr_srange_step:=40;
      _weapon(0,wpt_missle,aw_srange,_r,0 ,fr_2hfps,MID_BPlasma,0,upgr_uac_ccturr,1,upgr_uac_attack,1,wtrset_enemy_alive_mech,wpr_any+wpr_move,uidall,[],3,-65);
      _weapon(1,wpt_missle,aw_srange,_r,0 ,fr_2hfps,MID_BPlasma,0,upgr_uac_ccturr,1,upgr_uac_attack,1,wtrset_enemy_alive     ,wpr_any+wpr_move,uidall,[],3,-65);
   end;
end;

UID_HMilitaryUnit,
UID_UMilitaryUnit:
begin
   _mhits     := 3000;
   _renerg    := 200;
   _r         := 66;
   _srange    := 200;
   _ucl       := 1;
   _btime     := 45;
   _ukbuilding:= true;
   _isbarrack := true;

   if(i=UID_HMilitaryUnit)then
   begin
      _ucl       := 4;
      ups_units  := zimbas;
   end
   else
   begin
      ups_units  := marines;
      _zombie_uid:= UID_HMilitaryUnit;
   end;
end;
UID_UFactory:
begin
   _mhits     := 3000;
   _renerg    := 200;
   _r         := 66;
   _srange    := 200;
   _ucl       := 4;
   _btime     := 45;
   _ukbuilding:= true;
   _isbarrack := true;

   ups_units:=[UID_APC,UID_FAPC,UID_UACBot,UID_Terminator,UID_Tank,UID_Flyer];
end;

UID_UGenerator,
UID_UAGenerator:
begin
   _mhits     := 400;
   _renerg    := 20;
   _generg    := 20;
   _r         := 42;
   _srange    := 200;
   _ucl       := 2;
   _btime     := 20;
   _ukbuilding:= true;
   if(i=UID_UAGenerator)then
   begin
      _renerg:=0;
      _btime :=_btime*2;
      _generg:=_generg*2;
      _ucl   :=5;
   end
   else _ability   := uab_rebuild;
end;

UID_UWeaponFactory:
begin
   _mhits     := 3000;
   _renerg    := 200;
   _r         := 62;
   _srange    := 200;
   _ucl       := 9;
   _btime     := 45;
   _ukbuilding:= true;
   _issmith   := true;

   ups_upgrades := [];
end;

UID_UTechCenter :
begin
   _mhits     := 3000;
   _renerg    := 200;
   _r         := 62;
   _srange    := 200;
   _ucl       := 10;
   _btime     := 60;
   _limituse  := 3;
   _ability   := uab_uac__unit_adv;
   _ruid1     := UID_UWeaponFactory;
   _ukbuilding:= true;
end;
UID_UNuclearPlant:
begin
   _mhits     := 4000;
   _renerg    := 300;
   _generg    := 300;
   _r         := 70;
   _srange    := 200;
   _ucl       := 11;
   _btime     := 90;
   _max       := 1;
   _ability   := uab_building_adv;
   _ukbuilding:= true;
   _ruid1     := UID_UWeaponFactory;
//   _ruid2     := UID_UTechCenter;
end;

UID_URadar:
begin
   _mhits     := 1000;
   _renerg    := 200;
   _r         := 35;
   _srange    := 200;
   _ucl       := 12;
   _btime     := 30;
   _limituse  := 3;
   _ability   := uab_radar;
   _ukbuilding:= true;
end;
UID_URMStation:
begin
   _mhits     := 1000;
   _renerg    := 200;
   _r         := 40;
   _srange    := 200;
   _ucl       := 13;
   _btime     := 30;
   _max       := 1;
   _ruid1     := UID_UTechCenter;
   _ruid2     := UID_UNuclearPlant;
   _ability   := uab_uac_rstrike;
   _ukbuilding:= true;
   _addon     := true;
end;

UID_UCTurret:
begin
   _mhits     := 1000;
   _renerg    := 50;
   _r         := 15;
   _srange    := 250;
   _ucl       := 6;
   _btime     := 15;
   _attack    := atm_always;
   _ukbuilding:= true;
   _upgr_armor:= upgr_uac_turarm;
   _ability   := uab_rebuild;
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_4hfps,MID_Bulletx2,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground_light_bio,wpr_any,uidall,[],0,0);
   _weapon(1,wpt_missle   ,aw_srange,0,0 ,fr_4hfps,MID_Bulletx2,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground_bio      ,wpr_any,uidall,[],0,0);
   _weapon(2,wpt_missle   ,aw_srange,0,0 ,fr_4hfps,MID_Bulletx2,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground          ,wpr_any,uidall,[],0,0);
end;
UID_UPTurret:
begin
   _mhits     := 1000;
   _renerg    := 50;
   _r         := 15;
   _srange    := 250;
   _ucl       := 7;
   _btime     := 15;
   _attack    := atm_always;
   _ukbuilding:= true;
   _upgr_armor:= upgr_uac_turarm;
   _ability   := uab_rebuild;
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_4hfps,MID_BPlasma,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground_mech  ,wpr_any,uidall,[],0,-8);
   _weapon(1,wpt_missle   ,aw_srange,0,0 ,fr_4hfps,MID_BPlasma,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground       ,wpr_any,uidall,[],0,-8);
end;
UID_URTurret:
begin
   _mhits     := 1000;
   _renerg    := 50;
   _r         := 15;
   _srange    := 250;
   _ucl       := 8;
   _btime     := 15;
   _attack    := atm_always;
   _ukbuilding:= true;
   _addon     := true;
   _upgr_armor:= upgr_uac_turarm;
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_fps  ,MID_URocket,0,0,0,upgr_uac_attack,4,wtrset_enemy_alive_fly          ,wpr_any ,uidall,[],0,-8);
end;

UID_UMine:
begin
   _mhits     := 5;
   _renerg    := 10;
   _r         := 5;
   _srange    := 100;
   _ucl       := 21;
   _btime     := 2;
   _ucl       := 21;
   _attack    := atm_always;
   _ukbuilding:= true;
   _issolid   := false;

   _weapon(0,wpt_missle,350,0,0 ,fr_4fps,MID_StunMine,0,0,0,0,0,wtrset_enemy_alive_ground,wpr_sspos,uidall-[UID_UMine],[fr_4fps-fr_fps],0,0);
end;

///////////////////////////////////
UID_Engineer:
begin
   _mhits     := 200;
   _renerg    := 100;
   _r         := 12;
   _speed     := 13;
   _srange    := 200;
   _ucl       := 0;
   _btime     := 10;
   _attack    := atm_always;
   _zombie_uid:= UID_ZEngineer;
   _ability   := uab_umine;
   _uklight   := true;
   _fdeathhits(-30);
   _weapon(0,wpt_heal  ,aw_hmelee,0,6,fr_3h2fps,0          ,0,0,0,upgr_uac_melee ,2,wtrset_repair                ,wpr_any,uidall,[],0,0);
   _weapon(1,wpt_missle,aw_srange,0,0,fr_3h2fps,MID_MBullet,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_mech_nstun,wpr_adv,uidall,[],0,0);
   _weapon(2,wpt_missle,aw_srange,0,0,fr_3h2fps,MID_MBullet,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_mech      ,wpr_adv,uidall,[],0,0);
   _weapon(3,wpt_missle,aw_srange,0,0,fr_3h2fps,MID_Bullet ,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive           ,wpr_any,uidall,[],0,0);
end;
UID_Medic:
begin
   _mhits     := 200;
   _renerg    := 100;
   _r         := 12;
   _speed     := 13;
   _srange    := 200;
   _ucl       := 1;
   _btime     := 10;
   _attack    := atm_always;
   _zombie_uid:= UID_ZFormer;
   _uklight   := true;
   _fdeathhits(-30);
   _weapon(0,wpt_heal  ,aw_hmelee,0,6,fr_3h2fps,0          ,0,0,0,upgr_uac_melee ,2,wtrset_heal                 ,wpr_any,uidall,[],0,0);
   _weapon(1,wpt_missle,aw_srange,0,0,fr_3h2fps,MID_TBullet,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_bio_nstun,wpr_adv,uidall,[],0,0);
   _weapon(2,wpt_missle,aw_srange,0,0,fr_3h2fps,MID_TBullet,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_bio      ,wpr_adv,uidall,[],0,0);
   _weapon(3,wpt_missle,aw_srange,0,0,fr_3h2fps,MID_Bullet ,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive          ,wpr_any,uidall,[],0,0);
end;
UID_Sergant:
begin
   _mhits     := 200;
   _renerg    := 100;
   _r         := 12;
   _speed     := 13;
   _srange    := 241;
   _ucl       := 2;
   _btime     := 20;
   _attack    := atm_always;
   _zombie_uid:= UID_ZSergant;
   _uklight   := true;
   _fdeathhits(-30);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_2h3fps,MID_SSShot,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground_nlight_bio,wpr_adv ,uidall,[],0,0);
   _weapon(1,wpt_missle,aw_srange,0,0,fr_2h3fps,MID_SSShot,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground_bio       ,wpr_adv ,uidall,[],0,0);
   _weapon(2,wpt_missle,aw_srange,0,0,fr_2h3fps,MID_SSShot,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground           ,wpr_adv ,uidall,[],0,0);
   _weapon(3,wpt_missle,aw_srange,0,0,fr_fps   ,MID_SShot ,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground_nlight_bio,wpr_nadv,uidall,[],0,0);
   _weapon(4,wpt_missle,aw_srange,0,0,fr_fps   ,MID_SShot ,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground_bio       ,wpr_nadv,uidall,[],0,0);
   _weapon(5,wpt_missle,aw_srange,0,0,fr_fps   ,MID_SShot ,0,0,0,upgr_uac_attack,3,wtrset_enemy_alive_ground           ,wpr_nadv,uidall,[],0,0);
end;
UID_Commando:
begin
   _mhits     := 200;
   _renerg    := 100;
   _r         := 12;
   _speed     := 11;
   _srange    := 250;
   _ucl       := 3;
   _btime     := 20;
   _attack    := atm_always;
   _zombie_uid:= UID_ZCommando;
   _uklight   := true;
   _fdeathhits(-30);
   _weapon(0,wpt_missle,aw_srange,0,0,fr_7hfps,MID_Bullet,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive,wpr_any,uidall,[],0,0);
end;
UID_Bomber:
begin
   _mhits     := 200;
   _renerg    := 100;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 4;
   _btime     := 20;
   _attack    := atm_always;
   _zombie_uid:= UID_ZBomber;
   _uklight   := true;
   _fdeathhits(-30);
   _weapon(0,wpt_missle   ,aw_srange,rocket_sr,0 ,fr_2h3fps,MID_Granade,0,0,0,upgr_uac_attack,4,wtrset_enemy_alive_ground_buildings,wpr_adv ,uidall,[],0,-4);
   _weapon(1,wpt_missle   ,aw_srange,0        ,0 ,fr_2h3fps,MID_URocket,0,0,0,upgr_uac_attack,4,wtrset_enemy_alive_fly             ,wpr_any ,uidall,[],0,-4);
   _weapon(2,wpt_missle   ,aw_srange,rocket_sr,0 ,fr_2h3fps,MID_Granade,0,0,0,upgr_uac_attack,4,wtrset_enemy_alive_ground          ,wpr_adv ,uidall,[],0,-4);
   _weapon(3,wpt_missle   ,aw_srange,rocket_sr,0 ,fr_2h3fps,MID_URocket,0,0,0,upgr_uac_attack,4,wtrset_enemy_alive_ground          ,wpr_nadv,uidall,[],0,-4);
end;
UID_Major:
begin
   _mhits     := 200;
   _renerg    := 100;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 5;
   _btime     := 20;
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
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_4hfps,MID_BPlasma,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_fly_mech     ,wpr_adv +wpr_air   ,uidall,[],0,0);
   _weapon(1,wpt_missle   ,aw_srange,0,0 ,fr_4hfps,MID_BPlasma,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_fly          ,wpr_adv +wpr_air   ,uidall,[],0,0);
   _weapon(2,wpt_missle   ,aw_srange,0,0 ,fr_4hfps,MID_BPlasma,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground_mech  ,wpr_nadv+wpr_ground,uidall,[],0,0);
   _weapon(3,wpt_missle   ,aw_srange,0,0 ,fr_4hfps,MID_BPlasma,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground       ,wpr_nadv+wpr_ground,uidall,[],0,0);
end;
UID_BFG:
begin
   _mhits     := 200;
   _renerg    := 200;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 6;
   _btime     := 60;
   _attack    := atm_always;
   _zombie_uid:= UID_ZBFG;
   _uklight   := true;
   _limituse  := 2;
   _ruid1     := UID_UTechCenter;
   _fdeathhits(-30);
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_2fps,MID_BFG,0,0,0,upgr_uac_attack,5,wtrset_enemy_alive,wpr_adv ,uidall,[fr_fps],0,0);
end;
UID_FAPC:
begin
   _mhits     := 400;
   _renerg    := 100;
   _r         := 33;
   _speed     := 22;
   _srange    := 250;
   _ucl       := 7;
   _btime     := 30;
   _apcm      := 10;
   _apcs      := 8;
   _ukfly     := uf_fly;
   _attack    := atm_always;
   _ukmech    := true;
   _slowturn  := true;

   ups_apc    :=marines+[UID_APC,UID_UACBot,UID_Terminator,UID_Tank];
end;
UID_APC:
begin
   _mhits     := 600;
   _renerg    := 100;
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
   _mhits     := 400;
   _renerg    := 200;
   _r         := 15;
   _speed     := 14;
   _srange    := 250;
   _ucl       := 9;
   _btime     := 20;
   _apcs      := 2;
   _limituse  := 2;
   _attack    := atm_always;
   _ukmech    := true;
   _uklight   := true;
   _addon     := true;
   _ability   := uab_buildturret;
   _weapon(0,wpt_missle   ,aw_srange,0,0 ,fr_4hfps,MID_BPlasma,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground_mech  ,wpr_any,uidall,[],0,0);
   _weapon(1,wpt_missle   ,aw_srange,0,0 ,fr_4hfps,MID_BPlasma,0,0,0,upgr_uac_attack,1,wtrset_enemy_alive_ground       ,wpr_any,uidall,[],0,0);
end;
UID_Terminator:
begin
   _mhits     := 600;
   _renerg    := 200;
   _r         := 16;
   _speed     := 14;
   _srange    := 250;
   _ucl       := 10;
   _btime     := 60;
   _apcs      := 3;
   _limituse  := 3;
   _attack    := atm_always;
   _ukmech    := true;
   _addon     := true;
   _ruid1     := UID_UTechCenter;
end;
UID_Tank:
begin
   _mhits     := 600;
   _renerg    := 200;
   _r         := 20;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 11;
   _btime     := 60;
   _apcs      := 7;
   _limituse  := 3;
   _attack    := atm_always;
   _ukmech    := true;
   _addon     := true;
   _splashresist:=true;
   _ruid1     := UID_UTechCenter;
   _weapon(0,wpt_missle   ,_srange+100,rocket_sr,0 ,fr_2h3fps,MID_Tank,0,0,0,upgr_uac_attack,2,wtrset_enemy_alive_ground_buildings,wpr_adv ,uidall,[],0,0);
   _weapon(1,wpt_missle   ,_srange+100,rocket_sr,0 ,fr_2h3fps,MID_Tank,0,0,0,upgr_uac_attack,2,wtrset_enemy_alive_ground          ,wpr_adv ,uidall,[],0,0);
   _weapon(2,wpt_missle   ,aw_srange  ,rocket_sr,0 ,fr_2h3fps,MID_Tank,0,0,0,upgr_uac_attack,2,wtrset_enemy_alive_ground_buildings,wpr_nadv,uidall,[],0,0);
   _weapon(3,wpt_missle   ,aw_srange  ,rocket_sr,0 ,fr_2h3fps,MID_Tank,0,0,0,upgr_uac_attack,2,wtrset_enemy_alive_ground          ,wpr_nadv,uidall,[],0,0);
end;
UID_Flyer:
begin
   _mhits     := 600;
   _renerg    := 200;
   _r         := 18;
   _speed     := 19;
   _srange    := 300;
   _ucl       := 12;
   _btime     := 60;
   _apcs      := 7;
   _ukfly     := uf_fly;
   _limituse  := 3;
   _attack    := atm_always;
   _ukmech    := true;
   _addon     := true;
   _ruid1     := UID_UTechCenter;
   _weapon(0,wpt_missle   ,_srange    ,0,0 ,fr_2hfps,MID_Flyer,0,0,0,upgr_uac_attack,2,wtrset_enemy_alive_fly   ,wpr_any,uidall,[],0,0);
   _weapon(1,wpt_missle   ,_srange-100,0,0 ,fr_2hfps,MID_Flyer,0,0,0,upgr_uac_attack,2,wtrset_enemy_alive_ground,wpr_adv,uidall,[],0,0);
end;
UID_UTransport:
begin
   _mhits     := 1000;
   _renerg    := 150;
   _r         := 36;
   _speed     := 10;
   _srange    := 250;
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

      if(_ukbuilding)then
      begin
         _zombie_hits:=_mhits div 2;
         _ukmech:=true;
         if(_base_armor<=0)then _base_armor:=10;
      end
      else
      begin
         //_zombie_hits:=0;
         if(_base_armor<=0)and(_ukmech)then _base_armor:=5;
      end;

      _shcf:=_mhits/_mms;

      if(_btime> 0)then _bstep:=(_mhits div 2) div _btime;
      if(_bstep<=0)then _bstep:=1;
      _tprod:=_btime*fr_fps;

      if(_limituse<=0)then _limituse:=1;
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
begin
   FillChar(_upids,SizeOf(_upids),0);

   //         race id                  time lvl  enr  rupgr         ruid                multi doom2
   _setUPGR(r_hell,upgr_hell_dattack   ,180,4   ,200 ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_uarmor    ,180,4   ,200 ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_barmor    ,180,4   ,200 ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_mattack   ,60 ,4   ,100 ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_regen     ,60 ,2   ,50  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_pains     ,45 ,3   ,50  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_heye      ,60 ,2   ,50  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_towers    ,90 ,3   ,50  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_teleport  ,120,2   ,50  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_hktele    ,180,1   ,100 ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_paina     ,60 ,2   ,50  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_mainr     ,60 ,2   ,50  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_hktdoodads,60 ,1   ,50  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_pinkspd   ,60 ,1   ,50  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_revtele   ,60 ,1   ,100 ,0            ,UID_HMonastery     ,false,false);
   _setUPGR(r_hell,upgr_hell_6bld      ,20 ,15  ,100 ,0            ,UID_HMonastery     ,true ,false);
   _setUPGR(r_hell,upgr_hell_9bld      ,60 ,1   ,100 ,0            ,UID_HFortress      ,false,true );
   _setUPGR(r_hell,upgr_hell_revmis    ,60 ,1   ,100 ,0            ,UID_HMonastery     ,false,true );
   _setUPGR(r_hell,upgr_hell_totminv   ,60 ,1   ,100 ,0            ,UID_HAltar         ,false,true );
   _setUPGR(r_hell,upgr_hell_bldrep    ,60 ,3   ,100 ,0            ,UID_HAltar         ,false,true );
   _setUPGR(r_hell,upgr_hell_b478tel   ,30 ,15  ,25  ,0            ,UID_HAltar         ,true ,true );
   _setUPGR(r_hell,upgr_hell_invuln    ,180,1   ,300 ,0            ,UID_HAltar         ,false,true );

   _setUPGR(r_uac ,upgr_uac_attack     ,180,4   ,100 ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_uarmor     ,120,4   ,100 ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_barmor     ,180,4   ,100 ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_melee      ,60 ,3   ,75  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_mspeed     ,60 ,2   ,75  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_apcgun     ,60 ,1   ,50  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_detect     ,60 ,1   ,50  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_towers     ,90 ,3   ,50  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_radar_r    ,90 ,3   ,50  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_mainm      ,120,1   ,75  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_ccturr     ,120,1   ,75  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_mainr      ,60 ,2   ,50  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_ccldoodads ,60 ,1   ,50  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_mines      ,60 ,2   ,50  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_jetpack    ,60 ,1   ,50  ,0            ,UID_UTechCenter    ,false,false);
   _setUPGR(r_uac ,upgr_uac_6bld       ,120,1   ,100 ,0            ,UID_UTechCenter    ,false,false);
   _setUPGR(r_uac ,upgr_uac_9bld       ,60 ,1   ,100 ,0            ,UID_UNuclearPlant  ,false,true );
   _setUPGR(r_uac ,upgr_uac_rstrike    ,120,6   ,125 ,0            ,UID_UTechCenter    ,true ,true );
   _setUPGR(r_uac ,upgr_uac_mechspd    ,60 ,2   ,75  ,0            ,UID_UTechCenter    ,false,true );
   _setUPGR(r_uac ,upgr_uac_mecharm    ,180,4   ,100 ,0            ,UID_UTechCenter    ,false,true );
   _setUPGR(r_uac ,upgr_uac_turarm     ,120,2   ,75  ,0            ,UID_UTechCenter    ,false,true );




  { _setUPGR(r_hell,upgr_attack    ,180,4 ,4 ,255       ,255);
   _setUPGR(r_hell,upgr_armor     ,180,4 ,4 ,255       ,255);
   _setUPGR(r_hell,upgr_build     ,120,4 ,4 ,255       ,255);
   _setUPGR(r_hell,upgr_melee     ,60 ,3 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_regen     ,120,2 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_pains     ,60 ,4 ,2 ,255       ,255);
   _setUPGR(r_hell,upgr_vision    ,120,3 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_towers    ,120,4 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_5bld      ,120,3 ,2 ,255       ,255);
   _setUPGR(r_hell,upgr_mainm     ,180,1 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_paina     ,120,2 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_mainr     ,120,2 ,2 ,255       ,255);
   _setUPGR(r_hell,upgr_pinkspd   ,60 ,1 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_misfst    ,120,1 ,2 ,255       ,255);
   _setUPGR(r_hell,upgr_6bld      ,20 ,15,8 ,255       ,UID_HMonastery);
   _setUPGR(r_hell,upgr_2tier     ,180,1 ,10,255       ,UID_HMonastery);
   _setUPGR(r_hell,upgr_revtele   ,120,1 ,3 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_revmis    ,120,1 ,2 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_totminv   ,120,1 ,2 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_bldrep    ,120,3 ,2 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_mainonr   ,60 ,1 ,2 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_b478tel   ,30 ,15,1 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_hinvuln   ,180,3 ,10,upgr_2tier,UID_HAltar    );
   _setUPGR(r_hell,upgr_bldenrg   ,180,3 ,4 ,upgr_2tier,UID_HFortress );
   _setUPGR(r_hell,upgr_9bld      ,180,1 ,4 ,upgr_2tier,UID_HFortress );

   _setUPGR(r_uac ,upgr_attack    ,180,4 ,4 ,255       ,255);
   _setUPGR(r_uac ,upgr_armor     ,120,5 ,4 ,255       ,255);
   _setUPGR(r_uac ,upgr_build     ,180,4 ,4 ,255       ,255);
   _setUPGR(r_uac ,upgr_melee     ,60 ,3 ,3 ,255       ,255);
   _setUPGR(r_uac ,upgr_mspeed    ,60 ,2 ,3 ,255       ,255);
   _setUPGR(r_uac ,upgr_plsmt     ,120,2 ,2 ,255       ,255);
   _setUPGR(r_uac ,upgr_vision    ,120,1 ,3 ,255       ,255);
   _setUPGR(r_uac ,upgr_towers    ,120,4 ,3 ,255       ,255);
   _setUPGR(r_uac ,upgr_5bld      ,120,3 ,2 ,255       ,255);
   _setUPGR(r_uac ,upgr_mainm     ,180,1 ,3 ,255       ,255);
   _setUPGR(r_uac ,upgr_ucomatt   ,180,1 ,4 ,upgr_mainm,255);
   _setUPGR(r_uac ,upgr_mainr     ,120,2 ,2 ,255       ,255);
   _setUPGR(r_uac ,upgr_mines     ,60 ,1 ,2 ,255       ,255);
   _setUPGR(r_uac ,upgr_minesen   ,60 ,1 ,2 ,upgr_mines,255);
   _setUPGR(r_uac ,upgr_6bld      ,180,1 ,8 ,255       ,UID_UTechCenter);
   _setUPGR(r_uac ,upgr_2tier     ,180,1 ,10,255       ,UID_UTechCenter);
   _setUPGR(r_uac ,upgr_blizz     ,180,8 ,10,upgr_2tier,UID_UTechCenter);
   _setUPGR(r_uac ,upgr_mechspd   ,120,2 ,3 ,upgr_2tier,UID_UTechCenter);
   _setUPGR(r_uac ,upgr_mecharm   ,180,4 ,4 ,upgr_2tier,UID_UTechCenter);
   _setUPGR(r_uac ,upgr_6bld2     ,120,1 ,2 ,upgr_2tier,UID_UTechCenter);
   _setUPGR(r_uac ,upgr_mainonr   ,60 ,1 ,2 ,upgr_2tier,UID_UTechCenter);
   _setUPGR(r_uac ,upgr_turarm    ,120,2 ,3 ,upgr_2tier,UID_UTechCenter);
   _setUPGR(r_uac ,upgr_rturrets  ,180,1 ,4 ,upgr_2tier,UID_UTechCenter);
   _setUPGR(r_uac ,upgr_bldenrg   ,180,3 ,4 ,upgr_2tier,UID_UNuclearPlant  );
   _setUPGR(r_uac ,upgr_9bld      ,180,1 ,4 ,upgr_2tier,UID_UNuclearPlant  );  }

   //                                      wtr_owner_p wtr_owner_a wtr_owner_e wtr_hits_h wtr_hits_d wtr_hits_a wtr_bio wtr_mech wtr_building wtr_bld wtr_nbld wtr_ground wtr_fly wtr_adv wtr_nadv wtr_light wtr_nlight wtr_stun wtr_nostun;
   wtrset_enemy                          :=                        wtr_owner_e+wtr_hits_h+wtr_hits_d+wtr_hits_a+wtr_bio+wtr_mech+wtr_building+wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive                    :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_building+wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground             :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_building+wtr_bld+wtr_nbld+wtr_ground        +wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_nlight      :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_building+wtr_bld+wtr_nbld+wtr_ground        +wtr_adv+wtr_nadv+          wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_nlight_bio  :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+                      wtr_bld+wtr_nbld+wtr_ground        +wtr_adv+wtr_nadv+          wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_mech        :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+        wtr_mech             +wtr_bld+wtr_nbld+wtr_ground        +wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_fly                :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech+wtr_building+wtr_bld+wtr_nbld+           wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_fly_mech           :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+        wtr_mech             +wtr_bld+wtr_nbld+           wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_mech               :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+        wtr_mech             +wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_mech_nstun         :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+        wtr_mech             +wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+         wtr_nostun;
   wtrset_enemy_alive_buildings          :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+                 wtr_building+wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_nbuildings         :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+wtr_mech             +wtr_bld+wtr_nbld+           wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_buildings   :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+                 wtr_building+wtr_bld+wtr_nbld+wtr_ground        +wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_bio                :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+                      wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_bio_nstun          :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+                      wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+         wtr_nostun;
   wtrset_enemy_alive_nlight_bio         :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+                      wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light           +wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_bio         :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+                      wtr_bld+wtr_nbld+wtr_ground+        wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_enemy_alive_ground_light_bio   :=                        wtr_owner_e+wtr_hits_h           +wtr_hits_a+wtr_bio+                      wtr_bld+wtr_nbld+wtr_ground+        wtr_adv+wtr_nadv+wtr_light           +wtr_stun+wtr_nostun;
   wtrset_heal                           :=wtr_owner_p+wtr_owner_a            +wtr_hits_h                      +wtr_bio+                      wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;
   wtrset_repair                         :=wtr_owner_p+wtr_owner_a            +wtr_hits_h                              +wtr_mech+wtr_building+wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+         wtr_nostun;
   wtrset_resurect                       :=wtr_owner_p+wtr_owner_a                       +wtr_hits_d           +wtr_bio+wtr_mech+wtr_building+wtr_bld+wtr_nbld+wtr_ground+wtr_fly+wtr_adv+wtr_nadv+wtr_light+wtr_nlight+wtr_stun+wtr_nostun;


   FillChar(_uids   ,SizeOf(_uids   ),0);

   initUIDS;
end;
