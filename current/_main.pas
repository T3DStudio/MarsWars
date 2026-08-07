
{$IFDEF _FULLGAME}   // FULL GAME
  {$APPTYPE CONSOLE}
  {$DEFINE TESTMODE}
  //{$DEFINE NONETINTEST}
  {$DEFINE DOCGEN}
  //{$APPTYPE GUI}
{$ELSE}              // DED SERVER
  {$APPTYPE CONSOLE}
{$ENDIF}

uses SysUtils, SDL, SDL_Net,crt
{$IFDEF _FULLGAME}
, SDL_Image, SDL_Gfx, openal, _sound_OGGLoader,_SDL_SavePNG
{$ENDIF};


{$include _const.pas}
{$include _type.pas}
{$include _var.pas}

{$include _common.pas}
     {$IFDEF _FULLGAME}
        //{$include .pas}
        {$include _sounds.pas}
     {$ENDIF}
{$include _net_com.pas}
{$include _objects_main_data.pas}
     {$IFDEF _FULLGAME}
        {$include _objects_client_data.pas}
        {$include _strings.pas}
        {$include _html_doc.pas}
        {$include _lang.pas}
        {$include _config.pas}
        {$include _sprite_model.pas}
        {$include _draw_com.pas}
        {$include _draw_menu.pas}
        {$include _draw_ui.pas}
        {$include _draw_game.pas}
        {$include _draw_objs_units.pas}
        {$include _draw_objs_map.pas}
        {$include _effects.pas}
        {$include _draw.pas}
        {$include _loadgfx.pas}
     {$ENDIF}
{$include _map.pas}
{$Include _missiles.pas}
{$include _units_common.pas}
{$include _units.pas}
{$include _ai_common.pas}
{$include _ai_collect.pas}
{$include _ai_main.pas}
{$include _keypoints.pas}
{$include _unit_client.pas}
     {$IFDEF _FULLGAME}
        {$include _campaings.pas}
     {$ENDIF}
{$include _game.pas}
     {$IFDEF _FULLGAME}
        {$Include _saveload.pas}
        {$include _menu.pas}
        {$include _input.pas}
     {$ENDIF}
{$include _init.pas}

{$R *.res}

{var
  st:single;   }
var t:pSDL_Surface;

begin
   //t^.format^.palette^.colors;

   game_Init;

   {$IFDEF _FULLGAME}
   {$IFDEF DOCGEN}
   htmldoc_make;
   ui_language:=not ui_language;SwitchLanguage;
   htmldoc_make;
   ui_language:=not ui_language;SwitchLanguage;
   htmldoc_SaveSprites;
   {$ENDIF}
   {$ENDIF}

   while(game_Cycle)do
   begin
      fr_FPSSecondD:=SDL_GetTicks;

      {$IFDEF _FULLGAME}
      game_Input;
      game_Main;
      if(vid_draw)then
      game_Draw;
      {$ELSE}
      while(SDL_PollEvent(sys_EVENT)>0)do
        case(sys_EVENT^.type_)of
        SDL_QUITEV  : break;
        end;
      game_Main;
      {$ENDIF}

      fr_FPSSecondU:=SDL_GetTicks-fr_FPSSecondD;
      fr_delay;
   end;

   {$IFDEF _FULLGAME}
   net_disconnect;
   cfg_write;
   {$ENDIF}
end.


