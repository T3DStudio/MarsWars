
procedure d_Alarms;
var i,r:byte;
begin
   for i:=0 to ui_max_alarms do
    with ui_alarms[i] do
     if(at>0)then
     begin
        r:=(at*2) mod vid_uialrm_ti;
        if(ab)
        then RectangleColor(r_minimap,ax-r,ay-r,ax+r,ay+r, c_white)
        else CircleColor   (r_minimap,ax  ,ay  ,        r, c_white);
        dec(at,1);
     end;

   case g_mode of
gm_ct:
      for i:=1 to MaxCPoints do
       with g_cpoints[i] do
        if(ct>0)and((G_Step mod 20)>10)
        then circleColor(r_minimap,mpx,mpy,map_prmm,c_gray     )
        else circleColor(r_minimap,mpx,mpy,map_prmm,p_color(pl));
gm_royl:
      circleColor(r_minimap,ui_hwp,ui_hwp,trunc(g_royal_r*map_mmcx)+1,ui_muc[(g_royal_r mod 2)=0]);
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
begin
   with _players[HPlayer]do
   case m_brush of
   1..255:
   begin
      dec(m_brushx,vid_vx-lx);
      dec(m_brushy,vid_vy-ly);

      with _uids[m_brush] do
      begin
         spr:=_uid2spr(m_brush,_advanced[g_addon]);
         SDL_SetAlpha(spr^.surf,SDL_SRCALPHA,128);
         _draw_surf(tar,m_brushx-spr^.hw,m_brushy-spr^.hh,spr^.surf);
         SDL_SetAlpha(spr^.surf,SDL_SRCALPHA or SDL_RLEACCEL,255);

         circleColor(tar,m_brushx,m_brushy,_r,m_brushc);
      end;

      inc(m_brushx,vid_vx-lx);
      inc(m_brushy,vid_vy-ly);

      {if(m_brush in [4,7,10])then
       circleColor(tar,m_vx,m_vy,towers_sr[upgr[upgr_towers]],c_gray); }

      // build areas
      while(ui_builders_n>0)do
      begin
         dec(ui_builders_n,1);
         circleColor(tar,
         lx+ui_builders_x[ui_builders_n]-vid_vx,
         ly+ui_builders_y[ui_builders_n]-vid_vy,
         ui_builders_r[ui_builders_n],c_white);
      end;

      // points areas
      if(g_mode=gm_ct)then
       for i:=1 to MaxCPoints do
        with g_cpoints[i] do
         circleColor(tar,
         lx+px-vid_vx,
         ly+py-vid_vy,
         base_r,c_blue);

      // map build rect
      rectangleColor(tar,
      lx+map_b0-vid_vx,ly+map_b0-vid_vy,
      lx+map_b1-vid_vx,ly+map_b1-vid_vy,
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
   for i:=1 to 9 do
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
            if(n>0)then inc(y,vid_oisw);
            x:=ui_oicox-vid_oips;
         end;
         with _players[HPlayer] do
          with _uids[c] do _draw_surf(tar,x,y,un_sbtn[_advanced[g_addon]].surf);

         dec(x,vid_oisw);
         inc(n,1);
      end;
      if(y0=-1)then y0:=y+4;
      _draw_text(tar,ui_oicox,y0   ,b2s(i)             ,ta_right,255,c_white);
      _draw_text(tar,ui_oicox,y0+10,i2s(ui_orders_n[i]),ta_right,255,c_gray );
      inc(y,vid_oihw);
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
var ux,uy,ui_dBW:integer;
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
   ui_dBW:=vid_BW-font_w-3;

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
   _draw_surf(tar,bx,by,btn);
   if(sel)then rectangleColor(tar,bx+1,by+1,bx+vid_tBW-3,by+vid_tBW-3,c_lime);

   if(i1>0)then _draw_text(tar,bx+3,by+2 ,i2s(i1),ta_left,255,c1);
   if(i2>0)then _draw_text(tar,bx+3,by+11,i2s(i2),ta_left,255,c2);
   if(i3>0)then _draw_text(tar,bx+3,by+22,i2s(i3),ta_left,255,c3);
end;

procedure d_Panel(tar:pSDL_Surface);
var ui,ux,uy,uid,rld:integer;
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
            uy:=ui_tabsy+1;
         end
         else
         begin
            ux:=ui_tabsy+1;
            uy:=ui*vid_tBW+1;
         end;

         case ui of
         0: d_tabbtn(tar,spr_tabs[ui],ux,uy, ucl_cs[true ],ui_uid_buildn,ucl_c [true ], c_lime ,c_yellow,c_orange, ui=ui_tab);
         1: d_tabbtn(tar,spr_tabs[ui],ux,uy, ucl_cs[false],uproda       ,ucl_c [false], c_lime ,c_yellow,c_orange, ui=ui_tab);
         2: begin if(pproda>0)then uid:=(ui_first_upgr_time div fr_fps)+1 else uid:=0;
            d_tabbtn(tar,spr_tabs[ui],ux,uy, uid          ,pproda  ,0            , c_white,c_yellow,0       , ui=ui_tab);
            end;
         3: d_tabbtn(tar,spr_tabs[ui],ux,uy, 0            ,0       ,0            , 0      ,0       ,0       , ui=ui_tab);
         end;
      end;

      d_TextBTN(tar,0,9,@str_menu,c_white);
      if(net_nstat>ns_none)and(G_WTeam=255)then
       if(g_paused>0)
       then d_TextBTN(tar,2,9,@str_pause,p_color(g_paused))
       else d_TextBTN(tar,2,9,@str_pause,c_white          );

      if(vid_ppos<2)then
      begin
         _draw_text(tar,ui_energx  ,ui_iy,#19+i2s(cenerg),ta_right,255,c_aqua );
         _draw_text(tar,ui_energx+2,ui_iy,i2s(menerg)    ,ta_left ,255,c_white);
      end
      else
      begin
         _draw_text(tar,ui_energx  ,ui_iy-6,#19+i2s(cenerg),ta_middle,255,c_aqua );
         _draw_text(tar,ui_energx+2,ui_iy+6,i2s(menerg)    ,ta_middle,255,c_white);
      end;
      _draw_text(tar,ui_armyx   ,ui_iy,b2s(army)           ,ta_middle,255,c_white);

      case ui_tab of    // buildings
      0:
      for ui:=0 to ui_ubtns do
      begin
         uid:=ui_panel_uids[race ,ui_tab,ui];
         if(uid=0)then continue;

         with _uids[uid] do
         begin
            if(uid_e[uid]=0)then
            begin
               if(a_units[uid]<=0)then continue;
               if((G_addon=false)and(_addon))then continue;
            end;

            ux:=(ui mod 3);
            uy:=(ui div 3);

            req:=_uid_cndt(@_players[HPlayer],uid);

            _drawBtn (tar,ux,uy,un_btn[_advanced[g_addon]].surf,m_brush=uid,(req>0) or not(uid in ui_prod_builds));
            _drawBtnt(tar,ux,uy,
            b2s(ui_uid_builds[uid]),'',b2s(uid_s[uid]),b2s   (uid_e[uid])      ,r2s(ui_uid_reload[uid]),
            c_dyellow              ,0 ,c_lime         ,ui_muc[uid_e[uid]>=_max],c_aqua  ,r2s(build_cd));
         end;
      end;


      1:      // units
      for ui:=0 to ui_ubtns do
      begin
         uid:=ui_panel_uids[race ,ui_tab,ui];
         if(uid=0)then continue;
         with _uids[uid] do
         begin
            if(uid_e[uid]=0)then
            begin
               if(a_units[uid]<=0)then continue;
               if((G_addon=false)and(_addon))then continue;
            end;

            ux:=(ui mod 3);
            uy:=(ui div 3);

            _drawBtn (tar,ux,uy,un_btn[_advanced[g_addon]].surf,false,(_uid_cndt(@_players[HPlayer],uid)>0) or (uproda>=uprodm) or (uprodu[uid]>=ui_prod_units[uid]));
            _drawBtnt(tar,ux,uy,
            b2s(((ui_units_ptime[uid]+fr_ifps) div fr_fps)),b2s(uprodc[uid]),b2s(uid_s[uid]),b2s(   uid_e[uid])      ,b2s(ui_units_inapc[uid]),
            c_white                                        ,c_dyellow       ,c_lime         ,ui_muc[uid_e[uid]>=_max],c_purple                ,'');
         end;
      end;

      2:
      for ui:=0 to ui_ubtns do
      begin
         uid:=ui_panel_uids[race ,ui_tab,ui];

         if (a_upgrs[uid]<=0)then continue;
         if((G_addon=false)and(_upids[uid]._up_addon))then continue;

         ux:=(ui mod 3);
         uy:=(ui div 3);

         _drawBtn(tar,ux,uy,_upids[uid]._up_btn.surf,ui_upgr[uid]>0, (_upid_cndt(@_players[HPlayer],uid)>0) or (pproda>=pprodm)or(n_smiths<=0));

         _drawBtnt(tar,ux,uy,
         b2s(((ui_upgr[uid]+fr_ifps) div fr_fps)),b2s(ui_upgrct[uid]),'',b2s(   upgr[uid])                      ,'',
         c_white                                 ,c_dyellow          ,0 ,ui_muc[upgr[uid]>=_upids[uid]._up_max] ,0 ,'');
      end;

      3:
      if(_rpls_rst>=rpl_rhead)then
      begin
         _drawBtn(tar,0,4,spr_b_rfast,_fsttime  ,false);
         _drawBtn(tar,1,4,spr_b_rskip,false     ,false);
         _drawBtn(tar,2,4,spr_b_rstop,g_paused>0,false);
         _drawBtn(tar,0,5,spr_b_rvis ,_rpls_vidm,false);
         _drawBtn(tar,1,5,spr_b_rlog ,_rpls_log ,false);
         _drawBtn(tar,2,5,spr_b_rfog ,_fog      ,false);

         ux:=2;
         uy:=6;

         for ui:=0 to MaxPlayers do
         begin
            if(ui=0)
            then _drawBtnt(tar,ux,uy,str_all          ,'','','','',c_white    ,0,0,0,0,'')
            else _drawBtnt(tar,ux,uy,_players[ui].name,'','','','',p_color(ui),0,0,0,0,'');
            _drawBtn(tar,ux,uy,r_empty,ui=HPlayer,_players[ui].army=0);

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
         _drawBtn(tar,0,0,spr_b_move   ,false  ,ui_uibtn_move=0   );
         _drawBtn(tar,1,0,spr_b_hold   ,false  ,ui_uibtn_move=0   );
         _drawBtn(tar,2,0,spr_b_patrol ,false  ,ui_uibtn_move=0   );

         _drawBtn(tar,0,1,spr_b_attack ,false  ,ui_uibtn_move=0   );
         _drawBtn(tar,1,1,spr_b_stop   ,false  ,ui_uibtn_move=0   );
         _drawBtn(tar,2,1,spr_b_apatrol,false  ,ui_uibtn_move=0   );

         _drawBtn(tar,0,2,spr_b_action ,false  ,ui_uibtn_action=0 );
         _drawBtn(tar,1,2,spr_b_rclck  ,m_a_inv,false             );
         _drawBtn(tar,2,2,spr_b_cancel ,false  ,false             );

         _drawBtn(tar,0,3,spr_b_paction,false  ,ui_uibtn_action=0 );
         _drawBtn(tar,1,3,spr_b_selall ,false  ,ui_uibtn_f2=0);
         _drawBtn(tar,2,3,spr_b_delete ,false  ,(ucl_cs[false]+ucl_cs[true])=0);
      end;

      end;
   end;
end;

procedure d_MapMouse(tar:pSDL_Surface;lx,ly:integer);
var sx,sy:integer;
begin
   if(_rpls_rst<rpl_rhead)then
   begin
      D_BuildUI(tar,lx,ly);

      with _players[HPlayer] do
       for sx:=0 to 255 do
        if(uid_s[sx]>0)then
         with _uids[sx] do
         case _ability of
uab_uac_rstrike: if(upgr[upgr_uac_rstrike]>0)then circleColor(tar,m_vx,m_vy,blizz_r,c_gray);
         end;

      if(ui_mc_a>0)then //click effect
      begin
         sx:=ui_mc_a;
         sy:=sx shr 1;
         ellipseColor(tar,ui_mc_x-vid_vx,ui_mc_y-vid_vy,sx,sy,ui_mc_c);

         dec(ui_mc_a,1);
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
var i,
   uid:byte;
    hs:pshortstring;
begin
   if(0<=m_bx)and(m_bx<3)and(3<=m_by)and(m_by<=16)then
   begin
      hs:=nil;
      case m_by of
      3  : case (vid_ppos<2) of
           true :if(m_vy>ui_tabsy)
                 then hs:=@str_hint_t[(m_vx-vid_panelx) div vid_tBW ]
                 else hs:=@str_hint_a[(m_vx-vid_panelx) div vid_2tBW];
           false:if(m_vx>ui_tabsy)
                 then hs:=@str_hint_t[(m_vy-vid_panely) div vid_tBW ]
                 else ;
           end;
      13 : begin
              if(m_bx=2)then
               if(net_nstat=ns_none)or(G_WTeam<255)then exit;
              hs:=@str_hint_m[m_bx];
           end;
      15 : if(vid_ppos>=2)and(m_bx=0)then hs:=@str_hint_a[0];
      16 : if(vid_ppos>=2)and(m_bx=0)then hs:=@str_hint_a[1];
      else
        i:=((m_by-4)*3)+(m_bx mod 3);

        with _players[HPlayer] do
        if(i<ui_ubtns)then
        begin
           if(ui_tab=3)then
           begin
              if(_rpls_rst>=rpl_rhead)then
              begin
                 if(i<12)then exit;
              end
              else
                 if(i>11)then exit;
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
                         if(a_units[uid]<=0)then exit;
                         if((g_addon=false)and(_uids[uid]._addon))then exit;
                      end;
                      hs:=@_uids[uid].un_hint;
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
var i:byte;
begin
   // CHAT
   if(_igchat)or(_rpls_log)then
   begin
      for i:=0 to MaxNetChat do _draw_text(tar,ui_textx,ui_chaty-13*i,net_chat[HPlayer,i]                   ,ta_left,255        ,c_white);
      if(_rpls_log=false)then   _draw_text(tar,ui_textx,ui_hinty     ,':'+net_chat_str+chat_type[vid_rtui>6],ta_left,ui_ingamecl,c_white);
   end
   else
     if(net_chat_shlm>0)then
     begin
        _draw_text(tar,ui_textx,ui_chaty,net_chat[HPlayer,0],ta_left,255,c_white);
        dec(net_chat_shlm,1);
     end
     else d_Hints(tar);

   // VICTORY/DEFEAT PAUSE REPLAY END
   if(_rpls_rst=rpl_end)
   then _draw_text(tar,ui_uiuphx,ui_texty,str_repend,ta_middle,255,c_white)
   else
    if(_rpls_rst<rpl_rhead)then
     with _players[HPlayer] do
     begin
        if(G_WTeam=255)then
        begin
           if(menu_s2<>ms2_camp)then
            if(_players[HPlayer].army=0)then _draw_text(tar,ui_uiuphx,ui_texty,str_lose  ,ta_middle,255,c_red);
           if(G_paused>0)then
            if(net_nstat=ns_clnt)and(net_cl_svttl=ClientTTL)
            then _draw_text(tar,ui_uiuphx,ui_texty+12,str_waitsv,ta_middle,255,p_color(net_cl_svpl))
            else _draw_text(tar,ui_uiuphx,ui_texty+12,str_pause ,ta_middle,255,p_color(G_paused   ));
        end
        else
        begin
           if(G_WTeam=team)
           then _draw_text(tar,ui_uiuphx,ui_texty,str_win   ,ta_middle,255,c_lime)
           else _draw_text(tar,ui_uiuphx,ui_texty,str_lose  ,ta_middle,255,c_red);
        end;
     end;

   // TIMER
   d_Timer(tar,ui_textx,ui_texty,g_step,ta_left,str_time);

   // INVASION
   if(G_WTeam=255)then
    if(g_mode=gm_inv)then
    begin
       D_Timer(tar,ui_textx,ui_texty+14,g_inv_time,ta_left,str_inv_time+b2s(g_inv_wave_n)+', '+str_time);
       if(_players[0].army>0)then _draw_text(tar,ui_textx,ui_texty+26,str_inv_ml+' '+b2s(_players[0].army),ta_left,255,c_white);
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
   else _draw_surf(tar,m_vx,m_vy,spr_cursor);
   end;
   if(c<>0)then
   begin
      circleColor(tar,m_vx   ,m_vy,10,        c);
      hlineColor (tar,m_vx-12,m_vx+12,m_vy   ,c);
      vlineColor (tar,m_vx   ,m_vy-12,m_vy+12,c);
   end;
end;

procedure d_ui(tar:pSDL_Surface;lx,ly:integer);
begin
   d_PanelUI(tar,lx,ly);
   d_UIText(tar);
   if(m_sxs>-1)then rectangleColor(tar,lx+m_sxs-vid_vx, ly+m_sys-vid_vy, m_vx, m_vy, p_color(HPlayer));
end;



