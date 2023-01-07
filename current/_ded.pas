
procedure _dedInit;
begin
   net_status:=ns_srvr;
   if(net_UpSocket=false)then
   begin
      net_dispose;
      net_status:=ns_none;
      _CYCLE:=false;
   end
   else
   begin
      HPlayer:=0;
      PlayersSetDefault;
   end;

   vid_menu_redraw:=true;
end;


procedure NewAI(r,t,a:byte);
var p:byte;
begin
   for p:=1 to MaxPlayers do
    with _Players[p] do
     if(state=ps_none)then
     begin
        if(g_mode in [gm_scirmish,gm_capture])then  team:=t;
        race:=r;
        mrace:=race;
        ai_skill:=a;
        PlayerSetState(p,ps_comp);
        break;
     end;
end;

procedure RemoveAI;
var p:byte;
begin
   for p:=1 to MaxPlayers do
    with _Players[p] do
     if(state=ps_comp)then PlayerSetState(p,ps_none);
end;

procedure cmp_ffa;
var i: byte;
begin
   for i:=1 to MaxPlayers do
    with _players[i] do
     if(state=ps_comp)then team:=i;
end;

procedure _parseCmd(msg:string;pl:byte);
var v      : shortstring;
    l,p,a  : byte;
    args   : array of shortstring;
function _a2r(s:shortstring):byte;
begin
   _a2r:=r_random;
   if(s='H')or(s='h')then _a2r:=r_hell;
   if(s='U')or(s='u')then _a2r:=r_uac;
end;
begin
   if(length(msg)=0)then exit;
   if(ord(msg[1])<=MaxPlayers)then delete(msg,1,1);

   setlength(args,0);
   a:=0;
   l:=length(msg);
   while(l>0)do
   begin
      v:='';
      p:=pos(' ',msg);
      if(p>0)then
      begin
         v:=copy(msg,1,p-1);
         delete(msg,1,p);
         l-=p;
      end
      else
      begin
         v:=msg;
         delete(msg,1,l);
         l:=0;
      end;

      while(true)do
      begin
         p:=pos(' ',v);
         if(p=0)
         then break
         else delete(v,p,1);
      end;

      a+=1;
      setlength(args,a);
      args[a-1]:=v;
   end;

   if(a=0)then exit;

   case args[0] of
   '-h',
   '-help':
   begin
      GameLogCommon(0,log_to_all,'MarsWars dedicated server, '+str_ver  ,false);
      GameLogCommon(0,log_to_all,'New map: -m [seed size lakes obs sym]',false);
      GameLogCommon(0,log_to_all,'Add AI player: -p [R/H/U team skill]' ,false);
      GameLogCommon(0,log_to_all,'Remove all AI players: -k or -noai'   ,false);
      GameLogCommon(0,log_to_all,'Set 1..6 teams to AI players: -ffa'   ,false);
      GameLogCommon(0,log_to_all,'Game moddes: -s - scirmish'           ,false);
      GameLogCommon(0,log_to_all,'  -f2/3- 2/3 fortress, -i - invasion' ,false);
      GameLogCommon(0,log_to_all,'  -c - capturing points, -a - assault',false);
      GameLogCommon(0,log_to_all,'  -rb - royal battle'                 ,false);
      GameLogCommon(0,log_to_all,'  -ud/-d2 - UDOOM/DOOM 2 mode'        ,false);
      GameLogCommon(0,log_to_all,'Fixed player starts: -fp'             ,false);
      GameLogCommon(0,log_to_all,'Starting base options: -st 1-6'       ,false);
      GameLogCommon(0,log_to_all,'Fill empty slots with AI: -fs 0-7'    ,false);
      exit;
   end;
   '-m'  : if(a<6)
           then begin Map_randommap; Map_premap;end
           else
           begin
              map_seed    :=s2c(args[1]);
              map_mw      :=mm3(MinSMapW, s2i(args[2]), MaxSMapW);
              map_liq     :=min2(7,s2b(args[3]));
              map_obs     :=min2(7,s2b(args[4]));
              map_symmetry:=s2i(args[5])>0;
              Map_premap;
           end;
   '-p'  : if(a<3)
           then with _players[pl] do NewAI(race,team,4)
           else NewAI(_a2r(args[1]), mm3(1,s2b(args[2]),MaxPlayers), mm3(1,s2b(args[3]),7));
'-ffa'   : cmp_ffa;
'-noai',
'-k'     : RemoveAI;
'-3x3'   : begin g_mode:=gm_3x3;      Map_premap; end;
'-2x2x2' : begin g_mode:=gm_2x2x2;    Map_premap; end;
'-scir'  : begin g_mode:=gm_scirmish; Map_premap; cmp_ffa; end;
'-inv'   : begin g_mode:=gm_invasion; Map_premap; end;
'-cpt'   : begin g_mode:=gm_capture;  Map_premap; cmp_ffa; end;
'-koth'  : begin g_mode:=gm_koth;     Map_premap; end;
'-rb'    : begin g_mode:=gm_royale;   Map_premap; end;
'-cg'    : begin g_cgenerators     :=not g_cgenerators;    Map_premap;end;
'-fp'    : begin g_fixed_positions :=not g_fixed_positions;Map_premap;end;
'-st'    : if(a=2)then g_start_base:=mm3(0,s2b(args[1])-1,gms_g_startb);
'-fs'    : if(a=2)then g_ai_slots  :=mm3(0,s2b(args[1])  ,gms_g_maxai );
   else exit;
   end;
   vid_menu_redraw:=true;
end;

procedure _dedCode;
begin
   case G_Started of
false: if(PlayersReadyStatus)then
       begin
          vid_menu_redraw:=true;
          G_Started:=true;
          GameStartSkirmish;
       end;
true : if(PlayerAllOut)then
       begin
          G_Started:=false;
          PlayersSetDefault;
       end;
   end;
end;

procedure _screenLine(s1:shortstring;x1:byte;
                      s2:shortstring;x2:byte;
                      s3:shortstring;x3:byte;
                      s4:shortstring;x4:byte;
                      s5:shortstring;x5:byte;
                      s6:shortstring;x6:byte);
var s: shortstring;

procedure ss(sp:pshortstring;x:byte);
var i,t:byte;
begin
   i:=x+length(sp^);
   t:=length(s);
   if(i>t)then i:=t;
   t:=1;
   while(x<i)do
   begin
      s[x]:=sp^[t];
      x+=1;
      t+=1;
   end;
end;

begin
   s:='                                                                      ';
   if(x1>0)then ss(@s1,x1);
   if(x2>0)then ss(@s2,x2);
   if(x3>0)then ss(@s3,x3);
   if(x4>0)then ss(@s4,x4);
   if(x5>0)then ss(@s5,x5);
   if(x6>0)then ss(@s6,x6);
   writeln(s);
end;

procedure ps(p:byte);
begin
   if(p=0)
   then _screenLine(str_plname,1   , str_plstat,15, str_srace      ,25, str_team          ,35, '',0, '',0)
   else with _players[p] do
        if(state<>ps_none)
        then _screenLine(name      ,1   , PlayerGetStatus(p)  ,15, str_race[mrace],25, b2s(PlayerGetTeam(g_mode,p)),35, '',0, '',0)
        else _screenLine(name      ,1   , PlayerGetStatus(p)  ,15, '-----'        ,25, '-'                         ,35, '',0, '',0);
end;

function SVGameStatus:shortstring;
begin
   if(g_started=false)
   then SVGameStatus:=str_gnstarted
   else
     if(G_Status=0)
     then SVGameStatus:=str_grun
     else SVGameStatus:=str_gpaused+b2s(G_Status);
end;

procedure _dedScreen;
begin
   if(vid_menu_redraw)then
   begin
      clrscr;
      consoley:=0;
      vid_menu_redraw:=false;
   end;

   if(consoley<=fr_fps1)then
   begin
      case consoley of
      0 : writeln(str_wcaption,' ',str_cprt,str_udpport,net_port);
      1 : writeln(str_gstatus, SVGameStatus);
      2 : writeln(str_gsettings);
      4 : writeln('         ',str_gmodet     ,' ',str_gmode  [g_mode ] );
      6 : writeln('         ',str_fstarts    ,' ',g_fixed_positions    );
      8 : writeln('         ',str_starta     ,' ',str_startat[g_start_base]);
      9 : writeln('         ',str_aislots    ,' ',g_ai_slots           );
      10: writeln('         ',str_cgenerators,' ',str_cgeneratorsM[g_cgenerators]);
      11: writeln;
      12: _screenLine(str_map,1, str_m_seed   ,10, str_m_siz  ,25, str_m_liq       ,35, str_m_obs       ,45,str_m_sym        ,56);
      14: _screenLine(''     ,1, c2s(map_seed),10, i2s(map_mw),25, _str_mx(map_liq),35, _str_mx(map_obs),45,b2c[map_symmetry],56);
      15: writeln;
      16: ps(0);
      18: ps(1);
      20: ps(2);
      22: ps(3);
      24: ps(4);
      26: ps(5);
      28: ps(6);
      end;

      consoley+=1;
   end;
end;
