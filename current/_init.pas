{$IFDEF _FULLGAME}

function InitVideo:boolean;
begin
   InitVideo:=false;

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
   camp_Init;

   InitVideo:=true;
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

procedure GameInit;
begin
   GameCycle:=false;

   fr_init;

   StartParams;
   randomize;

   GameObjectsInit;

   {$IFDEF _FULLGAME}

   input_InitDefaultActionHotkeys;

   cfg_read;

   ui_InitControlPanelBTNActions;

   saveload_MakeSaveData;
   replay_MakeReplayHeaderData;

   if not(InitVideo)then exit;
   if not(InitSound)then exit;

   InitRX2Y;
   lng_eng;
   InitClientDataGame;
   InitClientDataMissiles;
   gfx_MakeUnitIcons;
   InitClientDataAbilities;
   SwitchLanguage;

   menu_HelpIList:=@str_doc_Credits;

   {$ENDIF}

   if not(InitNET)then exit;

   Map_randommap;
   Game_DefaultAll;

   NEW(sys_EVENT);

   GameCycle:=true;

   {$IFDEF _FULLGAME}
   net_ServerListParseAddr;
   {$ELSE}
   Dedicated_Init;
   {$ENDIF}
end;
