
{$IFDEF _FULLGAME}
procedure _unit_clfog(pu:PTUnit);
begin
   with (pu^) do
   begin
      fsr:=srng div fog_cw;
      if(fsr>MFogM)then fsr:=MFogM;
   end;
end;

{$ENDIF}

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

procedure InitUnits;
{$IFDEF _FULLGAME}
const
     btnhkeys1 : array[0..ui_p_btnsh,0..ui_p_lsecwi] of cardinal =
       ((SDLK_R, SDLK_T, SDLK_Y, SDLK_U, SDLK_I     ,SDLK_O    , SDLK_R, SDLK_T, SDLK_Y, SDLK_U),
        (SDLK_F, SDLK_G, SDLK_H, SDLK_J, SDLK_K     ,SDLK_L    , SDLK_F, SDLK_G, SDLK_H, SDLK_J),
        (SDLK_V, SDLK_B, SDLK_N, SDLK_M, SDLK_PERIOD,SDLK_COMMA, SDLK_V, SDLK_B, SDLK_N, SDLK_M));
     btnhkeys2 : array[0..ui_p_btnsh,0..ui_p_lsecwi] of cardinal =
       ((0, 0, 0, 0, 0, 0, SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl),
        (0, 0, 0, 0, 0, 0, SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl),
        (0, 0, 0, 0, 0, 0, SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl));
     //SDLK_LESS, SDLK_GREATER
{$ENDIF}
var i,a:byte;
{$IFDEF _FULLGAME}
procedure snd(advt:byte;sndt:byte;sndc:pMIX_CHUNK=nil;eid:byte=0;eids:pMIX_CHUNK=nil);
var adv:boolean;
begin
   with _tuids[i] do
   begin
      adv:=false;
      if(advt=1)then adv:=true;
      if(advt>2)then snd(1,sndt,sndc,eid,eids);

      if(sndc<>nil)then   // sound
       if(_ueffsndn[adv,sndt]<MaxUIDSnds)then
       begin
          _ueffsnds[adv,sndt,_ueffsndn[adv,sndt]]:=sndc;
          inc(_ueffsndn[adv,sndt],1);
       end;
      if(eid  >0  )then _ueffeid [adv,sndt]:=eid; // effect
      if(eids<>nil)then _ueffeids[adv,sndt]:=eids; // effect sound
   end;
end;
procedure asnd(wp:byte;snd:pMIX_CHUNK;arld:integer=-1);
begin
   with _tuids[i] do
   with _a_weap[wp] do
   begin
      aw_snd:=snd;
      if(arld=-3)then aw_rlda:= aw_rldt div 3;
      if(arld=-2)then aw_rlda:= aw_rldt div 2;
      if(arld=-1)then aw_rlda:=(aw_rldt div 3)*2;
      if(arld>-1)then aw_rlda:= aw_rldt;
   end;
end;
procedure csnd(snd:pMIX_CHUNK);
begin
   with _tuids[i] do
    if(snd<>nil)then
     if(_com_sndn<MaxUIDSnds)then
     begin
        _com_snds[_com_sndn]:=snd;
        inc(_com_sndn,1);
     end;
end;
{$ENDIF}
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
   with _toids[uo_auto     ] do begin rnbld:=true; toall:=true;  end;
   with _toids[uo_unload   ] do begin                                                                     toall:=true;end;
   with _toids[uo_upload   ] do begin rtar:=at_aown;         rtaru:=[0..255];                                         end;
   with _toids[uo_rallpos  ] do begin rtar:=at_map+at_aall;  rnbld:=true; rtaru:=[0..255];                toall:=true;end;
   with _toids[uo_destroy  ] do begin rnbld:=true;                                                        toall:=true;end;
   with _toids[uo_uteleport] do begin rtar:=at_aown+at_builds+at_bld;rtaru:=[UID_HTeleport];              toall:=true;end;
   with _toids[uo_spawndron] do begin rmana:=50;rulimit:=true;                                            toall:=true;end;
   with _toids[uo_archresur] do begin rtar:=at_resur;  cauto:=true;rtaru:=[0..255];r2attack:=true;                    end;
   with _toids[uo_botrepair] do begin rtar:=at_mrepair;cauto:=true;rtaru:=[0..255];r2attack:=true;        toall:=true;end;

   with _toids[uo_prod] do
   begin
      rulimit:= true;
      rtar   := at_map;
   end;

   utbl_start[r_hell]:=UID_HKeep;
   utbl_start[r_uac ]:=UID_UCommandCenter;

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

       _altdeath  := false;
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
          att(1,-1,15,60,0,0      ,wpr_any,wpt_ddmg,uo_attack,at_aenemy,[UID_Imp]    );
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
          att(0,-1,30,60,0,0      ,wpr_any,wpt_ddmg,uo_attack,at_aenemy+at_ground,[0..255] );
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
         att(0,0 ,0 ,75,0,MID_Cacodemon,wpr_any,wpt_msle,uo_attack,at_aenemy,[1..255]-[i]    );
         att(1,-1,20,60,0,0            ,wpr_any,wpt_ddmg,uo_attack,at_aenemy,[UID_Cacodemon] );
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
         att(1,-1,40,60,0,0        ,wpr_any,wpt_ddmg,uo_attack,at_aenemy,[UID_Knight] );
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
         //_a_rldr  := 95;
         _ctime   := vid_fps*60;
         _renerg  := 5;
         _ruid    := UID_HFortress;
         _urace   := r_hell;
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
            if(_itattack>0)and(aw_rldt>0)then _orders:=_orders+[aw_order];
         end;
       if(_itbarrack)or(i in [UID_UCommandCenter])then _orders:=_orders+[uo_rallpos];
       if(_mspeed>0  )then _orders:=_orders+[uo_smove,uo_move,uo_spatrol,uo_patrol,uo_hold,uo_stop];
       if(_itbuilder )
       or(_itbarrack )then _orders:=_orders+[uo_prod];
       if(_itbuild=false)then _orders:=_orders+[uo_uteleport];
       _orders:=_orders+[uo_destroy,uo_upload,uo_auto];

       {$IFDEF _FULLGAME}
       _fr      := (_r div fog_cw)+1;
       _anims   := 0;
       _btnx    := 255;
       _btny    := 255;
       _sdpth   := 0;


       case i of
       UID_HKeep          : begin _btny:= 0;_btnx:=0; end;
       UID_HGate          : begin _btny:= 0;_btnx:=1; end;
       UID_HSymbol        : begin _btny:= 0;_btnx:=2; end;
       UID_HPools         : begin _btny:= 0;_btnx:=3; end;
       UID_HTower         : begin _btny:= 0;_btnx:=4; end;
       UID_HTeleport      : begin _btny:= 0;_btnx:=5; _sdpth:=-4;end;
       UID_HMonastery     : begin _btny:= 1;_btnx:=0; end;
       UID_HFortress      : begin _btny:= 1;_btnx:=1; end;
       UID_HTotem         : begin _btny:= 2;_btnx:=0; end;
       UID_HAltar         : begin _btny:= 2;_btnx:=1; _sdpth:=-3;end;

       UID_UCommandCenter : begin _btny:= 0;_btnx:=0; end;
       UID_UMilitaryUnit  : begin _btny:= 0;_btnx:=1; end;
       UID_UGenerator     : begin _btny:= 0;_btnx:=2; end;
       UID_UWeaponFactory : begin _btny:= 0;_btnx:=3; end;
       UID_UTurret        : begin _btny:= 0;_btnx:=4; _anims:=3; end;
       UID_URadar         : begin _btny:= 0;_btnx:=5; end;
       UID_UVehicleFactory: begin _btny:= 1;_btnx:=0; end;
       UID_UPTurret       : begin _btny:= 2;_btnx:=0; end;
       UID_URTurret       : begin _btny:= 2;_btnx:=1; end;
       UID_URocketL       : begin _btny:= 2;_btnx:=2; end;



//                                                                    DEATH                          PAIN                          CREATE                        MELEE ATTACK           DISTANCE ATTACK
       UID_Imp            : begin _btny:= 0;_btnx:=0; _anims  := 11;  snd(2 ,ueff_death,snd_impd1  );snd(2,ueff_pain  ,snd_z_p   );snd(2,ueff_create,snd_impc1 );asnd(1,snd_hmelee ,-2);asnd(0,snd_hshoot ,-2);
                                                                      snd(2 ,ueff_death,snd_impd2  );snd(2,ueff_create,snd_impc2 );                                                                            end;
       UID_LostSoul       : begin _btny:= 0;_btnx:=1;                 snd(2 ,ueff_death,snd_pexp   );snd(2,ueff_pain  ,snd_dpain );snd(2,ueff_create,snd_d0    );asnd(1,snd_d0     ,-2);                       end;
       UID_Demon          : begin _btny:= 0;_btnx:=2; _anims  := 14;  snd(2 ,ueff_death,snd_demond );snd(2,ueff_pain  ,snd_dpain );snd(2,ueff_create,snd_demonc);asnd(1,snd_demona ,-2);                       end;
       UID_Cacodemon      : begin _btny:= 0;_btnx:=3;                 snd(2 ,ueff_death,snd_cacod  );snd(2,ueff_pain  ,snd_dpain );snd(2,ueff_create,snd_cacoc );asnd(1,snd_hmelee ,-2);asnd(0,snd_hshoot ,-2);end;
       UID_Knight         : begin _btny:= 0;_btnx:=4; _anims  := 11;  snd(0 ,ueff_death,snd_knightd);snd(2,ueff_pain  ,snd_dpain );snd(2,ueff_create,snd_knight);asnd(1,snd_hmelee ,-2);asnd(0,snd_hshoot ,-2);
                                                                      snd(1 ,ueff_death,snd_barond );end; //snd_baron
       UID_Cyberdemon     : begin _btny:= 0;_btnx:=5; _anims  := 10;  snd(2 ,ueff_death,snd_cyberd );snd(2,ueff_pain  ,snd_dpain );snd(2,ueff_create,snd_cyberc);                       asnd(0,snd_launch ,-2);end;
       UID_Mastermind     : begin _btny:= 1;_btnx:=0; _anims  := 10;  snd(2 ,ueff_death,snd_mindd  );snd(2,ueff_pain  ,snd_dpain );snd(2,ueff_create,snd_mindc );                       asnd(0,snd_shotgun,-2);end;
       UID_Pain           : begin _btny:= 1;_btnx:=1; _anims  := 6 ;  snd(2 ,ueff_death,snd_pain_d );snd(2,ueff_pain  ,snd_pain_p);snd(2,ueff_create,snd_pain_c);                       asnd(0,snd_d0     ,-2);end;
       UID_Revenant       : begin _btny:= 1;_btnx:=2; _anims  := 14;  snd(2 ,ueff_death,snd_rev_d  );snd(2,ueff_pain  ,snd_z_p   );snd(2,ueff_create,snd_rev_c );asnd(1,snd_rev_m  ,-2);asnd(0,snd_rev_a  ,-2);end;
       UID_Mancubus       : begin _btny:= 1;_btnx:=3; _anims  := 9 ;  snd(2 ,ueff_death,snd_man_d  );snd(2,ueff_pain  ,snd_man_p );snd(2,ueff_create,snd_man_c );                       asnd(0,snd_man_a  , 0);end;
       UID_Arachnotron    : begin _btny:= 1;_btnx:=4; _anims  := 10;  snd(2 ,ueff_death,snd_ar_d   );snd(2,ueff_pain  ,snd_dpain );snd(2,ueff_create,snd_ar_c  );                       asnd(0,snd_plasmas, 0);end;
       UID_Archvile       : begin _btny:= 1;_btnx:=5; _anims  := 15;  snd(2 ,ueff_death,snd_arch_d );snd(2,ueff_pain  ,snd_arch_p);snd(2,ueff_create,snd_arch_c);asnd(1,snd_meat   ,-2);asnd(0,snd_arch_a ,-2);end;

       UID_ZFormer        : begin _btny:= 2;_btnx:=0; _anims  := 17; end;
       UID_ZSergant       : begin _btny:= 2;_btnx:=1; _anims  := 17; end;
       UID_ZCommando      : begin _btny:= 2;_btnx:=2; _anims  := 14; end;
       UID_ZBomber        : begin _btny:= 2;_btnx:=3; _anims  := 13; end;
       UID_ZMajor         : begin _btny:= 2;_btnx:=4; _anims  := 14; end;
       UID_ZBFG           : begin _btny:= 2;_btnx:=5; _anims  := 13; end;



       UID_Dron           : begin                                    snd(2,ueff_create,snd_dron0 );
                                                                     snd(2,ueff_create,snd_dron1 );asnd(0,snd_cast2 ,-2);end;
       UID_Sergant        : begin _btny:= 0;_btnx:=0; _anims  := 17; end;
       UID_Commando       : begin _btny:= 0;_btnx:=1; _anims  := 14; end;
       UID_Medic          : begin _btny:= 0;_btnx:=2; _anims  := 17; end;
       UID_Bomber         : begin _btny:= 0;_btnx:=3; _anims  := 13; end;
       UID_Major          : begin _btny:= 0;_btnx:=4; _anims  := 13; end;
       UID_BFG            : begin _btny:= 0;_btnx:=5; _anims  := 13; end;
       UID_Scout          : begin{_btny:= 0;_btnx:=7;}_anims  := 17; end;
       UID_FAPC           : begin _btny:= 1;_btnx:=0;                end;
       UID_APC            : begin _btny:= 1;_btnx:=1; _anims  := 17; end;
       UID_Terminator     : begin _btny:= 2;_btnx:=0; _anims  := 13; end;
       UID_Tank           : begin _btny:= 2;_btnx:=1; _anims  := 17; end;
       UID_Flyer          : begin _btny:= 2;_btnx:=2;                end;

       UID_Mine           : begin _sdpth:=-2; end;
       end;

       case i of
       UID_ZFormer,
       UID_ZSergant,
       UID_ZCommando,
       UID_ZBomber,
       UID_ZMajor,
       UID_ZBFG      : begin
                          snd(2,ueff_create,snd_z_s1);snd(2,ueff_death ,snd_z_d1);snd(2,ueff_pain  ,snd_z_p );
                          snd(2,ueff_create,snd_z_s2);snd(2,ueff_death ,snd_z_d2);snd(2,ueff_adeath,snd_meat);
                          snd(2,ueff_create,snd_z_s3);snd(2,ueff_death ,snd_z_d3);
                       end;
       UID_Scout,
       UID_Medic,
       UID_Sergant,
       UID_Commando,
       UID_Bomber,
       UID_Major,
       UID_BFG       : begin
                          snd(2,ueff_create,snd_uac_u0);csnd(snd_uac_u0);snd(2,ueff_death,snd_ud1);snd(2,ueff_adeath,snd_meat);
                          snd(2,ueff_create,snd_uac_u1);csnd(snd_uac_u1);snd(2,ueff_death,snd_ud2);
                          snd(2,ueff_create,snd_uac_u2);csnd(snd_uac_u2);
                       end;
       UID_FAPC,
       UID_APC,
       UID_Terminator,
       UID_Tank,
       UID_Flyer     : begin
                          snd(2,ueff_create,snd_uac_u0);csnd(snd_uac_u0);
                          snd(2,ueff_create,snd_uac_u1);csnd(snd_uac_u1);
                          snd(2,ueff_create,snd_uac_u2);csnd(snd_uac_u2);
                       end;
       end;

       case i of
       UID_Imp          : csnd(snd_imp);
       UID_LostSoul,
       UID_Demon,
       UID_Cacodemon,
       UID_Knight,
       UID_Cyberdemon,
       UID_Mastermind,
       UID_Pain         : csnd(snd_demon1);
       UID_Revenant     : csnd(snd_rev_ac);
       UID_ZFormer,
       UID_ZSergant,
       UID_ZCommando,
       UID_ZBomber,
       UID_ZMajor,
       UID_ZBFG,
       UID_Mancubus     : csnd(snd_zomb);
       UID_Arachnotron  : csnd(snd_ar_act);
       UID_Archvile     : csnd(snd_arch_a);
       end;

       case _urace of
       r_hell : if(_itbuild)
                then snd(2,ueff_startb,snd_cubes)
                else snd(2,ueff_startb,snd_teleport);
       r_uac  : if(_itbuild)
                then snd(2,ueff_startb,snd_ubuild)
                else snd(2,ueff_startb,snd_teleport);
       end;

       case i of
       UID_Cyberdemon : begin _foota:=30;snd(2,ueff_foot,snd_cyberf); end;
       UID_Arachnotron: begin _foota:=28;snd(2,ueff_foot,snd_ar_f  ); end;
       UID_Mastermind : begin _foota:=22;snd(2,ueff_foot,snd_mindf ); end;
       end;

       if(_ukey1=0)then
        if(_btnx<=ui_p_lsecwi)and(_btny<=ui_p_btnsh)then
        begin
           _ukey1:=btnhkeys1[_btny,_btnx];
           _ukey2:=btnhkeys2[_btny,_btnx];
        end;

       if(_ukey1=0)
       then _ukeyc:=''
       else
       begin
          _ukeyc:=UpperCase(GetKeyName(_ukey1));
          case _ukey2 of
          SDLK_LCtrl : _ukeyc:='Ctr+'+_ukeyc;
          SDLK_LShift: _ukeyc:='Sft+'+_ukeyc;
          SDLK_LAlt  : _ukeyc:='Alt+'+_ukeyc;
          0          : ;
          else
             _ukeyc:='???+'+_ukeyc;
          end;
       end;

       {$ENDIF}
    end;

end;
{
{$IFDEF _FULLGAME}PlaySND(snd_pistol,pu);{$ENDIF}
{$IFDEF _FULLGAME}PlaySND(snd_shotgun,pu);{$ENDIF}
procedure _unit_deff(pu:PTUnit;deff:boolean);
begin
   with (pu^) do
   with (puid^) do
   with _players[player] do
   begin
      if(_itbuild)then
      begin

      end;


      if(deff)then
      begin
         if(_itbuild)then
         begin
            if(uid=UID_Mine)then
            begin
               PlaySND(snd_exp,pu);
               _effect_add(vx,vy,map_flydpth[_uf]+vy,EID_Exp);
            end
            else
            begin
               if(race=r_hell)and(hits<200)and(bld=false)then
               begin
                  if(_r<41)
                  then _effect_add(vx,vy+5 ,-5,eid_db_h1)
                  else _effect_add(vx,vy+10,-5,eid_db_h0);
                  exit;
               end;
               PlaySND(snd_exp2,pu);
               if(_r>48)then
               begin
                  _effect_add(vx,vy,map_flydpth[_uf]+vy,EID_BBExp);
                  if(race=r_hell)
                  then _effect_add(vx,vy+10,-10,eid_db_h0)
                  else _effect_add(vx,vy+10,-10,eid_db_u0);
               end
               else
               begin
                  _effect_add(vx,vy,map_flydpth[_uf]+vy,EID_BExp);
                  if(race=r_hell)
                  then _effect_add(vx,vy+10,-10,eid_db_h1)
                  else _effect_add(vx,vy+10,-10,eid_db_u1);
               end;
            end;
         end
         else
           if(_gavnodth)then
            if(_uf>uf_ground)then
            begin
               PlaySND(snd_exp,pu);
               _effect_add(vx,vy,map_flydpth[_uf]+vy,EID_Exp);
            end
            else
            begin
               PlaySND(snd_meat,pu);
               _effect_add(vx,vy,map_flydpth[_uf]+vy,EID_Gavno);
            end
           else
            case uid of
        UID_Dron :   begin
                        PlaySND(snd_exp,pu);
                        _effect_add(vx,vy,map_flydpth[_uf]+vy,EID_Exp);
                     end;
        UID_APC,
        UID_FAPC   : begin
                        PlaySND(snd_exp,pu);
                        _effect_add(vx,vy,map_flydpth[_uf]+vy,EID_BExp);
                     end;
        UID_Flyer,
        UID_Terminator,
        UID_Tank   : begin
                        PlaySND(snd_exp,pu);
                        _effect_add(vx,vy,map_flydpth[_uf]+vy,EID_Exp2);
                     end;
            end;
      end
      else
      case uid of
    UID_LostSoul   : PlaySND(,pu);

    UID_Demon      : PlaySND(,pu);
    UID_Cacodemon  : PlaySND(,pu);
    UID_Knight     : if(buff[ub_advanced]=0)
                     then PlaySND(,pu)
                     else PlaySND(,pu);

}

