
procedure PlayerSetSkirmishTech(PlayerTarget:byte);
begin
   with g_players[PlayerTarget] do
   begin
      {
      PlayerSetAllowedUnits(PlayerTarget,[UID_HKeep         ..UID_HBarracks,
                                          UID_LostSoul      ..UID_ZBFGMarine,
                                          UID_UCommandCenter..UID_UComputerStation,
                                          UID_Engineer      ..UID_Flyer  ],
                                          MaxUnits,true);

      PlayerSetAllowedUnits(PlayerTarget,[UID_HMonastery ,UID_HFortress       ,UID_HAltar,
                                          UID_UTechCenter,UID_UComputerStation,UID_URMStation ],1,false); }

      PlayerSetAllowedUnits(PlayerTarget,uids_all,MaxUnits              ,true );
      PlayerSetAllowedUnits(PlayerTarget,[UID_LostSoul, UID_Phantom ],20,false);


      if(map_generators>0)
      then PlayerSetAllowedUnits(PlayerTarget,[UID_HSymbol,UID_UGenerator],0,false);

      PlayerSetAllowedUpgrades(PlayerTarget,uids_all,255,true);
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
   pss_opened  : g_players[SlotSource].team:=PlayerSlotGetTeam(map_scenario,SlotSource,SlotSource);
   end;
   case g_slot_state[SlotTarget] of
   pss_observer: ;
   pss_opened  : g_players[SlotTarget].team:=PlayerSlotGetTeam(map_scenario,SlotTarget,SlotTarget);
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
   //or(PlayerRequestor>LastPlayer)
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
      if(PlayerRequestor<=LastPlayer)then
      begin
         if(PlayerRequestor=PlayerTarget)then exit;
         if(PlayerRequestor<>PlayerLobby)and(PlayerLobby<=LastPlayer)then exit;
         if(map_preset_cur>0)then
          with map_presets[map_preset_cur] do
           if(mapp_player_team[PlayerTarget]>LastPlayer)
           then exit
           else
             case NewState of
         pss_closed,
         pss_observer : exit;
             end;
      end;
   end;

   PlayerSlotChangeState:=true;

   if(Check)or(NewState=g_slot_state[PlayerTarget])then exit;

   with g_players[PlayerTarget] do
    case NewState of
pss_closed,
pss_opened   : begin
                  PlayerSetType(PlayerTarget,pt_none);
                  g_slot_state[PlayerTarget]:=NewState;
                  team:=PlayerSlotGetTeam(map_scenario,PlayerTarget,255);
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
                  ai_skill:=NewState-pss_AI_1+1;
                  PlayerSetType(PlayerTarget,pt_ai);
                  team:=PlayerSlotGetTeam(map_scenario,PlayerTarget,255);
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
   or(map_preset_cur   >0)
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
      if(PlayerSlotGetTeam(map_scenario,PlayerTarget,255)<>team)then
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
   {$IFDEF _FULLGAME}
   or(rpls_rstate=rpls_state_read)
   {$ENDIF}
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

   UpdatePlayerColors;

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

procedure InitDefaultMaps;
procedure SetMap(pid:byte;mseed:cardinal;msize:integer;mtype,msym,mscenario,t1,t2,t3,t4,t5,t6,t7,t8:byte);
begin
   if(map_preset_n<=pid)then
   begin
      if(map_preset_n=255)then exit;
      while(map_preset_n<=pid)do
      begin
         map_preset_n+=1;
         setlength(map_presets,map_preset_n);
      end;
   end;

   with map_presets[pid] do
   begin
      mapp_seed    := mseed;
      mapp_psize   := msize;
      mapp_type    := mtype;
      mapp_symmetry:= msym;
      mapp_scenario:= mscenario;
      FillChar(mapp_player_team,SizeOf(mapp_player_team),0);
      mapp_player_team[0]:=t1;
      mapp_player_team[1]:=t2;
      mapp_player_team[2]:=t3;
      mapp_player_team[3]:=t4;
      mapp_player_team[4]:=t5;
      mapp_player_team[5]:=t6;
      mapp_player_team[6]:=t7;
      mapp_player_team[7]:=t8;
   end;
end;
begin
   map_preset_cur:=0;
   map_preset_n  :=0;
   setlength(map_presets,map_preset_n);

   SetMap(mapp_1x1_plane   , 667,4000,mapt_steppe,1,ms_scirmish,0,1,255,255,255,255,255,255);
   SetMap(mapp_1x1_lake    ,6667,4000,mapt_clake ,1,ms_scirmish,0,1,255,255,255,255,255,255);
   SetMap(mapp_1x1_cave    , 667,4000,mapt_canyon,1,ms_scirmish,0,1,255,255,255,255,255,255);

   {$IFNDEF _FULLGAME}
   g_presets[gp_custom].gp_name:= 'custom';
   MakeGamePresetsNames(@str_gmodel[0],@str_m_typel[0]);
   {$ENDIF}
end;

function MapLoad(PlayerRequestor,preset:byte;Check:boolean):boolean;
var p:byte;
begin
   MapLoad:=false;

   if(G_Started)
   or((PlayerRequestor<=LastPlayer)and(PlayerLobby<>PlayerRequestor)and(PlayerLobby<=LastPlayer))
   or(preset>=map_preset_n)then exit;

   MapLoad:=true;

   if(Check)then exit;

   map_preset_cur:=preset;

   if(map_preset_cur>0)then
   with map_presets[map_preset_cur] do
   begin
      map_seed    := mapp_seed;
      map_psize   := mapp_psize;
      map_type    := mapp_type;
      map_symmetry:= mapp_symmetry;
      map_scenario:= mapp_scenario;
      g_fixed_positions
                  := false;

      for p:=0 to LastPlayer do
        if(mapp_player_team[p]<=LastPlayer)
        then PlayerSlotChangeState(255,p,pss_opened  ,false)
        else PlayerSlotChangeState(255,p,pss_observer,false);

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
nmid_loby_gameFixStarts   : if(map_preset_cur=0)then
                          begin
                             GameSetCommonSetting:=true;
                             if(Check)then exit;
                             g_fixed_positions:=NewVal>0;
                             map_Make1;
                          end;
nmid_loby_gameDeadPObs: begin
                             GameSetCommonSetting:=true;
                             if(Check)then exit;
                             g_deadobservers:=NewVal>0;
                          end;
nmid_loby_gameEmptySlots  : begin
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

   vid_cam_x:=-vid_panel_pw;
   vid_cam_y:=0;
   GameCameraBounds;

   vid_blink_timer1:=0;
   vid_blink_timer2:=0;

   ui_tab :=tt_buildings;
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

procedure GameCreateStartBase(x,y:integer;uid,level,playern:byte;count:integer);
var
n  : byte;
r,d,
ds : integer;
procedure Spawn(tx,ty:integer);
begin
   unit_add(tx,ty,0,uid,playern,true,false,level);
   n+=1;
end;
begin
   n:=0;
   if(count<=0)then exit;

   d  :=point_dir(x,y,map_phsize,map_phsize);
   ds :=360 div count;
   if(count=1)
   then r:=0
   else r:=g_uids[uid]._r;

   while(count>0) do
   begin
      Spawn(
      x+trunc(r*cos(d*degtorad)),
      y-trunc(r*sin(d*degtorad)));
      d+=ds;
      count-=1;
   end;
end;

procedure GameConfigureSkirmish;
var p:byte;
begin
   g_royal_r:=trunc(sqrt(sqr(map_phsize)*2));

   // Basic player settings
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

        team:=PlayerSlotGetTeam(map_scenario,p,255);
        race:=slot_race;

        if(race=r_random)then race:=1+random(r_cnt);

        if(player_type=pt_human)then ai_skill:=player_default_ai_level;//g_ai_slots
     end;

   if(not g_fixed_positions)then map_ShufflePlayerStarts(map_scenario in ms_ScenariosFixedTeams);

   for p:=0 to LastPlayer do
    with g_players[p] do
     if(player_type<>pt_none)and(not isobserver)then
     begin
        PlayerSetSkirmishTech(p);
        ai_PlayerSetSkirmishSettings(p);
        if (0<=map_PlayerStartX[p])and(map_PlayerStartX[p]<=map_psize)
        and(0<=map_PlayerStartY[p])and(map_PlayerStartY[p]<=map_psize)then
        begin
           GameCreateStartBase(map_PlayerStartX[p],
                               map_PlayerStartY[p],
                               uid_race_start_base[race],
                               3*byte(map_generators>0),p,1+integer(map_generators>0));
           unit_add(map_PlayerStartX[p],map_PlayerStartY[p],0,UID_Imp,p,true,false,0);
           //unit_add(map_PlayerStartX[p],map_PlayerStartY[p],0,UID_Imp,p,true,false,0);
           //unit_add(map_PlayerStartX[p],map_PlayerStartY[p],0,UID_Imp,p,true,false,0);
           //unit_add(map_PlayerStartX[p],map_PlayerStartY[p],0,UID_Imp,p,true,false,0);
        end;
     end;

   {$IFDEF _FULLGAME}
   GameCameraMoveToPoint(map_PlayerStartX[PlayerClient],map_PlayerStartY[PlayerClient]);
   if(g_players[PlayerClient].isobserver)then ui_tab:=tt_controls;
   UIPlayer:=PlayerClient;
   {$ENDIF}
end;


function GameStartScirmish(PlayerRequestor:byte;Check:boolean):boolean;
begin
   GameStartScirmish:=false;

   if(G_Started)
   or((PlayerRequestor<>PlayerLobby)and(PlayerLobby<=LastPlayer))then exit;

   if(PlayersGetReadyStatus)then
   begin
      GameStartScirmish :=true;
      if(Check)then exit;
      G_Started :=true;
      {$IFDEF _FULLGAME}
      menu_state:=false;
      menu_item :=0;
      G_Status  :=gs_running;
      vid_PanelUpdTimer:=0;
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
   MapLoad(255,map_preset_cur,false);
end;

{$IFDEF _FULLGAME}
procedure MakeRandomSkirmish(andstart:boolean);
var p:byte;
begin
   if(G_Started)then exit;

   Map_randommap;

   map_preset_cur:=0;
   map_scenario      :=ms_scirmish;
   map_generators:=random(gms_g_maxgens+1);

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

////////////////////////////////////////////////////////////////////////////////
//
//  CLEINT-SIDE SELECTIOn&GROUPING

function CheckSimpleClick(x0,y0,x1,y1:integer):boolean;
begin
   CheckSimpleClick:=max2i(abs(x0-x1),abs(y0-y1))<3;
end;

function ui_ActionsIsAllowed(playern:byte):boolean;
begin
   ui_ActionsIsAllowed:=false;
   with g_players[playern] do
     if(UIPlayer<>playern)
     or(isobserver)
     or(isdefeated)
     or(rpls_rstate=rpls_state_read)
     or(g_status<>gs_running)then exit;
   ui_ActionsIsAllowed:=true;
end;

procedure units_SelectRect(add:boolean;playern:byte;x0,y0,x1,y1:integer;fuid:byte);
var u,
usel_max:integer;
wasselect,
SelectBuildings:boolean;
begin
   if(not ui_ActionsIsAllowed(playern))then exit;

   if(x0>x1)then begin u:=x1;x1:=x0;x0:=u;end;
   if(y0>y1)then begin u:=y1;y1:=y0;y0:=u;end;

   if(CheckSimpleClick(x0,y0,x1,y1))
   then usel_max:=1
   else usel_max:=32000;

   SelectBuildings:=true;
   if(fuid=255)then
     for u:=1 to MaxUnits do
      with g_punits[u]^ do
       if(hits>0)and(playern=playeri)and(not IsIntUnitRange(transport,nil))then
        with uid^ do
         if(RectInRect(x0,y0,x1,y1,vx,vy,_r))and(not _ukbuilding)then
         begin
            SelectBuildings:=false;
            break;
         end;

   for u:=1 to MaxUnits do
     with g_punits[u]^ do
       if(hits>0)and(playern=playeri)and(not IsIntUnitRange(transport,nil))then
       begin
          wasselect:=isselected;

          isselected:=false;
          if(usel_max>0)then
            if(not add)or(not wasselect and add)then
              if(fuid=255)or(fuid=uidi)then
                with uid^ do
                  isselected:=(RectInRect(x0,y0,x1,y1,vx,vy,_r))and(SelectBuildings or not _ukbuilding);

          if(wasselect<>isselected)then
            if(isselected)
            then unit_PC_select_inc(g_punits[u])
            else unit_PC_select_dec(g_punits[u]);
          if(isselected)then
          begin
             UpdateLastSelectedUnit(unum);
             if(usel_max>0)then usel_max-=1;
          end;
       end;
end;
procedure units_SelectGroup(add:boolean;playern,fgroup:byte);
var u:integer;
wasselect:boolean;
begin
   if(not ui_ActionsIsAllowed(playern))then exit;

   for u:=1 to MaxUnits do
    with g_punits[u]^ do
     if(hits>0)and(playern=playeri)and(not IsIntUnitRange(transport,nil))then
     begin
        wasselect:=isselected;

        isselected:=false;
        if(not add)or(not wasselect and add)then
          case fgroup of
          0..
          MaxUnitGroups: isselected:=group=fgroup;
          254          : isselected:=UnitF1Select(g_punits[u]);
          255          : isselected:=UnitF2Select(g_punits[u]);
          end;

        if(wasselect<>isselected)then
          if(isselected)
          then unit_PC_select_inc(g_punits[u])
          else unit_PC_select_dec(g_punits[u]);

        if(isselected)then UpdateLastSelectedUnit(unum);
     end;
end;
procedure units_Grouping(add:boolean;playern,fgroup:byte);
var u:integer;
begin
   if(not ui_ActionsIsAllowed(playern))then exit;

   if(fgroup<=MaxUnitGroups)then
     for u:=1 to MaxUnits do
       with g_punits[u]^ do
         if(hits>0)and(playern=playeri)and(not IsIntUnitRange(transport,nil))then
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




procedure PlayerExecuteOrder(playern:byte);
var
su,eu,d     : integer;
ClearErrors : boolean;
pu,
order_u  : PTUnit;
order_d  : integer;
procedure SetOrderUnit;
begin
   with pu^ do
   with player^ do
     d:=point_dist_int(o_x0,o_y0,x,y);
   if(d<order_d)then
   begin
      order_d:=d;
      order_u:=pu;
   end;
end;
begin
   with g_players[playern] do
   begin
      case o_id of
po_build : if(0<o_a0)and(o_a0<255)then PlayerSetProdError(playern,lmt_argt_unit,byte(o_a0),StartBuild(o_x0,o_y0,byte(o_a0),playern),nil);
      else
        ClearErrors:=false;

        if(o_id=po_unit_order_set)then
          if(IsIntUnitRange(o_x1,@pu))then
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

        order_d:=order_d.MaxValue;
        order_u:=nil;

        while(su<>eu)do
        begin
           pu:=g_punits[su];
           with pu^  do
           with uid^ do
           if(hits>0)and(not IsIntUnitRange(transport,nil))and(playern=playeri)then
           begin
              if(isselected)then
                case o_id of
// unit orders
po_unit_order_set    : if(o_a0 in ua_toAll)
                       then unit_SetAction(pu,o_a0,o_x0,o_y0,o_x1)
                       else
                         if(ua_id<>o_a0)
                         then SetOrderUnit;

po_prod_stop         : begin
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
           end;

           if(su>eu)
           then su-=1
           else su+=1;
        end;

        if(o_id=po_unit_order_set)and(order_u<>nil)then unit_SetAction(order_u,o_a0,o_x0,o_y0,o_x1);

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

procedure MainGame;
var w:word;
x0,y0:integer;
pu:PTUnit;
begin
   {$IFDEF _FULLGAME}
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
      g_cycle_order:=(g_cycle_order+1) mod order_period;
      g_cycle_regen:=(g_cycle_regen+1) mod regen_period;

      {debug_AddDoaminCells;

      with g_players[PlayerClient] do
        if(IsIntUnitRange(uid_x[UID_Imp],@pu))then
          with pu^ do
          with uid^ do
            if(isselected)then
            begin
               {UIInfoItemAddCircle(movePFNext_x,movePFNext_y,5,c_orange );
               if(StepCollisionR(mouse_map_x,mouse_map_y,g_uids[UID_Imp]._r,zone,328,348))then
                 UIInfoItemAddCircle(mouse_map_x,mouse_map_y,5,c_lime );   }
            end;  }

      //x0:=8360;
      //y0:=6782;

      if(ServerSide)then
      begin
         G_Step+=1;

         UpdatePlayersStatusVars;

         {GameModeCPoints;
         case map_scenario of
         ms_royale    : begin
                           if(g_cycle_order=0)then
                             if(g_royal_r>0)then g_royal_r-=1;
                           GameDefaultEndConditions;
                        end;
         ms_capture,
         ms_KotH      : GameDefaultDefeatConditions;
         else           GameDefaultEndConditions;
         end;}
      end;
      UnitsCode;
      MissilesCode;
   end;

   if(net_status=ns_server)then net_Server;
end;

{$IFDEF _FULLGAME}
//if(kt_mright=1)then
//  MakeZone(mouse_map_x div MapCellW,mouse_map_y div MapCellW);

{ if(kt_mleft=1)then
begin
   debug_Sgx :=mouse_map_x div MapCellW;
   debug_Sgy :=mouse_map_y div MapCellW;


   if (0<=debug_Sgx)and(debug_Sgx<MaxMapSizeCelln)
   and(0<=debug_Sgy)and(debug_Sgy<MaxMapSizeCelln)
   then debug_d1:=map_grid[debug_Sgx,debug_Sgy].tgc_pf_domain
   else debug_d1:=0;
end;
if(kt_mright=1)then
begin
   debug_Dgx :=mouse_map_x div MapCellW;
   debug_Dgy :=mouse_map_y div MapCellW;

   if (0<=debug_Dgx)and(debug_Dgx<MaxMapSizeCelln)
   and(0<=debug_Dgy)and(debug_Dgy<MaxMapSizeCelln)
   then debug_d2:=map_grid[debug_Dgx,debug_Dgy].tgc_pf_domain
   else debug_d2:=0;
end;

if(kt_mleft=1)or(kt_mright=1)then
begin
   writeln('Sg ',debug_Sgx,' ',debug_Sgy,' ',map_csize,' d1 ',debug_d1);
   writeln('Dg ',debug_Dgx,' ',debug_Dgy,' ',map_csize,' d2 ',debug_d2);
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

UIInfoItemAddLine(
debug_Sx,                   debug_Sy,
debug_Sx+debug_Dvx*MapCellW,debug_Sy+debug_Dvy*MapCellW,c_red);

tx:=debug_Dgx*MapCellW;
ty:=debug_Dgy*MapCellW;
UnitsInfoAddRect(tx,ty,tx+MapCellW,ty+MapCellW,c_blue);

tx:=(debug_Sgx+debug_Svx)*MapCellW+5;
ty:=(debug_Sgy+debug_Svy)*MapCellW+5;
UnitsInfoAddRect(tx,ty,tx+MapCellW-10,ty+MapCellW-10,c_orange);  }

{$ENDIF}



