
///////////////////////////////////////////////////////////////
procedure InitClientDataGame;
var
u,i,r,w,
DefaultRLDA_pa:byte;
un_eid_snd_set:boolean;

//local funcs
procedure setMWSModel(level:byte;mwsm:PTMWSModel);
begin
   with g_uids[u] do
     if(level<=LastUnitLevel)then
       for level:=level to LastUnitLevel do
         uid_SpriteModel[level]:=mwsm;
end;

procedure setCommandSND(asnd_ready,asnd_move,asnd_attack,asnd_annoy,asnd_select:PTSoundSet); // command sounds
begin
   with g_uids[u] do
   begin
      uid_snd_ready :=asnd_ready;
      uid_snd_move  :=asnd_move;
      uid_snd_attack:=asnd_attack;
      uid_snd_annoy :=asnd_annoy;
      uid_snd_select:=asnd_select;
   end;
end;

procedure CalcDefaultArmsAnimPoints(pAnimPoints,pShotPoints:PTSoB;pa:byte);
var i,x:byte;
procedure setline(a0,a1:byte);
begin
   while(a0<>a1)do
   begin
      pAnimPoints^:=pAnimPoints^+[a1];
      if(a0<a1)
      then a1-=1
      else a1+=1;
   end;
end;
begin
   i :=255;
   x :=255;

   for i:=255 downto 0 do
     if(i in pShotPoints^)or(i=0)then
     begin
        if(x<255)then setline(x-((x-i) div pa),x);
        x:=i;
     end;
end;

procedure SetArmsAnimPoints(aa:byte;rld:TSoB);
begin
   with g_uids[u] do
     if(aa<=LastUnitArms)then
       for aa:=aa to LastUnitArms do
         with uid_arms[aa] do
           aw_AnimPoints:=rld;
end;

procedure setBuildingSND(s:PTSoundSet);
begin setCommandSND(nil,s,s,s,s);end;

procedure setEffectEID(aa,aeid_summon,aeid_deathSlow,aeid_deathFast,aeid_pain:byte);
begin
   with g_uids[u] do
     if(aa<=LastUnitLevel)then
       for aa:=aa to LastUnitLevel do
         with uid_arms[aa] do
         begin
            uid_eid_Summon   [aa]:=aeid_summon;
            uid_eid_DeathSlow[aa]:=aeid_deathSlow;
            uid_eid_DeathFast[aa]:=aeid_deathFast;
            uid_eid_Pain     [aa]:=aeid_pain;
         end;
end;
procedure setEffectEID2(aa:byte;summonspr:PTMWTexture);
begin
   with g_uids[u] do
     if(aa<=LastUnitLevel)then
       for aa:=aa to LastUnitLevel do
         with uid_arms[aa] do
           uid_eid_SummonSpr[aa]:=summonspr;
end;
procedure setEffectSND(asnd_summon,asnd_deathSlow,asnd_deathFast,asnd_pain:PTSoundSet);
begin
   with g_uids[u] do
   begin
      uid_snd_Summon   :=asnd_summon;
      uid_snd_DeathSlow:=asnd_deathSlow;
      uid_snd_DeathFast:=asnd_deathFast;
      uid_snd_Pain     :=asnd_pain;
   end;
   un_eid_snd_set:=true;
end;

procedure setFootSND(footsnd:PTSoundSet;footanim:integer);
begin
   with g_uids[u] do
   begin
      uid_snd_Foot    :=footsnd;
      uid_AnimStepFoot:=footanim;
   end;
end;

procedure setWeaponESND(aa:byte;snd_start,snd_shot:PTSoundSet;eid_start,eid_shot:byte);
begin
   with g_uids[u] do
     if(aa<=LastUnitArms)then
       for aa:=aa to LastUnitArms do
         with uid_arms[aa] do
         begin
            aw_snd_start:=snd_start;
            aw_snd_shot :=snd_shot;
            aw_eid_start:=eid_start;
            aw_eid_shot :=eid_shot;
         end;
end;
procedure setWeaponTEID(aa:byte;asnd_target:PTSoundSet;aeid_target:byte;rld_a:TSoB;eid_target_onstart:boolean=false;
                                                                                   eid_target_onfire :boolean=false;
                                                                                   eid_target_onshot :boolean=false);
begin
   with g_uids[u] do
     if(aa<=LastUnitArms)then
       for aa:=aa to LastUnitArms do
         with uid_arms[aa] do
         begin
            aw_snd_target:=asnd_target;
            aw_eid_target:=aeid_target;
            if(rld_a<>[])then aw_AnimPoints:=rld_a;
            aw_eid_target_onstart:=eid_target_onstart;
            aw_eid_target_onfire :=eid_target_onfire;
            aw_eid_target_onshot :=eid_target_onshot;
         end;
end;
procedure setWeaponESND2(aaset:TSoB;asnd_start,asnd_shot:PTSoundSet;aeid_start,aeid_shot:byte);
var aa:byte;
begin
   with g_uids[u] do
     for aa:=0 to LastUnitArms do
       if(aa in aaset)then
         with uid_arms[aa] do
         begin
            aw_snd_start:=asnd_start;
            aw_snd_shot :=asnd_shot;
            aw_eid_start:=aeid_start;
            aw_eid_shot :=aeid_shot;
         end;
end;
procedure setWeaponTEID2(aaset:TSoB;snd_target:PTSoundSet;eid_target:byte;rld_a:TSoB);
var aa:byte;
begin
   with g_uids[u] do
     for aa:=0 to LastUnitArms do
       if(aa in aaset)then
         with uid_arms[aa] do
         begin
            aw_snd_target:=snd_target;
            aw_eid_target:=eid_target;
            if(rld_a<>[])then aw_AnimPoints:=rld_a;
         end;
end;

////////////////////////////////////////////////////////////////////////////////
begin
   FillChar(ui_panel_uids,SizeOf(ui_panel_uids),0);

   for u:=0 to 255 do
   with g_uids[u] do
   begin
      un_eid_snd_set:=false;
      setMWSModel(0,@spr_dmodel);
      uid_AnimStepWalk :=10;
      uid_AnimStepDeath:=10;

      DefaultRLDA_pa:=3;

      case u of
UID_LostSoul,
UID_Phantom :
begin
   case u of
   UID_LostSoul: setMWSModel(0,@spr_lostsoul);
   UID_Phantom : setMWSModel(0,@spr_phantom );
   end;
   setCommandSND(snd_lost_move,snd_hell_move,snd_lost_move,snd_hell_pain,snd_hell_move);
   setEffectEID (0,0  ,0       ,u       ,0            );
   setEffectSND (  nil,snd_explode_plasma,snd_explode_plasma,snd_hell_pain);
   setWeaponESND(0,nil,snd_lost_move,0,0);
end;
UID_Imp:
begin
   uid_AnimStepWalk :=12;
   uid_AnimStepDeath:=8;
   setMWSModel  (0,@spr_imp);
   setCommandSND(snd_imp_ready,snd_imp_move,snd_imp_ready,snd_zimba_pain  ,snd_imp_move);
   setEffectEID (0,0  ,0            ,EID_InfantryGibs,0             );
   setEffectSND (  nil,snd_imp_death,snd_Gibs        ,snd_zimba_pain);
   setWeaponESND(0,nil,snd_hell_attack,0,0);
   setWeaponESND(1,nil,snd_hell_melee ,0,0);
end;
UID_Demon:
begin
   uid_AnimStepWalk :=15;
   uid_AnimStepDeath:=9;
   setMWSModel  (0,@spr_demon);
   setCommandSND(snd_demon_ready,snd_hell_move,snd_demon_ready,snd_hell_pain,snd_hell_move);
   setEffectEID (0,0  ,0              ,0  ,0            );
   setEffectSND (  nil,snd_demon_death,nil,snd_hell_pain);
   setWeaponESND(0,nil,snd_demon_melee,0,0);
end;
UID_Cacodemon:
begin
   uid_AnimStepDeath:=10;
   setMWSModel  (0,@spr_cacodemon);
   setCommandSND(snd_caco_ready,snd_hell_move,snd_caco_ready,snd_hell_pain,snd_hell_move);
   setEffectEID (0,0,0,0,0);
   setEffectSND (  nil,snd_caco_death ,nil,snd_hell_pain );
   setWeaponESND(0,nil,snd_hell_attack,0,0);
   setWeaponESND(1,nil,snd_hell_melee ,0,0);
end;
UID_Knight:
begin
   uid_AnimStepWalk :=12;
   uid_AnimStepDeath:=10;
   setMWSModel(0,@spr_knight);
   setCommandSND(snd_knight_ready,snd_hell_move,snd_knight_ready,snd_hell_pain,snd_hell_move);
   setEffectEID (0,0,0,0,0);
   setEffectSND (  nil,snd_knight_death ,nil,snd_hell_pain );
   setWeaponESND(0,nil,snd_hell_attack,0,0);
   setWeaponESND(1,nil,snd_hell_melee ,0,0);
end;
UID_Baron:
begin
   uid_AnimStepWalk :=12;
   uid_AnimStepDeath:=10;
   setMWSModel  (0,@spr_baron);
   setCommandSND(snd_baron_ready,snd_hell_move,snd_baron_ready,snd_hell_pain,snd_hell_move);
   setEffectEID (0,0,0,0,0);
   setEffectSND (  nil,snd_baron_death  ,nil,snd_hell_pain );
   setWeaponESND(0,nil,snd_hell_attack,0,0);
   setWeaponESND(1,nil,snd_hell_melee ,0,0);
end;
UID_Cyberdemon:
begin
   uid_AnimStepWalk:=13;
   setMWSModel  (0,@spr_cyberdemon);
   setCommandSND(snd_cyber_ready,snd_hell_move,snd_cyber_ready,snd_hell_pain,snd_hell_move);
   setEffectEID (0,0,0,0,0);
   setEffectSND (  nil,snd_cyber_death,nil,snd_hell_pain );
   setFootSND   (snd_cyber_foot,25);
   setWeaponESND(0,nil,snd_shot_rocket,0,0);
end;
UID_Mastermind:
begin
   uid_AnimStepWalk :=15;
   uid_AnimStepDeath:=16;
   setMWSModel  (0,@spr_mastermind);
   setCommandSND(snd_mastermind_ready,snd_hell_move,snd_mastermind_ready,snd_hell_pain,snd_hell_move);
   setEffectEID (0,0,0,0,0);
   setEffectSND (  nil,snd_mastermind_death,nil,snd_hell_pain );
   setFootSND   (snd_mastermind_foot,18);
   setWeaponESND(0,nil,snd_shot_shotgun,0,0);
end;
UID_Pain:
begin
   uid_AnimStepWalk:=7;
   setMWSModel  (0,@spr_pain);
   setCommandSND(snd_pain_ready,snd_hell_move,snd_hell_move,snd_pain_pain,snd_hell_move);
   setEffectEID (0,0,0,u,0);
   setEffectSND (  nil,snd_pain_death,snd_pain_death,snd_pain_pain );
end;
UID_Revenant:
begin
   uid_AnimStepWalk :=17;
   uid_AnimStepDeath:=9;
   setMWSModel  (0,@spr_revenant);
   setCommandSND(snd_revenant_ready,snd_revenant_move,snd_revenant_ready,snd_zimba_pain,snd_revenant_move);
   setEffectEID (0,0,0,0,0);
   setEffectSND (  nil,snd_revenant_death,nil,snd_zimba_pain);
   setWeaponESND(0,nil,snd_revenant_attack,0,0);
   setWeaponESND(1,nil,snd_revenant_melee ,0,0);
end;
UID_Mancubus:
begin
   uid_AnimStepWalk :=12;
   uid_AnimStepDeath:=13;
   setMWSModel  (0,@spr_mancubus);
   setCommandSND(snd_mancubus_ready,snd_zimba_move,snd_mancubus_ready,snd_mancubus_pain,snd_zimba_move);
   setEffectEID (0,0,0,0,0);
   setEffectSND (  nil,snd_mancubus_death ,nil,snd_mancubus_pain );
   setWeaponESND(0,snd_mancubus_attack,snd_hell_attack,0,0);
end;
UID_Arachnotron:
begin
   uid_AnimStepWalk :=14;
   uid_AnimStepDeath:=13;
   setMWSModel  (0,@spr_arachnotron);
   setCommandSND(snd_arachno_ready,snd_arachno_move,snd_arachno_ready,snd_hell_pain,snd_arachno_move);
   setEffectEID (0,0,0,0,0);
   setEffectSND (  nil,snd_arachno_death,nil,snd_hell_pain );
   setFootSND   (snd_arachno_foot,26);
   setWeaponESND(0,nil,snd_shot_plasma,0,0);
end;
UID_Archvile:
begin
   uid_AnimStepWalk :=17;
   uid_AnimStepDeath:=12;
   setMWSModel  (0,@spr_archvile);
   setCommandSND(snd_archvile_ready,snd_archvile_move,snd_archvile_ready,snd_archvile_pain,snd_archvile_move);
   setEffectEID (0,0,0,0,0);
   setEffectSND (  nil,snd_archvile_death  ,nil,snd_archvile_pain );
   setWeaponESND(0,nil,snd_Gibs,0,0);
   setWeaponTEID(0,nil,0       ,[0..255]);
   setWeaponESND(1,snd_archvile_attack,nil,0,0);
   setWeaponTEID(1,snd_archvile_fire  ,EID_ArchFire,[0..65],true,true,false); //
end;

UID_ZMedic:
begin
   uid_AnimStepWalk :=16;
   uid_AnimStepDeath:=8;
   setCommandSND(snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setMWSModel  (0,@spr_ZFormer);
   setEffectEID (0,0  ,0              ,EID_InfantryGibs,0             );
   setEffectSND (  nil,snd_zimba_death,snd_Gibs ,snd_zimba_pain);
   setWeaponESND(0,nil,snd_Healing,0,0);
   setWeaponESND(1,nil,snd_shot_pistol,0,0);
   with uid_arms[0] do begin aw_eid_target:=MID_YPlasma;aw_eid_target_onshot:=true;end;
end;
UID_ZEngineer:
begin
   uid_AnimStepWalk :=16;
   uid_AnimStepDeath:=8;
   setCommandSND(snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setMWSModel  (0,@spr_ZEngineer);
   setEffectEID (0,0  ,0              ,EID_InfantryGibs,0             );
   setEffectSND (  nil,snd_zimba_death,snd_Gibs ,snd_zimba_pain);
   setWeaponESND(0,nil,snd_repairing,0,0);
   setWeaponESND(1,nil,snd_shot_pistol,0,0);
   with uid_arms[0] do begin aw_eid_target:=MID_BPlasma;aw_eid_target_onshot:=true;end;
end;
UID_ZSergant:
begin
   uid_AnimStepWalk :=17;
   uid_AnimStepDeath:=8;
   setCommandSND(snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (0,0  ,0              ,EID_InfantryGibs,0             );
   setEffectSND (  nil,snd_zimba_death,snd_Gibs ,snd_zimba_pain);
   setMWSModel  (0,@spr_ZShotgunner);
   setWeaponESND(0,nil,snd_shot_shotgun,0,0);
end;
UID_ZSSergant:
begin
   uid_AnimStepWalk :=17;
   uid_AnimStepDeath:=8;
   setCommandSND(snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (0,0  ,0              ,EID_InfantryGibs,0             );
   setEffectSND (  nil,snd_zimba_death,snd_Gibs ,snd_zimba_pain);
   setMWSModel  (0,@spr_ZSSGunner);
   setWeaponESND(0,nil,snd_shot_ssg    ,0,0);
end;
UID_ZCommando:
begin
   uid_AnimStepWalk :=17;
   uid_AnimStepDeath:=8;
   setCommandSND(snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (0,0  ,0              ,EID_InfantryGibs,0             );
   setEffectSND (  nil,snd_zimba_death,snd_Gibs ,snd_zimba_pain);
   setMWSModel  (0,@spr_ZCommando);
   setWeaponESND(0,nil,snd_shot_shotgun,0,0);
end;
UID_ZSiegeMarine:
begin
   uid_AnimStepWalk :=17;
   uid_AnimStepDeath:=8;
   setCommandSND(snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (0,0  ,0              ,EID_InfantryGibs,0             );
   setEffectSND (  nil,snd_zimba_death,snd_Gibs ,snd_zimba_pain);
   setMWSModel  (0,@spr_ZSiege);
   setWeaponESND(0,nil,snd_shot_rocket,0,0);
end;
UID_ZAntiaircrafter:
begin
   uid_AnimStepWalk :=17;
   uid_AnimStepDeath:=8;
   setCommandSND(snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (0,0  ,0              ,EID_InfantryGibs,0             );
   setEffectSND (  nil,snd_zimba_death,snd_Gibs ,snd_zimba_pain);
   setMWSModel  (0,@spr_ZAntiaircrafter);
   setWeaponESND(0,nil,snd_shot_rocket,0,0);
end;
UID_ZFPlasmagunner:
begin
   uid_AnimStepWalk :=14;
   uid_AnimStepDeath:=8;
   setMWSModel  (0,@spr_ZPlasmagunner);
   setCommandSND(snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (0,0  ,EID_Exp,EID_Exp,0  );
   setEffectSND (  snd_JetPackOn,snd_explode,snd_explode,nil);
   setWeaponESND(0    ,nil,snd_shot_plasma,0,0);
   setWeaponTEID(0    ,nil,0,[0..255]);
end;
UID_ZBFGMarine:
begin
   uid_AnimStepWalk :=15;
   uid_AnimStepDeath:=8;
   setCommandSND(snd_zimba_ready,snd_zimba_move,snd_zimba_move,snd_zimba_pain,snd_zimba_move);
   setEffectEID (0,0  ,0              ,EID_InfantryGibs,0             );
   setEffectSND (  nil,snd_zimba_death,snd_Gibs ,snd_zimba_pain);
   setMWSModel  (0,@spr_ZBFG);
   setWeaponESND(0,snd_shot_bfg,nil,0,0);
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
   setMWSModel(0,@spr_HGate1);
   setMWSModel(1,@spr_HGate2);
   setMWSModel(2,@spr_HGate3);
   setMWSModel(3,@spr_HGate4);
   setBuildingSND(snd_hell_hgate);
end;
UID_HSymbol1:
begin
   setMWSModel(0,@spr_HSymbol1);
   setBuildingSND(snd_hell_hsymbol);
end;
UID_HSymbol2:
begin
   setMWSModel(0,@spr_HSymbol2);
   setBuildingSND(snd_hell_hsymbol);
end;
UID_HSymbol3:
begin
   setMWSModel(0,@spr_HSymbol3);
   setBuildingSND(snd_hell_hsymbol);
end;
UID_HSymbol4:
begin
   setMWSModel(0,@spr_HSymbol4);
   setBuildingSND(snd_hell_hsymbol);
end;
UID_HPools:
begin
   setMWSModel(0,@spr_HPools1);
   setMWSModel(1,@spr_HPools2);
   setMWSModel(2,@spr_HPools3);
   setMWSModel(3,@spr_HPools4);
   setBuildingSND(snd_hell_hpool);
end;
UID_HFTower:
begin
   uid_AnimStepWalk:=5;

   setMWSModel(0,@spr_HFTower);
   setBuildingSND(snd_hell_htower);
   setWeaponESND(0,nil,snd_hell_attack    ,0,MID_Imp);
   uid_eid_bcrater_y:=15;
end;
UID_HSTower:
begin
   uid_AnimStepWalk:=5;

   setMWSModel(0,@spr_HSTower);
   setBuildingSND(snd_hell_htower);
   setWeaponESND(0,nil,snd_hell_attack    ,0,MID_Baron);
   uid_eid_bcrater_y:=15;
end;
UID_HTeleport:
begin
   uid_AnimStepWalk:=5;

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
end;
UID_HTotem:
begin
   setMWSModel(0,@spr_HTotem);
   setBuildingSND(snd_hell_htotem);
   uid_eid_bcrater_y:=12;
   setWeaponESND(0,snd_archvile_attack,nil,0,0);
   setWeaponTEID(0,snd_archvile_fire,EID_ArchFire,[0..65],true,true,false ); //
end;
UID_HAltar:
begin
   setMWSModel(0,@spr_HAltar);
   setBuildingSND(snd_hell_haltar);
end;
UID_HFortress:
begin
   setMWSModel(0,@spr_HFortress);
   setBuildingSND(snd_hell_hfort);
end;
UID_HEye:
begin
   setMWSModel(0,@spr_HEye);
   setBuildingSND(snd_hell_eye);
   uid_eid_bcrater:=255;
   setEffectEID(0,0  ,UID_HEye,UID_HEye,0  );
   setEffectSND(  nil,snd_explode_plasma,snd_explode_plasma,nil);
end;
UID_HCommandCenter:
begin
   setMWSModel(0,@spr_HCommandCenter);
   setBuildingSND(snd_hell_hbuild);
   setEffectEID(0,0       ,EID_BBExp           ,EID_BBExp           ,0  );
   setEffectSND(  snd_hell,snd_explode_building,snd_explode_building,nil);
   uid_eid_bcrater_y:=10;
   setWeaponESND(0    ,nil,snd_hell_attack,0,0);
end;
UID_HACommandCenter:
begin
   setMWSModel(0,@spr_HACommandCenter);
   setBuildingSND(snd_hell_hbuild);
   setEffectEID(0,0       ,EID_BBExp           ,EID_BBExp           ,0  );
   setEffectSND(  snd_hell,snd_explode_building,snd_explode_building,nil);
   uid_eid_bcrater_y:=10;
   setWeaponESND(0    ,nil,snd_hell_attack,0,0);
end;
UID_HBarracks:
begin
   setMWSModel(0,@spr_HBarracks1);
   setMWSModel(1,@spr_HBarracks2);
   setMWSModel(2,@spr_HBarracks3);
   setMWSModel(3,@spr_HBarracks4);
   setBuildingSND(snd_hell_hbuild);
   setEffectEID(0,0     ,EID_BBExp           ,EID_BBExp           ,0  );
   setEffectEID(1,0     ,EID_BBExp           ,EID_BBExp           ,0  );
   setEffectSND(snd_hell,snd_explode_building,snd_explode_building,nil);
   uid_eid_bcrater_y:=10;
end;


UID_Engineer:
begin
   uid_AnimStepWalk:=15;
   uid_AnimStepDeath:=8;
   setMWSModel(0,@spr_Engineer);
   setCommandSND(snd_scout_ready   ,snd_scout_move   ,snd_scout_move     ,snd_scout_select  ,snd_scout_select   );
   setEffectEID (0,0  ,0             ,EID_InfantryGibs,0  );
   setEffectSND (  nil,snd_uac_hdeath,snd_Gibs ,nil);
   setWeaponESND(0,nil,snd_repairing,0,0);
   setWeaponESND(1,nil,snd_shot_pistol ,0,0);
   with uid_arms[0] do begin aw_eid_target:=MID_BPlasma;aw_eid_target_onshot:=true;end;
end;
UID_Medic:
begin
   uid_AnimStepWalk:=15;
   uid_AnimStepDeath:=8;
   setMWSModel(0,@spr_Medic);
   setCommandSND(snd_medic_ready,snd_medic_move,snd_medic_move,snd_medic_annoy,snd_medic_select);
   setEffectEID (0,0  ,0             ,EID_InfantryGibs,0  );
   setEffectSND (  nil,snd_uac_hdeath,snd_Gibs ,nil);
   setWeaponESND(0,nil,snd_Healing,0,0);
   setWeaponESND(1,nil,snd_shot_pistol,0,0);
   with uid_arms[0] do begin aw_eid_target:=MID_YPlasma;aw_eid_target_onshot:=true;end;
end;
UID_Sergant:
begin
   uid_AnimStepWalk:=17;
   uid_AnimStepDeath:=8;
   setMWSModel(0,@spr_Shotgunner);
   setCommandSND(snd_shotgunner_ready,snd_shotgunner_move,snd_shotgunner_attack,snd_shotgunner_annoy,snd_shotgunner_select);
   setEffectEID (0,0  ,0             ,EID_InfantryGibs,0  );
   setEffectSND (  nil,snd_uac_hdeath,snd_Gibs ,nil);
   setWeaponESND(0,nil,snd_shot_shotgun ,0,0);
end;
UID_SSergant:
begin
   uid_AnimStepWalk:=17;
   uid_AnimStepDeath:=8;
   setMWSModel(0,@spr_SSGunner);
   setCommandSND(snd_ssg_ready       ,snd_ssg_move       ,snd_ssg_attack       ,snd_ssg_annoy       ,snd_ssg_select       );
   setEffectEID (0,0  ,0             ,EID_InfantryGibs,0  );
   setEffectSND (  nil,snd_uac_hdeath,snd_Gibs ,nil);
   setWeaponESND(0,nil,snd_shot_ssg    ,0,0);
end;
UID_Commando:
begin
   uid_AnimStepWalk:=16;
   uid_AnimStepDeath:=8;
   setMWSModel(0,@spr_Commando);
   setCommandSND(snd_commando_ready,snd_commando_move,snd_commando_attack,snd_commando_annoy,snd_commando_select);
   setEffectEID (0,0  ,0             ,EID_InfantryGibs,0  );
   setEffectSND (  nil,snd_uac_hdeath,snd_Gibs ,nil);
   setWeaponESND(0,nil,snd_shot_pistol,0,0);
end;
UID_SiegeMarine:
begin
   uid_AnimStepWalk:=15;
   uid_AnimStepDeath:=8;
   setMWSModel(0,@spr_Siege);
   setCommandSND(snd_rocketmarine_ready,snd_rocketmarine_move,snd_rocketmarine_attack,snd_rocketmarine_annoy,snd_rocketmarine_select);
   setEffectEID (0,0  ,0             ,EID_InfantryGibs,0  );
   setEffectSND (  nil,snd_uac_hdeath,snd_Gibs ,nil);
   setWeaponESND(0,nil,snd_shot_rocket,0,0);
end;
UID_Antiaircrafter:
begin
   uid_AnimStepWalk:=16;
   uid_AnimStepDeath:=8;
   setMWSModel(0,@spr_Antiaircrafter);
   setCommandSND(snd_engineer_ready,snd_engineer_move,snd_engineer_attack,snd_engineer_annoy,snd_engineer_select);
   setEffectEID (0,0  ,0             ,EID_InfantryGibs,0  );
   setEffectSND (  nil,snd_uac_hdeath,snd_Gibs ,nil);
   setWeaponESND(0,nil,snd_shot_rocket,0,0);
end;
UID_FPlasmagunner:
begin
   uid_AnimStepDeath:=8;
   setMWSModel(0,@spr_Plasmagunner);
   setCommandSND(snd_plasmamarine_ready,snd_plasmamarine_move,snd_plasmamarine_attack,snd_plasmamarine_annoy,snd_plasmamarine_select);
   setEffectEID (0,0         ,EID_Exp,EID_Exp,0  );
   setEffectSND (  snd_JetPackOn,snd_explode,snd_explode,nil);
   setWeaponESND(0    ,nil,snd_shot_plasma,0,0);
   //setWeaponTEID(0    ,nil,0,[0..255]);
end;
UID_BFGMarine:
begin
   uid_AnimStepWalk:=14;
   uid_AnimStepDeath:=8;
   setMWSModel(0,@spr_BFG);
   setCommandSND(snd_bfgmarine_ready,snd_bfgmarine_move,snd_bfgmarine_attack,snd_bfgmarine_annoy,snd_bfgmarine_select);
   setEffectEID (0,0  ,0             ,EID_InfantryGibs,0  );
   setEffectSND (  nil,snd_uac_hdeath,snd_Gibs ,nil);
   setWeaponESND(0,snd_shot_bfg,nil,0,0);
   setWeaponTEID(0,nil,0,[fr_fps1-10..255]);
end;
UID_UTransport:
begin
   setMWSModel(0,@spr_Transport);
   setMWSModel(1,@spr_ATransport);
   setCommandSND(snd_transport_ready,snd_transport_move,snd_transport_move,snd_transport_annoy,snd_transport_select);
   setEffectEID (0,0  ,EID_BExp,EID_BExp,0  );
   setEffectSND (  nil,snd_explode ,snd_explode ,nil);
end;
UID_UACDron:
begin
   setMWSModel(0,@spr_UACDron);
   setCommandSND(snd_uacbot_move,snd_uacbot_move,snd_uacbot_attack,snd_uacbot_annoy,snd_uacbot_select);
   setEffectEID (0,0  ,EID_Exp2,EID_Exp2,0  );
   setEffectSND (  nil,snd_explode ,snd_explode ,nil);
   setWeaponESND(0    ,nil,snd_shot_plasma,0,0);
   uid_eid_bcrater:=UID_UGturret;
   uid_eid_BuildHellType:=true;
end;
UID_Terminator:
begin
   uid_AnimStepWalk:=15;
   setMWSModel(0,@spr_Terminator);
   setCommandSND(snd_terminator_ready,snd_terminator_move,snd_terminator_attack,snd_terminator_annoy,snd_terminator_select);
   setEffectEID (0,0  ,EID_Exp2,EID_Exp2,0  );
   setEffectSND (  nil,snd_explode ,snd_explode ,nil);

   setWeaponESND(0,nil,snd_shot_shotgun,0,0);
   setWeaponESND(1,nil,snd_revenant_attack,0,0);

   setWeaponTEID(0,nil,0,[0..255]);
   with uid_arms[1] do
   begin
      aw_AnimStay:=sms_mattack;
      aw_AnimPoints:=[];
   end;

   DefaultRLDA_pa:=2;
end;
UID_Tank:
begin
   uid_AnimStepWalk:=15;
   setMWSModel(0,@spr_Tank);
   setCommandSND(snd_tank_ready,snd_tank_move,snd_tank_attack,snd_tank_annoy,snd_tank_select);
   setEffectEID (0,0  ,EID_BExp,EID_BExp,0  );
   setEffectSND (  nil,snd_explode ,snd_explode ,nil);
   setWeaponESND(0    ,nil,snd_explode,0,0);
   setWeaponTEID(0    ,nil,0,[fr_fps1..255]);
end;
UID_Flyer:
begin
   setMWSModel(0,@spr_Flyer);
   setCommandSND(snd_uacfighter_ready,snd_uacfighter_move,snd_uacfighter_attack,snd_uacfighter_annoy,snd_uacfighter_select);
   setEffectEID (0,0  ,EID_Exp2,EID_Exp2,0  );
   setEffectSND (nil,snd_explode ,snd_explode ,nil);
   setWeaponESND(0  ,nil,snd_shot_flyer,0,0);
end;


UID_UCommandCenter:
begin
   setMWSModel(0,@spr_UCommandCenter);
   setBuildingSND(snd_uac_cc);
   setWeaponESND(0    ,nil,snd_shot_plasma,0,0);
end;
UID_UACommandCenter:
begin
   setMWSModel(0,@spr_UACommandCenter);
   setBuildingSND(snd_uac_cc);
   setWeaponESND(0    ,nil,snd_shot_plasma,0,0);
end;
UID_UBarracks:
begin
   setMWSModel(0,@spr_UBarracks1);
   setMWSModel(1,@spr_UBarracks2);
   setMWSModel(2,@spr_UBarracks3);
   setMWSModel(3,@spr_UBarracks4);
   setBuildingSND(snd_uac_barracks);
end;
UID_UFactory:
begin
   setMWSModel(0,@spr_UFactory1 );
   setMWSModel(1,@spr_UFactory2);
   setMWSModel(2,@spr_UFactory3);
   setMWSModel(3,@spr_UFactory4);
   setBuildingSND(snd_uac_factory);
end;
UID_UGenerator1:
begin
   setMWSModel(0,@spr_UGenerator1);
   setBuildingSND(snd_uac_generator);
end;
UID_UGenerator2:
begin
   setMWSModel(0,@spr_UGenerator2);
   setBuildingSND(snd_uac_suply);
end;
UID_UGenerator3:
begin
   setMWSModel(0,@spr_UGenerator3);
   setBuildingSND(snd_uac_suply);
end;
UID_UGenerator4:
begin
   setMWSModel(0,@spr_UGenerator4);
   setBuildingSND(snd_uac_suply);
end;
UID_UWeaponFactory:
begin
   setMWSModel(0,@spr_UWeaponFactory1); //@
   setMWSModel(1,@spr_UWeaponFactory2);
   setMWSModel(2,@spr_UWeaponFactory3);
   setMWSModel(3,@spr_UWeaponFactory4);
   setBuildingSND(snd_uac_forge);
end;
UID_UTechCenter:
begin
   setMWSModel(0,@spr_UTechCenter);
   setBuildingSND(snd_uac_tech);
end;
UID_UGTurret:
begin
   uid_AnimStepWalk    := 6;
   setMWSModel(0,@spr_UTurret);
   setMWSModel(1,@spr_UPTurret);
   setBuildingSND(snd_uac_ctower);
   uid_eid_bcrater_y:=1;
   setWeaponESND(0,nil,snd_shot_plasma ,0,0);
   setWeaponESND(1,nil,snd_shot_shotgun,0,0);
end;
UID_UATurret:
begin
   uid_AnimStepWalk    := 2;

   setMWSModel(0,@spr_URTurret);
   setBuildingSND(snd_uac_rtower);
   setWeaponESND(0,nil,snd_shot_rocket,0,0);
   uid_eid_bcrater_y:=1;
end;

// SPECIAL
UID_URadar:
begin
   setMWSModel(0,@spr_URadar);
   setBuildingSND(snd_uac_radar);
end;
UID_UAcademy:
begin
   setMWSModel(0,@spr_UAcademy);
   setBuildingSND(snd_uac_academy);
end;
UID_UHPowerConductor:
begin
   setMWSModel(0,@spr_UHPowerConductor);
   setBuildingSND(snd_uac_rescc);
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

UID_UBaseMil:
begin
   setMWSModel(0,@spr_ubase0);
   setBuildingSND(snd_uac_cc);
end;
UID_UBaseCom:
begin
   setMWSModel(0,@spr_ubase1);
   setBuildingSND(snd_uac_cc);
end;
UID_UBaseGen:
begin
   setMWSModel(0,@spr_ubase2);
   setBuildingSND(snd_uac_generator);
end;
UID_UBaseRef:
begin
   setMWSModel(0,@spr_ubase3);
   setBuildingSND(snd_uac_cc);
end;
UID_UBaseNuc:
begin
   setMWSModel(0,@spr_ubase4);
   setBuildingSND(snd_uac_cc);
end;
UID_UBaseLab:
begin
   setMWSModel(0,@spr_ubase5);
   setBuildingSND(snd_uac_cc);
end;

UID_UCBuild0:
begin
   setMWSModel(0,@spr_ubuild0);
   setBuildingSND(snd_uac_suply);
end;
UID_UCBuild1:
begin
   setMWSModel(0,@spr_ubuild1);
   setBuildingSND(snd_uac_suply);
end;
UID_UCBuild2:
begin
   setMWSModel(0,@spr_ubuild2);
   setBuildingSND(snd_uac_suply);
end;
UID_UCBuild3:
begin
   setMWSModel(0,@spr_ubuild3);
   setBuildingSND(snd_uac_suply);
end;
UID_USPort  :
begin
   setMWSModel(0,@spr_starport);
   setBuildingSND(snd_uac_rls);
end;
UID_UPortal :
begin
   setMWSModel(0,@spr_portal);
   setBuildingSND(snd_uac_rescc);
end;

      end;

      if(uid_uibtn<=ui_ButtonsNum)then
        if  (ui_panel_uids[uid_race,byte(not uid_isbuilding),uid_uibtn] =0)
        then ui_panel_uids[uid_race,byte(not uid_isbuilding),uid_uibtn]:=u;

      if(uid_isbuilding)then
      begin
         if(uid_eid_bcrater=0)then
           case uid_race of
           r_hell: begin
                      if(uid_r>42)
                      then uid_eid_bcrater:=EID_db_h0
                      else uid_eid_bcrater:=EID_db_h1;
                      uid_eid_BuildHellType:=true;
                   end;
           r_uac : begin
                      if(uid_r<20)
                      then uid_eid_bcrater:=u
                      else
                        if(uid_r>42)
                        then uid_eid_bcrater:=EID_db_u0
                        else uid_eid_bcrater:=EID_db_u1;
                   end;
           end;
         if(not un_eid_snd_set)then
           if(uid_r>42)then
           begin
              setEffectEID(0,0  ,EID_BBExp           ,EID_BBExp           ,0  );
              setEffectSND(  nil,snd_explode_building,snd_explode_building,nil);
              if(uid_eid_bcrater_y=0)then uid_eid_bcrater_y:=10;
           end
           else
           begin
              setEffectEID(0,0  ,EID_BExp            ,EID_BExp            ,0  );
              setEffectSND(  nil,snd_explode_building,snd_explode_building,nil);
              if(uid_eid_bcrater_y=0)then uid_eid_bcrater_y:=5;
           end;
         if(uid_snd_ready=nil)then uid_snd_ready:=snd_constr_complete[uid_race];
      end;

      for w:=0 to LastUnitArms do
        with uid_arms[w] do
          if(aw_AnimPoints=[])then CalcDefaultArmsAnimPoints(@aw_AnimPoints,@aw_ShotPoints,DefaultRLDA_pa);

      uid_FogcR:=(uid_r div fog_cw)+1;
      if(uid_FogcR<1)then uid_FogcR:=1;
   end;

   u:=UID_HCommandCenter;  setEffectEID2(0,gfx_uid2spr(UID_UCommandCenter  ,0,0));
   u:=UID_HACommandCenter; setEffectEID2(0,gfx_uid2spr(UID_UACommandCenter ,0,0));
   u:=UID_HBarracks;       setEffectEID2(0,gfx_uid2spr(UID_UBarracks       ,0,0));
                           setEffectEID2(1,gfx_uid2spr(UID_UBarracks       ,0,1));

   // ui panel
   for r:=1 to r_count do
   begin
      i:=0;
      for u:=0 to 255 do
        with g_upgrs[u] do
          if(upgr_race=r)then
          begin
             ui_panel_uids[r,2,upgr_btni]:=u;
             i+=1;
             if(i>ui_ButtonsNum)then break;
          end;
   end;

   // upgrades
   for u:=0 to 255 do
     with g_upgrs[u] do
     begin
        upgr_btn:=spr_dummy;

        case u of
upgr_hell_DistDamage1   : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,0 ]; end;
upgr_hell_UnitArmor     : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,1 ]; end;
upgr_hell_BuildArmor    : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,2 ]; end;
upgr_hell_MeleeDamage   : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,3 ]; end;
upgr_hell_Regeneration  : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,4 ]; end;
upgr_hell_PainFactor    : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,5 ]; end;
upgr_hell_BuilderR      : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,11]; end;
upgr_hell_HKeepShift    : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,9 ]; end;
upgr_hell_DecayAura     : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,10]; end;
upgr_hell_TowerR        : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,7 ]; end;
upgr_hell_Spectre       : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,19]; end;
upgr_hell_UnitSightR    : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,13]; end;
upgr_hell_Phantoms      : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,15]; end;
upgr_hell_DistDamage2   : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,20]; end;
upgr_hell_Resurrect     : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,12]; end;
upgr_hell_TeleportCD    : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,8 ]; end;
upgr_hell_T2TNoCD       : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,14]; end;
upgr_hell_EvilEyeR      : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,6 ]; end;
upgr_hell_TotemInvis    : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,16]; end;
upgr_hell_BuildRestore  : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,17]; end;
upgr_hell_TowerBlink    : begin upgr_btn:=spr_uibtn_Upgrades[r_hell,18]; end;

upgr_uac_DistDamage     : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,0 ]; end;
upgr_uac_BioArmor       : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,1 ]; end;
upgr_uac_BuildArmor     : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,2 ]; end;
upgr_uac_RepairTools    : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,3 ]; end;
upgr_uac_BioSpeed       : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,4 ]; end;
upgr_uac_SSMWeapon      : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,14]; end;
upgr_uac_BuilderR       : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,11]; end;
upgr_uac_CCFly          : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,9 ]; end;
upgr_uac_CCAttack       : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,10]; end;
upgr_uac_TowerR         : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,7 ]; end;
upgr_uac_DronTurret     : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,20]; end;
upgr_uac_UnitSightR     : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,12]; end;
upgr_uac_CommandoInvis  : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,19]; end;
upgr_uac_AASplash       : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,13]; end;
upgr_uac_MechSpeed      : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,15]; end;
upgr_uac_MechArmor      : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,16]; end;
upgr_uac_TerAAWeapon    : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,17]; end;
upgr_uac_Transport      : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,6 ]; end;
upgr_uac_RadarR         : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,8 ]; end;
upgr_uac_TurretPlasma   : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,5 ]; end;
upgr_uac_TurretArmor    : begin upgr_btn:=spr_uibtn_Upgrades[r_uac ,18]; end;


        end;
     end;
end;

procedure InitClientDataAbilities;
var a:byte;
begin

   for a:=0 to 255 do
   with g_aids[a] do
   begin
      ua_btn        := spr_empty;
      ua_mbrush_r   := 0; // 0..*** - value, -255..-1 - r of UID, -256 - 'caster itself', '-257' - next form of caster
      ua_mbrush_hint:= 0;

      case a of
uab_Teleport         : ua_btn     :=spr_uibtn_Upgrades[r_hell,8 ].surf;
uab_Recall           : ua_btn     :=spr_uibtn_Upgrades[r_hell,14].surf;
uab_UACScan          : begin
                       ua_btn     :=spr_uibtn_AbilityUACScan;
                       ua_mbrush_r:=uambt_SightR;
                       end;
uab_UACStrike        : begin
                       ua_btn     :=spr_uibtn_AbilityUACStrike;
                       ua_mbrush_r:=uambt_Blizzard;
                       end;
uab_HellCCLand,
uab_UACCCLand        : begin
                       ua_btn     :=spr_uibtn_AbilityCCLand;
                       ua_mbrush_r:=uambt_Self;
                       end;
uab_HellCCLandTo,
uab_UACCCLandTo      : begin
                       ua_btn     :=spr_uibtn_AbilityCCLandTo;
                       ua_mbrush_r:=uambt_Self;
                       end;
uab_HEyeVision       : ua_btn     :=spr_uibtn_AbilityHVision;
uab_HEyeBlink        : begin
                       ua_btn     :=spr_uibtn_AbilityBlink;
                       ua_mbrush_r:=uambt_Self;
                       end;
uab_HTowerBlink      : begin
                       ua_btn     :=spr_uibtn_Upgrades[r_hell,18].surf;
                       ua_mbrush_r:=uambt_Self;
                       end;

uab_HKeepShift       : begin
                       ua_btn     :=spr_uibtn_Upgrades[r_hell,9 ].surf;
                       ua_mbrush_r:=uambt_Self;
                       end;
uab_HKeepAura        : ua_btn     :=spr_uibtn_Upgrades[r_hell,10].surf;

uab_SphereSoul       : ua_btn     :=spr_uibtn_AbilitySSoul;
uab_SphereInvis      : ua_btn     :=spr_uibtn_AbilitySInvis;
uab_SphereInvuln     : ua_btn     :=spr_uibtn_AbilitySInvuln;
uab_SphereRDamage    : ua_btn     :=spr_uibtn_AbilitySRDamage;
uab_SphereDDamage    : ua_btn     :=spr_uibtn_AbilitySDDamage;
uab_SphereTurbo      : ua_btn     :=spr_uibtn_AbilitySTurbo;

uab_PretorEquip      : ua_btn     :=spr_uibtn_AbilityPretEquip;
uab_Bribe            : ua_btn     :=spr_uibtn_AbilityBribe;
uab_Hack             : ua_btn     :=spr_uibtn_AbilityHack;

uab_SpawnLost        : ua_btn     :=spr_uibtn_AbilitySpawnLost;
uab_SpawnLostTo      : ua_btn     :=spr_uibtn_AbilitySpawnLostTo;

uab_Unload           : ua_btn     :=spr_uibtn_AbilityUnload;
uab_UnloadTo         : ua_btn     :=spr_uibtn_AbilityUnloadTo;

uab_ToUACDron        : ua_mbrush_r:=-UID_UACDron;
uab_ToUGTurretTo     : ua_mbrush_r:=-UID_UGTurret;
uab_ToUATurretTo     : ua_mbrush_r:=-UID_UATurret;

uab_ToHAKeep         : ua_mbrush_r:=-UID_HAKeep;
uab_ToHSymbol2       : ua_mbrush_r:=-UID_HSymbol2;
uab_ToHSymbol3       : ua_mbrush_r:=-UID_HSymbol3;
uab_ToHSymbol4       : ua_mbrush_r:=-UID_HSymbol4;
uab_ToHACommandCenter: ua_mbrush_r:=-UID_HACommandCenter;
uab_ToHFTower        : ua_mbrush_r:=-UID_HFTower;
uab_ToHSTower        : ua_mbrush_r:=-UID_HSTower;

uab_ToHGate          : ua_mbrush_r:=-UID_HGate;
uab_ToHPool          : ua_mbrush_r:=-UID_HPools;
uab_ToHBarracks      : ua_mbrush_r:=-UID_HBarracks;
uab_ToHTotem         : ua_mbrush_r:=-UID_HTotem;

uab_ToUACommandCenter: ua_mbrush_r:=-UID_UACommandCenter;
uab_ToUGenerator2    : ua_mbrush_r:=-UID_UGenerator2;
uab_ToUGenerator3    : ua_mbrush_r:=-UID_UGenerator3;
uab_ToUGenerator4    : ua_mbrush_r:=-UID_UGenerator4;
uab_ToUAGTurret      : ua_mbrush_r:=-UID_UGTurret;
uab_ToUAATurret      : ua_mbrush_r:=-UID_UATurret;

uab_ToUBarracks      : ua_mbrush_r:=-UID_UBarracks;
uab_ToUFactory       : ua_mbrush_r:=-UID_UFactory;
uab_ToUWeaponFactory : ua_mbrush_r:=-UID_UWeaponFactory;

uab_URadarLvlUp      : ua_mbrush_r:=-UID_URadar;
uab_URMStationLvlUp  : ua_mbrush_r:=-UID_URMStation;
      end;

      case a of
uab_ToUACDron,
uab_ToUGTurretTo,
uab_ToUATurretTo,
uab_ToHAKeep,
uab_ToHSymbol2,
uab_ToHSymbol3,
uab_ToHSymbol4,
uab_ToHACommandCenter,
uab_ToHFTower,
uab_ToHSTower,
uab_ToHGate,
uab_ToHPool,
uab_ToHBarracks,
uab_ToHTotem,
uab_ToUACommandCenter,
uab_ToUGenerator2,
uab_ToUGenerator3,
uab_ToUGenerator4,
uab_ToUAGTurret,
uab_ToUAATurret,
uab_ToUBarracks,
uab_ToUFactory,
uab_ToUWeaponFactory : ua_mbrush_hint:=byte(-ua_mbrush_r);
      end;

      case a of
uab_ToUAGTurret,
uab_ToUAATurret,
uab_ToUACDron,
uab_ToUGTurretTo,
uab_ToUATurretTo,
uab_ToHTotem,
uab_ToHFTower,
uab_ToHSTower        : ua_mbrush_hint_HalfProdTime:=true;
      end;

      if(ua_btn=spr_empty)then
        case ua_mbrush_r of
        -255..-1 : ua_btn:=g_uids[-ua_mbrush_r].uid_BTNBig.surf;
        end;
   end;
end;




