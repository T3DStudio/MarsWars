
procedure PlayerSetSkirmishTech(p:byte);
begin
   with _players[p] do
   begin
      PlayerSetAllowedUnitsMax(p,[UID_HKeep         ..UID_HBarracks,
                                  UID_LostSoul      ..UID_ZBFGMarine,
                                  UID_UCommandCenter..UID_UComputerStation,
                                  UID_Engineer      ..UID_Flyer  ],
                                  MaxUnits,true);

      PlayerSetAllowedUnitsMax(p,[ UID_HMonastery ,UID_HFortress       ,UID_HAltar,
                                   UID_UTechCenter,UID_UComputerStation,UID_URMStation ],1,false);

      PlayerSetAllowedUnitsMax(p,[ UID_LostSoul, UID_Phantom ],20,false);


      case g_generators of
      0:;
      1    :PlayerSetAllowedUnitsMax(p,[ UID_HKeep     ,UID_HCommandCenter,UID_UCommandCenter],0,false);
      else  PlayerSetAllowedUnitsMax(p,[ UID_HSymbol   ,UID_HASymbol      ,UID_HKeep          ,UID_HCommandCenter,
                                         UID_UGenerator,UID_UAGenerator   ,UID_UCommandCenter],0,false);
      end;


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

procedure PlayerKill(pl:byte;instant:boolean);
var u:integer;
begin
   for u:=1 to MaxUnits do
    with _punits[u]^ do
     if(hits>0)and(playeri=pl)then unit_kill(_punits[u],instant,true,false,true,true);
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
      PlayerSetAllowedUnitsMax   (0,[],0,true);
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
   g_player_astatus:=255;

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
   uncappedFPS:=false;
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
   m_brush:=mb_empty;

   rpls_fog   :=true;

   svld_str_fname:='';

   rpls_pnu  :=0;
   rpls_plcam:=false;
   //if(rpls_state>=rpls_state_read)then
   rpls_state:=rpls_state_none;
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
   unit_add(tx,ty,0,uid    ,pl,true,false,0);
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
      r  :=70+c*28; //18
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

   if(not g_fixed_positions)then
     if not(g_mode in gm_fixed_positions)then map_ShufflePlayerStarts;

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
        if(team>0)and(0<=map_psx[p])and(map_psx[p]<=map_mw)
        then GameCreateStartBase(map_psx[p],map_psy[p],uid_race_start_fbase[race],uid_race_start_abase[race],p,g_start_base,g_generators>0);

        unit_add(map_psx[p],map_psy[p],0,UID_Imp,p,true,false,0);
     end;

   {$IFDEF _FULLGAME}
   MoveCamToPoint(map_psx[HPlayer] , map_psy[HPlayer]);
   if(_players[HPlayer].team=0)then ui_tab:=3;
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
       MainMenu :=false;
       if(menu_s2<>ms2_camp)
       then GameStartSkirmish
       else ;//_CMPMap;
       vid_panel_timer:=0;
       UIPlayer:=HPlayer;
    end;
end;

procedure MakeRandomSkirmish(andstart:boolean);
var p:byte;
begin
   if(G_Started)then exit;

   Map_randommap;

   g_mode      :=gm_scirmish;
   g_start_base:=random(gms_g_startb+1);
   g_generators:=random(gms_g_maxgens+1);

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

   if(random(3)=0)
   then g_ai_slots:=0
   else g_ai_slots:=random(player_default_ai_level+1);

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
su,eu,d: integer;
SelectBuildings,
ClearErrors,
pselected: boolean;
pu,
sability_u  : PTUnit;
sability_d  : integer;
function RectInRect(x0,y0,x1,y1,vx,vy,r:integer):boolean;
begin
   RectInRect:=((x0-r)<=vx)and(vx<=(x1+r))and((y0-r)<=vy)and(vy<=(y1+r));
end;
begin
   with _players[pl] do
   if(o_id>0)and(army>0)then
   begin
      if(pl<>HPlayer)then   // ded serverside counter
      PlayerAPMInc(pl);

      case o_id of
po_build               : if(0<o_a0)and(o_a0<255)then PlayerSetProdError(pl,lmt_argt_unit,byte(o_a0),StartBuild(o_x0,o_y0,byte(o_a0),pl),nil);
      else
        SelectBuildings:=true;
        ClearErrors:=false;

        if(o_id=po_select_rect_set)
        or(o_id=po_select_rect_add)then
        begin
           if(o_x0>o_x1)then begin su:=o_x1;o_x1:=o_x0;o_x0:=su;end;
           if(o_y0>o_y1)then begin su:=o_y1;o_y1:=o_y0;o_y0:=su;end;

           for su:=1 to MaxUnits do
            with _punits[su]^ do
             if(hits>0)and(pl=playeri)and(not IsUnitRange(transport,nil))then
              with uid^ do
               if(RectInRect(o_x0,o_y0,o_x1,o_y1,vx,vy,_r))and(not _ukbuilding)then
               begin
                  SelectBuildings:=false;
                  break;
               end;
        end;

        if(o_id=po_unit_order_set)then
          if(IsUnitRange(o_x1,@pu))then
          begin
             o_x0:=pu^.x;
             o_y0:=pu^.y;
          end;

        case o_id of
po_prod_unit_stop,
po_prod_upgr_stop,
po_prod_stop      : begin
                       su:=MaxUnits;
                       eu:=1;
                    end;
        else
           su:=1;
           eu:=MaxUnits;
        end;

     //   selected_n:=ucl_cs[true]+ucl_cs[false];
        sability_d:=sability_d.MaxValue;
        sability_u:=nil;

        while(su<>eu)do
        begin
           pu:=_punits[su];
           with pu^ do
           with uid^ do
           if(hits>0)and(not IsUnitRange(transport,nil))and(pl=playeri)then
           begin
              pselected:=isselected;

              case o_id of
// select
po_select_rect_set,
po_select_rect_add   : if(o_id=po_select_rect_set)
                       or((not isselected)and(o_id=po_select_rect_add))
                       then isselected:=RectInRect(o_x0,o_y0,o_x1,o_y1,vx,vy,_r)and(SelectBuildings or not _ukbuilding);
po_select_uid_set,
po_select_uid_add    : if(o_id=po_select_uid_set)
                       or((not isselected)and(o_id=po_select_uid_add))then
                         if(0<o_a0)and(o_a0<255)
                         then isselected:=RectInRect(o_x0,o_y0,o_x1,o_y1,vx,vy,_r)and(o_a0=uidi);
po_select_group_set,
po_select_group_add  : if(o_id=po_select_group_set)
                       or((not isselected)and(o_id=po_select_group_add))then isselected:=(group=o_a0);
po_select_special_set: isselected:=UnitF2Select(pu);

// groups
po_unit_group_set    : if(isselected)then
                       begin
                          if(0<=o_a0)and(o_a0<MaxUnitGroups)then group:=o_a0;
                       end
                       else if(group=o_a0)then group:=0;
po_unit_group_add    : if(isselected)then
                         if(0<=o_a0)and(o_a0<MaxUnitGroups)then group:=o_a0;

// unit orders
po_unit_order_set    : if(isselected)then
                         case o_a0 of
                       uo_move      : unit_SetOrder(pu,o_x1,o_x0,o_y0,-1,-1,ua_move  );
                       uo_attack    : unit_SetOrder(pu,o_x1,o_x0,o_y0,-1,-1,ua_attack);
                       uo_patrol    : unit_SetOrder(pu,0   ,o_x0,o_y0,x ,y ,ua_move  );
                       uo_apatrol   : unit_SetOrder(pu,0   ,o_x0,o_y0,x ,y ,ua_attack);
                       //uo_stay      : default
                       uo_hold      : unit_SetOrder(pu,0   ,x   ,y   ,-1,-1,ua_hold  );
                       uo_destroy   : begin unit_kill(pu,false,false,true,false,true);pselected:=isselected;end;
                       uo_sability  : if(ua_id<>ua_psability)then
                                        if(unit_sability (pu,false))then ClearErrors:=true;
                       uo_psability : if(ua_id<>ua_psability)then
                                        if(unit_psability(pu,o_x0,o_y0,o_x1,true))then
                                        begin
                                           ClearErrors:=true;
                                           d:=point_dist_int(o_x0,o_y0,x,y);
                                           if(d<sability_d)then
                                           begin
                                              sability_d:=d;
                                              sability_u:=pu;
                                           end;
                                        end;
                       uo_rebuild   : if(_unit_rebuild(pu,false))then ClearErrors:=true;
                         else         unit_SetOrder(pu,0   ,x   ,y   ,-1,-1,ua_attack);
                         end;
po_prod_stop         : if(isselected)then
                       begin
                       if(unit_ProdUnitStop(pu,255,false))then break;
                       if(unit_ProdUpgrStop(pu,255,false))then break;
                       end;
              end;

              if(0<o_a0)and(o_a0<=255)then
              begin
                 if(s_barracks<=0)or(isselected)then
                   case o_id of
po_prod_unit_start   : if(unit_ProdUnitStart(pu,o_a0      ))then begin PlayerClearProdError(player);break;end;// start  training
po_prod_unit_stop    : if(unit_ProdUnitStop (pu,o_a0,false))then break;
                   end;
                 if(s_smiths  <=0)or(isselected)then
                   case o_id of
po_prod_upgr_start   : if(unit_ProdUpgrStart(pu,o_a0      ))then begin PlayerClearProdError(player);break;end;// start  upgr
po_prod_upgr_stop    : if(unit_ProdUpgrStop (pu,o_a0,false))then break;
                   end;
              end;

              if(isselected)then
              begin
                 if(pselected=false)then
                 begin
                    unit_PC_select_inc(pu);
                    {$IFDEF _FULLGAME}
                    UpdateLastSelectedUnit(unum);
                    {$ENDIF}
                 end;
              end
              else
                if(pselected=true)then unit_PC_select_dec(pu);
           end;

           if(su>eu)
           then su-=1
           else su+=1;
        end;

        if(o_id=po_unit_order_set)then
          case o_a0 of
uo_psability : if(sability_u<>nil)then unit_psability(sability_u,o_x0,o_y0,o_x1,false);
          end;
        if(ClearErrors)then PlayerClearProdError(@_players[pl]);
      end;

      o_id:=0;
   end;
end;

procedure GameDefaultEndConditions;
var p,wteam_last,wteams_n: byte;
teams_army: array[0..MaxPlayers] of integer;
begin
   if(net_status>ns_single)and(G_Step<fr_fps1)then exit;

   wteam_last:=255;
   wteams_n  :=0;
   FillChar(teams_army,SizeOf(teams_army),0);
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

procedure DefaultDefeatConditions;
var i:byte;
begin
   for i:=1 to MaxPlayers do
     if(_players[i].army>0)then exit;
   GameSetStatusWinnerTeam(0);
end;

procedure PlayersCycle;
var p:byte;
begin
   for p:=0 to MaxPlayers do
    with _players[p] do
     if(state>ps_none)then
     begin
        if(state=PS_Play)and(p<>HPlayer)and(net_status=ns_server)then
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

        if(G_Started)and(G_Status=gs_running)then
        begin
           if(build_cd>0)then build_cd-=1;

           if(ServerSide)then
           begin
              revealed:=false;
              if(n_builders=0){$IFDEF _FULLGAME}and(menu_s2<>ms2_camp){$ENDIF}then
                if(g_mode<>gm_invasion)
                or(p>0)then revealed:=true;

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

   vid_panel_timer+=1;vid_panel_timer:=vid_panel_timer mod vid_panel_period;

   r_blink1_colorb  :=vid_blink_timer1>vid_blink_periodh;
   r_blink2_colorb  :=vid_blink_timer2>vid_blink_period1;

   r_blink1_color_BG:=ui_blink_color1[r_blink1_colorb];
   r_blink1_color_BY:=ui_blink_color2[r_blink1_colorb];
   r_blink2_color_BG:=ui_blink_color1[r_blink2_colorb];
   r_blink2_color_BY:=ui_blink_color2[r_blink2_colorb];

   SoundControl;

   if(net_status=ns_client)then
    if(net_svsearch)
    then net_Discowering
    else net_Client;
   replay_Code;

   {$ELSE}
   Dedicated_Code;
   Dedicated_Screen;
   {$ENDIF}

   PlayersCycle;

   if(G_Started)and(G_Status=gs_running)then
   begin
      _cycle_order+=1;_cycle_order:=_cycle_order mod order_period;
      _cycle_regen+=1;_cycle_regen:=_cycle_regen mod regen_period;

      if(ServerSide)then
      begin
         G_Step+=1;

         UpdatePlayersStatus;

         GameModeCPoints;
         case g_mode of
         gm_invasion  : begin
                        GameModeInvasion;
                        DefaultDefeatConditions;
                        end;
         gm_royale    : begin
                           if(_cycle_order=0)then
                             if(g_royal_r>0)then g_royal_r-=1;
                           GameDefaultEndConditions;
                        end;
         gm_capture,
         gm_KotH      : DefaultDefeatConditions;
         else           GameDefaultEndConditions;
         end;
      end;
      GameObjectsCode;
   end;

   if(net_status=ns_server)then net_Server;
end;


