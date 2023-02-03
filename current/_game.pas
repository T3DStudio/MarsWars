
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
      PlayerSetAllowedUnits(p,[ UID_HSymbol,UID_HASymbol,
                                UID_UGenerator,UID_UAGenerator ],0,false);


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

procedure PlayerSetState(p,st:byte);
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

   vid_menu_redraw  := true;

   Map_premap;

   {$IFDEF _FULLGAME}
   _fsttime:=false;
   _warpten:=false;

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
   then _unit_add(x,y,0,uid,pl,true,false,0)
   else
   begin
      if(c>5)then
      begin
         _unit_add(x,y,0,uid,pl,true,false,0);
         c-=1;
      end;
      ds :=map_mw div 2;
      d  :=point_dir(x,y,ds,ds);
      ds :=360 div (c+1);
      r  :=46+c*18;
      for i:=0 to c do
      begin
         _unit_add(
         x+trunc(r*cos(d*degtorad)),
         y-trunc(r*sin(d*degtorad)),
         0,uid,pl,true,false,0);

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

         if(state=ps_play)then ai_skill:=player_default_ai_level;// g_ai_slots;//
      end;
   end;

   for p:=1 to MaxPlayers do
    with _players[p] do
     if(state<>ps_none)then
     begin
        PlayerSetSkirmishTech(p);
        ai_PlayerSetSkirmishSettings(p);
        GameCreateStartBase(map_psx[p],map_psy[p],uid_race_start_base[race],p,g_start_base);
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
       vid_blink_timer1:=2;
       map_RedrawMenuMinimap;
       d_Panel(r_uipanel);
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

   if(andstart)then GameMakeDestroy;
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
                      ui_UnitSelectedNU:=unum;
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
   exit;

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
              if(ttl=ClientTTL)or(ttl=fr_fps1)then vid_menu_redraw:=true;
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
           if(state=ps_comp)then ai_player_code(p);

           if(build_cd>0)then build_cd-=1;

           PlayerExecuteOrder(p);

           if(prod_error_cndt>0)then
            GameLogCantProduction(p,prod_error_uid,prod_error_utp,prod_error_cndt,prod_error_x,prod_error_y,false);
           prod_error_cndt  :=0;
        end;
     end;
end;

procedure g_inv_CalcWave;
const min_wave_time = fr_fps1*15;
var a,i:integer;
begin
   case g_inv_wave_n of
   1  : g_inv_wave_t_next:=fr_fps1*90;
   else g_inv_wave_t_next:=fr_fps1*90; //g_inv_wave_t_curr;
   end;

   g_inv_limit:=ul5+(g_inv_wave_n-1)*ul8;

  { a:=0;
   for i:=1 to MaxPlayers do
    with _players[i] do
    if(state=ps_play)then inc(a,ucl_c[false]);

   dec(g_inv_wave_t_next, g_inv_wave_n*fr_fps1*2);
   dec(g_inv_wave_t_next,(a div 15)*fr_fps1);
   dec(g_inv_wave_t_next, ((map_mw-MaxSMapW) div 100)*fr_fps1);
   dec(g_inv_wave_t_next, g_startb*5*fr_fps1);

   if(g_inv_wave_t_next<min_wave_time)then g_inv_wave_t_next:=min_wave_time;

   g_inv_wt:=0;

   case g_inv_wave_n of
   1  : g_inv_mn:=30;
   2  : g_inv_mn:=60;
   3  : g_inv_mn:=90;
   else g_inv_mn:=MaxPlayerUnits;
   end;                        }
end;

procedure GameModeInvasionSpawnMonsters(limit:integer;MaxMonsterLimit:integer);
var tx,ty:integer;
function SpawnMonster(uid:byte):boolean;
begin
   SpawnMonster:=false;
   if(limit<_uids[uid]._limituse)then exit;
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
   SpawnMonster:=_unit_add(tx,ty,0,uid,0,true,true,0);
   if(SpawnMonster)then limit-=_uids[uid]._limituse;
end;
function SpawnL(ul:integer):boolean;
begin
   SpawnL:=false;
   if(MaxMonsterLimit>=ul)then
    case ul of
ul10 : case random(2) of
       0 :SpawnL:=SpawnMonster(UID_Cyberdemon);
       1 :SpawnL:=SpawnMonster(UID_Mastermind);
       end;
ul4  : case random(4) of
       0 :SpawnL:=SpawnMonster(UID_Archvile);
       1 :SpawnL:=SpawnMonster(UID_Terminator);
       2 :SpawnL:=SpawnMonster(UID_Tank);
       3 :SpawnL:=SpawnMonster(UID_Flyer);
       end;
ul3  : case random(3) of
       0 :SpawnL:=SpawnMonster(UID_Baron);
       1 :SpawnL:=SpawnMonster(UID_Mancubus);
       2 :SpawnL:=SpawnMonster(UID_Arachnotron);
       end;
ul2  : case random(9) of
       0 :SpawnL:=SpawnMonster(UID_Demon);
       1 :SpawnL:=SpawnMonster(UID_Cacodemon);
       2 :SpawnL:=SpawnMonster(UID_Knight);
       3 :SpawnL:=SpawnMonster(UID_Revenant);
       4 :SpawnL:=SpawnMonster(UID_BFGMarine);
       5 :SpawnL:=SpawnMonster(UID_ZBFGMarine);
       6 :SpawnL:=SpawnMonster(UID_SSergant);
       7 :SpawnL:=SpawnMonster(UID_ZSSergant);
       8 :SpawnL:=SpawnMonster(UID_UACBot);
       end;
ul1  : case random(15) of
       0 :SpawnL:=SpawnMonster(UID_Imp);
       1 :SpawnL:=SpawnMonster(UID_Sergant);
       2 :SpawnL:=SpawnMonster(UID_Commando);
       3 :SpawnL:=SpawnMonster(UID_Antiaircrafter);
       4 :SpawnL:=SpawnMonster(UID_SiegeMarine);
       5 :SpawnL:=SpawnMonster(UID_Plasmagunner);
       6 :SpawnL:=SpawnMonster(UID_FPlasmagunner);
       7 :SpawnL:=SpawnMonster(UID_ZSergant);
       8 :SpawnL:=SpawnMonster(UID_ZCommando);
       9 :SpawnL:=SpawnMonster(UID_ZAntiaircrafter);
       10:SpawnL:=SpawnMonster(UID_ZSiegeMarine);
       11:SpawnL:=SpawnMonster(UID_ZPlasmagunner);
       12:SpawnL:=SpawnMonster(UID_ZFPlasmagunner);
       13:SpawnL:=SpawnMonster(UID_ZEngineer);
       14:SpawnL:=SpawnMonster(UID_Pain);
       end;
    end;
end;
function SpawnLR:boolean;
begin
   case random(5) of
   0 : SpawnLR:=SpawnL(ul1 );
   1 : SpawnLR:=SpawnL(ul2 );
   2 : SpawnLR:=SpawnL(ul3 );
   3 : SpawnLR:=SpawnL(ul4 );
   4 : SpawnLR:=SpawnL(ul10);
   end;
end;
begin
   while(limit>0)and(_players[0].army<MaxPlayerUnits)do
    if(not SpawnLR)then
     if(not SpawnL(ul10))then
      if(not SpawnL(ul4 ))then
       if(not SpawnL(ul3 ))then
        if(not SpawnL(ul2 ))then
         if(not SpawnL(ul1 ))then break;
end;

procedure GameModeInvasion;
const max_wave_time = fr_fps1*150;
begin
   if(_players[0].armylimit=0)then
   begin
      if(g_inv_wave_t_next=0)then
      begin
         if(g_inv_wave_n>=InvMaxWaves)
         then GameSetStatusWinnerTeam(1)
         else
         begin
            g_inv_wave_n+=1;
            g_inv_CalcWave;
         end;
      end
      else
      begin
         g_inv_wave_t_next-=1;
         if(g_inv_wave_t_next=0)then
         begin
            {$IFDEF _FULLGAME}
            SoundPlayMMapAlarm(snd_teleport,false);
            {$ENDIF}
            GameModeInvasionSpawnMonsters(g_inv_limit,ul10);
         end;
      end;
   end
   else if(g_inv_wave_t_curr<max_wave_time)then g_inv_wave_t_curr+=1;
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

         PlayersStatus;

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


