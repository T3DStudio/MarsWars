{$IFDEF _FULLGAME}

function video_Init:boolean;
begin
   video_Init:=false;

   if(SDL_Init(SDL_INIT_VIDEO)<>0)then begin WriteSDLError; exit; end;

   NEW(vid_RECT);

   SDL_putenv('SDL_VIDEO_WINDOW_POS');
   SDL_putenv('SDL_VIDEO_CENTERED=1');
   SDL_ShowCursor(0);
   SDL_enableUNICODE(1);

   SDL_WM_SetCaption(@str_wcaption[1], nil );

   gfx_InitColors;
   vid_MakeScreen;
   draw_LoadingScreen(@str_loading_gfx,c_yellow);
   gfx_LoadAll;

   video_Init:=true;
end;

procedure StartParams;
var t,i:integer;
    s:string;
begin
   t:=ParamCount;
   if(t>0)then
     for i:=1 to t do
     begin
        s:=ParamStr(i);
        {$IFDEF TESTMODE}
        if(s='test' )then TestMode:=1;
        if(s='testD')then TestMode:=2;
        {$ENDIF}
     end;
end;

{$ELSE}

procedure StartParams;
var t:integer;
begin
   t:=ParamCount;
   net_ServerPort:=10666;
   if(ParamCount>0)then
     for t:=1 to ParamCount do
       case t of
       1: begin
             net_ServerPort:=s2w(ParamStr(t));
             if(net_ServerPort=0)then net_ServerPort:=10666;
          end;
       2: case ParamStr(t) of
          '-',
          '0': net_svLanAdv:=false;
          end;
       end;
end;

{$ENDIF}

procedure game_Init;
begin
   game_Cycle:=false;

   fr_init;

   StartParams;
   randomize;

   game_InitGameDataAll;

   {$IFDEF _FULLGAME}
   camp_Init;

   input_InitDefaultActionHotkeys;

   lang_Init;

   cfg_read;

   ui_InitControlPanelBTNActions;

   saveload_MakeSaveData;
   replay_MakeReplayHeaderData;

   if not(video_Init)then exit;
   if not(sound_Init)then exit;

   InitRX2Y;
   lang_InitActionHotkeys;
   InitClientDataGame;
   InitClientDataUpgrades;
   InitClientDataMissiles;
   gfx_MakeUnitIcons;
   InitClientDataAbilities;
   lang_Update;

   menu_HelpIList:=@str_doc_Credits;
   {$ENDIF}

   if not(net_Init)then exit;

   map_RandomMap;
   game_DefaultAll;

   NEW(sys_EVENT);

   game_Cycle:=true;

   {$IFDEF _FULLGAME}
   net_ServerListParseAddrs;

   {$IFDEF DOCGEN}
   htmldoc_Make;
   {$ENDIF}

   {$ELSE}
   dedicated_Init;
   {$ENDIF}
end;
