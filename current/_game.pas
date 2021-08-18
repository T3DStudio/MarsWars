
procedure _swapPlayers(p0,p1:integer);
var tp:TPlayer;
begin
   if(_players[p0].state=ps_play)or(p1=p0)then exit;

   tp:=_players[p0];
   _players[p0]:=_players[p1];
   _players[p1]:=tp;

   _players[p0].pnum:=p0;
   _players[p1].pnum:=p1;

   if(HPlayer=p1)then HPlayer:=p0
   else
     if(HPlayer=p0)then HPlayer:=p1;
end;

procedure _playerSetState(p:integer);
begin
   with _players[p] do
    case state of
PS_None: begin ready:=false;name :=str_ps_none;       ttl:=0;end;
PS_Comp: begin ready:=true; name :=ai_name(ai_skill); ttl:=0;end;
PS_Play: begin ready:=false;name :='';                ttl:=0;end;
    end;
end;

procedure DefPlayers;
var p:byte;
begin
   FillChar(_players,SizeOf(TPList),0);
   for p:=0 to MaxPlayers do
    with _players[p] do
    begin
       ai_skill := def_ai;
       race     :=r_random;
       team     :=p;
       state    :=ps_none;
       _playerSetState(p);
       ready    :=false;
       pnum     :=p;

       {ai_pushtime := fr_fps*30;
       ai_pushmin  := 55;
       ai_pushuids := [];
       ai_towngrd  := 3;
       ai_maxunits := 100;
       ai_flags    := $FFFFFFFF;
       ai_pushtimei:= 0;
       ai_pushfrmi := 0; }

       _units_au(p,[UID_HKeep..UID_HMilitaryUnit,
                    UID_LostSoul..UID_ZBFG,
                    UID_UCommandCenter..UID_UMine,
                    UID_Engineer..UID_Flyer],
                    255,true);

       _upgrs_au(p,[0..255],255,true);

      // a_upgr  := [0..MaxUpgrs];
   end;

   with _players[0] do
   begin
      race     :=r_hell;
      state    :=ps_comp;
      _units_au(0,[],0,true);
      _upgrs_au(0,[],0,true);
   end;

   {$IFDEF _FULLGAME}
   HPlayer:=1;
   with _players[1] do
   begin
      state:=ps_play;
      name :=PlayerName;
   end;

   PlayerColor[0]:=c_white;
   PlayerColor[1]:=c_red;
   PlayerColor[2]:=c_orange;
   PlayerColor[3]:=c_yellow;
   PlayerColor[4]:=c_lime;
   PlayerColor[5]:=c_aqua;
   PlayerColor[6]:=c_blue;

   {$ELSE}
   HPlayer:=0;
   with _players[0] do
   begin
      name :='SERVER';
   end;
   {$ENDIF}
end;

procedure DefGameObjects;
var u:integer;
begin
   randomize;

   G_Step   :=0;
   G_Paused :=0;
   G_WTeam  :=255;
   G_plstat :=255;

   ServerSide :=true;

   FillChar(g_cpoints ,SizeOf(g_cpoints ),0);
   FillChar(_missiles,SizeOf(_missiles),0);

   FillChar(_units   ,SizeOf(_units   ),0);

   for u:=0 to MaxUnits do
   with _units[u] do
   begin
      hits  :=dead_hits;
      player:=@_players[playeri];
      uid   :=@_units  [uidi   ];
   end;
   _LastCreatedUnit :=0;
   _LastCreatedUnitP:=@_units[_LastCreatedUnit];

   DefPlayers;

   UnitStepNum:=8;

   g_inv_wave_n := 0;
   g_inv_time   := 0;
   g_inv_wave_t := 0;
   g_royal_r    := 0;

   _uclord_c    := 0;
   _uregen_c    := 0;

   vid_mredraw:=true;

   Map_premap;

   {$IFDEF _FULLGAME}
   _fsttime:=false;
   _warpten:=false;

   vid_vx:=-vid_panelw;
   vid_vy:=0;
   _view_bounds;

   vid_rtui:=0;
   vid_vsls:=0;

   ui_tab :=0;
   ui_UnitSelectedNU:=0;
   ui_UnitSelectedPU:=0;
   ui_builders_n:=0;

   FillChar(_effects ,SizeOf(_effects ),0);
   FillChar(ui_alarms,SizeOf(ui_alarms),0);

   _igchat:=false;
   net_chat_clear;
   net_chat_str:='';
   net_cl_svttl:=0;
   net_cl_svpl :=0;
   net_m_error :='';

   ui_umark_u:=0;
   ui_umark_t:=0;

   m_sxs  :=-1;
   m_brush:=-32000;

   _fog   :=true;

   _svld_str:='';

   _rpls_pnu :=0;
   _rpls_vidm:=false;
   if(_rpls_rst>rpl_wunit)then _rpls_rst:=rpl_none;
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
        ai_skill+=1;
        if(ai_skill>gms_g_maxai)then ai_skill:=1;
        name:=ai_name(ai_skill);
     end;
end;

{$ENDIF}

procedure _CreateStartBase(x,y:integer;uid,pl,c:byte);
var i:byte;
r,d,xs,ys,
   ds:integer;
begin
   if(c=0)
   then _unit_add(x,y,uid,pl,true,false)
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

         _unit_add(xs,ys,uid,pl,true,false);

         d+=ds;
      end;
   end;
end;

procedure _StartSkirmish;
var p:byte;
begin
   g_royal_r:=trunc(sqrt(sqr(map_hmw)*2));

   for p:=0 to MaxPlayers do
   with _players[p] do
   begin
      team:=PickPlayerTeam(g_mode,p);

      if(p=0)then continue;

      if(state=ps_none)then
       if(G_aislots>0)then
       begin
          state   :=ps_comp;
          ai_skill:=G_aislots;
          race    :=r_random;
          _playerSetState(p);
       end;

      if(race=r_random)then race:=1+random(r_cnt);

      if(state<>PS_None)then
      begin
         _CreateStartBase(map_psx[p],map_psy[p],start_base[race],p,G_startb);

         if(state=ps_play)then ai_skill:=def_ai;
        // _setAI(p);
      end;
   end;

   {$IFDEF _FULLGAME}
   _moveHumView(map_psx[HPlayer] , map_psy[HPlayer]);
   {$ENDIF}
end;


{$IFDEF _FULLGAME}
procedure _StartStopGame;
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
       then _StartSkirmish
       else ;//_CMPMap;
       vid_rtui:=2;
       _makeMMB;
       d_Panel(r_uipanel);
    end;
end;

procedure MakeRandomSkirmish(st:boolean);
var p:byte;
begin
   if(G_Started)then exit;

   Map_randommap;

   G_mode   :=gm_scir;
   G_startb :=random(gms_g_startb+1);
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

   if(st)then _StartStopGame;
end;
{$ELSE}
{$include _ded.pas}
{$ENDIF}

function _CheckSimpleClick(o_x0,o_y0,o_x1,o_y1:integer):boolean;
begin
   _CheckSimpleClick:=dist2(o_x0,o_y0,o_x1,o_y1)<4;
end;

function f2select(pu:PTUnit):boolean;
begin
   f2select:=false;
   with pu^  do
   with uid^ do
   begin
      if(speed <=0)then exit;
      if(_attack=0)then exit;
      if(uo_id=ua_paction)then exit;
   end;
   f2select:=true;
end;

procedure _u_ord(pl:byte);
var
u,eu,
scnt,
scntm : integer;
 psel : boolean;
pu    : PTUnit;
begin
   with _players[pl] do
   if(o_id>0)and(army>0)then
   begin
      case o_id of
uo_build   : if(0<o_x1)and(o_x1<=255)then _unit_startb(o_x0,o_y0,o_x1,pl);
      else
         scnt :=0;
         scntm:=MaxPlayerUnits;
         if(o_id in [uo_select,uo_aselect])then
         begin
            if(o_x0>o_x1)then begin u:=o_x1;o_x1:=o_x0;o_x0:=u;end;
            if(o_y0>o_y1)then begin u:=o_y1;o_y1:=o_y0;o_y0:=u;end;
            if(_CheckSimpleClick(o_x0,o_y0,o_x1,o_y1))then scntm:=1;
         end;

         u :=1;
         eu:=MaxUnits+1;
         if(o_id=uo_corder)then   // reverse unit loop
          case o_x0 of
          co_destroy,
          co_cupgrade,
          co_cuprod,
          co_pcancle  : begin
                           u :=MaxUnits;
                           eu:=0;
                        end;
          end;

         while(u<>eu)do
         begin
            pu:=@_units[u];
            with pu^ do
            with uid^ do
             if(hits>0)and(inapc=0)and(pl=playeri)then
             begin
                psel:=sel;
                if (o_id=uo_select )
                or((o_id=uo_aselect)and(not sel))then
                begin
                   sel:=((o_x0-_r)<=vx)and(vx<=(o_x1+_r))
                     and((o_y0-_r)<=vy)and(vy<=(o_y1+_r));
                   if(speed=0)and(scntm>1)and(o_id<>uo_aselect)then sel:=false;
                   if(scnt>=scntm)then sel:=false;
                end;
                if(o_id=uo_selorder)and((o_y0=0)or(not sel))then sel:=(order=o_x0);

                if(o_id=uo_dblselect)or((o_id=uo_adblselect)and(not sel))then
                 if(uidi=o_a0)then
                  sel:=((o_x0-_r)<=vx)and(vx<=(o_x1+_r))
                    and((o_y0-_r)<=vy)and(vy<=(o_y1+_r));

                if(o_id=uo_specsel)then
                 if(o_x0<1)or(255<o_x0)then
                 begin if(f2select(pu)        )then sel:=true else if(o_y0=0)then sel:=false; end
                 else  if(_max=1)and(uidi=o_x0)then sel:=true else if(o_y0=0)then sel:=false;


                if(o_id=uo_corder)then
                 case o_x0 of
                 co_supgrade : if(s_smiths  =0)and(_unit_supgrade (pu,o_y0))then break;   // start upgr
                 co_cupgrade : if(s_smiths  =0)and(_unit_cupgrade (pu,o_y0))then break;   // cancle upgr
                 co_suprod   : if(s_barracks=0)and(_unit_straining(pu,o_y0))then break;   // start training
                 co_cuprod   : if(s_barracks=0)and(_unit_ctraining(pu,o_y0))then break;   // cancle training
                 end;

                if(sel)then
                begin
                   case o_id of
               uo_setorder,
               uo_addorder   : order:=o_x0;
               uo_corder     : case o_x0 of  // o_x0 = id, o_y0 = tar, o_x1,o_y1 - x,y
                    co_destroy :  _unit_kill(pu,false,o_y0>0);
                    co_rcamove,
                    co_rcmove  :  begin     // right clik
                                     case _ability of
                                     uab_uac_rstrike : _unit_umstrike(pu,o_x1,o_y1);
                                     uab_radar       : _unit_uradar  (pu,o_x1,o_y1);
                                     uab_htowertele  : if(o_y0<>u)and(o_y0<>0)and(_attack>atm_none)
                                                       then uo_tar:=o_y0
                                                       else _unit_htteleport(pu,o_x1,o_y1);
                                     uab_hell_unit_adv,
                                     uab_building_adv: uo_tar:=o_y0;
                                     else
                                        uo_tar:=0;
                                        uo_x  :=o_x1;
                                        uo_y  :=o_y1;
                                        uo_bx :=-1;

                                        if(o_y0<>u)then uo_tar:=o_y0;
                                        if(o_x0<>co_rcmove)or(speed<=0)
                                        then uo_id:=ua_amove
                                        else
                                        begin
                                           uo_id :=ua_move;
                                           a_tar :=0;
                                        end;
                                     end;

                                     _unit_turn(pu);
                                  end;
                    co_stand,
                    co_move,
                    co_patrol,
                    co_astand,
                    co_amove,
                    co_apatrol :  if(speed>0)then   // attack, move, patrol, stand, hold
                                  begin
                                     case o_x0 of
                         co_stand,
                         co_astand:  begin
                                        uo_x  :=x;
                                        uo_y  :=y;
                                        uo_bx :=-1;
                                        uo_tar:=0;
                                        a_tar :=0;
                                     end;
                         co_move,
                         co_patrol,
                         co_amove,
                         co_apatrol: begin
                                        uo_x  :=o_x1;
                                        uo_y  :=o_y1;
                                        uo_bx :=-1;
                                        uo_tar:=0;
                                        _unit_turn(pu);
                                        case o_x0 of
                              co_patrol,
                              co_apatrol: begin   // patrol
                                             uo_bx:=x;
                                             uo_by:=y;
                                          end;
                                        end;
                                     end;
                                     end;
                                     case o_x0 of
                              co_stand  : begin
                                             uo_id :=ua_hold;
                                             a_tar :=0;
                                          end;
                              co_move,
                              co_patrol : begin
                                             uo_id :=ua_move;
                                             a_tar :=0;
                                          end;
                              co_astand,
                              co_amove,
                              co_apatrol: uo_id:=ua_amove;
                                     end;
                                  end;
                    co_paction :  begin
                                     uo_x  :=o_x1;
                                     uo_y  :=o_y1;
                                     uo_bx :=-1;
                                     a_tar :=0;
                                     uo_tar:=0;
                                     if((_ability=0)and(apcc<=0))or(speed<=0)
                                     then uo_id:=ua_amove
                                     else uo_id:=ua_paction;
                                     _unit_turn(pu);
                                  end;
                    co_action  :  _unit_action   (pu);
                    co_supgrade:  _unit_supgrade (pu,o_y0);
                    co_cupgrade:  _unit_cupgrade (pu,o_y0);
                    co_suprod  :  _unit_straining(pu,o_y0);
                    co_cuprod  :  _unit_ctraining(pu,o_y0);
                    co_pcancle :  begin
                                  _unit_ctraining(pu,255);
                                  _unit_cupgrade (pu,255);
                                  end;
                               end;
                   end;

                   if(psel=false)then
                   begin
                      _unit_counters_inc_select(pu);
                      {$IFDEF _FULLGAME}
                      ui_UnitSelectedNU:=unum;
                      {$ENDIF}
                   end;
                   scnt+=1;
                end
                else
                begin
                   if(psel=true)then _unit_counters_dec_select(pu);
                   if(o_id=uo_setorder)and(order=o_x0)then order:=0;
                end;
             end;

            if(u>eu)
            then u-=1
            else u+=1;
         end;
      end;

      o_id:=0;
   end;
end;

procedure Endgame;
var p:byte;
begin
   if(not G_Started)
   or(G_Paused=0)
   or(not ServerSide)then exit;

   if(net_nstat>ns_none)and(G_Step<fr_fps)then exit;

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
        if(state>ps_none)then team_army[team]+=army;

      {$IFDEF _FULLGAME}
      if(menu_s2=ms2_camp)
      then //cmp_code
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

procedure PlayersCycle;
//const _pushtimes = _uclord_p;
var p:byte;
begin
   for p:=0 to MaxPlayers do
    with _players[p] do
     if(state>ps_none)then
     begin
        if(state=PS_Play)and(p<>HPlayer)and(net_nstat=ns_srvr)then
        begin
           if(ttl<ClientTTL)then
           begin
              ttl+=1;
              if(ttl=ClientTTL)or(ttl=fr_fps)then vid_mredraw:=true;
           end
           else
             if(G_Started=false)then
             begin
                state:=PS_None;
                _playerSetState(p);
                vid_mredraw:=true;
             end;
        end;

        if(G_Started)and(G_Paused=0)and(ServerSide)then
        begin
           _u_ord(p);

           if(build_cd>0)then build_cd-=1;
        end;
     end;

   Endgame;
end;
    {
procedure g_inv_calcmm;
const min_wave_time = fr_fps*15;
var a,i:integer;
begin
   case g_inv_wn of
   1  : g_inv_t:=fr_fps*90;
   else g_inv_t:=g_inv_wt;
   end;

   a:=0;
   for i:=1 to MaxPlayers do
    with _players[i] do
    if(state=ps_play)then inc(a,ucl_c[false]);

   dec(g_inv_t, g_inv_wn*fr_fps*2);
   dec(g_inv_t,(a div 15)*fr_fps);
   dec(g_inv_t, ((map_mw-MaxSMapW) div 100)*fr_fps);
   dec(g_inv_t, g_startb*5*fr_fps);

   if(g_inv_t<min_wave_time)then g_inv_t:=min_wave_time;

   g_inv_wt:=0;

   case g_inv_wn of
   1  : g_inv_mn:=30;
   2  : g_inv_mn:=60;
   3  : g_inv_mn:=90;
   else g_inv_mn:=MaxPlayerUnits;
   end;
end;

procedure g_inv_spawn;
const max_wave_time = fr_fps*150;
var i,tx,ty:integer;
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
            PlaySND(snd_teleport,nil);
            {$ENDIF}
            for i:=1 to g_inv_mn do
            begin
               case g_inv_wn of
               1 : mon:=UID_ZFormer;
               2 : case i mod 2 of
                   0 : mon:=UID_ZFormer;
                   1 : mon:=UID_ZSergant;
                   end;
               3 : case i mod 7 of
                   0 : mon:=UID_ZFormer;
                   1 : mon:=UID_ZSergant;
                   2 : mon:=UID_ZCommando;
                   3 : mon:=UID_ZBomber;
                   4 : mon:=UID_ZMajor;
                   5 : mon:=UID_ZBFG;
                   end;
               4 : case i of
                   1..10: mon:=UID_Baron
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
                   1   : mon:=UID_Cyberdemon;
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
               7 : mon:=UID_CacoDemon;
               else
                  if(i<(g_inv_wn*2))then
                    case i mod 2 of
                    0: mon:=UID_Cyberdemon;
                    1: mon:=UID_Mastermind;
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
                   if((i mod 11)=0)then
                   begin
                      buff[ub_invis ]:=_bufinf;
                      buff[ub_detect]:=_bufinf;
                   end;
                  buff[ub_advanced ]:=_bufinf;
                  //painc:=5*painc;
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
   for i:=1 to MaxCPoints do
    with g_cpt_pl[i] do
    begin
       if(ct>0)then dec(ct,1);
       if(t=0)or(t<>_players[pl].team)then
       begin
          t:=_players[pl].team;
          e:=1;
       end
       else inc(e,1);
    end;

   if(e=MaxCPoints)and(G_WTeam=255)then
   begin
      G_WTeam:=t;
      for i:=1 to MaxUnits do
       with _units[i] do
        if(hits>0)and(inapc=0)then
         with player^ do
          if(team<>t)then _unit_kill(@_units[i],false,false);
   end;
end;  }

{$include _net_game.pas}

procedure CodeGame;
begin
   {$IFDEF _FULLGAME}
   vid_rtui+=1;
   vid_rtui:=vid_rtui mod vid_rtuis;

   if(vid_rtui=0)then _MusicCheck;
   if(snd_anoncer_pause>0)then snd_anoncer_pause-=1;
   if(snd_unitcmd_pause>0)then snd_unitcmd_pause-=1;

   if(net_nstat=ns_clnt)then net_GClient;
   _rpls_code;

   {$ELSE}
   _dedCode;
   _dedScreen;
   {$ENDIF}

   PlayersCycle;

   if(G_Started)then
   begin
      //if(k_ctrl=5)then PlaySoundSet(snd_zimba_death);//PlayInGameAnoncer(snd_under_attack[false,_players[HPlayer].race]);
      //if(k_alt =5)then PlayInGameAnoncer(snd_under_attack[true ,_players[HPlayer].race]);

      if(G_paused=0)then
      begin
         {$IFDEF _FULLGAME}
         FillChar(ui_builders_x ,SizeOf(ui_builders_x ),0);
         FillChar(ui_units_ptime,SizeOf(ui_units_ptime),0);
         ui_first_upgr_time:=0;
         ui_uid_buildn     :=0;
         ui_uibtn_action   :=0;
         ui_uibtn_move     :=0;
         ui_uibtn_f2       :=0;
         ui_prod_builds    :=[];
         FillChar(ui_prod_units ,SizeOf(ui_prod_units ),0);
         FillChar(ui_orders_uids,SizeOf(ui_orders_uids),0);
         FillChar(ui_upgrct     ,SizeOf(ui_upgrct     ),0);
         FillChar(ui_upgr       ,SizeOf(ui_upgr       ),0);
         FillChar(ui_units_inapc,SizeOf(ui_units_inapc),0);
         FillChar(ui_uid_builds ,SizeOf(ui_uid_builds ),0);
         FillChar(ui_orders_n   ,SizeOf(ui_orders_n   ),0);
         FillChar(ui_orders_x   ,SizeOf(ui_orders_x   ),0);
         FillChar(ui_orders_y   ,SizeOf(ui_orders_y   ),0);
         if(ui_umark_t>0)then begin ui_umark_t-=1;if(ui_umark_t=0)then ui_umark_u:=0;end;

         PlayUnitSelect;
         {$ENDIF}

         _uclord_c+=1; _uclord_c:=_uclord_c mod _uclord_p;
         _uregen_c+=1; _uregen_c:=_uregen_c mod regen_per;

         if(ServerSide)then
         begin
            if(_uclord_c=0)then
             if(g_royal_r>0)then g_royal_r-=1;

            G_Step+=1;
            //if(g_mode=gm_ct )then _CPoints;
            //if(g_mode=gm_inv)then g_inv_spawn;
         end;
      end;

      _obj_cycle;
   end;

   if(net_nstat=ns_srvr)then net_GServer;
end;


