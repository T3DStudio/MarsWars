
procedure d_Alarms;
var i,r:byte;
begin
   {for i:=0 to ui_max_alarms do
    with ui_alarms[i] do
     if(at>0)then
     begin
        r:=(at*2) mod vid_uialrm_ti;
        if(ab)
        then RectangleColor(r_minimap,ax-r,ay-r,ax+r,ay+r, c_white)
        else CircleColor   (r_minimap,ax  ,ay  ,        r, c_white);
        at-=1;
     end;  }

   case g_mode of
gm_cptp: for i:=1 to MaxCPoints do
          with g_cpoints[i] do
           if(ct>0)and((G_Step mod 20)>10)
           then circleColor(r_minimap,mpx,mpy,map_prmm,c_gray            )
           else circleColor(r_minimap,mpx,mpy,map_prmm,PlayerGetColor(pl));
gm_royl: circleColor(r_minimap,ui_hwp,ui_hwp,trunc(g_royal_r*map_mmcx)+1,ui_muc[(g_royal_r mod 2)=0]);
   end;
end;

procedure d_Minimap(tar:pSDL_Surface);
begin
   rectangleColor(r_minimap,vid_mmvx,vid_mmvy,vid_mmvx+map_mmvw,vid_mmvy+map_mmvh, c_white);

   d_Alarms;

   _draw_surf(tar      ,1,1,r_minimap );
   _draw_surf(r_minimap,0,0,r_bminimap);
end;

procedure d_BuildUI(tar:pSDL_Surface;lx,ly:integer);
var spr:PTMWTexture;
      i:integer;
 dunit:TUnit;
pdunit:PTUnit;
begin
   with _players[HPlayer]do
   case m_brush of
   1..255:
   begin
      m_brushx-=vid_cam_x-lx;
      m_brushy-=vid_cam_y-ly;

      with _uids[m_brush] do
      begin
         spr:=_uid2spr(m_brush,_bornadvanced[g_addon]);
         SDL_SetAlpha(spr^.surf,SDL_SRCALPHA,128);
         _draw_surf(tar,m_brushx-spr^.hw,m_brushy-spr^.hh,spr^.surf);
         SDL_SetAlpha(spr^.surf,SDL_SRCALPHA or SDL_RLEACCEL,255);

         circleColor(tar,m_brushx,m_brushy,_r,m_brushc);

         //sight range
         FillChar(dunit,SizeOf(dunit),0);
         pdunit:=@dunit;
         with dunit do
         begin
            uidi   :=m_brush;
            playeri:=HPlayer;
            player :=@_players[playeri];
            bld    :=true;
            hits   :=_mhits;
         end;
         _unit_apUID(pdunit,false);
         _unit_upgr (pdunit);
         if(UIUnitDrawRange(pdunit))then
          circleColor(tar,m_brushx,m_brushy,dunit.srange,ui_unitrS[vid_rtui>vid_rtuish]);
      end;

      m_brushx+=vid_cam_x-lx;
      m_brushy+=vid_cam_y-ly;

      // points areas
      if(g_mode=gm_cptp)then
       for i:=1 to MaxCPoints do
        with g_cpoints[i] do
         circleColor(tar,
         lx+px-vid_cam_x,
         ly+py-vid_cam_y,
         base_r,c_blue);

      // map build rect
      rectangleColor(tar,
      lx+map_b0-vid_cam_x,ly+map_b0-vid_cam_y,
      lx+map_b1-vid_cam_x,ly+map_b1-vid_cam_y,
      c_white);
   end;
   end;
end;

procedure d_OrderIcons(tar:pSDL_Surface);
const rown = 6;
var  x,y,y0:integer;
     c,i,n :byte;
     b     :boolean;
begin
   y  :=ui_texty+vid_oiw;
   if(MaxUnitOrders>1)then
   for i:=1 to MaxUnitOrders-1 do
   begin
      n  :=0;
      y0 :=-1;
      x  :=ui_oicox;
      for b:=false to true do
      for c:=0 to 255 do
      if(c in ui_orders_uids[i,b])then
      begin
         if(y0=-1)then y0:=y+4;
         if((n mod rown)=0)then
         begin
            if(n>0)then y+=vid_oisw;
            x:=ui_oicox-vid_oips;
         end;
         with _players[HPlayer] do
          with _uids[c] do _draw_surf(tar,x,y,un_sbtn[_bornadvanced[g_addon]].surf);

         x-=vid_oisw;
         n+=1;
      end;
      if(y0=-1)then y0:=y+4;
      if(ui_orders_n[i]>0)then
      begin
      _draw_text(tar,ui_oicox,y0   ,b2s(i)             ,ta_right,255,c_white);
      _draw_text(tar,ui_oicox,y0+10,i2s(ui_orders_n[i]),ta_right,255,c_gray );
      end;
      y+=vid_oihw;
   end;
   _draw_text(tar,ui_oicox-4,ui_texty+2,str_orders,ta_right,255,c_white);
end;

procedure _drawBtn(tar:pSDL_Surface;x,y:integer;surf:pSDL_Surface;sel,dsbl:boolean);
var ux,uy:integer;
begin
   if(vid_ppos<2)then
   begin
      ux:=x*vid_BW+1;
      uy:=ui_bottomsy+y*vid_BW+1;
   end
   else
   begin
      ux:=ui_bottomsy+y*vid_BW+1;
      uy:=x*vid_BW+1;
   end;
   _draw_surf(tar,ux,uy,surf);
   if(sel)then rectangleColor(tar,ux+1,uy+1,ux+vid_BW-3,uy+vid_BW-3,c_lime)
   else
     if(dsbl)then boxColor(tar,ux,uy,ux+vid_BW-2,uy+vid_BW-2,c_ablack);
end;

procedure _drawBtnt(tar:pSDL_Surface;x,y:integer;
lu1 ,lu2 ,ru ,rd ,ld :shortstring;
clu1,clu2,cru,crd,cld:cardinal;ms:shortstring);
var ux,uy:integer;
function cs(ps:pshortstring):boolean;begin cs:=(ps^<>'')and(ps^[1]<>'0'); end;
begin
   if(vid_ppos<2)then
   begin
      ux:=x*vid_BW+1;
      uy:=ui_bottomsy+y*vid_BW+1;
   end
   else
   begin
      ux:=ui_bottomsy+y*vid_BW+1;
      uy:=x*vid_BW+1;
   end;

   if(cs(@lu1))then _draw_text(tar,ux+2       ,uy+3       ,lu1,ta_left  ,5,clu1);
   if(cs(@lu2))then _draw_text(tar,ux+2       ,uy+5+font_w,lu2,ta_left  ,5,clu2);
   if(cs(@ru ))then _draw_text(tar,ux+vid_BW-3,uy+3       ,ru ,ta_right ,5,cru );
   if(cs(@rd ))then _draw_text(tar,ux+vid_BW-3,uy+ui_dBW  ,rd ,ta_right ,5,crd );
   if(cs(@ld ))then _draw_text(tar,ux+2       ,uy+ui_dBW  ,ld ,ta_left  ,5,cld );

   if(cs(@ms ))then _draw_text(tar,ux+vid_hBW,uy+vid_hBW  ,ms ,ta_middle  ,5,c_red );
end;

procedure d_TextBTN(tar:pSDL_Surface;bx,by:integer;txt:pshortstring;c:cardinal);
var ux,uy:integer;
begin
   if(vid_ppos<2)then
   begin
      ux:=bx*vid_BW+vid_hBW;
      uy:=ui_bottomsy+by*vid_BW+8;
   end
   else
   begin
      ux:=ui_bottomsy+by*vid_BW+vid_hBW;
      uy:=bx*vid_BW+8;
   end;

   _draw_text(tar,ux,uy,txt^,ta_middle,6,c);
end;

procedure d_tabbtn(tar,btn:pSDL_Surface;
bx,by,
i1,i2,i3:integer;
c1,c2,c3:cardinal;
sel:boolean);
begin
   if(vid_ppos<2)then
   begin
      _draw_surf(tar,bx,by+5,btn);
      if(sel)then rectangleColor(tar,bx+1,by+1,bx+vid_tBW-3,by+vid_BW-3,c_lime);
      if(i1>0)then _draw_text(tar,bx+3,by+3       ,i2s(i1),ta_left,255,c1);
      if(i2>0)then _draw_text(tar,bx+3,by+font_w+5,i2s(i2),ta_left,255,c2);
      if(i3>0)then _draw_text(tar,bx+3,by+ui_dBW  ,i2s(i3),ta_left,255,c3);
   end
   else
   begin
      _draw_surf(tar,bx+5,by,btn);
      if(sel)then rectangleColor(tar,bx+1,by+1,bx+vid_BW-3,by+vid_tBW-3,c_lime);
      if(i1>0)then _draw_text(tar,bx+3,by+3 ,i2s(i1),ta_left,255,c1);
      if(i2>0)then _draw_text(tar,bx+3,by+13,i2s(i2),ta_left,255,c2);
      if(i3>0)then _draw_text(tar,bx+3,by+24,i2s(i3),ta_left,255,c3);
   end;
end;

procedure d_Panel(tar:pSDL_Surface);
var ui,ux,uy,uid:integer;
             req:cardinal;
function r2s(r:integer):shortstring;
begin if(r<=0)then r2s:='' else r2s:=i2s((r div fr_fps)+1) end;
begin
   with _players[HPlayer] do
   begin
      _draw_surf(tar,0,0,r_panel);

      for ui:=0 to 3 do
      begin
         if(vid_ppos<2)then
         begin
            ux:=ui*vid_tBW+1;
            uy:=vid_panelw+1;
         end
         else
         begin
            ux:=vid_panelw+1;
            uy:=ui*vid_tBW+1;
         end;

         case ui of
         0: d_tabbtn(tar,spr_tabs[ui],ux,uy, ucl_cs[true ],ui_uid_buildn,ucl_c [true ], c_lime ,c_yellow,c_orange, ui=ui_tab);
         1: d_tabbtn(tar,spr_tabs[ui],ux,uy, ucl_cs[false],uproda       ,ucl_c [false], c_lime ,c_yellow,c_orange, ui=ui_tab);
         2: begin if(upproda>0)then uid:=(ui_first_upgr_time div fr_fps)+1 else uid:=0;
            d_tabbtn(tar,spr_tabs[ui],ux,uy, uid          ,upproda  ,0            , c_white,c_yellow,0       , ui=ui_tab);
            end;
         3: d_tabbtn(tar,spr_tabs[ui],ux,uy, 0            ,0        ,0            , 0      ,0       ,0       , ui=ui_tab);
         end;
      end;

      d_TextBTN(tar,0,8,@str_menu,c_white);
      if(net_status>ns_none)then
       if(0<g_status)and(g_status<=MaxPlayers)
       then d_TextBTN(tar,2,8,@str_pause,PlayerGetColor(g_status))
       else d_TextBTN(tar,2,8,@str_pause,c_white                 );

      case ui_tab of

      0: // buildings
      for ui:=0 to ui_ubtns do
      begin
         uid:=ui_panel_uids[race ,ui_tab,ui];
         if(uid=0)then continue;

         with _uids[uid] do
         begin
            if(uid_e[uid]<=0)then
            begin
               if(a_units[uid]<=0)then continue;
               if((G_addon=false)and(_addon))then continue;
            end;

            ux:=(ui mod 3);
            uy:=(ui div 3);

            req:=_uid_conditionals(@_players[HPlayer],uid);

            _drawBtn (tar,ux,uy,un_btn[_bornadvanced[g_addon]].surf,m_brush=uid,(req>0) or not(uid in ui_prod_builds));
            _drawBtnt(tar,ux,uy,
            b2s(ui_uid_builds[uid]),'',b2s(uid_s[uid]),b2s   (uid_e[uid])      ,r2s(ui_uid_reload[uid]),
            c_dyellow              ,0 ,c_lime         ,ui_muc[uid_e[uid]>=_max],c_aqua  ,r2s(build_cd));

            ui_uid_reload[uid]:=-1;
         end;
      end;

      1: // units
      for ui:=0 to ui_ubtns do
      begin
         uid:=ui_panel_uids[race ,ui_tab,ui];
         if(uid=0)then continue;

         with _uids[uid] do
         begin
            if(uid_e[uid]<=0)then
            begin
               if(a_units[uid]<=0)then continue;
               if((G_addon=false)and(_addon))then continue;
            end;

            ux:=(ui mod 3);
            uy:=(ui div 3);

            _drawBtn (tar,ux,uy,un_btn[_bornadvanced[g_addon]].surf,false,(_uid_conditionals(@_players[HPlayer],uid)>0) or (uproda>=uprodm) or (uprodu[uid]>=ui_prod_units[uid]));
            _drawBtnt(tar,ux,uy,
            b2s(((ui_units_ptime[uid]+fr_ifps) div fr_fps)),b2s(uprodu[uid]),b2s(uid_s[uid]),b2s(   uid_e[uid])      ,b2s(ui_units_inapc[uid]),
            c_white                                        ,c_dyellow       ,c_lime         ,ui_muc[uid_e[uid]>=_max],c_purple                ,'');
         end;
      end;

      2: // upgrades
      for ui:=0 to ui_ubtns do
      begin
         uid:=ui_panel_uids[race ,ui_tab,ui];

         if (a_upgrs[uid]<=0)then continue;
         if((G_addon=false)and(_upids[uid]._up_addon))then continue;

         ux:=(ui mod 3);
         uy:=(ui div 3);

         _drawBtn(tar,ux,uy,_upids[uid]._up_btn.surf,ui_upgr[uid]>0, (_upid_conditionals(@_players[HPlayer],uid)>0)or(upproda>=upprodm) or (upprodu[uid]>=ui_prod_upgrades[uid]));

         _drawBtnt(tar,ux,uy,
         b2s(((ui_upgr[uid]+fr_ifps) div fr_fps)),b2s(ui_upgrct[uid]),'',b2s(   upgr[uid])                      ,'',
         c_white                                 ,c_dyellow          ,0 ,ui_muc[upgr[uid]>=_upids[uid]._up_max] ,0 ,'');
      end;

      3: // actions
      if(rpls_state>=rpl_rhead)then
      begin
         _drawBtn(tar,0,4,spr_b_rfast,_fsttime    ,false);
         _drawBtn(tar,1,4,spr_b_rskip,false       ,false);
         _drawBtn(tar,2,4,spr_b_rstop,g_status>0  ,false);
         _drawBtn(tar,0,5,spr_b_rvis ,rpls_plcam  ,false);
         _drawBtn(tar,1,5,spr_b_rlog ,rpls_showlog,false);
         _drawBtn(tar,2,5,spr_b_rfog ,rpls_fog    ,false);

         ux:=2;
         uy:=6;

         for ui:=0 to MaxPlayers do
         begin
            if(ui=0)
            then _drawBtnt(tar,ux,uy,str_all          ,'','','','',c_white           ,0,0,0,0,'')
            else _drawBtnt(tar,ux,uy,_players[ui].name,'','','','',PlayerGetColor(ui),0,0,0,0,'');
            _drawBtn(tar,ux,uy,r_empty,ui=HPlayer,_players[ui].army=0);

            ux+=1;
            if(ux>2)then
            begin
               ux:=0;
               uy+=1;
            end;
         end;
      end
      else
      begin
         _drawBtn(tar,0,0,spr_b_action ,false  ,ui_uibtn_action<=0 );
         _drawBtn(tar,1,0,spr_b_paction,false  ,ui_uibtn_action<=0 );
         _drawBtn(tar,2,0,spr_b_rclck  ,m_a_inv,false              );

         _drawBtn(tar,0,1,spr_b_attack ,false  ,ui_uibtn_move<=0   );
         _drawBtn(tar,1,1,spr_b_stop   ,false  ,ui_uibtn_move<=0   );
         _drawBtn(tar,2,1,spr_b_apatrol,false  ,ui_uibtn_move<=0   );

         _drawBtn(tar,0,2,spr_b_move   ,false  ,ui_uibtn_move<=0   );
         _drawBtn(tar,1,2,spr_b_hold   ,false  ,ui_uibtn_move<=0   );
         _drawBtn(tar,2,2,spr_b_patrol ,false  ,ui_uibtn_move<=0   );

         _drawBtn(tar,0,3,spr_b_cancel ,false  ,false              );
         _drawBtn(tar,1,3,spr_b_selall ,false  ,ui_orders_n[MaxUnitOrders]  <=0);
         _drawBtn(tar,2,3,spr_b_delete ,false  ,(ucl_cs[false]+ucl_cs[true])<=0);
      end;

      end;
   end;
end;

procedure d_MapMouse(tar:pSDL_Surface;lx,ly:integer);
var sx,sy:integer;
begin
   if(rpls_state<rpl_rhead)then
   begin
      D_BuildUI(tar,lx,ly);

      with _players[HPlayer] do
       for sx:=0 to 255 do
        if(uid_s[sx]>0)then
         with _uids[sx] do
          case _ability of
uab_uac_rstrike: if(upgr[upgr_uac_rstrike]>0)then circleColor(tar,mouse_x,mouse_y,blizz_r,c_gray);
          end;

      if(ui_mc_a>0)then //click effect
      begin
         sx:=ui_mc_a;
         sy:=sx shr 1;
         ellipseColor(tar,ui_mc_x-vid_cam_x,ui_mc_y-vid_cam_y,sx,sy,ui_mc_c);

         ui_mc_a-=1;
      end;
   end;
end;

procedure d_PanelUI(tar:pSDL_Surface;lx,ly:integer);
begin
   d_MapMouse(tar,lx,ly);

   if(vid_rtui=2)then
   begin
      d_MiniMap(r_panel  );
      d_Panel  (r_uipanel);
   end;
end;

procedure d_Hints(tar:pSDL_Surface);
const rpl_btns_border = 12;
var i,
   uid:byte;
    hs:pshortstring;
begin
   //str_hint_a
   if(0<=m_bx)and(m_bx<3)and(3<=m_by)and(m_by<=16)then
   begin
      hs:=nil;
      case m_by of
      3  : case (vid_ppos<2) of
           true :if(mouse_y>vid_panelw)then hs:=@str_hint_t[(mouse_x-vid_panelx) div vid_tBW];
           false:if(mouse_x>vid_panelw)then hs:=@str_hint_t[(mouse_y-vid_panely) div vid_tBW];
           end;
      12 : begin
              if(m_bx=2)then
               if(net_status=ns_none)then exit;
              hs:=@str_hint_m[m_bx];
           end;
      else
        i:=((m_by-4)*3)+(m_bx mod 3);

        with _players[HPlayer] do
        if(i<ui_ubtns)then
        begin
           if(ui_tab=3)then
           begin
              if(rpls_state>=rpl_rhead)then
              begin
                 if(i<rpl_btns_border)then exit;
              end
              else
                 if(i>=rpl_btns_border)then exit;
              hs:=@str_hint[ui_tab,race,i];
           end
           else
           begin
              uid:=ui_panel_uids[race,ui_tab,i];
              if(uid>0)then
              case ui_tab of
              0,1: begin
                      if(uid_e[uid]=0)then
                      begin
                         if (a_units[uid]<=0)then exit;
                         if((g_addon=false)and(_uids[uid]._addon))then exit;
                      end;
                      hs:=@_uids[uid].un_txt_hint;
                   end;
              2  : begin
                      if (a_upgrs[uid]<=0)then exit;
                      if((g_addon=false)and(_upids[uid]._up_addon))then exit;
                      hs:=@_upids[uid]._up_hint;
                   end;
              end;
           end;
        end;
      end;
      if(hs=nil)then exit;
      _draw_text(tar,ui_textx,ui_hinty,hs^,ta_left,255,c_white);
   end;
end;

procedure D_UIText(tar:pSDL_Surface);
var i:integer;
  str:shortstring;
  col:cardinal;
begin
   // LOG and HINTs
   if(net_chat_shlm>0)then net_chat_shlm-=1;

   if(ingame_chat)or(rpls_showlog)then
   begin
      ReMakeLogForDraw(HPlayer,ui_ingamecl,ui_game_log_height,lmts_menu_chat);
      if(ui_log_n>0)then
       for i:=0 to ui_log_n-1 do
        if(ui_log_c[i]>0)then _draw_text(tar,ui_textx,ui_logy-font_3hw*i,ui_log_s[i],ta_left,255,ui_log_c[i]);
      if(rpls_showlog=false)then _draw_text(tar,ui_textx,ui_chaty,':'+net_chat_str+chat_type[vid_rtui>6],ta_left,ui_ingamecl,c_white);
   end
   else
     if(net_chat_shlm>0)then
     begin
        ReMakeLogForDraw(HPlayer,ui_ingamecl,(net_chat_shlm div chat_shlm_t)+1,lmts_last_messages);
        if(ui_log_n>0)then
         for i:=0 to ui_log_n-1 do
          if(ui_log_c[i]>0)then _draw_text(tar,ui_textx,ui_logy-font_3hw*i,ui_log_s[i],ta_left,255,ui_log_c[i]);
     end;
   d_Hints(tar);


   // resources
   with _players[HPlayer] do
   begin
      _draw_text(tar,ui_energx,ui_energy,#19+str_hint_energy+#25+i2s(cenerg          )+' / '+#19+i2s(menerg),ta_left,255,c_white);
      _draw_text(tar,ui_armyx ,ui_armyy ,#16+str_hint_army  +#25+i2s(armylimit+uprodl)+' / '+#16+'125'      ,ta_left,255,ui_limit[armylimit>=MaxPlayerLimit]);
   end;

   // VICTORY/DEFEAT/PAUSE/REPLAY END
   if(GameGetStatus(@str,@col))then _draw_text(tar,ui_uiuphx,ui_uiuphy,str,ta_middle,255,col);

   // TIMER
   D_Timer(tar,ui_textx,ui_texty,g_step,ta_left,str_time);

   // INVASION
   if(g_mode=gm_inv)then
   begin
      D_Timer(tar,ui_textx,ui_texty+font_3hw,g_inv_time,ta_left,str_inv_time+b2s(g_inv_wave_n)+', '+str_time);
      if(_players[0].army>0)then _draw_text(tar,ui_textx,ui_texty+font_6hw,str_inv_ml+' '+b2s(_players[0].army),ta_left,255,c_white);
   end;

   d_OrderIcons(tar);
end;

procedure d_UIMouse(tar:pSDL_Surface);   //cursor/brash
var c:cardinal;
begin
   c:=0;
   case m_brush of
co_move,
co_patrol  : c:=c_lime;
co_amove,
co_apatrol : c:=c_red;
co_paction : c:=c_aqua;
   else _draw_surf(tar,mouse_x,mouse_y,spr_cursor);
   end;
   if(c<>0)then
   begin
      circleColor(tar,mouse_x   ,mouse_y,10,           c);
      hlineColor (tar,mouse_x-12,mouse_x+12,mouse_y   ,c);
      vlineColor (tar,mouse_x   ,mouse_y-12,mouse_y+12,c);
   end;
end;

procedure d_ui(tar:pSDL_Surface;lx,ly:integer);
begin
   d_PanelUI(tar,lx,ly);
   d_UIText(tar);
   if(mouse_select_x0>-1)then rectangleColor(tar,lx+mouse_select_x0-vid_cam_x, ly+mouse_select_y0-vid_cam_y, mouse_x, mouse_y, PlayerGetColor(HPlayer));
end;



