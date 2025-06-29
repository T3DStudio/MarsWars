
////////////////////////////////////////////////////////////////////////////////
//
//   FORWARD Declarations
//

procedure unit_damage (pu:PTUnit;damage,pain_f:integer;pl:byte;IgnoreArmor:boolean);  forward;
procedure unit_Bonuses(pu:PTUnit);forward;
function unit_canMove       (pu:PTUnit):boolean; forward;
function unit_canAttack     (pu:PTUnit;check_buffs:boolean):boolean; forward;
function unit_TransportCheck(pTransport,pTarget:PTUnit):boolean;     forward;

procedure aiu_InitVars   (pu:PTUnit);forward;
procedure aiu_CollectData(pu,tu:PTUnit;ud:integer;tu_transport:PTUnit;AttackableTarget:boolean);forward;
procedure ai_InitVars       (pu:PTUnit);forward;
procedure ai_SetCurrentAlarm(tu:PTUnit;x,y,ud:integer;zone:word);forward;
procedure ai_CollectData    (pu,tu:PTUnit;ud:integer;tu_transport:PTUnit;AttackableTarget:boolean);forward;
procedure ai_scout_pick     (pu:PTUnit);forward;
function ai_HighPriorityTarget(player:PTPlayer;tu:PTUnit):boolean;forward;
function map_IsObstacleZone(zone:word    ):boolean;forward;
function map_CellGetZone   (cx,cy:integer):word;   forward;
function map_MapGetZone    (mx,my:integer):word;   forward;
function map_InGridRange   (a:integer    ):boolean;forward;

function point_dist_rint(dx0,dy0,dx1,dy1:integer):integer;  forward;

procedure pushOut_GridUAction(apx,apy:pinteger;r:integer;azone:word);forward;

procedure PlayerSlotValidate; forward;

{$IFDEF _FULLGAME}
function menu_Escape(exitMenu:boolean):boolean; forward;
function ui_AddMarker(ax,ay:integer;av:byte;new:boolean):boolean;forward;
function sm_uid2MWTexture(_uid:byte;dir:integer;level:byte):PTMWTexture;forward;
function LogMes2UIAlarm:boolean; forward;
procedure SoundLogUIPlayer(playern:byte);  forward;
procedure replay_SavePlayPosition;forward;
function replay_GetProgress:single;forward;
procedure draw_LoadingScreen(CaptionString:shortstring;color:TMWColor); forward;
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
//   FRAMERATE
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
   if(sys_uncappedFPS)and(not menu_state)
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

// byte to char
function t2c(l:byte):char;begin if(l=0)then t2c:='-' else t2c:=b2s(l)[1]; end;

function txt_ValidateStr(BaseStr:shortstring;MaxSize:byte;Chars:PTSoc):shortstring;
var i:byte;
begin
   txt_ValidateStr:='';
   if(length(BaseStr)>0)then
     for i:=1 to length(BaseStr) do
     begin
        if(BaseStr[i] in Chars^)then txt_ValidateStr+=BaseStr[i];
        if(length(txt_ValidateStr)>=MaxSize)then break;
     end;
end;

function str_NowDateTime(noMS:boolean=false):shortstring;
var YY,MM,DD,H,M,S,MS:word;
begin
   DeCodeDate(Date,YY,MM,DD);
   DeCodeTime(Time,H,M,S,MS);
   if(noMS)
   then str_NowDateTime:=w2s(YY)+'_'+w2s(MM)+'_'+w2s(DD)+' '+w2s(H)+'-'+w2s(M)+'-'+w2s(S)
   else str_NowDateTime:=w2s(YY)+'_'+w2s(MM)+'_'+w2s(DD)+' '+w2s(H)+'-'+w2s(M)+'-'+w2s(S)+'-'+w2s(MS);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   BASIC MATH
//

function max2i(x1,x2   :integer):integer;begin if(x1>x2)then max2i:=x1 else max2i:=x2;end;
function max3i(x1,x2,x3:integer):integer;begin max3i:=max2i(max2i(x1,x2),x3);end;
function min2i(x1,x2   :integer):integer;begin if(x1<x2)then min2i:=x1 else min2i:=x2;end;
function min3i(x1,x2,x3:integer):integer;begin min3i:=min2i(min2i(x1,x2),x3);end;

function mm3i(minx,x,maxx:integer):integer;begin mm3i:=min2i(maxx,max2i(x,minx)); end;

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

procedure PlayersValidateName;
var p:byte;
begin
   for p:=0 to LastPlayer do
     with g_players[p] do name:=txt_ValidateStr(name,PlayerNameLen,@k_pname);
end;

procedure PlayerSetAllowedUnits(playern:byte;UIDSet:TSob;max:integer;Clear:boolean);
var i:byte;
begin
   with g_players[playern] do
   begin
      if(Clear)then FillChar(a_units,SizeOf(a_units),0);
      if(UIDSet<>[])then
       for i:=0 to 255 do
        if(i in UIDSet)then
         with g_uids[i] do a_units[i]:=max;
   end;
end;
procedure PlayerSetAllowedUpgrades(playern:byte;UPIDSet:TSob;lvl:integer;Clear:boolean);
var i:byte;
begin
   with g_players[playern] do
   begin
      if(Clear)then FillChar(a_upgrs,SizeOf(a_upgrs),0);
      if(UPIDSet<>[])then
       for i:=0 to 255 do
        if(i in UPIDSet)then
         with g_upids[i] do a_upgrs[i]:=min2i(_up_max,lvl);
   end;
end;
procedure PlayerSetCurrentUpgrades(playern:byte;UPIDSet:TSob;lvl:integer;Clear,NoCheckMaxLevel:boolean);
var i:byte;
begin
   with g_players[playern] do
   begin
      if(Clear)then FillChar(upgr,SizeOf(upgr),0);
      if(UPIDSet<>[])then
       for i:=0 to 255 do
        if(i in UPIDSet)then
         with g_upids[i] do
          if(NoCheckMaxLevel)
          then upgr[i]:=min2i(_up_max,lvl)
          else upgr[i]:=min3i(a_upgrs[i],_up_max,lvl);
   end;
end;

function PlayersGetReadyStatus:boolean;
var p,c,r:byte;
begin
   c:=0;
   r:=0;
   for p:=0 to LastPlayer do
    with g_players[p] do
     if(player_type=pt_human)then
     begin
        c+=1;
        if(isready)
        or(p=PlayerClient)
        or(p=PlayerLobby )then r+=1;
     end;
   PlayersGetReadyStatus:=(r=c)and(c>0);
end;

function PlayerSlotGetTeam(playeri,SuggestedTeam:byte):byte;
begin
   PlayerSlotGetTeam:=0;
   if(playeri<=LastPlayer)and(map_MaxTeams>0)then
     with g_players[playeri] do
     begin
        if(map_Scenario in ms_ScenariosFixedTeams)then
        begin
           PlayerSlotGetTeam:=playeri div (map_MaxPlayers div map_MaxTeams);
        end
        else
          if(SuggestedTeam>=map_MaxTeams)
          then PlayerSlotGetTeam:=playeri
          else PlayerSlotGetTeam:=SuggestedTeam;
     end;

       {{if(map_preset_cur>0)then
         with map_preset_l[map_preset_cur] do
           PlayerSlotGetTeam:=mapp_player_team[playeri]
       else}
         case mapScenario of
ms_4x4     : case playeri of
             0..3: PlayerSlotGetTeam:=0;
             4..7: PlayerSlotGetTeam:=1;
             end;
ms_2x2x2x2 : case playeri of
             0,1 : PlayerSlotGetTeam:=0;
             2,3 : PlayerSlotGetTeam:=1;
             4,5 : PlayerSlotGetTeam:=2;
             6,7 : PlayerSlotGetTeam:=3;
             end;
ms_assault : case playeri of
             0,1,
             2,3,
             4,5 : PlayerSlotGetTeam:=0;
             6,7 : PlayerSlotGetTeam:=1;
             end;
         else
             if(SuggestedTeam>LastPlayer)then SuggestedTeam:=team;
             PlayerSlotGetTeam:=SuggestedTeam;
         end;   }
end;

procedure UpdatePlayersStatusVars;    // ????????????????????????
var p:byte;
begin
   g_player_astatus:=0;
   g_player_rstatus:=0;
   g_cl_units      :=0;
   for p:=0 to LastPlayer do
    with g_players[p] do
    begin
       if(player_type>pt_none)then
       begin
          SetBBit(@g_player_rstatus,p,isrevealed);
          if(army>0)then
          begin
             SetBBit(@g_player_astatus,p,true);
             g_cl_units+=MaxPlayerUnits;
          end;
       end;
    end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   PLAYER LOG
//

function PlayerGetAlliesByte(playern:byte;AddSelf:boolean):byte;
var i:byte;
begin
   PlayerGetAlliesByte:=0;
   for i:=0 to LastPlayer do
    with g_players[i] do
     if(player_type>pt_none)and(team=g_players[playern].team)then
     begin
        if(not AddSelf)and(i=playern)then continue;
        SetBBit(@PlayerGetAlliesByte,i,true);
     end;
end;

function PlayerSetProdError(playern,utp,uid:byte;cndt:cardinal;pu:PTUnit):boolean;
begin
   PlayerSetProdError:=false;
   if(playern<=LastPlayer)then
    with g_players[playern] do
     if(cndt>0)then
     begin
        prod_error_cndt:=cndt;
        prod_error_utp :=utp;
        prod_error_uid :=uid;
        if(pu<>nil)then
        begin
           prod_error_x:=mm3i(1,pu^.x,map_psize);
           prod_error_y:=mm3i(1,pu^.y,map_psize);
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
                   if(point_dist_rint(xi,yi,x,y)<base_1rh)then exit;
      end;
   end;
   PlayerLogCheckNearEvent:=false;
end;

procedure PlayerLogAdd(PlayerTarget,amtype,aargt,aargx:byte;astr:shortstring;ax,ay:integer;local:boolean);
{$IFDEF _FULLGAME}
var PlayerReciever:byte;
{$ENDIF}
begin
   if(PlayerTarget>LastPlayer)then exit;

   with g_players[PlayerTarget] do
   if(player_type>pt_none)then
   begin
      case amtype of
0..LastPlayer,
lmt_player_chat,
lmt_player_defeated,
lmt_player_surrender,
lmt_player_leave,
lmt_game_end,
lmt_game_message     :; // типы сообщений, который добавляются всегда

lmt_unit_attacked,      // сообщения атаки - не повторять чаще чем раз в 5 секунд
lmt_allies_attacked  : if(PlayerLogCheckNearEvent(PlayerTarget,[lmt_unit_attacked,lmt_allies_attacked],fr_fps5,ax,ay))then exit;
      else
         // если такоеже сообщение, в том же месте и с тем же типом уже было - не добавлять
         with log_l[log_i] do
           if(tick<=G_Step)then
             if (mtype=amtype)
             and(argt =aargt)
             and(argx =aargx)then
               if((G_Step-tick)<fr_fps3)then exit;
      end;

      if(not local)then log_n+=1;

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
      then PlayerReciever:=PlayerClient
      else PlayerReciever:=ui_player;
      if(PlayerTarget=PlayerReciever)then
      begin
         ui_LogLastMesTimer:=min2i(ui_LogLastMesTimer+log_LastMesTime,log_LastMesMaxN);
         menu_redraw:=true;

         if(LogMes2UIAlarm)then SoundLogUIPlayer(ui_player);

         if(amtype=lmt_player_defeated )
         or(amtype=lmt_player_surrender)then
           if(g_deadobservers)and(aargx=ui_player)then ui_tab:=tt_controls;
      end;
      {$ENDIF}
   end;
end;

procedure PlayersAddToLog(PlayerSender,to_players,amtype,auidt,auid:byte;astr:shortstring;ax,ay:integer;local:boolean);
var i:byte;
begin
   for i:=0 to LastPlayer do
     if(GetBBit(@to_players,i))
     or(i=PlayerSender)
     or(PlayerSender>LastPlayer)then PlayerLogAdd(i,amtype,auidt,auid,astr,ax,ay,local);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   LOG COMMON
//

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
   if(not g_ServerSide)then exit;
   PlayersAddToLog(0,log_to_all,lmt_game_end,0,wteam,'',0,0,false);
end;
procedure GameLogPlayerDefeated(player:byte);
begin
   if(player>LastPlayer)or(not g_ServerSide)then exit;
   PlayersAddToLog(player,log_to_all,lmt_player_defeated,0,player,'',0,0,false);
end;
procedure GameLogPlayerLeave(player:byte);
begin
   if(player>LastPlayer)or(not g_ServerSide)then exit;
   PlayersAddToLog(player,log_to_all,lmt_player_leave,0,0,g_players[player].name+str_msg_PlayerLeave,0,0,false);
end;
procedure GameLogPlayerSurrender(player:byte);
begin
   if(player>LastPlayer)or(not g_ServerSide)then exit;
   PlayersAddToLog(player,log_to_all,lmt_player_surrender,0,player,'',0,0,false);
end;
procedure GameLogUnitReady(pu:PTunit);
begin
   if(pu=nil)or(not g_ServerSide)then exit;

   with pu^ do PlayersAddToLog(playeri,0,lmt_unit_ready,lmt_argt_unit ,uidi,'',x,y,false);
end;
procedure GameLogUnitPromoted(pu:PTunit);
begin
   if(pu=nil)or(not g_ServerSide)then exit;

   with pu^ do PlayersAddToLog(playeri,0,lmt_unit_promoted,0,uidi,'',x,y,false);
end;
procedure GameLogUpgradeComplete(player,upid:byte;x,y:integer);
begin
   if(player>LastPlayer)or(not g_ServerSide)then exit;

   PlayersAddToLog(player,0,lmt_upgrade_complete,0,upid,'',x,y,false);
end;
procedure GameLogCantProduction(playeri,uid,utp:byte;condt:cardinal;x,y:integer;local:boolean);
var bt:byte;
begin
   if(playeri>LastPlayer)or(condt=0)then exit;

   with g_players[playeri] do
   begin
      if(player_type=pt_ai)then exit;

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
           if((condt and ureq_smiths  )>0)
           or((condt and ureq_barracks)>0)
           then bt:=lmt_NeedMoreProd
           else
             if((condt and ureq_busy)>0)
             then bt:=lmt_production_busy
             else
               if((condt and ureq_needbuilders)>0)
               or((condt and ureq_builders    )>0)
               then bt:=lmt_unit_needbuilder
               else
                 if((condt and ureq_energy)>0)
                 then bt:=lmt_req_energy
                 else
                   if((condt and ureq_alreadyAdv)>0)
                   then bt:=lmt_already_adv
                   else
                     if((condt and ureq_unknown)>0)
                     then bt:=lmt_cant_order
                     else bt:=lmt_req_common;

   PlayersAddToLog(playeri,0,bt,utp,uid,'',x,y,local);
end;
procedure GameLogMapMark(playeri:byte;x,y:integer);
begin
   if(playeri>LastPlayer)or(not g_ServerSide)then exit;

   PlayersAddToLog(playeri,PlayerGetAlliesByte(playeri,true),lmt_map_mark,0,playeri,'',x,y,false);
end;
procedure GameLogUnitAttacked(pu:PTunit);
begin
   if(pu=nil)or(not g_ServerSide)then exit;

   with pu^ do
   begin
      PlayersAddToLog(playeri,0                                 ,lmt_unit_attacked  ,0,uidi,'',x,y,false);
      PlayersAddToLog(playeri,PlayerGetAlliesByte(playeri,false),lmt_allies_attacked,0,uidi,'',x,y,false);
   end;
end;

procedure PlayerClearLog(playeri:byte);
var i:cardinal;
begin
   if(playeri>LastPlayer)then exit;

   with g_players[playeri] do
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

{procedure PlayersClearLog;
var i:byte;
begin
   for i:=0 to LastPlayer do PlayerClearLog(i);
end;}

////////////////////////////////////////////////////////////////////////////////
//
//   OTHER
//

procedure WriteSDLError(comment:shortstring);
var  f:Text;
tmpStr:shortstring;
begin
   Assign(f,str_outLogFName);
   if FileExists(str_outLogFName)
   then Append (f)
   else Rewrite(f);
   tmpStr:=str_NowDateTime(true);
   if(str_outLogLastDate<>tmpStr)then
   begin
      str_outLogLastDate:=tmpStr;
      writeln(str_outLogLastDate);
   end;
   writeln(f,comment,' ',sdl_GetError);
   SDL_ClearError;
   Close(f);
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

function point_dist_int(dx0,dy0,dx1,dy1:integer):integer;
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

function dir360(d:integer):integer;
begin
   dir360:=d mod 360;
   if(dir360<0)then dir360+=360;
end;

function dir_turn(d1,d2,spd:integer):integer;
var d:integer;
begin
   d:=dir_diff(d2,d1);

   if abs(d)<=spd
   then dir_turn:=d2
   else dir_turn:=d1+(spd*sign(d));
   dir_turn:=dir360(dir_turn);
end;

procedure pushIn_1r(tx,ty:pinteger;x0,y0,r0:integer);
var
vx,vy:integer;
a    :single;
begin
   vx :=x0-tx^;
   vy :=y0-ty^;
   a  :=sqrt(sqr(vx)+sqr(vy));
   if(a<=0)then exit;
   tx^:=x0-trunc(r0*vx/a);
   ty^:=y0-trunc(r0*vy/a);
end;

function pushOut_1r(tx,ty:pinteger;x0,y0,r0:integer):boolean;
var
vx,vy:integer;
a    :single;
begin
   pushOut_1r:=false;
   vx :=x0-tx^;
   vy :=y0-ty^;
   if (abs(vx)>r0)
   and(abs(vy)>r0)then exit;
   a  :=sqrt(sqr(vx)+sqr(vy));
   if(a<=0)or(a>r0)then exit;
   tx^:=x0-trunc(r0*vx/a);
   ty^:=y0-trunc(r0*vy/a);
   pushOut_1r:=true;
end;

procedure pushOut_2r(tx,ty:pinteger;x0,y0,r0,x1,y1,r1:integer);
var d:integer;
vx,vy,
  a,h:single;
begin
   if (r0<>NOTSET)
   and(r1<>NOTSET)then
   begin
      d:=point_dist_int(x0,y0,x1,y1);
      if(abs(r0-r1)<=d)and(d<=(r0+r1))and(d>0)then
      begin
         a:=(sqr(r0)-sqr(r1)+sqr(d))/(2*d);
         h:=sqrt(sqr(r0)-sqr(a));

         vx:=(x1-x0)/d;
         vy:=(y1-y0)/d;

         if( trunc(-vy*(x0-tx^)+vx*(y0-ty^)) <= 0 )then
         begin
            tx^:=trunc( x0+a*vx-(h*vy) );
            ty^:=trunc( y0+a*vy+(h*vx) );
         end
         else
         begin
            tx^:=trunc( x0+a*vx+(h*vy) );
            ty^:=trunc( y0+a*vy-(h*vx) );
         end;
         exit;
      end;
   end;
   if(r0<>NOTSET)then begin pushOut_1r(tx,ty,x0,y0,r0);exit;end;
   if(r1<>NOTSET)then begin pushOut_1r(tx,ty,x1,y1,r1);exit;end;
end;

procedure mgcell2NearestXY(px,py,gmx0,gmy0,gmx1,gmy1:integer;pushOutR:integer;rx,ry,rd:pinteger);
var td,
    tx,
    ty:integer;
procedure SetpushOutXY(ad,ax,ay:integer);
begin
   if(ad<td)then
   begin
      td:=ad;
      tx:=ax;
      ty:=ay;
   end;
end;
begin
   tx:=px;
   ty:=py;
   td:=NOTSET;

   if (gmx0<=px)and(px<=gmx1)
   and(gmy0<=py)and(py<=gmy1)then
   begin
      if(pushOutR>0)then
      begin
         SetpushOutXY(abs(gmx0-px),gmx0-pushOutR,py);
         SetpushOutXY(abs(gmx1-px),gmx1+pushOutR,py);
         SetpushOutXY(abs(gmy0-py),px,gmy0-pushOutR);
         SetpushOutXY(abs(gmy1-py),px,gmy1+pushOutR);
         td:=-td;
      end
      else td:=0;
   end
   else
       if(px<gmx0)and(py<gmy0)then begin
                                      if(pushOutR>0)
                                      then pushOut_1r(@tx,@ty,gmx0,    gmy0,pushOutR+1)
                                      else begin          tx:=gmx0;ty:=gmy0;end;
                                      if(rd<>nil)then td:=point_dist_int(px,py,gmx0,gmy0);
                                   end
  else if(gmx1<px)and(py<gmy0)then begin
                                      if(pushOutR>0)
                                      then pushOut_1r(@tx,@ty,gmx1,    gmy0,pushOutR+1)
                                      else begin          tx:=gmx1;ty:=gmy0;end;
                                      if(rd<>nil)then td:=point_dist_int(px,py,gmx1,gmy0);
                                   end
  else if(gmx1<px)and(gmy1<py)then begin
                                      if(pushOutR>0)
                                      then pushOut_1r(@tx,@ty,gmx1,    gmy1,pushOutR+1)
                                      else begin          tx:=gmx1;ty:=gmy1;end;
                                      if(rd<>nil)then td:=point_dist_int(px,py,gmx1,gmy1);
                                   end
  else if(px<gmx0)and(gmy1<py)then begin
                                      if(pushOutR>0)
                                      then pushOut_1r(@tx,@ty,gmx0,    gmy1,pushOutR+1)
                                      else begin          tx:=gmx0;ty:=gmy1;end;
                                      if(rd<>nil)then td:=point_dist_int(px,py,gmx0,gmy1);
                                   end
  else if(px<gmx0)then             begin
                                      td:=abs(gmx0-px);
                                      if(pushOutR<=0)
                                      then tx:=gmx0
                                      else if(td<pushOutR)then tx:=gmx0-pushOutR;
                                   end
  else if(gmx1<px)then             begin
                                      td:=abs(px-gmx1);
                                      if(pushOutR<=0)
                                      then tx:=gmx1
                                      else if(td<pushOutR)then tx:=gmx1+pushOutR;
                                   end
  else if(py<gmy0)then             begin
                                      td:=abs(gmy0-py);
                                      if(pushOutR<=0)
                                      then ty:=gmy0
                                      else if(td<pushOutR)then ty:=gmy0-pushOutR;
                                   end
  else if(gmy1<py)then             begin
                                      td:=abs(py-gmy1);
                                      if(pushOutR<=0)
                                      then ty:=gmy1
                                      else if(td<pushOutR)then ty:=gmy1+pushOutR;
                                   end;
   if(rx<>nil)then rx^:=tx;
   if(ry<>nil)then ry^:=ty;
   if(rd<>nil)then rd^:=td;
end;

function dist2mgcellC(mx,my,gx,gy:integer):integer;
var gmx,gmy:integer;
begin
   gmx:=gx*MapCellW;
   gmy:=gy*MapCellW;
   mgcell2NearestXY(mx,my,gmx,gmy,gmx+MapCellW,gmy+MapCellW,0,nil,nil,@dist2mgcellC);
end;

{function dist2mgcellM(tx,ty,gmx,gmy:integer):integer;
var mx ,my :integer;
begin
   mgcell2NearestXY(tx,ty,gmx,gmy,gmx+MapCellW,gmy+MapCellW,0,@mx,@my,@dist2mgcellM);
end;}

function IsIntUnitRange(u:integer;ppu:PPTUnit):boolean;
begin
   IsIntUnitRange:=false;
   if(0<u)and(u<=MaxUnits)then
   begin
      IsIntUnitRange:=true;
      if(ppu<>nil)then ppu^:=g_punits[u];
   end;
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

function CheckRoyalBattleRadiusPoint(x,y,d:integer):boolean;
begin
   if(map_scenario=ms_royale)
   then CheckRoyalBattleRadiusPoint:=(point_dist_int(x,y,map_phsize,map_phsize)+d)>=g_RoyalBattle_r
   else CheckRoyalBattleRadiusPoint:=false;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   RANDOM

function g_random(m:integer):integer;
const a = 4;
begin
   g_random_p+=1;
   g_random_i:=g_random_i*a+random_table[g_random_p];
   if(m=0)
   then g_random:=0
   else g_random:=abs(integer(g_random_i) mod m);
end;

function g_randomr(r:integer):integer;
begin
   if(r=0)
   then g_randomr:=0
   else g_randomr:=g_random(r)-g_random(r);
end;

procedure g_randomFromMapSeed;
begin
   g_random_i:= word(map_seed);
   g_random_p:= byte(map_seed);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   UID/UPID Checks

function uid_CheckPlayerLimit(pl:PTPlayer;uid:byte):boolean;
begin
   with pl^ do
    with g_uids[uid] do
     if(_ukbuilding)and(menergy<=0)
     then uid_CheckPlayerLimit:=false
     else uid_CheckPlayerLimit:=((uid_e[uid]+uprodu[uid])<a_units[uid])and((army+uproda)<MaxPlayerUnits)and((armylimit+uprodl+_limituse)<=MaxPlayerLimit);
end;

function uid_CheckRequirements(pl:PTPlayer;uid:byte):cardinal;
procedure setr(ni:cardinal;b:boolean);
begin if(b)then uid_CheckRequirements:=uid_CheckRequirements or ni;end;
begin
   uid_CheckRequirements:=0;
   with pl^ do
   with g_uids[uid] do
   begin
      setr(ureq_unitlimit ,(army     +uproda          )>=MaxPlayerUnits);
      setr(ureq_armylimit ,(armylimit+uprodl+_limituse)> MaxPlayerLimit);
      setr(ureq_ruid      ,(_ruid1>0)and(uid_eb[_ruid1]<_ruid1n));
      setr(ureq_ruid      ,(_ruid2>0)and(uid_eb[_ruid2]<_ruid2n));
      setr(ureq_ruid      ,(_ruid3>0)and(uid_eb[_ruid3]<_ruid3n));
      setr(ureq_rupid     ,(_rupgr>0)and(upgr  [_rupgr]<_rupgrl));
      setr(ureq_energy    , cenergy<_renergy                     );
      setr(ureq_time      , _btime<=0                            );
      setr(ureq_max       ,(uid_e[uid]+uprodu[uid])>=a_units[uid]);

      case _ukbuilding of
true  : begin
           setr(ureq_builders ,n_builders<=0);
           setr(ureq_bld_r    ,build_cd  > 0);
        end;
false : setr(ureq_barracks    ,n_barracks<=0);
      end;
   end;
end;

function upid_CalcCostEnergy(upgr,lvl:byte):integer;
begin
   upid_CalcCostEnergy:=0;
   with g_upids[upgr] do
    if(0<lvl)and(lvl<=_up_max)then
     if(_up_mfrg)or((_up_renerg_xpl<=0)and(_up_renerg_apl<=0))
     then upid_CalcCostEnergy:=_up_renerg
     else
     begin
        lvl-=1;
        upid_CalcCostEnergy:=(_up_renerg*ipower(_up_renerg_xpl,lvl))+(_up_renerg_apl*lvl);
     end;
end;
function upid_CalcCostTime(upgr,lvl:byte):integer;
const upgr_max_time = fr_fps1*255;
begin
   upid_CalcCostTime:=0;
   with g_upids[upgr] do
    if(0<lvl)and(lvl<=_up_max)then
     if(_up_mfrg)or((_up_time_xpl<=0)and(_up_time_apl<=0))
     then upid_CalcCostTime:=_up_time
     else
     begin
        lvl-=1;
        upid_CalcCostTime:=min2i(upgr_max_time,_up_time*ipower(_up_time_xpl,lvl)+(_up_time_apl*lvl));
     end;
end;

function upid_CheckRequirements(pl:PTPlayer;up:byte):cardinal;
procedure setr(ni:cardinal;b:boolean);
begin if(b)then upid_CheckRequirements:=upid_CheckRequirements or ni;end;
begin
   upid_CheckRequirements:=0;
   with pl^ do
   with g_upids[up] do
   begin
      setr(ureq_ruid   ,(_up_ruid1>0)and(uid_eb[_up_ruid1]=0)  );
      setr(ureq_ruid   ,(_up_ruid2>0)and(uid_eb[_up_ruid2]=0)  );
      setr(ureq_ruid   ,(_up_ruid3>0)and(uid_eb[_up_ruid3]=0)  );
      setr(ureq_rupid  ,(_up_rupgr>0)and(upgr  [_up_rupgr]=0)  );
      setr(ureq_energy , cenergy<upid_CalcCostEnergy(up,upgr[up]+1)   );
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

function hits_li2si(h,mh:longint;s:single):shortint;
begin
   if(h>=mh                         )then hits_li2si:=127  else
   if(h =0                          )then hits_li2si:=0    else
   if(h =dead_hits                  )then hits_li2si:=-127 else
   if(h<=ndead_hits                 )then hits_li2si:=-128 else
   if(fdead_hits<h)and(h<0          )then hits_li2si:=mm3i(-125,h div _d2shi,-1  ) else
   if( dead_hits<h)and(h<=fdead_hits)then hits_li2si:=-126 else
                                          hits_li2si:=mm3i(   1,trunc(h/s)  ,_mms);
end;

function ai_name(ain:byte):shortstring;
begin
   if(ain=0)
   then ai_name:=str_pt_none
   else
     {$IFDEF _FULLGAME}
     case ain of
     0  : ai_name:=str_ptype_AI+' '+tc_gray  +b2s(ain)+tc_default;
     1  : ai_name:=str_ptype_AI+' '+tc_blue  +b2s(ain)+tc_default;
     2  : ai_name:=str_ptype_AI+' '+tc_aqua  +b2s(ain)+tc_default;
     3  : ai_name:=str_ptype_AI+' '+tc_lime  +b2s(ain)+tc_default;
     4  : ai_name:=str_ptype_AI+' '+tc_green +b2s(ain)+tc_default;
     5  : ai_name:=str_ptype_AI+' '+tc_yellow+b2s(ain)+tc_default;
     6  : ai_name:=str_ptype_AI+' '+tc_orange+b2s(ain)+tc_default;
     7  : ai_name:=str_ptype_AI+' '+tc_red   +b2s(ain)+tc_default;
     else ai_name:=str_ptype_AI+' '+str_ptype_cheater+' '+tc_purple+b2s(ain)+tc_default;
     end;
     {$ELSE}
     if(ain<8)
     then ai_name:=str_ps_comp+' '                   +b2s(ain)
     else ai_name:=str_ps_comp+' '+str_ps_cheater+' '+b2s(ain);
     {$ENDIF}
end;

function UnitHaveRPoint(uid:byte):boolean;
begin
   with g_uids[uid] do
   UnitHaveRPoint:=(_isbarrack)or(_ability=ua_HTeleport);
end;

function UnitF1Select(pu:PTUnit):boolean;
begin
   UnitF1Select:=false;
   with pu^  do
   with uid^ do
     if(hits<=0)
     or(not iscomplete)
     or(IsIntUnitRange(transport,nil))
     or(not _isbuilder)then exit;
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
      or(IsIntUnitRange(transport,nil))then exit;

      if(speed          <=0)then exit;
      if(_ukbuilding       )then exit;
      if(not _attack       )then exit;
      if not(ua_id in ua_f2)then exit;

      if(IsIntUnitRange(ua_tar,@tu))then
      begin
         if(tu^.uid^._ability=ua_HTeleport)and(not ukfly)then exit;

         if(unit_TransportCheck(pu,tu))
         or(unit_TransportCheck(tu,pu))then exit;
      end;
   end;
   UnitF2Select:=true;
end;

{function unit_canRebuild(pu:PTUnit):cardinal;
begin
   unit_canRebuild:=0;
   with pu^     do
   with uid^    do
    if(not iscomplete)
    or(hits<=0)
    or(_rebuild_uid=0)
    or((_rebuild_level>0)and(level>=_rebuild_level))
    then unit_canRebuild:=ureq_alreadyAdv
    else
      with player^ do
      begin
         if(_rebuild_ruid>0)then
          if(uid_eb[_rebuild_ruid]<=0)then unit_canRebuild+=ureq_ruid;

         if(_rebuild_rupgr>0)and(_rebuild_rupgrl>0)then
          if(upgr[_rebuild_rupgr]<_rebuild_rupgrl)then unit_canRebuild+=ureq_rupid;
      end;
end;}

{function unit_canAbility(pu:PTUnit):cardinal;
begin
   unit_canAbility:=0;
   with pu^     do
   with uid^    do
    if(not iscomplete)
    or(hits<=0)
    or(_ability=0)
    then unit_canAbility:=ureq_unknown
    else
      with player^ do
      begin
         if(_ability_rNoObstacles)then
           if(map_IsObstacleZone(zone))then unit_canAbility+=ureq_place;

         if(_ability_ruid>0)then
           if(uid_eb[_ability_ruid]<=0)then unit_canAbility+=ureq_ruid;

         if(_ability_rupgr>0)and(_ability_rupgrl>0)then
           if(upgr[_ability_rupgr]<_ability_rupgrl)then unit_canAbility+=ureq_rupid;

         if(_ability=ua_RebuildInPoint)and(unit_canAbility=0)then unit_canAbility+=unit_canRebuild(pu);
      end;
end; }

function GameStatus_IsEnded:boolean;
begin
   GameStatus_IsEnded:=(gs_win_team0<=G_status)and(G_status<=gs_win_team7);
end;

procedure GameSetStatusWinnerTeam(team:byte);
begin
   if(team<=LastPlayer)then
     G_status:=gs_win_team0+team;
   GameLogEndGame(team);
end;

function CheckUnitBaseFlags(pTarget:PTUnit;flags:cardinal):boolean;
begin
   CheckUnitBaseFlags:=false;

   if((flags and wtr_unit    )=0)and(not pTarget^.uid^._ukbuilding   )then exit;
   if((flags and wtr_building)=0)and(    pTarget^.uid^._ukbuilding   )then exit;

   if((flags and wtr_bio     )=0)and(not pTarget^.uid^._ukmech       )then exit;
   if((flags and wtr_mech    )=0)and(    pTarget^.uid^._ukmech       )then exit;

   if((flags and wtr_light   )=0)and    (pTarget^.uid^._uklight      )then exit;
   if((flags and wtr_heavy   )=0)and not(pTarget^.uid^._uklight      )then exit;

   if((flags and wtr_ground  )=0)and(pTarget^.ukfly = uf_ground      )then exit;
   if((flags and wtr_fly     )=0)and(pTarget^.ukfly = uf_fly         )then exit;

   CheckUnitBaseFlags:=true;
end;

function CheckUnitTeamVision(POVTeam:byte;pTarget:PTUnit;SkipInvisCheck:boolean):boolean;
begin
   with pTarget^ do
     if(buff[ub_Invis]<=0)or(hits<=0)or(SkipInvisCheck)
     then CheckUnitTeamVision:=(TeamVision[POVTeam]>0)
     else CheckUnitTeamVision:=(TeamVision[POVTeam]>0)and(TeamDetection[POVTeam]>0);
end;

procedure MakeMapPresetsNames(pstr_gmode,pstr_maptype:pshortstring);
var i,
    p,
    pn:byte;
begin
   if(map_preset_n>1)then
    for i:=1 to map_preset_n-1 do
     with map_preset_l[i] do
     begin
        pn:=0;
        //for p:=0 to LastPlayer do
       //   if(mapp_player_team[p]<=LastPlayer)then pn+=1;

        if(pn>0)
        then mapp_name:=b2s(pn)+')'
        else mapp_name:='';

        if(pstr_gmode<>nil)then
        begin
           pstr_gmode+=mapp_scenario;
           mapp_name+=pstr_gmode^;
           pstr_gmode-=mapp_scenario;
        end;

        if(pstr_maptype<>nil)then
        begin
           pstr_maptype+=mapp_type;
           mapp_name+=' '+pstr_maptype^;
           pstr_maptype-=mapp_type;
        end;
     end;
end;

{$IFDEF _FULLGAME}

////////////////////////////////////////////////////////////////////////////////
//
//   OTHER
//

type
TInputState = (tis_NPressed,tis_NReleased,tis_Pressed,tis_DPressed,tis_Released);

{function input_Check(iact:byte;CheckState:TInputState):boolean;
begin
   input_Check:=false;
   case CheckState of
tis_NPressed  : input_Check:=input_actions[iact].ik_timer_pressed=1;
tis_NReleased : input_Check:=input_actions[iact].ik_timer_pressed=-1;
tis_Pressed   : input_Check:=input_actions[iact].ik_timer_pressed>0;
tis_DPressed  : with input_actions[iact] do
                input_Check:=(ik_timer_pressed=1)and(ik_timer_twice>0);
tis_Released  : input_Check:=input_actions[iact].ik_timer_pressed=0;
   end;
end; }
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


function enum_val2TUIControlBarPos(val:integer):TUIControlBarPos;
begin
   for result in TUIControlBarPos do
     if(ord(result)=val)then exit;
   result:=low(TUIControlBarPos);
end;
function enum_val2TUIUnitHBarsOption(val:integer):TUIUnitHBarsOption;
begin
   for result in TUIUnitHBarsOption do
     if(ord(result)=val)then exit;
   result:=low(TUIUnitHBarsOption);
end;
function enum_val2TPlayersColorSchema(val:integer):TPlayersColorSchema;
begin
   for result in TPlayersColorSchema do
     if(ord(result)=val)then exit;
   result:=low(TPlayersColorSchema);
end;

function tabControlContent:TTabControlContent;
begin
   tabControlContent:=tcp_none;
   if(rpls_rstate>=rpls_state_read)
   then tabControlContent:=tcp_replay
   else
     if(g_players[PlayerClient].isobserver)or(GameStatus_IsEnded)
     then tabControlContent:=tcp_observer
     else
       if(not g_players[PlayerClient].isdefeated)
       then tabControlContent:=tcp_controls;
end;

function RoundN(x,n:integer):integer;
begin
   if(n>0)
   then RoundN:=round(x/n)*n
   else RoundN:=x
end;

////////////////////////////////////////////////////////////////////////////////
//
//   String
//

function str_linesCount(str:shortstring):byte;
var l:byte;
begin
   str_linesCount:=0;
   l:=length(str);
   while(l>0)do
   begin
      if(str[l]=tc_nl1)
      or(str[l]=tc_nl2)then str_linesCount+=1;
      l-=1;
   end;
end;

function str_SpaceSize(str:shortstring;newSize:byte):shortstring;
var l,i:byte;
begin
   str_SpaceSize:=str;
   l:=0;
   i:=length(str_SpaceSize);
   while(i>0)do
   begin
      if not(str_SpaceSize[i] in tc_SpecialChars)then l+=1;
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

function str_GStep2Time(gstep:cardinal):shortstring;
var
s , m, h: cardinal;
ss,sm,sh:shortstring;
begin
   s:=gstep div fr_fps1;
   m:=s div 60;
   s:=s mod 60;
   h:=m div 60;
   m:=m mod 60;

   str_GStep2Time:='';
   if(h>0)then
   begin
      if(h<10)then sh:='0'+c2s(h) else sh:=c2s(h);
      str_GStep2Time:=sh+':';
   end;
   if(m<10)then sm:='0'+c2s(m) else sm:=c2s(m);
   if(s<10)then ss:='0'+c2s(s) else ss:=c2s(s);
   str_GStep2Time+=sm+':'+ss;
end;

// replay/save common file data
function FileReadBaseGameInfo(var f:file;str_info1,str_info2:pshortstring):boolean;
const dots: shortstring = ': ';
map_charsn= 12;
var
dbyte : byte;
dint  : integer;
dcard : cardinal;
begin
   FileReadBaseGameInfo:=false;
   dbyte:=0;
   dint :=0;
   dcard:=0;

   // TIME
   BlockRead(f,dcard,SizeOf(G_Step      )); str_info1^+=str_uiHint_Time+str_GStep2Time(dcard)+tc_nl2;

   // MAP info
   str_info1^+=str_menu_map+tc_nl2;

   BlockRead(f,dbyte,SizeOf(map_preset_cur   ));
   if(dbyte>=map_preset_n         )then begin str_info1^:=str_error_WrongVersion;close(f);exit; end
                                   else       str_info1^+=' '+str_SpaceSize(str_map_Map       +dots,map_charsn)+map_preset_l[dbyte].mapp_name+tc_nl2;

   BlockRead(f,dbyte,SizeOf(map_scenario     ));
   if not(dbyte in allmapscenarios)then begin str_info1^:=str_error_WrongVersion;close(f);exit; end
                                   else       str_info1^+=' '+str_SpaceSize(str_map_scenario  +dots,map_charsn)+str_map_scenariol[dbyte]+tc_nl2;

   BlockRead(f,dbyte,SizeOf(map_generators   ));
   if(dbyte>gms_g_maxgens         )then begin str_info1^:=str_error_WrongVersion;close(f);exit; end
                                   else       str_info1^+=' '+str_SpaceSize(str_map_Generators+dots,map_charsn)+str_map_Generatorsl[dbyte]+tc_nl2;

   BlockRead(f,dcard,SizeOf(map_seed    ));   str_info1^+=' '+str_SpaceSize(str_map_seed      +dots,map_charsn)+c2s(dcard)+tc_nl2;
   BlockRead(f,dint ,SizeOf(map_psize   ));
   if(dint<MinMapSize)
   or(MaxMapSize<dint)             then begin str_info1^:=str_error_WrongVersion;close(f);exit; end
                                   else       str_info1^+=' '+str_SpaceSize(str_map_size      +dots,map_charsn)+i2s(dint)+tc_nl2;

   BlockRead(f,dbyte,SizeOf(map_type    ));
   if(dbyte>gms_m_types           )then begin str_info1^:=str_error_WrongVersion;close(f);exit; end
                                   else       str_info1^+=' '+str_SpaceSize(str_map_type      +dots,map_charsn)+str_map_typel[dbyte]+tc_default+tc_nl2;

   BlockRead(f,dbyte,SizeOf(map_symmetry));
   if(dbyte>gms_m_symm            )then begin str_info1^:=str_error_WrongVersion;close(f);exit; end
                                   else       str_info1^+=' '+str_SpaceSize(str_map_sym       +dots,map_charsn)+str_map_syml[dbyte]+tc_nl2;

   BlockRead(f,dint ,SizeOf(theme_cur   ));
   if(dint<0)or(dint>=theme_n)     then begin str_info1^:=str_error_WrongVersion;close(f);exit; end
                                   else       str_info1^+=' '+str_SpaceSize(str_map_theme     +dots,map_charsn)+theme_name[dint]+tc_nl2;

   // GAME info
   str_info2^:=str_menu_GameOptions+tc_nl2;
   BlockRead(f,dbyte,SizeOf(g_fixed_positions));
                                              str_info2^+=str_menu_FixedStarts  +dots+str_bool[dbyte>0]+tc_default+tc_nl2;

   BlockRead(f,dbyte,SizeOf(g_deadobservers  ));
                                              str_info2^+=str_menu_DeadObservers+dots+str_bool[dbyte>0]+tc_default+tc_nl2;

   BlockRead(f,dbyte,SizeOf(g_ai_slots       ));
   if(dbyte>gms_g_maxai           )then begin str_info2^:=str_error_WrongVersion;close(f);exit; end
                                   else       str_info2^+=str_menu_AISlots+dots+ai_name(dbyte)+tc_nl2;
   str_info2^+=tc_nl2+str_SpaceSize(str_menu_players,PlayerNameLen+3)
                     +str_SpaceSize(str_menu_race   ,9)
                     +str_menu_team;

   FileReadBaseGameInfo:=true;
end;

procedure UpdateLastSelectedUnit(u:integer);
var tu:PTUnit;
begin
   if(IsIntUnitRange(u,@tu))then
   begin
      if(ui_UnitSelectedNU<>0)then
        if(tu^.uid^._ucl<=g_units[ui_UnitSelectedNU].uid^._ucl)
        then exit;
      ui_UnitSelectedNU:=u;
   end;
end;


function UIUnitDrawRangeConditionals(pu:PTUnit):boolean;
begin
   with pu^  do
    with uid^ do
     UIUnitDrawRangeConditionals:=(_attack)
                                or(isbuildarea)
                                or(_ability=ua_UScan)
                                or(_ability=ua_HellVision);
end;

function ScrollInt(i:pinteger;s,min,max:integer;loop:boolean):boolean;
var oldi:integer;
begin
   ScrollInt:=false;
   if(max<min)then exit;
   oldi:=i^;
   i^+=s;
   if(loop)then
   begin
      if(i^>max)then i^:=min;
      if(i^<min)then i^:=max;
   end
   else i^:=mm3i(min,i^,max);;
   ScrollInt:=oldi<>i^;
end;

procedure WriteLog(mess:shortstring);
var  f:Text;
tmpStr:shortstring;
begin
   Assign(f,str_outLogFName);
   if FileExists(str_outLogFName)
   then Append (f)
   else Rewrite(f);
   tmpStr:=str_NowDateTime(true);
   if(str_outLogLastDate<>tmpStr)then
   begin
      str_outLogLastDate:=tmpStr;
      writeln(str_outLogLastDate);
   end;
   writeln(f,mess);
   {$IFDEF CONSOLE}
   writeln(mess);
   {$ENDIF}
   Close(f);
end;

function fog_check(x,y:integer):boolean;
var cx,cy:integer;
begin
   cx:=x div fog_CellW;
   cy:=y div fog_CellW;
   fog_check:=false;
   if(0<=cx)and(cx<=ui_FogView_cw)
  and(0<=cy)and(cy<=ui_FogView_ch)then fog_check:=ui_FogView_pgrid[cx,cy];
end;

function RectInCam(x,y,hw,hh,s:integer):boolean;
begin
   x-=vid_cam_x;
   y-=vid_cam_y;
   RectInCam:=((-hw           )<x)and(x<(vid_cam_w+hw))
           and((-hh-max2i(0,s))<y)and(y<(vid_cam_h+hh));
end;
function PointInCam(x,y:integer):boolean;
begin
   x-=vid_cam_x;
   y-=vid_cam_y;
   PointInCam:=(0<x)and(x<vid_cam_w)
            and(0<y)and(y<vid_cam_h);
end;
function RectInRect(x0,y0,x1,y1,vx,vy,r:integer):boolean;
begin
   RectInRect:=((x0-r)<=vx)and(vx<=(x1+r))and((y0-r)<=vy)and(vy<=(y1+r));
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
      if(not RectInCam(vx,vy,_r,_r,0))then
      begin
         ui_CheckUnitUIPlayerVision:=false;
         exit;
      end;

   if(not ui_fog)then exit;

   if(ui_player>LastPlayer)then
   begin
      if(rpls_rstate=rpls_state_read)
      or(g_players[PlayerClient].isobserver)then exit;
   end
   else
      if(tu^.TeamVision[g_players[ui_player].team]>0)then exit;

   ui_CheckUnitUIPlayerVision:=false;
end;

function ui_CheckUnitFullFogVision(tu:PTUnit):boolean;
begin
   ui_CheckUnitFullFogVision:=false;
   if(tu=nil)then exit;

   if(rpls_rstate>=rpls_state_read)
   or(g_players[PlayerClient].isobserver)then
   begin
      if(ui_player>LastPlayer)
      then ui_CheckUnitFullFogVision:=true
      else
        if(tu^.player^.team=g_players[ui_player].team)then ui_CheckUnitFullFogVision:=true;
   end
   else ui_CheckUnitFullFogVision:=(tu^.player^.team=g_players[PlayerClient].team);
end;

function ui_MapPointInRevealedInScreen(x,y:integer):boolean;
begin
   ui_MapPointInRevealedInScreen:=false;
   x-=vid_cam_x;
   y-=vid_cam_y;
   if(0<x)and(x<vid_cam_w)and
     (0<y)and(y<vid_cam_h)then
      if(not ui_fog)
      then ui_MapPointInRevealedInScreen:=true
      else ui_MapPointInRevealedInScreen:=fog_check(x,y);
end;

function ui_UIPlayerTeam(team:byte):boolean;
begin
   if(ui_player>LastPlayer)
   then ui_UIPlayerTeam:=true
   else ui_UIPlayerTeam:=team=g_players[ui_player].team;
end;

function PlayerGetColor(player:byte):TMWColor;
begin
   {
   str_menu_PlayersColorl[pcs_default]:= tc_white +'default'+tc_default;
   str_menu_PlayersColorl[pcs_LYR    ]:= tc_lime  +'own '   +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
   str_menu_PlayersColorl[pcs_WYR    ]:= tc_white +'own '   +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
   str_menu_PlayersColorl[pcs_WAR    ]:= tc_white +'own '   +tc_aqua  +'ally '+tc_red+'enemy'+tc_default;
   str_menu_PlayersColorl[pcs_teams  ]:= tc_lime+'t'+tc_red+'e'+tc_aqua+'a'+tc_yellow+'m'+tc_blue+'s'  +tc_default;
   str_menu_PlayersColorl[pcs_wTeams ]:= tc_white +'own '   +str_menu_PlayersColorl[pcs_teams];
   }
   PlayerGetColor:=c_white;
   if(player<=LastPlayer)then
     case ui_PlayersColorSchema of
pcs_default: PlayerGetColor:=PlayerColorSchemeFFA[player];
pcs_LYR,
pcs_WYR,
pcs_WAR    : if(player=ui_player)then
               case ui_PlayersColorSchema of
               pcs_LYR: PlayerGetColor:=c_lime;
               pcs_WYR,
               pcs_WAR: PlayerGetColor:=c_white;
               end
             else
               if(PlayerSlotGetTeam(ui_player,255)=PlayerSlotGetTeam(player,255))then
                 case ui_PlayersColorSchema of
                 pcs_LYR,
                 pcs_WYR: PlayerGetColor:=c_yellow;
                 pcs_WAR: PlayerGetColor:=c_aqua;
                 end
               else PlayerGetColor:=c_red;
pcs_teams  : PlayerGetColor:=PlayerColorSchemeTEAM[PlayerSlotGetTeam(player,255)];
pcs_wTeams : if(player=ui_player)
             then PlayerGetColor:=c_white
             else PlayerGetColor:=PlayerColorSchemeTEAM[PlayerSlotGetTeam(player,255)];
     else
     end;
end;

function ShadowColor(c:TMWColor):TMWColor;
begin
   ShadowColor:=
   (((c and $00FF0000) shr 17) shl 16) +
   (((c and $0000FF00) shr  9) shl 8 ) +
   (((c and $000000FF) shr  1)       );
end;

procedure UpdatePlayerColors;
var p:byte;
begin
   for p:=0 to LastPlayer do
   begin
      PlayerColorNormal[p]:=PlayerGetColor(p);
      PlayerColorShadow[p]:=ShadowColor(PlayerColorNormal[p]);
   end;
end;
function GetPlayerColor(playern:byte;default:TMWColor):TMWColor;
begin
   if(playern<=LastPlayer)
   then GetPlayerColor:=PlayerColorNormal[playern]
   else GetPlayerColor:=default;
end;

function GetCPColor(cp:byte):TMWColor;
begin
   GetCPColor:=c_gray;
   if(cp<=LastKeyPoint)then
     with g_KeyPoints[cp] do
       if(cpCaptureR>0)then
         if(cpTimer>0)and(ui_blink3=0)
         then GetCPColor:=PlayerColorNormal[cpTimerPlayer]
         else GetCPColor:=PlayerColorNormal[cpOwnerPlayer];
end;

////////////////////////////////////////////////////////////////////////////////
//
//   GAME

function hits_si2li(sh:shortint;mh:integer;s:single):longint;
begin
   case sh of
127     : hits_si2li:=mh;
1..126  : hits_si2li:=mm3i(1,trunc(sh*s),mh-1);
0       : hits_si2li:=0;
-125..-1: hits_si2li:=mm3i(dead_hits+1,sh*_d2shi,-1);
-126    : hits_si2li:=fdead_hits;
-127    : hits_si2li:=dead_hits;
-128    : hits_si2li:=ndead_hits;
   end;
end;

function GameGetStatusStrColor(pstr:pshortstring;pcol:PTMWColor;POVPlayer:byte):boolean;
var t:byte;
begin
   GameGetStatusStrColor:=false;

   if(G_status<gs_running)then
   begin
      GameGetStatusStrColor:=true;
      if(pstr<>nil)then pstr^:=str_gsunknown;
      if(pcol<>nil)then pcol^:=c_gray;

      if(pstr<>nil)and(pcol<>nil)then
        case G_status of
0..LastPlayer : begin
                   pstr^:=str_pause;
                   pcol^:=PlayerColorNormal[G_status];
                end;
gs_replayerror: begin
                   pstr^:=str_error_FileRead;
                   pcol^:=c_white;
                end;
gs_replayend  : begin
                   pstr^:=str_repend;
                   pcol^:=c_white;
                end;
gs_replaypause: begin
                   pstr^:=str_pause;
                   pcol^:=c_white;
                end;
gs_waitserver : begin
                   pstr^:=str_waitsv;
                   if(PlayerLobby<=LastPlayer)
                   then pcol^:=PlayerColorNormal[PlayerLobby]
                   else pcol^:=c_ltgray;
                end;
        else
         if(gs_win_team0<=G_status)and(G_status<=gs_win_team7)then
           if(POVPlayer<=LastPlayer)then
           begin
              t:=G_status-gs_win_team0;
              if(t=g_players[POVPlayer].team)then
              begin
                 pstr^:=str_win;
                 pcol^:=c_lime;
              end
              else
              begin
                 pstr^:=str_lose;
                 pcol^:=c_red;
              end;
           end
           else
             if(pstr<>nil)then pstr^:='';
        end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   GAME CAMERA

procedure GameCameraBounds;
var x0,y0,x1,y1:integer;
begin
   x0:=0;x1:=0;
   y0:=0;y1:=0;
   case ui_CBarPos of
uicbp_left  : x0:=-round(max2i(ui_ControlBar_w,ui_MiniMap_w)/vid_cam_sc);
uicbp_right : x1:=+round(max2i(ui_ControlBar_w,ui_MiniMap_w)/vid_cam_sc);
uicbp_top   : y0:=-round(max2i(ui_ControlBar_h,ui_MiniMap_w)/vid_cam_sc);
uicbp_bottom: y1:=+round(max2i(ui_ControlBar_h,ui_MiniMap_w)/vid_cam_sc);
   end;

   if(vid_cam_w>=map_psize)
   then vid_cam_x:=map_phsize-vid_cam_hw+(x0-x1) div 2
   else vid_cam_x:=mm3i(x0,vid_cam_x,map_psize-vid_cam_w+x1);

   if(vid_cam_h>=map_psize)
   then vid_cam_y:=map_phsize-vid_cam_hh+(y0-y1) div 2
   else vid_cam_y:=mm3i(y0,vid_cam_y,map_psize-vid_cam_h+y1);

   vid_cam_x1   :=vid_cam_x+vid_cam_w;
   vid_cam_y1   :=vid_cam_y+vid_cam_h;

   vid_mmvx     :=round(vid_cam_x*map_mm_cx);
   vid_mmvy     :=round(vid_cam_y*map_mm_cx);
   ui_FogView_sx:=vid_cam_x div fog_CellW;
   ui_FogView_sy:=vid_cam_y div fog_CellW;
   ui_FogView_ex:=ui_FogView_sx+ui_FogView_cw;
   ui_FogView_ey:=ui_FogView_sy+ui_FogView_ch;
end;

procedure GameCameraMoveToPoint(mx,my:integer);
begin
   vid_cam_x:=mx-vid_cam_hw;
   vid_cam_y:=my-vid_cam_hh;
   GameCameraBounds;
end;

procedure GameCameraMoveToLastEvent;
var log_pi:cardinal;
begin
   if(ui_player<=LastPlayer)then
   with g_players[ui_player] do
   begin
      log_pi:=log_i;
      while true do
      begin
         with log_l[log_pi] do
          if(xi>0)or(yi>0)then
          begin
             GameCameraMoveToPoint(xi,yi);
             break;
          end;
         if(log_pi>0)
         then log_pi-=1
         else log_pi:=MaxPlayerLog;
         if(log_pi=log_i)then exit;
      end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    CLIENT LOG PROCESSIGN

function TrimString(s:shortstring;l:byte):shortstring;
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
   TrimString:=s;
end;

function LogMessage2StrColor(ptlog:PTLogMes;mcolor:PTMWColor):shortstring;
begin
   LogMessage2StrColor:='';
   mcolor^:=c_white;
   with ptlog^ do
    case mtype of
0..LastPlayer        : if(length(str)>0)then
                       begin
                          //mtype = sender
                          mcolor^:=PlayerColorNormal[mtype];
                          LogMessage2StrColor:=g_players[mtype].name+': '+str;
                       end;
lmt_req_ruids,
lmt_req_common,
lmt_req_energy,
lmt_cant_build       : begin
                          case mtype of
                          lmt_req_ruids : LogMessage2StrColor:=str_uiWarn_CheckReqs;
                          lmt_req_common: LogMessage2StrColor:=str_uiWarn_CantProd;
                          lmt_req_energy: LogMessage2StrColor:=str_uiWarn_NeedEnergy;
                          lmt_cant_build: LogMessage2StrColor:=str_uiWarn_CantBuild;
                          end;
                          if(argx>0)then
                            case argt of
                          lmt_argt_unit: with g_uids [argx] do LogMessage2StrColor+=' ('+un_txt_name+')';
                          lmt_argt_upgr: with g_upids[argx] do LogMessage2StrColor+=' ('+_up_name   +')';
                            end;
                       end;
lmt_player_chat,
lmt_game_message     ,
lmt_player_leave     : LogMessage2StrColor:=str;//if(argx<=MaxPlayers)then LogMessage2StrColor:=g_players[argx].name+str_msg_PlayerLeave;
lmt_game_end         : if(argx<=LastPlayer)and(ui_player<=LastPlayer)then
                        if(argx=g_players[ui_player].team)
                        then LogMessage2StrColor:=str_win
                        else LogMessage2StrColor:=str_lose;
lmt_player_surrender : if(argx<=LastPlayer)then LogMessage2StrColor:=g_players[argx].name+str_msg_PlayerSurrender;
lmt_player_defeated  : if(argx<=LastPlayer)then LogMessage2StrColor:=g_players[argx].name+str_msg_PlayerDefeated;
lmt_upgrade_complete : begin
                       with g_upids[argx] do LogMessage2StrColor:=str_uiWarn_UpgradeComplete+' ('+_up_name+')';
                       mcolor^:=c_yellow;
                       end;
lmt_unit_ready       : begin
                       with g_uids[argx] do
                        case argt of
                         lmt_argt_unit : if(_ukbuilding)
                                     then LogMessage2StrColor:=str_uiWarn_BuildingComplete+' ('+un_txt_name+')'
                                     else LogMessage2StrColor:=str_uiWarn_UnitComplete    +' ('+un_txt_name+')';
                        end;
                       mcolor^:=c_green;
                       end;
lmt_unit_promoted    : begin
                       with g_uids[argx] do LogMessage2StrColor:=str_uiWarn_UnitPromoted+' ('+un_txt_name+')';
                       mcolor^:=c_aqua;
                       end;
lmt_allies_attacked  : begin
                       with g_uids[argx] do
                        LogMessage2StrColor:=str_uiWarn_AlliesAttacked+' ('+un_txt_name+')';
                       mcolor^:=c_orange;
                       end;
lmt_unit_attacked    : begin
                       with g_uids[argx] do
                        if(_ukbuilding)
                        then LogMessage2StrColor:=str_uiWarn_BaseAttacked+' ('+un_txt_name+')'
                        else LogMessage2StrColor:=str_uiWarn_UnitAttacked+' ('+un_txt_name+')';
                       mcolor^:=c_red;
                       end;
lmt_cant_order       : begin
                       LogMessage2StrColor:=str_uiWarn_CantExecute;
                       with g_uids [argx] do LogMessage2StrColor+=' ('+un_txt_name+')';
                       end;
lmt_MaximumReached   : LogMessage2StrColor:=str_uiWarn_MaximumReached;
lmt_NeedMoreProd     : LogMessage2StrColor:=str_uiWarn_NeedMoreProd;
lmt_already_adv      : LogMessage2StrColor:=str_uiWarn_CantRebuild;
lmt_production_busy  : LogMessage2StrColor:=str_uiWarn_ProductionBusy;
lmt_unit_needbuilder : LogMessage2StrColor:=str_uiWarn_NeedMoreBuilders;
lmt_unit_limit       : LogMessage2StrColor:=str_uiWarn_MaxLimitReached;
lmt_map_mark         : begin
                       mcolor^:=c_gray;
                       if(argx<=LastPlayer)then
                         with g_players[argx] do LogMessage2StrColor:=name+str_uiWarn_MapMark;
                       end;
    else               LogMessage2StrColor:='UNKNOWN MESSAGE TYPE'; mcolor^:=c_purple;
    end;
end;

procedure MakeLogListForDraw(POVPlayer:byte;widthchars,listheight:integer;logtypes:TSoB);
var ts:shortstring;
mc:TMWColor;
n,i:cardinal;
chunkp,
chunkl,
chunks:integer;
 st,sl:byte;
procedure AddLine(s:shortstring;t:byte;c:TMWColor);
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

   if(widthchars>0)and(listheight>0)and(POVPlayer<=LastPlayer)then
   with g_players[POVPlayer] do
   begin
      widthchars+=1;
      i:=log_i;
      n:=listheight;

      while(n>0)do
      begin
         mc:=c_white;
         st:=log_l[i].mtype;
         if(st in logtypes)
         then ts:=LogMessage2StrColor(@log_l[i],@mc)
         else ts:='';
         sl:=length(ts);
         if(i=0)
         then i:=MaxPlayerLog
         else i-=1;
         n-=1;

         if(sl>0)then
          if(sl<=widthchars)
          then AddLine(ts,st,mc)
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
                AddLine(copy(ts,chunkp,chunkl),st,mc);
                chunks-=1;
             end;
          end;
      end;
   end;
   while(ui_log_n<listheight)do AddLine('',0,c_black);
end;

{$ELSE}
////////////////////////////////////////////////////////////////////////////////
//
//   DEDICATED SERVER FUNCTIONS

function PlayerGetStatus(p:byte):char;
begin
   with g_players[p] do
   begin
      PlayerGetStatus:=#0;
      {PlayerGetStatus:=str_ps_c[state];
      if(state=ps_play)then
      begin
         if(g_started=false)
         then PlayerGetStatus:=str_b2c[isready]
         else PlayerGetStatus:=str_ps_c[ps_play];
         if(nttl>=fr_fps1)then PlayerGetStatus:=str_ps_t;
      end;
      if(p=PlayerClient)then PlayerGetStatus:=str_ps_h; }
   end;
end;

function PlayerAllOut:boolean;
var i,c,r:byte;
begin
   c:=0;
   r:=0;
   {for i:=0 to LastPlayer do
    with g_players[i] do
     if (state=pt_Play) then
     begin
        c+=1;
        if(nttl=ClientTTL)then r+=1;
     end;  }
   PlayerAllOut:=(r=c)and(c>0);
end;

{$ENDIF}



