
{$IFDEF _FULLGAME}
function _unit_shadowz(pu:PTUnit):integer;
begin
   with pu^  do
   with uid^ do
   begin
      if(_isbuilding=false)
      then _unit_shadowz:= fly_height[uf]
      else
        if(speed<=0)
        then _unit_shadowz:=-fly_z
        else _unit_shadowz:=fly_height[uf]-fly_z;
    end;
end;

procedure _unit_fog_r(pu:PTUnit);
begin
   with pu^ do
   begin
      fsr:=0;
      if(fog_cw>0)then fsr:=min2(srange div fog_cw,MFogM);
   end;
end;
{$ENDIF}


function _canmove(pu:PTUnit):boolean;
begin
   with pu^ do
   with uid^ do
   begin
      _canmove:=false;

      if(ServerSide=false)and(speed>0)then
      begin
         _canmove:=(x<>uo_bx)or(y<>uo_by);
         exit;
      end;

      if(speed<=0)or(buff[ub_stopattack]>0)or(bld=false)then exit;

      if(_ismech)then
      begin
         if(_isbuilding)then
         begin
            if(buff[ub_clcast]>0)then exit;
         end
         else
         begin
            if(buff[ub_gear ]>0)
            or(buff[ub_stun ]>0) then exit;
         end;
      end
      else
      begin
         if(buff[ub_pain ]>0)
         or(buff[ub_cast ]>0)
         or(buff[ub_stun ]>0)
         or(buff[ub_gear ]>0)then exit;
      end;

      _canmove:=true;
   end;
end;

function _canattack(pu:PTUnit):boolean;
var tu:PTUnit;
begin
   _canattack:=false;
   with pu^  do
   with uid^ do
   begin
      if(bld=false)or(hits<=0)or(_attack=atm_none)then exit;

      if(_isbuilding=false)then
      begin
         if(_ismech=false)then
         begin
            if(buff[ub_pain]>0)then exit;
         end;
         if(buff[ub_gear ]>0)then exit;
         if(buff[ub_stun ]>0)then exit;
      end;

      case _attack of
   atm_bunker,
   atm_always  : if(_IsUnitRange(inapc,@tu))then
                 begin
                    if(tu^.inapc>0)then exit;
                    case tu^.uid^._attack of
                    atm_always,
                    atm_none,
                    atm_sturret: exit;
                    end;
                 end;
   atm_sturret : if(apcc <=0)then exit;
   atm_inapc   : if(inapc<=0)then exit;
      else exit;
      end;
   end;
   _canattack:=true;
end;

procedure _unit_apUID(pu:PTUnit);
begin
   with pu^ do
   begin
      uid:=@_uids[uidi];
      with uid^ do
      begin
         srange:= _srange;
         speed := _speed;
         uf    := _uf;
         apcm  := _apcm;
         painc := _painc;
         solid := _issolid;

         if(_isbuilding)and(_isbarrack)then uo_y:=y+_r;

         if(_advanced[g_addon])then buff[ub_advanced]:=_ub_infinity;

         {$IFDEF _FULLGAME}
         mmr   := trunc(_r*map_mmcx)+1;

         shadow:=_unit_shadowz(pu);

         _unit_fog_r(pu);
         {$ENDIF}
         if(ServerSide)then hits:=_mhits;
      end;
   end;
end;

procedure initUIDS;
var i:byte;

procedure _weapon(aa,wtype:byte;range,count:integer;reload,oid,ruid,rupid,rupidl,dupgr:byte;dupgrs:integer;tarf,reqf:cardinal;uids,reload_s:TSoB);
begin
   with _uids[i] do
   if(aa<=MaxUnitWeapons)then
   with _a_weap[aa] do
   begin
      aw_type   :=wtype;
      aw_range  :=range;
      aw_count  :=count;
      aw_rld    :=reload;
      aw_oid    :=oid;
      aw_ruid   :=ruid;
      aw_rupgr  :=rupid;
      aw_rupgr_l:=rupidl;
      aw_dupgr  :=dupgr;
      aw_dupgr_s:=dupgrs;
      aw_tarf   :=tarf;
      aw_reqf   :=reqf;
      aw_uids   :=uids;
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
      _uf        := uf_ground;
      _ucl       := 255;
      _apcs      := 1;
      _urace     := r_hell;
      _attack    := atm_none;
      _srange    := 250;
      _attack    := atm_always;
      _fdeathhits(-32000);

      _isbuilding:=false;
      _isbuilder :=false;
      _issmith   :=false;
      _isbarrack :=false;
      _ismech    :=false;
      _issolid   :=true;
      _slowturn  :=false;

      case i of
//         HELL BUILDINGS   ////////////////////////////////////////////////////
UID_HKeep:
begin
   _mhits     := 3000;
   _renerg    := 12;
   _generg    := 16;
   _r         := 66;
   _srange    := base_rA[0];
   _ucl       := 0;
   _btime     := 60;

   _isbuilding:= true;
   _isbuilder := true;

   ups_builder:= [UID_HKeep..UID_HFortress];
end;
UID_HGate:
begin
   _mhits     := 1500;
   _renerg    := 10;
   _r         := 60;
   _srange    := 200;
   _ucl       := 3;
   _btime     := 40;

   _barrack_teleport:=true;

   _isbuilding:= true;
   _isbarrack := true;

   ups_units  := [UID_LostSoul..UID_Archvile];
end;
UID_HSymbol:
begin
   _mhits     := 100;
   _renerg    := 1;
   _generg    := 1;
   _r         := 22;
   _srange    := 200;
   _ucl       := 2;
   _btime     := 8;

   _isbuilding:= true;
end;
UID_HPools:
begin
   _mhits     := 1000;
   _renerg    := 10;
   _r         := 53;
   _srange    := 200;
   _ucl       := 9;
   _btime     := 40;

   _isbuilding:= true;
   _issmith   := true;

   ups_upgrades := [];
end;
UID_HTower:
begin
   _mhits     := 700;
   _renerg    := 2;
   _r         := 21;
   _srange    := 250;
   _ucl       := 6;
   _btime     := 20;
   _attack    := atm_always;
   _ability   := uab_htowertele;

   _isbuilding:= true;
end;
UID_HTeleport:
begin
   _mhits     := 400;
   _renerg    := 4;
   _r         := 28;
   _srange    := 200;
   _ucl       := 12;
   _btime     := 30;
   _max       := 1;
   _ability   := uab_teleport;

   _isbuilding:= true;
   _issolid   := false;
end;
UID_HMonastery:
begin
   _mhits     := 1000;
   _renerg    := 10;
   _r         := 65;
   _srange    := 200;
   _ucl       := 10;
   _btime     := 90;
   _max       := 1;
   _ruid      := UID_HPools;
   _ability   := uab_hell_unit_adv;

   _isbuilding:= true;
end;
UID_HTotem:
begin
   _mhits     := 700;
   _renerg    := 4;
   _r         := 21;
   _srange    := 250;
   _ucl       := 7;
   _btime     := 25;
   _ruid      := UID_HAltar;
   _attack    := atm_always;
   _ability   := uab_htowertele;
   //_rupgr     := upgr_2tier;

   _isbuilding:= true;
end;
UID_HAltar:
begin
   _mhits     := 500;
   _renerg    := 4;
   _r         := 50;
   _srange    := 200;
   _ucl       := 13;
   _btime     := 30;
   _max       := 1;
   _ruid      := UID_HMonastery;
   //_rupgr     := upgr_2tier;

   _isbuilding:= true;
   _issmith   := true;
end;
UID_HFortress:
begin
   _mhits     := 4000;
   _renerg    := 12;
   _generg    := 12;
   _r         := 86;
   _srange    := 300;
   _ucl       := 11;
   _btime     := 90;
   _max       := 1;
   _ruid      := UID_HPools;
   _ability   := uab_building_adv;

   _isbuilding:= true;
   _isbuilder := true;

   ups_builder:=[UID_HKeep..UID_HAltar]-[UID_HFortress];
end;
UID_HEye:
begin
   _mhits     := 240;
   _renerg    := 1;
   _r         := 5;
   _srange    := 250;
   _ucl       := 21;
   _btime     := 1;
   //_rupgr     := upgr_vision;

   _isbuilding:= true;
   _issolid   := false;
end;
UID_HCommandCenter:  //UID_UCommandCenter
begin
   _mhits     := 2500;
   _renerg    := 16;
   _generg    := 12;
   _speed     := 6;
   _r         := 66;
   _srange    := base_rA[0];
   _ucl       := 1;
   _btime     := 90;
   _apcm      := 30;

   _isbuilding:= true;

   ups_builder:=[UID_HCommandCenter,UID_HSymbol,UID_HTower,UID_HMilitaryUnit];
   ups_apc    :=demons;
end;
UID_HMilitaryUnit:
begin
   _mhits     := 1500;
   _renerg    := 10;
   _r         := 66;
   _srange    := base_rA[0];
   _ucl       := 4;
   _btime     := 40;

   _isbuilding:=true;
   _isbarrack :=true;

   ups_units  :=zimbas;
end;
//////////////////////////////

UID_LostSoul   :
begin
   _mhits     := 90;
   _renerg    := 1;
   _r         := 10;
   _speed     := 23;
   _srange    := 250;
   _ucl       := 0;
   _painc     := 1;
   _btime     := 8;
   _uf        := uf_soaring;
   _attack    := atm_always;
   _ability   := uab_morph2heye;
   _fdeathhits(1);
   _weapon(0,wpt_directdmg,-8,10,fr_fps,0,0,0,0,upgr_hell_mattack,5,wtrset_enemy_alive,wpr_adv+wpr_zombie,uidall,[]);
   _weapon(1,wpt_directdmg,-8,10,fr_fps,0,0,0,0,upgr_hell_mattack,5,wtrset_enemy_alive,wpr_any           ,uidall,[]);
end;
UID_Imp        :
begin
   _mhits     := 70;
   _renerg    := 1;
   _r         := 11;
   _speed     := 9;
   _srange    := 250;
   _ucl       := 1;
   _painc     := 3;
   _btime     := 5;
   _attack    := atm_always;
   _fdeathhits(-30);
   _weapon(0,wpt_missle   ,250,0 ,fr_3h2fps,MID_Imp,0,0,0,upgr_hell_dattack,2,wtrset_enemy_alive       ,wpr_adv ,uidall-[UID_Imp],[]);
   _weapon(1,wpt_missle   ,250,0 ,fr_fps   ,MID_Imp,0,0,0,upgr_hell_dattack,2,wtrset_enemy_alive       ,wpr_nadv,uidall-[UID_Imp],[]);
   _weapon(2,wpt_directdmg,-8 ,10,fr_fps   ,0      ,0,0,0,upgr_hell_mattack,5,wtrset_enemy_alive_ground,wpr_any ,[UID_Imp]       ,[]);
end;
UID_Demon      :
begin
   _mhits     := 150;
   _renerg    := 2;
   _r         := 14;
   _speed     := 14;
   _srange    := 200;
   _ucl       := 2;
   _painc     := 8;
   _btime     := 8;
   _attack    := atm_always;
   _weapon(0,wpt_directdmg,-8 ,35,fr_hfps,0      ,0,upgr_hell_pinkspd,1,upgr_hell_mattack,5,wtrset_enemy_alive_ground,wpr_any ,uidall,[]);
   _weapon(1,wpt_directdmg,-8 ,35,fr_fps ,0      ,0,0                ,0,upgr_hell_mattack,5,wtrset_enemy_alive_ground,wpr_any ,uidall,[]);
end;
UID_Cacodemon  :
begin
   _mhits     := 225;
   _renerg    := 2;
   _r         := 14;
   _speed     := 9;
   _srange    := 250;
   _ucl       := 3;
   _painc     := 6;
   _btime     := 20;
   _apcs      := 2;
   _uf        := uf_fly;
   _attack    := atm_always;
   _zfall     := fly_height[uf_fly];
   _weapon(0,wpt_missle   ,300,0 ,fr_fps   ,MID_Cacodemon,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive    ,wpr_adv ,uidall-[UID_Cacodemon],[]);
   _weapon(1,wpt_missle   ,250,0 ,fr_fps   ,MID_Cacodemon,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive    ,wpr_nadv,uidall-[UID_Cacodemon],[]);
   _weapon(2,wpt_directdmg,-8 ,25,fr_fps   ,0            ,0,0,0,upgr_hell_mattack,5,wtrset_enemy_alive_fly,wpr_any ,[UID_Cacodemon]       ,[]);
end;
UID_Baron      :
begin
   _mhits     := 350;
   _renerg    := 4;
   _r         := 14;
   _speed     := 9;
   _srange    := 250;
   _ucl       := 4;
   _painc     := 8;
   _btime     := 40;
   _apcs      := 3;
   _attack    := atm_always;
   _advanced[false]:=true;
   _weapon(0,wpt_missle   ,250,0 ,fr_fps   ,MID_Baron,0,0,0,upgr_hell_dattack,4,wtrset_enemy_alive_ground,wpr_any ,uidall-[UID_Baron],[]);
   _weapon(1,wpt_missle   ,150,0 ,fr_fps   ,MID_Baron,0,0,0,upgr_hell_dattack,4,wtrset_enemy_alive_fly   ,wpr_any ,uidall-[UID_Baron],[]);//???????
   _weapon(2,wpt_directdmg,-8 ,45,fr_fps   ,0        ,0,0,0,upgr_hell_mattack,5,wtrset_enemy_alive_ground,wpr_any ,[UID_Baron]       ,[]);
end;
UID_Cyberdemon :
begin
   _mhits     := 2000;
   _renerg    := 10;
   _max       := 1;
   _r         := 20;
   _speed     := 11;
   _srange    := 250;
   _ucl       := 5;
   _painc     := 15;
   _btime     := 90;
   _apcs      := 10;
   _ruid      := UID_HMonastery;
   _attack    := atm_always;
   _weapon(0,wpt_missle   ,300,0 ,fr_fps   ,MID_HRocket,0,0,0,upgr_hell_dattack,5,wtrset_enemy_alive_buildings,wpr_adv ,uidall,[]);
   _weapon(1,wpt_missle   ,250,0 ,fr_fps   ,MID_HRocket,0,0,0,upgr_hell_dattack,5,wtrset_enemy_alive_buildings,wpr_nadv,uidall,[]);
   _weapon(2,wpt_missle   ,300,0 ,fr_fps   ,MID_HRocket,0,0,0,upgr_hell_dattack,5,wtrset_enemy_alive          ,wpr_adv ,uidall,[]);
   _weapon(3,wpt_missle   ,250,0 ,fr_fps   ,MID_HRocket,0,0,0,upgr_hell_dattack,5,wtrset_enemy_alive          ,wpr_nadv,uidall,[]);
end;
UID_Mastermind :
begin
   _mhits     := 2000;
   _renerg    := 10;
   _max       := 1;
   _r         := 35;
   _speed     := 11;
   _srange    := 275;
   _ucl       := 6;
   _painc     := 15;
   _btime     := 90;
   _apcs      := 10;
   _ruid      := UID_HMonastery;
   _attack    := atm_always;
   _weapon(0,wpt_missle   ,325,0 ,fr_8hfps,MID_Bulletx2,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive_bio,wpr_adv ,uidall,[]);
   _weapon(1,wpt_missle   ,275,0 ,fr_8hfps,MID_Bulletx2,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive_bio,wpr_nadv,uidall,[]);
   _weapon(2,wpt_missle   ,325,0 ,fr_8hfps,MID_Bulletx2,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive    ,wpr_adv ,uidall,[]);
   _weapon(3,wpt_missle   ,275,0 ,fr_8hfps,MID_Bulletx2,0,0,0,upgr_hell_dattack,1,wtrset_enemy_alive    ,wpr_nadv,uidall,[]);
end;
UID_Pain       :
begin
   _mhits     := 200;
   _renerg    := 6;
   _r         := 14;
   _speed     := 9;
   _srange    := 250;
   _ucl       := 7;
   _painc     := 3;
   _btime     := 40;
   _apcs      := 2;
   _ruid      := UID_HFortress;
   _uf        := uf_fly;
   _attack    := atm_always;
   _ability   := uab_spawnlost;
   _weapon(0,wpt_unit   ,350,0 ,fr_1h1fps,UID_LostSoul,0,0,0,0,0,wtrset_enemy_alive,wpr_any,uidall,[]);
   _fdeathhits(1);
end;
UID_Revenant   :
begin
   _mhits     := 200;
   _renerg    := 4;
   _r         := 13;
   _speed     := 12;
   _srange    := 250;
   _ucl       := 8;
   _painc     := 7;
   _btime     := 40;
   _ruid      := UID_HFortress;
   _attack    := atm_always;
   _weapon(0,wpt_missle   ,350,0 ,fr_fps   ,MID_RevenantS,0,upgr_hell_revmis,1,upgr_hell_dattack,4,wtrset_enemy_alive_fly   ,wpr_adv ,uidall-[UID_Revenant],[]);
   _weapon(1,wpt_missle   ,275,0 ,fr_fps   ,MID_RevenantS,0,upgr_hell_revmis,1,upgr_hell_dattack,4,wtrset_enemy_alive_fly   ,wpr_nadv,uidall-[UID_Revenant],[]);
   _weapon(2,wpt_missle   ,350,0 ,fr_fps   ,MID_Revenant ,0,0               ,0,upgr_hell_dattack,4,wtrset_enemy_alive_fly   ,wpr_adv ,uidall-[UID_Revenant],[]);
   _weapon(3,wpt_missle   ,275,0 ,fr_fps   ,MID_Revenant ,0,0               ,0,upgr_hell_dattack,4,wtrset_enemy_alive_fly   ,wpr_nadv,uidall-[UID_Revenant],[]);
   _weapon(4,wpt_missle   ,350,0 ,fr_fps   ,MID_RevenantS,0,upgr_hell_revmis,1,upgr_hell_dattack,4,wtrset_enemy_alive       ,wpr_adv ,uidall-[UID_Revenant],[]);
   _weapon(5,wpt_missle   ,275,0 ,fr_fps   ,MID_RevenantS,0,upgr_hell_revmis,1,upgr_hell_dattack,4,wtrset_enemy_alive       ,wpr_nadv,uidall-[UID_Revenant],[]);
   _weapon(6,wpt_missle   ,350,0 ,fr_fps   ,MID_Revenant ,0,0               ,0,upgr_hell_dattack,4,wtrset_enemy_alive       ,wpr_adv ,uidall-[UID_Revenant],[]);
   _weapon(7,wpt_missle   ,275,0 ,fr_fps   ,MID_Revenant ,0,0               ,0,upgr_hell_dattack,4,wtrset_enemy_alive       ,wpr_nadv,uidall-[UID_Revenant],[]);
   _weapon(8,wpt_directdmg,-8 ,30,fr_3h2fps,0            ,0,0               ,0,upgr_hell_mattack,5,wtrset_enemy_alive_ground,wpr_any ,       [UID_Revenant],[]);
end;
UID_Mancubus   :
begin
   _mhits     := 400;
   _renerg    := 6;
   _r         := 20;
   _speed     := 6;
   _srange    := 275;
   _ucl       := 9;
   _painc     := 4;
   _btime     := 60;
   _ruid      := UID_HMonastery;
   _attack    := atm_always;
   _weapon(0,wpt_missle   ,300,-8,fr_mancubus_r,MID_Mancubus,0,0,0,upgr_hell_dattack,5,wtrset_enemy_alive_ground_buildings,wpr_any ,uidall-[UID_Mancubus],[110,70,30]);
   _weapon(1,wpt_missle   ,300,-8,fr_mancubus_r,MID_Mancubus,0,0,0,upgr_hell_dattack,5,wtrset_enemy_alive_ground          ,wpr_any ,uidall-[UID_Mancubus],[110,70,30]);
   _weapon(2,wpt_missle   ,200,-8,fr_mancubus_r,MID_Mancubus,0,0,0,upgr_hell_dattack,5,wtrset_enemy_alive_fly             ,wpr_any ,uidall-[UID_Mancubus],[110,70,30]);
end;
UID_Arachnotron:
begin
   _mhits     := 350;
   _renerg    := 6;
   _r         := 20;
   _speed     := 8;
   _srange    := 250;
   _ucl       := 10;
   _painc     := 4;
   _btime     := 50;
   _ruid      := UID_HMonastery;
   _attack    := atm_always;
   _weapon(0,wpt_missle   ,350,0 ,fr_hhfps,MID_YPlasma,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_mech  ,wpr_adv ,uidall-[UID_Arachnotron],[]);
   _weapon(1,wpt_missle   ,275,0 ,fr_hhfps,MID_YPlasma,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive_mech  ,wpr_nadv,uidall-[UID_Arachnotron],[]);
   _weapon(2,wpt_missle   ,350,0 ,fr_hhfps,MID_YPlasma,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive       ,wpr_adv ,uidall-[UID_Arachnotron],[]);
   _weapon(3,wpt_missle   ,275,0 ,fr_hhfps,MID_YPlasma,0,0,0,upgr_hell_dattack,3,wtrset_enemy_alive       ,wpr_nadv,uidall-[UID_Arachnotron],[]);
end;
UID_Archvile:
begin
   _mhits     := 400;
   _renerg    := 10;
   _r         := 14;
   _speed     := 15;
   _srange    := 250;
   _ucl       := 11;
   _painc     := 12;
   _btime     := 90;
   _apcs      := 2;
   _ruid      := UID_HMonastery;
   _attack    := atm_always;
   //_rupgr     := upgr_2tier;
   _weapon(0,wpt_resurect,-8  ,0,fr_fps,0,0,0,0,0,0,wtrset_resurect,wpr_adv+wpr_cast,arch_res,[]);
   _weapon(1,wpt_missle   ,450,0,140   ,MID_ArchFire,0,0,0,upgr_hell_dattack,5,wtrset_enemy_alive_nbuildings,wpr_any,uidall,[65]);
end;

UID_ZFormer:
begin
   _mhits     := 50;
   _renerg    := 1;
   _r         := 12;
   _speed     := 13;
   _srange    := 250;
   _ucl       := 12;
   _painc     := 1;
   _btime     := 5;
   _attack    := atm_always;
   _fdeathhits(-25);
end;
UID_ZEngineer:
begin
   _mhits     := 100;
   _renerg    := 3;
   _r         := 12;
   _speed     := 14;
   _srange    := 200;
   _ucl       := 13;
   _painc     := 4;
   _btime     := 20;
   _attack    := atm_always;
   _fdeathhits(1);
end;
UID_ZSergant:
begin
   _mhits     := 80;
   _renerg    := 2;
   _r         := 12;
   _speed     := 13;
   _srange    := 241;
   _ucl       := 14;
   _painc     := 4;
   _btime     := 10;
   _attack    := atm_always;
   _fdeathhits(-30);
end;
UID_ZCommando:
begin
   _mhits     := 100;
   _renerg    := 2;
   _r         := 12;
   _speed     := 11;
   _srange    := 250;
   _ucl       := 15;
   _painc     := 4;
   _btime     := 15;
   _attack    := atm_always;
   _fdeathhits(-30);
end;
UID_ZBomber:
begin
   _mhits     := 100;
   _renerg    := 3;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 16;
   _painc     := 4;
   _btime     := 30;
   _attack    := atm_always;
   _fdeathhits(-30);
end;
UID_ZMajor:
begin
   _mhits     := 100;
   _renerg    := 4;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 17;
   _painc     := 4;
   _btime     := 20;
   _attack    := atm_always;
   _fastdeath_hits[false]:=-30;
   _fastdeath_hits[true ]:=1;
end;
UID_ZBFG:
begin
   _mhits     := 100;
   _renerg    := 5;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 18;
   _painc     := 4;
   _btime     := 60;
   _attack    := atm_always;
   _fdeathhits(-30);
end;


//         UAC BUILDINGS   /////////////////////////////////////////////////////
UID_UCommandCenter:
begin
   _mhits     := 2500;
   _renerg    := 16;
   _generg    := 12;
   _r         := 66;
   _srange    := base_rA[0];
   _ucl       := 0;
   _btime     := 90;

   _zombie_uid:= UID_HCommandCenter;

   _attack    := atm_always;

   _isbuilding:= true;
   _isbuilder := true;
   _slowturn  := true;

   ups_builder:=[UID_UCommandCenter..UID_UNuclearPlant];
end;
UID_UMilitaryUnit:
begin
   _mhits     := 1750;
   _renerg    := 10;
   _r         := 66;
   _srange    := 200;
   _ucl       := 3;
   _btime     := 40;

   _zombie_uid:= UID_HMilitaryUnit;

   _isbuilding:=true;
   _isbarrack :=true;

   ups_units:=marines;
end;
UID_UFactory:
begin
   _mhits     := 1750;
   _renerg    := 10;
   _r         := 66;
   _srange    := 200;
   _ucl       := 4;
   _btime     := 40;

   _isbuilding:=true;
   _isbarrack :=true;

   ups_units:=[UID_APC,UID_FAPC,UID_Terminator,UID_Tank,UID_Flyer];
end;
UID_UGenerator:
begin
   _mhits     := 200;
   _renerg    := 2;
   _generg    := 2;
   _r         := 42;
   _srange    := 200;
   _ucl       := 2;
   _btime     := 16;

   _isbuilding:=true;
end;
UID_UWeaponFactory:
begin
   _mhits     := 1750;
   _renerg    := 10;
   _r         := 62;
   _srange    := 200;
   _ucl       := 9;
   _btime     := 40;

   _isbuilding:=true;
   _issmith   :=true;

   ups_upgrades := [];
end;

UID_URadar:
begin
   _mhits     := 400;
   _renerg    := 4;
   _r         := 35;
   _srange    := 200;
   _ucl       := 12;
   _btime     := 30;
   _max       := 1;
   _ability   := uab_radar;

   _isbuilding:=true;
end;
UID_UTechCenter :
begin
   _mhits     := 1750;
   _renerg    := 12;
   _r         := 62;
   _srange    := 200;
   _ucl       := 10;
   _btime     := 90;
   _max       := 1;
   _ruid      := UID_UWeaponFactory;
   _ability   := uab_uac__unit_adv;

   _isbuilding:=true;
end;
UID_URMStation:
begin
   _mhits     := 500;
   _renerg    := 8;
   _r         := 40;
   _srange    := 200;
   _ucl       := 13;
   _btime     := 30;
   _max       := 1;
   _ruid      := UID_UTechCenter;
   //_rupgr     := upgr_2tier;
   _ability   := uab_uac_rstrike;

   _isbuilding:=true;
end;
UID_UCTurret:
begin
   _mhits     := 400;
   _renerg    := 2;
   _r         := 17;
   _srange    := 250;
   _ucl       := 6;
   _btime     := 15;
   _attack    := atm_always;

   _isbuilding:=true;
end;
UID_UPTurret:
begin
   _mhits     := 400;
   _renerg    := 4;
   _r         := 17;
   _srange    := 250;
   _ucl       := 7;
   _btime     := 20;
   _ruid      := UID_UTechCenter;
   _attack    := atm_always;

   _isbuilding:=true;
end;
UID_URTurret:
begin
   _mhits     := 400;
   _renerg    := 6;
   _r         := 17;
   _srange    := 250;
   _ucl       := 8;
   _btime     := 25;
   _ruid      := UID_UTechCenter;
   _attack    := atm_always;
   //_rupgr     := upgr_rturrets;

   _isbuilding:=true;
end;
UID_UNuclearPlant:
begin
   _mhits     := 2000;
   _renerg    := 20;
   _generg    := 16;
   _r         := 70;
   _srange    := 200;
   _ucl       := 11;
   _btime     := 90;
   _max       := 1;
   _ruid      := UID_UTechCenter;
   _ability   := uab_building_adv;

   _isbuilding:=true;
end;
UID_UMine:
begin
   _mhits     := 5;
   _renerg    := 1;
   _r         := 5;
   _srange    := 100;
   _ucl       := 21;
   _btime     := 5;
   _ucl       := 21;
   _attack    := atm_always;

   _isbuilding:= true;
   _issolid   := false;

   _weapon(0,wpt_missle   ,350,0 ,fr_4fps,MID_Mine,0,0,0,0,0,wtrset_enemy_alive_ground,wpr_sspos,[0..255]-[UID_UMine],[fr_4fps-fr_fps]);
end;

///////////////////////////////////
UID_Engineer:
begin
   _mhits     := 100;
   _renerg    := 1;
   _r         := 12;
   _speed     := 13;
   _srange    := 200;
   _ucl       := 0;
   _btime     := 10;
   _attack    := atm_always;
   _zombie_uid:= UID_ZEngineer;
   _ability   := uab_umine;
   _fdeathhits(-30);
end;
UID_Medic:
begin
   _mhits     := 100;
   _renerg    := 1;
   _r         := 12;
   _speed     := 13;
   _srange    := 200;
   _ucl       := 1;
   _btime     := 10;
   _attack    := atm_always;
   _zombie_uid:= UID_ZFormer;
   _fdeathhits(-30);
end;
UID_Sergant:
begin
   _mhits     := 100;
   _renerg    := 2;
   _r         := 12;
   _speed     := 13;
   _srange    := 241;
   _ucl       := 2;
   _btime     := 10;
   _attack    := atm_always;
   _zombie_uid:= UID_ZSergant;
   _fdeathhits(-30);
end;
UID_Commando:
begin
   _mhits     := 100;
   _renerg    := 2;
   _r         := 12;
   _speed     := 11;
   _srange    := 250;
   _ucl       := 3;
   _btime     := 15;
   _attack    := atm_always;
   _zombie_uid:= UID_ZCommando;
   _fdeathhits(-30);
end;
UID_Bomber:
begin
   _mhits     := 100;
   _renerg    := 4;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 4;
   _btime     := 30;
   _attack    := atm_always;
   _zombie_uid:= UID_ZBomber;
   _fdeathhits(-30);
end;
UID_Major:
begin
   _mhits     := 100;
   _renerg    := 4;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 5;
   _btime     := 20;
   _attack    := atm_always;
   _zombie_uid:= UID_ZMajor;
   _fastdeath_hits[false]:=-30;
   _fastdeath_hits[true ]:=1;
end;
UID_BFG:
begin
   _mhits     := 100;
   _renerg    := 5;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 6;
   _btime     := 60;
   _attack    := atm_always;
   _zombie_uid:= UID_ZBFG;
   _fdeathhits(-30);
end;
UID_FAPC:
begin
   _mhits     := 350;
   _renerg    := 3;
   _r         := 33;
   _speed     := 22;
   _srange    := 250;
   _ucl       := 7;
   _btime     := 25;
   _apcm      := 10;
   _apcs      := 8;
   _uf        := uf_fly;
   _attack    := atm_always;

   _ismech    := true;
   _slowturn  := true;

   ups_apc    :=marines+[UID_APC,UID_Terminator,UID_Tank,UID_Flyer];
end;
UID_APC:
begin
   _mhits     := 450;
   _renerg    := 3;
   _r         := 25;
   _speed     := 15;
   _srange    := 250;
   _ucl       := 8;
   _btime     := 25;
   _apcm      := 10;
   _apcs      := 10;
   _attack    := atm_always;

   _ismech    := true;
   _slowturn  := true;

   ups_apc    :=marines;
end;
UID_Terminator:
begin
   _mhits     := 350;
   _renerg    := 6;
   _r         := 16;
   _speed     := 14;
   _srange    := 275;
   _ucl       := 9;
   _btime     := 60;
   _apcs      := 3;
   _ruid      := UID_UTechCenter;
   _attack    := atm_always;
   //_rupgr     := upgr_2tier;

   _ismech    := true;
end;
UID_Tank:
begin
   _mhits     := 450;
   _renerg    := 6;
   _r         := 20;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 10;
   _btime     := 60;
   _apcs      := 7;
   _ruid      := UID_UTechCenter;
   _attack    := atm_always;
   //_rupgr     := upgr_2tier;

   _ismech    := true;
end;
UID_Flyer:
begin
   _mhits     := 350;
   _renerg    := 3;
   _r         := 18;
   _speed     := 19;
   _srange    := 275;
   _ucl       := 11;
   _btime     := 60;
   _apcs      := 7;
   _uf        := uf_fly;
   _ruid      := UID_UTechCenter;
   _attack    := atm_always;
   //_rupgr     := upgr_2tier;

   _ismech    := true;
end;
UID_UTransport:
begin
   _mhits     := 400;
   _renerg    := 6;
   _r         := 36;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 12;
   _btime     := 60;
   _apcm      := 30;
   _apcs      := 10;
   _ruid      := UID_UTechCenter;
   _uf        := uf_fly;

   _ismech    := true;
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

      _ismech:=_ismech or _isbuilding;

      if(_isbuilding)
      then _zombie_hits:=_mhits div 2
      else _zombie_hits:=_mhits;

      _shcf:=_mhits/_mms;

      if(_btime> 0)then _bstep:=(_mhits div 2) div _btime;
      if(_bstep<=0)then _bstep:=1;
      _tprod:=_btime*fr_fps;
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

   //         race  id               time lvl enr  rupgr        ruid                 multi doom2
   _setUPGR(r_hell,upgr_hell_dattack ,180,4   ,8  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_uarmor  ,180,4   ,8  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_barmor  ,180,4   ,6  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_mattack ,60 ,4   ,6  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_regen   ,60 ,2   ,6  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_pains   ,60 ,3   ,4  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_heye    ,60 ,3   ,6  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_towers  ,120,3   ,6  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_teleport,120,2   ,2  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_pinkspd ,60 ,1   ,6  ,0            ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_6bld    ,20 ,15  ,12 ,0            ,UID_HMonastery     ,true ,false);
   _setUPGR(r_hell,upgr_hell_revmis  ,60 ,1   ,6  ,0            ,UID_HMonastery     ,false,true );
   _setUPGR(r_hell,upgr_hell_totminv ,120,1   ,6  ,0            ,UID_HAltar         ,false,true );
   _setUPGR(r_hell,upgr_hell_b478tel ,30 ,15  ,2  ,0            ,UID_HAltar         ,true ,true );

   _setUPGR(r_uac ,upgr_uac_attack   ,180,4   ,8  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_uarmor   ,120,4   ,6  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_barmor   ,180,4   ,8  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_melee    ,60 ,3   ,6  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_mspeed   ,60 ,2   ,6  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_apcgun   ,120,2   ,6  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_detect   ,60 ,3   ,6  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_towers   ,120,3   ,6  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_detect   ,120,1   ,6  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_radar_r  ,120,3   ,4  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_mines    ,60 ,2   ,4  ,0            ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_6bld     ,120,2   ,12 ,0            ,UID_UTechCenter    ,false,false);
   _setUPGR(r_uac ,upgr_uac_rstrike  ,120,6   ,12 ,0            ,UID_UTechCenter    ,true ,true );
   _setUPGR(r_uac ,upgr_uac_mechspd  ,60 ,2   ,6  ,0            ,UID_UTechCenter    ,false,true );
   _setUPGR(r_uac ,upgr_uac_mecharm  ,180,4   ,8  ,0            ,0                  ,false,true );
   _setUPGR(r_uac ,upgr_uac_turarm   ,120,2   ,6  ,0            ,UID_UTechCenter    ,false,true );



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

   FillChar(_uids   ,SizeOf(_uids   ),0);

   initUIDS;
end;
