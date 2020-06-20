
{$IFNDEF _FULLGAME}

procedure NewAI(r,t,a:byte;slot:byte=0);
var p:byte;
begin
   if(0=t)or(t>MaxPlayers)then exit;

   if(slot=0)then
    for p:=1 to MaxPlayers do
     with _Players[p] do
      if(state=ps_none)then
      begin
         slot:=p;
         break;
      end;

   if(0<slot)and(slot<=MaxPlayers)then
    with _Players[slot] do
    begin
       team:=t;
       race:=r;
       state:=ps_comp;
       if(a in [1..6])
       then ai_skill:=a
       else ai_skill:=def_ai;
       _playerSetState(slot);
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

procedure cmd_ffa;
var p:byte;
begin
   for p:=1 to MaxPlayers do
    with _players[p] do
     if(state=ps_comp)then team:=p;
end;

{function _chcomm(ps:pshortstring;ss:shortstring):boolean;
begin
   _chcomm:=false;
   if(pos(ss,ps^)=1)then
   begin
      delete(ps^,1,length(ss));
      _chcomm:=true;
   end;
end;}

procedure _parseCmd(pl:byte);
var m,v,com:string;
l,p,a:byte;
args:array of shortstring;
begin
   m:=_players[pl].chatm[0];
   if(length(m)=0)
   then exit
   else
     if not(m[1] in k_kbstr)then delete(m,1,1);

   setlength(args,0);
   a :=0;
   l :=length(m);
   while(l>0)do
   begin
      v:='';
      p:=pos(' ',m);
      if(p>0)then
      begin
         v:=copy(m,1,p-1);
         delete(m,1,p);
         dec(l,p);
      end
      else
      begin
         v:=m;
         delete(m,1,l);
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
         net_chat_add('MarsWars dedicated server, v'+str_ver,0,255);
         net_chat_add('New map: -m seed size lakes obstacles' ,0,255);
         net_chat_add('Game mode: -s -scrimish, -f2 -2 bases',0,255);
         net_chat_add('-f3 - 3 bases',0,255);
         net_chat_add('Add AI: -ai slot(1-6,0-any) skill(1-6)',0,255);
         net_chat_add('team(1-6) race(r/h/u)',0,255);
         net_chat_add('Remove all AI players: -noai',0,255);
         net_chat_add('Fill free slots: -fai x(0-no,1-6)',0,255);
      end;
   '-m':
      if(a<5)then
      begin
         Map_randommap;
         Map_premap;
      end
      else
      begin
         map_seed:= s2c(args[1]);
         map_mw  :=(s2w(args[2]) div 500)*500;
         map_liq := s2b(args[3]);
         map_obs := s2b(args[4]);
         Map_premap;
      end;
   '-s':
      begin
         g_mode:=gm_scir;
         cmd_ffa;
         Map_premap;
      end;
   '-f2':
      begin
         g_mode:=gm_tdm2;
         Map_premap;
      end;
   '-f3':
      begin
         g_mode:=gm_tdm3;
         Map_premap;
      end;
   '-noai': RemoveAI;
   '-ai':
      if(a<5)
      then with _players[pl] do  NewAI(race,team,def_ai)
      else
      begin
         p:=r_random;
         case Lowercase(args[4]) of
         '0','r','random': p:=r_random;
         '1','h','hell'  : p:=r_hell;
         '2','u','uac'   : p:=r_uac;
         end;
         NewAI(p,s2b(args[3]),s2b(args[2]),s2b(args[1]));
      end;
   '-fai':
      if(a>1)then
      begin
         G_aislots:=s2b(args[1]);
         if(G_aislots>6)then G_aislots:=6;
         writeln(G_aislots);
      end;
   '-ffa': cmd_ffa;
   end;
end;

{$ENDIF}

function NewP(sip:cardinal;sp:word):byte;
var i:byte;
begin
   NewP:=0;
   for i:=1 to MaxPlayers do
    if(i<>HPlayer)then
     with _Players[i] do
      if(state=PS_None)then
      begin
         nip   := sip;
         nport := sp;
         NewP  := i;
         state := PS_Play;
         ttl   := 0;
         vid_mredraw:=true;
         break;
      end;
end;

function A2P(sip:cardinal;sp:word;newplayer:boolean):byte;
var i:byte;
begin
   A2P:=0;
   for i:=1 to MaxPlayers do
    if(i<>HPlayer)then
     with _Players[i] do
      if(state=PS_Play)and(nip=sip)and(nport=sp)then
      begin A2P:=i; ttl:=0; break;end;

   if(A2P=0)and(G_Started=false)and(newplayer)then A2P:=NewP(sip,sp);
end;

procedure _svReadClInfo(pid:byte);
var iname: string;
    iteam,
    irace: byte;
    iredy: boolean;
begin
   with _Players[pid] do
   begin
      iname :=net_readstring;
      iteam :=net_readbyte;
      irace :=net_readbyte;
      iredy :=net_readbool;
      chatc :=net_readbyte;
      PNU   :=net_readbyte;

      mrace:=race;

      if(iname<>name)
      or(iteam<>team)
      or(irace<>race)
      or(iredy<>ready)
      then vid_mredraw:=true;

      name  :=iname;
      if(g_mode in [gm_scir])then team:=iteam;
      race  :=irace;
      ready :=iredy;
   end;
end;

procedure net_GServer;
var mid,pid,i:byte;
begin
   net_clearbuffer;

   while(net_Receive>0)do
   begin
      mid:=net_readbyte;

      case mid of
nmid_getinfo :
      begin
         net_clearbuffer;
         net_writebyte(nmid_getinfo);
         net_writebyte(ver);
         net_writebool(g_started);
         net_writebyte(g_mode);
         for i:=1 to MaxPlayers do
          with _players[i] do
          begin
             net_writestring(name);
             net_writebyte(race);
             net_writebyte(team);
          end;
         net_send(net_lastinip,net_lastinport);
      end;
nmid_connect:
      begin
         i:=net_readbyte;
         if(i<>ver)then
         begin
            net_clearbuffer;
            net_writebyte(nmid_sver);
            net_send(net_lastinip,net_lastinport);
            continue;
         end;
         pid:=A2P(net_lastinip,net_lastinport,true);
         if(pid=0) then
         begin
            net_clearbuffer;
            if(g_started)
            then net_writebyte(nmid_sgst)
            else net_writebyte(nmid_sfull);
            net_send(net_lastinip,net_lastinport);
            continue;
         end;

         if(G_Started=false)then _svReadClInfo(pid);

         net_clearbuffer;
         net_writebyte(nmid_startinf);
         net_writebool(G_Started);
         for i:=1 to MaxPlayers do
          with _Players[i] do
          begin
             net_writebyte  (state);
             if(state<>PS_None)then
             begin
                net_writestring(name);
                net_writebyte  (team);
                net_writebyte  (race);
                net_writebool  (ready);
                net_writeint   (ttl);
             end;
          end;

         net_writebyte(pid);
         net_writebyte(HPlayer);

         net_writecard(map_seed);
         net_writeint (map_mw);
         net_writebyte(map_liq);
         net_writebyte(map_obs);
         net_writebyte(g_mode);
         net_writebyte(g_aislots);

         net_send(net_lastinip,net_lastinport);
      end;
      else
         pid:=A2P(net_lastinip,net_lastinport,false);
         if(pid>0)then
         begin
            if(mid=nmid_plout)then
            begin
               net_chat_add(_players[pid].name+str_plout,255,0);
               if(G_Started=false)then _players[pid].state:=ps_none;
               continue;
            end;

            if(mid=nmid_chat)then
            begin
               i:=net_readbyte;
               net_chat_add(net_readstring,pid,i);
               {$IFNDEF _FULLGAME}
               if(G_Started=false)then _parseCmd(pid);
               {$ENDIF}
            end;

            if(G_Started)then
            begin
               if(mid=nmid_order)then
                with _players[pid]do
                begin
                   o_x0:=net_readint;
                   o_y0:=net_readint;
                   o_x1:=net_readint;
                   o_y1:=net_readint;
                   o_id:=net_readbyte;
                end;

               if(mid=nmid_clinf) then
                with _players[pid] do
                begin
                   PNU    :=net_readbyte;
                   rghtatt:=net_readbool;
                   chatc  :=net_readbyte;
                   {if(i<>chats)then
                   begin
                      net_clearbuffer;
                      net_writebyte(nmid_clchup);
                      net_writebyte(chats);
                      net_writechat(pid);
                      net_send(nip,nport);
                   end;}
                end;

               if(mid=nmid_pause)then
                if(G_Status<=MaxPlayers)then
                begin
                   if(G_Status=pid)
                   then G_Status:=0
                   else
                     if(G_Status<>HPlayer)or(G_Status=0)then G_Status:=pid;
                   {$IFNDEF _FULLGAME}
                   vid_mredraw:=true;
                   {$ENDIF}
                end;
            end
            else
            begin
               if(mid=nmid_swapp)then
               begin
                  i:=net_readbyte;
                  _swapPlayers(i,pid);
                  vid_mredraw:=true;
               end;
            end;
         end
         else
         begin
            net_clearbuffer;
            net_writebyte(nmid_ncon);
            net_send(net_lastinip,net_lastinport);
         end;
      end;
   end;

   for i:=1 to MaxPlayers do
    if(i<>HPlayer)then
     with _players[i] do
      if(state=PS_Play)and(ttl<ClientTTL)then
      begin
         if(G_Started)and((net_period mod NetTickN)=0)then
         begin
            net_clearbuffer;
            net_writebyte(nmid_shap);
            net_writebyte(G_Status);
            if(G_Status=0)then _wclinet_gframe(i,false);
            net_send(nip,nport);
         end;

         if(i=net_period)then
          if(chatc<>chats)then
          begin
             net_clearbuffer;
             net_writebyte(nmid_clchup);
             net_writebyte(chats);
             net_writechat(i);
             net_send(nip,nport);
          end;
      end;

   inc(net_period,1);
   net_period:=net_period mod vid_h2fps;
end;

{$IFDEF _FULLGAME}

procedure net_readmap;
var
    map_imw   : integer;
    g_imode,
    map_iliq,
    map_iobs  : byte;
    map_iseed : word;
begin
   map_imw   := map_mw;
   map_iliq  := map_liq;
   map_iobs  := map_obs;
   map_iseed := map_seed;
   g_imode   := g_mode;

   map_seed := net_readcard;
   map_mw   := net_readint;
   map_liq  := net_readbyte;
   map_obs  := net_readbyte;
   g_mode   := net_readbyte;
   g_aislots:= net_readbyte;

   if(map_imw  <>map_mw)
   or(map_iliq <>map_liq)
   or(map_iobs <>map_obs)
   or(map_iseed<>map_seed)
   or(g_imode  <>g_mode)
   then Map_premap;
end;

procedure net_GClient;
var mid,i:byte;
    gst:boolean;
begin
   net_clearbuffer;
   while(net_Receive>0)do
   if(net_lastinip=net_cl_svip)and(net_lastinport=net_cl_svport)then
   begin
      net_cl_svttl:=0;
      mid:=net_readbyte;//

      case mid of
nmid_sfull:
        begin
           net_m_error:=str_sfull;
           vid_mredraw:=true;
        end;
nmid_sver:
        begin
           net_m_error:=str_sver;
           vid_mredraw:=true;
        end;
nmid_sgst:
        begin
           net_m_error:=str_sgst;
           vid_mredraw:=true;
        end;
nmid_ncon:
        begin
           G_Started:=false;
           _menu:=true;
           PlayerReady:=false;
           DefGameObjects;
        end;
nmid_clchup:
        begin
           i:=net_readbyte;
           if(net_clchats<>i)then
           begin
              PlayGSND(snd_chat);
              _rpls_nwrch:=true;
              ui_chat_shlm:=chat_shlm_t;
           end;
           net_clchats:=i;
           net_readchat;
           vid_mredraw:=true;
        end;
nmid_startinf:
        begin
           gst:=net_readbool;

           for i:=1 to MaxPlayers do
            with _Players[i] do
            begin
               state:= net_readbyte;
               if(state<>PS_None)then
               begin
                  name := net_readstring;
                  team := net_readbyte;
                  race := net_readbyte;
                  ready:= net_readbool;
                  ttl  := net_readint;
                  if(gst=false)then mrace:=race;
               end;
            end;

           HPlayer    :=net_readbyte;
           net_cl_svpl:=net_readbyte;

           net_readmap;

           net_m_error:='';
           vid_mredraw:=true;

           if(gst<>G_Started)then
           begin
              G_Started:=gst;
              if(G_Started)then
              begin
                 _menu:=false;
                 onlySVCode:=false;
                 ui_chat_shlm:=0;
                 _moveHumView(map_psx[HPlayer] , map_psy[HPlayer]);
                 _draw_surf(spr_mback,ui_mmmpx,ui_mmmpy,ui_tminimap);
              end
              else
              begin
                 _menu:=true;
                 PlayerReady:=false;
                 DefGameObjects;
              end;
           end;
        end;
      end;

      if(G_Started)then
      begin
         if(mid=nmid_shap)then
         begin
            G_Status:=net_readbyte;
            if(G_Status=0)then _rclinet_gframe(HPlayer,false);
         end;
      end;
   end;

   if(net_period=0)then
   begin
      net_clearbuffer;
      if (G_Started=false) then
      begin
         net_writebyte  (nmid_connect);
         net_writebyte  (ver);
         net_writestring(PlayerName );
         net_writebyte  (PlayerTeam );
         net_writebyte  (PlayerRace );
         net_writebool  (PlayerReady);
         net_writebyte  (net_clchats);
         net_writebyte  (_cl_pnua[net_pnui]);
      end
      else
      begin
         net_writebyte(nmid_clinf);
         net_writebyte(_cl_pnua[net_pnui]);
         net_writebool(m_a_inv);
         net_writebyte(net_clchats);
      end;
      net_send(net_cl_svip,net_cl_svport);
   end;

   inc(net_period,1);
   net_period:=net_period mod vid_h2fps;
   if(net_cl_svttl<ClientTTL)then
   begin
      inc(net_cl_svttl,1);
      if(net_cl_svttl=vid_fps)then vid_mredraw:=true;
      if(net_cl_svttl=ClientTTL)then G_Status:=19;
   end;
end;

{$ENDIF}

