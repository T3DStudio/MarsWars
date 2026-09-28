
const
ded_ConsoleBaseLine = '                                                                                          ';

procedure dedicated_Lang;
begin
   str_gstat_Lobby                := 'Lobby';
   str_gstat_Started              := 'Started';
   str_gstat_WaitForPlayers       := 'Waiting for players';
   str_gstat_WonTeam              := 'Won by a team #';
   str_gstat_GamePaused           := 'Paused by ';
   str_gstat_Status               := 'Game status: ';

   str_gmsg_RecordStart           := '(DedServer)Start recording: ';
   str_gmsg_RecordError           := '(DedServer)Recording error: ';
   str_gmsg_RecordStop            := '(DedServer)Stop recording: ';

   str_SR_RecordGames             := 'Record games';

   str_net_UDPPort                := ' UPD port: ';
   str_Caption_GOptions           := 'Game options:';
   str_Caption_Map                := 'Map options:';

   str_map_GeneratorsL[mapg_5  ]  := '5 min';
   str_map_GeneratorsL[mapg_10 ]  := '10 min';
   str_map_GeneratorsL[mapg_15 ]  := '15 min';
   str_map_GeneratorsL[mapg_20 ]  := '20 min';
   str_map_GeneratorsL[mapg_inf]  := 'infinity';

   str_map_ScenarioL[mc_ffa3     ]:= 'FFA(3)';
   str_map_ScenarioL[mc_ffa4     ]:= 'FFA(4)';
   str_map_ScenarioL[mc_ffa5     ]:= 'FFA(5)';
   str_map_ScenarioL[mc_ffa6     ]:= 'FFA(6)';
   str_map_ScenarioL[mc_ffa7     ]:= 'FFA(7)';
   str_map_ScenarioL[mc_ffa8     ]:= 'FFA(8)';
   str_map_ScenarioL[mc_1x1      ]:= '1x1';
   str_map_ScenarioL[mc_2x2      ]:= '2x2';
   str_map_ScenarioL[mc_3x3      ]:= '3x3';
   str_map_ScenarioL[mc_4x4      ]:= '4x4';
   str_map_ScenarioL[mc_2x2x2    ]:= '2x2x2';
   str_map_ScenarioL[mc_2x2x2x2  ]:= '2x2x2x2';
   str_map_ScenarioL[mc_KeyPoints]:= 'Key Points';
   str_map_ScenarioL[mc_KotH     ]:= 'KotH';
   str_map_ScenarioL[mc_royale   ]:= 'Royal Battle';

   str_map_SymmetryL[maps_none ]  := 'no';
   str_map_SymmetryL[maps_point]  := 'point';
   str_map_SymmetryL[maps_lineV]  := 'line |';
   str_map_SymmetryL[maps_lineH]  := 'line -';
   str_map_SymmetryL[maps_lineL]  := 'line \';
   str_map_SymmetryL[maps_lineR]  := 'line /';

   str_map_TemplateL[mapt_lake]   := 'lake';
   str_map_TemplateL[mapt_island] := 'island';
   str_map_TemplateL[mapt_temple] := 'temple';
   str_map_TemplateL[mapt_cave]   := 'cave';
   str_map_TemplateL[mapt_steppe] := 'steppe';
   str_map_TemplateL[mapt_canyon] := 'canyon';


   str_map_Scenario               := 'Scenario';
   str_map_Generators             := 'Generators';
   str_map_Seed                   := 'Seed';
   str_map_Size                   := 'Size';
   str_map_Template               := 'Template';
   str_map_Symmetry               := 'Symmetry';
   str_GO_AISlots                 := 'Fill empty slots';
   str_GO_FixedStarts             := 'Fixed player starts';
   str_GO_NewObservers            := 'New observers after game start';

   str_Player                     := 'Player';
   str_State                      := 'State';
   str_team                       := 'Team';
   str_srace                      := 'Race';
   str_ping                       := 'Ping';

   str_ps_AI                      := 'AI';
   str_ps_Hum                     := 'Hum.';

   str_race[r_random]             := 'RANDOM';
   str_race[r_hell  ]             := 'HELL';
   str_race[r_uac   ]             := 'UAC';
   str_observer                   := 'OBSERVER';

   rpls_NamePrefix                := 'MWDedReplay';
end;

procedure dedicated_StartParams;
const  dedp_netport = '-netport';
       dedp_lanadv  = '-lanadv';
       dedp_record  = '-record';
var i,t:longint;
nparam,
cparam:shortstring;
begin
   cparam:='';
   t:=ParamCount;
   if(t>0)then
     for i:=1 to t do
     begin
        nparam:=ParamStr(i);
        case nparam of
        dedp_record,
        dedp_netport,
        dedp_lanadv : cparam:=nparam;
        else
           case cparam of
           dedp_netport: begin
                            net_ServerPort:=s2w(nparam);
                            if(net_ServerPort=0)then
                              net_ServerPort:=net_DefaultPort;
                         end;
           dedp_lanadv : net_svLanAdv:=s2i(nparam)<>0;
           dedp_record : rpls_Record :=s2i(nparam)<>0;
           else cparam:='';
           end;
        end;
     end;
end;

procedure dedicated_Init;
begin
   if(net_UpSocket(net_ServerPort))then
   begin
      replay_MakeReplayHeaderData;
      net_status:=ns_server;
      Players_SetDefaults;
      //game_MakeRandomSkirmish;
   end
   else game_Cycle :=false;

   menu_update:=true;
end;

procedure dedicated_Code;
var GameEnded:boolean;
begin
   case G_Started of
   false: if(g_LobbyTimer<=0)then
            if(players_AllReady)and(players_NonObserversCount>1)then
              g_LobbyTimer:=g_GameStartTime;
   true : begin
             GameEnded:=Game_IsEnded;
             if(GameEnded)then
               if(g_LobbyTimer<=0)
               then g_LobbyTimer:=ded_GameEndTime
               else
               begin
                  g_LobbyTimer-=1;
                  if(g_LobbyTimer>0)then
                  begin
                     if((g_LobbyTimer mod fr_fps5)=0)then
                       GameLog_EndsIn(g_LobbyTimer div fr_fps1);
                  end;
               end;

             if(NoHumanPlayers)
             or(GameEnded and(g_LobbyTimer=0))then
               Game_Break(false);
          end;
   end;
end;

procedure dedicated_Clear;
var x,y:byte;
begin
   x:=WhereX;
   y:=Wherey;
   GotoXY(1,y);
   write(ded_ConsoleBaseLine);
   GotoXY(x,y);
end;

procedure dedicated_Line1(s1:shortstring);
begin
   dedicated_Clear;
   writeln(s1);
end;

procedure dedicated_Line5(s1:shortstring;x1:byte;
                          s2:shortstring;x2:byte;
                          s3:shortstring;x3:byte;
                          s4:shortstring;x4:byte;
                          s5:shortstring;x5:byte;
                          s6:shortstring;x6:byte);
var s: shortstring;
procedure ss(sp:pshortstring;x:byte);
var i,t:byte;
begin
   i:=x+length(sp^);
   t:=length(s);
   if(i>t)then i:=t;
   t:=1;
   while(x<i)do
   begin
      s[x]:=sp^[t];
      x+=1;
      t+=1;
   end;
end;
begin
   s:=ded_ConsoleBaseLine;
   if(x1>0)then ss(@s1,x1);
   if(x2>0)then ss(@s2,x2);
   if(x3>0)then ss(@s3,x3);
   if(x4>0)then ss(@s4,x4);
   if(x5>0)then ss(@s5,x5);
   if(x6>0)then ss(@s6,x6);
   writeln(s);
end;

procedure PlayerDataLine(p:byte);
function PlayerGetPINGStr:shortstring;
begin
   PlayerGetPINGStr:='';
   with g_PlayersGame[p] do
   with g_PlayersTemp[p] do
     if(state=ps_human)then PlayerGetPINGStr:=w2s(net_ping);
end;

begin
   with g_PlayersGame[p] do
     if(state=ps_none)
     then   dedicated_Line5(b2s(p+1),1,player_GetStateString(p),3,name,11,'',29,'',39,'',49)
     else
       if(isobserver)
       then dedicated_Line5(b2s(p+1),1,player_GetStateString(p),3,name,11,str_observer   ,29, ''         ,39, PlayerGetPINGStr,49)
       else dedicated_Line5(b2s(p+1),1,player_GetStateString(p),3,name,11,str_race[mrace],29, b2s(team+1),39, PlayerGetPINGStr,49);
end;

function Dedicated_GameStatusStr:shortstring;
begin
   if(not g_started)
   then Dedicated_GameStatusStr:=str_gstat_Lobby
   else
     case G_status of
     gs_running    : Dedicated_GameStatusStr:=str_gstat_Started;
     gs_paused0..
     gs_paused7    : Dedicated_GameStatusStr:=str_gstat_GamePaused+g_PlayersGame[G_status-gs_paused0].name;
     gs_waitplayers: Dedicated_GameStatusStr:=str_gstat_WaitForPlayers;
     gs_win_team0..
     gs_win_team7  : Dedicated_GameStatusStr:=str_gstat_WonTeam+b2s(G_Status-gs_win_team0+1);
     else            Dedicated_GameStatusStr:='UNKNOWN STATUS';
     end;
end;

procedure Dedicated_Screen;
const ded_ScreenUpdatePause = fr_fps4;
function g_AISlotsStr:shortstring;
begin
   if(g_AISlots>0)
   then g_AISlotsStr:=ai_name(g_AISlots,255)
   else g_AISlotsStr:='NO';
end;

begin
   if(menu_update)and(console_y>ded_ScreenUpdatePause)then
   begin
      //clrscr;
      GotoXY(1,1);

      console_y:=0;
      menu_update:=false;
   end;

   if(console_y<=ded_ScreenUpdatePause)then
   begin
      case console_y of
      0 : writeln(str_wcaption,' ',str_copyright,str_net_UDPPort,net_ServerPort);
      2 : dedicated_Line1(str_gstat_Status+Dedicated_GameStatusStr);
      4 : writeln(str_Caption_GOptions);
      6 : dedicated_Line5(str_GO_FixedStarts   ,1, str_GO_AISlots,22, str_GO_NewObservers,40, str_SR_RecordGames,72,'',55,'',70);
      8 : dedicated_Line5(b2c[g_FixedPositions],1, g_AISlotsStr  ,22, b2c[g_NewObservers],40, b2c[rpls_Record]  ,72,'',55,'',70);
      10: writeln;
      12: writeln(str_Caption_Map);
      14: dedicated_Line5(str_map_Scenario               ,1, str_map_Generators                 ,15, str_map_Seed ,30, str_map_Size  ,45, str_map_Template               ,55, str_map_Symmetry               ,70);
      16: dedicated_Line5(str_map_ScenarioL[map_scenario],1, str_map_GeneratorsL[map_generatorT],15, c2s(map_seed),30, i2s(map_Size1),45, str_map_TemplateL[map_Template],55, str_map_SymmetryL[map_symmetry],70);
      18: writeln;
      20: dedicated_Line5('#',1,str_State                ,3, str_Player,11,str_srace,29,str_team ,39, str_ping,49);   // captions
      22: PlayerDataLine(0);
      24: PlayerDataLine(1);
      26: PlayerDataLine(2);
      28: PlayerDataLine(3);
      30: PlayerDataLine(4);
      32: PlayerDataLine(5);
      34: PlayerDataLine(6);
      36: PlayerDataLine(7);
      end;

      console_y+=1;
   end;
end;
