
procedure NewAI(r,t,a:byte);
var p:byte;
begin
   for p:=1 to MaxPlayers do
    with _Players[p] do
     if(state=ps_none)then
     begin
        if(g_mode in [gm_scir,gm_ct])then  team:=t;
        race:=r;
        mrace:=race;
        state:=ps_comp;
        ai_skill:=a;
        _playerSetState(p);
        break;
     end;
end;

procedure RemoveAI;
var p:byte;
begin
   for p:=1 to MaxPlayers do
    with _Players[p] do
    if(state=ps_comp)then
    begin
       state:=ps_none;
       _playerSetState(p);
    end;
end;

procedure cmp_ffa;
var i: byte;
begin
   for i:=1 to MaxPlayers do
    with _players[i] do
     if(state=ps_comp)then team:=i;
end;

procedure _parseCmd(msg:string;pl:byte);
var
    v      : shortstring;
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
   a :=0;
   l :=length(msg);
   while(l>0)do
   begin
      v:='';
      p:=pos(' ',msg);
      if(p>0)then
      begin
         v:=copy(msg,1,p-1);
         delete(msg,1,p);
         dec(l,p);
      end
      else
      begin
         v:=msg;
         delete(msg,1,l);
         dec(l,l);
      end;

      while (true) do
      begin
         p:=pos(' ',v);
         if(p=0)
         then break
         else delete(v,p,1);
      end;

      inc(a,1);
      setlength(args,a);
      args[a-1]:=v;
   end;

   if(a=0)then exit;

   case args[0] of
   '-h',
   '-help':
   begin
      net_chat_add('MarsWars dedicated server, '+str_ver  ,0,255);
      net_chat_add('New map: -m [seed size lakes obs]'    ,0,255);
      net_chat_add('Add AI player: -p [R/H/U team skill]' ,0,255);
      net_chat_add('Remove all AI players: -k or -noai'   ,0,255);
      net_chat_add('Set 1..6 teams to AI players: -ffa'   ,0,255);
      net_chat_add('Game moddes: -s - scirmish'           ,0,255);
      net_chat_add('  -f2/3- 2/3 fortress, -i - invasion' ,0,255);
      net_chat_add('  -c - capturing points, -a - assault',0,255);
      net_chat_add('  -ud/-d2 - UDOOM/DOOM 2 mode'        ,0,255);
      net_chat_add('Show/hide player starts: -ps'         ,0,255);
      net_chat_add('Starting base options: -st 1-6'       ,0,255);
      net_chat_add('Fill empty slots with AI: -fs 0-7'    ,0,255);
      exit;
   end;
   '-m'  : if(a<5)
           then begin Map_randommap; Map_premap;end
           else
           begin
              map_seed:=s2c(args[1]);
              map_mw  :=mm3(MinSMapW, (s2i(args[2]) div 500)*500, MaxSMapW);
              map_liq :=min2(7,s2b(args[3]));
              map_obs :=min2(7,s2b(args[4]));
              Map_premap;
           end;
   '-p'  : if(a<3)
           then with _players[pl] do NewAI(race,team,4)
           else NewAI(_a2r(args[1]), mm3(1,s2b(args[2]),MaxPlayers), mm3(1,s2b(args[3]),7));
   '-ffa': cmp_ffa;
   '-noai',
   '-k'  : RemoveAI;
   '-d2' : g_addon:=true;
   '-ud' : g_addon:=false;
   '-f2' : begin g_mode:=gm_2fort; Map_premap; end;
   '-f3' : begin g_mode:=gm_3fort; Map_premap; end;
   '-s'  : begin g_mode:=gm_scir;  Map_premap; cmp_ffa; end;
   '-i'  : begin g_mode:=gm_inv;   Map_premap; end;
   '-c'  : begin g_mode:=gm_ct;    Map_premap; cmp_ffa; end;
   '-a'  : begin g_mode:=gm_coop;  Map_premap; end;
   '-ps' : g_shpos:=not g_shpos;
   '-st' : if(a=2)then G_startb :=mm3(0,s2b(args[1])-1,5);
   '-fs' : if(a=2)then G_aislots:=mm3(0,s2b(args[1]),7);
   else exit;
   end;
   vid_mredraw:=true;
end;

procedure _dedCode;
begin
   if(G_Started=false)then
   begin
      if(_plsReady)then
      begin
         vid_mredraw:=true;
         G_Started:=true;
         _CreateStartPositionsSkirmish;
      end;
   end
   else
   begin
      if(_plsOut)then
      begin
         G_Started:=false;
         DefGameObjects;
      end;
   end;
end;

procedure _screenLine(s1:shortstring;x1:byte;
                      s2:shortstring;x2:byte;
                      s3:shortstring;x3:byte;
                      s4:shortstring;x4:byte;
                      s5:shortstring;x5:byte);
var s: shortstring;

procedure ss(sp:pshortstring;x:byte);
var i,t:byte;
begin
   i:=x+length(sp^);
   t:=length(s);
   if(i>t)then i:=t;
   t:=1;
   while (x<i) do
   begin
      s[x]:=sp^[t];
      inc(x,1);
      inc(t,1);
   end;
end;

begin
   s:='                                                                      ';
   if(x1>0)then ss(@s1,x1);
   if(x2>0)then ss(@s2,x2);
   if(x3>0)then ss(@s3,x3);
   if(x4>0)then ss(@s4,x4);
   if(x5>0)then ss(@s5,x5);
   writeln(s);
end;

procedure ps(p:byte);
begin
   if(p=0)
   then _screenLine(str_plname,1   , str_plstat,15, str_srace      ,25, str_team          ,35, '',0)
   else with _players[p] do
        if(state<>ps_none)
        then _screenLine(name      ,1   , _plst(p)  ,15, str_race[mrace],25, b2s(_PickPTeam(g_mode,p)),35, '',0)
        else _screenLine(name      ,1   , _plst(p)  ,15, '---',25, '-',35, '',0);
end;

function SVGameStatus:shortstring;
begin
   if(g_started=false)
   then SVGameStatus:='Not started'
   else
     if(G_Paused=0)
     then SVGameStatus:='Run'
     else SVGameStatus:='Paused by player #'+b2s(G_Paused);
end;

procedure _dedScreen;
begin
   if(vid_mredraw)then
   begin
      clrscr;
      consoley:=0;
      vid_mredraw := false;
   end;

   if(consoley<=fr_fps)then
   begin
      case consoley of
      0 : writeln(str_wcaption,' ',str_cprt,' UPD port: ',net_sv_port);
      1 : writeln('Game status: ', SVGameStatus);
      2 : writeln('Game settings:');
      3 : writeln('         ',str_gaddon  ,' ',str_addon[g_addon]);
      4 : writeln('         ',str_gmodet  ,' ',str_gmode[g_mode ]);
      6 : writeln('         ',str_sstarts ,' ',g_shpos);
      8 : writeln('         ',str_starta  ,' ',str_startat[g_startb]);
      10: writeln('         ',str_aislots ,' ',G_aislots);
      11: writeln;
      12: _screenLine('Map',1, str_m_seed   ,10, str_m_siz  ,25, str_m_liq   ,35, str_m_obs   ,45);
      14: _screenLine(''   ,1, c2s(map_seed),10, i2s(map_mw),25, _str_mx[map_liq],35, _str_mx[map_obs],45);
      15: writeln;
      16: ps(0);
      18: ps(1);
      20: ps(2);
      22: ps(3);
      24: ps(4);
      26: ps(5);
      28: ps(6);
      end;

      inc(consoley,1);
   end;
end;
