
////////////////////////////////////////////////////////////////////////////////
//
//   FORWARD Declarations
//

procedure unit_damage(pu:PTUnit;damage,pain_f:integer;pl:byte;IgnoreArmor:boolean);forward;
procedure unit_Bonuses (pu:PTUnit);forward;
function unit_canMove  (pu:PTUnit):boolean; forward;
function unit_canAttack(pu:PTUnit;check_buffs:boolean):boolean; forward;
function unit_sability (pu:PTUnit;check:boolean):cardinal;      forward;
function unit_pability (pu:PTUnit;taru,tarx,tary:integer;check:boolean):cardinal;forward;
function unit_rebuild  (pu:PTUnit;check:boolean):cardinal;      forward;
function unit_CheckTransport(uTransport,uTarget:PTUnit):boolean;forward;

procedure aiu_InitVars(pu:PTUnit);forward;
procedure aiu_CollectData(pu,tu:PTUnit;ud:integer;tu_transport:PTUnit);forward;
procedure aiu_code(pu:PTUnit);forward;

procedure ai_InitVars(pu:PTUnit);forward;
procedure ai_SetCurrentAlarm(tu:PTUnit;x,y,ud:integer;zone:word);forward;
procedure ai_CollectData(pu,tu:PTUnit;ud:integer;tu_transport:PTUnit);forward;
procedure ai_scout_pick(pu:PTUnit);forward;
procedure ai_code(pu:PTUnit);forward;
function ai_HighPriorityTarget(player:PTPlayer;tu:PTUnit):boolean;forward;

function pf_IfObstacleZone(zone:word):boolean;  forward;
function point_dist_rint(dx0,dy0,dx1,dy1:integer):integer;  forward;

{$IFDEF _FULLGAME}
procedure vid_LoadingScreen(load_str:pshortstring;color:cardinal);  forward;
function ui_AddMarker(ax,ay:integer;av:byte;new:boolean):boolean;forward;
function uid2spr(auid:byte;dir:integer;level:byte):PTMWTexture;forward;
function LogMes2UIAlarm:boolean; forward;
procedure SoundLogUIPlayer(playern:byte);   forward;

function menu_MouseXY2Item:byte; forward;
function menu_ReadyButtonEnabled:boolean;forward;
function PlayerNameChangeble  :boolean;forward;

function PlayersSlotEnabled:boolean;forward;
function PlayerAIToggle  (player:byte;check:boolean):boolean;forward;
function PlayerRaceChange(player:byte;check:boolean):boolean;forward;
function PlayerTeamChange(player:byte;forward,check:boolean):boolean;forward;

function saveload_Save  (check:boolean):boolean;forward;
function saveload_Load  (check:boolean):boolean;forward;
function saveload_Delete(check:boolean):boolean;forward;

procedure replay_SavePlayPosition;forward;
function replay_Delete(check:boolean):boolean;forward;
function replay_Play  (check:boolean):boolean;forward;
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

// team to char
function t2c(l:byte):char;begin if(l=0)then t2c:='-' else t2c:=b2s(l)[1]; end;

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

procedure PlayerSetAllowedUnits(p:byte;g:TSob;max:integer;new:boolean);    // allowed units
var i:byte;
begin
   with g_players[p] do
   begin
      if(new)then FillChar(a_units,SizeOf(a_units),0);
      if(g<>[])then
       for i:=0 to 255 do
        if(i in g)then
         with g_uids[i] do a_units[i]:=max;
   end;
end;
procedure PlayerSetAllowedUpgrades(p:byte;g:TSob;lvl:integer;new:boolean);  // allowed upgrades
var i:byte;
begin
   with g_players[p] do
   begin
      if(new)then FillChar(a_upgrs,SizeOf(a_upgrs),0);
      if(g<>[])then
       for i:=0 to 255 do
        if(i in g)then
         with g_upids[i] do a_upgrs[i]:=min2i(_up_max,lvl);
   end;
end;
procedure PlayerSetCurrentUpgrades(p:byte;g:TSob;lvl:integer;new,NoCheck:boolean);  // current upgrades
var i:byte;
begin
   with g_players[p] do
   begin
      if(new)then FillChar(upgr,SizeOf(upgr),0);
      if(g<>[])then
       for i:=0 to 255 do
        if(i in g)then
         with g_upids[i] do
          if(NoCheck)
          then upgr[i]:=min2i(_up_max,lvl)
          else upgr[i]:=min3i(a_upgrs[i],_up_max,lvl);
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   APM Counter
//

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

function PlayerGetAlliesByte(playeri:byte;AddSelf:boolean):byte;
var p:byte;
begin
   PlayerGetAlliesByte:=0;
   for p:=1 to LastPlayer do
     with g_players[p] do
       if(state>ps_none)then
       begin
          if(not AddSelf)and(p=playeri)then continue;

          case g_players[playeri].observer of
          false: if(team<>g_players[playeri].team)then continue;
          true : if(not observer)then continue;
          end;
          SetBBit(@PlayerGetAlliesByte,p,true);
       end;
end;

function PlayerSetProdError(player,utp,uid:byte;cndt:cardinal;pu:PTUnit):boolean;
begin
   PlayerSetProdError:=false;
   if(player<=LastPlayer)then
   with g_players[player] do
   if(cndt>0)then
   begin
      prod_error_cndt:=cndt;
      if(pu<>nil)then
      begin
         prod_error_x:=mm3i(1,pu^.x,map_Size);
         prod_error_y:=mm3i(1,pu^.y,map_Size);
         if(utp=lmt_argt_abil)then
           if(uid=0)or(uid=254)or(uid=255)then uid:=pu^.uid^._ability;
      end
      else
      begin
         prod_error_x:=-1;
         prod_error_y:=-1;
      end;
      prod_error_utp :=utp;
      prod_error_uid :=uid;
      PlayerSetProdError:=true;
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
   with g_players[playeri] do
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
           if(tick>g_tick)or not(mtype in mtypes)
           then continue
           else
             if((g_tick-tick)<tickDiff)then
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
   if(ptarget>LastPlayer)then exit;

   with g_players[ptarget] do
   if(state>ps_none)then
   begin
      case amtype of
0..LastPlayer,
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
           if(tick<=g_tick)then
             if (mtype=amtype)
             and(argt=aargt)
             and(argx=aargx)
             then
              if((g_tick-tick)<fr_fps3)then exit;
      end;

      if(ServerSide)then log_n+=1;

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
         tick :=g_tick;
      end;

      {$IFDEF _FULLGAME}
      if(ptarget=rpls_player)and(rpls_log_c<MaxPlayerLog)and(rpls_fstate=rpls_write)then rpls_log_c+=1;

      if(net_status=ns_client)
      then ThisPlayer:=LocalPlayer
      else ThisPlayer:=UIPlayer;
      if(ptarget=ThisPlayer)then
      begin
         net_chat_shlm:=min2i(net_chat_shlm+chat_LastMsgTime,chat_LastMsgTimeMax);
         menu_update:=true;

         if(LogMes2UIAlarm)then SoundLogUIPlayer(ThisPlayer);

         if(rpls_pstate<rpls_read)and(g_type<>gt_campaing)then
           if((amtype=lmt_player_defeated)and(g_DefeatedObs)and(aargx=UIPlayer))
           or(amtype=lmt_game_end)then
           begin
              ui_tab:=3;
              ui_fog:=false;
              //UIPlayer:=0;
           end;
      end;
      {$ENDIF}
   end;
end;

procedure PlayersAddToLog(from_player,to_players,amtype,auidt,auid:byte;astr:shortstring;ax,ay:integer;local:boolean);
var i:byte;
begin
   for i:=0 to LastPlayer do
    if((to_players and (1 shl i))>0)
    or(i=from_player)
    or(i=0)then PlayerAddLog(i,amtype,auidt,auid,astr,ax,ay,local);
end;

procedure GameLogChat(sender,targets:byte;message:shortstring;local:boolean);
begin
   if(targets>0)then
    if(sender<=LastPlayer)
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
   if(player>LastPlayer)or(ServerSide=false)then exit;
   PlayersAddToLog(player,log_to_all,lmt_player_defeated,0,player,'',0,0,false);
end;
procedure GameLogPlayerLeave(player:byte);
begin
   if(player>LastPlayer)or(ServerSide=false)then exit;
   PlayersAddToLog(player,log_to_all,lmt_player_leave,0,0,g_players[player].name+str_gmsg_PlayerLeft,0,0,false);
end;
procedure GameLogPlayerSurrender(player:byte);
begin
   if(player>LastPlayer)or(ServerSide=false)then exit;
   PlayersAddToLog(player,log_to_all,lmt_player_surrender,0,0,g_players[player].name+str_gmsg_PlayerSurrender,0,0,false);
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
   if(pl>LastPlayer)or(ServerSide=false)then exit;

   PlayersAddToLog(pl,0,lmt_upgrade_complete,0,upid,'',x,y,false);
end;
procedure GameLogCantProduction(pl,uid,utp:byte;condt:cardinal;x,y:integer;local:boolean);
var bt:byte;
begin
   if(pl>LastPlayer)or(condt=0)then exit;

   with g_players[pl] do
   begin
      if(state=ps_ai)then exit;

      if(uid>0)and(utp=lmt_argt_unit)then
        if(a_units[uid]<=0)and(uid_e[uid]<=0)then exit;
   end;

   if((condt and ureq_usespability)>0)
   then bt:=lmt_ability_needSP
   else
     if((condt and ureq_usesability)>0)
     then bt:=lmt_ability_needS
     else
       if((condt and ureq_place)>0)
       then bt:=lmt_cant_build
       else
         if((condt and ureq_landplace)>0)
         then bt:=lmt_ability_cantland
         else
           if((condt and ureq_ruid )>0)
           or((condt and ureq_rupid)>0)
           then bt:=lmt_req_ruids
           else
             if((condt and ureq_reloading)>0)
             then bt:=lmt_ability_reload
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
                             if((condt and ureq_invalidtar)>0)
                             then bt:=lmt_invalid_tar
                             else
                               if((condt and ureq_unknown   )>0)
                               then bt:=lmt_cant_order
                               else bt:=lmt_req_common;

   PlayersAddToLog(pl,0,bt,utp,uid,'',x,y,local);
end;
procedure GameLogMapMark(pl:byte;x,y:integer);
begin
   if(pl>LastPlayer)or(ServerSide=false)then exit;

   PlayersAddToLog(pl,
   PlayerGetAlliesByte(pl,true)
   ,lmt_map_mark,0,pl,'',x,y,false);
end;
procedure GameLogUnitAttacked(pu:PTunit);
begin
   if(pu=nil)or(ServerSide=false)then exit;

   with pu^ do
   begin
      PlayersAddToLog(playeri,0                          ,lmt_unit_attacked  ,0,uidi,'',x,y,false);
      PlayersAddToLog(playeri,PlayerGetAlliesByte(playeri,false),lmt_allies_attacked,0,uidi,'',x,y,false);
   end;
end;
procedure GameLogCPointCaptured(from_player,cpoint,to_team:byte);
begin
   if(to_team>LastPlayer)
   or(from_player>LastPlayer)
   or(LastKeyPoint<cpoint)then exit;

   if(cpoint=0)and(map_scenario=mc_KotH)then exit;

   with g_KeyPoints[cpoint] do
     if(cpenergy>0)
     then PlayersAddToLog(from_player,PlayerGetAlliesByte(from_player,false),lmt_ngen_captured  ,0,0,'',cpx,cpy,false)
     else PlayersAddToLog(from_player,PlayerGetAlliesByte(from_player,false),lmt_cpoint_captured,0,0,'',cpx,cpy,false);
end;
procedure GameLogCPointLost(from_player,cpoint,to_team:byte);
begin
   if(to_team>LastPlayer)
   or(from_player>LastPlayer)
   or(LastKeyPoint<cpoint)then exit;

   if(cpoint=0)and(map_scenario=mc_KotH)then exit;

   with g_KeyPoints[cpoint] do
     if(cpenergy>0)
     then PlayersAddToLog(from_player,PlayerGetAlliesByte(from_player,false),lmt_ngen_lost  ,0,0,'',cpx,cpy,false)
     else PlayersAddToLog(from_player,PlayerGetAlliesByte(from_player,false),lmt_cpoint_lost,0,0,'',cpx,cpy,false);
end;
procedure GameLogKotHControl;
begin
   if(map_scenario<>mc_KotH)then exit;

   with g_KeyPoints[0] do
     PlayersAddToLog(255,255,lmt_koth_control,0,cpTimerOwnerTeam,'',cpx,cpy,false);
end;
procedure GameLogNgenExh(from_player,cpoint,to_team:byte);
begin
   if(to_team>LastPlayer)
   or(from_player>LastPlayer)
   or(LastKeyPoint<cpoint)then exit;

   if(cpoint=0)and(map_scenario=mc_KotH)then exit;

   with g_KeyPoints[cpoint] do
     PlayersAddToLog(from_player,PlayerGetAlliesByte(from_player,false),lmt_ngen_exh  ,0,0,'',cpx,cpy,false);
end;

procedure PlayerClearLog(pn:byte);
var i:cardinal;
begin
   if(pn>LastPlayer)then exit;

   with g_players[pn] do
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
   for i:=0 to LastPlayer do PlayerClearLog(i);
end;

function PlayerObserver(player:PTPlayer):boolean;
begin
   with player^ do
   PlayerObserver:=(g_DefeatedObs and(armylimit<=0){$IFDEF _FULLGAME}and(rpls_pstate<rpls_read){$ENDIF})
                 or(team=0);
end;

function PlayersReadyStatus:boolean;
var p,c,r:byte;
begin
   c:=0;
   r:=0;
   for p:=1 to LastPlayer do
    with g_players[p] do
     if(state=ps_human)then
     begin
        c+=1;
        if(ready){$IFDEF _FULLGAME}or(p=LocalPlayer){$ENDIF}then r+=1;
     end;
   PlayersReadyStatus:=(r=c)and(c>0);
end;

function PlayerGetFixedTeams(gm,p:byte):byte;
begin
   PlayerGetFixedTeams:=0;
   if(p<=LastPlayer)then
     with g_players[p] do
       case gm of
mc_3x3     : case p of
             1..3: PlayerGetFixedTeams:=1;
             4..6: PlayerGetFixedTeams:=4;
             end;
mc_2x2x2   : case p of
             1,2 : PlayerGetFixedTeams:=1;
             3,4 : PlayerGetFixedTeams:=3;
             5,6 : PlayerGetFixedTeams:=4;
             end;
mc_invasion:       PlayerGetFixedTeams:=1;
       else        PlayerGetFixedTeams:=p;
       end;
end;

function PlayerValidateTeam(p,nt:byte):byte;
begin
   PlayerValidateTeam:=0;
   if(p<=LastPlayer)then
     with g_players[p] do
       if(nt>0)then
         if(map_scenario in mc_fixed_teams)
         then PlayerValidateTeam:=PlayerGetFixedTeams(map_scenario,p)
         else
           case state of
           ps_none : PlayerValidateTeam:=p;
           ps_human : if(team>LastPlayer)
                     then PlayerValidateTeam:=0
                     else PlayerValidateTeam:=nt;
           ps_ai : if(team>LastPlayer)or(team=0)
                     then PlayerValidateTeam:=p
                     else PlayerValidateTeam:=nt;
           end;
end;
procedure PlayersValidateTeam;
var p:byte;
begin
   for p:=1 to LastPlayer do
     with g_players[p] do
       team:=PlayerValidateTeam(p,team);
   {$IFDEF _FULLGAME}
   PlayerTeam:=PlayerValidateTeam(LocalPlayer,PlayerTeam);
   {$ENDIF}
end;

function PlayerGetStatus(p:byte):char;
begin
   with g_players[p] do
   begin
      PlayerGetStatus:=str_ps_c[state];
      if(state=ps_human)then
      begin
         if(g_started=false)
         then PlayerGetStatus:=b2c[ready]
         else PlayerGetStatus:=str_ps_c[ps_human];
         if(ttl>=fr_fps1)then PlayerGetStatus:=str_ps_t;
         {$IFDEF _FULLGAME}
         if(net_cl_Hoster=p)then
         begin
            PlayerGetStatus:=str_ps_sv;
            if(net_cl_svttl>=fr_fps1)then PlayerGetStatus:=str_ps_t;
         end;
         {$ENDIF}
      end;
      {$IFDEF _FULLGAME}
      if(p=LocalPlayer)then PlayerGetStatus:=str_ps_h;
      {$ENDIF}
   end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure UpdatePlayersStatus;
var p:byte;
begin
   g_player_astatus:=0;
   g_player_rstatus:=0;
   g_cl_units      :=0;
   for p:=0 to LastPlayer do
    with g_players[p] do
    begin
       observer:=false;
       if(state>ps_none)then
       begin
          SetBBit(@g_player_rstatus,p,revealed);
          observer:=PlayerObserver(@g_players[p]);
          if(army>0)then
          begin
             SetBBit(@g_player_astatus,p,true);
             g_cl_units+=MaxPlayerUnits;
          end;
       end;
    end;
end;


function IsUnitRange(u:integer;ppu:PPTUnit):boolean;
begin
   IsUnitRange:=false;
   if(0<u)and(u<=MaxUnits)then
   begin
      IsUnitRange:=true;
      if(ppu<>nil)then ppu^:=@g_units[u];
   end;
end;



function _CheckRoyalBattlePoint(x,y,d:integer):boolean;
begin
   if(map_scenario=mc_royale)
   then _CheckRoyalBattlePoint:=(point_dist_int(x,y,map_hmw,map_hmw)+d)>=g_royal_r
   else _CheckRoyalBattlePoint:=false;
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

function _uid_player_limit(pl:PTPlayer;uid:byte):boolean;
begin
   with pl^ do
    with g_uids[uid] do
     if(_ukbuilding)and(menergy<=0)
     then _uid_player_limit:=false
     else _uid_player_limit:=((uid_e[uid]+uprodu[uid])<a_units[uid])and((army+uproda)<MaxPlayerUnits)and((armylimit+uprodl+_limituse)<=MaxPlayerLimit);
end;

function CheckUnitReqs(pl:PTPlayer;uid:byte;forRebuildCheck:boolean=false):cardinal;
procedure setr(ni:cardinal;b:boolean);
begin if(b)then CheckUnitReqs:=CheckUnitReqs or ni;end;
begin
   CheckUnitReqs:=0;
   with pl^ do
   with g_uids[uid] do
   begin
      if(not forRebuildCheck)then
      begin
      setr(ureq_unitlimit ,(army     +uproda          )>=MaxPlayerUnits);
      setr(ureq_armylimit ,(armylimit+uprodl+_limituse)> MaxPlayerLimit);
      end;
      setr(ureq_ruid      ,(_ruid1>0)and(uid_eb[_ruid1]<_ruid1n));
      setr(ureq_ruid      ,(_ruid2>0)and(uid_eb[_ruid2]<_ruid2n));
      setr(ureq_ruid      ,(_ruid3>0)and(uid_eb[_ruid3]<_ruid3n));
      setr(ureq_rupid     ,(_rupgr>0)and(upgr  [_rupgr]<_rupgrl));
      setr(ureq_energy    , cenergy<_renergy                     );
      setr(ureq_time      , _btime<=0                            );
      if(not forRebuildCheck)then
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

function GetUpgradeEnergy(upgr,lvl:byte):integer;
begin
   GetUpgradeEnergy:=0;
   with g_upids[upgr] do
    if(0<lvl)and(lvl<=_up_max)then
     if(_up_mfrg)or((_up_renerg_xpl<=0)and(_up_renerg_apl<=0))
     then GetUpgradeEnergy:=_up_renerg
     else
     begin
        lvl-=1;
        GetUpgradeEnergy:=(_up_renerg*ipower(_up_renerg_xpl,lvl))+(_up_renerg_apl*lvl);
     end;
end;
function GetUpgradeTime(upgr,lvl:byte):integer;
const upgr_max_time = fr_fps1*255;
begin
   GetUpgradeTime:=0;
   with g_upids[upgr] do
    if(0<lvl)and(lvl<=_up_max)then
     if(_up_mfrg)or((_up_time_xpl<=0)and(_up_time_apl<=0))
     then GetUpgradeTime:=_up_time
     else
     begin
        lvl-=1;
        GetUpgradeTime:=min2i(upgr_max_time,_up_time*ipower(_up_time_xpl,lvl)+(_up_time_apl*lvl));
     end;
end;

function CheckUpgradeReqs(pl:PTPlayer;up:byte):cardinal;
procedure setr(ni:cardinal;b:boolean);
begin if(b)then CheckUpgradeReqs:=CheckUpgradeReqs or ni;end;
begin
   CheckUpgradeReqs:=0;
   with pl^ do
   with g_upids[up] do
   begin
      setr(ureq_ruid   ,(_up_ruid >0)and(uid_eb[_up_ruid ]=0)  );
      setr(ureq_rupid  ,(_up_rupgr>0)and(upgr  [_up_rupgr]=0)  );
      setr(ureq_energy , cenergy<GetUpgradeEnergy(up,upgr[up]+1)   );
      setr(ureq_time   , _up_time<=0                           );
      setr(ureq_max    ,(integer(upgr[up]+upprodu[up])>=min2i(_up_max,a_upgrs[up])));
      setr(ureq_product,(_up_mfrg=false)and(upprodu[up]>0)     );
      setr(ureq_smiths , n_smiths<=0                           );
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   OTHER
//

function _Hi2Si(h,mh:integer;s:single):shortint;
begin
   if(h>=mh                         )then _Hi2Si:=127  else
   if(h =0                          )then _Hi2Si:=0    else
   if(h =dead_hits                  )then _Hi2Si:=-127 else
   if(h<=ndead_hits                 )then _Hi2Si:=-128 else
   if(fdead_hits<h)and(h<0          )then _Hi2Si:=mm3i(-125,h div _d2shi,-1  ) else
   if( dead_hits<h)and(h<=fdead_hits)then _Hi2Si:=-126 else
                                          _Hi2Si:=mm3i(   1,trunc(h/s)  ,_mms);
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

function UnitHaveRPoint(uid:byte):boolean;
begin
   with g_uids[uid] do
   UnitHaveRPoint:=(_isbarrack)or(_ability=uab_Teleport);
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
      or(IsUnitRange(transport,nil))then exit;

      if(speed          <=0)then exit;
      if(_ukbuilding       )then exit;
      if(_attack  =atm_none)then exit;
      if(uo_id=ua_psability)
      or(uo_id=ua_hold     )
      or(uo_bx>0           )then exit;

      if(IsUnitRange(uo_tar,@tu))then
      begin
         if(tu^.uid^._ability=uab_Teleport)and(not ukfly)then exit;

         if(unit_CheckTransport(pu,tu))
         or(unit_CheckTransport(tu,pu))then exit;
      end;
   end;
   UnitF2Select:=true;
end;

procedure GameSetStatusWinnerTeam(team:byte);
begin
   if(team>LastPlayer)then exit;

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

function ui_ability(pu:PTUnit;pability:boolean):boolean;
begin
   ui_ability:=false;

   if(pu=nil)then exit;
   with pu^ do
   with uid^ do
   begin
      if(hits<=0)
      or(_ability=0)
      or(not iscomplete)then exit;

      if not(_ability in player^.a_ability)then exit;

      case pability of
      false: if not(_ability in uab_sabilityOrder)then exit;
      true : if not(_ability in uab_pabilityOrder)then exit;
      end;
   end;

   ui_ability:=true;
end;

function ui_rebuild(pu:PTUnit):boolean;
begin
   ui_rebuild:=false;

   if(pu=nil)then exit;

   with pu^ do
   with uid^ do
   begin
      if(hits<=0)
      or(not iscomplete)then exit;
      if(_rebuild_uid=0)then exit;
      if(_rebuild_uid=uidi)and(level>=MaxUnitLevel)then exit;
      if(_rebuild_uid<>uidi)and(player^.a_units[_rebuild_uid]<=0)then exit;
      if not(_rebuild_uid in player^.a_rebuild)then exit;
   end;

   ui_rebuild:=true;
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

////////////////////////////////////////////////////////////////////////////////
//
//   INPUT
//

function InputAction(iact:byte):boolean;
begin
   InputAction:=input_actions[iact].ik_timer_pressed>0;
end;
function InputActionPressed(iact:byte):boolean;
begin
   InputActionPressed:=input_actions[iact].ik_timer_pressed=1;
end;
function InputActionReleased(iact:byte):boolean;
begin
   InputActionReleased:=input_actions[iact].ik_timer_pressed=-1;
end;
function InputActionDPressed(iact:byte):boolean;
begin
   with input_actions[iact] do
   InputActionDPressed:=(ik_timer_pressed=1)and(ik_timer_twice>0);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   GAME
//

function Game_IsEnded:boolean;
begin
   Game_IsEnded:=(gs_win_team0<=G_status)and(G_status<=gs_win_team6);
end;

function PlayerGetColor(player:byte):cardinal;
begin
   PlayerGetColor:=c_white;
   if(player<=LastPlayer)then
     case ui_PlayersColor of
     1,
     2,
     3: if(player=UIPlayer)then
          case ui_PlayersColor of
          1: PlayerGetColor:=c_lime;
          2,
          3: PlayerGetColor:=c_white;
          end
        else
          if(g_players[UIPlayer].team<>g_players[player].team)
          then PlayerGetColor:=c_red
          else
            case ui_PlayersColor of
            1,
            2: PlayerGetColor:=c_yellow;
            3: PlayerGetColor:=c_aqua;
            end;
     4: PlayerGetColor:=PlayerColors[g_players[player].team];
     5: if(player=UIPlayer)
        then PlayerGetColor:=c_white
        else PlayerGetColor:=PlayerColors[g_players[player].team];
     else    PlayerGetColor:=PlayerColors[player];
     end;
end;

function GetKeyPointColor(cp:byte):cardinal;
function PlayerForKeyPointColor(p:byte):byte;
begin
   PlayerForKeyPointColor:=p;
   if(0<p)and(p<=LastPlayer)and(UIPlayer>0)then
     if(g_players[UIPlayer].team=g_players[p].team)then PlayerForKeyPointColor:=UIPlayer;
end;
begin
   GetKeyPointColor:=c_black;
   if(cp>LastKeyPoint)then exit;
   with g_KeyPoints[cp] do
     if(cpCaptureR>0)then
       if(cpTimer>0)and(ui_blink3=0)
       then GetKeyPointColor:=PlayerGetColor(PlayerForKeyPointColor(cpTimerOwnerPlayer))
       else GetKeyPointColor:=PlayerGetColor(PlayerForKeyPointColor(cpOwnerPlayer     ))
end;

function GameGetStatus(pstr:pshortstring;pcol:pcardinal;VisPlayer:byte):boolean;
var t:byte;
begin
   GameGetStatus:=false;

   if(G_status>gs_running)then
   begin
      GameGetStatus:=true;
      if(pstr<>nil)then pstr^:=str_gstat_Unknown;
      if(pcol<>nil)then pcol^:=c_gray;

      if(pstr<>nil)and(pcol<>nil)then
      case G_status of
1..LastPlayer : begin
                   pstr^:=str_gstat_Pauseed;
                   pcol^:=PlayerGetColor(G_status);
                end;
gs_replayerror: begin
                   pstr^:=str_gstat_ReplayError;
                   pcol^:=c_white;
                end;
gs_replayend  : begin
                   pstr^:=str_gstat_ReplayEnd;
                   pcol^:=c_white;
                end;
gs_waitserver : begin
                   pstr^:=str_gstat_WaitForServer;
                   pcol^:=PlayerGetColor(net_cl_Hoster);
                end;
gs_replaypause: begin
                   pstr^:=str_gstat_Pauseed;
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
              if(t=g_players[VisPlayer].team)then
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
      end;
   end;
end;

function GameBack(offMenu,check:boolean):boolean;
begin
   GameBack:=false;
   if(not MainMenu)then exit;

   if(menu_page<>0)then
   begin
      GameBack:=true;
      if(check)then exit;

      menu_page:=0;
      menu_update:=true;
      if(not offMenu)then exit;
   end;

   if(not G_Started)and(g_type<>0)and(net_status=ns_none)then
   begin
      GameBack:=true;
      if(check)then exit;

      g_type:=0;
      menu_update:=true;
      if(not offMenu)then exit;
   end;

   if(G_Started)then
   begin
      GameBack:=true;
      if(check)then exit;

      MainMenu   :=false;
      menu_update:=true;
      menu_ItemSelected  :=0;
      if(net_status=ns_none)and(g_Status<=LastPlayer)then
        if(MainMenu)
        then g_Status:=LocalPlayer
        else g_Status:=gs_running;
   end;
end;
procedure GameOpenMenu;
begin
   if(MainMenu)then exit;

   MainMenu   :=true;
   menu_update:=true;
   menu_ItemSelected:=0;
   if(net_status=ns_none)and(g_Status<=LastPlayer)then
     if(MainMenu)
     then g_Status:=LocalPlayer
     else g_Status:=gs_running;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   UI
//

function ui_ControlTabType:TTabControlContent;
begin
   ui_ControlTabType:=tcc_none;
   if(rpls_pstate>=rpls_read)
   then ui_ControlTabType:=tcc_replay
   else
     if((g_players[LocalPlayer].observer)or(Game_IsEnded))and(g_type<>gt_campaing)
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
        if(tu^.uid^._ucl>g_units[ui_UnitSelectedNU].uid^._ucl)
        then
        else exit;
      ui_UnitSelectedNU:=u;
   end;
end;

function ui_UnitNeedDrawRange(pu:PTUnit):boolean;
begin
   with pu^  do
    with uid^ do
     ui_UnitNeedDrawRange:=(_attack>0)
                         or(_isbuilder and not ukfly)
                         or(_ability=uab_UACScan)
                         or(_ability=uab_HellVision);
end;


function ui_fog_CheckXY(x,y:integer):boolean;
var cx,cy:integer;
begin
   x+=ui_cam_fx;
   y+=ui_cam_fy;
   cx:=x div fog_cw;
   cy:=y div fog_cw;
   ui_fog_CheckXY:=false;
   if(0<=cx)and(cx<=fog_vfwm)
  and(0<=cy)and(cy<=fog_vfhm)then ui_fog_CheckXY:=(ui_fog_pgrid[cx,cy]>0);
end;

function RectInCam(x,y,hw,hh,s:integer):boolean;
begin
   RectInCam:=((ui_cam_x-hw          )<x)and(x<(ui_cam_x+ui_cam_w+hw))
           and((ui_cam_y-hh-max2i(0,s))<y)and(y<(ui_cam_y+ui_cam_h+hh));
end;
function PointInCam(x,y:integer):boolean;
begin
   PointInCam:=(ui_cam_x<x)and(x<(ui_cam_x+ui_cam_w))
            and(ui_cam_y<y)and(y<(ui_cam_y+ui_cam_h));
end;

function CheckUnitUIVision(tu:PTUnit):boolean;
begin
   CheckUnitUIVision:=true;

   if(not ui_fog)then exit;

   if(UIPlayer=0)then
     if(rpls_pstate>=rpls_read)or(g_players[LocalPlayer].observer)or(Game_IsEnded)then exit;

   if(tu<>nil)then
     if(tu^.player^.team=g_players[UIPlayer].team)then exit;

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
          if(rpls_pstate=rpls_read)or(g_players[LocalPlayer].observer)or(Game_IsEnded)then
          begin
             CheckUnitUIVisionScreen:=true;
             exit;
          end;

        CheckUnitUIVisionScreen:=(TeamVision[g_players[UIPlayer].team]>0)or(not ui_fog);
     end;
end;

function MapPointInScreenP(x,y:integer;CheckSquare:boolean):boolean;
begin
   MapPointInScreenP:=false;
   x-=ui_cam_x;
   y-=ui_cam_y;
   if(-fog_cw<x)and(x<(ui_cam_w+fog_cw))and
     (-fog_cw<y)and(y<(ui_cam_h+fog_cw))then
   begin
      if(not ui_fog)
      then MapPointInScreenP:=true
      else MapPointInScreenP:=ui_fog_CheckXY(x,y);
      if(CheckSquare)and(not MapPointInScreenP)then
      begin
         x+=ui_cam_x;
         y+=ui_cam_y;
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

procedure ui_Camera_Bounds;
begin
   ui_cam_x  :=mm3i(0,ui_cam_x,map_Size-ui_cam_w);
   ui_cam_y  :=mm3i(0,ui_cam_y,map_Size-ui_cam_h);
   ui_cam_cx := ui_cam_x+ui_cam_hw;
   ui_cam_cy := ui_cam_y+ui_cam_hh;
   ui_cam_fx :=(ui_cam_x mod fog_cw);
   ui_cam_fy :=(ui_cam_y mod fog_cw);

   ui_cam_mmx:=round(ui_cam_x*map_mmcx);
   ui_cam_mmy:=round(ui_cam_y*map_mmcx);
   ui_fog_sx :=ui_cam_x div fog_cw;
   ui_fog_sy :=ui_cam_y div fog_cw;
   ui_fog_ex :=ui_fog_sx+ui_fog_vfw;
   ui_fog_ey :=ui_fog_sy+ui_fog_vfh;
end;

procedure ui_Camera_MoveToPoint(mx,my:integer);
begin
   ui_cam_x:=mx-(ui_cam_w shr 1);
   ui_cam_y:=my-(ui_cam_h shr 1);
   ui_Camera_Bounds;
end;

procedure ui_Camera_MoveToGroup(ugroupN:byte);
begin
   if(ugroupN>MaxUnitGroups)then exit;
   if(ui_groups_n[ugroupN]>0)then
     ui_Camera_MoveToPoint(ui_groups_x[ugroupN] , ui_groups_y[ugroupN])
end;

procedure ui_Camera_ToLastEvent;
var log_pi:cardinal;
begin
   with g_players[UIPlayer] do
   begin
      log_pi:=log_i;
      while true do
      begin
         with log_l[log_pi] do
          if(xi>0)or(yi>0)then
          begin
             ui_Camera_MoveToPoint(xi,yi);
             break;
          end;
         if(log_pi>0)
         then log_pi-=1
         else log_pi:=MaxPlayerLog;
         if(log_pi=log_i)then exit;
      end;
   end;
end;

function _Si2Hi(sh:shortint;mh:integer;s:single):integer;
begin
   case sh of
127     : _Si2Hi:=mh;
1..126  : _Si2Hi:=mm3i(1,trunc(sh*s),mh-1);
0       : _Si2Hi:=0;
-125..-1: _Si2Hi:=mm3i(dead_hits+1,sh*_d2shi,-1);
-126    : _Si2Hi:=fdead_hits;
-127    : _Si2Hi:=dead_hits;
-128    : _Si2Hi:=ndead_hits;
   end;
end;



function ParseLogMessage(ptlog:PTLogMes;mcolor:pcardinal):shortstring;
begin
   ParseLogMessage:='';
   mcolor^:=c_white;
   with ptlog^ do
    case mtype of
0..LastPlayer        : if(length(str)>0)then
                       begin
                          //mtype = sender
                          mcolor^:=PlayerGetColor(mtype);
                          ParseLogMessage:=g_players[mtype].name+': '+str;
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
                          lmt_argt_unit: with g_uids [argx] do ParseLogMessage+=' ('+un_txt_name+')';
                          lmt_argt_upgr: with g_upids[argx] do ParseLogMessage+=' ('+_up_name   +')';
                          {lmt_argt_abil: case argx of
                                         254 : ParseLogMessage+=' ('+str_sability+')';
                                         255 : ParseLogMessage+=' ('+str_spability+')';
                                         else  ParseLogMessage+=' ('+str_ability_name[argx]+')';
                                         end;  }
                            end;
                       end;
lmt_player_chat,
lmt_game_message,
lmt_player_surrender,
lmt_player_leave     : ParseLogMessage:=str;//if(argx<=LastPlayer)then ParseLogMessage:=g_players[argx].name+str_gmsg_PlayerLeft;
lmt_game_end         : if(argx<=LastPlayer)then
                        if(argx=g_players[UIPlayer].team)
                        then ParseLogMessage:=str_gstat_Win
                        else ParseLogMessage:=str_gstat_Lose;
lmt_player_defeated  : if(argx<=LastPlayer)then ParseLogMessage:=g_players[argx].name+str_gmsg_PlayerDefeat;
lmt_upgrade_complete : begin
                       with g_upids[argx] do ParseLogMessage:=str_upgrade_complete+' ('+_up_name+')';
                       mcolor^:=c_yellow;
                       end;
lmt_unit_ready       : begin
                       with g_uids[argx] do
                        case argt of
                         lmt_argt_unit : if(_ukbuilding)
                                         then ParseLogMessage:=str_building_complete+' ('+un_txt_name+')'
                                         else ParseLogMessage:=str_unit_complete    +' ('+un_txt_name+')';
                        end;
                       mcolor^:=c_green;
                       end;
lmt_unit_advanced    : begin
                       with g_uids[argx] do ParseLogMessage:=str_unit_advanced+' ('+un_txt_name+')';
                       mcolor^:=c_aqua;
                       end;
lmt_allies_attacked  : begin
                       with g_uids[argx] do
                        ParseLogMessage:=str_allies_attacked+' ('+un_txt_name+')';
                       mcolor^:=c_orange;
                       end;
lmt_unit_attacked    : begin
                       with g_uids[argx] do
                        if(_ukbuilding)
                        then ParseLogMessage:=str_base_attacked+' ('+un_txt_name+')'
                        else ParseLogMessage:=str_unit_attacked+' ('+un_txt_name+')';
                       mcolor^:=c_red;
                       end;
lmt_cpoint_captured  : begin
                       ParseLogMessage:=str_cpoint_captured;
                       mcolor^:=c_dred;
                       end;
lmt_cpoint_lost      : begin
                       ParseLogMessage:=str_cpoint_lost;
                       mcolor^:=c_dred;
                       end;
lmt_koth_control     : begin
                       ParseLogMessage:=b2s(argx)+str_koth_control;
                       mcolor^:=c_dred;
                       end;
lmt_ngen_exh         : begin
                       ParseLogMessage:=str_ngen_exh;
                       mcolor^:=c_dyellow;
                       end;
lmt_ngen_captured    : begin
                       ParseLogMessage:=str_ngen_captured;
                       mcolor^:=c_dyellow;
                       end;
lmt_ngen_lost        : begin
                       ParseLogMessage:=str_ngen_lost;
                       mcolor^:=c_dyellow;
                       end;
lmt_ability_cantland : begin
                       ParseLogMessage:=str_cant_land;
                        {if(argx>0)then
                          case argt of
                        lmt_argt_abil: case argx of
                                       //254 : ParseLogMessage+=' ('+str_sability+')';
                                       //255 : ParseLogMessage+=' ('+str_spability+')';
                                       else  ParseLogMessage+=' ('+str_ability_name[argx]+')';
                                       end;
                          end;}
                       end;
lmt_ability_reload   : begin
                       ParseLogMessage:=str_ability_reloading;
                       { if(argx>0)then
                          case argt of
                        lmt_argt_abil: case argx of
                                       //254 : ParseLogMessage+=' ('+str_sability+')';
                                      // 255 : ParseLogMessage+=' ('+str_spability+')';
                                       else  ParseLogMessage+=' ('+str_ability_name[argx]+')';
                                       end;
                          end; }
                       end;
//lmt_ability_needS    : ParseLogMessage:=str_use_sability;
//lmt_ability_needSP   : ParseLogMessage:=str_use_spability;
lmt_invalid_tar      : ParseLogMessage:=str_invalid_target;
lmt_cant_order       : begin
                       ParseLogMessage:=str_cant_execute;
                       if(argx>0)then
                         case argt of
                       lmt_argt_unit: with g_uids [argx] do ParseLogMessage+=' ('+un_txt_name+')';
                       lmt_argt_upgr: with g_upids[argx] do ParseLogMessage+=' ('+_up_name   +')';
                       {lmt_argt_abil: case argx of
                                      //254 : ParseLogMessage+=' ('+str_sability+')';
                                      //255 : ParseLogMessage+=' ('+str_spability+')';
                                      else  ParseLogMessage+=' ('+str_ability_name[argx]+')';
                                      end; }
                         end;
                       end;
lmt_MaximumReached   : ParseLogMessage:=str_MaximumReached;
lmt_NeedMoreProd     : ParseLogMessage:=str_NeedMoreProd;
lmt_already_adv      : ParseLogMessage:=str_cant_advanced;
lmt_production_busy  : ParseLogMessage:=str_production_busy;
lmt_unit_needbuilder : ParseLogMessage:=str_need_more_builders;
lmt_unit_limit       : ParseLogMessage:=str_maxlimit_reached;
lmt_map_mark         : begin
                       mcolor^:=c_gray;
                       if(argx<=LastPlayer)then
                         with g_players[argx] do ParseLogMessage:=name+str_mapMark;
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
   with g_players[playern] do
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

function FileReadBaseGameInfo(var f:file;strInfoVar:pshortstring):boolean;
type
TShortPlayerInfo = record
   mrace,
   team,
   state:byte;
   name :shortstring;
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
   strInfoVar^:=str_map+tc_nl3;

   vbyte1:=255;
   BlockRead(f,vbyte1,sizeof(map_scenario  ));
   if not(vbyte1 in allmapscenarios        )then exit
                                            else strInfoVar^+=' '+str_map_Scenario  +': '+str_map_ScenarioL  [vbyte1]+tc_default+tc_nl3;
   vbyte1:=255;
   BlockRead(f,vbyte1,sizeof(map_generators));
   if(vbyte1>map_MaxGenerators                 )then exit
                                            else strInfoVar^+=' '+str_map_Generators+': '+str_map_GeneratorsL[vbyte1]+tc_nl3;
   vcard:=0;
   BlockRead(f,vcard ,sizeof(map_seed      ));   strInfoVar^+=' '+str_map_Seed      +': '+c2s(vcard)+tc_nl3;

   vint:=-1;
   BlockRead(f,vint  ,sizeof(map_Size      ));
   if(vint<map_MinSize)or(map_MaxSize<vint )then exit
                                            else strInfoVar^+=' '+str_map_Size      +': '+i2s(vint )+tc_nl3;
   vbyte1:=255;
   BlockRead(f,vbyte1,sizeof(map_Obstacles ));
   if(vbyte1>map_MaxObstacles              )then exit
                                            else strInfoVar^+=' '+str_map_Obstacles +': '+strMX(vbyte1)+tc_nl3;

   vbyte1:=255;
   BlockRead(f,vbyte1,sizeof(map_Symmetry  ));   strInfoVar^+=' '+str_map_Symmetry  +': '+b2cc[vbyte1>0]+tc_nl3;

   vint:=-1;
   BlockRead(f,vint  ,sizeof(theme_i       ));
   if(vint>=theme_n                        )then exit
                                            else strInfoVar^+=' '+theme_name[vint]+tc_default+tc_nl3;

   lplayer:=255;
   BlockRead(f,lplayer,sizeof(LocalPlayer  ));

   strInfoVar^+=tc_nl3;

   vcard:=0;
   BlockRead(f,vcard  ,sizeof(g_tick       ));   strInfoVar^+=str_time+str_GTick2Time(vcard)+tc_nl3;

   strInfoVar^+=tc_nl3+str_Players+tc_nl3;
   for p:=1 to LastPlayer do
     with playerInfo do
     begin
        BlockRead(f,state,sizeof(state));
        BlockRead(f,name ,sizeof(name ));
        BlockRead(f,mrace,sizeof(mrace));
        BlockRead(f,team ,sizeof(team ));

        if(p=lplayer)
        then strInfoVar^+=' '+chr(p)+'>'+tc_default
        else strInfoVar^+=' '+chr(p)+'#'+tc_default;

        if(state>PS_None)then
          if(team=0)
          then strInfoVar^+=str_observer[1]   +','+t2c(team)+','
          else strInfoVar^+=str_race[mrace][2]+','+t2c(team)+',';
        strInfoVar^+=name+tc_nl3
     end;

   FileReadBaseGameInfo:=true;
end;

{$ELSE}

function PlayerAllOut:boolean;
var i,c,r:byte;
begin
   c:=0;
   r:=0;
   for i:=1 to MaxPlayers do
    with g_players[i] do
     if (state=PS_human) then
     begin
        c+=1;
        if(ttl=ClientTTL)then r+=1;
     end;
   PlayerAllOut:=(r=c)and(c>0);
end;

{$ENDIF}



