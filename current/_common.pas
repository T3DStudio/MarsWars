procedure _unit_damage(pu:PTUnit;damage,pain_f:integer;pl:byte);  forward;
procedure _unit_upgr  (pu:PTUnit);  forward;
procedure ai_clear_vars(pu:PTUnit);forward;
procedure ai_set_nearest_alarm(tu:PTUnit;x,y,ud:integer;zone:word);forward;
procedure ai_collect_data(pu,tu:PTUnit;ud:integer);forward;
procedure ai_scout_pick(pu:PTUnit);forward;
procedure ai_code(pu:PTUnit);forward;
function ai_HighPrioTarget(player:PTPlayer;tu:PTUnit):boolean;forward;
function _canmove  (pu:PTUnit):boolean; forward;
function _canattack(pu:PTUnit;check_buffs:boolean):boolean; forward;
function _itcanapc(uu,tu:PTUnit):boolean;  forward;
function pf_isobstacle_zone(zone:word):boolean;  forward;

{$IFDEF _FULLGAME}
function ui_addalrm(ax,ay:integer;av:byte;new:boolean):boolean;forward;
function LogMes2UIAlarm:boolean; forward;
procedure SoundLogHPlayer;  forward;
{$ENDIF}

function b2s (i:byte    ):shortstring;begin str(i,b2s );end;
function w2s (i:word    ):shortstring;begin str(i,w2s );end;
function c2s (i:cardinal):shortstring;begin str(i,c2s );end;
function i2s (i:integer ):shortstring;begin str(i,i2s );end;
function si2s(i:single  ):shortstring;begin str(i,si2s);end;
function s2b (str:shortstring):byte    ;var t:integer;begin val(str,s2b ,t);end;
function s2w (str:shortstring):word    ;var t:integer;begin val(str,s2w ,t);end;
function s2i (str:shortstring):integer ;var t:integer;begin val(str,s2i ,t);end;
function s2c (str:shortstring):cardinal;var t:integer;begin val(str,s2c ,t);end;
function s2si(str:shortstring):single  ;var t:integer;begin val(str,s2si,t);end;

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

function cf(c,f:pcardinal):boolean;  // check flag
begin cf:=(c^ and f^)>0;end;

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
procedure PlayerSetCurrentUpgrades(p:byte;g:TSob;lvl:integer;new:boolean);  // current upgrades
var i:byte;
begin
   with _players[p] do
   begin
      if(new)then FillChar(upgr,SizeOf(upgr),0);
      if(g<>[])then
       for i:=0 to 255 do
        if(i in g)then
         with _upids[i] do upgr[i]:=min3(a_upgrs[i],_up_max,lvl);
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   LOG
//

function PlayerSetProdError(player,utp,uid:byte;cndt:cardinal;pu:PTUnit):boolean;
begin
   PlayerSetProdError:=false;
   if(player<=MaxPlayers)then
   with _players[player] do
   begin
      prod_error_cndt:=cndt;
      prod_error_utp :=utp;
      prod_error_uid :=uid;
      if(pu<>nil)then
      begin
      prod_error_x   :=byte(pu^.x shr 5);
      prod_error_y   :=byte(pu^.y shr 5);
      end
      else
      begin
      prod_error_x   :=255;
      prod_error_y   :=255;
      end;
      PlayerSetProdError:=cndt>0;
   end;
end;

procedure PlayerAddLog(ptarget,amtype,auidt,auid:byte;astr:shortstring;ax,ay:integer;local:boolean);
begin
   if(ptarget>MaxPlayers)then exit;

   with _players[ptarget] do
   if(state>ps_none)then
   begin
      if(local=false)then
      log_n+=1;

      log_i+=1;
      if(log_i>MaxPlayerLog)then log_i:=0;

      with log_l[log_i] do
      begin
         mtype:=amtype;
         uidt :=auidt;
         uid  :=auid;
         str  :=astr;
         x    :=ax;
         y    :=ay;
      end;

      {$IFDEF _FULLGAME}
      if(ptarget=HPlayer)then
      begin
         net_chat_shlm:=min2(net_chat_shlm+chat_shlm_t,chat_shlm_max);
         vid_menu_redraw:=true;

         if(LogMes2UIAlarm)then SoundLogHPlayer;
      end;
      {$ENDIF}
   end;
end;

procedure PlayersAddToLog(playern,to_players,amtype,auidt,auid:byte;astr:shortstring;ax,ay:integer;local:boolean);
var i:byte;
begin
   for i:=0 to MaxPlayers do
    if((to_players and (1 shl i))>0)
    or(i=playern)
    or(i=0)then PlayerAddLog(i,amtype,auidt,auid,astr,ax,ay,local);
end;

procedure GameLogChat(sender,targets:byte;message:shortstring;local:boolean);
begin
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
procedure GameLogPlayerDefeated(pl:byte);
begin
   if(pl>MaxPlayers)or(ServerSide=false)then exit;
   PlayersAddToLog(pl,log_to_all,lmt_player_defeated,0,pl,'',0,0,false);
end;
procedure GameLogPlayerLeave(pl:byte);
begin
   if(pl>MaxPlayers)or(ServerSide=false)then exit;
   PlayersAddToLog(pl,log_to_all,lmt_player_leave,0,pl,'',0,0,false);
end;
procedure GameLogUnitReady(pu:PTunit);
begin
   if(pu=nil)or(ServerSide=false)then exit;

   with pu^ do
    if(buff[ub_advanced]>0)
    then PlayersAddToLog(playeri,0,lmt_unit_ready,glcp_unita,uidi,'',x,y,false)
    else PlayersAddToLog(playeri,0,lmt_unit_ready,glcp_unit ,uidi,'',x,y,false);
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
   if(pl>MaxPlayers)or(ServerSide=false)or(condt=0)then exit;

   if(_players[pl].state=ps_comp)then exit;

   if(cf(@condt,@ureq_place))
   then bt:=lmt_cant_build
   else
     if(cf(@condt,@ureq_ruid))or(cf(@condt,@ureq_rupid))
     then bt:=lmt_req_ruids
     else
      if(condt=ureq_energy)
      then bt:=lmt_req_energy
      else bt:=lmt_req_common;

   PlayersAddToLog(pl,0,bt,utp,uid,'',x,y,local);
end;
procedure GameLogMapMark(pl:byte;x,y:integer);
begin
   if(pl>MaxPlayers)or(ServerSide=false)then exit;

   PlayersAddToLog(pl,0,lmt_map_mark,0,0,'',x,y,false);
end;

procedure PlayerClearLog(pn:byte);
begin
   if(pn>MaxPlayers)then exit;

   with _players[pn] do
   begin
      FillChar(log_l,SizeOf(log_l),0);
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
   PlayerObserver:=(upgr[upgr_fog_vision]>0)
                 or(g_deadobservers and(armylimit<=0))
                 or((pnum>0)and(team=0));
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
             5,6 : PlayerGetTeam:=5;
             end;
gm_invasion: PlayerGetTeam:=1;
     else    PlayerGetTeam:=_players[p].team;
     end;
end;

function PlayerGetStatus(p:integer):char;
begin
   with _players[p] do
   begin
      PlayerGetStatus:=str_ps_c[state];
      if(state=ps_play)then
      begin
         if(g_started=false)
         then PlayerGetStatus:=b2c[ready]
         else PlayerGetStatus:=str_ps_c[ps_play];
         if(ttl>=fr_fps)then PlayerGetStatus:=str_ps_t;
         {$IFDEF _FULLGAME}
         if(net_cl_svpl=p)then
         begin
            PlayerGetStatus:=str_ps_sv;
            if(net_cl_svttl>=fr_fps)then PlayerGetStatus:=str_ps_t;
         end;
         {$ENDIF}
      end;
      if(p=HPlayer)then PlayerGetStatus:=str_ps_h;
   end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure CalcPLNU;
var p:byte;
begin
   g_player_status:=0;
   g_cl_units:=0;
   for p:=0 to MaxPlayers do
    with _players[p] do
     if(army>0)and(state>ps_none)then
     begin
        g_player_status:=g_player_status or (1 shl p);
        g_cl_units+=MaxPlayerUnits;
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
var vx,vy,avx,avy:integer;
    res:single;
begin
   point_dir:=270;
   vx:=x1-x0;
   vy:=y1-y0;

   if(vx=0)and(vy=0)then exit;

   avx:=abs(vx);
   avy:=abs(vy);

   if(avx>avy)
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

procedure _AddToInt(bt:pinteger;val:integer);
begin
   if(bt^<val)then bt^:=val;
end;

function _CheckRoyalBattleR(x,y,d:integer):boolean;
begin
   if(g_mode=gm_royale)
   then _CheckRoyalBattleR:=(point_dist_int(x,y,map_hmw,map_hmw)+d)>=g_royal_r
   else _CheckRoyalBattleR:=false;
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
     else _uid_player_limit:=((army+uproda)<MaxPlayerUnits)and((armylimit+uprodl+_limituse)<=MaxPlayerLimit);
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
      setr(ureq_rupid     ,(_rupgr>0)and(upgr  [_rupgr]<_rupgrn));
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
const upgr_max_time = fr_fps*255;
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
     8  : ai_name:=str_ps_comp+' '+tc_purple+b2s(ain)+tc_default;
     else ai_name:=str_ps_comp+' '+tc_white +b2s(ain)+tc_default;
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
   _UnitHaveRPoint:=(_isbarrack)or(_ability in [uab_teleport,uab_uac__unit_adv]);
end;

function UnitF2Select(pu:PTUnit):boolean;
var tu:PTUnit;
begin
   UnitF2Select:=false;
   with pu^  do
   with uid^ do
   begin
      if(hits<=0)
      or(not bld)
      or(_IsUnitRange(inapc,nil))then exit;

      if(speed          <=0)then exit;
      if(_ukbuilding       )then exit;
      if(_attack  =atm_none)then exit;
      if(uo_id=ua_paction  )
      or(uo_id=ua_hold     )
      or(uo_bx>0           )then exit;

      if(_IsUnitRange(uo_tar,@tu))then
      begin
         if(tu^.uid^._ability=uab_teleport)then exit;

         if(tu^.uid^._ability=uab_uac__unit_adv)then
          if(_ability<>uab_advance)and(buff[ub_advanced]<=0)then exit;

         if(_itcanapc(pu,tu))
         or(_itcanapc(tu,pu))then exit;
      end;
   end;
   UnitF2Select:=true;
end;

function _canability(pu:PTUnit):boolean;
begin
   _canability:=false;
   with pu^     do
   with uid^    do
   if(_ability>0)then
   with player^ do
   begin
      if(bld=false)or(hits<=0)then exit;

      if(_ability_no_obstacles)then
       if(pf_isobstacle_zone(pfzone))then exit;

      if(_ability_rupgr>0)then
       if(upgr[_ability_rupgr]<_ability_rupgrl)then exit;

      if(_ability_ruid>0)then
       if(uid_eb[_ability_ruid]<=0)then exit;
   end;
   _canability:=true;
end;

function _uvision(uteam:byte;tu:PTUnit;noinvis:boolean):boolean;
begin
   {$IFDEF _FULLGAME}
   if(rpls_state>=rpl_rhead)and(HPlayer=0)
   then _uvision:=true
   else
   {$ENDIF}
    with tu^ do
     if(buff[ub_invis]<=0)or(hits<=0)or(noinvis)
     then _uvision:=(vsnt[uteam]>0)
     else _uvision:=(vsnt[uteam]>0)and(vsni[uteam]>0);
end;

{$IFDEF _FULLGAME}


function UIUnitDrawRange(pu:PTUnit):boolean;
begin
   with pu^  do
    with uid^ do
     UIUnitDrawRange:=(_attack>0)
                    or(isbuildarea)
                    or(_ability=uab_radar)
                    or(_ability=uab_hell_vision);
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
   writeln(mess);
   Close(f);
end;

function fog_check(x,y:integer):boolean;
var cx,cy:integer;
begin
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

function PointInScreenP(x,y:integer;player:PTPlayer):boolean;
begin
   // player = player of vision source
   PointInScreenP:=false;
   x-=vid_cam_x;
   y-=vid_cam_y;
   if(0<x)and(x<vid_cam_w)and
     (0<y)and(y<vid_cam_h)then
   begin
      if(player<>nil)then
       if (player^.team=_players[HPlayer].team)
       or((rpls_state>=rpl_rhead)and(player^.pnum=0))then
       begin
          PointInScreenP:=true;
          exit;
       end;

      if(rpls_fog=false)or(fog_check(x,y))then PointInScreenP:=true;
   end;
end;

function PlayerGetColor(player:byte):cardinal;
begin
   PlayerGetColor:=c_white;
   if(player<=MaxPlayers)then
    case vid_plcolors of
   1,
   2: if(player=HPlayer)then
        if(vid_plcolors=1)
        then PlayerGetColor:=c_lime
        else PlayerGetColor:=c_white
      else
        if(PlayerGetTeam(g_mode,HPlayer)=PlayerGetTeam(g_mode,player))
        then PlayerGetColor:=c_yellow
        else PlayerGetColor:=c_red;
   3: PlayerGetColor:=PlayerColor[PlayerGetTeam(g_mode,player)];
   4: if(player=HPlayer)
      then PlayerGetColor:=c_white
      else PlayerGetColor:=PlayerColor[PlayerGetTeam(g_mode,player)];
    else PlayerGetColor:=PlayerColor[player];
    end;
end;

function GetCPColor(cp:byte):cardinal;
begin
   GetCPColor:=c_black;
   if(cp<1)or(cp>MaxCPoints)then exit;
   with g_cpoints[cp] do
    if(cpCapturer>0)then
     if(cpTimer>0)and((G_Step mod 20)>10)
     then GetCPColor:=PlayerGetColor(cpTimerOwnerPlayer)
     else GetCPColor:=PlayerGetColor(cpOwnerPlayer     );
end;

function GameGetStatus(pstr:pshortstring;pcol:pcardinal):boolean;
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
        if(G_status>=gs_win_team)then
        begin
           t:=G_status-gs_win_team;
           if(t<=MaxPlayers)then
            if(t=_players[HPlayer].team)then
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
      _menu:=not _menu;
      vid_menu_redraw:=_menu;
      menu_item:=0;
      if(net_status=ns_none)and(g_Status<=MaxPlayers)then
       if(_menu)
       then g_Status:=HPlayer
       else g_Status:=gs_running;
   end;
end;

procedure CamBounds;
begin
   vid_cam_x:=mm3(0,vid_cam_x,map_mw-vid_cam_w);
   vid_cam_y:=mm3(0,vid_cam_y,map_mw-vid_cam_h);

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
   with _players[HPlayer] do
   begin
      log_pi:=log_i;
      while true do
      begin
         with log_l[log_pi] do
          if(x>0)or(y>0)then
          begin
             MoveCamToPoint(x,y);
             break;
          end;
         if(log_pi>0)
         then log_pi-=1
         else log_pi:=MaxPlayerLog;
         if(log_pi=log_i)then exit;
      end;
   end;
end;

procedure GameLogUnitAttacked(pu:PTunit);
var atype:byte;
begin
   if(pu=nil)then exit;

   with pu^ do
    if(playeri=HPlayer)then
    begin
       if(uid^._ukbuilding)
       then atype:=aummat_attacked_b
       else atype:=aummat_attacked_u;
       if(ui_addalrm(x,y,atype,false))then PlayersAddToLog(playeri,0,lmt_unit_attacked,0,uidi,'',x,y,true);
    end;
end;

function ParseLogMessage(ptlog:PTLogMes;mcolor:pcardinal):shortstring;
begin
   ParseLogMessage:='';
   mcolor^:=c_white;
   with ptlog^ do
    case mtype of
0..MaxPlayers        : begin
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
                          case uidt of
                          glcp_unit,
                          glcp_unita: with _uids [uid] do ParseLogMessage:=ParseLogMessage+' ('+un_txt_name+')';
                          glcp_upgr : with _upids[uid] do ParseLogMessage:=ParseLogMessage+' ('+_up_name   +')';
                          end;
                       end;
lmt_player_chat,
lmt_game_message     : ParseLogMessage:=str;
lmt_player_leave     : if(uid<=MaxPlayers)then ParseLogMessage:=_players[uid].name+str_plout;
lmt_game_end         : if(uid<=MaxPlayers)then
                        if(uid=_players[HPlayer].team)
                        then ParseLogMessage:=str_win
                        else ParseLogMessage:=str_lose;
lmt_player_defeated  : if(uid<=MaxPlayers)then
                        if(uid<>HPlayer)then ParseLogMessage:=_players[uid].name+str_player_def;
lmt_upgrade_complete : begin
                       with _upids[uid] do ParseLogMessage:=str_upgrade_complete+' ('+_up_name+')';
                       mcolor^:=c_yellow;
                       end;
lmt_unit_ready       : begin
                       with _uids [uid] do
                        case uidt of
                         glcp_unit : if(_ukbuilding)
                                     then ParseLogMessage:=str_building_complete+' ('+un_txt_name+')'
                                     else ParseLogMessage:=str_unit_complete    +' ('+un_txt_name+')';
                         glcp_unita: if(_ukbuilding)
                                     then ParseLogMessage:=str_building_complete+' ('+str_advanced+un_txt_name+')'
                                     else ParseLogMessage:=str_unit_complete    +' ('+str_advanced+un_txt_name+')';
                        end;
                       mcolor^:=c_green;
                       end;
lmt_unit_advanced    : begin
                       with _uids[uid] do ParseLogMessage:=str_unit_advanced+' ('+un_txt_name+')';
                       mcolor^:=c_aqua;
                       end;
lmt_unit_attacked    : begin
                       with _uids[uid] do
                        if(_ukbuilding)
                        then ParseLogMessage:=str_base_attacked+' ('+un_txt_name+')'
                        else ParseLogMessage:=str_unit_attacked+' ('+un_txt_name+')';
                       mcolor^:=c_red;
                       end;
    end;
end;

procedure ReMakeLogForDraw(playern:byte;widthchars,listheight:integer;logtypes:TSoB);
var ts:shortstring;
mc,n,i:cardinal;
chunkp,
chunkl,
chunks:integer;
 st,sl:byte;
procedure _add(s:shortstring;t:byte;c:cardinal);
begin
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



