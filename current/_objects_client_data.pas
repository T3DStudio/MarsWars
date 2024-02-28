
///////////////////////////////////////////////////////////////
procedure InitUIDDataCL;
var u,i,r,w,
  DefaultRLDA_pa:byte;
un_eid_snd_set:boolean;

//local funcs
procedure setMWSModel(level:byte;mwsm:PTMWSModel);
var l:byte;
begin
   with g_uids[u] do
   for l:=level to MaxUnitLevel do
   un_smodel[l]:=mwsm;
end;

procedure setCommandSND(ready,move,attack,annoy,select:PTSoundSet); // command sounds
begin
   with g_uids[u] do
   begin
      un_snd_ready :=ready;
      un_snd_move  :=move;
      un_snd_attack:=attack;
      un_snd_annoy :=annoy;
      un_snd_select:=select;
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
   with g_uids[u] do
   for aa:=aa to MaxUnitWeapons do
   with _a_weap[aa] do
   begin
      aw_rld_a:=rld;
   end;
end;

procedure setBuildingSND(s:PTSoundSet);
begin setCommandSND(nil,s,s,s,s);end;

procedure setEffectEID(aa:byte;summon,death,fdeath,pain:byte);
begin
   with g_uids[u] do
   for aa:=aa to MaxUnitLevel do
   with _a_weap[aa] do
   begin
      un_eid_summon[aa]:=summon;
      un_eid_death [aa]:=death;
      un_eid_fdeath[aa]:=fdeath;
      un_eid_pain  [aa]:=pain;
   end;
end;
procedure setEffectEID2(aa:byte;summonspr:PTMWTexture);
begin
   with g_uids[u] do
   for aa:=aa to MaxUnitLevel do
   with _a_weap[aa] do
   begin
      un_eid_summon_spr[aa]:=summonspr;
   end;
end;
procedure setEffectSND(summon,death,fdeath,pain:PTSoundSet);
begin
   with g_uids[u] do
   begin
      un_eid_snd_summon:=summon;
      un_eid_snd_death :=death;
      un_eid_snd_fdeath:=fdeath;
      un_eid_snd_pain  :=pain;
   end;
   un_eid_snd_set:=true;
end;

procedure setFOOT(footsnd:PTSoundSet;footanim:integer);
begin
   with g_uids[u] do
   begin
      un_eid_snd_foot:=footsnd;
      un_foot_anim   :=footanim;
   end;
end;

procedure setWeaponESND(aa:byte;snd_start,snd_shot:PTSoundSet;eid_start,eid_shot:byte);
begin
   with g_uids[u] do
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
   with g_uids[u] do
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
   with g_uids[u] do
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
   with g_uids[u] do
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
   with g_uids[u] do
   begin
      un_eid_snd_set:=false;
      setMWSModel(0,@spr_dmodel);
      _animw:=10;
      _animd:=10;

      DefaultRLDA_pa:=3;

      case u of
UID_LostSoul,
UID_Phantom:
begin
   if(u=UID_Phantom)
   then setMWSModel(0,@spr_phantom )
   else setMWSModel(0,@spr_lostsoul);
   setCommandSND(snd_lost_move,snd_hell_move,snd_lost_move,snd_hell_pain,snd_hell_move);
   setEffectEID (0,0  ,0        ,u       ,0            );
   setEffectSND (    nil,snd_pexp ,snd_pexp,snd_hell_pain);
   setWeaponESND(0  ,nil,snd_lost_move,0,0);
end;
UID_Imp:
begin
   _animw:=12;
   _animd:=8;
   setMWSModel  (0,@spr_imp);
   setCommandSND(snd_imp_ready,snd_imp_move,snd_imp_ready,snd_zimba_pain,snd_imp_move);
   setEffectEID (0,0  ,0            ,EID_Gavno,0             );
   setEffectSND (  nil,snd_imp_death,snd_meat ,snd_zimba_pain);
   setWeaponESND(0,nil,snd_hell_attack,0,0);
   setWeaponESND(1,nil,snd_hell_melee ,0,0);
end;
UID_Demon:
begin
   _animw:=19;
   _animd:=9;
   setMWSModel  (0,@spr_demon);
   setCommandSND(snd_demon_ready,snd_hell_move,snd_demon_ready,snd_hell_pain,snd_hell_move);
   setEffectEID (0,0  ,0              ,0  ,0             );
   setEffectSND (  nil,snd_demon_death,nil,snd_hell_pain );
   setWeaponESND(0,nil,snd_demon_melee,0,0);
end;
UID_Cacodemon:
begin
   _animd:=10;
   setMWSModel  (0,@spr_cacodemon);
   setCommandSND(snd_caco_ready,snd_hell_move,snd_caco_ready,snd_hell_pain,snd_hell_move);
   setEffectEID (0,0  ,0              ,0  ,0             );
   setEffectSND (  nil,snd_caco_death ,nil,snd_hell_pain );
   setWeaponESND(0,nil,snd_hell_attack,0,0);
   setWeaponESND(1,nil,snd_hell_melee ,0,0);
end;
UID_Knight:
begin
   _animw:=12;
   _animd:=10;
   setMWSModel(0,@spr_knight);
   setCommandSND(snd_knight_ready,snd_hell_move,snd_knight_ready,snd_hell_pain,snd_hell_move);
   setEffectEID (0,0  ,0                ,0  ,0             );
   setEffectSND (  nil,snd_knight_death ,nil,snd_hell_pain );
   setWeaponESND(0,nil,snd_hell_attack,0,0);
   setWeaponESND(1,nil,snd_hell_melee ,0,0);
end;
UID_Baron:
begin
   _animw:=12;
   _animd:=10;
   setMWSModel  (0,@spr_baron);
   setCommandSND(snd_baron_ready ,snd_hell_move,snd_baron_ready ,snd_hell_pain,snd_hell_move);
   setEffectEID (0,0  ,0                ,0  ,0             );
   setEffectSND (  nil,snd_baron_death  ,nil,snd_hell_pain );
   setWeaponESND(0,nil,snd_hell_attack,0,0);
   setWeaponESND(1,nil,snd_hell_melee ,0,0);
end;
UID_Cyberdemon:
begin
   _animw:=11;
   setMWSModel  (0,@spr_cyberdemon);
   setCommandSND(snd_cyber_ready,snd_hell_move,snd_cyber_ready,snd_hell_pain,snd_hell_move);
   setEffectEID (0,0  ,0              ,0  ,0             );
   setEffectSND (  nil,snd_cyber_death,nil,snd_hell_pain );
   setFOOT      (snd_cyber_foot,30);
   setWeaponESND(0,nil,snd_launch,0,0);
end;
UID_Mastermind:
begin
   _animw:=13;
   _animd:=16;
   setMWSModel  (0,@spr_mastermind);
   setCommandSND(snd_mastermind_ready,snd_hell_move,snd_mastermind_ready,snd_hell_pain,snd_hell_move);
   setEffectEID (0,0  ,0                   ,0  ,0             );
   setEffectSND (  nil,snd_mastermind_death,nil,snd_hell_pain );
   setFOOT      (snd_mastermind_foot,22);
   setWeaponESND(0,nil,snd_shotgun,0,0);
end;
UID_Pain:
begin
   _animw:=7;
   setMWSModel  (0,@spr_pain);
   setCommandSND(snd_pain_ready,snd_hell_move,snd_hell_move,snd_pain_pain,snd_hell_move);
   setEffectEID (0,0  ,0   ,UID_Pain      ,0             );
   setEffectSND (  nil,snd_pain_death,snd_pain_death,snd_pain_pain );
end;
UID_Revenant:
begin
   _animw:=16;
   _animd:=9;
   setMWSModel  (0,@spr_revenant);
   setCommandSND(snd_revenant_ready,snd_revenant_move,snd_revenant_ready,snd_zimba_pain,snd_revenant_move);
   setEffectEID (0,0  ,0                 ,0  ,0             );
   setEffectSND (  nil,snd_revenant_death,nil,snd_zimba_pain);
   setWeaponESND(0,nil,snd_revenant_attack,0,0);
   setWeaponESND(1,nil,snd_revenant_melee ,0,0);
end;
UID_Mancubus:
begin
   _animw:=11;
   _animd:=13;
   setMWSModel  (0,@spr_mancubus);
   setCommandSND(snd_mancubus_ready,snd_zimba_move,snd_mancubus_ready,snd_mancubus_pain,snd_zimba_move);
   setEffectEID (0,0  ,0              ,0  ,0             );
   setEffectSND (  nil,snd_mancubus_death ,nil,snd_mancubus_pain );
   setWeaponESND(0,snd_mancubus_attack,snd_hell_attack,0,0);
end;
UID_Arachnotron:
begin
   _animw:=13;
   _animd:=13;
   setMWSModel  (0,@spr_arachnotron);
   setCommandSND(snd_arachno_ready,snd_arachno_move,snd_arachno_ready,snd_hell_pain,snd_arachno_move);
   setEffectEID (0,0  ,0              ,0  ,0             );
   setEffectSND (  nil,snd_arachno_death,nil,snd_hell_pain );
   setFOOT      (snd_arachno_foot,26);
   setWeaponESND(0,nil,snd_plasma,0,0);
end;
UID_Archvile:
begin
   _animw:=15;
   _animd:=12;
   setMWSModel  (0,@spr_archvile);
   setCommandSND(snd_archvile_ready,snd_archvile_move,snd_archvile_ready,snd_archvile_pain,snd_archvile_move);
   setEffectEID (0,0  ,0                   ,0  ,0                 );
   setEffectSND (  nil,snd_archvile_death  ,nil,snd_archvile_pain );
   setWeaponESND(0,nil,snd_meat,0,0);
   setWeaponTEID(0,nil,0       ,[0..255]);
   setWeaponESND(1,snd_archvile_attack,nil,0,0);
   setWeaponTEID(1,nil  ,0,[0..65]); //snd_archvile_fire EID_ArchFire
end;

UID_ZFormer:
begin
   _animw:=15;
   _animd:=8;
   setCommandSND(snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setMWSModel  (0,@spr_ZFormer);
   setEffectEID (0,0  ,0              ,EID_Gavno,0             );
   setEffectSND (  nil,snd_zimba_death,snd_meat ,snd_zimba_pain);
   setWeaponESND(0,nil,snd_pistol,0,0);
end;
UID_ZEngineer:
begin
   _animw:=15;
   _animd:=8;
   setCommandSND(snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setMWSModel  (0,@spr_ZEngineer);
   setEffectEID (0,0  ,EID_Exp,EID_Exp,0  );
   setEffectSND (  nil,snd_exp,snd_exp,nil);
end;
UID_ZSergant:
begin
   _animw:=15;
   _animd:=8;
   setCommandSND(snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (0,0  ,0              ,EID_Gavno,0             );
   setEffectSND (  nil,snd_zimba_death,snd_meat ,snd_zimba_pain);
   setMWSModel  (0,@spr_ZSergant);
   setWeaponESND(0,nil,snd_shotgun,0,0);
end;
UID_ZSSergant:
begin
   _animw:=14;
   _animd:=8;
   setCommandSND(snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (0,0  ,0              ,EID_Gavno,0             );
   setEffectSND (  nil,snd_zimba_death,snd_meat ,snd_zimba_pain);
   setMWSModel  (0,@spr_ZSSergant);
   setWeaponESND(0,nil,snd_ssg    ,0,0);
end;
UID_ZCommando:
begin
   _animw:=14;
   _animd:=8;
   setCommandSND(snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (0,0  ,0              ,EID_Gavno,0             );
   setEffectSND (  nil,snd_zimba_death,snd_meat ,snd_zimba_pain);
   setMWSModel  (0,@spr_ZCommando);
   setWeaponESND(0,nil,snd_shotgun,0,0);
end;
UID_ZSiegeMarine:
begin
   _animw:=13;
   _animd:=8;
   setCommandSND(snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (0,0  ,0              ,EID_Gavno,0             );
   setEffectSND (  nil,snd_zimba_death,snd_meat ,snd_zimba_pain);
   setMWSModel  (0,@spr_ZSiege);
   setWeaponESND(0,nil,snd_launch,0,0);
end;
UID_ZAntiaircrafter:
begin
   _animw:=13;
   _animd:=8;
   setCommandSND(snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (0,0  ,0              ,EID_Gavno,0             );
   setEffectSND (  nil,snd_zimba_death,snd_meat ,snd_zimba_pain);
   setMWSModel  (0,@spr_ZAntiaircrafter);
   setWeaponESND(0,nil,snd_launch,0,0);
end;
UID_ZFPlasmagunner:
begin
   _animw:=14;
   _animd:=8;
   setMWSModel  (0,@spr_ZFMajor);
   setCommandSND(snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (0,0  ,EID_Exp,EID_Exp,0  );
   setEffectSND (  snd_jetpon,snd_exp,snd_exp,nil);
   setWeaponESND(0    ,nil,snd_plasma,0,0);
   setWeaponTEID(0    ,nil,0,[0..255]);
end;
UID_ZBFGMarine:
begin
   _animw:=11;
   _animd:=8;
   setCommandSND(snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (0,0  ,0              ,EID_Gavno,0             );
   setEffectSND (  nil,snd_zimba_death,snd_meat ,snd_zimba_pain);
   setMWSModel  (0,@spr_ZBFG);
   setWeaponESND(0,snd_bfg_shot,nil,0,0);
   setWeaponTEID(0,nil,0,[fr_fps1-10..255]);
end;


UID_HKeep:
begin
   setMWSModel(0,@spr_HKeep);
   setBuildingSND(snd_hell_hk);
end;
UID_HAKeep:
begin
   setMWSModel(0,@spr_HAKeep);
   setBuildingSND(snd_hell_hk);
end;
UID_HGate:
begin
   setMWSModel(0,@spr_HGate );
   setMWSModel(1,@spr_HAGate);
   setBuildingSND(snd_hell_hgate);
end;
UID_HSymbol:
begin
   setMWSModel(0,@spr_HSymbol);
   setBuildingSND(snd_hell_hsymbol);
end;
UID_HASymbol:
begin
   setMWSModel(0,@spr_HASymbol);
   setBuildingSND(snd_hell_hsymbol);
end;
UID_HPools:
begin
   setMWSModel(0,@spr_HPools );
   setMWSModel(1,@spr_HAPools);
   setBuildingSND(snd_hell_hpool);
end;
UID_HTower:
begin
   _animw:=5;

   setMWSModel(0,@spr_HTower);
   setBuildingSND(snd_hell_htower);
   setWeaponESND(0,nil,snd_hell_attack    ,0,MID_Imp);
   un_eid_bcrater_y:=15;
end;
UID_HTeleport:
begin
   _animw:=5;

   setMWSModel(0,@spr_HTeleport);
   setBuildingSND(snd_hell_hteleport);
end;
UID_HPentagram:
begin
   setMWSModel(0,@spr_HPentagram);
   setBuildingSND(snd_hell_hbuild);
end;
UID_HMonastery:
begin
   setMWSModel(0,@spr_HMonastery);
   setBuildingSND(snd_hell_hmon);
   un_build_amode:=2;
end;
UID_HTotem:
begin
   setMWSModel(0,@spr_HTotem);
   setBuildingSND(snd_hell_htotem);
   un_build_amode:=2;
   un_eid_bcrater_y:=12;
   setWeaponESND(0,snd_archvile_attack,nil,0,0);
   setWeaponTEID(0,nil,0,[0..65]); // snd_archvile_fire                EID_ArchFire
end;
UID_HAltar:
begin
   setMWSModel(0,@spr_HAltar);
   setBuildingSND(snd_hell_haltar);
   un_build_amode:=2;
end;
UID_HFortress:
begin
   setMWSModel(0,@spr_HFortress);
   setBuildingSND(snd_hell_hfort);
   un_build_amode:=2;
end;
UID_HEye:
begin
   setMWSModel(0,@spr_HEye);
   setBuildingSND(snd_hell_eye);
   un_build_amode:=2;
   un_eid_bcrater:=255;
   setEffectEID(0,0  ,UID_HEye,UID_HEye,0  );
   setEffectSND(  nil,snd_pexp,snd_pexp,nil);
end;
UID_HCommandCenter:
begin
   setMWSModel(0,@spr_HCommandCenter);
   setBuildingSND(snd_hell_hbuild);
   setEffectEID(0,0       ,EID_BBExp           ,EID_BBExp           ,0  );
   setEffectSND(  snd_hell,snd_building_explode,snd_building_explode,nil);
   un_eid_bcrater_y:=10;
   setWeaponESND(0    ,nil,snd_hell_attack,0,0);
end;
UID_HACommandCenter:
begin
   setMWSModel(0,@spr_HACommandCenter);
   setBuildingSND(snd_hell_hbuild);
   setEffectEID(0,0       ,EID_BBExp           ,EID_BBExp           ,0  );
   setEffectSND(  snd_hell,snd_building_explode,snd_building_explode,nil);
   un_eid_bcrater_y:=10;
   setWeaponESND(0    ,nil,snd_hell_attack,0,0);
end;
UID_HBarracks:
begin
   setMWSModel(0,@spr_HBarracks );
   setMWSModel(1,@spr_HABarracks);
   setBuildingSND(snd_hell_hbuild);
   setEffectEID(0,0     ,EID_BBExp           ,EID_BBExp           ,0  );
   setEffectEID(1,0     ,EID_BBExp           ,EID_BBExp           ,0  );
   setEffectSND(snd_hell,snd_building_explode,snd_building_explode,nil);
   un_eid_bcrater_y:=10;
end;


UID_Engineer:
begin
   _animw:=15;
   _animd:=8;
   setMWSModel(0,@spr_Engineer);
   setCommandSND(snd_scout_ready   ,snd_scout_move   ,snd_scout_move     ,snd_scout_select  ,snd_scout_select   );
   setEffectEID (0,0  ,0             ,EID_Gavno,0  );
   setEffectSND (  nil,snd_uac_hdeath,snd_meat ,nil);
   setWeaponESND(0,nil,snd_electro,0,0);
   setWeaponESND(1,nil,snd_pistol ,0,0);
   with _a_weap[0] do begin aw_eid_target:=MID_BPlasma;aw_eid_target_onlyshot:=true;end;
end;
UID_Medic:
begin
   _animw:=15;
   _animd:=8;
   setMWSModel(0,@spr_Medic);
   setCommandSND(snd_medic_ready,snd_medic_move,snd_medic_move,snd_medic_annoy,snd_medic_select);
   setEffectEID (0,0  ,0             ,EID_Gavno,0  );
   setEffectSND (  nil,snd_uac_hdeath,snd_meat ,nil);
   setWeaponESND(0,nil,snd_healing,0,0);
   setWeaponESND(1,nil,snd_pistol,0,0);
   with _a_weap[0] do begin aw_eid_target:=MID_YPlasma;aw_eid_target_onlyshot:=true;end;
end;
UID_Sergant:
begin
   _animw:=17;
   _animd:=8;
   setMWSModel(0,@spr_Sergant);
   setCommandSND(snd_shotgunner_ready,snd_shotgunner_move,snd_shotgunner_attack,snd_shotgunner_annoy,snd_shotgunner_select);
   setEffectEID (0,0  ,0             ,EID_Gavno,0  );
   setEffectSND (  nil,snd_uac_hdeath,snd_meat ,nil);
   setWeaponESND(0,nil,snd_shotgun ,0,0);
end;
UID_SSergant:
begin
   _animw:=17;
   _animd:=8;
   setMWSModel(0,@spr_SSergant);
   setCommandSND(snd_ssg_ready       ,snd_ssg_move       ,snd_ssg_attack       ,snd_ssg_annoy       ,snd_ssg_select       );
   setEffectEID (0,0  ,0             ,EID_Gavno,0  );
   setEffectSND (  nil,snd_uac_hdeath,snd_meat ,nil);
   setWeaponESND(0,nil,snd_ssg    ,0,0);
end;
UID_Commando:
begin
   _animw:=16;
   _animd:=8;
   setMWSModel(0,@spr_Commando);
   setCommandSND(snd_commando_ready,snd_commando_move,snd_commando_attack,snd_commando_annoy,snd_commando_select);
   setEffectEID (0,0  ,0             ,EID_Gavno,0  );
   setEffectSND (  nil,snd_uac_hdeath,snd_meat ,nil);
   setWeaponESND(0,nil,snd_pistol,0,0);
end;
UID_SiegeMarine:
begin
   _animw:=15;
   _animd:=8;
   setMWSModel(0,@spr_Siege);
   setCommandSND(snd_rocketmarine_ready,snd_rocketmarine_move,snd_rocketmarine_attack,snd_rocketmarine_annoy,snd_rocketmarine_select);
   setEffectEID (0,0  ,0             ,EID_Gavno,0  );
   setEffectSND (  nil,snd_uac_hdeath,snd_meat ,nil);
   setWeaponESND(0,nil,snd_launch,0,0);
end;
UID_Antiaircrafter:
begin
   _animw:=16;
   _animd:=8;
   setMWSModel(0,@spr_Antiaircrafter);
   setCommandSND(snd_engineer_ready,snd_engineer_move,snd_engineer_attack,snd_engineer_annoy,snd_engineer_select);
   setEffectEID (0,0  ,0             ,EID_Gavno,0  );
   setEffectSND (  nil,snd_uac_hdeath,snd_meat ,nil);
   setWeaponESND(0,nil,snd_launch,0,0);
end;
UID_FPlasmagunner:
begin
   _animd:=8;
   setMWSModel(0,@spr_FMajor);
   setCommandSND(snd_plasmamarine_ready,snd_plasmamarine_move,snd_plasmamarine_attack,snd_plasmamarine_annoy,snd_plasmamarine_select);
   setEffectEID (0,0         ,EID_Exp,EID_Exp,0  );
   setEffectSND (  snd_jetpon,snd_exp,snd_exp,nil);
   setWeaponESND(0    ,nil,snd_plasma,0,0);
   //setWeaponTEID(0    ,nil,0,[0..255]);
end;
UID_BFGMarine:
begin
   _animw:=14;
   _animd:=8;
   setMWSModel(0,@spr_BFG);
   setCommandSND(snd_bfgmarine_ready,snd_bfgmarine_move,snd_bfgmarine_attack,snd_bfgmarine_annoy,snd_bfgmarine_select);
   setEffectEID (0,0  ,0             ,EID_Gavno,0  );
   setEffectSND (  nil,snd_uac_hdeath,snd_meat ,nil);
   setWeaponESND(0,snd_bfg_shot,nil,0,0);
   setWeaponTEID(0,nil,0,[fr_fps1-10..255]);
end;
UID_UTransport:
begin
   setMWSModel(0,@spr_FAPC);
   setMWSModel(1,@spr_Transport);
   setCommandSND(snd_transport_ready,snd_transport_move,snd_transport_move,snd_transport_annoy,snd_transport_select);
   setEffectEID (0,0  ,EID_BExp,EID_BExp,0  );
   setEffectSND (  nil,snd_exp ,snd_exp ,nil);
end;
UID_APC:
begin
   _animw:=17;
   setMWSModel(0,@spr_APC);
   setCommandSND(snd_APC_ready,snd_APC_move,snd_APC_move,snd_APC_move,snd_APC_move);
   setEffectEID (0,0  ,EID_BExp,EID_BExp,0  );
   setEffectSND (  nil,snd_exp ,snd_exp ,nil);
end;
UID_UACDron:
begin
   setMWSModel(0,@spr_UACBot);
   setCommandSND(snd_uacbot_move,snd_uacbot_move,snd_uacbot_attack,snd_uacbot_annoy,snd_uacbot_select);
   setEffectEID (0,0  ,EID_Exp2,EID_Exp2,0  );
   setEffectSND (  nil,snd_exp ,snd_exp ,nil);
   setWeaponESND(0    ,nil,snd_plasma,0,0);
end;
UID_Terminator:
begin
   _animw:=15;
   setMWSModel(0,@spr_Terminator);
   setCommandSND(snd_terminator_ready,snd_terminator_move,snd_terminator_attack,snd_terminator_annoy,snd_terminator_select);
   setEffectEID (0,0  ,EID_Exp2,EID_Exp2,0  );
   setEffectSND (  nil,snd_exp ,snd_exp ,nil);

   setWeaponESND(0,nil,snd_shotgun,0,0);
   setWeaponESND(1,nil,snd_revenant_attack,0,0);

   setWeaponTEID(0,nil,0,[0..255]);
   with _a_weap[1] do
   begin
      aw_AnimStay:=sms_mattack;
      aw_rld_a:=[];
   end;

   DefaultRLDA_pa:=2;
end;
UID_Tank:
begin
   _animw:=15;
   setMWSModel(0,@spr_Tank);
   setCommandSND(snd_tank_ready,snd_tank_move,snd_tank_attack,snd_tank_annoy,snd_tank_select);
   setEffectEID (0,0  ,EID_BExp,EID_BExp,0  );
   setEffectSND (  nil,snd_exp ,snd_exp ,nil);
   setWeaponESND(0    ,nil,snd_exp,0,0);
   setWeaponTEID(0    ,nil,0,[fr_fps1..255]);
end;
UID_Flyer:
begin
   setMWSModel(0,@spr_Flyer);
   setCommandSND(snd_uacfighter_ready,snd_uacfighter_move,snd_uacfighter_attack,snd_uacfighter_annoy,snd_uacfighter_select);
   setEffectEID (0,0  ,EID_Exp2,EID_Exp2,0  );
   setEffectSND (nil,snd_exp ,snd_exp ,nil);
   setWeaponESND(0  ,nil,snd_flyer_s,0,0);
end;


UID_UCommandCenter:
begin
   setMWSModel(0,@spr_UCommandCenter);
   setBuildingSND(snd_uac_cc);
   setWeaponESND(0    ,nil,snd_plasma,0,0);
end;
UID_UACommandCenter:
begin
   setMWSModel(0,@spr_UACommandCenter);
   setBuildingSND(snd_uac_cc);
   setWeaponESND(0    ,nil,snd_plasma,0,0);
end;
UID_UBarracks:
begin
   setMWSModel(0,@spr_UBarracks);
   setMWSModel(1,@spr_UABarracks);
   setBuildingSND(snd_uac_barracks);
end;
UID_UFactory:
begin
   setMWSModel(0,@spr_UFactory );
   setMWSModel(1,@spr_UAFactory);
   setBuildingSND(snd_uac_factory);
end;
UID_UGenerator:
begin
   setMWSModel(0,@spr_UGenerator);
   setBuildingSND(snd_uac_generator);
end;
UID_UAGenerator:
begin
   setMWSModel(0,@spr_UAGenerator);
   setBuildingSND(snd_uac_suply);
end;
UID_UWeaponFactory:
begin
   setMWSModel(0,@spr_UWeaponFactory); //@
   setMWSModel(1,@spr_UAWeaponFactory);
   setBuildingSND(snd_uac_smith);
end;
UID_UTechCenter:
begin
   setMWSModel(0,@spr_UTechCenter);
   setBuildingSND(snd_uac_tech);
end;
UID_UGTurret:
begin
   _animw    := 6;
   setMWSModel(0,@spr_UTurret);
   setMWSModel(1,@spr_UPTurret);
   setBuildingSND(snd_uac_ctower);
   un_eid_bcrater_y:=1;
   setWeaponESND(0,nil,snd_plasma ,0,0);
   setWeaponESND(1,nil,snd_shotgun,0,0);
end;
UID_UATurret:
begin
   _animw    := 2;

   setMWSModel(0,@spr_URTurret);
   setBuildingSND(snd_uac_rtower);
   setWeaponESND(0,nil,snd_launch,0,0);
   un_eid_bcrater_y:=1;
end;
UID_URadar:
begin
   setMWSModel(0,@spr_URadar);
   setBuildingSND(snd_uac_radar);
end;
UID_URMStation:
begin
   setMWSModel(0,@spr_URocketL);
   setBuildingSND(snd_uac_rls);
end;

UID_UComputerStation:
begin
   setMWSModel(0,@spr_UNuclearPlant);
   setBuildingSND(snd_uac_nucl);
end;
UID_UMine:
begin
   setMWSModel   (0,@spr_Mine);
   setBuildingSND(snd_mine_place);
   un_snd_ready:=snd_mine_place;
   setWeaponESND(0,nil,snd_electro,0,0);
   setEffectEID(0,0  ,EID_Exp,EID_Exp,0  );
   setEffectSND(  nil,snd_exp,snd_exp,nil);
   un_eid_bcrater:=255;
end;

      end;

      if  (ui_panel_uids[_urace,byte(not _ukbuilding),_ucl] =0)
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
             setEffectEID(0,0  ,EID_BBExp           ,EID_BBExp           ,0  );
             setEffectSND(  nil,snd_building_explode,snd_building_explode,nil);
             if(un_eid_bcrater_y=0)then un_eid_bcrater_y:=10;
          end
          else
          begin
             setEffectEID(0,0  ,EID_BExp            ,EID_BExp            ,0  );
             setEffectSND(  nil,snd_building_explode,snd_building_explode,nil);
             if(un_eid_bcrater_y=0)then un_eid_bcrater_y:=5;
          end;
         if(un_snd_ready=nil)then un_snd_ready:=snd_constr_complete[_urace];
      end;

      for w:=0 to MaxUnitWeapons do
       with _a_weap[w] do
        if(aw_rld_a=[])then _CalcDefaultRLDA(@aw_rld_a,@aw_rld_s,DefaultRLDA_pa);

      _fr:=(_r div fog_cw)+1;
      if(_fr<1)then _fr:=1;
   end;

   u:=UID_HCommandCenter;  setEffectEID2(0,_uid2spr(UID_UCommandCenter  ,0,0));
   u:=UID_HACommandCenter; setEffectEID2(0,_uid2spr(UID_UACommandCenter ,0,0));
   u:=UID_HBarracks;       setEffectEID2(0,_uid2spr(UID_UBarracks       ,0,0));
                           setEffectEID2(1,_uid2spr(UID_UBarracks       ,0,1));

   // ui panel
   for r:=1 to r_cnt do
   begin
      i:=0;
      for u:=0 to 255 do
      with g_upids[u] do
      if(_up_race=r)then
      begin
         ui_panel_uids[r,2,_up_btni]:=u;
         i+=1;
         if(i>ui_ubtns)then break;
      end;
   end;

   // upgrades
   for u:=0 to 255 do
   with g_upids[u] do
   begin
      _up_btn:=spr_dummy;

      case u of
upgr_hell_t1attack  : begin _up_btn:=spr_b_up[r_hell,0 ]; end;
upgr_hell_uarmor    : begin _up_btn:=spr_b_up[r_hell,1 ]; end;
upgr_hell_barmor    : begin _up_btn:=spr_b_up[r_hell,2 ]; end;
upgr_hell_mattack   : begin _up_btn:=spr_b_up[r_hell,3 ]; end;
upgr_hell_vision    : begin _up_btn:=spr_b_up[r_hell,15]; end;
upgr_hell_regen     : begin _up_btn:=spr_b_up[r_hell,4 ]; end;
upgr_hell_pains     : begin _up_btn:=spr_b_up[r_hell,5 ]; end;
upgr_hell_heye      : begin _up_btn:=spr_b_up[r_hell,6 ]; end;
upgr_hell_towers    : begin _up_btn:=spr_b_up[r_hell,7 ]; end;
upgr_hell_teleport  : begin _up_btn:=spr_b_up[r_hell,8 ]; end;
upgr_hell_HKTeleport: begin _up_btn:=spr_b_up[r_hell,9 ]; end;
upgr_hell_paina     : begin _up_btn:=spr_b_up[r_hell,10]; end;
upgr_hell_buildr    : begin _up_btn:=spr_b_up[r_hell,11]; end;
upgr_hell_extbuild  : begin _up_btn:=spr_b_up[r_hell,20]; end;
upgr_hell_spectre   : begin _up_btn:=spr_b_up[r_hell,23]; end;
upgr_hell_ghostm    : begin _up_btn:=spr_b_up[r_hell,12]; end;
upgr_hell_phantoms  : begin _up_btn:=spr_b_up[r_hell,17]; end;
upgr_hell_t2attack  : begin _up_btn:=spr_b_up[r_hell,24]; end;
upgr_hell_rteleport : begin _up_btn:=spr_b_up[r_hell,16]; end;
upgr_hell_totminv   : begin _up_btn:=spr_b_up[r_hell,18]; end;
upgr_hell_bldrep    : begin _up_btn:=spr_b_up[r_hell,19]; end;
upgr_hell_tblink    : begin _up_btn:=spr_b_up[r_hell,21]; end;
upgr_hell_resurrect : begin _up_btn:=spr_b_up[r_hell,13]; end;
upgr_hell_invuln    : begin _up_btn:=spr_b_up[r_hell,22]; end;

upgr_uac_attack     : begin _up_btn:=spr_b_up[r_uac ,0 ]; end;
upgr_uac_uarmor     : begin _up_btn:=spr_b_up[r_uac ,1 ]; end;
upgr_uac_barmor     : begin _up_btn:=spr_b_up[r_uac ,2 ]; end;
upgr_uac_melee      : begin _up_btn:=spr_b_up[r_uac ,3 ]; end;
upgr_uac_vision     : begin _up_btn:=spr_b_up[r_uac ,12]; end;
upgr_uac_mspeed     : begin _up_btn:=spr_b_up[r_uac ,4 ]; end;
upgr_uac_plasmt     : begin _up_btn:=spr_b_up[r_uac ,5 ]; end;
upgr_uac_soaring    : begin _up_btn:=spr_b_up[r_uac ,6 ]; end;
upgr_uac_towers     : begin _up_btn:=spr_b_up[r_uac ,7 ]; end;
upgr_uac_radar_r    : begin _up_btn:=spr_b_up[r_uac ,8 ]; end;
upgr_uac_CCFly      : begin _up_btn:=spr_b_up[r_uac ,9 ]; end;
upgr_uac_ccturr     : begin _up_btn:=spr_b_up[r_uac ,10]; end;
upgr_uac_buildr     : begin _up_btn:=spr_b_up[r_uac ,11]; end;
upgr_uac_extbuild   : begin _up_btn:=spr_b_up[r_uac ,20]; end;
upgr_uac_commando   : begin _up_btn:=spr_b_up[r_uac ,22]; end;
upgr_uac_botturret  : begin _up_btn:=spr_b_up[r_uac ,23]; end;
upgr_uac_airsp      : begin _up_btn:=spr_b_up[r_uac ,13]; end;
upgr_uac_ssgup      : begin _up_btn:=spr_b_up[r_uac ,15]; end;
upgr_uac_transport  : begin _up_btn:=spr_b_up[r_uac ,24]; end;
upgr_uac_mechspd    : begin _up_btn:=spr_b_up[r_uac ,17]; end;
upgr_uac_mecharm    : begin _up_btn:=spr_b_up[r_uac ,18]; end;
upgr_uac_turarm     : begin _up_btn:=spr_b_up[r_uac ,21]; end;
upgr_uac_rstrike    : begin _up_btn:=spr_b_up[r_uac ,16]; end;
upgr_uac_antiair    : begin _up_btn:=spr_b_up[r_uac ,19]; end;

      end;

   end;
end;




