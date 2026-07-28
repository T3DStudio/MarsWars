
////////////////////////////////////////////////////////////////////////////////
//
//   FORWARD Declarations
//

procedure unit_damage (pTarget:PTUnit;damage:integer;damagePlayer:byte;IgnoreArmor:boolean);forward;
procedure unit_Bonuses(pu:PTUnit);forward;
procedure unit_kill   (pu:PTUnit;instant,fastdeath,buildcd,KillAllInside,suicide:boolean);forward;
function unit_TryChangeOwner(pTarget:PTUnit;newOwner:PTPlayerGameData;log,check:boolean):byte;forward;
function unit_add      (Ux,Uy,Uunum:integer;Uuid,UplayerN:byte;Ucomplete,Usummoned:boolean;Ulevel:byte;altMode:boolean=false):boolean;forward;
function unit_canMove  (pu:PTUnit):boolean; forward;
function unit_canAttack(pu:PTUnit;check_buffs:boolean):boolean; forward;
function unit_CheckTransport(pTransport,pPassenger:PTUnit):boolean;forward;
function unit_AbilityCheck(pCaster:PTUnit;aid:byte;liteCheck:boolean):byte;forward;

procedure ai_Local_InitVars(pu:PTUnit);forward;
procedure ai_Local_CollectData(pu,tu:PTUnit;ud:integer;tu_transport:PTUnit);forward;
procedure ai_Local_Code(pu:PTUnit);forward;

procedure ai_Global_InitVars(pu:PTUnit);forward;
procedure ai_Global_CollectData(pu,tu:PTUnit;ud:integer;tu_transport:PTUnit;isattackable:boolean);forward;
procedure ai_Global_Code(pu:PTUnit);forward;

function map_GetZone(mx,my:integer;mr:integer=0):word;forward;
procedure map_SymmetryPoints(startx,starty:integer;resultx,resulty:pinteger);forward;

function point_dist_rint(dx0,dy0,dx1,dy1:integer):integer;  forward;

procedure KeyPoints_Clear;   forward;

procedure game_RoyalSetCenter(rx,ry:integer);forward;
procedure Game_RemoveAIObservers; forward;
procedure game_MakeRandomSkirmish; forward;
procedure Game_ShuffleAINames; forward;

{$IFDEF _FULLGAME}
procedure draw_LoadingScreen(load_str:pshortstring;color:TMWColor);forward;
function ui_AddMarker(ax,ay:integer;av:byte;new:boolean):boolean;forward;
procedure ui_EnableControlActs;forward;
procedure ui_InitControlPanelBTNActions;forward;
function LogMes2UIAlarm(POVPlayer:byte):boolean; forward;
procedure snd_SoundLogUIPlayer(PListener:byte);   forward;
procedure snd_StopSoundSourceAll;forward;

procedure unit_UICountersAll; forward;

procedure ability_UACStrike_missile(playeri:byte;fromx,fromy,tox,toy:integer);forward;

function gfx_uid2spr(auid:byte;dir:integer;level:byte):PTMWTexture;forward;
function gfx_ShadowColor(c:TMWColor):TMWColor;forward;

function Game_PauseToggle(check:boolean):boolean;forward;
function GameNetServerList(start,check:boolean):boolean;forward;

procedure menu_msgBox_Set(str_caption,str_body:shortstring;mtype:TMenuMessageBoxType);forward;
function menu_MouseXY2Item:byte; forward;
function menu_ReadyButtonEnabled:boolean;forward;
function menu_ChatSize:integer;  forward;

function PlayerNameChangeble  :boolean;forward;

function PlayerGetColorCur(player:byte;shadow:boolean):TMWColor;  forward;
function PlayerGetColorDef(player:byte):TMWColor; forward;
function PlayerAIToggle  (PlayerTarget,PlayerRequestor:byte;check:boolean):boolean;forward;
function PlayerRaceScroll(PlayerTarget,PlayerRequestor:byte;check:boolean):boolean;forward;
function PlayerTeamScroll(PlayerTarget,PlayerRequestor:byte;forward,check:boolean):boolean;forward;

function saveload_Save  (check:boolean):boolean;forward;
function saveload_Load  (check:boolean):boolean;forward;
function saveload_DeleteInit(check:boolean):boolean;forward;

procedure replay_SavePlayPosition; forward;
function replay_DeleteInit(check:boolean):boolean;forward;
function replay_Play  (check:boolean):boolean;forward;
function replay_TogglePause (check:boolean):boolean;forward;
function replay_IsPaused:boolean;  forward;
function replay_GetProgress:single;forward;
procedure replay_WriteBlock(count:cardinal;pData:pointer);forward;
function replay_ReadBlock(count:cardinal;pResult:pointer):boolean;forward;

procedure map_MiniMap_KeyPoints(tar:pSDL_Surface;forGame:boolean);forward;
function map_ObstacleR(obs_f:byte):integer;forward;
procedure map_RedrawMenuMinimap;forward;

function Float2Str(s:single):shortstring;
var l:byte;
begin
   Float2Str:=FormatFloat('#0.##',s);
   l:=length(Float2Str);
   while(l>0)do
   begin
      if(Float2Str[l]=',')then Float2Str[l]:='.';
      l-=1;
   end;
end;

function str_AbilityHintName(aid,uipos:byte):shortstring;forward;
function str_GTick2Time(gtick:cardinal):shortstring;forward;
function str_SpaceSize(str:shortstring;newSize:byte):shortstring;forward;
{$ENDIF}


////////////////////////////////////////////////////////////////////////////////
//
//   FRAME RATE
//

procedure fr_init;
begin
   fr_LastTicks :=0;
   fr_BaseTicks :=0;
   fr_FrameCount:=0;
   fr_FPSSecond :=0;
   fr_FPSSecondN:=0;
   fr_FPSSecondC:=0;
end;

procedure fr_delay;
var
fr_TargetTicks,
fr_CurrentTicks: cardinal;
begin
   fr_FrameCount+=1;

   fr_CurrentTicks:=SDL_GetTicks;

   fr_FPSSecondD  :=fr_CurrentTicks-fr_LastTicks;
   fr_FPSSecond   +=fr_FPSSecondD;
   fr_FPSSecondN  +=1;
   if(fr_FPSSecond>=1000)then
   begin
      fr_FPSSecondC:=fr_FPSSecondN;
      fr_FPSSecondN:=0;
      fr_FPSSecond :=fr_FPSSecond mod 1000;
   end;

   fr_LastTicks   :=fr_CurrentTicks;

   {$IFDEF _FULLGAME}
   if(sys_uncappedFPS)and(not MainMenu)
   then fr_TargetTicks :=fr_BaseTicks + fr_FrameCount
   else
   {$ENDIF}
   fr_TargetTicks :=fr_BaseTicks + trunc(fr_FrameCount*fr_RateTicks);

   if(fr_CurrentTicks<=fr_TargetTicks)
   then sdl_Delay(fr_TargetTicks-fr_CurrentTicks)
   else
   begin
      fr_FrameCount:=0;
      fr_BaseTicks :=fr_CurrentTicks;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   BASIC String
//

// ... to string
function b2s (i:byte    ):shortstring;begin str(i,b2s );end;
function w2s (i:word    ):shortstring;begin str(i,w2s );end;
function c2s (i:cardinal):shortstring;begin str(i,c2s );end;
function i2s (i:integer ):shortstring;begin str(i,i2s );end;
function li2s(i:longint ):shortstring;begin str(i,li2s);end;
function si2s(i:single  ):shortstring;begin str(i,si2s);end;
// string to ...
function s2b (str:shortstring):byte    ;var t:integer;begin val(str,s2b ,t);end;
function s2w (str:shortstring):word    ;var t:integer;begin val(str,s2w ,t);end;
function s2i (str:shortstring):integer ;var t:integer;begin val(str,s2i ,t);end;
function s2c (str:shortstring):cardinal;var t:integer;begin val(str,s2c ,t);end;
function s2si(str:shortstring):single  ;var t:integer;begin val(str,s2si,t);end;

// card ticks to secs
function ct2s(r:cardinal):cardinal;
begin
   if(r>0)
   then ct2s:=(r+fr_ifps) div fr_fps1
   else ct2s:=0;
end;

procedure STRADD(s:pshortstring;ad,sep:shortstring);
begin
   if(length(ad)>0)then
     if(length(s^)=0)
     then s^:=ad
     else s^:=s^+sep+ad;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   basic math
//

function max2i(x1,x2   :longint):integer;
var r:longint;
begin
   if(x1>x2)
   then r:=x1
   else r:=x2;
   if(r>max2i.MaxValue)then r:=max2i.MaxValue;
   if(r<max2i.MinValue)then r:=max2i.MinValue;
   max2i:=r;
end;
function min2i(x1,x2   :longint):integer;
var r:longint;
begin
   if(x1<x2)
   then r:=x1
   else r:=x2;
   if(r>min2i.MaxValue)then r:=min2i.MaxValue;
   if(r<min2i.MinValue)then r:=min2i.MinValue;
   min2i:=r;
end;
function max3i(x1,x2,x3:longint):integer;begin max3i:=max2i(max2i(x1,x2),x3);end;
function min3i(x1,x2,x3:longint):integer;begin min3i:=min2i(min2i(x1,x2),x3);end;

function min2b(x1,x2   :byte):byte;begin if(x1<x2)then min2b:=x1 else min2b:=x2;end;
function max2b(x1,x2   :byte):byte;begin if(x1>x2)then max2b:=x1 else max2b:=x2;end;

function min2c(x1,x2   :cardinal):cardinal;begin if(x1<x2)then min2c:=x1 else min2c:=x2;end;
function min3c(x1,x2,x3:cardinal):cardinal;begin min3c:=min2c(min2c(x1,x2),x3);end;

function mm3i(mnx,x,mxx:longint ):integer;begin mm3i:=min2i(mxx,max2i(x,mnx)); end;

function i2c(i:integer):string4;
begin
   i2c:=#0#0;
   move(i,i2c[1],2);
end;
function c2i(cc:string4):integer;
begin
   move(cc[1],c2i,2);
end;

function GetBBit(pb:pbyte;nb:byte):boolean;
begin
   GetBBit:=(pb^ and (1 shl nb))>0;
end;

procedure SetBBit(pb:pbyte;nb:byte;nozero:boolean);
var i:byte;
begin
   i:=(1 shl nb);
   if(nozero)
   then pb^:=pb^ or i
   else
     if((pb^ and i)>0)then pb^:=pb^ xor i;
end;

function sign(x:integer;noZero:boolean=false):integer;
begin
   if(noZero)
   then sign:=1
   else sign:=0;
   if(x>0)then sign:= 1;
   if(x<0)then sign:=-1;
end;

function point_dist_rint(dx0,dy0,dx1,dy1:integer):integer;
var t:longint;
begin
   dx0:=abs(dx1-dx0);
   dy0:=abs(dy1-dy0);
   if(dx0=0)
   then point_dist_rint:=dy0
   else
     if(dy0=0)
     then point_dist_rint:=dx0
     else
     begin
        if(dx0<dy0)
        then t:=(123*dy0+51*dx0) shr 7
        else t:=(123*dx0+51*dy0) shr 7;
        if(t>point_dist_rint.MaxValue)or(t<0)
        then point_dist_rint:=point_dist_rint.MaxValue
        else point_dist_rint:=t;
     end;
end;

function point_dist_int(dx0,dy0,dx1,dy1:longint):integer;
var t:longint;
begin
   dx0:=abs(dx0-dx1);
   dy0:=abs(dy0-dy1);
   if(dx0=0)
   then point_dist_int:=dy0
   else
     if(dy0=0)
     then point_dist_int:=dx0
     else
     begin
        t:=longint(sqr(dx0))+longint(sqr(dy0));
        if(t<0)
        then point_dist_int:=integer.MaxValue
        else
          if(t=0)
          then point_dist_int:=0
          else
          begin
             t:=round(sqrt(t));
             if(t<point_dist_int.MaxValue)
             then point_dist_int:=t
             else point_dist_int:=point_dist_int.MaxValue;
          end;
     end;
end;

function point_dist_real(dx0,dy0,dx1,dy1:integer):single;
begin
   point_dist_real:=sqrt(sqr(abs(dx0-dx1))+sqr(abs(dy0-dy1)));
end;

function point_dir(x0,y0,x1,y1:integer):integer;
var vx,vy:integer;
    res  :single;
begin
   point_dir:=270;
   vx:=x1-x0;
   vy:=y1-y0;

   if(vx=0)and(vy=0)then exit;

   if(abs(vx)>abs(vy))
   then res:=   trunc((vy/vx)*45)
   else res:=90-trunc((vx/vy)*45);

   if(vy<0)then
   begin
      if(res<0)then res:=res+360 else
      if(res>0)then res:=res+180;
   end
   else
     if(res<0)then res:=res+180;

   if(vx<0)and(res=0)then res:=180;

   point_dir:=trunc(360-res);
end;

function dir_diff(dir1,dir2:integer):integer;
begin
   dir_diff:=((( (dir1-dir2) mod 360) + 540) mod 360) - 180;
end;

function dir_MOD360(d:integer):integer;
begin
   dir_MOD360:=d mod 360;
   if(dir_MOD360<0)then dir_MOD360:=dir_MOD360+360;
end;

function dir_turn(d1,d2,spd:integer):integer;
var d:integer;
begin
   d:=dir_diff(d2,d1);

   if abs(d)<=spd
   then dir_turn:=d2
   else dir_turn:=d1+(spd*sign(d));
   dir_turn:=dir_MOD360(dir_turn);
end;

function AddToInt(bt:pinteger;val:integer):boolean;
begin
   AddToInt:=false;
   if(bt^<val)then
   begin
      bt^:=val;
      AddToInt:=true;
   end;
end;

procedure ScrollByte(pb:pbyte;forward:boolean;min,max:byte;loop:boolean=true);
begin
   case forward of
true : case loop of
       true : if(pb^=255)or(pb^>=max)
              then pb^:=min
              else pb^+=1;
       false: if(pb^<max)then pb^+=1;
       end;
false: case loop of
       true : if(pb^=0  )or(pb^<=min)
              then pb^:=max
              else pb^-=1;
       false: if(pb^>min)then pb^-=1;
       end;
   end;
end;

procedure ScrollByteSet(pb:pbyte;fwrd:boolean;pset:PTSoB);
begin
   if(pset^=[])then exit;
   repeat
     if(fwrd)
     then pb^+=1
     else pb^-=1
   until pb^ in pset^
end;

procedure ScrollInt(i:pinteger;s,min,max:integer;loop:boolean=true);
begin
   i^+=s;
   case loop of
true : begin
          if(i^>max)then i^:=min;
          if(i^<min)then i^:=max;
       end;
false: begin
          if(i^>max)then i^:=max;
          if(i^<min)then i^:=min;
       end;
   end;
end;

function ipower(base,n:integer):integer;
begin
   ipower:=1;
   if(n<0)or(base<=0)then exit;
   case n of
   0    : ipower:=1;
   1    : ipower:=base;
   else   ipower:=base; while(n>1)do begin ipower*=base;n-=1;end;
   end;
end;

function RingCollision(x1,y1,rO1,rI1,x2,y2,rO2,rI2:integer):boolean;
var d:integer;
begin
   RingCollision:=false;
   if(rI1<0)then rI1:=0;
   if(rI2<0)then rI2:=0;
   d:=point_dist_int(x1,y1,x2,y2);
   if(d>(rO1+rO2))then exit;
   if((d+rO1)<rI2)
   or((d+rO2)<rI1)then exit;
   RingCollision:=true;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   COMMON
//

procedure WriteSDLError;
var f:Text;
begin
   Assign(f,outlogfn);
   if FileExists(outlogfn)
   then Append (f)
   else Rewrite(f);
   writeln(f,sdl_GetError);
   SDL_ClearError;
   Close(f);
end;


////////////////////////////////////////////////////////////////////////////////
//
//   COMMON Players funcs
//

procedure PlayerSetAllowedUnits(p:byte;g:TSob;max:integer;new:boolean);    // allowed units  (by uids)
var i:byte;
begin
   with g_PlayersGame[p] do
   begin
      if(new)then FillChar(units_uid_m,SizeOf(units_uid_m),0);
      if(g<>[])then
        for i in g do
          units_uid_m[i]:=max;
   end;
end;
procedure PlayerSetAllowedUpgrades(p:byte;g:TSob;lvl:byte;new:boolean);  // allowed upgrades
var i:byte;
begin
   with g_PlayersGame[p] do
   begin
      if(new)then FillChar(upgrs_max,SizeOf(upgrs_max),0);
      if(g<>[])then
        for i in g do
          with g_upgrs[i] do upgrs_max[i]:=min2b(upgr_max,lvl);
   end;
end;
procedure PlayerSetCurrentUpgrades(p:byte;g:TSob;lvl:integer;new:boolean);  // current upgrades
var i:byte;
begin
   with g_PlayersGame[p] do
   begin
      if(new)then FillChar(upgrs_cur,SizeOf(upgrs_cur),0);
      if(g<>[])then
       for i:=0 to 255 do
        if(i in g)then
         with g_upgrs[i] do
          upgrs_cur[i]:=min3i(upgrs_max[i],upgr_max,lvl);
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   PLAYERS LOG
//

function PlayerGetAlliesByte(playeri:byte;AddSelf:boolean):byte;
var p:byte;
begin
   if(playeri>LastPlayer)
   then PlayerGetAlliesByte:=255
   else
   begin
      PlayerGetAlliesByte:=0;
      for p:=0 to LastPlayer do
        with g_PlayersGame[p] do
          if(state>ps_None)then
          begin
             if(not AddSelf)and(p=playeri)then continue;

             case g_PlayersGame[playeri].isobserver of
             false: if(team<>g_PlayersGame[playeri].team)
                    or(isobserver)
                    or(isdefeated)then continue;
             true : if(not isobserver)then continue;
             end;
             SetBBit(@PlayerGetAlliesByte,p,true);
          end;
   end;
end;

function PlayerLogCheckNearEvent(playeri:byte;tickDiff:cardinal;x,y:integer;mtypes:TSoB):boolean;
var ln,li:cardinal;
begin
   PlayerLogCheckNearEvent:=true;
   with g_PlayersGame[playeri] do
   begin
      li:=log_i;
      for ln:=0 to MaxPlayerLog do
      begin
         if(li>0)
         then li-=1
         else li:=MaxPlayerLog;

         with log_l[li] do
           if(lm_tick>g_tick)or not(lm_type in mtypes)
           then continue
           else
             if((g_tick-lm_tick)<tickDiff)then
               if(x<0)or(y<0)
               then exit
               else
                 if (lm_x=x)
                 and(lm_y=y)
                 then exit
                 else
                   if(point_dist_rint(lm_x,lm_y,x,y)<base_r2)then exit;
      end;
   end;
   PlayerLogCheckNearEvent:=false;
end;

procedure PlayerAddLog(ptarget,amtype,adatat,adatau:byte;astr:shortstring;ax,ay:integer);
{$IFDEF _FULLGAME}
var POVPlayer:byte;
{$ENDIF}
begin
   if(ptarget>LastPlayer)then exit;

   with g_PlayersGame[ptarget] do
     if(state>ps_None)then
     begin
        case amtype of
// message types without spam protection
lmt_chat_player0..
lmt_chat_player7,
lmt_chat_local,
lmt_player_connected,
lmt_player_leave,
lmt_player_surrender,
lmt_player_timeout,
lmt_player_defeated,
lmt_player_revealed,
lmt_player_ready,
lmt_player_nready,
lmt_replay_RecStart,
lmt_replay_RecStop,
lmt_replay_RecError,
lmt_kpoint_CaptureStart,
lmt_kpoint_Captured,
lmt_ngen_exh,
lmt_ngen_captured,
lmt_ngen_lost,
lmt_ngen_Alarm,
lmt_koth_CaptureStart,
lmt_koth_Alarm,
lmt_other_UACStrike,
lmt_other_UACScan,
lmt_game_end,
lmt_game_message,
lmt_game_ReadyToStart,
lmt_game_BreakStarting,
lmt_game_StartsIn,
lmt_game_ResetIn,
lmt_game_Paused,
lmt_game_Resumed
                     :;

lmt_unit_attackedU,
lmt_unit_attackedB,
lmt_allies_attackedU,
lmt_allies_attackedB : if(PlayerLogCheckNearEvent(ptarget,fr_fps6,ax,ay,[lmt_unit_attackedU,
                                                                         lmt_unit_attackedB,
                                                                         lmt_allies_attackedU,
                                                                         lmt_allies_attackedB]))then exit;
lmt_unit_LevelUp     : if(PlayerLogCheckNearEvent(ptarget,fr_fps6,ax,ay,[amtype              ]))then exit;

lmt_markLook,
lmt_markAttack       : if(PlayerLogCheckNearEvent(ptarget,fr_fps1,ax,ay,[amtype              ]))then exit;
        else
           with log_l[log_i] do
             if(lm_tick<=g_tick)then
               if (lm_type=amtype)
               and(lm_data_t=adatat)
               and(lm_data_u=adatau)then
                 if((g_tick-lm_tick)<fr_fps3)then exit;
        end;

        log_n+=1;

        log_i+=1;
        if(log_i>MaxPlayerLog)then log_i:=0;

        with log_l[log_i] do
        begin
           lm_type  :=amtype;
           lm_data_t:=adatat;
           lm_data_u:=adatau;
           lm_string:=astr;
           lm_x     :=ax;
           lm_y     :=ay;
           lm_tick  :=g_tick;
        end;

        {$IFDEF _FULLGAME}
        if(ptarget=rpls_player)and(rpls_log_c<MaxPlayerLog)and(rpls_fstate=rpls_write)then rpls_log_c+=1;

        if(not ServerSide)then
          case g_started of
          false: case amtype of
                 lmt_game_ReadyToStart : g_LobbyTimer:=g_GameStartTime;
                 lmt_game_StartsIn     : g_LobbyTimer:=adatau*fr_fps1-1;
                 lmt_game_BreakStarting: g_LobbyTimer:=0;
                 end;
          true :
                   case amtype of
                   lmt_player_leave,
                   lmt_player_timeout  : if(adatau<=LastPlayer)then
                                           with g_PlayersGame[adatau] do state:=ps_none;
                   lmt_player_connected: if(adatau<=LastPlayer)then
                                           with g_PlayersGame[adatau] do
                                           begin
                                              name      :=astr;
                                              state     :=ps_human;
                                              isobserver:=true;
                                           end;
                   lmt_other_UACStrike : with log_l[log_i] do
                                           ability_UACStrike_missile(lm_data_u,c2i(lm_string[1]+lm_string[2]),
                                                                               c2i(lm_string[3]+lm_string[4]),lm_x,lm_y);
                   end;
          end;

        if(net_status<>ns_none)or(not g_started)
        then POVPlayer:=LocalPlayer
        else POVPlayer:=UIPlayer;
        if(ptarget=POVPlayer)then
        begin
           if(amtype in lmts_last_events)then
             ui_log_LastTimer :=min2i(ui_log_LastTimer +ui_log_TimeLast ,ui_log_TimeMax );

           menu_update:=true;

           if(LogMes2UIAlarm(POVPlayer))then snd_SoundLogUIPlayer(POVPlayer);

           if(rpls_pstate<rpls_read)and(g_type<>gt_campaing)then
             if((amtype=lmt_player_defeated)and(g_NewObservers)and(adatau=UIPlayer))
             or(amtype=lmt_game_end)then
             begin
                ui_tab:=3;
                ui_fog:=false;
             end;
        end;
        {$ENDIF}
     end;
end;

procedure PlayersAddToLog(from_player,to_players,amtype,auidt,auid:byte;astr:shortstring;ax,ay:integer);
var p:byte;
begin
   for p:=0 to LastPlayer do
     if(GetBBit(@to_players,p))
     or(p=from_player)then PlayerAddLog(p,amtype,auidt,auid,astr,ax,ay);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   TYPICAL GAME LOG MESSAGES

// LOG
procedure GameLog_Chat(sender,chat_tar:byte;message:shortstring);
var dt:byte;
begin
   case chat_tar of
   chat_all     : begin
                     chat_tar:=255;
                     dt:=0;
                  end;
   chat_allies  : begin
                     chat_tar:=PlayerGetAlliesByte(sender,true);
                     dt:=1;
                  end;
   0..LastPlayer: chat_tar:=1 shl chat_tar;
   else
      chat_tar:=0;
   end;

   if(chat_tar>0)then
     if(sender<=LastPlayer)
     then PlayersAddToLog(sender,chat_tar,lmt_chat_player0+sender,dt,0,g_PlayersGame[sender].name+': '+message,0,0)
     else PlayersAddToLog(sender,chat_tar,lmt_chat_local        ,0 ,0,message                                ,0,0);
end;
{procedure GameLog_Common(sender,targets:byte;message:shortstring);
begin
   PlayersAddToLog(sender,targets,lmt_game_message,0,0,message,0,0);
end;  }

// PLAYERS
procedure GameLog_PlayerConnected(player:byte);
begin
   if(player<=LastPlayer)then
   PlayersAddToLog(player,log_to_all,lmt_player_connected,0,player,g_PlayersGame[player].name,0,0);
end;
procedure GameLog_PlayerLeave(player:byte);
begin
   if(player<=LastPlayer)then
   PlayersAddToLog(player,log_to_all,lmt_player_leave,0,player,g_PlayersGame[player].name,0,0);
end;
procedure GameLog_PlayerTimeOut(player:byte);
begin
   if(player<=LastPlayer)then
   PlayersAddToLog(player,log_to_all,lmt_player_timeout,0,player,g_PlayersGame[player].name,0,0);
end;
procedure GameLog_PlayerDefeated(player:byte);
begin
   if(player<=LastPlayer)then
   PlayersAddToLog(player,log_to_all,lmt_player_defeated,0,player,g_PlayersGame[player].name,0,0);
end;
procedure GameLog_PlayerRevealed(player:byte);
begin
   if(player>LastPlayer)then exit;

   with g_PlayersGame[player] do
   PlayersAddToLog(player,log_to_all,lmt_player_revealed,byte(isrevealed),player,name,0,0);
end;

procedure GameLog_PlayerSurrender(player:byte);
begin
   if(player<=LastPlayer)then
   PlayersAddToLog(player,log_to_all,lmt_player_surrender,0,player,g_PlayersGame[player].name,0,0);
end;

procedure GameLog_PlayerReadyStat(player:byte);
begin
   if(player<=LastPlayer)then
     with g_PlayersGame[player] do
       if(isready)
       then PlayersAddToLog(255,log_to_all,lmt_player_ready ,0,0,name,0,0)
       else PlayersAddToLog(255,log_to_all,lmt_player_nready,0,0,name,0,0)
end;

{$IFDEF _FULLGAME}
// RECORDS
procedure GameLogRecStart(fname:shortstring);
begin
   PlayersAddToLog(LocalPlayer,0,lmt_replay_RecStart,0,0,fname,0,0)
end;
procedure GameLogRecStop (fname:shortstring);
begin
   PlayersAddToLog(LocalPlayer,0,lmt_replay_RecStop,0,0,fname,0,0)
end;
procedure GameLogRecError(errorStr:shortstring);
begin
   PlayersAddToLog(LocalPlayer,0,lmt_replay_RecError,0,0,errorStr,0,0)
end;
{$ENDIF}

// GAME
procedure GameLog_ReadyToStart;
begin
   PlayersAddToLog(255,log_to_all,lmt_game_ReadyToStart,0,0,'',0,0)
end;
procedure GameLog_BreakStarting;
begin
   PlayersAddToLog(255,log_to_all,lmt_game_BreakStarting,0,0,'',0,0)
end;
procedure GameLog_StartsIn(seconds:integer);
begin
   PlayersAddToLog(255,log_to_all,lmt_game_StartsIn,0,byte(seconds),'',0,0)
end;
{$IFNDEF _FULLGAME}
procedure GameLog_EndsIn(seconds:integer);
begin
   PlayersAddToLog(255,log_to_all,lmt_game_ResetIn ,0,byte(seconds),'',0,0)
end;
{$ENDIF}
procedure GameLog_EndGame(wteam:byte);
begin
   PlayersAddToLog(255,log_to_all,lmt_game_end,0,wteam,'',0,0);
end;
procedure GameLog_Paused(playerN:byte);
begin
   if(playerN<=LastPlayer)then
     with g_PlayersGame[playerN] do
   PlayersAddToLog(playerN,log_to_all,lmt_game_Paused,0,0,name,0,0);
end;
procedure GameLog_Resumed(playerN:byte);
begin
   if(playerN<=LastPlayer)then
     with g_PlayersGame[playerN] do
   PlayersAddToLog(playerN,log_to_all,lmt_game_Resumed,0,0,name,0,0);
end;

function GameLog_ReqMsg(playerN,auid,atype,amsgid:byte;x,y:integer;check:boolean=false):boolean;
begin
   GameLog_ReqMsg:=false;
   if(playerN>LastPlayer)
   or(amsgid=0)then exit;

   with g_PlayersGame[playerN] do
   begin
      GameLog_ReqMsg:=true;

      if(check)
      or(state=ps_AI)then exit;
   end;

   PlayersAddToLog(playerN,0,amsgid,atype,auid,'',x,y);
end;
procedure GameLog_MapMark(playeri:byte;x,y,mType:integer);
begin
   if(playeri>LastPlayer)then exit;

   with g_PlayersGame[playeri] do
     case mType of
     co_markLook  : PlayersAddToLog(playeri,PlayerGetAlliesByte(playeri,true),lmt_markLook  ,0,0,name,x,y);
     co_markAttack: PlayersAddToLog(playeri,PlayerGetAlliesByte(playeri,true),lmt_markAttack,0,0,name,x,y);
     end;
end;

procedure GameLog_UACStrike(playeri:byte;fromx,fromy,tox,toy:integer);
begin
   if(playeri>LastPlayer)then exit;

   PlayersAddToLog(playeri,log_to_all,lmt_other_UACStrike,0,playeri,i2c(fromx)+i2c(fromy),tox,toy);
end;
procedure GameLog_UACScan(playeri,scanedPlayers:byte;tox,toy:integer);
begin
   if(playeri>LastPlayer)
   or(scanedPlayers=0)then exit;

   PlayersAddToLog(playeri,scanedPlayers,lmt_other_UACScan,0,playeri,'',tox,toy);
end;

// UNITS
procedure GameLog_UnitReady(pu:PTunit);
begin
   if(pu<>nil)then
   with pu^ do
     if(uid^.uid_isbuilding)
     then PlayersAddToLog(playeri,0,lmt_unit_readyB,lmt_argt_unit ,uidi,'',x,y)
     else PlayersAddToLog(playeri,0,lmt_unit_readyU,lmt_argt_unit ,uidi,'',x,y);
end;
procedure GameLog_UnitCaptured(pu:PTunit);
begin
   if(pu<>nil)then
   with pu^ do PlayersAddToLog(playeri,0,lmt_unit_captured,lmt_argt_unit ,uidi,'',x,y);
end;
procedure GameLog_UnitLost(pu:PTunit);
begin
   if(pu<>nil)then
   with pu^ do PlayersAddToLog(playeri,0,lmt_unit_lost,lmt_argt_unit ,uidi,'',x,y);
end;
procedure GameLog_UnitResurrected(pu:PTunit);
begin
   if(pu<>nil)then
   with pu^ do PlayersAddToLog(playeri,0,lmt_unit_resurrected,lmt_argt_unit ,uidi,'',x,y);
end;
procedure GameLog_UnitPromoted(pu:PTunit);
begin
   if(pu<>nil)then
   with pu^ do PlayersAddToLog(playeri,0,lmt_unit_LevelUp,0,uidi,'',x,y);
end;
procedure GameLog_UpgradeComplete(playeri,upid:byte;x,y:integer);
begin
   if(playeri>LastPlayer)then exit;

   PlayersAddToLog(playeri,0,lmt_upgrade_complete,0,upid,'',x,y);
end;
procedure GameLog_UnitAttacked(pu:PTunit);
begin
   if(pu=nil)then exit;

   with pu^ do
   begin
      if(uid^.uid_isbuilding)
      then PlayersAddToLog(playeri,0                                 ,lmt_unit_attackedB  ,0,uidi,'',x,y)
      else PlayersAddToLog(playeri,0                                 ,lmt_unit_attackedU  ,0,uidi,'',x,y);
      if(uid^.uid_isbuilding)
      then PlayersAddToLog(playeri,PlayerGetAlliesByte(playeri,false),lmt_allies_attackedB,0,uidi,'',x,y)
      else PlayersAddToLog(playeri,PlayerGetAlliesByte(playeri,false),lmt_allies_attackedU,0,uidi,'',x,y);
   end;
end;

// KEY POINTS
procedure GameLog_KeyPointCaptureStart(kpoint:byte);
begin
   if(LastKeyPoint<kpoint)then exit;

   with map_KeyPointsL[kpoint] do
     with kp_TeamData[MaxPlayers] do
       PlayersAddToLog(255,255,lmt_kpoint_CaptureStart,kpoint,kptd_TimerOwnerTeam,'',kp_x,kp_y);
end;
procedure GameLog_KeyPointCaptured(kpoint:byte);
begin
   if(LastKeyPoint<kpoint)then exit;

   with map_KeyPointsL[kpoint] do
     with kp_TeamData[MaxPlayers] do
       PlayersAddToLog(255,255,lmt_kpoint_Captured,kpoint,kptd_OwnerTeam,'',kp_x,kp_y);
end;
// KotH
procedure GameLog_KotHControl;
begin
   with map_KeyPointsL[0] do
     with kp_TeamData[MaxPlayers] do
       PlayersAddToLog(255,255,lmt_koth_CaptureStart,0,kptd_TimerOwnerTeam,'',kp_x,kp_y);
end;
procedure GameLog_KothCountDown;
var t:integer;
begin
   with map_KeyPointsL[0] do
     with kp_TeamData[MaxPlayers] do
     begin
        if(kptd_Timer>=kp_CaptureTime)then exit;

        t:=kp_CaptureTime-kptd_Timer;

        if(t>=fr_fps10)then
        begin
           if((t mod fr_fps10)<>0)then exit;
        end
        else
          if((t mod fr_fps1)<>0)then exit;

        PlayersAddToLog(255,255,lmt_koth_Alarm,0,kptd_TimerOwnerTeam,i2s(t div fr_fps1),kp_x,kp_y);
     end;
end;
// Generators
procedure GameLog_GeneratorCaptured(from_player,kpoint:byte);
begin
   if(LastPlayer<from_player)
   or(LastKeyPoint<kpoint)then exit;

   with g_PlayersGame[from_player] do
     if(isdefeated)
     or(isobserver)then exit;

   with map_KeyPointsL[kpoint] do
     PlayersAddToLog(from_player,0,lmt_ngen_captured  ,0,0,'',kp_x,kp_y);
end;
procedure GameLog_GeneratorAlarm(from_player,kpoint:byte);
begin
   if(LastPlayer<from_player)
   or(LastKeyPoint<kpoint)then exit;

   with g_PlayersGame[from_player] do
     if(isdefeated)
     or(isobserver)then exit;

   with map_KeyPointsL[kpoint] do
     PlayersAddToLog(from_player,0,lmt_ngen_Alarm  ,0,0,'',kp_x,kp_y);
end;
procedure GameLog_GeneratorLost(from_player,kpoint:byte);
begin
   if(LastPlayer<from_player)
   or(LastKeyPoint<kpoint)then exit;

   with g_PlayersGame[from_player] do
     if(isdefeated)
     or(isobserver)then exit;

   with map_KeyPointsL[kpoint] do
     PlayersAddToLog(from_player,0,lmt_ngen_lost  ,0,0,'',kp_x,kp_y);
end;
procedure GameLog_GeneratorExh(from_player,kpoint:byte);
begin
   if(LastPlayer<from_player)
   or(LastKeyPoint<kpoint)then exit;

   with g_PlayersGame[from_player] do
     if(isdefeated)
     or(isobserver)then exit;

   with map_KeyPointsL[kpoint] do
     PlayersAddToLog(from_player,0,lmt_ngen_exh  ,0,0,'',kp_x,kp_y);
end;

// PLAYER LOG COMMON
procedure PlayerClearLog(playerN:byte);
var i:cardinal;
begin
   if(playerN>LastPlayer)then exit;

   with g_PlayersGame[playerN] do
   begin
      FillChar(log_l,SizeOf(log_l),0);
      for i:=0 to MaxPlayerLog do
        with log_l[i] do
        begin
           lm_x:=-1;
           lm_y:=-1;
        end;
      log_n:=0;
      log_i:=0;
   end;
end;

procedure PlayersClearLog;
var p:byte;
begin
   for p:=0 to LastPlayer do PlayerClearLog(p);
end;

// OTHER

function PlayersAllReady:boolean;
var p,
c_human,
c_ready:byte;
begin
   c_human:=0;
   c_ready:=0;
   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
       if(state=ps_human)then
       begin
          c_human+=1;
          if(isready){$IFDEF _FULLGAME}or(p=LocalPlayer){$ENDIF}then c_ready+=1;
       end;
   PlayersAllReady:=(c_ready=c_human)and(c_human>0);
end;
function PlayersNonObserversCount:byte;
var p:byte;
begin
   PlayersNonObserversCount:=0;
   for p:=0 to LastPlayer do
     if(p<map_MaxPlayers)then
       with g_PlayersGame[p] do
         case state of
         ps_none : if(g_AISlots>0)then
                   PlayersNonObserversCount+=1;
         ps_ai   : PlayersNonObserversCount+=1;
         ps_human: if(not isobserver)then
                   PlayersNonObserversCount+=1;
         end;
end;

function PlayerGetFixedTeams(gm,p:byte):byte;
begin
   PlayerGetFixedTeams:=p;
   if(p<=LastPlayer)then
     with g_PlayersGame[p] do
       case gm of
mc_1x1     : case p of
             0,1 : PlayerGetFixedTeams:=p;
             end;
mc_2x2     : case p of
             0..1: PlayerGetFixedTeams:=0;
             2..3: PlayerGetFixedTeams:=1;
             end;
mc_3x3     : case p of
             0..2: PlayerGetFixedTeams:=0;
             3..5: PlayerGetFixedTeams:=1;
             end;
mc_4x4     : case p of
             0..3: PlayerGetFixedTeams:=0;
             4..7: PlayerGetFixedTeams:=1;
             end;
mc_2x2x2   : case p of
             0,1 : PlayerGetFixedTeams:=0;
             2,3 : PlayerGetFixedTeams:=1;
             4,5 : PlayerGetFixedTeams:=2;
             end;
mc_2x2x2x2 : case p of
             0,1 : PlayerGetFixedTeams:=0;
             2,3 : PlayerGetFixedTeams:=1;
             4,5 : PlayerGetFixedTeams:=2;
             6,7 : PlayerGetFixedTeams:=3;
             end;
       else  PlayerGetFixedTeams:=p;
       end;
end;

function PlayerValidateTeam(p,nt:byte):byte;
begin
   PlayerValidateTeam:=0;
   if(p<=LastPlayer)then
     with g_PlayersGame[p] do
       if(map_scenario in mc_fixed_teams)
       then PlayerValidateTeam:=PlayerGetFixedTeams(map_scenario,p)
       else
         case state of
         ps_None : PlayerValidateTeam:=p;
         ps_AI,
         ps_human: if(team>LastPlayer)
                   then PlayerValidateTeam:=0
                   else PlayerValidateTeam:=nt;
         end;
end;
procedure PlayersValidateTeam;
var p:byte;
begin
   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
       team:=PlayerValidateTeam(p,team);
end;

function PlayerStateString(p:byte):string4;
begin
   PlayerStateString:='';
   with g_PlayersGame[p] do
   with g_PlayersTemp[p] do
     case state of
     ps_AI   : PlayerStateString:=str_ps_AI;
     ps_Human: {$IFDEF _FULLGAME}
               if(LocalPlayer=p)
               then PlayerStateString:=str_ps_Me
               else
               {$ENDIF}
                 if(net_ttl>=fr_fps1)
                 then PlayerStateString:=str_ps_ttl
                 else
                   if(g_started)
                   then PlayerStateString:=str_ps_Hum
                   else PlayerStateString:=b2c[isready{$IFDEF _FULLGAME} or((net_status=ns_client)and(p=net_cl_Hoster)){$ENDIF}];
     end;
end;

function KeyPoint_GetPlayerTeam(playerN:byte):byte;
begin
   KeyPoint_GetPlayerTeam:=MaxPlayers;
   if(playerN<MaxPlayers)then
     KeyPoint_GetPlayerTeam:=g_PlayersGame[playerN].team;
end;

////////////////////////////////////////////////////////////////////////////////

function IsUnitRange(u:integer;ppu:PPTUnit):boolean;
begin
   IsUnitRange:=false;
   if(0<u)and(u<=MaxUnits)then
   begin
      IsUnitRange:=true;
      if(ppu<>nil)then ppu^:=@g_units[u];
   end;
end;

function g_CheckRoyalBattlePoint(x,y,d:integer):boolean;
begin
   if(map_scenario=mc_royale)
   then g_CheckRoyalBattlePoint:=(point_dist_int(x,y,g_royal_Rx,g_royal_Ry)+d)>=g_royal_RCur
   else g_CheckRoyalBattlePoint:=false;
end;

procedure Game_SetStatusWinnerTeam(team:byte);
begin
   if(team>LastPlayer)then exit;

   g_status:=gs_win_team0+team;
   GameLog_EndGame(team);
end;

function Game_IsEnded:boolean;
begin
   Game_IsEnded:=(gs_win_team0<=g_status)and(g_status<=gs_win_team7);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   RANDOM
//

function g_random(m:integer):integer;
const a = 4;
      t : array[byte] of byte = (
//0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
0  ,   8, 109, 220, 222, 241, 149, 107,  75, 248, 254, 140,  16,  66,  74,   21,
211,  47,  80, 242, 154,  27, 205, 128, 161,  89,  77,  36,  95, 110,  85,   48,
212, 140, 211, 249,  22,  79, 200,  50,  28, 188,  52, 140, 202, 120,  68,  145,
62 ,  70, 184, 190,  91, 197, 152, 224, 149, 104,  25, 178, 252, 182, 202,  182,
141, 197,   4,  81, 181, 242, 145,  42,  39, 227, 156, 198, 225, 193, 219,   93,
122, 175, 249,   0, 175, 143,  70, 239,  46, 246, 163,  53, 163, 109, 168,  135,
2  , 235,  25,  92,  20, 145, 138,  77,  69, 166,  78, 176, 173, 212, 166,  113,
94 , 161,  41,  50, 239,  49, 111, 164,  70,  60,   2,  37, 171,  75, 136,  156,
11 ,  56,  42, 146, 138, 229,  73, 146,  77,  61,  98, 196, 135, 106,  63,  197,
195,  86,  96, 203, 113, 101, 170, 247, 181, 113,  80, 250, 108,   7, 255,  237,
129, 226,  79, 107, 112, 166, 103, 241,  24, 223, 239, 120, 198,  58,  60,   82,
128,   3, 184,  66, 143, 224, 145, 224,  81, 206, 163,  45,  63,  90, 168,  114,
59 ,  33, 159,  95,  28, 139, 123,  98, 125, 196,  15,  70, 194, 253,  54,   14,
109, 226,  71,  17, 161,  93, 186,  87, 244, 138,  20,  52, 123, 251,  26,   36,
17 ,  46,  52, 231, 232,  76,  31, 221,  84,  37, 216, 165, 212, 106, 197,  242,
98 ,  43,  39, 175, 254, 145, 190,  84, 118, 222, 187, 136, 120, 163, 236,  249
);
begin
   g_random_p+=1;
   g_random_i:=g_random_i*a+t[g_random_p];
   if(m=0)
   then g_random:=0
   else g_random:=abs(integer(g_random_i) mod m);
end;

function g_randomx(x,m:integer):integer;
begin
   if(m=0)
   then g_randomx:=0
   else
   begin
      g_random_i+=word(x);
      g_randomx:=g_random(m);
   end;
end;

function g_randomr(r:integer):integer;
begin
   if(r=0)
   then g_randomr:=0
   else g_randomr:=g_random(r)-g_random(r);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   Unit/Upgrades Checks
//

function upgrade_GetAffectedUIDs(upgr:byte):TSoB;
var u,a:byte;
begin
   upgrade_GetAffectedUIDs:=[];
   for u:=1 to 255 do
     with g_uids[u] do
     begin
        if(upgr=uid_Armor_upgr1   )
        or(upgr=uid_Armor_upgr2   )
        or(upgr=uid_Regen_upgr    )
        or(upgr=uid_MSpeed_upgr   )
        or(upgr=uid_PainState_upgr)
        or(upgr=uid_SightR_upgr      )
        or(upgr=uid_TransportMax_upgr)
        or(upgr=g_aids[uid_ability1].ua_req_upgr   )
        or(upgr=g_aids[uid_ability1].ua_rldDec_upgr)
        or(upgr=g_aids[uid_ability2].ua_req_upgr   )
        or(upgr=g_aids[uid_ability2].ua_rldDec_upgr)
        or(upgr=g_aids[uid_ability3].ua_req_upgr   )
        or(upgr=g_aids[uid_ability3].ua_rldDec_upgr)
        then upgrade_GetAffectedUIDs+=[u];

        for a:=0 to LastUnitArms  do
          with uid_arms[a] do
            if(upgr=aw_req_upgr)
            or(upgr=aw_impact_upgr)then upgrade_GetAffectedUIDs+=[u];
     end;
end;

function upgrade_GetEnergy(upgr,lvl:byte):integer;
begin
   upgrade_GetEnergy:=0;
   with g_upgrs[upgr] do
     if(0<lvl)and(lvl<=upgr_max)then
       if(upgr_renerg_xpl<=0)and(upgr_renerg_apl<=0)
       then upgrade_GetEnergy:=upgr_renerg
       else
       begin
          lvl-=1;
          upgrade_GetEnergy:=(upgr_renerg*ipower(upgr_renerg_xpl,lvl))+(upgr_renerg_apl*lvl);
       end;
end;
function upgrade_GetTime(upgr,lvl:byte):integer;
const upgr_max_time = fr_fps1*255;
begin
   upgrade_GetTime:=0;
   with g_upgrs[upgr] do
     if(0<lvl)and(lvl<=upgr_max)then
       if(upgr_time_xpl<=0)and(upgr_time_apl<=0)
       then upgrade_GetTime:=upgr_time
       else
       begin
          lvl-=1;
          upgrade_GetTime:=min2i(upgr_max_time,upgr_time*ipower(upgr_time_xpl,lvl)+(upgr_time_apl*lvl));
       end;
end;

function upgrade_CheckReqs(player:PTPlayerGameData;upgr:byte):byte;
begin
   upgrade_CheckReqs:=0;
   with player^ do
   with g_upgrs[upgr] do
   begin
      if(units_upgrProds_c<=0)then
      begin upgrade_CheckReqs:=lmt_unit_NeedProdUnit;exit;end;

      if(upgrs_max[upgr]<=0)then
      begin upgrade_CheckReqs:=lmt_prod_Unavailable;exit;end;

      if((upgrs_cur[upgr]+prod_upgr_upid[upgr])>=upgrs_max[upgr] )then  //min2i(upgr_max,)
      begin upgrade_CheckReqs:=lmt_Req_MaxCount;exit;end;

      if(upgr_ruid >0)and(units_uid_c[upgr_ruid ]=0)
      or(upgr_rupgr>0)and(upgrs_cur  [upgr_rupgr]=0)then
      begin upgrade_CheckReqs:=lmt_Req_Common;exit;end;

      if(prod_upgr_upid[upgr]>0)then
      begin upgrade_CheckReqs:=lmt_upgrade_InProgress;exit;end;

      if(upgr_time<=0)then
      begin upgrade_CheckReqs:=lmt_prod_BadOrder;exit;end;

      if(res_energyl_cur<upgrade_GetEnergy(upgr,upgrs_cur[upgr]+1))then
      begin upgrade_CheckReqs:=lmt_Req_Energy;exit;end;
   end;
end;

function player_UIDLimitCheck(player:PTPlayerGameData;uid:byte):boolean;
begin
   with player^ do
     with g_uids[uid] do
       if(uid_isbuilder)and(units_builders_e>=PlayerMaxBuilders)
       then player_UIDLimitCheck:=false
       else player_UIDLimitCheck:=((units_uid_e[uid]+prod_unit_uid[uid])<units_uid_m[uid])
                            and((units_all_e+prod_unit_Now)<MaxPlayerUnits)
                            and((armylimit+prod_unit_Limit+uid_LimitUse)<=MaxPlayerLimit);
end;

function unit_CheckReqs(player:PTPlayerGameData;uid:byte;checkExtraEnergy:integer=0):byte;
begin
   unit_CheckReqs:=0;
   with player^ do
   with g_uids[uid] do
   begin
      case uid_isbuilding of
true  : begin
           if(units_builders_c<=0)then begin unit_CheckReqs:=lmt_unit_NeedBuilder;exit;end;
           if(build_cd        > 0)then begin unit_CheckReqs:=lmt_prod_CD;         exit;end;
        end;
false : if(units_unitProds_c<=0)then begin unit_CheckReqs:=lmt_unit_NeedProdUnit;exit;end;
      end;

      if(uid_MaxHits1<=0)then begin unit_CheckReqs:=lmt_prod_BadOrder;exit;end;

      if(units_uid_m[uid]<=0)then begin unit_CheckReqs:=lmt_prod_Unavailable;exit;end;

      if((uid_isbuilder)and(units_builders_e>=PlayerMaxBuilders))then
      begin unit_CheckReqs:=lmt_Req_MaxBuilders;exit;end;

      if((units_uid_e[uid]+prod_unit_uid[uid])>=units_uid_m[uid])then
      begin unit_CheckReqs:=lmt_Req_MaxCount;exit;end;

      if((uid_req_uid1>0)and(units_uid_c[uid_req_uid1]<uid_req_uid1n))
      or((uid_req_uid2>0)and(units_uid_c[uid_req_uid2]<uid_req_uid2n))
      or((uid_req_uid3>0)and(units_uid_c[uid_req_uid3]<uid_req_uid3n))
      or((uid_req_upgr>0)and(upgrs_cur  [uid_req_upgr]=0            ))then
      begin unit_CheckReqs:=lmt_Req_Common;exit;end;

      if((units_all_e+prod_unit_Now             )>=MaxPlayerUnits)
      or((armylimit+prod_unit_Limit+uid_LimitUse)> MaxPlayerLimit)then
      begin unit_CheckReqs:=lmt_Req_Limit;exit;end;

      if(uid_req_HellPower>0)and(res_HellPower<uid_req_HellPower)then begin unit_CheckReqs:=lmt_Req_HellPower;exit;end;
      if(uid_req_UACLoot  >0)and(res_UACLoot  <uid_req_UACLoot  )then begin unit_CheckReqs:=lmt_Req_UACLoot;  exit;end;

      if(uid_isbuilding and(res_energyl_max<=0))
      or(res_energyl_cur<0)then begin unit_CheckReqs:=lmt_Req_Energy;exit;end;

      if(uid_req_EnergyLevel>0)then
        case(state=ps_AI)and(uid_isbuilder)of
        false: if(res_energyl_cur<(uid_req_EnergyLevel+checkExtraEnergy))then
               begin unit_CheckReqs:=lmt_Req_Energy;exit;end;   //energyCur_BldGens    energyCur_transforms
        true : if((res_energyl_cur+energyCur_units+energyCur_upgrades+energyCur_BldOther-checkExtraEnergy)<uid_req_EnergyLevel)
               or(res_energyl_max<(uid_req_EnergyLevel+checkExtraEnergy))then
               begin unit_CheckReqs:=lmt_Req_Energy;exit;end;
        end;
   end;
end;

function unit_PossibleTransports(uid:byte):boolean;
var u:byte;
begin
   unit_PossibleTransports:=false;
   for u:=1 to 255 do
     with g_uids[u] do
       if(uid in ups_TransportUIDs)then
       begin
          unit_PossibleTransports:=true;
          break;
       end;
end;

function unit_IsProducting(pu:PTUnit):boolean;
var i:byte;
begin
   unit_IsProducting:=false;
   with pu^  do
   with uid^ do
     if(uid_isbarrack)or(uid_isforge)then
       for i:=0 to LastUnitLevel do
       begin
          if(i>level)then break;
          if((uid_isbarrack)and(uprod_r[i]>0))
          or((uid_isforge  )and(pprod_r[i]>0))then
          begin
             unit_IsProducting:=true;
             exit;
          end;
       end;
end;

function unit_OrderCheckProdCancel(pu:pTunit):boolean;
begin
   unit_OrderCheckProdCancel:=true;
   with pu^ do
   with uid^ do
    if(not iscomplete)
    then exit
    else
     if(transformTimer>0)
     then exit
     else
      if(unit_IsProducting(pu))
      then exit;
   unit_OrderCheckProdCancel:=false;
end;

function unit_OrderCheckForge(pu:pTunit;oid:byte):boolean;
begin
   unit_OrderCheckForge:=true;
   with pu^     do
   with uid^    do
   with player^ do
     if(uid_isforge)then
       if(oid in uid_prod_Upgrades)or(oid=255)then
         if(units_upgrProds_s<=0)or(isselected)then exit;
   unit_OrderCheckForge:=false;
end;
function unit_OrderCheckBarrack(pu:pTunit;oid:byte):boolean;
begin
   unit_OrderCheckBarrack:=true;
   with pu^     do
   with uid^    do
   with player^ do
     if(uid_isbarrack)then
       if(oid in uid_prod_Units)or(oid=255)then
         if(units_unitProds_s<=0)or(isselected)then exit;
   unit_OrderCheckBarrack:=false;
end;
function unit_ReadyForAbilityOrder(pu:PTUnit):boolean;
begin
   with pu^ do
   with player^ do
     unit_ReadyForAbilityOrder:=(units_all_s=1)or
                               ((uo_id<>ua_ability1)
                             and(uo_id<>ua_ability2)
                             and(uo_id<>ua_ability3));
end;

function unit_OrderCheckAbility(pu:PTUnit;aid:byte):boolean;
begin
   unit_OrderCheckAbility:=false;
   with pu^ do
   with uid^ do
     if(uid_ability1=aid)
     or(uid_ability2=aid)
     or(uid_ability3=aid)then
       unit_OrderCheckAbility:=unit_ReadyForAbilityOrder(pu);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   OTHER
//

function hits_li2si(h,mh:longint;s:single):shortint;
begin
   if(h<=hits_ndead                 )
   or(s.IsNan     )
   or(s.IsInfinity)
   or(mh<=0)                         then hits_li2si:=-128 else
   if(s<=0)                          then hits_li2si:=-128 else
   if(h =hits_dead                  )then hits_li2si:=-127 else
   if(hits_fdead<h)and(h<0          )then hits_li2si:=mm3i(-125,h div _d2shi,-1  ) else
   if(h =0                          )then hits_li2si:= 0   else
   if(h>=mh                         )then hits_li2si:= 127 else
   if( hits_dead<h)and(h<=hits_fdead)then hits_li2si:=-126 else
                                          hits_li2si:=mm3i(   1,trunc(h/s)  ,sintMaxHits);
end;

function ai_name(ain,playerN:byte):shortstring;
begin
   if(ain=0)
   then ai_name:=''
   else
   begin
      ai_name:=str_ps_AI+b2s(ain);
      if(playerN<=LastPlayer)then
        ai_name+=ai_names_l[(map_seed+playerN) mod ai_names_max];
   end;
end;

function CheckUnitBaseFlags(tu:PTUnit;flags:cardinal;skipFlyCheck:boolean=false):boolean;
begin
   CheckUnitBaseFlags:=false;

   if((flags and wtr_unit    )=0)and(not tu^.uid^.uid_isbuilding)then exit;
   if((flags and wtr_building)=0)and(    tu^.uid^.uid_isbuilding)then exit;

   if((flags and wtr_bio     )=0)and(not tu^.uid^.uid_ismech    )then exit;
   if((flags and wtr_mech    )=0)and(    tu^.uid^.uid_ismech    )then exit;

   if((flags and wtr_light   )=0)and    (tu^.uid^.uid_islight   )then exit;
   if((flags and wtr_heavy   )=0)and not(tu^.uid^.uid_islight   )then exit;

   if(not skipFlyCheck)then
   begin
   if((flags and wtr_ground  )=0)and(tu^.isfly = uf_ground      )then exit;
   if((flags and wtr_fly     )=0)and(tu^.isfly = uf_fly         )then exit;
   end;

   CheckUnitBaseFlags:=true;
end;

function CheckUnitTeamVision(POVTeam:byte;pTarget:PTUnit;SkipInvisCheck:boolean):boolean;
begin
   with pTarget^ do
     if(buffs[ub_Invisibility]<=0)or(hits<=0)or(SkipInvisCheck)
     then CheckUnitTeamVision:=(TeamVision[POVTeam]>0)
     else CheckUnitTeamVision:=(TeamVision[POVTeam]>0)and(TeamDetection[POVTeam]>0);
end;

procedure UnitOrderSetNearestTarget(taru:PTUnit;cx,cy:integer;ptaru:PPTunit;pdist:pinteger;pPriority:pboolean;cPriority,noReload:boolean;closest:boolean);
var d:integer;
begin
   d:=point_dist_int(cx,cy,taru^.x,taru^.y);

   if(cPriority>pPriority^)then
   begin
      ptaru^    :=taru;
      pdist^    :=d;
      pPriority^:=cPriority;
   end
   else
     if(cPriority=pPriority^)then
       case cPriority or noReload of
       true : if(    closest and(d<pdist^))
              or(not closest and(d>pdist^))then
              begin
                 pdist^:=d;
                 ptaru^:=taru;
              end;
       false: if(taru^.rld<pdist^)then
              begin
                 pdist^:=taru^.rld;
                 ptaru^:=taru;
              end;
       end;
end;

function unit_GetCastingAbility(pu:PTUnit):byte;
begin
   unit_GetCastingAbility:=0;
   with pu^ do
   with uid^ do
     case uo_id of
     ua_ability1: unit_GetCastingAbility:=uid_ability1;
     ua_ability2: unit_GetCastingAbility:=uid_ability2;
     ua_ability3: unit_GetCastingAbility:=uid_ability3;
     end;
end;

function ability_CheckTarget(aid:byte;pCasterPlayer,pTargetPlayer:PTPlayerGameData):boolean;
begin
   ability_CheckTarget:=false;
   with g_aids[aid] do
     case ua_type of
     uat_UnitAny  :;
     uat_UnitOwn  : if(pCasterPlayer      <>pTargetPlayer      )then exit;
     uat_UnitAlly : if(pCasterPlayer^.team<>pTargetPlayer^.team)then exit;
     uat_UnitEnemy: if(pCasterPlayer^.team= pTargetPlayer^.team)then exit;
     else exit;
     end;
   ability_CheckTarget:=true;
end;


{$IFDEF _FULLGAME}

procedure WriteLog(mess:shortstring);
var f:Text;
begin
   Assign(f,outlogfn);
   if FileExists(outlogfn)
   then Append (f)
   else Rewrite(f);
   writeln(f,mess);
   {$IFDEF CONSOLE}
   writeln(mess);
   {$ENDIF}
   Close(f);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   APM
//

procedure apm_Inc;
begin
   with g_PlayerAPM do
     apm_history_l[apm_history_p]+=1;
end;

procedure apm_Calc;
var i:word;
apm_new:word;
begin
   with g_PlayerAPM do
   begin
      apm_new:=0;
      for i:=0 to apm_period_ticks do apm_new+=apm_history_l[i];
      apm_new:=round(apm_new*apm_period_min);

      apm_cur+=sign(apm_new-apm_cur);

      apm_history_p+=1;
      if(apm_history_p>apm_period_ticks)then apm_history_p:=0;
      apm_history_l[apm_history_p]:=0;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   INPUT
//

function InputAction(iact:byte):boolean;
begin
   with input_actions[iact] do
     InputAction:=(ik_kstate=ks_pressed)
                or(ik_kstate=ks_hold   )
                or(ik_kstate=ks_both   );
end;
function InputActionPressed(iact:byte):boolean;
begin
   with input_actions[iact] do
     InputActionPressed:=(ik_kstate=ks_pressed)
                       or(ik_kstate=ks_both   );
end;
function InputActionStuck(iact:byte):boolean;
begin
   with input_actions[iact] do
     InputActionStuck:=(ik_kstate=ks_hold)
                    and(ik_timer_pressed>k_LastCharStuckDelay);
end;
function InputActionStuckP(iact:byte;period:integer=fr_fps1 div fr_fpsq):boolean;
begin
   InputActionStuckP:=false;
   if(period>0)then
     with input_actions[iact] do
       InputActionStuckP:=(ik_kstate=ks_hold)
                      and (ik_timer_pressed>k_LastCharStuckDelay)
                      and((ik_timer_pressed mod period)=0);
end;
function InputActionReleased(iact:byte):boolean;
begin
   with input_actions[iact] do
     InputActionReleased:=(ik_kstate=ks_released)
                        or(ik_kstate=ks_both   );
end;
function InputActionDPressed(iact:byte):boolean;
begin
   with input_actions[iact] do
     InputActionDPressed:=((ik_kstate=ks_pressed)or(ik_kstate=ks_both))
                       and(ik_timer_twice>0);
end;

function iActOn(iact:byte):boolean;
begin
   iActOn:=input_actions[iact].ik_astate>as_off;
end;
function iActEnabled(iact:byte):boolean;
begin
   iActEnabled:=input_actions[iact].ik_astate=as_enabled;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   GAME
//

function GameGetStatus(gstatus:byte;pstr:pshortstring;pcol:PTMWColor;POVPlayer:byte):boolean;
function GetLagPlayers:shortstring;
var p:byte;
begin
   GetLagPlayers:='';
   for p:=0 to LastPlayer do
     with g_PlayersTemp[p] do
     with g_PlayersGame[p] do
       if(state=ps_human)and(not isobserver)and(not isdefeated)and(net_ttl>=fr_fps1)then
         STRADD(@GetLagPlayers,name+'('+b2s((TTLMaxClientGame-net_ttl) div fr_fps1)+')',sep_comma);
end;
procedure SetS(str:shortstring;add:boolean=false);
begin
   if(pstr=nil)then exit;
   if(add)
   then pstr^+=str
   else pstr^:=str;
end;
procedure SetC(col:cardinal);
begin
   if(pcol<>nil)then pcol^:=col;
end;
begin
   GameGetStatus:=false;

   if(gstatus<>gs_running)then
   begin
      GameGetStatus:=true;
      SetS(str_gstat_Unknown);
      SetC(c_gray);

      case gstatus of
gs_paused0..
gs_paused7    : begin
                   SetS(str_gstat_GamePaused+g_PlayersGame[gstatus-gs_paused0].name);
                   SetC(PlayerGetColorDef(gstatus-gs_paused0));
                end;
gs_replayerror: begin
                   SetS(str_gstat_ReplayError+rpls_file_LastErrS);
                   SetC(c_white);
                end;
gs_replayend  : begin
                   SetS('');
                   SetC(c_white);
                end;
gs_replaypause: begin
                   SetS(str_gstat_ReplayPaused);
                   SetC(c_white);
                end;
gs_waitserver : begin
                   SetS(str_gstat_WaitForServer);
                   if(net_cl_Hoster<=LastPlayer)then
                   begin
                      SetS(tc_nl2+'('+g_PlayersGame[net_cl_Hoster].name+')',true);
                      SetC(PlayerGetColorDef(gstatus-gs_paused0));
                   end
                   else SetC(PlayerColorDefaultNormal);
                end;
gs_waitplayers: begin
                   SetS(str_gstat_WaitForPlayers);
                   if(rpls_pstate<>rpls_read)then
                     SetS(tc_nl2+GetLagPlayers,true);
                   SetC(c_white);
                end;
gs_win_team0..
gs_win_team7  : if(POVPlayer>LastPlayer)then
                begin
                   SetS(str_gstat_WonByTeam+b2s(gstatus-gs_win_team0+1));
                   SetC(c_ltgray);
                end
                else
                  if((gstatus-gs_win_team0)=g_PlayersGame[POVPlayer].team)then
                  begin
                     SetS(str_gstat_Win);
                     SetC(c_lime);
                  end
                  else
                  begin
                     SetS(str_gstat_Lose);
                     SetC(c_red);
                  end;
        end;

      if(rpls_pstate=rpls_read)and(rpls_file_pos>=rpls_file_size)then SetS(tc_nl2+tc_white+str_gstat_ReplayEnd,true);
   end;
end;

function MenuBack(offMenu,check:boolean):boolean;
begin
   MenuBack:=false;
   if(not MainMenu)then exit;

   if(g_LobbyTimer>0)and(net_status<>ns_client)then
   begin
      MenuBack:=true;
      if(check)then exit;

      g_LobbyTimer:=0;
      menu_update:=true;
      if(not offMenu)then exit;
   end;

   if(GameNetServerList(false,check))then
   begin
      MenuBack:=true;
      if(check)then exit;

      menu_update:=true;
      if(not offMenu)then exit;
   end;

   if(menu_page<>0)then
   begin
      MenuBack:=true;
      if(check)then exit;

      menu_page:=0;
      menu_update:=true;
      if(not offMenu)then exit;
   end;

   if(not g_started)and(g_type<>0)and(net_status=ns_none)then
   begin
      MenuBack:=true;
      if(check)then exit;

      g_type:=0;
      menu_update:=true;
      if(not offMenu)then exit;
   end;

   if(g_started)then
   begin
      MenuBack:=true;
      if(check)then exit;

      MainMenu     :=false;
      menu_update  :=true;
      menu_ItemSelected:=0;
   end;
end;
procedure GameOpenMenu(force:boolean=false);
begin
   if(MainMenu)
   and(not force)then exit;

   MainMenu   :=true;
   menu_update:=true;
   menu_redraw_pause:=0;
   ui_update_mmap:=0;
   menu_ItemSelected:=0;
   snd_StopSoundSourceAll;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   UI
//

function RectInCam(x,y,hw,hh,s:integer):boolean;
begin
   if(s<0)then s:=0;
   RectInCam:=((ui_cam_x-hw  )<x)and(x<(ui_cam_x+ui_cam_w+hw))
           and((ui_cam_y-hh-s)<y)and(y<(ui_cam_y+ui_cam_h+hh));
end;
function PointInCam(x,y:integer):boolean;
begin
   PointInCam:=(ui_cam_x<x)and(x<(ui_cam_x+ui_cam_w))
            and(ui_cam_y<y)and(y<(ui_cam_y+ui_cam_h));
end;

procedure PlayersUpdateColorSchema(POVPlayer:byte);
var p,t:byte;
function PlayerGetCurrentTeam(player:byte):byte;
begin
   if(player>LastPlayer)
   then PlayerGetCurrentTeam:=LastPlayer
   else
     if(map_scenario in mc_fixed_teams)
     then PlayerGetCurrentTeam:=PlayerGetFixedTeams(map_scenario,player)
     else
       with g_PlayersGame[player] do
         if(g_Started)or(state>ps_none)
         then PlayerGetCurrentTeam:=team
         else PlayerGetCurrentTeam:=player;
end;
begin
   for p:=0 to LastPlayer do
   begin
      {
      0
      1 tc_lime  +'own ' +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
      2 tc_white +'own ' +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
      3 tc_white +'own ' +tc_aqua  +'ally '+tc_red+'enemy'+tc_default;
      4 tc_purple+'teams'+tc_default;
      5 tc_white +'own ' +tc_purple+'teams'+tc_default;
      }
      case ui_PlayersColor of
      1,
      2,
      3 : if(p=POVPlayer)then
            case ui_PlayersColor of
            1: PlayerColorsSchemeCurNormal[p]:=c_lime;
            2,
            3: PlayerColorsSchemeCurNormal[p]:=c_white;
            end
          else
            if(PlayerGetCurrentTeam(POVPlayer)<>PlayerGetCurrentTeam(p))
            then PlayerColorsSchemeCurNormal[p]:=c_red
            else
              case ui_PlayersColor of
              1,
              2: PlayerColorsSchemeCurNormal[p]:=c_yellow;
              3: PlayerColorsSchemeCurNormal[p]:=c_aqua;
              end;
      4,
      5: if(p=POVPlayer)and(ui_PlayersColor=5)
         then PlayerColorsSchemeCurNormal[p]:=c_white
         else
         begin
            t:=PlayerGetCurrentTeam(p);
            case t of
            0,2,4,6: PlayerColorsSchemeCurNormal[p]:=PlayerColorsSchemeDefault[(t+6) mod MaxPlayers];
            1,3,5,7: PlayerColorsSchemeCurNormal[p]:=PlayerColorsSchemeDefault[ t   mod MaxPlayers];
            end;
         end;
      else PlayerColorsSchemeCurNormal[p]:=PlayerColorsSchemeDefault[p];
      end;
      PlayerColorsSchemeCurShadow[p]:=gfx_ShadowColor(PlayerColorsSchemeCurNormal[p]);
   end;
end;

function PlayerGetColorDef(player:byte):TMWColor;
begin
   if(player>LastPlayer)
   then PlayerGetColorDef:=PlayerColorDefaultNormal
   else PlayerGetColorDef:=PlayerColorsSchemeDefault[player];
end;

function PlayerGetColorCur(player:byte;shadow:boolean):TMWColor;
begin
   if(player>LastPlayer)then
     case shadow of
     true : PlayerGetColorCur:=PlayerColorDefaultShadow;
     false: PlayerGetColorCur:=PlayerColorDefaultNormal;
     end
   else
     if(shadow)
     then PlayerGetColorCur:=PlayerColorsSchemeCurShadow[player]
     else PlayerGetColorCur:=PlayerColorsSchemeCurNormal[player];
end;

function KeyPoint_GetColor(keyPoint:byte;shadow:boolean):TMWColor;
begin
   case shadow of
   false: KeyPoint_GetColor:=PlayerColorDefaultNormal;
   true : KeyPoint_GetColor:=PlayerColorDefaultShadow;
   end;
   if(keyPoint>LastKeyPoint)then exit;
   with map_KeyPointsL[keyPoint] do
     with kp_TeamData[KeyPoint_GetPlayerTeam(UIPlayer)] do
       if(kptd_Active)then
         if(kptd_Timer>0)and(ui_blink3=0)
         then KeyPoint_GetColor:=PlayerGetColorCur(kptd_TimerOwnerPlayer,shadow)
         else KeyPoint_GetColor:=PlayerGetColorCur(kptd_OwnerPlayer     ,shadow);
end;

function ui_SetUIPlayer(NewPlayerN:byte;check:boolean):boolean;
begin
   ui_SetUIPlayer:=false;

   if(NewPlayerN<>255)then
   begin
      if(NewPlayerN>=map_MaxPlayers)
      or(NewPlayerN>LastPlayer)then exit;

      with g_PlayersGame[NewPlayerN] do
        if(NewPlayerN<>LocalPlayer)then
          if((isobserver)and(not isdefeated))
          or(state=ps_None)then exit;
   end;
   ui_SetUIPlayer:=true;

   if(check)then exit;

   UIPlayer:=NewPlayerN;
end;

function ui_ObserverPov(POVPlayer:byte):boolean;
begin
   ui_ObserverPov:=false;
   if(POVPlayer>LastPlayer)
   or(POVPlayer=LocalPlayer)
   then exit
   else
     with g_PlayersTemp[POVPlayer] do
     with g_PlayersGame[POVPlayer] do
       if(cam_w<=0)
       or(cam_h<=0)
       or(state<>ps_human)then exit;

   ui_ObserverPov:=true;
end;

function ui_ControlTabTypeF:TTabControlContent;
begin
   ui_ControlTabTypeF:=tcc_none;
   if(rpls_pstate>=rpls_read)
   then ui_ControlTabTypeF:=tcc_replay
   else
     if((g_PlayersGame[LocalPlayer].isobserver)or(Game_IsEnded))and(g_type<>gt_campaing)
     then ui_ControlTabTypeF:=tcc_observer
     else ui_ControlTabTypeF:=tcc_controls;
end;

function ui_UnitNeedDrawRange(pu:PTUnit):boolean;
begin
   with pu^  do
    with uid^ do
     ui_UnitNeedDrawRange:=(uid_CanAttack)
                         or(uid_isbuilder and not isfly)
                         or(uid_isdetector);
end;

function ui_MouseBrushNeedDrawEdges:boolean;
begin
   ui_MouseBrushNeedDrawEdges:=true;
   case m_brush of
   1..255     : exit;
   -255..-1   : with g_aids[-m_brush] do
                  case ua_mbrush_r of
                  -255..-1,
                  uambt_self: exit;
                  end;
   end;
   ui_MouseBrushNeedDrawEdges:=false;
end;
function ui_AbilityGetBrushR(aid:byte;pCaster:PTUnit):integer;
begin
   ui_AbilityGetBrushR:=0;
   with g_aids[aid] do
     case ua_mbrush_r of
     -255..-1    : ui_AbilityGetBrushR:=g_uids[-ua_mbrush_r].uid_r;
     uambt_sightR: if(pCaster<>nil)then ui_AbilityGetBrushR:=pCaster^.srange;
     uambt_self  : if(pCaster<>nil)then ui_AbilityGetBrushR:=pCaster^.uid^.uid_r;
     else          ui_AbilityGetBrushR:=ua_mbrush_r;
     end;
end;
function ui_AbilityGetBrushSpr(aid,casterUID:byte):pTMWTexture;
begin
   ui_AbilityGetBrushSpr:=pspr_dummy;
   with g_aids[aid] do
     case ua_mbrush_r of
     -255..-1   : ui_AbilityGetBrushSpr:=gfx_uid2spr(-ua_mbrush_r,270,0);
     uambt_self : ui_AbilityGetBrushSpr:=gfx_uid2spr(casterUID   ,270,0);
     end;
end;
function unit_AbilityGetUIDRef(aid,casterUID:byte):byte;
begin
   unit_AbilityGetUIDRef:=0;
   with g_aids[aid] do
     case ua_mbrush_r of
     -255..-1   : unit_AbilityGetUIDRef:=byte(-ua_mbrush_r);
     uambt_self : unit_AbilityGetUIDRef:=casterUID;
     end;
end;

function ui_fog_CheckXY(x,y:integer):boolean;
var cx,cy:integer;
begin
   x+=ui_cam_fx;
   y+=ui_cam_fy;
   cx:=x div fog_cw;
   cy:=y div fog_cw;
   ui_fog_CheckXY:=false;
   if(0<=cx)and(cx<ui_fog_gridw)
  and(0<=cy)and(cy<ui_fog_gridh)then ui_fog_CheckXY:=ui_fog_pgrid[cx,cy];
end;

function ui_CheckUnitUIPlayerVision(tu:PTUnit;CheckCam:boolean):boolean;
begin
   if(tu=nil)then
   begin
      ui_CheckUnitUIPlayerVision:=false;
      exit;
   end;

   ui_CheckUnitUIPlayerVision:=true;

   if(CheckCam)then
     with tu^ do
       with uid^ do
         if(not RectInCam(vx,vy,uid_r,uid_r,0))then
         begin
            ui_CheckUnitUIPlayerVision:=false;
            exit;
         end;

   if(not ui_fog)then exit;

   if(UIplayer>LastPlayer)then
   begin
      if(ui_ControlTabType in [tcc_observer,tcc_replay])then exit;
   end
   else
      if(tu^.TeamVision[g_PlayersGame[UIplayer].team]>0)then exit;

   ui_CheckUnitUIPlayerVision:=false;
end;

function ui_CheckUnitFullFogReveal(tu:PTUnit):boolean;
begin
   ui_CheckUnitFullFogReveal:=false;
   if(tu=nil)then exit;

   if(ui_ControlTabType in [tcc_observer,tcc_replay])then
   begin
      if(UIPlayer>LastPlayer)
      then ui_CheckUnitFullFogReveal:=true
      else
        if(tu^.player^.team=g_PlayersGame[UIPlayer].team)then ui_CheckUnitFullFogReveal:=true;
   end
   else ui_CheckUnitFullFogReveal:=(tu^.player^.team=g_PlayersGame[LocalPlayer].team);
end;

function ui_CheckMapPointFogVision(x,y:integer;CheckSquare:boolean):boolean;
begin
   ui_CheckMapPointFogVision:=false;
   x-=ui_cam_x;
   y-=ui_cam_y;
   if(-fog_cw<x)and(x<(ui_cam_w+fog_cw))and
     (-fog_cw<y)and(y<(ui_cam_h+fog_cw))then
   begin
      if(not ui_fog)
      then ui_CheckMapPointFogVision:=true
      else ui_CheckMapPointFogVision:=ui_fog_CheckXY(x,y);
      if(CheckSquare)and(not ui_CheckMapPointFogVision)then
      begin
         x+=ui_cam_x;
         y+=ui_cam_y;
         ui_CheckMapPointFogVision:=ui_CheckMapPointFogVision(x-fog_cw,y       ,false)or
                                    ui_CheckMapPointFogVision(x+fog_cw,y       ,false)or
                                    ui_CheckMapPointFogVision(x       ,y+fog_cw,false)or
                                    ui_CheckMapPointFogVision(x       ,y-fog_cw,false)or
                                    ui_CheckMapPointFogVision(x-fog_cw,y-fog_cw,false)or
                                    ui_CheckMapPointFogVision(x+fog_cw,y-fog_cw,false)or
                                    ui_CheckMapPointFogVision(x+fog_cw,y+fog_cw,false)or
                                    ui_CheckMapPointFogVision(x-fog_cw,y+fog_cw,false);
      end;
   end;
end;

procedure ui_Camera_Bounds;
var
bx0,bx1,
by0,by1:integer;
begin
   bx0:=0;
   by0:=0;
   bx1:=map_Size1-ui_cam_w;
   by1:=map_Size1-ui_cam_h;
   case ui_ControlPanelPos of
   cpp_left  : bx0-=ui_UIPanelW;
   cpp_right : bx1+=ui_UIPanelW;
   cpp_top   : by0-=ui_UIPanelH;
   cpp_bottom: by1+=ui_UIPanelH;
   end;

   ui_cam_x  :=mm3i(bx0,ui_cam_x,bx1);
   ui_cam_y  :=mm3i(by0,ui_cam_y,by1);

   ui_cam_cx :=ui_cam_x+ui_cam_hw;
   ui_cam_cy :=ui_cam_y+ui_cam_hh;
   ui_cam_mmx:=round(ui_cam_x*map_MiniMap_cx);
   ui_cam_mmy:=round(ui_cam_y*map_MiniMap_cx);
   ui_cam_fx :=ui_cam_x mod fog_cw;
   ui_cam_fy :=ui_cam_y mod fog_cw;
   ui_fog_sx :=ui_cam_x div fog_cw;
   ui_fog_sy :=ui_cam_y div fog_cw;
   ui_fog_ex :=ui_fog_sx+ui_fog_gridw;
   ui_fog_ey :=ui_fog_sy+ui_fog_gridh;
end;

procedure ui_Camera_MoveToPoint(mx,my:integer);
begin
   ui_cam_x:=mx-ui_cam_hw;
   ui_cam_y:=my-ui_cam_hh;
   case ui_ControlPanelPos of
   cpp_left  : ui_cam_x-=ui_CtrlPanelWh;
   cpp_right : ui_cam_x+=ui_CtrlPanelWh;
   cpp_top   : ui_cam_y-=ui_CtrlPanelWh;
   cpp_bottom: ui_cam_y+=ui_CtrlPanelWh;
   end;
   ui_Camera_Bounds;
end;

procedure ui_Camera_MoveToGroup(pugroup:pTUnitGroup);
begin
   if(pugroup=nil)then exit;
   with pugroup^ do
     if(ugroup_n>0)then
       ui_Camera_MoveToPoint(ugroup_x,ugroup_y);
end;

procedure ui_Camera_ToLastEvent;
var log_pi:cardinal;
begin
   if(UIPlayer<=LastPlayer)then
     with g_PlayersGame[UIPlayer] do
     begin
        log_pi:=log_i;
        while true do
        begin
           with log_l[log_pi] do
             if(lm_x>0)or(lm_y>0)then
             begin
                ui_Camera_MoveToPoint(lm_x,lm_y);
                break;
             end;
           if(log_pi>0)
           then log_pi-=1
           else log_pi:=MaxPlayerLog;
           if(log_pi=log_i)then exit;
        end;
     end;
end;

function ui_CommanderWeight(pu:PTUnit):word;
begin
   ui_CommanderWeight:=0;
   with pu^ do
   with uid^ do
   begin
      if(uid_HaveAbility   )then ui_CommanderWeight+=2048;
      if(not uid_isbuilding)then ui_CommanderWeight+=1024;
      if(not uid_isbuilder )then ui_CommanderWeight+=512;
      if(not uid_isbarrack )then ui_CommanderWeight+=256;
      if(not uid_isforge   )then ui_CommanderWeight+=128;
      if(not rld        <=0)then ui_CommanderWeight+=64;
   end;
end;

function ui_HaveAttack(pu:PTunit):boolean;
var w:byte;
begin
   ui_HaveAttack:=false;
   with pu^.uid^ do
   with pu^.player^ do
     if(uid_CanAttack)then
       for w:=0 to LastUnitArms do
         with uid_arms[w] do
           if(aw_reload>0)then
           begin
              if(aw_req_uid >0)and(units_uid_c[aw_req_uid ]<=0)then continue;
              if(aw_req_upgr>0)and(upgrs_cur  [aw_req_upgr] =0)then continue;
              ui_HaveAttack:=true;
              break;
           end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   UI LOG
//

function ParseLogMessage(ptlog:PTLogMes;mcolor:pTMWColor):shortstring;
procedure AddDataStr;
begin
   with ptlog^ do
     if(lm_data_u>0)then
       case lm_data_t of
       lmt_argt_unit   : with g_uids [lm_data_u] do ParseLogMessage+=' ('+uid_str_name +')';
       lmt_argt_upgrade: with g_upgrs[lm_data_u] do ParseLogMessage+=' ('+upgr_str_Name+')';
       lmt_argt_ability: ParseLogMessage+=' ('+str_AbilityHintName(lm_data_u,255)+')';
       end;
end;
function Team2Name(ateam:byte):shortstring;
var
p,pnt,lp:byte;
begin
   Team2Name:='';
   pnt:=0;
   lp :=255;
   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
       if(not isdefeated)and(not isobserver)and(team=ateam)then
       begin
          pnt+=1;
          lp :=p;
       end;

   if(pnt=0)
   then
   else
     if(pnt=1)
     then Team2Name:=g_PlayersGame[lp].name
     else Team2Name:=str_PT_Team+' #'+b2s(ateam+1);
end;
begin
   ParseLogMessage:='';
   mcolor^:=c_white;
   with ptlog^ do
     case lm_type of
lmt_chat_player0..
lmt_chat_player7      : if(length(lm_string)>0)then
                        begin
                           mcolor^:=PlayerGetColorDef(lm_type-lmt_chat_player0);
                           if(lm_data_t=0)
                           then ParseLogMessage:=str_ui_ChatAll   +'> '+lm_string
                           else ParseLogMessage:=str_ui_ChatAllies+'> '+lm_string;
                        end;
lmt_chat_local        : ParseLogMessage:=lm_string;
lmt_Req_Limit         : ParseLogMessage:=str_warn_MaxLimitReached;
lmt_Req_MaxCount      : ParseLogMessage:=str_warn_MaxCountReached;
lmt_Req_MaxBuilders   : ParseLogMessage:=str_warn_MaxBuildersReached;
lmt_Req_Common,
lmt_Req_Energy,
lmt_Req_HellPower,
lmt_Req_UACLoot,
lmt_unit_MaxLevel,
lmt_prod_Unavailable,
lmt_prod_BadOrder,
lmt_prod_CD,
lmt_prod_BadPlace     : begin
                           case lm_type of
                           lmt_Req_Common      : ParseLogMessage:=str_warn_Req_Common;
                           lmt_Req_Energy      : ParseLogMessage:=str_warn_Req_Energy;
                           lmt_Req_HellPower   : ParseLogMessage:=str_warn_Req_HellPower;
                           lmt_Req_UACLoot     : ParseLogMessage:=str_warn_Req_UACLoot;
                           lmt_unit_MaxLevel   : ParseLogMessage:=str_warn_unit_MaxLevel;
                           lmt_prod_Unavailable: ParseLogMessage:=str_warn_prod_Unavailable;
                           lmt_prod_BadOrder   : ParseLogMessage:=str_warn_prod_BadOrder;
                           lmt_prod_CD         : ParseLogMessage:=str_warn_prod_CD;
                           lmt_prod_BadPlace   : ParseLogMessage:=str_warn_prod_BadPlace;
                           end;
                           AddDataStr;
                        end;
lmt_prod_AllBusy      : ParseLogMessage:=str_warn_prod_AllBusy;

lmt_player_connected  : ParseLogMessage:=lm_string+str_gmsg_PlayerConnected;
lmt_player_leave      : ParseLogMessage:=lm_string+str_gmsg_PlayerLeave;
lmt_player_timeout    : ParseLogMessage:=lm_string+str_gmsg_PlayerTimeOut;
lmt_player_surrender  : ParseLogMessage:=lm_string+str_gmsg_PlayerSurrender;
lmt_player_defeated   : ParseLogMessage:=lm_string+str_gmsg_PlayerDefeat;
lmt_player_revealed   : if(lm_data_t>0)
                        then ParseLogMessage:=lm_string+str_gmsg_PlayerRevealed
                        else ParseLogMessage:=lm_string+str_gmsg_PlayerNoRevealed;
lmt_player_ready,
lmt_player_nready     : ParseLogMessage:=lm_string+str_lobby_PlayerReady[lm_type=lmt_player_ready];
lmt_game_Paused       : ParseLogMessage:=lm_string+str_gmsg_PlayerPaused;
lmt_game_Resumed      : ParseLogMessage:=lm_string+str_gmsg_PlayerResumed;
lmt_game_message      : ParseLogMessage:=lm_string;
lmt_game_end          : if(lm_data_u<=LastPlayer)and(UIPlayer<=LastPlayer)then
                          if(lm_data_u=g_PlayersGame[UIPlayer].team)
                          then ParseLogMessage:=str_gstat_Win
                          else ParseLogMessage:=str_gstat_Lose;
lmt_game_ReadyToStart : ParseLogMessage:=str_lobby_ReadyToStart;
lmt_game_BreakStarting: ParseLogMessage:=str_lobby_BreakStarting;
lmt_game_StartsIn     : ParseLogMessage:=str_lobby_GameStartIn+b2s(lm_data_u);
lmt_game_ResetIn      : ParseLogMessage:=str_lobby_GameResetIn+b2s(lm_data_u);

lmt_upgrade_InProgress: ParseLogMessage:=str_warn_upgrade_InProgress;
lmt_upgrade_complete  : begin
                           with g_upgrs[lm_data_u] do ParseLogMessage:=str_warn_upgrade_complete+' ('+upgr_str_Name+')';
                           mcolor^:=c_yellow;
                        end;
lmt_unit_readyU,
lmt_unit_readyB       : begin
                           with g_uids[lm_data_u] do
                             case lm_data_t of
                             lmt_argt_unit : if(uid_isbuilding)
                                             then ParseLogMessage:=str_warn_building_complete+' ('+uid_str_name+')'
                                             else ParseLogMessage:=str_warn_unit_complete    +' ('+uid_str_name+')';
                             end;
                           mcolor^:=c_green;
                        end;
lmt_unit_resurrected  : begin
                           mcolor^:=c_dorange;
                           ParseLogMessage:=str_warn_unit_resurrected;
                           AddDataStr;
                        end;
lmt_unit_captured     : begin
                           ParseLogMessage:=str_warn_unit_captured;
                           AddDataStr;
                        end;
lmt_unit_lost         : begin
                           ParseLogMessage:=str_warn_unit_lost;
                           AddDataStr;
                        end;
lmt_unit_LevelUp      : begin
                           with g_uids[lm_data_u] do ParseLogMessage:=str_warn_unit_Levelup+' ('+uid_str_name+')';
                           mcolor^:=c_blue;
                        end;
lmt_allies_attackedU,
lmt_allies_attackedB  : begin
                           with g_uids[lm_data_u] do
                             ParseLogMessage:=str_warn_allies_attacked+' ('+uid_str_name+')';
                           mcolor^:=c_orange;
                        end;
lmt_unit_attackedU,
lmt_unit_attackedB    : begin
                           with g_uids[lm_data_u] do
                             case lm_type of
                             lmt_unit_attackedU: ParseLogMessage:=str_warn_unit_attacked+' ('+uid_str_name+')';
                             lmt_unit_attackedB: ParseLogMessage:=str_warn_base_attacked+' ('+uid_str_name+')';
                             end;
                           mcolor^:=c_red;
                        end;

lmt_kpoint_CaptureStart,
lmt_kpoint_Captured,
lmt_koth_CaptureStart,
lmt_koth_Alarm        : begin
                           case lm_type of
                           lmt_kpoint_CaptureStart: ParseLogMessage:=Team2Name(lm_data_u)+str_warn_kpoint_CaptureStart+b2s(lm_data_t+1);
                           lmt_kpoint_Captured    : if(map_scenario=mc_koth)
                                                    then ParseLogMessage:=Team2Name(lm_data_u)+str_ui_KotHWinner
                                                    else ParseLogMessage:=Team2Name(lm_data_u)+str_warn_kpoint_Captured+b2s(lm_data_t+1);
                           lmt_koth_CaptureStart  : ParseLogMessage:=Team2Name(lm_data_u)+str_warn_koth_CaptureStart;
                           lmt_koth_Alarm         : ParseLogMessage:=str_warn_koth_Alarm+lm_string;
                           end;
                           if(UIPlayer>LastPlayer)
                           then mcolor^:=c_ltgray
                           else
                             if(lm_data_u=g_PlayersGame[UIPlayer].team)
                             then mcolor^:=c_ltblue
                             else mcolor^:=c_ltred;
                        end;

lmt_ngen_exh,
lmt_ngen_captured,
lmt_ngen_Alarm,
lmt_ngen_lost         : begin
                           case lm_type of
                           lmt_ngen_exh     : ParseLogMessage:=str_warn_ngen_exh;
                           lmt_ngen_captured: ParseLogMessage:=str_warn_ngen_captured;
                           lmt_ngen_Alarm   : ParseLogMessage:=str_warn_ngen_Alarm;
                           lmt_ngen_lost    : ParseLogMessage:=str_warn_ngen_lost;
                           end;
                           mcolor^:=c_aqua;
                        end;
lmt_Invalid_Order,
lmt_unit_NeedProdUnit,
lmt_unit_NeedBuilder,
lmt_ability_BadPlace,
lmt_ability_reload,
lmt_ability_Casting,
lmt_ability_ReqUACNear,
lmt_ability_ReqHelNear,
lmt_ability_Tar2Close : begin
                           case lm_type of
                           lmt_Invalid_Order     : ParseLogMessage:=str_warn_Invalid_Order;
                           lmt_unit_NeedProdUnit : ParseLogMessage:=str_warn_NeedProdUnit;
                           lmt_unit_NeedBuilder  : ParseLogMessage:=str_warn_NeedBuilder;
                           lmt_ability_BadPlace  : ParseLogMessage:=str_warn_AbilityBadPlace;
                           lmt_ability_reload    : ParseLogMessage:=str_warn_AbilityReload;
                           lmt_ability_Casting   : ParseLogMessage:=str_warn_AbilityCasting;
                           lmt_ability_ReqUACNear: ParseLogMessage:=str_warn_AbilityReqUACNear;
                           lmt_ability_ReqHelNear: ParseLogMessage:=str_warn_AbilityReqHelNear;
                           lmt_ability_Tar2Close : ParseLogMessage:=str_warn_AbilityTar2Close;
                           end;
                           AddDataStr;
                        end;
lmt_invalid_Target    : ParseLogMessage:=str_warn_Invalid_Target;
lmt_markLook          : begin
                           mcolor^:=c_ltgray;
                           ParseLogMessage:=lm_string+str_warn_markLook;
                        end;
lmt_markAttack        : begin
                           mcolor^:=c_ltred;
                           ParseLogMessage:=lm_string+str_warn_markAttack;
                        end;
lmt_other_UACStrike   : begin
                           if(lm_data_u<=LastPlayer)
                           then ParseLogMessage:=g_PlayersGame[lm_data_u].name
                           else ParseLogMessage:='???';
                           ParseLogMessage+=str_warn_UACStrike;
                           mcolor^:=c_dred;
                        end;
lmt_other_UACScan     : begin
                           ParseLogMessage:=str_warn_UACScan;
                           if(lm_data_u<=LastPlayer)
                           then ParseLogMessage+=g_PlayersGame[lm_data_u].name
                           else ParseLogMessage+='???';
                           mcolor^:=c_lime;
                        end;
lmt_replay_RecStart,
lmt_replay_RecStop,
lmt_replay_RecError   : begin
                           case lm_type of
                           lmt_replay_RecStart: ParseLogMessage:=str_gmsg_RecordStart+tc_white+lm_string;
                           lmt_replay_RecStop : ParseLogMessage:=str_gmsg_RecordStop +tc_white+lm_string;
                           lmt_replay_RecError: ParseLogMessage:=str_gmsg_RecordError+tc_white+lm_string;
                           end;
                           mcolor^:=c_brown;
                        end;
     else               ParseLogMessage:='UNKNOWN MESSAGE TYPE';
                        mcolor^:=c_purple;
     end;
end;

procedure MakeLogListForDraw(playern:byte;widthChars,listHeight,listScroll:integer;logTypes:TSoB);
var
lineL :byte;
n,i   :cardinal;
chunkp,
chunkl,
chunks:integer;
aline :shortstring;
atype :byte;
acolor:TMWColor;
procedure addLine(line:shortstring;ltype:byte;color:TMWColor);
begin
   if(ui_log_n>=listHeight)then exit;
   ui_log_n+=1;
   SetLength(ui_log_lines,ui_log_n);
   SetLength(ui_log_type ,ui_log_n);
   SetLength(ui_log_color,ui_log_n);
   ui_log_lines[ui_log_n-1]:=line;
   ui_log_type [ui_log_n-1]:=ltype;
   ui_log_color[ui_log_n-1]:=color;
end;
begin
   ui_log_n:=0;
   SetLength(ui_log_lines,ui_log_n);
   SetLength(ui_log_type ,ui_log_n);
   SetLength(ui_log_color,ui_log_n);

   if(listHeight>MaxPlayerLog)then listHeight:=MaxPlayerLog;

   if(widthChars>0)and(listHeight>0)and(playern<=LastPlayer)then
     with g_PlayersGame[playern] do
     begin
        widthChars+=1;
        i:=log_i;
        while(listScroll>0)do
        begin
           if(i=0)
           then i:=MaxPlayerLog
           else i-=1;
           listScroll-=1;
        end;
        n:=listHeight;

        while(n>0)do
        begin
           acolor:=c_white;
           atype :=log_l[i].lm_type;
           if(atype in logTypes)
           then aline:=ParseLogMessage(@log_l[i],@acolor)
           else aline:='';
           lineL:=length(aline);
           if(i=0)
           then i:=MaxPlayerLog
           else i-=1;
           n-=1;

           if(lineL>0)then
             if(lineL<=widthChars)
             then addLine(aline,atype,acolor)
             else
             begin
                chunks:=lineL div widthChars;
                while(chunks>=0)do
                begin
                   chunkp:=chunks*widthChars+1;
                   if(chunkp>lineL)then continue;
                   chunkl:=widthChars;
                   if((chunkl+chunkp)>lineL)then
                   begin
                      chunkl:=(lineL mod widthChars);
                      if(chunkl<=0)then chunkl:=1;
                   end;
                   addLine(copy(aline,chunkp,chunkl),atype,acolor);
                   chunks-=1;
                end;
             end;
        end;
     end;
   while(ui_log_n<listHeight)do addLine('',0,0);
end;


////////////////////////////////////////////////////////////////////////////////
//
//   UNITS
//

function unit_F1SelectFilter(pu:PTUnit):boolean;
begin
   unit_F1SelectFilter:=false;
   with pu^  do
   with uid^ do
     if(hits<=0)
     or(not iscomplete)
     or(IsUnitRange(transportU,nil))
     or(not uid_isbuilder)then exit;
   unit_F1SelectFilter:=true;
end;


function unit_F2SelectFilter(pu:PTUnit):boolean;
var puo_tar:PTUnit;
begin
   unit_F2SelectFilter:=false;
   with pu^  do
   with uid^ do
   begin
      if(hits<=0)
      or(not iscomplete    )then exit;

      if(IsUnitRange(transportU,nil))then exit;

      if(speed          <=0)then exit;
      if(uid_isbuilding    )then exit;
      if(not uid_CanAttack )then exit;
      if(uo_id=ua_ability1 )
      or(uo_id=ua_ability2 )
      or(uo_id=ua_ability3 )
      or(uo_id=ua_hold     )
      or(uo_bx>0           )then exit;

      if(IsUnitRange(uo_tar,@puo_tar))then
      begin
         if(puo_tar^.uid^.uid_ability_isteleport)and(not isfly)then exit;

         if(unit_CheckTransport(pu,puo_tar))
         or(unit_CheckTransport(puo_tar,pu))then exit;
      end;
   end;
   unit_F2SelectFilter:=true;
end;


function unit_CalcShadowZ(pu:PTUnit;uidApply:boolean=false):integer;
begin
   with pu^  do
   with uid^ do
     case uidApply of
     true : if(uid_isbuilding)
            then unit_CalcShadowZ:=-fly_hz
            else unit_CalcShadowZ:=fly_height[uid_isfly];
     false: if(not uid_isbuilding)
            then unit_CalcShadowZ:=fly_height[isfly]
            else
              if(speed<=0)or(not iscomplete)or(transformTimer>0)
              then unit_CalcShadowZ:=-fly_hz   // no shadowz
              else unit_CalcShadowZ:=0;
     end;
end;

procedure unit_CalcFogR(pu:PTUnit);
begin
   with pu^ do
   with g_unitsVis[unum] do fsr:=mm3i(1,srange div fog_cw,fog_MaxR);
end;

procedure units_UpdateMiniMapR;
var u:byte;
begin
   for u:=1 to 255 do
     with g_uids[u] do
       uid_MiniMapR:=trunc(uid_r*map_MiniMap_cx)+1;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   OTHER
//

function TileSetGetN(    b10,
                     b01,b11,b21,
                         b12    :boolean):integer;
begin
   TileSetGetN:=-1;// empty
   if(b11)
   then TileSetGetN:=0 // full filled
   else
   begin
      TileSetGetN:=0;
      if(b10)then TileSetGetN+=1;
      if(b01)then TileSetGetN+=2;
      if(b21)then TileSetGetN+=4;
      if(b12)then TileSetGetN+=8;
      if(TileSetGetN=0)then TileSetGetN:=-1;
   end;
end;

function menudoc_ValidForTableUnit(uid:byte;forBalance:boolean):boolean;
begin
   menudoc_ValidForTableUnit:=false;
   with g_uids[uid] do
     if(uid_r>0)then
     begin
        if(forBalance)then
        begin
           if (uid_balance_Good   =[])
           and(uid_balance_Bad    =[])
           and(uid_balance_Useless=[])then exit;
           if(not uid_CanAttack)then exit;
        end;
        menudoc_ValidForTableUnit:=true;
     end;
end;
function menudoc_ValidForTableUpgrade(upid:byte):boolean;
begin
   menudoc_ValidForTableUpgrade:=false;
   with g_upgrs[upid] do
     if (upgr_time>0)
     and(upgr_max >0)then
       menudoc_ValidForTableUpgrade:=true;
end;

function hits_si2li(sh:shortint;mh:integer;s:single):longint;
begin
   case sh of
127     : hits_si2li:=mh;
1..126  : hits_si2li:=mm3i(1,trunc(sh*s),mh-1);
0       : hits_si2li:=0;
-125..-1: hits_si2li:=mm3i(hits_dead+1,sh*_d2shi,-1);
-126    : hits_si2li:=hits_fdead;
-127    : hits_si2li:=hits_dead;
-128    : hits_si2li:=hits_ndead;
   end;
end;

function FileReadBaseGameInfo(var f:file;strInfoVar1,strInfoVar2,strInfoVar3:pshortstring):boolean;
type
TShortPlayerInfo = record
   mrace,
   team,
   state   :byte;
   name    :shortstring;
   observer:boolean;
end;
var
playerInfo:TShortPlayerInfo;
lplayer,p,
vbyte1:byte;
vint  :integer;
vcard :cardinal;
pstr  :pshortstring;
begin
   FileReadBaseGameInfo:=false;

   vbyte1 :=0;
   vint   :=0;
   vcard  :=0;
   lplayer:=0;
   strInfoVar1^:=str_map+tc_nl2;

   vbyte1:=255;
   BlockRead(f,vbyte1,sizeof(map_scenario  ));
   if not(vbyte1 in allmapscenarios        )then exit
                                            else strInfoVar1^+=' '+str_map_Scenario  +': '+str_map_ScenarioL  [vbyte1]+tc_default+tc_nl2;
   vbyte1:=255;
   BlockRead(f,vbyte1,sizeof(map_GeneratorT));
   if(vbyte1>mapg_Last                     )then exit
                                            else strInfoVar1^+=' '+str_map_Generators+': '+str_map_GeneratorsL[vbyte1]+tc_nl2;
   vcard:=0;
   BlockRead(f,vcard ,sizeof(map_seed      ));   strInfoVar1^+=' '+str_map_Seed      +': '+c2s(vcard)+tc_nl2;

   vint:=-1;
   BlockRead(f,vint  ,sizeof(map_Size1     ));
   if(vint<map_MinSize)or(map_MaxSize<vint )then exit
                                            else strInfoVar1^+=' '+str_map_Size      +': '+i2s(vint )+tc_nl2;
   vbyte1:=255;
   BlockRead(f,vbyte1,sizeof(map_Template  ));
   if(vbyte1>mapt_Last                     )then exit
                                            else strInfoVar1^+=' '+str_map_Template  +': '+str_map_TemplateL[vbyte1]+tc_default+tc_nl2;

   vbyte1:=255;
   BlockRead(f,vbyte1,sizeof(map_Symmetry  ));
   if(vbyte1>maps_Last                     )then exit
                                            else strInfoVar1^+=' '+str_map_Symmetry  +': '+str_map_SymmertyL[vbyte1]+tc_nl2;

   vint:=-1;
   BlockRead(f,vint  ,sizeof(theme_i       ));
   if(vint>=theme_n                        )then exit
                                            else strInfoVar1^+=' '+str_themes[vint]+tc_default+tc_nl2;

   lplayer:=255;
   BlockRead(f,lplayer,sizeof(LocalPlayer  ));

   strInfoVar1^+=tc_nl2;

   vcard:=0;
   BlockRead(f,vcard  ,sizeof(g_tick       ));   strInfoVar1^+=str_menu_InGameTime+str_GTick2Time(vcard)+tc_nl2+tc_nl2;

   strInfoVar1^+=str_Players+tc_nl2;
   //----------------  seconds string
   strInfoVar2^:='';
   strInfoVar3^:='';
   pstr:=strInfoVar2;
   for p:=0 to LastPlayer do
     with playerInfo do
     begin
        BlockRead(f,state   ,sizeof(state   ));
        BlockRead(f,name    ,sizeof(name    ));
        BlockRead(f,mrace   ,sizeof(mrace   ));
        BlockRead(f,team    ,sizeof(team    ));
        BlockRead(f,observer,sizeof(observer));
        if(length(name)>MaxPlayerNameLen)then SetLength(name,MaxPlayerNameLen);

        if(p=4)then pstr:=strInfoVar3;

        pstr^+=chr(p);
        if(p=lplayer)
        then pstr^+='>'
        else pstr^+='#';
        pstr^+=tc_default;

        pstr^+=str_SpaceSize(name,MaxPlayerNameLen+1);

        if(state>ps_None)then
          if(observer)
          then pstr^+=str_SpaceSize(str_observer   ,9)
          else pstr^+=str_SpaceSize(str_race[mrace],9)+b2s(team+1);
        pstr^+=tc_nl2
     end;

   FileReadBaseGameInfo:=true;
end;

{$ELSE}


function NoHumanPlayers:boolean;
var p:byte;
begin
   NoHumanPlayers:=false;
   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
       if(state=PS_human)then exit;
   NoHumanPlayers:=true;
end;

{$ENDIF}



