
procedure PlayerSetSkirmishTech(p:byte);
begin
   with g_players[p] do
   begin
      PlayerSetAllowedUnitsMax(p,[UID_HKeep         ..UID_HBarracks,
                                  UID_LostSoul      ..UID_ZBFGMarine,
                                  UID_UCommandCenter..UID_UComputerStation,
                                  UID_Engineer      ..UID_Flyer  ],
                                  MaxUnits,true);

      PlayerSetAllowedUnitsMax(p,[ UID_HMonastery ,UID_HFortress       ,UID_HAltar,
                                   UID_UTechCenter,UID_UComputerStation,UID_URMStation ],1,false);

      PlayerSetAllowedUnitsMax(p,[ UID_LostSoul, UID_Phantom ],20,false);


      case g_generators of
      0:;
      1    :PlayerSetAllowedUnitsMax(p,[ UID_HKeep     ,UID_HCommandCenter,UID_UCommandCenter                    ],0,false);
      else  PlayerSetAllowedUnitsMax(p,[ UID_HSymbol   ,UID_HASymbol      ,UID_HKeep          ,UID_HCommandCenter,
                                         UID_UGenerator,UID_UAGenerator   ,UID_UCommandCenter                    ],0,false);
      end;

      PlayerSetAllowedUpgrades(p,[0..255],255,true);
   end;
end;

function PlayersSwap(SlotSource,SlotTarget:byte;Check:boolean):boolean;
var tp:TPlayer;
begin
   PlayersSwap:=false;

   if(SlotSource>MaxPlayers  )
   or(SlotTarget>MaxPlayers  )
   or(SlotSource=0           )
   or(SlotTarget=0           )
   or(SlotSource=SlotTarget)then exit;

   with g_players[SlotSource] do
     if(state<>ps_play)
     then exit
     else
       if(g_slot_state[SlotSource]<>ps_opened  )and
         (g_slot_state[SlotSource]<>ps_observer)then exit;

   with g_players[SlotTarget] do
     if(state=ps_play)then exit;
   if(g_slot_state[SlotTarget]<>ps_opened  )and
     (g_slot_state[SlotTarget]<>ps_observer)then exit;

   PlayersSwap:=true;

   if(Check)then exit;

   tp:=g_players[SlotSource];
   g_players[SlotSource]:=g_players[SlotTarget];
   g_players[SlotTarget]:=tp;

   g_players[SlotSource].pnum:=SlotSource;
   g_players[SlotTarget].pnum:=SlotTarget;

   case g_slot_state[SlotSource] of
   ps_observer: g_players[SlotSource].team:=0;
   ps_opened  : g_players[SlotSource].team:=PlayerGetTeam(g_mode,SlotSource,SlotSource);
   end;
   case g_slot_state[SlotTarget] of
   ps_observer: g_players[SlotTarget].team:=0;
   ps_opened  : g_players[SlotTarget].team:=PlayerGetTeam(g_mode,SlotTarget,SlotTarget);
   end;

   if(PlayerClient=SlotTarget)then PlayerClient:=SlotSource
   else
     if(PlayerClient=SlotSource)then PlayerClient:=SlotTarget;

   if(PlayerLobby=SlotTarget)then PlayerLobby:=SlotSource
   else
     if(PlayerLobby=SlotSource)then PlayerLobby:=SlotTarget;
end;

procedure PlayerSetState(PlayerTarget,newstate:byte);
begin
   with g_players[PlayerTarget] do
   begin
      case newstate of
ps_none: begin isready:=false;name :=str_ps_none;      end;
PS_Comp: begin isready:=true; name :=ai_name(ai_skill);end;
ps_play: begin isready:=false;name :='';               end;
      end;
      nttl :=0;
      state:=newstate;
   end;
end;

function PlayerSlotChangeState(PlayerRequestor,PlayerTarget,NewState:byte;Check:boolean):boolean;
begin
   PlayerSlotChangeState:=false;

   if(NewState=255)and(Check)then
   begin
      for NewState:=0 to ps_states_n-1 do
        if(PlayerSlotChangeState(PlayerRequestor,PlayerTarget,NewState,Check))then
        begin
           PlayerSlotChangeState:=true;
           break;
        end;
      exit;
   end;

   if(PlayerRequestor>MaxPlayers)
   or(PlayerTarget   >MaxPlayers)
   or(PlayerTarget   =0)
   or(NewState>=ps_states_n)
   or(G_Started)then exit;

   case NewState of
ps_ready   : with g_players[PlayerTarget] do
               if(state<>ps_play)
               or(PlayerTarget=PlayerLobby)
               or(    isready)
               or(net_status=ns_single)
               or(PlayerRequestor<>PlayerTarget)then exit;
ps_nready  : with g_players[PlayerTarget] do
               if(state<>ps_play)
               or(PlayerTarget=PlayerLobby)
               or(not isready)
               or(net_status=ns_single)
               or(PlayerRequestor<>PlayerTarget)then exit;
ps_swap    : if(not PlayersSwap(PlayerRequestor,PlayerTarget,true))then exit;
   else
      if(PlayerRequestor=PlayerTarget)then exit;
      if(PlayerRequestor>0)then
      begin
         if(PlayerRequestor<>PlayerLobby)and(PlayerLobby<>0)then exit;

         if(g_preset_cur>0)then
          with g_presets[g_preset_cur] do
           if(gp_player_team[PlayerTarget]>0)then
            case NewState of
      ps_closed,
      ps_observer : exit;
            end
            else exit;
      end;
   end;

   PlayerSlotChangeState:=true;

   if(Check)or(NewState=g_slot_state[PlayerTarget])then exit;

   with g_players[PlayerTarget] do
    case NewState of
ps_closed,
ps_opened   : begin
                 PlayerSetState(PlayerTarget,ps_none);
                 g_slot_state[PlayerTarget]:=NewState;
                 if(team=0)then team:=PlayerTarget;
                 team:=PlayerGetTeam(g_mode,PlayerTarget,255);
              end;
ps_observer : begin
                 g_slot_state[PlayerTarget]:=NewState;
                 PlayerSetState(PlayerTarget,ps_none);
                 team:=0;
              end;
ps_ready    : isready:=true;
ps_nready   : isready:=false;
ps_swap     : PlayersSwap(PlayerRequestor,PlayerTarget,false);
ps_AI_1..
ps_AI_11    : begin
                 g_slot_state[PlayerTarget]:=NewState;
                 ai_skill  :=NewState-ps_AI_1+1;
                 PlayerSetState(PlayerTarget,ps_comp);
                 if(team=0)then team:=PlayerTarget;
                 team:=PlayerGetTeam(g_mode,PlayerTarget,255);
              end;
    end;
end;
function PlayerSlotChangeRace(PlayerRequestor,PlayerTarget,NewRace:byte;Check:boolean):boolean;
begin
   PlayerSlotChangeRace:=false;

   if(NewRace=255)and(Check)then
   begin
      for NewRace:=0 to r_cnt do
        if(PlayerSlotChangeRace(PlayerRequestor,PlayerTarget,NewRace,Check))then
        begin
           PlayerSlotChangeRace:=true;
           break;
        end;
      exit;
   end;

   if(NewRace>r_cnt)
   or(PlayerRequestor>MaxPlayers)
   or(PlayerTarget   >MaxPlayers)
   or(PlayerTarget   =0)
   or(G_Started)then exit;

   with g_players[PlayerTarget] do
   begin
      if(team=0)
      or(g_slot_state[PlayerTarget]=ps_closed  )
      or(g_slot_state[PlayerTarget]=ps_observer)then exit;

      if((PlayerRequestor= PlayerTarget)and(state=ps_play))
      or((PlayerRequestor<>PlayerTarget)and(state=ps_comp)and((PlayerRequestor=0)or(PlayerRequestor=PlayerLobby)or(PlayerLobby=0)))
      then
      else exit;

      PlayerSlotChangeRace:=true;

      if(Check)or(NewRace=slot_race)then exit;

      slot_race:=NewRace;
   end;
end;
function PlayerSlotChangeTeam(PlayerRequestor,PlayerTarget,NewTeam:byte;Check:boolean):boolean;
var n:byte;
begin
   PlayerSlotChangeTeam:=false;

   if(NewTeam=255)and(Check)then
   begin
      n:=0;
      for NewTeam:=0 to MaxPlayers do
        if(PlayerSlotChangeTeam(PlayerRequestor,PlayerTarget,NewTeam,Check))then n+=1;
      PlayerSlotChangeTeam:=(n>1);
      exit;
   end;

   if(NewTeam        >MaxPlayers)
   or(PlayerRequestor>MaxPlayers)
   or(PlayerTarget   >MaxPlayers)
   or(PlayerTarget   =0)
   or(g_preset_cur   >0)
   or(G_Started)then exit;

   with g_players[PlayerTarget] do
   begin
      if( g_slot_state[PlayerTarget]=ps_observer)
      or( g_slot_state[PlayerTarget]=ps_closed  )
      or((ps_AI_1<=g_slot_state[PlayerTarget]   )and(g_slot_state[PlayerTarget]<=ps_AI_11)and(state=ps_comp)and(NewTeam=0))
      or((g_slot_state[PlayerTarget]=ps_opened  )and(state=ps_none))
      or((g_slot_state[PlayerTarget]=ps_opened  )and(state=ps_play)and(PlayerRequestor<>PlayerTarget))
      or((g_slot_state[PlayerTarget]=ps_opened  )and(state=ps_comp)and(PlayerRequestor>0)and(PlayerRequestor<>PlayerLobby)and(PlayerLobby>0))
      then exit;

      n:=team;
      team:=NewTeam;
      if(PlayerGetTeam(g_mode,PlayerTarget,255)<>team)then
      begin
         team:=n;
         exit;
      end
      else team:=n;

      PlayerSlotChangeTeam:=true;

      if(Check)or(NewTeam=team)then exit;

      team:=NewTeam;
   end;
end;

procedure PlayerKill(PlayerTarget:byte);
var u:integer;
begin
   for u:=1 to MaxUnits do
    if(g_punits[u]^.playeri=PlayerTarget)then
     unit_kill(g_punits[u],false,true,false,true,true);
end;

function PlayerSpecialDefeat(PlayerTarget:byte;Surrender,Check:boolean):boolean;
begin
   PlayerSpecialDefeat:=false;

   if(not g_started)
   or(PlayerTarget>MaxPlayers)then exit;

   with g_players[PlayerTarget] do
   begin
      if(state<>ps_play)then exit;

      if(Surrender)then
        if(armylimit<=0)
        or(isobserver)then exit;

      PlayerSpecialDefeat:=true;

      if(Check)then exit;

      if(armylimit>0)then PlayerKill(PlayerTarget);

      if(Surrender)then
      begin
         GameLogPlayerSurrender(PlayerTarget);
      end
      else
      begin
         GameLogPlayerLeave(PlayerTarget);
         PlayerSetState(PlayerTarget,ps_none);
      end;
   end;
end;

procedure PlayersSetDefault;
var p:byte;
begin
   FillChar(g_players,SizeOf(TPList),0);
   for p:=0 to MaxPlayers do
    with g_players[p] do
    begin
       g_slot_state[p]:=ps_opened;
       ai_skill  :=player_default_ai_level;
       slot_race :=r_random;
       race      :=r_random;
       team      :=p;
       isready   :=false;
       pnum      :=p;
       PlayerSetState(p,ps_none);
       PlayerSetSkirmishTech(p);
       PlayerClearLog(p);
       log_EnergyCheck:=0;
    end;

   with g_players[0] do
   begin
      race     :=r_hell;
      state    :=ps_comp;
      PlayerSetAllowedUnitsMax(0,[],0,true);
      PlayerSetAllowedUpgrades(0,[],0,true);
   end;

   FillChar(player_APMdata,SizeOf(player_APMdata),0);

   {$IFDEF _FULLGAME}
   PlayerColor[0]:=c_ltgray;
   PlayerColor[1]:=c_red;
   PlayerColor[2]:=c_orange;
   PlayerColor[3]:=c_yellow;
   PlayerColor[4]:=c_lime;
   PlayerColor[5]:=c_aqua;
   PlayerColor[6]:=c_blue;

   PlayerClient:=1;

   with g_players[PlayerClient] do
   begin
      state     :=ps_play;
      name      :=PlayerName;
   end;

   {$ELSE}
   PlayerClient:=0;
   with g_players[PlayerClient] do
   begin
      name :='SERVER';
   end;
   {$ENDIF}
   g_slot_state[PlayerClient]:=ps_opened;
   PlayerLobby:=PlayerClient;
end;

{procedure GameCheckCurrentPreset;
var i,p:byte;
begin
   g_preset_cur:=0;
   if(g_preset_n>1)then
    for p:=1 to g_preset_n-1 do
     with g_presets[g_preset_cur] do
     begin
        if(map_seed    <> gp_map_seed)
        or(map_mw      <> gp_map_mw  )
        or(map_type    <> gp_map_type)
        or(map_symmetry<> gp_map_symmetry)
        or(g_mode      <> gp_g_mode  )
        or(g_fixed_positions<> true  )then continue;

        for i:=1 to MaxPlayers do
          case (gp_player_slot[i]) of
          true : if not(g_slot_state[i] in [ps_opened,ps_AI_1..ps_AI_11])then continue;
          false: if not(g_slot_state[i] in [ps_observer,ps_closed      ])then continue;
          end;
        g_preset_cur:=p;
        break;
     end;
end;}

function GameLoadPreset(PlayerRequestor,preset:byte;Check:boolean):boolean;
var p:byte;
begin
   GameLoadPreset:=false;

   if(g_started)
   or((PlayerRequestor>0)and(PlayerLobby>0)and(PlayerLobby<>PlayerRequestor))
   or(preset>=g_preset_n)then exit;

   GameLoadPreset:=true;

   if(Check)then exit;

   g_preset_cur:=preset;

   if(g_preset_cur>0)then
   with g_presets[g_preset_cur] do
   begin
      map_seed    := gp_map_seed;
      map_mw      := gp_map_mw;
      map_type    := gp_map_type;
      map_symmetry:= gp_map_symmetry;
      g_mode      := gp_g_mode;
      g_fixed_positions
                  := true;

      for p:=1 to MaxPlayers do
        if(gp_player_team[p]>0)
        then PlayerSlotChangeState(0,p,ps_opened  ,false)
        else PlayerSlotChangeState(0,p,ps_observer,false);

      {$IFDEF _FULLGAME}
      PlayerSetState(PlayerClient,ps_play);
      g_players[PlayerClient].name:=PlayerName;
      {$ENDIF}

      map_premap;
   end;
end;

function GameSetCommonSetting(PlayerRequestor,setting,NewVal:byte;Check:boolean):boolean;
begin
   GameSetCommonSetting:=false;
   if(G_Started)
   or((PlayerRequestor>0)and(PlayerLobby>0)and(PlayerLobby<>PlayerRequestor))
   then exit;

   case setting of
nmid_lobbby_gamemode    : if(g_preset_cur=0)then
                          begin
                             if not(NewVal in allgamemodes)then exit;
                             GameSetCommonSetting:=true;
                             if(Check)then exit;
                             g_mode:=NewVal;
                             map_premap;
                          end;
nmid_lobbby_builders    : begin
                             if(NewVal>gms_g_startb)then exit;
                             GameSetCommonSetting:=true;
                             if(Check)then exit;
                             g_start_base:=NewVal;
                          end;
nmid_lobbby_generators  : begin
                             if(NewVal>gms_g_maxgens)then exit;
                             GameSetCommonSetting:=true;
                             if(Check)then exit;
                             g_generators:=NewVal;
                             map_premap;
                          end;
nmid_lobbby_FixStarts   : if(g_preset_cur=0)then
                          begin
                             GameSetCommonSetting:=true;
                             if(Check)then exit;
                             g_fixed_positions:=NewVal>0;
                             map_premap;
                          end;
nmid_lobbby_DeadPbserver: begin
                             GameSetCommonSetting:=true;
                             if(Check)then exit;
                             g_deadobservers:=NewVal>0;
                          end;
nmid_lobbby_EmptySlots  : begin
                             if(NewVal>gms_g_maxai)then exit;
                             GameSetCommonSetting:=true;
                             if(Check)then exit;
                             g_ai_slots:=NewVal;
                          end;
   end;
end;


procedure GameDefaultAll;
var u:integer;
begin
   randomize;

   G_Step          :=0;
   G_Status        :=0;
   g_player_astatus:=255;

   ServerSide      :=true;

   FillChar(g_cpoints ,SizeOf(g_cpoints ),0);
   FillChar(g_missiles,SizeOf(g_missiles),0);
   FillChar(g_units   ,SizeOf(g_units   ),0);

   for u:=0 to MaxUnits do
   with g_units[u] do
   begin
      hits  :=dead_hits;
      player:=@g_players[playeri];
      uid   :=@g_units  [uidi   ];
   end;
   LastCreatedUnit :=0;
   LastCreatedUnitP:=@g_units[LastCreatedUnit];

   PlayersSetDefault;

   UnitMoveStepTicks:= 8;

   g_inv_wave_n     := 0;
   g_inv_wave_t_next:= 0;
   g_inv_wave_t_curr:= 0;
   g_royal_r        := 0;

   g_cycle_order    := 0;
   g_cycle_regen    := 0;

   Map_premap;

   {$IFDEF _FULLGAME}
   sys_uncappedFPS:=false;
   test_fastprod:=false;

   menu_remake:= true;
   menu_redraw:= true;

   vid_cam_x:=-vid_panelw;
   vid_cam_y:=0;
   GameCameraBounds;

   vid_blink_timer1:=0;
   vid_blink_timer2:=0;

   ui_tab :=0;
   ui_UnitSelectedNU:=0;
   ui_UnitSelectedPU:=0;

   FillChar(g_effects ,SizeOf(g_effects ),0);
   FillChar(ui_alarms,SizeOf(ui_alarms),0);

   ingame_chat :=0;
   net_chat_str:='';
   net_cl_svttl:=0;
   net_status_str :='';

   ui_umark_u:=0;
   ui_umark_t:=0;

   mouse_select_x0:=-1;
   m_brush:=mb_empty;

   sys_fog   :=true;

   svld_str_fname:='';

   rpls_pnu  :=0;
   rpls_plcam:=false;
   rpls_state:=rpls_state_none;
   {$ELSE}
   screen_redraw:=true;
   {$ENDIF}
end;

{$IFDEF _FULLGAME}
procedure GameBreakClientGame;
begin
   net_disconnect;
   net_dispose;
   GameDefaultAll;
   G_started  :=false;
   net_status :=ns_single;
end;

{$include _replays.pas}
{$ENDIF}

procedure GameCreateStartBase(x,y:integer;uidF,uidA,pl,c:byte;AdvancedBase:boolean);
var  i,n,uid:byte;
r,d,ds:integer;
procedure _Spawn(tx,ty:integer);
begin
   if(n=0)and(AdvancedBase)and(c=0)
   then uid:=uidA
   else uid:=uidF;
   unit_add(tx,ty,0,uid    ,pl,true,false,0);
   n+=1;
end;
begin
   if(c>6)then c:=6;
   n:=0;

   if(c=0)
   then _Spawn(x,y)
   else
   begin
      if(c>5)then
      begin
         _Spawn(x,y);
         c-=1;
      end;
      ds :=map_mw div 2;
      d  :=point_dir(x,y,ds,ds);
      ds :=360 div (c+1);
      r  :=70+c*28; //18
      for i:=0 to c do
      begin
         _Spawn(
         x+trunc(r*cos(d*degtorad)),
         y-trunc(r*sin(d*degtorad))
         );

         d+=ds;
      end;
   end;
end;

procedure GameStartSkirmish;
var p:byte;
begin
   g_royal_r:=trunc(sqrt(sqr(map_hmw)*2));

   if(not g_fixed_positions)then
     if not(g_mode in gm_ModesFixedPositions)then map_ShufflePlayerStarts;

   for p:=0 to MaxPlayers do
   with g_players[p] do
   begin
      case g_slot_state[p] of
ps_closed   : PlayerSetState(p,ps_none);
ps_observer : team:=0;
ps_opened   : if(p>0)and(state=ps_none)and(g_ai_slots>0)then
              begin
                 ai_skill:=g_ai_slots;
                 race    :=r_random;
                 PlayerSetState(p,ps_comp);
                 if(team=0)then team:=1;
              end;
ps_AI_1..
ps_AI_11    : begin
                 ai_skill:=(g_slot_state[p]-ps_AI_1)+1;
              end;
      else
        g_slot_state[p]:=ps_closed;
        PlayerSetState(p,ps_none);
      end;

      team:=PlayerGetTeam(g_mode,p,255);

      if(p=0)then
      begin
         race    :=r_hell;
         ai_skill:=gms_g_maxai;
         PlayerSetState(p,ps_comp);
         PlayerSetCurrentUpgrades(p,[1..255],15,true,true);
         ai_PlayerSetSkirmishSettings(p);
      end
      else
      begin
         if(race=r_random)then race:=1+random(r_cnt);

         if(state=ps_play)then ai_skill:=player_default_ai_level;//g_ai_slots
      end;
   end;

   for p:=1 to MaxPlayers do
    with g_players[p] do
     if(state<>ps_none)then
     begin
        PlayerSetSkirmishTech(p);
        ai_PlayerSetSkirmishSettings(p);
        if(team>0)and(0<=map_psx[p])and(map_psx[p]<=map_mw)then
        begin
           GameCreateStartBase(map_psx[p],map_psy[p],uid_race_start_fbase[race],uid_race_start_abase[race],p,g_start_base,g_generators>0);
           unit_add(map_psx[p],map_psy[p],0,UID_Imp,p,true,false,0);
           unit_add(map_psx[p],map_psy[p],0,UID_Imp,p,true,false,0);
           unit_add(map_psx[p],map_psy[p],0,UID_Imp,p,true,false,0);
           unit_add(map_psx[p],map_psy[p],0,UID_Imp,p,true,false,0);
        end;
     end;

   {$IFDEF _FULLGAME}
   GameCameraMoveToPoint(map_psx[PlayerClient],map_psy[PlayerClient]);
   if(g_players[PlayerClient].team=0)then
   begin
      ui_tab:=3;
      UIPlayer:=0;
   end
   else UIPlayer:=PlayerClient;
   {$ENDIF}
end;


function GameStart(PlayerRequestor:byte;Check:boolean):boolean;
begin
   GameStart:=false;

   if(G_Started)
   or((PlayerRequestor>0)and(PlayerRequestor<>PlayerLobby)and(PlayerLobby>0))then exit;

   if(PlayersReadyStatus)then
   begin
      GameStart:=true;
      if(Check)then exit;
      G_Started :=true;
      {$IFDEF _FULLGAME}
      menu_state:=false;
      menu_item:=0;
      if(menu_s2<>ms2_camp)
      then GameStartSkirmish
      else ;//_CMPMap;
      vid_panel_timer:=0;
      {$ELSE}
      GameStartSkirmish;
      {$ENDIF}
   end;
end;
function GameBreak(PlayerRequestor:byte;Check:boolean):boolean;
begin
   GameBreak:=false;

   if(not G_Started)
   or((PlayerRequestor>0)and(PlayerRequestor<>PlayerLobby))then exit;

   GameBreak:=true;
   if(Check)then exit;
   {$IFDEF _FULLGAME}
   menu_item:=0;
   {$ENDIF}
   G_Started:=false;
   GameDefaultAll;
end;

{$IFDEF _FULLGAME}
procedure MakeRandomSkirmish(andstart:boolean);
var p:byte;
begin
   if(G_Started)then exit;

   Map_randommap;

   g_preset_cur:=0;
   g_mode      :=gm_scirmish;
   g_start_base:=random(gms_g_startb +1);
   g_generators:=random(gms_g_maxgens+1);

   PlayersSetDefault;

   for p:=2 to MaxPlayers do
    with g_players[p] do
    begin
       race :=random(r_cnt+1);
       slot_race:=race;

       if(p=4)
       then team:=1+random(4)
       else team:=2+random(3);

       if(random(2)=0)and(p>2)
       then PlayerSlotChangeState(0,p,ps_opened        ,false)
       else PlayerSlotChangeState(0,p,ps_AI_3+random(6),false);
    end;

   PlayersSwap(PlayerClient,random(MaxPlayers)+1,false);

   if(random(3)=0)
   then g_ai_slots:=0
   else g_ai_slots:=random(player_default_ai_level+1);

   Map_premap;

   if(andstart)then GameStart(PlayerClient,false);
end;
{$ELSE}
{$include _ded.pas}
{$ENDIF}

function CheckSimpleClick(o_x0,o_y0,o_x1,o_y1:integer):boolean;
begin
   CheckSimpleClick:=point_dist_rint(o_x0,o_y0,o_x1,o_y1)<4;
end;


procedure PlayerExecuteOrder(pl:byte);
var
su,eu,d: integer;
SelectBuildings,
ClearErrors,
pselected: boolean;
pu,
sability_u  : PTUnit;
sability_d  : integer;
function RectInRect(x0,y0,x1,y1,vx,vy,r:integer):boolean;
begin
   RectInRect:=((x0-r)<=vx)and(vx<=(x1+r))and((y0-r)<=vy)and(vy<=(y1+r));
end;
begin
   with g_players[pl] do
   if(o_id>0)and(army>0)then
   begin
      if(pl<>PlayerClient)then   // ded serverside counter
      PlayerAPMInc(pl);

      case o_id of
po_build               : if(0<o_a0)and(o_a0<255)then PlayerSetProdError(pl,lmt_argt_unit,byte(o_a0),StartBuild(o_x0,o_y0,byte(o_a0),pl),nil);
      else
        SelectBuildings:=true;
        ClearErrors:=false;

        if(o_id=po_select_rect_set)
        or(o_id=po_select_rect_add)then
        begin
           if(o_x0>o_x1)then begin su:=o_x1;o_x1:=o_x0;o_x0:=su;end;
           if(o_y0>o_y1)then begin su:=o_y1;o_y1:=o_y0;o_y0:=su;end;

           for su:=1 to MaxUnits do
            with g_punits[su]^ do
             if(hits>0)and(pl=playeri)and(not IsUnitRange(transport,nil))then
              with uid^ do
               if(RectInRect(o_x0,o_y0,o_x1,o_y1,vx,vy,_r))and(not _ukbuilding)then
               begin
                  SelectBuildings:=false;
                  break;
               end;
        end;

        if(o_id=po_unit_order_set)then
          if(IsUnitRange(o_x1,@pu))then
          begin
             o_x0:=pu^.x;
             o_y0:=pu^.y;
          end;

        case o_id of
po_prod_unit_stop,
po_prod_upgr_stop,
po_prod_stop      : begin
                       su:=MaxUnits;
                       eu:=1;
                    end;
        else
           su:=1;
           eu:=MaxUnits;
        end;

     //   selected_n:=ucl_cs[true]+ucl_cs[false];
        sability_d:=sability_d.MaxValue;
        sability_u:=nil;

        while(su<>eu)do
        begin
           pu:=g_punits[su];
           with pu^ do
           with uid^ do
           if(hits>0)and(not IsUnitRange(transport,nil))and(pl=playeri)then
           begin
              pselected:=isselected;

              case o_id of
// select
po_select_rect_set,
po_select_rect_add   : if(o_id=po_select_rect_set)
                       or((not isselected)and(o_id=po_select_rect_add))
                       then isselected:=RectInRect(o_x0,o_y0,o_x1,o_y1,vx,vy,_r)and(SelectBuildings or not _ukbuilding);
po_select_uid_set,
po_select_uid_add    : if(o_id=po_select_uid_set)
                       or((not isselected)and(o_id=po_select_uid_add))then
                         if(0<o_a0)and(o_a0<255)
                         then isselected:=RectInRect(o_x0,o_y0,o_x1,o_y1,vx,vy,_r)and(o_a0=uidi);
po_select_group_set,
po_select_group_add  : if(o_id=po_select_group_set)
                       or((not isselected)and(o_id=po_select_group_add))then isselected:=(group=o_a0);
po_select_special_set: isselected:=UnitF2Select(pu);

// groups
po_unit_group_set    : if(isselected)then
                       begin
                          if(0<=o_a0)and(o_a0<MaxUnitGroups)then group:=o_a0;
                       end
                       else if(group=o_a0)then group:=0;
po_unit_group_add    : if(isselected)then
                         if(0<=o_a0)and(o_a0<MaxUnitGroups)then group:=o_a0;

// unit orders
po_unit_order_set    : if(isselected)then
                         case o_a0 of
                       uo_move      : unit_SetOrder(pu,o_x1,o_x0,o_y0,-1,-1,ua_move  );
                       uo_attack    : unit_SetOrder(pu,o_x1,o_x0,o_y0,-1,-1,ua_attack);
                       uo_patrol    : unit_SetOrder(pu,0   ,o_x0,o_y0,x ,y ,ua_move  );
                       uo_apatrol   : unit_SetOrder(pu,0   ,o_x0,o_y0,x ,y ,ua_attack);
                       //uo_stay      : default
                       uo_hold      : unit_SetOrder(pu,0   ,x   ,y   ,-1,-1,ua_hold  );
                       uo_destroy   : begin unit_kill(pu,false,false,true,false,true);pselected:=isselected;end;
                       uo_sability  : if(ua_id<>ua_psability)then
                                        if(unit_sability (pu,false))then ClearErrors:=true;
                       uo_psability : if(ua_id<>ua_psability)then
                                        if(unit_psability(pu,o_x0,o_y0,o_x1,true))then
                                        begin
                                           ClearErrors:=true;
                                           d:=point_dist_int(o_x0,o_y0,x,y);
                                           if(d<sability_d)then
                                           begin
                                              sability_d:=d;
                                              sability_u:=pu;
                                           end;
                                        end;
                       uo_rebuild   : if(_unit_rebuild(pu,false))then ClearErrors:=true;
                         else         unit_SetOrder(pu,0   ,x   ,y   ,-1,-1,ua_attack);
                         end;
po_prod_stop         : if(isselected)then
                       begin
                       if(unit_ProdUnitStop(pu,255,false))then break;
                       if(unit_ProdUpgrStop(pu,255,false))then break;
                       end;
              end;

              if(0<o_a0)and(o_a0<=255)then
              begin
                 if(s_barracks<=0)or(isselected)then
                   case o_id of
po_prod_unit_start   : if(unit_ProdUnitStart(pu,o_a0      ))then begin PlayerClearProdError(player);break;end;// start  training
po_prod_unit_stop    : if(unit_ProdUnitStop (pu,o_a0,false))then break;
                   end;
                 if(s_smiths  <=0)or(isselected)then
                   case o_id of
po_prod_upgr_start   : if(unit_ProdUpgrStart(pu,o_a0      ))then begin PlayerClearProdError(player);break;end;// start  upgr
po_prod_upgr_stop    : if(unit_ProdUpgrStop (pu,o_a0,false))then break;
                   end;
              end;

              if(isselected)then
              begin
                 if(pselected=false)then
                 begin
                    unit_PC_select_inc(pu);
                    {$IFDEF _FULLGAME}
                    UpdateLastSelectedUnit(unum);
                    {$ENDIF}
                 end;
              end
              else
                if(pselected=true)then unit_PC_select_dec(pu);
           end;

           if(su>eu)
           then su-=1
           else su+=1;
        end;

        if(o_id=po_unit_order_set)then
          case o_a0 of
uo_psability : if(sability_u<>nil)then unit_psability(sability_u,o_x0,o_y0,o_x1,false);
          end;
        if(ClearErrors)then PlayerClearProdError(@g_players[pl]);
      end;

      o_id:=0;
   end;
end;

procedure GameDefaultEndConditions;
var p,wteam_last,wteams_n: byte;
teams_army: array[0..MaxPlayers] of integer;
begin
   if(net_status>ns_single)and(G_Step<fr_fps1)then exit;

   wteam_last:=255;
   wteams_n  :=0;
   FillChar(teams_army,SizeOf(teams_army),0);
   for p:=0 to MaxPlayers do
    with g_players[p] do
     teams_army[team]+=army;

   for p:=0 to MaxPlayers do
    if(teams_army[p]>0)then
    begin
       wteam_last:=p;
       wteams_n  +=1;
    end;

   if(wteams_n=1)then GameSetStatusWinnerTeam(wteam_last);
end;

procedure GameDefaultDefeatConditions;
var i:byte;
begin
   for i:=1 to MaxPlayers do
     if(g_players[i].army>0)then exit;
   GameSetStatusWinnerTeam(0);
end;

procedure PlayersCycle;
var p:byte;
begin
   for p:=0 to MaxPlayers do
    with g_players[p] do
     if(state>ps_none)then
     begin
        if(state=ps_play)and(p<>PlayerClient)and(net_status=ns_server)then
        begin
           if(nttl<ClientTTL)then
           begin
              nttl+=1;
              if(nttl=ClientTTL)or(nttl=fr_fps1)then {$IFDEF _FULLGAME}menu_remake{$ELSE}screen_redraw{$ENDIF}:=true;
           end
           else
             if(G_Started=false)then
             begin
                PlayerSetState(p,ps_none);
                {$IFDEF _FULLGAME}menu_remake{$ELSE}screen_redraw{$ENDIF}:=true;
             end;
        end;
        if(net_logsend_pause>0)then net_logsend_pause-=1;

        if(G_Started)and(G_Status=gs_running)then
        begin
           if(build_cd>0)then build_cd-=1;

           if(ServerSide)then
           begin
              isrevealed:=false;
              if(n_builders=0){$IFDEF _FULLGAME}and(menu_s2<>ms2_camp){$ENDIF}then
                if(g_mode<>gm_invasion)
                or(p>0)then isrevealed:=true;

              PlayerExecuteOrder(p);

              if(state=ps_comp)
              then ai_player_code(p)
              else
                if(log_EnergyCheck>0)
                then log_EnergyCheck-=1
                else
                  if(cenergy>=0)
                  then log_EnergyCheck:=1
                  else
                  begin
                     log_EnergyCheck:=fr_fps6;
                     PlayersAddToLog(p,0,lmt_req_energy,0,0,'',-1,-1,false);
                  end;

              if(prod_error_cndt>0)then
                GameLogCantProduction(p,prod_error_uid,prod_error_utp,prod_error_cndt,prod_error_x,prod_error_y,false);
              prod_error_cndt  :=0;
           end;
        end;
     end;

   for p:=0 to MaxPlayers do PlayerAPMUpdate(p);
end;

{$include _net_game.pas}

procedure CodeGame;
begin
   {$IFDEF _FULLGAME}
   vid_blink_timer1+=1;vid_blink_timer1:=vid_blink_timer1 mod vid_blink_period1;
   vid_blink_timer2+=1;vid_blink_timer2:=vid_blink_timer2 mod vid_blink_period2;

   if(vid_blink_timer1=0)then
   begin
      r_blink3+=1;
      r_blink3:=r_blink3 mod 4;
   end;

   vid_panel_timer+=1;vid_panel_timer:=vid_panel_timer mod vid_panel_period;

   r_blink1_colorb  :=vid_blink_timer1>vid_blink_periodh;
   r_blink2_colorb  :=vid_blink_timer2>vid_blink_period1;

   r_blink1_color_BG:=ui_blink_color1[r_blink1_colorb];
   r_blink1_color_BY:=ui_blink_color2[r_blink1_colorb];
   r_blink2_color_BG:=ui_blink_color1[r_blink2_colorb];
   r_blink2_color_BY:=ui_blink_color2[r_blink2_colorb];

   SoundControl;

   if(net_status=ns_client)then
    if(net_svsearch)
    then net_Discowering
    else net_Client;
   replay_Code;

   {$ELSE}
   Dedicated_Code;
   Dedicated_Screen;
   {$ENDIF}

   PlayersCycle;

   if(G_Started)and(G_Status=gs_running)then
   begin
      g_cycle_order+=1;g_cycle_order:=g_cycle_order mod order_period;
      g_cycle_regen+=1;g_cycle_regen:=g_cycle_regen mod regen_period;

      if(ServerSide)then
      begin
         G_Step+=1;

         UpdatePlayersStatusVars;

         GameModeCPoints;
         case g_mode of
         gm_invasion  : begin
                        GameModeInvasion;
                        GameDefaultDefeatConditions;
                        end;
         gm_royale    : begin
                           if(g_cycle_order=0)then
                             if(g_royal_r>0)then g_royal_r-=1;
                           GameDefaultEndConditions;
                        end;
         gm_capture,
         gm_KotH      : GameDefaultDefeatConditions;
         else           GameDefaultEndConditions;
         end;
      end;
      GameObjectsCode;
   end;

   if(net_status=ns_server)then net_Server;
end;


