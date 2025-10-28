
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
        r:=(g_tick+cardinal(i+al_t)) mod ui_alarm_time;

        case al_v of
aummat_attacked_b,
aummat_created_b,
aummat_upgrade    : RectangleColor(ui_minimap,al_mx-r,al_my-r,al_mx+r,al_my+r, al_c);
aummat_advance,
aummat_attacked_u,
aummat_created_u,
aummat_info       : CircleColor   (ui_minimap,al_mx  ,al_my  ,              r, al_c);
        end;

        al_t-=2;
     end;

   map_MinimapKeyPoints(ui_minimap,true);

   case map_scenario of
mc_royale   : circleColor(ui_minimap,ui_hwp,ui_hwp,trunc(g_royal_r*map_mmcx)+1,ui_max_color[ui_mm_ScanBlink]);
   end;
end;

procedure d_Minimap(tar:pSDL_Surface);
var i:byte;
begin
   rectangleColor(ui_minimap,ui_cam_mmx,ui_cam_mmy,ui_cam_mmx+map_mmvw,ui_cam_mmy+map_mmvh, c_white);

   d_MinimapAlarms;

   // debug
   if(TestMode>1)and(UIPlayer<=LastPlayer)then
    with g_gplayers[UIPlayer] do
     for i:=0 to LastPlayer do
      with ai_alarms[i] do
       if(aia_enemy_limit>0)then
        circleColor(ui_minimap,round(aia_x*map_mmcx),round(aia_y*map_mmcx),5,c_orange);

   draw_sdlsurface(tar       ,1,1,ui_minimap );
   draw_sdlsurface(ui_minimap,0,0,ui_bminimap);

   ui_mm_ScanBlink:=not ui_mm_ScanBlink;
end;

procedure d_UIMouseBrush(tar:pSDL_Surface);
var spr:PTMWTexture;
 dunit:TUnit;
pdunit:PTUnit;
procedure DrawNoBuildAreas(SideStep:integer);
var i:integer;
begin
   // points areas
   for i:=0 to LastKeyPoint do
     with g_KeyPoints[i] do
       if(kpCaptureR>0)and(kpNoBuildR>0)then
         circleColor(tar,
         kpx-ui_cam_x,
         kpy-ui_cam_y,
         kpNoBuildR,c_blue);

   // map build rect
   rectangleColor(tar,
   SideStep-ui_cam_x,
   SideStep-ui_cam_y,
   map_Size-SideStep-ui_cam_x,
   map_Size-SideStep-ui_cam_y,
   c_blue);
end;

begin
   m_brushx-=ui_cam_x;
   m_brushy-=ui_cam_y;

   with g_gplayers[LocalPlayer]do
   case m_brush of
   1..255     : with g_uids[m_brush] do
                begin
                   spr:=uid2spr(m_brush,270,0);
                   SDL_SetAlpha(spr^.surf,SDL_SRCALPHA,128);
                   draw_sdlsurface(tar,m_brushx-spr^.hw,m_brushy-spr^.hh,spr^.surf);
                   SDL_SetAlpha(spr^.surf,SDL_SRCALPHA or SDL_RLEACCEL,255);

                   circleColor(tar,m_brushx,m_brushy,uid_r,m_brushc);

                   //sight range
                   FillChar(dunit,SizeOf(dunit),0);
                   pdunit:=@dunit;
                   with dunit do
                   begin
                      uidi      :=m_brush;
                      playeri   :=LocalPlayer;
                      player    :=@g_gplayers[playeri];
                      iscomplete:=true;
                      hits      :=uid_MaxHits1;
                   end;
                   unit_ApplyUID(pdunit);
                   unit_Bonuses (pdunit);
                   if(ui_UnitNeedDrawRange(pdunit))
                   then circleColor(tar,m_brushx,m_brushy,dunit.srange,ui_blink2_color_BG);

                   DrawNoBuildAreas(uid_r);
                end;
   {co_pability: if(ui_uibtn_pabilityu<>nil)then
                  with ui_uibtn_pabilityu^.uid^ do
                    case uid_ability of
                    uab_UACStrike     : circleColor(tar,mouse_x,mouse_y,blizzard_sr               ,c_gray);
                    uab_UACScan       : circleColor(tar,mouse_x,mouse_y,ui_uibtn_pabilityu^.srange,c_gray);
                    uab_RebuildInPoint: begin
                                        spr:=uid2spr(uid_rebuild_uid,270,0);
                                        SDL_SetAlpha(spr^.surf,SDL_SRCALPHA,128);
                                        draw_sdlsurface(tar,m_brushx-spr^.hw,m_brushy-spr^.hh,spr^.surf);
                                        SDL_SetAlpha(spr^.surf,SDL_SRCALPHA or SDL_RLEACCEL,255);

                                        circleColor(tar,m_brushx,m_brushy,g_uids[uid_rebuild_uid].uid_r,c_gray);
                                        DrawNoBuildAreas(g_uids[uid_rebuild_uid].uid_r);
                                        end;
                    uab_HTowerBlink,
                    uab_HKeepShift,
                    uab_UACCCLand     : begin
                                        spr:=uid2spr(ui_uibtn_pabilityu^.uidi,270,0);
                                        SDL_SetAlpha(spr^.surf,SDL_SRCALPHA,128);
                                        draw_sdlsurface(tar,m_brushx-spr^.hw,m_brushy-spr^.hh,spr^.surf);
                                        SDL_SetAlpha(spr^.surf,SDL_SRCALPHA or SDL_RLEACCEL,255);

                                        circleColor(tar,m_brushx,m_brushy,uid_r,c_gray);
                                        DrawNoBuildAreas(uid_r);
                                        end;
                   end; }
   end;

   m_brushx+=ui_cam_x;
   m_brushy+=ui_cam_y;
end;

procedure d_GroupsIcons(tar:pSDL_Surface);
const rown = 6;
var  x,y,y0:integer;
     c,i,n :byte;
     b     :boolean;
begin
   y:=ui_groupY+ui_GroupIcoW1h;
   draw_text(tar,ui_groupX,y,str_ui_UnitGroups,ta_RU,255,c_white);
   y+=ui_GroupIcoW1;
   if(MaxUnitGroups>1)then
     for i:=1 to MaxUnitGroups do
       with ui_group_d[i] do
       begin
          n  :=0;
          y0 :=-1;
          x  :=ui_groupX;
          for b:=false to true do
            for c:=0 to 255 do
              if(c in ugroup_uids[b])then
              begin
                 if(y0=-1)then y0:=y+font_wh;
                 if((n mod rown)=0)then
                 begin
                    if(n>0)then y+=ui_GroupIcoWq3;
                    x:=ui_groupX-ui_GroupIcoW2q3;
                 end;
                 with g_uids[c] do draw_sdlsurface(tar,x,y,uid_BTNSmall.surf);

                 x-=ui_GroupIcoWq3;
                 n+=1;
              end;
          if(y0=-1)then y0:=y+font_wh;
          if(ugroup_n>0)then
          begin
             draw_text(tar,ui_groupX,y0            ,b2s(i)       ,ta_RU,255,c_white );
             draw_text(tar,ui_groupX,y0+txt_line_h1,i2s(ugroup_n),ta_RU,255,c_orange);
          end;
          y+=ui_GroupIcoW1h;
       end;
end;

procedure ui_Panel_ButtonXY(bx0,by0,bx1,by1:pinteger;px,py,btnW,btnH:integer);
begin
   if(ui_ControlPanelPos<2)then
   begin
      bx0^:=px*btnW;if(bx1<>nil)then bx1^:=bx0^+btnW;
      by0^:=py*btnH;if(by1<>nil)then by1^:=by0^+btnH;
   end
   else
   begin
      bx0^:=py*btnH;if(bx1<>nil)then bx1^:=bx0^+btnH;
      by0^:=px*btnW;if(by1<>nil)then by1^:=by0^+btnW;
   end;
end;


procedure drawButtonS(tar:pSDL_Surface;bx,by:integer;surf:pSDL_Surface;selected,disabled:boolean);
var ux,uy:integer;
begin
   ui_Panel_ButtonXY(@ux,@uy,nil,nil,bx,by,ui_ButtonW1,ui_ButtonW1);

   draw_sdlsurface(tar,ux+1,uy+1,surf);

   if(selected)
   then draw_rectw(tar,ux,uy,ux+ui_ButtonW1,uy+ui_ButtonW1,-2,0,c_lime)
   else
     if(disabled)then boxColor(tar,ux+2,uy+2,ux+ui_ButtonW1-2,uy+ui_ButtonW1-2,c_ablack);
end;

procedure drawButtonT(tar:pSDL_Surface;bx,by:integer;
lu1 ,lu2 ,ru ,rd ,ld :shortstring;
clu1,clu2,cru,crd,cld:cardinal;ms:shortstring);
var ux,uy:integer;
function cs(ps:pshortstring):boolean;begin cs:=(length(ps^)<>0)and(ps^[1]<>'0'); end;
begin
   ui_Panel_ButtonXY(@ux,@uy,nil,nil,bx,by,ui_ButtonW1,ui_ButtonW1);

   if(cs(@lu1))then draw_text(tar,ux+font_wh            ,uy+font_wh            ,lu1,ta_LU  ,5,clu1);
   if(cs(@lu2))then draw_text(tar,ux+font_wh            ,uy+font_wh+txt_line_h1,lu2,ta_LU  ,5,clu2);
   if(cs(@ru ))then draw_text(tar,ux-font_wh+ui_ButtonW1,uy+font_wh            ,ru ,ta_RU  ,5,cru );
   if(cs(@rd ))then draw_text(tar,ux-font_wh+ui_ButtonW1,uy-font_wh+ui_ButtonW1,rd ,ta_RB  ,5,crd );
   if(cs(@ld ))then draw_text(tar,ux+font_wh            ,uy-font_wh+ui_ButtonW1,ld ,ta_LB  ,5,cld );

   if(cs(@ms ))then draw_text(tar,ux+ui_ButtonWh,uy+ui_ButtonWh  ,ms ,ta_MM,5,c_red );
end;


procedure d_ButtonSText(tar:pSDL_Surface;bx,by:integer;align:byte;txt:pshortstring;color:cardinal;selected,disabled:boolean);
var ux,uy:integer;
begin
   ui_Panel_ButtonXY(@ux,@uy,nil,nil,bx,by,ui_ButtonW1,ui_ButtonW1);

   case align of
ta_MM: if(ui_ControlPanelPos<2)
       then draw_text(tar,ux+ui_ButtonWh,min2i(uy+ui_ButtonWh,vid_vh-font_w1h),txt^,align,5,color)
       else draw_text(tar,ux+ui_ButtonWh,      uy+ui_ButtonWh                 ,txt^,align,5,color);
ta_LU:      draw_text(tar,ux+font_wh    ,uy+font_wh                           ,txt^,align,5,color);
   end;
   drawButtonS(tar,bx,by,spr_empty,selected,disabled);
end;

procedure d_TabButtonSprite(tar,btn:pSDL_Surface;bi:integer;selected:boolean);
var
bx0,by0,
bx1,by1:integer;
begin
   ui_Panel_ButtonXY(@bx0,@by0,@bx1,@by1,bi,3,ui_TabButtonW,ui_ButtonW1);

   draw_sdlsurface(tar,((bx0+bx1)div 2)-(btn^.w div 2),
                       ((by0+by1)div 2)-(btn^.h div 2),btn);
   if(selected)then draw_rectw(tar,bx0,by0,bx1,by1,-2,0,c_lime);
end;

procedure d_TabButtonText(tar:pSDL_Surface;bi,
                          i1,i2,i3,i4:integer;
                          c1,c2,c3,c4:cardinal);
var
bx0,by0,
bx1,by1:integer;
begin
   ui_Panel_ButtonXY(@bx0,@by0,@bx1,@by1,bi,3,ui_TabButtonW,ui_ButtonW1);

   if(ui_ControlPanelPos<2)then
   begin
by0+=font_wh;if(i1>0)then draw_text(tar,bx0+font_wh,by0,i2s(i1),ta_LU,255,c1);by0+=txt_line_h1;
             if(i2>0)then draw_text(tar,bx0+font_wh,by0,i2s(i2),ta_LU,255,c2);by0+=txt_line_h1;
             if(i3>0)then draw_text(tar,bx0+font_wh,by0,i2s(i3),ta_LU,255,c3);by0+=txt_line_h1;
             if(i4>0)then draw_text(tar,bx0+font_wh,by0,i2s(i4),ta_LU,255,c4);
   end
   else
   begin
by0+=font_wh;if(i1>0)then draw_text(tar,bx0+font_wh            ,by0            ,i2s(i1),ta_LU,255,c1);
             if(i2>0)then draw_text(tar,bx0+font_wh            ,by0+txt_line_h1,i2s(i2),ta_LU,255,c2);

             if(i3>0)then draw_text(tar,bx0-font_wh+ui_ButtonW1,by0            ,i2s(i3),ta_RU,255,c3);
             if(i4>0)then draw_text(tar,bx0-font_wh+ui_ButtonW1,by0+txt_line_h1,i2s(i4),ta_RU,255,c4);
   end;
end;

{function GetRebuildIco(pu:PTUnit):pSDL_Surface;
begin
   GetRebuildIco:=spr_uibtn_Rebuild;
   if(pu<>nil)then
     if(pu^.uid^.uid_rebuild_uid>0)then
       GetRebuildIco:=g_uids[pu^.uid^.uid_rebuild_uid].uid_BTNBig.surf;
end; }

function ui_PanelBTNUnit(POVPlayer:PTPlayerGameData;uid:byte):boolean;
begin
   ui_PanelBTNUnit:=false;
   if(uid=0)then exit;
   if(POVPlayer<>nil)then
     with POVPlayer^ do
       with g_uids[uid] do
         if (units_uid_e[uid]<=0)
         and(units_ucl_e[uid_isbuilding,uid_class]<=0)
         and(units_uid_m[uid]<=0)then exit;
   ui_PanelBTNUnit:=true;
end;
function ui_PanelBTNUpgrade(POVPlayer:PTPlayerGameData;uid:byte):boolean;
begin
   ui_PanelBTNUpgrade:=false;
   if(uid=0)then exit;
   if(POVPlayer<>nil)then
     with POVPlayer^ do
       if(upgrs_max[uid]<=0)then exit;
   ui_PanelBTNUpgrade:=true;
end;


procedure d_Panel(tar:pSDL_Surface;PVisPlayer:PTPlayerGameData);
var
ucl,p,
uid,
ux,uy:integer;
begin
   draw_sdlsurface(tar,0,0,ui_UIPanelTemplate);

   for ucl:=0 to 3 do d_TabButtonSprite(tar,spr_uibtn_Tabs[ucl],ucl,ucl=ui_tab);
   if(PVisPlayer<>nil)then
     with PVisPlayer^ do
       for ucl:=0 to 3 do
         case ucl of
         0: d_TabButtonText(tar,ucl,ui_bprod_first      ,ui_bprod_all ,units_bld_s[true ],units_bld_e[true ],c_white,c_yellow,c_lime,c_orange);
         1: d_TabButtonText(tar,ucl,it2s(ui_uprod_first),prod_unit_Now,units_bld_s[false],units_bld_e[false],c_white,c_yellow,c_lime,c_orange);
         2: d_TabButtonText(tar,ucl,it2s(ui_pprod_first),prod_upgr_Now,0                 ,0                 ,c_white,c_yellow,0     ,0       );
         3: d_TabButtonText(tar,ucl,0                   ,0            ,0                 ,0                 ,0      ,0       ,0     ,0       );
         end;

   if(iActOn(iAct_InGameMenu ))then d_ButtonSText(tar,0,ui_CtrlPanelBL,ta_MM,@str_ui_menu   ,c_white                       ,false,false);
   if(iActOn(iAct_InGamePause))then d_ButtonSText(tar,2,ui_CtrlPanelBL,ta_MM,@str_menu_Pause,PlayerGetColor(g_status,false),false,false);

{
drawButtonS(tar,ux,uy,spr_uibtn_mmark  ,false   ,false              );
}
   case ui_tab of
   tab_buildings,
   tab_units,
   tab_upgrades : if(PVisPlayer<>nil)then
                    for ucl:=0 to ui_ButtonsNum do
                      if(iActOn(iAct_SProd1+ucl ))then
                        with PVisPlayer^ do
                        begin
                           ux:=(ucl mod 3);
                           uy:=(ucl div 3)+4;
                           uid:=ui_panel_uids[race,ui_tab,ucl];
                           case ui_tab of
                           tab_buildings: with g_uids[uid] do
                                          begin
                                             drawButtonS(tar,ux,uy,uid_BTNBig.surf,m_brush=uid,not iActEnabled(iAct_SProd1+ucl));
                                             drawButtonT(tar,ux,uy,
                                             i2s(ui_bprod_ucl_time[uid_class]),i2s(ui_bprod_ucl_count[ucl]),i2s(units_ucl_s[true,ucl]),i2s(units_ucl_e[true,ucl])                            ,ir2s(ui_bucl_reload[ucl]),
                                             ui_cenergy[energyl_cur<0]        ,c_dyellow                   ,c_lime                    ,ui_max_color[not player_UIDLimitCheck(PVisPlayer,uid)],c_aqua,ir2s(build_cd));
                                          end;
                           tab_units    : with g_uids[uid] do
                                          begin
                                             drawButtonS(tar,ux,uy,uid_BTNBig.surf,false,not iActEnabled(iAct_SProd1+ucl));
                                             drawButtonT(tar,ux,uy,
                                             ir2s(ui_uprod_uid_time[uid]),i2s(prod_unit_uid[uid]),i2s(units_uid_s[uid]),i2s(units_uid_e[uid])                                 ,i2s(ui_units_inapc[uid]),
                                             ui_cenergy[energyl_cur<0]   ,c_dyellow              ,c_lime               ,ui_max_color[not player_UIDLimitCheck(PVisPlayer,uid)],c_purple,'');
                                          end;
                           tab_upgrades : begin
                                             drawButtonS(tar,ux,uy,g_upids[uid].upgr_btn.surf,ui_pprod_upg_time[uid]>0,not iActEnabled(iAct_SProd1+ucl));
                                             drawButtonT(tar,ux,uy,
                                             ir2s(ui_pprod_upg_time[uid]),i2s(prod_upgr_upid[uid]),'',b2s(upgrs_cur[uid])                                 ,'',
                                             ui_cenergy[energyl_cur<0]   ,c_dyellow        ,0 ,ui_max_color[upgrs_cur[uid]>=g_upids[uid].upgr_max] ,0 ,'');
                                          end;
                           end;
                      end;

   tab_controls : for ucl:=0 to ui_ButtonsNum do
                  begin
                     ux:=(ucl mod 3);
                     uy:=(ucl div 3)+4;

                     uid:=ui_panel_CTabIActs[ui_ControlTabType,ucl];
                     if(iActOn(uid))then
                       case uid of
                       iAct_Control_UAbility1,
                       iAct_Control_UAbility2,
                       iAct_Control_UAbility3 : if(ui_CommandercPU<>nil)then
                                                begin
                                                   p:=0;
                                                   case uid of
                                                   iAct_Control_UAbility1: p:=ui_CommandercPU^.uid^.uid_ability1;
                                                   iAct_Control_UAbility2: p:=ui_CommandercPU^.uid^.uid_ability2;
                                                   iAct_Control_UAbility3: p:=ui_CommandercPU^.uid^.uid_ability3;
                                                   end;
                                                   if(p>0)then
                                                   begin
                                                      drawButtonS(tar,ux,uy,ui_AbilityGetBTN(ui_CommandercPU,p),-m_brush=p,not iActEnabled(uid));
                                                      drawButtonT(tar,ux,uy,'','','','',ir2s(ui_CommandercPU^.rld),
                                                                            0 ,0 ,0 ,0 ,c_aqua                    ,'');
                                                   end;
                                                end;
                       iAct_Control_UAMove    : drawButtonS(tar,ux,uy,spr_uibtn_Attack    ,false,not iActEnabled(uid));
                       iAct_Control_UAStop    : drawButtonS(tar,ux,uy,spr_uibtn_Stop      ,false,not iActEnabled(uid));
                       iAct_Control_UAPatrol  : drawButtonS(tar,ux,uy,spr_uibtn_APatrol   ,false,not iActEnabled(uid));
                       iAct_Control_UMove     : drawButtonS(tar,ux,uy,spr_uibtn_Move      ,false,not iActEnabled(uid));
                       iAct_Control_UStop     : drawButtonS(tar,ux,uy,spr_uibtn_Hold      ,false,not iActEnabled(uid));
                       iAct_Control_UPatrol   : drawButtonS(tar,ux,uy,spr_uibtn_Patrol    ,false,not iActEnabled(uid));
                       iAct_Control_UProdCncl : drawButtonS(tar,ux,uy,spr_uibtn_ProdCancel,false,not iActEnabled(uid));
                       iAct_Control_UDestroy  : drawButtonS(tar,ux,uy,spr_uibtn_Delete    ,false,not iActEnabled(uid));
                       iAct_Control_USelBase  : drawButtonS(tar,ux,uy,spr_uibtn_F1        ,false,not iActEnabled(uid));
                       iAct_Control_USelArmy  : drawButtonS(tar,ux,uy,spr_uibtn_F2        ,false,not iActEnabled(uid));

                       iAct_Replay_Fog,
                       iAct_Observer_Fog      : drawButtonS(tar,ux,uy,spr_uibtn_ReplayFog  ,ui_fog,not iActEnabled(uid));

                       iAct_Replay_PlayerAll,
                       iAct_Observer_PlayerAll: d_ButtonSText(tar,ux,uy,ta_MM,@str_all,c_white,UIPlayer>LastPlayer,not iActEnabled(uid));

                       iAct_Observer_Player0..
                       iAct_Observer_Player7  : begin
                                                   p:=uid-iAct_Observer_Player0;
                                                   with g_gplayers[p] do
                                                     d_ButtonSText(tar,ux,uy,ta_LU,@name,PlayerGetColor(p,false),UIPlayer=p,not iActEnabled(uid));
                                                end;

                       iAct_Replay_Player0..
                       iAct_Replay_Player7    : begin
                                                   p:=uid-iAct_Replay_Player0;
                                                   with g_gplayers[p] do
                                                     d_ButtonSText(tar,ux,uy,ta_LU,@name,PlayerGetColor(p,false),UIPlayer=p,not iActEnabled(uid));
                                                end;
                       iAct_Replay_Log        : drawButtonS(tar,ux,uy,spr_uibtn_ReplayLog  ,rpls_showlog     ,not iActEnabled(uid));
                       iAct_Replay_POV        : drawButtonS(tar,ux,uy,spr_uibtn_ReplayPOV  ,rpls_POVRecorder ,not iActEnabled(uid));
                       iAct_Replay_Fast       : drawButtonS(tar,ux,uy,spr_uibtn_ReplayFast ,sys_uncappedFPS  ,not iActEnabled(uid));
                       iAct_Replay_Pause      : drawButtonS(tar,ux,uy,spr_uibtn_ReplayPause,replay_IsPaused  ,not iActEnabled(uid));
                       iAct_Replay_Back60     : drawButtonS(tar,ux,uy,spr_uibtn_ReplayBack3,false            ,not iActEnabled(uid));
                       iAct_Replay_Back10     : drawButtonS(tar,ux,uy,spr_uibtn_ReplayBack2,false            ,not iActEnabled(uid));
                       iAct_Replay_Back2      : drawButtonS(tar,ux,uy,spr_uibtn_ReplayBack1,false            ,not iActEnabled(uid));
                       iAct_Replay_Forward2   : drawButtonS(tar,ux,uy,spr_uibtn_ReplayForw1,false            ,not iActEnabled(uid));
                       iAct_Replay_Forward10  : drawButtonS(tar,ux,uy,spr_uibtn_ReplayForw2,false            ,not iActEnabled(uid));
                       iAct_Replay_Forward60  : drawButtonS(tar,ux,uy,spr_uibtn_ReplayForw3,false            ,not iActEnabled(uid));
                       end;
                  end;
   end;
end;



procedure d_MapMouse(tar:pSDL_Surface);
var sx,sy,i,r:integer;
begin
   d_UIMouseBrush(tar);

   if(ui_mc_a>0)then //click effect
   begin
      sx:=ui_mc_a;
      sy:=sx shr 1;
      ellipseColor(tar,ui_mc_x-ui_cam_x,ui_mc_y-ui_cam_y,sx,sy,ui_mc_c);

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

          sx:=al_x-ui_cam_x;
          sy:=al_y-ui_cam_y;

          r:=(32-(g_tick mod 32))*4;

          circleColor(tar,sx,sy,r,c_white);
       end;
end;

procedure d_MakeHintList;
var
uid,a:byte;
s1   :shortstring;
procedure AddLine(pstr:pshortstring);
begin
   str_AddToStrList(@ui_MouseHintL,@ui_MouseHintN,ui_HintLineLen,@ui_MouseHintW,false,false,pstr^);
end;
procedure BrushTargetHint;
begin
   if(m_UnitTargetP<>nil)then
     with m_UnitTargetP^ do
     with uid^ do
     with player^ do
     begin
        AddLine(@uid_str_name);
        s1:=str_UnitAttributes(m_UnitTargetP,0);
        AddLine(@s1);
        s1:='';
        STRADD(@s1,lvlstr_w,sep_wdash);
        STRADD(@s1,lvlstr_a,sep_wdash);
        STRADD(@s1,lvlstr_s,sep_wdash);
        if(length(s1)>0)then
        begin
        s1:=str_hint_UpgradesLvl+s1+tc_default;
        STRADD(@s1,str_hint_hits+li2s(hits),sep_scomma);
        if(playeri=UIPlayer)and(uid_EnergyGen>0)then
        STRADD(@s1,str_hint_IncEnergyLevel+'('+tc_aqua+'+'+i2s(uid_EnergyGen)+tc_default+')',sep_scomma);
        AddLine(@s1);
        end;
        s1:=tc_white+'('+tc_default+chr(playeri)+name+tc_white+')';
        AddLine(@s1);
     end;
end;
begin
   case m_focus of
   mf_map      : case m_brush of
                 co_apatrol,
                 co_patrol,
                 1..255     :;
                 -255..-1   : with g_aids[-m_brush] do
                              begin
                                 AddLine(@ua_str_name);
                                 case ua_type of
                                 uat_UnitAny,
                                 uat_UnitOwn,
                                 uat_UnitAlly,
                                 uat_UnitEnemy: BrushTargetHint;
                                 end;
                              end
                 else BrushTargetHint;
                 end;

   mf_Tabs     : if(0<=m_btnN)and(m_btnN<4)then AddLine(@str_ui_Tab[m_BtnN]);
   mf_CtrlPanel: if(0<=m_btnN)and(m_btnN<=ui_ButtonsNum)then
                   case ui_tab of
                   tab_Buildings,
                   tab_Units,
                   tab_Upgrades : if(UIPlayer<=LastPlayer)then
                                    with g_gplayers[UIPlayer] do
                                    begin
                                       uid:=ui_panel_uids[race,ui_tab,m_BtnN];
                                       if(iActOn(iAct_SProd1+m_btnN))then
                                         case ui_tab of
                                         tab_Buildings,
                                         tab_Units    : with g_uids[uid] do
                                                        begin
                                                           AddLine(@uid_str_NameHK      );
                                                           AddLine(@uid_str_CostLimit   );
                                                           AddLine(@uid_str_DefaultAttr );
                                                           AddLine(@uid_str_FullDescript);
                                                           if(uid_CanAttack)then
                                                           begin
                                                              AddLine(@str_hint_UnitArming);
                                                              for a:=0 to LastUnitArms do
                                                                AddLine(@uid_str_Arms[a]);
                                                              AddLine(@uid_str_ArmsCommon );
                                                           end;
                                                           AddLine(@uid_str_Reqs);
                                                           AddLine(@uid_str_Prod);
                                                        end;
                                         tab_Upgrades : with g_upids[uid] do
                                                        begin
                                                           AddLine(@upgr_str_NameHK);
                                                           s1:=str_makeUpgrCostHint(uid,upgrs_cur[uid]+1);
                                                           AddLine(@s1);
                                                           AddLine(@upgr_str_Descript);
                                                           AddLine(@upgr_str_Reqs);
                                                        end;
                                         end;
                                    end;
                   tab_Controls : begin
                                     uid:=ui_panel_CTabIActs[ui_ControlTabType,m_BtnN];
                                     if(iActOn(uid))then
                                       case uid of
                                       0                     : ;
                                       iAct_Control_UAbility1,
                                       iAct_Control_UAbility2,
                                       iAct_Control_UAbility3: if(ui_CommandercPU<>nil)then
                                                               begin
                                                                  a:=0;
                                                                  case uid of
                                                                  iAct_Control_UAbility1: a:=ui_CommandercPU^.uid^.uid_ability1;
                                                                  iAct_Control_UAbility2: a:=ui_CommandercPU^.uid^.uid_ability2;
                                                                  iAct_Control_UAbility3: a:=ui_CommandercPU^.uid^.uid_ability3;
                                                                  end;
                                                                  if(a>0)then
                                                                    with g_aids[a] do
                                                                      case ua_mbrush_r of
                                                                      -255..-1   :;
                                                                      uambt_nform:;
                                                                      uambt_self :;
                                                                      else
                                                                      end;
                                                                      {case ua_mbrush_uid of
                                                                      0  : begin
                                                                              AddLine(@ua_str_name    );
                                                                              AddLine(@ua_str_Descript);
                                                                           end;
                                                                      255: if(ui_CommandercPU^.uid^.uid_nextForm=0)then
                                                                           begin
                                                                              AddLine(@ua_str_name    );
                                                                              AddLine(@ua_str_Descript);
                                                                           end
                                                                           else
                                                                             with g_uids[ui_CommandercPU^.uid^.uid_nextForm] do
                                                                             begin
                                                                                AddLine(@uid_str_Name     );
                                                                                AddLine(@uid_str_CostLimit);
                                                                             end;
                                                                      else
                                                                          with g_uids[ua_mbrush_uid] do
                                                                          begin
                                                                             AddLine(@uid_str_Name     );
                                                                             AddLine(@uid_str_CostLimit);
                                                                          end;
                                                                      end};
                                                               end;
                                       else                    AddLine(@str_action_hint[uid]);
                                       end;
                                  end;
                    end;
   mf_MenuPause: case m_btnN of
                 0 : if(iActOn(iAct_InGameMenu ))then AddLine(@str_action_hint[iAct_InGameMenu ]);
                 2 : if(iActOn(iAct_InGamePause))then AddLine(@str_action_hint[iAct_InGamePause]);
                 end;
   end;
end;

procedure D_ReplayProgress(tar:pSDL_Surface);
var
w : integer;
cx: single;
begin
   cx:=replay_GetProgress;
   w :=round(cx*ui_ReplayBarW);

   boxColor (tar,ui_ReplayBarX,ui_ReplayBarY-ui_ReplayBarH,ui_ReplayBarX+w,ui_ReplayBarY,c_yellow);
   draw_text(tar,ui_ReplayBarX,ui_ReplayBarY,i2s(round(cx*100))+'%',ta_LB,255,c_white);
end;

procedure D_UILog(tar:pSDL_Surface;x,y:integer;logAlign,POVPlayer,LogLineLen,LogListH:byte;LogSet:TSob);
var i:integer;
begin
   MakeLogListForDraw(POVPlayer,LogLineLen,LogListH,0,LogSet);
   if(ui_log_n>0)then
     for i:=0 to ui_log_n-1 do
       if(ui_log_color[i]>0)then
         draw_text(tar,x,y-txt_line_h2*i,ui_log_lines[i],logAlign,255,ui_log_color[i]);
end;

procedure D_UIText(tar:pSDL_Surface);
var i,x,y,
limit :integer;
logPov:byte;
  str :shortstring;
  col :cardinal;
function ChatString:shortstring;
begin
   case ui_InGameChat of
chat_all     : ChatString:=str_ui_ChatAll;
chat_allies  : ChatString:=str_ui_ChatAllies;
1..MaxPlayers: ChatString:=g_gplayers[ui_InGameChat-1].name+':';
   end;
end;
begin
   // replay progress bar
   if(rpls_pstate=rpls_read)then
     D_ReplayProgress(tar);

   if(net_status=ns_client)
   then logPov:=LocalPlayer
   else logPov:=UIPlayer;

   // last events and chat
   if(ui_InGameChat>0)or(rpls_showlog)then
   begin
      D_UILog(tar,ui_logx,ui_logy-txt_line_h3,ta_LB,logPov,ui_log_LineLen,ui_log_ListSize,lmts_menu_chat);
      if(ui_InGameChat>0)then
      begin
         str:=ChatString;
         draw_text(tar,ui_logx,
                       ui_logy,
                       str+str_CutLast(net_chat_str+chat_type[ui_blink1_colorb],ui_log_LineLen-length(str)),
                       ta_LB,ui_log_LineLen,c_white);
      end;
   end
   else
     if(ui_log_LastTimer>0)then // last messages
     begin
        ui_log_LastTimer-=1;
        D_UILog(tar,ui_logx,ui_logy,ta_LB,logPov,ui_log_LineLen,(ui_log_LastTimer div ui_log_TimeLast)+1,lmts_last_events);
     end;

   // resources
   if(UIPlayer<=LastPlayer)then
     with g_gplayers[UIPlayer] do
       if(not isdefeated)and(not isobserver)then
       begin
          limit:=armylimit+prod_unit_Limit;
          draw_text(tar,ui_EnergyX,ui_EnergyY            ,str_ui_EnergyLevel   +tc_default+i2s(energyl_cur               )+tc_white+' / '+tc_aqua  +i2s(energyl_max)
                                                                                                                         ,ta_RU,255,ui_cenergy[energyl_cur<=0]         );
          draw_text(tar,ui_ArmyX  ,ui_ArmyY              ,str_ui_LimitArmy     +tc_default+limit2s(limit,MinUnitLimit)+tc_white+' / '+tc_orange+ui_limitstr
                                                                                                                         ,ta_LU,255,ui_limit[limit>=MaxPlayerLimit]);
          draw_text(tar,ui_ArmyX  ,ui_ArmyY+txt_line_h2  ,str_ui_LimitUnits    +limit2s(units_bld_l[true ]               ,MinUnitLimit),ta_LU,255,c_white);
          draw_text(tar,ui_ArmyX  ,ui_ArmyY+txt_line_h2*2,str_ui_LimitBuildings+limit2s(units_bld_l[false]+prod_unit_Limit,MinUnitLimit),ta_LU,255,c_white);
       end;

   // GAME STATUS VICTORY/DEFEAT/PAUSE/REPLAY END
   if(GameGetStatus(@str,@col,UIPlayer))then draw_text(tar,ui_GameStatusX,ui_GameStatusY,str,ta_MU,255,col);

   // POV PLAYER
   if(rpls_pstate=rpls_read)or(g_gplayers[LocalPlayer].isobserver)then
     if(UIPlayer<=LastPlayer)
     then draw_text(tar,ui_GameStatusX,ui_PovPlayerY,g_gplayers[UIPlayer].name,ta_MU,255,PlayerGetColor(UIPlayer,false))
     else draw_text(tar,ui_GameStatusX,ui_PovPlayerY,str_all                  ,ta_MU,255,c_white                       );

   // TIMER
   D_Timer(tar,ui_timerX,ui_timerY,g_tick,ta_LU,255,str_ui_time,c_white);

   // OBJECTIVES
   y:=ui_objectivesY;
   draw_text(tar,ui_objectivesx,y,str_ui_Objectives,ta_LU,ui_Objectives_LineLen,c_white,@y);
   y+=txt_line_h2;
   case g_type  of
   gt_scirmish: case map_scenario of
                mc_KotH     : begin
                              draw_text(tar,ui_objectivesx,y,str_objective_KotH  ,ta_LU,ui_Objectives_LineLen,c_white,@y);
                              y+=txt_line_h2;
                              with g_KeyPoints[0] do
                               if(g_tick<g_step_koth_pause)
                               then D_Timer(tar,ui_objectivesx,y,g_step_koth_pause-g_tick,ta_LU,ui_Objectives_LineLen,str_ui_KotHTime_act,c_gray,@y)
                               else
                                 if(kpOwnerPlayer<=LastPlayer)
                                 then draw_text(tar,ui_objectivesx,y,g_gplayers[kpOwnerPlayer].name+str_ui_KotHWinner,ta_LU,ui_Objectives_LineLen,PlayerGetColor(kpOwnerPlayer,false),@y)
                                 else
                                   if(kpTimer<=0)
                                   then draw_text(tar,ui_objectivesx,y,str_ui_KothTime+'---',ta_LU,ui_Objectives_LineLen,c_white,@y)
                                   else
                                     if(ui_blink2_colorb)
                                     then D_Timer(tar,ui_objectivesx,y,kpCaptureTime-kpTimer,ta_LU,ui_Objectives_LineLen,str_ui_KothTime,c_white,@y)
                                     else D_Timer(tar,ui_objectivesx,y,kpCaptureTime-kpTimer,ta_LU,ui_Objectives_LineLen,str_ui_KothTime,PlayerGetColor(kpTimerOwnerPlayer,false),@y);
                              end;
                mc_KeyPoints: draw_text(tar,ui_objectivesx,y,str_objective_KeyPoints  ,ta_LU,ui_Objectives_LineLen,c_white);
                mc_royale   : draw_text(tar,ui_objectivesx,y,str_objective_RoyalBattle,ta_LU,ui_Objectives_LineLen,c_white);
                else          draw_text(tar,ui_objectivesx,y,str_objective_Scirmish   ,ta_LU,ui_Objectives_LineLen,c_white);
                end;
   end;

   //ui_MouseHintL
   ui_MouseHintN:=0;
   setlength(ui_MouseHintL,ui_MouseHintN);
   ui_MouseHintW:=0;
   d_MakeHintList;
   if(ui_MouseHintN>0)then
   begin
      if(ui_ControlPanelPos=cpp_bottom)
      then y:=ui_MouseHintY-txt_line_h2*ui_MouseHintN
      else y:=ui_MouseHintY;
      if(ui_ControlPanelPos=cpp_right)
      then x:=ui_MouseHintX+(ui_HintLineLen-ui_MouseHintW)*font_w1
      else x:=ui_MouseHintX;
      for i:=0 to ui_MouseHintN-1 do
        draw_text(tar,x,y+txt_line_h2*i,ui_MouseHintL[i],ta_LU,255,c_white);
   end;

   if(TestMode>0)then draw_text(tar,ui_cam_hw,ui_cam_hh,'TEST MODE '+b2s(TestMode),ta_MU,255,c_white);

   //if(ui_ShowAPM )then draw_text(tar,ui_Apmx,ui_Apmy,'APM: '+_playerAPM[UIPlayer].APM_Str                 ,ta_LU,255,c_white);
   if(vid_ShowFPS)then draw_text(tar,ui_FPSX,ui_FPSY,'FPS: '+c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')',ta_LU,255,c_white);

   if(UIPlayer<=LastPlayer)then
     d_GroupsIcons(tar);
end;

procedure d_UIMouseCursor(tar:pSDL_Surface);   //cursor/brash
begin
   draw_sdlsurface(tar,mouse_x,mouse_y,spr_cursor);
   case m_brush of
   co_empty :;
   co_move,
   co_patrol   : draw_sdlsurface(tar,mouse_x+spr_cursorWh,mouse_y+spr_cursorHh,spr_cursorSubG);
   co_amove,
   co_apatrol  : draw_sdlsurface(tar,mouse_x+spr_cursorWh,mouse_y+spr_cursorHh,spr_cursorSubR);
   else          draw_sdlsurface(tar,mouse_x+spr_cursorWh,mouse_y+spr_cursorHh,spr_cursorSubA);
   end;
end;

procedure d_LayerUI(tar:pSDL_Surface);
var
ux,uy:integer;
PVisPlayer:PTPlayerGameData;
begin
   if(ui_update_timer>0)
   then ui_update_timer-=1
   else ui_update_timer:=ui_update_period1;
   if(ui_umark_t>0)then
   begin
      ui_umark_t-=1;
      if(ui_umark_t=0)then ui_umark_u:=0;
   end;


   if(UIPlayer>LastPlayer)
   then PVisPlayer:=nil
   else PVisPlayer:=@g_gplayers[UIPlayer];

   if(rpls_pstate<rpls_read)then
     d_MapMouse(tar);

   if(ui_update_timer=0)then d_MiniMap(ui_UIPanelTemplate);

   if(ui_update_timer=0)or(ui_update_now)then
   begin
      // update panel template
      if(PVisPlayer<>nil)then
        with PVisPlayer^ do
          if(race>r_random)and(ui_panel_race<>race)then
          begin
             ui_panel_race:=race;
             for ux:=0 to ui_CtrlPanelBW-1 do
             for uy:=ui_CtrlPanelBW+1 to ui_CtrlPanelBL do
               if(ui_ControlPanelPos<2)// left-right
               then draw_sdlsurface(ui_UIPanelTemplate,ux*ui_ButtonW1+1,uy*ui_ButtonW1+1,spr_uipanel_EmptyBTN[race])
               else draw_sdlsurface(ui_UIPanelTemplate,uy*ui_ButtonW1+1,ux*ui_ButtonW1+1,spr_uipanel_EmptyBTN[race]);
          end;

      d_Panel(ui_UIPanel,PVisPlayer);
      ui_update_now:=false;
   end;

   d_UIText(tar);
   if(mouse_select_xs0<>NOTSET)then
     rectangleColor(tar,mouse_select_xs0-ui_cam_x,
                        mouse_select_ys0-ui_cam_y, mouse_x, mouse_y, PlayerGetColor(UIPlayer,false));

   draw_sdlsurface(tar,ui_UIPanelX,ui_UIPanelY,ui_UIPanel);

   d_UIMouseCursor(tar);
end;



