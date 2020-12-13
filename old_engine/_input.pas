
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

procedure _player_s_o(ox0,oy0,ox1,oy1:integer;oid,pl:byte);
var su,i:integer;
  cmsnd:boolean;
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
           o_id:=oid;
        end;

      if(oid<>uo_corder)then exit;

      with _players[HPlayer] do
      begin
         su:=0;
         cmsnd:=false;
         for i:=1 to 255 do
          with _ulst[i] do
           if(speed>0)then inc(su,uid_s[i]);
         if(su>0)then cmsnd:=true;
         if(upgr[upgr_mainm]>0)then inc(su,ucl_s[true,0]);
         inc(su,ucl_s[true,5]+ucl_s[true,4]+ucl_s[true,7]);
         for i:=1 to 255 do
          with _ulst[i] do
           if(isbarrack)then inc(su,uid_s[i]);
         inc(su,uid_s[UID_HCommandCenter]);
         if(race=r_uac )then
         begin
            if(upgr[upgr_blizz]>0)then inc(su,ucl_s[true,8]);
            inc(su,ucl_s[true,6]);
            inc(su,ucl_s[true,0]);
         end;
         if(race=r_hell)then
         begin
            if(upgr[upgr_6bld   ]>0)then inc(su,ucl_s[true,6]);
         end;
         for i:=_uts downto 0 do
          if(ucl_s[false,i]>0)then break;
      end;

      if(cmsnd)then _unit_comssnd(i,_players[HPlayer].race);

      if(su<=0)then exit;

      inc(ox1,vid_mapx);
      inc(oy1,vid_mapy);

      if(oy0>0)then
      begin
         ui_umark_u:=oy0;
         ui_umark_t:=vid_hfps;
      end;

      case ox0 of
      co_paction : _click_eff(ox1,oy1,vid_hhfps,c_aqua  );
      co_rcamove : _click_eff(ox1,oy1,vid_hhfps,c_yellow);
      co_rcmove,
      co_move,
      co_patrol  : _click_eff(ox1,oy1,vid_hhfps,c_lime  );
      co_amove,
      co_apatrol : _click_eff(ox1,oy1,vid_hhfps,c_red   );
      end;
   end;
end;

function _whoInPoint(tx,ty,tt:integer):integer;
var i,sc:integer;
    htm :byte;
function _ch(utm:byte):boolean;
begin
   _ch:=true;
   if(tt=1)then _ch:=utm<>htm;
   if(tt=2)then _ch:=utm= htm;
end;
begin
   sc:=0;
   with _players[HPlayer]do
   begin
      for i:=0 to _uts do
      begin
         inc(sc,ucl_s[false,i]);
         inc(sc,ucl_s[true ,i]);
      end;
      htm:=team;
   end;
   _whoInPoint:=0;
   if(_nhp(tx,ty))then
    for i:=1 to MaxUnits do
     with _units[i] do
      if(hits>0)and(inapc=0)and(_ch(player^.team))then
       if(_uvision(htm,@_units[i],false))then
        if(dist2(vx,vy,tx,ty)<r)then
        begin
           if(playeri=HPlayer)and(sc=1)and(sel=true)then continue;
           _whoInPoint:=i;
           break;
       end;
end;

procedure _chkbld;
var uid:byte;
begin
   case m_brush of
   0.._uts:
    with _players[HPlayer] do
     if(m_brush in _sbs_ucls)and(ucl_e[true,m_brush]>0)then
     begin
        _player_s_o(m_brush,k_shift,0,0,uo_specsel ,HPlayer);
        m_brush:=co_empty;
     end
     else
       if _bldCndt(@_players[HPlayer],m_brush)and(bld_r=0)
       then m_brush:=co_empty
       else if not((build_b<m_mx)and(m_mx<map_b1)and(build_b<m_my)and(m_my<map_b1))
            then m_brushc:=c_blue
            else
            begin
               uid:=cl2uid[race,true,m_brush];
               if not(uid in ui_prod_builds)then
               begin
                  m_brush:=co_empty;
                  exit;
               end;
               case _unit_grbcol(m_mx,m_my,_ulst[uid].r,HPlayer,uid,true) of
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
               _player_s_o(co_move ,t,x,y,uo_corder,HPlayer);
            end;
co_amove  : begin                     // attack
               t:=_whoInPoint(x,y,1);
               _player_s_o(co_amove,t,x,y,uo_corder,HPlayer);
            end;
co_paction,
co_patrol,
co_apatrol: _player_s_o(m_brush,0,x,y,uo_corder,HPlayer);
co_empty  : begin                     // rclick
               t:=_whoInPoint(x,y,0);
               if(m_a_inv)
               then _player_s_o(co_rcmove ,t,x,y,uo_corder,HPlayer)
               else _player_s_o(co_rcamove,t,x,y,uo_corder,HPlayer);
            end;
   end;

   m_brush:=co_empty;
end;

function _rclickmove(uid:byte):boolean;
begin
   _rclickmove:=false;
   if(uid>0)then
    with _ulst[uid] do
     if(max=1)then
      if(ucl=6)or(uidi in [UID_HTeleport,UID_HAltar])then _rclickmove:=true;
end;

procedure _panel_click(tab,bx,by:integer;right,mid:boolean);
var u:integer;
begin
   //writeln(tab,': ',bx,', ',by);
   PlaySNDM(snd_click);
   case by of
   9: case bx of         // buttons
      0 : ToggleMenu;
      1 : ;
      2 : if(net_nstat>ns_none)then TogglePause;
      end;
  -1: case vid_ppos of   // tabs
      0,1: begin dec(m_vx,vid_panelx); if(m_vy>ui_tabsy)then ui_tab:=m_vx div vid_tBW;inc(m_vx,vid_panelx);end;
      2,3: begin dec(m_vy,vid_panely); if(m_vx>ui_tabsy)then ui_tab:=m_vy div vid_tBW;inc(m_vy,vid_panely);end;
      end;
   else
     u:=(by*3)+(bx mod 3);

     if(0<=by)and(by<9)then
     with _players[HPlayer] do
      case tab of

0: if(G_Paused=0)and(_rpls_rst<rpl_runit)then  // builds
   case right of
false: begin m_brush:=u;_chkbld;end;
true : if(ucl_x[u]>0)then
        if(_rclickmove(cl2uid[race,true,u]))then
         with _units[ucl_x[u]] do _command(x,y);
   end;

1: if(G_Paused=0)and(_rpls_rst<rpl_runit)then  // units
   if(u<19)then
   case right of
false: _player_s_o(co_suprod,u,0,0, uo_corder  ,HPlayer);
true : _player_s_o(co_cuprod,u,0,0, uo_corder  ,HPlayer);
   end;

2: if(G_Paused=0)and(_rpls_rst<rpl_runit)then  // upgrades
   if(u<=MaxUpgrs)then
   case right of
false: _player_s_o(co_supgrade,u,0,0, uo_corder  ,HPlayer);
true : _player_s_o(co_cupgrade,u,0,0, uo_corder  ,HPlayer);
   end;

3: if(_rpls_rst<rpl_rhead)then
   begin
      if(G_Paused=0)and(right=false)then
      begin
         case u of
   0 : m_brush:=co_move;
   1 : _player_s_o(co_stand  ,0,0,0, uo_corder  ,HPlayer);
   2 : m_brush:=co_patrol;

   3 : m_brush:=co_amove;
   4 : _player_s_o(co_astand ,0,0,0, uo_corder  ,HPlayer);
   5 : m_brush:=co_apatrol;

   6 : _player_s_o(co_action ,0,0,0, uo_corder  ,HPlayer);
   7 : m_a_inv:=not m_a_inv;
   8 : _player_s_o(co_pcancle,0,0,0, uo_corder  ,HPlayer);

   10: if(ordx[10]>0)then
        if(k_dbl>0)
        then _moveHumView(ordx[10], ordy[10])
        else _player_s_o(0,0,0,0,uo_specsel,HPlayer);
   11: _player_s_o(co_destroy,0,0,0, uo_corder  ,HPlayer);
         end;
         _chkbld;
      end;
   end
   else
     if(u=13)then
     begin
        if(mid)
        then _rpls_step:=vid_hfps*vid_fps
        else
          if(right=false)
          then _rpls_step:=vid_hfps*2
          else _rpls_step:=vid_hfps*10;
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
                 _panel_click(ui_tab,ko mod 3,(ko div 3),false,false);
                 exit;
              end;
           end;

           if(G_Paused=0)then
           begin
              for ko:=0 to 11 do  // actions
               if(k=_hotkeyA[ko])then
               begin
                  if(_hotkeyA[ko]=0)then continue;
                  _panel_click(3,ko mod 3,(ko div 3),false,false);
                  exit;
               end;

              case k of
           sdlk_0..sdlk_9 :  begin
                                ko:=_event^.key.keysym.sym-sdlk_0;
                                if (k_ctrl>1)
                                then _player_s_o(ko,0,0,0,uo_setorder,HPlayer)
                                else
                                  if (k_alt>1)
                                  then _player_s_o(ko,0,0,0,uo_addorder,HPlayer)
                                  else
                                    if(k_dbl>0)and(ordx[ko]>0)and(ko>0)
                                    then _moveHumView(ordx[ko] , ordy[ko])
                                    else _player_s_o(ko,k_shift,0,0,uo_selorder,HPlayer);
                             end;

              else
              end;
           end;
        end
        else
          for ko:=0 to 14 do  // actions
           if(k=_hotkeyR[ko])and(_hotkeyR[ko]>0)then
           begin
              _panel_click(3,ko mod 3,(ko div 3)+12,k_ctrl>1,k_alt>1);
              exit;
           end;

      end;
   k_dbl:=vid_hhfps;
end;

procedure _keyp(i:pbyte);
begin
   if (i^>1)and(i^<255) then inc(i^,1); //
   if (i^=1) then i^:=0;
end;

procedure WindowEvents;
begin
   _keyp(@k_u);
   _keyp(@k_d);
   _keyp(@k_r);
   _keyp(@k_l);
   _keyp(@k_shift);
   _keyp(@k_ctrl);
   _keyp(@k_alt);
   _keyp(@k_ml);
   _keyp(@k_mr);
   _keyp(@k_chrt);
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
      SDL_MOUSEBUTTONUP  : begin
                              case (_event^.button.button) of
                            SDL_BUTTON_left   : k_ml:=1;
                            SDL_BUTTON_right  : k_mr:=1;
                            SDL_BUTTON_middle : m_vmove:=false;
                              else
                              end;
                           end;
      SDL_MOUSEBUTTONDOWN: begin
                              case (_event^.button.button) of
                            SDL_BUTTON_left      : if (k_ml=0) then k_ml:=2;
                            SDL_BUTTON_right     : if (k_mr=0) then k_mr:=2;
                            SDL_BUTTON_middle    : if(_menu=false)and(G_Started)and(_rpls_vidm=false)then m_vmove:=true;
                            SDL_BUTTON_WHEELDOWN : if(_menu)then
                                                   begin
                                                      vid_mredraw:=true;

                                                      if(_m_sel=98)then _scrollV(@_cmp_sm,1,0,MaxMissions-vid_camp_m);
                                                      if(_m_sel=36)then _scrollV(@_svld_sm,1,0,_svld_ln-vid_svld_m-1);
                                                      if(_m_sel=41)then _scrollV(@_rpls_sm,1,0,_rpls_ln-vid_rpls_m-1);
                                                   end;
                            SDL_BUTTON_WHEELUP   : if(_menu)then
                                                   begin
                                                      vid_mredraw:=true;

                                                      if(_m_sel=98)then _scrollV(@_cmp_sm,-1,0,MaxMissions-vid_camp_m);
                                                      if(_m_sel=36)then _scrollV(@_svld_sm,-1,0,_svld_ln-vid_svld_m-1);
                                                      if(_m_sel=41)then _scrollV(@_rpls_sm,-1,0,_rpls_ln-vid_rpls_m-1);
                                                   end;
                              else
                              end;
                           end;
      SDL_QUITEV         : begin _CYCLE:=false; end;
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
                                sdlk_up     : if (k_u    =0) then k_u    :=2;
                                sdlk_down   : if (k_d    =0) then k_d    :=2;
                                sdlk_left   : if (k_l    =0) then k_l    :=2;
                                sdlk_right  : if (k_r    =0) then k_r    :=2;
                                sdlk_rshift : if (k_shift=0) then k_shift:=2;
                                sdlk_lshift : if (k_shift=0) then k_shift:=2;
                                sdlk_rctrl  : if (k_ctrl =0) then k_ctrl :=2;
                                sdlk_lctrl  : if (k_ctrl =0) then k_ctrl :=2;
                                sdlk_ralt   : if (k_alt  =0) then k_alt  :=2;
                                sdlk_lalt   : if (k_alt  =0) then k_alt  :=2;
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
      u:=m_vx-vid_panelx; m_bx:=u div vid_BW;if(u<0)then dec(m_bx,1);
      u:=m_vy-vid_panely; m_by:=u div vid_BW;if(u<0)then dec(m_by,1);
   end
   else
   begin
      u:=m_vy-vid_panely; m_bx:=u div vid_BW;if(u<0)then dec(m_bx,1);
      u:=m_vx-vid_panelx; m_by:=u div vid_BW;if(u<0)then dec(m_by,1);
   end;

   if(m_ldblclk>0)then dec(m_ldblclk,1);

   _chkbld;

   if(k_ml=2)then                    // left button
    if(m_bx<0)or(3<=m_bx)then        // map
    case m_brush of
co_empty  : begin
               m_sxs:=m_mx;
               m_sys:=m_my;
            end;
0.._uts   : if(m_brushc=c_lime)then
            begin
               _player_s_o(m_mx,m_my,m_brush,0, uo_build  ,HPlayer);
               _chkbld;
            end;
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
      else        if(_rpls_vidm=false)then ui_panelmmm:=true;
      end
      else _panel_click(ui_tab,m_bx,m_by-4,false,false);     // panel

   if(k_ml=1)then
   begin
      ui_panelmmm:=false;

      if(m_sxs>-1)then //select
      begin
         if(m_ldblclk>0)
         then
           if(k_shift<2)
           then _player_s_o(vid_vx,vid_vy, vid_vx+vid_sw,vid_vy+vid_sh, uo_dblselect  ,HPlayer)
           else _player_s_o(vid_vx,vid_vy, vid_vx+vid_sw,vid_vy+vid_sh, uo_adblselect ,HPlayer)
         else
           if(k_shift<2)
           then _player_s_o(m_sxs,m_sys,m_mx,m_my,uo_select ,HPlayer)
           else _player_s_o(m_sxs,m_sys,m_mx,m_my,uo_aselect,HPlayer);

         m_sxs:=-1;
         m_ldblclk:=vid_hhfps;
      end;
   end;

   if(ui_panelmmm)and(m_sxs=-1)then
   begin
      _moveHumView(trunc((m_vx-vid_panelx)/map_mmcx), trunc((m_vy-vid_panely)/map_mmcx));
      _view_bounds;
   end;

   if(k_mr=2)then                 // right button
    if(m_brush<>co_empty)
    then m_brush:=co_empty
    else
     if(m_bx<0)or(3<=m_bx)        // map
     then _command(m_mx,m_my)
     else
       if(m_by<3)                 // minimap
       then _command(trunc((m_vx-vid_panelx)/map_mmcx), trunc((m_vy-vid_panely)/map_mmcx))
       else _panel_click(ui_tab,m_bx,m_by-4,true,false);     // panel
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



