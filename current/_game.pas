
procedure PlayerSetSkirmishTech(PlayerTarget:byte);
begin
   with g_players[PlayerTarget] do
   begin
      PlayerSetAllowedUnits(PlayerTarget,[UID_HKeep         ..UID_HBarracks,
                                          UID_LostSoul      ..UID_ZBFGMarine,
                                          UID_UCommandCenter..UID_UComputerStation,
                                          UID_Engineer      ..UID_Flyer  ],
                                          MaxUnits,true);

      PlayerSetAllowedUnits(PlayerTarget,[UID_HMonastery ,UID_HFortress       ,UID_HAltar,
                                          UID_UTechCenter,UID_UComputerStation,UID_URMStation ],1,false);

      PlayerSetAllowedUnits(PlayerTarget,[UID_LostSoul, UID_Phantom ],20,false);


      case g_generators of
      0:;
      1    :PlayerSetAllowedUnits(PlayerTarget,[UID_HKeep     ,UID_HCommandCenter,UID_UCommandCenter                    ],0,false);
      else  PlayerSetAllowedUnits(PlayerTarget,[UID_HSymbol   ,UID_HASymbol      ,UID_HKeep          ,UID_HCommandCenter,
                                                UID_UGenerator,UID_UAGenerator   ,UID_UCommandCenter                    ],0,false);
      end;

      PlayerSetAllowedUpgrades(PlayerTarget,[0..255],255,true);
   end;
end;

function PlayersSwap(SlotSource,SlotTarget:byte;Check:boolean):boolean;
var tp:TPlayer;
begin
   PlayersSwap:=false;

   if(SlotSource>LastPlayer  )
   or(SlotTarget>LastPlayer  )
   or(SlotSource=SlotTarget)then exit;

   with g_players[SlotSource] do
     if(player_type<>pt_human)
     then exit
     else
       if(g_slot_state[SlotSource]<>pss_opened  )and
         (g_slot_state[SlotSource]<>pss_observer)then exit;

   with g_players[SlotTarget] do
     if(player_type=pt_human)then exit;
   if(g_slot_state[SlotTarget]<>pss_opened  )and
     (g_slot_state[SlotTarget]<>pss_observer)then exit;

   PlayersSwap:=true;

   if(Check)then exit;

   tp:=g_players[SlotSource];
   g_players[SlotSource]:=g_players[SlotTarget];
   g_players[SlotTarget]:=tp;

   g_players[SlotSource].pnum:=SlotSource;
   g_players[SlotTarget].pnum:=SlotTarget;

   case g_slot_state[SlotSource] of
   pss_observer: ;
   pss_opened  : g_players[SlotSource].team:=PlayerSlotGetTeam(g_mode,SlotSource,SlotSource);
   end;
   case g_slot_state[SlotTarget] of
   pss_observer: ;
   pss_opened  : g_players[SlotTarget].team:=PlayerSlotGetTeam(g_mode,SlotTarget,SlotTarget);
   end;

   if(PlayerClient=SlotTarget)then PlayerClient:=SlotSource
   else
     if(PlayerClient=SlotSource)then PlayerClient:=SlotTarget;

   if(PlayerLobby=SlotTarget)then PlayerLobby:=SlotSource
   else
     if(PlayerLobby=SlotSource)then PlayerLobby:=SlotTarget;
end;

procedure PlayerSetType(PlayerTarget,newType:byte);
begin
   with g_players[PlayerTarget] do
   begin
      case newType of
pt_none : begin isready:=false;name :=str_pt_none;      end;
pt_ai   : begin isready:=true; name :=ai_name(ai_skill);end;
pt_human: begin isready:=false;name :='';               end;
      end;
      net_ttl :=0;
      player_type:=newType;
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

   if(NewState     >=ps_states_n)
   or(PlayerRequestor>LastPlayer)
   or(PlayerTarget   >LastPlayer)
   or(G_Started)then exit;

   case NewState of
pss_ready    : with g_players[PlayerTarget] do
                 if(player_type<>pt_human)
                 or(PlayerTarget=PlayerLobby)
                 or(    isready)
                 or(net_status=ns_single)
                 or(PlayerRequestor<>PlayerTarget)then exit;
pss_nready   : with g_players[PlayerTarget] do
                 if(player_type<>pt_human)
                 or(PlayerTarget=PlayerLobby)
                 or(not isready)
                 or(net_status=ns_single)
                 or(PlayerRequestor<>PlayerTarget)then exit;
pss_swap     : if(not PlayersSwap(PlayerRequestor,PlayerTarget,true))then exit;
pss_sobserver: with g_players[PlayerTarget] do
                 if(player_type<>pt_human)
                 or(    isobserver)
                 or(g_slot_state[PlayerTarget]=pss_observer)
                 or(PlayerRequestor<>PlayerTarget)then exit;
pss_splayer  : with g_players[PlayerTarget] do
                 if(player_type<>pt_human)
                 or(not isobserver)
                 or(g_slot_state[PlayerTarget]=pss_observer)
                 or(PlayerRequestor<>PlayerTarget)then exit;
   else
      if(PlayerRequestor=PlayerTarget)then exit;

      if(PlayerRequestor<>PlayerLobby)and(PlayerLobby<=LastPlayer)then exit;

      {if(g_preset_cur>0)then
       with g_presets[g_preset_cur] do
        if(gp_player_team[PlayerTarget]<=LastPlayer)then
         case NewState of
      pss_closed,
      pss_observer : exit;
         end
       else exit; }
   end;

   PlayerSlotChangeState:=true;

   if(Check)or(NewState=g_slot_state[PlayerTarget])then exit;

   with g_players[PlayerTarget] do
    case NewState of
pss_closed,
pss_opened   : begin
                 PlayerSetType(PlayerTarget,pt_none);
                 g_slot_state[PlayerTarget]:=NewState;
                 team:=PlayerSlotGetTeam(g_mode,PlayerTarget,255);
              end;
pss_observer : begin
                 g_slot_state[PlayerTarget]:=NewState;
                 PlayerSetType(PlayerTarget,pt_none);
              end;
pss_sobserver: isobserver:=true;
pss_splayer  : isobserver:=false;
pss_ready    : isready:=true;
pss_nready   : isready:=false;
pss_swap     : PlayersSwap(PlayerRequestor,PlayerTarget,false);
pss_AI_1..
pss_AI_11    : begin
                 g_slot_state[PlayerTarget]:=NewState;
                 ai_skill  :=NewState-pss_AI_1+1;
                 PlayerSetType(PlayerTarget,pt_ai);
                 team:=PlayerSlotGetTeam(g_mode,PlayerTarget,255);
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
   or(PlayerRequestor>LastPlayer)
   or(PlayerTarget   >LastPlayer)
   or(G_Started)then exit;

   with g_players[PlayerTarget] do
   begin
      if(isobserver)
      or(g_slot_state[PlayerTarget]=pss_closed  )
      or(g_slot_state[PlayerTarget]=pss_observer)then exit;

      if((PlayerRequestor= PlayerTarget)and(player_type=pt_human))
      or((PlayerRequestor<>PlayerTarget)and(player_type=pt_ai)and((PlayerRequestor=PlayerLobby)or(PlayerLobby>LastPlayer)))
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
      for NewTeam:=0 to LastPlayer do
        if(PlayerSlotChangeTeam(PlayerRequestor,PlayerTarget,NewTeam,Check))then n+=1;
      PlayerSlotChangeTeam:=(n>1);
      exit;
   end;

   if(NewTeam        >LastPlayer)
   or(PlayerRequestor>LastPlayer)
   or(PlayerTarget   >LastPlayer)
   or(g_preset_cur   >0)
   or(G_Started)then exit;

   with g_players[PlayerTarget] do
   begin
      if( g_slot_state[PlayerTarget]=pss_observer)
      or( g_slot_state[PlayerTarget]=pss_closed  )

      or((pss_AI_1<=g_slot_state[PlayerTarget]   )
      and(g_slot_state[PlayerTarget]<=pss_AI_11  )and(player_type=pt_ai  )and(PlayerRequestor<>PlayerLobby )and(PlayerLobby<=LastPlayer))

      or((g_slot_state[PlayerTarget]=pss_opened  )and(player_type=pt_none))
      or((g_slot_state[PlayerTarget]=pss_opened  )and(player_type=pt_human)and(PlayerRequestor<>PlayerTarget))
      or((g_slot_state[PlayerTarget]=pss_opened  )and(player_type=pt_ai   )and(PlayerRequestor<>PlayerLobby )and(PlayerLobby<=LastPlayer))
      or(isobserver)
      then exit;

      n:=team;
      team:=NewTeam;
      if(PlayerSlotGetTeam(g_mode,PlayerTarget,255)<>team)then
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

function PlayerSurrender(PlayerTarget:byte;Check:boolean):boolean;
begin
   PlayerSurrender:=false;

   if(not G_Started)
   or(PlayerTarget>LastPlayer)
   or(rpls_rstate=rpls_state_read)
   or(GameStatus_End)
   or(not g_deadobservers)then exit;

   with g_players[PlayerTarget] do
   if(not isdefeated)and(not isobserver)then
   begin
      PlayerSurrender:=true;

      if(Check)then exit;

      isdefeated:=true;
      isobserver:=true;
      GameLogPlayerSurrender(PlayerTarget);
   end;
end;
function PlayerDefeat(PlayerTarget:byte;Check:boolean):boolean;
begin
   PlayerDefeat:=false;

   if(not G_Started)
   or(PlayerTarget>LastPlayer)then exit;

   with g_players[PlayerTarget] do
   if(not isdefeated)and(not isobserver)then
   begin
      PlayerDefeat:=true;

      if(Check)then exit;

      isdefeated:=true;
      GameLogPlayerDefeated(PlayerTarget);
   end;
end;
function PlayerLeave(PlayerTarget:byte;Check:boolean):boolean;
begin
   PlayerLeave:=false;

   if(not G_Started)
   or(PlayerTarget>LastPlayer)then exit;

   with g_players[PlayerTarget] do
   if(player_type>pt_none)then
   begin
      PlayerLeave:=true;

      if(Check)then exit;

      isdefeated:=true;

      GameLogPlayerLeave(PlayerTarget);
      PlayerSetType(PlayerTarget,pt_none);
   end;
end;


procedure PlayersSetDefault;
var p:byte;
begin
   FillChar(g_players,SizeOf(TPList),0);
   for p:=0 to LastPlayer do
    with g_players[p] do
    begin
       g_slot_state[p]:=pss_opened;
       ai_skill       :=player_default_ai_level;
       slot_race      :=r_random;
       race           :=r_random;
       team           :=p;
       pnum           :=p;
       isready        :=false;
       isobserver     :=false;
       isdefeated     :=false;
       isrevealed     :=false;
       PlayerSetType(p,pt_none);
       PlayerSetSkirmishTech(p);
       PlayerClearLog(p);
       log_EnergyCheck:=0;
    end;

   with g_players[0] do
   begin
      race       :=r_hell;
      player_type:=pt_ai;
      PlayerSetAllowedUnits   (0,[],0,true);
      PlayerSetAllowedUpgrades(0,[],0,true);
   end;

   {$IFDEF _FULLGAME}
   PlayerColorSchemeFFA[0]:=c_red;
   PlayerColorSchemeFFA[1]:=c_orange;
   PlayerColorSchemeFFA[2]:=c_yellow;
   PlayerColorSchemeFFA[3]:=c_lime;
   PlayerColorSchemeFFA[4]:=c_aqua;
   PlayerColorSchemeFFA[5]:=c_blue;
   PlayerColorSchemeFFA[6]:=c_lpurple;
   PlayerColorSchemeFFA[7]:=c_purple;

   PlayerColorSchemeTEAM[0]:=c_lime;
   PlayerColorSchemeTEAM[1]:=c_red;
   PlayerColorSchemeTEAM[2]:=c_aqua;
   PlayerColorSchemeTEAM[3]:=c_yellow;
   PlayerColorSchemeTEAM[4]:=c_blue;
   PlayerColorSchemeTEAM[5]:=c_orange;
   PlayerColorSchemeTEAM[6]:=c_purple;
   PlayerColorSchemeTEAM[7]:=c_lpurple;

   UpdateScirmishColorScheme;

   PlayerClient:=0;

   with g_players[PlayerClient] do
   begin
      player_type:=pt_human;
      name       :=PlayerName;
   end;
   g_slot_state[PlayerClient]:=pss_opened;
   PlayerLobby:=PlayerClient;

   {$ELSE}
   PlayerClient:=255;
  { with g_players[PlayerClient] do
   begin
      name :='SERVER';
   end;  }
   {$ENDIF}
end;

procedure InitGamePresets;
procedure SetPreset(pid:byte;mseed:cardinal;msize:integer;mtype,msym,gmode,t1,t2,t3,t4,t5,t6:byte);
begin
   if(g_preset_n<=pid)then
   begin
      if(g_preset_n=255)then exit;
      while(g_preset_n<=pid)do
      begin
         g_preset_n+=1;
         setlength(g_presets,g_preset_n);
      end;
   end;

   with g_presets[pid] do
   begin
      gp_map_seed    := mseed;
      gp_map_mw      := msize;
      gp_map_type    := mtype;
      gp_map_symmetry:= msym;
      gp_g_mode      := gmode;
      FillChar(gp_player_team,SizeOf(gp_player_team),0);
      gp_player_team[1]:=t1;
      gp_player_team[2]:=t2;
      gp_player_team[3]:=t3;
      gp_player_team[4]:=t4;
      gp_player_team[5]:=t5;
      gp_player_team[6]:=t6;
   end;
end;
begin
   g_preset_cur:=0;
   g_preset_n  :=0;
   setlength(g_presets,g_preset_n);

   SetPreset(gp_1x1_plane   , 667,4000,mapt_steppe,1,gm_scirmish,0,1,255,255,255,255);
   SetPreset(gp_1x1_lake    ,6667,4000,mapt_clake ,1,gm_scirmish,0,1,155,255,255,255);
   SetPreset(gp_1x1_cave    , 667,4000,mapt_canyon,1,gm_scirmish,0,1,255,255,255,255);

   {$IFNDEF _FULLGAME}
   g_presets[gp_custom].gp_name:= 'custom preset';
   MakeGamePresetsNames(@str_gmodel[0],@str_m_typel[0]);
   {$ENDIF}
end;

function GameLoadPreset(PlayerRequestor,preset:byte;Check:boolean):boolean;
var p:byte;
begin
   GameLoadPreset:=false;

   if(G_Started)
   or(PlayerRequestor>lastPlayer)
   or((PlayerLobby<>PlayerRequestor)and(PlayerLobby<=LastPlayer))
   or(preset>=g_preset_n)then exit;

   GameLoadPreset:=true;

   if(Check)then exit;

   g_preset_cur:=preset;

   if(g_preset_cur>0)then
   with g_presets[g_preset_cur] do
   begin
      map_seed    := gp_map_seed;
      map_size    := gp_map_mw;
      map_type    := gp_map_type;
      map_symmetry:= gp_map_symmetry;
      g_mode      := gp_g_mode;
      g_fixed_positions
                  := false;

      for p:=0 to LastPlayer do
        if(gp_player_team[p]>0)
        then PlayerSlotChangeState(0,p,pss_opened  ,false)
        else PlayerSlotChangeState(0,p,pss_observer,false);

      {$IFDEF _FULLGAME}
      PlayerSetType(PlayerClient,pt_human);
      g_players[PlayerClient].name:=PlayerName;
      {$ENDIF}

      map_Make1;
   end;
end;

function GameSetCommonSetting(PlayerRequestor,setting,NewVal:byte;Check:boolean):boolean;
begin
   GameSetCommonSetting:=false;
   if(G_Started)
   or((PlayerRequestor<=LastPlayer)and(PlayerLobby<=LastPlayer)and(PlayerLobby<>PlayerRequestor))
   then exit;

   case setting of
nmid_lobbby_gamemode    : if(g_preset_cur=0)then
                          begin
                             if not(NewVal in allgamemodes)then exit;
                             GameSetCommonSetting:=true;
                             if(Check)then exit;
                             g_mode:=NewVal;
                             map_Make1;
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
                             map_Make1;
                          end;
nmid_lobbby_FixStarts   : if(g_preset_cur=0)then
                          begin
                             GameSetCommonSetting:=true;
                             if(Check)then exit;
                             g_fixed_positions:=NewVal>0;
                             map_Make1;
                          end;
nmid_lobbby_DeadPObs: begin
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

   g_royal_r        := 0;

   g_cycle_order    := 0;
   g_cycle_regen    := 0;

   map_Make1;

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
   rpls_POVCam:=false;
   rpls_rstate:=rpls_state_none;
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
   G_Started :=false;
   net_status:=ns_single;
end;

{$include _replays.pas}
{$ENDIF}

procedure GameCreateStartBase(x,y:integer;uidF,uidA,pl,c:byte;AdvancedBase:boolean);
var
n,uid :byte;
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
   n:=0;
   if(c>6)then c:=6;

   _Spawn(x,y);

   if(c=0)then exit;

   d  :=point_dir(x,y,map_hsize,map_hsize);
   ds :=360 div c;
   r  :=g_uids[uid]._r*2+2;

   while(c>0) do
   begin
      _Spawn(
      x+trunc(r*cos(d*degtorad)),
      y-trunc(r*sin(d*degtorad)));
      d+=ds;
      c-=1;
   end;
end;

procedure GameConfigureSkirmish;
var p:byte;
begin
   g_royal_r:=trunc(sqrt(sqr(map_hsize)*2));

   for p:=0 to LastPlayer do
     with g_players[p] do
     begin
        case g_slot_state[p] of
pss_closed   : PlayerSetType(p,pt_none);
pss_observer : isobserver:=true;
pss_opened   : if(player_type=pt_none)and(g_ai_slots>0)then
               begin
                  ai_skill:=g_ai_slots;
                  race    :=r_random;
                  PlayerSetType(p,pt_ai);
               end;
pss_AI_1..
pss_AI_11    : ai_skill:=(g_slot_state[p]-pss_AI_1)+1;
        else
          g_slot_state[p]:=pss_closed;
          PlayerSetType(p,pt_none);
        end;

        team:=PlayerSlotGetTeam(g_mode,p,255);
        race:=slot_race;

        if(race=r_random)then race:=1+random(r_cnt);

        if(player_type=pt_human)then ai_skill:=player_default_ai_level;//g_ai_slots
     end;

   if(not g_fixed_positions)then map_ShufflePlayerStarts(g_mode in gm_ModesFixedTeams);

   for p:=0 to LastPlayer do
    with g_players[p] do
     if(player_type<>pt_none)and(not isobserver)then
     begin
        PlayerSetSkirmishTech(p);
        ai_PlayerSetSkirmishSettings(p);
        if (0<=map_PlayerStartX[p])and(map_PlayerStartX[p]<=map_size)
        and(0<=map_PlayerStartY[p])and(map_PlayerStartY[p]<=map_size)then
        begin
           GameCreateStartBase(map_PlayerStartX[p],
                               map_PlayerStartY[p],
                               uid_race_start_fbase[race],
                               uid_race_start_abase[race],p,g_start_base,g_generators>0);
           unit_add(map_PlayerStartX[p],map_PlayerStartY[p],0,UID_Imp,p,true,false,0);
           //unit_add(map_PlayerStartX[p],map_PlayerStartY[p],0,UID_Imp,p,true,false,0);
           //unit_add(map_PlayerStartX[p],map_PlayerStartY[p],0,UID_Imp,p,true,false,0);
           //unit_add(map_PlayerStartX[p],map_PlayerStartY[p],0,UID_Imp,p,true,false,0);
        end;
     end;

   {$IFDEF _FULLGAME}
   GameCameraMoveToPoint(map_PlayerStartX[PlayerClient],map_PlayerStartY[PlayerClient]);
   if(g_players[PlayerClient].isobserver)then ui_tab:=3;
   UIPlayer:=PlayerClient;
   {$ENDIF}
end;


function GameStartScirmish(PlayerRequestor:byte;Check:boolean):boolean;
begin
   GameStartScirmish:=false;

   if(G_Started)
   or((PlayerRequestor<=LastPlayer)and(PlayerRequestor<>PlayerLobby)and(PlayerLobby<=LastPlayer))then exit;

   if(PlayersReadyStatus)then
   begin
      GameStartScirmish :=true;
      if(Check)then exit;
      G_Started :=true;
      {$IFDEF _FULLGAME}
      menu_state:=false;
      menu_item :=0;
      G_Status  :=gs_running;
      vid_panel_timer:=0;
      {$ENDIF}
      map_Make2;
      GameConfigureSkirmish;
   end;
end;
function GameBreak(PlayerRequestor:byte;Check:boolean):boolean;
begin
   GameBreak:=false;

   if(not G_Started)
   or(net_status=ns_client)
   or((PlayerRequestor<=LastPlayer)and(PlayerRequestor<>PlayerLobby))then exit;

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

   for p:=1 to LastPlayer do
    with g_players[p] do
    begin
       race :=random(r_cnt+1);
       slot_race:=race;

       if(p=4)
       then team:=1+random(4)
       else team:=2+random(3);

       if(random(2)=0)and(p>1)
       then PlayerSlotChangeState(0,p,pss_opened        ,false)
       else PlayerSlotChangeState(0,p,pss_AI_3+random(6),false);
    end;

   PlayersSwap(PlayerClient,random(MaxPlayer),false);

   if(random(3)=0)
   then g_ai_slots:=0
   else g_ai_slots:=random(player_default_ai_level+1);

   map_Make1;

   if(andstart)then GameStartScirmish(PlayerClient,false);
end;
{$ELSE}
{$include _ded.pas}
{$ENDIF}

function CheckSimpleClick(o_x0,o_y0,o_x1,o_y1:integer):boolean;
begin
   CheckSimpleClick:=point_dist_rint(o_x0,o_y0,o_x1,o_y1)<4;
end;


procedure PlayerExecuteOrder(playern:byte);
var
su,eu,d     : integer;
SelectBuildings,
ClearErrors,
pselected   : boolean;
pu,
sability_u  : PTUnit;
sability_d  : integer;
function RectInRect(x0,y0,x1,y1,vx,vy,r:integer):boolean;
begin
   RectInRect:=((x0-r)<=vx)and(vx<=(x1+r))and((y0-r)<=vy)and(vy<=(y1+r));
end;
begin
   with g_players[playern] do
   begin
      //if(playern<>PlayerClient)then   // ded serverside counter
      //  PlayerAPMInc(playern);

      case o_id of
po_build        : if(0<o_a0)and(o_a0<255)then PlayerSetProdError(playern,lmt_argt_unit,byte(o_a0),StartBuild(o_x0,o_y0,byte(o_a0),playern),nil);
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
             if(hits>0)and(playern=playeri)and(not IsUnitRange(transport,nil))then
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

        sability_d:=sability_d.MaxValue;
        sability_u:=nil;

        while(su<>eu)do
        begin
           pu:=g_punits[su];
           with pu^  do
           with uid^ do
           if(hits>0)and(not IsUnitRange(transport,nil))and(playern=playeri)then
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
po_select_all_set    : isselected:=UnitF2Select(pu);

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
                       uo_move      : unit_SetOrder(pu,o_x1,o_x0,o_y0,-1,-1,ua_move  ,true );
                       uo_attack    : unit_SetOrder(pu,o_x1,o_x0,o_y0,-1,-1,ua_attack,true );
                       uo_patrol    : unit_SetOrder(pu,0   ,o_x0,o_y0, x, y,ua_move  ,true );
                       uo_apatrol   : unit_SetOrder(pu,0   ,o_x0,o_y0, x, y,ua_attack,true );
                       uo_hold      : unit_SetOrder(pu,0   ,x   ,y   ,-1,-1,ua_hold  ,false);
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
                       uo_rebuild   : if(unit_rebuild(pu,false))then ClearErrors:=true;
                         else
                     //uo_stay      : default
                                      unit_SetOrder(pu,0   ,x   ,y   ,-1,-1,ua_attack,false);
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
                 if(not pselected)then
                 begin
                    unit_PC_select_inc(pu);
                    {$IFDEF _FULLGAME}
                    UpdateLastSelectedUnit(unum);
                    {$ENDIF}
                 end;
              end
              else
                if(pselected)then unit_PC_select_dec(pu);
           end;

           if(su>eu)
           then su-=1
           else su+=1;
        end;

        if(o_id=po_unit_order_set)then
          case o_a0 of
uo_psability : if(sability_u<>nil)then unit_psability(sability_u,o_x0,o_y0,o_x1,false);
          end;
        if(ClearErrors)then PlayerClearProdError(@g_players[playern]);
      end;

      o_id:=0;
   end;
end;

procedure GameDefaultEndConditions;
var p,wteam_last,wteams_n: byte;
teams_army: array[0..LastPlayer] of integer;
begin
   if(net_status>ns_single)and(G_Step<fr_fps1)then exit;

   wteam_last:=255;
   wteams_n  :=0;
   FillChar(teams_army,SizeOf(teams_army),0);
   for p:=0 to LastPlayer do
    with g_players[p] do
     teams_army[team]+=army;

   for p:=0 to LastPlayer do
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
   for i:=0 to LastPlayer do
     if(g_players[i].army>0)then exit;
   GameSetStatusWinnerTeam(0);
end;

procedure PlayersCycle;
var p:byte;
begin
   for p:=0 to LastPlayer do
    with g_players[p] do
     if(player_type>pt_none)then
     begin
        if(player_type=pt_human)and(p<>PlayerClient)and(net_status=ns_server)then
        begin
           if(net_ttl<ClientTTL)then
           begin
              net_ttl+=1;
              if(net_ttl=ClientTTL)or(net_ttl=fr_fps1)then {$IFDEF _FULLGAME}menu_remake{$ELSE}screen_redraw{$ENDIF}:=true;
           end
           else
             if(not G_Started)then
             begin
                PlayerSetType(p,pt_none);
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
              if(n_builders<=0)then//{$IFDEF _FULLGAME}and(menu_s2<>ms2_camp){$ENDIF}
                isrevealed:=true;

              if(o_id>0)and(army>0)and(not isobserver)and(not isdefeated)and(player_type=pt_human)then
                PlayerExecuteOrder(p);

              if(player_type=pt_ai)
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

   //for p:=0 to MaxPlayers do PlayerAPMUpdate(p);
end;

{$include _net_game.pas}



procedure CodeGame;
var tx,ty:integer;
w,dx:word;
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
      {$IFDEF _FULLGAME}
      //if(ks_mright=1)then
      //  MakeZone(mouse_map_x div MapCellW,mouse_map_y div MapCellW);

     { if(ks_mleft=1)then
      begin
         debug_Sgx :=mouse_map_x div MapCellW;
         debug_Sgy :=mouse_map_y div MapCellW;


         if (0<=debug_Sgx)and(debug_Sgx<MaxMapSizeCelln)
         and(0<=debug_Sgy)and(debug_Sgy<MaxMapSizeCelln)
         then debug_d1:=map_grid[debug_Sgx,debug_Sgy].tgc_pf_domain
         else debug_d1:=0;
      end;
      if(ks_mright=1)then
      begin
         debug_Dgx :=mouse_map_x div MapCellW;
         debug_Dgy :=mouse_map_y div MapCellW;

         if (0<=debug_Dgx)and(debug_Dgx<MaxMapSizeCelln)
         and(0<=debug_Dgy)and(debug_Dgy<MaxMapSizeCelln)
         then debug_d2:=map_grid[debug_Dgx,debug_Dgy].tgc_pf_domain
         else debug_d2:=0;
      end;

      if(ks_mleft=1)or(ks_mright=1)then
      begin
         writeln('Sg ',debug_Sgx,' ',debug_Sgy,' ',map_LastCell,' d1 ',debug_d1);
         writeln('Dg ',debug_Dgx,' ',debug_Dgy,' ',map_LastCell,' d2 ',debug_d2);
         if(debug_d1>0)and(debug_d2>0)then
           with map_gridDomainMX[debug_d1-1,debug_d2-1] do
             writeln(nextDomain,' ',edgeCells_n);
      end;

      if(r_blink2_colorb)then
      begin
         debug_cell(debug_Sgx,debug_Sgy,5,c_lime);
         debug_cell(debug_Dgx,debug_Dgy,5,c_blue);

         if(debug_d1>0)and(debug_d2>0)then
         begin
            with map_gridDomainMX[debug_d1-1,debug_d2-1] do
              if(edgeCells_n>0)then
               for w:=0 to edgeCells_n-1 do
                with edgeCells_l[w] do
                 UnitsInfoAddRect(p_x-MapCellhw+5,p_y-MapCellhw+5,p_x+MapCellhw-5,p_y+MapCellhw-5,c_orange);
            {dx:=map_gridDomainMX[debug_d1-1,debug_d2-1].nextDomain;
            if(dx>0)then
             with map_gridDomainMX[debug_d1-1,dx-1] do
               if(edgeCells_n>0)then
                for w:=0 to edgeCells_n-1 do
                 with edgeCells_l[w] do
                  UnitsInfoAddRect(p_x-MapCellhw+5,p_y-MapCellhw+5,p_x+MapCellhw-5,p_y+MapCellhw-5,c_orange); }
         end;
      end;  }

         {if(map_gridDomain_n>0)then
           for w:=0 to map_gridDomain_n-1 do
             with domain_center_l[w-1] do debug_cell(p_x,p_y,9,map_gridDomain_color[w-1]); }

         {debug_Sx  :=mouse_map_x;
         debug_Sy  :=mouse_map_y;
         debug_Sgx :=debug_Sx div MapCellW;
         debug_Sgy :=debug_Sy div MapCellW; }

         //map_GridLineCollision(debug_Sgx,debug_Sgy,mouse_map_x div MapCellW,mouse_map_y div MapCellW,0,true);

         {if(LineCollision(debug_Sgx,debug_Sgy,0,0))
         then AddPoint(debug_Sgx,debug_Sgy,5,c_red )
         else AddPoint(debug_Sgx,debug_Sgy,5,c_lime);}

         {if(debug_array_n>0)then
          for tx:=0 to debug_array_n-1 do
           AddPoint(debug_array_x[tx],debug_array_y[tx],5,c_orange); }

     {

      debug_Dx  :=g_units[g_players[PlayerClient].uid_x[UID_Imp]].ua_x;
      debug_Dy  :=g_units[g_players[PlayerClient].uid_x[UID_Imp]].ua_y;
      debug_Dgx :=debug_Dx div MapCellW;
      debug_Dgy :=debug_Dy div MapCellW;

      pf_FindNextCell(
      g_units[g_players[PlayerClient].uid_x[UID_Imp]].zone,
       debug_Sgx ,debug_Sgy,
       debug_Sx  ,debug_Sy ,
       debug_Dx  ,debug_Dy ,
      @debug_Svx,@debug_Svy,
      @debug_Dvx,@debug_Dvy);

      tx:=debug_Sgx*MapCellW;
      ty:=debug_Sgy*MapCellW;
      UnitsInfoAddRect(tx,ty,tx+MapCellW,ty+MapCellW,c_lime);

      UnitsInfoAddline(
      debug_Sx,                   debug_Sy,
      debug_Sx+debug_Dvx*MapCellW,debug_Sy+debug_Dvy*MapCellW,c_red);

      tx:=debug_Dgx*MapCellW;
      ty:=debug_Dgy*MapCellW;
      UnitsInfoAddRect(tx,ty,tx+MapCellW,ty+MapCellW,c_blue);

      tx:=(debug_Sgx+debug_Svx)*MapCellW+5;
      ty:=(debug_Sgy+debug_Svy)*MapCellW+5;
      UnitsInfoAddRect(tx,ty,tx+MapCellW-10,ty+MapCellW-10,c_orange);  }

      {$ENDIF}

      g_cycle_order:=(g_cycle_order+1) mod order_period;
      g_cycle_regen:=(g_cycle_regen+1) mod regen_period;

      if(ServerSide)then
      begin
         G_Step+=1;

         UpdatePlayersStatusVars;

         {GameModeCPoints;
         case g_mode of
         gm_royale    : begin
                           if(g_cycle_order=0)then
                             if(g_royal_r>0)then g_royal_r-=1;
                           GameDefaultEndConditions;
                        end;
         gm_capture,
         gm_KotH      : GameDefaultDefeatConditions;
         else           GameDefaultEndConditions;
         end;}
      end;
      GameObjectsCode;
   end;

   if(net_status=ns_server)then net_Server;
end;


