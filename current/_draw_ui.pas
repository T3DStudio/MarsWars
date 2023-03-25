
function it2s(r:integer):integer;
begin
   if(r>0)
   then it2s:=(r+fr_ifps) div fr_fps1
   else it2s:=0;
end;
function ct2s(r:cardinal):cardinal;
begin
   if(r>0)
   then ct2s:=(r+fr_ifps) div fr_fps1
   else ct2s:=0;
end;
function ir2s(r:integer):shortstring;
begin
   if(r<=0)
   then ir2s:=''
   else ir2s:=i2s(it2s(r))
end;
function cr2s(r:cardinal):shortstring;
begin
   if(r<=0)
   then cr2s:=''
   else cr2s:=c2s(ct2s(r))
end;


procedure d_MinimapAlarms;
var i,r:byte;
begin
   for i:=0 to ui_max_alarms do
    with ui_alarms[i] do
     if(al_t>0)then
     begin
        //r:=(al_t*2) mod vid_uialrm_t;
        r:=(g_step+cardinal(i+al_t)) mod ui_alarm_time;

        case al_v of
aummat_attacked_b,
aummat_created_b,
aummat_upgrade    : RectangleColor(r_minimap,al_mx-r,al_my-r,al_mx+r,al_my+r, al_c);
aummat_advance,
aummat_attacked_u,
aummat_created_u,
aummat_info       : CircleColor   (r_minimap,al_mx  ,al_my  ,              r, al_c);
        end;

        al_t-=2;
     end;

   for i:=1 to MaxCPoints do
    with g_cpoints[i] do
     if(cpCapturer>0)then
      if(cpenergy>0)
      then map_minimap_cpoint(r_minimap,cpmx,cpmy,cpmr,char_gen,GetCPColor(i))
      else map_minimap_cpoint(r_minimap,cpmx,cpmy,cpmr,char_cp ,GetCPColor(i));

   case g_mode of
gm_royale   : circleColor(r_minimap,ui_hwp,ui_hwp,trunc(g_royal_r*map_mmcx)+1,ui_max_color[(g_royal_r mod 2)=0]);
   end;
end;

procedure d_Minimap(tar:pSDL_Surface);
var i:byte;
begin
   rectangleColor(r_minimap,vid_mmvx,vid_mmvy,vid_mmvx+map_mmvw,vid_mmvy+map_mmvh, c_white);

   d_MinimapAlarms;

   // debug
   if(_testmode>0)then
    with _players[UIPlayer] do
     for i:=0 to MaxPlayers do
      with ai_alarms[i] do
       if(aia_enemy_limit>0)then
        circleColor(r_minimap,round(aia_x*map_mmcx),round(aia_y*map_mmcx),5,c_orange);

   _draw_surf(tar      ,1,1,r_minimap );
   _draw_surf(r_minimap,0,0,r_bminimap);

   r_minimap_scan_blink:=not r_minimap_scan_blink;
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
         spr:=_uid2spr(m_brush,270,0);
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
         _unit_apUID(pdunit);
         _unit_upgr (pdunit);
         if(UIUnitDrawRange(pdunit))
         then circleColor(tar,m_brushx,m_brushy,dunit.srange,r_blink2_color_BG);
      end;

      m_brushx+=vid_cam_x-lx;
      m_brushy+=vid_cam_y-ly;

      // points areas
      for i:=1 to MaxCPoints do
       with g_cpoints[i] do
        if(cpCapturer>0)and(cpnobuildr>0)then
         circleColor(tar,
         lx+cpx-vid_cam_x,
         ly+cpy-vid_cam_y,
         cpnobuildr,c_blue);

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
   y:=ui_texty+vid_oihw;
   _draw_text(tar,ui_oicox-4,y+2,str_orders,ta_right,255,c_white);
   y+=vid_oiw;
   if(MaxUnitGroups>1)then
   for i:=1 to MaxUnitGroups-1 do
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
         with _uids[c] do _draw_surf(tar,x,y,un_sbtn.surf);

         x-=vid_oisw;
         n+=1;
      end;
      if(y0=-1)then y0:=y+4;
      if(ui_orders_n[i]>0)then
      begin
      _draw_text(tar,ui_oicox,y0   ,b2s(i)             ,ta_right,255,c_white );
      _draw_text(tar,ui_oicox,y0+10,i2s(ui_orders_n[i]),ta_right,255,c_orange);
      end;
      y+=vid_oihw;
   end;
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
i1,i2,i3,i4:integer;
c1,c2,c3,c4:cardinal;
sel:boolean);
begin
   if(vid_ppos<2)then
   begin
      _draw_surf(tar,bx,by+5,btn);
      if(sel)then rectangleColor(tar,bx+1,by+1,bx+vid_tBW-3,by+vid_BW-3,c_lime);
by+=3;if(i1>0)then _draw_text(tar,bx+3,by,i2s(i1),ta_left,255,c1);by+=font_w+3;
      if(i2>0)then _draw_text(tar,bx+3,by,i2s(i2),ta_left,255,c2);by+=font_w+3;
      if(i3>0)then _draw_text(tar,bx+3,by,i2s(i3),ta_left,255,c3);by+=font_w+3;
      if(i4>0)then _draw_text(tar,bx+3,by,i2s(i4),ta_left,255,c4);
   end
   else
   begin
      _draw_surf(tar,bx+5,by,btn);
      if(sel)then rectangleColor(tar,bx+1,by+1,bx+vid_BW-3,by+vid_tBW-3,c_lime);
by+=3;if(i1>0)then _draw_text(tar,bx+3,by         ,i2s(i1),ta_left,255,c1);
      if(i2>0)then _draw_text(tar,bx+3,by+font_w+3,i2s(i2),ta_left,255,c2);

      if(i3>0)then _draw_text(tar,bx+vid_BW-3,by         ,i2s(i3),ta_right,255,c3);
      if(i4>0)then _draw_text(tar,bx+vid_BW-3,by+font_w+3,i2s(i4),ta_right,255,c4);
   end;
end;

procedure d_Panel(tar:pSDL_Surface;VisPlayer:byte);
var ucl,ux,uy,uid:integer;
              req:cardinal;
PVisPlayer:PTPlayer;
procedure PlayersButtoms;
var p:byte;
begin
   for p:=0 to MaxPlayers do
   begin
      if(p=0)
      then _drawBtnt(tar,ux,uy,str_all         ,'','','','',c_white          ,0,0,0,0,'')
      else _drawBtnt(tar,ux,uy,_players[p].name,'','','','',PlayerGetColor(p),0,0,0,0,'');
      _drawBtn(tar,ux,uy,r_empty,p=VisPlayer,_players[p].army=0);

      ux+=1;
      if(ux>2)then
      begin
         ux:=0;
         uy+=1;
      end;
   end;
end;
begin
   PVisPlayer:=@_players[VisPlayer];
   with PVisPlayer^ do
   begin
      _draw_surf(tar,0,0,r_panel);

      for ucl:=0 to 3 do
      begin
         if(vid_ppos<2)then
         begin
            ux:=ucl*vid_tBW+1;
            uy:=vid_panelw+1;
         end
         else
         begin
            ux:=vid_panelw+1;
            uy:=ucl*vid_tBW+1;
         end;

         case ucl of
         0: d_tabbtn(tar,spr_tabs[ucl],ux,uy, ui_bprod_first      ,ui_bprod_all,ucl_cs[true ],ucl_c[true ],c_white,c_yellow,c_lime,c_orange, ucl=ui_tab);
         1: d_tabbtn(tar,spr_tabs[ucl],ux,uy, it2s(ui_uprod_first),uproda      ,ucl_cs[false],ucl_c[false],c_white,c_yellow,c_lime,c_orange, ucl=ui_tab);
         2: d_tabbtn(tar,spr_tabs[ucl],ux,uy, it2s(ui_pprod_first),upproda     ,0            ,0           ,c_white,c_yellow,0     ,0       , ucl=ui_tab);
         3: d_tabbtn(tar,spr_tabs[ucl],ux,uy, 0                   ,0           ,0            ,0           ,0      ,0       ,0     ,0       , ucl=ui_tab);
         end;
      end;

      d_TextBTN(tar,0,ui_menu_btnsy-4,@str_menu,c_white);
      if(net_status>ns_none)then
       if(0<g_status)and(g_status<=MaxPlayers)
       then d_TextBTN(tar,2,ui_menu_btnsy-4,@str_pause,PlayerGetColor(g_status))
       else d_TextBTN(tar,2,ui_menu_btnsy-4,@str_pause,c_white                 );

      if(1<ks_ctrl)and(ks_ctrl<10)then writeln(upproda,' ',upprodm);

      case ui_tab of
      0: // buildings
      for ucl:=0 to ui_ubtns do
      begin
         uid:=ui_panel_uids[race ,ui_tab,ucl];//_ReplaceUid(ui_panel_uids[race ,ui_tab,ucl],PVisPlayer);
         if(uid=0)then continue;

         with _uids[uid] do
         begin
            if(uid_e[uid]<=0)then
            begin
               if(a_units[uid]<=0)then continue;
            end;

            ux:=(ucl mod 3);
            uy:=(ucl div 3);

            req:=_uid_conditionals(PVisPlayer,uid);

            // _bornadvanced[g_addon]
            _drawBtn (tar,ux,uy,un_btn.surf,m_brush=uid,(req>0) or not(uid in ui_bprod_possible));
            _drawBtnt(tar,ux,uy,

            i2s(ui_bprod_ucl_time[_ucl]),i2s(ui_bprod_ucl_count[ucl]),i2s(ucl_s[true,ucl]),i2s(ucl_e[true,ucl])                       ,ir2s(ui_ucl_reload[ucl]),
            ui_cenergy[cenergy<0]       ,c_dyellow                   ,c_lime              ,ui_max_color[ucl_e[true,ucl]>=a_units[uid]],c_aqua                 ,ir2s(build_cd));

            ui_uid_reload[uid]:=-1;
            ui_ucl_reload[ucl]:=-1;
         end;
      end;

      1: // units
      for ucl:=0 to ui_ubtns do
      begin
         uid:=ui_panel_uids[race ,ui_tab,ucl];//_ReplaceUid(ui_panel_uids[race ,ui_tab,ucl],PVisPlayer);
         if(uid=0)then continue;

         with _uids[uid] do
         begin
            if(uid_e[uid]<=0)then
            begin
               if(a_units[uid]<=0)then continue;
            end;

            ux:=(ucl mod 3);
            uy:=(ucl div 3);

            //(uprodu[uid]>=ui_uprod_uid_max[uid])
            req:=_uid_conditionals(PVisPlayer,uid);

            _drawBtn (tar,ux,uy,un_btn.surf,false,(req>0) or (uproda>=uprodm) or (ui_uprod_cur>=ui_uprod_max) or(ui_uprod_uid_max[uid]<=0));
            _drawBtnt(tar,ux,uy,
            ir2s(ui_uprod_uid_time[uid]),i2s(uprodu[uid]),i2s(uid_s[uid]),i2s(   uid_e[uid])                    ,i2s(ui_units_inapc[uid]),
            ui_cenergy[cenergy<0]      ,c_dyellow       ,c_lime         ,ui_max_color[uid_e[uid]>=a_units[uid]],c_purple                ,'');
         end;
      end;


      2: // upgrades
      for ucl:=0 to ui_ubtns do
      begin
         uid:=ui_panel_uids[race ,ui_tab,ucl];

         if (a_upgrs[uid]<=0)then continue;

         ux:=(ucl mod 3);
         uy:=(ucl div 3);

         _drawBtn(tar,ux,uy,_upids[uid]._up_btn.surf,ui_pprod_time[uid]>0,
         (_upid_conditionals(PVisPlayer,uid)>0)or(upproda>=upprodm) or (upprodu[uid]>=ui_pprod_max[uid]) );

         _drawBtnt(tar,ux,uy,
         ir2s(ui_pprod_time[uid]),i2s(upprodu[uid]),'',b2s(   upgr[uid])                            ,'',
         ui_cenergy[cenergy<0]  ,c_dyellow         ,0 ,ui_max_color[upgr[uid]>=_upids[uid]._up_max] ,0 ,'');
      end;

      3: // actions
      if(rpls_state>=rpl_rhead)then
      begin
         _drawBtn(tar,0,0,spr_b_rfast,_fsttime    ,false);
         _drawBtn(tar,1,0,spr_b_rskip,false       ,false);
         _drawBtn(tar,2,0,spr_b_rstop,g_status>0  ,false);
         _drawBtn(tar,0,1,spr_b_rvis ,rpls_plcam  ,false);
         _drawBtn(tar,1,1,spr_b_rlog ,rpls_showlog,false);
         _drawBtn(tar,2,1,spr_b_rfog ,rpls_fog    ,false);

         ux:=2;
         uy:=2;
         PlayersButtoms;
      end
      else
        if(_players[HPlayer].observer)then
        begin
           _drawBtn(tar,0,0,spr_b_rfog ,rpls_fog    ,false);

           ux:=2;
           uy:=0;
           PlayersButtoms;
        end
        else
        begin
           _drawBtn(tar,0,0,spr_b_action ,false   ,ui_uibtn_action <=0);
           _drawBtn(tar,1,0,spr_b_paction,false   ,ui_uibtn_action <=0);
           _drawBtn(tar,2,0,spr_b_rebuild,false   ,ui_uibtn_rebuild<=0);

           _drawBtn(tar,0,1,spr_b_attack ,false   ,ui_uibtn_move<=0   );
           _drawBtn(tar,1,1,spr_b_stop   ,false   ,ui_uibtn_move<=0   );
           _drawBtn(tar,2,1,spr_b_apatrol,false   ,ui_uibtn_move<=0   );

           _drawBtn(tar,0,2,spr_b_move   ,false   ,ui_uibtn_move<=0   );
           _drawBtn(tar,1,2,spr_b_hold   ,false   ,ui_uibtn_move<=0   );
           _drawBtn(tar,2,2,spr_b_patrol ,false   ,ui_uibtn_move<=0   );

           _drawBtn(tar,0,3,spr_b_cancel ,false   ,false              );
           _drawBtn(tar,1,3,spr_b_selall ,false   ,ui_orders_n[MaxUnitGroups]  <=0);
           _drawBtn(tar,2,3,spr_b_delete ,false   ,(ucl_cs[false]+ucl_cs[true])<=0);

           _drawBtn(tar,0,4,spr_b_mmark  ,false   ,false              );
           _drawBtn(tar,1,4,spr_b_rclck  ,m_action,false              );
        end;

      end;
   end;
end;

procedure d_MapMouse(tar:pSDL_Surface;lx,ly:integer);
var sx,sy,i,r:integer;
begin
   if(rpls_state<rpl_rhead)then
   begin
      D_BuildUI(tar,lx,ly);

      if(m_brush=co_paction)then
       with _players[HPlayer] do
        for sx:=0 to 255 do
         if(uid_s[sx]>0)and(uid_x[sx]>0)then
          with _uids[sx] do
           case _ability of
uab_UACStrike: if(upgr[upgr_uac_rstrike]>0)then circleColor(tar,mouse_x,mouse_y,blizzard_sr,c_gray);
uab_UACScan  : circleColor(tar,mouse_x,mouse_y,_units[uid_x[sx]].srange,c_gray);
           end;

      if(ui_mc_a>0)then //click effect
      begin
         sx:=ui_mc_a;
         sy:=sx shr 1;
         ellipseColor(tar,ui_mc_x-vid_cam_x,ui_mc_y-vid_cam_y,sx,sy,ui_mc_c);

         ui_mc_a-=1;
      end;

      for i:=0 to ui_max_alarms do
       with ui_alarms[i] do
        if(al_t>0)then
        begin
           case al_v of
aummat_info     : ;
           else continue;
           end;

           sx:=al_x-vid_cam_x+lx;
           sy:=al_y-vid_cam_y+ly;

           r:=(32-(g_step mod 32))*4;

           circleColor(tar,sx,sy,r,c_white);
        end;
   end;
end;

procedure d_PanelUI(tar:pSDL_Surface;lx,ly:integer);
begin
   d_MapMouse(tar,lx,ly);

   if(vid_blink_timer1=2)then
   begin
      d_MiniMap(r_panel  );
      d_Panel  (r_uipanel,UIPlayer);
   end;
end;

procedure d_Hints(tar:pSDL_Surface;pl:byte);
var i,
   uid :byte;
     s1:shortstring;
    hs1,
    hs2,
    hs3:pshortstring;
    tu :PTUnit;
begin
   //str_hint_a
   if(0<=m_bx)and(m_bx<3)and(3<=m_by)and(m_by<=16)then
   begin
      hs1:=nil;
      hs2:=nil;
      hs3:=nil;
      if(m_by=ui_menu_btnsy)then
      begin
         if(m_bx=2)then
          if(net_status=ns_none)then exit;
         hs1:=@str_hint_m[m_bx];
      end
      else
      case m_by of
      3  : case (vid_ppos<2) of
           true :if(mouse_y>vid_panelw)then hs1:=@str_hint_t[(mouse_x-vid_panelx) div vid_tBW];
           false:if(mouse_x>vid_panelw)then hs1:=@str_hint_t[(mouse_y-vid_panely) div vid_tBW];
           end;
      else
        i:=((m_by-4)*3)+(m_bx mod 3);

        with _players[pl] do
        if(i<=ui_ubtns)then
        begin
           if(ui_tab=3)then
           begin
              if(i<=_mhkeys)then
                if(rpls_state>=rpl_rhead)
                then hs1:=@str_hint_r[i]
                else
                  if(_players[HPlayer].observer)
                  then hs1:=@str_hint_o[i]
                  else hs1:=@str_hint_a[i];
           end
           else
           begin
              uid:=ui_panel_uids[race,ui_tab,i];
              if(uid>0)then
              case ui_tab of
              0,1: begin
                      if(uid_e[uid]=0)and(a_units[uid]<=0)then exit;
                      hs1:=@_uids[uid].un_txt_uihint1;
                      hs2:=@_uids[uid].un_txt_uihint2;
                      hs3:=@_uids[uid].un_txt_uihint3;
                   end;
              2  : begin
                      if(a_upgrs[uid]<=0)then exit;
                      s1:=_makeUpgrBaseHint(uid,upgr[uid]+1);
                      hs1:=@s1;
                      hs3:=@_upids[uid]._up_hint;
                   end;
              end;
           end;
        end;
      end;
      if(hs1<>nil)then _draw_text(tar,ui_textx,ui_hinty1,hs1^,ta_left,ui_ingamecl,c_white);
      if(hs2<>nil)then _draw_text(tar,ui_textx,ui_hinty2,hs2^,ta_left,ui_ingamecl,c_white);
      if(hs3<>nil)then _draw_text(tar,ui_textx,ui_hinty3,hs3^,ta_left,ui_ingamecl,c_white);
   end
   else
     if(_IsUnitRange(ui_uhint,@tu))then
     begin
        _draw_text(tar,ui_textx,ui_hinty1,tu^.uid^.un_txt_uihintS ,ta_left,ui_ingamecl,c_white);
        _draw_text(tar,ui_textx,ui_hinty3,tc_white+'('+tc_default+tu^.player^.name+tc_white+')',ta_left,ui_ingamecl,PlayerGetColor(tu^.player^.pnum));
     end;
end;

procedure D_UIText(tar:pSDL_Surface;VisPlayer:byte);
var i,limit:integer;
  str:shortstring;
  col:cardinal;
function ChatString:shortstring;
begin
   case ingame_chat of
chat_all     : ChatString:=str_chat_all;
chat_allies  : ChatString:=str_chat_allies;
1..MaxPlayers: ChatString:=_players[ingame_chat].name+':';
   end;
end;
begin
   // LOG and HINTs
   if(net_chat_shlm>0)then net_chat_shlm-=1;

   if(ingame_chat>0)or(rpls_showlog)then
   begin
      MakeLogListForDraw(HPlayer,ui_ingamecl,ui_game_log_height,lmts_menu_chat);
      if(ui_log_n>0)then
       for i:=0 to ui_log_n-1 do
        if(ui_log_c[i]>0)then _draw_text(tar,ui_textx,ui_logy-font_3hw*i,ui_log_s[i],ta_left,255,ui_log_c[i]);
      if(ingame_chat>0)then _draw_text(tar,ui_textx,ui_chaty,ChatString+net_chat_str+chat_type[r_blink1_colorb],ta_left,ui_ingamecl,c_white);
   end
   else
     if(net_chat_shlm>0)then
     begin
        MakeLogListForDraw(VisPlayer,ui_ingamecl,(net_chat_shlm div chat_shlm_t)+1,lmts_last_messages);
        if(ui_log_n>0)then
         for i:=0 to ui_log_n-1 do
          if(ui_log_c[i]>0)then _draw_text(tar,ui_textx,ui_logy-font_3hw*i,ui_log_s[i],ta_left,255,ui_log_c[i]);
     end;
   d_Hints(tar,VisPlayer);

   // resources
   with _players[VisPlayer] do
   begin
      limit:=armylimit+uprodl;
      _draw_text(tar,ui_energx,ui_energy,tc_aqua  +str_hint_energy+tc_default+i2s(cenergy)+tc_white+' / '+tc_aqua  +i2s(menergy),ta_left,255,ui_cenergy[cenergy<=0]);
      _draw_text(tar,ui_armyx ,ui_armyy ,tc_orange+str_hint_army  +tc_default+l2s(limit  )+tc_white+' / '+tc_orange+ui_limitstr ,ta_left,255,ui_limit[limit>=MaxPlayerLimit]);
   end;

   // VICTORY/DEFEAT/PAUSE/REPLAY END
   if(GameGetStatus(@str,@col,VisPlayer))then _draw_text(tar,ui_uiuphx,ui_uiuphy,str,ta_middle,255,col);

   if(VisPlayer<>HPlayer)then
    if(VisPlayer>0)
    then _draw_text(tar,ui_uiuphx,ui_uiplayery,_players[VisPlayer].name,ta_middle,255,c_white)
    else _draw_text(tar,ui_uiuphx,ui_uiplayery,str_all                 ,ta_middle,255,c_white);

   // TIMER
   D_Timer(tar,ui_textx,ui_texty,g_step,ta_left,str_time,c_white);

   // INVASION
   case g_mode of
gm_invasion: begin
                D_Timer(tar,ui_textx,ui_texty+font_3hw,g_inv_wave_t_next,ta_left,str_inv_time+b2s(g_inv_wave_n)+', '+str_time,c_white);
                if(_players[0].army>0)then _draw_text(tar,ui_textx,ui_texty+font_6hw,str_inv_ml+' '+l2s(_players[0].armylimit),ta_left,255,c_white);
             end;
gm_koth    : with g_cpoints[1] do
              if(cpOwnerPlayer>0)
              then _draw_text(tar,ui_textx,ui_texty+font_3hw,_players[cpOwnerPlayer].name+str_kothwinner,ta_left,255,PlayerGetColor(cpOwnerPlayer))
              else
                if(cpTimer<=0)
                then _draw_text(tar,ui_textx,ui_texty+font_3hw,str_kothtime+'---',ta_left,255,c_white)
                else
                  if(r_blink2_colorb)
                  then D_Timer(tar,ui_textx,ui_texty+font_3hw,cpCaptureTime-cpTimer,ta_left,str_kothtime,c_white)
                  else D_Timer(tar,ui_textx,ui_texty+font_3hw,cpCaptureTime-cpTimer,ta_left,str_kothtime,PlayerGetColor(cpTimerOwnerPlayer));
   end;

   if(vid_APM)then _draw_text(tar,ui_apmx,ui_apmy,'APM: '+_playerAPM[VisPlayer].APM_Str                ,ta_left,255,c_white);
   if(vid_FPS)then _draw_text(tar,ui_fpsx,ui_fpsy,'FPS: '+c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')',ta_left,255,c_white);

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
co_mmark   : c:=c_white;
   else _draw_surf(tar,mouse_x,mouse_y,spr_cursor);
   end;
   if(c<>0)then
   begin
      circleColor(tar,mouse_x   ,mouse_y,10,           c);
      hlineColor (tar,mouse_x-12,mouse_x+12,mouse_y   ,c);
      vlineColor (tar,mouse_x   ,mouse_y-12,mouse_y+12,c);
   end;
end;

procedure d_ui(tar:pSDL_Surface;lx,ly:integer;pl:byte);
begin
   d_PanelUI(tar,lx,ly);
   d_UIText(tar,pl);
   if(mouse_select_x0>-1)then rectangleColor(tar,lx+mouse_select_x0-vid_cam_x, ly+mouse_select_y0-vid_cam_y, mouse_x, mouse_y, PlayerGetColor(pl));
end;



