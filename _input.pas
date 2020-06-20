
procedure escape_key;
begin
   if(_igchat)then
   begin
      _igchat:=false;
      ui_chat_str:='';
   end
   else ToggleMenu;
end;

procedure _sendchat;
begin
   if(length(ui_chat_str)>0)then
    if(net_nstat=ns_clnt)
    then net_chatm
    else
      if(_menu)or(G_Started=false)
      then net_chat_add(ui_chat_str,HPlayer,255)
      else net_chat_add(ui_chat_str,HPlayer,ui_chattar);
   ui_chat_str:='';
end;

procedure return_key;
begin
   if(_menu=false)then
   begin
      if(_igchat)then
      begin
         _sendchat;
         _igchat:=false;
      end
      else
        if(_rpls_rst<rpl_rhead)then
        begin
           _igchat:=true;
           ui_chat_shlm:=0;
        end;
   end
   else
    if(m_chat)
    then _sendchat
    else
      case _m_sel of
        ms_mltsvp,
        ms_mltcla,
        ms_setpln:
                  begin
                     net_cl_saddr;
                     _players[HPlayer].name:=PlayerName;
                     vid_mredraw:=true;
                     _m_sel:=0;
                  end;
      end;
end;

procedure TogglePause;
begin
   if(net_nstat=ns_clnt)
   then net_cl_pause
   else
     if(net_nstat=ns_srvr)then
      if(G_Status<=MaxPlayers)then
       if(G_Status=0)
       then G_Status:=HPlayer
       else G_Status:=0;
end;

procedure ToggleChatTarget;
var ux,uy:integer;
    i:byte;
begin
   uy:=(ui_panely+ui_p_ychat+font_w+4);
   if(uy>m_vy)then exit;
   ux:=(m_vx-ui_p_xchat) div vid_hBW;
   uy:=(m_vy-uy) div 11;
   if(0<=ux)and(ux<=1)and(0<=uy)and(uy<=2)then
   begin
      i:=((ux+uy*2)+1);
      if(i<>HPlayer)then
      begin
         i:=1 shl i;
         if((ui_chattar and i)>0)
          then ui_chattar:=ui_chattar xor i
          else ui_chattar:=ui_chattar or i;
      end;
   end;
end;

procedure _player_s_o(ox0,oy0,ox1,oy1:integer;oid,pl:byte);
var i:byte;
begin
   if(G_Status=0)and(_rpls_rst<rpl_rhead)then
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

      with _players[HPlayer] do
      if(sarmy>0)then
      begin
        if(ox0=0)then
         for i:=0 to 255 do
          if(uid_s[i]>0)then
           with _tuids[i] do
            if(_mspeed=0)and not(uo_rallpos in _orders)then exit;

         if(oid=po_uorder)or(oid=po_uordera)then
          if(0<=ox0)and(ox0<=255)then
           with _tuids[ui_lsuc] do
           with _toids[ox0] do
            if{(ox0 in _orders)and}((rtar and at_anytar)>0)then
            begin
               case _com_sndn of
               0: ;
               1:   PlayUSND(_com_snds[0]);
               else PlayUSND(_com_snds[random(_com_sndn)]);
               end;

               if(oy0>0)then
               begin
                  ui_umark_u :=oy0;
                  ui_umark_ut:=vid_h3fps;
               end
               else
                 if(ox0=0)then
                  if(rghtatt)
                  then _click_eff(ox1,oy1,vid_h4fps,_toids[uo_attack]._omarc)
                  else _click_eff(ox1,oy1,vid_h4fps,_toids[uo_move  ]._omarc)
                 else
                   if(_omarc>0)then _click_eff(ox1,oy1,vid_h4fps,_omarc);
            end;
      end;
   end;
end;

procedure _porder(ox0,oy0,ox1,oy1:integer);
begin
   if(k_shift>1)
   then _player_s_o(ox0,oy0,ox1,oy1,po_uordera,HPlayer)
   else _player_s_o(ox0,oy0,ox1,oy1,po_uorder ,HPlayer);
end;

procedure _chkbrush;
begin
   if(m_brtar<0)then
   begin
      if(_checkBldPrc(HPlayer,_tuids[-m_brtar]._itbuild)=false)or(_unitBC(HPlayer,-m_brtar))or(_chprodmana(-m_brtar,HPlayer)=false)then
      begin
         m_brush:=0;
         m_brtar:=0;
         exit;
      end;

      case _unit_grbcol(m_mx,m_my,_tuids[-m_brtar]._r,HPlayer,_tuids[-m_brtar]._uf,true,_tuids[-m_brtar]._itbuild) of
        0 : m_brcolor:=c_lime;
        1 : m_brcolor:=c_red;
        2 : m_brcolor:=c_blue;
      else  m_brcolor:=c_gray;
      end;
   end
   else
     if(m_brush>0)then
     begin
        if(ui_lsuc>0)then ;
         if(_chabil(m_brush,ui_lsuc,HPlayer,m_brtar,ui_su_bld,ui_su_spd)=false)then m_brush:=0;
     end;
end;

procedure _PanelAbility(ap,atar,arg3,arg4:integer;nobrush:boolean);
begin
   with _toids[ap] do
    if((rtar and at_anytar)=0)or(nobrush)
    then _porder(ap,atar,arg3,arg4)
    else
    begin
       m_brush:=ap;
       m_brtar:=atar;
       _chkbrush;
    end;
end;


procedure _PanelClick(rc:boolean;bx,by:integer);
var bc:byte;
begin
   ui_redraw:=0;
   PlayGSND(snd_click);
   bc:=0;
   if(0<=by)and(by<=ui_p_btnsh)then
    if(bx=0)
    then ui_tab:=by
    else
    if(bx=ui_p_xsbtns)then
      case by of
      0 : begin
             _igchat:=false;
             ToggleMenu;
          end;
      1 : TogglePause;
      2 : if(net_nstat<>ps_none)then ToggleChatTarget;
      end
    else
     if(_rpls_rst>=rpl_rhead)then
      case bx of
  ui_p_rsecx : case by of
               0: _fsttime:=not _fsttime;
               1: begin _rpls_log:=not _rpls_log;ui_chat_shlm:=0 end;
               2: if(rc=false)then
                  begin
                     if(HPlayer>=MaxPlayers)
                     then HPlayer:=0
                     else inc(HPlayer,1);
                  end
                  else
                  begin
                     if(HPlayer=0)
                     then HPlayer:=MaxPlayers
                     else dec(HPlayer,1);
                  end;
               end;
1+ui_p_rsecx : case by of
               0: if(rc=false)
                  then _rpls_step:=vid_fps
                  else _rpls_step:=vid_fps*5;
               1: _fog:=not _fog;
               end;
2+ui_p_rsecx : case by of
               0: _rpls_pause:=not _rpls_pause;
               end;
      end
     else
      if(1<=bx)and(bx<ui_p_rsecx)then
      begin
         if(ui_p_lsecwi<=bx)then
         begin
            dec(bx,ui_p_lsecwi);
            if(by>=2)then
            begin
               if(bx=0)then _player_s_o(k_shift,0,1,0,po_selspec ,HPlayer);
            end
            else
              with _players[HPlayer] do
              begin
                 bc:=ui_UIMBTNS[race,bx,by];
                 if(bc>0)then
                  if(rc=false)
                  then _player_s_o(k_shift,bc,0,0,po_selspec ,HPlayer)
                  else
                    if(uid_e[bc]=1)then _player_s_o(0,uid_u0[bc],0,0,po_uorder ,HPlayer);
              end;
         end
         else
         with _players[HPlayer] do
         begin
            bc:=ui_UIPBTNS[bx-1,by,ui_tab,race];
            if(bc>0)then
             case ui_tab of
          0 : if(rc=false)then // start building
              begin
                 m_brush:=uo_prod;
                 m_brtar:=-bc;
                 _chkbrush;
              end;
          1 : case race_pstyle[false,_players[HPlayer].race] of  // unit production
              true : if(rc=false)then  // warp style
                     begin
                        m_brush:=uo_prod;
                        m_brtar:=-bc;
                        _chkbrush;
                     end;
              false: if(rc=false)
                     then _player_s_o(uo_prod,-bc,0 ,0, po_uorder ,HPlayer)
                     else _player_s_o(uo_prod,-bc,-1,0, po_uorder ,HPlayer);
              end;
          2: ;
             end;
         end;
      end
      else
       if(ui_p_rsecx<=bx)and(bx<ui_p_xsbtns)then
       begin
          bc:=ui_UIABTNS[ui_lsuc,bx-ui_p_rsecx,by];
          if(bc>0)then
           if(rc=false)
           then _PanelAbility(bc,0,0,0,false)
           else _PanelAbility(uo_auto,bc,integer(bc in ui_su_aut),0,false);
             //if(bc in ui_su_aut)
             //then _player_s_o(bc,0,0,0, po_autoa  ,HPlayer)
             //else _player_s_o(bc,1,0,0, po_autoa  ,HPlayer);
       end;
end;

procedure _hotkeys(k:cardinal);
var ko:cardinal;
    bc,
    uibx,
    uiby:integer;
begin
   if(k=sdlk_pause)
   then TogglePause
   else
     if(G_Status=0)then
      case k of
      sdlk_tab: begin
                   inc(ui_tab,1);
                   ui_tab:=ui_tab mod 3;
                end;
      else
        if(_testmode)and(net_nstat=0)then
         case k of
            sdlk_end        : _fsttime:=not _fsttime;
            sdlk_home       : _warpten:=not _warpten;
            sdlk_pageup     : with _players[HPlayer] do if(state=PS_Play)then state:=PS_Comp else state:=PS_Play;
            sdlk_pagedown   : ;//with _players[HPlayer] do if(upgr[upgr_invuln]=0)then upgr[upgr_invuln]:=1 else upgr[upgr_invuln]:=0;
            sdlk_backspace  : _fog:=not _fog;
            SDLK_F5         : begin HPlayer:=0;exit end;
            SDLK_F6         : begin HPlayer:=1;exit end;
            SDLK_F7         : begin HPlayer:=2;exit end;
            SDLK_F8         : begin HPlayer:=3;exit end;
            SDLK_F9         : begin HPlayer:=4;exit end;
            SDLK_F10        : begin HPlayer:=5;exit end;
            SDLK_F11        : begin HPlayer:=6;exit end;
            sdlk_insert     : _draw:= not _draw;
         end;

        case k of
          sdlk_0..sdlk_9 : begin
                              ko:=_event^.key.keysym.sym-sdlk_0;
                              if (k_ctrl>1)
                              then _player_s_o(ko,0,0,0,po_setorder,HPlayer)
                              else
                                if(k_dbl>0)and(ordx[ko]>0)and(ko>0)
                                then _moveHumView(ordx[ko] , ordy[ko])
                                else _player_s_o(ko,k_shift,0,0,po_selorder,HPlayer);
                           end;
          sdlk_F2        : _PanelClick(false,ui_p_lsecwi,2);
        else
           if(k_ctrl>1)and(k=sdlk_A)then
           begin
              _PanelClick(false,ui_p_lsecwi,2);
              exit;
           end;

           ko:=0;
           if(k_ctrl >1)then ko:=SDLK_LCtrl;
           if(k_shift>1)then ko:=sdlk_LShift;
           if(k_alt  >1)then ko:=sdlk_LAlt;

           for uiby:=0 to ui_p_btnsh do
            for uibx:=1 to ui_p_mainbtns do
             if(_rpls_rst>=rpl_rhead)then
             else
               if(uibx<ui_p_rsecx)then
               begin
                  bc:=ui_UIPBTNS[uibx-1,uiby,ui_tab,_players[HPlayer].race];
                  if(bc>0)then
                   with _tuids[bc] do
                    case ui_tab of
                     0,1: begin
                             if(_ukey2>0)and(ko<>_ukey2)then continue;
                             if(_ukey1=k)then
                             begin
                                _PanelClick(false,uibx,uiby);
                                exit;
                             end;
                          end;
                       2:;
                    end;
               end
               else
               begin
                  bc:=ui_UIABTNS[ui_lsuc,uibx-ui_p_rsecx,uiby];
                  with _toids[bc] do
                  begin
                     if(_okey1=k)then
                     begin
                        if(_okey2>0)and(ko<>_okey2)then continue;
                     end
                     else
                       if(_okey3<>k)then continue;
                     _PanelClick(false,uibx,uiby);
                     exit;
                  end;
               end;
        end;
      end;
   k_dbl:=vid_h4fps;
end;

procedure _keyp(i:pbyte);
begin
   if (i^>1)and(i^<255) then inc(i^,1);
   if (i^=1) then i^:=0;
end;

procedure _WindowEvents;
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

   while (SDL_PollEvent(_EVENT)>0) do
    CASE (_EVENT^.type_) OF
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
                            SDL_BUTTON_middle    : if(_menu=false)and(G_Started)then m_vmove:=true;
                            SDL_BUTTON_WHEELDOWN : if(_menu)then
                                                   begin
                                                      vid_mredraw:=true;

                                                      //if(_m_sel=30)then _scrollV(@_cmp_sm,1,0,MaxMissions-vid_camp_m);
                                                      if(menu_s1=ms1_svld)then _scrollV(@_svld_sm,1,0,_svld_ln-menu_svld_m-1);
                                                      if(menu_s1=ms1_reps)then _scrollV(@_rpls_sm,1,0,_rpls_ln-menu_rpls_m-1);
                                                   end;
                            SDL_BUTTON_WHEELUP   : if(_menu)then
                                                   begin
                                                      vid_mredraw:=true;

                                                      //if(_m_sel=30)then _scrollV(@_cmp_sm,-1,0,MaxMissions-vid_camp_m);
                                                      if(menu_s1=ms1_svld)then _scrollV(@_svld_sm,-1,0,_svld_ln-menu_svld_m-1);
                                                      if(menu_s1=ms1_reps)then _scrollV(@_rpls_sm,-1,0,_rpls_ln-menu_rpls_m-1);
                                                   end;
                              else
                              end;
                           end;
      SDL_QUITEV         : begin _CYCLE:=false; end;
      SDL_KEYUP          : begin
                              k_chrt:=1;
                              case (_EVENT^.key.keysym.sym) of
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
                                if(_menu=false)and(_igchat=false)and(G_Started)then _hotkeys(_event^.key.keysym.sym);
                              end;
                           end;
    else
    end;
end;

function _uichabilcast:boolean;
begin
   _uichabilcast:=false;

   if(m_brtar<0)and(m_brcolor<>c_lime)then exit;
   if(_chabilt(m_brush,HPlayer,m_brtar)=false)then exit;

   _uichabilcast:=true;
end;

procedure G_Mouse;
begin
   m_mx := m_vx+vid_vx;
   m_my := m_vy+vid_vy;
   m_bx :=(m_vx-ui_mmwidth) div vid_BW;
   m_by :=(m_vy-ui_panelby) div vid_BW;

   if(m_ldblclk>0)then dec(m_ldblclk,1);

   _chkbrush;

   if(k_ml=2)then
   begin
      ui_redraw:=0;
      if(m_vy<ui_panely)then
      begin
         if(m_brush=0)then
         begin
            m_sxs:=m_mx;
            m_sys:=m_my;
         end
         else
         begin
            if(_uichabilcast=false)then exit;
            _porder(m_brush,m_brtar,m_mx,m_my);
            if(m_brush<>uo_prod)and(k_shift=0)then
            begin
               m_brush:=uo_rightcl;
               m_brtar:=0;
            end;
            exit;
         end;
      end
      else
        if(m_vx<=ui_mmwidth)then //minimap
        begin
           if(m_brush>0)then
           begin
              if(_uichabilcast=false)then exit;
              _porder(m_brush,m_brtar,trunc(m_vx/map_mmcx),trunc((m_vy-ui_panely)/map_mmcx));
              if(m_brush<>uo_prod)and(k_shift=0)then
              begin
                 m_brush:=uo_rightcl;
                 m_brtar:=0;
              end;
              exit;
           end
           else ui_panelmmm:=true;
        end
        else
          if(m_vy<ui_panelby)then  //small panel
          begin

          end
          else _PanelClick(false,m_bx,m_by);
   end;

   if(k_ml=1)then //select
   begin
      ui_panelmmm:=false;

      if(m_sxs>-1)then
      begin
         ui_redraw:=0;

         if(m_ldblclk>0)then
          if(k_shift<2)
          then _player_s_o(vid_vx,vid_vy,vid_vx+vid_mw,vid_vy+vid_mh, po_dblselect  ,HPlayer)
          else _player_s_o(vid_vx,vid_vy,vid_vx+vid_mw,vid_vy+vid_mh, po_adblselect ,HPlayer)
         else
          if(k_shift<2)
          then _player_s_o(m_sxs,m_sys,m_mx,m_my,po_select ,HPlayer)
          else _player_s_o(m_sxs,m_sys,m_mx,m_my,po_aselect,HPlayer);

         m_sxs:=-1;
         m_ldblclk:=vid_h4fps;
      end;
   end;

   if(ui_panelmmm)and(m_sxs=-1)then
   begin
      if(k_ml=3)then ui_redraw:=0;
      vid_vx:=trunc(m_vx/map_mmcx)-(vid_mw shr 1);
      vid_vy:=trunc((m_vy-ui_panely)/map_mmcx)-(vid_mh shr 1);
      _view_bounds;
   end;

   if(k_mr=2)then                // right clic
   begin
      if(m_vy<ui_panely)then
      begin
         if(m_brush=0)then _porder(m_brush,m_brtar,m_mx,m_my);
         m_brush:=0;
         m_brtar:=0;
      end
      else
        if(m_vx<=ui_mmwidth)then //minimap
        begin
           if(m_brush=uo_rightcl)then _porder(m_brush,m_brtar,trunc(m_vx/map_mmcx),trunc((m_vy-ui_panely)/map_mmcx));
           m_brush:=uo_rightcl;
           m_brtar:=0;
        end
        else
          if(m_vy<ui_panelby)then  //small panel
          begin
          end
          else _PanelClick(true,m_bx,m_by);// buttoms
   end;
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

procedure G_Keyboard;
begin
   if(m_vmove=false) then _view_move;
   if(_igchat)then ui_chat_str:=menu_sf(ui_chat_str,k_kbstr,ChatLen2);
end;

procedure _inputGame;
begin
   _WindowEvents;

   if(_menu)
   then G_Menu
   else
   begin
      G_Keyboard;
      G_Mouse;
   end;
end;


