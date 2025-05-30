
procedure Dedicated_Init;
begin
   net_status:=ns_server;
   if(not net_UpSocket(net_port))then
   begin
      net_dispose;
      net_status:=ns_single;
      GameCycle :=false;
   end
   else PlayersSetDefault;

   screen_redraw:=true;
end;

procedure Dedicated_Code;
begin
   case G_Started of
false: ;
       {if(PlayersReadyStatus)then
       begin
          screen_redraw:=true;
          G_Started:=true;
          GameStartSkirmish;
       end;}
true : if(PlayerAllOut)then
       begin
          G_Started:=false;
          GameDefaultAll;
       end;
   end;
end;

procedure Dedicated_screenLine(s1:shortstring;x1:byte;
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
   then        Dedicated_screenLine(str_plname,1   , str_plstat          ,15, str_srace          ,25, str_team                    ,35, '',0, '',0)   // captions
   else with g_players[p] do
        if(player_type=pt_none)
        then   Dedicated_screenLine(name      ,1   , PlayerGetStatus(p)  ,15, '--'               ,25, ''                          ,35, '',0, '',0)
        else
          {if(team=0)
          then Dedicated_screenLine(name      ,1   , PlayerGetStatus(p)  ,15, str_observer        ,25, t2c(PlayerGetTeam(g_mode,p,255)),35, '',0, '',0)
          else Dedicated_screenLine(name      ,1   , PlayerGetStatus(p)  ,15, str_racel[slot_race],25, t2c(PlayerGetTeam(g_mode,p,255)),35, '',0, '',0); }
end;

function SVGameStatus:shortstring;
begin
   if(g_started)
   then SVGameStatus:=str_grun
   else SVGameStatus:=str_gnstarted;
   case G_status of
gs_running    : ;
0..LastPlayer : SVGameStatus:=str_gpaused+b2s(G_Status)
   else
     if(gs_win_team0<=G_status)and(G_status<=gs_win_team6)then SVGameStatus:=str_gwinner+b2s(G_Status-gs_win_team0);
   end;
end;

procedure Dedicated_Screen;
begin
   if(screen_redraw)then
   begin
      clrscr;
      consoley:=0;
      screen_redraw:=false;
   end;

   if(consoley<=fr_fps1)then
   begin
      case consoley of
      0 : writeln(str_wcaption,' ',str_cprt,str_udpport,net_port);
      2 : writeln(str_gstatus, SVGameStatus);
      4 : writeln(str_gpreset, g_presets[g_preset_cur].gp_name);
      6 : writeln(str_gsettings);
      8 : writeln('         ',str_gmode        ,str_gmodel[g_mode ]           );
      //10: writeln('         ',str_starta       ,b2s(g_start_base+1)           );
      12: writeln('         ',str_cgenerators  ,str_cgeneratorsl[g_generators]);
      14: writeln('         ',str_fstarts      ,str_b2c[g_fixed_positions]    );
      16: writeln('         ',str_deadobservers,str_b2c[g_deadobservers ]     );
      18: writeln('         ',str_aislots      ,g_ai_slots                    );
      20: writeln;
      22: Dedicated_screenLine(str_map,1, str_m_seed   ,10, str_m_siz     ,25, str_m_type           ,35, str_m_sym               ,45,'',56);
      24: Dedicated_screenLine(''     ,1, c2s(map_seed),10, i2s(map_psize),25, str_m_typel[map_type],35, str_m_syml[map_symmetry],45,'',56);
      26: writeln;
      28: ps(0);
      30: ps(1);
      32: ps(2);
      34: ps(3);
      36: ps(4);
      38: ps(5);
      40: ps(6);
      end;

      consoley+=1;
   end;
end;
