const

camp_MaxNMAIUpgrades = 20;

camp_AutoSavePrefix  = 'CampaignAutoSave_';


procedure camp_Init;
begin
   camp_data.cd_lastm:=5;
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
   if(not Game_IsEnded)then
   begin
      camp_data.cd_lastm+=1;
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

procedure camp_AllowUnitsForPlayer(ap:byte;uids:TSoB);
var
i    :byte;
added:shortstring;
begin
   added:='';
   with g_PlayersGame[ap] do
     for i in uids do
       if(units_uid_m[i]<=0)then STRADD(@added,g_uids[i].uid_str_name,sep_comma);

   if(length(added)=0)then exit;

   player_SetAllowedUnits(ap,uids, MaxUnits,false);
   GameLog_Chat(255,LocalPlayer,str_Camp_NewUnits+added);
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

            if(alevel>2)then  // UV,NM
            begin
               res_energyl_cur+=2500;
               res_energyl_max+=2500;
               upgrs_cur[upgr_fprod_build]:=1;
            end;
            if(alevel>1)then
              camp_SetBaseLevelUnitUpgrades(ap,(alevel-1)*2);
            aip_MaxUpgradeLevel:=alevel*2;

            camp_removeAIFlag(ap,aif_base_DefendAlly);
            camp_removeAIFlag(ap,aif_army_early_attack0);
            camp_removeAIFlag(ap,aif_army_early_attack1);
            camp_removeAIFlag(ap,aif_army_scout);
            aip_flags:=aip_flags or aif_cheat_VisBuildings;

            case attackPause of
            -1 : aip_pause_attack:=-fr_fps1*max2i(1,200-55*alevel);
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
var
p,
p_player,
p_ally1,
p_enemy1,
p_enemy2:byte;
begin
   game_DefaultAll;
   g_FixedPositions:=true;
   g_NewObservers  :=false;
   case camp_sel of
   0 : begin  ////  HELL vs HELL
          p_player   :=0;
          LocalPlayer:=p_player;
          UIPlayer   :=p_player;
          case camp_mis_sel of
          0 : begin ////////////////////   HELL vs HELL #1    ////////////////////////////////////////////////////////////////////////////
                 FillChar(camp_data,SizeOf(camp_data),0); // first mission of camp
                 camp_data.cd_lastm :=1;
                 camp_data.cd_NMTime:=fr_fps1*30;

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

                 p_enemy1:=7;

                 // PLAYER
                 camp_SetPlayer(p_player,r_hell,0,ps_human,PlayerName);

                 camp_SetPStart(p_player,map_Size1 div 4,map_Size1 div 3);
                 camp_SetPStartMirror(p_enemy1,p_player);

                 camp_CreateUnit(p_player,map_PlayerStartX[p_player]    ,map_PlayerStartY[p_player]    ,UID_HKeep);
                 camp_CreateUnit(p_player,map_PlayerStartX[p_player]-80 ,map_PlayerStartY[p_player]-100,UID_HGate);

                 player_SetAllowedUnits   (p_player,[ UID_HGate,
                                                      UID_Imp     ], MaxUnits,true);
                 player_SetAllowedUpgrades(p_player,[0..255       ], 0       ,true);

                 with g_PlayersGame[p_player] do a_ability:=[];


                 //  Clan of Bites

                 camp_SetPlayer(p_enemy1,r_hell,1,ps_AI   ,str_Camp_HE_CoB);

                 camp_SetAI(p_enemy1,camp_diff,0,-1);
                 with g_PlayersGame[p_enemy1] do
                 begin
                    aip_MaxUnitLimit  :=ul30;
                    aip_MaxAttackLimit:=0;
                    aip_MaxTowers     :=6;
                    aip_MaxEnergy     :=2000;
                 end;

                 camp_CreateUnit(p_enemy1,map_PlayerStartX[p_enemy1]+110,map_PlayerStartY[p_enemy1]-110,UID_HKeep,60);
                 camp_CreateUnit(p_enemy1,map_PlayerStartX[p_enemy1]-110,map_PlayerStartY[p_enemy1]+110,UID_HKeep,60);
                 camp_CreateUnit(p_enemy1,map_PlayerStartX[p_enemy1]+110,map_PlayerStartY[p_enemy1]+110,UID_HKeep,60);

                 camp_CreateUnitAreaR(p_enemy1,10,map_PlayerStartX[p_enemy1],map_PlayerStartY[p_enemy1],100,UID_Demon,60);


                 player_SetAllowedUnits   (p_enemy1,[ UID_HGate,
                                                     UID_HPools,
                                                     UID_HFTower,
                                                     UID_Demon   ], MaxUnits,true);
                 player_SetAllowedUpgrades(p_enemy1,[ 0..255      ],0        ,true);
                 with g_PlayersGame[p_enemy1] do a_ability:=[];
              end;

          1 : begin ////////////////////   HELL vs HELL #2   //////////////////////////////////////////////////////////////////////////////
                 camp_data.cd_NMTime:=fr_fps1*90;

                 map_Seed         :=10666;
                 map_scenario     :=mc_royale;
                 map_GeneratorT   :=2;
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

                 p_ally1 :=7;
                 p_enemy1:=3;
                 p_enemy2:=1;

                 // PLAYER

                 camp_SetPlayer(p_player,r_hell,0,ps_human,PlayerName);

                 camp_SetPStart(p_player,map_Size1 div 4,map_Size1 div 5);

                 camp_CreateUnit(p_player,map_PlayerStartX[p_player]-100,map_PlayerStartY[p_player]-100,UID_HKeep);
                 camp_CreateUnit(p_player,map_PlayerStartX[p_player]+100,map_PlayerStartY[p_player]+100,UID_HKeep);
                 camp_CreateUnit(p_player,map_PlayerStartX[p_player]-80 ,map_PlayerStartY[p_player]+100,UID_HGate);
                 camp_CreateUnit(p_player,map_PlayerStartX[p_player]+80 ,map_PlayerStartY[p_player]-100,UID_HPools);
                 camp_CreateUnitAreaR(p_player,3,map_PlayerStartX[p_player],map_PlayerStartY[p_player],100,UID_Imp  );
                 camp_CreateUnitAreaR(p_player,3,map_PlayerStartX[p_player],map_PlayerStartY[p_player],100,UID_Demon);

                 player_SetAllowedUnits   (p_player,[ UID_HKeep,
                                                     UID_HGate,
                                                     UID_HPools,
                                                     UID_HFTower,
                                                     UID_Imp,
                                                     UID_Demon             ], MaxUnits,true);
                 player_SetAllowedUpgrades(p_player,[ upgr_hell_DistDamage1,
                                                     upgr_hell_UnitArmor ,
                                                     upgr_hell_MeleeDamage,
                                                     upgr_hell_Regeneration,
                                                     upgr_hell_PainFactor ,
                                                     upgr_hell_BuilderR    ], 2       ,true);
                 with g_PlayersGame[p_player] do a_ability:=[uab_ToHAKeep];

                 // Tribe of Evil (green)
                 camp_SetPStart(p_enemy1,(map_Size1 div 7)*4,map_Size1-(map_Size1 div 6));

                 camp_SetPlayer(p_enemy1,r_hell,1,ps_AI   ,str_Camp_HE_ToE);
                 camp_SetAI(p_enemy1,camp_diff,0  ,-1);
                 with g_PlayersGame[p_enemy1] do
                 begin
                    aip_MaxAttackLimit:=aip_MaxUnitLimit div 3;
                    aip_MaxTowers     :=2+camp_diff;
                 end;
                 camp_removeAIFlag(p_enemy1,aif_base_smart_order);

                 camp_CreateUnit(p_enemy1,map_PlayerStartX[p_enemy1]    ,map_PlayerStartY[p_enemy1]-100,UID_HKeep,60);
                 camp_CreateUnit(p_enemy1,map_PlayerStartX[p_enemy1]-110,map_PlayerStartY[p_enemy1]+100,UID_HKeep,60);
                 camp_CreateUnit(p_enemy1,map_PlayerStartX[p_enemy1]+110,map_PlayerStartY[p_enemy1]+100,UID_HKeep,60);
                 camp_CreateUnitAreaR(p_enemy1,5,map_PlayerStartX[p_enemy1],map_PlayerStartY[p_enemy1],100,UID_Revenant,60);
                 camp_CreateUnitAreaR(p_enemy1,5,map_PlayerStartX[p_enemy1],map_PlayerStartY[p_enemy1],100,UID_Baron   ,60);
                 camp_CreateUnitAreaR(p_enemy1,5,map_PlayerStartX[p_enemy1],map_PlayerStartY[p_enemy1],100,UID_Demon   ,60);

                 player_SetAllowedUnits   (p_enemy1,[ UID_HAKeep,
                                                      UID_HGate,
                                                      UID_HPools,
                                                      UID_HFTower,
                                                      UID_HTeleport          ], MaxUnits,true );
                 player_SetAllowedUnits   (p_enemy1,[ UID_Demon,
                                                      UID_Baron,
                                                      UID_Revenant           ], 30      ,false);
                 player_SetAllowedUpgrades(p_enemy1,[ upgr_hell_DistDamage1,
                                                      upgr_hell_UnitArmor ,
                                                      upgr_hell_MeleeDamage,
                                                      upgr_hell_Regeneration,
                                                      upgr_hell_PainFactor ,
                                                      upgr_hell_BuilderR     ], 5       ,true );
                 with g_PlayersGame[p_enemy1] do a_ability:=[uab_ToHAKeep];

                 // Hell Knights
                 camp_SetPStart(p_enemy2,map_Size1-(map_Size1 div 6),(map_Size1 div 7)*3);

                 camp_SetPlayer(p_enemy2,r_hell,2,ps_AI   ,str_Camp_HE_HN);
                 camp_SetAI(p_enemy2,camp_diff,0  ,-1);
                 with g_PlayersGame[p_enemy2] do
                 begin
                    aip_MaxAttackLimit:=aip_MaxUnitLimit div 3;
                    aip_MaxTowers     :=2+camp_diff;
                 end;
                 camp_removeAIFlag(p_enemy1,aif_base_smart_order);

                 camp_CreateUnit(p_enemy2,map_PlayerStartX[p_enemy2]+110,map_PlayerStartY[p_enemy2]-110,UID_HKeep,60);
                 camp_CreateUnit(p_enemy2,map_PlayerStartX[p_enemy2]-100,map_PlayerStartY[p_enemy2]+110,UID_HKeep,60);
                 camp_CreateUnit(p_enemy2,map_PlayerStartX[p_enemy2]+110,map_PlayerStartY[p_enemy2]+60 ,UID_HKeep,60);
                 camp_CreateUnitAreaR(p_enemy2,5,map_PlayerStartX[p_enemy2],map_PlayerStartY[p_enemy2],100,UID_Cacodemon,60);
                 camp_CreateUnitAreaR(p_enemy2,5,map_PlayerStartX[p_enemy2],map_PlayerStartY[p_enemy2],100,UID_Knight   ,60);
                 camp_CreateUnitAreaR(p_enemy2,5,map_PlayerStartX[p_enemy2],map_PlayerStartY[p_enemy2],100,UID_Imp      ,60);

                 player_SetAllowedUnits   (p_enemy2,[ UID_HAKeep,
                                                      UID_HGate,
                                                      UID_HPools,
                                                      UID_HFTower,
                                                      UID_HEyeNest           ], MaxUnits,true );
                 player_SetAllowedUnits   (p_enemy2,[ UID_Imp,
                                                      UID_Knight,
                                                      UID_Cacodemon          ], 30      ,false);
                 player_SetAllowedUpgrades(p_enemy2,[ upgr_hell_DistDamage1,
                                                      upgr_hell_UnitArmor ,
                                                      upgr_hell_MeleeDamage,
                                                      upgr_hell_Regeneration,
                                                      upgr_hell_PainFactor ,
                                                      upgr_hell_BuilderR     ],5        ,true );

                 with g_PlayersGame[p_enemy2] do a_ability:=[uab_ToHAKeep];
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
//var i:integer;
begin
   if(g_cycle_regen=0)and(camp_diff=4)then
     with camp_data do
       if(cd_NMTime>0)then
         camp_NightmareLvlUp(g_tick div cd_NMTime);

   case camp_sel of
   0 : case camp_mis_sel of
       0 : if(g_cycle_regen=0)then
           begin      //  HELL vs HELL #1
              if(g_PlayersGame[0].units_bld_lc[false]>=ul15)then
                with g_PlayersGame[7] do
                  if(aip_MaxAttackLimit=0)then
                  begin
                     aip_MaxUnitLimit  +=ul15*camp_diff;
                     aip_MaxAttackLimit:=aip_MaxUnitLimit div 3;
                     upgrs_cur[upgr_fprod_unit]:=1;
                  end;

              with g_PlayersGame[LocalPlayer] do
                if(units_uid_c[UID_HKeep]=0)
                then game_SetStatusWinnerTeam(7)
                else
                  if (res_energyl_max>=2000)
                  and(g_PlayersGame[7].units_bld_lc[true]=0)
                  and(units_uid_c[UID_Imp  ]>=30)
                  and(units_uid_c[UID_HGate]>=10)
                  then camp_Win;
           end;

       1 : if(g_cycle_regen=0)then
           begin
              if(g_PlayersGame[3].units_bld_lc[true]=0)then
                camp_AllowUnitsForPlayer(LocalPlayer,[ UID_Baron,
                                                       UID_Revenant,
                                                       UID_HAKeep  ,
                                                       UID_HTeleport]);

              if(g_PlayersGame[1].units_bld_lc[true]=0)then
                camp_AllowUnitsForPlayer(LocalPlayer,[ UID_Knight,
                                                       UID_Cacodemon,
                                                       UID_HAKeep   ,
                                                       UID_HEyeNest ]);

              if (g_PlayersGame[LocalPlayer].units_uid_c[UID_HKeep ]=0)
              and(g_PlayersGame[LocalPlayer].units_uid_c[UID_HAKeep]=0)
              then game_SetStatusWinnerTeam(1)
              else
                if (g_PlayersGame[1].units_bld_lc[true]=0)
                and(g_PlayersGame[3].units_bld_lc[true]=0)
                then camp_Win;
           end;

       end;
   end;
end;

