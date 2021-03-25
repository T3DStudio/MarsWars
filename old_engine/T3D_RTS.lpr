program T3D_RTS;

{$DEFINE _FULLGAME}
//{$UNDEF _FULLGAME}

{$IFDEF _FULLGAME}   // FULL GAME
  {$APPTYPE CONSOLE}
  //{$APPTYPE GUI}
{$ELSE}              // DED SERVER
  {$APPTYPE CONSOLE}
{$ENDIF}

uses SysUtils, SDL, SDL_Net
{$IFDEF _FULLGAME}
,crt, SDL_Image, SDL_Gfx, SDL_Mixer;
{$ELSE}
,crt;
{$ENDIF}


{$include _const.pas}
{$include _type.pas}
{$include _var.pas}

{$include _common.pas}
     {$IFDEF _FULLGAME}
        {$include _sounds.pas}
     {$ENDIF}
{$include _net_com.pas}
{$include _units_cl.pas}
     {$IFDEF _FULLGAME}
        {$include _lang.pas}
        {$include _config.pas}
        {$include _units_spr.pas}
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
{$include _units_common.pas}
{$include _units.pas}
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

begin
   InitGame;

   while (_CYCLE) do
   begin
   {$IFDEF _FULLGAME}
      fps_cs:=SDL_GetTicks;

      if(fps_cs<fps_ns)then continue;

      if(_fsttime)
      then fps_ns:=fps_cs
      else fps_ns:=fps_cs+fr_mpt;

      InputGame;
      CodeGame;
      if(_draw)then DrawGame;

      fps_tt:=SDL_GetTicks-fps_cs;
   {$ELSE}
      while (SDL_PollEvent(_EVENT)>0) do
       CASE (_EVENT^.type_) OF
       SDL_QUITEV  : break;
       end;

      CodeGame;

      SDL_Delay(fr_mpt);
   {$ENDIF}
   end;

   {$IFDEF _FULLGAME}
   net_plout;
   cfg_write;
   {$ENDIF}
end.


