
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
aummat_upgrade    : RectangleColor(r_gminimap,al_mx-r,al_my-r,al_mx+r,al_my+r, al_c);
aummat_advance,
aummat_attacked_u,
aummat_created_u,
aummat_info       : CircleColor   (r_gminimap,al_mx  ,al_my  ,              r, al_c);
        end;

        al_t-=2;
     end;

   for i:=1 to MaxCPoints do
    with g_cpoints[i] do
     if(cpCaptureR>0)then
      if(cpenergy>0)
      then map_MinimapSpot(r_gminimap,cpmx,cpmy,cpmr,char_gen,GetCPColor(i))
      else map_MinimapSpot(r_gminimap,cpmx,cpmy,cpmr,char_cp ,GetCPColor(i));

   case g_mode of
gm_royale   : circleColor(r_gminimap,ui_hwp,ui_hwp,trunc(g_royal_r*map_mm_cx)+1,ui_max_color[r_blink2_colorb]);
   end;
end;

procedure d_Minimap(tar:pSDL_Surface);
var i:byte;
begin
   rectangleColor(r_gminimap,vid_mmvx,vid_mmvy,vid_mmvx+map_mm_CamW,vid_mmvy+map_mm_CamH, c_white);

   d_MinimapAlarms;

   {$IFDEF DTEST}
   if(test_mode>1)then
    if(UIPlayer<=LastPlayer)then
     with g_players[UIPlayer] do
      for i:=0 to LastPlayer do
       with ai_alarms[i] do
        if(aia_enemy_limit>0)then
         circleColor(r_gminimap,round(aia_x*map_mm_cx),round(aia_y*map_mm_cx),5,c_orange);
   {$ENDIF}

   draw_surf(tar       ,1,1,r_gminimap);
   draw_surf(r_gminimap,0,0,r_bminimap); // clear minimap for next cycle

   r_minimap_scan_blink:=not r_minimap_scan_blink;
end;

procedure ui_DrawBuild(tar:pSDL_Surface;lx,ly:integer);
var spr:PTMWTexture;
      i:integer;
 dunit:TUnit;
pdunit:PTUnit;
begin
   m_brushx-=vid_cam_x-lx;
   m_brushy-=vid_cam_y-ly;

   with g_players[PlayerClient]do
   case m_brush of
1..255:
   begin
      with g_uids[m_brush] do
      begin
         spr:=sm_uid2MWTexture(m_brush,270,0);
         SDL_SetAlpha(spr^.sdlSurface,SDL_SRCALPHA,128);
         draw_surf(tar,m_brushx-spr^.hw,m_brushy-spr^.hh,spr^.sdlSurface);
         SDL_SetAlpha(spr^.sdlSurface,SDL_SRCALPHA or SDL_RLEACCEL,255);

         circleColor(tar,m_brushx,m_brushy,_r,m_brushc);

         //sight range
         FillChar(dunit,SizeOf(dunit),0);
         pdunit:=@dunit;
         with dunit do
         begin
            uidi      :=m_brush;
            playeri   :=PlayerClient;
            player    :=@g_players[playeri];
            iscomplete:=true;
            hits      :=_mhits;
         end;
         unit_apllyUID(pdunit);
         unit_Bonuses (pdunit);
         if(UIUnitDrawRangeConditionals(pdunit))
         then circleColor(tar,m_brushx,m_brushy,dunit.srange,r_blink2_color_BG);
      end;

      // points areas
      for i:=1 to MaxCPoints do
       with g_cpoints[i] do
        if(cpCaptureR>0)and(cpNoBuildR>0)then
         circleColor(tar,
         lx+cpx-vid_cam_x,
         ly+cpy-vid_cam_y,
         cpNoBuildR,c_blue);

   end;
mb_psability:
   for i:=0 to 255 do
    if(uid_s[i]>0)and(IsUnitRange(uid_x[i],nil))then
     with g_uids[i] do
      case _ability of
uab_UACStrike     : if(upgr[upgr_uac_rstrike]>0)then circleColor(tar,mouse_x,mouse_y,blizzard_sr,c_gray);
uab_UACScan       : circleColor(tar,mouse_x,mouse_y,g_units[uid_x[i]].srange,c_gray);
uab_RebuildInPoint: begin
                    spr:=sm_uid2MWTexture(_rebuild_uid,270,0);
                    SDL_SetAlpha(spr^.sdlSurface,SDL_SRCALPHA,128);
                    draw_surf(tar,m_brushx-spr^.hw,m_brushy-spr^.hh,spr^.sdlSurface);
                    SDL_SetAlpha(spr^.sdlSurface,SDL_SRCALPHA or SDL_RLEACCEL,255);

                    circleColor(tar,m_brushx,m_brushy,g_uids[_rebuild_uid]._r,c_gray);
                    end;
uab_HTowerBlink,
uab_HKeepBlink,
uab_CCFly         : begin
                    spr:=sm_uid2MWTexture(i,270,0);
                    SDL_SetAlpha(spr^.sdlSurface,SDL_SRCALPHA,128);
                    draw_surf(tar,m_brushx-spr^.hw,m_brushy-spr^.hh,spr^.sdlSurface);
                    SDL_SetAlpha(spr^.sdlSurface,SDL_SRCALPHA or SDL_RLEACCEL,255);

                    circleColor(tar,m_brushx,m_brushy,_r,c_gray);
                    end;
        end;
   end;

   m_brushx+=vid_cam_x-lx;
   m_brushy+=vid_cam_y-ly;
end;

procedure ui_DrawGroupsIcons(tar:pSDL_Surface);
const rown = 6;
var  x,y,y0:integer;
     c,i,n :byte;
     b     :boolean;
begin
   y:=ui_texty+vid_oihw;
   draw_text(tar,ui_oicox-4,y+2,str_uiHint_UGroups,ta_RU,255,c_white);
   y+=vid_oiw;
   if(MaxUnitGroups>1)then
   for i:=1 to MaxUnitGroups-1 do
   begin
      n  :=0;
      y0 :=-1;
      x  :=ui_oicox;
      for b:=false to true do
      for c:=0 to 255 do
      if(c in ui_groups_uids[i,b])then
      begin
         if(y0=-1)then y0:=y+4;
         if((n mod rown)=0)then
         begin
            if(n>0)then y+=vid_oisw;
            x:=ui_oicox-vid_oips;
         end;
         with g_uids[c] do draw_surf(tar,x,y,un_sbtn.sdlSurface);

         x-=vid_oisw;
         n+=1;
      end;
      if(y0=-1)then y0:=y+4;
      if(ui_groups_n[i]>0)then
      begin
      draw_text(tar,ui_oicox,y0   ,b2s(i)             ,ta_RU,255,c_white );
      draw_text(tar,ui_oicox,y0+10,i2s(ui_groups_n[i]),ta_RU,255,c_orange);
      end;
      y+=vid_oihw;
   end;
end;

procedure ui_drawBtn(tar:pSDL_Surface;x,y:integer;surf:pSDL_Surface;sel,dsbl:boolean);
var ux,uy:integer;
begin
   if(vid_PannelPos<2)then // left right
   begin
      ux:=x*vid_BW+1;
      uy:=ui_bottomsy+y*vid_BW+1;
   end
   else
   begin
      ux:=ui_bottomsy+x*vid_BW+1;
      uy:=y*vid_BW+1;
      ux+=vid_BW*3*(y div 3);
      uy-=vid_BW*3*(y div 3);
   end;
   draw_surf(tar,ux,uy,surf);
   if(sel)then
   begin
      rectangleColor(tar,ux+1,uy+1,ux+vid_BW-3,uy+vid_BW-3,c_lime);
      rectangleColor(tar,ux+2,uy+2,ux+vid_BW-4,uy+vid_BW-4,c_lime);
   end
   else
     if(dsbl)then boxColor(tar,ux,uy,ux+vid_BW-2,uy+vid_BW-2,c_ablack);
end;

procedure ui_drawBtnT(tar:pSDL_Surface;x,y:integer;
lu1 ,lu2 ,ru ,rd ,ld :shortstring;
clu1,clu2,cru,crd,cld:cardinal;ms:shortstring);
var ux,uy:integer;
function cs(ps:pshortstring):boolean;begin cs:=(length(ps^)>0)and(ps^[1]<>'0'); end;
begin
   if(vid_PannelPos<2)then
   begin
      ux:=x*vid_BW+1;
      uy:=ui_bottomsy+y*vid_BW+1;
   end
   else
   begin
      ux:=ui_bottomsy+x*vid_BW+1;
      uy:=y*vid_BW+1;
      ux+=vid_BW*3*(y div 3);
      uy-=vid_BW*3*(y div 3);
   end;

   if(cs(@lu1))then draw_text(tar,ux+3       ,uy+4            ,lu1,ta_LU,5,clu1);
   if(cs(@lu2))then draw_text(tar,ux+3       ,uy+6+basefont_w1,lu2,ta_LU,5,clu2);
   if(cs(@ru ))then draw_text(tar,ux+vid_BW-4,uy+4            ,ru ,ta_RU,5,cru );
   if(cs(@rd ))then draw_text(tar,ux+vid_BW-4,uy+vid_BW-1     ,rd ,ta_RD,5,crd );
   if(cs(@ld ))then draw_text(tar,ux+3       ,uy+vid_BW-1     ,ld ,ta_LD,5,cld );

   if(cs(@ms ))then draw_text(tar,ux+vid_hBW,uy+vid_hBW  ,ms ,ta_MU,5,c_red );
end;

procedure d_TextBTN(tar:pSDL_Surface;bx,by:integer;txt:pshortstring;c:cardinal);
var ux,uy:integer;
begin
   if(vid_PannelPos<2)then
   begin
      ux:=bx*vid_BW+vid_hBW;
      uy:=ui_bottomsy+by*vid_BW+8;
   end
   else
   begin
      ux:=ui_bottomsy+by*vid_BW+vid_hBW;
      uy:=bx*vid_BW+8;
   end;

   draw_text(tar,ux,uy,txt^,ta_MU,6,c);
end;

procedure d_TabBTN(tar,btn:pSDL_Surface;
bx,by,
i1,i2,i3,i4:integer;
c1,c2,c3,c4:cardinal;
sel:boolean);
begin
   if(vid_PannelPos<2)then
   begin
      draw_surf(tar,bx,by+5,btn);
      if(sel)then
      begin
         rectangleColor(tar,bx+1,by+1,bx+vid_tBW-3,by+vid_BW-3,c_lime);
         rectangleColor(tar,bx+2,by+2,bx+vid_tBW-4,by+vid_BW-4,c_lime);
      end;
by+=3;if(i1>0)then draw_text(tar,bx+4,by,i2s(i1),ta_LU,255,c1);by+=basefont_w1+3;
      if(i2>0)then draw_text(tar,bx+4,by,i2s(i2),ta_LU,255,c2);by+=basefont_w1+3;
      if(i3>0)then draw_text(tar,bx+4,by,i2s(i3),ta_LU,255,c3);by+=basefont_w1+3;
      if(i4>0)then draw_text(tar,bx+4,by,i2s(i4),ta_LU,255,c4);
   end
   else
   begin
      draw_surf(tar,bx+5,by,btn);
      if(sel)then
      begin
         rectangleColor(tar,bx+1,by+1,bx+vid_BW-3,by+vid_tBW-3,c_lime);
         rectangleColor(tar,bx+2,by+2,bx+vid_BW-4,by+vid_tBW-4,c_lime);
      end;
by+=3;if(i1>0)then draw_text(tar,bx+3,by              ,i2s(i1),ta_LU,255,c1);
      if(i2>0)then draw_text(tar,bx+3,by+basefont_w1+3,i2s(i2),ta_LU,255,c2);

      if(i3>0)then draw_text(tar,bx+vid_BW-4,by              ,i2s(i3),ta_RU,255,c3);
      if(i4>0)then draw_text(tar,bx+vid_BW-4,by+basefont_w1+3,i2s(i4),ta_RU,255,c4);
   end;
end;

procedure d_Panel(tar:pSDL_Surface;POVPlayer:byte);
var ucl,ux,uy,uid:integer;
              req:cardinal;
pPOVPlayer:PTPlayer;
procedure PlayersButtoms;
var p:byte;
begin
   for p:=0 to LastPlayer do
   begin
      ui_drawBtnT(tar,ux,uy,g_players[p].name,'','','','',PlayerColorScheme[p],0,0,0,0,'');
      ui_drawBtn (tar,ux,uy,r_empty,p=POVPlayer,not GetBBit(@g_player_astatus,p));

      ux+=1;
      if(ux>2)then
      begin
         ux:=0;
         uy+=1;
      end;
   end;
   ui_drawBtn (tar,ux,uy,r_empty,p=POVPlayer,false);
   ui_drawBtnT(tar,ux,uy,str_panelHint_all,'','','','',c_white,0,0,0,0,'')
end;
begin
   if(POVPlayer>LastPlayer)
   then pPOVPlayer:=@ui_dPlayer
   else pPOVPlayer:=@g_players[POVPlayer];
   with pPOVPlayer^ do
   begin
      draw_surf(tar,0,0,r_panel);

      for ucl:=0 to 3 do
      begin
         if(vid_PannelPos<2)then
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
         0: d_TabBTN(tar,spr_tabs[ucl],ux,uy, ui_bprod_first      ,ui_bprod_all,ucl_cs[true ],ucl_c[true ],c_white,c_yellow,c_lime,c_orange, ucl=ui_tab);
         1: d_TabBTN(tar,spr_tabs[ucl],ux,uy, it2s(ui_uprod_first),uproda      ,ucl_cs[false],ucl_c[false],c_white,c_yellow,c_lime,c_orange, ucl=ui_tab);
         2: d_TabBTN(tar,spr_tabs[ucl],ux,uy, it2s(ui_pprod_first),upproda     ,0            ,0           ,c_white,c_yellow,0     ,0       , ucl=ui_tab);
         3: d_TabBTN(tar,spr_tabs[ucl],ux,uy, 0                   ,0           ,0            ,0           ,0      ,0       ,0     ,0       , ucl=ui_tab);
         end;
      end;

      d_TextBTN(tar,0,ui_menu_btnsy-4,@str_panelHint_menu,c_white);
      if(net_status>ns_single)then
       if(g_status<=LastPlayer)
       then d_TextBTN(tar,2,ui_menu_btnsy-4,@str_pause,PlayerColorScheme[g_status])
       else d_TextBTN(tar,2,ui_menu_btnsy-4,@str_pause,c_white                    );

      case ui_tab of
      0: if(POVPlayer<=LastPlayer)then
         for ucl:=0 to ui_ubtns do  // buildings
         begin
            uid:=ui_panel_uids[race ,ui_tab,ucl];
            if(uid=0)then continue;

            with g_uids[uid] do
            begin
               if(uid_e[uid]<=0)and(ucl_e[_ukbuilding,_ucl]<=0)then
                 if(a_units[uid]<=0)then continue;

               ux:=(ucl mod 3);
               uy:=(ucl div 3);

               req:=uid_CheckRequirements(pPOVPlayer,uid);

               ui_drawBtn (tar,ux,uy,un_btn.sdlSurface,m_brush=uid,(req>0) or not(uid in ui_bprod_possible));
               ui_drawBtnT(tar,ux,uy,

               i2s(ui_bprod_ucl_time[_ucl]),i2s(ui_bprod_ucl_count[ucl]),i2s(ucl_s[true,ucl]),i2s(ucl_e[true,ucl])                       ,ir2s(ui_bucl_reload[ucl]),
               ui_cenergy[cenergy<0]       ,c_dyellow                   ,c_lime              ,ui_max_color[ucl_e[true,ucl]>=a_units[uid]],c_aqua                   ,ir2s(build_cd));

               ui_uid_reload [uid]:=-1;
               ui_bucl_reload[ucl]:=-1;
            end;
         end;

      1: if(POVPlayer<=LastPlayer)then
         for ucl:=0 to ui_ubtns do  // units
         begin
            uid:=ui_panel_uids[race ,ui_tab,ucl];
            if(uid=0)then continue;

            with g_uids[uid] do
            begin
               if(uid_e[uid]<=0)and(ucl_e[_ukbuilding,_ucl]<=0)then
                 if(a_units[uid]<=0)then continue;

               ux:=(ucl mod 3);
               uy:=(ucl div 3);

               req:=uid_CheckRequirements(pPOVPlayer,uid);

               ui_drawBtn (tar,ux,uy,un_btn.sdlSurface,false,(req>0) or (uproda>=uprodm) or (ui_uprod_cur>=ui_uprod_max) or(ui_uprod_uid_max[uid]<=0));
               ui_drawBtnT(tar,ux,uy,
               ir2s(ui_uprod_uid_time[uid]),i2s(uprodu[uid]),i2s(uid_s[uid]),i2s(   uid_e[uid])                    ,i2s(ui_units_InTransport[uid]),
               ui_cenergy[cenergy<0]      ,c_dyellow       ,c_lime         ,ui_max_color[uid_e[uid]>=a_units[uid]],c_purple                ,'');
            end;
         end;

      2: if(POVPlayer<=LastPlayer)then
         for ucl:=0 to ui_ubtns do  // upgrades
         begin
            uid:=ui_panel_uids[race ,ui_tab,ucl];

            if (a_upgrs[uid]<=0)then continue;

            ux:=(ucl mod 3);
            uy:=(ucl div 3);

            ui_drawBtn(tar,ux,uy,g_upids[uid]._up_btn.sdlSurface,ui_pprod_time[uid]>0,
            (upid_CheckRequirements(pPOVPlayer,uid)>0)or(upproda>=upprodm) or (upprodu[uid]>=ui_pprod_max[uid]) );

            ui_drawBtnT(tar,ux,uy,
            ir2s(ui_pprod_time[uid]),i2s(upprodu[uid]),'',b2s(   upgr[uid])                            ,'',
            ui_cenergy[cenergy<0]  ,c_dyellow         ,0 ,ui_max_color[upgr[uid]>=g_upids[uid]._up_max] ,0 ,'');
         end;

      3: case tab3PageType of   // actions
         1: begin
               ui_drawBtn(tar,0,0,spr_b_rfast,sys_uncappedFPS,false);
               ui_drawBtn(tar,1,0,spr_b_rback,false          ,false);
               ui_drawBtn(tar,2,0,spr_b_rskip,false          ,false);
               ui_drawBtn(tar,0,1,spr_b_rstop,g_status>0     ,false);
               ui_drawBtn(tar,1,1,spr_b_rvis ,rpls_POVCam    ,false);
               ui_drawBtn(tar,2,1,spr_b_rlog ,rpls_showlog   ,false);
               ui_drawBtn(tar,0,2,spr_b_rfog ,sys_fog        ,false);

               ux:=2;
               uy:=2;
               PlayersButtoms;
            end;
         2: begin
               ui_drawBtn(tar,0,0,spr_b_rfog ,sys_fog    ,false);

               ux:=2;
               uy:=0;
               PlayersButtoms;
            end;
         3: begin
               ui_drawBtn(tar,0,0,spr_b_action ,false   ,ui_uibtn_sability>0);
               ui_drawBtn(tar,1,0,spr_b_paction,false   ,ui_uibtn_sability>0);
               ui_drawBtn(tar,2,0,spr_b_rebuild,false   ,ui_uibtn_rebuild<=0);

               ui_drawBtn(tar,0,1,spr_b_attack ,false   ,ui_uibtn_move<=0   );
               ui_drawBtn(tar,1,1,spr_b_stop   ,false   ,ui_uibtn_move<=0   );
               ui_drawBtn(tar,2,1,spr_b_apatrol,false   ,ui_uibtn_move<=0   );

               ui_drawBtn(tar,0,2,spr_b_move   ,false   ,ui_uibtn_move<=0   );
               ui_drawBtn(tar,1,2,spr_b_hold   ,false   ,ui_uibtn_move<=0   );
               ui_drawBtn(tar,2,2,spr_b_patrol ,false   ,ui_uibtn_move<=0   );

               ui_drawBtn(tar,0,3,spr_b_cancel ,false   ,false              );
               ui_drawBtn(tar,1,3,spr_b_selall ,false   ,ui_groups_n[MaxUnitGroups]  <=0);
               ui_drawBtn(tar,2,3,spr_b_delete ,false   ,(ucl_cs[false]+ucl_cs[true])<=0);

               ui_drawBtn(tar,0,4,spr_b_mmark  ,false   ,false              );
               ui_drawBtn(tar,1,4,spr_b_rclck  ,m_action,false              );
            end;
         end;
      end;
   end;
end;

procedure d_UIMouseMapEffects(tar:pSDL_Surface;lx,ly:integer);
var sx,sy,i,r:integer;
begin
   if(rpls_rstate<rpls_state_read)then
   begin
      ui_DrawBuild(tar,lx,ly);

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

           r:=(fr_fpsd2-(g_step mod fr_fpsd2))*4;

           circleColor(tar,sx,sy,r,c_white);
        end;
   end;
end;

procedure d_PanelUI;
begin
   if(vid_panel_timer=1)then
   begin
      d_MiniMap(r_panel  );
      d_Panel  (r_uipanel,UIPlayer);
   end;
end;

procedure d_Hints(tar:pSDL_Surface;POVPlayer:byte);
var uid:byte;
i,bx,by:integer;
     s1:shortstring;
    hs1,
    hs2,
    hs3,
    hs4:pshortstring;
    tu :PTUnit;
begin
   //str_panelHint_a
   if(0<=m_bx)and(m_bx<3)and(3<=m_by)and(m_by<=ui_menu_btnsy)then
   begin
      hs1:=nil;
      hs2:=nil;
      hs3:=nil;
      hs4:=nil;
      if(m_by=ui_menu_btnsy)then // menu/pause line hints
      begin
         if(m_bx=2)then
          if(net_status=ns_single)then exit;
         hs1:=@str_panelHint_Common[m_bx];
      end
      else
      case m_by of  // tab hints
      3  : case (vid_PannelPos<2) of
           true :if(mouse_y>vid_panelw)then hs1:=@str_panelHint_Tab[(mouse_x-vid_panelx) div vid_tBW];
           false:if(mouse_x>vid_panelw)then hs1:=@str_panelHint_Tab[(mouse_y-vid_panely) div vid_tBW];
           end;
      else
        if(vid_PannelPos<2)then
        begin
           bx:= m_bx;
           by:= m_by-4;
        end
        else
        begin
           bx:=(m_by-4);
           by:= m_bx   ;
           by+=3*(bx div 3);
           bx-=3*(bx div 3);
        end;
        i :=(by*3)+(bx mod 3);

        if(0<=i)and(i<=ui_ubtns)then
        begin
           if(ui_tab=3)then
           begin
              if(i<=_mhkeys)then
                case tab3PageType of
                1: hs1:=@str_panelHint_r[i];
                2: hs1:=@str_panelHint_o[i];
                3: hs1:=@str_panelHint_a[i];
                end;
           end
           else
             if(POVPlayer<=LastPlayer)then
               with g_players[POVPlayer] do
               begin
                  uid:=ui_panel_uids[race,ui_tab,i];
                  if(uid>0)then
                    case ui_tab of
                    0,1: begin
                            with g_uids[uid] do
                              if(uid_e[uid]=0)and(ucl_e[_ukbuilding,_ucl]<=0)and(a_units[uid]<=0)then exit;
                            hs1:=@g_uids[uid].un_txt_uihint1;
                            hs2:=@g_uids[uid].un_txt_uihint2;
                            hs3:=@g_uids[uid].un_txt_uihint3;
                            hs4:=@g_uids[uid].un_txt_uihint4;
                         end;
                    2  : begin
                            if(a_upgrs[uid]<=0)then exit;
                            s1 :=_makeUpgrBaseHint(uid,upgr[uid]+1);
                            hs1:=@s1;
                            hs4:=@g_upids[uid]._up_hint;
                         end;
                    end;
               end;
        end;
      end;
      if(hs1<>nil)then draw_text(tar,ui_textx,ui_hinty1,hs1^,ta_LU,ui_ingamecl,c_white);
      if(hs2<>nil)then draw_text(tar,ui_textx,ui_hinty2,hs2^,ta_LU,ui_ingamecl,c_white);
      if(hs3<>nil)then draw_text(tar,ui_textx,ui_hinty3,hs3^,ta_LU,ui_ingamecl,c_white);
      if(hs4<>nil)then draw_text(tar,ui_textx,ui_hinty4,hs4^,ta_LU,ui_ingamecl,c_white);
   end
   else
     if(IsUnitRange(ui_uhint,@tu))then
       with tu^ do
       with uid^ do
       with player^ do
       begin
          draw_text(tar,ui_textx,ui_hinty1,un_txt_uihintS+_makeAttributeStr(tu,0),ta_LU,ui_ingamecl,c_white);

          s1:='';
          _ADDSTR(@s1,lvlstr_w,sep_wdash);
          _ADDSTR(@s1,lvlstr_a,sep_wdash);
          _ADDSTR(@s1,lvlstr_s,sep_wdash);
          if(length(s1)>0)then draw_text(tar,ui_textx,ui_hinty2,str_uhint_UnitLevel+s1,ta_LU,ui_ingamecl,c_white);

          draw_text(tar,ui_textx,ui_hinty3,tc_white+'('+tc_default+name+tc_white+')',ta_LU,ui_ingamecl,PlayerColorScheme[pnum]);
     end;
end;

procedure D_ReplayProgress(tar:pSDL_Surface);
var x,y,
    w:integer;
    cx :single;
begin
   x:=vid_mapx;
   y:=vid_mapy+vid_cam_h-basefont_w1h;

   cx:=replay_GetProgress;

   w:=round(vid_cam_w*cx);

   boxColor(tar,x,y,x+w,y+basefont_w1h,c_yellow);
   draw_text(tar,x,y,rpls_list[rpls_list_sel]+' '+i2s(round(cx*100))+'%',ta_LU,255,c_white);
end;

procedure D_UIText(tar:pSDL_Surface;POVPlayer:byte);
var i,
limit:integer;
  str:shortstring;
  col:cardinal;
function ChatString:shortstring;
begin
   case ingame_chat of
chat_all     : ChatString:=str_chat_all;
chat_allies  : ChatString:=str_chat_allies;
0..LastPlayer: ChatString:=g_players[ingame_chat].name+':';
   end;
end;
begin
   // replay progress bar
   if(rpls_rstate=rpls_state_read)then D_ReplayProgress(tar);

   // LOG and HINTs
   if(log_LastMesTimer>0)then log_LastMesTimer-=1;
   if(ingame_chat>0)or(rpls_showlog)then
   begin
      if(net_status=ns_client)
      then MakeLogListForDraw(PlayerClient ,ui_ingamecl,ui_GameLogHeight,lmts_menu_chat)
      else MakeLogListForDraw(UIPlayer     ,ui_ingamecl,ui_GameLogHeight,lmts_menu_chat);
      if(ui_log_n>0)then
       for i:=0 to ui_log_n-1 do
        if(ui_log_c[i]>0)then draw_text(tar,ui_textx,ui_logy-basefont_w1h*i,ui_log_s[i],ta_LU,255,ui_log_c[i]);
      if(ingame_chat>0)then draw_text(tar,ui_textx,ui_chaty,ChatString+net_chat_str+chat_type[r_blink1_colorb],ta_LU,ui_ingamecl,c_white);
   end
   else
     if(log_LastMesTimer>0)then // last messages
     begin
        if(net_status=ns_client)
        then MakeLogListForDraw(PlayerClient ,ui_ingamecl,(log_LastMesTimer div log_LastMesTime)+1,lmts_last_messages)
        else MakeLogListForDraw(UIPlayer     ,ui_ingamecl,(log_LastMesTimer div log_LastMesTime)+1,lmts_last_messages);
        if(ui_log_n>0)then
         for i:=0 to ui_log_n-1 do
          if(ui_log_c[i]>0)then draw_text(tar,ui_textx,ui_logy-basefont_w1h*i,ui_log_s[i],ta_LU,255,ui_log_c[i]);
     end;
   d_Hints(tar,POVPlayer);

   // resources
   if(POVPlayer<=LastPlayer)then
     with g_players[POVPlayer] do
     begin
        limit:=armylimit+uprodl;
        draw_text(tar,ui_energx,ui_energy,tc_aqua  +str_uiHint_Energy+tc_default+i2s(cenergy           )+tc_white+' / '+tc_aqua  +i2s(menergy),ta_LU,255,ui_cenergy[cenergy<=0]);
        draw_text(tar,ui_armyx ,ui_armyy,tc_orange+str_uiHint_Army  +tc_default+l2s(limit,MinUnitLimit)+tc_white+' / '+tc_orange+ui_limitstr,ta_LU,255,ui_limit[limit>=MaxPlayerLimit]);

        if(ui_armyx<mouse_x)and(mouse_x<=(ui_armyx+140))and(ui_armyy<=mouse_y)and(mouse_y<=(ui_armyy+basefont_w1))then
        begin
        draw_text(tar,ui_armyx,ui_armyy+draw_font_h1  ,str_attr_building+tc_default+': '+l2s(ucl_l[true ]       ,MinUnitLimit),ta_LU,255,c_white);
        draw_text(tar,ui_armyx,ui_armyy+draw_font_h1*2,str_attr_unit    +tc_default+': '+l2s(ucl_l[false]+uprodl,MinUnitLimit),ta_LU,255,c_white);
        end;
     end;

   // VICTORY/DEFEAT/PAUSE/REPLAY END
   if(GameGetStatus(@str,@col,POVPlayer))then draw_text(tar,ui_uiuphx,ui_uiuphy,str,ta_MU,255,col);

   if(POVPlayer<>PlayerClient)or(rpls_rstate>=rpls_state_read)then
     if(POVPlayer<=LastPlayer)
     then draw_text(tar,ui_uiuphx,ui_uiplayery,g_players[POVPlayer].name,ta_MU,255,PlayerColorScheme[POVPlayer])
     else draw_text(tar,ui_uiuphx,ui_uiplayery,str_panelHint_all                  ,ta_MU,255,c_white           );

   // TIMER
   D_Timer(tar,ui_textx,ui_texty,g_step,ta_LU,str_uiHint_Time,c_white);

   // Game mode specific info
   case g_mode of
gm_koth    : with g_cpoints[1] do
              if(g_step<g_step_koth_pause)
              then D_Timer(tar,ui_textx,ui_texty+basefont_w1h,g_step_koth_pause-g_step,ta_LU,str_uiHint_KotHTimeAct,c_gray)
              else
                if(cpOwnerPlayer>0)
                then draw_text(tar,ui_textx,ui_texty+basefont_w1h,g_players[cpOwnerPlayer].name+str_uiHint_KotHWinner,ta_LU,255,PlayerColorScheme[cpOwnerPlayer])
                else
                  if(cpTimer<=0)
                  then draw_text(tar,ui_textx,ui_texty+basefont_w1h,str_uiHint_KotHTime+'---',ta_LU,255,c_white)
                  else
                    if(r_blink2_colorb)
                    then D_Timer(tar,ui_textx,ui_texty+basefont_w1h,cpCaptureTime-cpTimer,ta_LU,str_uiHint_KotHTime,c_white)
                    else D_Timer(tar,ui_textx,ui_texty+basefont_w1h,cpCaptureTime-cpTimer,ta_LU,str_uiHint_KotHTime,PlayerColorScheme[cpTimerOwnerPlayer]);
   end;

   if(test_mode>0)then draw_text(tar,vid_mapx+vid_cam_hw,vid_mapy+vid_cam_hh,'TEST MODE '+b2s(test_mode),ta_MU,255,c_white);

   //if(vid_APM)then draw_text(tar,ui_apmx,ui_apmy,'APM: '+player_APMdata[POVPlayer].APM_Str                ,ta_LU,255,c_white);
   if(vid_FPS)then draw_text(tar,ui_fpsx,ui_fpsy,'FPS: '+c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')',ta_LU,255,c_white);

   ui_DrawGroupsIcons(tar);
end;

procedure d_UIMouseCursor(tar:pSDL_Surface);   //cursor/brash
var c:cardinal;
begin
   c:=0;
   case m_brush of
mb_move,
mb_patrol   : c:=c_lime;
mb_attack,
mb_apatrol  : c:=c_red;
mb_psability: c:=c_aqua;
mb_mark     : c:=c_white;
   else draw_surf(tar,mouse_x,mouse_y,spr_cursor);
   end;
   if(c<>0)then
   begin
      circleColor(tar,mouse_x   ,mouse_y,10,           c);
      hlineColor (tar,mouse_x-12,mouse_x+12,mouse_y   ,c);
      vlineColor (tar,mouse_x   ,mouse_y-12,mouse_y+12,c);
   end;
end;

procedure d_ui(tar:pSDL_Surface;lx,ly:integer;POVPlayer:byte);
begin
   d_UIMouseMapEffects(tar,lx,ly);
   d_PanelUI;
   d_UIText(tar,POVPlayer);
   if(mouse_select_x0>-1)then
     if(POVPlayer<=LastPlayer)
     then rectangleColor(tar,lx+mouse_select_x0-vid_cam_x, ly+mouse_select_y0-vid_cam_y, mouse_x, mouse_y, PlayerColorScheme[POVPlayer])
     else rectangleColor(tar,lx+mouse_select_x0-vid_cam_x, ly+mouse_select_y0-vid_cam_y, mouse_x, mouse_y, c_white);
end;



