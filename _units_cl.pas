


procedure _unit_sclass(pu:PTUnit);
var i:byte;
begin
   with (pu^) do
   begin
      puid:=@_tuids[uid];
      with (puid^) do
      begin
         speed   :=_mspeed;
         srng    :=_srng;
         uf      :=_uf;
         aattack :=true;
         itbarea :=_itbarea;
         itwarea :=_itwarea;

         for i:=0 to MaxAttacks do a_rng[i]:=_a_weap[i].aw_rng;

         {$IFDEF _FULLGAME}
         shadow:=0;
         if(_itbuild)then
         begin
            _mmr:=round(_r*map_mmcx+0.3);
            shadow:=0;
         end
         else
         begin
            shadow:=1+(uf*fly_height);
            _mmr:=1;
         end;
         if(onlySVCode)or(hits>0)then _unit_clfog(pu);
         {$ENDIF}

         if(onlySVCode)then
         begin
            hits:=_mhits div 2;
         end;
      end;
   end;
end;

procedure InitGameData;
var i,a:byte;
procedure att(aa:byte;rng,mdmg,rldt,rlds:integer;mid:byte;req,tp,order:byte;tar:word=0;taru:TSob=[];upgr:byte=0;uid:byte=0);
begin
   with _tuids[i] do
   with _a_weap[aa] do
   begin
      aw_rng  :=rng;
      aw_mdmg :=mdmg;
      aw_rldt :=rldt;
      aw_rlds :=rlds;
      aw_mid  :=mid;
      aw_req  :=req;
      aw_type :=tp;
      aw_order:=order;
      if(order=uo_attack)then
      begin
         aw_tar  :=tar;
         aw_taru :=taru;
         aw_rupgr:=upgr;
         aw_ruid :=uid;
      end
      else
      begin
         aw_tar  :=_toids[order].rtar;
         aw_taru :=_toids[order].rtaru;
         aw_rupgr:=_toids[order].rupgr;
         aw_ruid :=_toids[order].ruid;
      end;
   end;
end;
begin
   // upgrades
   with _tupids[up_hell_dattack] do begin _upcnt:=4 ; _uprenerg:=5 ; _uptime:=240; end;
   with _tupids[up_hell_mattack] do begin _upcnt:=4 ; _uprenerg:=4 ; _uptime:=60 ; end;
   with _tupids[up_hell_uarmor ] do begin _upcnt:=4 ; _uprenerg:=5 ; _uptime:=240; end;
   with _tupids[up_hell_barmor ] do begin _upcnt:=4 ; _uprenerg:=5 ; _uptime:=180; end;

   for i:=1 to 255 do
    with _tupids[i] do
    begin
       // seconds to ticks
       _uptime:=vid_fps*_uptime;
    end;

   // unit orders
   with _toids[uo_rightcl  ] do
   begin
      rtar    :=at_map+at_aall;
      rtaru   :=[0..255];
      toall   :=true;
   end;
                   //
   with _toids[uo_move     ] do begin rspd:=true; rtar:=at_map+at_aall;  rtaru:=[0..255];                 toall:=true;end;
   with _toids[uo_smove    ] do begin rspd:=true; rtar:=at_map+at_aall;  rtaru:=[0..255];   cattack:=true;toall:=true;end;
   with _toids[uo_stop     ] do begin rspd:=true;                                           cattack:=true;toall:=true;end;
   with _toids[uo_hold     ] do begin rspd:=true;                                           cattack:=true;toall:=true;end;
   with _toids[uo_patrol   ] do begin rspd:=true; rtar:=at_map;                             cattack:=true;toall:=true;end;
   with _toids[uo_spatrol  ] do begin rspd:=true; rtar:=at_map;                             cattack:=true;toall:=true;end;
   with _toids[uo_attack   ] do begin rtar:=at_map+at_aenemy;rtaru:=[0..255];r2attack:=true;cattack:=true;toall:=true;end;
   with _toids[uo_auto     ] do begin rnbld:=true;                                                        toall:=true;end;
   with _toids[uo_unload   ] do begin                                                                     toall:=true;end;
   with _toids[uo_upload   ] do begin rtar:=at_aown;         rtaru:=[0..255];                                         end;
   with _toids[uo_rallpos  ] do begin rtar:=at_map+at_aall;  rnbld:=true; rtaru:=[0..255];                toall:=true;end;
   with _toids[uo_destroy  ] do begin rnbld:=true;                                                        toall:=true;end;
   with _toids[uo_uteleport] do begin rtar:=at_aown+at_builds+at_bld;rtaru:=[UID_HTeleport];              toall:=true;end;
   with _toids[uo_spawndron] do begin rmana:=50;rulimit:=true;                                            toall:=true;end;
   with _toids[uo_archresur] do begin rtar:=at_resur;  cauto:=true; rtaru:=[0..255];r2attack:=true;                   end;
   with _toids[uo_botrepair] do begin rtar:=at_mrepair;cauto:=true; rtaru:=[0..255];r2attack:=true;       toall:=true;end;
   with _toids[uo_spawnlost] do begin rulimit:=true;                                                      toall:=true;end;

   with _toids[uo_prod] do
   begin
      rulimit:= true;
      rtar   := at_map;
   end;

   // Start base

   utbl_start[r_hell]:=UID_HKeep;
   utbl_start[r_uac ]:=UID_UCommandCenter;

   // Units

   for i:=0 to 255 do
    with _tuids[i] do
    begin
       _renerg    := 1;
       _solid     := true;
       _max       := 255;
       _mhits     := 100;
       _apcs      := 1;
       _r         := 5;
       _fastturn  := true;

       _fdeath    := false;
       _itbuild   := false;
       _itmech    := false;
       _itbarrack := false;
       _itsmith   := false;
       _itbuilder := false;
       _itattack  := atm_none;

       case i of
UID_LostSoul :
       begin
          _mhits   := 80;
          _r       := 10;
          _uf      := uf_soaring;
          _mspeed  := 20;
          _srng    := 260;
          _painc   := 3;
          _ctime   := vid_fps*5;
          _renerg  := 1;
          _itattack:= atm_always;
          _urace   := r_hell;
          att(0,-1,15,60,0,0      ,wpr_any,wpt_ddmg,uo_attack,at_aenemy,[1..255] );
       end;
UID_Imp :
       begin
          _mhits   := 70;
          _r       := 12;
          _uf      := uf_ground;
          _mspeed  := 8;
          _srng    := 230;
          _painc   := 3;
          _ctime   := vid_fps*5;
          _renerg  := 1;
          _itattack:= atm_always;
          _urace   := r_hell;
          att(0,0 ,0 ,65,0,MID_Imp,wpr_any,wpt_msle,uo_attack,at_aenemy,[1..255]-[i] );
          att(1,-1,15,60,0,0      ,wpr_any,wpt_ddmg,uo_attack,at_aenemy,[1..255]     );
       end;
UID_Demon:
       begin
          _mhits   := 150;
          _r       := 13;
          _uf      := uf_ground;
          _mspeed  := 14;
          _srng    := 220;
          _painc   := 8;
          _ctime   := vid_fps*10;
          _renerg  := 1;
          _itattack:= atm_always;
          _urace   := r_hell;
          att(0,-1,30,60,0,0      ,wpr_any,wpt_ddmg,uo_attack,at_aenemy+at_ground,[1..255] );
       end;
UID_CacoDemon:
      begin
         _mhits   := 200;
         _r       := 14;
         _uf      := uf_fly;
         _mspeed  := 8;
         _srng    := 260;
         _painc   := 6;
         _ctime   := vid_fps*20;
         _renerg  := 2;
         _itattack:= atm_always;
         _urace   := r_hell;
         _zfall   := 60;
         att(0,0 ,0 ,75,0,MID_Cacodemon,wpr_any,wpt_msle,uo_attack,at_aenemy,[1..255]-[i] );
         att(1,-1,20,60,0,0            ,wpr_any,wpt_ddmg,uo_attack,at_aenemy,[1..255]     );
      end;
UID_Knight:
      begin
         _mhits   := 300;
         _r       := 13;
         _uf      := uf_ground;
         _mspeed  := 8;
         _srng    := 230;
         _painc   := 4;
         _ctime   := vid_fps*40;
         _renerg  := 3;
         _itattack:= atm_always;
         _urace   := r_hell;
         att(0,0 ,0 ,75,0,MID_Baron,wpr_any,wpt_msle,uo_attack,at_aenemy,[1..255]-[i] );
         att(1,-1,40,60,0,0        ,wpr_any,wpt_ddmg,uo_attack,at_aenemy,[1..255]     );
      end;
UID_Cyberdemon:
      begin
         _mhits   := 1800;
         _r       := 20;
         _uf      := uf_ground;
         _mspeed  := 9;
         _srng    := 260;
         _painc   := 13;
         //_a_rldr  := 65;
         _ctime   := vid_fps*120;
         _max     := 1;
         _renerg  := 10;
         _ruid    := UID_HMonastery;
         _itattack:= atm_always;
         _urace   := r_hell;
         att(0,0 ,0 ,65,0,MID_HRocket,wpr_any,wpt_msle,uo_attack,at_aenemy,[1..255] );
      end;
UID_Mastermind:
      begin
         _mhits   := 1800;
         _r       := 35;
         _uf      := uf_ground;
         _mspeed  := 9;
         _srng    := 260;
         _painc   := 13;
         //_a_rldr  := 9;
         _ctime   := vid_fps*120;
         _max     := 1;
         _renerg  := 10;
         _ruid    := UID_HMonastery;
         _itattack:= atm_always;
         _urace   := r_hell;
      end;
UID_Pain:
      begin
         _mhits   := 170;
         _r       := 15;
         _uf      := uf_fly;
         _mspeed  := 8;
         _srng    := 310;
         _painc   := 3;
         _ctime   := vid_fps*60;
         _renerg  := 5;
         _ruid    := UID_HFortress;
         _urace   := r_hell;
         _itattack:= atm_always;
         att(0,0,0,90,0,UID_LostSoul ,wpr_any,wpt_uspwn,uo_attack,at_aenemy,[1..255]);
         _orders:=[uo_spawnlost]
      end;
UID_Revenant:
      begin
         _mhits   := 210;
         _r       := 15;
         _uf      := uf_ground;
         _mspeed  := 11;
         _srng    := 280;
         //_ratt    := 0;
         _painc   := 7;
         //_a_rldr  := 70;
         _ctime   := vid_fps*60;
         _renerg  := 5;
         _ruid    := UID_HFortress;
         _itattack:= atm_always;
         _urace   := r_hell;
         //_mdamage := 25;
      end;
UID_Mancubus:
      begin
         _mhits   := 325;
         _r       := 20;
         _uf      := uf_ground;
         _mspeed  := 5;
         _srng    := 280;
         //_ratt    := 0;
         _painc   := 6;
         //_a_rldr  := 150;
         _ctime   := vid_fps*60;
         _renerg  := 6;
         _ruid    := UID_HFortress;
         _itattack:= atm_always;
         _urace   := r_hell;
      end;
UID_Arachnotron:
      begin
         _mhits   := 300;
         _r       := 20;
         _uf      := uf_ground;
         _mspeed  := 8;
         _srng    := 280;
         //_ratt    := 0;
         _painc   := 4;
         //_a_rldr  := 15;
         _ctime   := vid_fps*60;
         _renerg  := 6;
         _ruid    := UID_HFortress;
         _itattack:= atm_always;
         _urace   := r_hell;
      end;
UID_ArchVile:
      begin
         _mhits   := 300;
         _r       := 15;
         _uf      := uf_ground;
         _mspeed  := 14;
         _srng    := 330;
         //_ratt    := 0;
         _painc   := 12;
         //_a_rldr  := 140;
         _ctime   := vid_fps*80;
         _renerg  := 7;
         _ruid    := UID_HFortress;
         _itattack:= atm_always;
         _urace   := r_hell;
         att(0,-1,0,60,0,0,wpr_any,wpt_resur,uo_archresur);
      end;

       ////////////////////////////////////////////////////////////////////////////////
UID_HKeep:
       begin
          _mhits    := 3000;
          _uf       := uf_ground;
          _srng     := 280;
          _r        := 66;
          _generg   := 3;
          _renerg   := 4;
          _itbuild  := true;
          _itbarea  := true;
          _itbuilder:= true;
          _urace    := r_hell;
       end;
UID_HGate:
       begin
          _mhits    := 1500;
          _uf       := uf_ground;
          _srng     := 200;
          _r        := 60;
          _generg   := 0;
          _renerg   := 2;
          _bldstep  := 20;
          _itbuild  := true;
          _itbarrack:= true;
          _urace    := r_hell;
       end;
UID_HSymbol:
       begin
          _mhits    := 300;
          _uf       := uf_ground;
          _srng     := 200;
          _r        := 25;
          _generg   := 1;
          _renerg   := 1;
          _bldstep  := 8;
          _itbuild  := true;
          _urace    := r_hell;
          _itwarea  := true;
       end;
UID_HPools:
       begin
          _mhits    := 1000;
          _uf       := uf_ground;
          _srng     := 200;
          _r        := 55;
          _generg   := 0;
          _renerg   := 4;
          _bldstep  := 10;
          _itbuild  := true;
          _itsmith  := true;
          _urace    := r_hell;
       end;
UID_HTower:
       begin
          _mhits    := 600;
          _uf       := uf_ground;
          _srng     := 260;
          _r        := 22;
          _generg   := 0;
          _renerg   := 1;
          //_a_rldr   := 40;
          _bldstep  := 14;
          _itbuild  := true;
          _urace    := r_hell;
          _itattack := atm_always;
       end;
UID_HTeleport:
       begin
          _mhits    := 500;
          _uf       := uf_ground;
          _srng     := 200;
          _r        := 30;
          _generg   := 0;
          _renerg   := 2;
          _solid    := false;
          _max      := 1;
          _bldstep  := 10;
          _itbuild  := true;
          _urace    := r_hell;
          _orders   := [uo_rallpos];
       end;
UID_HMonastery:
       begin
          _mhits    := 1000;
          _uf       := uf_ground;
          _srng     := 200;
          _r        := 65;
          _generg   := 0;
          _renerg   := 6;
          _max      := 1;
          _bldstep  := 5;
          _itbuild  := true;
          _ruid     := UID_HPools;
          _urace    := r_hell;
       end;
UID_HFortress:
       begin
          _mhits    := 3000;
          _uf       := uf_ground;
          _srng     := 330;
          _r        := 86;
          _generg   := 2;
          _renerg   := 8;
          _max      := 1;
          _bldstep  := 8;
          _itbuild  := true;
          _itbarea  := true;
          _ruid     := UID_HMonastery;
          _itbuilder:= true;
          _urace    := r_hell;
       end;
UID_HTotem:
       begin
          _mhits    := 500;
          _uf       := uf_ground;
          _srng     := 260;
          _r        := 22;
          _generg   := 0;
          _renerg   := 3;
          _bldstep  := 10;
          //_a_rldr   := 140;
          _itbuild  := true;
          _ruid     := UID_HFortress;
          _urace    := r_hell;
          _itattack := atm_always;
       end;
UID_HAltar:
       begin
          _mhits    := 1000;
          _uf       := uf_ground;
          _srng     := 200;
          _r        := 50;
          _generg   := 0;
          _renerg   := 4;
          _bldstep  := 15;
          _max      := 1;
          _itbuild  := true;
          _ruid     := UID_HFortress;
          _urace    := r_hell;
       end;

UID_HMilitaryUnit:
       begin
          _mhits    := 1500;
          _uf       := uf_ground;
          _srng     := 200;
          _r        := 70;
          _generg   := 0;
          _renerg   := 2;
          _bldstep  := 20;
          _itbuild  := true;
          _urace    := r_hell;
       end;
       ////////////////////////////////////////////////////////////////////////////////

UID_Dron:
       begin
          _mhits    := 50;
          _r        := 11;
          _uf       := uf_ground;
          _mspeed   := 10;
          _srng     := 220;
          _ctime    := vid_fps*8;
          _renerg   := 1;
          _itmech   := true;
          _ruid     := UID_UCommandCenter;
          _itbuilder:= true;
          _urace    := r_uac;
          _itattack := atm_always;
          att(0,-1, 8,40,0,0     ,wpr_any,wpt_heal,uo_botrepair);
       end;

UID_Scout:
       begin
          _mhits   := 95;
          _r       := 12;
          _uf      := uf_ground;
          _mspeed  := 12;
          _srng    := 260;
          //_ratt    := 0;
          _painc   := 0;
          //_a_rldr  := 45;
          _ctime   := vid_fps*5;
          _renerg  := 1;
          _itattack:= atm_always;
          _urace    := r_uac;
       end;
UID_Sergant:
       begin
          _mhits   := 95;
          _r       := 12;
          _uf      := uf_ground;
          _mspeed  := 12;
          _srng    := 200;
          //_ratt    := 0;
          _painc   := 0;
          //_a_rldr  := 65;
          _ctime   := vid_fps*10;
          _renerg  := 1;
          _itattack:= atm_inmove;
          _urace    := r_uac;
       end;
UID_Medic:
       begin
          _mhits   := 95;
          _r       := 12;
          _uf      := uf_ground;
          _mspeed  := 12;
          _srng    := 230;
          //_ratt    := 0;
          _painc   := 0;
          //_a_rldr  := 45;
          _ctime   := vid_fps*5;
          _renerg  := 1;
          _itattack:= atm_always;
          _ruid    := UID_UWeaponFactory;
          _urace    := r_uac;
       end;

UID_FAPC:
       begin
          _mhits    := 250;
          _r        := 28;
          _uf       := uf_fly;
          _mspeed   := 22;
          _srng     := 260;
          _ctime    := vid_fps*25;
          _renerg   := 3;
          _itmech   := true;
          _apcm     := 10;
          _apcuids  := [UID_Dron,UID_Scout,UID_Sergant,UID_Medic,UID_APC];
          _urace    := r_uac;
          _fastturn := false;
          _orders   := [uo_unload];
       end;
UID_APC:
      begin
         _mhits    := 350;
         _r        := 20;
         _uf       := uf_ground;
         _mspeed   := 16;
         _srng     := 260;
         _ctime    := vid_fps*25;
         _renerg   := 3;
         _itmech   := true;
         _apcs     := 10;
         _apcm     := 5;
         _apcuids  := [UID_Dron,UID_Scout,UID_Sergant,UID_Medic];
         _itattack := atm_bunker;
         _urace    := r_uac;
         _fastturn := false;
         _orders   := [uo_unload];
      end;

////////////////////////////////////////////////////////////////////////////////
UID_UCommandCenter:
       begin
          _mhits    := 4000;
          _uf       := uf_ground;
          _srng     := 280;
          _r        := 66;
          _generg   := 4;
          _renerg   := 5;
          _itbuild  := true;
          _urace    := r_uac;
          _orders   := [uo_spawndron];
       end;
UID_UMilitaryUnit:
       begin
          _mhits    := 1750;
          _uf       := uf_ground;
          _srng     := 200;
          _r        := 60;
          _generg   := 0;
          _renerg   := 2;
          _bldstep  := 18;
          _itbuild  := true;
          _ruid     := UID_UCommandCenter;
          _itbarrack:= true;
          _urace    := r_uac;
       end;
UID_UGenerator:
       begin
          _mhits   := 500;
          _uf      := uf_ground;
          _srng    := 200;
          _r       := 42;
          _generg  := 2;
          _renerg  := 1;
          _bldstep := 7;
          _itbuild := true;
          _ruid    := UID_UCommandCenter;
          _urace    := r_uac;
       end;
UID_UWeaponFactory:
       begin
          _mhits   := 1700;
          _uf      := uf_ground;
          _srng    := 200;
          _r       := 62;
          _generg  := 0;
          _renerg  := 4;
          _bldstep := 15;
          _itbuild := true;
          _ruid    := UID_UCommandCenter;
          _itsmith := true;
          _urace   := r_uac;
       end;
UID_UTurret:
       begin
          _mhits   := 400;
          _uf      := uf_ground;
          _srng    := 260;
          _r       := 19;
          _generg  := 0;
          _renerg  := 1;
          _bldstep := 13;
          _itbuild := true;
          _ruid    := UID_UCommandCenter;
          _urace   := r_uac;
          //_a_rldr  := 6;
          _itattack:= atm_always;
       end;
UID_URadar:
       begin
          _mhits   := 500;
          _uf      := uf_ground;
          _srng    := 200;
          _r       := 35;
          _generg  := 0;
          _renerg  := 2;
          _bldstep := 10;
          _max     := 1;
          _itbuild := true;
          _ruid    := UID_UWeaponFactory;
          _urace   := r_uac;
       end;
UID_UVehicleFactory:
       begin
          _mhits   := 1700;
          _uf      := uf_ground;
          _srng    := 200;
          _r       := 62;
          _generg  := 0;
          _renerg  := 5;
          _bldstep := 9;
          _max     := 1;
          _itbuild := true;
          _ruid    := UID_UWeaponFactory;
          _urace   := r_uac;
       end;
UID_UPTurret:
       begin
          _mhits   := 600;
          _uf      := uf_ground;
          _srng    := 260;
          _r       := 19;
          _generg  := 0;
          _renerg  := 2;
          _bldstep := 13;
          _itbuild := true;
          _ruid    := UID_UVehicleFactory;
          _urace   := r_uac;
          _itattack:= atm_always;
          //_a_rldr  := 70;
       end;
UID_URTurret:
       begin
          _mhits   := 600;
          _uf      := uf_ground;
          _srng    := 260;
          _r       := 19;
          _generg  := 0;
          _renerg  := 2;
          _bldstep := 13;
          _itbuild := true;
          _ruid    := UID_UVehicleFactory;
          _urace   := r_uac;
          _itattack:= atm_always;
          //_a_rldr  := 70;
       end;
UID_URocketL:
       begin
          _mhits   := 1000;
          _uf      := uf_ground;
          _srng    := 200;
          _r       := 40;
          _generg  := 0;
          _renerg  := 2;
          _max     := 1;
          _itbuild := true;
          _ruid    := UID_UVehicleFactory;
          _urace   := r_uac;
       end;

       end;

       _shcf:=_mhits/_mms;
       if(_itbuild)then
       begin
          if(_bldstep=0)then _bldstep:=18;
          _itmech:=true;
       end;
       if(_ctime=0)and(_bldstep>0)then _ctime  :=(_mhits*_uclord_p) div _bldstep;
       if(_ctime>0)and(_bldstep=0)then _bldstep:=(_mhits*_uclord_p) div _ctime;
       if(_bldstep=0)then _bldstep:=1;
       if(_ctime  =0)then _ctime  :=1;

       for a:=0 to MaxAttacks do
         with _a_weap[a] do
         begin
            if(aw_rlds=0)then aw_rlds:=aw_rldt;
            if(_itattack>0)and(aw_rldt>0)then _orders:=_orders+[aw_order,uo_rightcl];
         end;
       if(_itbarrack)or(i in [UID_UCommandCenter])then _orders:=_orders+[uo_rallpos,uo_rightcl];
       if(_mspeed>0     )then _orders:=_orders+[uo_smove,uo_move,uo_spatrol,uo_patrol,uo_hold,uo_stop,uo_rightcl];
       if(_itbuilder    )
       or(_itbarrack    )
       or(_itsmith      )then _orders:=_orders+[uo_prod     ];
       if(_itbuild=false)then _orders:=_orders+[uo_uteleport,uo_rightcl];
       _orders:=_orders+[uo_destroy,uo_upload,uo_auto];
    end;

end;

