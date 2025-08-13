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
   vid_LoadingScreen(@str_loading_gfx,c_yellow);
   gfx_LoadAll;
   cmp_Init;

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

        if(s='test' )then TestMode:=1;
        if(s='testD')then TestMode:=2;
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

   FillChar(menu_NetMsg,SizeOf(menu_NetMsg),0);
   input_InitDefaultActionHotkeys;
   ui_InitControlPanelBTNActions;

   cfg_read;

   saveload_MakeSaveData;
   replay_MakeReplayHeaderData;

   if not(InitVideo)then exit;
   if not(InitSound)then exit;

   InitRX2Y;
   lng_eng;
   SwitchLanguage;
   InitUIDDataCL;
   InitMIDDataCL;
   gfx_MakeUnitIcons;
   gfx_MakeAbilityIcons;

   {$ENDIF}

   if not(InitNET)then exit;

   Map_randommap;
   GameDefaultAll;

   NEW(sys_EVENT);

   GameCycle:=true;

   {$IFNDEF _FULLGAME}
   Dedicated_Init;
   {$ENDIF}
end;
