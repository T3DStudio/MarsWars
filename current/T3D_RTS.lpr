program T3D_RTS;

{$DEFINE _FULLGAME}
//{$UNDEF _FULLGAME}


{$IFDEF _FULLGAME}   // FULL GAME
  {$APPTYPE CONSOLE}
  {$DEFINE DEBUG0}
  //{$DEFINE UNITDATA}
  {$APPTYPE GUI}
{$ELSE}              // DED SERVER
  {$APPTYPE CONSOLE}
{$ENDIF}

uses SysUtils, SDL, SDL_Net,crt
{$IFDEF _FULLGAME}
, SDL_Image, SDL_Gfx, openal, _sound_OGGLoader
{$ENDIF};


{$include _const.pas}
{$include _type.pas}
{$include _var.pas}

{$include _common.pas}
     {$IFDEF _FULLGAME}
        {$include _sounds.pas}
     {$ENDIF}
{$include _net_com.pas}
{$include _objects_main_data.pas}
     {$IFDEF _FULLGAME}
        {$include _objects_client_data.pas}
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
{$include _path.pas}
{$include _map.pas}
{$Include _missiles.pas}
{$include _units_common.pas}
{$include _units.pas}
{$include _ai_base.pas}
{$include _ai_main.pas}
{$include _cpoints.pas}
{$include _invasion.pas}
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

{procedure _test;
var i:byte;
begin
   for i:=0 to 255 do
   with _uids[i] do
   if(_r>0)then
   begin
      writeln(_r,' ',(_r/12):4:4,' ',un_txt_name);
   end;
end; }

begin
   InitGame;
   {$IFDEF _FULLGAME}
   if(TestMode=2)then
   begin
   WriteUnitDescriptions;
   {$IFDEF UNITDATA}
   test_UnitsSpec;
   {$ENDIF}
   end;
   {$ENDIF}

   while(GameCycle)do
   begin
      fr_FPSSecondD:=SDL_GetTicks;

      {$IFDEF _FULLGAME}
      InputGame;
      CodeGame;
      if(r_draw)then DrawGame;
      {$ELSE}
      while(SDL_PollEvent(_EVENT)>0)do
        case (_EVENT^.type_) of
        SDL_QUITEV  : break;
        end;
      CodeGame;
      {$ENDIF}

      fr_FPSSecondU:=SDL_GetTicks-fr_FPSSecondD;
      fr_delay;
   end;

   {$IFDEF _FULLGAME}
   net_disconnect;
   cfg_write;
   {$ENDIF}
end.

