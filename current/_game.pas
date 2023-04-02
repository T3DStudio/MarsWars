
procedure PlayerSetSkirmishTech(p:byte);
begin
   with _players[p] do
   begin
      PlayerSetAllowedUnits(p,[ UID_HKeep         ..UID_HBarracks,
                                UID_LostSoul      ..UID_ZBFGMarine,
                                UID_UCommandCenter..UID_UNuclearPlant,
                                UID_Engineer      ..UID_Flyer  ],
                                MaxUnits,true);

      PlayerSetAllowedUnits(p,[ UID_HMonastery ,UID_HFortress    ,UID_HAltar, UID_HPentagram,
                                UID_UTechCenter,UID_UNuclearPlant,UID_URMStation ],1,false);

      if(g_cgenerators>0)then
      PlayerSetAllowedUnits(p,[ UID_HSymbol   ,UID_HASymbol   ,UID_HKeep         ,UID_HCommandCenter,
                                UID_UGenerator,UID_UAGenerator,UID_UCommandCenter],0,false);


      PlayerSetAllowedUpgrades(p,[0..255],255,true); //

      //if(not g_addon)then
      //upgr[upgr_hell_baron]:=1;


      {ai_pushtime := fr_fps1*30;
      ai_pushmin  := 55;
      ai_pushuids := [];
      ai_towngrd  := 3;
      ai_maxunits := 100;
      ai_flags    := $FFFFFFFF;
      ai_pushtimei:= 0;
      ai_pushfrmi := 0; }
   end;
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

procedure PlayerSetState(p,newstate:byte);
begin
   with _players[p] do
   begin
      case newstate of
PS_None: begin ready:=false;name :=str_ps_none;       ttl:=0;if(p>0)and(state=ps_comp)then team:=p;end;
PS_Comp: begin ready:=true; name :=ai_name(ai_skill); ttl:=0;if(p>0)and(team=0)then team:=p;end;
PS_Play: begin ready:=false;name :='';                ttl:=0;end;
      end;
      state:=newstate;
   end;
end;

procedure PlayerKill(pl:byte);
var u:integer;
begin
   for u:=1 to MaxUnits do
    with _punits[u]^ do
     if(hits>0)and(playeri=pl)then _unit_kill(_punits[u],false,true,false,true);
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
       PlayerSetSkirmishTech(p);
       PlayerClearLog(p);
       log_EnergyCheck:=0;
   end;

   with _players[0] do
   begin
      race     :=r_hell;
      state    :=ps_comp;
      PlayerSetAllowedUnits   (0,[],0,true);
      PlayerSetAllowedUpgrades(0,[],0,true);
   end;

   FillChar(_playerAPM,SizeOf(_playerAPM),0);

   {$IFDEF _FULLGAME}
   HPlayer:=1;
   with _players[HPlayer] do
   begin
      state:=ps_play;
      name :=PlayerName;
   end;

   PlayerColor[0]:=c_ltgray;
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

   UnitStepTicks    := 8;

   g_inv_wave_n     := 0;
   g_inv_wave_t_next:= 0;
   g_inv_wave_t_curr:= 0;
   g_royal_r        := 0;

   _cycle_order     := 0;
   _cycle_regen     := 0;

   Map_premap;

   {$IFDEF _FULLGAME}
   _fsttime:=false;
   _warpten:=false;

   vid_menu_redraw  := true;

   vid_cam_x:=-vid_panelw;
   vid_cam_y:=0;
   CamBounds;

   vid_blink_timer1:=0;
   vid_blink_timer2:=0;
   vid_vsls:=0;

   ui_tab :=0;
   ui_UnitSelectedNU:=0;
   ui_UnitSelectedPU:=0;

   FillChar(_effects ,SizeOf(_effects ),0);
   FillChar(ui_alarms,SizeOf(ui_alarms),0);

   ingame_chat :=0;
   net_chat_str:='';
   net_cl_svttl:=0;
   net_cl_svpl :=0;
   net_m_error :='';

   ui_umark_u:=0;
   ui_umark_t:=0;

   mouse_select_x0:=-1;
   m_brush:=-32000;

   rpls_fog   :=true;

   svld_str_fname:='';

   rpls_pnu  :=0;
   rpls_plcam:=false;
   if(rpls_state>rpl_wunit)then rpls_state:=rpl_none;
   {$ELSE}
   screen_redraw:=true;
   {$ENDIF}
end;

{$IFDEF _FULLGAME}
{$include _replays.pas}
{$ENDIF}

procedure GameCreateStartBase(x,y:integer;uidF,uidA,pl,c:byte;AdvancedBase:boolean);
var  i,n,uid:byte;
r,d,ds:integer;
procedure _Spawn(tx,ty:integer);
begin
   if(n=0)and(AdvancedBase)and(c=0)
   then uid:=uidA
   else uid:=uidF;
   _unit_add(tx,ty,0,uid    ,pl,true,false,0);
   n+=1;
end;

begin
   if(c>6)then c:=6;
   n:=0;

   if(c=0)
   then _Spawn(x,y)
   else
   begin
      if(c>5)then
      begin
         _Spawn(x,y);
         c-=1;
      end;
      ds :=map_mw div 2;
      d  :=point_dir(x,y,ds,ds);
      ds :=360 div (c+1);
      r  :=50+c*18;
      for i:=0 to c do
      begin
         _Spawn(
         x+trunc(r*cos(d*degtorad)),
         y-trunc(r*sin(d*degtorad))
         );

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
         race    :=r_hell;
         ai_skill:=gms_g_maxai;
         PlayerSetState(p,ps_comp);
         PlayerSetCurrentUpgrades(p,[1..255],15,true,true);
         ai_PlayerSetSkirmishSettings(p);
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

         if(state=ps_play)then ai_skill:=player_default_ai_level;//g_ai_slots
      end;
   end;

   for p:=1 to MaxPlayers do
    with _players[p] do
     if(state<>ps_none)then
     begin
        PlayerSetSkirmishTech(p);
        ai_PlayerSetSkirmishSettings(p);
        if(team>0)then GameCreateStartBase(map_psx[p],map_psy[p],uid_race_start_fbase[race],uid_race_start_abase[race],p,g_start_base,g_cgenerators>0);
     end;

   {$IFDEF _FULLGAME}
   MoveCamToPoint(map_psx[HPlayer] , map_psy[HPlayer]);
   {$ENDIF}
end;


{$IFDEF _FULLGAME}
procedure GameMakeReset;
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
       vid_blink_timer1:=1;
       UIPlayer:=HPlayer;
    end;
end;

procedure MakeRandomSkirmish(andstart:boolean);
var p:byte;
begin
   if(G_Started)then exit;

   Map_randommap;

   g_mode       :=gm_scirmish;
   g_start_base :=random(gms_g_startb+1);
   g_cgenerators:=random(gms_g_maxgens+1);

   PlayersSwap(1,HPlayer);

   for p:=2 to MaxPlayers do
    with _players[p] do
    begin
       race :=random(r_cnt+1);
       mrace:=race;

       if(p=4)
       then team:=1+random(4)
       else team:=2+random(3);

       ai_skill:=random(6)+2;

       if(random(2)=0)and(p>2)
       then PlayerSetState(p,ps_none)
       else PlayerSetState(p,ps_comp);
    end;

   PlayersSwap(random(MaxPlayers)+1,HPlayer);

   g_ai_slots:=random(player_default_ai_level+1);

   Map_premap;

   if(andstart)then GameMakeReset;
end;
{$ELSE}
{$include _ded.pas}
{$ENDIF}

function CheckSimpleClick(o_x0,o_y0,o_x1,o_y1:integer):boolean;
begin
   CheckSimpleClick:=point_dist_rint(o_x0,o_y0,o_x1,o_y1)<4;
end;


procedure PlayerExecuteOrder(pl:byte);
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
      if(pl<>HPlayer)then   // ded serverside counter
      PlayerAPMInc(pl);

      case o_id of
uo_build   : if(0<o_x1)and(o_x1<=255)then PlayerSetProdError(pl,lmt_argt_unit,byte(o_x1),_unit_start_build(o_x0,o_y0,byte(o_x1),pl),nil);
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
         if(o_id=uo_corder)then
          case o_x0 of
          co_destroy,
          co_cupgrade,
          co_cuprod,
          co_pcancle  : begin   // reverse unit loop
                           _su :=MaxUnits;
                           _eu:=0;
                        end;
          co_supgrade : if(n_smiths  <=0)then begin PlayerSetProdError(pl,lmt_argt_upgr,o_y0,ureq_smiths  ,nil);o_id:=0;end;
          co_suprod   : if(n_barracks<=0)then begin PlayerSetProdError(pl,lmt_argt_unit,o_y0,ureq_barracks,nil);o_id:=0;end;
          end;

         while(_su<>_eu)do
         begin
            pu:=_punits[_su];
            with pu^ do
            with uid^ do
             if(hits>0)and(not _IsUnitRange(transport,nil))and(pl=playeri)then
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
                if(o_id=uo_selorder)and((o_y0=0)or(not sel))then sel:=(group=o_x0);
                if(o_id=uo_dblselect)or((o_id=uo_adblselect)and(not sel))then
                begin
                   if(oa=nil)then
                    if(not _IsUnitRange(o_a0,@oa))then break;
                   if(uidi=oa^.uidi)
                   then sel:=((o_x0-_r)<=vx)and(vx<=(o_x1+_r))
                          and((o_y0-_r)<=vy)and(vy<=(o_y1+_r))
                   else if(o_id<>uo_adblselect)then sel:=false;
                end;
                if(o_id=uo_specsel)then
                  if(UnitF2Select(pu))
                  then sel:=true
                  else
                    if(o_y0=0)then sel:=false;

                if(o_id=uo_corder)then
                 case o_x0 of
                 co_supgrade : if(s_smiths  <=0)or(sel)then if(_unit_supgrade (pu,o_y0      ))then begin PlayerClearProdError(player);break;end;// start  upgr
                 co_cupgrade : if(s_smiths  <=0)or(sel)then if(_unit_cupgrade (pu,o_y0,false))then break;                                       // cancle upgr
                 co_suprod   : if(s_barracks<=0)or(sel)then if(_unit_straining(pu,o_y0      ))then begin PlayerClearProdError(player);break;end;// start  training
                 co_cuprod   : if(s_barracks<=0)or(sel)then if(_unit_ctraining(pu,o_y0,false))then break;                                       // cancle training
                 co_pcancle  : begin
                               if(s_barracks<=0)or(sel)then if(_unit_ctraining(pu,255 ,false))then break;
                               if(s_smiths  <=0)or(sel)then if(_unit_cupgrade (pu,255 ,false))then break;
                               end;
                 end;

                if(sel)then
                begin
                   case o_id of
               uo_setorder,
               uo_addorder   : if(0<=o_x0)and(o_x0<MaxUnitGroups)then group:=o_x0;
               uo_corder     : if(_unit_player_order(pu,o_x0,o_y0,o_x1,o_y1))then break;
                   end;

                   if(psel=false)then
                   begin
                      _unit_counters_inc_select(pu);
                      {$IFDEF _FULLGAME}
                      UpdateLastSelectedUnit(unum);
                      {$ENDIF}
                   end;
                   usel_n+=1;
                end
                else
                begin
                   if(psel=true)then _unit_counters_dec_select(pu);
                   if(o_id=uo_setorder)and(group=o_x0)then group:=0;
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

procedure GameDefaultEndConditions;
var p,wteam_last,wteams_n: byte;
teams_army: array[0..MaxPlayers] of integer;
begin
   //exit;

   if(net_status>ns_none)and(G_Step<fr_fps1)then exit;

   FillChar(teams_army,SizeOf(teams_army),0);

   wteam_last:=255;
   wteams_n  :=0;

   for p:=0 to MaxPlayers do
    with _players[p] do
     teams_army[team]+=army;

   for p:=0 to MaxPlayers do
    if(teams_army[p]>0)then
    begin
       wteam_last:=p;
       wteams_n  +=1;
    end;

   if(wteams_n=1)then GameSetStatusWinnerTeam(wteam_last);
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
              if(ttl=ClientTTL)or(ttl=fr_fps1)then {$IFDEF _FULLGAME}vid_menu_redraw{$ELSE}screen_redraw{$ENDIF}:=true;
           end
           else
             if(G_Started=false)then
             begin
                PlayerSetState(p,PS_None);
                {$IFDEF _FULLGAME}vid_menu_redraw{$ELSE}screen_redraw{$ENDIF}:=true;
             end;
        end;
        if(net_logsend_pause>0)then net_logsend_pause-=1;

        if(G_Started)and(G_Status=gs_running)and(ServerSide)then
        begin
           if(build_cd>0)then build_cd-=1;

           PlayerExecuteOrder(p);

           if(state=ps_comp)
           then ai_player_code(p)
           else
             if(log_EnergyCheck>0)
             then log_EnergyCheck-=1
             else
               if(cenergy>=0)
               then log_EnergyCheck:=1
               else
               begin
                  log_EnergyCheck:=fr_fps6;
                  PlayersAddToLog(p,0,lmt_req_energy,0,0,'',-1,-1,false);
               end;

           if(prod_error_cndt>0)then
             GameLogCantProduction(p,prod_error_uid,prod_error_utp,prod_error_cndt,prod_error_x,prod_error_y,false);
           prod_error_cndt  :=0;
        end;
     end;

   for p:=0 to MaxPlayers do PlayerAPMUpdate(p);
end;

{$include _net_game.pas}

procedure CodeGame;
begin
   {$IFDEF _FULLGAME}
   vid_blink_timer1+=1;vid_blink_timer1:=vid_blink_timer1 mod vid_blink_period1;
   vid_blink_timer2+=1;vid_blink_timer2:=vid_blink_timer2 mod vid_blink_period2;

   if(vid_blink_timer1=0)then
   begin
      r_blink3+=1;
      r_blink3:=r_blink3 mod 4;
   end;

   r_blink1_colorb  :=vid_blink_timer1>vid_blink_periodh;
   r_blink2_colorb  :=vid_blink_timer2>vid_blink_period1;

   r_blink1_color_BG:=ui_blink_color1[r_blink1_colorb];
   r_blink1_color_BY:=ui_blink_color2[r_blink1_colorb];
   r_blink2_color_BG:=ui_blink_color1[r_blink2_colorb];
   r_blink2_color_BY:=ui_blink_color2[r_blink2_colorb];

   SoundControl;

   if(net_status=ns_clnt)then net_GClient;
   replay_Code;

   {$ELSE}
   _dedCode;
   _dedScreen;
   {$ENDIF}

   PlayersCycle;

   if(G_Started)and(G_Status=gs_running)then
   begin
      _cycle_order+=1;_cycle_order:=_cycle_order mod order_period;
      _cycle_regen+=1;_cycle_regen:=_cycle_regen mod regen_period;

      if(ServerSide)then
      begin
         G_Step+=1;

         PlayersStatus(@g_player_status,@g_cl_units);

         GameModeCPoints;
         case g_mode of
         gm_invasion  : GameModeInvasion;
         gm_royale    : begin
                           if(_cycle_order=0)then
                            if(g_royal_r>0)then g_royal_r-=1;
                           GameDefaultEndConditions;
                        end;
         gm_capture,
         gm_KotH      : ;
         else           GameDefaultEndConditions;
         end;
      end;
      _obj_cycle;
   end;

   if(net_status=ns_srvr)then net_GServer;
end;


