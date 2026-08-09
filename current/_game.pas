
procedure player_SetSkirmishTech(playerN:byte);
begin
   with g_PlayersGame[playerN] do
   begin
      player_SetAllowedUnits(playerN,[ UID_HKeep         ..UID_HBarracks,
                                      UID_LostSoul      ..UID_ZBFGMarine,
                                      UID_UCommandCenter..UID_URMStation,
                                      UID_Engineer      ..UID_Flyer     ]-[UID_HEye],
                                    MaxUnits,true );

      player_SetAllowedUnits(playerN,[ UID_LostSoul,
                                      UID_Phantom ],
                                    scirmish_MaxLost
                                            ,false);
      player_SetAllowedUnits(playerN,[ UID_HAltar  ],
                                    scirmish_MaxHAltar
                                            ,false);


      player_SetAllowedUpgrades(playerN,[0..255],255,true);

      a_ability:=[1..255];
   end;
end;

function players_Swap(pSlot,pTarget:byte;Check:boolean):boolean;
var
  tgp:TPlayerDataGame;
  tnp:TPlayerDataTemp;
t0,t1:byte;
begin
   //pSlot - target slot
   //pTarget - player target
   //pTarget -> pSlot
   players_Swap:=false;

   if(g_started)
   or(g_LobbyTimer>0)
   {$IFDEF _FULLGAME}
   or(g_type=gt_campaing)
   {$ENDIF}then exit;

   if(pSlot>LastPlayer)
   or(pTarget>LastPlayer)
   then exit;

   if(g_PlayersGame[pSlot].state<>ps_none)
   or(pTarget=pSlot)then exit;

   players_Swap:=true;

   if(Check)then exit;

   {$IFDEF _FULLGAME}
   if(net_status=ns_client)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_lobby_PJumpToSlot);
      net_writebyte(pSlot);
      net_send(net_cl_svip,net_cl_svport);
      exit;
   end;
   {$ENDIF}

   t0:=g_PlayersGame[pSlot  ].team;
   t1:=g_PlayersGame[pTarget].team;

   tgp:=g_PlayersGame[pSlot];
   g_PlayersGame[pSlot  ]:=g_PlayersGame[pTarget];
   g_PlayersGame[pTarget]:=tgp;

   tnp:=g_PlayersTemp[pSlot];
   g_PlayersTemp[pSlot  ]:=g_PlayersTemp[pTarget];
   g_PlayersTemp[pTarget]:=tnp;

   g_PlayersGame[pSlot  ].pnum:=pSlot;
   g_PlayersGame[pTarget].pnum:=pTarget;

   if(pSlot  >=map_MaxPlayers)then
   g_PlayersGame[pSlot  ].isobserver:=true;
   g_PlayersGame[pTarget].isobserver:=false;

   g_PlayersGame[pSlot  ].team:=player_ValidateTeam(pSlot  ,t1);
   g_PlayersGame[pTarget].team:=player_ValidateTeam(pTarget,t0);

   {$IFDEF _FULLGAME}
   if(LocalPlayer=pTarget)then LocalPlayer:=pSlot
   else
     if(LocalPlayer=pSlot)then LocalPlayer:=pTarget;

   menu_update:=true;
   {$ENDIF}
end;

procedure player_SetState(playerN,newState:byte);
begin
   with g_PlayersGame[playerN] do
   begin
      case newState of
ps_None : begin isready:=false;if(not g_started)then
                               name :='';       end;
ps_AI   : begin isready:=true; name :=ai_name(aip_skill,playerN);isobserver:=false;end;
ps_human: begin isready:=false;name :='';               end;
      end;
      team :=player_ValidateTeam(playerN,team);
      state:=newState;
   end;
end;

procedure player_Kill(playerN:byte;instant:boolean);
var u:integer;
begin
   for u:=1 to MaxUnits do
     with g_punits[u]^ do
       if(playeri=playerN)then
         unit_kill(g_punits[u],instant,true,false,true,true);
end;

procedure player_SetDefaults(p:byte);
begin
   with g_PlayersGame[p] do
   begin
      aip_skill :=player_default_ai_level;
      race      :=r_random;
      mrace     :=r_random;
      team      :=p;
      isready   :=false;
      pnum      :=p;
      isobserver:=false;
      isdefeated:=false;
      isrevealed:=false;
      log_n     :=0;
      log_n_cl  :=0;
   end;
end;

procedure players_SetDefaults;
var p:byte;
begin
   FillChar(ai_TeamAlarms,SizeOf(ai_TeamAlarms),0);

   FillChar(g_PlayersScore,SizeOf(g_PlayersScore),0);
   FillChar(g_PlayersGame ,SizeOf(g_PlayersGame ),0);
   FillChar(g_PlayersTemp ,SizeOf(g_PlayersTemp ),0);
   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
     begin
        player_SetDefaults(p);
        player_SetState(p,ps_None);
        player_SetSkirmishTech(p);
        player_ClearLog(p);
        log_EnergyCheckTimer:=0;

        //res_HellPower:=30000;
        //res_UACLoot  :=30000;
     end;

   {$IFDEF _FULLGAME}
   LocalPlayer:=0;
   with g_PlayersGame[LocalPlayer] do
   begin
      state:=ps_human;
      name :=PlayerName;
   end;

   KeyPointColorDefaultNormal:=c_ltgray;
   KeyPointColorDefaultShadow:=gfx_ShadowColor(KeyPointColorDefaultNormal);

   PlayerColorDefaultNormal  :=c_white;
   PlayerColorDefaultShadow  :=gfx_ShadowColor(PlayerColorDefaultNormal);

   PlayerColorsSchemeDefault[0]:=c_red;
   PlayerColorsSchemeDefault[1]:=c_orange;
   PlayerColorsSchemeDefault[2]:=c_yellow;
   PlayerColorsSchemeDefault[3]:=c_lime;
   PlayerColorsSchemeDefault[4]:=c_aqua;
   PlayerColorsSchemeDefault[5]:=c_blue;
   PlayerColorsSchemeDefault[6]:=c_violet;
   PlayerColorsSchemeDefault[7]:=c_purple;
   {$ENDIF}
end;

procedure game_ShuffleAINames;
var
u,i:byte;
ts :shortstring;
begin
   ai_names_l:=ai_names_o;
   for u:=0 to ai_names_max-1 do
   for i:=0 to ai_names_max-1 do
     if(u<>i)and( (map_seed and (1 shl ((map_seed+byte(u*3)+i) mod 32)))>0 )then
     begin
        ts:=ai_names_l[i];
        ai_names_l[i]:=ai_names_l[u];
        ai_names_l[u]:=ts;
     end;
end;

procedure game_DefaultAll;
var u:integer;
begin
   randomize;

   g_tick         :=0;
   g_status       :=gs_running;

   KeyPoints_Clear;
   FillChar(g_missiles ,SizeOf(g_missiles ),0);
   FillChar(g_units    ,SizeOf(g_units    ),0);
   for u:=0 to MaxUnits do
     with g_units[u] do
     begin
        hits  :=hits_dead;
        player:=@g_PlayersGame[playeri];
        uid   :=@g_units  [uidi   ];
     end;
   LastCreatedUnit :=0;
   LastCreatedUnitP:=@g_units[LastCreatedUnit];

   players_SetDefaults;

   UnitStepTicks := 8;

   g_royal_RCur  := g_royal_RCur.MaxValue;

   g_cycle_order := 0;
   g_cycle_regen := 0;
   g_LobbyTimer  := 0;

   {$IFDEF DEBUG0}
   test_InstaProd:=false;
   {$ENDIF}

   menu_update:=true;

   {$IFDEF _FULLGAME}
   ServerSide     :=true;

   sys_uncappedFPS:=false;

   vid_ScreenSpritesS:=0;

   ui_cam_x:=-ui_CtrlPanelW;
   ui_cam_y:=0;
   ui_Camera_Bounds;

   ui_blink_timer1:=0;
   ui_blink_timer2:=0;
   ui_tab :=0;
   ui_ScoresRebuild:=true;

   FillChar(ui_alarms,SizeOf(ui_alarms),0);
   FillChar(g_effects,SizeOf(g_effects),0);
   FillChar(g_PlayerAPM,SizeOf(g_PlayerAPM),0);

   ui_InGameChat :=0;
   net_chat_str:='';
   net_cl_svttl:=0;
   net_cl_Hoster:=255;

   ui_umark_u:=0;
   ui_umark_t:=0;

   mouse_select_xs0:=NOTSET;
   mouse_select_ys0:=NOTSET;
   m_brush:=co_empty;

   ui_fog   :=true;

   svld_str_fname:='';

   rpls_pnu    :=0;
   ui_playerPOV:=false;
   rpls_pstate :=rpls_none;

   PlayersUpdateColorSchema(LocalPlayer);
   {$ENDIF}

   Map_Make;
end;

{$IFDEF _FULLGAME}
procedure game_LocalStart;
var p:byte;
begin
   if(g_PlayersGame[LocalPlayer].isobserver)then
   begin
      ui_tab  :=tab_controls;
      UIPlayer:=MaxPlayers;
      for p:=0 to LastPlayer do
        with g_PlayersGame[p] do
          if (state>ps_none)
          and(not isobserver)
          and(not isdefeated)then break;
      if(p<MaxPlayers)
      then ui_Camera_MoveToPoint(map_PlayerStartX[p],map_PlayerStartY[p])
      else ui_Camera_MoveToPoint(map_SizeH,map_SizeH);
   end
   else
   begin
      UIPlayer :=LocalPlayer;
      ui_Camera_MoveToPoint(map_PlayerStartX[LocalPlayer],map_PlayerStartY[LocalPlayer]);
   end;
   ui_log_LastTimer:=0;
   rpls_RecordTryPause:=0;
   if(snd_RenewMusicList)then
     snd_GameMusicReLoad;
end;

procedure game_LocalEnd;
begin
   Scenario_KeyPointsEndGameClientFix;
   game_SetStatusDefeatedNTeam(g_status-gs_win_team0);
   ui_ScoresRebuild:=true;
   if(not ui_ScoresShow)then
     ui_ToggleShowScores;
end;

{$include _replays.pas}
{$ENDIF}

function player_Surrender(pid:byte;check:boolean):boolean;
begin
   player_Surrender:=false;

   if(not g_started)
   or(pid>LastPlayer)
   {$IFDEF _FULLGAME}
   or(rpls_pstate=rpls_read)
   {$ENDIF}
   or(not g_NewObservers)
   or(g_started and game_IsEnded)then exit;

   with g_PlayersGame[pid] do
     if(state<>ps_Human)
     or(armylimit<=0)
     or(units_all_e<=0)
     or(isdefeated)
     or(isobserver)then exit;

   {$IFDEF _FULLGAME}
   if (net_status=ns_client)
   and(net_cl_svttl>=TTLServer)then exit;
   {$ENDIF}

   player_Surrender:=true;
   if(check)then exit;

   {$IFDEF _FULLGAME}
   if(net_status=ns_client)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_PlayerSurrender);
      net_send(net_cl_svip,net_cl_svport);
      exit;
   end;
   {$ENDIF}

   GameLog_PlayerSurrender(pid);
   player_Kill(pid,true);
end;

procedure game_RemoveAIObservers;
var p:byte;
begin
   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
       if(p>=map_MaxPlayers)and(state=ps_AI)then player_SetState(p,ps_none);
end;


procedure game_MakeSkirmishBase(x,y:integer;playerN,ubuilder,ubarrack:byte);
var i:integer;
begin
   unit_add(x,y,0,ubuilder,playerN,true,false,0);
   i:=round((g_uids[ubuilder].uid_r+g_uids[ubarrack].uid_r)/1.415);
   unit_add(x-sign(map_SizeH-x,true)*i,
            y-sign(map_SizeH-y,true)*i,0,ubarrack,playerN,true,false,0);
end;

procedure game_StartSkirmish;
var p:byte;
begin
   g_royal_RCur:=g_royal_Rmax;
   if(not g_FixedPositions)then map_ShuffleStarts(true,map_scenario in mc_fixed_teams);

   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
       if(p>=map_MaxPlayers)then isobserver:=true;

   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
       if(isobserver)then
       begin
          team:=0;
          race:=r_hell;
       end
       else
       begin
          team:=player_ValidateTeam(p,team);

          if(state=ps_None)then
            if(g_AISlots>0)then
            begin
               aip_skill:=g_AISlots;
               race     :=r_random;
               player_SetState(p,ps_AI);
            end;

          if(race=r_random)then race:=1+random(r_count);

          if(state=ps_human)then aip_skill:=player_default_ai_level;//g_AISlots
       end;

   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
       if(state<>ps_None)then
       begin
          player_SetSkirmishTech(p);
          ai_PlayerSetSkirmishSettings(p);
          if(not isobserver)then
            case race of
            r_hell: game_MakeSkirmishBase(map_PlayerStartX[p],map_PlayerStartY[p],p,UID_HKeep         ,UID_HGate    );
            r_uac : game_MakeSkirmishBase(map_PlayerStartX[p],map_PlayerStartY[p],p,UID_UCommandCenter,UID_UBarracks);
            end;
       end;

   {$IFDEF _FULLGAME}
   game_LocalStart;
   {$ENDIF}
end;

function game_Start(check:boolean):boolean;
begin
   game_Start:=false;

   if(g_started)
   or(net_status=ns_client)
   then exit;

   {$IFDEF _FULLGAME}
   case g_type of
   gt_campaing: if(camp_sel<0)
                or(camp_size<=camp_sel)
                then exit
                else
                  if(camp_mis_sel<0)
                  or(min2i(camp_data.cd_lastm,camp_mis_size[camp_sel])<=camp_mis_sel)
                  then exit;
   gt_scirmish: if(not players_AllReady)
                or(players_NonObserversCount<2)
                then exit;
   else exit;
   end;
   {$ELSE}
   if(not players_AllReady)
   or(players_NonObserversCount<2)
   then exit;
   {$ENDIF}

   game_Start:=true;

   if(check)then exit;

   map_Seed2RandomBase;
   {$IFDEF _FULLGAME}
   case g_type of
   gt_campaing: cmp_StartMission;
   gt_scirmish: game_StartSkirmish;
   else exit;
   end;
   {$ELSE}
   Game_StartSkirmish;
   {$ENDIF}
   game_ScoresInit;

   {$IFDEF _FULLGAME}
   unit_UICountersAll;
   ui_EnableControlActs;
   menu_ItemSelected:=0;
   MainMenu :=false;
   {$ELSE}
   menu_update:=true;
   {$ENDIF}
   g_started:=true;
end;

function game_Break(check:boolean):boolean;
begin
   game_Break:=false;

   if(not g_started)
   or(net_status=ns_client)then exit;

   game_Break:=true;

   if(check)then exit;

   {$IFDEF _FULLGAME}
   case rpls_pstate of
   rpls_read : begin
                  replay_Abort;
                  menu_page:=mi_replays;
                  g_type:=0;
               end;
   rpls_write: replay_Abort;
   end;
   if(g_type=gt_campaing)then // next mission
     if(game_IsEnded)then
       with g_PlayersGame[LocalPlayer] do
         if((gs_win_team0+team)=g_status)then
           if(0<=camp_sel)and(camp_sel<camp_size)then
           if(0<=camp_mis_sel)and(camp_mis_sel<(camp_mis_size[camp_sel]-1))then camp_mis_sel+=1;

   menu_ItemSelected:=0;
   {$ENDIF}
   g_started:=false;
   game_DefaultAll;
end;

{$IFDEF _FULLGAME}
function game_PauseToggle(check:boolean):boolean;
begin
   game_PauseToggle:=false;

   case net_status of
   ns_client  : case g_status of
                gs_running,
                gs_paused0..
                gs_paused7  : begin
                              game_PauseToggle:=true;
                              if(check)then exit;
                              net_pause;
                              end;
                end;
   ns_server  : case g_status of
                gs_running  : begin
                                 game_PauseToggle:=true;
                                 if(check)then exit;

                                 g_status:=LocalPlayer;
                                 GameLog_Paused(LocalPlayer);
                              end;
                gs_paused0..
                gs_paused7  : begin
                                 game_PauseToggle:=true;
                                 if(check)then exit;

                                 GameLog_Resumed(g_status-gs_paused0);
                                 g_status:=gs_running;
                              end;
                end;
   end;
end;

function CheckPointClick(o_x0,o_y0,o_x1,o_y1:integer):boolean;
begin
   CheckPointClick:=point_dist_rint(o_x0,o_y0,o_x1,o_y1)<4;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   UNIT SELECTION
//

procedure units_SelectRect(add:boolean;x0,y0,x1,y1,sel_opt:integer);
var
u              : integer;
SelectBuildings,
wassel         : boolean;
begin
   if(not ui_GameControlsEnabled)then exit;

   if(x0>x1)then begin u:=x1;x1:=x0;x0:=u;end;
   if(y0>y1)then begin u:=y1;y1:=y0;y0:=u;end;
   ui_CommanderClear;

   SelectBuildings:=true;
   if(add)
   then SelectBuildings:=(g_PlayersGame[LocalPlayer].units_bld_s[false]=0)
   else
     if(sel_opt=0)then
       for u:=1 to MaxUnits do
        with g_punits[u]^ do
         if(hits>0)and(LocalPlayer=playeri)and(not IsUnitRange(transportU,nil))then
          with uid^ do
           if(not uid_isbuilding)then
             if((x0-uid_r)<=vx)and(vx<=(x1+uid_r))
            and((y0-uid_r)<=vy)and(vy<=(y1+uid_r))then
             begin
                SelectBuildings:=false;
                break;
             end;

   for u:=1 to MaxUnits do
     with g_punits[u]^ do
       if(hits>0)and(LocalPlayer=playeri)and(not IsUnitRange(transportU,nil))then
       begin
          wassel:=isselected;

          if(not add)then isselected:=false;
          if(not add)or(not wassel and add)then
            if(sel_opt=0)or(sel_opt=uidi)or(-sel_opt=unum)then
              with uid^ do
                isselected:=((x0-uid_r)<=vx)and(vx<=(x1+uid_r))
                         and((y0-uid_r)<=vy)and(vy<=(y1+uid_r))
                         and(SelectBuildings or not uid_isbuilding);

          if(wassel<>isselected)then
            if(isselected)
            then unit_IncCounters_Select(g_punits[u])
            else unit_DecCounters_Select(g_punits[u]);
          if(isselected)then
          begin
             ui_UnitSelSound:=true;
             ui_CommanderSet(g_punits[u]);
          end;
       end;

   if(ui_tab_Auto)then ui_unit2Tab(ui_CommandercPU);
end;
procedure units_SelectGroup(add:boolean;fgroup:byte);
var u:integer;
wassel:boolean;
begin
   if(not ui_GameControlsEnabled)
   or(fgroup=0)then exit;

   ui_CommanderClear;

   for u:=1 to MaxUnits do
     with g_punits[u]^ do
       if(hits>0)and(LocalPlayer=playeri)and(not IsUnitRange(transportU,nil))then
       begin
          wassel:=isselected;

          if(not add)then isselected:=false;
          if(not add)or(not wassel and add)then
            case fgroup of
            1..
            MaxUnitGroups: isselected:=group=fgroup;
            255          : isselected:=unit_F2SelectFilter(g_punits[u]);
            254          : isselected:=unit_F1SelectFilter(g_punits[u]);
            end;

          if(wassel<>isselected)then
            if(isselected)
            then unit_IncCounters_Select(g_punits[u])
            else unit_DecCounters_Select(g_punits[u]);

          if(isselected)then
          begin
             ui_UnitSelSound:=true;
             ui_CommanderSet(g_punits[u]);
          end;
       end;
   if(ui_tab_Auto)then ui_unit2Tab(ui_CommandercPU);
end;
procedure units_SetGroup(add:boolean;fgroup:byte);
var u:integer;
begin
   if(not ui_GameControlsEnabled)
   or(fgroup>MaxUnitGroups)then exit;

   for u:=1 to MaxUnits do
     with g_punits[u]^ do
       if(hits>0)and(LocalPlayer=playeri)and(not IsUnitRange(transportU,nil))then
         case add of
         false: if(isselected)
                then group:=fgroup
                else
                  if(group=fgroup)then group:=0;
         true : if(isselected)
                then group:=fgroup;
         end;
end;

{$ELSE}
{$include _ded.pas}
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
//
//   GAME SCENARIOS
//

procedure scenario_DefaultEndConditions;
var p,wteam_last,wteams_n: byte;
teams_army: array[0..LastPlayer] of integer;
begin
   if(net_status>ns_none)and(g_tick<fr_fps1)then exit;

   wteam_last:=255;
   wteams_n  :=0;
   FillChar(teams_army,SizeOf(teams_army),0);
   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
       teams_army[team]+=units_all_e;

   for p:=0 to LastPlayer do
     if(teams_army[p]>0)then
     begin
        wteam_last:=p;
        wteams_n  +=1;
     end;

   if(wteams_n=1)then game_SetStatusWinnerTeam(wteam_last);
end;

procedure scenario_DefaultDefeatConditions;
var p:byte;
begin
   for p:=0 to LastPlayer do
     if(g_PlayersGame[p].units_all_c>0)then exit;
   game_SetStatusWinnerTeam(255);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   GAME COMMON
//

procedure game_MakeRandomSkirmish;
var p,
ainum:byte;
begin
   case random(7) of
   0:   map_scenario:=mc_royale;
   1:   map_scenario:=mc_KeyPoints;
   2:   map_scenario:=mc_KotH;
   else
     case random(7) of
     0: map_scenario:=mc_ffa3;
     1: map_scenario:=mc_ffa4;
     2: map_scenario:=mc_ffa5;
     3: map_scenario:=mc_ffa6;
     4: map_scenario:=mc_ffa7;
     5: map_scenario:=mc_ffa8;
     6: map_scenario:=mc_1x1;
     end;
   end;

   case map_scenario of
   mc_1x1,
   mc_ffa3 : map_RandomMap(3000,4000);
   mc_ffa4 : map_RandomMap(3500,5000);
   else      map_RandomMap(4000);
   end;
   game_ShuffleAINames;

   map_GeneratorT:=random(mapg_Last)+1;

   map_SetScenarioMaxPlayers;

   {$IFDEF _FULLGAME}
   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
       if(state=ps_AI)then
         player_SetState(p,ps_None);

   players_Swap(random(map_MaxPlayers),LocalPlayer,false);
   {$ENDIF}

   ainum:=0;
   for p:=0 to map_MaxPlayers-1 do
     with g_PlayersGame[p] do
       if(state<>ps_human)then
       begin
          race :=random(r_count+1);
          mrace:=race;

          if(random(2)=0)
          or(ainum=0)then
          begin
             aip_skill:=random(6)+2;
             player_SetState(p,ps_AI);
             ainum+=1;
          end
          else player_SetState(p,ps_None);
          team:=random(MaxPlayers);
       end;

   if(random(3)=0)
   then g_AISlots:=0
   else g_AISlots:=random(player_default_ai_level+1);

   g_FixedPositions:=random(2)=0;

   Map_Make;
end;

procedure game_PlayerExecuteOrder(tPlayer:byte);
var
pu,
tar_u     : PTUnit;
u,
tar_d     : integer;
tar_ex    : boolean;
toall_n,
toall_msg : byte;
toall_msgx,
toall_msgy: integer;
begin
   with g_PlayersGame[tPlayer] do
   with g_PlayersTemp[tPlayer] do
   if(o_id>0)and(units_all_e>0)then
   begin
      case o_id of
      uo_build   : if(o_a0>0)then GameLog_ReqMsg(tPlayer,o_a0,lmt_argt_unit,unit_start_build(o_x0,o_y0,o_a0,tPlayer),-1,-1);
      uo_corder  : begin
                      tar_d     :=tar_d.MaxValue;
                      tar_u     :=nil;
                      tar_ex    :=false;
                      toall_n   :=0;
                      toall_msg :=0;
                      toall_msgx:=0;
                      toall_msgy:=0;

                      for u:=1 to MaxUnits do
                      begin
                         pu:=g_punits[u];
                         with pu^ do
                         with uid^ do
                           if(hits>0)and(tPlayer=playeri)and(not IsUnitRange(transportU,nil))then
                           begin
                              case o_x0 of
                              co_supgrade : if(unit_OrderCheckForge  (pu,o_a0))then UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_ProdStartUpgrade(pu,o_a0           ,true)=0,true ,true );
                              co_cupgrade : if(unit_OrderCheckForge  (pu,o_a0))then UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_ProdStopUpgrade (pu,o_a0,false,true,true)=0,true ,false);

                              co_sunit    : if(unit_OrderCheckBarrack(pu,o_a0))then UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_ProdStartUnit   (pu,o_a0           ,true)=0,true ,true );
                              co_cunit    : if(unit_OrderCheckBarrack(pu,o_a0))then UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_ProdStopUnit    (pu,o_a0,false,true,true)=0,true ,false);
                              co_pcancle  : if(isselected)then
                                              UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_OrderCheckProdCancel(pu),true ,true);
                              end;

                              if(isselected)then
                                case o_x0 of
                                // TO ONE
                                co_ability  : if(unit_OrderCheckAbility(pu,o_a0))then
                                                case g_aids[o_a0].ua_OrderToAll of
                                                false: UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_AbilityCheck    (pu,o_a0     ,false)=0,false,true );
                                                true : begin
                                                          toall_msg:=unit_AbilityCheck(pu,o_a0,false);
                                                          if(toall_msg=0)then
                                                          begin
                                                             unit_SetAbilityOrder(pu,o_a0,o_y0,o_x1,o_y1,false);
                                                             toall_n+=1;
                                                          end
                                                          else
                                                          begin
                                                             toall_msgx:=pu^.x;
                                                             toall_msgy:=pu^.y;
                                                          end;
                                                       end;
                                                end;

                                // TO ALL
                                co_destroy  : unit_kill(pu,false,false,true,false,true);
                                co_rcamove,
                                co_rcmove,
                                co_stand,
                                co_move,
                                co_patrol,
                                co_astand,
                                co_amove,
                                co_apatrol  : unit_SetBaseOrder(pu,o_x0,o_y0,o_x1,o_y1,false);
                                end;
                           end;
                      end;

                      if(tar_u<>nil)then
                        with tar_u^ do
                          case o_x0 of
                          co_supgrade: GameLog_ReqMsg(tPlayer,o_a0,lmt_argt_upgrade,unit_ProdStartUpgrade(tar_u,o_a0           ,false),x,y);
                          co_cupgrade: GameLog_ReqMsg(tPlayer,o_a0,lmt_argt_upgrade,unit_ProdStopUpgrade (tar_u,o_a0,false,true,false),x,y);
                          co_sunit   : GameLog_ReqMsg(tPlayer,o_a0,lmt_argt_unit   ,unit_ProdStartUnit   (tar_u,o_a0           ,false),x,y);
                          co_cunit   : GameLog_ReqMsg(tPlayer,o_a0,lmt_argt_unit   ,unit_ProdStopUnit    (tar_u,o_a0,false,true,false),x,y);

                          co_pcancle :
                                    if(not iscomplete)
                                    then unit_kill(tar_u,false,false,true,false,true)
                                    else
                                      if(transformTimer>0)
                                      then unit_TransformStop(tar_u,false)
                                      else
                                        if(unit_ProdStopUpgrade(tar_u,o_a0,false,true,false)>0)then
                                           unit_ProdStopUnit   (tar_u,o_a0,false,true,false);
                          co_ability :
                                if(not GameLog_ReqMsg(tPlayer,o_a0,lmt_argt_ability,unit_AbilityCheck    (tar_u,o_a0,false           ),x,y))then
                                  unit_SetAbilityOrder(tar_u,o_a0,o_y0,o_x1,o_y1,false);
                          end
                      else
                        case o_x0 of
                        co_supgrade: GameLog_ReqMsg(tPlayer,o_a0,lmt_argt_upgrade,lmt_unit_NeedProdUnit ,-1,-1);
                        co_cupgrade: ;
                        co_sunit   : GameLog_ReqMsg(tPlayer,o_a0,lmt_argt_unit   ,lmt_unit_NeedProdUnit ,-1,-1);
                        co_cunit   : ;
                        co_pcancle : GameLog_ReqMsg(tPlayer,0   ,255             ,lmt_Invalid_Order,-1,-1);
                        co_ability : if(toall_n=0)and(toall_msg>0)then
                                       if(g_aids[o_a0].ua_OrderToAll)then
                                         GameLog_ReqMsg(tPlayer,o_a0,lmt_argt_ability,toall_msg,toall_msgx,toall_msgy);
                        end;
                   end;
      end;
      o_id:=0;
   end;
end;

procedure game_PlayersCycle;
var p,t:byte;
trevealed:boolean;
HP_prev:integer;
begin
   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
     with g_PlayersTemp[p] do
       if(state>ps_None)then
       begin
          {$IFDEF TESTMODE}
          if(TestMode>0)and(state=ps_AI)and(isdefeated)then isobserver:=(p=LocalPlayer);
          {$ENDIF}

          if(state=ps_human)and(net_status=ns_server){$IFDEF _FULLGAME}and(p<>LocalPlayer){$ENDIF}then
          begin
             if(net_ttl<net_ttl.MaxValue)then net_ttl+=1;
             if(net_ttl>=fr_fps1)then
             begin
                if((net_ttl mod fr_fps2)=0)then menu_update:=true;
                if(net_ping<net_MaxPing)then net_ping+=fr_FrameMS;
             end;
             case g_started of
             false: if(net_ttl>=TTLMaxClientLobby)then
                    begin
                       GameLog_PlayerTimeOut(p);
                       player_SetState(p,ps_None);
                       menu_update:=true;
                       continue;
                    end;
             true : if(net_ttl>=TTLMaxClientGame )then
                    begin
                       GameLog_PlayerTimeOut(p);
                       state:=ps_none;
                       menu_update:=true;
                       continue;
                    end;
             end;
             if(net_TimerLogSend>0)then net_TimerLogSend-=1;
          end;

          if(g_started)and(g_status=gs_running)and(not isobserver)and(not isdefeated)then
          begin
             {$IFDEF _FULLGAME}
             if(ServerSide)or(ui_ControlTabType in [tcc_observer,tcc_replay])then
             {$ENDIF}
               if(build_cd>0)then build_cd-=1;

             {$IFDEF _FULLGAME}
             if(ServerSide)then
             {$ENDIF}
             begin
                game_ScoresAddI(p,psi_res_energy_max,res_energyl_max);

                if(race=r_hell)and(res_HellPower<HellPower_Max)then
                  if((g_tick mod HellPower_AddPeriod)=p)then
                    if(units_uid_c[UID_HAltar]>0)then
                    begin
                       HP_prev:=res_HellPower;
                       case units_uid_c[UID_HAltar] of
                       1  : res_HellPower:=min2i(HellPower_Max,res_HellPower+HellPower_Add1);
                       2  : res_HellPower:=min2i(HellPower_Max,res_HellPower+HellPower_Add2);
                       else res_HellPower:=min2i(HellPower_Max,res_HellPower+HellPower_Add3);
                       end;

                       if(HP_prev<res_HellPower)then
                         game_ScoresAddI(p,psi_res_HellPower,res_HellPower-HP_prev);
                    end;

                trevealed:=(units_builders_e=0){$IFDEF _FULLGAME}and(g_type=gt_scirmish){$ENDIF};
                if(not isrevealed)and(trevealed)then
                begin
                   isrevealed:=trevealed;
                   GameLog_PlayerRevealed(p);
                end
                else
                  if(isrevealed)and(not trevealed)then
                  begin
                     isrevealed:=trevealed;
                     GameLog_PlayerRevealed(p);
                  end;


                game_PlayerExecuteOrder(p);

                if(state=ps_AI)
                then ai_player_code(p)
                else
                  if(log_EnergyCheckTimer>0)
                  then log_EnergyCheckTimer-=1
                  else
                    if(res_energyl_cur>=0)
                    then log_EnergyCheckTimer:=1
                    else
                    begin
                       log_EnergyCheckTimer:=fr_fps6;
                       players_LogAdd(p,0,lmt_Req_Energy,0,0,'',-1,-1);
                    end;
             end;
          end;
       end;

   // remove alarms outside the map in royal battle
   if(g_cycle_order=0)and(map_scenario=mc_royale)then
     for t:=0 to LastPlayer do
       for p:=0 to ai_LastAlarm do
         with ai_TeamAlarms[t,p] do
           if(aia_limit>0)then
             if(game_CheckRoyalBattlePoint(aia_x,aia_y,base_r1))then aia_limit:=0;
end;

procedure game_LobbyTimer;
begin
   if(not g_started)then
     case net_status of
     ns_none,
     ns_server: if(g_LobbyTimer>0)then
                begin
                   if(g_LobbyTimer>=g_GameStartTime)then
                     GameLog_ReadyToStart;
                   if(not game_Start(true))then
                   begin
                      g_LobbyTimer:=0;
                      GameLog_BreakStarting;
                      exit;
                   end;
                   g_LobbyTimer-=1;
                   if(g_LobbyTimer<=0)
                   then game_Start(false)
                   else
                     if((g_LobbyTimer mod fr_fps1)=0)then GameLog_StartsIn(g_LobbyTimer div fr_fps1);
                end;
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   GAME/LOBBY OPTIONS
//

function game_IsOptionsChangeable:boolean;
begin
   game_IsOptionsChangeable:=false;

   if(g_started)
   or(g_LobbyTimer>0)
   {$IFDEF _FULLGAME}
   or(g_type<>gt_scirmish)
   {$ENDIF}then exit;

   case net_status of
   ns_none,
   ns_server: ;
   ns_client: {$IFDEF _FULLGAME}
              if(net_cl_svttl>=TTLServer)then
              {$ENDIF}
              exit;
   else exit;
   end;

   game_IsOptionsChangeable:=true;
end;

{$IFDEF _FULLGAME}
function game_IsLobbyMaster(PlayerRequestor:byte):boolean;
begin
   game_IsLobbyMaster:=false;
   case net_status of
   ns_none,
   ns_server: if(PlayerRequestor<>LocalPlayer)then exit;
   ns_client: if(net_cl_Hoster<>255)then exit;
   else exit;
   end;
   game_IsLobbyMaster:=true;
end;
{$ENDIF}

function player_AILevelScroll(PlayerTarget,PlayerRequestor:byte;forward,check:boolean):boolean;
begin
   player_AILevelScroll:=false;

   if(not game_IsOptionsChangeable)then exit;

   {$IFDEF _FULLGAME}
   if(not game_IsLobbyMaster(PlayerRequestor))then exit;
   {$ENDIF}

   if(PlayerTarget<=LastPlayer)and(PlayerTarget<map_MaxPlayers)then
     with g_PlayersGame[PlayerTarget] do
       if(state=ps_AI)then
       begin
          player_AILevelScroll:=true;

          if(check)then exit;

          {$IFDEF _FULLGAME}
          if(net_status=ns_client)then
          begin
             net_clearbuffer;
             net_writebyte(nmid_lobby_PAILevelScroll);
             net_writebyte(PlayerTarget);
             net_writebool(forward);
             net_send(net_cl_svip,net_cl_svport);
             exit;
          end;
          {$ENDIF}
          ScrollByte(@aip_skill,forward,1,g_MaxAISlots);
          name:=ai_name(aip_skill,PlayerTarget);
       end;
end;

function player_AIToggle(PlayerTarget,PlayerRequestor:byte;check:boolean):boolean;
begin
   player_AIToggle:=false;

   if(not game_IsOptionsChangeable)then exit;

   {$IFDEF _FULLGAME}
   if(not game_IsLobbyMaster(PlayerRequestor))then exit;
   {$ENDIF}

   if(PlayerTarget<=LastPlayer)and(PlayerTarget<map_MaxPlayers)then
     with g_PlayersGame[PlayerTarget] do
       if(state<>ps_human)then
       begin
          player_AIToggle:=true;
          if(check)then exit;

          {$IFDEF _FULLGAME}
          if(net_status=ns_client)then
          begin
             net_clearbuffer;
             net_writebyte(nmid_lobby_PAIToggle);
             net_writebyte(PlayerTarget);
             net_send(net_cl_svip,net_cl_svport);
             exit;
          end;
          {$ENDIF}

          if(state<>ps_None)
          then player_SetState(PlayerTarget,ps_None)
          else player_SetState(PlayerTarget,ps_AI  );

          {$IFDEF _FULLGAME}
          if(g_FixedPositions)then
          begin
             map_RedrawMenuMinimap;
             menu_redraw:=true;
          end;
          {$ENDIF}
       end;
end;

function player_RaceScroll(PlayerTarget,PlayerRequestor:byte;check:boolean):boolean;
begin
   player_RaceScroll:=false;

   if(not game_IsOptionsChangeable)then exit;

   if(PlayerTarget<=LastPlayer)and(PlayerTarget<map_MaxPlayers)then
     with g_PlayersGame[PlayerTarget] do
      if(not isobserver)and(state<>ps_None)then
      begin
         if(state=ps_None)then exit;

         case net_status of
         ns_none,
         ns_server: case state of
                    ps_AI   : {$IFDEF _FULLGAME}if(PlayerRequestor<>LocalPlayer)then exit{$ENDIF};
                    ps_Human: if(PlayerTarget<>PlayerRequestor)then exit;
                    end;
         ns_client: {$IFDEF _FULLGAME}
                    case state of
                    ps_AI   : if(not game_IsLobbyMaster(PlayerRequestor))then exit;
                    ps_Human: if(PlayerTarget<>PlayerRequestor)then exit;
                    end;
                    {$ELSE}
                    exit;
                    {$ENDIF}
         end;

         player_RaceScroll:=true;
         if(check)then exit;

         {$IFDEF _FULLGAME}
         if(net_status=ns_client)then
         begin
            net_clearbuffer;
            net_writebyte(nmid_lobby_PRace);
            net_writebyte(PlayerTarget);
            net_send(net_cl_svip,net_cl_svport);
            exit;
         end;
         {$ENDIF}

         race+=1;
         if(race>r_count)then race:=r_random;
         mrace:=race;
      end;
end;

function player_TeamScroll(PlayerTarget,PlayerRequestor:byte;forward,check:boolean):boolean;
begin
   player_TeamScroll:=false;

   if(not game_IsOptionsChangeable)then exit;

   if(PlayerTarget<=LastPlayer)and(PlayerTarget<map_MaxPlayers)then
     with g_PlayersGame[PlayerTarget] do
     begin
        if(state=ps_None)then exit;

        case net_status of
        ns_none,
        ns_server: case state of
                   ps_AI   : {$IFDEF _FULLGAME}
                             if(PlayerRequestor<>LocalPlayer )then exit{$ENDIF};
                   ps_Human: if(PlayerTarget<>PlayerRequestor)then exit;
                   end;
        ns_client: {$IFDEF _FULLGAME}
                   case state of
                   ps_AI   : if(not game_IsLobbyMaster(PlayerRequestor))then exit;
                   ps_Human: if(PlayerTarget<>PlayerRequestor)then exit;
                   end;
                   {$ELSE}
                   exit;
                   {$ENDIF}
        end;

        if(map_scenario in mc_fixed_teams)then exit;

        player_TeamScroll:=true;

        if(check)then exit;

        {$IFDEF _FULLGAME}
        if(net_status=ns_client)then
        begin
           net_clearbuffer;
           net_writebyte(nmid_lobby_PTeam);
           net_writebyte(PlayerTarget);
           net_writebool(forward);
           net_send(net_cl_svip,net_cl_svport);
           exit;
        end;
        {$ENDIF}

        ScrollByte(@team,forward,0,LastPlayer);
     end;
end;

function player_ToggleObserver(PlayerTarget,PlayerRequestor:byte;check:boolean):boolean;
begin
   player_ToggleObserver:=false;

   if(not game_IsOptionsChangeable)then exit;

   if(PlayerTarget<=LastPlayer)and(PlayerTarget<map_MaxPlayers)then
     with g_PlayersGame[PlayerTarget] do
     begin
        if(state<>ps_Human)
        or(PlayerTarget<>PlayerRequestor)then exit;

        player_ToggleObserver:=true;

        if(check)then exit;

        {$IFDEF _FULLGAME}
        if(net_status=ns_client)then
        begin
           net_clearbuffer;
           net_writebyte(nmid_lobby_PObserver);
           net_send(net_cl_svip,net_cl_svport);
           exit;
        end;
        {$ENDIF}

        isobserver:=not isobserver;
     end;
end;

function game_MapSetSeed(PlayerRequestor:byte;newSeed:cardinal;check:boolean):boolean;
begin
   game_MapSetSeed:=false;

   if(not game_IsOptionsChangeable)
   or((map_seed=newSeed)and not check)then exit;

   {$IFDEF _FULLGAME}
   if(not game_IsLobbyMaster(PlayerRequestor))then exit;
   {$ENDIF}

   game_MapSetSeed:=true;

   if(check)then exit;

   {$IFDEF _FULLGAME}
   if(net_status=ns_client)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_lobby_MSeed);
      net_writecard(newSeed);
      net_send(net_cl_svip,net_cl_svport);
      exit;
   end;
   menu_mseed:=c2s(newSeed);
   {$ENDIF}

   map_seed  :=newSeed;

   Map_Make;
end;

function game_SetOption(PlayerRequestor,param_type:byte;forward,check:boolean):boolean;
begin
   game_SetOption:=false;

   if(not game_IsOptionsChangeable)then exit;

   {$IFDEF _FULLGAME}
   if(not game_IsLobbyMaster(PlayerRequestor))then exit;
   {$ENDIF}

   game_SetOption:=true;

   if(check)then exit;

   {$IFDEF _FULLGAME}
   if(net_status=ns_client)then
   begin
      case param_type of
      nmid_lobby_MScenario,
      nmid_lobby_MGenerators,
      nmid_lobby_MSize,
      nmid_lobby_MTemplate,
      nmid_lobby_MSymmetry,
      nmid_lobby_MRandom,

      nmid_lobby_GFixedPositions,
      nmid_lobby_GAISlots,
      nmid_lobby_GNewObservers,
      nmid_lobby_GRandomScirmish: net_SendGSettings(param_type,forward);
      end;
      exit;
   end;
   {$ENDIF}

   case param_type of
   nmid_lobby_MScenario      : begin ScrollByteSet(@map_scenario,forward,@allmapscenarios);players_ValidateTeam;Map_Make;end;
   nmid_lobby_MGenerators    : begin ScrollByte   (@map_GeneratorT,forward,0,mapg_Last);Map_Make;end;
   nmid_lobby_MSize          : begin
                                  case forward of
                                  true : ScrollInt(@map_Size1, map_SizeMenuStep,map_MinSize,map_MaxSize);
                                  false: ScrollInt(@map_Size1,-map_SizeMenuStep,map_MinSize,map_MaxSize);
                                  end;
                                  Map_Make;
                               end;
   nmid_lobby_MTemplate      : begin ScrollByte(@map_Template,forward,0,mapt_Last); Map_Make; end;
   nmid_lobby_MSymmetry      : begin ScrollByte(@map_Symmetry,forward,0,maps_Last); Map_Make; end;
   nmid_lobby_MRandom        : begin map_RandomMap; Map_Make;end;
   nmid_lobby_GFixedPositions: begin
                                  g_FixedPositions:=not g_FixedPositions;
                                  Map_Make;
                               end;
   nmid_lobby_GAISlots       : ScrollByte(@g_AISlots  ,forward,0,g_MaxAISlots  );
   nmid_lobby_GNewObservers  : g_NewObservers:=not g_NewObservers;
   nmid_lobby_GRandomScirmish: if(forward)then game_MakeRandomSkirmish;
   end;
end;

{$include _net_game.pas}

procedure game_RoyalUpdateR;
var gtick:longint;
begin
   {$IFDEF _FULLGAME}
   if(g_type=gt_campaing)
   then gtick:=longint(g_tick) div camp_BattleRoyaleS
   else
   {$ENDIF}
        gtick:=longint(g_tick) div fr_fpsh;
   if(gtick>g_royal_RMax)
   then g_royal_RCur:=0
   else g_royal_RCur:=g_royal_Rmax-gtick;
end;

procedure game_RoyalSetCenter(rx,ry:integer);
begin
   g_royal_Rx  := rx;
   g_royal_Ry  := ry;
   {$IFDEF _FULLGAME}
   g_royal_RMMx:= round(g_royal_Rx*map_MiniMap_cx);
   g_royal_RMMy:= round(g_royal_Ry*map_MiniMap_cx);
   {$ENDIF}
   g_royal_Rmax:= round(max2i(max2i(point_dist_int(g_royal_Rx,g_royal_Ry,0        ,0        ),
                                    point_dist_int(g_royal_Rx,g_royal_Ry,0        ,map_Size1)),
                              max2i(point_dist_int(g_royal_Rx,g_royal_Ry,map_Size1,0        ),
                                    point_dist_int(g_royal_Rx,g_royal_Ry,map_Size1,map_Size1))));
end;

procedure game_Main;
begin
   {$IFDEF _FULLGAME}
   snd_SoundControl;

   case net_status of
   ns_client: if(net_SvList)
              then net_ServerListProc
              else net_Client;
   ns_server: if(g_started)then
                with g_PlayersTemp[LocalPlayer] do
                begin
                   cam_x:=ui_cam_x;
                   cam_y:=ui_cam_y;
                   cam_w:=ui_cam_w;
                   cam_h:=ui_cam_h;
                end;
   ns_none  : if(g_started)and(MainMenu)then exit;
   end;
   if(g_started)and(net_status<>ns_none)and(ui_playerPOV)then
     if(not ui_ObserverPov(UIPlayer))
     then ui_playerPOV:=false
     else
       with g_PlayersTemp[UIPlayer] do
       begin
          ui_cam_x:=(ui_cam_x+(cam_x+(cam_w div 2)-ui_cam_hw)) div 2;
          ui_cam_y:=(ui_cam_y+(cam_y+(cam_h div 2)-ui_cam_hh)) div 2;
          ui_Camera_Bounds;
       end;

   apm_Calc;

   replay_Code;

   {$ELSE}
   Dedicated_Code;
   Dedicated_Screen;
   {$ENDIF}

   game_LobbyTimer;
   game_PlayersCycle;

   if(g_started)and(g_status=gs_running)then
   begin
      g_cycle_order+=1;g_cycle_order:=g_cycle_order mod order_period;
      g_cycle_regen+=1;g_cycle_regen:=g_cycle_regen mod regen_period;

      case map_scenario of
      mc_KeyPoints: map_KeyPoints_UpdatePos;
      mc_royale   : game_RoyalUpdateR;
      end;

      {$IFDEF _FULLGAME}
      if(ServerSide)then
      begin
      {$ENDIF}
         g_tick+=1;
         Scenario_KeyPointsCodeServer;
         {$IFDEF _FULLGAME}
         case g_type of
         gt_scirmish: begin
         {$ENDIF}
                         Scenario_KeyPointsEndConditions;
                         case map_scenario of
                         mc_KeyPoints,
                         mc_KotH      : scenario_DefaultDefeatConditions;
                         else           scenario_DefaultEndConditions;
                         end;
      {$IFDEF _FULLGAME}
                      end;
         gt_campaing: cmp_MissionCode;
         end;
      end
      else Scenario_KeyPointsCodeClient;
      {$ENDIF}
      GameObjectsCode;
   end;

   if(net_status=ns_server)then net_Server;
end;


