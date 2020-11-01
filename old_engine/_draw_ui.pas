
procedure D_Alarms;
var i,r:byte;
begin
   for i:=0 to vid_uialrm_n do
    with ui_alrms[i] do
     if(at>0)then
     begin
        r:=(at*2) mod vid_uialrm_ti;
        if(ab)
        then RectangleColor(_minimap,ax-r,ay-r,ax+r,ay+r, c_white)
        else CircleColor   (_minimap,ax  ,ay  ,r,c_white);
        dec(at,1);
     end;
end;

procedure D_Minimap;
begin
   rectangleColor(_minimap,vid_mmvx,vid_mmvy,vid_mmvx+map_mmvw,vid_mmvy+map_mmvh, c_white);

   D_Alarms;

   _draw_surf(spr_panel,1,1,_minimap);
   _draw_surf(_minimap,0,0,_bminimap);
end;

procedure D_BuildUI;
var spr:PTUSprite;
      u:PTUnit;
      i:byte;
     sy:integer;
begin
   with _players[HPlayer]do
   case m_sbuild of
   0.._uts:
   begin
      sy :=cl2uid[race,true,m_sbuild];
      u  :=@_ulst[sy];
      spr:=_unit_spr(u);
      if(bld_r>0)and(m_sbuildc=c_lime)
      then circleColor(_screen,m_vx,m_vy,u^.r,c_green)
      else circleColor(_screen,m_vx,m_vy,u^.r,m_sbuildc);

      sy:=0;

      SDL_SetAlpha(spr^.surf,SDL_SRCALPHA or SDL_RLEACCEL,128);
      _draw_surf(_screen,m_vx-spr^.hw,m_vy-spr^.hh-sy,spr^.surf);
      SDL_SetAlpha(spr^.surf,SDL_SRCALPHA or SDL_RLEACCEL,255);

      if(m_sbuild in [4,7,10])then circleColor(_screen,m_vx,m_vy,towers_sr[upgr[upgr_towers]],c_gray);

      for i:=0 to _uts do
       if(ui_builders_x[i]<>0)then circleColor(_screen,ui_builders_x[i]-vid_vx,ui_builders_y[i]-vid_vy,ui_builders_r[i],c_white);

      if(g_mode=gm_ct)then
       for i:=1 to MaxPlayers do
        with g_ct_pl[i] do circleColor(_screen,px-vid_vx,py-vid_vy,base_r,c_blue);

      rectangleColor(_screen,build_b-vid_vx,build_b-vid_vy,map_b1-vid_vx,map_b1-vid_vy,c_white);
   end;
   end;
end;

procedure D_OrderIcons;
const rown = 6;
var  x,y,y0:integer;
     c,i,n :byte;
     b     :boolean;
begin
   y  :=2+vid_oiw;
   for i:=1 to 9 do
   begin
      n  :=0;
      y0 := -1;
      x  :=vid_mw-vid_oiw*2;
      for b:=false to true do
      begin
         for c:=0 to _uts do
          if(c in ui_orderu[i,b])then
          begin
             if(y0=-1)then y0:=y+4;
             if((n mod rown)=0)then
             begin
                if(n>0)then inc(y,vid_oisw);
                x:=vid_mw-vid_oips;
             end;
             with _players[HPlayer] do
             begin
                if(c=4)and(race=r_hell)then
                 if(g_addon)
                 then spr_ui_oico[race,b,c]:=spr_iob_knight
                 else spr_ui_oico[race,b,c]:=spr_iob_baron;

                _draw_surf(_screen,x,y,spr_ui_oico[race,b,c]);
             end;

             dec(x,vid_oisw);
             inc(n,1);
          end;
      end;
      if(y0=-1)then y0:=y+4;
      _draw_text(_screen,vid_mw,y0   ,b2s(i)      ,ta_right,255,c_white);
      _draw_text(_screen,vid_mw,y0+10,i2s(ordn[i]),ta_right,255,c_gray);
      inc(y,vid_oihw);
   end;
   _draw_text(_screen,vid_mw-4,2,str_orders,ta_right,255,c_white);
end;

procedure _drawBtn(tar:pSDL_Surface;x,y:integer;surf:pSDL_Surface;sel,dsbl:boolean);
begin
   x:=x*vid_BW+1;
   y:=ui_bottomsy+y*vid_BW+1;
   _draw_surf(tar,x,y,surf);
   if(sel)then rectangleColor(tar,x+1,y+1,x+vid_BW-3,y+vid_BW-3,c_lime)
   else
     if(dsbl)then boxColor(tar,x,y,x+vid_BW-2,y+vid_BW-2,c_ablack);
end;

procedure _drawBtnt(tar:pSDL_Surface;x,y:integer;
lu1 ,lu2 ,ru ,rd ,ld :shortstring;
clu1,clu2,cru,crd,cld:cardinal);
var ui_dBW:integer;
begin
   x:=x*vid_BW+1;
   y:=ui_bottomsy+y*vid_BW+1;
   ui_dBW:=vid_BW-font_w-3;

   if(lu1<>'')and(lu1[1]<>'0')then _draw_text(tar,x+2       ,y+3       ,lu1,ta_left  ,5,clu1);
   if(lu2<>'')and(lu2[1]<>'0')then _draw_text(tar,x+2       ,y+5+font_w,lu2,ta_left  ,5,clu2);
   if(ru <>'')and(ru [1]<>'0')then _draw_text(tar,x+vid_BW-3,y+3       ,ru ,ta_right ,5,cru );
   if(rd <>'')and(rd [1]<>'0')then _draw_text(tar,x+vid_BW-3,y+ui_dBW  ,rd ,ta_right ,5,crd );
   if(ld <>'')and(ld [1]<>'0')then _draw_text(tar,x+2       ,y+ui_dBW  ,ld ,ta_left  ,5,cld );
end;


procedure D_ui;
var ui,ux,uy,uid:integer;
function r2s(r:integer):shortstring;
begin if(r<=0)then r2s:='' else r2s:=i2s((r div vid_fps)+1) end;
begin
   with _players[HPlayer] do
   begin
      if(_rpls_rst< rpl_rhead)then
      begin
         D_BuildUI;
         if(race=r_uac)and(ucl_s[true,8]>0)then circleColor(_screen,m_vx,m_vy,blizz_r,c_gray);
      end;

      D_Timer(ui_textx,2,g_step,ta_left,str_time);
      if(G_WTeam=255)then
       if(g_mode=gm_inv)then
       begin
          D_Timer(ui_textx,14,g_inv_t,ta_left,str_inv_time+b2s(g_inv_wn)+', '+str_time);
          if(_players[0].army>0)then _draw_text(_screen,ui_textx,26,str_inv_ml+' '+b2s(_players[0].army),ta_left,255,c_white);
       end;

      D_OrderIcons;

      if(vid_rtui=2)then
      begin
         D_minimap;
         _draw_surf(_uipanel,0,0,spr_panel);

         for ux:=0 to 3 do _draw_surf(_uipanel,ux*vid_tBW+1,ui_tabsy+1,spr_tabs[ux]);

         ux:=1+(vid_tBW*ui_tab);
         uy:=ui_tabsy+2;
         rectangleColor(_uipanel,ux+1,uy,ux+vid_tBW-3,ui_bottomsy-2,c_lime);

         ux:=0;
         if(ucl_cs[true] >0)then _draw_text(_uipanel,ux+3,uy+2 ,i2s(ucl_cs[true] ),ta_left,255,c_lime  );
         if(ui_bldsc     >0)then _draw_text(_uipanel,ux+3,uy+10,i2s(ui_bldsc     ),ta_left,255,c_yellow);
         if(ucl_c [true] >0)then _draw_text(_uipanel,ux+3,uy+20,i2s(ucl_c [true] ),ta_left,255,c_orange);

         ux:=vid_tBW;
         if(ucl_cs[false]>0)then _draw_text(_uipanel,ux+3,uy+2 ,i2s(ucl_cs[false]),ta_left,255,c_lime  );
         if(uproda       >0)then _draw_text(_uipanel,ux+3,uy+10,i2s(uproda       ),ta_left,255,c_yellow);
         if(ucl_c [false]>0)then _draw_text(_uipanel,ux+3,uy+20,i2s(ucl_c [false]),ta_left,255,c_orange);

         if(ui_upgr_time>0)then
         begin
            ux:=vid_2tBW;
            _draw_text(_uipanel,ux+3,uy+2 ,i2s((ui_upgr_time div vid_fps)+1),ta_left,255,c_white );
            _draw_text(_uipanel,ux+3,uy+12,i2s(pproda)                      ,ta_left,255,c_yellow);
         end;

         uy:=(13*vid_BW)+8;
         _draw_text(_uipanel,vid_hBW,uy,str_menu ,ta_middle,255,c_white);
         if(net_nstat>ns_none)and(G_WTeam=255)then
          if(g_paused>0)
          then _draw_text(_uipanel,vid_2BW+vid_hBW,uy,str_pause,ta_middle,255,plcolor[g_paused])
          else _draw_text(_uipanel,vid_2BW+vid_hBW,uy,str_pause,ta_middle,255,c_white);

         _draw_text(_uipanel,ui_energx  ,ui_iy,#19+i2s(menerg-cenerg),ta_right,255,c_aqua );
         _draw_text(_uipanel,ui_energx+2,ui_iy,i2s(menerg)           ,ta_left ,255,c_white);

         _draw_text(_uipanel,ui_armyx ,ui_iy,b2s(army      ),ta_middle,255,c_white);

         case ui_tab of
         0:
         begin
            for ui:=0 to 23 do
            begin
               uid:=cl2uid[race ,true ,ui];
               if(uid=0)then continue;

               if(ucl_e[true,ui]=0)then
               begin
                  if(_bc_g(a_build,ui)=false)then continue;
                  if((G_addon=false)and(cl2uid[race,true,ui] in t2))then continue;
               end;

               ux:=(ui mod 3);
               uy:=(ui div 3);

               _drawBtn (_uipanel,ux,uy,spr_b_b[race,ui],m_sbuild=ui,_bldCndt(HPlayer,ui) or not(uid in ui_prod_builds));
               _drawBtnt(_uipanel,ux,uy,
               b2s(ui_blds[ ui]),'',b2s(ucl_s [true,ui]),b2s   (ucl_e [true,ui])                                ,''     ,
               c_dyellow        ,0 ,c_lime              ,ui_muc[ucl_e[true,ui]>=_ulst[cl2uid[race,true,ui]].max],c_white);

               case ui of
               5 : if(ucl_x[5]>0)then
                    if(_units[ucl_x[5]].rld_t>0)then
                     if(race=r_uac)
                     then _drawBtnt(_uipanel,ux,uy,'','','','',r2s(_units[ucl_x[5]].rld_t),0,0,0,0,ui_rad_rld[_units[ucl_x[5]].rld_t>_units[ucl_x[5]].rld_a])
                     else _drawBtnt(_uipanel,ux,uy,'','','','',r2s(_units[ucl_x[5]].rld_t),0,0,0,0,c_aqua);
               6 : if(ucl_x[6]>0)then
                    case race of
                    r_hell: if(upgr[upgr_6bld]       >0)then _drawBtnt(_uipanel,ux,uy,'','','','',b2s(upgr  [upgr_6bld])     ,0,0,0,0,c_red );
                    r_uac : if(_units[ucl_x[6]].rld_t>0)then _drawBtnt(_uipanel,ux,uy,'','','','',r2s(_units[ucl_x[6]].rld_t),0,0,0,0,c_aqua);
                    end;
               8 : if(ucl_x[8]>0)then
                    case race of
                    r_hell: if(upgr[upgr_hinvuln]>0)then _drawBtnt(_uipanel,ux,uy,'',''                     ,'','',b2s(upgr[upgr_hinvuln])    ,0,0    ,0,0,c_red );
                    r_uac : if(upgr[upgr_blizz  ]>0)then _drawBtnt(_uipanel,ux,uy,'',b2s(upgr[upgr_blizz  ]),'','',r2s(_units[ucl_x[8]].rld_t),0,c_red,0,0,c_aqua);
                    end;
               9 : if(ucl_x[9]>0)then _drawBtnt(_uipanel,ux,uy,'','','','',r2s(_units[ucl_x[9]].rld_t),0,0,0,0,c_aqua);
               end;
            end;
         end;

         1:
         begin
            for ui:=0 to 23 do
            begin
               uid:=cl2uid[race ,false,ui];
               if(uid=0)then continue;
               if(ucl_e[false,ui]=0)then
               begin
                  if(_bc_g(a_units,ui)=false)then continue;
                  if((G_addon=false)and(cl2uid[race,false,ui] in t2))then continue;
               end;

               if(ui=4)and(race=r_hell)then
                if(g_addon)
                then spr_b_u[race,ui]:=spr_b_knight
                else spr_b_u[race,ui]:=spr_b_baron;

               ux:=(ui mod 3);
               uy:=(ui div 3);

               _drawBtn(_uipanel,ux,uy,spr_b_u[race,ui],false,_untCndt(HPlayer,ui) or (uproda>=uprodm) or (uprodu[uid]>=ui_prod_units[uid]));
               _drawBtnt(_uipanel,ux,uy,
               b2s(((ui_units_ptime[ui]+vid_ifps) div vid_fps)),b2s(uprodc[ui])+#13+b2s(ui_prod_units[uid]),b2s(ucl_s [false,ui]),b2s(   ucl_e[false,ui])                                    ,b2s(ui_units_inapc[ui]),
               c_white                                         ,c_dyellow      ,c_lime               ,ui_muc[ucl_e[false,ui]>=_ulst[cl2uid[race,false,ui]].max],c_purple);
            end;
         end;

         2:
         begin
            for ui:=0 to MaxUpgrs do
            begin
               if(_bc_g(a_upgr,ui)=false)then continue;
               if((G_addon=false)and(ui>=upgr_2tier))then break;

               ux:=(ui mod 3);
               uy:=(ui div 3);

               _drawBtn(_uipanel,ux,uy,spr_b_up[race,ui],ui_upgr[ui]>0, _upgrreq(HPlayer,ui) or (pproda>=pprodm)or(ucl_x[3]=0));

               _drawBtnt(_uipanel,ux,uy,
               b2s(((ui_upgr[ui]+vid_ifps) div vid_fps)),b2s(ui_upgrct[ui]),'',b2s(upgr[ui]),'',
               c_white                                  ,c_dyellow         ,0 ,ui_muc [upgr[ui]>=upgrade_cnt[race,ui]] ,0);
            end;
         end;

         3:
         if(_rpls_rst>=rpl_rhead)then
         begin
            _drawBtn(_uipanel,0,3,spr_b_rfog ,_fog      ,false);

            _drawBtn(_uipanel,0,4,spr_b_rfast,_fsttime  ,false);
            _drawBtn(_uipanel,1,4,spr_b_rskip,false     ,false);
            _drawBtn(_uipanel,2,4,spr_b_rstop,g_paused>0,false);
            _drawBtn(_uipanel,0,5,spr_b_rvis ,_rpls_vidm,false);
            _drawBtn(_uipanel,1,5,spr_b_rlog ,_rpls_log ,false);

            ux:=2;
            uy:=5;

            for ui:=0 to MaxPlayers do
            begin
               if(ui=0)
               then _drawBtnt(_uipanel,ux,uy,str_all          ,'','','','',c_white    ,0,0,0,0)
               else _drawBtnt(_uipanel,ux,uy,_players[ui].name,'','','','',plcolor[ui],0,0,0,0);
               _drawBtn(_uipanel,ux,uy,_dsurf,ui=HPlayer,_players[ui].army=0);

               inc(ux,1);
               if(ux>2)then
               begin
                  ux:=0;
                  inc(uy,1);
               end;
            end;
         end
         else
         begin
            _drawBtn(_uipanel,0,0,spr_b_move   ,false,ui_uimove=0   );
            _drawBtn(_uipanel,1,0,spr_b_hold   ,false,ui_uimove=0   );
            _drawBtn(_uipanel,2,0,spr_b_patrol ,false,ui_uimove=0   );

            _drawBtn(_uipanel,0,1,spr_b_attack ,false,ui_uimove=0   );
            _drawBtn(_uipanel,1,1,spr_b_stop   ,false,ui_uimove=0   );
            _drawBtn(_uipanel,2,1,spr_b_apatrol,false,ui_uimove=0   );

            _drawBtn(_uipanel,0,2,spr_b_action ,false,ui_uiaction=0 );
            _drawBtn(_uipanel,1,2,spr_b_selall ,false,ui_battle_units=0);
            _drawBtn(_uipanel,2,2,spr_b_delete ,false,(ucl_cs[false]+ucl_cs[true])=0);

            _drawBtn(_uipanel,1,3,spr_b_rclck  ,m_a_inv   ,false    );
            _drawBtn(_uipanel,2,3,spr_b_cancel ,false     ,false    );
         end;

         end;
      end;
   end;
   _draw_surf(_screen,0,0,_uipanel);
end;

procedure D_hints;
var i,uid:byte;
    ty:integer;
begin
   if(m_bx<3)and(m_by>=3)and(m_by<=13)then
   begin
      ty:=vid_mh-40;
      case m_by of
      3  : if(m_vy>ui_tabsy)
           then _draw_text(_screen,ui_textx,ty,str_hint_t[m_vx div vid_tBW ],ta_left,255,c_white)
           else _draw_text(_screen,ui_textx,ty,str_hint_a[m_vx div vid_2tBW],ta_left,255,c_white);
      13 : begin
              if(m_bx=2)then
               if(net_nstat=ns_none)or(G_WTeam<255)then exit;
              _draw_text(_screen,ui_textx,ty,str_hint_m[m_bx],ta_left,255,c_white);
           end;
      else
        i:=((m_by-4)*3)+(m_bx mod 3);
        with _players[HPlayer] do
        if(i<=_uts)then
        begin
           case ui_tab of
           0 : case i of
               0 ..23 : begin
                           uid:=cl2uid[race ,true,i];
                           if(uid=0)
                           then exit
                           else
                             if(uid_e[uid]=0)then
                             begin
                                if(_bc_g(a_build,i)=false)then exit;
                                if((G_addon=false)and(uid in t2))then exit;
                             end;
                           _draw_text(_screen,ui_textx,ty,str_un_hint[uid],ta_left,255,c_white);
                        end;
               end;
           1 : case i of
               0..23  : begin
                           uid:=cl2uid[race ,false,i];
                           if(uid=0)
                           then exit
                           else
                             if(uid_e[uid]=0)then
                             begin
                                if(_bc_g(a_units,i)=false)then exit;
                                if((G_addon=false)and(uid in t2))then exit;
                             end;
                           _draw_text(_screen,ui_textx,ty,str_un_hint[uid],ta_left,255,c_white);
                        end;
               end;
           2 : begin
                  if(i<=MaxUpgrs)then
                  begin
                     if(_bc_g(a_upgr,i)=false)then exit;
                     if(g_addon=false)and(i>=upgr_2tier)then exit;
                  end;
                  _draw_text(_screen,ui_textx,ty,str_up_hint[i+(race*_uts)],ta_left,255,c_white);
               end;
           3 : begin
                  if(_rpls_rst>=rpl_rhead)then
                  begin
                     if(i=11)or(i<9)then exit;
                  end
                  else
                     if(i<>11)and(i>8)then exit;
                  _draw_text(_screen,ui_textx,ty,str_hint[ui_tab,race,i],ta_left,255,c_white);
               end;
           end;
        end;
      end;
   end;
end;

procedure D_UIText;
var i:byte;
begin
   if(_igchat)or(_rpls_log)then
   begin
      for i:=0 to MaxNetChat do _draw_text(_screen,ui_textx,vid_mh-60-13*i,net_chat[HPlayer,i],ta_left,255,c_white);
      if(_rpls_log=false)then _draw_text(_screen,ui_textx,vid_mh-50,':'+net_chat_str+chat_type[vid_rtui>6], ta_left,vid_ingamecl, c_white);
   end
   else
     if(net_chat_shlm>0)then
     begin
        _draw_text(_screen,ui_textx,vid_mh-60,net_chat[HPlayer,0],ta_left,255,c_white);
        dec(net_chat_shlm,1);
     end;

   D_hints;

   if(_rpls_rst=rpl_end)
   then _draw_text(_screen,472,2,str_repend,ta_middle,255,c_white)
   else
    if(_rpls_rst<rpl_rhead)then
     with _players[HPlayer] do
     begin
        if(G_WTeam=255)then
        begin
           if(menu_s2<>ms2_camp)then
            if(_players[HPlayer].army=0)then _draw_text(_screen,vid_uiuphx,2,str_lose  ,ta_middle,255,c_red);
           if(G_paused>0)then
            if(net_nstat=ns_clnt)and(net_cl_svttl=ClientTTL)
            then _draw_text(_screen,vid_uiuphx,12,str_waitsv,ta_middle,255,plcolor[net_cl_svpl])
            else _draw_text(_screen,vid_uiuphx,12,str_pause ,ta_middle,255,plcolor[G_paused]);
        end
        else
          begin
             if(G_WTeam=team)
             then _draw_text(_screen,vid_uiuphx,2,str_win   ,ta_middle,255,c_lime)
             else _draw_text(_screen,vid_uiuphx,2,str_lose  ,ta_middle,255,c_red);
             exit;
          end;
     end;
end;

procedure d_uimouse;
var c:cardinal;
begin
   c:=0;
   case m_sbuild of
   -1,
   -2 : c:=c_lime;
   -3,
   -4 : c:=c_red;
   else _draw_surf(_screen,m_vx,m_vy,spr_cursor);
   end;
   if(c<>0)then
   begin
      circleColor(_screen,m_vx,m_vy,10,c);
      hlineColor(_screen,m_vx-12,m_vx+12,m_vy,c);
      vlineColor(_screen,m_vx,m_vy-12,m_vy+12,c);
   end;
end;

