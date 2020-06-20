
procedure _playerSetState(p:integer);
begin
   with _players[p] do
   begin
      case state of
PS_None: begin ready:=false;name :=str_ps_none;end;
PS_Comp: begin ready:=true; name :=_ai_name(ai_skill); ttl:=0;end;
PS_Play: begin ready:=false;name :=''; ttl:=0;end;
      end;
   end;
end;

procedure _swapPlayers(p0,p1:byte);
var tp:TPlayer;
    cc:cardinal;
begin
   if(_players[p0].state=ps_play)or(p1=p0)then exit;

   tp:=_players[p0];
   _players[p0]:=_players[p1];
   _players[p1]:=tp;

   cc:=_players[p0].color;
   _players[p0].color:=_players[p1].color;
   _players[p1].color:=cc;

   if(HPlayer=p1)then HPlayer:=p0
   else
     if(HPlayer=p0)then HPlayer:=p1;
end;

procedure DefPlayers;
var p:byte;
begin
   FillChar(_players,SizeOf(_players),0);
   for p:=0 to MaxPlayers do
    with _players[p] do
    begin
       ai_skill   := def_ai;
       race       := r_random;
       mrace      := race;
       team       := p;
       ready      := false;
       state      := ps_none;
       mmana      := 100;
       cmana      := 100;
       _playerSetState(p);

       uid_a      := singleuids;

       {ai_pushpart:= 2;
       ai_maxarmy := 100;
       ai_attack  := 0;}

       //_bc_ss(@a_build,[0..8]);
       //_bc_ss(@a_units,[0..11]);
       //_bc_ss(@a_upgr ,[0..MaxUpgrs]);
   end;

   with _players[0] do
   begin
      race     := r_hell;
      state    := ps_comp;
      uid_a    := [];
      upgr_a   := [];
{$IFNDEF _FULLGAME}
      name     := 'SERVER';
   end;
{$ELSE}
      color    := c_lgray;
   end;

   with _players[1] do color:=c_red;
   with _players[2] do color:=c_orange;
   with _players[3] do color:=c_yellow;
   with _players[4] do color:=c_lime;
   with _players[5] do color:=c_aqua;
   with _players[6] do color:=c_blue;

   HPlayer:=1;
   with _players[1] do
   begin
      state  :=ps_play;
      name   :=PlayerName;
      rghtatt:=m_a_inv;
   end;
{$ENDIF}
end;

procedure DefGameObjects;
begin
   randomize;

   G_Step    :=0;
   G_Status  :=0;

   onlySVCode :=true;
   vid_mredraw:=true;

   DefPlayers;
   Map_premap;

   UnitStepNum:= MinUSTP;
   _uclord_c  := 0;
   _uregen_c  := 0;

   FillChar(_units,SizeOf(_units),0);
   _lcu:=0;
   while(_lcu<MaxUnits)do
   begin
      inc(_lcu,1);
      _unit_sclass(@_units[_lcu]);
      with _units[_lcu] do
      begin
         hits  :=dead_hits;
         unum  :=_lcu;
         uclord:=_lcu mod _uclord_p;
      end;
   end;
   _lcup:=@_units[_lcu];

   FillChar(_missiles,SizeOf(_missiles)   ,0);

{$IFDEF _FULLGAME}
   FillChar(_effects ,SizeOf(_effects )   ,0);

   net_chat_clear;
   _fsttime     := false;
   net_cl_svttl := 0;
   net_cl_svpl  := 0;
   net_m_error  := '';
   vid_vsls     := 0;
   vid_vx       := 0;
   vid_vy       := 0;
   _igchat      := false;
   ui_chat_str  := '';
   ui_chattar   := 255;
   m_sxs        := -1;
   _draw        := true;
   ui_tab       := 0;
   ui_redraw    := 0;
   _svld_str    := '';
   _fog         := true;
   _warpten     := false;
   m_brush      := 0;
   m_brtar      := 0;
   ui_umark_u   := 0;
   ui_umark_ut  := 0;
   ui_panelmmm  := false;
   _view_bounds;
   FillChar(fog_grid,SizeOf(fog_grid),0);
   net_unmvsts  := UnitStepNum;

   if(_rpls_rst>rpl_wunit)then _rpls_rst:=rpl_none;
{$ENDIF}
   //FillChar(ui_alrms,SizeOf(ui_alrms  )   ,0);
end;

procedure _SkirmishStart;
var p:byte;
begin
   for p:=1 to MaxPlayers do
    with _players[p] do
    begin
       if(state=ps_none)and(G_aislots>0)then
       begin
          state   :=ps_comp;
          ai_skill:=G_aislots;
          race    :=r_random;
          _playerSetState(p);
       end;

       team:=_PickPTeam(p);

       if(race=r_random)then race:=1+random(race_n);

       if(state<>PS_None)then
       begin
          _unitCreate(map_psx[p]    , map_psy[p]    ,utbl_start[race],p,true);
          //_unitCreate(map_psx[p]    , map_psy[p]    ,UID_LostSoul,p,true);
          _unitCreate(map_psx[p]    , map_psy[p]    ,UID_Imp,p,true);
          _unitCreate(map_psx[p]    , map_psy[p]    ,UID_Imp,p,true);
          _unitCreate(map_psx[p]    , map_psy[p]    ,UID_Imp,p,true);
          _unitCreate(map_psx[p]    , map_psy[p]    ,UID_Imp,p,true);
          _unitCreate(map_psx[p]    , map_psy[p]    ,UID_Pain,p,true);
         { if(race=r_uac)then _unitCreate(map_psx[p]    , map_psy[p]    ,UID_Dron,p,true);
          if(race=r_uac)then _unitCreate(map_psx[p]    , map_psy[p]    ,UID_Dron,p,true);
          if(race=r_uac)then _unitCreate(map_psx[p]    , map_psy[p]    ,UID_Dron,p,true);
          if(race=r_uac)then _unitCreate(map_psx[p]    , map_psy[p]    ,UID_Dron,p,true); }
          if(state=ps_play)then ai_skill:=def_ai;
          //_setAI(p);
       end;
    end;
end;

{$IFDEF _FULLGAME}

{$include _replays.pas}

procedure _StartMatch;
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
       G_Started:= true;
       _menu    := false;
       k_ml     := 1;
       if(menu_s2<>ms2_camp)then
       begin
          _draw_surf(spr_mback,ui_mmmpx,ui_mmmpy,ui_tminimap);
          _SkirmishStart;
          _moveHumView(map_psx[HPlayer] , map_psy[HPlayer]);
       end;
    end;
end;

procedure MakeRandomSkirmish(st:boolean);
var p:byte;
begin
   g_aislots:=0;

   Map_randommap;

   _swapPlayers(1,HPlayer);

   for p:=2 to MaxPlayers do
    with _players[p] do
    begin
       race :=random(race_n+1);
       mrace:=race;

       if(p=6)
       then team :=1+random(MaxPlayers)
       else team :=2+random(MaxPlayers-1);

       ai_skill:=random(3)+3;

       if(random(2)=0)and(p>2)
       then state:=ps_none
       else state:=ps_comp;
       _playerSetState(p);
    end;

   _swapPlayers(random(MaxPlayers)+1,HPlayer);

   Map_premap;

   if(st)then _StartMatch;
end;

{$ENDIF}

procedure _u_ord(pl:byte);
var u,um,us,
   slmax,
   slcnt:integer;
    psel:boolean;
begin
   with _players[pl] do
   if(o_id>0)then
   begin
      slmax:=MaxPlayerUnits;
      slcnt:=0;
      if(o_id in [po_select,po_aselect])then
      begin
         if(o_x0>o_x1)then begin u:=o_x1;o_x1:=o_x0;o_x0:=u;end;
         if(o_y0>o_y1)then begin u:=o_y1;o_y1:=o_y0;o_y0:=u;end;
         if(dist2(o_x0,o_y0,o_x1,o_y1)<4)then slmax:=1;
      end;

      if(o_id=po_uorder)and(o_x1<0)then
      begin
         u :=MaxUnits+1;
         us:=-1;
         um:=1;
      end
      else
      begin
         u :=0;
         us:=1;
         um:=MaxUnits;
      end;

      repeat
         inc(u,us);

         with _units[u] do
          if(hits>0)and(inapc=0)and(pl=player)then
           with puid^ do
           begin
              psel:=sel;

              case o_id of
po_select    :begin
                 sel:=((o_x0-_r)<=vx)and(vx<=(o_x1+_r))and((o_y0-_r)<=vy)and(vy<=(o_y1+_r));
                 if(speed=0)and(slmax>1)and(sel)then sel:=false;
                 if(slcnt>=slmax)then sel:=false;
              end;
po_aselect   :if((o_x0-_r)<=vx)and(vx<=(o_x1+_r))and((o_y0-_r)<=vy)and(vy<=(o_y1+_r))then
               if(slmax=1)
               then sel:=not sel
               else sel:=true;
po_dblselect :if(_lsuc=uid)then sel:=((o_x0-_r)<=vx)and(vx<=(o_x1+_r))and((o_y0-_r)<=vy)and(vy<=(o_y1+_r));
po_adblselect:if(_lsuc=uid)and(sel=false)then sel:=((o_x0-_r)<=vx)and(vx<=(o_x1+_r))and((o_y0-_r)<=vy)and(vy<=(o_y1+_r));
po_selorder  :if(o_y0=0)or(not sel)then sel:=(order=o_x0);
po_selspec   :sel:=(o_y0=uid)or((o_x0>0)and sel)or((o_x1>0)and(speed>0)and(uo_attack in _orders));
po_uorder    :if(o_x0=uo_prod)then
               if(_unit_setorder(@_units[u],o_x0,o_y0,o_x1,o_y1,false,false))then break;
              end;

              if(sel)then
              begin
                 case o_id of
              po_select,
              po_aselect     : if(slmax=1)and(psel=false)then _lsuc:=uid;
              po_setorder    : order:=byte(o_x0);
              po_uorder      : if(_unit_setorder(@_units[u],o_x0,o_y0,o_x1,o_y1,false,false))then break;
              po_uordera     : if(_unit_setorder(@_units[u],o_x0,o_y0,o_x1,o_y1,false,true ))then break;
                 end;

                 if(psel=false)then _unit_selcntinc(@_units[u]);
                 inc(slcnt,1);
              end
              else
              begin
                 if(psel=true)then _unit_selcntdec(@_units[u]);
                 if(o_id=po_setorder)and(order=o_x0)then order:=0;
              end;
           end;

      until (u=um);

      if(o_id in [po_select,po_aselect])then
       if(slmax>1)or(slcnt=0)then _lsuc:=0;

      o_id:=0;
   end;
end;

procedure _PlayersCycle;
var p:byte;
begin
   for p:=0 to MaxPlayers do
    with _players[p] do
     if(state>ps_none)then
     begin
        if(net_nstat=ns_srvr)and(state=PS_Play)and(p<>HPlayer)then
        begin
           if(ttl<ServerTTL)then inc(ttl,1);
           if(ttl<=ClientTTL)then
           begin
              if(ttl=vid_fps)or(ttl=ClientTTL)then vid_mredraw:=true;
           end
           else
             if(G_Started=false)then
             begin
                state:=PS_None;
                _playerSetState(p);
                vid_mredraw:=true;
             end;
        end;

        if(G_Started)and(G_Status=0)and(onlySVCode)then
        begin
           _u_ord(p);

           if(g_step mod vid_fps)=0 then
            if(cmana<mmana)then
            begin
               inc(cmana,10);
               if(cmana>mmana)then cmana:=mmana;
            end;
           {
           if(build_rld>0)then dec(build_rld);

           case race of
           r_hell : ;//if(upgr[upgr_hinvuln]>0)and(effect=0)then effect:=invuln_time;
           end;

          if(effect>0)then
           begin
              dec(effect,1);
              if(effect=0)then
               case race of
               r_hell : ;//upgr[upgr_hinvuln]:=0;
               end;
           end; }
        end;
     end;

   {if(G_Started)and(G_Paused=0)and(onlySVCode)then
   begin
      if(net_nstat>ns_none)and(G_Step<60)then exit;

      if(G_WTeam=255)then
      begin
         FillChar(team_army,SizeOf(team_army),0);
         //G_WTeam:=255;
         for p:=0 to MaxPlayers do
          with _players[p] do
           if(state>ps_none)then inc(team_army[team],army);

         if(menu_s2=ms2_camp)
         then //cmp_code
         else
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
         _draw   :=true;
      end;
   end; }
end;


{$include _net_game.pas}

{$IFNDEF _FULLGAME}

function _nrmlStr(str:shortstring):shortstring;
var i,l:byte;
begin
   _nrmlStr:='';
   l:=length(str);
   for i:=1 to l do
    if(str[i] in k_kbstr)then _nrmlStr:=_nrmlStr+str[i];
end;

procedure _redrawConsole;
var p,t:byte;

procedure _wrcons(str:shortstring;ss:byte);
var l:byte;
begin
   if(p=0)or(p>maxCOns)then exit;
   str:=_nrmlStr(str);
   _cons[p]:=_cons[p]+str;
   if(ss=0)then exit;
   l:=length(str);
   while(l<ss)do
   begin
      _cons[p]:=_cons[p]+' ';
      inc(l,1);
   end;
end;

begin
   if(vid_mredraw)then
   begin
      if(_crt>0)then
      begin
         dec(_crt,1);
         exit;
      end;

      for t:=1 to maxCons do _cons[t]:='';

      p:=1;

      _wrcons(str_wcaption+'    '+str_cprt,0);
      inc(p,1);

      _wrcons('Game status:',13);
      if(G_Started)then
      begin
         _wrcons('Started',10);
         if(G_Status>0)and(G_Status=MaxPlayers)
         then _wrcons('Paused by player #',G_Status);
      end
      else _wrcons('Lobby',10);

      inc(p,1);

      _wrcons('Map:',10);
      _wrcons('Seed',12);
      _wrcons('Size',11);
      _wrcons('Lakes',10);
      _wrcons('Obstacles',10);
      inc(p,1);

      _wrcons(' ',10);
      _wrcons(c2s(map_seed),12);
      _wrcons(i2s(map_mw),11);
      _wrcons(str_xN[map_liq],10);
      _wrcons('x'+b2s(map_obs),10);
      inc(p,1);

      _wrcons('Players:',10);
      _wrcons('Name'  ,NameLen+2);
      _wrcons('Status',8);
      _wrcons('Race',8);
      _wrcons('Team',8);
      _wrcons('Color',8);
      inc(p,1);
      for t:=1 to MaxPlayers do
       with _players[t] do
       begin
          _wrcons(' #'+b2s(t),10);
          if(state=ps_none)then
          begin
             _wrcons(str_ps_none,NameLen+2);
             _wrcons(_plst(t),8);
             _wrcons(' ',16);
          end
          else
          begin
             _wrcons(name,NameLen+2);
             _wrcons(_plst(t),8);
             _wrcons(str_race[mrace],8);
             _wrcons(b2s(team),8);
          end;
          _wrcons(ded_sv_color[t],8);
          inc(p,1);
       end;

      _wrcons('Common game chat:',0);
      inc(p,1);
      with _players[0] do
       for t:=11 downto 0 do
       begin
          if(chatm[t]<>'')then _wrcons(chatm[t],p);
          inc(p,1);
       end;

      vid_mredraw:=false;
      _consi:=1;
      _crt:=vid_fps;
   end
   else
    if(_consi<=maxCons)then
     if((net_period mod 2)=0)then
     begin
        if(_consi=1)then clrscr;
        if(length(_cons[_consi])>maxConsL)then setlength(_cons[_consi],maxConsL);
        writeln(_cons[_consi]);
        inc(_consi,1);
     end;
end;

procedure _dedCode;
begin
   if(G_Started=false)then
   begin
      if(_plsReady)then
      begin
         vid_mredraw:=true;
         G_Started:=true;
         _SkirmishStart;
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
   _redrawConsole;
end;

{$ENDIF}

procedure _Game;
begin
   _PlayersCycle;

   {$IFNDEF _FULLGAME}
   _dedCode;
   {$ELSE}
   if(net_nstat=ns_clnt)then net_GClient;
   _rpls_code;
   if(_uclord_c=0)then _MusicCheck;
   {$ENDIF}

   if(G_Started)then
   begin
      if(G_Status=0)then
      begin
         inc(_uclord_c,1);_uclord_c:=_uclord_c mod _uclord_p;
         inc(_uregen_c,1);_uregen_c:=_uregen_c mod _uregen_p;

         if(onlySVCode)then
         begin
            inc(G_Step,1);
         end;

         _obj_cycle;
      end;
   end;

   if(net_nstat=ns_srvr)then net_GServer;
end;

