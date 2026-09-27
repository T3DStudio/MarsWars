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

procedure camp_removeAIFlag(ap:byte;flag:cardinal);
begin
   with g_PlayersGame[ap] do
     if((aip_flags and flag)>0)then aip_flags:=aip_flags xor flag;
end;

procedure camp_SetAI(ap,alevel:byte;attackDelay,attackPause:integer);
begin
   with g_PlayersGame[ap] do
     case alevel of
     0..4           // ITYTD NTR HMP UV NM
       : begin
            if(alevel>3)then alevel:=3; // UV = NM
            case alevel of
            0 :  aip_skill:=1;
            1 :  aip_skill:=3;
            else aip_skill:=5;
            end;
            ai_PlayerSetSkirmishSettings(ap);
            case alevel of
            2: begin // HMP
                  res_energyl_cur:=1000;
                  res_energyl_max:=1000;
               end;
            3: begin // UV,NM
                  res_energyl_cur:=3000;
                  res_energyl_max:=3000;
                  upgrs_cur[upgr_fprod_build]:=1;
               end;
            end;
            if(alevel>1)then
              camp_SetBaseLevelUnitUpgrades(ap,(alevel-1)*2);
            aip_MaxUpgradeLevel:=alevel*2;

            camp_removeAIFlag(ap,aif_base_DefendAlly   );
            camp_removeAIFlag(ap,aif_base_suicide      );
            camp_removeAIFlag(ap,aif_army_early_attack0);
            camp_removeAIFlag(ap,aif_army_early_attack1);
            camp_removeAIFlag(ap,aif_army_scout);
            aip_flags:=aip_flags or aif_cheat_VisBuildings;

            case attackPause of
            -1 : aip_pause_attack:=-fr_fps1*max2i(1,180-45*alevel); // 45 90 135 180
            1..attackPause.MaxValue
               : aip_pause_attack:=-fr_fps1*attackPause;
            end;

            if(attackDelay>=0)then aip_delay_attack:= fr_fps1*attackDelay;
         end;
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

procedure camp_CreateMarker(playeri:byte;ux,uy:integer);
begin
   case g_PlayersGame[LocalPlayer].race of
   r_hell: unit_add(ux,uy,0,UID_HMarker,playeri,true,false,0);
   r_uac :;
   end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//   MISSIONS START
//

procedure cmp_StartMission;
var p:byte;
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

                 camp_SetAI(p,cd_camp_skill,210,-1);
                 with g_PlayersGame[p] do
                 begin
                    aip_MaxUnitLimit  :=ul30;
                    aip_MaxAttackLimit:=0;//ul2+ul2*camp_skill; //ul2..ul10
                    aip_MaxTowers     :=6;
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
                 camp_SetPStart(p,(map_Size1 div 4),map_Size1-(map_Size1 div 4));

                 camp_SetPlayer(p,r_hell,1,ps_AI   ,str_Camp_HE_EE);
                 camp_SetAI(p,cd_camp_skill,0  ,-1);
                 with g_PlayersGame[p] do
                 begin
                    aip_MaxAttackLimit:=aip_MaxUnitLimit div 3;
                    aip_MaxTowers     :=2+cd_camp_skill*2;
                 end;
                 camp_removeAIFlag(p,aif_base_smart_order);

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
                 camp_SetPStart(p,map_Size1-(map_Size1 div 5),map_Size1-(map_Size1 div 3));

                 camp_SetPlayer(p,r_hell,2,ps_AI   ,str_Camp_HE_PoA);
                 camp_SetAI(p,cd_camp_skill,0  ,-1);
                 with g_PlayersGame[p] do
                 begin
                    aip_MaxAttackLimit:=aip_MaxUnitLimit div 3;
                    aip_MaxTowers     :=2+cd_camp_skill;
                    aip_flags:= aip_flags or aif_base_advanceMain;
                    aip_flags:= aip_flags or aif_base_advanceOther;
                 end;
                 camp_removeAIFlag(p,aif_base_smart_order);

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
                 camp_data.cd_NMTime:=fr_fps1*125;

                 map_Seed         :=10666;
                 map_scenario     :=mc_koth;
                 map_GeneratorT   :=2;
                 map_Size1        :=5750;
                 map_Template     :=mapt_temple;
                 map_Symmetry     :=maps_lineV;
                 map_MaxPlayers   :=8;
                 map_GenOnObstacle:=true;
                 map_ObstaclesGap :=40;

                 map_Seed2RandomBase;
                 camp_ClearPStarts;

                 cd_p_ally1 :=1;
                 cd_p_ally2 :=3;

                 cd_p_enemy1:=7;
                 cd_p_enemy2:=2;
                 cd_p_enemy3:=6;

                 // PLAYER

                 p:=cd_p_player;

                 camp_SetPlayer(p,r_hell,0,ps_human,PlayerName);

                 camp_SetPStart(p,map_Size1-(map_Size1 div 5),(map_Size1 div 5));

                 camp_CreateUnit(p,map_PlayerStartX[p],map_PlayerStartY[p],UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]-g_uids[UID_HKeep].uid_r*2,map_PlayerStartY[p],UID_HKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]+g_uids[UID_HKeep].uid_r*2,map_PlayerStartY[p],UID_HKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p],map_PlayerStartY[p]+150,UID_HGate);
                 camp_CreateUnit(p,map_PlayerStartX[p],map_PlayerStartY[p]-150,UID_HPools);

                 camp_CreateUnitAreaR(p,5,map_PlayerStartX[p]-100,map_PlayerStartY[p]-100,100,UID_Imp     );
                 camp_CreateUnitAreaR(p,3,map_PlayerStartX[p]-100,map_PlayerStartY[p]-100,100,UID_Demon   );
                 camp_CreateUnitAreaR(p,5,map_PlayerStartX[p]-100,map_PlayerStartY[p]-100,100,UID_Revenant);
                 camp_CreateUnitAreaR(p,2,map_PlayerStartX[p]-100,map_PlayerStartY[p]-100,100,UID_Baron   );

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
                                               upgr_hell_BuildRestore], 3       ,true);

                 with g_PlayersGame[p] do a_ability:=[uab_ToHAKeep,uab_ToHGate,uab_ToHPools,uab_HEyeVision,uab_HEyeSpawn,uab_Teleport,uab_Recall];

                 // ALLY 1     Servants of Fire
                 p:=cd_p_ally1;

                 camp_SetPStart(p ,map_Size1-(map_Size1 div 7),map_Size1 div 2);

                 camp_SetPlayer(p,r_hell,0,ps_AI   ,str_Camp_HE_SoF);
                 camp_SetAI(p,cd_camp_skill,0  ,-1);

                 camp_CreateUnit(p,map_PlayerStartX[p]    ,map_PlayerStartY[p]    ,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]-200,map_PlayerStartY[p]    ,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]+150,map_PlayerStartY[p]-150,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]+150,map_PlayerStartY[p]+150,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]+200,map_PlayerStartY[p]    ,UID_HMonastery);

                 camp_CreateUnitAreaR(p,5,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Imp     );
                 camp_CreateUnitAreaR(p,3,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Archvile);
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
                                                UID_Archvile,
                                                UID_Pain      ], MaxUnits,true);
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


                 // ALLY 2     Cyber Division
                 p:=cd_p_ally2;

                 camp_SetPStart(p ,map_Size1-(map_Size1 div 5),map_Size1-(map_Size1 div 5));

                 camp_SetPlayer(p,r_hell,0,ps_AI   ,str_Camp_HE_CB);
                 camp_SetAI(p,cd_camp_skill,0  ,-1);

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
                 p:=cd_p_enemy1;
                 camp_SetPStart(p ,(map_Size1 div 5),(map_Size1 div 5));

                 camp_SetPlayer(p,r_hell,1,ps_AI   ,str_Camp_HE_BS);
                 camp_SetAI(p,cd_camp_skill,0  ,-1);
                 with g_PlayersGame[p] do
                 begin
                    aip_MaxTowers     :=2+cd_camp_skill*2;
                    aip_MinTowers     :=aip_MaxTowers;
                    upgrs_cur[upgr_hell_Spectre]:=1;
                 end;

                 camp_CreateUnit(p,map_PlayerStartX[p]    ,map_PlayerStartY[p]    ,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]+200,map_PlayerStartY[p]    ,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]-150,map_PlayerStartY[p]+150,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]-150,map_PlayerStartY[p]-150,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]-200,map_PlayerStartY[p]    ,UID_HFortress );
                 camp_CreateUnit(p,map_PlayerStartX[p]+150,map_PlayerStartY[p]-150,UID_HMonastery);

                 camp_CreateUnitAreaR(p,10,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Revenant);
                 camp_CreateUnitAreaR(p,10,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Demon);

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
                 player_SetAllowedUnits   (p ,[ UID_Cacodemon ], 10      ,false);

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

                 camp_SetPlayer(p,r_hell,1,ps_AI   ,str_Camp_HE_BS);
                 camp_SetAI(p,cd_camp_skill,0  ,-1);
                 with g_PlayersGame[p] do
                 begin
                    aip_MaxTowers     :=5+cd_camp_skill*2;
                    aip_MinTowers     :=aip_MaxTowers;
                    upgrs_cur[upgr_hell_TowerBlink]:=1;
                    upgrs_cur[upgr_hell_TotemInvis]:=1;
                 end;

                 camp_CreateUnit(p,map_PlayerStartX[p]    ,map_PlayerStartY[p]    ,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]+200,map_PlayerStartY[p]    ,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]-150,map_PlayerStartY[p]+150,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]-150,map_PlayerStartY[p]-150,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]-200,map_PlayerStartY[p]    ,UID_HFortress );
                 camp_CreateUnit(p,map_PlayerStartX[p]+150,map_PlayerStartY[p]-150,UID_HMonastery);

                 camp_CreateUnitAreaR(p,10,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Knight  );
                 camp_CreateUnitAreaR(p,10,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Baron   );
                 camp_CreateUnitAreaR(p,5 ,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_ArchVile);

                 player_SetAllowedUnits   (p ,[ UID_HKeep,
                                                UID_HAKeep,
                                                UID_HGate,
                                                UID_HPools,
                                                UID_HFTower,
                                                UID_HTeleport,
                                                UID_HMonastery,
                                                UID_HTotem,
                                                UID_Knight,
                                                UID_Baron,
                                                UID_ArchVile ], MaxUnits,true);
                 player_SetAllowedUnits   (p ,[ UID_Cacodemon], 10      ,false);
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
                                                upgr_hell_TotemInvis  ], 4       ,true);

                 // ENEMY 3    Clan of Burning Sky
                 p:=cd_p_enemy3;
                 camp_SetPStart(p ,(map_Size1 div 5),map_Size1-(map_Size1 div 5));


                 camp_SetPlayer(p,r_hell,1,ps_AI   ,str_Camp_HE_CoBS);
                 camp_SetAI(p,cd_camp_skill,0  ,-1);
                 with g_PlayersGame[p] do
                 begin
                    aip_MaxTowers     :=2+cd_camp_skill*2;
                    aip_MinTowers     :=aip_MaxTowers;
                    aip_flags := aip_flags or aif_ability_other;
                 end;
                 camp_removeAIFlag(p,aif_army_smart_micro);

                 camp_CreateUnit(p,map_PlayerStartX[p]    ,map_PlayerStartY[p]    ,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]+200,map_PlayerStartY[p]    ,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]-150,map_PlayerStartY[p]+150,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]-150,map_PlayerStartY[p]-150,UID_HAKeep);
                 camp_CreateUnit(p,map_PlayerStartX[p]-200,map_PlayerStartY[p]    ,UID_HFortress );
                 camp_CreateUnit(p,map_PlayerStartX[p]+150,map_PlayerStartY[p]-150,UID_HMonastery);
                 camp_CreateUnit(p,map_PlayerStartX[p]+150,map_PlayerStartY[p]+150,UID_HAltar);
                 camp_CreateUnit(p,map_PlayerStartX[p]+ 50,map_PlayerStartY[p]-250,UID_HAltar);
                 camp_CreateUnit(p,map_PlayerStartX[p]-280,map_PlayerStartY[p]+150,UID_HAltar);
                 camp_CreateUnit(p,map_PlayerStartX[p]-280,map_PlayerStartY[p]-150,UID_HAltar);

                 camp_CreateUnitAreaR(p,15,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Cacodemon);
                 camp_CreateUnitAreaR(p,5 ,map_PlayerStartX[p],map_PlayerStartY[p],100,UID_Pain     );

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
                                                UID_LostSoul], MaxUnits,true);
                 player_SetAllowedUpgrades(p ,[ upgr_hell_DistDamage1,
                                                upgr_hell_UnitArmor ,
                                                upgr_hell_BuildArmor,
                                                upgr_hell_MeleeDamage,
                                                upgr_hell_Regeneration,
                                                upgr_hell_PainFactor ,
                                                upgr_hell_BuilderR,
                                                upgr_hell_TowerR    ,
                                                upgr_hell_UnitSightR,
                                                upgr_hell_DistDamage2,
                                                upgr_hell_TeleportCD,
                                                upgr_hell_T2TNoCD,
                                                upgr_hell_BuildRestore], 4       ,true);
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
tmpb2:boolean;
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
              begin
                 if(g_PlayersGame[cd_p_player].units_bld_lc[false]>=ul30)and(aip_MaxAttackLimit<=ul10)then
                 begin
                    aip_MaxUnitLimit  +=ul20*cd_camp_skill;
                    aip_MaxAttackLimit+=aip_MaxUnitLimit div 3;
                    upgrs_cur[upgr_fprod_unit]:=1;
                 end;
                 //writeln(' delay_attack=',aip_delay_attack,' timer_attack=',aip_timer_attack,' pause_attack=',aip_pause_attack,' MaxAttackLimit=',aip_MaxAttackLimit,' LP.units_bld_lc=',g_PlayersGame[LocalPlayer].units_bld_lc[false]);
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

              tmpb2:=(map_KeyPointsL[0].kp_TeamData[MaxPlayers].kptd_OwnerTeam=g_PlayersGame[cd_p_enemy1].team);

              camp_ObjStat:=0;
              SetBBit(@camp_ObjStat,0,not tmpb1);
              SetBBit(@camp_ObjStat,1,not tmpb2);
              SetBBit(@camp_ObjStat,2,(map_KeyPointsL[0].kp_TeamData[MaxPlayers].kptd_OwnerTeam=g_PlayersGame[cd_p_player].team));
              SetBBit(@camp_ObjStat,3,(g_PlayersGame[cd_p_enemy1].units_bld_lc[true]=0)
                                   and(g_PlayersGame[cd_p_enemy2].units_bld_lc[true]=0)
                                   and(g_PlayersGame[cd_p_enemy3].units_bld_lc[true]=0) );

              if(tmpb1)
              or(tmpb2)
              then game_SetStatusWinnerTeam(g_PlayersGame[cd_p_enemy1].team)
              else
                if(camp_ObjStat=%1111)
                then camp_Win;
           end;
       end;
   end;
end;

