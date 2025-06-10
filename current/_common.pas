procedure _unit_damage(pu:PTUnit;damage,pain_f:integer;pl:byte;IgnoreArmor:boolean);  forward;
procedure _unit_upgr  (pu:PTUnit);forward;
procedure aiu_InitVars(pu:PTUnit);forward;
procedure ai_InitVars(pu:PTUnit);forward;
procedure ai_SetCurrentAlarm(tu:PTUnit;x,y,ud:integer;zone:word);forward;
procedure aiu_CollectData(pu,tu:PTUnit;ud:integer;tu_transport:PTUnit);forward;
procedure ai_CollectData(pu,tu:PTUnit;ud:integer;tu_transport:PTUnit);forward;
procedure ai_scout_pick(pu:PTUnit);forward;
procedure aiu_code(pu:PTUnit);forward;
procedure ai_code(pu:PTUnit);forward;
function ai_HighPriorityTarget(player:PTPlayer;tu:PTUnit):boolean;forward;
function unit_canmove  (pu:PTUnit):boolean; forward;
function unit_canAttack(pu:PTUnit;check_buffs:boolean):boolean; forward;
function unit_canAbility(pu:PTUnit;CheckMode:byte=0):cardinal;  forward;
function _itcanapc(uu,tu:PTUnit):boolean;  forward;
function pf_IfObstacleZone(zone:word):boolean;  forward;
function point_dist_rint(dx0,dy0,dx1,dy1:integer):integer;  forward;

{$IFDEF _FULLGAME}
function ui_AddMarker(ax,ay:integer;av:byte;new:boolean):boolean;forward;
function _uid2spr(_uid:byte;dir:integer;level:byte):PTMWTexture;forward;
function LogMes2UIAlarm:boolean; forward;
procedure SoundLogUIPlayer(playern:byte);   forward;
procedure replay_SavePlayPosition;forward;
function replay_GetProgress:single;forward;

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
   if(uncappedFPS)and(not MainMenu)
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


function b2s (i:byte    ):shortstring;begin str(i,b2s );end;
function w2s (i:word    ):shortstring;begin str(i,w2s );end;
function c2s (i:cardinal):shortstring;begin str(i,c2s );end;
function i2s (i:integer ):shortstring;begin str(i,i2s );end;
function li2s(i:longint ):shortstring;begin str(i,li2s);end;
function si2s(i:single  ):shortstring;begin str(i,si2s);end;
function s2b (str:shortstring):byte    ;var t:integer;begin val(str,s2b ,t);end;
function s2w (str:shortstring):word    ;var t:integer;begin val(str,s2w ,t);end;
function s2i (str:shortstring):integer ;var t:integer;begin val(str,s2i ,t);end;
function s2c (str:shortstring):cardinal;var t:integer;begin val(str,s2c ,t);end;
function s2si(str:shortstring):single  ;var t:integer;begin val(str,s2si,t);end;

function t2c(l:byte):char;begin if(l=0)then t2c:='-' else t2c:=b2s(l)[1]; end;

function max2(x1,x2   :integer):integer;begin if(x1>x2)then max2:=x1 else max2:=x2;end;
function max3(x1,x2,x3:integer):integer;begin max3:=max2(max2(x1,x2),x3);end;
function min2(x1,x2   :integer):integer;begin if(x1<x2)then min2:=x1 else min2:=x2;end;
function min3(x1,x2,x3:integer):integer;begin min3:=min2(min2(x1,x2),x3);end;

function mm3(mnx,x,mxx:integer):integer;begin mm3:=min2(mxx,max2(x,mnx)); end;

function _str_mx(x:byte):shortstring;
begin
   if(x=0)
   then _str_mx:='-'
   else _str_mx:='x'+b2s(x);
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

////////////////////////////////////////////////////////////////////////////////
//
//   COMMON Players funcs
//

procedure PlayerSetAllowedUnits(p:byte;g:TSob;max:integer;new:boolean);    // allowed units
var i:byte;
begin
   with _players[p] do
   begin
      if(new)then FillChar(a_units,SizeOf(a_units),0);
      if(g<>[])then
       for i:=0 to 255 do
        if(i in g)then
         with _uids[i] do a_units[i]:=max;
   end;
end;
procedure PlayerSetAllowedUpgrades(p:byte;g:TSob;lvl:integer;new:boolean);  // allowed upgrades
var i:byte;
begin
   with _players[p] do
   begin
      if(new)then FillChar(a_upgrs,SizeOf(a_upgrs),0);
      if(g<>[])then
       for i:=0 to 255 do
        if(i in g)then
         with _upids[i] do a_upgrs[i]:=min2(_up_max,lvl);
   end;
end;
procedure PlayerSetCurrentUpgrades(p:byte;g:TSob;lvl:integer;new,NoCheck:boolean);  // current upgrades
var i:byte;
begin
   with _players[p] do
   begin
      if(new)then FillChar(upgr,SizeOf(upgr),0);
      if(g<>[])then
       for i:=0 to 255 do
        if(i in g)then
         with _upids[i] do
          if(NoCheck)
          then upgr[i]:=min2(_up_max,lvl)
          else upgr[i]:=min3(a_upgrs[i],_up_max,lvl);
   end;
end;

procedure PlayerAPMInc(player:byte);
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

////////////////////////////////////////////////////////////////////////////////
//
//   LOG
//

function PlayerAllies(playeri:byte;AddSelf:boolean):byte;
var i:byte;
begin
   PlayerAllies:=0;
   for i:=1 to MaxPlayers do
    with _players[i] do
     if(state>ps_none)and(team=_players[playeri].team)then
     begin
        if(not AddSelf)and(i=playeri)then continue;
        SetBBit(@PlayerAllies,i,true);
     end;
end;

function PlayerSetProdError(player,utp,uid:byte;cndt:cardinal;pu:PTUnit):boolean;
begin
   PlayerSetProdError:=false;
   if(player<=MaxPlayers)then
   with _players[player] do
   if(cndt>0)then
   begin
      prod_error_cndt:=cndt;
      prod_error_utp :=utp;
      prod_error_uid :=uid;
      if(pu<>nil)then
      begin
         prod_error_x:=mm3(1,pu^.x,map_mw);
         prod_error_y:=mm3(1,pu^.y,map_mw);
      end
      else
      begin
         prod_error_x:=-1;
         prod_error_y:=-1;
      end;
      PlayerSetProdError:=(cndt>0);
   end;
end;
procedure PlayerClearProdError(player:PTPlayer);
begin
   player^.prod_error_cndt:=0;
end;

function PlayerLogCheckNearEvent(playeri:byte;mtypes:TSoB;tickDiff:cardinal;x,y:integer):boolean;
var ln,li:cardinal;
begin
   PlayerLogCheckNearEvent:=true;
   with _players[playeri] do
   begin
      ln:=0;
      li:=log_i;

      while(ln<=MaxPlayerLog)do
      begin
         ln+=1;
         if(li>0)
         then li-=1
         else li:=MaxPlayerLog;

         with log_l[li] do
           if(tick>G_Step)or not(mtype in mtypes)
           then continue
           else
             if((G_Step-tick)<tickDiff)then
               if(x<0)or(y<0)
               then exit
               else
                 if (xi=x)
                 and(yi=y)
                 then exit
                 else
                   if(point_dist_rint(xi,yi,x,y)<base_2r)then exit;
      end;
   end;
   PlayerLogCheckNearEvent:=false;
end;

procedure PlayerAddLog(ptarget,amtype,aargt,aargx:byte;astr:shortstring;ax,ay:integer;local:boolean);
{$IFDEF _FULLGAME}
var ThisPlayer:byte;
{$ENDIF}
begin
   if(ptarget>MaxPlayers)then exit;

   with _players[ptarget] do
   if(state>ps_none)then
   begin
      case amtype of
0..MaxPlayers,
lmt_player_chat,
lmt_player_defeated,
lmt_player_leave,
lmt_player_surrender,
lmt_game_end,
lmt_game_message     :;
lmt_unit_attacked,
lmt_allies_attacked  : if(PlayerLogCheckNearEvent(ptarget,[lmt_unit_attacked,lmt_allies_attacked],fr_fps5,ax,ay))then exit;
lmt_unit_advanced    : if(PlayerLogCheckNearEvent(ptarget,[amtype],fr_fps5,ax,ay))then exit;
      else
         with log_l[log_i] do
           if(tick<=G_Step)then
             if (mtype=amtype)
             and(argt=aargt)
             and(argx=aargx)
             then
              if((G_Step-tick)<fr_fps3)then exit;
      end;

      if(not local)then
      log_n+=1;

      log_i+=1;
      if(log_i>MaxPlayerLog)then log_i:=0;

      with log_l[log_i] do
      begin
         mtype:=amtype;
         argt :=aargt;
         argx :=aargx;
         str  :=astr;
         xi   :=ax;
         yi   :=ay;
         tick :=g_Step;
      end;

      {$IFDEF _FULLGAME}
      if(net_status=ns_client)
      then ThisPlayer:=HPlayer
      else ThisPlayer:=UIPlayer;
      if(ptarget=ThisPlayer)then
      begin
         net_chat_shlm:=min2(net_chat_shlm+chat_shlm_t,chat_shlm_max);
         vid_menu_redraw:=true;

         if(LogMes2UIAlarm)then SoundLogUIPlayer(ThisPlayer);

         if(rpls_state<rpls_read)then
           if((amtype=lmt_player_defeated)and(g_deadobservers)and(aargx=UIPlayer))
           or(amtype=lmt_game_end)then
           begin
              ui_tab:=3;
              rpls_fog:=false;
              //UIPlayer:=0;
           end;
      end;
      {$ENDIF}
   end;
end;

procedure PlayersAddToLog(from_player,to_players,amtype,auidt,auid:byte;astr:shortstring;ax,ay:integer;local:boolean);
var i:byte;
begin
   for i:=0 to MaxPlayers do
    if((to_players and (1 shl i))>0)
    or(i=from_player)
    or(i=0)then PlayerAddLog(i,amtype,auidt,auid,astr,ax,ay,local);
end;

procedure GameLogChat(sender,targets:byte;message:shortstring;local:boolean);
begin
   if(targets>0)then
    if(sender<=MaxPlayers)
    then PlayersAddToLog(sender,targets,sender         ,0,0,message,0,0,local)
    else PlayersAddToLog(sender,targets,lmt_player_chat,0,0,message,0,0,local);
end;
procedure GameLogCommon(sender,targets:byte;message:shortstring;local:boolean);
begin
   PlayersAddToLog(sender,targets,lmt_game_message,0,0,message,0,0,local);
end;
procedure GameLogEndGame(wteam:byte);
begin
   if(ServerSide=false)then exit;
   PlayersAddToLog(0,log_to_all,lmt_game_end,0,wteam,'',0,0,false);
end;
procedure GameLogPlayerDefeated(player:byte);
begin
   if(player>MaxPlayers)or(ServerSide=false)then exit;
   PlayersAddToLog(player,log_to_all,lmt_player_defeated,0,player,'',0,0,false);
end;
procedure GameLogPlayerLeave(player:byte);
begin
   if(player>MaxPlayers)or(ServerSide=false)then exit;
   PlayersAddToLog(player,log_to_all,lmt_player_leave,0,0,_players[player].name+str_plout,0,0,false);
end;
procedure GameLogPlayerSurrender(player:byte);
begin
   if(player>MaxPlayers)or(ServerSide=false)then exit;
   PlayersAddToLog(player,log_to_all,lmt_player_surrender,0,0,_players[player].name+str_player_surrender,0,0,false);
end;
procedure GameLogUnitReady(pu:PTunit);
begin
   if(pu=nil)or(ServerSide=false)then exit;

   with pu^ do PlayersAddToLog(playeri,0,lmt_unit_ready,lmt_argt_unit ,uidi,'',x,y,false);
end;
procedure GameLogUnitPromoted(pu:PTunit);
begin
   if(pu=nil)or(ServerSide=false)then exit;

   with pu^ do
    PlayersAddToLog(playeri,0,lmt_unit_advanced,0,uidi,'',x,y,false);
end;
procedure GameLogUpgradeComplete(pl,upid:byte;x,y:integer);
begin
   if(pl>MaxPlayers)or(ServerSide=false)then exit;

   PlayersAddToLog(pl,0,lmt_upgrade_complete,0,upid,'',x,y,false);
end;
procedure GameLogCantProduction(pl,uid,utp:byte;condt:cardinal;x,y:integer;local:boolean);
var bt:byte;
begin
   if(pl>MaxPlayers)or(condt=0)then exit;

   with _players[pl] do
   begin
      if(state=ps_comp)then exit;

      if(a_units[uid]<=0)and(uid_e[uid]<=0)then exit;
   end;

   if((condt and ureq_place)>0)
   then bt:=lmt_cant_build
   else
     if((condt and ureq_ruid )>0)
     or((condt and ureq_rupid)>0)
     then bt:=lmt_req_ruids
     else
       if((condt and ureq_max )>0)
       then bt:=lmt_MaximumReached
       else
         if((condt and ureq_armylimit )>0)
         or((condt and ureq_unitlimit )>0)
         then bt:=lmt_unit_limit
         else
           if((condt and ureq_energy)>0)
           then bt:=lmt_req_energy
           else
             if((condt and ureq_smiths  )>0)
             or((condt and ureq_barracks)>0)
             then bt:=lmt_NeedMoreProd
             else
               if((condt and ureq_needbuilders)>0)
               or((condt and ureq_builders    )>0)
               then bt:=lmt_unit_needbuilder
               else
                 if((condt and ureq_busy)>0)
                 then bt:=lmt_production_busy
                 else
                   if((condt and ureq_alreadyAdv)>0)
                   then bt:=lmt_already_adv
                   else
                     if((condt and ureq_unknown   )>0)
                     then bt:=lmt_cant_order
                     else bt:=lmt_req_common;

   PlayersAddToLog(pl,0,bt,utp,uid,'',x,y,local);
end;
procedure GameLogMapMark(pl:byte;x,y:integer);
begin
   if(pl>MaxPlayers)or(ServerSide=false)then exit;

   PlayersAddToLog(pl,
   PlayerAllies(pl,true)
   ,lmt_map_mark,0,pl,'',x,y,false);
end;
procedure GameLogUnitAttacked(pu:PTunit);
begin
   if(pu=nil)or(ServerSide=false)then exit;

   with pu^ do
   begin
      PlayersAddToLog(playeri,0                          ,lmt_unit_attacked  ,0,uidi,'',x,y,false);
      PlayersAddToLog(playeri,PlayerAllies(playeri,false),lmt_allies_attacked,0,uidi,'',x,y,false);
   end;
end;

procedure PlayerClearLog(pn:byte);
var i:cardinal;
begin
   if(pn>MaxPlayers)then exit;

   with _players[pn] do
   begin
      FillChar(log_l,SizeOf(log_l),0);
      for i:=0 to MaxPlayerLog do
       with log_l[i] do
       begin
          xi:=-1;
          yi:=-1;
       end;
      log_n:=0;
      log_i:=0;
   end;
end;

procedure PlayersClearLog;
var i:byte;
begin
   for i:=0 to MaxPlayers do PlayerClearLog(i);
end;

////////////////////////////////////////////////////////////////////////////////

function PlayerObserver(player:PTPlayer):boolean;
begin
   with player^ do
   PlayerObserver:=(g_deadobservers and(armylimit<=0){$IFDEF _FULLGAME}and(rpls_state<rpls_read){$ENDIF})
                 or(team=0);
end;

function PlayersReadyStatus:boolean;
var p,c,r:byte;
begin
   c:=0;
   r:=0;
   for p:=1 to MaxPlayers do
    with _players[p] do
     if(state=ps_play)then
     begin
        c+=1;
        if(ready)or(p=HPlayer)then r+=1;
     end;
   PlayersReadyStatus:=(r=c)and(c>0);
end;

function PlayerGetTeam(gm,p:byte):byte;
begin
   PlayerGetTeam:=0;
   if(p<=MaxPlayers)then
    with _players[p] do
     if(team>0)then
      if(p=0)
      then PlayerGetTeam:=0
      else
        case gm of
gm_3x3     : case p of
             1..3: PlayerGetTeam:=1;
             4..6: PlayerGetTeam:=4;
             end;
gm_2x2x2   : case p of
             1,2 : PlayerGetTeam:=1;
             3,4 : PlayerGetTeam:=3;
             5,6 : PlayerGetTeam:=4;
             end;
gm_invasion:       PlayerGetTeam:=1;
        else       PlayerGetTeam:=_players[p].team;
        end;
end;

function PlayerGetStatus(p:byte):char;
begin
   with _players[p] do
   begin
      PlayerGetStatus:=str_ps_c[state];
      if(state=ps_play)then
      begin
         if(g_started=false)
         then PlayerGetStatus:=b2c[ready]
         else PlayerGetStatus:=str_ps_c[ps_play];
         if(ttl>=fr_fps1)then PlayerGetStatus:=str_ps_t;
         {$IFDEF _FULLGAME}
         if(net_cl_svpl=p)then
         begin
            PlayerGetStatus:=str_ps_sv;
            if(net_cl_svttl>=fr_fps1)then PlayerGetStatus:=str_ps_t;
         end;
         {$ENDIF}
      end;
      if(p=HPlayer)then PlayerGetStatus:=str_ps_h;
   end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure UpdatePlayersStatus;
var p:byte;
begin
   g_player_astatus:=0;
   g_player_rstatus:=0;
   g_cl_units      :=0;
   for p:=0 to MaxPlayers do
    with _players[p] do
    begin
       observer:=false;
       if(state>ps_none)then
       begin
          SetBBit(@g_player_rstatus,p,revealed);
          observer:=PlayerObserver(@_players[p]);
          if(army>0)then
          begin
             SetBBit(@g_player_astatus,p,true);
             g_cl_units+=MaxPlayerUnits;
          end;
       end;
    end;
end;

function sign(x:integer):integer;
begin
   sign:=0;
   if(x>0)then sign:= 1;
   if(x<0)then sign:=-1;
end;

function point_dist_rint(dx0,dy0,dx1,dy1:integer):integer;
begin
   dx0:=abs(dx1-dx0);
   dy0:=abs(dy1-dy0);
   if(dx0<dy0)
   then point_dist_rint:=(123*dy0+51*dx0) shr 7
   else point_dist_rint:=(123*dx0+51*dy0) shr 7;
end;

function point_dist_int(dx0,dy0,dx1,dy1:integer):integer;
begin
   point_dist_int:=round(sqrt(sqr(abs(dx0-dx1))+sqr(abs(dy0-dy1))));
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

function _DIR360(d:integer):integer;
begin
   _DIR360:=d mod 360;
   if(_DIR360<0)then _DIR360:=_DIR360+360;
end;

function dir_turn(d1,d2,spd:integer):integer;
var d:integer;
begin
   d:=dir_diff(d2,d1);

   if abs(d)<=spd
   then dir_turn:=d2
   else dir_turn:=d1+(spd*sign(d));
   dir_turn:=_DIR360(dir_turn);
end;

function _IsUnitRange(u:integer;ppu:PPTUnit):boolean;
begin
   _IsUnitRange:=false;
   if(0<u)and(u<=MaxUnits)then
   begin
      _IsUnitRange:=true;
      if(ppu<>nil)then ppu^:=@_units[u];
   end;
end;

function _AddToInt(bt:pinteger;val:integer):boolean;
begin
   _AddToInt:=false;
   if(bt^<val)then
   begin
      bt^:=val;
      _AddToInt:=true;
   end;
end;

function _CheckRoyalBattlePoint(x,y,d:integer):boolean;
begin
   if(g_mode=gm_royale)
   then _CheckRoyalBattlePoint:=(point_dist_int(x,y,map_hmw,map_hmw)+d)>=g_royal_r
   else _CheckRoyalBattlePoint:=false;
end;

function _random(m:integer):integer;
const a = 4;
      t : array[byte] of byte = (
   //   0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
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
   map_rpos+=1;
   map_iseed:=map_iseed*a+t[map_rpos];
   if(m=0)
   then _random:=0
   else _random:=abs(integer(map_iseed) mod m);
end;

function _randomx(x,m:integer):integer;
begin
   if(m=0)
   then _randomx:=0
   else
   begin
      map_iseed+=word(x);
      _randomx:=_random(m);
   end;
end;

function _randomr(r:integer):integer;
begin
   if(r=0)
   then _randomr:=0
   else _randomr:=_random(r)-_random(r);
end;

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

function _uid_player_limit(pl:PTPlayer;uid:byte):boolean;
begin
   with pl^ do
    with _uids[uid] do
     if(_ukbuilding)and(menergy<=0)
     then _uid_player_limit:=false
     else _uid_player_limit:=((uid_e[uid]+uprodu[uid])<a_units[uid])and((army+uproda)<MaxPlayerUnits)and((armylimit+uprodl+_limituse)<=MaxPlayerLimit);
end;

function _uid_conditionals(pl:PTPlayer;uid:byte):cardinal;
procedure setr(ni:cardinal;b:boolean);
begin if(b)then _uid_conditionals:=_uid_conditionals or ni;end;
begin
   _uid_conditionals:=0;
   with pl^ do
   with _uids[uid] do
   begin
      setr(ureq_unitlimit ,(army     +uproda          )>=MaxPlayerUnits);
      setr(ureq_armylimit ,(armylimit+uprodl+_limituse)> MaxPlayerLimit);
      setr(ureq_ruid      ,(_ruid1>0)and(uid_eb[_ruid1]<_ruid1n));
      setr(ureq_ruid      ,(_ruid2>0)and(uid_eb[_ruid2]<_ruid2n));
      setr(ureq_ruid      ,(_ruid3>0)and(uid_eb[_ruid3]<_ruid3n));
      setr(ureq_rupid     ,(_rupgr>0)and(upgr  [_rupgr]<_rupgrl));
      setr(ureq_energy    , cenergy<_renergy                     );
      setr(ureq_time      , _btime<=0                            );
      setr(ureq_max       ,((uid_e[uid]+uprodu[uid])>=a_units[uid])or
                          ((_isbuilder)and(e_builders>=PlayerMaxBuilders)));

      case _ukbuilding of
true  : begin
           setr(ureq_builders ,n_builders<=0);
           setr(ureq_bld_r    ,build_cd  > 0);
        end;
false : setr(ureq_barracks    ,n_barracks<=0);
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

function _upid_energy(upgr,lvl:byte):integer;
begin
   _upid_energy:=0;
   with _upids[upgr] do
    if(0<lvl)and(lvl<=_up_max)then
     if(_up_mfrg)or((_up_renerg_xpl<=0)and(_up_renerg_apl<=0))
     then _upid_energy:=_up_renerg
     else
     begin
        lvl-=1;
        _upid_energy:=(_up_renerg*ipower(_up_renerg_xpl,lvl))+(_up_renerg_apl*lvl);
     end;
end;
function _upid_time(upgr,lvl:byte):integer;
const upgr_max_time = fr_fps1*255;
begin
   _upid_time:=0;
   with _upids[upgr] do
    if(0<lvl)and(lvl<=_up_max)then
     if(_up_mfrg)or((_up_time_xpl<=0)and(_up_time_apl<=0))
     then _upid_time:=_up_time
     else
     begin
        lvl-=1;
        _upid_time:=min2(upgr_max_time,_up_time*ipower(_up_time_xpl,lvl)+(_up_time_apl*lvl));
     end;
end;

function _upid_conditionals(pl:PTPlayer;up:byte):cardinal;
procedure setr(ni:cardinal;b:boolean);
begin if(b)then _upid_conditionals:=_upid_conditionals or ni;end;
begin
   _upid_conditionals:=0;
   with pl^ do
   with _upids[up] do
   begin
      setr(ureq_ruid   ,(_up_ruid >0)and(uid_eb[_up_ruid ]=0)  );
      setr(ureq_rupid  ,(_up_rupgr>0)and(upgr  [_up_rupgr]=0)  );
      setr(ureq_energy , cenergy<_upid_energy(up,upgr[up]+1)   );
      setr(ureq_time   , _up_time<=0                           );
      setr(ureq_max    ,(integer(upgr[up]+upprodu[up])>=min2(_up_max,a_upgrs[up])));
      setr(ureq_product,(_up_mfrg=false)and(upprodu[up]>0)     );
      setr(ureq_smiths , n_smiths<=0                           );
   end;
end;

function _Hi2Si(h,mh:integer;s:single):shortint;
begin
   if(h>=mh                         )then _Hi2Si:=127  else
   if(h =0                          )then _Hi2Si:=0    else
   if(h =dead_hits                  )then _Hi2Si:=-127 else
   if(h<=ndead_hits                 )then _Hi2Si:=-128 else
   if(fdead_hits<h)and(h<0          )then _Hi2Si:=mm3(-125,h div _d2shi,-1  ) else
   if( dead_hits<h)and(h<=fdead_hits)then _Hi2Si:=-126 else
                                          _Hi2Si:=mm3(   1,trunc(h/s)  ,_mms);
end;

function ai_name(ain:byte):shortstring;
begin
   if(ain=0)
   then ai_name:=str_ps_none
   else
     {$IFDEF _FULLGAME}
     case ain of
     0  : ai_name:=str_ps_comp+' '+tc_gray  +b2s(ain)+tc_default;
     1  : ai_name:=str_ps_comp+' '+tc_blue  +b2s(ain)+tc_default;
     2  : ai_name:=str_ps_comp+' '+tc_aqua  +b2s(ain)+tc_default;
     3  : ai_name:=str_ps_comp+' '+tc_lime  +b2s(ain)+tc_default;
     4  : ai_name:=str_ps_comp+' '+tc_green +b2s(ain)+tc_default;
     5  : ai_name:=str_ps_comp+' '+tc_yellow+b2s(ain)+tc_default;
     6  : ai_name:=str_ps_comp+' '+tc_orange+b2s(ain)+tc_default;
     7  : ai_name:=str_ps_comp+' '+tc_red   +b2s(ain)+tc_default;
     8  : ai_name:=str_ps_comp+' '+tc_purple+b2s(ain)+tc_default+' cheater';
     else ai_name:=str_ps_comp+' '+tc_white +b2s(ain)+tc_default+' cheater';
     end;
     {$ELSE}
     ai_name:=str_ps_comp+' '+b2s(ain);
     {$ENDIF}
end;

procedure PlayerSwitchAILevel(p:byte);
begin
   with _players[p] do
    if(state=PS_Comp)then
    begin
       ai_skill+=1;
       if(ai_skill>gms_g_maxai)then ai_skill:=1;
       name:=ai_name(ai_skill);
    end;
end;

function _UnitHaveRPoint(uid:byte):boolean;
begin
   with _uids[uid] do
   _UnitHaveRPoint:=(_isbarrack)or(_ability=uab_Teleport);
end;

function UnitF1Select(pu:PTUnit):boolean;
begin
   UnitF1Select:=false;
   with pu^  do
   with uid^ do
   begin
      if(hits<=0)
      or(not iscomplete)
      or(_IsUnitRange(transport,nil))then exit;

      if(not _isbuilder)then exit;

   end;
   UnitF1Select:=true;
end;

function UnitF2Select(pu:PTUnit):boolean;
var tu:PTUnit;
begin
   UnitF2Select:=false;
   with pu^  do
   with uid^ do
   begin
      if(hits<=0)
      or(not iscomplete)
      or(_IsUnitRange(transport,nil))then exit;

      if(speed          <=0)then exit;
      if(_ukbuilding       )then exit;
      if(_attack  =atm_none)then exit;
      if(uo_id=ua_psability)
      or(uo_id=ua_hold     )
      or(uo_bx>0           )then exit;

      if(_IsUnitRange(uo_tar,@tu))then
      begin
         if(tu^.uid^._ability=uab_Teleport)and(not ukfly)then exit;

         if(_itcanapc(pu,tu))
         or(_itcanapc(tu,pu))then exit;
      end;
   end;
   UnitF2Select:=true;
end;

function unit_canRebuild(pu:PTUnit):cardinal;
begin
   unit_canRebuild:=0;
   if(pu=nil)
   then unit_canRebuild:=ureq_unknown
   else
     with pu^     do
     with uid^    do
      if(iscomplete=false)
      or(hits<=0)
      or(_rebuild_uid=0)
      or((_rebuild_uid=pu^.uidi)and(level>=MaxUnitLevel))
      then unit_canRebuild:=ureq_alreadyAdv
      else
        with player^ do
        begin
           if(_rebuild_ruid>0)then
            if(uid_eb[_rebuild_ruid]<=0)then unit_canRebuild+=ureq_ruid;

           if(_rebuild_rupgr>0)and(_rebuild_rupgrl>0)then
            if(upgr[_rebuild_rupgr]<_rebuild_rupgrl)then unit_canRebuild+=ureq_rupid;
        end;
end;

function unit_canAbility(pu:PTUnit;CheckMode:byte=0):cardinal;
procedure AddUREQ(ureq:cardinal);
begin
   unit_canAbility:=unit_canAbility or ureq;
end;
begin
   unit_canAbility:=0;
   if(pu=nil)
   then AddUREQ(ureq_unknown)
   else
     with pu^     do
     with uid^    do
      if(not iscomplete)
      or(hits<=0)
      or(_ability=0)
      or(rld>0)
      then AddUREQ(ureq_unknown)
      else
        with player^ do
        begin
           // basic checks
           case CheckMode of
           1: if not(_ability in uab_abilityOrder )then AddUREQ(ureq_common );
           2: if not(_ability in uab_pabilityOrder)then AddUREQ(ureq_unknown);
           end;

           if(_ability_no_obstacles)then
            if(pf_IfObstacleZone(pfzone))then unit_canAbility+=ureq_place;

           if(_ability_ruid>0)then
            if(uid_eb[_ability_ruid]<=0)then unit_canAbility+=ureq_ruid;

           if(_ability_rupgr>0)and(_ability_rupgrl>0)then
            if(upgr[_ability_rupgr]<_ability_rupgrl)then unit_canAbility+=ureq_rupid;

           if(_ability=uab_RebuildInPoint)and(unit_canAbility=0)then unit_canAbility+=unit_canRebuild(pu);

           case _ability of
           uab_Unload : if(transportC=0)then AddUREQ(ureq_common);
           end;
        end;
end;

procedure GameSetStatusWinnerTeam(team:byte);
begin
   if(team<=MaxPlayers)then
   G_status:=gs_win_team0+team;
   GameLogEndGame(team);
end;

function CheckUnitBaseFlags(tu:PTUnit;flags:cardinal):boolean;
begin
   CheckUnitBaseFlags:=false;

   if((flags and wtr_unit    )=0)and(not tu^.uid^._ukbuilding   )then exit;
   if((flags and wtr_building)=0)and(    tu^.uid^._ukbuilding   )then exit;

   if((flags and wtr_bio     )=0)and(not tu^.uid^._ukmech       )then exit;
   if((flags and wtr_mech    )=0)and(    tu^.uid^._ukmech       )then exit;

   if((flags and wtr_light   )=0)and    (tu^.uid^._uklight      )then exit;
   if((flags and wtr_heavy   )=0)and not(tu^.uid^._uklight      )then exit;

   if((flags and wtr_ground  )=0)and(tu^.ukfly = uf_ground      )then exit;
   if((flags and wtr_fly     )=0)and(tu^.ukfly = uf_fly         )then exit;

   CheckUnitBaseFlags:=true;
end;

function CheckUnitTeamVision(POVTeam:byte;tu:PTUnit;SkipInvisCheck:boolean):boolean;
begin
   with tu^ do
     if(buff[ub_Invis]<=0)or(hits<=0)or(SkipInvisCheck)
     then CheckUnitTeamVision:=(vsnt[POVTeam]>0)
     else CheckUnitTeamVision:=(vsnt[POVTeam]>0)and(vsni[POVTeam]>0);
end;

{$IFDEF _FULLGAME}

function GameCheckEndStatus:boolean;
begin
   GameCheckEndStatus:=(gs_win_team0<=G_status)and(G_status<=gs_win_team6);
end;

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

procedure UpdateLastSelectedUnit(u:integer);
var tu:PTUnit;
begin
   if(_IsUnitRange(u,@tu))then
   begin
      if(ui_UnitSelectedNU=0)
      then
      else
        if(tu^.uid^._ucl>_units[ui_UnitSelectedNU].uid^._ucl)
        then
        else exit;
      ui_UnitSelectedNU:=u;
   end;
end;


function UIUnitDrawRange(pu:PTUnit):boolean;
begin
   with pu^  do
    with uid^ do
     UIUnitDrawRange:=(_attack>0)
                    or(isbuildarea)
                    or(_ability=uab_UACScan)
                    or(_ability=uab_HellVision);
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
procedure ScrollByte(pb:pbyte;fwrd:boolean;min,max:byte);
begin
   if(fwrd)then
   begin
      if(pb^<255)then
      begin
         pb^+=1;
         if(pb^>max)then pb^:=max;
      end;
   end
   else
      if(pb^>0  )then
      begin
         pb^-=1;
         if(pb^<min)then pb^:=min;
      end;
end;


procedure ScrollInt(i:pinteger;s,min,max:integer);
begin
   i^+=s;
   if(i^>max)then i^:=max;
   if(i^<min)then i^:=min;
end;

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

function fog_check(x,y:integer):boolean;
var cx,cy:integer;
begin
   x+=vid_cam_fx;
   y+=vid_cam_fy;
   cx:=x div fog_cw;
   cy:=y div fog_cw;
   fog_check:=false;
   if(0<=cx)and(cx<=fog_vfwm)
  and(0<=cy)and(cy<=fog_vfhm)then fog_check:=(vid_fog_pgrid[cx,cy]>0);
end;

function RectInCam(x,y,hw,hh,s:integer):boolean;
begin
   RectInCam:=((vid_cam_x-hw          )<x)and(x<(vid_cam_x+vid_cam_w+hw))
           and((vid_cam_y-hh-max2(0,s))<y)and(y<(vid_cam_y+vid_cam_h+hh));
end;
function PointInCam(x,y:integer):boolean;
begin
   PointInCam:=(vid_cam_x<x)and(x<(vid_cam_x+vid_cam_w))
            and(vid_cam_y<y)and(y<(vid_cam_y+vid_cam_h));
end;

function CheckUnitUIVision(tu:PTUnit):boolean;
begin
   CheckUnitUIVision:=true;

   if(not rpls_fog)then exit;

   if(UIPlayer=0)then
     if(rpls_state>=rpls_read)or(_players[HPlayer].observer)or(GameCheckEndStatus)then exit;

   if(tu<>nil)then
     if(tu^.player^.team=_players[UIPlayer].team)then exit;

   CheckUnitUIVision:=false;
end;

function CheckUnitUIVisionScreen(tu:PTUnit):boolean;
begin
   CheckUnitUIVisionScreen:=false;
   with tu^ do
    with uid^ do
     if(RectInCam(vx,vy,_r,_r,0))then
     begin
        if(UIPlayer=0)then
          if(rpls_state=rpls_read)or(_players[HPlayer].observer)or(GameCheckEndStatus)then
          begin
             CheckUnitUIVisionScreen:=true;
             exit;
          end;

        CheckUnitUIVisionScreen:=(vsnt[_players[UIPlayer].team]>0)or(not rpls_fog);
     end;
end;

function MapPointInScreenP(x,y:integer;CheckSquare:boolean):boolean;
begin
   MapPointInScreenP:=false;
   x-=vid_cam_x;
   y-=vid_cam_y;
   if(-fog_cw<x)and(x<(vid_cam_w+fog_cw))and
     (-fog_cw<y)and(y<(vid_cam_h+fog_cw))then
   begin
      if(not rpls_fog)
      then MapPointInScreenP:=true
      else MapPointInScreenP:=fog_check(x,y);
      if(CheckSquare)and(not MapPointInScreenP)then
      begin
         x+=vid_cam_x;
         y+=vid_cam_y;
         MapPointInScreenP:=MapPointInScreenP(x-fog_cw,y,false)or
                            MapPointInScreenP(x+fog_cw,y,false)or
                            MapPointInScreenP(x,y+fog_cw,false)or
                            MapPointInScreenP(x,y-fog_cw,false)or
                            MapPointInScreenP(x-fog_cw,y-fog_cw,false)or
                            MapPointInScreenP(x+fog_cw,y-fog_cw,false)or
                            MapPointInScreenP(x+fog_cw,y+fog_cw,false)or
                            MapPointInScreenP(x-fog_cw,y+fog_cw,false);
      end;
   end;
end;

function PlayerGetColor(player:byte):cardinal;
begin
   PlayerGetColor:=c_white;
   if(player<=MaxPlayers)then
    case vid_plcolors of
   1,
   2,
   3: if(player=UIPlayer)then
         case vid_plcolors of
         1: PlayerGetColor:=c_lime;
         2,
         3: PlayerGetColor:=c_white;
         end
      else
        if(PlayerGetTeam(g_mode,UIPlayer)=PlayerGetTeam(g_mode,player))then
          case vid_plcolors of
          1,
          2: PlayerGetColor:=c_yellow;
          3: PlayerGetColor:=c_aqua;
          end
        else PlayerGetColor:=c_red;
   4: PlayerGetColor:=PlayerColor[PlayerGetTeam(g_mode,player)];
   5: if(player=UIPlayer)
      then PlayerGetColor:=c_white
      else PlayerGetColor:=PlayerColor[PlayerGetTeam(g_mode,player)];
    else PlayerGetColor:=PlayerColor[player];
    end;
end;

function GetCPColor(cp:byte):cardinal;
function PlayerForCPColor(p:byte):byte;
begin
   PlayerForCPColor:=p;
   if(0<p)and(p<=MaxPlayers)and(UIPlayer>0)then
     if(_players[UIPlayer].team=_players[p].team)then PlayerForCPColor:=UIPlayer;
end;
begin
   GetCPColor:=c_black;
   if(cp<1)or(cp>MaxCPoints)then exit;
   with g_cpoints[cp] do
    if(cpCaptureR>0)then
     if(cpTimer>0)and(r_blink3=0)
     then GetCPColor:=PlayerGetColor(PlayerForCPColor(cpTimerOwnerPlayer))
     else GetCPColor:=PlayerGetColor(PlayerForCPColor(cpOwnerPlayer     ))
end;

function GameGetStatus(pstr:pshortstring;pcol:pcardinal;VisPlayer:byte):boolean;
var t:byte;
begin
   GameGetStatus:=false;

   if(G_status>gs_running)then
   begin
      GameGetStatus:=true;
      if(pstr<>nil)then pstr^:=str_gsunknown;
      if(pcol<>nil)then pcol^:=c_gray;

      if(pstr<>nil)and(pcol<>nil)then
      case G_status of
1..MaxPlayers : begin
                   pstr^:=str_pause;
                   pcol^:=PlayerGetColor(G_status);
                end;
gs_replayerror: begin
                   pstr^:=str_reperror;
                   pcol^:=c_white;
                end;
gs_replayend  : begin
                   pstr^:=str_repend;
                   pcol^:=c_white;
                end;
gs_waitserver : begin
                   pstr^:=str_waitsv;
                   pcol^:=PlayerGetColor(net_cl_svpl);
                end;
gs_replaypause: begin
                   pstr^:=str_pause;
                   pcol^:=c_white;
                end;
      else
         if(gs_win_team0<=G_status)and(G_status<=gs_win_team6)then
           if(VisPlayer=0)then
           begin
              if(pstr<>nil)then pstr^:='';
           end
           else
           begin
              t:=G_status-gs_win_team0;
              if(t=_players[VisPlayer].team)then
              begin
                 pstr^:=str_win;
                 pcol^:=c_lime;
              end
              else
              begin
                 pstr^:=str_lose;
                 pcol^:=c_red;
              end;
           end;
      end;
   end;
end;

procedure ToggleMenu;
begin
   if(G_Started)then
   begin
      MainMenu:=not MainMenu;
      vid_menu_redraw:=MainMenu;
      menu_item:=0;
      if(net_status=ns_none)and(g_Status<=MaxPlayers)then
       if(MainMenu)
       then g_Status:=HPlayer
       else g_Status:=gs_running;
   end;
end;

procedure CamBounds;
begin
   vid_cam_x:=mm3(0,vid_cam_x,map_mw-vid_cam_w);
   vid_cam_y:=mm3(0,vid_cam_y,map_mw-vid_cam_h);
   vid_cam_fx:=(vid_cam_x mod fog_cw);
   vid_cam_fy:=(vid_cam_y mod fog_cw);

   vid_mmvx:=round(vid_cam_x*map_mmcx);
   vid_mmvy:=round(vid_cam_y*map_mmcx);
   vid_fog_sx :=vid_cam_x div fog_cw;
   vid_fog_sy :=vid_cam_y div fog_cw;
   vid_fog_ex :=vid_fog_sx+vid_fog_vfw;
   vid_fog_ey :=vid_fog_sy+vid_fog_vfh;
end;

procedure MoveCamToPoint(mx,my:integer);
begin
   vid_cam_x:=mx-(vid_cam_w shr 1);
   vid_cam_y:=my-(vid_cam_h shr 1);
   CamBounds;
end;

function _Si2Hi(sh:shortint;mh:integer;s:single):integer;
begin
   case sh of
127     : _Si2Hi:=mh;
1..126  : _Si2Hi:=mm3(1,trunc(sh*s),mh-1);
0       : _Si2Hi:=0;
-125..-1: _Si2Hi:=mm3(dead_hits+1,sh*_d2shi,-1);
-126    : _Si2Hi:=fdead_hits;
-127    : _Si2Hi:=dead_hits;
-128    : _Si2Hi:=ndead_hits;
   end;
end;

procedure MoveCamToLastEvent;
var log_pi:cardinal;
begin
   with _players[UIPlayer] do
   begin
      log_pi:=log_i;
      while true do
      begin
         with log_l[log_pi] do
          if(xi>0)or(yi>0)then
          begin
             MoveCamToPoint(xi,yi);
             break;
          end;
         if(log_pi>0)
         then log_pi-=1
         else log_pi:=MaxPlayerLog;
         if(log_pi=log_i)then exit;
      end;
   end;
end;

function ParseLogMessage(ptlog:PTLogMes;mcolor:pcardinal):shortstring;
begin
   ParseLogMessage:='';
   mcolor^:=c_white;
   with ptlog^ do
    case mtype of
0..MaxPlayers        : if(length(str)>0)then
                       begin
                          //mtype = sender
                          mcolor^:=PlayerGetColor(mtype);
                          ParseLogMessage:=_players[mtype].name+': '+str;
                       end;
lmt_req_ruids,
lmt_req_common,
lmt_req_energy,
lmt_cant_build       : begin
                          case mtype of
                          lmt_req_ruids : ParseLogMessage:=str_check_reqs;
                          lmt_req_common: ParseLogMessage:=str_cant_prod;
                          lmt_req_energy: ParseLogMessage:=str_need_energy;
                          lmt_cant_build: ParseLogMessage:=str_cant_build;
                          end;
                          if(argx>0)then
                            case argt of
                          lmt_argt_unit: with _uids [argx] do ParseLogMessage+=' ('+un_txt_name+')';
                          lmt_argt_upgr: with _upids[argx] do ParseLogMessage+=' ('+_up_name   +')';
                            end;
                       end;
lmt_player_chat,
lmt_game_message     ,
lmt_player_surrender,
lmt_player_leave     : ParseLogMessage:=str;//if(argx<=MaxPlayers)then ParseLogMessage:=_players[argx].name+str_plout;
lmt_game_end         : if(argx<=MaxPlayers)then
                        if(argx=_players[UIPlayer].team)
                        then ParseLogMessage:=str_win
                        else ParseLogMessage:=str_lose;
lmt_player_defeated  : if(argx<=MaxPlayers)then ParseLogMessage:=_players[argx].name+str_player_def;
lmt_upgrade_complete : begin
                       with _upids[argx] do ParseLogMessage:=str_upgrade_complete+' ('+_up_name+')';
                       mcolor^:=c_yellow;
                       end;
lmt_unit_ready       : begin
                       with _uids[argx] do
                        case argt of
                         lmt_argt_unit : if(_ukbuilding)
                                     then ParseLogMessage:=str_building_complete+' ('+un_txt_name+')'
                                     else ParseLogMessage:=str_unit_complete    +' ('+un_txt_name+')';
                        end;
                       mcolor^:=c_green;
                       end;
lmt_unit_advanced    : begin
                       with _uids[argx] do ParseLogMessage:=str_unit_advanced+' ('+un_txt_name+')';
                       mcolor^:=c_aqua;
                       end;
lmt_allies_attacked  : begin
                       with _uids[argx] do
                        ParseLogMessage:=str_allies_attacked+' ('+un_txt_name+')';
                       mcolor^:=c_orange;
                       end;
lmt_unit_attacked    : begin
                       with _uids[argx] do
                        if(_ukbuilding)
                        then ParseLogMessage:=str_base_attacked+' ('+un_txt_name+')'
                        else ParseLogMessage:=str_unit_attacked+' ('+un_txt_name+')';
                       mcolor^:=c_red;
                       end;
lmt_cant_order       : begin
                       ParseLogMessage:=str_cant_execute;
                       with _uids [argx] do ParseLogMessage+=' ('+un_txt_name+')';
                       end;
lmt_MaximumReached   : ParseLogMessage:=str_MaximumReached;
lmt_NeedMoreProd     : ParseLogMessage:=str_NeedMoreProd;
lmt_already_adv      : ParseLogMessage:=str_cant_advanced;
lmt_production_busy  : ParseLogMessage:=str_production_busy;
lmt_unit_needbuilder : ParseLogMessage:=str_need_more_builders;
lmt_unit_limit       : ParseLogMessage:=str_maxlimit_reached;
lmt_map_mark         : begin
                       mcolor^:=c_gray;
                       if(argx<=MaxPlayers)then
                         with _players[argx] do ParseLogMessage:=name+str_mapMark;
                       end;
    else               ParseLogMessage:='UNKNOWN MESSAGE TYPE'; mcolor^:=c_purple;
    end;
end;

procedure MakeLogListForDraw(playern:byte;widthchars,listheight:integer;logtypes:TSoB);
var ts:shortstring;
mc,n,i:cardinal;
chunkp,
chunkl,
chunks:integer;
 st,sl:byte;
procedure _add(s:shortstring;t:byte;c:cardinal);
begin
   if(ui_log_n>=listheight)then exit;
   ui_log_n+=1;
   SetLength(ui_log_s,ui_log_n);
   SetLength(ui_log_t,ui_log_n);
   SetLength(ui_log_c,ui_log_n);
   ui_log_s[ui_log_n-1]:=s;
   ui_log_t[ui_log_n-1]:=t;
   ui_log_c[ui_log_n-1]:=c;
end;
begin
   ui_log_n:=0;
   SetLength(ui_log_s,ui_log_n);
   SetLength(ui_log_t,ui_log_n);
   SetLength(ui_log_c,ui_log_n);

   if(listheight>MaxPlayerLog)then listheight:=MaxPlayerLog;

   if(widthchars>0)and(listheight>0)then
   with _players[playern] do
   begin
      widthchars+=1;
      i:=log_i;
      n:=listheight;

      while(n>0)do
      begin
         mc:=c_white;
         st:=log_l[i].mtype;
         if(st in logtypes)
         then ts:=ParseLogMessage(@log_l[i],@mc)
         else ts:='';
         sl:=length(ts);
         if(i=0)
         then i:=MaxPlayerLog
         else i-=1;
         n-=1;

         if(sl>0)then
          if(sl<=widthchars)
          then _add(ts,st,mc)
          else
          begin
             chunks:=sl div widthchars;
             while(chunks>=0)do
             begin
                chunkp:=chunks*widthchars+1;
                if(chunkp>sl)then continue;
                chunkl:=widthchars;
                if((chunkl+chunkp)>sl)then
                begin
                   chunkl:=(sl mod widthchars);
                   if(chunkl<=0)then chunkl:=1;
                end;
                _add(copy(ts,chunkp,chunkl),st,mc);
                chunks-=1;
             end;
          end;
      end;
   end;
   while(ui_log_n<listheight)do _add('',0,0);
end;

procedure _LoadingScreen(load_str:pshortstring;color:cardinal);
begin
   SDL_FillRect(r_screen,nil,0);
   stringColor(r_screen,(vid_vw div 2)-(length(load_str^)*font_w div 2), vid_vh div 2,@(load_str^[1]),color);
   SDL_FLIP(r_screen);
end;

{$ELSE}

function PlayerAllOut:boolean;
var i,c,r:byte;
begin
   c:=0;
   r:=0;
   for i:=1 to MaxPlayers do
    with _Players[i] do
     if (state=PS_Play) then
     begin
        c+=1;
        if(ttl=ClientTTL)then r+=1;
     end;
   PlayerAllOut:=(r=c)and(c>0);
end;

{$ENDIF}



