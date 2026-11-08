const

camp_MaxNMAIUpgrades = 16;

camp_AutoSavePrefix  = 'CampaignAutoSave_';


procedure camp_Init;
begin
   camp_data.cd_lastm:=5;

   // CAMPAINGS
   str_camp_clear;

   str_camp_Add('1');

   str_camp_MisAdd(0,'1');
   str_camp_MisAdd(0,'2');
   str_camp_MisAdd(0,'3');
   str_camp_MisAdd(0,'4');
   str_camp_MisAdd(0,'5');
end;

procedure camp_UnitsUpdateMiniMapXY;
var u:integer;
begin
   for u:=1 to MaxUnits do
   begin
      unit_UpdateMiniMapXY(g_punits[u]);
      with g_units[u] do
        mapZone:=map_GetZone(x,y);
   end;
end;

procedure camp_Win;
begin
   if(not game_IsEnded)then
   begin
      with camp_data do
        {if(camp_data.cd_lastm<camp_mis_sel)
        then cd_lastm:=camp_mis_sel+1
        else}
          if(camp_data.cd_lastm=(camp_mis_sel+1))
          then cd_lastm+=1;

      game_SetStatusWinnerTeam(g_PlayersGame[LocalPlayer].team);
      saveload_SaveWrite(camp_AutoSavePrefix+str_DateTime);
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    PLAYER START
//

procedure camp_ClearPStarts;
var p:byte;
begin
   for p:=0 to LastPlayer do
   begin
      map_PlayerStartX[p]:=-5000;
      map_PlayerStartY[p]:=-5000;
   end;
end;
procedure camp_SetPStart(p:byte;px,py:integer);
begin
   map_PlayerStartX[p]:=px;
   map_PlayerStartY[p]:=py;
end;
procedure camp_SetPStartMirror(pTo,pFrom:byte);
begin
   map_PlayerStartX[pTo]:=map_Size1-map_PlayerStartX[pFrom];
   map_PlayerStartY[pTo]:=map_Size1-map_PlayerStartY[pFrom];
end;
{procedure camp_SetPStartBetweenP(pTo,pFrom1,pFrom2:byte);
begin
   map_PlayerStartX[pTo]:=(map_PlayerStartX[pFrom1]+map_PlayerStartX[pFrom2]) div 2;
   map_PlayerStartY[pTo]:=(map_PlayerStartY[pFrom1]+map_PlayerStartY[pFrom2]) div 2;
end;

procedure camp_FillPStartsCircle(pstart,pnum:byte;cx,cy,cr,cd:integer);
var p:byte;
dstep,
ddir :integer;
begin
   if(pnum<1)or(pnum>LastPlayer)then exit;

   dstep:=round(360/pnum);
   ddir :=cd;

   for p:=1 to pnum do
   begin
      map_PlayerStartX[pstart]:=cx+round(cr*cos(ddir*DEGTORAD));
      map_PlayerStartY[pstart]:=cy+round(cr*sin(ddir*DEGTORAD));
      ddir  +=dstep;
      pstart+=1;
      if(pstart>LastPlayer)then break;
   end;
end; }
////////////////////////////////////////////////////////////////////////////////
//
//    PLAYER PROPERTY
//

procedure camp_SetPlayer(ap,arace,ateam,atype:byte;pname:shortstring);
begin
   with g_PlayersGame[ap] do
   begin
      state     :=atype;
      race      :=arace;
      team      :=ateam;
      isdefeated:=false;
      isobserver:=false;
      name      :=pname;
   end;
end;

procedure camp_SetBaseLevelUnitUpgrades(ap,level:byte);
var
armor,
attack:byte;
procedure UpgrSet(pb:pbyte;lvl:byte);
begin
   if (pb^<lvl)
   and(pb^< camp_MaxNMAIUpgrades)
   and(lvl<=camp_MaxNMAIUpgrades)then
   begin
      game_ScoresAddC(ap,psc_upgrades_level,lvl-pb^);
      pb^:=lvl;
   end;
end;
begin
   armor :=level div 2;
   attack:=level-armor;
   with g_PlayersGame[ap] do
     case race of
     r_hell: begin
                UpgrSet(@upgrs_cur[upgr_hell_DistDamage1],attack);
                UpgrSet(@upgrs_cur[upgr_hell_DistDamage2],attack);
                UpgrSet(@upgrs_cur[upgr_hell_MeleeDamage],attack);
                UpgrSet(@upgrs_cur[upgr_hell_UnitArmor  ],armor );
             end;
     r_uac : begin
                UpgrSet(@upgrs_cur[upgr_uac_DistDamage  ],attack);
                UpgrSet(@upgrs_cur[upgr_uac_BioArmor    ],armor );
                UpgrSet(@upgrs_cur[upgr_uac_MechArmor   ],armor );
             end;
     end;
end;

function camp_AllowUnitsForPlayer(ap:byte;uids:TSoB):boolean;
var
i    :byte;
added:shortstring;
begin
   camp_AllowUnitsForPlayer:=false;

   added:='';
   with g_PlayersGame[ap] do
     for i in uids do
       if(units_uid_m[i]<=0)then STRADD(@added,g_uids[i].uid_str_name,sep_comma);

   if(length(added)=0)then exit;

   camp_AllowUnitsForPlayer:=true;

   player_SetAllowedUnits(ap,uids, MaxUnits,false);

   ui_SysMassageAdd(str_Camp_NewUnits+added,50,fr_fps10*3);
   snd_SoundPlayUI(snd_chat);
end;

procedure camp_NightmareLvlUp(level:byte);
var p:byte;
begin
   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
       if(team<>g_PlayersGame[LocalPlayer].team)
       and(armylimit>0)then
         camp_SetBaseLevelUnitUpgrades(p,level);
end;

{procedure camp_AIFlagDel(ap:byte;flag:cardinal);
begin
   with g_PlayersGame[ap] do
     if((aip_flags and flag)>0)then aip_flags:=aip_flags xor flag;
end;
procedure camp_AIFlagSel(ap:byte;flag:cardinal);
begin
   with g_PlayersGame[ap] do aip_flags:=aip_flags or flag;
end; }

procedure camp_SetAI(ap,alevel_build,
                        alevel_res,
                        alevel_upgr,
                        alevel_attack,
                        alevel_magic :byte;attackDelay,attackPause:integer;aiflags:cardinal);
begin
   // ITYTD NTR HMP UV NM
   with g_PlayersGame[ap] do
   begin
      aip_skill:=5;
      aip_flags:=aiflags;

      if(alevel_build >3)then alevel_build :=3; // UV = NM
      if(alevel_res   >3)then alevel_res   :=3;
      if(alevel_upgr  >3)then alevel_upgr  :=3;
      if(alevel_attack>3)then alevel_attack:=3;
      if(alevel_magic >3)then alevel_magic :=3;

      ai_SetBaseOpt(ap,
                    1000+alevel_build*2000,    // energy
                    1+alevel_build*2,          // builders
                    3+alevel_build*6,          // barracks
                    1+alevel_build  ,          // forges
                    2+alevel_build*3,          // detectors
                    min2i(2+alevel_build*8,12),// min towers
                    min2i(8+alevel_build*8,12),// max towers
                    alevel_build    ,          // max super
                    5+15*alevel_attack,        // attack limit
                    20+alevel_build*20,        // max army limit
                    0               ,          // attack pause
                    90 -(alevel_magic*30),     // detection pause
                    90 -(alevel_magic*30),     // magic pause
                    120-(alevel_magic*30));    // super pause

      case alevel_res of
      2: begin // HMP
            res_energyl_cur:=3000;
            res_energyl_max:=3000;
         end;
      3: begin // UV,NM
            res_energyl_cur:=5000;
            res_energyl_max:=5000;
            upgrs_cur[upgr_fprod_build]:=1;
            upgrs_cur[upgr_fprod_upgr ]:=1;
         end;
      end;

      aip_MaxUpgradeLevel:=alevel_upgr*2;

      case attackPause of
      -1 : aip_pause_attack:=-fr_fps1*max2i(1,180-45*alevel_attack); // 45 90 135 180
      1..attackPause.MaxValue
         : aip_pause_attack:=-fr_fps1*attackPause;
      end;

      aip_delay_attack:=0;
      if(attackDelay>=0)then aip_delay_attack:= fr_fps1*attackDelay;
   end;
end;

procedure camp_CreateUnit(playeri:byte;ux,uy:integer;uuid:byte;initVisionTime:integer=0);
begin
   unit_add(ux,uy,0,uuid,playeri,true,false,0);
   if(LastCreatedUnit>0)then
     with LastCreatedUnitP^ do
     begin
        TeamVision[g_PlayersGame[LocalPlayer].team]:=fr_fps1*initVisionTime;
        dir:=g_random(360);
     end;
end;

procedure camp_CreateUnitAreaR(playeri:byte;un,ux,uy,ur:integer;uuid:byte;initVisionTime:integer=0);
begin
   while(un>0)do
   begin
      camp_CreateUnit(playeri,ux-g_randomr(ur),uy-g_randomr(ur),uuid,initVisionTime);
      un-=1;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   MISSIONS START
//

procedure cmp_StartMission;
var
p      : byte;
tx,ty,
td,tu  : integer;
aiflags: cardinal;
begin
   game_DefaultAll;
   g_FixedPositions:=true;
   g_NewObservers  :=false;
   with camp_data do
   begin
      cd_camp_skill:=camp_diff;
      if(cd_camp_skill>3)then cd_camp_skill:=3;
   end;

   with camp_data do
   case camp_sel of
   0 : begin  ////  HELL vs HELL
          cd_p_player:=0;
          LocalPlayer:=cd_p_player;
          UIPlayer   :=cd_p_player;
          case camp_mis_sel of
          0 : begin ////////////////////   HELL vs HELL #1    ////////////////////////////////////////////////////////////////////////////
                 cd_lastm :=1; // first mission of camp
                 cd_NMTime:=fr_fps1*40;

                 map_Seed         :=777;
                 map_scenario     :=mc_1x1;
                 map_GeneratorT   :=4;
                 map_Size1        :=4000;
                 map_Template     :=mapt_cave;
                 map_Symmetry     :=maps_none;
                 map_MaxPlayers   :=2;
                 map_GenOnObstacle:=false;
                 map_ObstaclesGap :=100;

                 map_Seed2RandomBase;
                 camp_ClearPStarts;

                 cd_p_enemy1:=7;

                 // PLAYER
                 p:=cd_p_player;
                 camp_SetPlayer(p,r_hell,0,ps_human,PlayerName);

                 camp_SetPStart(p,map_Size1 div 4,map_Size1 div 3);

                 camp_CreateUnit(p,map_PlayerStartX[p]    ,map_PlayerStartY[p]    ,UID_HKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]-80 ,map_PlayerStartY[p]-100,UID_HGate);

                 player_SetAllowedUnits   (p,[ UID_HGate,
                                               UID_Imp     ], MaxUnits,true);
                 player_SetAllowedUpgrades(p,[ 0..255      ], 0       ,true);

                 with g_PlayersGame[p] do a_ability:=[];

                 //  Clan of Bites
                 p:=cd_p_enemy1;

                 camp_SetPStartMirror(p,cd_p_player);

                 camp_SetPlayer(p,r_hell,1,ps_AI   ,str_Camp_HE_CoB);

                 aiflags:=aif_base_smart_order+
                          aif_base_DefendOwn+
                          aif_army_scout+
                          aif_cheat_VisBuildings;
                 if(cd_camp_skill>=2)then aiflags+= aif_army_scoutAggr;

                 camp_SetAI(p,cd_camp_skill,
                              cd_camp_skill,
                              cd_camp_skill,
                              cd_camp_skill,
                              cd_camp_skill,210,-1,aiflags);
                 with g_PlayersGame[p] do
                 begin
                    aip_MaxUnitLimit  :=ul10*4;
                    aip_MaxAttackLimit:=0;
                    aip_MaxTowers     :=4+cd_camp_skill*2;
                    aip_MaxEnergy     :=4000;
                 end;

                 camp_CreateUnit(p,map_PlayerStartX[p]+110,map_PlayerStartY[p]-110,UID_HKeep,60);
                 camp_CreateUnit(p,map_PlayerStartX[p]-110,map_PlayerStartY[p]+110,UID_HKeep,60);
                 camp_CreateUnit(p,map_PlayerStartX[p]+110,map_PlayerStartY[p]+110,UID_HKeep,60);

                 camp_CreateUnitAreaR(p,11,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Demon,60);


                 player_SetAllowedUnits   (p,[ UID_HGate,
                                               UID_HPools,
                                               UID_HFTower,
                                               UID_Demon             ], MaxUnits,true);
                 player_SetAllowedUpgrades(p,[ upgr_hell_UnitArmor ,
                                               upgr_hell_MeleeDamage,
                                               upgr_hell_Regeneration,
                                               upgr_hell_PainFactor  ],255,true);
                 with g_PlayersGame[p] do a_ability:=[];
              end;

          1 : begin ////////////////////   HELL vs HELL #2   //////////////////////////////////////////////////////////////////////////////
                 camp_data.cd_NMTime:=fr_fps1*105;

                 map_Seed         :=10666;
                 map_scenario     :=mc_royale;
                 map_GeneratorT   :=3;
                 map_Size1        :=5000;
                 map_Template     :=mapt_steppe;
                 map_Symmetry     :=maps_none;
                 map_MaxPlayers   :=8;
                 map_GenOnObstacle:=false;
                 map_ObstaclesGap :=100;

                 map_Seed2RandomBase;
                 camp_ClearPStarts;

                 g_royal_Rx:=map_Size1;
                 g_royal_Ry:=map_Size1;

                 cd_p_enemy1:=3;
                 cd_p_enemy2:=1;

                 aiflags:=aif_base_smart_order+
                          aif_base_advanceMain+
                          aif_base_DefendOwn+
                          aif_army_scout+
                          aif_army_smart_order+
                          aif_ability_detection+
                          aif_cheat_VisBuildings;
                 if(cd_camp_skill>=2)then aiflags+= aif_army_scoutAggr;

                 // PLAYER

                 p:=cd_p_player;

                 camp_SetPlayer(p,r_hell,0,ps_human,PlayerName);

                 camp_SetPStart(p,map_Size1 div 3,map_Size1 div 7);

                 camp_CreateUnit(p,map_PlayerStartX[p]-100,map_PlayerStartY[p]-100,UID_HKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]+100,map_PlayerStartY[p]+100,UID_HKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]-80 ,map_PlayerStartY[p]+100,UID_HGate);
                 camp_CreateUnit(p,map_PlayerStartX[p]+80 ,map_PlayerStartY[p]-100,UID_HPools);
                 camp_CreateUnitAreaR(p,3,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Imp  );
                 camp_CreateUnitAreaR(p,3,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Demon);

                 player_SetAllowedUnits   (p,[ UID_HKeep,
                                               UID_HGate,
                                               UID_HPools,
                                               UID_HFTower,
                                               UID_Imp,
                                               UID_Demon             ], MaxUnits,true);
                 player_SetAllowedUpgrades(p,[ upgr_hell_DistDamage1,
                                               upgr_hell_UnitArmor ,
                                               upgr_hell_BuildArmor,
                                               upgr_hell_MeleeDamage,
                                               upgr_hell_Regeneration,
                                               upgr_hell_PainFactor ,
                                               upgr_hell_BuilderR    ], 2       ,true);
                 with g_PlayersGame[p] do a_ability:=[uab_ToHAKeep];

                 // Evil Eyes (green)
                 p:=cd_p_enemy1;
                 camp_SetPStart(p,(map_Size1 div 5)*2,map_Size1-(map_Size1 div 4));

                 camp_SetPlayer(p,r_hell,1,ps_AI   ,str_Camp_HE_EE);

                 camp_SetAI(p,3,
                              3,
                              cd_camp_skill,
                              cd_camp_skill,
                              cd_camp_skill,0  ,-1, aiflags);
                 with g_PlayersGame[p] do
                 begin
                    aip_MaxUnitLimit:=(60+cd_camp_skill*10)*ul1;
                    aip_MaxAttackLimit:=(5+7*cd_camp_skill)*ul1;
                 end;

                 camp_CreateUnit(p,map_PlayerStartX[p]    ,map_PlayerStartY[p]-100,UID_HAKeep,60);
                 camp_CreateUnit(p,map_PlayerStartX[p]-110,map_PlayerStartY[p]+100,UID_HAKeep,60);
                 camp_CreateUnit(p,map_PlayerStartX[p]+110,map_PlayerStartY[p]+100,UID_HAKeep,60);
                 camp_CreateUnitAreaR(p,7,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Revenant,60);
                 camp_CreateUnitAreaR(p,7,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Baron   ,60);
                 camp_CreateUnitAreaR(p,7,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Demon   ,60);

                 player_SetAllowedUnits   (p,[ UID_HAKeep,
                                               UID_HGate,
                                               UID_HPools,
                                               UID_HFTower,
                                               UID_HMonastery,
                                               UID_HEyeNest           ], MaxUnits,true );
                 player_SetAllowedUnits   (p,[ UID_Demon,
                                               UID_Baron,
                                               UID_Revenant           ], 40      ,false);
                 player_SetAllowedUpgrades(p,[ upgr_hell_DistDamage1,
                                               upgr_hell_UnitArmor ,
                                               upgr_hell_MeleeDamage,
                                               upgr_hell_Regeneration,
                                               upgr_hell_PainFactor ,
                                               upgr_hell_BuilderR     ], 5       ,true );
                 with g_PlayersGame[p] do a_ability:=[uab_ToHAKeep];

                 // Pack of Anger (orange)
                 p:=cd_p_enemy2;
                 camp_SetPStart(p,map_Size1-(map_Size1 div 5),map_Size1-(map_Size1 div 4));

                 camp_SetPlayer(p,r_hell,2,ps_AI   ,str_Camp_HE_PoA);
                 camp_SetAI(p,3,
                              3,
                              cd_camp_skill,
                              cd_camp_skill,
                              cd_camp_skill,0  ,-1, aiflags);
                 with g_PlayersGame[p] do
                 begin
                    aip_MaxUnitLimit:=(60+cd_camp_skill*10)*ul1;
                    aip_MaxAttackLimit:=(5+7*cd_camp_skill)*ul1;
                 end;

                 camp_CreateUnit(p,map_PlayerStartX[p]+110,map_PlayerStartY[p]-110,UID_HAKeep,60);
                 camp_CreateUnit(p,map_PlayerStartX[p]-100,map_PlayerStartY[p]+110,UID_HAKeep,60);
                 camp_CreateUnit(p,map_PlayerStartX[p]+110,map_PlayerStartY[p]+60 ,UID_HAKeep,60);
                 camp_CreateUnitAreaR(p,7,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Cacodemon,60);
                 camp_CreateUnitAreaR(p,7,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Knight   ,60);
                 camp_CreateUnitAreaR(p,7,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Imp      ,60);

                 player_SetAllowedUnits   (p,[ UID_HAKeep,
                                               UID_HGate,
                                               UID_HPools,
                                               UID_HFTower,
                                               UID_HFortress,
                                               UID_HTeleport          ], MaxUnits,true );
                 player_SetAllowedUnits   (p,[ UID_Imp,
                                               UID_Cacodemon          ], 40      ,false);
                 player_SetAllowedUnits   (p,[ UID_Knight             ], 10      ,false);
                 player_SetAllowedUpgrades(p,[ upgr_hell_UnitArmor    ], 1       ,true );
                 player_SetAllowedUpgrades(p,[ upgr_hell_DistDamage1,
                                               upgr_hell_UnitArmor ,
                                               upgr_hell_MeleeDamage,
                                               upgr_hell_Regeneration,
                                               upgr_hell_PainFactor ,
                                               upgr_hell_BuilderR     ], 5       ,false);

                 with g_PlayersGame[p] do a_ability:=[uab_ToHAKeep,uab_ToHGate,uab_ToHPools];
              end;
          2 : begin ////////////////////   HELL vs HELL #3   //////////////////////////////////////////////////////////////////////////////
                 camp_data.cd_NMTime:=fr_fps1*90;

                 map_Seed         :=10666;
                 map_scenario     :=mc_ffa6;
                 map_GeneratorT   :=2;
                 map_Size1        :=5750;
                 map_Template     :=mapt_temple;
                 map_Symmetry     :=maps_lineV;
                 map_MaxPlayers   :=8;
                 map_GenOnObstacle:=true;
                 map_ObstaclesGap :=100;

                 map_Seed2RandomBase;
                 camp_ClearPStarts;

                 cd_p_ally1 :=1;
                 cd_p_ally2 :=3;

                 cd_p_enemy1:=7;
                 cd_p_enemy2:=2;
                 cd_p_enemy3:=6;

                 aiflags:=aif_base_smart_order+
                          aif_base_advanceMain+
                          aif_base_advanceOther+
                          aif_base_DefendOwn+
                          aif_base_DefendAlly+
                          aif_army_scout+
                          aif_army_scoutAggr+
                          aif_army_smart_order+
                          aif_upgr_smart_order+
                          aif_ability_detection+
                          aif_ability_other+
                          aif_ability_TowerRush+
                          aif_ability_invis+
                          aif_cheat_VisBuildings;

                 // PLAYER

                 p:=cd_p_player;

                 camp_SetPlayer(p,r_hell,0,ps_human,PlayerName);

                 camp_SetPStart(p,map_Size1-(map_Size1 div 5),(map_Size1 div 5));

                 camp_SetBaseLevelUnitUpgrades(p,4);

                 camp_CreateUnit(p,map_PlayerStartX[p],map_PlayerStartY[p],UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]-g_uids[UID_HKeep].uid_r*2,map_PlayerStartY[p],UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]+g_uids[UID_HKeep].uid_r*2,map_PlayerStartY[p],UID_HKeep );
                 camp_CreateUnit(p,map_PlayerStartX[p],map_PlayerStartY[p]+150,UID_HGate);
                 camp_CreateUnit(p,map_PlayerStartX[p],map_PlayerStartY[p]-150,UID_HPools);

                 camp_CreateUnitAreaR(p,5,map_PlayerStartX[p]-100,map_PlayerStartY[p]-100,100,UID_Imp     );
                 camp_CreateUnitAreaR(p,3,map_PlayerStartX[p]-100,map_PlayerStartY[p]-100,100,UID_Demon   );
                 camp_CreateUnitAreaR(p,5,map_PlayerStartX[p]-100,map_PlayerStartY[p]-100,100,UID_Revenant);
                 camp_CreateUnitAreaR(p,2,map_PlayerStartX[p]-100,map_PlayerStartY[p]-100,100,UID_Baron   );
                 camp_CreateUnitAreaR(p,5,map_PlayerStartX[p]-100,map_PlayerStartY[p]-100,100,UID_Cacodemon);

                 player_SetAllowedUnits   (p,[ UID_HKeep,
                                               UID_HAKeep,
                                               UID_HGate,
                                               UID_HPools,
                                               UID_HFTower,
                                               UID_HTeleport,
                                               UID_HEyeNest,
                                               UID_HEye,
                                               UID_HMonastery,
                                               UID_HFortress,
                                               UID_Imp,
                                               UID_Demon,
                                               UID_Baron,
                                               UID_Knight,
                                               UID_Cacodemon,
                                               UID_Revenant  ], MaxUnits,true);
                 player_SetAllowedUpgrades(p,[ upgr_hell_DistDamage1,
                                               upgr_hell_UnitArmor ,
                                               upgr_hell_BuildArmor,
                                               upgr_hell_MeleeDamage,
                                               upgr_hell_Regeneration,
                                               upgr_hell_PainFactor ,
                                               upgr_hell_BuilderR,
                                               upgr_hell_ADetection,
                                               upgr_hell_TowerR    ,
                                               upgr_hell_UnitSightR,
                                               upgr_hell_DistDamage2,
                                               upgr_hell_TeleportCD,
                                               upgr_hell_T2TNoCD,
                                               upgr_hell_EvilEyeR,
                                               upgr_hell_BuildRestore], 4       ,true);

                 with g_PlayersGame[p] do a_ability:=[uab_ToHAKeep,uab_ToHGate,uab_ToHPools,uab_HEyeVision,uab_HEyeSpawn,uab_Teleport,uab_Recall];

                 // ALLY 1     Servants of Fire
                 p:=cd_p_ally1;

                 camp_SetPStart(p ,map_Size1-(map_Size1 div 7),map_Size1 div 2);

                 camp_SetPlayer(p,r_hell,0,ps_AI   ,str_Camp_HE_SoF);

                 camp_SetAI(p,3,
                              3,
                              cd_camp_skill,
                              cd_camp_skill,
                              cd_camp_skill,0  ,-1, aiflags);
                 with g_PlayersGame[p] do
                 begin
                    aip_MaxUnitLimit  :=60*ul1;
                    aip_MaxAttackLimit:=ul10+ul10*cd_camp_skill;
                    upgrs_cur[upgr_hell_Resurrect]:=1;
                 end;

                 camp_CreateUnit(p,map_PlayerStartX[p]    ,map_PlayerStartY[p]    ,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]-200,map_PlayerStartY[p]    ,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]+150,map_PlayerStartY[p]-150,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]+150,map_PlayerStartY[p]+150,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]+200,map_PlayerStartY[p]    ,UID_HMonastery);

                 camp_CreateUnitAreaR(p,5,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Imp     );
                 camp_CreateUnitAreaR(p,1,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Archvile);
                 camp_CreateUnitAreaR(p,3,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Mancubus);
                 camp_CreateUnitAreaR(p,2,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Pain    );

                 player_SetAllowedUnits   (p ,[ UID_HKeep,
                                                UID_HAKeep,
                                                UID_HGate,
                                                UID_HPools,
                                                UID_HFTower,
                                                UID_HTeleport,
                                                UID_HMonastery,
                                                UID_Imp,
                                                UID_Mancubus,
                                                UID_Pain      ], MaxUnits,true);
                 player_SetAllowedUnits   (p ,[ UID_Archvile  ], 1+cd_camp_skill,false);

                 player_SetAllowedUpgrades(p ,[ upgr_hell_DistDamage1,
                                                upgr_hell_UnitArmor ,
                                                upgr_hell_BuildArmor,
                                                upgr_hell_MeleeDamage,
                                                upgr_hell_Regeneration,
                                                upgr_hell_PainFactor ,
                                                upgr_hell_BuilderR,
                                                upgr_hell_ADetection,
                                                upgr_hell_Resurrect,
                                                upgr_hell_TowerR    ,
                                                upgr_hell_UnitSightR,
                                                upgr_hell_DistDamage2,
                                                upgr_hell_TeleportCD,
                                                upgr_hell_T2TNoCD,
                                                upgr_hell_BuildRestore], 4       ,true);


                 // ALLY 2     Cyber Division
                 p:=cd_p_ally2;

                 camp_SetPStart(p ,map_Size1-(map_Size1 div 5),map_Size1-(map_Size1 div 5));

                 camp_SetPlayer(p,r_hell,0,ps_AI   ,str_Camp_HE_CB);
                 camp_SetAI(p,3,
                              3,
                              cd_camp_skill,
                              cd_camp_skill,
                              cd_camp_skill,0  ,-1, aiflags);
                 with g_PlayersGame[p] do
                 begin
                    aip_MaxUnitLimit  :=60*ul1;
                    aip_MaxAttackLimit:=ul10+ul10*cd_camp_skill;
                 end;

                 camp_CreateUnit(p,map_PlayerStartX[p]    ,map_PlayerStartY[p]    ,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]-200,map_PlayerStartY[p]    ,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]+150,map_PlayerStartY[p]-150,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]+150,map_PlayerStartY[p]+150,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]+200,map_PlayerStartY[p]    ,UID_HPentagram);

                 camp_CreateUnitAreaR(p,5,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Arachnotron);
                 camp_CreateUnitAreaR(p,1,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Cyberdemon);
                 camp_CreateUnitAreaR(p,1,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Mastermind);

                 player_SetAllowedUnits   (p ,[ UID_HKeep,
                                                UID_HAKeep,
                                                UID_HGate,
                                                UID_HPools,
                                                UID_HFTower,
                                                UID_HTeleport,
                                                UID_HMonastery,
                                                UID_HPentagram,
                                                UID_Arachnotron,
                                                UID_Cyberdemon,
                                                UID_Mastermind], MaxUnits,true);
                 player_SetAllowedUpgrades(p ,[ upgr_hell_DistDamage1,
                                                upgr_hell_UnitArmor ,
                                                upgr_hell_BuildArmor,
                                                upgr_hell_MeleeDamage,
                                                upgr_hell_Regeneration,
                                                upgr_hell_PainFactor ,
                                                upgr_hell_BuilderR,
                                                upgr_hell_ADetection,
                                                upgr_hell_TowerR    ,
                                                upgr_hell_UnitSightR,
                                                upgr_hell_DistDamage2,
                                                upgr_hell_TeleportCD,
                                                upgr_hell_T2TNoCD,
                                                upgr_hell_BuildRestore], 4       ,true);

                 // ENEMY 1    Blood Squad

                 aiflags:=aif_base_smart_order+
                          aif_base_advanceMain+
                          aif_base_advanceOther+
                          aif_base_DefendOwn+
                          aif_army_scout+
                          aif_army_scoutAggr+
                          aif_army_smart_order+
                          aif_upgr_smart_order+
                          aif_ability_detection+
                          aif_ability_other+
                          aif_ability_TowerRush+
                          aif_ability_invis+
                          aif_cheat_VisBuildings;


                 p:=cd_p_enemy1;
                 camp_SetPStart(p ,(map_Size1 div 5),(map_Size1 div 5));

                 camp_SetPlayer(p,r_hell,1,ps_AI   ,str_Camp_HE_BS);
                 camp_SetAI(p,3,
                              3,
                              cd_camp_skill,
                              cd_camp_skill,
                              cd_camp_skill,0  ,-1, aiflags);
                 with g_PlayersGame[p] do
                 begin
                    upgrs_cur[upgr_hell_Spectre]:=1;
                    upgrs_cur[upgr_fprod_unit  ]:=1;
                    aip_MaxUnitLimit  :=70*ul1;
                    aip_MaxAttackLimit:=ul10+ul10*cd_camp_skill;
                 end;

                 camp_CreateUnit(p,map_PlayerStartX[p]    ,map_PlayerStartY[p]    ,UID_HAKeep,60);
                 camp_CreateUnit(p,map_PlayerStartX[p]+200,map_PlayerStartY[p]    ,UID_HAKeep,60);
                 camp_CreateUnit(p,map_PlayerStartX[p]-150,map_PlayerStartY[p]+150,UID_HAKeep,60);
                 camp_CreateUnit(p,map_PlayerStartX[p]-150,map_PlayerStartY[p]-150,UID_HAKeep,60);
                 camp_CreateUnit(p,map_PlayerStartX[p]-200,map_PlayerStartY[p]    ,UID_HFortress );
                 camp_CreateUnit(p,map_PlayerStartX[p]+150,map_PlayerStartY[p]-150,UID_HMonastery);

                 player_SetAllowedUnits   (p ,[ UID_HKeep,
                                                UID_HAKeep,
                                                UID_HGate,
                                                UID_HPools,
                                                UID_HFTower,
                                                UID_HTeleport,
                                                UID_HMonastery,
                                                UID_HFortress,
                                                UID_Revenant,
                                                UID_Demon     ], MaxUnits,true );

                 player_SetAllowedUpgrades(p ,[ upgr_hell_DistDamage1,
                                                upgr_hell_UnitArmor ,
                                                upgr_hell_BuildArmor,
                                                upgr_hell_MeleeDamage,
                                                upgr_hell_Regeneration,
                                                upgr_hell_Spectre,
                                                upgr_hell_PainFactor ,
                                                upgr_hell_BuilderR,
                                                upgr_hell_TowerR    ,
                                                upgr_hell_UnitSightR,
                                                upgr_hell_DistDamage2,
                                                upgr_hell_TeleportCD,
                                                upgr_hell_T2TNoCD,
                                                upgr_hell_BuildRestore], 4       ,true);

                 // ENEMY 2    Lords Of Horror
                 p:=cd_p_enemy2;
                 camp_SetPStart(p ,(map_Size1 div 7),map_Size1 div 2);

                 camp_SetPlayer(p,r_hell,1,ps_AI   ,str_Camp_HE_LoH);
                 camp_SetAI(p,3,
                              3,
                              cd_camp_skill,
                              cd_camp_skill,
                              cd_camp_skill,0  ,-1, aiflags);
                 with g_PlayersGame[p] do
                 begin
                    upgrs_cur[upgr_hell_TowerBlink]:=1;
                    upgrs_cur[upgr_hell_TotemInvis]:=1;
                    upgrs_cur[upgr_hell_Resurrect ]:=1;
                    aip_MaxUnitLimit  :=70*ul1;
                    aip_MaxAttackLimit:=ul10+ul10*cd_camp_skill;
                 end;

                 camp_CreateUnit(p,map_PlayerStartX[p]    ,map_PlayerStartY[p]    ,UID_HAKeep,60);
                 camp_CreateUnit(p,map_PlayerStartX[p]+200,map_PlayerStartY[p]    ,UID_HAKeep,60);
                 camp_CreateUnit(p,map_PlayerStartX[p]-150,map_PlayerStartY[p]+150,UID_HAKeep,60);
                 camp_CreateUnit(p,map_PlayerStartX[p]-150,map_PlayerStartY[p]-150,UID_HAKeep,60);
                 camp_CreateUnit(p,map_PlayerStartX[p]-200,map_PlayerStartY[p]    ,UID_HFortress );
                 camp_CreateUnit(p,map_PlayerStartX[p]+150,map_PlayerStartY[p]-150,UID_HMonastery);

                 player_SetAllowedUnits   (p ,[ UID_HKeep,
                                                UID_HAKeep,
                                                UID_HGate,
                                                UID_HPools,
                                                UID_HFTower,
                                                UID_HTeleport,
                                                UID_HMonastery,
                                                UID_Knight,
                                                UID_Baron     ], MaxUnits       ,true );
                 player_SetAllowedUnits   (p ,[ UID_Archvile,
                                                UID_HTotem    ], 1+cd_camp_skill,false);

                 player_SetAllowedUpgrades(p ,[ upgr_hell_DistDamage1,
                                                upgr_hell_UnitArmor ,
                                                upgr_hell_BuildArmor,
                                                upgr_hell_MeleeDamage,
                                                upgr_hell_Regeneration,
                                                upgr_hell_Resurrect,
                                                upgr_hell_PainFactor ,
                                                upgr_hell_BuilderR,
                                                upgr_hell_TowerR    ,
                                                upgr_hell_UnitSightR,
                                                upgr_hell_DistDamage2,
                                                upgr_hell_TeleportCD,
                                                upgr_hell_T2TNoCD,
                                                upgr_hell_BuildRestore,
                                                upgr_hell_TowerBlink,
                                                upgr_hell_TotemInvis  ], 4      ,true );

                 // ENEMY 3    Clan of Burning Sky
                 p:=cd_p_enemy3;
                 camp_SetPStart(p ,(map_Size1 div 5),map_Size1-(map_Size1 div 5));


                 camp_SetPlayer(p,r_hell,1,ps_AI   ,str_Camp_HE_CoBS);
                 camp_SetAI(p,3,
                              3,
                              cd_camp_skill,
                              cd_camp_skill,
                              cd_camp_skill,0  ,-1, aiflags);
                 with g_PlayersGame[p] do
                 begin
                    aip_MaxUnitLimit  :=70*ul1;
                    aip_MaxAttackLimit:=ul10+ul10*cd_camp_skill;
                 end;

                 camp_CreateUnit(p,map_PlayerStartX[p]    ,map_PlayerStartY[p]    ,UID_HAKeep,60);
                 camp_CreateUnit(p,map_PlayerStartX[p]+200,map_PlayerStartY[p]    ,UID_HAKeep,60);
                 camp_CreateUnit(p,map_PlayerStartX[p]-150,map_PlayerStartY[p]+150,UID_HAKeep,60);
                 camp_CreateUnit(p,map_PlayerStartX[p]-150,map_PlayerStartY[p]-150,UID_HAKeep,60);
                 camp_CreateUnit(p,map_PlayerStartX[p]-200,map_PlayerStartY[p]    ,UID_HFortress );
                 camp_CreateUnit(p,map_PlayerStartX[p]+150,map_PlayerStartY[p]-150,UID_HMonastery);
                 camp_CreateUnit(p,map_PlayerStartX[p]+150,map_PlayerStartY[p]+150,UID_HAltar);
                 camp_CreateUnit(p,map_PlayerStartX[p]+ 50,map_PlayerStartY[p]-250,UID_HAltar);
                 camp_CreateUnit(p,map_PlayerStartX[p]-280,map_PlayerStartY[p]+150,UID_HAltar);
                 camp_CreateUnit(p,map_PlayerStartX[p]-280,map_PlayerStartY[p]-150,UID_HAltar);

                 player_SetAllowedUnits   (p ,[ UID_HKeep,
                                                UID_HAKeep,
                                                UID_HGate,
                                                UID_HPools,
                                                UID_HFTower,
                                                UID_HTeleport,
                                                UID_HMonastery,
                                                UID_HTotem,
                                                UID_Cacodemon,
                                                UID_Pain,
                                                UID_LostSoul], MaxUnits        ,true);
                 player_SetAllowedUnits   (p ,[ UID_LostSoul], scirmish_MaxLost,false);
                 player_SetAllowedUpgrades(p ,[ upgr_hell_DistDamage1,
                                                upgr_hell_UnitArmor ,
                                                upgr_hell_BuildArmor,
                                                upgr_hell_MeleeDamage,
                                                upgr_hell_Regeneration,
                                                upgr_hell_PainFactor ,
                                                upgr_hell_DecayAura,
                                                upgr_hell_BuilderR,
                                                upgr_hell_TowerR    ,
                                                upgr_hell_UnitSightR,
                                                upgr_hell_DistDamage2,
                                                upgr_hell_TeleportCD,
                                                upgr_hell_T2TNoCD,
                                                upgr_hell_BuildRestore], 4       ,true);
              end;
          3 : begin ////////////////////   HELL vs HELL #4   //////////////////////////////////////////////////////////////////////////////

                 camp_data.cd_NMTime:=fr_fps1*105;

                 map_Seed         :=10666;
                 map_scenario     :=mc_KeyPoints;
                 map_GeneratorT   :=0;
                 map_Size1        :=6500;
                 map_Template     :=mapt_canyon;
                 map_Symmetry     :=maps_none;
                 map_MaxPlayers   :=3;
                 map_GenOnObstacle:=true;
                 map_ObstaclesGap :=100;
                 map_Sizeh:=map_Size1 div 2;

                 map_Seed2RandomBase;
                 camp_ClearPStarts;

                 cd_p_enemy1:=1;
                 cd_p_enemy2:=3;

                 aiflags:=aif_base_smart_order+
                          aif_base_advanceMain+
                          aif_base_advanceOther+
                          aif_base_BuilderMove+
                          aif_base_DefendOwn+
                          aif_army_scout+
                          aif_army_scoutAggr+
                          aif_army_smart_order+
                          aif_army_smart_micro+
                          aif_army_smart_Target+
                          aif_upgr_smart_order+
                          aif_ability_detection+
                          aif_ability_other+
                          aif_ability_TowerRush+
                          aif_ability_invis;

                 map_CalcLakeR(@td,@tu);
                 map_Starts_Circle(map_Sizeh,map_Sizeh,20,td+base_r1);

                 map_PlayerStartX[cd_p_enemy2]:=map_PlayerStartX[2];
                 map_PlayerStartY[cd_p_enemy2]:=map_PlayerStartY[2];

                 // PLAYER

                 p:=cd_p_player;

                 camp_SetPlayer(p,r_hell,0,ps_human,PlayerName);

                 camp_SetBaseLevelUnitUpgrades(p,6);

                 player_SetAllowedUnits   (p ,[ UID_HKeep,
                                                UID_HAKeep,
                                                UID_HGate,
                                                UID_HPools,
                                                UID_HFTower,
                                                UID_HTotem,
                                                UID_HTeleport,
                                                UID_HMonastery,
                                                UID_HFortress,
                                                UID_HAltar,
                                                UID_HEye,
                                                UID_HEyeNest,
                                                UID_Imp,
                                                UID_Demon,
                                                UID_Knight,
                                                UID_Baron,
                                                UID_Cacodemon,
                                                UID_Revenant,
                                                UID_Pain,
                                                UID_LostSoul,
                                                UID_ArchVile  ], MaxUnits          ,true);
                 player_SetAllowedUnits   (p ,[ UID_HAltar    ], scirmish_MaxHAltar,false);
                 player_SetAllowedUnits   (p ,[ UID_LostSoul  ], scirmish_MaxLost  ,false);

                 player_SetAllowedUpgrades(p ,[ upgr_hell_DistDamage1,
                                                upgr_hell_UnitArmor ,
                                                upgr_hell_BuildArmor,
                                                upgr_hell_MeleeDamage,
                                                upgr_hell_Regeneration,
                                                upgr_hell_PainFactor ,
                                                upgr_hell_BuilderR,
                                                upgr_hell_ADetection,
                                                upgr_hell_Resurrect,
                                                upgr_hell_TowerR    ,
                                                upgr_hell_UnitSightR,
                                                upgr_hell_DecayAura,
                                                upgr_hell_DistDamage2,
                                                upgr_hell_TeleportCD,
                                                upgr_hell_EvilEyeR,
                                                upgr_hell_Spectre,
                                                upgr_hell_TotemInvis,
                                                upgr_hell_TowerBlink,
                                                upgr_hell_T2TNoCD,
                                                upgr_hell_BuildRestore], 4       ,true);

                 // ENEMY 1     Servants of Fire
                 p:=cd_p_enemy1;

                 camp_SetPlayer(p,r_hell,1,ps_AI   ,str_Camp_HE_SoF);

                 camp_SetAI(p,3,
                              3,
                              cd_camp_skill,
                              cd_camp_skill,
                              cd_camp_skill,0  ,-1, aiflags);
                 with g_PlayersGame[p] do
                 begin
                    aip_MaxUnitLimit  :=100*ul1;
                    aip_MaxAttackLimit:=ul10+ul10*cd_camp_skill;
                    upgrs_cur[upgr_hell_BuildArmor]:=5;
                    upgrs_cur[upgr_fprod_unit]:=3;
                 end;


                 player_SetAllowedUnits   (p ,[ UID_HKeep,
                                                UID_HAKeep,
                                                UID_HGate,
                                                UID_HPools,
                                                UID_HFTower,
                                                UID_HTotem,
                                                UID_HTeleport,
                                                UID_HMonastery,
                                                UID_HFortress,
                                                UID_HAltar,
                                                UID_HEye,
                                                UID_HEyeNest,
                                                UID_Imp,
                                                UID_Demon,
                                                UID_Knight,
                                                UID_Baron,
                                                UID_Revenant,
                                                UID_Cacodemon,
                                                UID_Mancubus,
                                                UID_Pain,
                                                UID_LostSoul,
                                                UID_ArchVile  ], MaxUnits          ,true );
                 player_SetAllowedUnits   (p ,[ UID_HAltar    ], scirmish_MaxHAltar,false);
                 player_SetAllowedUnits   (p ,[ UID_LostSoul  ], scirmish_MaxLost  ,false);

                 player_SetAllowedUpgrades(p ,[ upgr_hell_DistDamage1,
                                                upgr_hell_UnitArmor ,
                                                upgr_hell_BuildArmor,
                                                upgr_hell_MeleeDamage,
                                                upgr_hell_Regeneration,
                                                upgr_hell_PainFactor ,
                                                upgr_hell_BuilderR,
                                                upgr_hell_ADetection,
                                                upgr_hell_Resurrect,
                                                upgr_hell_TowerR    ,
                                                upgr_hell_UnitSightR,
                                                upgr_hell_DecayAura,
                                                upgr_hell_DistDamage2,
                                                upgr_hell_TeleportCD,
                                                upgr_hell_EvilEyeR,
                                                upgr_hell_Spectre,
                                                upgr_hell_TotemInvis,
                                                upgr_hell_TowerBlink,
                                                upgr_hell_T2TNoCD,
                                                upgr_hell_BuildRestore], 4       ,true);

                 // ENEMY 2     Cyber division
                 p:=cd_p_enemy2;

                 camp_SetPlayer(p,r_hell,1,ps_AI   ,str_Camp_HE_CB);
                 camp_SetAI(p,3,
                              3,
                              cd_camp_skill,
                              cd_camp_skill,
                              cd_camp_skill,0  ,-1, aiflags);
                 with g_PlayersGame[p] do
                 begin
                    aip_MaxUnitLimit  :=100*ul1;
                    aip_MaxAttackLimit:=ul10+ul10*cd_camp_skill;
                    upgrs_cur[upgr_hell_BuildArmor]:=5;
                    upgrs_cur[upgr_fprod_unit]:=3;
                 end;

                 player_SetAllowedUnits   (p ,[ UID_HKeep,
                                                UID_HAKeep,
                                                UID_HGate,
                                                UID_HPools,
                                                UID_HFTower,
                                                UID_HTotem,
                                                UID_HTeleport,
                                                UID_HMonastery,
                                                UID_HFortress,
                                                UID_HAltar,
                                                UID_HEye,
                                                UID_HEyeNest,
                                                UID_Imp,
                                                UID_Demon,
                                                UID_Knight,
                                                UID_Revenant,
                                                UID_Baron,
                                                UID_Cacodemon,
                                                UID_Pain,
                                                UID_LostSoul,
                                                UID_ArchVile,
                                                UID_Cyberdemon,
                                                UID_Arachnotron,
                                                UID_Mastermind  ], MaxUnits          ,true );
                 player_SetAllowedUnits   (p ,[ UID_HAltar      ], scirmish_MaxHAltar,false);
                 player_SetAllowedUnits   (p ,[ UID_LostSoul    ], scirmish_MaxLost  ,false);

                 player_SetAllowedUpgrades(p ,[ upgr_hell_DistDamage1,
                                                upgr_hell_UnitArmor ,
                                                upgr_hell_BuildArmor,
                                                upgr_hell_MeleeDamage,
                                                upgr_hell_Regeneration,
                                                upgr_hell_PainFactor ,
                                                upgr_hell_BuilderR,
                                                upgr_hell_ADetection,
                                                upgr_hell_Resurrect,
                                                upgr_hell_TowerR    ,
                                                upgr_hell_UnitSightR,
                                                upgr_hell_DecayAura,
                                                upgr_hell_DistDamage2,
                                                upgr_hell_TeleportCD,
                                                upgr_hell_EvilEyeR,
                                                upgr_hell_Spectre,
                                                upgr_hell_TotemInvis,
                                                upgr_hell_TowerBlink,
                                                upgr_hell_T2TNoCD,
                                                upgr_hell_BuildRestore], 4       ,true);
                 // starts

                 td:=g_uids[UID_HKeep].uid_r*2;
                 for p in [cd_p_player,cd_p_enemy1,cd_p_enemy2] do
                 begin
                    tu:=point_dir(map_PlayerStartX[p],map_PlayerStartY[p],map_Sizeh,map_Sizeh);
                    tx:= round(td*cos(tu*DEGTORAD));
                    ty:=-round(td*sin(tu*DEGTORAD));

                    camp_CreateUnit(p,map_PlayerStartX[p]-tx*2,map_PlayerStartY[p]-ty*2,UID_HAKeep,60);
                    camp_CreateUnit(p,map_PlayerStartX[p]-tx  ,map_PlayerStartY[p]-ty  ,UID_HAKeep,60);
                    camp_CreateUnit(p,map_PlayerStartX[p]     ,map_PlayerStartY[p]     ,UID_HAKeep,60);
                    camp_CreateUnit(p,map_PlayerStartX[p]+tx  ,map_PlayerStartY[p]+ty  ,UID_HAKeep,60);

                    if(p=cd_p_player)then
                    begin
                       camp_CreateUnitAreaR(p,5,map_PlayerStartX[p]-100,map_PlayerStartY[p],100,UID_Imp     );
                       camp_CreateUnitAreaR(p,1,map_PlayerStartX[p]    ,map_PlayerStartY[p],100,UID_Archvile);
                    end;
                    if(p=cd_p_enemy1)
                    or(p=cd_p_enemy2)then
                    begin
                       camp_CreateUnitAreaR(p,10,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Cacodemon);
                       camp_CreateUnitAreaR(p,1 ,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Archvile );
                    end;
                 end;

              end;
          4 : begin ////////////////////   HELL vs HELL #5   //////////////////////////////////////////////////////////////////////////////
                 camp_data.cd_NMTime:=fr_fps1*105;

                 map_Seed         :=10666;
                 map_scenario     :=mc_koth;
                 map_GeneratorT   :=0;
                 map_Size1        :=7000;
                 map_Template     :=mapt_island;
                 map_Symmetry     :=maps_none;
                 map_MaxPlayers   :=8;
                 map_GenOnObstacle:=true;
                 map_ObstaclesGap :=60;
                 map_Sizeh:=map_Size1 div 2;

                 map_Seed2RandomBase;
                 camp_ClearPStarts;

                 cd_p_enemy1:=1;
                 cd_p_enemy2:=2;
                 cd_p_enemy3:=3;

                 aiflags:=aif_base_smart_order+
                          aif_base_advanceMain+
                          aif_base_advanceOther+
                          aif_base_BuilderMove+
                          aif_base_DefendOwn+
                          aif_army_scout+
                          aif_army_scoutAggr+
                          aif_army_smart_order+
                          aif_army_smart_micro+
                          aif_army_smart_Target+
                          aif_upgr_smart_order+
                          aif_ability_detection+
                          aif_ability_other+
                          aif_ability_TowerRush+
                          aif_ability_invis+
                          aif_cheat_VisBuildings;

                 map_CalcLakeR(@td,@tu);
                 map_Starts_Circle(map_Sizeh,map_Sizeh,50,td+base_r1);
                 map_ShuffleStarts(false,false);

                 td:=g_uids[UID_HKeep].uid_r*2;
                 for p:=0 to LastPlayer do
                 begin
                    tu:=point_dir(map_PlayerStartX[p],map_PlayerStartY[p],map_Sizeh,map_Sizeh);
                    tx:= round(td*cos(tu*DEGTORAD));
                    ty:=-round(td*sin(tu*DEGTORAD));

                    if(p=cd_p_player)then
                    begin
                       camp_SetPlayer(p,r_hell,0,ps_human,PlayerName);
                       camp_SetBaseLevelUnitUpgrades(p,8);
                    end
                    else
                    begin
                       camp_SetPlayer(p,r_hell,p,ps_AI,b2s(p));
                       camp_SetAI(p,3,
                                    3,
                                    cd_camp_skill,
                                    cd_camp_skill,
                                    cd_camp_skill,0  ,-1, aiflags);
                       with g_PlayersGame[p] do
                       begin
                          aip_MinTowers     :=2+cd_camp_skill;
                          aip_MaxTowers     :=aip_MinTowers*cd_camp_skill;
                          aip_MaxUnitLimit  :=100*ul1;
                          aip_MaxAttackLimit:=ul15+ul15*cd_camp_skill;

                          upgrs_cur[upgr_fprod_unit]:=1;
                       end;
                       camp_SetBaseLevelUnitUpgrades(p,10);
                    end;

                    camp_CreateUnit(p,map_PlayerStartX[p]-tx*2,map_PlayerStartY[p]-ty*2,UID_HAKeep,60);
                    camp_CreateUnit(p,map_PlayerStartX[p]-tx  ,map_PlayerStartY[p]-ty  ,UID_HAKeep,60);
                    camp_CreateUnit(p,map_PlayerStartX[p]     ,map_PlayerStartY[p]     ,UID_HAKeep,60);
                    camp_CreateUnit(p,map_PlayerStartX[p]+tx  ,map_PlayerStartY[p]+ty  ,UID_HAKeep,60);
                    camp_CreateUnit(p,map_PlayerStartX[p]+tx*2,map_PlayerStartY[p]+ty*2,UID_HAKeep,60);

                    player_SetAllowedUnits   (p ,[ UID_HKeep,
                                                   UID_HAKeep,
                                                   UID_HGate,
                                                   UID_HPools,
                                                   UID_HFTower,
                                                   UID_HTotem,
                                                   UID_HTeleport,
                                                   UID_HMonastery,
                                                   UID_HPentagram,
                                                   UID_HFortress,
                                                   UID_HEyeNest,
                                                   UID_HEye,
                                                   UID_HAltar,

                                                   UID_LostSoul,
                                                   UID_Imp,
                                                   UID_Demon,
                                                   UID_Knight,
                                                   UID_Baron,
                                                   UID_Revenant,
                                                   UID_Cacodemon,
                                                   UID_Pain,
                                                   UID_Mancubus,
                                                   UID_Arachnotron,
                                                   UID_Archvile,
                                                   UID_Cyberdemon,
                                                   UID_Mastermind        ], MaxUnits          ,true );
                    player_SetAllowedUnits   (p ,[ UID_LostSoul          ], scirmish_MaxLost  ,false);
                    player_SetAllowedUnits   (p ,[ UID_HAltar            ], scirmish_MaxHAltar,false);

                    if(p<>cd_p_player)then
                    player_SetAllowedUnits   (p ,[ UID_HTotem,
                                                   UID_Archvile          ], 1+cd_camp_skill   ,false);

                    case p of
                    1,2 : player_SetAllowedUnits   (p ,[ UID_Mancubus,UID_Baron,UID_Knight,UID_Revenant ], 0,false);
                    3,6 : player_SetAllowedUnits   (p ,[ UID_Cacodemon                                  ], 0,false);
                    5,4 : player_SetAllowedUnits   (p ,[ UID_Pain,UID_Demon,UID_Imp,UID_Cyberdemon      ], 0,false);
                    end;

                    player_SetAllowedUpgrades(p ,[ upgr_hell_DistDamage1,
                                                   upgr_hell_UnitArmor ,
                                                   upgr_hell_BuildArmor,
                                                   upgr_hell_MeleeDamage,
                                                   upgr_hell_Regeneration,
                                                   upgr_hell_ADetection,
                                                   upgr_hell_PainFactor ,
                                                   upgr_hell_DecayAura,
                                                   upgr_hell_HKeepShift,
                                                   upgr_hell_BuilderR,
                                                   upgr_hell_TowerR    ,
                                                   upgr_hell_UnitSightR,
                                                   upgr_hell_Spectre,
                                                   upgr_hell_DistDamage2,
                                                   upgr_hell_TeleportCD,
                                                   upgr_hell_Resurrect,
                                                   upgr_hell_EvilEyeR,
                                                   upgr_hell_TotemInvis,
                                                   upgr_hell_T2TNoCD,
                                                   upgr_hell_BuildRestore,
                                                   upgr_hell_TowerBlink  ], 4       ,true);

                    PlayerSetCurrentUpgrades (p ,[ upgr_hell_DistDamage1,
                                                   upgr_hell_UnitArmor ,
                                                   upgr_hell_BuildArmor,
                                                   upgr_hell_MeleeDamage,
                                                   upgr_hell_Regeneration,
                                                   upgr_hell_ADetection,
                                                   upgr_hell_PainFactor ,
                                                   upgr_hell_BuilderR,
                                                   upgr_hell_TowerR    ,
                                                   upgr_hell_UnitSightR,
                                                   upgr_hell_DistDamage2,
                                                   upgr_hell_TeleportCD,
                                                   upgr_hell_EvilEyeR,
                                                   upgr_hell_BuildRestore], 4       ,false);
                 end;

                 g_PlayersGame[1].name:=str_Camp_HE_1;
                 g_PlayersGame[2].name:=str_Camp_HE_2;
                 g_PlayersGame[3].name:=str_Camp_HE_3;
                 g_PlayersGame[4].name:=str_Camp_HE_4;
                 g_PlayersGame[5].name:=str_Camp_HE_5;
                 g_PlayersGame[6].name:=str_Camp_HE_6;
                 g_PlayersGame[7].name:=str_Camp_HE_7;

                 g_PlayersGame[2].team:=1;
                 g_PlayersGame[6].team:=7;
                 g_PlayersGame[5].team:=3;
              end;
          end;
       end;

   end;

   Map_Make;
   camp_UnitsUpdateMiniMapXY;
   ui_Camera_MoveToPoint(map_PlayerStartX[LocalPlayer],map_PlayerStartY[LocalPlayer]);
   ui_tab:=0;

   FillChar(ai_TeamAlarms,SizeOf(ai_TeamAlarms),0);
   if(camp_diff=4)then // NightMare disable base unit armor
     for p:=0 to LastPlayer do
       with g_PlayersGame[p] do
         if(state=ps_AI)then
           if(team<>g_PlayersGame[LocalPlayer].team)then
             case race of
             r_hell: begin
                        upgrs_max[upgr_hell_UnitArmor  ]:=0;
                        upgrs_max[upgr_hell_DistDamage1]:=0;
                        upgrs_max[upgr_hell_DistDamage2]:=0;
                     end;
             r_uac : begin
                        upgrs_max[upgr_uac_DistDamage  ]:=0;
                        upgrs_max[upgr_uac_BioArmor    ]:=0;
                        upgrs_max[upgr_uac_MechArmor   ]:=0;
                     end;
             end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   MISSIONS In-game code
//

procedure cmp_MissionCode;
var
tmpb1,
tmpb2,
tmpb3:boolean;
p    :byte;
begin
   if(g_cycle_regen=0)and(camp_diff=4)then
     with camp_data do
       if(cd_NMTime>0)then
         camp_NightmareLvlUp(g_tick div cd_NMTime);

   with camp_data do
   case camp_sel of
   0 : case camp_mis_sel of
       ////////////////////   HELL vs HELL #1    ////////////////////////////////////////////////////////////////////////////
       0 : begin      //  HELL vs HELL #1
              with g_PlayersGame[cd_p_enemy1] do
                if(g_PlayersGame[cd_p_player].units_bld_lc[false]>=ul30)and(aip_MaxAttackLimit<=0)then
                begin
                   aip_MaxUnitLimit  +=ul20*cd_camp_skill;
                   aip_MaxAttackLimit:=aip_MaxUnitLimit div 3;
                   upgrs_cur[upgr_fprod_unit]:=1;
                end;

              camp_ObjStat:=0;
              with g_PlayersGame[cd_p_player] do
              begin
                 tmpb1:=(units_uid_c[UID_HKeep]>0);

                 SetBBit(@camp_ObjStat,0,tmpb1);
                 SetBBit(@camp_ObjStat,1,(res_energyl_max>=2000));
                 SetBBit(@camp_ObjStat,2,(units_uid_c[UID_HGate]>=10));
                 SetBBit(@camp_ObjStat,3,(units_uid_c[UID_Imp  ]>=30));
                 SetBBit(@camp_ObjStat,4,(g_PlayersGame[cd_p_enemy1].units_bld_lc[true]=0));

                 if(not tmpb1)
                 then game_SetStatusWinnerTeam(g_PlayersGame[cd_p_enemy1].team)
                 else
                   if(camp_ObjStat=%11111)
                   then camp_Win;
              end;
           end;

       ////////////////////   HELL vs HELL #2    ////////////////////////////////////////////////////////////////////////////
       1 : begin
              if(g_PlayersGame[cd_p_enemy1].units_bld_lc[true]=0)then
                if(camp_AllowUnitsForPlayer(cd_p_player,[ UID_Baron,
                                                          UID_Revenant,
                                                          UID_HAKeep  ,
                                                          UID_HEyeNest,
                                                          UID_HMonastery]))then
                  g_PlayersGame[cd_p_player].upgrs_cur[upgr_hell_DistDamage2]:=3;

              if(g_PlayersGame[cd_p_enemy2].units_bld_lc[true]=0)then
                camp_AllowUnitsForPlayer(cd_p_player,[ UID_Knight,
                                                       UID_Cacodemon,
                                                       UID_HAKeep   ,
                                                       UID_HTeleport,
                                                       UID_HFortress]);

              camp_ObjStat:=0;
              with g_PlayersGame[cd_p_player] do
              begin
                 tmpb1:=(units_uid_c[UID_HKeep ]>0)or(units_uid_c[UID_HAKeep]>0);
                 SetBBit(@camp_ObjStat,0,tmpb1);
              end;
              SetBBit(@camp_ObjStat,1,(g_PlayersGame[cd_p_enemy1].units_bld_lc[true]=0)
                                   and(g_PlayersGame[cd_p_enemy2].units_bld_lc[true]=0) );

              if(not tmpb1)then
              begin
                 if(g_PlayersGame[cd_p_enemy1].units_bld_lc[false]>g_PlayersGame[cd_p_enemy2].units_bld_lc[false])
                 then game_SetStatusWinnerTeam(g_PlayersGame[cd_p_enemy1].team)
                 else game_SetStatusWinnerTeam(g_PlayersGame[cd_p_enemy2].team)
              end
              else
                if(camp_ObjStat=%11)
                then camp_Win;
           end;

       ////////////////////   HELL vs HELL #3    ////////////////////////////////////////////////////////////////////////////
       2 : begin
              tmpb1:=((g_PlayersGame[cd_p_player].units_uid_c[UID_HKeep ]=0)and(g_PlayersGame[cd_p_player].units_uid_c[UID_HAKeep]=0))
                   or((g_PlayersGame[cd_p_ally1 ].units_uid_c[UID_HKeep ]=0)and(g_PlayersGame[cd_p_ally1 ].units_uid_c[UID_HAKeep]=0))
                   or((g_PlayersGame[cd_p_ally2 ].units_uid_c[UID_HKeep ]=0)and(g_PlayersGame[cd_p_ally2 ].units_uid_c[UID_HAKeep]=0));

              tmpb2:=(g_PlayersGame[cd_p_enemy1].units_bld_lc[true]=0)
                  and(g_PlayersGame[cd_p_enemy2].units_bld_lc[true]=0)
                  and(g_PlayersGame[cd_p_enemy3].units_bld_lc[true]=0);

              camp_ObjStat:=0;
              SetBBit(@camp_ObjStat,0,not tmpb1);
              SetBBit(@camp_ObjStat,1,    tmpb2);

              if(tmpb1)
              then game_SetStatusWinnerTeam(g_PlayersGame[cd_p_enemy1].team)
              else
                if(camp_ObjStat=%11)
                then camp_Win;
           end;
       ////////////////////   HELL vs HELL #4    ////////////////////////////////////////////////////////////////////////////
       3 : begin
              with g_PlayersGame[cd_p_player] do
                tmpb1:=(units_uid_c[UID_HKeep ]=0)
                    and(units_uid_c[UID_HAKeep]=0);

              p:=map_KeyPointsL[0].kp_TeamData[MaxPlayers].kptd_OwnerPlayer;
              tmpb2:=false;
              tmpb3:=false;
              if(Scenario_KeyPointsEndConditions(true))then
              begin
                 if(p=cd_p_player)
                 then tmpb2:=true
                 else tmpb3:=true
              end;

              camp_ObjStat:=0;
              SetBBit(@camp_ObjStat,0,not tmpb1);
              SetBBit(@camp_ObjStat,1,    tmpb2);
              SetBBit(@camp_ObjStat,2,not tmpb3);

              if(tmpb3)
              then game_SetStatusWinnerTeam(g_PlayersGame[p].team)
              else
                if(tmpb2)
                then camp_Win
                else
                  if(tmpb1)then
                    if(g_PlayersGame[cd_p_enemy1].units_bld_lc[false]>g_PlayersGame[cd_p_enemy2].units_bld_lc[false])
                    then game_SetStatusWinnerTeam(g_PlayersGame[cd_p_enemy1].team)
                    else game_SetStatusWinnerTeam(g_PlayersGame[cd_p_enemy2].team)
           end;
       ////////////////////   HELL vs HELL #5    ////////////////////////////////////////////////////////////////////////////
       4 : begin
              with g_PlayersGame[cd_p_player] do
                tmpb1:=(units_uid_c[UID_HKeep ]=0)
                    and(units_uid_c[UID_HAKeep]=0);

              p:=map_KeyPointsL[0].kp_TeamData[MaxPlayers].kptd_OwnerPlayer;
              tmpb2:=false;
              tmpb3:=false;
              if(Scenario_KeyPointsEndConditions(true))then
              begin
                 if(p=cd_p_player)
                 then tmpb2:=true
                 else tmpb3:=true
              end;

              camp_ObjStat:=0;
              SetBBit(@camp_ObjStat,0,not tmpb1);
              SetBBit(@camp_ObjStat,1,    tmpb2);
              SetBBit(@camp_ObjStat,2,not tmpb3);

              if(tmpb3)
              then game_SetStatusWinnerTeam(g_PlayersGame[p].team)
              else
                if(tmpb2)
                then camp_Win
                else
                  if(tmpb1)then
                  begin
                     for p:=0 to LastPlayer do
                       if(p<>cd_p_player)then
                         if(g_PlayersGame[p].units_bld_lc[false]>0)then
                         begin
                            game_SetStatusWinnerTeam(g_PlayersGame[p].team);
                            exit;
                         end;
                     game_SetStatusWinnerTeam(g_PlayersGame[cd_p_enemy1].team);
                  end;
           end
       end;
   end;
end;

