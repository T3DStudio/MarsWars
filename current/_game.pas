
procedure PlayerSetSkirmishTech(p:byte);
begin
   with _players[p] do
   begin
      PlayerSetAllowedUnits(p,[ UID_HKeep         ..UID_HMilitaryUnit,
                                UID_LostSoul      ..UID_ZBFG,
                                UID_UCommandCenter..UID_UNuclearPlant,
                                UID_Engineer      ..UID_Flyer  ],
                                MaxUnits,true);

      PlayerSetAllowedUnits(p,[ UID_HMonastery,UID_HFortress,UID_HAltar,
                                UID_UNuclearPlant,UID_URMStation ],1,false);

      PlayerSetAllowedUpgrades(p,[0..255],255,true); //



      {ai_pushtime := fr_fps*30;
      ai_pushmin  := 55;
      ai_pushuids := [];
      ai_towngrd  := 3;
      ai_maxunits := 100;
      ai_flags    := $FFFFFFFF;
      ai_pushtimei:= 0;
      ai_pushfrmi := 0; }
   end;
   PlayerSetSkirmishAIParams(p);
end;

procedure PlayersSwap(p0,p1:byte);
var tp:TPlayer;
begin
   if(p0>MaxPlayers)
   or(p1>MaxPlayers)then exit;
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

procedure PlayerSetState(p:integer;st:byte);
begin
   with _players[p] do
   begin
      state:=st;
      case state of
PS_None: begin ready:=false;name :=str_ps_none;       ttl:=0;end;
PS_Comp: begin ready:=true; name :=ai_name(ai_skill); ttl:=0;end;
PS_Play: begin ready:=false;name :='';                ttl:=0;end;
      end;
   end;
end;

procedure PlayersSetDefault;
var p:byte;
begin
   FillChar(_players,SizeOf(TPList),0);
   for p:=0 to MaxPlayers do
    with _players[p] do
    begin
       ai_skill :=player_default_ai_level;
       race     :=r_random;
       team     :=p;
       ready    :=false;
       pnum     :=p;
       PlayerSetState(p,ps_none);
       PlayerClearLog(p);
   end;

   with _players[0] do
   begin
      race     :=r_hell;
      state    :=ps_comp;
      PlayerSetAllowedUnits   (0,[],0,true);
      PlayerSetAllowedUpgrades(0,[],0,true);
   end;

   {$IFDEF _FULLGAME}
   HPlayer:=1;
   with _players[HPlayer] do
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
   with _players[HPlayer] do
   begin
      name :='SERVER';
   end;
   {$ENDIF}
end;

procedure GameDefaultAll;
var u:integer;
begin
   randomize;

   G_Step         :=0;
   G_Status       :=0;
   G_player_status:=255;

   ServerSide     :=true;

   FillChar(g_cpoints,SizeOf(g_cpoints),0);
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

   PlayersSetDefault;

   UnitStepTicks:= 8;

   g_inv_wave_n := 0;
   g_inv_time   := 0;
   g_inv_wave_t := 0;
   g_royal_r    := 0;

   _cycle_order    := 0;
   _cycle_regen    := 0;

   vid_menu_redraw:=true;

   Map_premap;

   {$IFDEF _FULLGAME}
   _fsttime:=false;
   _warpten:=false;

   vid_cam_x:=-vid_panelw;
   vid_cam_y:=0;
   CamBounds;

   vid_rtui:=0;
   vid_vsls:=0;

   ui_tab :=0;
   ui_UnitSelectedNU:=0;
   ui_UnitSelectedPU:=0;

   FillChar(_effects ,SizeOf(_effects ),0);
   FillChar(ui_alarms,SizeOf(ui_alarms),0);

   ingame_chat :=false;
   net_chat_str:='';
   net_cl_svttl:=0;
   net_cl_svpl :=0;
   net_m_error :='';

   ui_umark_u:=0;
   ui_umark_t:=0;

   mouse_select_x0:=-1;
   m_brush:=-32000;

   rpls_fog   :=true;

   _svld_str:='';

   rpls_pnu  :=0;
   rpls_plcam:=false;
   if(rpls_state>rpl_wunit)then rpls_state:=rpl_none;
   {$ELSE}
   {$ENDIF}
end;

{$IFDEF _FULLGAME}
{$include _replays.pas}
{$ENDIF}

procedure GameCreateStartBase(x,y:integer;uid,pl,c:byte);
var  i:byte;
r,d,ds:integer;
begin
   if(c=0)
   then _unit_add(x,y,uid,pl,true,false,false)
   else
   begin
      if(c>5)then
      begin
         _unit_add(x,y,uid,pl,true,false,false);
         c-=1;
      end;
      ds :=map_mw div 2;
      d  :=p_dir(x,y,ds,ds);
      ds :=360 div (c+1);
      r  :=46+c*18;
      for i:=0 to c do
      begin
         _unit_add(
         x+trunc(r*cos(d*degtorad)),
         y-trunc(r*sin(d*degtorad)),
         uid,pl,true,false,false);

         d+=ds;
      end;
   end;
end;

procedure GameStartSkirmish;
var p:byte;
begin
   g_royal_r:=trunc(sqrt(sqr(map_hmw)*2));

   for p:=0 to MaxPlayers do
   with _players[p] do
   begin
      team:=PlayerGetTeam(g_mode,p);

      if(p=0)then
      begin
         // neutrall player settings depend from g_mode

         race :=r_hell;
         state:=ps_comp;
      end
      else
      begin
         if(state=ps_none)then
          if(g_ai_slots>0)then
          begin
             ai_skill:=g_ai_slots;
             race    :=r_random;
             PlayerSetState(p,ps_comp);
          end;

         if(race=r_random)then race:=1+random(r_cnt);

         if(state<>ps_none)then
         begin
            if(state=ps_play)then ai_skill:=player_default_ai_level;//g_ai_slots;//

            PlayerSetSkirmishTech(p);
            GameCreateStartBase(map_psx[p],map_psy[p],uid_race_start_base[race],p,g_start_base);
         end;
      end;
   end;

   {$IFDEF _FULLGAME}
   MoveCamToPoint(map_psx[HPlayer] , map_psy[HPlayer]);
   {$ENDIF}
end;


{$IFDEF _FULLGAME}
procedure GameMakeDestroy;
begin
   menu_item:=0;
   if(G_Started)then
   begin
      G_Started:=false;
      GameDefaultAll;
   end
   else
    if(PlayersReadyStatus)then
    begin
       G_Started:=true;
       _menu    :=false;
       if(menu_s2<>ms2_camp)
       then GameStartSkirmish
       else ;//_CMPMap;
       vid_rtui:=2;
       map_RedrawMenuMinimap;
       d_Panel(r_uipanel);
    end;
end;

procedure MakeRandomSkirmish(andstart:boolean);
var p:byte;
begin
   if(G_Started)then exit;

   Map_randommap;

   g_mode       :=gm_scir;
   g_start_base :=random(gms_g_startb+1);
   g_addon      :=random(3)<>0;

   PlayersSwap(1,HPlayer);

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
       then PlayerSetState(p,ps_none)
       else PlayerSetState(p,ps_comp);
    end;

   PlayersSwap(random(6)+1,HPlayer);

   g_ai_slots:=random(5);

   Map_premap;

   if(andstart)then GameMakeDestroy;
end;
{$ELSE}
{$include _ded.pas}
{$ENDIF}

function CheckSimpleClick(o_x0,o_y0,o_x1,o_y1:integer):boolean;
begin
   CheckSimpleClick:=dist2(o_x0,o_y0,o_x1,o_y1)<4;
end;


procedure _u_ord(pl:byte);
var
_su,_eu,
usel_n,
usel_max : integer;
psel     : boolean;
oa,
pu       : PTUnit;
begin
   oa:=nil;
   with _players[pl] do
   if(o_id>0)and(army>0)then
   begin
      case o_id of
uo_build   : if(0<o_x1)and(o_x1<=255)then PlayerSetProdError(pl,glcp_unit,byte(o_x1),_unit_start_build(o_x0,o_y0,byte(o_x1),pl),nil);
      else
         usel_n  :=0;
         usel_max:=MaxPlayerUnits;
         if(o_id in [uo_select,uo_aselect])then
         begin
            if(o_x0>o_x1)then begin _su:=o_x1;o_x1:=o_x0;o_x0:=_su;end;
            if(o_y0>o_y1)then begin _su:=o_y1;o_y1:=o_y0;o_y0:=_su;end;
            if(CheckSimpleClick(o_x0,o_y0,o_x1,o_y1))then usel_max:=1;
         end;

         _su :=1;
         _eu:=MaxUnits+1;
         if(o_id=uo_corder)then   // reverse unit loop
          case o_x0 of
          co_destroy,
          co_cupgrade,
          co_cuprod,
          co_pcancle  : begin
                           _su :=MaxUnits;
                           _eu:=0;
                        end;
          end;

         while(_su<>_eu)do
         begin
            pu:=_punits[_su];
            with pu^ do
            with uid^ do
             if(hits>0)and(not _IsUnitRange(inapc,nil))and(pl=playeri)then
             begin
                psel:=sel;

                // common select
                if (o_id=uo_select )
                or((o_id=uo_aselect)and(not sel))then
                begin
                   sel:=((o_x0-_r)<=vx)and(vx<=(o_x1+_r))
                     and((o_y0-_r)<=vy)and(vy<=(o_y1+_r));
                   if(speed <=0)and(usel_max>1)and(o_id<>uo_aselect)then sel:=false;
                   if(usel_n>=usel_max)then sel:=false;
                end;
                if(o_id=uo_selorder)and((o_y0=0)or(not sel))then sel:=(order=o_x0);
                if(o_id=uo_dblselect)or((o_id=uo_adblselect)and(not sel))then
                begin
                   if(oa=nil)then
                    if(not _IsUnitRange(o_a0,@oa))then break;
                   if(uidi=oa^.uidi)and((buff[ub_advanced]>0)=(oa^.buff[ub_advanced]>0))
                   then sel:=((o_x0-_r)<=vx)and(vx<=(o_x1+_r))
                          and((o_y0-_r)<=vy)and(vy<=(o_y1+_r))
                   else if(o_id<>uo_adblselect)then sel:=false;
                end;
                if(o_id=uo_specsel)then
                 if(o_x0<1)or(255<o_x0)
                 then begin if(UnitF2Select(pu))then sel:=true else if(o_y0=0)then sel:=false; end
                 else       if(a_units[uidi]=1)and(uidi=o_x0)then sel:=true else if(o_y0=0)then sel:=false;

                if(o_id=uo_corder)then
                 case o_x0 of
                 co_supgrade : if(s_smiths  =0)then if(_unit_supgrade (pu,o_y0))then break;   // start  upgr
                 co_cupgrade : if(s_smiths  =0)then if(_unit_cupgrade (pu,o_y0))then break;   // cancle upgr
                 co_suprod   : if(s_barracks=0)then if(_unit_straining(pu,o_y0))then break;   // start  training
                 co_cuprod   : if(s_barracks=0)then if(_unit_ctraining(pu,o_y0))then break;   // cancle training
                 end;

                if(sel)then
                begin
                   case o_id of
               uo_setorder,
               uo_addorder   : if(0<=o_x0)and(o_x0<MaxUnitOrders)then order:=o_x0;
               uo_corder     : if(not _unit_player_order(pu,o_x0,o_y0,o_x1,o_y1))then break;
                   end;

                   if(psel=false)then
                   begin
                      _unit_counters_inc_select(pu);
                      {$IFDEF _FULLGAME}
                      ui_UnitSelectedNU:=unum;
                      {$ENDIF}
                   end;
                   usel_n+=1;
                end
                else
                begin
                   if(psel=true)then _unit_counters_dec_select(pu);
                   if(o_id=uo_setorder)and(order=o_x0)then order:=0;
                end;
             end;

            if(_su>_eu)
            then _su-=1
            else _su+=1;
         end;
      end;

      o_id:=0;
   end;
end;

procedure GameEndConditions;
var p:byte;
begin
   if(not G_Started)
   or(G_Status=gs_running)
   or(not ServerSide)then exit;

   if(net_status>ns_none)and(G_Step<fr_fps)then exit;

   g_player_status:=0;
   for p:=0 to MaxPlayers do
    with _players[p] do
     if(army>0)and(state>ps_none)then g_player_status:=g_player_status or (1 shl p);

  { if(G_WTeam=255)then
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
      r_draw:=true;
      {$ENDIF}
   end; }
end;

procedure PlayersCycle;
var p:byte;
begin
   for p:=0 to MaxPlayers do
    with _players[p] do
     if(state>ps_none)then
     begin
        if(state=PS_Play)and(p<>HPlayer)and(net_status=ns_srvr)then
        begin
           if(ttl<ClientTTL)then
           begin
              ttl+=1;
              if(ttl=ClientTTL)or(ttl=fr_fps)then vid_menu_redraw:=true;
           end
           else
             if(G_Started=false)then
             begin
                PlayerSetState(p,PS_None);
                vid_menu_redraw:=true;
             end;
        end;
        if(net_logsend_pause>0)then net_logsend_pause-=1;

        if(G_Started)and(G_Status=gs_running)and(ServerSide)then
        begin
           if(build_cd>0)then build_cd-=1;

           _u_ord(p);

           if(prod_error_cndt>0)then
           begin
              GameLogCantProduction(p,prod_error_uid,prod_error_utp,prod_error_cndt,prod_error_x,prod_error_y,false);
              prod_error_cndt:=0;
           end;
        end;
     end;

   GameEndConditions;
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
end;  }

procedure GameModeCPoints;
var i,t,e:integer;
begin
   e:=0;
   t:=0;
   for i:=1 to MaxCPoints do
    with g_cpoints[i] do
    begin
       if(ct>0)then ct-=1;
       if(t=0)or(t<>_players[pl].team)then
       begin
          t:=_players[pl].team;
          e:=1;
       end
       else e+=1;
    end;

   {if(e=MaxCPoints)and(G_WTeam=255)then
   begin
      G_WTeam:=t;
      for i:=1 to MaxUnits do
       with _units[i] do
        if(hits>0)and(inapc=0)then
         with player^ do
          if(team<>t)then _unit_kill(@_units[i],false,false);
   end; }
end;

{$include _net_game.pas}

procedure CodeGame;
begin
   {$IFDEF _FULLGAME}
   vid_rtui+=1;
   vid_rtui:=vid_rtui mod vid_rtuis;

   SoundControl;

   if(net_status=ns_clnt)then net_GClient;
   replay_code;

   {$ELSE}
   _dedCode;
   _dedScreen;
   {$ENDIF}

   PlayersCycle;

   if(G_Started)then
   begin
      //if(k_ctrl=5)then PlaySoundSet(snd_zimba_death);//PlayInGameAnoncer(snd_under_attack[false,_players[HPlayer].race]);
      //if(k_alt =5)then PlayInGameAnoncer(snd_under_attack[true ,_players[HPlayer].race]);

      if(G_Status=gs_running)then
      begin
         _cycle_order+=1;_cycle_order:=_cycle_order mod order_period;
         _cycle_regen+=1;_cycle_regen:=_cycle_regen mod regen_period;

         if(ServerSide)then
         begin
            G_Step+=1;

            case g_mode of
            gm_cptp : GameModeCPoints;
            gm_inv  : ;
            gm_royl : if(_cycle_order=0)then
                       if(g_royal_r>0)then g_royal_r-=1;
            end;
         end;
         _obj_cycle;
      end;
   end;

   if(net_status=ns_srvr)then net_GServer;
end;


