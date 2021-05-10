
procedure _swapPlayers(p0,p1:integer);
var tp:TPlayer;
begin
   if(_players[p0].state=ps_play)or(p1=p0)then exit;

   tp:=_players[p0];
   _players[p0]:=_players[p1];
   _players[p1]:=tp;

   if(HPlayer=p1)then HPlayer:=p0
   else
     if(HPlayer=p0)then HPlayer:=p1;
end;

procedure _playerSetState(p:integer);
begin
   with _players[p] do
   begin
      case state of
PS_None: begin ready:=false;name :=str_ps_none;end;
PS_Comp: begin ready:=true; name :=ai_name(ai_skill); ttl:=0;end;
PS_Play: begin ready:=false;name :=''; ttl:=0;end;
      end;
   end;
end;

procedure DefPlayers;
var p:byte;
begin
   FillChar(_players,SizeOf(TPList),0);
   for p:=0 to MaxPlayers do
    with _players[p] do
    begin
       ai_skill   := def_ai;
       race :=r_random;
       team :=p;
       state:=ps_none;
       _playerSetState(p);
       ready:=false;

       ai_pushpart := 2;
       ai_maxarmy  := 100;
       ai_attack   := 0;

       _bc_ss(@a_build,[0..11]);
       _bc_ss(@a_units,[0..18]);
       _bc_ss(@a_upgr ,[0..MaxUpgrs]);
   end;

   with _players[0] do
   begin
      race     :=r_hell;
      state    :=ps_comp;
      a_build  :=0;
      a_units  :=0;
      a_upgr   :=0;
      ai_attack:=2;
   end;

   {$IFDEF _FULLGAME}
   HPlayer:=1;
   with _players[1] do
   begin
      state:=ps_play;
      name :=PlayerName;
   end;

   plcolor[0]:=c_white;
   plcolor[1]:=c_red;
   plcolor[2]:=c_orange;
   plcolor[3]:=c_yellow;
   plcolor[4]:=c_lime;
   plcolor[5]:=c_aqua;
   plcolor[6]:=c_blue;

   {$ELSE}
   HPLayer:=0;
   with _players[0] do
   begin
      name :='SERVER';
   end;
   {$ENDIF}
end;

procedure DefGameObjects;
begin
   randomize;

   G_Step   :=0;
   G_Paused :=0;
   G_WTeam  :=255;
   //G_Mode   :=gm_scir;
   G_plstat :=255;

   onlySVCode :=true;

   FillChar(_missiles,SizeOf(_missiles)   ,0);

   FillChar(_units   ,SizeOf(_units  )   ,0);
   _lcu:=0;
   while(_lcu<MaxUnits)do
   begin
      inc(_lcu,1);
      _units[_lcu].hits:=dead_hits;
   end;

   FillChar(g_ct_pl  ,SizeOf(g_ct_pl),  0);

   DefPlayers;

   UnitStepNum:=8;

   _lcu :=0;
   _lcup:=@_units[0];
   _lsuc:=255;

   g_inv_wn     := 0;
   g_inv_t      := 0;
   g_inv_wt     := 0;

   _uclord_c    := 0;
   _uregen_c    := 0;

   vid_mredraw:=true;

   Map_premap;

   {$IFDEF _FULLGAME}
   _fsttime:=false;
   _warpten:=false;

   vid_vx:=-vid_panel;
   vid_vy:=0;
   _view_bounds;

   vid_rtui:=0;
   vid_vsls:=0;

   ui_tab :=0;

   FillChar(_effects ,SizeOf(_effects )   ,0);

   FillChar(ui_alrms,SizeOf(ui_alrms  )   ,0);

   net_m_error:='';

   _igchat:=false;
   net_chat_str:='';
   net_chat_clear;
   net_cl_svttl:=0;
   net_cl_svpl:=0;

   if(_rpls_rst>rpl_wunit)then _rpls_rst:=rpl_none;

   m_sxs:=-1;
   m_sbuild:=255;

   _fog    :=true;

   _svld_str:='';

   ui_umark_u:=0;
   ui_umark_t:=0;

   cmp_ait2p:=0;

   _rpls_pnu:=0;
   _rpls_vidm:=false;
   {$ELSE}
   {$ENDIF}
end;

{$IFDEF _FULLGAME}
{$include _replays.pas}

procedure _swAI(p:byte);
begin
   with _players[p] do
    if(state=PS_Comp)then
     begin
        inc(ai_skill,1);
        if(ai_skill>7)then ai_skill:=1;
        name:=ai_name(ai_skill);
     end;
end;

procedure _dmgtest;
var x,y,p:integer;
begin
   x:=100;
   y:=100;

   for p:=1 to 255 do
    if(p in [1..70,240..250])then
    begin
       if(_ulst[p].r>0)then
       begin
          _unit_add(x,y,p,0,true);
          with _lcup^ do
          begin
             mhits:=1000;
             hits :=mhits;
             solid:=false;
          end;
       end;
       inc(y,100);
       if(y>map_mw)then
       begin
          y:=100;
          inc(x,100);
       end;
    end;
end;

{$ENDIF}


procedure _CreateStartBase(x,y:integer;uid,pl,c:byte);
var i:byte;
r,d,xs,ys,
   ds:integer;
begin
   if(c=0)
   then _unit_add(x,y,uid,pl,true)
   else
   begin
      ds :=map_mw div 2;
      d  :=p_dir(x,y,ds,ds);
      ds :=360 div (c+1);
      r  :=50+c*18;
      for i:=0 to c do
      begin
         xs:=x+trunc(r*cos(d*degtorad));
         ys:=y-trunc(r*sin(d*degtorad));

         _unit_add(xs,ys,uid,pl,true);

         inc(d,ds);
      end;
   end;
end;



procedure _CreateStartPositionsSkirmish;
var p:byte;
begin
   GModeTeams(g_mode);
   case g_mode of
gm_inv:
     with _players[0] do
     begin
        _upgr_ss(@upgr ,[0..20],r_hell,1);
        ai_skill:=6;
     end;
gm_royl:g_royal_r   := trunc(sqrt( sqr(map_cx)*2 ));
   end;

   for p:=1 to MaxPlayers do
    with _players[p] do
    begin
       if(state=ps_none)then
        if(G_aislots>0)then
        begin
           state   :=ps_comp;
           ai_skill:=G_aislots;
           race    :=r_random;
           _playerSetState(p);
        end;

       if(race=r_random)then race:=1+random(2);

       if(state<>PS_None)then
       begin
          _CreateStartBase(map_psx[p],map_psy[p],cl2uid[race,true,0],p,G_startb);

          if(state=ps_play)then ai_skill:=def_ai;
          _setAI(p);
       end;
    end;

   {$IFDEF _FULLGAME}
   if(_testdmg)then _dmgtest;

   _moveHumView(map_psx[HPlayer] , map_psy[HPlayer]);
   {$ENDIF}
end;



{$IFDEF _FULLGAME}
procedure _StartGame;
begin
   _m_sel:=0;
   if(G_Started)then
   begin
      G_Started:=false;
      DefGameObjects;
   end
   else
    if(_plsReady)then
    begin
       G_Started:=true;
       _menu    :=false;
       if(menu_s2<>ms2_camp)
       then _CreateStartPositionsSkirmish
       else _CMPMap;
       vid_rtui:=2;
       _makeMMB;
       sdl_FillRect(_minimap,nil,0);
       D_ui;
    end;
end;

procedure MakeRandomSkirmish(st:boolean);
var p:byte;
begin
   Map_randommap;

   G_mode   :=gm_scir;
   G_startb :=random(6);
   g_addon  :=random(3)<>0;

   _swapPlayers(1,HPlayer);

   for p:=2 to MaxPlayers do
    with _players[p] do
    begin
       race :=random(3);
       mrace:=race;

       if(p=4)
       then team :=1+random(4)
       else team :=2+random(3);

       ai_skill:=random(4)+2;

       if(random(2)=0)and(p>2)
       then state:=ps_none
       else state:=ps_comp;
       _playerSetState(p);
    end;

   _swapPlayers(random(6)+1,HPlayer);

   G_aislots:=random(5);

   Map_premap;

   if(st)then _StartGame;
end;
{$ELSE}
{$include _ded.pas}
{$ENDIF}

procedure _u_ord(pl:byte);
var u,_u,scnt,scntm:integer;
 psel:boolean;
begin
   with _players[pl] do
   if(o_id>0)and(army>0)then
   begin
      case o_id of
uo_build   : _unit_startb(o_x0,o_y0,o_x1,pl);
      else
         scnt :=0;
         scntm:=100;
         if(o_id in [uo_select,uo_aselect])then
         begin
            if(o_x0>o_x1)then begin u:=o_x1;o_x1:=o_x0;o_x0:=u;end;
            if(o_y0>o_y1)then begin u:=o_y1;o_y1:=o_y0;o_y0:=u;end;
            if(dist2(o_x0,o_y0,o_x1,o_y1)<4)then scntm:=1;
         end;

         u :=1;
         _u:=MaxUnits;
         if(o_id=uo_action)then
          case o_x0 of
          -3,
          -5: begin
                 u :=MaxUnits;
                 _u:=1;
              end;
          end;

         while (u<>_u) do
         begin
            with _units[u] do
             if(hits>0)and(inapc=0)and(pl=player)then
             begin
                psel:=sel;
                if(o_id=uo_select)or((o_id=uo_aselect)and(not sel))then
                begin
                   sel:=((o_x0-r)<=vx)and(vx<=(o_x1+r))and((o_y0-r)<=vy)and(vy<=(o_y1+r));
                   if(speed=0)and(scntm>1)and(o_id<>uo_aselect)then sel:=false;
                   if(scnt>=scntm)then sel:=false;
                end;
                if(o_id=uo_selorder)and((o_y0=0)or(not sel))then sel:=(order=o_x0);

                if(o_id=uo_dblselect)or((o_id=uo_adblselect)and(not sel))then
                 if(_lsuc=uid)then
                  sel:=((o_x0-r)<=vx)and(vx<=(o_x1+r))and((o_y0-r)<=vy)and(vy<=(o_y1+r));

                if(o_id=uo_specsel)then
                 case o_x0 of
                    0 : if(speed>0)and(uid in whocanattack)then sel:=true else if(o_y0=0)then sel:=false;
                 else
                    if(o_x0 in _sbs_ucls)then
                     if(ubx[o_x0]=u)then sel:=true else if(o_y0=0)then sel:=false;
                 end;

                if(o_id=uo_action)then
                 case o_x0 of
                 -2 : if(rld=0)and(ucl=3)and(isbuild)and(bld)then
                       if(u_s[true,3]=0)then                      // start upgr
                       begin
                          _unit_supgrade(u,o_y0);
                          break;
                       end;
                 -3 : if(rld>0)and(ucl=3)and(isbuild)and(bld)then
                       if(utrain=o_y0)or(o_y0=-1)then
                        if(u_s[true,3]=0)then                     // cancle upgr
                        begin
                           _unit_cupgrade(u);
                           break;
                        end;
                 -4 : if(rld=0)and(ucl=1)and(isbuild)and(bld)then
                       if(u_s[true,1]=0)then                      // start training
                       begin
                          _unit_straining(u,o_y0);
                          break;
                       end;
                 -5 : if(rld>0)and(ucl=1)and(isbuild)and(bld)then
                       if(utrain=o_y0)or(o_y0=-1)then
                        if(u_s[true,1]=0)then                     // cancle training
                        begin
                           _unit_ctraining(u);
                           break;
                        end;
                 end;

                if(sel)then
                begin
                   case o_id of
               uo_select     : _lsuc:=uid;
               uo_setorder,
               uo_addorder   : order:=o_x0;
               uo_delete     : _unit_kill(u,false,o_x0>0);
               uo_move       : begin
                                  uo_x :=o_x0;
                                  uo_y :=o_y0;
                                  uo_bx:=-1;

                                  case uid of
                                   UID_HKeep      : _unit_bteleport(u);
                                   UID_URadar     : _unit_uradar(u);
                                   UID_URocketL   : _unit_URocketL(u);
                                   UID_HMonastery,
                                   UID_HGate,
                                   UID_UMilitaryUnit,
                                   UID_HMilitaryUnit : if(o_y1<>u)then uo_tar:=o_y1;
                                   UID_HSymbol,
                                   UID_HTower,
                                   UID_HTotem     : begin
                                                       if(o_y1<>u)and(o_y1<>0)
                                                       then uo_tar:=o_y1
                                                       else _unit_b247teleport(u);
                                                    end;
                                   else
                                     if(o_y1<>u)then uo_tar:=o_y1;
                                     if(o_x1>0)or(speed=0)
                                     then uo_id:=ua_amove
                                     else
                                     begin
                                        uo_id:=ua_move;
                                        tar1 :=0;
                                     end;
                                     _unit_turn(u);
                                  end;
                               end;
               uo_paction    : if(speed>0)and(uo_id<>ua_paction)then
                               begin
                                  uo_x  :=o_x0;
                                  uo_y  :=o_y0;
                                  uo_bx :=-1;
                                  uo_tar:=0;
                                  uo_id :=ua_paction;
                                  _unit_turn(u);
                                  break;
                               end;
               uo_action     : case o_x0 of
                                  2 : if(speed>0)then
                                      begin
                                         case o_y0 of
                                         0,1:
                                         begin
                                            uo_x  :=x;
                                            uo_y  :=y;
                                            uo_bx :=-1;
                                            tar1  :=0;
                                            uo_tar:=0;
                                         end;
                                         -4..-1:
                                         begin
                                            uo_x  :=o_x1;
                                            uo_y  :=o_y1;
                                            uo_bx :=-1;
                                            uo_tar:=0;
                                            _unit_turn(u);
                                            case o_y0 of
                                            -2,-4: begin
                                                      uo_bx:=x;
                                                      uo_by:=y;
                                                   end;
                                            end;
                                         end;
                                         end;
                                         case o_y0 of
                                         0       : uo_id:=ua_hold;
                                         -1,-2   : begin
                                                   uo_id:=ua_move;
                                                   tar1 :=0;
                                                   end;
                                         1,-3,-4 : uo_id:=ua_amove;
                                         end;
                                      end;
                                  1 : _unit_action(u);
                                 -2 : _unit_supgrade(u,o_y0);
                                 -3 : if(utrain=o_y0)or(o_y0=-1)then _unit_cupgrade(u);
                                 -4 : _unit_straining(u,o_y0);
                                 -5 : if(utrain=o_y0)or(o_y0=-1)then _unit_ctraining(u);
                                 -6 : case ucl of
                                      1: _unit_ctraining(u);
                                      3: _unit_cupgrade(u);
                                      end;
                               end;
                   end;

                   if(psel=false)then
                   begin
                      inc(u_s [isbuild,ucl],1);
                      inc(u_cs[isbuild],1);
                   end;
                   inc(scnt,1);
                end
                else
                begin
                   if(psel=true)then
                   begin
                      dec(u_s [isbuild,ucl],1);
                      dec(u_cs[isbuild],1);
                   end;
                   if(o_id=uo_setorder)and(order=o_x0)then order:=0;
                end;
             end;

            if(u>_u)
            then dec(u,1)
            else inc(u,1);
         end;

         if(o_id in [uo_select,uo_aselect])then
          if(scnt=0)then _lsuc:=255;
      end;

      o_id:=0;
   end;
end;

procedure PlayersCycle;
var p:byte;
begin
   for p:=0 to MaxPlayers do
    with _players[p] do
     if(state>ps_none)then
     begin
        if(state=PS_Play)and(p<>HPlayer)and(net_nstat=ns_srvr)then
        begin
           if (ttl<ClientTTL)then
           begin
              Inc(ttl,1);
              if(ttl=ClientTTL)or(ttl=vid_fps)then vid_mredraw:=true;
           end
           else
             if(G_Started=false)then
             begin
                state:=PS_None;
                _playerSetState(p);
                vid_mredraw:=true;
             end;
        end;

        if(G_Started)and(G_Paused=0)and(onlySVCode)then
        begin
           _u_ord(p);

           if(bld_r>0)then dec(bld_r,1);
        end;
     end;

   if(G_Started)and(G_Paused=0)and(onlySVCode)then
   begin
      if(net_nstat>ns_none)and(G_Step<60)then exit;

      G_plstat:=0;
      for p:=0 to MaxPlayers do
       with _players[p] do
        if(army>0)and(state>ps_none)then G_plstat:=G_plstat or (1 shl p);

      if(G_WTeam=255)then
      begin
         FillChar(team_army,SizeOf(team_army),0);
         G_WTeam:=255;
         for p:=0 to MaxPlayers do
          with _players[p] do
           if(state>ps_none)then inc(team_army[team],army);

         {$IFDEF _FULLGAME}
         if(menu_s2=ms2_camp)
         then cmp_code
         else
         {$ENDIF}
           if(g_mode<>gm_inv)then
            for p:=0 to MaxPlayers do
             if(team_army[p]>0)then
              if(G_WTeam<255)then
              begin
                 G_WTeam:=255;
                 break;
              end
              else G_WTeam:=p;
      end
      else
      begin
         G_Paused:=1;
         {$IFDEF _FULLGAME}
         _draw:=true;
         {$ENDIF}
      end;
   end;
end;

procedure g_inv_calcmm;
const min_wave_time = vid_fps*15;
var a,i:integer;
begin
   case g_inv_wn of
   1  : g_inv_t:=vid_fps*90;
   else g_inv_t:=g_inv_wt;
   end;

   a:=0;
   for i:=1 to MaxPlayers do
    with _players[i] do
    if(state=ps_play)and(army>0)then inc(a,u_c[false]);

   dec(g_inv_t, g_inv_wn*vid_fps*2);
   dec(g_inv_t,(a div 10)*vid_fps);
   dec(g_inv_t, ((map_mw-MaxSMapW) div 100)*vid_fps);
   dec(g_inv_t, g_startb*15*vid_fps);

   if(g_inv_t<min_wave_time)then g_inv_t:=min_wave_time;

   g_inv_wt:=0;

   case g_inv_wn of
   1  : g_inv_mn:=30+15*g_startb;
   2  : g_inv_mn:=60+15*g_startb;
   3  : g_inv_mn:=90+15*g_startb;
   else g_inv_mn:=MaxPlayerUnits;
   end;
end;

procedure g_inv_spawn;
const max_wave_time = vid_fps*150;
var i,tx,ty,j:integer;
  mon:byte;
begin
   if(G_WTeam=255)then
   if(_players[0].army=0)then
   begin
      if(g_inv_t=0)then
      begin
         if(g_inv_wn=20)
         then G_WTeam:=1
         else
         begin
            inc(g_inv_wn,1);
            g_inv_calcmm;
         end;
      end
      else
      begin
         dec(g_inv_t,1);
         if(g_inv_t=0)then
         begin
            {$IFDEF _FULLGAME}
            PlaySND(snd_teleport,0);
            {$ENDIF}
            j:=(g_inv_wn*2)+(g_startb*2)+(map_mw div 400);
            for i:=1 to g_inv_mn do
            begin
               mon:=UID_CacoDemon;
               case g_inv_wn of
               1 : mon:=UID_ZFormer;
               2 : case i of
                   1..2: mon:=UID_Baron
                   else
                       case i mod 2 of
                       0 : mon:=UID_ZFormer;
                       1 : mon:=UID_ZSergant;
                       end;
                   end;
               3 : case i of
                   1   : mon:=UID_Cyberdemon;
                   2..8: mon:=UID_Baron
                   else
                       case i mod 7 of
                       0 : mon:=UID_ZFormer;
                       1 : mon:=UID_ZSergant;
                       2 : mon:=UID_ZCommando;
                       3 : mon:=UID_ZBomber;
                       4 : mon:=UID_ZMajor;
                       5 : mon:=UID_ZBFG;
                       end;
                   end;
               4 : case i of
                   1..3 : mon:=UID_Cyberdemon;
                   4..15: mon:=UID_Baron
                   else
                       case i mod 7 of
                       0 : mon:=UID_ZFormer;
                       1 : mon:=UID_ZSergant;
                       2 : mon:=UID_ZCommando;
                       3 : mon:=UID_ZBomber;
                       4 : mon:=UID_ZMajor;
                       5 : mon:=UID_ZBFG;
                       end;
                   end;
               5 : case i of
                   1..4 : mon:=UID_Cyberdemon;
                   5..20: mon:=UID_Baron;
                   else
                       case i mod 7 of
                       0 : mon:=UID_ZFormer;
                       1 : mon:=UID_ZSergant;
                       2 : mon:=UID_ZCommando;
                       3 : mon:=UID_ZBomber;
                       4 : mon:=UID_ZMajor;
                       5 : mon:=UID_ZBFG;
                       end;
                   end;
               6 : mon:=UID_Demon;
               7 : case i of
                   1..4 : mon:=UID_Cyberdemon;
                   5..20: mon:=UID_Baron;
                   else
                       mon:=UID_Cacodemon;
                   end;
               else
                  if(i<j)then
                    case i mod 3 of
                    0: mon:=UID_Cyberdemon;
                    1: mon:=UID_Mastermind;
                    2: mon:=UID_Cyberdemon;
                    end
                  else
                    case i mod g_inv_wn of
                    0 : mon:=UID_ZFormer;
                    1 : mon:=UID_ZSergant;
                    2 : mon:=UID_ZCommando;
                    3 : mon:=UID_ZBomber;
                    4 : mon:=UID_ZMajor;
                    5 : mon:=UID_ZBFG;
                    6 : mon:=UID_Imp;
                    7 : mon:=UID_Revenant;
                    8 : mon:=UID_Demon;
                    9 : mon:=UID_Commando;
                    10: mon:=UID_Terminator;
                    11: mon:=UID_Flyer;
                    12: mon:=UID_Arachnotron;
                    13: mon:=UID_Mancubus;
                    14: mon:=UID_Archvile;
                    15: mon:=UID_ZCommando;
                    16: mon:=UID_ZBomber;
                    17: mon:=UID_ZMajor;
                    18: mon:=UID_Pain;
                    else
                        mon:=UID_Baron;
                    end;
               end;

               if(random(2)=0)then
               begin
                  if(random(2)=0)
                  then tx:=map_mw
                  else tx:=0;
                  ty:=random(map_mw);
               end
               else
               begin
                  if(random(2)=0)
                  then ty:=map_mw
                  else ty:=0;
                  tx:=random(map_mw);
               end;

               _unit_add(tx,ty,mon,0,true);
               with _lcup^ do
               begin
                  {$IFDEF _FULLGAME}
                  _effect_add(vx,vy,vy+map_flydpth[uf]+1,EID_Teleport);
                  {$ENDIF}
                  if(g_inv_wn>8)then
                  begin
                     if((i mod 10)=0)then buff[ub_invis ]:=_bufinf;
                     if((i mod 9 )=0)then buff[ub_detect]:=_bufinf;
                  end;
                  buff[ub_advanced ]:=_bufinf;
                  painc:=5*g_inv_wn;
                  order:=2;
               end;
            end;
         end;
      end;
   end
   else if(g_inv_wt<max_wave_time)then inc(g_inv_wt,1);
end;

procedure _CPoints;
var i,t,e:integer;
begin
   e:=0;
   t:=0;
   for i:=1 to MaxPlayers do
    with g_ct_pl[i] do
    begin
       if(ct>0)then dec(ct,1);
       if(t=0)or(t<>_players[pl].team)then
       begin
          t:=_players[pl].team;
          e:=1;
       end
       else inc(e,1);
    end;

   if(e=MaxPlayers)and(G_WTeam=255)then
   begin
      G_WTeam:=t;
      for i:=1 to MaxUnits do
       with _units[i] do
        if(hits>0)and(inapc=0)then
         with _players[player] do
          if(team<>t)then _unit_kill(i,false,false);
   end;
end;

{$include _net_game.pas}

procedure CodeGame;
begin
   {$IFDEF _FULLGAME}
   inc(vid_rtui,1);
   vid_rtui:=vid_rtui mod vid_rtuis;

   if(vid_rtui=0)then _MusicCheck;

   if(net_nstat=ns_clnt)then net_GClient;
   _rpls_code;

   {$ELSE}
   _dedCode;
   _dedScreen;
   {$ENDIF}

   PlayersCycle;

   if(G_Started)then
   begin
      if(G_paused=0)then
      begin
         {$IFDEF _FULLGAME}
         FillChar(ui_bldrs_x,SizeOf(ui_bldrs_x),0);
         FillChar(ui_trnt   ,SizeOf(ui_trnt   ),0);
         FillChar(ui_trntc  ,SizeOf(ui_trntc  ),0);
         ui_bldsc    :=0;
         ui_uiaction :=0;
         ui_uselected:=0;
         ui_uimove   :=0;
         ui_upgrc    :=0;
         ui_upgrl    :=0;
         ui_trntca   :=0;
         ui_batlu    :=0;
         FillChar(ui_orderu ,SizeOf(ui_orderu ),0);
         FillChar(ui_upgrct ,SizeOf(ui_upgrct ),0);
         FillChar(ui_upgr   ,SizeOf(ui_upgr   ),0);
         FillChar(ui_apc    ,SizeOf(ui_apc    ),0);
         FillChar(ui_blds   ,SizeOf(ui_blds   ),0);
         FillChar(ordn      ,SizeOf(ordn      ),0);
         FillChar(ordx      ,SizeOf(ordx      ),0);
         FillChar(ordy      ,SizeOf(ordy      ),0);
         if(ui_umark_t>0)then begin dec(ui_umark_t,1);if(ui_umark_t=0)then ui_umark_u:=0;end;
         {$ENDIF}
         inc(_uclord_c,1); _uclord_c:=_uclord_c mod _uclord_p;
         inc(_uregen_c,1); _uregen_c:=_uregen_c mod regen_per;

         if(_uclord_c=0)then
          if(g_royal_r>0)then dec(g_royal_r,1);

         if(onlySVCode)then
         begin
            inc(G_Step,1);
            if(g_mode=gm_ct )then _CPoints;
            if(g_mode=gm_inv)then g_inv_spawn;
         end;
      end;

      _obj_cycle(G_Paused>0);
   end;

   if(net_nstat=ns_srvr)then net_GServer;
end;


