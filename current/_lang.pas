
////////////////////////////////////////////////////////////////////////////////
//
//  MAIN
//


function UIDsArmsImpactUpgr(upgr:byte):TSoB;
var uid,arm:byte;
begin
   UIDsArmsImpactUpgr:=[];
   for uid in [1..255] do
     with g_uids[uid] do
       if(uid_r>0)then
         for arm:=0 to LastUnitArms do
           with uid_arms[arm] do
             if(aw_impact_upgr=upgr)then UIDsArmsImpactUpgr+=[uid];
end;

procedure DocHelp_AddHotKeys(line:shortstring);
begin
   str_AddToUIStringList(@str_doc_HotKeys,ui_DocLineLen2,false,false,line);
end;
function DocHelp_GetHotKeys(iActSet:TSoB):shortstring;
var i:byte;
begin
   DocHelp_GetHotKeys:='';
   for i in iActSet do
     STRADD(@DocHelp_GetHotKeys,str_ActionHotKey(i),sep_space);
   if(length(DocHelp_GetHotKeys)>0)then
     DocHelp_GetHotKeys:=tc_docbr+DocHelp_GetHotKeys+': ';
end;

procedure DocHelp_AddBaseControls(line:shortstring);
begin
   str_AddToUIStringList(@str_doc_BaseControls,ui_DocLineLen2,false,false,line);
end;
procedure DocHelp_AddBaseMechanics(line:shortstring);
begin
   str_AddToUIStringList(@str_doc_BaseMechanics,ui_DocLineLen2,false,false,line);
end;
procedure DocHelp_AddGamUI(line:shortstring);
begin
   str_AddToUIStringList(@str_doc_GameUI,ui_DocLineLen2,false,false,line);
end;
procedure DocHelp_AddOther(line:shortstring);
begin
   str_AddToUIStringList(@str_doc_Other,ui_DocLineLen2,false,false,line);
end;
procedure DocHelp_AddCredits(line:shortstring);
begin
   if(line<>tc_docbr)then line+=tc_docbr;
   str_AddToUIStringList(@str_doc_Credits,ui_DocLineLen2,false,false,line);
end;
procedure DocHelp_AddCreditsMusic;
var Info: TSearchRec;
begin
   if(FindFirst(folder_sound+folder_music_menu+'*.ogg',faReadonly,info)=0)then
     repeat
       setlength(info.Name,length(info.Name)-4);
       DocHelp_AddCredits('- '+info.Name);
     until(FindNext(info)<>0);
   FindClose(info);
   if(FindFirst(folder_sound+folder_music_game+'*.ogg',faReadonly,info)=0)then
     repeat
       setlength(info.Name,length(info.Name)-4);
       DocHelp_AddCredits('- '+info.Name);
     until(FindNext(info)<>0);
   FindClose(info);
end;

procedure str_camp_Add(name:shortstring);
begin
   camp_size+=1;
   setlength(camp_list      ,camp_size);
   setlength(camp_mis_list  ,camp_size);
   setlength(camp_mis_size  ,camp_size);
   setlength(camp_obj_main  ,camp_size);
   setlength(camp_obj_object,camp_size);
   setlength(camp_obj_loc   ,camp_size);
   setlength(camp_obj_size  ,camp_size);

   camp_mis_size[camp_size-1]:=0;
   setlength(camp_mis_list[camp_size-1],0);
   camp_list[camp_size-1]:=name;
   setlength(camp_obj_main  [camp_size-1],0);
   setlength(camp_obj_object[camp_size-1],0);
   setlength(camp_obj_loc   [camp_size-1],0);
   setlength(camp_obj_size  [camp_size-1],0);
end;

procedure str_camp_MisAdd(camp_n:integer;name:shortstring);
begin
   if(camp_n<0)
   or(camp_size<=camp_n)then exit;

   camp_mis_size[camp_n]+=1;
   setlength(camp_mis_list  [camp_n],camp_mis_size[camp_n]);
   setlength(camp_obj_main  [camp_n],camp_mis_size[camp_n]);
   setlength(camp_obj_object[camp_n],camp_mis_size[camp_n]);
   setlength(camp_obj_loc   [camp_n],camp_mis_size[camp_n]);
   setlength(camp_obj_size  [camp_n],camp_mis_size[camp_n]);
   camp_obj_object[camp_n][camp_mis_size[camp_n]-1]:='';
   camp_obj_loc   [camp_n][camp_mis_size[camp_n]-1]:='';
   camp_mis_list[camp_n][camp_mis_size[camp_n]-1]:=name;

   setlength(camp_obj_main[camp_n][camp_mis_size[camp_n]-1],0);
             camp_obj_size[camp_n][camp_mis_size[camp_n]-1]:=0;
end;

procedure str_camp_MissTextAdd(camp_n,miss_n:integer;line:shortstring);
begin
   if(camp_n<0)
   or(camp_size<=camp_n)then exit;

   if(miss_n<0)
   or(camp_mis_size[camp_n]<=miss_n)then exit;

   str_AddToStringArray(@camp_obj_main[camp_n][miss_n],@camp_obj_size[camp_n][miss_n],nil,menu_infoLineSize,false,false,line);
end;

procedure str_camp_clear;
begin
   while(camp_size>0)do
   begin
      camp_size-=1;

      while(camp_mis_size[camp_size]>0)do
      begin
         camp_mis_size[camp_size]-=1;
         setlength(camp_obj_main[camp_size][camp_mis_size[camp_size]],0);
      end;

      setlength(camp_mis_list  [camp_size],0);
      setlength(camp_obj_main  [camp_size],0);
      setlength(camp_obj_object[camp_size],0);
      setlength(camp_obj_loc   [camp_size],0);
   end;
   setlength(camp_list      ,camp_size);
   setlength(camp_mis_list  ,camp_size);
   setlength(camp_mis_size  ,camp_size);
   setlength(camp_obj_main  ,camp_size);
   setlength(camp_obj_size  ,camp_size);
   setlength(camp_obj_object,camp_size);
   setlength(camp_obj_loc   ,camp_size);
end;

procedure str_camps_clearPlot;
var c,m:integer;
begin
   if(camp_size>0)then
     for c:=0 to camp_size-1 do
       if(camp_mis_size[c]>0)then
         for m:=0 to camp_mis_size[c]-1 do
         begin
            setlength(camp_obj_main[c,m],0);
            camp_obj_size[c,m]:=0;
         end;
end;

////////////////////////////////////////////////////////////////////////////////

var
str_tmp1,
str_tmp2,
str_tmp3:shortstring;

procedure lang_Init;
var
Info: TSearchRec;
i   : byte;
begin
   lang_Count:=0;
   setlength(lang_List,lang_Count);

   if(FindFirst(folder_language+'*',faReadonly,info)=0)then
     repeat
        if(length(info.Name)>0)then
        begin
           lang_Count+=1;
           setlength(lang_List,lang_Count);
           lang_List[lang_Count-1]:=info.Name;
           if(lang_Count=255)then break;
        end;
     until(FindNext(info)<>0);
   FindClose(info);

   // constants
   str_ReplayQualityL[0]         := tc_aqua  +'x1 '+tc_default+'/'+tc_red   +' x1';
   str_ReplayQualityL[1]         := tc_aqua  +'x2 '+tc_default+'/'+tc_red   +' x2';
   str_ReplayQualityL[2]         := tc_lime  +'x3 '+tc_default+'/'+tc_orange+' x3';
   str_ReplayQualityL[3]         := tc_lime  +'x4 '+tc_default+'/'+tc_orange+' x4';
   str_ReplayQualityL[4]         := tc_yellow+'x5 '+tc_default+'/'+tc_yellow+' x5';
   str_ReplayQualityL[5]         := tc_yellow+'x6 '+tc_default+'/'+tc_yellow+' x6';
   str_ReplayQualityL[6]         := tc_orange+'x7 '+tc_default+'/'+tc_lime  +' x7';
   str_ReplayQualityL[7]         := tc_orange+'x8 '+tc_default+'/'+tc_lime  +' x8';
   str_ReplayQualityL[8]         := tc_red   +'x9 '+tc_default+'/'+tc_aqua  +' x9';
   str_ReplayQualityL[9]         := tc_red   +'x10'+tc_default+'/'+tc_aqua  +' x10';

   str_NetQualityL[0]            := tc_red   +'x1';
   str_NetQualityL[1]            := tc_red   +'x2';
   str_NetQualityL[2]            := tc_orange+'x3';
   str_NetQualityL[3]            := tc_orange+'x4';
   str_NetQualityL[4]            := tc_yellow+'x5';
   str_NetQualityL[5]            := tc_yellow+'x6';
   str_NetQualityL[6]            := tc_lime  +'x7';
   str_NetQualityL[7]            := tc_lime  +'x8';
   str_NetQualityL[8]            := tc_aqua  +'x9';
   str_NetQualityL[9]            := tc_aqua  +'x10';


   FillChar(str_menu_hint,sizeOf(str_menu_hint),0);
   FillChar(menu_hint_pos,sizeOf(menu_hint_pos),0);

   for i in [1..255] do menu_hint_pos[i]:=i;

   menu_hint_pos[mi_SaveLoad_fname]:=mi_SaveLoad_list;

   for i in [mi_Players_Panel  ..mi_Players_Obs7       ]-
            [mi_Players_Ready]                           do menu_hint_pos[i]:=mi_Players_Panel;
   for i in [mi_Map_Panel      ..mi_Map_Random         ] do menu_hint_pos[i]:=mi_Map_Panel;
   for i in [mi_Game_Panel     ..mi_Game_Random        ] do menu_hint_pos[i]:=mi_Game_Panel;
   for i in [mi_MP_Panel       ..mi_MP_ChatLine        ]-
            [mi_MP_Disconnect]                           do menu_hint_pos[i]:=mi_MP_Panel;

   for i in [mi_SG_PlayerName  ..mi_SG_ShowPlayerScrns ] do menu_hint_pos[i]:=mi_SG_PlayerName;
   for i in [mi_SR_RecordGames ..mi_SR_RecordQuality   ] do menu_hint_pos[i]:=mi_SR_RecordGames;
   for i in [mi_SV_ResolutionW ..mi_SV_MenuScaling     ] do menu_hint_pos[i]:=mi_SV_ResolutionW;
   for i in [mi_SS_SoundVolume ..mi_SS_RenewPlaylist   ] do menu_hint_pos[i]:=mi_SS_SoundVolume;
   for i in [mi_help_Credits   ..mi_help_Other         ] do menu_hint_pos[i]:=mi_help_Credits;

   // PLAYERS
   for i in [mi_Players_AIskil0..mi_Players_AIskil7    ] do menu_hint_pos[i]:=mi_Players_Panel;
   for i in [mi_Players_Slot0  ..mi_Players_Slot7      ] do menu_hint_pos[i]:=mi_Players_Panel;
   for i in [mi_Players_State0 ..mi_Players_State7     ] do menu_hint_pos[i]:=mi_Players_Panel;

   // MAP
   menu_hint_pos[mi_Map_Generators]:=mi_Map_Panel;
   menu_hint_pos[mi_Map_Seed      ]:=mi_Map_Panel;
end;

procedure lang_InitActionHotkeys;
var t:byte;
begin
   for t:=0 to 255 do input_actions[t].ik_str_HK:=str_ActionHotKey(t);
end;

function lang_FindN(name:shortstring):byte;
var i:byte;
begin
   lang_FindN:=0;
   if(lang_Count>0)then
     for i:=0 to lang_Count-1 do
       if(lang_List[i]=name)then
       begin
          lang_FindN:=i;
          break;
       end;
end;

function lang_Key2StrVar(key:shortstring):pshortstring;
var u:byte;
begin
   lang_Key2StrVar:=nil;

   case key of
   'str_tmp1'                           : lang_Key2StrVar:= @str_tmp1;
   'str_tmp2'                           : lang_Key2StrVar:= @str_tmp2;
   'str_tmp3'                           : lang_Key2StrVar:= @str_tmp3;

   'str_ps_AI'                          : lang_Key2StrVar:= @str_ps_AI;
   'str_ps_Host'                        : lang_Key2StrVar:= @str_ps_Host;
   'str_ps_Hum'                         : lang_Key2StrVar:= @str_ps_Hum;

   'str_Caption_Map'                    : lang_Key2StrVar:= @str_Caption_Map;
   'str_Caption_Players'                : lang_Key2StrVar:= @str_Caption_Players;
   'str_Caption_Multiplayer'            : lang_Key2StrVar:= @str_Caption_Multiplayer;
   'str_Caption_GOptions'               : lang_Key2StrVar:= @str_Caption_GOptions;
   'str_Caption_Server'                 : lang_Key2StrVar:= @str_Caption_Server;
   'str_Caption_Client'                 : lang_Key2StrVar:= @str_Caption_Client;
   'str_Caption_Objectives'             : lang_Key2StrVar:= @str_Caption_Objectives;
   'str_Caption_NetSvList'              : lang_Key2StrVar:= @str_Caption_NetSvList;

   'str_menu_Campaings'                 : lang_Key2StrVar:= @str_menu_Campaings;
   'str_menu_Scirmish'                  : lang_Key2StrVar:= @str_menu_Scirmish;
   'str_menu_Playback'                  : lang_Key2StrVar:= @str_menu_Playback;
   'str_menu_SaveLoad'                  : lang_Key2StrVar:= @str_menu_SaveLoad;
   'str_menu_LoadGame'                  : lang_Key2StrVar:= @str_menu_LoadGame;
   'str_menu_Replays'                   : lang_Key2StrVar:= @str_menu_Replays;
   'str_menu_Settings'                  : lang_Key2StrVar:= @str_menu_Settings;
   'str_menu_Help'                      : lang_Key2StrVar:= @str_menu_Help;

   'str_menu_Start'                     : lang_Key2StrVar:= @str_menu_Start;
   'str_menu_Cancel'                    : lang_Key2StrVar:= @str_menu_Cancel;
   'str_menu_Surrender'                 : lang_Key2StrVar:= @str_menu_Surrender;
   'str_menu_MissionAbort'              : lang_Key2StrVar:= @str_menu_MissionAbort;
   'str_menu_MissionEnd'                : lang_Key2StrVar:= @str_menu_MissionEnd;
   'str_menu_PlaybackStop'              : lang_Key2StrVar:= @str_menu_PlaybackStop;
   'str_menu_Exit'                      : lang_Key2StrVar:= @str_menu_Exit;
   'str_menu_Back'                      : lang_Key2StrVar:= @str_menu_Back;

   'str_menu_Chat'                      : lang_Key2StrVar:= @str_menu_Chat;
   'str_menu_Pause'                     : lang_Key2StrVar:= @str_menu_Pause;
   'str_menu_InGameTime'                : lang_Key2StrVar:= @str_menu_InGameTime;

   'str_or'                             : lang_Key2StrVar:= @str_or;
   'str_and'                            : lang_Key2StrVar:= @str_and;
   'str_YesNoG[true]'                   : lang_Key2StrVar:= @str_YesNoG[true ];
   'str_YesNoG[false]'                  : lang_Key2StrVar:= @str_YesNoG[false];

   'str_lobby_PlayerReady[false]'       : lang_Key2StrVar:= @str_lobby_PlayerReady[false];
   'str_lobby_PlayerReady[true]'        : lang_Key2StrVar:= @str_lobby_PlayerReady[true ];
   'str_lobby_ReadyToStart'             : lang_Key2StrVar:= @str_lobby_ReadyToStart;
   'str_lobby_BreakStarting'            : lang_Key2StrVar:= @str_lobby_BreakStarting;
   'str_lobby_GameStartIn'              : lang_Key2StrVar:= @str_lobby_GameStartIn;
   'str_lobby_GameResetIn'              : lang_Key2StrVar:= @str_lobby_GameResetIn;

   'str_menuMsg_HintImg'                : lang_Key2StrVar:= @str_menuMsg_HintImg;
   'str_menuMsg_HintDefault'            : lang_Key2StrVar:= @str_menuMsg_HintDefault;
   'str_menuMsg_HintClient'             : lang_Key2StrVar:= @str_menuMsg_HintClient;

   'str_S_Game'                         : lang_Key2StrVar:= @str_S_Game;
   'str_S_Replay'                       : lang_Key2StrVar:= @str_S_Replay;
   'str_S_Video'                        : lang_Key2StrVar:= @str_S_Video;
   'str_S_Sound'                        : lang_Key2StrVar:= @str_S_Sound;

   'str_SR_RecordGames'                 : lang_Key2StrVar:= @str_SR_RecordGames;
   'str_SR_Quality'                     : lang_Key2StrVar:= @str_SR_Quality;
   'str_SR_ReplayPrefix'                : lang_Key2StrVar:= @str_SR_ReplayPrefix;

   'str_SG_ShowAPM'                     : lang_Key2StrVar:= @str_SG_ShowAPM;
   'str_SG_ColoredShadow'               : lang_Key2StrVar:= @str_SG_ColoredShadow;
   'str_SG_ScrollSpeed'                 : lang_Key2StrVar:= @str_SG_ScrollSpeed;
   'str_SG_MouseScroll'                 : lang_Key2StrVar:= @str_SG_MouseScroll;
   'str_SG_PlayerName'                  : lang_Key2StrVar:= @str_SG_PlayerName;
   'str_SG_Language'                    : lang_Key2StrVar:= @str_SG_Language;
   'str_SG_RightClickAct'               : lang_Key2StrVar:= @str_SG_RightClickAct;
   'str_SG_RightClickActL[true]'        : lang_Key2StrVar:= @str_SG_RightClickActL[true ];
   'str_SG_RightClickActL[false]'       : lang_Key2StrVar:= @str_SG_RightClickActL[false];
   'str_SG_ControlPanelPos'             : lang_Key2StrVar:= @str_SG_ControlPanelPos;
   'str_SG_ControlPanelPosL[cpp_left]'  : lang_Key2StrVar:= @str_SG_ControlPanelPosL[cpp_left];
   'str_SG_ControlPanelPosL[cpp_right]' : lang_Key2StrVar:= @str_SG_ControlPanelPosL[cpp_right];
   'str_SG_ControlPanelPosL[cpp_top]'   : lang_Key2StrVar:= @str_SG_ControlPanelPosL[cpp_top];
   'str_SG_ControlPanelPosL[cpp_bottom]': lang_Key2StrVar:= @str_SG_ControlPanelPosL[cpp_bottom];
   'str_SG_ControlPanelAuto'            : lang_Key2StrVar:= @str_SG_ControlPanelAuto;
   'str_SG_ShowPlayerScrns'             : lang_Key2StrVar:= @str_SG_ShowPlayerScrns;
   'str_SG_HealthBars'                  : lang_Key2StrVar:= @str_SG_HealthBars;
   'str_SG_HealthBarsL[0]'              : lang_Key2StrVar:= @str_SG_HealthBarsL[0];
   'str_SG_HealthBarsL[1]'              : lang_Key2StrVar:= @str_SG_HealthBarsL[1];
   'str_SG_HealthBarsL[2]'              : lang_Key2StrVar:= @str_SG_HealthBarsL[2];
   'str_SG_PlayersColor'                : lang_Key2StrVar:= @str_SG_PlayersColor;
   'str_SG_PlayersColorL[0]'            : lang_Key2StrVar:= @str_SG_PlayersColorL[0];
   'str_SG_PlayersColorL[1]'            : lang_Key2StrVar:= @str_SG_PlayersColorL[1];
   'str_SG_PlayersColorL[2]'            : lang_Key2StrVar:= @str_SG_PlayersColorL[2];
   'str_SG_PlayersColorL[3]'            : lang_Key2StrVar:= @str_SG_PlayersColorL[3];
   'str_SG_PlayersColorL[4]'            : lang_Key2StrVar:= @str_SG_PlayersColorL[4];
   'str_SG_PlayersColorL[5]'            : lang_Key2StrVar:= @str_SG_PlayersColorL[5];

   'str_SV_ResolutionW'                 : lang_Key2StrVar:= @str_SV_ResolutionW;
   'str_SV_ResolutionH'                 : lang_Key2StrVar:= @str_SV_ResolutionH;
   'str_SV_ResolutionApply'             : lang_Key2StrVar:= @str_SV_ResolutionApply;
   'str_SV_Windowed'                    : lang_Key2StrVar:= @str_SV_Windowed;
   'str_SV_MenuScale'                   : lang_Key2StrVar:= @str_SV_MenuScale;
   'str_SV_ShowFPS'                     : lang_Key2StrVar:= @str_SV_ShowFPS;

   'str_SS_MusicVolume'                 : lang_Key2StrVar:= @str_SS_MusicVolume;
   'str_SS_SoundVolume'                 : lang_Key2StrVar:= @str_SS_SoundVolume;
   'str_SS_NextTrack'                   : lang_Key2StrVar:= @str_SS_NextTrack;
   'str_SS_ReloadMusic'                 : lang_Key2StrVar:= @str_SS_ReloadMusic;
   'str_SS_RenewMusicList'              : lang_Key2StrVar:= @str_SS_RenewMusicList;
   'str_SS_MusicListSize'               : lang_Key2StrVar:= @str_SS_MusicListSize;
   'str_SS_Playlist'                    : lang_Key2StrVar:= @str_SS_Playlist;

   'str_GO_AISlots'                     : lang_Key2StrVar:= @str_GO_AISlots;
   'str_GO_FixedStarts'                 : lang_Key2StrVar:= @str_GO_FixedStarts;
   'str_GO_NewObservers'                : lang_Key2StrVar:= @str_GO_NewObservers;
   'str_GO_Random'                      : lang_Key2StrVar:= @str_GO_Random;

   'str_map'                            : lang_Key2StrVar:= @str_map;
   'str_map_Seed'                       : lang_Key2StrVar:= @str_map_Seed;
   'str_map_Size'                       : lang_Key2StrVar:= @str_map_Size;
   'str_map_Random'                     : lang_Key2StrVar:= @str_map_Random;
   'str_map_Scenario'                   : lang_Key2StrVar:= @str_map_Scenario;
   'str_map_ScenarioL[mc_ffa3]'         : lang_Key2StrVar:= @str_map_ScenarioL[mc_ffa3];
   'str_map_ScenarioL[mc_ffa4]'         : lang_Key2StrVar:= @str_map_ScenarioL[mc_ffa4];
   'str_map_ScenarioL[mc_ffa5]'         : lang_Key2StrVar:= @str_map_ScenarioL[mc_ffa5];
   'str_map_ScenarioL[mc_ffa6]'         : lang_Key2StrVar:= @str_map_ScenarioL[mc_ffa6];
   'str_map_ScenarioL[mc_ffa7]'         : lang_Key2StrVar:= @str_map_ScenarioL[mc_ffa7];
   'str_map_ScenarioL[mc_ffa8]'         : lang_Key2StrVar:= @str_map_ScenarioL[mc_ffa8];
   'str_map_ScenarioL[mc_1x1]'          : lang_Key2StrVar:= @str_map_ScenarioL[mc_1x1];
   'str_map_ScenarioL[mc_2x2]'          : lang_Key2StrVar:= @str_map_ScenarioL[mc_2x2];
   'str_map_ScenarioL[mc_3x3]'          : lang_Key2StrVar:= @str_map_ScenarioL[mc_3x3];
   'str_map_ScenarioL[mc_4x4]'          : lang_Key2StrVar:= @str_map_ScenarioL[mc_4x4];
   'str_map_ScenarioL[mc_2x2x2]'        : lang_Key2StrVar:= @str_map_ScenarioL[mc_2x2x2];
   'str_map_ScenarioL[mc_2x2x2x2]'      : lang_Key2StrVar:= @str_map_ScenarioL[mc_2x2x2x2];
   'str_map_ScenarioL[mc_KeyPoints]'    : lang_Key2StrVar:= @str_map_ScenarioL[mc_KeyPoints];
   'str_map_ScenarioL[mc_KotH]'         : lang_Key2StrVar:= @str_map_ScenarioL[mc_KotH];
   'str_map_ScenarioL[mc_royale]'       : lang_Key2StrVar:= @str_map_ScenarioL[mc_royale];

   'str_map_Generators'                 : lang_Key2StrVar:= @str_map_Generators;
   'str_map_GeneratorsL[mapg_5]'        : lang_Key2StrVar:= @str_map_GeneratorsL[mapg_5];
   'str_map_GeneratorsL[mapg_10]'       : lang_Key2StrVar:= @str_map_GeneratorsL[mapg_10];
   'str_map_GeneratorsL[mapg_15]'       : lang_Key2StrVar:= @str_map_GeneratorsL[mapg_15];
   'str_map_GeneratorsL[mapg_20]'       : lang_Key2StrVar:= @str_map_GeneratorsL[mapg_20];
   'str_map_GeneratorsL[mapg_inf]'      : lang_Key2StrVar:= @str_map_GeneratorsL[mapg_inf];

   'str_map_Symmetry'                   : lang_Key2StrVar:= @str_map_Symmetry;
   'str_map_SymmertyL[maps_none]'       : lang_Key2StrVar:= @str_map_SymmertyL[maps_none];
   'str_map_SymmertyL[maps_point]'      : lang_Key2StrVar:= @str_map_SymmertyL[maps_point];
   'str_map_SymmertyL[maps_lineV]'      : lang_Key2StrVar:= @str_map_SymmertyL[maps_lineV];
   'str_map_SymmertyL[maps_lineh]'      : lang_Key2StrVar:= @str_map_SymmertyL[maps_lineh];
   'str_map_SymmertyL[maps_lineL]'      : lang_Key2StrVar:= @str_map_SymmertyL[maps_lineL];
   'str_map_SymmertyL[maps_lineR]'      : lang_Key2StrVar:= @str_map_SymmertyL[maps_lineR];

   'str_map_Template'                   : lang_Key2StrVar:= @str_map_Template;
   'str_map_TemplateL[mapt_lake]'       : lang_Key2StrVar:= @str_map_TemplateL[mapt_lake];
   'str_map_TemplateL[mapt_island]'     : lang_Key2StrVar:= @str_map_TemplateL[mapt_island];
   'str_map_TemplateL[mapt_temple]'     : lang_Key2StrVar:= @str_map_TemplateL[mapt_temple];
   'str_map_TemplateL[mapt_cave]'       : lang_Key2StrVar:= @str_map_TemplateL[mapt_cave];
   'str_map_TemplateL[mapt_steppe]'     : lang_Key2StrVar:= @str_map_TemplateL[mapt_steppe];
   'str_map_TemplateL[mapt_canyon]'     : lang_Key2StrVar:= @str_map_TemplateL[mapt_canyon];

   'str_objective_Scirmish'             : lang_Key2StrVar:= @str_objective_Scirmish;
   'str_objective_RoyalBattle'          : lang_Key2StrVar:= @str_objective_RoyalBattle;
   'str_objective_KotH'                 : lang_Key2StrVar:= @str_objective_KotH;
   'str_objective_KeyPoints'            : lang_Key2StrVar:= @str_objective_KeyPoints;

   'str_FileError_NExists'              : lang_Key2StrVar:= @str_FileError_NExists;
   'str_FileError_Open'                 : lang_Key2StrVar:= @str_FileError_Open;
   'str_FileError_WData'                : lang_Key2StrVar:= @str_FileError_WData;
   'str_FileError_WVer'                 : lang_Key2StrVar:= @str_FileError_WVer;

   'str_PT_Player'                      : lang_Key2StrVar:= @str_PT_Player;
   'str_PT_State'                       : lang_Key2StrVar:= @str_PT_State;
   'str_PT_Race'                        : lang_Key2StrVar:= @str_PT_Race;
   'str_PT_Team'                        : lang_Key2StrVar:= @str_PT_Team;
   'str_PT_Color'                       : lang_Key2StrVar:= @str_PT_Color;
   'str_PT_Ping'                        : lang_Key2StrVar:= @str_PT_Ping;
   'str_PT_Obs'                         : lang_Key2StrVar:= @str_PT_Obs;

   'str_race[r_random]'                 : lang_Key2StrVar:= @str_race[r_random];
   'str_race[r_hell]'                   : lang_Key2StrVar:= @str_race[r_hell];
   'str_race[r_uac]'                    : lang_Key2StrVar:= @str_race[r_uac];
   'str_observer'                       : lang_Key2StrVar:= @str_observer;

   'str_Players'                        : lang_Key2StrVar:= @str_Players;
   'str_all'                            : lang_Key2StrVar:= @str_all;

   'str_themes[0]'                      : lang_Key2StrVar:= @str_themes[0];
   'str_themes[1]'                      : lang_Key2StrVar:= @str_themes[1];
   'str_themes[2]'                      : lang_Key2StrVar:= @str_themes[2];
   'str_themes[3]'                      : lang_Key2StrVar:= @str_themes[3];
   'str_themes[4]'                      : lang_Key2StrVar:= @str_themes[4];
   'str_themes[5]'                      : lang_Key2StrVar:= @str_themes[5];
   'str_themes[6]'                      : lang_Key2StrVar:= @str_themes[6];
   'str_themes[7]'                      : lang_Key2StrVar:= @str_themes[7];
   'str_themes[8]'                      : lang_Key2StrVar:= @str_themes[8];

   'str_FileInfo'                       : lang_Key2StrVar:= @str_FileInfo;
   'str_FileSave'                       : lang_Key2StrVar:= @str_FileSave;
   'str_FileLoad'                       : lang_Key2StrVar:= @str_FileLoad;
   'str_FilePlay'                       : lang_Key2StrVar:= @str_FilePlay;
   'str_FileDelete'                     : lang_Key2StrVar:= @str_FileDelete;
   'str_FileReWrite'                    : lang_Key2StrVar:= @str_FileReWrite;

   'str_gstat_Lobby'                    : lang_Key2StrVar:= @str_gstat_Lobby;
   'str_gstat_WonTeam'                  : lang_Key2StrVar:= @str_gstat_WonTeam;
   'str_gstat_Started'                  : lang_Key2StrVar:= @str_gstat_Started;
   'str_gstat_Win'                      : lang_Key2StrVar:= @str_gstat_Win;
   'str_gstat_Lose'                     : lang_Key2StrVar:= @str_gstat_Lose;
   'str_gstat_GamePaused'               : lang_Key2StrVar:= @str_gstat_GamePaused;
   'str_gstat_ReplayEnd'                : lang_Key2StrVar:= @str_gstat_ReplayEnd;
   'str_gstat_ReplayError'              : lang_Key2StrVar:= @str_gstat_ReplayError;
   'str_gstat_ReplayPaused'             : lang_Key2StrVar:= @str_gstat_ReplayPaused;
   'str_gstat_WaitForServer'            : lang_Key2StrVar:= @str_gstat_WaitForServer;
   'str_gstat_WaitForPlayers'           : lang_Key2StrVar:= @str_gstat_WaitForPlayers;
   'str_gstat_Unknown'                  : lang_Key2StrVar:= @str_gstat_Unknown;

   'str_gmsg_GameSaved'                 : lang_Key2StrVar:= @str_gmsg_GameSaved;
   'str_gmsg_GameLoaded'                : lang_Key2StrVar:= @str_gmsg_GameLoaded;
   'str_gmsg_NoNewObservers'            : lang_Key2StrVar:= @str_gmsg_NoNewObservers;
   'str_gmsg_PlayerConnected'           : lang_Key2StrVar:= @str_gmsg_PlayerConnected;
   'str_gmsg_PlayerLeave'               : lang_Key2StrVar:= @str_gmsg_PlayerLeave;
   'str_gmsg_PlayerTimeOut'             : lang_Key2StrVar:= @str_gmsg_PlayerTimeOut;
   'str_gmsg_PlayerDefeat'              : lang_Key2StrVar:= @str_gmsg_PlayerDefeat;
   'str_gmsg_PlayerSurrender'           : lang_Key2StrVar:= @str_gmsg_PlayerSurrender;
   'str_gmsg_PlayerPaused'              : lang_Key2StrVar:= @str_gmsg_PlayerPaused;
   'str_gmsg_PlayerResumed'             : lang_Key2StrVar:= @str_gmsg_PlayerResumed;
   'str_gmsg_PlayerRevealed'            : lang_Key2StrVar:= @str_gmsg_PlayerRevealed;
   'str_gmsg_PlayerNoRevealed'          : lang_Key2StrVar:= @str_gmsg_PlayerNoRevealed;
   'str_gmsg_PortBlocked'               : lang_Key2StrVar:= @str_gmsg_PortBlocked;
   'str_gmsg_WrongVersion'              : lang_Key2StrVar:= @str_gmsg_WrongVersion;
   'str_gmsg_ServerFull'                : lang_Key2StrVar:= @str_gmsg_ServerFull;
   'str_gmsg_RecordStart'               : lang_Key2StrVar:= @str_gmsg_RecordStart;
   'str_gmsg_RecordError'               : lang_Key2StrVar:= @str_gmsg_RecordError;
   'str_gmsg_RecordStop'                : lang_Key2StrVar:= @str_gmsg_RecordStop;

   'str_warn_AbilityBadPlace'           : lang_Key2StrVar:= @str_warn_AbilityBadPlace;
   'str_warn_prod_BadPlace'             : lang_Key2StrVar:= @str_warn_prod_BadPlace;
   'str_warn_prod_CD'                   : lang_Key2StrVar:= @str_warn_prod_CD;
   'str_warn_prod_BadOrder'             : lang_Key2StrVar:= @str_warn_prod_BadOrder;
   'str_warn_prod_AllBusy'              : lang_Key2StrVar:= @str_warn_prod_AllBusy;
   'str_warn_prod_Unavailable'          : lang_Key2StrVar:= @str_warn_prod_Unavailable;
   'str_warn_Req_Energy'                : lang_Key2StrVar:= @str_warn_Req_Energy;
   'str_warn_Req_HellPower'             : lang_Key2StrVar:= @str_warn_Req_HellPower;
   'str_warn_Req_UACLoot'               : lang_Key2StrVar:= @str_warn_Req_UACLoot;
   'str_warn_Req_Common'                : lang_Key2StrVar:= @str_warn_Req_Common;
   'str_warn_unit_MaxLevel'             : lang_Key2StrVar:= @str_warn_unit_MaxLevel;
   'str_warn_unit_Levelup'              : lang_Key2StrVar:= @str_warn_unit_Levelup;
   'str_warn_unit_complete'             : lang_Key2StrVar:= @str_warn_unit_complete;
   'str_warn_unit_attacked'             : lang_Key2StrVar:= @str_warn_unit_attacked;
   'str_warn_unit_resurrected'          : lang_Key2StrVar:= @str_warn_unit_resurrected;
   'str_warn_unit_captured'             : lang_Key2StrVar:= @str_warn_unit_captured;
   'str_warn_unit_lost'                 : lang_Key2StrVar:= @str_warn_unit_lost;
   'str_warn_upgrade_InProgress'        : lang_Key2StrVar:= @str_warn_upgrade_InProgress;
   'str_warn_upgrade_complete'          : lang_Key2StrVar:= @str_warn_upgrade_complete;
   'str_warn_building_complete'         : lang_Key2StrVar:= @str_warn_building_complete;
   'str_warn_base_attacked'             : lang_Key2StrVar:= @str_warn_base_attacked;
   'str_warn_allies_attacked'           : lang_Key2StrVar:= @str_warn_allies_attacked;
   'str_warn_MaxLimitReached'           : lang_Key2StrVar:= @str_warn_MaxLimitReached;
   'str_warn_NeedBuilder'               : lang_Key2StrVar:= @str_warn_NeedBuilder;
   'str_warn_NeedProdUnit'              : lang_Key2StrVar:= @str_warn_NeedProdUnit;
   'str_warn_MaxCountReached'           : lang_Key2StrVar:= @str_warn_MaxCountReached;
   'str_warn_MaxBuildersReached'        : lang_Key2StrVar:= @str_warn_MaxBuildersReached;
   'str_warn_MarkLook'                  : lang_Key2StrVar:= @str_warn_MarkLook;
   'str_warn_MarkAttack'                : lang_Key2StrVar:= @str_warn_MarkAttack;
   'str_warn_kpoint_Captured'           : lang_Key2StrVar:= @str_warn_kpoint_Captured;
   'str_warn_kpoint_CaptureStart'       : lang_Key2StrVar:= @str_warn_kpoint_CaptureStart;
   'str_warn_koth_CaptureStart'         : lang_Key2StrVar:= @str_warn_koth_CaptureStart;
   'str_warn_koth_Alarm'                : lang_Key2StrVar:= @str_warn_koth_Alarm;
   'str_warn_ngen_captured'             : lang_Key2StrVar:= @str_warn_ngen_captured;
   'str_warn_ngen_alarm'                : lang_Key2StrVar:= @str_warn_ngen_alarm;
   'str_warn_ngen_lost'                 : lang_Key2StrVar:= @str_warn_ngen_lost;
   'str_warn_ngen_exh'                  : lang_Key2StrVar:= @str_warn_ngen_exh;
   'str_warn_Invalid_Target'            : lang_Key2StrVar:= @str_warn_Invalid_Target;
   'str_warn_Invalid_Order'             : lang_Key2StrVar:= @str_warn_Invalid_Order;
   'str_warn_AbilityReload'             : lang_Key2StrVar:= @str_warn_AbilityReload;
   'str_warn_AbilityCasting'            : lang_Key2StrVar:= @str_warn_AbilityCasting;
   'str_warn_AbilityReqUACNear'         : lang_Key2StrVar:= @str_warn_AbilityReqUACNear;
   'str_warn_AbilityReqHelNear'         : lang_Key2StrVar:= @str_warn_AbilityReqHelNear;
   'str_warn_AbilityTar2Close'          : lang_Key2StrVar:= @str_warn_AbilityTar2Close;
   'str_warn_UACStrike'                 : lang_Key2StrVar:= @str_warn_UACStrike;
   'str_warn_UACScan'                   : lang_Key2StrVar:= @str_warn_UACScan;

   'str_ui_time'                        : lang_Key2StrVar:= @str_ui_time;
   'str_ui_menu'                        : lang_Key2StrVar:= @str_ui_menu;
   'str_ui_UnitGroups'                  : lang_Key2StrVar:= @str_ui_UnitGroups;
   'str_ui_KothTime'                    : lang_Key2StrVar:= @str_ui_KothTime;
   'str_ui_KotHTime_act'                : lang_Key2StrVar:= @str_ui_KotHTime_act;
   'str_ui_KotHWinner'                  : lang_Key2StrVar:= @str_ui_KotHWinner;
   'str_ui_ChatAll'                     : lang_Key2StrVar:= @str_ui_ChatAll;
   'str_ui_ChatAllies'                  : lang_Key2StrVar:= @str_ui_ChatAllies;
   'str_ui_Tab[tab_Buildings]'          : lang_Key2StrVar:= @str_ui_Tab[tab_Buildings];
   'str_ui_Tab[tab_Units]'              : lang_Key2StrVar:= @str_ui_Tab[tab_Units];
   'str_ui_Tab[tab_Upgrades]'           : lang_Key2StrVar:= @str_ui_Tab[tab_Upgrades];
   'str_ui_Tab[tab_Controls]'           : lang_Key2StrVar:= @str_ui_Tab[tab_Controls];
   'str_ui_LimitArmy'                   : lang_Key2StrVar:= @str_ui_LimitArmy;
   'str_ui_LimitBuildings'              : lang_Key2StrVar:= @str_ui_LimitBuildings;
   'str_ui_LimitUnits'                  : lang_Key2StrVar:= @str_ui_LimitUnits;
   'str_ui_EnergyLevel'                 : lang_Key2StrVar:= @str_ui_EnergyLevel;
   'str_ui_HellPower'                   : lang_Key2StrVar:= @str_ui_HellPower;
   'str_ui_UACLoot'                     : lang_Key2StrVar:= @str_ui_UACLoot;
   'str_ui_objectives'                  : lang_Key2StrVar:= @str_ui_objectives;
   'str_ui_SelectTarget'                : lang_Key2StrVar:= @str_ui_SelectTarget;
   'str_ui_SelectBPlace'                : lang_Key2StrVar:= @str_ui_SelectBPlace;
   'str_ui_BuildHint'                   : lang_Key2StrVar:= @str_ui_BuildHint;
   'str_ui_BuildTip'                    : lang_Key2StrVar:= @str_ui_BuildTip;
   'str_ui_RightClickCancel'            : lang_Key2StrVar:= @str_ui_RightClickCancel;

   'str_attr_alive'                     : lang_Key2StrVar:= @str_attr_alive;
   'str_attr_dead'                      : lang_Key2StrVar:= @str_attr_dead;
   'str_attr_unit'                      : lang_Key2StrVar:= @str_attr_unit;
   'str_attr_building'                  : lang_Key2StrVar:= @str_attr_building;
   'str_attr_mech'                      : lang_Key2StrVar:= @str_attr_mech;
   'str_attr_bio'                       : lang_Key2StrVar:= @str_attr_bio;
   'str_attr_light'                     : lang_Key2StrVar:= @str_attr_light;
   'str_attr_heavy'                     : lang_Key2StrVar:= @str_attr_heavy;
   'str_attr_fly'                       : lang_Key2StrVar:= @str_attr_fly;
   'str_attr_ground'                    : lang_Key2StrVar:= @str_attr_ground;
   'str_attr_level'                     : lang_Key2StrVar:= @str_attr_level;
   'str_attr_SSoul'                     : lang_Key2StrVar:= @str_attr_SSoul;
   'str_attr_SInvuln'                   : lang_Key2StrVar:= @str_attr_SInvuln;
   'str_attr_SInvis'                    : lang_Key2StrVar:= @str_attr_SInvis;
   'str_attr_SRDamage'                  : lang_Key2StrVar:= @str_attr_SRDamage;
   'str_attr_SDDamage'                  : lang_Key2StrVar:= @str_attr_SDDamage;
   'str_attr_STurbo'                    : lang_Key2StrVar:= @str_attr_STurbo;
   'str_attr_HVision'                   : lang_Key2StrVar:= @str_attr_HVision;
   'str_attr_Scaned'                    : lang_Key2StrVar:= @str_attr_Scaned;
   'str_attr_Decay'                     : lang_Key2StrVar:= @str_attr_Decay;
   'str_attr_stuned'                    : lang_Key2StrVar:= @str_attr_stuned;
   'str_attr_detector'                  : lang_Key2StrVar:= @str_attr_detector;
   'str_attr_heroic'                    : lang_Key2StrVar:= @str_attr_heroic;

   'str_hint_upgrade'                   : lang_Key2StrVar:= @str_hint_upgrade;
   'str_hint_sec'                       : lang_Key2StrVar:= @str_hint_sec;
   'str_hint_requirements'              : lang_Key2StrVar:= @str_hint_requirements;
   'str_hint_req'                       : lang_Key2StrVar:= @str_hint_req;
   'str_hint_uprod'                     : lang_Key2StrVar:= @str_hint_uprod;
   'str_hint_bprod'                     : lang_Key2StrVar:= @str_hint_bprod;
   'str_hint_UpgradesLvl'               : lang_Key2StrVar:= @str_hint_UpgradesLvl;
   'str_hint_Zombies'                   : lang_Key2StrVar:= @str_hint_Zombies;
   'str_hint_Demons'                    : lang_Key2StrVar:= @str_hint_Demons;
   'str_hint_Except'                    : lang_Key2StrVar:= @str_hint_Except;
   'str_hint_SplashResist'              : lang_Key2StrVar:= @str_hint_SplashResist;
   'str_hint_FlyLikeTarget'             : lang_Key2StrVar:= @str_hint_FlyLikeTarget;
   'str_hint_TargetLimit'               : lang_Key2StrVar:= @str_hint_TargetLimit;
   'str_hint_builder'                   : lang_Key2StrVar:= @str_hint_builder;
   'str_hint_barrack'                   : lang_Key2StrVar:= @str_hint_barrack;
   'str_hint_forge'                     : lang_Key2StrVar:= @str_hint_forge;
   'str_hint_IncEnergyLevel'            : lang_Key2StrVar:= @str_hint_IncEnergyLevel;
   'str_hint_UnitArming'                : lang_Key2StrVar:= @str_hint_UnitArming;
   'str_hint_Abilities'                 : lang_Key2StrVar:= @str_hint_Abilities;
   'str_hint_SightR'                    : lang_Key2StrVar:= @str_hint_SightR;
   'str_hint_MaxQuantity'               : lang_Key2StrVar:= @str_hint_MaxQuantity;

   'str_uarm_melee'                     : lang_Key2StrVar:= @str_uarm_melee;
   'str_uarm_ranged'                    : lang_Key2StrVar:= @str_uarm_ranged;
   'str_uarm_zombie'                    : lang_Key2StrVar:= @str_uarm_zombie;
   'str_uarm_ressurect'                 : lang_Key2StrVar:= @str_uarm_ressurect;
   'str_uarm_heal'                      : lang_Key2StrVar:= @str_uarm_heal;
   'str_uarm_spawn'                     : lang_Key2StrVar:= @str_uarm_spawn;
   'str_uarm_targets'                   : lang_Key2StrVar:= @str_uarm_targets;
   'str_uarm_BaseImpact'                : lang_Key2StrVar:= @str_uarm_BaseImpact;
   'str_uarm_MinRange'                  : lang_Key2StrVar:= @str_uarm_MinRange;
   'str_uarm_MaxRange'                  : lang_Key2StrVar:= @str_uarm_MaxRange;
   'str_uarm_BonusAFlyR'                : lang_Key2StrVar:= @str_uarm_BonusAFlyR;
   'str_uarm_BonusAGroundR'             : lang_Key2StrVar:= @str_uarm_BonusAGroundR;
   'str_uarm_BonusAUnitR'               : lang_Key2StrVar:= @str_uarm_BonusAUnitR;
   'str_uarm_BonusABuildingR'           : lang_Key2StrVar:= @str_uarm_BonusABuildingR;
   'str_uarm_SplashDamageR'             : lang_Key2StrVar:= @str_uarm_SplashDamageR;
   'str_uarm_Upgrade'                   : lang_Key2StrVar:= @str_uarm_Upgrade;
   'str_uarm_Factor'                    : lang_Key2StrVar:= @str_uarm_Factor;
   'str_uarm_ShotsPerSec'               : lang_Key2StrVar:= @str_uarm_ShotsPerSec;

   'str_ability_passive'                : lang_Key2StrVar:= @str_ability_passive;
   'str_ability_active'                 : lang_Key2StrVar:= @str_ability_active;
   'str_ability_notarget'               : lang_Key2StrVar:= @str_ability_notarget;
   'str_ability_point'                  : lang_Key2StrVar:= @str_ability_point;
   'str_ability_UnitAny'                : lang_Key2StrVar:= @str_ability_UnitAny;
   'str_ability_UnitOwn'                : lang_Key2StrVar:= @str_ability_UnitOwn;
   'str_ability_UnitAlly'               : lang_Key2StrVar:= @str_ability_UnitAlly;
   'str_ability_UnitEnemy'              : lang_Key2StrVar:= @str_ability_UnitEnemy;
   'str_ability_reload'                 : lang_Key2StrVar:= @str_ability_reload;
   'str_ability_ReloadFactors'          : lang_Key2StrVar:= @str_ability_ReloadFactors;
   'str_ability_rldDecByLevel'          : lang_Key2StrVar:= @str_ability_rldDecByLevel;

   'str_net_Ready'                      : lang_Key2StrVar:= @str_net_Ready;
   'str_net_Disconnect'                 : lang_Key2StrVar:= @str_net_Disconnect;
   'str_net_UDPPort'                    : lang_Key2StrVar:= @str_net_UDPPort;
   'str_net_ServerStart'                : lang_Key2StrVar:= @str_net_ServerStart;
   'str_net_ServerStop'                 : lang_Key2StrVar:= @str_net_ServerStop;
   'str_net_Connect'                    : lang_Key2StrVar:= @str_net_Connect;
   'str_net_Quality'                    : lang_Key2StrVar:= @str_net_Quality;
   'str_net_Address'                    : lang_Key2StrVar:= @str_net_Address;
   'str_net_ServerList'                 : lang_Key2StrVar:= @str_net_ServerList;
   'str_net_ServerListAdd'              : lang_Key2StrVar:= @str_net_ServerListAdd;
   'str_net_ServerLANAdv'               : lang_Key2StrVar:= @str_net_ServerLANAdv;
   'str_net_ConnectedTo'                : lang_Key2StrVar:= @str_net_ConnectedTo;
   'str_net_DedicatedServer'            : lang_Key2StrVar:= @str_net_DedicatedServer;

   'str_help_Credits'                   : lang_Key2StrVar:= @str_help_Credits;
   'str_help_GameControls'              : lang_Key2StrVar:= @str_help_GameControls;
   'str_help_GameHotKeys'               : lang_Key2StrVar:= @str_help_GameHotKeys;
   'str_help_GameUI'                    : lang_Key2StrVar:= @str_help_GameUI;
   'str_help_GameMechanics'             : lang_Key2StrVar:= @str_help_GameMechanics;
   'str_help_UnitsInfo'                 : lang_Key2StrVar:= @str_help_UnitsInfo;
   'str_help_BalanceTable'              : lang_Key2StrVar:= @str_help_BalanceTable;
   'str_help_UpgradesInfo'              : lang_Key2StrVar:= @str_help_UpgradesInfo;
   'str_help_Other'                     : lang_Key2StrVar:= @str_help_Other;

   'str_help_ImgUI'                     : lang_Key2StrVar:= @str_help_ImgUI;
   'str_help_ImgUUpgrade'               : lang_Key2StrVar:= @str_help_ImgUUpgrade;
   'str_help_ImgGenerators'             : lang_Key2StrVar:= @str_help_ImgGenerators;
   'str_help_ImgKeyPoints'              : lang_Key2StrVar:= @str_help_ImgKeyPoints;
   'str_help_ImgKotH'                   : lang_Key2StrVar:= @str_help_ImgKotH;

   'str_doc_HotKey'                     : lang_Key2StrVar:= @str_doc_HotKey;
   'str_doc_Attributes'                 : lang_Key2StrVar:= @str_doc_Attributes;
   'str_doc_ReqEnergy'                  : lang_Key2StrVar:= @str_doc_ReqEnergy;
   'str_doc_ReqHellPower'               : lang_Key2StrVar:= @str_doc_ReqHellPower;
   'str_doc_ReqUACLoot'                 : lang_Key2StrVar:= @str_doc_ReqUACLoot;
   'str_doc_ProdTime'                   : lang_Key2StrVar:= @str_doc_ProdTime;
   'str_doc_Limit'                      : lang_Key2StrVar:= @str_doc_Limit;
   'str_doc_MaxHits'                    : lang_Key2StrVar:= @str_doc_MaxHits;
   'str_doc_FastDeath'                  : lang_Key2StrVar:= @str_doc_FastDeath;
   'str_doc_Hits'                       : lang_Key2StrVar:= @str_doc_Hits;
   'str_doc_LifeTime'                   : lang_Key2StrVar:= @str_doc_LifeTime;
   'str_doc_BaseRegen'                  : lang_Key2StrVar:= @str_doc_BaseRegen;
   'str_doc_BaseSightR'                 : lang_Key2StrVar:= @str_doc_BaseSightR;
   'str_doc_Size'                       : lang_Key2StrVar:= @str_doc_Size;
   'str_doc_BaseMSpeed'                 : lang_Key2StrVar:= @str_doc_BaseMSpeed;
   'str_doc_Role'                       : lang_Key2StrVar:= @str_doc_Role;
   'str_doc_Description'                : lang_Key2StrVar:= @str_doc_Description;
   'str_doc_PainC'                      : lang_Key2StrVar:= @str_doc_PainC;
   'str_doc_TransportSize'              : lang_Key2StrVar:= @str_doc_TransportSize;
   'str_doc_TransportCpst'              : lang_Key2StrVar:= @str_doc_TransportCpst;
   'str_doc_UpgrLevels'                 : lang_Key2StrVar:= @str_doc_UpgrLevels;
   'str_doc_UpgrAffectedUIDs'           : lang_Key2StrVar:= @str_doc_UpgrAffectedUIDs;
   'str_doc_LevelUpTime'                : lang_Key2StrVar:= @str_doc_LevelUpTime;
   'str_doc_LevelArmorBonus'            : lang_Key2StrVar:= @str_doc_LevelArmorBonus;
   'str_doc_LevelDamageBonus'           : lang_Key2StrVar:= @str_doc_LevelDamageBonus;
   'str_doc_LevelPainSBonus'            : lang_Key2StrVar:= @str_doc_LevelPainSBonus;
   'str_doc_LevelRegenBonus'            : lang_Key2StrVar:= @str_doc_LevelRegenBonus;
   'str_doc_BountyHellPower'            : lang_Key2StrVar:= @str_doc_BountyHellPower;
   'str_doc_BountyUACLoot'              : lang_Key2StrVar:= @str_doc_BountyUACLoot;
   'str_doc_ZombieUID'                  : lang_Key2StrVar:= @str_doc_ZombieUID;
   'str_doc_ZombieHits'                 : lang_Key2StrVar:= @str_doc_ZombieHits;
   'str_doc_DeathUnit'                  : lang_Key2StrVar:= @str_doc_DeathUnit;
   'str_doc_UpgrArmor'                  : lang_Key2StrVar:= @str_doc_UpgrArmor;
   'str_doc_UpgrRegen'                  : lang_Key2StrVar:= @str_doc_UpgrRegen;
   'str_doc_UpgrSpeed'                  : lang_Key2StrVar:= @str_doc_UpgrSpeed;
   'str_doc_UpgrPainS'                  : lang_Key2StrVar:= @str_doc_UpgrPainS;
   'str_doc_UpgrSightR'                 : lang_Key2StrVar:= @str_doc_UpgrSightR;
   'str_doc_UpgrTransport'              : lang_Key2StrVar:= @str_doc_UpgrTransport;
   'str_doc_BalanceGood'                : lang_Key2StrVar:= @str_doc_BalanceGood;
   'str_doc_BalanceBad'                 : lang_Key2StrVar:= @str_doc_BalanceBad;
   'str_doc_BalanceUseless'             : lang_Key2StrVar:= @str_doc_BalanceUseless;
   'str_doc_LMB'                        : lang_Key2StrVar:= @str_doc_LMB;
   'str_doc_RMB'                        : lang_Key2StrVar:= @str_doc_RMB;
   'str_doc_MWH'                        : lang_Key2StrVar:= @str_doc_MWH;
   'str_doc_NoteUnitBalance'            : lang_Key2StrVar:= @str_doc_NoteUnitBalance;
   'str_doc_NoteMaxBuilders'            : lang_Key2StrVar:= @str_doc_NoteMaxBuilders;

   'str_ScoreBoardC[psc_units_created]'   : lang_Key2StrVar:= @str_ScoreBoardC[psc_units_created   ];
   'str_ScoreBoardC[psc_units_summoned]'  : lang_Key2StrVar:= @str_ScoreBoardC[psc_units_summoned  ];
   'str_ScoreBoardC[psc_units_resurected]': lang_Key2StrVar:= @str_ScoreBoardC[psc_units_resurected];
   'str_ScoreBoardC[psc_units_captured]'  : lang_Key2StrVar:= @str_ScoreBoardC[psc_units_captured  ];
   'str_ScoreBoardC[psc_units_lost]'      : lang_Key2StrVar:= @str_ScoreBoardC[psc_units_lost      ];
   'str_ScoreBoardC[psc_units_destroyed]' : lang_Key2StrVar:= @str_ScoreBoardC[psc_units_destroyed ];
   'str_ScoreBoardC[psc_units_ExpTotal]'  : lang_Key2StrVar:= @str_ScoreBoardC[psc_units_ExpTotal  ];
   'str_ScoreBoardC[psc_builds_created]'  : lang_Key2StrVar:= @str_ScoreBoardC[psc_builds_created  ];
   'str_ScoreBoardC[psc_builds_summoned]' : lang_Key2StrVar:= @str_ScoreBoardC[psc_builds_summoned ];
   'str_ScoreBoardC[psc_builds_captured]' : lang_Key2StrVar:= @str_ScoreBoardC[psc_builds_captured ];
   'str_ScoreBoardC[psc_builds_lost]'     : lang_Key2StrVar:= @str_ScoreBoardC[psc_builds_lost     ];
   'str_ScoreBoardC[psc_builds_destroyed]': lang_Key2StrVar:= @str_ScoreBoardC[psc_builds_destroyed];
   'str_ScoreBoardC[psc_upgrades_level]'  : lang_Key2StrVar:= @str_ScoreBoardC[psc_upgrades_level  ];
   'str_ScoreBoardC[psc_InGameTime]'      : lang_Key2StrVar:= @str_ScoreBoardC[psc_InGameTime      ];

   'str_ScoreBoardI[psi_res_energy_max]': lang_Key2StrVar:= @str_ScoreBoardI[psi_res_energy_max];
   'str_ScoreBoardI[psi_res_UACLoot]'   : lang_Key2StrVar:= @str_ScoreBoardI[psi_res_UACLoot   ];
   'str_ScoreBoardI[psi_res_HellPower]' : lang_Key2StrVar:= @str_ScoreBoardI[psi_res_HellPower ];

   'str_Camp_Difficulty'                : lang_Key2StrVar:= @str_Camp_Difficulty;
   'str_Camp_DifficultyL[0]'            : lang_Key2StrVar:= @str_Camp_DifficultyL[0];
   'str_Camp_DifficultyL[1]'            : lang_Key2StrVar:= @str_Camp_DifficultyL[1];
   'str_Camp_DifficultyL[2]'            : lang_Key2StrVar:= @str_Camp_DifficultyL[2];
   'str_Camp_DifficultyL[3]'            : lang_Key2StrVar:= @str_Camp_DifficultyL[3];
   'str_Camp_DifficultyL[4]'            : lang_Key2StrVar:= @str_Camp_DifficultyL[4];

   'str_Camp_Campaign'                  : lang_Key2StrVar:= @str_Camp_Campaign;
   'str_Camp_Mission'                   : lang_Key2StrVar:= @str_Camp_Mission;
   'str_Camp_Info'                      : lang_Key2StrVar:= @str_Camp_Info;
   'str_Camp_Location'                  : lang_Key2StrVar:= @str_Camp_Location;
   'str_Camp_NewUnits'                  : lang_Key2StrVar:= @str_Camp_NewUnits;

   'str_Camp_HE_CoB'                    : lang_Key2StrVar:= @str_Camp_HE_CoB;
   'str_Camp_HE_EE'                     : lang_Key2StrVar:= @str_Camp_HE_EE;
   'str_Camp_HE_PoA'                    : lang_Key2StrVar:= @str_Camp_HE_PoA;
   'str_Camp_HE_BS'                     : lang_Key2StrVar:= @str_Camp_HE_BS;
   'str_Camp_HE_LoH'                    : lang_Key2StrVar:= @str_Camp_HE_LoH;
   'str_Camp_HE_CoBS'                   : lang_Key2StrVar:= @str_Camp_HE_CoBS;

   'str_camp_1'                         : lang_Key2StrVar:= @camp_list[0];

   'str_camp_1_miss_1_name'             : lang_Key2StrVar:= @camp_mis_list[0][0];
   'str_camp_1_miss_2_name'             : lang_Key2StrVar:= @camp_mis_list[0][1];
   'str_camp_1_miss_3_name'             : lang_Key2StrVar:= @camp_mis_list[0][2];
   'str_camp_1_miss_4_name'             : lang_Key2StrVar:= @camp_mis_list[0][3];
   'str_camp_1_miss_5_name'             : lang_Key2StrVar:= @camp_mis_list[0][4];

   'str_camp_1_miss_1_obj'              : lang_Key2StrVar:= @camp_obj_object[0][0];
   'str_camp_1_miss_2_obj'              : lang_Key2StrVar:= @camp_obj_object[0][1];
   'str_camp_1_miss_3_obj'              : lang_Key2StrVar:= @camp_obj_object[0][2];
   'str_camp_1_miss_4_obj'              : lang_Key2StrVar:= @camp_obj_object[0][3];
   'str_camp_1_miss_5_obj'              : lang_Key2StrVar:= @camp_obj_object[0][4];

   'str_camp_1_miss_1_loc'              : lang_Key2StrVar:= @camp_obj_loc[0][0];
   'str_camp_1_miss_2_loc'              : lang_Key2StrVar:= @camp_obj_loc[0][1];
   'str_camp_1_miss_3_loc'              : lang_Key2StrVar:= @camp_obj_loc[0][2];
   'str_camp_1_miss_4_loc'              : lang_Key2StrVar:= @camp_obj_loc[0][3];
   'str_camp_1_miss_5_loc'              : lang_Key2StrVar:= @camp_obj_loc[0][4];

   // ABILITIES

   'str_name[uab_Teleport]'             : lang_Key2StrVar:= @g_aids[uab_Teleport         ].ua_str_name;
   'str_name[uab_Recall]'               : lang_Key2StrVar:= @g_aids[uab_Recall           ].ua_str_name;
   'str_name[uab_UACScan]'              : lang_Key2StrVar:= @g_aids[uab_UACScan          ].ua_str_name;
   'str_name[uab_UACStrike]'            : lang_Key2StrVar:= @g_aids[uab_UACStrike        ].ua_str_name;
   'str_name[uab_HEyeSpawn]'            : lang_Key2StrVar:= @g_aids[uab_HEyeSpawn        ].ua_str_name;
   'str_name[uab_HTowerBlink]'          : lang_Key2StrVar:= @g_aids[uab_HTowerBlink      ].ua_str_name;
   'str_name[uab_HKeepShift]'           : lang_Key2StrVar:= @g_aids[uab_HKeepShift       ].ua_str_name;
   'str_name[uab_HKeepAura]'            : lang_Key2StrVar:= @g_aids[uab_HKeepAura        ].ua_str_name;
   'str_name[uab_SpawnLost]'            : lang_Key2StrVar:= @g_aids[uab_SpawnLost        ].ua_str_name;
   'str_name[uab_SpawnLostTo]'          : lang_Key2StrVar:= @g_aids[uab_SpawnLostTo      ].ua_str_name;
   'str_name[uab_HEyeVision]'           : lang_Key2StrVar:= @g_aids[uab_HEyeVision       ].ua_str_name;
   'str_name[uab_UACCCLand]'            : lang_Key2StrVar:= @g_aids[uab_UACCCLand        ].ua_str_name;
   'str_name[uab_UACCCLandTo]'          : lang_Key2StrVar:= @g_aids[uab_UACCCLandTo      ].ua_str_name;
   'str_name[uab_HellCCLand]'           : lang_Key2StrVar:= @g_aids[uab_HellCCLand       ].ua_str_name;
   'str_name[uab_HellCCLandTo]'         : lang_Key2StrVar:= @g_aids[uab_HellCCLandTo     ].ua_str_name;

   'str_name[uab_Unload]'               : lang_Key2StrVar:= @g_aids[uab_Unload           ].ua_str_name;
   'str_name[uab_UnloadTo]'             : lang_Key2StrVar:= @g_aids[uab_UnloadTo         ].ua_str_name;

   'str_name[uab_SphereSoul]'           : lang_Key2StrVar:= @g_aids[uab_SphereSoul       ].ua_str_name;
   'str_name[uab_SphereInvis]'          : lang_Key2StrVar:= @g_aids[uab_SphereInvis      ].ua_str_name;
   'str_name[uab_SphereInvuln]'         : lang_Key2StrVar:= @g_aids[uab_SphereInvuln     ].ua_str_name;
   'str_name[uab_SphereRDamage]'        : lang_Key2StrVar:= @g_aids[uab_SphereRDamage    ].ua_str_name;
   'str_name[uab_SphereDDamage]'        : lang_Key2StrVar:= @g_aids[uab_SphereDDamage    ].ua_str_name;
   'str_name[uab_SphereTurbo]'          : lang_Key2StrVar:= @g_aids[uab_SphereTurbo      ].ua_str_name;

   'str_name[uab_UACGeneral]'           : lang_Key2StrVar:= @g_aids[uab_UACGeneral       ].ua_str_name;
   'str_name[uab_Bribe]'                : lang_Key2StrVar:= @g_aids[uab_Bribe            ].ua_str_name;
   'str_name[uab_Hack]'                 : lang_Key2StrVar:= @g_aids[uab_Hack             ].ua_str_name;

   'str_name[uab_ToHAKeep]'             : lang_Key2StrVar:= @g_aids[uab_ToHAKeep         ].ua_str_name;
   'str_name[uab_ToHGate]'              : lang_Key2StrVar:= @g_aids[uab_ToHGate          ].ua_str_name;
   'str_name[uab_ToHPools]'             : lang_Key2StrVar:= @g_aids[uab_ToHPools         ].ua_str_name;
   'str_name[uab_ToHACommandCenter]'    : lang_Key2StrVar:= @g_aids[uab_ToHACommandCenter].ua_str_name;
   'str_name[uab_ToHBarracks]'          : lang_Key2StrVar:= @g_aids[uab_ToHBarracks      ].ua_str_name;

   'str_name[uab_ToUACommandCenter]'    : lang_Key2StrVar:= @g_aids[uab_ToUACommandCenter].ua_str_name;
   'str_name[uab_ToUBarracks]'          : lang_Key2StrVar:= @g_aids[uab_ToUBarracks      ].ua_str_name;
   'str_name[uab_ToUFactory]'           : lang_Key2StrVar:= @g_aids[uab_ToUFactory       ].ua_str_name;
   'str_name[uab_ToUWeaponFactory]'     : lang_Key2StrVar:= @g_aids[uab_ToUWeaponFactory ].ua_str_name;
   'str_name[uab_ToUAGTurret]'          : lang_Key2StrVar:= @g_aids[uab_ToUAGTurret      ].ua_str_name;
   'str_name[uab_ToUAATurret]'          : lang_Key2StrVar:= @g_aids[uab_ToUAATurret      ].ua_str_name;
   'str_name[uab_ToUACDron]'            : lang_Key2StrVar:= @g_aids[uab_ToUACDron        ].ua_str_name;
   'str_name[uab_ToUGTurretTo]'         : lang_Key2StrVar:= @g_aids[uab_ToUGTurretTo     ].ua_str_name;
   'str_name[uab_ToUATurretTo]'         : lang_Key2StrVar:= @g_aids[uab_ToUATurretTo     ].ua_str_name;
   'str_name[uab_LvlUpURadar]'          : lang_Key2StrVar:= @g_aids[uab_LvlUpURadar      ].ua_str_name;
   'str_name[uab_LvlUpURMStation]'      : lang_Key2StrVar:= @g_aids[uab_LvlUpURMStation  ].ua_str_name;

   'str_name[uab_HSpecter]'             : lang_Key2StrVar:= @g_aids[uab_HSpecter         ].ua_str_name;
   'str_name[uab_HStealth]'             : lang_Key2StrVar:= @g_aids[uab_HStealth         ].ua_str_name;
   'str_name[uab_HHTShroud]'            : lang_Key2StrVar:= @g_aids[uab_HHTShroud        ].ua_str_name;
   'str_name[uab_HT2TNoCD]'             : lang_Key2StrVar:= @g_aids[uab_HT2TNoCD         ].ua_str_name;
   'str_name[uab_UAASplash]'            : lang_Key2StrVar:= @g_aids[uab_UAASplash        ].ua_str_name;

   'str_dscr[uab_Teleport]'             : lang_Key2StrVar:= @g_aids[uab_Teleport         ].ua_str_Descript;
   'str_dscr[uab_Recall]'               : lang_Key2StrVar:= @g_aids[uab_Recall           ].ua_str_Descript;
   'str_dscr[uab_UACScan]'              : lang_Key2StrVar:= @g_aids[uab_UACScan          ].ua_str_Descript;
   'str_dscr[uab_UACStrike]'            : lang_Key2StrVar:= @g_aids[uab_UACStrike        ].ua_str_Descript;
   'str_dscr[uab_HEyeSpawn]'            : lang_Key2StrVar:= @g_aids[uab_HEyeSpawn        ].ua_str_Descript;
   'str_dscr[uab_HTowerBlink]'          : lang_Key2StrVar:= @g_aids[uab_HTowerBlink      ].ua_str_Descript;
   'str_dscr[uab_HKeepShift]'           : lang_Key2StrVar:= @g_aids[uab_HKeepShift       ].ua_str_Descript;
   'str_dscr[uab_HKeepAura]'            : lang_Key2StrVar:= @g_aids[uab_HKeepAura        ].ua_str_Descript;
   'str_dscr[uab_SpawnLost]'            : lang_Key2StrVar:= @g_aids[uab_SpawnLost        ].ua_str_Descript;
   'str_dscr[uab_SpawnLostTo]'          : lang_Key2StrVar:= @g_aids[uab_SpawnLostTo      ].ua_str_Descript;
   'str_dscr[uab_HEyeVision]'           : lang_Key2StrVar:= @g_aids[uab_HEyeVision       ].ua_str_Descript;
   'str_dscr[uab_UACCCLand]'            : lang_Key2StrVar:= @g_aids[uab_UACCCLand        ].ua_str_Descript;
   'str_dscr[uab_UACCCLandTo]'          : lang_Key2StrVar:= @g_aids[uab_UACCCLandTo      ].ua_str_Descript;
   'str_dscr[uab_HellCCLand]'           : lang_Key2StrVar:= @g_aids[uab_HellCCLand       ].ua_str_Descript;
   'str_dscr[uab_HellCCLandTo]'         : lang_Key2StrVar:= @g_aids[uab_HellCCLandTo     ].ua_str_Descript;

   'str_dscr[uab_Unload]'               : lang_Key2StrVar:= @g_aids[uab_Unload           ].ua_str_Descript;
   'str_dscr[uab_UnloadTo]'             : lang_Key2StrVar:= @g_aids[uab_UnloadTo         ].ua_str_Descript;

   'str_dscr[uab_SphereSoul]'           : lang_Key2StrVar:= @g_aids[uab_SphereSoul       ].ua_str_Descript;
   'str_dscr[uab_SphereInvis]'          : lang_Key2StrVar:= @g_aids[uab_SphereInvis      ].ua_str_Descript;
   'str_dscr[uab_SphereInvuln]'         : lang_Key2StrVar:= @g_aids[uab_SphereInvuln     ].ua_str_Descript;
   'str_dscr[uab_SphereRDamage]'        : lang_Key2StrVar:= @g_aids[uab_SphereRDamage    ].ua_str_Descript;
   'str_dscr[uab_SphereDDamage]'        : lang_Key2StrVar:= @g_aids[uab_SphereDDamage    ].ua_str_Descript;
   'str_dscr[uab_SphereTurbo]'          : lang_Key2StrVar:= @g_aids[uab_SphereTurbo      ].ua_str_Descript;

   'str_dscr[uab_UACGeneral]'           : lang_Key2StrVar:= @g_aids[uab_UACGeneral       ].ua_str_Descript;
   'str_dscr[uab_Bribe]'                : lang_Key2StrVar:= @g_aids[uab_Bribe            ].ua_str_Descript;
   'str_dscr[uab_Hack]'                 : lang_Key2StrVar:= @g_aids[uab_Hack             ].ua_str_Descript;

   'str_dscr[uab_ToHAKeep]'             : lang_Key2StrVar:= @g_aids[uab_ToHAKeep         ].ua_str_Descript;
   'str_dscr[uab_ToHGate]'              : lang_Key2StrVar:= @g_aids[uab_ToHGate          ].ua_str_Descript;
   'str_dscr[uab_ToHPools]'             : lang_Key2StrVar:= @g_aids[uab_ToHPools         ].ua_str_Descript;
   'str_dscr[uab_ToHACommandCenter]'    : lang_Key2StrVar:= @g_aids[uab_ToHACommandCenter].ua_str_Descript;
   'str_dscr[uab_ToHBarracks]'          : lang_Key2StrVar:= @g_aids[uab_ToHBarracks      ].ua_str_Descript;

   'str_dscr[uab_ToUACommandCenter]'    : lang_Key2StrVar:= @g_aids[uab_ToUACommandCenter].ua_str_Descript;
   'str_dscr[uab_ToUBarracks]'          : lang_Key2StrVar:= @g_aids[uab_ToUBarracks      ].ua_str_Descript;
   'str_dscr[uab_ToUFactory]'           : lang_Key2StrVar:= @g_aids[uab_ToUFactory       ].ua_str_Descript;
   'str_dscr[uab_ToUWeaponFactory]'     : lang_Key2StrVar:= @g_aids[uab_ToUWeaponFactory ].ua_str_Descript;
   'str_dscr[uab_ToUAGTurret]'          : lang_Key2StrVar:= @g_aids[uab_ToUAGTurret      ].ua_str_Descript;
   'str_dscr[uab_ToUAATurret]'          : lang_Key2StrVar:= @g_aids[uab_ToUAATurret      ].ua_str_Descript;
   'str_dscr[uab_ToUACDron]'            : lang_Key2StrVar:= @g_aids[uab_ToUACDron        ].ua_str_Descript;
   'str_dscr[uab_ToUGTurretTo]'         : lang_Key2StrVar:= @g_aids[uab_ToUGTurretTo     ].ua_str_Descript;
   'str_dscr[uab_ToUATurretTo]'         : lang_Key2StrVar:= @g_aids[uab_ToUATurretTo     ].ua_str_Descript;
   'str_dscr[uab_LvlUpURadar]'          : lang_Key2StrVar:= @g_aids[uab_LvlUpURadar      ].ua_str_Descript;
   'str_dscr[uab_LvlUpURMStation]'      : lang_Key2StrVar:= @g_aids[uab_LvlUpURMStation  ].ua_str_Descript;

   'str_dscr[uab_HSpecter]'             : lang_Key2StrVar:= @g_aids[uab_HSpecter         ].ua_str_Descript;
   'str_dscr[uab_HStealth]'             : lang_Key2StrVar:= @g_aids[uab_HStealth         ].ua_str_Descript;
   'str_dscr[uab_HHTShroud]'            : lang_Key2StrVar:= @g_aids[uab_HHTShroud        ].ua_str_Descript;
   'str_dscr[uab_HT2TNoCD]'             : lang_Key2StrVar:= @g_aids[uab_HT2TNoCD         ].ua_str_Descript;
   'str_dscr[uab_UAASplash]'            : lang_Key2StrVar:= @g_aids[uab_UAASplash        ].ua_str_Descript;

   // UNITS

   'str_name[UID_HKeep]'                : lang_Key2StrVar:= @g_uids[UID_HKeep            ].uid_str_name;
   'str_dscr[UID_HKeep]'                : lang_Key2StrVar:= @g_uids[UID_HKeep            ].uid_str_BaseDescript;
   'str_name[UID_HAKeep]'               : lang_Key2StrVar:= @g_uids[UID_HAKeep           ].uid_str_name;
   'str_dscr[UID_HAKeep]'               : lang_Key2StrVar:= @g_uids[UID_HAKeep           ].uid_str_BaseDescript;
   'str_name[UID_HGate]'                : lang_Key2StrVar:= @g_uids[UID_HGate            ].uid_str_name;
   'str_dscr[UID_HGate]'                : lang_Key2StrVar:= @g_uids[UID_HGate            ].uid_str_BaseDescript;
   'str_name[UID_HPools]'               : lang_Key2StrVar:= @g_uids[UID_HPools           ].uid_str_name;
   'str_dscr[UID_HPools]'               : lang_Key2StrVar:= @g_uids[UID_HPools           ].uid_str_BaseDescript;
   'str_name[UID_HPentagram]'           : lang_Key2StrVar:= @g_uids[UID_HPentagram       ].uid_str_name;
   'str_dscr[UID_HPentagram]'           : lang_Key2StrVar:= @g_uids[UID_HPentagram       ].uid_str_BaseDescript;
   'str_name[UID_HMonastery]'           : lang_Key2StrVar:= @g_uids[UID_HMonastery       ].uid_str_name;
   'str_dscr[UID_HMonastery]'           : lang_Key2StrVar:= @g_uids[UID_HMonastery       ].uid_str_BaseDescript;
   'str_name[UID_HFortress]'            : lang_Key2StrVar:= @g_uids[UID_HFortress        ].uid_str_name;
   'str_dscr[UID_HFortress]'            : lang_Key2StrVar:= @g_uids[UID_HFortress        ].uid_str_BaseDescript;
   'str_name[UID_HFTower]'              : lang_Key2StrVar:= @g_uids[UID_HFTower          ].uid_str_name;
   'str_dscr[UID_HFTower]'              : lang_Key2StrVar:= @g_uids[UID_HFTower          ].uid_str_BaseDescript;
   'str_name[UID_HTotem]'               : lang_Key2StrVar:= @g_uids[UID_HTotem           ].uid_str_name;
   'str_dscr[UID_HTotem]'               : lang_Key2StrVar:= @g_uids[UID_HTotem           ].uid_str_BaseDescript;
   'str_name[UID_HEyeNest]'             : lang_Key2StrVar:= @g_uids[UID_HEyeNest         ].uid_str_name;
   'str_dscr[UID_HEyeNest]'             : lang_Key2StrVar:= @g_uids[UID_HEyeNest         ].uid_str_BaseDescript;
   'str_name[UID_HEye]'                 : lang_Key2StrVar:= @g_uids[UID_HEye             ].uid_str_name;
   'str_dscr[UID_HEye]'                 : lang_Key2StrVar:= @g_uids[UID_HEye             ].uid_str_BaseDescript;
   'str_name[UID_HTeleport]'            : lang_Key2StrVar:= @g_uids[UID_HTeleport        ].uid_str_name;
   'str_dscr[UID_HTeleport]'            : lang_Key2StrVar:= @g_uids[UID_HTeleport        ].uid_str_BaseDescript;
   'str_name[UID_HAltar]'               : lang_Key2StrVar:= @g_uids[UID_HAltar           ].uid_str_name;
   'str_dscr[UID_HAltar]'               : lang_Key2StrVar:= @g_uids[UID_HAltar           ].uid_str_BaseDescript;
   'str_name[UID_HCommandCenter]'       : lang_Key2StrVar:= @g_uids[UID_HCommandCenter   ].uid_str_name;
   'str_dscr[UID_HCommandCenter]'       : lang_Key2StrVar:= @g_uids[UID_HCommandCenter   ].uid_str_BaseDescript;
   'str_name[UID_HACommandCenter]'      : lang_Key2StrVar:= @g_uids[UID_HACommandCenter  ].uid_str_name;
   'str_dscr[UID_HACommandCenter]'      : lang_Key2StrVar:= @g_uids[UID_HACommandCenter  ].uid_str_BaseDescript;
   'str_name[UID_HBarracks]'            : lang_Key2StrVar:= @g_uids[UID_HBarracks        ].uid_str_name;
   'str_dscr[UID_HBarracks]'            : lang_Key2StrVar:= @g_uids[UID_HBarracks        ].uid_str_BaseDescript;
   'str_name[UID_HMarker]'              : lang_Key2StrVar:= @g_uids[UID_HMarker          ].uid_str_name;
   'str_dscr[UID_HMarker]'              : lang_Key2StrVar:= @g_uids[UID_HMarker          ].uid_str_BaseDescript;
   'str_name[UID_LostSoul]'             : lang_Key2StrVar:= @g_uids[UID_LostSoul         ].uid_str_name;
   'str_dscr[UID_LostSoul]'             : lang_Key2StrVar:= @g_uids[UID_LostSoul         ].uid_str_BaseDescript;
   'str_name[UID_Phantom]'              : lang_Key2StrVar:= @g_uids[UID_Phantom          ].uid_str_name;
   'str_dscr[UID_Phantom]'              : lang_Key2StrVar:= @g_uids[UID_Phantom          ].uid_str_BaseDescript;
   'str_name[UID_Imp]'                  : lang_Key2StrVar:= @g_uids[UID_Imp              ].uid_str_name;
   'str_dscr[UID_Imp]'                  : lang_Key2StrVar:= @g_uids[UID_Imp              ].uid_str_BaseDescript;
   'str_name[UID_Demon]'                : lang_Key2StrVar:= @g_uids[UID_Demon            ].uid_str_name;
   'str_dscr[UID_Demon]'                : lang_Key2StrVar:= @g_uids[UID_Demon            ].uid_str_BaseDescript;
   'str_name[UID_Cacodemon]'            : lang_Key2StrVar:= @g_uids[UID_Cacodemon        ].uid_str_name;
   'str_dscr[UID_Cacodemon]'            : lang_Key2StrVar:= @g_uids[UID_Cacodemon        ].uid_str_BaseDescript;
   'str_name[UID_Knight]'               : lang_Key2StrVar:= @g_uids[UID_Knight           ].uid_str_name;
   'str_dscr[UID_Knight]'               : lang_Key2StrVar:= @g_uids[UID_Knight           ].uid_str_BaseDescript;
   'str_name[UID_Baron]'                : lang_Key2StrVar:= @g_uids[UID_Baron            ].uid_str_name;
   'str_dscr[UID_Baron]'                : lang_Key2StrVar:= @g_uids[UID_Baron            ].uid_str_BaseDescript;
   'str_name[UID_Cyberdemon]'           : lang_Key2StrVar:= @g_uids[UID_Cyberdemon       ].uid_str_name;
   'str_dscr[UID_Cyberdemon]'           : lang_Key2StrVar:= @g_uids[UID_Cyberdemon       ].uid_str_BaseDescript;
   'str_name[UID_Mastermind]'           : lang_Key2StrVar:= @g_uids[UID_Mastermind       ].uid_str_name;
   'str_dscr[UID_Mastermind]'           : lang_Key2StrVar:= @g_uids[UID_Mastermind       ].uid_str_BaseDescript;
   'str_name[UID_Pain]'                 : lang_Key2StrVar:= @g_uids[UID_Pain             ].uid_str_name;
   'str_dscr[UID_Pain]'                 : lang_Key2StrVar:= @g_uids[UID_Pain             ].uid_str_BaseDescript;
   'str_name[UID_Revenant]'             : lang_Key2StrVar:= @g_uids[UID_Revenant         ].uid_str_name;
   'str_dscr[UID_Revenant]'             : lang_Key2StrVar:= @g_uids[UID_Revenant         ].uid_str_BaseDescript;
   'str_name[UID_Mancubus]'             : lang_Key2StrVar:= @g_uids[UID_Mancubus         ].uid_str_name;
   'str_dscr[UID_Mancubus]'             : lang_Key2StrVar:= @g_uids[UID_Mancubus         ].uid_str_BaseDescript;
   'str_name[UID_Arachnotron]'          : lang_Key2StrVar:= @g_uids[UID_Arachnotron      ].uid_str_name;
   'str_dscr[UID_Arachnotron]'          : lang_Key2StrVar:= @g_uids[UID_Arachnotron      ].uid_str_BaseDescript;
   'str_name[UID_Archvile]'             : lang_Key2StrVar:= @g_uids[UID_Archvile         ].uid_str_name;
   'str_dscr[UID_Archvile]'             : lang_Key2StrVar:= @g_uids[UID_Archvile         ].uid_str_BaseDescript;
   'str_name[UID_ZMedic]'               : lang_Key2StrVar:= @g_uids[UID_ZMedic           ].uid_str_name;
   'str_dscr[UID_ZMedic]'               : lang_Key2StrVar:= @g_uids[UID_ZMedic           ].uid_str_BaseDescript;
   'str_name[UID_ZEngineer]'            : lang_Key2StrVar:= @g_uids[UID_ZEngineer        ].uid_str_name;
   'str_dscr[UID_ZEngineer]'            : lang_Key2StrVar:= @g_uids[UID_ZEngineer        ].uid_str_BaseDescript;
   'str_name[UID_ZSergant]'             : lang_Key2StrVar:= @g_uids[UID_ZSergant         ].uid_str_name;
   'str_dscr[UID_ZSergant]'             : lang_Key2StrVar:= @g_uids[UID_ZSergant         ].uid_str_BaseDescript;
   'str_name[UID_ZSSergant]'            : lang_Key2StrVar:= @g_uids[UID_ZSSergant        ].uid_str_name;
   'str_dscr[UID_ZSSergant]'            : lang_Key2StrVar:= @g_uids[UID_ZSSergant        ].uid_str_BaseDescript;
   'str_name[UID_ZCommando]'            : lang_Key2StrVar:= @g_uids[UID_ZCommando        ].uid_str_name;
   'str_dscr[UID_ZCommando]'            : lang_Key2StrVar:= @g_uids[UID_ZCommando        ].uid_str_BaseDescript;
   'str_name[UID_ZAntiaircrafter]'      : lang_Key2StrVar:= @g_uids[UID_ZAntiaircrafter  ].uid_str_name;
   'str_dscr[UID_ZAntiaircrafter]'      : lang_Key2StrVar:= @g_uids[UID_ZAntiaircrafter  ].uid_str_BaseDescript;
   'str_name[UID_ZSiegeMarine]'         : lang_Key2StrVar:= @g_uids[UID_ZSiegeMarine     ].uid_str_name;
   'str_dscr[UID_ZSiegeMarine]'         : lang_Key2StrVar:= @g_uids[UID_ZSiegeMarine     ].uid_str_BaseDescript;
   'str_name[UID_ZFPlasmagunner]'       : lang_Key2StrVar:= @g_uids[UID_ZFPlasmagunner   ].uid_str_name;
   'str_dscr[UID_ZFPlasmagunner]'       : lang_Key2StrVar:= @g_uids[UID_ZFPlasmagunner   ].uid_str_BaseDescript;
   'str_name[UID_ZBFGMarine]'           : lang_Key2StrVar:= @g_uids[UID_ZBFGMarine       ].uid_str_name;
   'str_dscr[UID_ZBFGMarine]'           : lang_Key2StrVar:= @g_uids[UID_ZBFGMarine       ].uid_str_BaseDescript;
   'str_name[UID_UCommandCenter]'       : lang_Key2StrVar:= @g_uids[UID_UCommandCenter   ].uid_str_name;
   'str_dscr[UID_UCommandCenter]'       : lang_Key2StrVar:= @g_uids[UID_UCommandCenter   ].uid_str_BaseDescript;
   'str_name[UID_UACommandCenter]'      : lang_Key2StrVar:= @g_uids[UID_UACommandCenter  ].uid_str_name;
   'str_dscr[UID_UACommandCenter]'      : lang_Key2StrVar:= @g_uids[UID_UACommandCenter  ].uid_str_BaseDescript;
   'str_name[UID_UBarracks]'            : lang_Key2StrVar:= @g_uids[UID_UBarracks        ].uid_str_name;
   'str_dscr[UID_UBarracks]'            : lang_Key2StrVar:= @g_uids[UID_UBarracks        ].uid_str_BaseDescript;
   'str_name[UID_UFactory]'             : lang_Key2StrVar:= @g_uids[UID_UFactory         ].uid_str_name;
   'str_dscr[UID_UFactory]'             : lang_Key2StrVar:= @g_uids[UID_UFactory         ].uid_str_BaseDescript;
   'str_name[UID_UWeaponFactory]'       : lang_Key2StrVar:= @g_uids[UID_UWeaponFactory   ].uid_str_name;
   'str_dscr[UID_UWeaponFactory]'       : lang_Key2StrVar:= @g_uids[UID_UWeaponFactory   ].uid_str_BaseDescript;
   'str_name[UID_UGTurret]'             : lang_Key2StrVar:= @g_uids[UID_UGTurret         ].uid_str_name;
   'str_dscr[UID_UGTurret]'             : lang_Key2StrVar:= @g_uids[UID_UGTurret         ].uid_str_BaseDescript;
   'str_name[UID_UATurret]'             : lang_Key2StrVar:= @g_uids[UID_UATurret         ].uid_str_name;
   'str_dscr[UID_UATurret]'             : lang_Key2StrVar:= @g_uids[UID_UATurret         ].uid_str_BaseDescript;
   'str_name[UID_UScienceCenter]'       : lang_Key2StrVar:= @g_uids[UID_UScienceCenter   ].uid_str_name;
   'str_dscr[UID_UScienceCenter]'       : lang_Key2StrVar:= @g_uids[UID_UScienceCenter   ].uid_str_BaseDescript;
   'str_name[UID_UComputerStation]'     : lang_Key2StrVar:= @g_uids[UID_UComputerStation ].uid_str_name;
   'str_dscr[UID_UComputerStation]'     : lang_Key2StrVar:= @g_uids[UID_UComputerStation ].uid_str_BaseDescript;
   'str_name[UID_URadar]'               : lang_Key2StrVar:= @g_uids[UID_URadar           ].uid_str_name;
   'str_dscr[UID_URadar]'               : lang_Key2StrVar:= @g_uids[UID_URadar           ].uid_str_BaseDescript;
   'str_name[UID_UAcademy]'             : lang_Key2StrVar:= @g_uids[UID_UAcademy         ].uid_str_name;
   'str_dscr[UID_UAcademy]'             : lang_Key2StrVar:= @g_uids[UID_UAcademy         ].uid_str_BaseDescript;
   'str_name[UID_UHPowerConductor]'     : lang_Key2StrVar:= @g_uids[UID_UHPowerConductor ].uid_str_name;
   'str_dscr[UID_UHPowerConductor]'     : lang_Key2StrVar:= @g_uids[UID_UHPowerConductor ].uid_str_BaseDescript;
   'str_name[UID_URMStation]'           : lang_Key2StrVar:= @g_uids[UID_URMStation       ].uid_str_name;
   'str_dscr[UID_URMStation]'           : lang_Key2StrVar:= @g_uids[UID_URMStation       ].uid_str_BaseDescript;
   'str_name[UID_Sergant]'              : lang_Key2StrVar:= @g_uids[UID_Sergant          ].uid_str_name;
   'str_dscr[UID_Sergant]'              : lang_Key2StrVar:= @g_uids[UID_Sergant          ].uid_str_BaseDescript;
   'str_name[UID_SSergant]'             : lang_Key2StrVar:= @g_uids[UID_SSergant         ].uid_str_name;
   'str_dscr[UID_SSergant]'             : lang_Key2StrVar:= @g_uids[UID_SSergant         ].uid_str_BaseDescript;
   'str_name[UID_Commando]'             : lang_Key2StrVar:= @g_uids[UID_Commando         ].uid_str_name;
   'str_dscr[UID_Commando]'             : lang_Key2StrVar:= @g_uids[UID_Commando         ].uid_str_BaseDescript;
   'str_name[UID_Antiaircrafter]'       : lang_Key2StrVar:= @g_uids[UID_Antiaircrafter   ].uid_str_name;
   'str_dscr[UID_Antiaircrafter]'       : lang_Key2StrVar:= @g_uids[UID_Antiaircrafter   ].uid_str_BaseDescript;
   'str_name[UID_SiegeMarine]'          : lang_Key2StrVar:= @g_uids[UID_SiegeMarine      ].uid_str_name;
   'str_dscr[UID_SiegeMarine]'          : lang_Key2StrVar:= @g_uids[UID_SiegeMarine      ].uid_str_BaseDescript;
   'str_name[UID_FPlasmagunner]'        : lang_Key2StrVar:= @g_uids[UID_FPlasmagunner    ].uid_str_name;
   'str_dscr[UID_FPlasmagunner]'        : lang_Key2StrVar:= @g_uids[UID_FPlasmagunner    ].uid_str_BaseDescript;
   'str_name[UID_BFGMarine]'            : lang_Key2StrVar:= @g_uids[UID_BFGMarine        ].uid_str_name;
   'str_dscr[UID_BFGMarine]'            : lang_Key2StrVar:= @g_uids[UID_BFGMarine        ].uid_str_BaseDescript;
   'str_name[UID_Engineer]'             : lang_Key2StrVar:= @g_uids[UID_Engineer         ].uid_str_name;
   'str_dscr[UID_Engineer]'             : lang_Key2StrVar:= @g_uids[UID_Engineer         ].uid_str_BaseDescript;
   'str_name[UID_Medic]'                : lang_Key2StrVar:= @g_uids[UID_Medic            ].uid_str_name;
   'str_dscr[UID_Medic]'                : lang_Key2StrVar:= @g_uids[UID_Medic            ].uid_str_BaseDescript;
   'str_name[UID_UTransport]'           : lang_Key2StrVar:= @g_uids[UID_UTransport       ].uid_str_name;
   'str_dscr[UID_UTransport]'           : lang_Key2StrVar:= @g_uids[UID_UTransport       ].uid_str_BaseDescript;
   'str_name[UID_UACDron]'              : lang_Key2StrVar:= @g_uids[UID_UACDron          ].uid_str_name;
   'str_dscr[UID_UACDron]'              : lang_Key2StrVar:= @g_uids[UID_UACDron          ].uid_str_BaseDescript;
   'str_name[UID_Terminator]'           : lang_Key2StrVar:= @g_uids[UID_Terminator       ].uid_str_name;
   'str_dscr[UID_Terminator]'           : lang_Key2StrVar:= @g_uids[UID_Terminator       ].uid_str_BaseDescript;
   'str_name[UID_Tank]'                 : lang_Key2StrVar:= @g_uids[UID_Tank             ].uid_str_name;
   'str_dscr[UID_Tank]'                 : lang_Key2StrVar:= @g_uids[UID_Tank             ].uid_str_BaseDescript;
   'str_name[UID_Flyer]'                : lang_Key2StrVar:= @g_uids[UID_Flyer            ].uid_str_name;
   'str_dscr[UID_Flyer]'                : lang_Key2StrVar:= @g_uids[UID_Flyer            ].uid_str_BaseDescript;

   // UPGRADES

   'str_name[upgr_hell_DistDamage1]'    : lang_Key2StrVar:= @g_upgrs[upgr_hell_DistDamage1 ].upgr_str_Name;
   'str_dscr[upgr_hell_DistDamage1]'    : lang_Key2StrVar:= @g_upgrs[upgr_hell_DistDamage1 ].upgr_str_Descript;
   'str_name[upgr_hell_UnitArmor]'      : lang_Key2StrVar:= @g_upgrs[upgr_hell_UnitArmor   ].upgr_str_Name;
   'str_dscr[upgr_hell_UnitArmor]'      : lang_Key2StrVar:= @g_upgrs[upgr_hell_UnitArmor   ].upgr_str_Descript;
   'str_name[upgr_hell_BuildArmor]'     : lang_Key2StrVar:= @g_upgrs[upgr_hell_BuildArmor  ].upgr_str_Name;
   'str_dscr[upgr_hell_BuildArmor]'     : lang_Key2StrVar:= @g_upgrs[upgr_hell_BuildArmor  ].upgr_str_Descript;
   'str_name[upgr_hell_MeleeDamage]'    : lang_Key2StrVar:= @g_upgrs[upgr_hell_MeleeDamage ].upgr_str_Name;
   'str_dscr[upgr_hell_MeleeDamage]'    : lang_Key2StrVar:= @g_upgrs[upgr_hell_MeleeDamage ].upgr_str_Descript;
   'str_name[upgr_hell_Regeneration]'   : lang_Key2StrVar:= @g_upgrs[upgr_hell_Regeneration].upgr_str_Name;
   'str_dscr[upgr_hell_Regeneration]'   : lang_Key2StrVar:= @g_upgrs[upgr_hell_Regeneration].upgr_str_Descript;
   'str_name[upgr_hell_PainFactor]'     : lang_Key2StrVar:= @g_upgrs[upgr_hell_PainFactor  ].upgr_str_Name;
   'str_dscr[upgr_hell_PainFactor]'     : lang_Key2StrVar:= @g_upgrs[upgr_hell_PainFactor  ].upgr_str_Descript;
   'str_name[upgr_hell_ADetection]'     : lang_Key2StrVar:= @g_upgrs[upgr_hell_ADetection  ].upgr_str_Name;
   'str_dscr[upgr_hell_ADetection]'     : lang_Key2StrVar:= @g_upgrs[upgr_hell_ADetection  ].upgr_str_Descript;
   'str_name[upgr_hell_HKeepShift]'     : lang_Key2StrVar:= @g_upgrs[upgr_hell_HKeepShift  ].upgr_str_Name;
   'str_dscr[upgr_hell_HKeepShift]'     : lang_Key2StrVar:= @g_upgrs[upgr_hell_HKeepShift  ].upgr_str_Descript;
   'str_name[upgr_hell_DecayAura]'      : lang_Key2StrVar:= @g_upgrs[upgr_hell_DecayAura   ].upgr_str_Name;
   'str_dscr[upgr_hell_DecayAura]'      : lang_Key2StrVar:= @g_upgrs[upgr_hell_DecayAura   ].upgr_str_Descript;
   'str_name[upgr_hell_BuilderR]'       : lang_Key2StrVar:= @g_upgrs[upgr_hell_BuilderR    ].upgr_str_Name;
   'str_dscr[upgr_hell_BuilderR]'       : lang_Key2StrVar:= @g_upgrs[upgr_hell_BuilderR    ].upgr_str_Descript;
   'str_name[upgr_hell_Spectre]'        : lang_Key2StrVar:= @g_upgrs[upgr_hell_Spectre     ].upgr_str_Name;
   'str_dscr[upgr_hell_Spectre]'        : lang_Key2StrVar:= @g_upgrs[upgr_hell_Spectre     ].upgr_str_Descript;
   'str_name[upgr_hell_UnitSightR]'     : lang_Key2StrVar:= @g_upgrs[upgr_hell_UnitSightR  ].upgr_str_Name;
   'str_dscr[upgr_hell_UnitSightR]'     : lang_Key2StrVar:= @g_upgrs[upgr_hell_UnitSightR  ].upgr_str_Descript;
   'str_name[upgr_hell_Phantoms]'       : lang_Key2StrVar:= @g_upgrs[upgr_hell_Phantoms    ].upgr_str_Name;
   'str_dscr[upgr_hell_Phantoms]'       : lang_Key2StrVar:= @g_upgrs[upgr_hell_Phantoms    ].upgr_str_Descript;
   'str_name[upgr_hell_DistDamage2]'    : lang_Key2StrVar:= @g_upgrs[upgr_hell_DistDamage2 ].upgr_str_Name;
   'str_dscr[upgr_hell_DistDamage2]'    : lang_Key2StrVar:= @g_upgrs[upgr_hell_DistDamage2 ].upgr_str_Descript;
   'str_name[upgr_hell_TeleportCD]'     : lang_Key2StrVar:= @g_upgrs[upgr_hell_TeleportCD  ].upgr_str_Name;
   'str_dscr[upgr_hell_TeleportCD]'     : lang_Key2StrVar:= @g_upgrs[upgr_hell_TeleportCD  ].upgr_str_Descript;
   'str_name[upgr_hell_T2TNoCD]'        : lang_Key2StrVar:= @g_upgrs[upgr_hell_T2TNoCD     ].upgr_str_Name;
   'str_dscr[upgr_hell_T2TNoCD]'        : lang_Key2StrVar:= @g_upgrs[upgr_hell_T2TNoCD     ].upgr_str_Descript;
   'str_name[upgr_hell_EvilEyeR]'       : lang_Key2StrVar:= @g_upgrs[upgr_hell_EvilEyeR    ].upgr_str_Name;
   'str_dscr[upgr_hell_EvilEyeR]'       : lang_Key2StrVar:= @g_upgrs[upgr_hell_EvilEyeR    ].upgr_str_Descript;
   'str_name[upgr_hell_TotemInvis]'     : lang_Key2StrVar:= @g_upgrs[upgr_hell_TotemInvis  ].upgr_str_Name;
   'str_dscr[upgr_hell_TotemInvis]'     : lang_Key2StrVar:= @g_upgrs[upgr_hell_TotemInvis  ].upgr_str_Descript;
   'str_name[upgr_hell_BuildRestore]'   : lang_Key2StrVar:= @g_upgrs[upgr_hell_BuildRestore].upgr_str_Name;
   'str_dscr[upgr_hell_BuildRestore]'   : lang_Key2StrVar:= @g_upgrs[upgr_hell_BuildRestore].upgr_str_Descript;
   'str_name[upgr_hell_TowerR]'         : lang_Key2StrVar:= @g_upgrs[upgr_hell_TowerR      ].upgr_str_Name;
   'str_dscr[upgr_hell_TowerR]'         : lang_Key2StrVar:= @g_upgrs[upgr_hell_TowerR      ].upgr_str_Descript;
   'str_name[upgr_hell_TowerBlink]'     : lang_Key2StrVar:= @g_upgrs[upgr_hell_TowerBlink  ].upgr_str_Name;
   'str_dscr[upgr_hell_TowerBlink]'     : lang_Key2StrVar:= @g_upgrs[upgr_hell_TowerBlink  ].upgr_str_Descript;
   'str_name[upgr_hell_Resurrect]'      : lang_Key2StrVar:= @g_upgrs[upgr_hell_Resurrect   ].upgr_str_Name;
   'str_dscr[upgr_hell_Resurrect]'      : lang_Key2StrVar:= @g_upgrs[upgr_hell_Resurrect   ].upgr_str_Descript;
   'str_name[upgr_hell_FTowerAMech]'    : lang_Key2StrVar:= @g_upgrs[upgr_hell_FTowerAMech ].upgr_str_Name;
   'str_dscr[upgr_hell_FTowerAMech]'    : lang_Key2StrVar:= @g_upgrs[upgr_hell_FTowerAMech ].upgr_str_Descript;
   'str_name[upgr_uac_DistDamage]'      : lang_Key2StrVar:= @g_upgrs[upgr_uac_DistDamage   ].upgr_str_Name;
   'str_dscr[upgr_uac_DistDamage]'      : lang_Key2StrVar:= @g_upgrs[upgr_uac_DistDamage   ].upgr_str_Descript;
   'str_name[upgr_uac_BioArmor]'        : lang_Key2StrVar:= @g_upgrs[upgr_uac_BioArmor     ].upgr_str_Name;
   'str_dscr[upgr_uac_BioArmor]'        : lang_Key2StrVar:= @g_upgrs[upgr_uac_BioArmor     ].upgr_str_Descript;
   'str_name[upgr_uac_BuildArmor]'      : lang_Key2StrVar:= @g_upgrs[upgr_uac_BuildArmor   ].upgr_str_Name;
   'str_dscr[upgr_uac_BuildArmor]'      : lang_Key2StrVar:= @g_upgrs[upgr_uac_BuildArmor   ].upgr_str_Descript;
   'str_name[upgr_uac_RepairTools]'     : lang_Key2StrVar:= @g_upgrs[upgr_uac_RepairTools  ].upgr_str_Name;
   'str_dscr[upgr_uac_RepairTools]'     : lang_Key2StrVar:= @g_upgrs[upgr_uac_RepairTools  ].upgr_str_Descript;
   'str_name[upgr_uac_BioSpeed]'        : lang_Key2StrVar:= @g_upgrs[upgr_uac_BioSpeed     ].upgr_str_Name;
   'str_dscr[upgr_uac_BioSpeed]'        : lang_Key2StrVar:= @g_upgrs[upgr_uac_BioSpeed     ].upgr_str_Descript;
   'str_name[upgr_uac_SSMWeapon]'       : lang_Key2StrVar:= @g_upgrs[upgr_uac_SSMWeapon    ].upgr_str_Name;
   'str_dscr[upgr_uac_SSMWeapon]'       : lang_Key2StrVar:= @g_upgrs[upgr_uac_SSMWeapon    ].upgr_str_Descript;
   'str_name[upgr_uac_ADetection]'      : lang_Key2StrVar:= @g_upgrs[upgr_uac_ADetection   ].upgr_str_Name;
   'str_dscr[upgr_uac_ADetection]'      : lang_Key2StrVar:= @g_upgrs[upgr_uac_ADetection   ].upgr_str_Descript;
   'str_name[upgr_uac_CCFly]'           : lang_Key2StrVar:= @g_upgrs[upgr_uac_CCFly        ].upgr_str_Name;
   'str_dscr[upgr_uac_CCFly]'           : lang_Key2StrVar:= @g_upgrs[upgr_uac_CCFly        ].upgr_str_Descript;
   'str_name[upgr_uac_CCAttack]'        : lang_Key2StrVar:= @g_upgrs[upgr_uac_CCAttack     ].upgr_str_Name;
   'str_dscr[upgr_uac_CCAttack]'        : lang_Key2StrVar:= @g_upgrs[upgr_uac_CCAttack     ].upgr_str_Descript;
   'str_name[upgr_uac_BuilderR]'        : lang_Key2StrVar:= @g_upgrs[upgr_uac_BuilderR     ].upgr_str_Name;
   'str_dscr[upgr_uac_BuilderR]'        : lang_Key2StrVar:= @g_upgrs[upgr_uac_BuilderR     ].upgr_str_Descript;
   'str_name[upgr_uac_DronTurret]'      : lang_Key2StrVar:= @g_upgrs[upgr_uac_DronTurret   ].upgr_str_Name;
   'str_dscr[upgr_uac_DronTurret]'      : lang_Key2StrVar:= @g_upgrs[upgr_uac_DronTurret   ].upgr_str_Descript;
   'str_name[upgr_uac_UnitSightR]'      : lang_Key2StrVar:= @g_upgrs[upgr_uac_UnitSightR   ].upgr_str_Name;
   'str_dscr[upgr_uac_UnitSightR]'      : lang_Key2StrVar:= @g_upgrs[upgr_uac_UnitSightR   ].upgr_str_Descript;
   'str_name[upgr_uac_CommandoInvis]'   : lang_Key2StrVar:= @g_upgrs[upgr_uac_CommandoInvis].upgr_str_Name;
   'str_dscr[upgr_uac_CommandoInvis]'   : lang_Key2StrVar:= @g_upgrs[upgr_uac_CommandoInvis].upgr_str_Descript;
   'str_name[upgr_uac_AASplash]'        : lang_Key2StrVar:= @g_upgrs[upgr_uac_AASplash     ].upgr_str_Name;
   'str_dscr[upgr_uac_AASplash]'        : lang_Key2StrVar:= @g_upgrs[upgr_uac_AASplash     ].upgr_str_Descript;
   'str_name[upgr_uac_MechSpeed]'       : lang_Key2StrVar:= @g_upgrs[upgr_uac_MechSpeed    ].upgr_str_Name;
   'str_dscr[upgr_uac_MechSpeed]'       : lang_Key2StrVar:= @g_upgrs[upgr_uac_MechSpeed    ].upgr_str_Descript;
   'str_name[upgr_uac_MechArmor]'       : lang_Key2StrVar:= @g_upgrs[upgr_uac_MechArmor    ].upgr_str_Name;
   'str_dscr[upgr_uac_MechArmor]'       : lang_Key2StrVar:= @g_upgrs[upgr_uac_MechArmor    ].upgr_str_Descript;
   'str_name[upgr_uac_TerAAWeapon]'     : lang_Key2StrVar:= @g_upgrs[upgr_uac_TerAAWeapon  ].upgr_str_Name;
   'str_dscr[upgr_uac_TerAAWeapon]'     : lang_Key2StrVar:= @g_upgrs[upgr_uac_TerAAWeapon  ].upgr_str_Descript;
   'str_name[upgr_uac_Transport]'       : lang_Key2StrVar:= @g_upgrs[upgr_uac_Transport    ].upgr_str_Name;
   'str_dscr[upgr_uac_Transport]'       : lang_Key2StrVar:= @g_upgrs[upgr_uac_Transport    ].upgr_str_Descript;
   'str_name[upgr_uac_RadarR]'          : lang_Key2StrVar:= @g_upgrs[upgr_uac_RadarR       ].upgr_str_Name;
   'str_dscr[upgr_uac_RadarR]'          : lang_Key2StrVar:= @g_upgrs[upgr_uac_RadarR       ].upgr_str_Descript;
   'str_name[upgr_uac_TurretPlasma]'    : lang_Key2StrVar:= @g_upgrs[upgr_uac_TurretPlasma ].upgr_str_Name;
   'str_dscr[upgr_uac_TurretPlasma]'    : lang_Key2StrVar:= @g_upgrs[upgr_uac_TurretPlasma ].upgr_str_Descript;
   'str_name[upgr_uac_TowerR]'          : lang_Key2StrVar:= @g_upgrs[upgr_uac_TowerR       ].upgr_str_Name;
   'str_dscr[upgr_uac_TowerR]'          : lang_Key2StrVar:= @g_upgrs[upgr_uac_TowerR       ].upgr_str_Descript;
   'str_name[upgr_uac_TurretArmor]'     : lang_Key2StrVar:= @g_upgrs[upgr_uac_TurretArmor  ].upgr_str_Name;
   'str_dscr[upgr_uac_TurretArmor]'     : lang_Key2StrVar:= @g_upgrs[upgr_uac_TurretArmor  ].upgr_str_Descript;

   // iActs
   'str_dscr[iAct_Control_UAMove]'      : lang_Key2StrVar:= @str_action_hint[iAct_Control_UAMove];
   'str_dscr[iAct_Control_UAStop]'      : lang_Key2StrVar:= @str_action_hint[iAct_Control_UAStop];
   'str_dscr[iAct_Control_UAPatrol]'    : lang_Key2StrVar:= @str_action_hint[iAct_Control_UAPatrol];

   'str_dscr[iAct_Control_UMove]'       : lang_Key2StrVar:= @str_action_hint[iAct_Control_UMove];
   'str_dscr[iAct_Control_UStop]'       : lang_Key2StrVar:= @str_action_hint[iAct_Control_UStop];
   'str_dscr[iAct_Control_UPatrol]'     : lang_Key2StrVar:= @str_action_hint[iAct_Control_UPatrol];

   'str_dscr[iAct_Control_UProdCncl]'   : lang_Key2StrVar:= @str_action_hint[iAct_Control_UProdCncl];
   'str_dscr[iAct_Control_UDestroy]'    : lang_Key2StrVar:= @str_action_hint[iAct_Control_UDestroy];

   'str_dscr[iAct_Control_USelBase]'    : lang_Key2StrVar:= @str_action_hint[iAct_Control_USelBase];
   'str_dscr[iAct_Control_USelArmy]'    : lang_Key2StrVar:= @str_action_hint[iAct_Control_USelArmy];

   'str_dscr[iAct_Control_MarkLook]'    : lang_Key2StrVar:= @str_action_hint[iAct_Control_MarkLook];
   'str_dscr[iAct_Control_MarkAttack]'  : lang_Key2StrVar:= @str_action_hint[iAct_Control_MarkAttack];
   'str_dscr[iAct_Control_ScoreBoard]'  : lang_Key2StrVar:= @str_action_hint[iAct_Control_ScoreBoard];

   'str_dscr[iAct_InGamePause]'         : lang_Key2StrVar:= @str_action_hint[iAct_InGamePause];
   'str_dscr[iAct_InGameMenu]'          : lang_Key2StrVar:= @str_action_hint[iAct_InGameMenu];

   'str_dscr[iAct_Replay_Fast]'         : lang_Key2StrVar:= @str_action_hint[iAct_Replay_Fast];
   'str_dscr[iAct_Replay_Pause]'        : lang_Key2StrVar:= @str_action_hint[iAct_Replay_Pause];
   'str_dscr[iAct_Replay_Back2]'        : lang_Key2StrVar:= @str_action_hint[iAct_Replay_Back2];
   'str_dscr[iAct_Replay_Back10]'       : lang_Key2StrVar:= @str_action_hint[iAct_Replay_Back10];
   'str_dscr[iAct_Replay_Back60]'       : lang_Key2StrVar:= @str_action_hint[iAct_Replay_Back60];
   'str_dscr[iAct_Replay_Forward2]'     : lang_Key2StrVar:= @str_action_hint[iAct_Replay_Forward2];
   'str_dscr[iAct_Replay_Forward10]'    : lang_Key2StrVar:= @str_action_hint[iAct_Replay_Forward10];
   'str_dscr[iAct_Replay_Forward60]'    : lang_Key2StrVar:= @str_action_hint[iAct_Replay_Forward60];
   'str_dscr[iAct_Replay_POV]'          : lang_Key2StrVar:= @str_action_hint[iAct_Replay_POV];
   'str_dscr[iAct_Replay_Log]'          : lang_Key2StrVar:= @str_action_hint[iAct_Replay_Log];
   'str_dscr[iAct_Replay_Fog]'          : lang_Key2StrVar:= @str_action_hint[iAct_Replay_Fog];
   'str_dscr[iAct_Replay_PlayerAll]'    : lang_Key2StrVar:= @str_action_hint[iAct_Replay_PlayerAll];
   'str_dscr[iAct_Replay_Player0]'      : lang_Key2StrVar:= @str_action_hint[iAct_Replay_Player0];
   'str_dscr[iAct_Replay_Player1]'      : lang_Key2StrVar:= @str_action_hint[iAct_Replay_Player1];
   'str_dscr[iAct_Replay_Player2]'      : lang_Key2StrVar:= @str_action_hint[iAct_Replay_Player2];
   'str_dscr[iAct_Replay_Player3]'      : lang_Key2StrVar:= @str_action_hint[iAct_Replay_Player3];
   'str_dscr[iAct_Replay_Player4]'      : lang_Key2StrVar:= @str_action_hint[iAct_Replay_Player4];
   'str_dscr[iAct_Replay_Player5]'      : lang_Key2StrVar:= @str_action_hint[iAct_Replay_Player5];
   'str_dscr[iAct_Replay_Player6]'      : lang_Key2StrVar:= @str_action_hint[iAct_Replay_Player6];
   'str_dscr[iAct_Replay_Player7]'      : lang_Key2StrVar:= @str_action_hint[iAct_Replay_Player7];

   'str_dscr[iAct_Observer_Fog]'        : lang_Key2StrVar:= @str_action_hint[iAct_Observer_Fog];
   'str_dscr[iAct_Observer_POV]'        : lang_Key2StrVar:= @str_action_hint[iAct_Observer_POV];
   'str_dscr[iAct_Observer_PlayerAll]'  : lang_Key2StrVar:= @str_action_hint[iAct_Observer_PlayerAll];
   'str_dscr[iAct_Observer_Player0]'    : lang_Key2StrVar:= @str_action_hint[iAct_Observer_Player0];
   'str_dscr[iAct_Observer_Player1]'    : lang_Key2StrVar:= @str_action_hint[iAct_Observer_Player1];
   'str_dscr[iAct_Observer_Player2]'    : lang_Key2StrVar:= @str_action_hint[iAct_Observer_Player2];
   'str_dscr[iAct_Observer_Player3]'    : lang_Key2StrVar:= @str_action_hint[iAct_Observer_Player3];
   'str_dscr[iAct_Observer_Player4]'    : lang_Key2StrVar:= @str_action_hint[iAct_Observer_Player4];
   'str_dscr[iAct_Observer_Player5]'    : lang_Key2StrVar:= @str_action_hint[iAct_Observer_Player5];
   'str_dscr[iAct_Observer_Player6]'    : lang_Key2StrVar:= @str_action_hint[iAct_Observer_Player6];
   'str_dscr[iAct_Observer_Player7]'    : lang_Key2StrVar:= @str_action_hint[iAct_Observer_Player7];
   end;


   if(lang_Key2StrVar<>nil)then exit;

   for u:=1 to 255 do
   begin
      // abilities
      with g_aids[u] do
      begin
         if(key=('uab_'+b2s(u)+'_name'))then
         begin
            lang_Key2StrVar:=@ua_str_name;
            exit;
         end;
         if(key=('uab_'+b2s(u)+'_descr'))then
         begin
            lang_Key2StrVar:=@ua_str_Descript;
            exit;
         end;
      end;

      // units
      with g_uids[u] do
      begin
         if(key=('uid_'+b2s(u)+'_name'))then
         begin
            lang_Key2StrVar:=@uid_str_name;
            exit;
         end;
         if(key=('uid_'+b2s(u)+'_descr'))then
         begin
            lang_Key2StrVar:=@uid_str_BaseDescript;
            exit;
         end;
      end;

      // upgrades
      with g_upgrs[u] do
      begin
         if(key=('upgr_'+b2s(u)+'_name'))then
         begin
            lang_Key2StrVar:=@upgr_str_Name;
            exit;
         end;
         if(key=('upgr_'+b2s(u)+'_descr'))then
         begin
            lang_Key2StrVar:=@upgr_str_Descript;
            exit;
         end;
      end;

      // iActs
      if(key=('iAct_'+b2s(u)+'_hk'))then
      begin
         lang_Key2StrVar:=@input_actions[u].ik_str_HK;
         exit;
      end;
      if(key=('iAct_'+b2s(u)+'_descr'))then
      begin
         lang_Key2StrVar:=@str_action_name[u];
         exit;
      end;

      // menu
      if(key=('menu_'+b2s(u)+'_descr'))then
      begin
         lang_Key2StrVar:=@str_menu_hint[u];
         exit;
      end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure lang_Update;
var
f    :text;
t    :byte;
err  :word;
line :AnsiString;
lfile,
skey :shortstring;
svar :pshortstring;

procedure lang_RemoveQuotes(pstr:pshortstring);
begin
   if(length(pstr^)>0)and(pstr^[length(pstr^)]=#39)then delete(pstr^,length(pstr^),1);
   if(length(pstr^)>0)and(pstr^[1            ]=#39)then delete(pstr^,1            ,1);
end;

function lang_ParseLangLine(vl:shortstring):shortstring;
const replace_a = [rfReplaceAll,rfIgnoreCase];
var
i   :byte;
pstr:pshortstring;
begin
   lang_ParseLangLine:='';

   if(length(vl)=0)then exit;
   if(vl[1] in ['#','\'])then exit;

   i:=pos('+',vl);
   while(i>0)do
   begin
      lang_ParseLangLine+=lang_ParseLangLine(Trim(copy(vl,1,i-1)));
      delete(vl,1,i);

      i:=pos('+',vl);
   end;

   lang_RemoveQuotes(@vl);

   pstr:=lang_Key2StrVar(vl);
   if(pstr<>nil)then
     vl:=pstr^;

   vl:=StringReplace(vl,'tc_player0' ,tc_player0 ,replace_a);
   vl:=StringReplace(vl,'tc_player1' ,tc_player1 ,replace_a);
   vl:=StringReplace(vl,'tc_player2' ,tc_player2 ,replace_a);
   vl:=StringReplace(vl,'tc_player3' ,tc_player3 ,replace_a);
   vl:=StringReplace(vl,'tc_player4' ,tc_player4 ,replace_a);
   vl:=StringReplace(vl,'tc_player5' ,tc_player5 ,replace_a);
   vl:=StringReplace(vl,'tc_player6' ,tc_player6 ,replace_a);
   vl:=StringReplace(vl,'tc_player7' ,tc_player7 ,replace_a);
   vl:=StringReplace(vl,'tc_nl'      ,tc_nl1     ,replace_a);
   vl:=StringReplace(vl,'tc_docbr'   ,tc_docbr   ,replace_a);
   vl:=StringReplace(vl,'tc_doccpt'  ,tc_doccpt  ,replace_a);
   vl:=StringReplace(vl,'tc_doccnt'  ,tc_doccnt  ,replace_a);
   vl:=StringReplace(vl,'tc_purple'  ,tc_purple  ,replace_a);
   vl:=StringReplace(vl,'tc_red'     ,tc_red     ,replace_a);
   vl:=StringReplace(vl,'tc_orange'  ,tc_orange  ,replace_a);
   vl:=StringReplace(vl,'tc_yellow'  ,tc_yellow  ,replace_a);
   vl:=StringReplace(vl,'tc_lime'    ,tc_lime    ,replace_a);
   vl:=StringReplace(vl,'tc_aqua'    ,tc_aqua    ,replace_a);
   vl:=StringReplace(vl,'tc_blue'    ,tc_blue    ,replace_a);
   vl:=StringReplace(vl,'tc_gray'    ,tc_gray    ,replace_a);
   vl:=StringReplace(vl,'tc_white'   ,tc_white   ,replace_a);
   vl:=StringReplace(vl,'tc_green'   ,tc_green   ,replace_a);
   vl:=StringReplace(vl,'tc_dgray'   ,tc_dgray   ,replace_a);
   vl:=StringReplace(vl,'tc_default' ,tc_default ,replace_a);
   vl:=StringReplace(vl,'tc_RankUAC' ,tc_RankUAC ,replace_a);
   vl:=StringReplace(vl,'tc_RankHell',tc_RankHell,replace_a);

   vl:=StringReplace(vl,'str_gcaption'   ,str_gcaption    ,replace_a);
   vl:=StringReplace(vl,'str_version'    ,str_version     ,replace_a);
   vl:=StringReplace(vl,'fileExt_Scrshot',fileExt_Scrshot ,replace_a);

   vl:=StringReplace(vl,'str_HellPower_Max'           ,i2s(HellPower_Max)          ,replace_a);
   vl:=StringReplace(vl,'str_UACLoot_Max'             ,i2s(UACLoot_Max)            ,replace_a);
   vl:=StringReplace(vl,'str_testmode_HellPower'      ,i2s(testmode_HellPower)     ,replace_a);
   vl:=StringReplace(vl,'str_testmode_UACLoot'        ,i2s(testmode_UACLoot  )     ,replace_a);
   vl:=StringReplace(vl,'str_PlayerMaxBuilders'       ,i2s(PlayerMaxBuilders)      ,replace_a);
   vl:=StringReplace(vl,'str_detection_time_sec'      ,i2s(detection_time_sec)     ,replace_a);
   vl:=StringReplace(vl,'str_DecayAuraDamage'         ,i2s(DecayAuraDamage)        ,replace_a);
   vl:=StringReplace(vl,'str_soul_maxHeal'            ,i2s(soul_maxHeal)           ,replace_a);
   vl:=StringReplace(vl,'str_soul_time_sec'           ,i2s(soul_time_sec)          ,replace_a);
   vl:=StringReplace(vl,'str_invis_time_sec'          ,i2s(invis_time_sec)         ,replace_a);
   vl:=StringReplace(vl,'str_invuln_time_sec'         ,i2s(invis_time_sec)         ,replace_a);
   vl:=StringReplace(vl,'str_rdamage_time_sec'        ,i2s(rdamage_time_sec)       ,replace_a);
   vl:=StringReplace(vl,'str_ddamage_time_sec'        ,i2s(ddamage_time_sec)       ,replace_a);
   vl:=StringReplace(vl,'str_dturbo_time_sec'         ,i2s(dturbo_time_sec)        ,replace_a);
   vl:=StringReplace(vl,'str_UACGeneralsMax'          ,b2s(UACGeneralsMax)         ,replace_a);
   vl:=StringReplace(vl,'str_scirmish_MaxHAltar'      ,i2s(scirmish_MaxHAltar)     ,replace_a);
   vl:=StringReplace(vl,'str_scirmish_MaxLost'        ,i2s(scirmish_MaxLost)       ,replace_a);
   vl:=StringReplace(vl,'str_net_DefaultPort'         ,w2s(net_DefaultPort)        ,replace_a);
   vl:=StringReplace(vl,'str_keyPoint_CTime_KotH_Sec' ,i2s(keyPoint_CTime_KotH_Sec),replace_a);
   vl:=StringReplace(vl,'str_keyPoint_KotH_pause_sec' ,i2s(keyPoint_KotH_pause_sec),replace_a);
   vl:=StringReplace(vl,'str_keyPoint_CTime_Def_Sec'  ,i2s(keyPoint_CTime_Def_Sec) ,replace_a);
   vl:=StringReplace(vl,'str_keyPoint_mcN'            ,i2s(keyPoint_mcN)           ,replace_a);

   vl:=StringReplace(vl,'str_map_generators_EnergyO'  ,i2s(map_generators_EnergyO) ,replace_a);
   vl:=StringReplace(vl,'str_map_generators_EnergyS'  ,i2s(map_generators_EnergyS) ,replace_a);
   vl:=StringReplace(vl,'str_map_generators_LimitS'   ,limit2s(map_generators_LimitS,ul1),replace_a);
   vl:=StringReplace(vl,'str_map_generators_LimitO'   ,limit2s(map_generators_LimitO,ul1),replace_a);

   vl:=StringReplace(vl,'str_upgr_hell_DistDamage1_uids',str_UnitsNamesList(UIDsArmsImpactUpgr(upgr_hell_DistDamage1)),replace_a);
   vl:=StringReplace(vl,'str_upgr_hell_DistDamage2_uids',str_UnitsNamesList(UIDsArmsImpactUpgr(upgr_hell_DistDamage2)),replace_a);

   vl:=StringReplace(vl,'str_UnitsNamesList([UID_Medic,UID_Engineer])'   ,str_UnitsNamesList([UID_Medic,UID_Engineer])   ,replace_a);
   vl:=StringReplace(vl,'str_UnitsNamesList([UID_HKeep,UID_HAKeep])'     ,str_UnitsNamesList([UID_HKeep  ,UID_HAKeep])   ,replace_a);
   vl:=StringReplace(vl,'str_UnitsNamesList([UID_HFTower,UID_HTotem])'   ,str_UnitsNamesList([UID_HFTower,UID_HTotem])   ,replace_a);
   vl:=StringReplace(vl,'str_UnitsNamesList([UID_UATurret,UID_UGTurret])',str_UnitsNamesList([UID_UATurret,UID_UGTurret]),replace_a);
   vl:=StringReplace(vl,'str_UnitsNamesList([UID_UCommandCenter,UID_UACommandCenter])',str_UnitsNamesList([UID_UCommandCenter,UID_UACommandCenter]),replace_a);

   with g_mids[MID_UACStrike] do
   begin
      vl:=StringReplace(vl,'UACStrike_base_damage'  ,i2s(mid_base_damage)        ,replace_a);
      vl:=StringReplace(vl,'UACStrike_size'         ,i2s(mid_size)               ,replace_a);
      vl:=StringReplace(vl,'UACStrike_base_SplashR' ,i2s(mid_base_SplashR)       ,replace_a);
      vl:=StringReplace(vl,'UACStrike_dm_RSMShot'   ,str_DamageMod(dm_RSMShot)   ,replace_a);
      vl:=StringReplace(vl,'UACStrike_Revealing_sec',i2s(UACStrike_Revealing_sec),replace_a);
   end;

   // Game hotkeys

   vl:=StringReplace(vl,'HK_InGameChat'        ,DocHelp_GetHotKeys([iAct_InGameChat          ]),replace_a);
   vl:=StringReplace(vl,'HK_InGameChatAll'     ,DocHelp_GetHotKeys([iAct_InGameChatAll       ]),replace_a);
   vl:=StringReplace(vl,'HK_InGameChatAllies'  ,DocHelp_GetHotKeys([iAct_InGameChatAllies    ]),replace_a);
   vl:=StringReplace(vl,'HK_InGamePause'       ,DocHelp_GetHotKeys([iAct_InGamePause         ]),replace_a);
   vl:=StringReplace(vl,'HK_InGameMenu'        ,DocHelp_GetHotKeys([iAct_InGameMenu          ]),replace_a);
   vl:=StringReplace(vl,'HK_Tab'               ,DocHelp_GetHotKeys([iAct_Tab                 ]),replace_a);
   vl:=StringReplace(vl,'HK_ScreenShot'        ,DocHelp_GetHotKeys([iAct_ScreenShot          ]),replace_a);
   vl:=StringReplace(vl,'HK_ToggleWindowed'    ,DocHelp_GetHotKeys([iAct_ToggleWindowed      ]),replace_a);
   vl:=StringReplace(vl,'HK_LastEvent'         ,DocHelp_GetHotKeys([iAct_LastEvent           ]),replace_a);
   vl:=StringReplace(vl,'HK_USetGroups'        ,DocHelp_GetHotKeys([iAct_USetGroup1..
                                                                    iAct_USetGroup9          ]),replace_a);
   vl:=StringReplace(vl,'HK_USetGroup0'        ,DocHelp_GetHotKeys([iAct_USetGroup0          ]),replace_a);
   vl:=StringReplace(vl,'HK_UAddGroups'        ,DocHelp_GetHotKeys([iAct_UAddGroup1..
                                                                    iAct_UAddGroup9          ]),replace_a);
   vl:=StringReplace(vl,'HK_USelGroups'        ,DocHelp_GetHotKeys([iAct_USelGroup1..
                                                                    iAct_USelGroup9          ]),replace_a);
   vl:=StringReplace(vl,'HK_UASlGroups'        ,DocHelp_GetHotKeys([iAct_UASlGroup1..
                                                                    iAct_UASlGroup9          ]),replace_a);
   vl:=StringReplace(vl,'HK_Control_UAbility'  ,DocHelp_GetHotKeys([iAct_Control_UAbility1..
                                                                    iAct_Control_UAbility3   ]),replace_a);
   vl:=StringReplace(vl,'HK_Control_BaseMove'  ,DocHelp_GetHotKeys([iAct_Control_UMove,
                                                                    iAct_Control_UStop,
                                                                    iAct_Control_UPatrol,
                                                                    iAct_Control_UAMove,
                                                                    iAct_Control_UAStop,
                                                                    iAct_Control_UAPatrol    ]),replace_a);
   vl:=StringReplace(vl,'HK_Control_UProdCncl' ,DocHelp_GetHotKeys([iAct_Control_UProdCncl   ]),replace_a);
   vl:=StringReplace(vl,'HK_Control_UDestroy'  ,DocHelp_GetHotKeys([iAct_Control_UDestroy    ]),replace_a);
   vl:=StringReplace(vl,'HK_Control_USelBase'  ,DocHelp_GetHotKeys([iAct_Control_USelBase    ]),replace_a);
   vl:=StringReplace(vl,'HK_Control_USelArmy'  ,DocHelp_GetHotKeys([iAct_Control_USelArmy    ]),replace_a);
   vl:=StringReplace(vl,'HK_Control_MarkLook'  ,DocHelp_GetHotKeys([iAct_Control_MarkLook    ]),replace_a);
   vl:=StringReplace(vl,'HK_Control_MarkAttack',DocHelp_GetHotKeys([iAct_Control_MarkAttack  ]),replace_a);
   vl:=StringReplace(vl,'HK_Control_ScoreBoard',DocHelp_GetHotKeys([iAct_Control_ScoreBoard  ]),replace_a);
   vl:=StringReplace(vl,'HK_Control_ToggleRec' ,DocHelp_GetHotKeys([iAct_Control_ToggleRec   ]),replace_a);
   vl:=StringReplace(vl,'HK_TogglePlayersColor',DocHelp_GetHotKeys([iAct_TogglePlayersColor  ]),replace_a);
   vl:=StringReplace(vl,'HK_SProds'            ,DocHelp_GetHotKeys([iAct_SProd1..iAct_SProd24]),replace_a);
   vl:=StringReplace(vl,'HK_Alt'               ,DocHelp_GetHotKeys([iAct_Alt                 ]),replace_a);
   vl:=StringReplace(vl,'HK_Replay_Fast'       ,DocHelp_GetHotKeys([iAct_Replay_Fast         ]),replace_a);
   vl:=StringReplace(vl,'HK_Replay_Pause'      ,DocHelp_GetHotKeys([iAct_Replay_Pause        ]),replace_a);
   vl:=StringReplace(vl,'HK_Replay_Back60'     ,DocHelp_GetHotKeys([iAct_Replay_Back60       ]),replace_a);
   vl:=StringReplace(vl,'HK_Replay_Back10'     ,DocHelp_GetHotKeys([iAct_Replay_Back10       ]),replace_a);
   vl:=StringReplace(vl,'HK_Replay_Back2'      ,DocHelp_GetHotKeys([iAct_Replay_Back2        ]),replace_a);
   vl:=StringReplace(vl,'HK_Replay_Forward2'   ,DocHelp_GetHotKeys([iAct_Replay_Forward2     ]),replace_a);
   vl:=StringReplace(vl,'HK_Replay_Forward10'  ,DocHelp_GetHotKeys([iAct_Replay_Forward10    ]),replace_a);
   vl:=StringReplace(vl,'HK_Replay_Forward60'  ,DocHelp_GetHotKeys([iAct_Replay_Forward60    ]),replace_a);
   vl:=StringReplace(vl,'HK_Replay_POV'        ,DocHelp_GetHotKeys([iAct_Replay_POV          ]),replace_a);
   vl:=StringReplace(vl,'HK_Replay_Log'        ,DocHelp_GetHotKeys([iAct_Replay_Log          ]),replace_a);
   vl:=StringReplace(vl,'HK_Replay_Fog'        ,DocHelp_GetHotKeys([iAct_Replay_Fog          ]),replace_a);
   vl:=StringReplace(vl,'HK_Replay_PlayerAll'  ,DocHelp_GetHotKeys([iAct_Replay_PlayerAll    ]),replace_a);
   vl:=StringReplace(vl,'HK_Replay_Players'    ,DocHelp_GetHotKeys([iAct_Replay_Player0..
                                                                    iAct_Replay_Player7      ]),replace_a);
   vl:=StringReplace(vl,'HK_Observer_Fog'      ,DocHelp_GetHotKeys([iAct_Observer_Fog        ]),replace_a);
   vl:=StringReplace(vl,'HK_Observer_POV'      ,DocHelp_GetHotKeys([iAct_Observer_POV        ]),replace_a);
   vl:=StringReplace(vl,'HK_Observer_PlayerAll',DocHelp_GetHotKeys([iAct_Observer_PlayerAll  ]),replace_a);
   vl:=StringReplace(vl,'HK_Observer_Players'  ,DocHelp_GetHotKeys([iAct_Observer_Player0..
                                                                    iAct_Observer_Player7    ]),replace_a);
   vl:=StringReplace(vl,'HK_test_FastTime'     ,DocHelp_GetHotKeys([iAct_test_FastTime       ]),replace_a);
   vl:=StringReplace(vl,'HK_test_InstaProd'    ,DocHelp_GetHotKeys([iAct_test_InstaProd      ]),replace_a);
   vl:=StringReplace(vl,'HK_test_ToggleAI'     ,DocHelp_GetHotKeys([iAct_test_ToggleAI       ]),replace_a);
   vl:=StringReplace(vl,'HK_test_iddqd'        ,DocHelp_GetHotKeys([iAct_test_iddqd          ]),replace_a);
   vl:=StringReplace(vl,'HK_test_FogToggle'    ,DocHelp_GetHotKeys([iAct_test_FogToggle      ]),replace_a);
   vl:=StringReplace(vl,'HK_test_DrawToggle'   ,DocHelp_GetHotKeys([iAct_test_DrawToggle     ]),replace_a);
   vl:=StringReplace(vl,'HK_test_NullUpgrades' ,DocHelp_GetHotKeys([iAct_test_NullUpgrades   ]),replace_a);
   vl:=StringReplace(vl,'HK_test_BePlayers'    ,DocHelp_GetHotKeys([iAct_test_BePlayer0..
                                                                    iAct_test_BePlayer7      ]),replace_a);
   vl:=StringReplace(vl,'HK_test_AddHellPower' ,DocHelp_GetHotKeys([iAct_test_AddHellPower   ]),replace_a);
   vl:=StringReplace(vl,'HK_test_AddUACLoot'   ,DocHelp_GetHotKeys([iAct_test_AddUACLoot     ]),replace_a);


   if(pos('str_',vl)>0)then writeln('str_ "',vl,'"');
   if(pos('2s'  ,vl)>0)then writeln('2s "'  ,vl,'"');

   lang_ParseLangLine+=vl;
end;
function lang_SpecKey(key,aline:shortstring):boolean;
var i:byte;
begin
   lang_SpecKey:=true;

   case key of
   'BalanceHint_BFG'      : str_SetUnitBalanceHint([UID_BFGMarine,UID_ZBFGMarine],aline,'','',false);
   'BalanceHint_PainState': for i:=1 to 255 do
                              with g_uids[i] do
                                if(uid_r>0)and(uid_PainState_Base>0)then
                                  str_SetUnitBalanceHint([i],'',aline,'',false);
   'DocHelp_Credits'      : if(length(aline)>0)then DocHelp_AddCredits      (aline);
   'DocHelp_BaseControls' : if(length(aline)>0)then DocHelp_AddBaseControls (aline);
   'DocHelp_HotKeyAction' : if(length(aline)>0)then DocHelp_AddHotKeys      (aline);
   'DocHelp_GamUI'        : if(length(aline)>0)then DocHelp_AddGamUI        (aline);
   'DocHelp_BaseMechanics': if(length(aline)>0)then DocHelp_AddBaseMechanics(aline);
   'DocHelp_Other'        : if(length(aline)>0)then DocHelp_AddOther        (aline);

   'str_camp_1_miss_1_plot':if(length(aline)>0)then str_camp_MissTextAdd    (0,0,aline);
   'str_camp_1_miss_2_plot':if(length(aline)>0)then str_camp_MissTextAdd    (0,1,aline);
   'str_camp_1_miss_3_plot':if(length(aline)>0)then str_camp_MissTextAdd    (0,2,aline);
   'str_camp_1_miss_4_plot':if(length(aline)>0)then str_camp_MissTextAdd    (0,3,aline);
   'str_camp_1_miss_5_plot':if(length(aline)>0)then str_camp_MissTextAdd    (0,4,aline);

   else lang_SpecKey:=false;
   end;
end;

procedure lang_ParseLine;
var
vr,vl:shortstring;
i    :cardinal;
begin
   line:=Trim(line);
   if(length(line)>255)then setlength(line,255);
   lang_UTF82b1b(@line);

   vr:='';
   vl:='';
   i :=pos('=',line);
   if(i>0)then
   begin
      vr:=Trim(copy(line,1,i-1));
      delete(line,1,i);
      if(length(line)=255)then writeln('255 ',line);
      vl:=lang_ParseLangLine(Trim(line));
      skey:=vr;
      svar:=lang_Key2StrVar(vr);
      if(svar<>nil)
      then svar^:=vl
      else
        if(not lang_SpecKey(skey,vl))then
          if(length(vr)>0)then writeln('unknown ',vr);
   end
   else
   begin
      if(length(line)=255)then writeln('255 ',line);
      vl:=lang_ParseLangLine(Trim(line));
      if(length(vl)=0)then
      begin
         svar:=nil;
         skey:='';
      end;
      if(svar<>nil)
      then svar^+=vl
      else
        if(not lang_SpecKey(skey,vl))then
          if(length(vr)>0)then writeln('unknown ',vr);
   end;
end;

begin
   draw_LoadingScreen(@str_loading_lang,c_white);

   lfile:=folder_language+lang_Current;
   if(not FileExists(lfile))then exit;

   assign(f,lfile);
   {$I-}
   reset(f);
   {$I+}
   err:=ioresult;
   if(err<>0)then
   begin
      WriteLog('Error opening language file: '+w2s(err));
      exit;
   end;

   str_StringListClear(@str_doc_Credits);
   str_StringListClear(@str_doc_BaseControls);
   str_StringListClear(@str_doc_HotKeys);
   str_StringListClear(@str_doc_GameUI);
   str_StringListClear(@str_doc_BaseMechanics);
   str_StringListClear(@str_doc_Other);
   str_camps_clearPlot;

   str_SetUnitBalanceHint([0..255],'','','',true);
   svar:=nil;

   while not eof(f) do
   begin
      readln(f,line);
      lang_ParseLine;

      err:=ioresult;
      if(err<>0)then
      begin
         close(f);
         WriteLog('Error opening language file: '+w2s(err));
         exit;
      end;
   end;
   close(f);

   str_YesNoC[true ]:= tc_lime+str_YesNoG[true ]+tc_default;
   str_YesNoC[false]:= tc_red +str_YesNoG[false]+tc_default;
   str_SG_PlayersColorL[0]:=str_YesNoG[false];

   for t:=0 to mc_Last do
     str_fileinfo_ScenarioL[t]:=str_RemoveSpecChars(str_map_ScenarioL[t]);
   for t:=1 to 255 do
   begin
      str_EndDot(@g_aids [t].ua_str_Descript     );
      str_EndDot(@g_uids [t].uid_str_BaseDescript);
      str_EndDot(@g_upgrs[t].upgr_str_Descript   );
   end;

   str_makeAllHints;
   ui_ScoresRebuild:=true;

   DocHelp_AddCreditsMusic;
   DocHelp_AddCredits(tc_docbr);
end;



