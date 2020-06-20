program T3D_RTS;

{$DEFINE _FULLGAME}
//{$UNDEF _FULLGAME}

{$IFDEF _FULLGAME}
  {$APPTYPE CONSOLE}
  //{$APPTYPE GUI}     // FULL GAME
{$ELSE}
  {$APPTYPE CONSOLE}   // DED SERVER
{$ENDIF}

uses SysUtils, SDL, SDL_Net
{$IFDEF _FULLGAME}
,crt, SDL_Image, SDL_Gfx, SDL_Mixer;
{$ELSE}
,crt;
{$ENDIF}

   {$INCLUDE _const.pas}
   {$INCLUDE _type.pas}
   {$INCLUDE _var.pas}
   {$INCLUDE _common.pas}
{$IFDEF _FULLGAME}
        {$INCLUDE _sounds.pas}
{$ENDIF}
   {$INCLUDE _net_com.pas}
{$IFDEF _FULLGAME}
        {$INCLUDE _lang.pas}
        {$INCLUDE _config.pas}
        {$INCLUDE _draw_com.pas}
        {$INCLUDE _effects.pas}
        {$INCLUDE _unit_ueffs.pas}
        {$INCLUDE _units_spr.pas}
        {$INCLUDE _draw_objects.pas}
        {$INCLUDE _draw_ui.pas}
        {$INCLUDE _draw_menu.pas}
        {$INCLUDE _draw.pas}
        {$INCLUDE _loadThemes.pas}
        {$INCLUDE _loadspr.pas}
{$ENDIF}
   {$INCLUDE _map.pas}
   {$INCLUDE _units_cl.pas}
   {$INCLUDE _units_common.pas}
   {$INCLUDE _missiles.pas}
   {$INCLUDE _units_actions.pas}
   {$INCLUDE _unit_client.pas}
   {$INCLUDE _units.pas}
   {$INCLUDE _game.pas}
{$IFDEF _FULLGAME}
        {$INCLUDE _saveload.pas}
        {$INCLUDE _menu.pas}
        {$INCLUDE _input.pas}
{$ENDIF}
   {$INCLUDE _startgame.pas}

begin
   _StartGame;

   while (_CYCLE) do
   begin
   {$IFNDEF _FULLGAME}
      while (SDL_PollEvent(_EVENT)>0) do
       CASE (_EVENT^.type_) OF
       SDL_QUITEV  : break;
       end;

      _Game;

      SDL_Delay(vid_mpt);
   {$ELSE}
      fps_cs:=SDL_GetTicks;

      if(fps_cs<fps_ns)then continue;

      if(_fsttime)
      then fps_ns:=fps_cs
      else fps_ns:=fps_cs+vid_mpt;

      _inputGame;
      _Game;
      if(_draw)then _drawGame;

      str_temp:=c2s(SDL_GetTicks-fps_cs)+#0;
      SDL_WM_SetCaption(@str_temp[1], nil );
   {$ENDIF}
   end;

   {$IFDEF _FULLGAME}
   cfg_write;
   {$ENDIF}
end.

