
procedure D_timer(tar:pSDL_Surface;x,y:integer;time:cardinal;ta:byte;str:shortstring);
var m,s,h:cardinal;
    hs,ms,ss:shortstring;
begin
   s:=time div vid_fps;
   m:=s div 60;
   s:=s mod 60;
   h:=m div 60;
   m:=m mod 60;
   if(h>0)then
   begin
      if(h<10)then hs:='0'+c2s(h) else hs:=c2s(h);
      str:=hs+':';
   end;
   if(m<10)then ms:='0'+c2s(m) else ms:=c2s(m);
   if(s<10)then ss:='0'+c2s(s) else ss:=c2s(s);
   str:=str+ms+':'+ss;
   _draw_text(tar,x,y,str,ta,255,c_white);
end;

procedure D_Minimap;
begin
   rectangleColor(ui_uminimap,vid_mmvx,vid_mmvy,vid_mmvx+map_mmvw,vid_mmvy+map_mmvh, c_white);

   _draw_surf(ui_panel,0,1,ui_tminimap);
   _draw_surf(ui_panel,0,1,ui_uminimap);

   boxColor(ui_uminimap,0,0,ui_uminimap^.w,ui_uminimap^.h,c_black);
end;

procedure _drawBtn(tar:pSDL_Surface;x,y:integer;surf:pSDL_Surface;
sel:boolean=false;auto:boolean=false;dsbl:boolean=false;
lu1:shortstring='';lu1c:cardinal=0;lu2:shortstring='';ru:shortstring='';rd:shortstring='';ld:shortstring='';ldc:cardinal=0;rdg:boolean=false);
begin
   if(surf=_dsurf)then exit;
   x:=ui_mmwidth+x*vid_BW+1;
   y:=ui_p_uplnh+y*vid_BW+1;
   _draw_surf(tar,x,y,surf);
   if(dsbl)then boxColor(tar,x,y,x+vid_BW-2,y+vid_BW-2,c_ablack);
   if(sel)
   then _draw_surf(tar,x,y,spr_btnsel)
   else
     if(auto)
     then _draw_surf(tar,x,y,spr_btnaut);
   if(lu1c=0)then lu1c:=c_white;
   if(lu1<>'0')then _draw_text(tar,x+1       ,y+1       ,lu1,ta_left  ,5,lu1c);
   if(lu2<>'0')then _draw_text(tar,x+1       ,y+font_w+1,lu2,ta_left  ,5,c_yellow);
   if(ru <>'0')then _draw_text(tar,x+vid_BW-1,y+1       ,ru ,ta_Fright,5,c_lime);
   if(rd <>'0')then
    if(rdg)
    then _draw_text(tar,x+vid_BW-1,y+ui_dBW  ,rd ,ta_Fright,5,c_gray)
    else _draw_text(tar,x+vid_BW-1,y+ui_dBW  ,rd ,ta_Fright,5,c_orange);
   if(ld <>'0')then _draw_text(tar,x+1       ,y+ui_dBW  ,ld ,ta_left  ,5,ldc);
end;

procedure D_Panel;
var   pc : cardinal;
uc,ux,uy : integer;
      cc : cardinal;
begin
   if(ui_redraw=0)then
   begin
      _draw_surf(ui_panel,0,0,ui_panelb);

      D_Minimap;
      D_timer(ui_panel,ui_p_xtimer,ui_p_uplnhh,G_Step,ta_FVleft,str_time);

      _draw_text(ui_panel,ui_p_xchat+vid_hBW ,ui_p_uplnh+vid_hBW ,str_menu, ta_FVmiddle,255,c_white);
      _draw_text(ui_panel,ui_p_xchat+2       ,ui_p_ychat+2       ,str_chat, ta_left    ,255,mic((net_nstat<>ns_none),false));
      for uc:=1 to MaxPlayers do
       if(uc<>HPlayer)then
       begin
          ux:=ui_p_xchat+((uc-1) mod 2)*vid_hBW+3;
          uy:=ui_p_ychat+((uc-1) div 2)*11+font_w+4;
          cc:=c_gray;
          if(net_nstat<>ns_none)then
           if((ui_chattar and (1 shl uc))>0)
           then cc:=_players[uc].color
           else cc:=c_gray;
          _draw_text(ui_panel,ux,uy,'#'+b2s(uc), ta_left,255, cc);
       end;
      if(net_nstat=ns_none)
      then pc:=c_gray
      else
        if(0<G_Status)and(G_Status<=MaxPlayers)
        then pc:=_players[G_Status].color
        else pc:=c_white;
      _draw_text(ui_panel,ui_p_xchat+vid_hBW ,ui_p_uplnh+vid_2hBW,str_pause ,ta_FVmiddle,255,pc);

      with _players[HPlayer] do
      begin
         _drawBtn(ui_panel,0,0,spr_uitab[0],0=ui_tab,false,false,i2s(ui_uidiptb),c_white,i2s(ui_bldblda[true]        ),b2s(uid_sb),b2s(uid_b),b2s(_bldrs),c_white);
         _drawBtn(ui_panel,0,1,spr_uitab[1],1=ui_tab,false,false,i2s(ui_uidiptu),c_white,b2s(uidsip+ui_bldblda[false]),b2s(uid_su),b2s(uid_u),b2s(_brcks),c_white);
         _drawBtn(ui_panel,0,2,spr_uitab[2],2=ui_tab,false,false,'',0,'','',b2s(_smths));

         _draw_text(ui_panel,ui_p_xenrgy,ui_p_uplnhh,#19+'E: '+#25+b2s(menerg-cenerg)+'/'+b2s(menerg),ta_FVleft ,255,c_white);
         _draw_text(ui_panel,ui_p_xmanay,ui_p_uplnhh,#18+'M: '+#25+b2s(cmana)        +'/'+b2s(mmana) ,ta_FVleft ,255,c_white);
         _draw_text(ui_panel,ui_p_xarmy ,ui_p_uplnhh,#16+'A: '+#25+b2s(army)                         ,ta_FVleft ,255,c_white);

         if(_rpls_rst>=rpl_rhead)then
         begin
            _drawBtn(ui_panel,ui_p_rsecx  ,0,spr_rspeed,_fsttime);
            _drawBtn(ui_panel,ui_p_rsecx+1,0,spr_rskip );
            _drawBtn(ui_panel,ui_p_rsecx+2,0,spr_rpause,_rpls_pause);
            _drawBtn(ui_panel,ui_p_rsecx  ,1,spr_rlog  ,_rpls_log);
            _drawBtn(ui_panel,ui_p_rsecx+1,1,spr_rfog  ,_fog);
            if(HPlayer=0)
            then _drawBtn(ui_panel,ui_p_rsecx  ,2,spr_rvis  ,false,false,false,'',c_white,'#'+b2s(_rpls_who),'','','ALL'           ,_players[HPlayer].color)
            else _drawBtn(ui_panel,ui_p_rsecx  ,2,spr_rvis  ,false,false,false,'',c_white,'#'+b2s(_rpls_who),'','','#'+b2s(HPlayer),_players[HPlayer].color);
         end
         else
          if(ui_lsuc>0)then
           with _tuids[ui_lsuc] do
           begin
              //if(_mmana>0)then _draw_text(ui_panel,ui_p_xmana,ui_p_uplnhh,#14+'E: '+#25+b2s(ui_su_mana)+'/'+b2s(_mmana) ,ta_FVleft  ,255,c_white);

              for ux:=0 to ui_p_rsecwi do
               for uy:=0 to ui_p_btnsh do
               begin
                  uc:=ui_UIABTNS[ui_lsuc,ux,uy];
                  if(uc>0)then
                   with _toids[uc] do
                    if(ui_su_bld)or(rnbld)then
                     //_drawBtn(ui_panel,ui_p_rsecx+ux,uy,_obtn,(uc in ui_su_abil),(uc in ui_su_aut),false,_okhnb);
                     _drawBtn(ui_panel,ui_p_rsecx+ux,uy,_obtn,(uc in ui_su_abil),(uc in ui_su_aut),not _chabil(uc,ui_lsuc,HPlayer,0,ui_su_bld,ui_su_spd),_okhnb);
               end;
           end;

         if(ui_tab<2)then
         begin
            for ux:=0 to 1 do
             for uy:=0 to 1 do
             begin
                uc:=ui_UIMBTNS[race,ux,uy];
                if(uc>0)then _drawBtn(ui_panel,ui_p_lsecwi+ux,uy,_tuids[uc]._ubtn,false,false,uid_e[uc]=0,'',c_white,i2s(ui_bldblds[uc]),b2s(uid_s[uc]),b2s(uid_e[uc]),'',0, uid_e[uc]>=_tuids[uc]._max);
             end;
            _drawBtn(ui_panel,ui_p_lsecwi,2,spr_b_selall,false,false,false,str_selall);
            vlineColor(ui_panel,ui_p_minispx,1              ,ui_mmwidth    ,c_white);
            hlineColor(ui_panel,ui_p_minispx,ui_p_minisphlx1,ui_p_minisphly,c_white);
         end;

         for ux:=0 to ui_p_lsecwi do
          for uy:=0 to ui_p_btnsh do
           case ui_tab of
           0  : begin
                   uc:=ui_UIPBTNS[ux,uy,ui_tab,race];
                   if(uc>0)then _drawBtn(ui_panel,1+ux,uy,_tuids[uc]._ubtn,(m_brtar=-uc),false,(_checkBldPrc(HPlayer,true )=false) or _unitBC(HPlayer,uc) or (_chprodmana(uc,HPlayer)=false),i2s(ui_uidipts[uc]),c_white,i2s(ui_bldblds[uc])          ,b2s(uid_s[uc]),b2s(uid_e[uc]),'',0, uid_e[uc]>=_tuids[uc]._max);
                end;
           1  : begin
                   uc:=ui_UIPBTNS[ux,uy,ui_tab,race];
                   if(uc>0)then _drawBtn(ui_panel,1+ux,uy,_tuids[uc]._ubtn,(m_brtar=-uc),false,(_checkBldPrc(HPlayer,false)=false) or _unitBC(HPlayer,uc) or (_chprodmana(uc,HPlayer)=false),i2s(ui_uidipts[uc]),c_white,i2s(uidip[uc]+ui_bldblds[uc]),b2s(uid_s[uc]),b2s(uid_e[uc]),'',0, uid_e[uc]>=_tuids[uc]._max);
                end;
           2  : ;
           end;
      end;
   end;
end;

procedure D_UIText;
var i:byte;
begin
   // Chat messages
   if(_igchat)or(_rpls_log)then
   begin
      for i:=0 to MaxNetChat do _draw_text(_screen,ui_chatx,ui_chaty2-txt_line_h3*i,net_clchatm[i],ta_left,255,c_white);
      if(_rpls_log=false)then
      _draw_text(_screen,ui_chatx,ui_chaty1,ui_chat_str+chat_type[ui_redraw>vid_h8fps], ta_left,vid_ingamecl, c_white);
   end
   else
     if(ui_chat_shlm>0)then
     begin
        _draw_text(_screen,ui_chatx,ui_chaty2,net_clchatm[0],ta_left,255,c_white);
        dec(ui_chat_shlm,1);
     end;

   // Game status
   case G_Status of
   0            : ;
   1..MaxPlayers: _draw_text(_screen,ui_xpws,font_w,str_pause ,ta_Fmiddle,255,_players[G_Status].color);
   18           : _draw_text(_screen,ui_xpws,font_w,str_repend,ta_Fmiddle,255,c_white);
   19           : _draw_text(_screen,ui_xpws,font_w,str_waitsv,ta_Fmiddle,255,_players[net_cl_svpl].color)
   else
     with _players[HPlayer] do
      if(20<=G_Status)then
      begin
         if((G_Status-20)=team)
         then _draw_text(_screen,ui_xpws,font_w,str_win   ,ta_Fmiddle,255,c_lime)
         else _draw_text(_screen,ui_xpws,font_w,str_lose  ,ta_Fmiddle,255,c_red );
      end
      else _draw_text(_screen,ui_xpws,font_w,str_pause ,ta_Fmiddle,255,c_white);
   end;
   _draw_text(_screen,ui_xpws,0,b2s(G_Status)+' '+b2s(anb_Terrain[map_trt])+' '+b2s(map_trt) ,ta_Fmiddle,255,c_white);


   // hints
   with _players[HPlayer] do
    if(m_vx>ui_mmwidth)then
     if(0<=m_by)and(m_by<=ui_p_btnsh)then
      if(ui_panelby<=m_vy)then
      begin
        if(m_bx=0)then _draw_text(_screen,ui_p_lhintx,ui_chaty3,str_tabs[m_by],ta_Left,255,c_white);

        case ui_tab of
        0,
        1 : begin
               if(1<=m_bx)and(m_bx<ui_p_lsecwi)then
               begin
                  i:=ui_UIPBTNS[m_bx-1,m_by,ui_tab,race];
                  if(i>0)then _draw_text(_screen,ui_p_lhintx,ui_chaty3,_tuids[i]._uhint,ta_Left,255,c_white);
               end;
               if(ui_p_lsecwi<=m_bx)and(m_bx<ui_p_rsecx)then
               begin
                  if(m_by=2)then
                   if(m_bx=ui_p_lsecwi)
                   then _draw_text(_screen,ui_p_lhintx,ui_chaty3,str_selallh,ta_Left,255,c_white)
                   else
                  else
                   if(m_by=0)and(m_bx=ui_p_lsecwi)
                   then _draw_text(_screen,ui_p_lhintx,ui_chaty3,str_builders,ta_Left,255,c_white)
                   else
                   begin
                      i:=ui_UIMBTNS[race,m_bx-ui_p_lsecwi,m_by];
                      if(i>0)then _draw_text(_screen,ui_p_lhintx,ui_chaty3,_tuids[i]._uname,ta_Left,255,c_white);
                   end;
               end;
            end;
        2 : ;
        end;

        if(ui_p_rsecx<=m_bx)and(m_bx<ui_p_xsbtns)then
        begin
           i:=ui_UIABTNS[ui_lsuc,m_bx-ui_p_rsecx,m_by];
           if(i>0)then
           begin
              _draw_text(_screen,ui_p_rhintx,ui_rpabily,_toids[i]._ohint,ta_Left,255,c_white);
           end;
        end;
      end
      else
        if(ui_panely<m_vy)then
         case m_bx of
         0,1: _draw_text(_screen,ui_p_lhintx,ui_chaty3,str_uienerg,ta_Left,255,c_white);
         2,3: _draw_text(_screen,ui_p_lhintx,ui_chaty3,str_uimana ,ta_Left,255,c_white);
         4,5: _draw_text(_screen,ui_p_lhintx,ui_chaty3,str_uiarmy ,ta_Left,255,c_white);
         end;

end;

procedure D_UI;
begin
   if(m_brtar<0)then
    with (ui_uasprites[-m_brtar]^) do
     with _tuids[-m_brtar] do
     begin
        if(surf<>_dsurf)then
        begin
           SDL_SetAlpha(surf,SDL_SRCALPHA,128);
           _draw_surf(_screen,m_vx-hw,m_vy-hh,surf);
           SDL_SetAlpha(surf,SDL_SRCALPHA,255);
        end;
        circleColor(_screen,m_vx,m_vy,_r,m_brcolor);
     end;

   D_Panel;

   _draw_surf(_screen,0,ui_panely,ui_panel);

   if(m_sxs>-1)then rectangleColor(_screen,m_sxs-vid_vx, m_sys-vid_vy, m_vx, m_vy, _players[HPlayer].color);

   if(m_brush=0)or(m_brtar<0)
   then _draw_surf(_screen,m_vx,m_vy,spr_cursor)
   else
   begin
      circleColor(_screen,m_vx,m_vy,10,c_white);
      hlineColor(_screen,m_vx-12,m_vx+12,m_vy,c_white);
      vlineColor(_screen,m_vx,m_vy-12,m_vy+12,c_white);
   end;

   D_UIText;

   inc(ui_redraw,1);
   ui_redraw:=ui_redraw mod ui_redrawp;

   if(ui_umark_ut>0)then
   begin
      dec(ui_umark_ut,1);
      if(ui_umark_ut=0)then ui_umark_u:=0;
   end;
end;

