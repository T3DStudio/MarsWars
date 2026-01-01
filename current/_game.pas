
procedure PlayerSetSkirmishTech(playerN:byte);
begin
   with g_gplayers[playerN] do
   begin
      PlayerSetAllowedUnits(playerN,[ UID_HKeep         ..UID_HBarracks,
                                      UID_LostSoul      ..UID_ZBFGMarine,
                                      UID_UCommandCenter..UID_URMStation,
                                      UID_Engineer      ..UID_Flyer  ],
                                    MaxUnits,true);

      PlayerSetAllowedUnits(playerN,[ UID_LostSoul,
                                      UID_Phantom ],
                                    20,false);

      if(map_generators>0)then
      PlayerSetAllowedUnits(playerN,[ UID_HSymbol1..UID_HSymbol4,
                                      UID_UGenerator1..UID_UGenerator4],0,false);


      PlayerSetAllowedUpgrades(playerN,[0..255],255,true); //

      a_rebuild:=[1..255];
      a_ability:=[1..255];
   end;
end;

function PlayersSwap(pSlot,pTarget:byte;Check:boolean):boolean;
var
  tgp:TPlayerGameData;
  tnp:TPlayerNetData;
t0,t1:byte;
begin
   //pSlot - target slot
   //pTarget - player target
   //pTarget -> pSlot
   PlayersSwap:=false;

   if(g_started)
   or(g_LobbyTimer>0)
   {$IFDEF _FULLGAME}
   or(g_type=gt_campaing)
   {$ENDIF}then exit;

   if(pSlot>LastPlayer)
   or(pTarget>LastPlayer)
   then exit;

   if(g_gplayers[pSlot].state<>ps_none)
   or(pTarget=pSlot)then exit;

   PlayersSwap:=true;

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

   t0:=g_gplayers[pSlot  ].team;
   t1:=g_gplayers[pTarget].team;

   tgp:=g_gplayers[pSlot];
   g_gplayers[pSlot  ]:=g_gplayers[pTarget];
   g_gplayers[pTarget]:=tgp;

   tnp:=g_nplayers[pSlot];
   g_nplayers[pSlot  ]:=g_nplayers[pTarget];
   g_nplayers[pTarget]:=tnp;

   g_gplayers[pSlot  ].pnum:=pSlot;
   g_gplayers[pTarget].pnum:=pTarget;

   if(pSlot  >=map_MaxPlayers)then
   g_gplayers[pSlot  ].isobserver:=true;
   g_gplayers[pTarget].isobserver:=false;

   g_gplayers[pSlot  ].team:=PlayerValidateTeam(pSlot  ,t1);
   g_gplayers[pTarget].team:=PlayerValidateTeam(pTarget,t0);

   {$IFDEF _FULLGAME}
   if(LocalPlayer=pTarget)then LocalPlayer:=pSlot
   else
     if(LocalPlayer=pSlot)then LocalPlayer:=pTarget;
   if(g_FixedPositions)then
     map_RedrawMenuMinimap;
   {$ENDIF}
end;

procedure PlayerSetState(playerN,newState:byte);
begin
   with g_gplayers[playerN] do
   begin
      case newState of
ps_None : begin isready:=false;if(not g_started)then
                               name :='';       end;
ps_AI   : begin isready:=true; name :=ai_name(ai_skill);isobserver:=false;end;
ps_human: begin isready:=false;name :='';               end;
      end;
      team :=PlayerValidateTeam(playerN,team);
      state:=newState;
   end;
end;

procedure PlayerKill(playerN:byte;instant:boolean);
var u:integer;
begin
   for u:=1 to MaxUnits do
     with g_punits[u]^ do
       if(playeri=playerN)then
         unit_kill(g_punits[u],instant,true,false,true,true);
end;

procedure PlayerSetDefault(p:byte);
begin
   with g_gplayers[p] do
   begin
      ai_skill  :=player_default_ai_level;
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
      res_HellPower:=30000;
      res_UACLoot  :=30000;
   end;
end;

procedure PlayersSetDefault;
var p:byte;
begin
   FillChar(g_gplayers,SizeOf(TPList    ),0);
   FillChar(g_nplayers,SizeOf(g_nplayers),0);
   for p:=0 to LastPlayer do
     with g_gplayers[p] do
     begin
        PlayerSetDefault(p);
        PlayerSetState(p,ps_None);
        PlayerSetSkirmishTech(p);
        PlayerClearLog(p);
        log_EnergyCheckTimer:=0;
     end;

   {$IFDEF _FULLGAME}
   LocalPlayer:=0;
   with g_gplayers[LocalPlayer] do
   begin
      state:=ps_human;
      name :=PlayerName;
   end;

   PlayerColorDefaultCurrent:=c_white;
   PlayerColorDefaultShadow :=gfx_ShadowColor(PlayerColorDefaultCurrent);

   PlayerColorsDefault[0]:=c_red;
   PlayerColorsDefault[1]:=c_orange;
   PlayerColorsDefault[2]:=c_yellow;
   PlayerColorsDefault[3]:=c_lime;
   PlayerColorsDefault[4]:=c_aqua;
   PlayerColorsDefault[5]:=c_blue;
   PlayerColorsDefault[6]:=c_violet;
   PlayerColorsDefault[7]:=c_purple;

   PlayerColorsCurrent[0]:=c_red;
   PlayerColorsCurrent[1]:=c_orange;
   PlayerColorsCurrent[2]:=c_yellow;
   PlayerColorsCurrent[3]:=c_lime;
   PlayerColorsCurrent[4]:=c_aqua;
   PlayerColorsCurrent[5]:=c_blue;
   PlayerColorsCurrent[6]:=c_violet;
   PlayerColorsCurrent[7]:=c_purple;
   {$ENDIF}
end;

procedure Game_DefaultAll;
var u:integer;
begin
   randomize;

   g_tick         :=0;
   G_Status       :=gs_running;

   ServerSide     :=true;

   KeyPoints_Clear;
   FillChar(g_missiles ,SizeOf(g_missiles ),0);
   FillChar(g_units    ,SizeOf(g_units    ),0);
   for u:=0 to MaxUnits do
     with g_units[u] do
     begin
        hits  :=hits_dead;
        player:=@g_gplayers[playeri];
        uid   :=@g_units  [uidi   ];
     end;
   LastCreatedUnit :=0;
   LastCreatedUnitP:=@g_units[LastCreatedUnit];

   PlayersSetDefault;

   UnitStepTicks := 8;

   g_royal_r     := 0;

   g_cycle_order := 0;
   g_cycle_regen := 0;
   g_LobbyTimer  := 0;

   Map_Make;
   {$IFDEF DEBUG0}
   test_InstaProd:=false;
   {$ENDIF}

   menu_update:=true;

   {$IFDEF _FULLGAME}
   sys_uncappedFPS:=false;

   vid_ScreenSpritesS:=0;

   ui_cam_x:=-ui_CtrlPanelW;
   ui_cam_y:=0;
   ui_Camera_Bounds;

   ui_blink_timer1:=0;
   ui_blink_timer2:=0;
   ui_tab :=0;

   FillChar(ui_alarms,SizeOf(ui_alarms),0);
   FillChar(g_effects,SizeOf(g_effects),0);

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

   rpls_pnu  :=0;
   rpls_POVRecorder:=false;
   rpls_pstate:=rpls_none;
   {$ENDIF}
end;

{$IFDEF _FULLGAME}
procedure GameLocalStart;
begin
   ui_Camera_MoveToPoint(map_PlayerStartX[LocalPlayer] , map_PlayerStartY[LocalPlayer]);
   if(g_gplayers[LocalPlayer].isobserver)then
   begin
      ui_tab  :=tab_controls;
      UIPlayer:=255;
   end
   else UIPlayer :=LocalPlayer;
   ui_log_LastTimer:=0;
   rpls_RecordTryPause:=0;
end;

{$include _replays.pas}
{$ENDIF}

function PlayerSurrender(pid:byte;check:boolean):boolean;
begin
   PlayerSurrender:=false;

   if(not g_started)
   or(pid>LastPlayer)
   {$IFDEF _FULLGAME}
   or(rpls_pstate=rpls_read)
   {$ENDIF}
   or(not g_DefeatedObs)
   or(g_started and Game_IsEnded)then exit;

   with g_gplayers[pid] do
     if(state<>ps_Human)
     or(armylimit<=0)
     or(units_all_e<=0)
     or(isdefeated)
     or(isobserver)then exit;

   {$IFDEF _FULLGAME}
   if (net_status=ns_client)
   and(net_cl_svttl>=TTLServer)then exit;
   {$ENDIF}

   PlayerSurrender:=true;
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
   PlayerKill(pid,true);
end;

procedure GameRemoveAIObservers;
var p:byte;
begin
   for p:=0 to LastPlayer do
     with g_gplayers[p] do
       if(p>=map_MaxPlayers)and(state=ps_AI)then PlayerSetState(p,ps_none);
end;

procedure GameCreateStartBase(x,y:integer;uid,playerN,count:byte);
var
i     :byte;
r,d,ds:integer;
begin
   if(count>6)then count:=6;

   if(count=0)
   then unit_add(x,y,0,uid,playerN,true,false,0)
   else
   begin
      if(count>5)then
      begin
         unit_add(x,y,0,uid,playerN,true,false,0);
         count-=1;
      end;
      d  :=point_dir(x,y,map_Sizeh,map_Sizeh);
      ds :=360 div (count+1);
      r  :=50+count*18;
      for i:=0 to count do
      begin
         unit_add(
         x+trunc(r*cos(d*degtorad)),
         y-trunc(r*sin(d*degtorad)),
         0,uid,playerN,true,false,0);

         d+=ds;
      end;
   end;
end;

procedure Game_StartSkirmish;
var p:byte;
begin
   g_royal_r:=trunc(sqrt(sqr(map_Sizeh)*2));
   if(not g_FixedPositions)then map_ShuffleStarts(map_scenario in mc_fixed_teams);

   for p:=0 to LastPlayer do
     with g_gplayers[p] do
       if(p>=map_MaxPlayers)then isobserver:=true;

   for p:=0 to LastPlayer do
     with g_gplayers[p] do
       if(isobserver)then
       begin
          team:=0;
          race:=r_hell;
       end
       else
       begin
          team:=PlayerValidateTeam(p,team);

          if(state=ps_None)then
            if(g_AISlots>0)then
            begin
               ai_skill:=g_AISlots;
               race    :=r_random;
               PlayerSetState(p,ps_AI);
            end;

          if(race=r_random)then race:=1+random(r_count);

          if(state=ps_human)then ai_skill:=player_default_ai_level;//g_AISlots
       end;

   for p:=0 to LastPlayer do
     with g_gplayers[p] do
       if(state<>ps_None)then
       begin
          PlayerSetSkirmishTech(p);
          ai_PlayerSetSkirmishSettings(p);
          if(not isobserver)then
             GameCreateStartBase(map_PlayerStartX[p],map_PlayerStartY[p],uid_race_start_fbase[race],p,0)
       end;

   {$IFDEF _FULLGAME}
   GameLocalStart;
   {$ENDIF}
end;

function GameStart(check:boolean):boolean;
begin
   GameStart:=false;

   if(G_Started)
   or(net_status=ns_client)
   then exit;

   {$IFDEF _FULLGAME}
   case g_type of
   gt_campaing: ;
   gt_scirmish: if(not PlayersAllReady)
                or(PlayersNonObserversCount<2)
                then exit;
   else exit;
   end;
   {$ELSE}
   if(not PlayersAllReady)
   or(PlayersNonObserversCount<2)
   then exit;
   {$ENDIF}

   GameStart:=true;

   if(check)then exit;

   {$IFDEF _FULLGAME}
   case g_type of
   gt_campaing: cmp_StartMission;
   gt_scirmish: Game_StartSkirmish;
   else exit;
   end;
   {$ELSE}
   Game_StartSkirmish;
   {$ENDIF}

   {$IFDEF _FULLGAME}
   unit_UICountersAll;
   ui_EnableControlActs;
   menu_ItemSelected:=0;
   MainMenu :=false;
   {$ELSE}
   menu_update:=true;
   {$ENDIF}
   G_Started:=true;
end;

function GameBreak(check:boolean):boolean;
begin
   GameBreak:=false;

   if(not G_Started)
   or(net_status=ns_client)then exit;

   GameBreak:=true;

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

   menu_ItemSelected:=0;
   {$ENDIF}
   G_Started:=false;
   Game_DefaultAll;
end;

{$IFDEF _FULLGAME}
function GamePauseToggle(check:boolean):boolean;
begin
   GamePauseToggle:=false;

   case net_status of
   ns_client  : case G_Status of
                gs_running,
                gs_paused0..
                gs_paused7  : begin
                              GamePauseToggle:=true;
                              if(check)then exit;
                              net_pause;
                              end;
                end;
   ns_server  : case G_Status of
                gs_running  : begin
                                 GamePauseToggle:=true;
                                 if(check)then exit;

                                 G_Status:=LocalPlayer;
                                 GameLog_Paused(LocalPlayer);
                              end;
                gs_paused0..
                gs_paused7  : begin
                                 GamePauseToggle:=true;
                                 if(check)then exit;

                                 GameLog_Resumed(G_Status-gs_paused0);
                                 G_Status:=gs_running;
                              end;
                end;
   end;
end;

function CheckPointClick(o_x0,o_y0,o_x1,o_y1:integer):boolean;
begin
   CheckPointClick:=point_dist_rint(o_x0,o_y0,o_x1,o_y1)<4;
end;

function ui_GameControlsEnabled:boolean;
begin
   ui_GameControlsEnabled:=false;
   with g_gplayers[LocalPlayer] do
     if(UIPlayer<>LocalPlayer)
     or(isobserver)
     or(isdefeated)
     or(rpls_pstate=rpls_read)then exit;
   if(g_status<>gs_running)then exit;
   ui_GameControlsEnabled:=true;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   UNIT SELECTION
//

procedure units_SelectRect(add:boolean;x0,y0,x1,y1:integer;fuid:byte);
var
u,
usel_max       : integer;
SelectBuildings,
wassel         : boolean;
begin
   if(not ui_GameControlsEnabled)then exit;

   if(x0>x1)then begin u:=x1;x1:=x0;x0:=u;end;
   if(y0>y1)then begin u:=y1;y1:=y0;y0:=u;end;
   usel_max:=32000;
   if(CheckPointClick(x0,y0,x1,y1))then usel_max:=1;
   ui_CommanderClear;

   SelectBuildings:=true;
   if(add)
   then SelectBuildings:=(g_gplayers[LocalPlayer].units_bld_s[false]=0)
   else
     if(fuid=255)then
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
          if(usel_max>0)then
            if(not add)or(not wassel and add)then
              if(fuid=255)or(fuid=uidi)then
                with uid^ do
                  isselected:=((x0-uid_r)<=vx)and(vx<=(x1+uid_r))
                    and((y0-uid_r)<=vy)and(vy<=(y1+uid_r))
                    and(SelectBuildings or not uid_isbuilding);

          if(wassel<>isselected)then
            if(isselected)
            then unit_IncCounters_Select(g_punits[u])
            else unit_DecCounters_Select(g_punits[u]);
          if(isselected)and(usel_max>0)then
          begin
             usel_max-=1;
             ui_UnitSelSound:=true;
             ui_CommanderSet(g_punits[u]);
          end;
       end;
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
end;
procedure units_Grouping(add:boolean;fgroup:byte);
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

procedure Scenario_DefaultEndConditions;
var p,wteam_last,wteams_n: byte;
teams_army: array[0..LastPlayer] of integer;
begin
   if(net_status>ns_none)and(g_tick<fr_fps1)then exit;

   wteam_last:=255;
   wteams_n  :=0;
   FillChar(teams_army,SizeOf(teams_army),0);
   for p:=0 to LastPlayer do
     with g_gplayers[p] do
       teams_army[team]+=units_all_e;

   for p:=0 to LastPlayer do
     if(teams_army[p]>0)then
     begin
        wteam_last:=p;
        wteams_n  +=1;
     end;

   if(wteams_n=1)then Game_SetStatusWinnerTeam(wteam_last);
end;

procedure Scenario_DefaultDefeatConditions;
var p:byte;
begin
   for p:=0 to LastPlayer do
     if(g_gplayers[p].units_all_e>0)then exit;
   Game_SetStatusWinnerTeam(255);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   GAME COMMON
//

procedure game_MakeRandomSkirmish;
var p:byte;
begin
   Map_randommap;

   case random(7) of
   0:   map_scenario:=mc_royale;
   1:   map_scenario:=mc_KeyPoints;
   2:   map_scenario:=mc_KotH;
   else map_scenario:=mc_ffa8;
   end;

   if(random(3)=0)
   then map_generators:=random(map_MaxGenerators)+1
   else map_generators:=0;

   for p:=0 to LastPlayer do
     with g_gplayers[p] do
       if(state<>ps_human)then
       begin
          race :=random(r_count+1);
          mrace:=race;

          team:=random(6);

          ai_skill:=random(6)+2;

          if(random(2)=0)
          then PlayerSetState(p,ps_None)
          else PlayerSetState(p,ps_AI);
       end;

   {$IFDEF _FULLGAME}
   PlayersSwap(random(MaxPlayers),LocalPlayer,false);
   {$ENDIF}

   if(random(3)=0)
   then g_AISlots:=0
   else g_AISlots:=random(player_default_ai_level+1);

   g_FixedPositions:=random(2)=0;

   Map_Make;
end;

procedure game_PlayerExecuteOrder(tPlayer:byte);
var
pu,
tar_u : PTUnit;
u,
tar_d : integer;
tar_ex: boolean;
begin
   with g_gplayers[tPlayer] do
   if(o_id>0)and(units_all_e>0)then
   begin
      case o_id of
      uo_build   : if(o_a0>0)then GameLog_ReqBits(tPlayer,o_a0,lmt_argt_unit,unit_start_build(o_x0,o_y0,o_a0,tPlayer),-1,-1);
      uo_corder  : begin
                      tar_d :=tar_d.MaxValue;
                      tar_u :=nil;
                      tar_ex:=false;

                      for u:=1 to MaxUnits do
                      begin
                         pu:=g_punits[u];
                         with pu^ do
                         with uid^ do
                           if(hits>0)and(tPlayer=playeri)and(not IsUnitRange(transportU,nil))then
                           begin
                              case o_x0 of
                              co_supgrade : if(unit_OrderCheckSmith  (pu,o_a0))then UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_ProdStartUpgrade(pu,o_a0           ,true)=0,true ,true );
                              co_cupgrade : if(unit_OrderCheckSmith  (pu,o_a0))then UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_ProdStopUpgrade (pu,o_a0,false     ,true)=0,true ,false);

                              co_sunit    : if(unit_OrderCheckBarrack(pu,o_a0))then UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_ProdStartUnit   (pu,o_a0           ,true)=0,true ,true );
                              co_cunit    : if(unit_OrderCheckBarrack(pu,o_a0))then UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_ProdStopUnit    (pu,o_a0,false,true,true)=0,true ,false);
                              co_pcancle  : if(isselected)then
                                            begin
                                            if(unit_OrderCheckBarrack(pu,o_a0))then UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_ProdStopUnit    (pu,o_a0,false,true,true)=0,true ,false);
                                            if(unit_OrderCheckSmith  (pu,o_a0))then UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_ProdStopUpgrade (pu,o_a0,false     ,true)=0,true ,false);
                                            end;
                              end;

                              if(isselected)then
                                case o_x0 of
                                // TO ONE
                                co_ability  : if(unit_OrderCheckAbility(pu,o_a0))then UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_AbilityCheck    (pu,o_a0     ,false)=0,false,true );

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
                          co_supgrade: GameLog_ReqBits(tPlayer,o_a0,lmt_argt_upgrade,unit_ProdStartUpgrade(tar_u,o_a0           ,false),x,y);
                          co_cupgrade: GameLog_ReqBits(tPlayer,o_a0,lmt_argt_upgrade,unit_ProdStopUpgrade (tar_u,o_a0,false     ,false),x,y);
                          co_sunit   : GameLog_ReqBits(tPlayer,o_a0,lmt_argt_unit   ,unit_ProdStartUnit   (tar_u,o_a0           ,false),x,y);
                          co_cunit   : GameLog_ReqBits(tPlayer,o_a0,lmt_argt_unit   ,unit_ProdStopUnit    (tar_u,o_a0,false,true,false),x,y);

                          co_pcancle :
                                    if(GameLog_ReqBits(tPlayer,o_a0,lmt_argt_upgrade,unit_ProdStopUpgrade (tar_u,o_a0,false     ,false),x,y))then
                                       GameLog_ReqBits(tPlayer,o_a0,lmt_argt_unit   ,unit_ProdStopUnit    (tar_u,o_a0,false,true,false),x,y);
                          co_ability :
                                if(not GameLog_ReqBits(tPlayer,o_a0,lmt_argt_ability,unit_AbilityCheck    (tar_u,o_a0,false           ),x,y))then
                                  unit_SetAbilityOrder(tar_u,o_a0,o_y0,o_x1,o_y1,false);
                          end
                      else
                        case o_x0 of
                        co_supgrade,
                        co_cupgrade: GameLog_ReqBits(tPlayer,o_a0,lmt_argt_upgrade,ureq_smiths  ,-1,-1);
                        co_sunit,
                        co_cunit   : GameLog_ReqBits(tPlayer,o_a0,lmt_argt_unit   ,ureq_barracks,-1,-1);
                        co_pcancle : GameLog_ReqBits(tPlayer,0   ,255             ,ureq_other   ,-1,-1);
                        co_ability : ;
                        end;
                   end;
      end;
      o_id:=0;
   end;
end;

procedure game_PlayersCycle;
var p:byte;
trevealed:boolean;
begin
   for p:=0 to LastPlayer do
     with g_gplayers[p] do
     with g_nplayers[p] do
       if(state>ps_None)then
       begin
          if(state=ps_human)and(net_status=ns_server){$IFDEF _FULLGAME}and(p<>LocalPlayer){$ENDIF}then
          begin
             if(net_ttl<net_ttl.MaxValue)then net_ttl+=1;
             if(net_ttl>=fr_fps1)then
             begin
                if((net_ttl mod fr_fps2)=0)then menu_update:=true;
                if(net_ping<net_MaxPing)then net_ping+=fr_FrameMS;
             end;
             case G_Started of
             false: if(net_ttl>=TTLMaxClientLobby)then
                    begin
                       GameLog_PlayerTimeOut(p);
                       PlayerSetState(p,ps_None);
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
             if(net_logsend_pause>0)then net_logsend_pause-=1;
          end;

          if(ServerSide)and(G_Started)and(G_Status=gs_running)and(not isobserver)and(not isdefeated)then
          begin
             if(build_cd>0)then build_cd-=1;
             if(race=r_hell)and(res_HellPower<HellPower_Max)then
               if((g_tick mod HellPower_AddPeriod)=p)then
                 if(units_uid_c[UID_HAltar]>0)then
                   case units_uid_c[UID_HAltar] of
                   1  : res_HellPower:=min2i(HellPower_Max,res_HellPower+HellPower_Add1);
                   2  : res_HellPower:=min2i(HellPower_Max,res_HellPower+HellPower_Add2);
                   else res_HellPower:=min2i(HellPower_Max,res_HellPower+HellPower_Add3);
                   end;

             trevealed:=(units_builders_e=0){$IFDEF _FULLGAME}and(g_type=gt_scirmish){$ENDIF};
             if(not isrevealed)and(trevealed)then
             begin
                GameLog_PlayerRevealed(p);
                isrevealed:=trevealed;
             end;

             game_PlayerExecuteOrder(p);

             if(state=ps_AI)
             then //ai_player_code(p)
             else
               if(log_EnergyCheckTimer>0)
               then log_EnergyCheckTimer-=1
               else
                 if(res_energyl_cur>=0)
                 then log_EnergyCheckTimer:=1
                 else
                 begin
                    log_EnergyCheckTimer:=fr_fps6;
                    PlayersAddToLog(p,0,lmt_Req_Energy,0,0,'',-1,-1);
                 end;
          end;
       end;
end;

procedure game_LobbyTimer;
begin
   if(not G_Started)then
     case net_status of
     ns_none,
     ns_server: if(g_LobbyTimer>0)then
                begin
                   if(g_LobbyTimer>=g_GameStartTime)then
                     GameLog_ReadyToStart;
                   if(not GameStart(true))then
                   begin
                      g_LobbyTimer:=0;
                      GameLog_BreakStarting;
                      exit;
                   end;
                   g_LobbyTimer-=1;
                   if(g_LobbyTimer<=0)
                   then GameStart(false)
                   else
                     if((g_LobbyTimer mod fr_fps1)=0)then GameLog_StartsIn(g_LobbyTimer div fr_fps1);
                end;
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   GAME OPTIONS
//

function GameOptionsChangeable:boolean;
begin
   GameOptionsChangeable:=false;

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

   GameOptionsChangeable:=true;
end;

{$IFDEF _FULLGAME}
function GameOptionsIsLobbyMaster(PlayerRequestor:byte):boolean;
begin
   GameOptionsIsLobbyMaster:=false;
   case net_status of
   ns_none,
   ns_server: if(PlayerRequestor<>LocalPlayer)then exit;
   ns_client: if(net_cl_Hoster<>255)then exit;
   else exit;
   end;
   GameOptionsIsLobbyMaster:=true;
end;
{$ENDIF}

function PlayerAILevelScroll(PlayerTarget,PlayerRequestor:byte;forward,check:boolean):boolean;
begin
   PlayerAILevelScroll:=false;

   if(not GameOptionsChangeable)then exit;

   {$IFDEF _FULLGAME}
   if(not GameOptionsIsLobbyMaster(PlayerRequestor))then exit;
   {$ENDIF}

   if(PlayerTarget<=LastPlayer)and(PlayerTarget<map_MaxPlayers)then
     with g_gplayers[PlayerTarget] do
       if(state=ps_AI)then
       begin
          PlayerAILevelScroll:=true;

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
          ScrollByte(@ai_skill,forward,1,g_MaxAISlots);
          name:=ai_name(ai_skill);
       end;
end;

function PlayerAIToggle(PlayerTarget,PlayerRequestor:byte;check:boolean):boolean;
begin
   PlayerAIToggle:=false;

   if(not GameOptionsChangeable)then exit;

   {$IFDEF _FULLGAME}
   if(not GameOptionsIsLobbyMaster(PlayerRequestor))then exit;
   {$ENDIF}

   if(PlayerTarget<=LastPlayer)and(PlayerTarget<map_MaxPlayers)then
     with g_gplayers[PlayerTarget] do
       if(state<>ps_human)then
       begin
          PlayerAIToggle:=true;
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
          then PlayerSetState(PlayerTarget,ps_None)
          else PlayerSetState(PlayerTarget,ps_AI  );

          {$IFDEF _FULLGAME}
          map_RedrawMenuMinimap;
          {$ENDIF}
       end;
end;

function PlayerRaceScroll(PlayerTarget,PlayerRequestor:byte;check:boolean):boolean;
begin
   PlayerRaceScroll:=false;

   if(not GameOptionsChangeable)then exit;

   if(PlayerTarget<=LastPlayer)and(PlayerTarget<map_MaxPlayers)then
     with g_gplayers[PlayerTarget] do
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
                    ps_AI   : if(not GameOptionsIsLobbyMaster(PlayerRequestor))then exit;
                    ps_Human: if(PlayerTarget<>PlayerRequestor)then exit;
                    end;
                    {$ELSE}
                    exit;
                    {$ENDIF}
         end;

         PlayerRaceScroll:=true;
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

function PlayerTeamScroll(PlayerTarget,PlayerRequestor:byte;forward,check:boolean):boolean;
begin
   PlayerTeamScroll:=false;

   if(not GameOptionsChangeable)then exit;

   if(PlayerTarget<=LastPlayer)and(PlayerTarget<map_MaxPlayers)then
     with g_gplayers[PlayerTarget] do
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
                   ps_AI   : if(not GameOptionsIsLobbyMaster(PlayerRequestor))then exit;
                   ps_Human: if(PlayerTarget<>PlayerRequestor)then exit;
                   end;
                   {$ELSE}
                   exit;
                   {$ENDIF}
        end;

        if(map_scenario in mc_fixed_teams)then exit;

        PlayerTeamScroll:=true;

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

function PlayerToggleObserver(PlayerTarget,PlayerRequestor:byte;check:boolean):boolean;
begin
   PlayerToggleObserver:=false;

   if(not GameOptionsChangeable)then exit;

   if(PlayerTarget<=LastPlayer)and(PlayerTarget<map_MaxPlayers)then
     with g_gplayers[PlayerTarget] do
     begin
        if(state<>ps_Human)
        or(PlayerTarget<>PlayerRequestor)then exit;

        PlayerToggleObserver:=true;

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

function GameMapSetSeed(PlayerRequestor:byte;newSeed:cardinal;check:boolean):boolean;
begin
   GameMapSetSeed:=false;

   if(not GameOptionsChangeable)
   or(map_seed=newSeed)then exit;

   {$IFDEF _FULLGAME}
   if(not GameOptionsIsLobbyMaster(PlayerRequestor))then exit;
   {$ENDIF}

   GameMapSetSeed:=true;

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

function GameSetOption(PlayerRequestor,param_type:byte;forward,check:boolean):boolean;
begin
   GameSetOption:=false;

   if(not GameOptionsChangeable)then exit;

   {$IFDEF _FULLGAME}
   if(not GameOptionsIsLobbyMaster(PlayerRequestor))then exit;
   {$ENDIF}

   GameSetOption:=true;

   if(check)then exit;

   {$IFDEF _FULLGAME}
   if(net_status=ns_client)then
   begin
      case param_type of
      nmid_lobby_MScenario,
      nmid_lobby_MGenerators,
      nmid_lobby_MSize,
      nmid_lobby_MObstacles,
      nmid_lobby_MSymmetry,
      nmid_lobby_MRandom,

      nmid_lobby_GFixedPositions,
      nmid_lobby_GAISlots,
      nmid_lobby_GDefeatedObs,
      nmid_lobby_GRandomScirmish: net_SendGSettings(param_type,forward);
      end;
      exit;
   end;
   {$ENDIF}

   case param_type of
   nmid_lobby_MScenario      : begin ScrollByteSet(@map_scenario,forward,@allmapscenarios);PlayersValidateTeam;Map_Make;end;
   nmid_lobby_MGenerators    : begin ScrollByte   (@map_generators,forward,0,map_MaxGenerators);Map_Make;end;
   nmid_lobby_MSize          : begin
                                  case forward of
                                  true : ScrollInt(@map_Size1, map_SizeMenuStep,map_MinSize,map_MaxSize);
                                  false: ScrollInt(@map_Size1,-map_SizeMenuStep,map_MinSize,map_MaxSize);
                                  end;
                                  Map_Make;
                               end;
   nmid_lobby_MObstacles     : begin ScrollByte(@map_ObstaclesF,forward,0,map_MaxObstacles); Map_Make; end;
   nmid_lobby_MSymmetry      : begin map_Symmetry:=not map_Symmetry; Map_Make; end;
   nmid_lobby_MRandom        : begin Map_randommap; Map_Make;end;
   nmid_lobby_GFixedPositions: begin
                                  g_FixedPositions:=not g_FixedPositions;
                                  {$IFDEF _FULLGAME}
                                  map_RedrawMenuMinimap;
                                  {$ENDIF}
                               end;
   nmid_lobby_GAISlots       : begin
                                  ScrollByte(@g_AISlots  ,forward,0,g_MaxAISlots  );
                                  {$IFDEF _FULLGAME}
                                  map_RedrawMenuMinimap;
                                  {$ENDIF}
                               end;
   nmid_lobby_GDefeatedObs   : g_DefeatedObs:=not g_DefeatedObs;
   nmid_lobby_GRandomScirmish: if(forward)then game_MakeRandomSkirmish;
   end;
end;

{$include _net_game.pas}

procedure GameMain;
begin
   {$IFDEF _FULLGAME}
   snd_SoundControl;

   case net_status of
   ns_client: if(net_svsearch)
              then net_Discowering
              else net_Client;
   ns_none  : if(g_Started)and(MainMenu)then exit;
   end;

   replay_Code;

   {$ELSE}
   Dedicated_Code;
   Dedicated_Screen;
   {$ENDIF}

   game_LobbyTimer;
   game_PlayersCycle;

   if(G_Started)and(G_Status=gs_running)then
   begin
      g_cycle_order+=1;g_cycle_order:=g_cycle_order mod order_period;
      g_cycle_regen+=1;g_cycle_regen:=g_cycle_regen mod regen_period;

      if(ServerSide)then
      begin
         g_tick+=1;

         Scenario_KeyPointsCode;
         {$IFDEF _FULLGAME}
         if(g_type=gt_scirmish)then
         begin
         {$ENDIF}
            Scenario_KeyPointsEndConditions;
            case map_scenario of
            mc_royale    : begin
                              if(g_cycle_order=0)then
                                if(g_royal_r>0)then g_royal_r-=1;
                              Scenario_DefaultEndConditions;
                           end;
            mc_KeyPoints,
            mc_KotH      : Scenario_DefaultDefeatConditions;
            else           Scenario_DefaultEndConditions;
            end;
         {$IFDEF _FULLGAME}
         end
         else cmp_MissionCode;
         {$ENDIF}
      end;
      GameObjectsCode;
   end;

   if(net_status=ns_server)then net_Server;
end;


