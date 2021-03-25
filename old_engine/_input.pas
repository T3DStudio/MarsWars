
procedure escape_key;
begin
   if(_igchat)then
   begin
      _igchat:=false;
      net_chat_str:='';
   end
   else ToggleMenu;
end;

procedure return_key;
begin
   if(_menu=false)and(not _igchat)and(net_nstat<>ns_none)
   then _igchat:=true
   else
    if(_m_sel=100)or(_igchat)then
    begin
       if(length(net_chat_str)>0)then
        if(net_nstat=ns_clnt)
        then net_chatm
        else net_chat_add(net_chat_str,HPlayer,net_chat_tar);
       net_chat_str:='';
       _igchat:=false;
    end;
end;

procedure TogglePause;
begin
   if(net_nstat=ns_clnt)
   then net_pause
   else
     if(net_nstat=ns_srvr)then
       if(G_paused=0)
       then G_paused:=HPlayer
       else G_paused:=0;
end;

procedure _ClientCommandEffect(cmd,tar,ox1,oy1:integer);
var su,i:integer;
    guid:byte;
begin
   su:=0;

   with _players[HPlayer] do
   begin
      for i:=1 to MaxUnits do
      with _units[i] do
      with uid^ do
      if(hits>0)and(sel)and(playeri=HPlayer)then
      if(speed>0)or(_attack>0)or(_UnitHaveRPoint(@_units[i]))then
      begin
         inc(su,1);
         guid:=uidi;
      end;
   end;

   if(su<=0)then exit;

   // move or attack sound  guid

   inc(ox1,vid_mapx);
   inc(oy1,vid_mapy);

   if(_IsUnitRange(tar))then
   begin
      ui_umark_u:=tar;
      ui_umark_t:=fr_hfps;
   end;

   case cmd of
   co_paction : _click_eff(ox1,oy1,fr_hhfps,c_aqua  );
   co_rcamove : _click_eff(ox1,oy1,fr_hhfps,c_yellow);
   co_rcmove,
   co_move,
   co_patrol  : _click_eff(ox1,oy1,fr_hhfps,c_lime  );
   co_amove,
   co_apatrol : _click_eff(ox1,oy1,fr_hhfps,c_red   );
   end;
end;

procedure _player_s_o(ox0,oy0,ox1,oy1:integer;oa0,oid,pl:byte);
begin
   if(G_Paused=0)and(_rpls_rst<rpl_rhead)then
   begin
      if(net_nstat=ns_clnt)then
      begin
         net_clearbuffer;
         net_writebyte(nmid_order);
         net_writeint (ox0);
         net_writeint (oy0);
         net_writeint (ox1);
         net_writeint (oy1);
         net_writebyte(oa0);
         net_writebyte(oid);
         net_send(net_cl_svip,net_cl_svport);
      end
      else
        with _players[pl] do
        begin
           o_x0:=ox0;
           o_y0:=oy0;
           o_x1:=ox1;
           o_y1:=oy1;
           o_a0:=oa0;
           o_id:=oid;
        end;

      if(oid=uo_corder)then _ClientCommandEffect(ox0,oy0,ox1,oy1);
   end;
end;

function _whoInPoint(tx,ty,tt:integer):integer;
var i,sc:integer;
    htm :byte;
function _ch(up:PTPlayer):boolean;
begin
   _ch:=true;
   if(tt=1)then _ch:=up^.team<>htm;
   if(tt=2)then _ch:=up^.team= htm;
   if(tt=3)then _ch:=up^.pnum=HPlayer;
end;
begin
   sc:=0;
   with _players[HPlayer]do
   begin
      inc(sc,ucl_cs[false]);
      inc(sc,ucl_cs[true ]);
      htm:=team;
   end;
   _whoInPoint:=0;
   if(_nhp(tx,ty))then
    for i:=1 to MaxUnits do
     with _units[i] do
      if(hits>0)and(inapc=0)and(_ch(player))then
       if(_uvision(htm,@_units[i],false))then
        if(dist2(vx,vy,tx,ty)<uid^._r)then
        begin
           if(tt<=2)then
           begin
              if(playeri=HPlayer)and(sc=1)and(sel=true)then continue;
              _whoInPoint:=i;
           end
           else _whoInPoint:=uidi;
           break;
       end;
end;

procedure _chkbld;
begin
   case m_brush of
   0     : m_brush:=co_empty;
   1..255:
    with _players[HPlayer] do
     if(_uids[m_brush]._max=1)and(uid_e[m_brush]>0)then
     begin
        _player_s_o(m_brush,k_shift,0,0,0,uo_specsel ,HPlayer);
        m_brush:=co_empty;
     end
     else
       if _uid_cndt(@_players[HPlayer],m_brush)>0
       then m_brush:=co_empty
       else
       begin
          if not(m_brush in ui_prod_builds)then
          begin
             m_brush:=co_empty;
             exit;
          end;

          if(k_ctrl>1)then
          begin
             m_brushx:=m_mx;
             m_brushy:=m_my;
          end
          else
          begin
             _building_newplace(m_mx,m_my,m_brush,HPlayer,@m_brushx,@m_brushy);
             m_brushx:=mm3(map_b0,m_brushx,map_b1);
             m_brushy:=mm3(map_b0,m_brushy,map_b1);
             m_brushx:=mm3(vid_vx,m_brushx,vid_vx+vid_sw);
             m_brushy:=mm3(vid_vy,m_brushy,vid_vy+vid_sh);
          end;

          case _unit_grbcol(m_brushx,m_brushy,_uids[m_brush]._r,HPlayer,m_brush,true) of
          1 :  m_brushc:=c_red;
          2 :  m_brushc:=c_blue;
          else m_brushc:=c_lime;
          end;
       end;
co_paction,
co_move ,co_patrol,
co_amove,co_apatrol : if(ui_uimove=0)then m_brush:=co_empty;
   else
   end;
end;

procedure _command(x,y:integer);
var t:integer;
begin
   t:=0;
   case m_brush of
co_move   : begin                     // move
               t:=_whoInPoint(x,y,2);
               _player_s_o(co_move ,t,x,y,0,uo_corder,HPlayer);
            end;
co_amove  : begin                     // attack
               t:=_whoInPoint(x,y,1);
               _player_s_o(co_amove,t,x,y,0,uo_corder,HPlayer);
            end;
co_paction,
co_patrol,
co_apatrol: _player_s_o(m_brush,0,x,y,0,uo_corder,HPlayer);
co_empty  : begin                     // rclick
               t:=_whoInPoint(x,y,0);
               if(m_a_inv)
               then _player_s_o(co_rcmove ,t,x,y,0,uo_corder,HPlayer)
               else _player_s_o(co_rcamove,t,x,y,0,uo_corder,HPlayer);
            end;
   end;

   m_brush:=co_empty;
end;

function _rclickmove(uid:byte):boolean;
begin
   _rclickmove:=false;
   if(uid>0)then
    with _uids[uid] do
     if(_max=1)then
      if(_ucl=6)or(uid in [UID_HTeleport,UID_HAltar])then _rclickmove:=true;
end;

procedure _panel_click(tab,bx,by:integer;right,mid:boolean);
var u:integer;
begin
   //writeln(tab,': ',bx,', ',by);
   PlaySNDM(snd_click);
   dec(by,4);// 0,0 under minimap

   case by of
   -1: case vid_ppos of   // tabs
       0,1: begin dec(m_vx,vid_panelx); if(m_vy>ui_tabsy)then ui_tab:=mm3(0,m_vx div vid_tBW,3);inc(m_vx,vid_panelx);end;
       2,3: begin dec(m_vy,vid_panely); if(m_vx>ui_tabsy)then ui_tab:=mm3(0,m_vy div vid_tBW,3);inc(m_vy,vid_panely);end;
       end;
   9: case bx of         // buttons
      0 : ToggleMenu;
      1 : ;
      2 : if(net_nstat>ns_none)then TogglePause;
      end;
   else
     u:=(by*3)+(bx mod 3);

     if(0<=by)and(by<9)then
     with _players[HPlayer] do
      case tab of

0: if(G_Paused=0)and(_rpls_rst<rpl_runit)then  // builds
   if(u<=ui_ubtns)then
   case right of
false: begin m_brush:=ui_panel_uids[race,0,u];_chkbld;end;
true : if(ucl_x[true,u]>0)then
        if(_rclickmove(ui_panel_uids[race,0,u]))then
         with _units[ucl_x[true,u]] do _command(x,y);
   end;

1: if(G_Paused=0)and(_rpls_rst<rpl_runit)then  // units
   if(u<=ui_ubtns)then
   case right of
false: _player_s_o(co_suprod,ui_panel_uids[race,1,u],0,0,0, uo_corder  ,HPlayer);
true : _player_s_o(co_cuprod,ui_panel_uids[race,1,u],0,0,0, uo_corder  ,HPlayer);
   end;

2: if(G_Paused=0)and(_rpls_rst<rpl_runit)then  // upgrades
   if(u<=ui_ubtns)then
   case right of
false: _player_s_o(co_supgrade,ui_panel_uids[race,2,u],0,0,0, uo_corder  ,HPlayer);
true : _player_s_o(co_cupgrade,ui_panel_uids[race,2,u],0,0,0, uo_corder  ,HPlayer);
   end;

3: if(_rpls_rst<rpl_rhead)then
   begin
      if(G_Paused=0)and(right=false)then
      begin
         case u of
   0 : m_brush:=co_move;
   1 : _player_s_o(co_stand  ,0,0,0,0, uo_corder  ,HPlayer);
   2 : m_brush:=co_patrol;

   3 : m_brush:=co_amove;
   4 : _player_s_o(co_astand ,0,0,0,0, uo_corder  ,HPlayer);
   5 : m_brush:=co_apatrol;

   6 : _player_s_o(co_action ,0,0,0,0, uo_corder  ,HPlayer);
   7 : m_a_inv:=not m_a_inv;
   8 : _player_s_o(co_pcancle,0,0,0,0, uo_corder  ,HPlayer);

   9 : m_brush:=co_paction;

   10: if(ui_orders_x[10]>0)then
        if(k_dbl>0)
        then _moveHumView(ui_orders_x[10], ui_orders_y[10])
        else _player_s_o(0,0,0,0,0,uo_specsel,HPlayer);
   11: _player_s_o(co_destroy,0,0,0,0, uo_corder  ,HPlayer);
         end;

         _chkbld;
      end;
   end
   else
     if(u=13)then
     begin
        if(mid)
        then _rpls_step:=fr_hfps*fr_fps
        else
          if(right=false)
          then _rpls_step:=fr_hfps*2
          else _rpls_step:=fr_hfps*10;
     end
     else
       if(right=false)then
        case u of
     12: _fsttime:=not _fsttime;
     14: if(_rpls_rst<rpl_end)then
          if(G_Paused>0)
          then G_Paused:=0
          else G_Paused:=200;
     15: _rpls_vidm:=not _rpls_vidm;
     16: _rpls_log :=not _rpls_log;
     17: _fog      :=not _fog;
 20..26: HPlayer   :=u-20;
        end;

      end;
   end;
end;

procedure _hotkeys(k:cardinal);
var ko,k2:cardinal;
begin
   if(k=sdlk_pause)
   then TogglePause
   else
      case k of
      sdlk_tab: begin
                   inc(ui_tab,1);
                   ui_tab:=ui_tab mod 4;
                end;
       1:begin end;
      else
        if(_testmode>0)and(net_nstat=0)then
         case k of
            sdlk_end       : if(k_ctrl>2)
                             then begin if(g_mode=gm_inv)then inc(g_inv_wn,1); end
                             else _fsttime:=not _fsttime;
            sdlk_home      : _warpten:=not _warpten;
            sdlk_pageup    : if(net_nstat<>ns_clnt) then with _players[HPlayer] do if(state=PS_Play)then state:=PS_Comp else state:=PS_Play;
            sdlk_pagedown  : with _players[HPlayer] do if(upgr[upgr_invuln]=0)then upgr[upgr_invuln]:=1 else upgr[upgr_invuln]:=0;
            sdlk_backspace : _fog:=not _fog;
            SDLK_F5        : begin HPlayer:=0;exit end;
            SDLK_F6        : begin HPlayer:=1;exit end;
            SDLK_F7        : begin HPlayer:=2;exit end;
            SDLK_F8        : begin HPlayer:=3;exit end;
            SDLK_F9        : begin HPlayer:=4;exit end;
            SDLK_F10       : begin HPlayer:=5;exit end;
            SDLK_F11       : begin HPlayer:=6;exit end;
            sdlk_insert    : _draw:= not _draw;
         end;

        if(_rpls_rst<rpl_rhead)then
        begin
           k2:=0;
           if(k_ctrl >1)then k2:=SDLK_LCtrl;
           if(k_alt  >1)then k2:=SDLK_LAlt;
           if(k_shift>1)then k2:=SDLK_LShift;
           case ui_tab of
        0,1,2:for ko:=0 to _mhkeys do
              begin
                 if(_hotkey2[ko]<>k2)
                 or(_hotkey1[ko]= 0 )
                 or(_hotkey1[ko]<>k )then continue;
                 _panel_click(ui_tab,ko mod 3,4+(ko div 3),false,false);
                 exit;
              end;
           end;

           if(G_Paused=0)then
           begin
              for ko:=0 to 11 do  // actions
               if(k=_hotkeyA[ko])then
               begin
                  if(_hotkeyA[ko]=0)then continue;
                  _panel_click(3,ko mod 3,4+(ko div 3),false,false);
                  exit;
               end;

              case k of
           sdlk_0..sdlk_9 :  begin
                                ko:=_event^.key.keysym.sym-sdlk_0;
                                if (k_ctrl>1)
                                then _player_s_o(ko,0,0,0,0,uo_setorder,HPlayer)
                                else
                                  if (k_alt>1)
                                  then _player_s_o(ko,0,0,0,0,uo_addorder,HPlayer)
                                  else
                                    if(k_dbl>0)and(ui_orders_x[ko]>0)and(ko>0)
                                    then _moveHumView(ui_orders_x[ko] , ui_orders_y[ko])
                                    else _player_s_o(ko,k_shift,0,0,0,uo_selorder,HPlayer);
                             end;

              else
              end;
           end;
        end
        else
          for ko:=0 to 14 do  // actions
           if(k=_hotkeyR[ko])and(_hotkeyR[ko]>0)then
           begin
              _panel_click(3,ko mod 3,16+(ko div 3),k_ctrl>1,k_alt>1);
              exit;
           end;

      end;
   k_dbl:=fr_hhfps;
end;

procedure _keyp(i:pbyte);
begin
   if (i^>1)and(i^<255) then inc(i^,1); //
   if (i^=1) then i^:=0;
end;

procedure WindowEvents;
begin
   _keyp(@k_u    );
   _keyp(@k_d    );
   _keyp(@k_r    );
   _keyp(@k_l    );
   _keyp(@k_shift);
   _keyp(@k_ctrl );
   _keyp(@k_alt  );
   _keyp(@k_ml   );
   _keyp(@k_mr   );
   _keyp(@k_chrt );
   if(k_dbl>0)then dec(k_dbl,1);

   while (SDL_PollEvent( _event )>0) do
    CASE (_event^.type_) OF
      SDL_MOUSEMOTION    : begin
                              if(m_vmove)and(_menu=false)and(G_Started)then
                              begin
                                 dec(vid_vx,_event^.motion.x-m_vx);
                                 dec(vid_vy,_event^.motion.y-m_vy);
                                 _view_bounds;
                              end;
                              m_vx:=_event^.motion.x;
                              m_vy:=_event^.motion.y;
                           end;
      SDL_MOUSEBUTTONUP  : case (_event^.button.button) of
                            SDL_BUTTON_LEFT   : k_ml:=1;
                            SDL_BUTTON_RIGHT  : k_mr:=1;
                            SDL_BUTTON_MIDDLE : m_vmove:=false;
                           else
                           end;
      SDL_MOUSEBUTTONDOWN: begin
                              case (_event^.button.button) of
                            SDL_BUTTON_LEFT      : if(k_ml=0)then k_ml:=2;
                            SDL_BUTTON_RIGHT     : if(k_mr=0)then k_mr:=2;
                            SDL_BUTTON_MIDDLE    : if(_menu=false)and(G_Started)and(_rpls_vidm=false)then m_vmove:=true;
                            SDL_BUTTON_WHEELDOWN : if(_menu)then
                                                   begin
                                                      vid_mredraw:=true;
                                                      case _m_sel of
                                                      98: _scrollV(@_cmp_sm,1,0,MaxMissions-vid_camp_m);
                                                      36: _scrollV(@_svld_sm,1,0,_svld_ln-vid_svld_m-1);
                                                      41: _scrollV(@_rpls_sm,1,0,_rpls_ln-vid_rpls_m-1);
                                                      end;
                                                   end;
                            SDL_BUTTON_WHEELUP   : if(_menu)then
                                                   begin
                                                      vid_mredraw:=true;
                                                      case _m_sel of
                                                      98: _scrollV(@_cmp_sm,-1,0,MaxMissions-vid_camp_m);
                                                      36: _scrollV(@_svld_sm,-1,0,_svld_ln-vid_svld_m-1);
                                                      41: _scrollV(@_rpls_sm,-1,0,_rpls_ln-vid_rpls_m-1);
                                                      end;
                                                   end;
                              else
                              end;
                           end;
      SDL_QUITEV         : _CYCLE:=false;
      SDL_KEYUP          : begin
                              k_chrt:=1;
                              case (_event^.key.keysym.sym) of
                                sdlk_up    : k_u    :=1;
                                sdlk_down  : k_d    :=1;
                                sdlk_left  : k_l    :=1;
                                sdlk_right : k_r    :=1;
                                sdlk_rshift: k_shift:=1;
                                sdlk_lshift: k_shift:=1;
                                sdlk_lctrl : k_ctrl :=1;
                                sdlk_rctrl : k_ctrl :=1;
                                sdlk_lalt  : k_alt  :=1;
                                sdlk_ralt  : k_alt  :=1;
                              else
                              end;
                           end;
      SDL_KEYDOWN        : begin
                              k_chrt:=2;
                              k_chr :=Widechar(_event^.key.keysym.unicode);
                              case (_event^.key.keysym.sym) of
                                sdlk_up     : if(k_u    =0)then k_u    :=2;
                                sdlk_down   : if(k_d    =0)then k_d    :=2;
                                sdlk_left   : if(k_l    =0)then k_l    :=2;
                                sdlk_right  : if(k_r    =0)then k_r    :=2;
                                sdlk_rshift : if(k_shift=0)then k_shift:=2;
                                sdlk_lshift : if(k_shift=0)then k_shift:=2;
                                sdlk_rctrl  : if(k_ctrl =0)then k_ctrl :=2;
                                sdlk_lctrl  : if(k_ctrl =0)then k_ctrl :=2;
                                sdlk_ralt   : if(k_alt  =0)then k_alt  :=2;
                                sdlk_lalt   : if(k_alt  =0)then k_alt  :=2;
                                SDLK_PRINT  : _screenshot;
                                sdlk_escape : escape_key;
                                sdlk_return : return_key;
                              else
                                if(_menu=false)and(G_Started)and(_igchat=false)then _hotkeys(_event^.key.keysym.sym);
                              end;
                           end;
    else
    end;
end;

procedure g_mouse;
var u:integer;
begin
   m_mx :=m_vx+vid_vx-vid_mapx;
   m_my :=m_vy+vid_vy-vid_mapy;
   if(vid_ppos<2)then
   begin
      u:=m_vx-vid_panelx;m_bx:=u div vid_BW;if(u<0)then dec(m_bx,1);
      u:=m_vy-vid_panely;m_by:=u div vid_BW;if(u<0)then dec(m_by,1);
   end
   else
   begin
      u:=m_vy-vid_panely;m_bx:=u div vid_BW;if(u<0)then dec(m_bx,1);
      u:=m_vx-vid_panelx;m_by:=u div vid_BW;if(u<0)then dec(m_by,1);
   end;

   if(m_ldblclk>0)then dec(m_ldblclk,1);

   _chkbld;

   if(k_ml=2)then                    // LMB down
    if(m_bx<0)or(3<=m_bx)then        // map
     case m_brush of
co_empty  : begin
               m_sxs:=m_mx;
               m_sys:=m_my;
               //_effect_add(m_mx,m_my,10000,EID_Gavno);
            end;
1..255    : if(m_brushc=c_lime)
            then _player_s_o(m_brushx,m_brushy,m_brush,0,0, uo_build  ,HPlayer)
            else PlayInGameAnoncer(snd_cannot_build[_players[HPlayer].race]);
co_paction,
co_move,
co_amove,
co_patrol,
co_apatrol: _command(m_mx,m_my);
     end
    else
      if(m_by<3)then      // minimap
      case m_brush of
      co_paction,
      co_move,
      co_amove,
      co_patrol,
      co_apatrol : _command(trunc((m_vx-vid_panelx)/map_mmcx),trunc((m_vy-vid_panely)/map_mmcx));
      else        if(_rpls_vidm=false)then m_mmap_move:=true;
      end
      else _panel_click(ui_tab,m_bx,m_by,false,false);     // panel

   if(k_ml=1)then  // LMB up
   begin
      m_mmap_move:=false;

      if(m_sxs>-1)then //select
      begin
         if(m_ldblclk>0)then
           if(k_shift<2)
           then _player_s_o(vid_vx,vid_vy, vid_vx+vid_sw,vid_vy+vid_sh,_whoInPoint(m_mx,m_my,3), uo_dblselect  ,HPlayer)
           else _player_s_o(vid_vx,vid_vy, vid_vx+vid_sw,vid_vy+vid_sh,_whoInPoint(m_mx,m_my,3), uo_adblselect ,HPlayer)
         else
           if(k_shift<2)
           then _player_s_o(m_sxs,m_sys,m_mx,m_my,0,uo_select ,HPlayer)
           else _player_s_o(m_sxs,m_sys,m_mx,m_my,0,uo_aselect,HPlayer);

         m_sxs:=-1;
         m_ldblclk:=fr_hhfps;
      end;
   end;

   if(m_mmap_move)and(m_sxs=-1)then
   begin
      _moveHumView(trunc((m_vx-vid_panelx)/map_mmcx), trunc((m_vy-vid_panely)/map_mmcx));
      _view_bounds;
   end;

   //if(k_mr=2)then _effect_add(m_mx,m_my,10000,EID_Teleport);

   if(k_mr=2)then                 // RMB down
    if(m_brush<>co_empty)
    then m_brush:=co_empty
    else
     if(m_bx<0)or(3<=m_bx)        // map
     then _command(m_mx,m_my)
     else
       if(m_by<3)                 // minimap
       then _command(trunc((m_vx-vid_panelx)/map_mmcx), trunc((m_vy-vid_panely)/map_mmcx))
       else _panel_click(ui_tab,m_bx,m_by,true,false);     // panel
end;

procedure _move_v_m;
begin
   if(m_vx<vid_vmb_x0)then dec(vid_vx,vid_vmspd);
   if(m_vy<vid_vmb_y0)then dec(vid_vy,vid_vmspd);
   if(m_vx>vid_vmb_x1)then inc(vid_vx,vid_vmspd);
   if(m_vy>vid_vmb_y1)then inc(vid_vy,vid_vmspd);
end;

procedure _view_move;
var vx,vy:integer;
begin
   vx:=vid_vx;
   vy:=vid_vy;

   if(vid_vmm)then _move_v_m;

   if (k_u>1) then dec(vid_vy,vid_vmspd);
   if (k_l>1) then dec(vid_vx,vid_vmspd);
   if (k_d>1) then inc(vid_vy,vid_vmspd);
   if (k_r>1) then inc(vid_vx,vid_vmspd);

   if(vx<>vid_vx)or(vy<>vid_vy)then _view_bounds;
end;

procedure g_keyboard;
begin
   if(m_vmove=false)and(_rpls_vidm=false)then _view_move;
   if(_igchat)then net_chat_str:=menu_sf(net_chat_str,k_kbstr,ChatLen2);
end;

procedure InputGame;
begin
   WindowEvents;

   if(_menu)
   then g_menu
   else
   begin
      g_keyboard;
      g_mouse;
   end;
end;



