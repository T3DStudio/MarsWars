
////////////////////////////////////////////////////////////////////////////////
//
//   FORWARD Declarations
//

procedure unit_damage(pu:PTUnit;damage:integer;pl:byte;IgnoreArmor:boolean);forward;
procedure unit_Bonuses (pu:PTUnit);forward;
function unit_canMove  (pu:PTUnit):boolean; forward;
function unit_canAttack(pu:PTUnit;check_buffs:boolean):boolean; forward;
function unit_sability (pCaster:PTUnit;check:boolean):cardinal; forward;
function unit_pability (pCaster:PTUnit;taru,tarx,tary:integer;check:boolean):cardinal;forward;
function unit_rebuild  (pu:PTUnit;check:boolean):cardinal;      forward;
function unit_CheckTransport(pTransport,pPassenger:PTUnit):boolean;forward;

{procedure ai_Local_InitVars(pu:PTUnit);forward;
procedure ai_Local_CollectData(pu,tu:PTUnit;ud:integer;tu_transport:PTUnit);forward;
procedure ai_Local_Code(pu:PTUnit);forward;

procedure ai_Global_InitVars(pu:PTUnit);forward;
procedure ai_Global_SetCurrentAlarm(tu:PTUnit;x,y,ud:integer;zone:word);forward;
procedure ai_Global_CollectData(pu,tu:PTUnit;ud:integer;tu_transport:PTUnit);forward;
procedure ai_Global_ScoutPick(pu:PTUnit);forward;
procedure ai_Global_Code(pu:PTUnit);forward;}
function ai_HighPriorityTarget(player:PTPlayerGameData;tu:PTUnit):boolean;forward;

function map_IfObstacleZone(zone:word):boolean;       forward;
function map_GetZone(mx,my:integer;mr:integer=0):word;forward;

function point_dist_rint(dx0,dy0,dx1,dy1:integer):integer;  forward;

procedure KeyPoints_Clear;   forward;

procedure GameRemoveAIObservers; forward;

{$IFDEF _FULLGAME}
procedure vid_LoadingScreen(load_str:pshortstring;color:cardinal);  forward;
function ui_AddMarker(ax,ay:integer;av:byte;new:boolean):boolean;forward;
function uid2spr(auid:byte;dir:integer;level:byte):PTMWTexture;forward;
function LogMes2UIAlarm:boolean; forward;
procedure SoundLogUIPlayer(PListener:byte);   forward;

function gfx_ShadowColor(c:cardinal):cardinal;forward;

function GamePauseToggle(check:boolean):boolean;forward;
function GameNetServerSearch(start,check:boolean):boolean;forward;

procedure menu_msgBox_Net(caption,body,btn1:shortstring;time:integer=fr_fps4);forward;
function menu_MouseXY2Item:byte; forward;
function menu_ReadyButtonEnabled:boolean;forward;
function PlayerNameChangeble  :boolean;forward;

function menu_ChatSize:integer;  forward;


function PlayerGetColor  (player:byte;shadow:boolean):cardinal;  forward;
function PlayerAIToggle  (PlayerTarget,PlayerRequestor:byte;check:boolean):boolean;forward;
function PlayerRaceScroll(PlayerTarget,PlayerRequestor:byte;check:boolean):boolean;forward;
function PlayerTeamScroll(PlayerTarget,PlayerRequestor:byte;forward,check:boolean):boolean;forward;

function saveload_Save  (check:boolean):boolean;forward;
function saveload_Load  (check:boolean):boolean;forward;
function saveload_Delete(check:boolean):boolean;forward;

procedure replay_SavePlayPosition; forward;
function replay_Delete(check:boolean):boolean;forward;
function replay_Play  (check:boolean):boolean;forward;
function replay_Pause (check:boolean):boolean;forward;
function replay_IsPaused:boolean;  forward;
function replay_GetProgress:single;forward;
procedure replay_WriteBlock(count:cardinal;pData:pointer);forward;
function replay_ReadBlock(count:cardinal;pResult:pointer):boolean;forward;


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


function strMX(x:byte):shortstring;
begin
   if(x=0)
   then strMX:='-'
   else strMX:='x'+b2s(x);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   basic math
//

function max2i(x1,x2   :integer):integer;begin if(x1>x2)then max2i:=x1 else max2i:=x2;end;
function max3i(x1,x2,x3:integer):integer;begin max3i:=max2i(max2i(x1,x2),x3);end;
function min2i(x1,x2   :integer):integer;begin if(x1<x2)then min2i:=x1 else min2i:=x2;end;
function min3i(x1,x2,x3:integer):integer;begin min3i:=min2i(min2i(x1,x2),x3);end;

function min2c(x1,x2   :cardinal):cardinal;begin if(x1<x2)then min2c:=x1 else min2c:=x2;end;
function min3c(x1,x2,x3:cardinal):cardinal;begin min3c:=min2c(min2c(x1,x2),x3);end;

function mm3i(mnx,x,mxx:integer):integer;begin mm3i:=min2i(mxx,max2i(x,mnx)); end;

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

function sign(x:integer):integer;
begin
   sign:=0;
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
   with g_gplayers[p] do
   begin
      if(new)then FillChar(units_uid_m,SizeOf(units_uid_m),0);
      if(g<>[])then
        for i:=0 to 255 do
          if(i in g)then units_uid_m[i]:=max;
   end;
end;
procedure PlayerSetAllowedUpgrades(p:byte;g:TSob;lvl:integer;new:boolean);  // allowed upgrades
var i:byte;
begin
   with g_gplayers[p] do
   begin
      if(new)then FillChar(upgrs_max,SizeOf(upgrs_max),0);
      if(g<>[])then
        for i:=0 to 255 do
          if(i in g)then
            with g_upids[i] do upgrs_max[i]:=min2i(upgr_max,lvl);
   end;
end;
procedure PlayerSetCurrentUpgrades(p:byte;g:TSob;lvl:integer;new,NoCheck:boolean);  // current upgrades
var i:byte;
begin
   with g_gplayers[p] do
   begin
      if(new)then FillChar(upgrs_cur,SizeOf(upgrs_cur),0);
      if(g<>[])then
       for i:=0 to 255 do
        if(i in g)then
         with g_upids[i] do
          if(NoCheck)
          then upgrs_cur[i]:=min2i(upgr_max ,lvl)
          else upgrs_cur[i]:=min3i(upgrs_max[i],upgr_max,lvl);
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   APM Counter
//

{procedure PlayerAPMInc(player:byte);
begin
   _playerAPM[player].APM_New+=1;
end;

procedure PlayerAPMUpdate(player:byte);
begin
   with _playerAPM[player] do
   begin
      if(APM_Time>0)
      then APM_Time-=1
      else
      begin
         APM_Time   :=APM_UPDPeriod;
         APM_Current:=(APM_Current+round((APM_1Period/APM_Time)*APM_New)) div 2;
         APM_Str    :=c2s(APM_Current);
         APM_New    :=0;
      end;
   end;
end;
       }
////////////////////////////////////////////////////////////////////////////////
//
//   PLAYERS LOG
//

function PlayerGetAlliesByte(playeri:byte;AddSelf:boolean):byte;
var p:byte;
begin
   PlayerGetAlliesByte:=0;
   for p:=0 to LastPlayer do
     with g_gplayers[p] do
       if(state>ps_None)then
       begin
          if(not AddSelf)and(p=playeri)then continue;

          case g_gplayers[playeri].isobserver of
          false: if(team<>g_gplayers[playeri].team)then continue;
          true : if(not isobserver)then continue;
          end;
          SetBBit(@PlayerGetAlliesByte,p,true);
       end;
end;

function PlayerLogCheckNearEvent(playeri:byte;tickDiff:cardinal;x,y:integer;mtypes:TSoB):boolean;
var ln,li:cardinal;
begin
   PlayerLogCheckNearEvent:=true;
   with g_gplayers[playeri] do
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
                   if(point_dist_rint(lm_x,lm_y,x,y)<base_2r)then exit;
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

   with g_gplayers[ptarget] do
     if(state>ps_None)then
     begin
        case amtype of
0..LastPlayer,
lmt_chat_common,
lmt_player_defeated,
lmt_player_leave,
lmt_player_surrender,
lmt_player_ready,
lmt_player_nready,
lmt_replay_RecStart,
lmt_replay_RecStop,
lmt_replay_RecError,
lmt_game_end,
lmt_game_message,
lmt_game_PlayersReady,
lmt_game_StartsIn
                     :;

lmt_unit_attacked,
lmt_allies_attacked  : if(PlayerLogCheckNearEvent(ptarget,fr_fps5,ax,ay,[lmt_unit_attacked,lmt_allies_attacked]))then exit;
lmt_unit_LevelUp     : if(PlayerLogCheckNearEvent(ptarget,fr_fps5,ax,ay,[amtype]))then exit;
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

        if(net_status=ns_client)
        then POVPlayer:=LocalPlayer
        else POVPlayer:=UIPlayer;
        if(ptarget=POVPlayer)then
        begin
           if(amtype in lmts_last_events)then
             ui_log_LastTimer :=min2i(ui_log_LastTimer +ui_log_TimeLast ,ui_log_TimeMax );

           menu_update:=true;

           if(LogMes2UIAlarm)then SoundLogUIPlayer(POVPlayer);

           if(rpls_pstate<rpls_read)and(g_type<>gt_campaing)then
             if((amtype=lmt_player_defeated)and(g_DefeatedObs)and(adatau=UIPlayer))
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

procedure GameLogChat(sender,targets:byte;message:shortstring);
begin
   if(targets>0)then
     if(sender<=LastPlayer)
     then PlayersAddToLog(sender,targets,sender         ,0,0,g_gplayers[sender].name+': '+message,0,0)
     else PlayersAddToLog(sender,targets,lmt_chat_common,0,0,message                             ,0,0);
end;
procedure GameLogCommon(sender,targets:byte;message:shortstring);
begin
   PlayersAddToLog(sender,targets,lmt_game_message,0,0,message,0,0);
end;
procedure GameLogPlayerReady(player:byte);
begin
   if(player>LastPlayer)then exit;

   with g_gplayers[player] do
     if(isready)
     then PlayersAddToLog(255,255,lmt_player_ready ,0,0,name,0,0)
     else PlayersAddToLog(255,255,lmt_player_nready,0,0,name,0,0)
end;
procedure GameLogPlayersReady;
begin
   PlayersAddToLog(255,255,lmt_game_PlayersReady,0,0,'',0,0)
end;
procedure GameLogStartsIn(seconds:integer);
begin
   PlayersAddToLog(255,255,lmt_game_StartsIn,0,byte(seconds),'',0,0)
end;
procedure GameLogRecStart(fname:shortstring);
begin
   PlayersAddToLog(255,255,lmt_replay_RecStart,0,0,fname,0,0)
end;
procedure GameLogRecStop (fname:shortstring);
begin
   PlayersAddToLog(255,255,lmt_replay_RecStop,0,0,fname,0,0)
end;
procedure GameLogRecError(errorStr:shortstring);
begin
   PlayersAddToLog(255,255,lmt_replay_RecError,0,0,errorStr,0,0)
end;
procedure GameLogEndGame(wteam:byte);
begin
   if(not ServerSide)then exit;
   PlayersAddToLog(0,log_to_all,lmt_game_end,0,wteam,'',0,0);
end;
procedure GameLogPlayerDefeated(player:byte);
begin
   if(player>LastPlayer)or(not ServerSide)then exit;
   PlayersAddToLog(player,log_to_all,lmt_player_defeated,0,player,'',0,0);
end;
procedure GameLogPlayerLeave(player:byte);
begin
   if(player>LastPlayer)or(not ServerSide)then exit;
   PlayersAddToLog(player,log_to_all,lmt_player_leave,0,0,g_gplayers[player].name+str_gmsg_PlayerLeft,0,0);
end;
procedure GameLogPlayerSurrender(player:byte);
begin
   if(player>LastPlayer)or(not ServerSide)then exit;
   PlayersAddToLog(player,log_to_all,lmt_player_surrender,0,0,g_gplayers[player].name+str_gmsg_PlayerSurrender,0,0);
end;
procedure GameLogUnitReady(pu:PTunit);
begin
   if(pu=nil)or(not ServerSide)then exit;

   with pu^ do PlayersAddToLog(playeri,0,lmt_unit_ready,lmt_argt_unit ,uidi,'',x,y);
end;
procedure GameLogUnitResurrected(pu:PTunit);
begin
   if(pu=nil)or(not ServerSide)then exit;

   with pu^ do PlayersAddToLog(playeri,0,lmt_unit_resurrected,lmt_argt_unit ,uidi,'',x,y);
end;
procedure GameLogUnitPromoted(pu:PTunit);
begin
   if(pu=nil)or(not ServerSide)then exit;

   with pu^ do
    PlayersAddToLog(playeri,0,lmt_unit_LevelUp,0,uidi,'',x,y);
end;
procedure GameLogUpgradeComplete(pl,upid:byte;x,y:integer);
begin
   if(pl>LastPlayer)or(not ServerSide)then exit;

   PlayersAddToLog(pl,0,lmt_upgrade_complete,0,upid,'',x,y);
end;
function GameLogBits2Message(playerN,auid,atype:byte;bits:cardinal;x,y:integer;check:boolean=false):boolean;
var bt:byte;
begin
   GameLogBits2Message:=false;
   if(playerN>LastPlayer)or(bits=0)then exit;

   with g_gplayers[playerN] do
   begin
      if(state=ps_AI)then exit;

      if(auid>0)and(atype=lmt_argt_unit)then
        if(units_uid_e[auid]<=0)and(units_uid_m[auid]<=0)then exit;
   end;
   GameLogBits2Message:=true;

   if(check)then exit;

   if((bits and ureq_place)>0)
   then bt:=lmt_prod_BadPlace
   else
     if((bits and ureq_landplace)>0)
     then bt:=lmt_ability_BadPlace
     else
       if((bits and ureq_ruid )>0)
       or((bits and ureq_rupid)>0)
       then bt:=lmt_Req_Common
       else
         if((bits and ureq_reloading)>0)
         then bt:=lmt_ability_reload
         else
           if((bits and ureq_InProgress)>0)
           then bt:=lmt_upgrade_InProgress
           else
             if((bits and ureq_max )>0)
             then bt:=lmt_Req_MaxCount
             else
               if((bits and ureq_armylimit )>0)
               or((bits and ureq_limit )>0)
               then bt:=lmt_Req_Limit
               else
                 if((bits and ureq_energy)>0)
                 then bt:=lmt_Req_Energy
                 else
                   if((bits and ureq_smiths  )>0)
                   or((bits and ureq_barracks)>0)
                   then bt:=lmt_NeedProdUnit
                   else
                     if((bits and ureq_builders)>0)
                     then bt:=lmt_unit_NeedBuilder
                     else
                       if((bits and ureq_busy)>0)
                       then bt:=lmt_prod_AllBusy
                       else
                         if((bits and ureq_InvalidTarget)>0)
                         then bt:=lmt_invalid_Target
                         else
                           if((bits and ureq_other   )>0)
                           then bt:=lmt_Invalid_Order
                           else bt:=lmt_prod_BadOrder;

   PlayersAddToLog(playerN,0,bt,atype,auid,'',x,y);
end;
procedure GameLogMapMark(pl:byte;x,y:integer);
begin
   if(pl>LastPlayer)or(not ServerSide)then exit;

   PlayersAddToLog(pl,
   PlayerGetAlliesByte(pl,true)
   ,lmt_map_mark,0,pl,'',x,y);
end;
procedure GameLogUnitAttacked(pu:PTunit);
begin
   if(pu=nil)or(not ServerSide)then exit;

   with pu^ do
   begin
      PlayersAddToLog(playeri,0                                 ,lmt_unit_attacked  ,0,uidi,'',x,y);
      PlayersAddToLog(playeri,PlayerGetAlliesByte(playeri,false),lmt_allies_attacked,0,uidi,'',x,y);
   end;
end;
procedure GameLogKeyPointCaptured(from_player,kpoint:byte);
begin
   if(from_player>LastPlayer)
   or(LastKeyPoint<kpoint)then exit;

   if(kpoint=0)and(map_scenario=mc_KotH)then exit;

   with g_KeyPoints[kpoint] do
     if(kpEnergy>0)
     then PlayersAddToLog(from_player,0,lmt_ngen_captured  ,0,0,'',kpx,kpy)
     else PlayersAddToLog(from_player,0,lmt_kpoint_captured,0,0,'',kpx,kpy);
end;
procedure GameLogKeyPointLost(from_player,kpoint:byte);
begin
   if(from_player>LastPlayer)
   or(LastKeyPoint<kpoint)then exit;

   if(kpoint=0)and(map_scenario=mc_KotH)then exit;

   with g_KeyPoints[kpoint] do
     if(kpEnergy>0)
     then PlayersAddToLog(from_player,0,lmt_ngen_lost  ,0,0,'',kpx,kpy)
     else PlayersAddToLog(from_player,0,lmt_kpoint_lost,0,0,'',kpx,kpy);
end;
procedure GameLogKotHControl;
begin
   if(map_scenario<>mc_KotH)then exit;

   with g_KeyPoints[0] do
     PlayersAddToLog(255,255,lmt_koth_control,0,kpTimerOwnerTeam,'',kpx,kpy);
end;
procedure GameLogNgenExh(from_player,kpoint:byte);
begin
   if(from_player>LastPlayer)
   or(LastKeyPoint<kpoint)then exit;

   if(kpoint=0)and(map_scenario=mc_KotH)then exit;

   with g_KeyPoints[kpoint] do
     PlayersAddToLog(from_player,0,lmt_ngen_exh  ,0,0,'',kpx,kpy);
end;

procedure PlayerClearLog(playerN:byte);
var i:cardinal;
begin
   if(playerN>LastPlayer)then exit;

   with g_gplayers[playerN] do
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

function PlayersAllReady:boolean;
var p,
c_human,
c_ready:byte;
begin
   c_human:=0;
   c_ready:=0;
   for p:=0 to LastPlayer do
     with g_gplayers[p] do
       if(state=ps_human)then
       begin
          c_human+=1;
          if(isready){$IFDEF _FULLGAME}or(p=LocalPlayer){$ENDIF}then c_ready+=1;
       end;
   PlayersAllReady:=(c_ready=c_human)and(c_human>0);
end;

function PlayerGetFixedTeams(gm,p:byte):byte;
begin
   PlayerGetFixedTeams:=LastPlayer;
   if(p<=LastPlayer)then
     with g_gplayers[p] do
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
     with g_gplayers[p] do
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
     with g_gplayers[p] do
       team:=PlayerValidateTeam(p,team);
end;

function PlayerStateString(p:byte):string4;
begin
   PlayerStateString:='';
   with g_gplayers[p] do
   with g_nplayers[p] do
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
                   if(not g_started)
                   then PlayerStateString:=b2c[isready]
                   else PlayerStateString:=str_ps_Hum;
     end;
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
   then g_CheckRoyalBattlePoint:=(point_dist_int(x,y,map_hSize,map_hSize)+d)>=g_royal_r
   else g_CheckRoyalBattlePoint:=false;
end;

procedure Game_SetStatusWinnerTeam(team:byte);
begin
   if(team>LastPlayer)then exit;

   G_status:=gs_win_team0+team;
   GameLogEndGame(team);
end;

function Game_IsEnded:boolean;
begin
   Game_IsEnded:=(gs_win_team0<=G_status)and(G_status<=gs_win_team7);
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
//   UID/UPID Checks
//

function _uid_player_limit(player:PTPlayerGameData;uid:byte):boolean;
begin
   with player^ do
     with g_uids[uid] do
       if(uid_isbuilder)and(units_builders_e>=PlayerMaxBuilders)
       then _uid_player_limit:=false
       else _uid_player_limit:=((units_uid_e[uid]+prod_unit_uid[uid])<units_uid_m[uid])
                            and((units_all_e+prod_unit_Now)<MaxPlayerUnits)
                            and((armylimit+prod_unit_Limit+uid_LimitUse)<=MaxPlayerLimit);
end;

function CheckUnitReqs(player:PTPlayerGameData;uid:byte;forRebuildCheck:boolean=false):cardinal;
procedure AddBits(ni:cardinal;b:boolean);
begin if(b)then CheckUnitReqs:=CheckUnitReqs or ni;end;
begin
   CheckUnitReqs:=0;
   with player^ do
   with g_uids[uid] do
   begin
      if(not forRebuildCheck)then
      begin
      AddBits(ureq_limit     ,(units_all_e+prod_unit_Now             )>=MaxPlayerUnits);
      AddBits(ureq_armylimit ,(armylimit+prod_unit_Limit+uid_LimitUse)> MaxPlayerLimit);
      end;
      AddBits(ureq_ruid      ,(uid_req_uid1>0)and(units_uid_c[uid_req_uid1]<uid_req_uid1n));
      AddBits(ureq_ruid      ,(uid_req_uid2>0)and(units_uid_c[uid_req_uid2]<uid_req_uid2n));
      AddBits(ureq_ruid      ,(uid_req_uid3>0)and(units_uid_c[uid_req_uid3]<uid_req_uid3n));
      AddBits(ureq_rupid     ,(uid_req_upgr>0)and(upgrs_cur  [uid_req_upgr]=0            ));
      AddBits(ureq_energy    ,(energyl_cur<uid_EnergyReq)or(uid_isbuilding and(energyl_max<=0)));
      AddBits(ureq_time      , uid_ProdTimeSec<=0   );

      if(not forRebuildCheck)then
      AddBits(ureq_max       ,((units_uid_e[uid]+prod_unit_uid[uid])>=units_uid_m[uid])or
                              ((uid_isbuilder)and(units_builders_e>=PlayerMaxBuilders)));

      case uid_isbuilding of
true  : begin
           AddBits(ureq_builders,units_builders_ec <=0);
           AddBits(ureq_BuildCD ,build_cd> 0);
        end;
false : AddBits(ureq_barracks   ,units_unitProds_ec<=0);
      end;
   end;
end;

function GetUpgradeEnergy(upgr,lvl:byte):integer;
begin
   GetUpgradeEnergy:=0;
   with g_upids[upgr] do
    if(0<lvl)and(lvl<=upgr_max)then
     if(upgr_mfrg)or((upgr_renerg_xpl<=0)and(upgr_renerg_apl<=0))
     then GetUpgradeEnergy:=upgr_renerg
     else
     begin
        lvl-=1;
        GetUpgradeEnergy:=(upgr_renerg*ipower(upgr_renerg_xpl,lvl))+(upgr_renerg_apl*lvl);
     end;
end;
function GetUpgradeTime(upgr,lvl:byte):integer;
const upgr_max_time = fr_fps1*255;
begin
   GetUpgradeTime:=0;
   with g_upids[upgr] do
    if(0<lvl)and(lvl<=upgr_max)then
     if(upgr_mfrg)or((upgr_time_xpl<=0)and(upgr_time_apl<=0))
     then GetUpgradeTime:=upgr_time
     else
     begin
        lvl-=1;
        GetUpgradeTime:=min2i(upgr_max_time,upgr_time*ipower(upgr_time_xpl,lvl)+(upgr_time_apl*lvl));
     end;
end;

function CheckUpgradeReqs(player:PTPlayerGameData;up:byte):cardinal;
procedure AddBits(ni:cardinal;b:boolean);
begin if(b)then CheckUpgradeReqs:=CheckUpgradeReqs or ni;end;
begin
   CheckUpgradeReqs:=0;
   with player^ do
   with g_upids[up] do
   begin
      AddBits(ureq_ruid      ,(upgr_ruid >0)and(units_uid_c[upgr_ruid ]=0)  );
      AddBits(ureq_rupid     ,(upgr_rupgr>0)and(upgrs_cur  [upgr_rupgr]=0)  );
      AddBits(ureq_energy    , energyl_cur<GetUpgradeEnergy(up,upgrs_cur[up]+1) );
      AddBits(ureq_time      , upgr_time<=0                            );
      AddBits(ureq_max       ,(integer(upgrs_cur[up]+prod_upgr_upid[up])>=min2i(upgr_max,upgrs_max[up])));
      AddBits(ureq_InProgress,(not upgr_mfrg)and(prod_upgr_upid[up]>0) );
      AddBits(ureq_smiths    , units_upgrProds_ec<=0                             );
   end;
end;

function UnitOrderCheckSmith(pu:pTunit;oid:byte):boolean;
begin
   UnitOrderCheckSmith:=true;
   with pu^     do
   with uid^    do
   with player^ do
     if(uid_issmith)then
       if(oid in uid_prod_Upgrades)or(oid=255)then
         if(units_upgrProds_s<=0)or(isselected)then exit;
   UnitOrderCheckSmith:=false;
end;
function UnitOrderCheckBarrack(pu:pTunit;oid:byte):boolean;
begin
   UnitOrderCheckBarrack:=true;
   with pu^     do
   with uid^    do
   with player^ do
     if(uid_isbarrack)then
       if(oid in uid_prod_Units)or(oid=255)then
         if(units_unitProds_s<=0)or(isselected)then exit;
   UnitOrderCheckBarrack:=false;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   OTHER
//

function hits_li2si(h,mh:longint;s:single):shortint;
begin
   if(h>=mh                         )then hits_li2si:=127  else
   if(h =0                          )then hits_li2si:=0    else
   if(h =hits_dead                  )then hits_li2si:=-127 else
   if(h<=hits_ndead                 )then hits_li2si:=-128 else
   if(hits_fdead<h)and(h<0          )then hits_li2si:=mm3i(-125,h div _d2shi,-1  ) else
   if( hits_dead<h)and(h<=hits_fdead)then hits_li2si:=-126 else
                                          hits_li2si:=mm3i(   1,trunc(h/s)  ,sintMaxHits);
end;

function ai_name(ain:byte):shortstring;
begin
   if(ain=0)
   then ai_name:=str_ps_none
   else
     {$IFDEF _FULLGAME}
     case ain of
     0  : ai_name:=str_ps_AI+' '+tc_gray  +b2s(ain)+tc_default;
     1  : ai_name:=str_ps_AI+' '+tc_blue  +b2s(ain)+tc_default;
     2  : ai_name:=str_ps_AI+' '+tc_aqua  +b2s(ain)+tc_default;
     3  : ai_name:=str_ps_AI+' '+tc_lime  +b2s(ain)+tc_default;
     4  : ai_name:=str_ps_AI+' '+tc_green +b2s(ain)+tc_default;
     5  : ai_name:=str_ps_AI+' '+tc_yellow+b2s(ain)+tc_default;
     6  : ai_name:=str_ps_AI+' '+tc_orange+b2s(ain)+tc_default;
     7  : ai_name:=str_ps_AI+' '+tc_red   +b2s(ain)+tc_default;
     8  : ai_name:=str_ps_AI+' '+tc_purple+b2s(ain)+tc_default+' cheater';
     else ai_name:=str_ps_AI+' '+tc_white +b2s(ain)+tc_default+' cheater';
     end;
     {$ELSE}
     ai_name:=str_ps_AI+' '+b2s(ain);
     {$ENDIF}
end;

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
      if(uo_id=ua_psability)
      or(uo_id=ua_sability )
      or(uo_id=ua_ability1 )
      or(uo_id=ua_ability2 )
      or(uo_id=ua_ability3 )
      or(uo_id=ua_hold     )
      or(uo_bx>0           )then exit;

      if(IsUnitRange(uo_tar,@puo_tar))then
      begin
         if(puo_tar^.uid^.uid_ability_isteleport)and(not ukfly)then exit;

         if(unit_CheckTransport(pu,puo_tar))
         or(unit_CheckTransport(puo_tar,pu))then exit;
      end;
   end;
   unit_F2SelectFilter:=true;
end;



function CheckUnitBaseFlags(tu:PTUnit;flags:cardinal):boolean;
begin
   CheckUnitBaseFlags:=false;

   if((flags and wtr_unit    )=0)and(not tu^.uid^.uid_isbuilding)then exit;
   if((flags and wtr_building)=0)and(    tu^.uid^.uid_isbuilding)then exit;

   if((flags and wtr_bio     )=0)and(not tu^.uid^.uid_ismech    )then exit;
   if((flags and wtr_mech    )=0)and(    tu^.uid^.uid_ismech    )then exit;

   if((flags and wtr_light   )=0)and    (tu^.uid^.uid_islight   )then exit;
   if((flags and wtr_heavy   )=0)and not(tu^.uid^.uid_islight   )then exit;

   if((flags and wtr_ground  )=0)and(tu^.ukfly = uf_ground      )then exit;
   if((flags and wtr_fly     )=0)and(tu^.ukfly = uf_fly         )then exit;

   CheckUnitBaseFlags:=true;
end;

function CheckUnitTeamVision(POVTeam:byte;pTarget:PTUnit;SkipInvisCheck:boolean):boolean;
begin
   with pTarget^ do
     if(buffs[ub_Invis]<=0)or(hits<=0)or(SkipInvisCheck)
     then CheckUnitTeamVision:=(TeamVision[POVTeam]>0)
     else CheckUnitTeamVision:=(TeamVision[POVTeam]>0)and(TeamDetection[POVTeam]>0);
end;

procedure UnitOrderSetNearestTarget(taru:PTUnit;cx,cy:integer;ptaru:PPTunit;pdist:pinteger;pCanExec:pboolean;CanExec,noReload:boolean;closest:boolean);
var d:integer;
begin
   d:=point_dist_int(cx,cy,taru^.x,taru^.y);

   if(CanExec>pCanExec^)then
   begin
      ptaru^   :=taru;
      pdist^   :=d;
      pCanExec^:=CanExec;
      exit;
   end
   else
     if(CanExec=pCanExec^)then
       case CanExec or noReload of
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

function ui_ReadyForAbility(pu:PTUnit):boolean;
begin
   with pu^ do
   with player^ do
   ui_ReadyForAbility:=(units_all_s=1)or
                       ((uo_id<>ua_psability)
                     and(uo_id<>ua_sability )
                     and(uo_id<>ua_ability1 )
                     and(uo_id<>ua_ability2 )
                     and(uo_id<>ua_ability3 ));
end;

function ui_HaveAbility(pu:PTUnit;pability:boolean):boolean;
begin
   ui_HaveAbility:=false;

   if(pu=nil)then exit;
   with pu^ do
   with uid^ do
   begin
      if(hits<=0)
      or(uid_ability=0)
      or(not iscomplete)then exit;

      if not(uid_ability in player^.a_ability)then exit;

      case pability of
      false: if not(uid_ability in uab_sabilityOrder)then exit;
      true : if not(uid_ability in uab_pabilityOrder)then exit;
      end;
   end;

   ui_HaveAbility:=true;
end;

function ui_HaveRebuild(pu:PTUnit):boolean;
begin
   ui_HaveRebuild:=false;

   if(pu=nil)then exit;

   with pu^ do
   with uid^ do
   begin
      if(hits<=0)
      or(not iscomplete)then exit;
      if(uid_rebuild_uid=0)then exit;
      if(uid_rebuild_uid=uidi)and(level>=LastUnitLevel)then exit;
      if(uid_rebuild_uid<>uidi)then
        with player^ do
          if(units_uid_m[uid_rebuild_uid]<=0)then exit;
      if not(uid_rebuild_uid in player^.a_rebuild)then exit;
   end;

   ui_HaveRebuild:=true;
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
//   COMMON STRING
//

function str_DateTime:shortstring;
var YY,MM,DD,H,M,S,MS:word;
function w2sZ(v,l:word):shortstring;
begin
   w2sZ:=w2s(v);
   if(l>0)then
     while(length(w2sZ)<l)do
       insert('0',w2sZ,1);
end;
begin
   DeCodeDate(Date,YY,MM,DD);
   DeCodeTime(Time,H,M,S,MS);
   str_DateTime:=w2sZ(YY,4)+'_'+w2sZ(MM,2)+'_'+w2sZ(DD,2)+' '+w2sZ(H,2)+'-'+w2sZ(M,2)+'-'+w2sZ(S,2)+'-'+w2sZ(MS,4);
end;

function str_Trim(s:shortstring;l:byte):shortstring;
var n:byte;
begin
   if(length(s)>l)then
   begin
      setlength(s,l);
      n:=0;
      while(l>0)and(n<3)do
      begin
         s[l]:='.';
         l-=1;
         n+=1;
      end;
   end;
   str_Trim:=s;
end;

function str_CutLast(s:shortstring;l:byte):shortstring;
var t:byte;
begin
   t:=length(s);
   if(t<=l)
   then str_CutLast:=s
   else str_CutLast:=copy(s,t-l+1,l);
end;

function str_GTick2Time(gtick:cardinal):shortstring;
var
s , m, h: cardinal;
ss,sm,sh:shortstring;
begin
   s:=gtick div fr_fps1;
   m:=s div 60;
   s:=s mod 60;
   h:=m div 60;
   m:=m mod 60;

   str_GTick2Time:='';
   if(h>0)then
   begin
      if(h<10)then sh:='0'+c2s(h) else sh:=c2s(h);
      str_GTick2Time:=sh+':';
   end;
   if(m<10)then sm:='0'+c2s(m) else sm:=c2s(m);
   if(s<10)then ss:='0'+c2s(s) else ss:=c2s(s);
   str_GTick2Time+=sm+':'+ss;
end;

function str_SpaceSize(str:shortstring;newSize:byte):shortstring;
var l,i:byte;
begin
   str_SpaceSize:=str;
   l:=0;
   i:=length(str_SpaceSize);
   while(i>0)do
   begin
      if not(str_SpaceSize[i] in tc_SpecChars)then l+=1;
      i-=1;
   end;
   if(newSize>l)then
   begin
      while(l<newSize)do
      begin
         l+=1;
         str_SpaceSize+=' ';
      end;
   end
   else
     if(newSize<l)then
       setlength(str_SpaceSize,newSize);
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
   begin
      InputActionPressed:=(ik_kstate=ks_pressed)
                        or(ik_kstate=ks_both   );
   end;
end;
function InputActionStuck(iact:byte):boolean;
begin
   with input_actions[iact] do
   begin
      InputActionStuck:=(ik_kstate=ks_hold)
                       and(ik_timer_pressed>k_LastCharStuckDelay);
   end;
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

function GameGetStatus(pstr:pshortstring;pcol:pcardinal;POVPlayer:byte):boolean;
begin
   GameGetStatus:=false;

   if(G_status<>gs_running)then
   begin
      GameGetStatus:=true;
      if(pstr<>nil)then pstr^:=str_gstat_Unknown;
      if(pcol<>nil)then pcol^:=c_gray;

      if(pstr<>nil)and(pcol<>nil)then
        case G_status of
0..LastPlayer : begin
                   pstr^:=str_gstat_GamePaused+g_gplayers[G_status].name;
                   pcol^:=PlayerGetColor(G_status,false);
                end;
gs_replayerror: begin
                   pstr^:=str_gstat_ReplayError+rpls_file_LastErrS;
                   pcol^:=c_white;
                end;
gs_replayend  : begin
                   pstr^:='';
                   pcol^:=c_white;
                end;
gs_waitserver : begin
                   pstr^:=str_gstat_WaitForServer;
                   pcol^:=PlayerGetColor(net_cl_Hoster,false);
                end;
gs_replaypause: begin
                   pstr^:=str_gstat_ReplayPaused;
                   pcol^:=c_white;
                end;
gs_win_team0..
gs_win_team7  : if(POVPlayer>LastPlayer)
                then pstr^:=''
                else
                  if((G_status-gs_win_team0)=g_gplayers[POVPlayer].team)then
                  begin
                     pstr^:=str_gstat_Win;
                     pcol^:=c_lime;
                  end
                  else
                  begin
                     pstr^:=str_gstat_Lose;
                     pcol^:=c_red;
                  end;
        end;

      if(rpls_pstate=rpls_read)and(rpls_file_pos>=rpls_file_size)then pstr^+=tc_nl2+tc_white+str_gstat_ReplayEnd;
   end;
end;

function MenuBack(offMenu,check:boolean):boolean;
begin
   MenuBack:=false;
   if(not MainMenu)then exit;

   if(GameNetServerSearch(false,check))then
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

   if(not G_Started)and(g_type<>0)and(net_status=ns_none)then
   begin
      MenuBack:=true;
      if(check)then exit;

      g_type:=0;
      menu_update:=true;
      if(not offMenu)then exit;
   end;

   if(G_Started)then
   begin
      MenuBack:=true;
      if(check)then exit;

      MainMenu     :=false;
      ui_update_now:=false;
      menu_update  :=true;
      menu_ItemSelected:=0;
   end;
end;
procedure GameOpenMenu;
begin
   if(MainMenu)then exit;

   MainMenu   :=true;
   menu_update:=true;
   menu_redraw_pause:=0;
   ui_update_timer:=0;
   menu_ItemSelected:=0;
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
var p:byte;
begin
   for p:=0 to LastPlayer do
   begin
      if(POVPlayer>LastPlayer)
      then PlayerColorsCurrent[p]:=PlayerColorsDefault[p]
      else
        case ui_PlayersColor of
        1,
        2,
        3: if(p=POVPlayer)then
             case ui_PlayersColor of
             1: PlayerColorsCurrent[p]:=c_lime;
             2,
             3: PlayerColorsCurrent[p]:=c_white;
             end
           else
                if(g_gplayers[POVPlayer].team<>g_gplayers[p].team)
                then PlayerColorsCurrent[p]:=c_red
                else
                  case ui_PlayersColor of
                  1,
                  2: PlayerColorsCurrent[p]:=c_yellow;
                  3: PlayerColorsCurrent[p]:=c_aqua;
                  end;
        4: PlayerColorsCurrent[p]:=PlayerColorsDefault[g_gplayers[p].team];
        5: if(p=POVPlayer)
           then PlayerColorsCurrent[p]:=c_white
           else PlayerColorsCurrent[p]:=PlayerColorsDefault[g_gplayers[p].team];
        else    PlayerColorsCurrent[p]:=PlayerColorsDefault[p];
        end;
      PlayerColorsShadow[p]:=gfx_ShadowColor(PlayerColorsCurrent[p]);
   end;
end;

function PlayerGetColor(player:byte;shadow:boolean):cardinal;
begin
   if(player>LastPlayer)then
     case shadow of
     false: PlayerGetColor:=PlayerColorDefaultCurrent;
     true : PlayerGetColor:=PlayerColorDefaultShadow;
     end
   else
     case shadow of
     false: PlayerGetColor:=PlayerColorsCurrent[player];
     true : PlayerGetColor:=PlayerColorsShadow [player];
     end;
end;

function GetKeyPointColor(keyPoint:byte;shadow:boolean):cardinal;
begin
   case shadow of
   false: GetKeyPointColor:=PlayerColorDefaultCurrent;
   true : GetKeyPointColor:=PlayerColorDefaultShadow;
   end;
   if(keyPoint>LastKeyPoint)then exit;
   with g_KeyPoints[keyPoint] do
     if(kpCaptureR>0)then
       if(kpTimer>0)and(ui_blink3=0)
       then GetKeyPointColor:=PlayerGetColor(kpTimerOwnerPlayer,shadow)
       else GetKeyPointColor:=PlayerGetColor(kpOwnerPlayer     ,shadow);
end;

function ui_SetPlayer(NewPlayerN:byte;check:boolean):boolean;
begin
   ui_SetPlayer:=false;

   if(NewPlayerN<>255)then
   begin
      if(NewPlayerN>=map_MaxPlayers)
      or(NewPlayerN>LastPlayer)then exit;

      with g_gplayers[NewPlayerN] do
        if(isobserver)and(not isdefeated)then exit;
   end;
   ui_SetPlayer:=true;

   if(check)then exit;

   UIPlayer:=NewPlayerN;
end;

function ui_ControlTabType:TTabControlContent;
begin
   ui_ControlTabType:=tcc_none;
   if(rpls_pstate>=rpls_read)
   then ui_ControlTabType:=tcc_replay
   else
     if((g_gplayers[LocalPlayer].isobserver)or(Game_IsEnded))and(g_type<>gt_campaing)
     then ui_ControlTabType:=tcc_observer
     else ui_ControlTabType:=tcc_controls;
end;

procedure ui_UpdateLastSelectedUnit(u:integer);
var tu:PTUnit;
begin
   if(IsUnitRange(u,@tu))then
   begin
      if(ui_UnitSelectedNU=0)
      then
      else
        if(tu^.uid^.uid_class>g_units[ui_UnitSelectedNU].uid^.uid_class)
        then
        else exit;
      ui_UnitSelectedNU:=u;
      ui_update_now:=true;
   end;
end;

function ui_UnitNeedDrawRange(pu:PTUnit):boolean;
begin
   with pu^  do
    with uid^ do
     ui_UnitNeedDrawRange:=(uid_CanAttack)
                         or(uid_isbuilder and not ukfly)
                         or(uid_ability=uab_UACScan)
                         or(uid_ability=uab_HEyeVision);
end;

function ui_MouseBrushNeedDrawEdges:boolean;
begin
   ui_MouseBrushNeedDrawEdges:=true;
   case m_brush of
   1..255     : exit;
   co_pability: if(ui_uibtn_pabilityu<>nil)then
                  case ui_uibtn_pabilityu^.uid^.uid_ability of
                  uab_HTowerBlink,
                  uab_HKeepShift,
                  uab_RebuildInPoint,
                  uab_UACCCLand         : exit;
                  end;
   end;
   ui_MouseBrushNeedDrawEdges:=false;
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
      if(rpls_pstate=rpls_read)
      or(g_gplayers[LocalPlayer].isobserver)then exit;
   end
   else
      if(tu^.TeamVision[g_gplayers[UIplayer].team]>0)then exit;

   ui_CheckUnitUIPlayerVision:=false;
end;

function ui_CheckUnitFullFogReveal(tu:PTUnit):boolean;
begin
   ui_CheckUnitFullFogReveal:=false;
   if(tu=nil)then exit;

   if(rpls_pstate>=rpls_read)
   or(g_gplayers[LocalPlayer].isobserver)then
   begin
      if(UIPlayer>LastPlayer)
      then ui_CheckUnitFullFogReveal:=true
      else
        if(tu^.player^.team=g_gplayers[UIPlayer].team)then ui_CheckUnitFullFogReveal:=true;
   end
   else ui_CheckUnitFullFogReveal:=(tu^.player^.team=g_gplayers[LocalPlayer].team);
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
   bx1:=map_Size-ui_cam_w;
   by1:=map_Size-ui_cam_h;
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
   ui_cam_mmx:=round(ui_cam_x*map_mmcx);
   ui_cam_mmy:=round(ui_cam_y*map_mmcx);
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
     with g_gplayers[UIPlayer] do
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
      if(not uid_issmith   )then ui_CommanderWeight+=128;
      if(not rld        <=0)then ui_CommanderWeight+=64;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   UI LOG
//

function ParseLogMessage(ptlog:PTLogMes;mcolor:pcardinal):shortstring;
procedure AddDataStr;
begin
   with ptlog^ do
     if(lm_data_u>0)then
       case lm_data_t of
       lmt_argt_unit   : with g_uids [lm_data_u] do ParseLogMessage+=' ('+uid_str_name +')';
       lmt_argt_upgrade: with g_upids[lm_data_u] do ParseLogMessage+=' ('+upgr_str_Name+')';
       lmt_argt_ability: with g_aids [lm_data_u] do ParseLogMessage+=' ('+ua_str_name  +')';
       end;
end;

begin
   ParseLogMessage:='';
   mcolor^:=c_white;
   with ptlog^ do
     case lm_type of
0..LastPlayer         : if(length(lm_string)>0)then
                        begin
                           //lm_type = sender
                           mcolor^:=PlayerGetColor(lm_type,false);
                           ParseLogMessage:=lm_string;
                        end;
lmt_chat_common       : ParseLogMessage:=lm_string;
lmt_Req_Limit         : ParseLogMessage:=str_warn_MaxLimitReached;
lmt_Req_MaxCount      : ParseLogMessage:=str_warn_MaxCountReached;
lmt_Req_Common,
lmt_Req_Energy,
lmt_prod_BadOrder,
lmt_prod_BadPlace     : begin
                           case lm_type of
                           lmt_Req_Common   : ParseLogMessage:=str_warn_Req_Common;
                           lmt_Req_Energy   : ParseLogMessage:=str_warn_Req_Energy;
                           lmt_prod_BadOrder: ParseLogMessage:=str_warn_prod_BadOrder;
                           lmt_prod_BadPlace: ParseLogMessage:=str_warn_prod_BadPlace;
                           end;
                           AddDataStr;
                        end;
lmt_prod_AllBusy      : ParseLogMessage:=str_warn_prod_AllBusy;

lmt_player_ready,
lmt_player_nready     : ParseLogMessage:=lm_string+str_lobby_PlayerReady[lm_type=lmt_player_ready];
lmt_player_surrender,
lmt_player_leave,
lmt_game_message      : ParseLogMessage:=lm_string;
lmt_game_end          : if(lm_data_u<=LastPlayer)and(UIPlayer<=LastPlayer)then
                          if(lm_data_u=g_gplayers[UIPlayer].team)
                          then ParseLogMessage:=str_gstat_Win
                          else ParseLogMessage:=str_gstat_Lose;
lmt_game_PlayersReady : ParseLogMessage:=str_lobby_AllPReady;
lmt_game_StartsIn     : ParseLogMessage:=str_lobby_GameStartIn+b2s(lm_data_u);

lmt_player_defeated   : if(lm_data_u<=LastPlayer)then ParseLogMessage:=g_gplayers[lm_data_u].name+str_gmsg_PlayerDefeat;
lmt_upgrade_InProgress: ParseLogMessage:=str_warn_upgrade_InProgress;
lmt_upgrade_complete  : begin
                        with g_upids[lm_data_u] do ParseLogMessage:=str_warn_upgrade_complete+' ('+upgr_str_Name+')';
                        mcolor^:=c_yellow;
                        end;
lmt_unit_ready        : begin
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
lmt_unit_LevelUp      : begin
                        with g_uids[lm_data_u] do ParseLogMessage:=str_warn_unit_Levelup+' ('+uid_str_name+')';
                        mcolor^:=c_aqua;
                        end;
lmt_allies_attacked   : begin
                        with g_uids[lm_data_u] do
                          ParseLogMessage:=str_warn_allies_attacked+' ('+uid_str_name+')';
                        mcolor^:=c_orange;
                        end;
lmt_unit_attacked     : begin
                        with g_uids[lm_data_u] do
                          if(uid_isbuilding)
                          then ParseLogMessage:=str_warn_base_attacked+' ('+uid_str_name+')'
                          else ParseLogMessage:=str_warn_unit_attacked+' ('+uid_str_name+')';
                        mcolor^:=c_red;
                        end;
lmt_kpoint_captured   : begin
                        ParseLogMessage:=str_warn_kpoint_captured;
                        mcolor^:=c_dred;
                        end;
lmt_kpoint_lost       : begin
                        ParseLogMessage:=str_warn_kpoint_lost;
                        mcolor^:=c_dred;
                        end;
lmt_koth_control      : begin
                        ParseLogMessage:=b2s(lm_data_u)+str_warn_koth_control;
                        mcolor^:=c_dred;
                        end;
lmt_ngen_exh          : begin
                        ParseLogMessage:=str_warn_ngen_exh;
                        mcolor^:=c_dyellow;
                        end;
lmt_ngen_captured     : begin
                        ParseLogMessage:=str_warn_ngen_captured;
                        mcolor^:=c_dyellow;
                        end;
lmt_ngen_lost         : begin
                        ParseLogMessage:=str_warn_ngen_lost;
                        mcolor^:=c_dyellow;
                        end;
lmt_ability_BadPlace  : begin
                        ParseLogMessage:=str_warn_AbilityBadPlace;
                        AddDataStr;
                        end;
lmt_ability_reload    : begin
                        ParseLogMessage:=str_warn_AbilityReload;
                        AddDataStr;
                        end;
lmt_invalid_Target    : ParseLogMessage:=str_warn_Invalid_Target;
lmt_Invalid_Order     : begin
                        ParseLogMessage:=str_warn_Invalid_Order;
                        AddDataStr;
                        end;

lmt_NeedProdUnit      : begin
                        ParseLogMessage:=str_warn_NeedProdUnit;
                        AddDataStr;
                        end;
lmt_unit_NeedBuilder  : begin
                        ParseLogMessage:=str_warn_NeedBuilder;
                        AddDataStr;
                        end;

lmt_map_mark          : begin
                        mcolor^:=c_gray;
                        if(lm_data_u<=LastPlayer)then
                          with g_gplayers[lm_data_u] do ParseLogMessage:=name+str_warn_mapMark;
                        end;
lmt_replay_RecStart   : begin
                        mcolor^:=c_brown;
                        ParseLogMessage:=str_gmsg_RecordStart+tc_white+lm_string;
                        end;
lmt_replay_RecStop    : begin
                        mcolor^:=c_brown;
                        ParseLogMessage:=str_gmsg_RecordStop +tc_white+lm_string;
                        end;
lmt_replay_RecError   : begin
                        mcolor^:=c_brown;
                        ParseLogMessage:=str_gmsg_RecordError+tc_white+lm_string;
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
acolor:cardinal;
procedure addLine(line:shortstring;ltype:byte;color:cardinal);
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
     with g_gplayers[playern] do
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
//   OTHER
//

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

function FileReadBaseGameInfo(var f:file;strInfoVar1,strInfoVar2:pshortstring):boolean;
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
   BlockRead(f,vbyte1,sizeof(map_generators));
   if(vbyte1>map_MaxGenerators             )then exit
                                            else strInfoVar1^+=' '+str_map_Generators+': '+str_map_GeneratorsL[vbyte1]+tc_nl2;
   vcard:=0;
   BlockRead(f,vcard ,sizeof(map_seed      ));   strInfoVar1^+=' '+str_map_Seed      +': '+c2s(vcard)+tc_nl2;

   vint:=-1;
   BlockRead(f,vint  ,sizeof(map_Size      ));
   if(vint<map_MinSize)or(map_MaxSize<vint )then exit
                                            else strInfoVar1^+=' '+str_map_Size      +': '+i2s(vint )+tc_nl2;
   vbyte1:=255;
   BlockRead(f,vbyte1,sizeof(map_ObstaclesF ));
   if(vbyte1>map_MaxObstacles              )then exit
                                            else strInfoVar1^+=' '+str_map_Obstacles +': '+strMX(vbyte1)+tc_nl2;

   vbyte1:=255;
   BlockRead(f,vbyte1,sizeof(map_Symmetry  ));   strInfoVar1^+=' '+str_map_Symmetry  +': '+b2cc[vbyte1>0]+tc_nl2;

   vint:=-1;
   BlockRead(f,vint  ,sizeof(theme_i       ));
   if(vint>=theme_n                        )then exit
                                            else strInfoVar1^+=' '+theme_name[vint]+tc_default+tc_nl2;

   lplayer:=255;
   BlockRead(f,lplayer,sizeof(LocalPlayer  ));

   strInfoVar1^+=tc_nl2;

   vcard:=0;
   BlockRead(f,vcard  ,sizeof(g_tick       ));   strInfoVar1^+=str_ui_time+str_GTick2Time(vcard)+tc_nl2+tc_nl2;

   strInfoVar1^+=str_Players+tc_nl2;
   //----------------  seconds string
   strInfoVar2^:='';
   for p:=0 to LastPlayer do
     with playerInfo do
     begin
        BlockRead(f,state   ,sizeof(state   ));
        BlockRead(f,name    ,sizeof(name    ));
        BlockRead(f,mrace   ,sizeof(mrace   ));
        BlockRead(f,team    ,sizeof(team    ));
        BlockRead(f,observer,sizeof(observer));
        if(length(name)>MaxPlayerNameLen)then SetLength(name,MaxPlayerNameLen);

        strInfoVar2^+=chr(p);
        if(p=lplayer)
        then strInfoVar2^+='>'
        else strInfoVar2^+='#';
        strInfoVar2^+=tc_default;

        strInfoVar2^+=str_SpaceSize(name,MaxPlayerNameLen+1);

        if(state>ps_None)then
          if(observer)
          then strInfoVar2^+=str_SpaceSize(str_observer   ,9)+b2s(team+1)
          else strInfoVar2^+=str_SpaceSize(str_race[mrace],9)+b2s(team+1);
        strInfoVar2^+=tc_nl2
     end;

   FileReadBaseGameInfo:=true;
end;

{$ELSE}

function PlayerAllOut:boolean;
var p,
c_players,
c_out    :byte;
begin
   c_players:=0;
   c_out    :=0;
   for p:=0 to MaxPlayers do
     with g_gplayers[p] do
     with g_nplayers[p] do
       if(state=PS_human)then
       begin
          c_players+=1;
          if(net_ttl>=ClientTTL)then c_out+=1;
       end;
   PlayerAllOut:=((c_out=c_players)and(c_players>0))or(c_players=0);
end;

{$ENDIF}



