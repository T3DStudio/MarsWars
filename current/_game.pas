
procedure PlayerSetSkirmishTech(p:byte);
begin
   with g_players[p] do
   begin
      PlayerSetAllowedUnits(p,[ UID_HKeep         ..UID_HBarracks,
                                UID_LostSoul      ..UID_ZBFGMarine,
                                UID_UCommandCenter..UID_UComputerStation,
                                UID_Engineer      ..UID_Flyer  ],
                                MaxUnits,true);

      PlayerSetAllowedUnits(p,[ UID_LostSoul, UID_Phantom ],20,false);

      if(g_generators>0)then
      PlayerSetAllowedUnits(p,[ UID_HSymbol1   ,UID_HSymbol2   ,
                                UID_UGenerator1,UID_UGenerator2],0,false);


      PlayerSetAllowedUpgrades(p,[0..255],255,true); //

      a_rebuild:=[1..255];
      a_ability:=[1..255];
   end;
end;

function PlayersSwap(p0,p1:byte):boolean;
var tp:TPlayer;
 t0,t1:byte;
begin
   //p0 - target slot
   //p1 - player target
   //p1 -> p0
   PlayersSwap:=false;

   if(g_started)
   {$IFDEF _FULLGAME}
   or(menu_s2=ms2_camp)
   {$ENDIF}then exit;

   if(p0>MaxPlayers)
   or(p1>MaxPlayers)
   or(p0=0)
   or(p1=0)then exit;

   if(g_players[p0].state=ps_play)
   or(p1=p0)then exit;

   PlayersSwap:=true;

   {$IFDEF _FULLGAME}
   if(net_status=ns_client)then
   begin
      net_clearbuffer;
      net_writebyte(nmid_lobby_PPosSwap);
      net_writebyte(p0);
      net_send(net_cl_svip,net_cl_svport);
      exit;
   end;
   {$ENDIF}

   t0:=g_players[p0].team;
   t1:=g_players[p1].team;

   tp:=g_players[p0];
   g_players[p0]:=g_players[p1];
   g_players[p1]:=tp;

   g_players[p0].pnum:=p0;
   g_players[p1].pnum:=p1;

   g_players[p0].team:=PlayerValidateTeam(p0,t1);
   g_players[p1].team:=PlayerValidateTeam(p1,t0);

   if(HPlayer=p1)then HPlayer:=p0
   else
     if(HPlayer=p0)then HPlayer:=p1;
end;

procedure PlayerSetState(p,newstate:byte);
begin
   with g_players[p] do
   begin
      case newstate of
PS_None: begin ready:=false;name :=str_ps_none;       ttl:=0;end;
PS_Comp: begin ready:=true; name :=ai_name(ai_skill); ttl:=0;end;
PS_Play: begin ready:=false;name :='';                ttl:=0;end;
      end;
      team:=PlayerValidateTeam(p,team);
      state:=newstate;
   end;
end;

procedure PlayerKill(pl:byte;instant:boolean);
var u:integer;
begin
   for u:=1 to MaxUnits do
    with g_punits[u]^ do
     if(playeri=pl)then
      unit_kill(g_punits[u],instant,true,false,true,true);
end;

procedure PlayersSetDefault;
var p:byte;
begin
   FillChar(g_players,SizeOf(TPList),0);
   for p:=0 to MaxPlayers do
    with g_players[p] do
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

   with g_players[0] do
   begin
      race     :=r_hell;
      state    :=ps_comp;
      PlayerSetAllowedUnits   (0,[],0,true);
      PlayerSetAllowedUpgrades(0,[],0,true);
   end;

   FillChar(_playerAPM,SizeOf(_playerAPM),0);

   {$IFDEF _FULLGAME}
   HPlayer:=1;
   with g_players[HPlayer] do
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
   with g_players[HPlayer] do
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
   FillChar(g_missiles,SizeOf(g_missiles),0);
   FillChar(g_units   ,SizeOf(g_units   ),0);

   for u:=0 to MaxUnits do
   with g_units[u] do
   begin
      hits  :=dead_hits;
      player:=@g_players[playeri];
      uid   :=@g_units  [uidi   ];
   end;
   LastCreatedUnit :=0;
   LastCreatedUnitP:=@g_units[LastCreatedUnit];

   PlayersSetDefault;

   UnitStepTicks    := 8;

   g_inv_wave_n     := 0;
   g_inv_wave_t_next:= 0;
   g_inv_wave_t_curr:= 0;
   g_royal_r        := 0;

   g_cycle_order     := 0;
   g_cycle_regen     := 0;

   Map_premap;
   {$IFDEF DEBUG0}
   _warpten:=false;
   {$ENDIF}

   {$IFDEF _FULLGAME}
   uncappedFPS:=false;

   vid_menu_redraw  := true;

   vid_cam_x:=-vid_panelw;
   vid_cam_y:=0;
   CameraBounds;

   vid_blink_timer1:=0;
   vid_blink_timer2:=0;
   vid_vsls:=0;

   ui_tab :=0;
   ui_UnitSelectedNU:=0;
   ui_UnitSelectedPU:=0;

   FillChar(g_effects ,SizeOf(g_effects ),0);
   FillChar(ui_alarms,SizeOf(ui_alarms),0);

   ingame_chat :=0;
   net_chat_str:='';
   net_cl_svttl:=0;
   net_cl_Hoster:=255;
   net_error_timer:=0;

   ui_umark_u:=0;
   ui_umark_t:=0;

   mouse_select_x0:=-1;
   m_brush:=-32000;

   rpls_fog   :=true;

   svld_str_fname:='';

   rpls_pnu  :=0;
   rpls_plcam:=false;
   //if(rpls_state>=rpls_read)then
   rpls_state:=rpls_none;
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
   if(AdvancedBase)
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
   with g_players[p] do
   begin
      team:=PlayerValidateTeam(p,team);

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
    with g_players[p] do
     if(state<>ps_none)then
     begin
        PlayerSetSkirmishTech(p);
        ai_PlayerSetSkirmishSettings(p);
        if(team>0)then
           if(g_generators>0)
           then GameCreateStartBase(map_psx[p],map_psy[p],uid_race_start_fbase[race],uid_race_start_abase[race],p,1,true )
           else GameCreateStartBase(map_psx[p],map_psy[p],uid_race_start_fbase[race],uid_race_start_abase[race],p,0,false);
     end;

   {$IFDEF _FULLGAME}
   MoveCamToPoint(map_psx[HPlayer] , map_psy[HPlayer]);
   if(g_players[HPlayer].team=0)then
   begin
      ui_tab:=3;
      UIPlayer:=0;
   end;
   {$ENDIF}
end;


{$IFDEF _FULLGAME}
procedure GameMakeStartBreak;
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
       if(menu_s2<>ms2_camp)
       then GameStartSkirmish
       else cmp_StartMission;
       MainMenu :=false;
       G_Started:=true;
       UIPlayer :=HPlayer;
       vid_blink_timer1:=1;
    end;
end;

function CheckSimpleClick(o_x0,o_y0,o_x1,o_y1:integer):boolean;
begin
   CheckSimpleClick:=point_dist_rint(o_x0,o_y0,o_x1,o_y1)<4;
end;

function UIAllowSelecting(playern:byte):boolean;
begin
   UIAllowSelecting:=false;
   with g_players[playern] do
     if(UIPlayer<>playern)
     or(observer)
     or(army=0)
     or(rpls_state=rpls_read)then exit;
   if(g_status<>gs_running)then exit;
   UIAllowSelecting:=true;
end;

procedure units_SelectRect(add:boolean;playern:byte;x0,y0,x1,y1:integer;fuid:byte);
var u ,
usel_max:integer;
wassel,
SelectBuildings:boolean;
begin
   if(not UIAllowSelecting(playern))then exit;

   if(x0>x1)then begin u:=x1;x1:=x0;x0:=u;end;
   if(y0>y1)then begin u:=y1;y1:=y0;y0:=u;end;
   usel_max:=32000;
   if(CheckSimpleClick(x0,y0,x1,y1))then usel_max:=1;

   SelectBuildings:=true;
   if(add)
   then SelectBuildings:=(g_players[playern].ucl_cs[false]=0)
   else
     if(fuid=255)then
       for u:=1 to MaxUnits do
        with g_punits[u]^ do
         if(hits>0)and(playern=playeri)and(not IsUnitRange(transport,nil))then
          with uid^ do
           if(not _ukbuilding)then
             if((x0-_r)<=vx)and(vx<=(x1+_r))
            and((y0-_r)<=vy)and(vy<=(y1+_r))then
             begin
                SelectBuildings:=false;
                break;
             end;

   for u:=1 to MaxUnits do
     with g_punits[u]^ do
       if(hits>0)and(playern=playeri)and(not IsUnitRange(transport,nil))then
       begin
          wassel:=sel;

          if(not add)then sel:=false;
          if(usel_max>0)then
            if(not add)or(not wassel and add)then
              if(fuid=255)or(fuid=uidi)then
                with uid^ do
                  sel:=((x0-_r)<=vx)and(vx<=(x1+_r))
                    and((y0-_r)<=vy)and(vy<=(y1+_r))
                    and(SelectBuildings or not _ukbuilding);

          if(wassel<>sel)then
            if(sel)then
            begin
               unit_counters_inc_select(g_punits[u]);
               UpdateLastSelectedUnit(unum);
            end
            else unit_counters_dec_select(g_punits[u]);
          if(sel)and(usel_max>0)then usel_max-=1;
       end;
end;
procedure units_SelectGroup(add:boolean;playern,fgroup:byte);
var u:integer;
wassel:boolean;
begin
   if(not UIAllowSelecting(playern))then exit;

   for u:=1 to MaxUnits do
    with g_punits[u]^ do
     if(hits>0)and(playern=playeri)and(not IsUnitRange(transport,nil))then
     begin
        wassel:=sel;

        if(not add)then sel:=false;
        if(not add)or(not wassel and add)then
          case fgroup of
          0..
          MaxUnitGroups: sel:=group=fgroup;
          254          : sel:=UnitF1Select(g_punits[u]);
          255          : sel:=UnitF2Select(g_punits[u]);
          end;

        if(wassel<>sel)then
          if(sel)
          then unit_counters_inc_select(g_punits[u])
          else unit_counters_dec_select(g_punits[u]);

        if(sel)then UpdateLastSelectedUnit(unum);
     end;
end;
procedure units_Grouping(add:boolean;playern,fgroup:byte);
var u:integer;
begin
   if(not UIAllowSelecting(playern))then exit;

   if(fgroup<=MaxUnitGroups)then
     for u:=1 to MaxUnits do
       with g_punits[u]^ do
         if(hits>0)and(playern=playeri)and(not IsUnitRange(transport,nil))then
           case add of
           false: if(sel)
                  then group:=fgroup
                  else
                    if(group=fgroup)then group:=0;
           true : if(sel)
                  then group:=fgroup;
           end;
end;


{$IFDEF UNITDATA}
function CheckUIDBaseFlags(tuid:PTUID;flags:cardinal):boolean;
begin
   CheckUIDBaseFlags:=false;

   if((flags and wtr_unit    )=0)and(not tuid^._ukbuilding   )then exit;
   if((flags and wtr_building)=0)and(    tuid^._ukbuilding   )then exit;

   if((flags and wtr_bio     )=0)and(not tuid^._ukmech       )then exit;
   if((flags and wtr_mech    )=0)and(    tuid^._ukmech       )then exit;

   if((flags and wtr_light   )=0)and    (tuid^._uklight      )then exit;
   if((flags and wtr_heavy   )=0)and not(tuid^._uklight      )then exit;

   if (tuid<>@_uids[UID_LostSoul])
   and(tuid<>@_uids[UID_Phantom ])then
   begin
   if((flags and wtr_ground  )=0)and(tuid^._ukfly=uf_ground  )then exit;
   if((flags and wtr_fly     )=0)and(tuid^._ukfly=uf_fly     )then exit;
   end;

   CheckUIDBaseFlags:=true;
end;

function WeaponCanAttackUid(pweap:PTUWeapon;uid:byte):single;
var dm:byte;
begin
   WeaponCanAttackUid:=0;

   with pweap^ do
   if(CheckUIDBaseFlags(@_uids[uid],aw_tarf))and(uid in aw_uids)then
   if(aw_type=wpt_missle)
   or(aw_type=wpt_directdmg)
   or(aw_type=wpt_unit)then
   begin
      WeaponCanAttackUid:=1;

      if(aw_dmod>0)then
        for dm:=0 to MaxDamageModFactors do
          with _dmods[aw_dmod][dm] do
            if(CheckUIDBaseFlags(@_uids[uid],dm_flags))then WeaponCanAttackUid*=(dm_factor/100);
   end;
end;

function TSOB2Surface(psob:PTSoB):pSDL_Surface;
const row = 7;
var
u,n,
x,y,
w,h:byte;
begin
   TSOB2Surface:=nil;

   n:=0;
   for u:=0 to 255 do
     if(u in psob^)then
       n+=1;

   if(n>0)then
   begin
      if(n<=row)then
      begin
         w:=n;
         h:=1;
      end
      else
      begin
         w:=row;
         h:=(n div row);
         if(n mod row)>0 then h+=1;
         //writeln(n,' ',w,' ',h,' ',(n mod row));
      end;

      TSOB2Surface:=_createSurf(vid_BWd*w,vid_BWd*h);
      x:=0;
      y:=0;
      for u:=0 to 255 do
        if(u in psob^)then
        begin
          _draw_surf(TSOB2Surface,x*vid_BWd,y*vid_BWd,_uids[u].un_btn2.surf);
          x+=1;
          if(x>=row)then
          begin
             x:=0;
             y+=1;
          end;
        end;
   end;
end;

procedure save_surf(fname:shortstring;surf:pSDL_Surface);
begin
   if(surf=nil)then exit;
   fname:='temp\'+fname+'.bmp'+#0;
   sdl_saveBMP(surf,@fname[1]);
   sdl_freesurface(surf);
end;

procedure test_UnitsSpec;
var
unit2good,
unit2fear,
unit2usles : array[byte] of set of byte;
var
u1,u2,w:byte;
dmg1,dmg2,t  :single;
pu1,pu2:PTUID;
begin
   FillChar(unit2good ,SizeOf(unit2good  ),0);
   FillChar(unit2fear ,SizeOf(unit2fear  ),0);
   FillChar(unit2usles,SizeOf(unit2usles ),0);

   for u1:=0 to 255 do
   for u2:=0 to 255 do
   begin
      pu1:=@_uids[u1];
      pu2:=@_uids[u2];

      if(pu1^._mhits<=0)
      or(pu2^._mhits<=0)
      or(pu1^._ucl=255)
      or(pu2^._ucl=255)then continue;

      if(pu1^._attack=0)then continue;

      dmg1:=0;
      dmg2:=0;
      for w:=0 to MaxUnitWeapons do
      begin
         t:=WeaponCanAttackUid(@pu1^._a_weap[w],u2);
         if(t>dmg1)then dmg1:=t;

         t:=WeaponCanAttackUid(@pu2^._a_weap[w],u1);
         if(t>dmg2)then dmg2:=t;
      end;

      //if(dmg1>1)or((pu2^._attack>0)or(not pu2^._ukbuilding))then
      //  if(dmg1>dmg2)and((dmg1>1)or(dmg2=0))then unit2good[u1]+=[u2];

      if(dmg1=0)and(dmg2>0)
      then unit2usles[u1]+=[u2]
      else
        if(dmg1<dmg2)then unit2fear[u1]+=[u2];

      {if(u1=UID_Mastermind)and(u2=UID_HSymbol1)then writeln(dmg1:3:3,' ',dmg2:3:3,' ',pu2^._attack);
}
   end;

  {for u1 in [UID_HTower] do
   begin
      writeln(_uids[u1].un_txt_name);
      write('Good against: ');
      for u2:=0 to 255 do
        if(u2 in unit2good[u1])then write(_uids[u2].un_txt_name,', ');
      writeln;
      write('Bad against: ');
      for u2:=0 to 255 do
        if(u2 in unit2fear[u1])then write(_uids[u2].un_txt_name,', ');
      writeln;
      write('Usles against: ');
      for u2:=0 to 255 do
        if(u2 in unit2usles[u1])then write(_uids[u2].un_txt_name,', ');
      writeln;
   end;}

   for u1 in [0..255] do     //
   begin
      pu1:=@_uids[u1];

      if(pu1^._mhits<=0)
      or(pu1^._ucl=255)then continue;
      if(pu1^._attack=0)then continue;

      save_surf(_uids[u1].un_txt_name+'_good' ,TSOB2Surface(@unit2good [u1]));
      save_surf(_uids[u1].un_txt_name+'_bad'  ,TSOB2Surface(@unit2fear [u1]));
      save_surf(_uids[u1].un_txt_name+'_usles',TSOB2Surface(@unit2usles[u1]));
   end;
   //for u1 in [0..255] do
   //  save_surf('btn_'+_uids[u1].un_txt_name,_uids[u1].un_btn.surf);
end;
{$ENDIF}

{$ELSE}
{$include _ded.pas}
{$ENDIF}

procedure MakeRandomSkirmish;
var p:byte;
begin
   Map_randommap;

   case random(7) of
   0:   g_mode:=gm_royale;
   1:   g_mode:=gm_capture;
   2:   g_mode:=gm_KotH;
   else g_mode:=gm_scirmish;
   end;

   if(random(3)=0)
   then g_generators:=random(gms_g_maxgens)+1
   else g_generators:=0;

   for p:=HPlayer+1 to MaxPlayers do
     with g_players[p] do
       if(state<>ps_play)then
       begin
          race :=random(r_cnt+1);
          mrace:=race;

          team:=1+random(4);

          ai_skill:=random(6)+2;

          if(random(2)=0)
          then PlayerSetState(p,ps_none)
          else PlayerSetState(p,ps_comp);
       end;

   {$IFDEF _FULLGAME}
   PlayersSwap(random(MaxPlayers)+1,HPlayer);
   {$ENDIF}

   if(random(3)=0)
   then g_ai_slots:=0
   else g_ai_slots:=random(player_default_ai_level+1);

   g_fixed_positions:=random(2)=0;

   Map_premap;
end;

procedure PlayerExecuteOrder(pl:byte);
var
_su,_eu: integer;
pu,
tar_u : PTUnit;
tar_d : integer;
tar_ex: boolean;
begin
   with g_players[pl] do
   if(o_id>0)and(army>0)then
   begin
      if(pl<>HPlayer)then   // ded serverside counter
      PlayerAPMInc(pl);

      case o_id of
uo_build   : if(0<o_x1)and(o_x1<=255)then PlayerSetProdError(pl,lmt_argt_unit,byte(o_x1),unit_start_build(o_x0,o_y0,byte(o_x1),pl),nil);
      else
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

         tar_d :=tar_d.MaxValue;
         tar_u :=nil;
         tar_ex:=false;

         while(_su<>_eu)do
         begin
            pu:=g_punits[_su];
            with pu^ do
            with uid^ do
             if(hits>0)and(not IsUnitRange(transport,nil))and(pl=playeri)then
             begin
                if(o_id=uo_corder)then
                  case o_x0 of
                  co_supgrade : if(s_smiths  <=0)or(sel)then UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_ProdStartUpgrade(pu,o_y0      ,true)=0,true,true );
                  co_cupgrade : if(s_smiths  <=0)or(sel)then UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_ProdStopUpgrade (pu,o_y0,false,true)=0,true,false);
                  co_suprod   : if(s_barracks<=0)or(sel)then UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_ProdStartUnit   (pu,o_y0      ,true)=0,true,true );
                  co_cuprod   : if(s_barracks<=0)or(sel)then UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_ProdStopUnit    (pu,o_y0,false,true)=0,true,false);
                  co_pcancle  : if(sel)then
                                begin
                                   UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_ProdStopUpgrade(pu,o_y0,false,true)=0,true,false);
                                   UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_ProdStopUnit   (pu,o_y0,false,true)=0,true,false);
                                end;
                  {co_supgrade : if(s_smiths  <=0)or(sel)then if(unit_ProdStartUpgrade(pu,o_y0))then begin PlayerClearProdError(player);break;end;// start  upgr
                  co_cupgrade : if(s_smiths  <=0)or(sel)then if(unit_ProdStopUpgrade (pu,o_y0,false))then break;                                       // cancle upgr
                  co_suprod   : if(s_barracks<=0)or(sel)then if(unit_ProdStartUnit(pu,o_y0      ))then begin PlayerClearProdError(player);break;end;// start  training
                  co_cuprod   : if(s_barracks<=0)or(sel)then if(unit_ProdStopUnit(pu,o_y0,false))then break;                                       // cancle training
                  co_pcancle  : if(sel)then
                                begin
                                if(unit_ProdStopUnit(pu,255,false))then break;
                                if(unit_ProdStopUpgrade (pu,255,false))then break;
                                end; }
                  end;

                if(sel)then
                begin
                   case o_id of
               uo_corder     : case o_x0 of
                               co_sability,
                               co_pability: if(_ability=o_a0)then
                                              if(uo_id<>ua_psability)or(s_all=1)then
                                                case o_x0 of
                                                co_sability: UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_sability(pu               ,true)=0,false,true );
                                                co_pability: UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_pability(pu,o_y0,o_x1,o_y1,true)=0,false,true );
                                                end;
                               co_rebuild : if(_rebuild_uid=o_a0)then
                                              UnitOrderSetNearestTarget(pu,o_x1,o_y1,@tar_u,@tar_d,@tar_ex,unit_rebuild(pu,true)=0,true ,true );

                               co_destroy : unit_kill(pu,false,false,true,false,true);

                               co_rcamove,
                               co_rcmove   : begin     // right click
                                                uo_tar:=0;
                                                uo_x  :=o_x1;
                                                uo_y  :=o_y1;
                                                uo_bx :=-1;

                                                if(o_y0<>unum)then uo_tar:=o_y0;
                                                if(o_x0<>co_rcmove)or(speed<=0)
                                                then uo_id:=ua_amove
                                                else uo_id:=ua_move;
                                             end;
                               co_stand    : unit_SetDefaultUO(pu,ua_hold, 0   ,x      ,y,-1,-1,true ,false);
                               co_move     : unit_SetDefaultUO(pu,ua_move ,o_y0,o_x1,o_y1,-1,-1,true ,false);
                               co_patrol   : unit_SetDefaultUO(pu,ua_move ,0   ,o_x1,o_y1, x, y,true ,false);
                               co_astand   : unit_SetDefaultUO(pu,ua_amove,0   ,x      ,y,-1,-1,false,false);
                               co_amove    : if(IsUnitRange(o_y0,nil))
                                        then unit_SetDefaultUO(pu,ua_move ,o_y0,o_x1,o_y1,-1,-1,false,false)
                                        else unit_SetDefaultUO(pu,ua_amove,0   ,o_x1,o_y1,-1,-1,false,false);
                               co_apatrol  : unit_SetDefaultUO(pu,ua_amove,0   ,o_x1,o_y1, x, y,false,false);
                               end;
                   end;
                end;
             end;

            if(_su>_eu)
            then _su-=1
            else _su+=1;
         end;

         if(o_id=uo_corder)and(tar_u<>nil)then
           case o_x0 of
         co_supgrade: PlayerSetProdError(pl,lmt_argt_upgr,o_y0,unit_ProdStartUpgrade(tar_u,o_y0      ,false),tar_u);
         co_cupgrade: PlayerSetProdError(pl,lmt_argt_upgr,o_y0,unit_ProdStopUpgrade (tar_u,o_y0,false,false),tar_u);
         co_suprod  : PlayerSetProdError(pl,lmt_argt_upgr,o_y0,unit_ProdStartUnit   (tar_u,o_y0      ,false),tar_u);
         co_cuprod  : PlayerSetProdError(pl,lmt_argt_upgr,o_y0,unit_ProdStopUnit    (tar_u,o_y0,false,false),tar_u);

         co_pcancle :
                   if(PlayerSetProdError(pl,lmt_argt_upgr,o_y0,unit_ProdStopUpgrade (tar_u,o_y0,false,false),tar_u))then
                      PlayerSetProdError(pl,lmt_argt_upgr,o_y0,unit_ProdStopUnit    (tar_u,o_y0,false,false),tar_u);

         co_sability: PlayerSetProdError(pl,lmt_argt_abil,o_a0,unit_sability(tar_u               ,false),tar_u);
         co_pability: PlayerSetProdError(pl,lmt_argt_abil,o_a0,unit_pability(tar_u,o_y0,o_x1,o_y1,false),tar_u);
         co_rebuild : PlayerSetProdError(pl,lmt_argt_unit,o_a0,unit_rebuild (tar_u               ,false),tar_u);
           end;
      end;

      o_id:=0;
   end;
end;

procedure GameDefaultEndConditions;
var p,wteam_last,wteams_n: byte;
teams_army: array[0..MaxPlayers] of integer;
begin
   if(net_status>ns_none)and(G_Step<fr_fps1)then exit;

   wteam_last:=255;
   wteams_n  :=0;
   FillChar(teams_army,SizeOf(teams_army),0);
   for p:=0 to MaxPlayers do
    with g_players[p] do
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
     if(g_players[i].army>0)then exit;
   GameSetStatusWinnerTeam(0);
end;

procedure PlayersCycle;
var p:byte;
begin
   for p:=0 to MaxPlayers do
    with g_players[p] do
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
              if(e_builders=0){$IFDEF _FULLGAME}and(menu_s2<>ms2_camp){$ENDIF}then
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
           end;

           if(prod_error_cndt>0)then
             GameLogCantProduction(p,prod_error_uid,prod_error_utp,prod_error_cndt,prod_error_x,prod_error_y,not ServerSide);
           prod_error_cndt  :=0;
        end;
     end;

   for p:=0 to MaxPlayers do PlayerAPMUpdate(p);
end;

function PlayerAILevelLoop(player:byte):boolean;
begin
   PlayerAILevelLoop:=false;

   if(g_started)
   {$IFDEF _FULLGAME}
   or(menu_s2=ms2_camp)
   {$ENDIF}then exit;

   if(0<player)and(player<=MaxPlayers)then
     with g_players[player] do
       if(state=PS_Comp)then
       begin
          PlayerAILevelLoop:=true;
          {$IFDEF _FULLGAME}
          if(net_status=ns_client)then
          begin
             net_clearbuffer;
             net_writebyte(nmid_lobby_PAIUp);
             net_writebyte(player);
             net_send(net_cl_svip,net_cl_svport);
             exit;
          end;
          {$ENDIF}
          ai_skill+=1;
          if(ai_skill>gms_g_maxai)then ai_skill:=1;
          name:=ai_name(ai_skill);
       end;
end;

function PlayerAIToggle(player:byte;check:boolean):boolean;
begin
   PlayerAIToggle:=false;

   if(g_started)
   {$IFDEF _FULLGAME}
   or(menu_s2=ms2_camp)
   {$ENDIF}then exit;

   if(0<player)and(player<=MaxPlayers)then
     with g_players[player] do
       if(state<>PS_Play)then
       begin
          PlayerAIToggle:=true;
          if(check)then exit;

          {$IFDEF _FULLGAME}
          if(net_status=ns_client)then
          begin
             net_clearbuffer;
             net_writebyte(nmid_lobby_PAIToggle);
             net_writebyte(player);
             net_send(net_cl_svip,net_cl_svport);
             exit;
          end;
          {$ENDIF}

          if(state<>ps_none)
          then PlayerSetState(player,PS_None)
          else
          begin
             PlayerSetState(player,PS_Comp);
             if(team=0)then team:=player;
          end;
       end;
end;

function PlayerTeamChange(player:byte;forward,check:boolean):boolean;
procedure HumanTeamRoll(pvar:pbyte);
begin
   if(g_mode in gm_fixed_teams)then
   begin
      if(pvar^=0)
      then pvar^:=PlayerGetFixedTeams(g_mode,player)
      else pvar^:=0;
   end
   else ScrollByte(pvar,forward,0,MaxPlayers);
end;

begin
   PlayerTeamChange:=false;

   if(g_started)
   {$IFDEF _FULLGAME}
   or(menu_s2=ms2_camp)
   {$ENDIF}
   then exit;


   if(0<player)and(player<=MaxPlayers)then
     with g_players[player] do
       if(player=HPlayer)and(net_status=ns_client)then
       begin
          {$IFDEF _FULLGAME}
          PlayerTeamChange:=true;
          if(check)then exit;

          if(g_mode in gm_fixed_teams)
          then HumanTeamRoll(@PlayerTeam)
          else ScrollByte(@PlayerTeam,forward,0,MaxPlayers);
          {$ENDIF}
       end
       else
         if(state=PS_Comp)or(player=HPlayer)then
         begin
            if(g_mode in gm_fixed_teams)then
              if(state=PS_Comp)then exit;

            PlayerTeamChange:=true;

            if(check)then exit;

            {$IFDEF _FULLGAME}
            if(net_status=ns_client)then
            begin
               net_clearbuffer;
               net_writebyte(nmid_lobby_PTeam);
               net_writebyte(player);
               net_writebool(forward);
               net_send(net_cl_svip,net_cl_svport);
               exit;
            end;
            {$ENDIF}
            if(state=PS_Comp)
            then ScrollByte(@team,forward,1,MaxPlayers)
            else HumanTeamRoll(@team);
         end;
end;

function PlayerRaceChange(player:byte;check:boolean):boolean;
begin
   PlayerRaceChange:=false;

   if(g_started)
   {$IFDEF _FULLGAME}
   or(menu_s2=ms2_camp)
   {$ENDIF}
   then exit;

   if(0<player)and(player<=MaxPlayers)then
     with g_players[player] do
      if(team>0)then
       if(player=HPlayer)and(net_status=ns_client)then
       begin
          {$IFDEF _FULLGAME}
          PlayerRaceChange:=true;
          if(check)then exit;

          PlayerRace+=1;
          if(PlayerRace>r_cnt)then PlayerRace:=0;
          {$ENDIF}
       end
       else
         if(state=PS_Comp)or(player=HPlayer)then
         begin
            PlayerRaceChange:=true;
            if(check)then exit;

            {$IFDEF _FULLGAME}
            if(net_status=ns_client)then
            begin
               net_clearbuffer;
               net_writebyte(nmid_lobby_PRace);
               net_writebyte(player);
               net_send(net_cl_svip,net_cl_svport);
               exit;
            end;
            {$ENDIF}

            race+=1;
            if(race>r_cnt)then race:=0;
            mrace:=race;
         end;
end;

procedure menu_GameMapSetting(param_type:byte;forward:boolean);
begin
   {$IFDEF _FULLGAME}
   if(net_status=ns_client)then
   begin
      case param_type of
      nmid_lobby_MSeed,
      nmid_lobby_MSize,
      nmid_lobby_MObs,
      nmid_lobby_MSym,
      nmid_lobby_MRandom,
      nmid_lobby_GMode,
      nmid_lobby_GFixPos,
      nmid_lobby_GAISlots,
      nmid_lobby_GGen,
      nmid_lobby_GDeadObs,
      nmid_lobby_GRandomScir: net_SendGSettings(param_type,forward);
      end;
      exit;
   end;
   {$ENDIF}

   case param_type of
   nmid_lobby_MSeed      : if(not forward)then begin map_RandomSeed;Map_premap;end;
   nmid_lobby_MSize      : begin
                              case forward of
                              true : ScrollInt(@map_mw, StepSMap,MinSMapW,MaxSMapW);
                              false: ScrollInt(@map_mw,-StepSMap,MinSMapW,MaxSMapW);
                              end;
                              Map_premap;
                           end;
   nmid_lobby_MObs       : begin ScrollByte(@map_obs,forward,0,7); Map_premap; end;
   nmid_lobby_MSym       : begin map_symmetry:=not map_symmetry; Map_premap; end;
   nmid_lobby_MRandom    : begin Map_randommap; Map_premap;end;

   nmid_lobby_GMode      : begin ScrollByteSet(@g_mode,forward,@allgamemodes);PlayersValidateTeam;Map_premap;end;
   nmid_lobby_GFixPos    : begin g_fixed_positions:=not g_fixed_positions;         Map_premap;end;
   nmid_lobby_GAISlots   : begin ScrollByte(@g_ai_slots  ,forward,0,gms_g_maxai  );Map_premap;end;
   nmid_lobby_GGen       : begin ScrollByte(@g_generators,forward,0,gms_g_maxgens);Map_premap;end;
   nmid_lobby_GDeadObs   : g_deadobservers:=not g_deadobservers;
   nmid_lobby_GRandomScir: if(forward)then MakeRandomSkirmish;
   end;
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
   if(net_error_timer>0)then net_error_timer-=1;

   r_blink1_colorb  :=vid_blink_timer1>vid_blink_periodh;
   r_blink2_colorb  :=vid_blink_timer2>vid_blink_period1;

   r_blink1_color_BG:=ui_blink_color1[r_blink1_colorb];
   r_blink1_color_BY:=ui_blink_color2[r_blink1_colorb];
   r_blink2_color_BG:=ui_blink_color1[r_blink2_colorb];
   r_blink2_color_BY:=ui_blink_color2[r_blink2_colorb];

   SoundControl;

   if(net_status=ns_client)then net_Client;
   replay_Code;

   {$ELSE}
   Dedicated_Code;
   Dedicated_Screen;
   {$ENDIF}

   PlayersCycle;

   if(G_Started)and(G_Status=gs_running)then
   begin
      g_cycle_order+=1;g_cycle_order:=g_cycle_order mod order_period;
      g_cycle_regen+=1;g_cycle_regen:=g_cycle_regen mod regen_period;

      if(ServerSide)then
      begin
         G_Step+=1;

         UpdatePlayersStatus;

         GameModeCPointsCode;
         {$IFDEF _FULLGAME}
         if(menu_s2<>ms2_camp)then
         begin
         {$ENDIF}
            GameModeCPointsEndConditions;
            case g_mode of
            gm_invasion  : begin
                           GameModeInvasion;
                           DefaultDefeatConditions;
                           end;
            gm_royale    : begin
                              if(g_cycle_order=0)then
                                if(g_royal_r>0)then g_royal_r-=1;
                              GameDefaultEndConditions;
                           end;
            gm_capture,
            gm_KotH      : DefaultDefeatConditions;
            else           GameDefaultEndConditions;
            end;
         {$IFDEF _FULLGAME}
         end
         else cmp_MissionCode;
         {$ENDIF}
      end;
      GameObjectsCode;
   end;

   if(net_status=ns_server)then net_Server;
end;


