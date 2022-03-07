



///////////////////////////////////////////////////////////////
procedure InitUIDDataCL;
var u,i,r,w,
  DefaultRLDA_pa:byte;
un_eid_snd_set:boolean;

//local funcs
procedure setMWSModel(mwsm,mwsma:PTMWSModel);
begin
   with _uids[u] do
   begin
      un_smodel[false]:= mwsm;
      if(mwsma=nil)
      then un_smodel[true ]:= mwsm
      else un_smodel[true ]:= mwsma;
   end;
end;

procedure setCommandSND(adv:boolean;ready,move,attack,annoy,select:PTSoundSet); // command sounds
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

procedure _CalcDefaultRLDA(a,s:PTSoB;pa:byte);
var i,x:byte;
procedure setline(a0,a1:byte);
begin
   while(a0<>a1)do
   begin
      a^:=a^+[a1];
      if(a0<a1)
      then a1-=1
      else a1+=1;
   end;
end;
begin
   i :=255;
   x :=255;

   for i:=255 downto 0 do
    if(i in s^)or(i=0)then
    begin
       if(x<255)then setline(x-((x-i) div pa),x);
       x:=i;
    end;
end;

procedure _SetRLDA(aa:byte;rld:TSoB);
begin
   with _uids[u] do
   for aa:=aa to MaxUnitWeapons do
   with _a_weap[aa] do
   begin
      aw_rld_a:=rld;
   end;
end;

procedure setBuildingSND(s:PTSoundSet);
begin setCommandSND(false,nil,s,s,s,s);end;

procedure setEffectEID (adv:boolean;ready,death,fdeath,pain:byte);
var b:boolean;
begin
   with _uids[u] do
   for b:=false to true do
   begin
      if(adv)and(b=false)then continue;
      un_eid_summon[b]:=ready;
      un_eid_death [b]:=death;
      un_eid_fdeath[b]:=fdeath;
      un_eid_pain  [b]:=pain;
   end;
end;
procedure setEffectSND(adv:boolean;ready,death,fdeath,pain:PTSoundSet);
var b:boolean;
begin
   with _uids[u] do
   for b:=false to true do
   begin
      if(adv)and(b=false)then continue;
      un_eid_snd_summon[b]:=ready;
      un_eid_snd_death [b]:=death;
      un_eid_snd_fdeath[b]:=fdeath;
      un_eid_snd_pain  [b]:=pain;
   end;
   un_eid_snd_set:=true;
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

procedure setWeaponESND(aa:byte;snd_start,snd_shot:PTSoundSet;eid_start,eid_shot:byte);
begin
   with _uids[u] do
   for aa:=aa to MaxUnitWeapons do
   with _a_weap[aa] do
   begin
      aw_snd_start:=snd_start;
      aw_snd_shot :=snd_shot;
      aw_eid_start:=eid_start;
      aw_eid_shot :=eid_shot;
   end;
end;
procedure setWeaponTEID(aa:byte;snd_target:PTSoundSet;eid_target:byte;rld_a:TSoB);
begin
   with _uids[u] do
   for aa:=aa to MaxUnitWeapons do
   with _a_weap[aa] do
   begin
      aw_snd_target:=snd_target;
      aw_eid_target:=eid_target;
      if(rld_a<>[])then aw_rld_a:=rld_a;
   end;
end;
procedure setWeaponESND2(aaset:TSoB;snd_start,snd_shot:PTSoundSet;eid_start,eid_shot:byte);
var aa:byte;
begin
   with _uids[u] do
   for aa:=0 to MaxUnitWeapons do
   if(aa in aaset)then
   with _a_weap[aa] do
   begin
      aw_snd_start:=snd_start;
      aw_snd_shot :=snd_shot;
      aw_eid_start:=eid_start;
      aw_eid_shot :=eid_shot;
   end;
end;
procedure setWeaponTEID2(aaset:TSoB;snd_target:PTSoundSet;eid_target:byte;rld_a:TSoB);
var aa:byte;
begin
   with _uids[u] do
   for aa:=0 to MaxUnitWeapons do
   if(aa in aaset)then
   with _a_weap[aa] do
   begin
      aw_snd_target:=snd_target;
      aw_eid_target:=eid_target;
      if(rld_a<>[])then aw_rld_a:=rld_a;
   end;
end;

begin
   FillChar(ui_panel_uids,SizeOf(ui_panel_uids),0);

   for u:=0 to 255 do
   with _uids[u] do
   begin
      un_eid_snd_set:=false;
      setMWSModel(@spr_dmodel,nil);
      _animw:=10;
      _animd:=10;

      DefaultRLDA_pa:=3;

      case u of
UID_LostSoul:
begin
   setMWSModel  (@spr_lostsoul,nil);
   setCommandSND(false,snd_lost_move,snd_hell_move,snd_lost_move,snd_hell_pain,snd_hell_move);
   setEffectEID (false,0  ,0        ,u       ,0            );
   setEffectSND (false,nil,snd_pexp ,snd_pexp,snd_hell_pain);
   setWeaponESND(0,nil,snd_lost_move,0,0);
end;
UID_Imp:
begin
   _animw:=12;
   _animd:=8;
   setMWSModel  (@spr_imp,nil);
   setCommandSND(false,snd_imp_ready,snd_imp_move,snd_imp_ready,snd_zimba_pain,snd_imp_move);
   setEffectEID (false,0  ,0            ,EID_Gavno,0             );
   setEffectSND (false,nil,snd_imp_death,snd_meat ,snd_zimba_pain);
   setWeaponESND(0,nil,snd_hell_attack,0,0);
   setWeaponESND(2,nil,snd_hell_melee ,0,0);
end;
UID_Demon:
begin
   _animw:=15;
   _animd:=9;
   setMWSModel  (@spr_demon,nil);
   setCommandSND(false,snd_demon_ready,snd_hell_move,snd_demon_ready,snd_hell_pain,snd_hell_move);
   setEffectEID (false,0  ,0              ,0  ,0             );
   setEffectSND (false,nil,snd_demon_death,nil,snd_hell_pain );
   setWeaponESND(0,nil,snd_demon_melee,0,0);
end;
UID_Cacodemon:
begin
   _animd:=10;
   setMWSModel  (@spr_cacodemon,nil);
   setCommandSND(false,snd_caco_ready,snd_hell_move,snd_caco_ready,snd_hell_pain,snd_hell_move);
   setEffectEID (false,0  ,0              ,0  ,0             );
   setEffectSND (false,nil,snd_caco_death ,nil,snd_hell_pain );
   setWeaponESND(0,nil,snd_hell_attack,0,0);
   setWeaponESND(2,nil,snd_hell_melee ,0,0);
end;
UID_Knight:
begin
   _animw:=12;
   _animd:=10;
   setMWSModel(@spr_knight,@spr_baron);
   setCommandSND(false,snd_knight_ready,snd_hell_move,snd_knight_ready,snd_hell_pain,snd_hell_move);
   setCommandSND(true ,snd_baron_ready ,snd_hell_move,snd_baron_ready ,snd_hell_pain,snd_hell_move);
   setEffectEID (false,0  ,0                ,0  ,0             );
   setEffectSND (false,nil,snd_knight_death ,nil,snd_hell_pain );
   setEffectSND (true ,nil,snd_baron_death  ,nil,snd_hell_pain );
   setWeaponESND(0,nil,snd_hell_attack,0,0);
   setWeaponESND(1,nil,snd_hell_melee ,0,0);
end;
UID_Cyberdemon:
begin
   _animw:=11;
   setMWSModel  (@spr_cyberdemon,nil);
   setCommandSND(false,snd_cyber_ready,snd_hell_move,snd_cyber_ready,snd_hell_pain,snd_hell_move);
   setEffectEID (false,0  ,0              ,0  ,0             );
   setEffectSND (false,nil,snd_cyber_death,nil,snd_hell_pain );
   setFOOT      (false,snd_cyber_foot,30);
   setWeaponESND(0,nil,snd_launch,0,0);
end;
UID_Mastermind:
begin
   _animw:=11;
   _animd:=16;
   setMWSModel  (@spr_mastermind,nil);
   setCommandSND(false,snd_mastermind_ready,snd_hell_move,snd_mastermind_ready,snd_hell_pain,snd_hell_move);
   setEffectEID (false,0  ,0                   ,0  ,0             );
   setEffectSND (false,nil,snd_mastermind_death,nil,snd_hell_pain );
   setFOOT      (false,snd_mastermind_foot,22);
   setWeaponESND(0,nil,snd_shotgun,0,0);
end;
UID_Pain:
begin
   _animw:=7;
   setMWSModel  (@spr_pain,nil);
   setCommandSND(false,snd_pain_ready,snd_hell_move,snd_hell_move,snd_pain_pain,snd_hell_move);
   setEffectEID (false,0  ,0             ,u             ,0             );
   setEffectSND (false,nil,snd_pain_death,snd_pain_death,snd_pain_pain );
end;
UID_Revenant:
begin
   _animw:=16;
   _animd:=9;
   setMWSModel  (@spr_revenant,nil);
   setCommandSND(false,snd_revenant_ready,snd_revenant_move,snd_revenant_ready,snd_zimba_pain,snd_revenant_move);
   setEffectEID (false,0  ,0                 ,0  ,0             );
   setEffectSND (false,nil,snd_revenant_death,nil,snd_zimba_pain);
   setWeaponESND(0,nil,snd_revenant_attack,0,0);
   setWeaponESND(2,nil,snd_revenant_melee ,0,0);
end;
UID_Mancubus:
begin
   _animw:=10;
   _animd:=13;
   setMWSModel  (@spr_mancubus,nil);
   setCommandSND(false,snd_mancubus_ready,snd_zimba_move,snd_mancubus_ready,snd_mancubus_pain,snd_zimba_move);
   setEffectEID (false,0  ,0              ,0  ,0             );
   setEffectSND (false,nil,snd_mancubus_death ,nil,snd_mancubus_pain );
   setWeaponESND(0,snd_mancubus_attack,snd_hell_attack,0,0);
end;
UID_Arachnotron:
begin
   _animw:=11;
   _animd:=13;
   setMWSModel  (@spr_arachnotron,nil);
   setCommandSND(false,snd_arachno_ready,snd_arachno_move,snd_arachno_ready,snd_hell_pain,snd_arachno_move);
   setEffectEID (false,0  ,0              ,0  ,0             );
   setEffectSND (false,nil,snd_arachno_death,nil,snd_hell_pain );
   setFOOT      (false,snd_arachno_foot,26);
   setWeaponESND(0,nil,snd_plasma,0,0);
end;
UID_Archvile:
begin
   _animw:=15;
   _animd:=12;
   setMWSModel  (@spr_archvile,nil);
   setCommandSND(false,snd_archvile_ready,snd_archvile_move,snd_archvile_ready,snd_archvile_pain,snd_archvile_move);
   setEffectEID (false,0  ,0                   ,0  ,0                 );
   setEffectSND (false,nil,snd_archvile_death  ,nil,snd_archvile_pain );
   setWeaponESND(0,nil,snd_meat,0,0);
   setWeaponTEID(0,nil,0       ,[0..255]);
   setWeaponESND(1,snd_archvile_attack,nil,0,0);
   setWeaponTEID(1,snd_archvile_fire  ,EID_ArchFire,[0..65]);
end;

UID_ZFormer:
begin
   _animw:=14;
   _animd:=8;
   setCommandSND(false,snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setMWSModel  (@spr_ZFormer,nil);
   setEffectEID (false,0  ,0              ,EID_Gavno,0             );
   setEffectSND (false,nil,snd_zimba_death,snd_meat ,snd_zimba_pain);
   setWeaponESND(0,nil,snd_pistol,0,0);
end;
UID_ZEngineer:
begin
   _animw:=15;
   _animd:=8;
   setCommandSND(false,snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setMWSModel  (@spr_ZEngineer,nil);
   setEffectEID (false,0  ,EID_Exp,EID_Exp,0  );
   setEffectSND (false,nil,snd_exp,snd_exp,nil);
end;
UID_ZSergant:
begin
   _animw:=18;
   _animd:=8;
   setCommandSND(false,snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (false,0  ,0              ,EID_Gavno,0             );
   setEffectSND (false,nil,snd_zimba_death,snd_meat ,snd_zimba_pain);
   setMWSModel  (@spr_ZSergant,@spr_ZSSergant);
   setWeaponESND(0,nil,snd_ssg    ,0,0);
   setWeaponESND(1,nil,snd_shotgun,0,0);
end;
UID_ZCommando:
begin
   _animw:=15;
   _animd:=8;
   setCommandSND(false,snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (false,0  ,0              ,EID_Gavno,0             );
   setEffectSND (false,nil,snd_zimba_death,snd_meat ,snd_zimba_pain);
   setMWSModel  (@spr_ZCommando,nil);
   setWeaponESND(0,nil,snd_shotgun,0,0);
end;
UID_ZBomber:
begin
   _animw:=14;
   _animd:=8;
   setCommandSND(false,snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (false,0  ,0              ,EID_Gavno,0             );
   setEffectSND (false,nil,snd_zimba_death,snd_meat ,snd_zimba_pain);
   setMWSModel  (@spr_ZBomber,nil);
   setWeaponESND(0,nil,snd_launch,0,0);
end;
UID_ZMajor:
begin
   _animw:=14;
   _animd:=8;
   setMWSModel(@spr_ZMajor,@spr_ZFMajor);
   setCommandSND(false,snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (false,0  ,0              ,EID_Gavno,0             );
   setEffectSND (false,nil,snd_zimba_death,snd_meat ,snd_zimba_pain);
   setEffectEID (true ,0  ,EID_Exp,EID_Exp,0  );
   setEffectSND (true ,nil,snd_exp,snd_exp,nil);
   setWeaponESND(0    ,nil,snd_plasma,0,0);
   setWeaponTEID(0    ,nil,0,[0..255]);
end;
UID_ZBFG:
begin
   _animw:=14;
   _animd:=8;
   setCommandSND(false,snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (false,0  ,0              ,EID_Gavno,0             );
   setEffectSND (false,nil,snd_zimba_death,snd_meat ,snd_zimba_pain);
   setMWSModel  (@spr_ZBFG,nil);
   setWeaponESND(0,snd_bfg_shot,nil,0,0);
   setWeaponTEID(0,nil,0,[fr_fps-10..255]);
end;


UID_HKeep:
begin
   setMWSModel(@spr_HKeep,nil);
   setBuildingSND(snd_hell_hk);
end;
UID_HGate:
begin
   setMWSModel(@spr_HGate,@spr_HAGate);
   setBuildingSND(snd_hell_hgate);
end;
UID_HSymbol:
begin
   setMWSModel(@spr_HSymbol,nil);
   setBuildingSND(snd_hell_hsymbol);
end;
UID_HASymbol:
begin
   setMWSModel(@spr_HASymbol,nil);
   setBuildingSND(snd_hell_hsymbol);
end;
UID_HPools:
begin
   setMWSModel(@spr_HPools,@spr_HAPools);
   setBuildingSND(snd_hell_hpool);
end;
UID_HTower:
begin
   _animw:=5;

   setMWSModel(@spr_HTower,nil);
   setBuildingSND(snd_hell_htower);
   setWeaponESND(0,nil,snd_revenant_attack,0,MID_Imp);
   setWeaponESND(1,nil,snd_hell_attack    ,0,MID_Imp);
   un_eid_bcrater_y:=15;
end;
UID_HTeleport:
begin
   _animw:=5;

   setMWSModel(@spr_HTeleport,nil);
   setBuildingSND(snd_hell_hteleport);
end;
UID_HMonastery:
begin
   setMWSModel(@spr_HMonastery,nil);
   setBuildingSND(snd_hell_hmon);
   un_build_amode:=2;
end;
UID_HTotem:
begin
   setMWSModel(@spr_HTotem,nil);
   setBuildingSND(snd_hell_htotem);
   un_build_amode:=2;
   un_eid_bcrater_y:=12;
   setWeaponESND(0,snd_archvile_attack,nil,0,0);
   setWeaponTEID(0,snd_archvile_fire  ,EID_ArchFire,[0..65]);
end;
UID_HAltar:
begin
   setMWSModel(@spr_HAltar,nil);
   setBuildingSND(snd_hell_haltar);
   un_build_amode:=2;
end;
UID_HFortress:
begin
   setMWSModel(@spr_HFortress,nil);
   setBuildingSND(snd_hell_hfort);
   un_build_amode:=2;
end;
UID_HEye:
begin
   setMWSModel(@spr_HEye,nil);
   setBuildingSND(snd_hell_eye);
   un_build_amode:=2;
   un_eid_bcrater:=255;
   un_snd_ready[false]:=snd_hell_eye;
   setEffectEID(false,0  ,UID_HEye ,UID_HEye,0  );
   setEffectEID(true ,0  ,EID_HAEye,EID_HAEye ,0  );
   setEffectSND(false,nil,snd_pexp,snd_pexp,nil);
end;
UID_HCommandCenter:
begin
   setMWSModel(@spr_HCC,nil);
   setBuildingSND(snd_hell_hbuild);
   setEffectEID(false,EID_HCC ,EID_BBExp           ,EID_BBExp           ,0  );
   setEffectSND(false,snd_hell,snd_building_explode,snd_building_explode,nil);
   un_eid_bcrater_y:=10;
   setWeaponESND(0    ,nil,snd_hell_attack,0,0);
end;
UID_HMilitaryUnit:
begin
   setMWSModel(@spr_HMUnit,@spr_HMUnita);
   setBuildingSND(snd_hell_hbuild);
   setEffectEID(false,EID_HMU ,EID_BBExp           ,EID_BBExp           ,0  );
   setEffectEID(true ,EID_HAMU,EID_BBExp           ,EID_BBExp           ,0  );
   setEffectSND(false,snd_hell,snd_building_explode,snd_building_explode,nil);
   un_eid_bcrater_y:=10;
end;


UID_Engineer:
begin
   _animw:=18;
   _animd:=8;
   setMWSModel(@spr_Engineer,nil);
   setCommandSND(false,snd_engineer_ready,snd_engineer_move,snd_engineer_attack,snd_engineer_annoy,snd_engineer_select);
   setEffectEID (false,0  ,0             ,EID_Gavno,0  );
   setEffectSND (false,nil,snd_uac_hdeath,snd_meat ,nil);
   setWeaponESND(0,nil,snd_electro,0,0);
   setWeaponESND(1,nil,snd_pistol ,0,0);
   with _a_weap[0] do begin aw_eid_target:=MID_BPlasma;aw_eid_target_onlyshot:=true;end;
end;
UID_Medic:
begin
   _animw:=18;
   _animd:=8;
   setMWSModel(@spr_Medic,nil);
   setCommandSND(false,snd_medic_ready,snd_medic_move,snd_medic_move,snd_medic_annoy,snd_medic_select);
   setEffectEID (false,0  ,0             ,EID_Gavno,0  );
   setEffectSND (false,nil,snd_uac_hdeath,snd_meat ,nil);
   setWeaponESND(0,nil,snd_healing,0,0);
   setWeaponESND(1,nil,snd_pistol,0,0);
   with _a_weap[0] do begin aw_eid_target:=MID_YPlasma;aw_eid_target_onlyshot:=true;end;
end;
UID_Sergant:
begin
   _animw:=18;
   _animd:=8;
   setMWSModel(@spr_Sergant,@spr_SSergant);
   setCommandSND(false,snd_shotgunner_ready,snd_shotgunner_move,snd_shotgunner_attack,snd_shotgunner_annoy,snd_shotgunner_select);
   setCommandSND(true ,snd_ssg_ready       ,snd_ssg_move       ,snd_ssg_attack       ,snd_ssg_annoy       ,snd_ssg_select       );
   setEffectEID (false,0  ,0             ,EID_Gavno,0  );
   setEffectSND (false,nil,snd_uac_hdeath,snd_meat ,nil);
   setWeaponESND(0,nil,snd_ssg    ,0,0);
   setWeaponESND(1,nil,snd_shotgun,0,0);
end;
UID_Commando:
begin
   _animw:=15;
   _animd:=8;
   setMWSModel(@spr_Commando,nil);
   setCommandSND(false,snd_commando_ready,snd_commando_move,snd_commando_attack,snd_commando_annoy,snd_commando_select);
   setEffectEID (false,0  ,0             ,EID_Gavno,0  );
   setEffectSND (false,nil,snd_uac_hdeath,snd_meat ,nil);
   setWeaponESND(0,nil,snd_pistol,0,0);
end;
UID_Bomber:
begin
   _animw:=14;
   _animd:=8;
   setMWSModel(@spr_Bomber,nil);
   setCommandSND(false,snd_rocketmarine_ready,snd_rocketmarine_move,snd_rocketmarine_attack,snd_rocketmarine_annoy,snd_rocketmarine_select);
   setEffectEID (false,0  ,0             ,EID_Gavno,0  );
   setEffectSND (false,nil,snd_uac_hdeath,snd_meat ,nil);
   setWeaponESND(0,nil,snd_launch,0,0);
end;
UID_Major:
begin
   _animw:=14;
   _animd:=8;
   setMWSModel(@spr_Major,@spr_FMajor);
   setCommandSND(false,snd_plasmamarine_ready,snd_plasmamarine_move,snd_plasmamarine_attack,snd_plasmamarine_annoy,snd_plasmamarine_select);
   setEffectEID (false,0  ,0             ,EID_Gavno,0  );
   setEffectSND (false,nil,snd_uac_hdeath,snd_meat ,nil);
   setEffectEID (true ,0  ,EID_Exp,EID_Exp,0  );
   setEffectSND (true ,nil,snd_exp,snd_exp,nil);
   setWeaponESND(0    ,nil,snd_plasma,0,0);
   setWeaponTEID(0    ,nil,0,[0..255]);
end;
UID_BFG:
begin
   _animw:=14;
   _animd:=8;
   setMWSModel(@spr_BFG,nil);
   setCommandSND(false,snd_bfgmarine_ready,snd_bfgmarine_move,snd_bfgmarine_attack,snd_bfgmarine_annoy,snd_bfgmarine_select);
   setEffectEID (false,0  ,0             ,EID_Gavno,0  );
   setEffectSND (false,nil,snd_uac_hdeath,snd_meat ,nil);
   setWeaponESND(0,snd_bfg_shot,nil,0,0);
   setWeaponTEID(0,nil,0,[fr_fps-10..255]);
end;
UID_FAPC:
begin
   setMWSModel(@spr_FAPC,nil);
   setCommandSND(false,snd_transport_ready,snd_transport_move,snd_transport_move,snd_transport_annoy,snd_transport_select);
   setEffectEID (false,0  ,EID_BExp,EID_BExp,0  );
   setEffectSND (false,nil,snd_exp ,snd_exp ,nil);
end;
UID_APC:
begin
   _animw:=17;
   setMWSModel(@spr_APC,nil);
   setCommandSND(false,snd_APC_ready,snd_APC_move,snd_APC_move,snd_APC_move,snd_APC_move);
   setEffectEID (false,0  ,EID_BExp,EID_BExp,0  );
   setEffectSND (false,nil,snd_exp ,snd_exp ,nil);
end;
UID_UACBot:
begin
   setMWSModel(@spr_UACBot,nil);
   setCommandSND(false,snd_uacbot_move,snd_uacbot_move,snd_uacbot_attack,snd_uacbot_annoy,snd_uacbot_select);
   setEffectEID (false,0  ,EID_Exp2,EID_Exp2,0  );
   setEffectSND (false,nil,snd_exp ,snd_exp ,nil);
   setWeaponESND(0    ,nil,snd_plasma,0,0);
end;
UID_Terminator:
begin
   _animw:=18;
   setMWSModel(@spr_Terminator,nil);
   setCommandSND(false,snd_terminator_ready,snd_terminator_move,snd_terminator_attack,snd_terminator_annoy,snd_terminator_select);
   setEffectEID (false,0  ,EID_Exp2,EID_Exp2,0  );
   setEffectSND (false,nil,snd_exp ,snd_exp ,nil);

   setWeaponESND(0,nil,snd_shotgun,0,0);
   setWeaponESND(1,nil,snd_ssg    ,0,0);
   setWeaponESND(2,nil,snd_pistol ,0,0);
   setWeaponESND(3,nil,snd_shotgun,0,0);

   DefaultRLDA_pa:=3;
end;
UID_Tank:
begin
   _animw:=17;
   setMWSModel(@spr_Tank,nil);
   setCommandSND(false,snd_tank_ready,snd_tank_move,snd_tank_attack,snd_tank_annoy,snd_tank_select);
   setEffectEID (false,0  ,EID_BExp,EID_BExp,0  );
   setEffectSND (false,nil,snd_exp ,snd_exp ,nil);
   setWeaponESND(0    ,nil,snd_exp,0,0);
   setWeaponTEID(0    ,nil,0,[fr_fps..255]);
end;
UID_Flyer:
begin
   setMWSModel(@spr_Flyer,nil);
   setCommandSND(false,snd_uacfighter_ready,snd_uacfighter_move,snd_uacfighter_attack,snd_uacfighter_annoy,snd_uacfighter_select);
   setEffectEID (false,0  ,EID_Exp2,EID_Exp2,0  );
   setEffectSND (false,nil,snd_exp ,snd_exp ,nil);
   setWeaponESND(0    ,nil,snd_flyer_s,0,0);
   setWeaponESND(1    ,nil,snd_launch ,0,0);
   //
end;
UID_UTransport:
begin
   setMWSModel(@spr_Transport,nil);
   setCommandSND(false,snd_transport_ready,snd_transport_move,snd_transport_move,snd_transport_annoy,snd_transport_select);
   setEffectEID (false,0  ,EID_BExp,EID_BExp,0  );
   setEffectSND (false,nil,snd_exp ,snd_exp ,nil);
end;


UID_UCommandCenter:
begin
   setMWSModel(@spr_UCommandCenter,nil);
   setBuildingSND(snd_uac_cc);
   setWeaponESND(0    ,nil,snd_plasma,0,0);
end;
UID_UMilitaryUnit:
begin
   setMWSModel(@spr_UMilitaryUnit,@spr_UAMilitaryUnit);
   setBuildingSND(snd_uac_barracks);
end;
UID_UFactory:
begin
   setMWSModel(@spr_UFactory,@spr_UAFactory);
   setBuildingSND(snd_uac_factory);
end;
UID_UGenerator:
begin
   setMWSModel(@spr_UGenerator,nil);
   setBuildingSND(snd_uac_generator);
end;
UID_UAGenerator:
begin
   setMWSModel(@spr_UAGenerator,nil);
   setBuildingSND(snd_uac_suply);
end;
UID_UWeaponFactory:
begin
   setMWSModel(@spr_UWeaponFactory,@spr_UAWeaponFactory);
   setBuildingSND(snd_uac_smith);
end;
UID_UTechCenter:
begin
   setMWSModel(@spr_UVehicleFactory,nil);
   setBuildingSND(snd_uac_tech);
end;
UID_UCTurret:
begin
   _animw    := 6;
   setMWSModel(@spr_UTurret,@spr_UPTurret);
   setBuildingSND(snd_uac_ctower);
   un_eid_bcrater_y:=1;
   setWeaponESND(0,nil,snd_shotgun,0,0);
   setWeaponESND(1,nil,snd_plasma ,0,0);
   setWeaponESND(2,nil,snd_shotgun,0,0);
end;
UID_URTurret:
begin
   _animw    := 2;

   setMWSModel(@spr_URTurret,nil);
   setBuildingSND(snd_uac_rtower);
   setWeaponESND(0,nil,snd_launch,0,0);
   un_eid_bcrater_y:=1;
end;
UID_URadar:
begin
   setMWSModel(@spr_URadar,nil);
   setBuildingSND(snd_uac_radar);
end;
UID_URMStation:
begin
   setMWSModel(@spr_URocketL,nil);
   setBuildingSND(snd_uac_rls);
end;

UID_UNuclearPlant:
begin
   setMWSModel(@spr_UNuclearPlant,nil);
   setBuildingSND(snd_uac_nucl);
end;
UID_UMine:
begin
   setMWSModel   (@spr_Mine,nil);
   setBuildingSND(snd_mine_place);
   un_snd_ready[false]:=snd_mine_place;
   setWeaponESND(0,nil,snd_electro,0,0);
   setEffectEID(false,0  ,EID_Exp,EID_Exp,0  );
   setEffectSND(false,nil,snd_exp,snd_exp,nil);
   un_eid_bcrater:=255;
end;

      end;

      if  (ui_panel_uids[_urace,byte(not _ukbuilding),_ucl]=0)
      then ui_panel_uids[_urace,byte(not _ukbuilding),_ucl]:=u;

      if(_ukbuilding)then
      begin
         if(un_eid_bcrater=0)then
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
         if(not un_eid_snd_set)then
         if(_r>42)then
         begin
            setEffectEID(false,0  ,EID_BBExp           ,EID_BBExp           ,0  );
            setEffectSND(false,nil,snd_building_explode,snd_building_explode,nil);
            if(un_eid_bcrater_y=0)then un_eid_bcrater_y:=10;
         end
         else
         begin
            setEffectEID(false,0  ,EID_BExp            ,EID_BExp            ,0  );
            setEffectSND(false,nil,snd_building_explode,snd_building_explode,nil);
            if(un_eid_bcrater_y=0)then un_eid_bcrater_y:=5;
         end;
         if(un_snd_ready[false]=nil)then un_snd_ready[false]:=snd_constr_complete[_urace];
         if(un_snd_ready[true ]=nil)then un_snd_ready[true ]:=un_snd_ready[false];
      end;

      for w:=0 to MaxUnitWeapons do
       with _a_weap[w] do
        if(aw_rld_a=[])then _CalcDefaultRLDA(@aw_rld_a,@aw_rld_s,DefaultRLDA_pa);

      _fr:=(_r div fog_cw)+1;
      if(_fr<1)then _fr:=1;
   end;


   // ui panel
   for r:=1 to r_cnt do
   begin
      i:=0;
      for u:=0 to 255 do
      with _upids[u] do
      if(_up_race=r)then
      begin
         ui_panel_uids[r,2,i]:=u;
         i+=1;
         if(i>ui_ubtns)then break;
      end;
   end;

   // upgrades
   for u:=0 to 255 do
   with _upids[u] do
   begin
      _up_btn:=spr_dummy;

      case u of
upgr_hell_dattack   : begin _up_btn:=spr_b_up[r_hell,0 ]; end;
upgr_hell_uarmor    : begin _up_btn:=spr_b_up[r_hell,1 ]; end;
upgr_hell_barmor    : begin _up_btn:=spr_b_up[r_hell,2 ]; end;
upgr_hell_mattack   : begin _up_btn:=spr_b_up[r_hell,3 ]; end;
upgr_hell_regen     : begin _up_btn:=spr_b_up[r_hell,4 ]; end;
upgr_hell_pains     : begin _up_btn:=spr_b_up[r_hell,5 ]; end;
upgr_hell_heye      : begin _up_btn:=spr_b_up[r_hell,6 ]; end;
upgr_hell_towers    : begin _up_btn:=spr_b_up[r_hell,7 ]; end;
upgr_hell_teleport  : begin _up_btn:=spr_b_up[r_hell,8 ]; end;
upgr_hell_hktele    : begin _up_btn:=spr_b_up[r_hell,9 ]; end;
upgr_hell_paina     : begin _up_btn:=spr_b_up[r_hell,10]; end;
upgr_hell_mainr     : begin _up_btn:=spr_b_up[r_hell,11]; end;
upgr_hell_hktdoodads: begin _up_btn:=spr_b_up[r_hell,20]; end;
upgr_hell_pinkspd   : begin _up_btn:=spr_b_up[r_hell,12]; end;
upgr_hell_revtele   : begin _up_btn:=spr_b_up[r_hell,16]; end;
upgr_hell_6bld      : begin _up_btn:=spr_b_up[r_hell,14]; end;
upgr_hell_9bld      : begin _up_btn:=spr_b_up[r_hell,24]; end;
upgr_hell_revmis    : begin _up_btn:=spr_b_up[r_hell,17]; end;
upgr_hell_totminv   : begin _up_btn:=spr_b_up[r_hell,18]; end;
upgr_hell_bldrep    : begin _up_btn:=spr_b_up[r_hell,19]; end;
upgr_hell_b478tel   : begin _up_btn:=spr_b_up[r_hell,21]; end;
upgr_hell_invuln    : begin _up_btn:=spr_b_up[r_hell,22]; end;

upgr_uac_attack     : begin _up_btn:=spr_b_up[r_uac ,0 ]; end;
upgr_uac_uarmor     : begin _up_btn:=spr_b_up[r_uac ,1 ]; end;
upgr_uac_barmor     : begin _up_btn:=spr_b_up[r_uac ,2 ]; end;
upgr_uac_melee      : begin _up_btn:=spr_b_up[r_uac ,3 ]; end;
upgr_uac_mspeed     : begin _up_btn:=spr_b_up[r_uac ,4 ]; end;
upgr_uac_plasmt     : begin _up_btn:=spr_b_up[r_uac ,5 ]; end;
upgr_uac_detect     : begin _up_btn:=spr_b_up[r_uac ,6 ]; end;
upgr_uac_towers     : begin _up_btn:=spr_b_up[r_uac ,7 ]; end;
upgr_uac_radar_r    : begin _up_btn:=spr_b_up[r_uac ,8 ]; end;
upgr_uac_mainm      : begin _up_btn:=spr_b_up[r_uac ,9 ]; end;
upgr_uac_ccturr     : begin _up_btn:=spr_b_up[r_uac ,10]; end;
upgr_uac_mainr      : begin _up_btn:=spr_b_up[r_uac ,11]; end;
upgr_uac_ccldoodads : begin _up_btn:=spr_b_up[r_uac ,20]; end;
upgr_uac_mines      : begin _up_btn:=spr_b_up[r_uac ,13]; end;
upgr_uac_jetpack    : begin _up_btn:=spr_b_up[r_uac ,15]; end;
upgr_uac_6bld       : begin _up_btn:=spr_b_up[r_uac ,14]; end;
upgr_uac_9bld       : begin _up_btn:=spr_b_up[r_uac ,24]; end;
upgr_uac_mechspd    : begin _up_btn:=spr_b_up[r_uac ,17]; end;
upgr_uac_mecharm    : begin _up_btn:=spr_b_up[r_uac ,18]; end;
upgr_uac_turarm     : begin _up_btn:=spr_b_up[r_uac ,21]; end;
upgr_uac_rstrike    : begin _up_btn:=spr_b_up[r_uac ,16]; end;

      end;

   end;
end;




