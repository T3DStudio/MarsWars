
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
      if(fog_cw>0)then
      begin
         fsr:=srange div fog_cw;
         if(fsr>MFogM)then fsr:=MFogM;
      end;
   end;
end;


procedure ObjTblCL;
var u,i,r:byte;

procedure setMWSM(mwsm,mwsma:PTMWSModel);
begin
   with _uids[u] do
   begin
      un_smodel[false]:= mwsm;
      if(mwsm=nil)
      then un_smodel[true ]:= mwsm
      else un_smodel[true ]:= mwsma;
   end;
end;

procedure setSND(adv:boolean;ready,move,attack,annoy,select:PTSoundSet); // command sounds
var b:boolean;
begin
   with _uids[u] do
   for b:=false to true do
   begin
      if(adv)and(b=false)then continue;
      un_snd_ready [b]:=ready;
      un_snd_move  [b]:=move;
      un_snd_attack[b]:=attack;
      un_snd_annoy [b]:=annoy;
      un_snd_select[b]:=select;
   end;
end;

procedure setBuildingSND(s:PTSoundSet);begin setSND(false,s,s,s,s,s);end;

procedure setEID (adv:boolean;ready,death,fdeath,pain:byte);
var b:boolean;
begin
   with _uids[u] do
   for b:=false to true do
   begin
      if(adv)and(b=false)then continue;
      un_eid_ready [b]:=ready;
      un_eid_death [b]:=death;
      un_eid_fdeath[b]:=fdeath;
      un_eid_pain  [b]:=pain;
   end;
end;
procedure setEIDS(adv:boolean;ready,death,fdeath,pain:PTSoundSet);
var b:boolean;
begin
   with _uids[u] do
   for b:=false to true do
   begin
      if(adv)and(b=false)then continue;
      un_eid_snd_ready [b]:=ready;
      un_eid_snd_death [b]:=death;
      un_eid_snd_fdeath[b]:=fdeath;
      un_eid_snd_pain  [b]:=pain;
   end;
end;

procedure setFOOT(adv:boolean;footsnd:PTSoundSet;footanim:integer);
var b:boolean;
begin
   with _uids[u] do
   for b:=false to true do
   begin
      if(adv)and(b=false)then continue;

      un_eid_snd_foot[b]:=footsnd;
      un_foot_anim   [b]:=footanim;
   end;
end;

begin
   FillChar(ui_panel_uids,SizeOf(ui_panel_uids),0);


   for u:=0 to 255 do
   with _uids[u] do
   begin
      setMWSM(@spr_dmodel,nil);
      _animw:=10;
      _animd:=10;

      case u of
UID_LostSoul:
begin
   setMWSM(@spr_lostsoul,nil);
   setSND (false,snd_lost_move,snd_hell_move,snd_lost_move,snd_hell_pain,snd_hell_move);
   setEID (false,EID_Teleport,0        ,u       ,0            );
   setEIDS(false,SND_Teleport,snd_pexp ,snd_pexp,snd_hell_pain);
end;
UID_Imp:
begin
   _animw:=12;
   _animd:=8;
   setMWSM(@spr_imp,nil);
   setSND (false,snd_imp_ready,snd_imp_move,snd_imp_ready,snd_zimba_pain,snd_imp_move);
   setEID (false,EID_Teleport,0            ,EID_Gavno,0             );
   setEIDS(false,SND_Teleport,snd_imp_death,snd_meat ,snd_zimba_pain);

end;
UID_Demon:
begin
   _animw:=15;
   _animd:=9;
   setMWSM(@spr_demon,nil);
   setSND (false,snd_demon_ready,snd_hell_move,snd_demon_ready,snd_hell_pain,snd_hell_move);
   setEID (false,EID_Teleport,0              ,0  ,0             );
   setEIDS(false,SND_Teleport,snd_demon_death,nil,snd_hell_pain );
end;
UID_Cacodemon:
begin
   _animd:=10;
   setMWSM(@spr_cacodemon,nil);
   setSND (false,snd_caco_ready,snd_hell_move,snd_caco_ready,snd_hell_pain,snd_hell_move);
   setEID (false,EID_Teleport,0              ,0  ,0             );
   setEIDS(false,SND_Teleport,snd_caco_death ,nil,snd_hell_pain );
end;
UID_Baron:
begin
   _animw:=12;
   _animd:=10;
   setMWSM(@spr_knight,@spr_baron);
   setSND (false,snd_knight_ready,snd_hell_move,snd_knight_ready,snd_hell_pain,snd_hell_move);
   setSND (true ,snd_baron_ready ,snd_hell_move,snd_baron_ready ,snd_hell_pain,snd_hell_move);

   setEID (false,EID_Teleport,0                ,0  ,0             );
   setEIDS(false,SND_Teleport,snd_knight_death ,nil,snd_hell_pain );
   setEIDS(true ,SND_Teleport,snd_baron_death  ,nil,snd_hell_pain );
end;
UID_Cyberdemon:
begin
   _animw:=11;
   setMWSM(@spr_cyberdemon,nil);
   setSND (false,snd_cyber_ready,snd_hell_move,snd_cyber_ready,snd_hell_pain,snd_hell_move);
   setEID (false,EID_Teleport,0              ,0  ,0             );
   setEIDS(false,SND_Teleport,snd_cyber_death,nil,snd_hell_pain );
   setFOOT(false,snd_cyber_foot,30);
end;
UID_Mastermind:
begin
   _animw:=11;
   _animd:=16;
   setMWSM(@spr_mastermind,nil);
   setSND (false,snd_mastermind_ready,snd_hell_move,snd_mastermind_ready,snd_hell_pain,snd_hell_move);
   setEID (false,EID_Teleport,0                   ,0  ,0             );
   setEIDS(false,SND_Teleport,snd_mastermind_death,nil,snd_hell_pain );
   setFOOT(false,snd_mastermind_foot,22);
end;
UID_Pain:
begin
   _animw:=7;
   setMWSM(@spr_pain,nil);
   setSND (false,snd_pain_ready,snd_hell_move,snd_hell_move,snd_pain_pain,snd_hell_move);
   setEID (false,EID_Teleport,0             ,u             ,0             );
   setEIDS(false,SND_Teleport,snd_pain_death,snd_pain_death,snd_pain_pain );
end;
UID_Revenant:
begin
   _animw:=16;
   _animd:=9;
   setMWSM(@spr_revenant,nil);
   setSND (false,snd_revenant_ready,snd_revenant_move,snd_revenant_ready,snd_zimba_pain,snd_revenant_move);
   setEID (false,EID_Teleport,0                 ,0  ,0             );
   setEIDS(false,SND_Teleport,snd_revenant_death,nil,snd_hell_pain );
end;
UID_Mancubus:
begin
   _animw:=10;
   _animd:=13;
   setMWSM(@spr_mancubus,nil);
   setSND (false,snd_mancubus_ready,snd_zimba_move,snd_mancubus_ready,snd_mancubus_pain,snd_zimba_move);
   setEID (false,EID_Teleport,0              ,0  ,0             );
   setEIDS(false,SND_Teleport,snd_mancubus_death ,nil,snd_mancubus_pain );
end;
UID_Arachnotron:
begin
   _animw:=11;
   _animd:=13;
   setMWSM(@spr_arachnotron,nil);
   setSND (false,snd_arachno_ready,snd_arachno_move,snd_arachno_ready,snd_arachno_move,snd_arachno_move);
   setEID (false,EID_Teleport,0              ,0  ,0             );
   setEIDS(false,SND_Teleport,snd_arachno_death,nil,snd_hell_pain );
   setFOOT(false,snd_arachno_foot,28);
end;
UID_Archvile:
begin
   _animw:=15;
   _animd:=12;
   setMWSM(@spr_archvile,nil);
   setSND (false,snd_archvile_ready,snd_archvile_move,snd_archvile_ready,snd_archvile_pain,snd_archvile_move);
   setEID (false,EID_Teleport,0                   ,0  ,0             );
   setEIDS(false,SND_Teleport,snd_archvile_death  ,nil,snd_archvile_pain );
end;
UID_ZFormer:
begin
   _animw:=14;
   _animd:=8;
   setMWSM(@spr_ZFormer,nil);
end;
UID_ZEngineer:
begin
   _animw:=14;
   _animd:=8;
   setMWSM(@spr_ZEngineer,nil);
   setEID (false,0  ,EID_Exp,EID_Exp,0  );
   setEIDS(false,nil,snd_exp,snd_exp,nil);
end;
UID_ZSergant:
begin
   _animw:=18;
   _animd:=8;
   setMWSM(@spr_ZSergant,@spr_ZSSergant);
end;
UID_ZCommando:
begin
   _animw:=15;
   _animd:=8;
   setMWSM(@spr_ZCommando,nil);
end;
UID_ZBomber:
begin
   _animw:=14;
   _animd:=8;
   setMWSM(@spr_ZBomber,nil);
end;
UID_ZMajor:
begin
   _animw:=14;
   _animd:=8;
   setMWSM(@spr_ZMajor,@spr_ZFMajor);

   setEID (true ,0  ,EID_Exp,EID_Exp,0  );
   setEIDS(true ,nil,snd_exp,snd_exp,nil);
end;
UID_ZBFG:
begin
   _animw:=14;
   _animd:=8;
   setMWSM(@spr_ZBFG,nil);
end;


UID_HKeep:
begin
   setMWSM(@spr_HKeep,nil);
   setBuildingSND(snd_hell_hk);
end;
UID_HGate:
begin
   setMWSM(@spr_HGate,@spr_HAGate);
   setBuildingSND(snd_hell_hgate);
end;
UID_HSymbol:
begin
   setMWSM(@spr_HSymbol,nil);
   setBuildingSND(snd_hell_hsymbol);
end;
UID_HPools:
begin
   setMWSM(@spr_HPools,@spr_HAPools);
   setBuildingSND(snd_hell_hpool);
end;
UID_HTower:
begin
   _animw:=5;

   setMWSM(@spr_HTower,nil);
   setBuildingSND(snd_hell_htower);
   un_eid_bcrater_y:=15;
end;
UID_HTeleport:
begin
   _animw:=5;

   setMWSM(@spr_HTeleport,nil);
   setBuildingSND(snd_hell_hteleport);
end;
UID_HMonastery:
begin
   setMWSM(@spr_HMonastery,nil);
   setBuildingSND(snd_hell_hmon);
   un_build_amode:=2;
end;
UID_HTotem:
begin
   setMWSM(@spr_HTotem,nil);
   setBuildingSND(snd_hell_htotem);
   un_build_amode:=2;
   un_eid_bcrater_y:=12;
end;
UID_HAltar:
begin
   setMWSM(@spr_HAltar,nil);
   setBuildingSND(snd_hell_haltar);
   un_build_amode:=2;
end;
UID_HFortress:
begin
   setMWSM(@spr_HFortress,nil);
   setBuildingSND(snd_hell_hfort);
   un_build_amode:=2;
end;
UID_HEye:
begin
   setMWSM(@spr_HEye,nil);
   setBuildingSND(snd_hell_hbuild);
   un_build_amode:=2;
end;
UID_HCommandCenter:
begin
   setMWSM(@spr_HCC,nil);
   setBuildingSND(snd_hell_hbuild);
end;
UID_HMilitaryUnit:
begin
   setMWSM(@spr_HMUnit,@spr_HMUnita);
   setBuildingSND(snd_hell_hbuild);
end;


UID_Engineer:
begin
   _animw:=18;
   _animd:=8;
   setMWSM(@spr_Engineer,nil);
   setSND (false,snd_engineer_ready,snd_engineer_move,snd_engineer_attack,snd_engineer_annoy,snd_engineer_select);
   setEID (false,0  ,0             ,EID_Gavno,0  );
   setEIDS(false,nil,snd_uac_hdeath,snd_meat ,nil);
end;
UID_Medic:
begin
   _animw:=18;
   _animd:=8;
   setMWSM(@spr_Medic,nil);
   setSND (false,snd_medic_ready,snd_medic_move,snd_medic_move,snd_medic_annoy,snd_medic_select);
   setEID (false,0  ,0             ,EID_Gavno,0  );
   setEIDS(false,nil,snd_uac_hdeath,snd_meat ,nil);
end;
UID_Sergant:
begin
   _animw:=18;
   _animd:=8;
   setMWSM(@spr_Sergant,@spr_SSergant);
   setSND (false,snd_shotgunner_ready,snd_shotgunner_move,snd_shotgunner_attack,snd_shotgunner_annoy,snd_shotgunner_select);
   setSND (true ,snd_ssg_ready       ,snd_ssg_move       ,snd_ssg_attack       ,snd_ssg_annoy       ,snd_ssg_select       );
   setEID (false,0  ,0             ,EID_Gavno,0  );
   setEIDS(false,nil,snd_uac_hdeath,snd_meat ,nil);
end;
UID_Commando:
begin
   _animw:=15;
   _animd:=8;
   setMWSM(@spr_Commando,nil);
   setSND (false,snd_commando_ready,snd_commando_move,snd_commando_attack,snd_commando_annoy,snd_commando_select);
   setEID (false,0  ,0             ,EID_Gavno,0  );
   setEIDS(false,nil,snd_uac_hdeath,snd_meat ,nil);
end;
UID_Bomber:
begin
   _animw:=14;
   _animd:=8;
   setMWSM(@spr_Bomber,nil);
   setSND (false,snd_rocketmarine_ready,snd_rocketmarine_move,snd_rocketmarine_attack,snd_rocketmarine_annoy,snd_rocketmarine_select);
   setEID (false,0  ,0             ,EID_Gavno,0  );
   setEIDS(false,nil,snd_uac_hdeath,snd_meat ,nil);
end;
UID_Major:
begin
   _animw:=14;
   _animd:=8;
   setMWSM(@spr_Major,@spr_FMajor);
   setSND (false,snd_plasmamarine_ready,snd_plasmamarine_move,snd_plasmamarine_attack,snd_plasmamarine_annoy,snd_plasmamarine_select);
   setEID (false,0  ,0             ,EID_Gavno,0  );
   setEIDS(false,nil,snd_uac_hdeath,snd_meat ,nil);

   setEID (true ,0  ,EID_Exp,EID_Exp,0  );
   setEIDS(true ,nil,snd_exp,snd_exp,nil);
end;
UID_BFG:
begin
   _animw:=14;
   _animd:=8;
   setMWSM(@spr_BFG,nil);
   setSND (false,snd_bfgmarine_ready,snd_bfgmarine_move,snd_bfgmarine_attack,snd_bfgmarine_annoy,snd_bfgmarine_select);
   setEID (false,0  ,0             ,EID_Gavno,0  );
   setEIDS(false,nil,snd_uac_hdeath,snd_meat ,nil);
end;
UID_FAPC:
begin
   setMWSM(@spr_FAPC,nil);
   setSND (false,snd_transport_ready,snd_transport_move,snd_transport_move,snd_transport_annoy,snd_transport_select);
   setEID (false,0  ,EID_BExp,EID_BExp,0  );
   setEIDS(false,nil,snd_exp ,snd_exp ,nil);
end;
UID_APC:
begin
   _animw:=17;
   setMWSM(@spr_APC,nil);
   setSND (false,snd_APC_ready,snd_APC_move,snd_APC_move,snd_APC_move,snd_APC_move);
   setEID (false,0  ,EID_BExp,EID_BExp,0  );
   setEIDS(false,nil,snd_exp ,snd_exp ,nil);
end;
UID_Terminator:
begin
   _animw:=18;
   setMWSM(@spr_Terminator,nil);
   setSND (false,snd_terminator_ready,snd_terminator_move,snd_terminator_attack,snd_terminator_annoy,snd_terminator_select);
   setEID (false,0  ,EID_Exp2,EID_Exp2,0  );
   setEIDS(false,nil,snd_exp ,snd_exp ,nil);
end;
UID_Tank:
begin
   _animw:=17;
   setMWSM(@spr_Tank,nil);
   setSND (false,snd_tank_ready,snd_tank_move,snd_tank_attack,snd_tank_annoy,snd_tank_select);
   setEID (false,0  ,EID_BExp,EID_BExp,0  );
   setEIDS(false,nil,snd_exp ,snd_exp ,nil);
end;
UID_Flyer:
begin
   setMWSM(@spr_Flyer,nil);
   setSND (false,snd_uacfighter_ready,snd_uacfighter_move,snd_uacfighter_attack,snd_uacfighter_annoy,snd_uacfighter_select);
   setEID (false,0  ,EID_Exp2,EID_Exp2,0  );
   setEIDS(false,nil,snd_exp ,snd_exp ,nil);
end;
UID_UTransport:
begin
   setMWSM(@spr_Transport,nil);
   setSND (false,snd_transport_ready,snd_transport_move,snd_transport_move,snd_transport_annoy,snd_transport_select);
   setEID (false,0  ,EID_BExp,EID_BExp,0  );
   setEIDS(false,nil,snd_exp ,snd_exp ,nil);
end;


UID_UCommandCenter:
begin
   setMWSM(@spr_UCommandCenter,nil);
   setBuildingSND(snd_uac_cc);
end;
UID_UMilitaryUnit:
begin
   setMWSM(@spr_UMilitaryUnit,@spr_UAMilitaryUnit);
   setBuildingSND(snd_uac_barracks);
end;
UID_UGenerator:
begin
   setMWSM(@spr_UGenerator,nil);
   setBuildingSND(snd_uac_generator);
end;
UID_UWeaponFactory:
begin
   setMWSM(@spr_UWeaponFactory,@spr_UAWeaponFactory);
   setBuildingSND(snd_uac_smith);
end;
UID_UTurret:
begin
   _animw    := 6;
   setMWSM(@spr_UTurret,nil);
   setBuildingSND(snd_uac_ctower);
   un_eid_bcrater_y:=1;
end;
UID_URadar:
begin
   setMWSM(@spr_URadar,nil);
   setBuildingSND(snd_uac_radar);
end;
UID_UVehicleFactory:
begin
   setMWSM(@spr_UVehicleFactory,nil);
   setBuildingSND(snd_uac_tech);
end;
UID_UPTurret:
begin
   _animw    := 4;

   setMWSM(@spr_UPTurret,nil);
   setBuildingSND(snd_uac_ctower);
   un_eid_bcrater_y:=1;
end;
UID_URocketL:
begin
   setMWSM(@spr_URocketL,nil);
   setBuildingSND(snd_uac_rls);
end;
UID_URTurret:
begin
   _animw    := 2;

   setMWSM(@spr_URTurret,nil);
   setBuildingSND(snd_uac_rtower);
   un_eid_bcrater_y:=1;
end;
UID_UNuclearPlant:
begin
   setMWSM(@spr_UNuclearPlant,nil);
   setBuildingSND(snd_uac_nucl);
end;
UID_UMine:
begin
   setMWSM(@spr_Mine,nil);
   setBuildingSND(snd_mine_place);
end;

      end;

      ui_panel_uids[_urace,byte(not _isbuilding),_ucl]:=u;

      if(_isbuilding)then
      begin
         case _urace of
       r_hell: begin
                  if(_r>42)
                  then un_eid_bcrater:=EID_db_h0
                  else un_eid_bcrater:=EID_db_h1;
                  if(un_build_amode=0)then un_build_amode:=1;
               end;
       r_uac : begin
                  if(_r<20)
                  then un_eid_bcrater:=u
                  else
                    if(_r>42)
                    then un_eid_bcrater:=EID_db_u0
                    else un_eid_bcrater:=EID_db_u1;
               end;
         end;
         if(_r>42)then
         begin
            setEID (false,0  ,EID_BBExp           ,EID_BBExp           ,0  );
            setEIDS(false,snd_constr_complete[_urace],snd_building_explode,snd_building_explode,nil);
            if(un_eid_bcrater_y=0)then un_eid_bcrater_y:=10;
         end
         else
         begin
            setEID (false,0  ,EID_BExp            ,EID_BExp            ,0  );
            setEIDS(false,nil,snd_building_explode,snd_building_explode,nil);
            if(un_eid_bcrater_y=0)then un_eid_bcrater_y:=5;
         end;
      end;

      _fr:=(_r div fog_cw)+1;
      if(_fr<1)then _fr:=1;
   end;

   for r:=1 to r_cnt do
   begin
      i:=0;
      for u:=0 to 255 do
      with _upids[u] do
      if(_up_race=r)then
      begin
         ui_panel_uids[r,2,i]:=u;
         inc(i,1);
         if(i>ui_ubtns)then break;
      end;
   end;

   for u:=0 to 255 do
   with _upids[u] do
   begin
      _up_btn:=spr_dummy;

      case u of

upgr_hell_teleport: begin _up_btn:=spr_b_up[r_hell,8 ]; end;
upgr_hell_b478tel : begin _up_btn:=spr_b_up[r_hell,21]; end;

upgr_uac_radar_r  : begin _up_btn:=spr_b_up[r_uac ,8 ]; end;
upgr_uac_rstrike  : begin _up_btn:=spr_b_up[r_uac ,16]; end;

      end;

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
         _canmove:=(x<>uo_x)or(y<>uo_y);
         exit;
      end;

      if(speed=0)or(buff[ub_stopafa]>0)then exit;

      if(_ismech)then
      begin
         if(_isbuilding)then
         begin
            if(buff[ub_clcast]>0)then exit;
         end
         else
         begin
            if(buff[ub_gear ]>0)
            or(buff[ub_toxin]>0) then exit;
         end;
      end
      else
      begin
         if(buff[ub_pain ]>0)
         or(buff[ub_toxin]>0)
         or(buff[ub_gear ]>0)then exit;
      end;

      _canmove:=true;
   end;
end;

function _canattack(pu:PTUnit):boolean;
begin
   _canattack:=false;
   with pu^ do
   if(bld)then
   with uid^ do
   case _attack of
    atm_none    : exit;
    atm_bunker,
    atm_always  : if(_IsUnitRange(inapc))then
                  begin
                     if(_units[inapc].inapc>0)then exit;
                     case _units[inapc].uid^._attack of
                     atm_none,
                     atm_sturret: exit;
                     end;
                  end;
    atm_sturret : if(apcc =0)then exit;
    atm_inapc   : if(inapc=0)then exit;
   else exit;
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
         arange:= _arange;
         speed := _speed;
         uf    := _uf;
         apcm  := _apcm;
         solid := _issolid;

         if(_isbuilding)and(_isbarrack)then inc(uo_y,_r+12);

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

{
atm_none             = 0;
atm_always           = 1;
atm_bunker           = 2;
atm_sturret          = 3;
atm_inapc            = 4;
}

procedure initUIDS;
var i:byte;
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
      _srange    := 260;
      _arange    := -1;

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
   _renerg    := 8;
   _generg    := 6;
   _r         := 66;
   _srange    := base_rA[0];
   _ucl       := 0;
   _btime     := 75;

   _isbuilding:= true;
   _isbuilder := true;

   ups_builder:= [UID_HKeep..UID_HFortress];
end;
UID_HGate:
begin
   _mhits     := 1500;
   _renerg    := 4;
   _r         := 60;
   _srange    := 200;
   _ucl       := 1;
   _btime     := 40;

   _isbuilding:= true;
   _isbarrack := true;

   ups_units  := [UID_LostSoul..UID_Archvile];
end;
UID_HSymbol:
begin
   _mhits     := 100;
   _renerg    := 1;
   _generg    := 1;
   _r         := 24;
   _srange    := 200;
   _ucl       := 2;
   _btime     := 8;

   _isbuilding:= true;
end;
UID_HPools:
begin
   _mhits     := 1000;
   _renerg    := 6;
   _r         := 53;
   _srange    := 200;
   _ucl       := 3;
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
   _ucl       := 4;
   _btime     := 20;
   _attack    := atm_always;
   _ability   := uad_htowertele;

   _isbuilding:= true;
end;
UID_HTeleport:
begin
   _mhits     := 400;
   _renerg    := 4;
   _r         := 28;
   _srange    := 200;
   _ucl       := 5;
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
   _ucl       := 6;
   _btime     := 90;
   _max       := 1;
   _ruid      := UID_HPools;

   _isbuilding:= true;
end;
UID_HTotem:
begin
   _mhits     := 700;
   _renerg    := 3;
   _r         := 21;
   _srange    := 250;
   _ucl       := 7;
   _btime     := 25;
   _ruid      := UID_HAltar;
   _attack    := atm_always;
   _ability   := uad_htowertele;
   //_rupgr     := upgr_2tier;

   _isbuilding:= true;
end;
UID_HAltar:
begin
   _mhits     := 500;
   _renerg    := 4;
   _r         := 50;
   _srange    := 200;
   _ucl       := 8;
   _btime     := 30;
   _max       := 1;
   _ruid      := UID_HMonastery;
   //_rupgr     := upgr_2tier;

   _isbuilding:= true;
end;
UID_HFortress:
begin
   _mhits     := 4000;
   _renerg    := 10;
   _generg    := 4;
   _r         := 86;
   _srange    := 300;
   _ucl       := 9;
   _btime     := 90;
   _max       := 1;
   _ruid      := UID_HPools;

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
   _mhits     := 3000;
   _renerg    := 8;
   _generg    := 6;
   _speed     := 6;
   _r         := 66;
   _srange    := base_rA[0];
   _ucl       := 12;
   _btime     := 90;

   _isbuilding:= true;

   ups_builder:=[UID_HCommandCenter,UID_HSymbol,UID_HTower,UID_HMilitaryUnit];
   ups_apc    :=demons;
end;
UID_HMilitaryUnit:
begin
   _mhits     := 1500;
   _renerg    := 4;
   _r         := 66;
   _srange    := base_rA[0];
   _ucl       := 13;
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
   _fastdeath[false]:=true;
   _fastdeath[true ]:=true;
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
end;
UID_Mastermind :
begin
   _mhits     := 2000;
   _renerg    := 10;
   _max       := 1;
   _r         := 35;
   _speed     := 11;
   _srange    := 250;
   _ucl       := 6;
   _painc     := 15;
   _btime     := 90;
   _apcs      := 10;
   _ruid      := UID_HMonastery;
   _attack    := atm_always;
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
   _fastdeath[false]:=true;
   _fastdeath[true ]:=true;
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
end;
UID_Mancubus   :
begin
   _mhits     := 400;
   _renerg    := 6;
   _r         := 20;
   _speed     := 6;
   _srange    := 250;
   _ucl       := 9;
   _painc     := 4;
   _btime     := 60;
   _ruid      := UID_HMonastery;
   _attack    := atm_always;
   //_rupgr     := upgr_2tier;
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
   //_rupgr     := upgr_2tier;
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
end;
UID_ZEngineer:
begin
   _mhits     := 100;
   _renerg    := 2;
   _r         := 12;
   _speed     := 14;
   _srange    := 200;
   _ucl       := 13;
   _painc     := 4;
   _btime     := 20;
   _attack    := atm_always;
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
end;
UID_ZBomber:
begin
   _mhits     := 100;
   _renerg    := 4;
   _r         := 12;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 16;
   _painc     := 4;
   _btime     := 30;
   _attack    := atm_always;
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
end;


//         UAC BUILDINGS   /////////////////////////////////////////////////////
UID_UCommandCenter:
begin
   _mhits     := 3500;
   _renerg    := 8;
   _generg    := 6;
   _r         := 66;
   _srange    := base_rA[0];
   _ucl       := 0;
   _btime     := 90;

   _zombieid  := UID_HCommandCenter;

   _attack    := atm_always;

   _isbuilding:= true;
   _isbuilder := true;
   _slowturn  := true;

   ups_builder:=[UID_UCommandCenter..UID_UNuclearPlant];
end;
UID_UMilitaryUnit:
begin
   _mhits     := 1750;
   _renerg    := 4;
   _r         := 66;
   _srange    := 200;
   _ucl       := 1;
   _btime     := 40;

   _zombieid  := UID_HMilitaryUnit;

   _isbuilding:=true;
   _isbarrack :=true;

   ups_units:=marines+[UID_APC,UID_FAPC,UID_Terminator,UID_Tank,UID_Flyer];
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
   _renerg    := 6;
   _r         := 62;
   _srange    := 200;
   _ucl       := 3;
   _btime     := 40;

   _isbuilding:=true;
   _issmith   :=true;

   ups_upgrades := [];
end;
UID_UTurret:
begin
   _mhits     := 400;
   _renerg    := 2;
   _r         := 17;
   _srange    := 250;
   _ucl       := 4;
   _btime     := 15;
   _attack    := atm_always;

   _isbuilding:=true;
end;
UID_URadar:
begin
   _mhits     := 400;
   _renerg    := 4;
   _r         := 35;
   _srange    := 200;
   _ucl       := 5;
   _btime     := 30;
   _max       := 1;
   _ability   := uab_radar;

   _isbuilding:=true;
end;
UID_UVehicleFactory :
begin
   _mhits     := 1750;
   _renerg    := 10;
   _r         := 62;
   _srange    := 200;
   _ucl       := 6;
   _btime     := 90;
   _max       := 1;
   _ruid      := UID_UWeaponFactory;

   _isbuilding:=true;
end;
UID_UPTurret:
begin
   _mhits     := 400;
   _renerg    := 2;
   _r         := 17;
   _srange    := 250;
   _ucl       := 7;
   _btime     := 20;
   _ruid      := UID_UVehicleFactory;
   _attack    := atm_always;

   _isbuilding:=true;
end;
UID_URocketL:
begin
   _mhits     := 500;
   _renerg    := 4;
   _r         := 40;
   _srange    := 200;
   _ucl       := 8;
   _btime     := 30;
   _max       := 1;
   _ruid      := UID_UVehicleFactory;
   //_rupgr     := upgr_2tier;
   _ability   := uad_uac_rstrike;

   _isbuilding:=true;
end;
UID_URTurret:
begin
   _mhits     := 400;
   _renerg    := 2;
   _r         := 17;
   _srange    := 250;
   _ucl       := 10;
   _btime     := 25;
   _ruid      := UID_UVehicleFactory;
   _attack    := atm_always;
   //_rupgr     := upgr_rturrets;

   _isbuilding:=true;
end;
UID_UNuclearPlant:
begin
   _mhits     := 2000;
   _renerg    := 10;
   _generg    := 15;
   _r         := 70;
   _srange    := 200;
   _ucl       := 9;
   _btime     := 90;
   _max       := 1;
   _ruid      := UID_UVehicleFactory;

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
   _zombieid  := UID_ZEngineer;
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
   _zombieid  := UID_ZFormer;
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
   _zombieid  := UID_ZSergant;
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
   _zombieid  := UID_ZCommando;
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
   _zombieid  := UID_ZBomber;
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
   _zombieid  := UID_ZMajor;
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
   _zombieid  := UID_ZBFG;
end;
UID_FAPC:
begin
   _mhits     := 250;
   _renerg    := 3;
   _r         := 33;
   _speed     := 22;
   _srange    := 250;
   _ucl       := 7;
   _btime     := 25;
   _apcm      := 10;
   _apcs      := 8;
   _ruid      := UID_UWeaponFactory;
   _uf        := uf_fly;
   _attack    := atm_always;

   _ismech    := true;
   _slowturn  := true;

   ups_apc    :=marines+[UID_APC,UID_Terminator,UID_Tank,UID_Flyer];
end;
UID_APC:
begin
   _mhits     := 350;
   _renerg    := 3;
   _r         := 25;
   _speed     := 15;
   _srange    := 250;
   _ucl       := 8;
   _btime     := 25;
   _apcm      := 10;
   _apcs      := 10;
   _ruid      := UID_UWeaponFactory;
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
   _ruid      := UID_UVehicleFactory;
   _attack    := atm_always;
   //_rupgr     := upgr_2tier;

   _ismech    := true;
end;
UID_Tank:
begin
   _mhits     := 400;
   _renerg    := 8;
   _r         := 20;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 10;
   _btime     := 60;
   _apcs      := 7;
   _ruid      := UID_UVehicleFactory;
   _attack    := atm_always;
   //_rupgr     := upgr_2tier;

   _ismech    := true;
end;
UID_Flyer:
begin
   _mhits     := 350;
   _renerg    := 8;
   _r         := 18;
   _speed     := 19;
   _srange    := 275;
   _ucl       := 11;
   _btime     := 60;
   _apcs      := 7;
   _uf        := uf_fly;
   _ruid      := UID_UVehicleFactory;
   _attack    := atm_always;
   //_rupgr     := upgr_2tier;

   _ismech    := true;
end;
UID_UTransport:
begin
   _mhits     := 400;
   _renerg    := 5;
   _r         := 36;
   _speed     := 10;
   _srange    := 250;
   _ucl       := 12;
   _btime     := 60;
   _apcm      := 30;
   _apcs      := 10;
   _ruid      := UID_UVehicleFactory;
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

      _ismech:=_ismech or _isbuilding;

      _shcf:=_mhits/_mms;

      if(_arange<0)then _arange:=_srange;

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

   //         race  id               time lvl enr rupgr     ruid

   _setUPGR(r_hell,upgr_hell_teleport,120,2   ,2  ,0         ,0                  ,false,false);
   _setUPGR(r_hell,upgr_hell_b478tel ,30 ,15  ,2  ,0         ,UID_HAltar         ,true ,true );

   _setUPGR(r_uac ,upgr_uac_radar_r  ,120, 3  ,4  ,0         ,0                  ,false,false);
   _setUPGR(r_uac ,upgr_uac_rstrike  ,120, 6  ,10 ,0         ,UID_UVehicleFactory,true ,true );



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
   _setUPGR(r_uac ,upgr_6bld      ,180,1 ,8 ,255       ,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_2tier     ,180,1 ,10,255       ,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_blizz     ,180,8 ,10,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_mechspd   ,120,2 ,3 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_mecharm   ,180,4 ,4 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_6bld2     ,120,1 ,2 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_mainonr   ,60 ,1 ,2 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_turarm    ,120,2 ,3 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_rturrets  ,180,1 ,4 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_bldenrg   ,180,3 ,4 ,upgr_2tier,UID_UNuclearPlant  );
   _setUPGR(r_uac ,upgr_9bld      ,180,1 ,4 ,upgr_2tier,UID_UNuclearPlant  );  }

   FillChar(_uids   ,SizeOf(_uids   ),0);

   initUIDS;
end;


