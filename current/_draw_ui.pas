
function ui_UpdateUIPlayer(u:integer):boolean;
var tu:PTUnit;
function TryUpd(pplayer:pbyte):boolean;
begin
   TryUpd:=false;
   if(IsUnitRange(u,@tu))then
   begin
      pplayer^:=tu^.playeri;
      TryUpd  :=true;
   end;
end;
begin
   ui_UpdateUIPlayer:=false;
   if(not g_gplayers[LocalPlayer].isobserver)and(not Game_IsEnded)and(rpls_pstate<rpls_read)
   then UIPlayer:=LocalPlayer
   else ui_UpdateUIPlayer:=TryUpd(@UIPlayer);
end;

function ui_AddMarker(ax,ay:integer;av:byte;new:boolean):boolean;
var i,ni,mx,my:integer;
begin
   {
   new  false - not required new alarm point
        true  - required
   return - true if alarm created
   }
   ui_AddMarker:=false;

   ax:=mm3i(1,ax,map_Size1);
   ay:=mm3i(1,ay,map_Size1);

   mx:=trunc(ax*map_MiniMap_cx);
   my:=trunc(ay*map_MiniMap_cx);

   if(not new)then
    for i:=0 to ui_max_alarms do
     with ui_alarms[i] do
      if(al_t>0)and(al_v=av)then
       if(point_dist_rint(al_mx,al_my,mx,my)<=ui_alarm_time)then
       begin
          al_x :=(al_x +ax) div 2;
          al_y :=(al_y +ay) div 2;
          al_mx:=(al_mx+mx) div 2;
          al_my:=(al_my+my) div 2;
          al_t :=ui_alarm_time;
          exit;
       end;

   ni:=0;
   for i:=0 to ui_max_alarms do
    if(ui_alarms[i].al_t<ui_alarms[ni].al_t)
    then ni:=i;

   with ui_alarms[ni] do
    if(al_t<=0)or(not new)then
    begin
       al_x :=ax;
       al_y :=ay;
       al_mx:=mx;
       al_my:=my;
       al_v :=av;
       al_t :=ui_alarm_time;
       case al_v of
aummat_attacked_u,
aummat_attacked_b : al_c:=c_red;
aummat_created_u,
aummat_created_b  : al_c:=c_lime;
aummat_advance    : al_c:=c_aqua;
aummat_upgrade    : al_c:=c_yellow;
aummat_info       : al_c:=c_white;
       end;
       ui_AddMarker:=true;
    end;
end;

function LogMes2UIAlarm:boolean;
begin
   // true  - need announcer sound
   // false - no need announcer sound
   LogMes2UIAlarm:=true;
   if(UIPlayer<=LastPlayer)then
     with g_gplayers[UIPlayer] do
       with log_l[log_i] do
         case lm_type of
lmt_unit_LevelUp    :      ui_AddMarker(lm_x,lm_y,aummat_advance   ,true);
lmt_unit_ready       : if(g_uids[lm_data_u].uid_isbuilding)
                       then ui_AddMarker(lm_x,lm_y,aummat_created_b ,true)
                       else ui_AddMarker(lm_x,lm_y,aummat_created_u ,true);
lmt_upgrade_complete :      ui_AddMarker(lm_x,lm_y,aummat_upgrade   ,true);
lmt_map_mark         :      ui_AddMarker(lm_x,lm_y,aummat_info      ,true);
lmt_allies_attacked,
lmt_unit_attacked    : begin
                       if(g_uids[lm_data_u].uid_isbuilding)
                       then ui_AddMarker(lm_x,lm_y,aummat_attacked_b,false)
                       else ui_AddMarker(lm_x,lm_y,aummat_attacked_u,false);

                       LogMes2UIAlarm:=not PointInCam(lm_x,lm_y);
                       end;
         end;
end;

function ui_PanelBTNUnit(POVPlayer:PTPlayerGameData;uid:byte):boolean;
begin
   ui_PanelBTNUnit:=false;
   if(uid=0)then exit;
   if(POVPlayer<>nil)then
     with POVPlayer^ do
       with g_uids[uid] do
         if (units_uid_e[uid]<=0)
         and(units_ucl_e[uid_isbuilding,uid_uibtn]<=0)
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
function ui_PanelBTNAbility(pu:PTUnit;abilityN:byte):boolean;
begin
   ui_PanelBTNAbility:=false;
   if(pu<>nil)then
     if(unit_ReadyForAbilityOrder(pu))then
       with pu^.uid^ do
         case abilityN of
         1 : ui_PanelBTNAbility:=unit_AbilityCheck(pu,uid_ability1,true)=0;
         2 : ui_PanelBTNAbility:=unit_AbilityCheck(pu,uid_ability2,true)=0;
         3 : ui_PanelBTNAbility:=unit_AbilityCheck(pu,uid_ability3,true)=0;
         end;
end;

procedure draw_UIMinimapAlarms;
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

   map_MiniMap_KeyPoints(ui_minimap,true);

   case map_scenario of
mc_royale   : circleColor(ui_minimap,ui_hwp,ui_hwp,trunc(g_royal_r*map_MiniMap_cx)+1,ui_max_color[ui_mm_ScanBlink]);
   end;
end;

procedure draw_UIMinimap(tar:pSDL_Surface);
var i:byte;
begin
   rectangleColor(ui_minimap,ui_cam_mmx,ui_cam_mmy,ui_cam_mmx+map_MiniMap_CamW,ui_cam_mmy+map_MiniMap_CamH, c_white);

   draw_UIMinimapAlarms;

   // debug
   if(TestMode>1)and(UIPlayer<=LastPlayer)then
    with g_gplayers[UIPlayer] do
     for i:=0 to LastPlayer do
      with aip_alarms[i] do
       if(aia_limit>0)then
        circleColor(ui_minimap,round(aia_x*map_MiniMap_cx),round(aia_y*map_MiniMap_cx),5,c_orange);

   draw_sdlsurface(tar       ,1,1,ui_minimap );
   draw_sdlsurface(ui_minimap,0,0,ui_bminimap);

   ui_mm_ScanBlink:=not ui_mm_ScanBlink;
end;

procedure draw_UIMouseBrush(tar:pSDL_Surface);
var spr: PTMWTexture;
  dunit: TUnit;
 pdunit: PTUnit;
procedure DrawNoBuildAreas(SideStep:integer);
var i:integer;
begin
   // points areas
   for i:=0 to LastKeyPoint do
     with map_KeyPointsL[i] do
       with kp_TeamData[KeyPoint_GetPlayerTeam(UIPlayer)] do
         if(kptd_Active)and(kp_RNoBuild>0)then
           circleColor(tar,
           kp_x-ui_cam_x,
           kp_y-ui_cam_y,
           kp_RNoBuild,c_blue);

   // map build rect
   rectangleColor(tar,
   SideStep-ui_cam_x,
   SideStep-ui_cam_y,
   map_Size1-SideStep-ui_cam_x,
   map_Size1-SideStep-ui_cam_y,
   c_blue);
end;
procedure DrawUIDBrush(uid:byte);
begin
   if(uid=0)then exit;

   spr:=gfx_uid2spr(uid,270,0);
   SDL_SetAlpha(spr^.surf,SDL_SRCALPHA,128);
   draw_sdlsurface(tar,m_brushx-spr^.hw,m_brushy-spr^.hh,spr^.surf);
   SDL_SetAlpha(spr^.surf,SDL_SRCALPHA or SDL_RLEACCEL,255);

   circleColor(tar,m_brushx,m_brushy,g_uids[uid].uid_r,m_brushc);
   if(ui_DrawEdges)then DrawNoBuildAreas(g_uids[uid].uid_r);
end;
begin
   m_brushx-=ui_cam_x;
   m_brushy-=ui_cam_y;

   with g_gplayers[LocalPlayer]do
   case m_brush of
   1..255     : with g_uids[m_brush] do
                begin
                   spr:=gfx_uid2spr(m_brush,270,0);
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
   -255..-1   : if(ui_CommandercPU<>nil)then
                  with g_aids[-m_brush] do //
                    if(ua_mbrush_r>0)
                    then circleColor(tar,mouse_x,mouse_y,ua_mbrush_r,c_aqua)
                    else
                      if(ua_mbrush_r=uambt_sightR)
                      then circleColor(tar,mouse_x,mouse_y,ui_CommandercPU^.srange,c_aqua)
                      else
                        if(ua_mbrush_r=uambt_Blizzard)then
                        begin
                           circleColor(tar,mouse_x,mouse_y,g_mids[MID_Blizzard].mid_base_SplashR,c_aqua);
                           circleColor(tar,mouse_x,mouse_y,g_mids[MID_Blizzard].mid_size        ,c_blue);
                        end
                        else
                          if(ua_mbrush_r<0)
                          then DrawUIDBrush(unit_AbilityGetUIDRef(byte(-m_brush),ui_CommandercPU^.uidi));
   end;

   m_brushx+=ui_cam_x;
   m_brushy+=ui_cam_y;
end;

procedure draw_UIGroupsIcons(tar:pSDL_Surface);
const rown = 6;
var  x,y,y0:integer;
     c,i,n :byte;
     b     :boolean;
begin
   y:=ui_groupY;
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


procedure draw_UIButtonS(tar:pSDL_Surface;bx,by:integer;surf:pSDL_Surface;selected,disabled:boolean);
var ux,uy:integer;
begin
   ui_Panel_ButtonXY(@ux,@uy,nil,nil,bx,by,ui_ButtonW1,ui_ButtonW1);

   draw_sdlsurface(tar,ux+1,uy+1,surf);

   if(selected)
   then draw_rectw(tar,ux,uy,ux+ui_ButtonW1,uy+ui_ButtonW1,-2,0,c_lime)
   else
     if(disabled)then boxColor(tar,ux+2,uy+2,ux+ui_ButtonW1-2,uy+ui_ButtonW1-2,c_ablack);
end;

procedure draw_UIButtonT(tar:pSDL_Surface;bx,by:integer;
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


procedure draw_UIButtonSText(tar:pSDL_Surface;bx,by:integer;align:byte;txt:pshortstring;color:cardinal;selected,disabled:boolean);
var ux,uy:integer;
begin
   ui_Panel_ButtonXY(@ux,@uy,nil,nil,bx,by,ui_ButtonW1,ui_ButtonW1);

   case align of
ta_MM: if(ui_ControlPanelPos<2)
       then draw_text(tar,ux+ui_ButtonWh,min2i(uy+ui_ButtonWh,vid_vh-font_w1h),txt^,align,5,color)
       else draw_text(tar,ux+ui_ButtonWh,      uy+ui_ButtonWh                 ,txt^,align,5,color);
ta_LU:      draw_text(tar,ux+font_wh    ,uy+font_wh                           ,txt^,align,5,color);
   end;
   draw_UIButtonS(tar,bx,by,spr_empty,selected,disabled);
end;

procedure draw_UITabButtonS(tar,btn:pSDL_Surface;bi:integer;selected:boolean);
var
bx0,by0,
bx1,by1:integer;
begin
   ui_Panel_ButtonXY(@bx0,@by0,@bx1,@by1,bi,3,ui_TabButtonW,ui_ButtonW1);

   draw_sdlsurface(tar,((bx0+bx1)div 2)-(btn^.w div 2),
                       ((by0+by1)div 2)-(btn^.h div 2),btn);
   if(selected)then draw_rectw(tar,bx0,by0,bx1,by1,-2,0,c_lime);
end;

procedure draw_UITabButtonT(tar:pSDL_Surface;bi,
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

procedure draw_UIPanel(tar:pSDL_Surface;PVisPlayer:PTPlayerGameData);
var
ucl,p,
uid,
ux,uy:integer;
act  :byte;
tstr :shortstring;
begin
   draw_sdlsurface(tar,0,0,ui_UIPanelTemplate);

   for ucl:=0 to 3 do draw_UITabButtonS(tar,spr_uibtn_Tabs[ucl],ucl,ucl=ui_tab);
   if(PVisPlayer<>nil)then
     with PVisPlayer^ do
       for ucl:=0 to 3 do
         case ucl of
         0: draw_UITabButtonT(tar,ucl,ui_bprod_first      ,ui_bprod_all ,units_bld_s[true ],units_bld_e[true ],c_white,c_yellow,c_lime,c_orange);
         1: draw_UITabButtonT(tar,ucl,it2s(ui_uprod_first),prod_unit_Now,units_bld_s[false],units_bld_e[false],c_white,c_yellow,c_lime,c_orange);
         2: draw_UITabButtonT(tar,ucl,it2s(ui_pprod_first),prod_upgr_Now,0                 ,0                 ,c_white,c_yellow,0     ,0       );
         3: draw_UITabButtonT(tar,ucl,0                   ,0            ,0                 ,0                 ,0      ,0       ,0     ,0       );
         end;

   if(iActOn(iAct_InGameMenu ))then draw_UIButtonSText(tar,0,ui_CtrlPanelBL,ta_MM,@str_ui_menu   ,c_white                       ,false,false);
   if(iActOn(iAct_InGamePause))then draw_UIButtonSText(tar,2,ui_CtrlPanelBL,ta_MM,@str_menu_Pause,PlayerGetColor(g_status,false),false,false);

{
draw_UIButtonS(tar,ux,uy,spr_uibtn_mmark  ,false   ,false              );
}
   case ui_tab of
   tab_buildings,
   tab_units,
   tab_upgrades : if(PVisPlayer<>nil)then
                    for p:=0 to ui_ButtonsNum do
                    begin
                       act:=ui_panel_PTabIActs[p];
                       if(act>0)and(iActOn(act))then
                         with PVisPlayer^ do
                         begin
                            ucl:=act-iAct_SProd1;
                            ux:=(p mod 3);
                            uy:=(p div 3)+4;
                            uid:=ui_panel_uids[race,ui_tab,ucl];
                            case ui_tab of
                            tab_buildings: with g_uids[uid] do
                                           begin
                                              draw_UIButtonS(tar,ux,uy,uid_BTNBig.surf,m_brush=uid,not iActEnabled(act));
                                              draw_UIButtonT(tar,ux,uy,
                                              i2s(ui_bprod_ucl_time[uid_uibtn]),i2s(ui_bprod_ucl_count[ucl]),i2s(units_ucl_s[true,ucl]),i2s(units_ucl_e[true,ucl])                            ,ir2s(ui_bucl_reload[ucl]),
                                              ui_cenergy[res_energyl_cur<0]    ,c_dyellow                   ,c_lime                    ,ui_max_color[not player_UIDLimitCheck(PVisPlayer,uid)],c_aqua,ir2s(build_cd));
                                           end;
                            tab_units    : with g_uids[uid] do
                                           begin
                                              draw_UIButtonS(tar,ux,uy,uid_BTNBig.surf,false,not iActEnabled(act));
                                              draw_UIButtonT(tar,ux,uy,
                                              ir2s(ui_uprod_uid_time[uid]) ,i2s(prod_unit_uid[uid]),i2s(units_uid_s[uid]),i2s(units_uid_e[uid])                                 ,i2s(ui_units_inapc[uid]),
                                              ui_cenergy[res_energyl_cur<0],c_dyellow              ,c_lime               ,ui_max_color[not player_UIDLimitCheck(PVisPlayer,uid)],c_purple,'');
                                           end;
                            tab_upgrades : begin
                                              draw_UIButtonS(tar,ux,uy,g_upgrs[uid].upgr_btn.surf,ui_pprod_upg_time[uid]>0,not iActEnabled(act));
                                              draw_UIButtonT(tar,ux,uy,
                                              ir2s(ui_pprod_upg_time[uid]) ,i2s(prod_upgr_upid[uid]),'',b2s(upgrs_cur[uid])                                 ,'',
                                              ui_cenergy[res_energyl_cur<0],c_dyellow               ,0 ,ui_max_color[upgrs_cur[uid]>=g_upgrs[uid].upgr_max] ,0 ,'');
                                           end;
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
                                                      draw_UIButtonS(tar,ux,uy,g_aids[p].ua_btn,-m_brush=p,not iActEnabled(uid));
                                                      if(g_aids[p].ua_reload>0)
                                                      then tstr:=ir2s(ui_CommandercPU^.rld)
                                                      else tstr:='';
                                                      draw_UIButtonT(tar,ux,uy,'','','','',tstr  ,
                                                                               0 ,0 ,0 ,0 ,c_aqua,'');
                                                   end;
                                                end;
                       iAct_Control_UAMove    : draw_UIButtonS(tar,ux,uy,spr_uibtn_Attack    ,false,not iActEnabled(uid));
                       iAct_Control_UAStop    : draw_UIButtonS(tar,ux,uy,spr_uibtn_Stop      ,false,not iActEnabled(uid));
                       iAct_Control_UAPatrol  : draw_UIButtonS(tar,ux,uy,spr_uibtn_APatrol   ,false,not iActEnabled(uid));
                       iAct_Control_UMove     : draw_UIButtonS(tar,ux,uy,spr_uibtn_Move      ,false,not iActEnabled(uid));
                       iAct_Control_UStop     : draw_UIButtonS(tar,ux,uy,spr_uibtn_Hold      ,false,not iActEnabled(uid));
                       iAct_Control_UPatrol   : draw_UIButtonS(tar,ux,uy,spr_uibtn_Patrol    ,false,not iActEnabled(uid));
                       iAct_Control_UProdCncl : draw_UIButtonS(tar,ux,uy,spr_uibtn_ProdCancel,false,not iActEnabled(uid));
                       iAct_Control_UDestroy  : draw_UIButtonS(tar,ux,uy,spr_uibtn_Delete    ,false,not iActEnabled(uid));
                       iAct_Control_USelBase  : draw_UIButtonS(tar,ux,uy,spr_uibtn_F1        ,false,not iActEnabled(uid));
                       iAct_Control_USelArmy  : draw_UIButtonS(tar,ux,uy,spr_uibtn_F2        ,false,not iActEnabled(uid));

                       iAct_Replay_Fog,
                       iAct_Observer_Fog      : draw_UIButtonS(tar,ux,uy,spr_uibtn_ReplayFog ,ui_fog,not iActEnabled(uid));

                       iAct_Replay_PlayerAll,
                       iAct_Observer_PlayerAll: draw_UIButtonSText(tar,ux,uy,ta_MM,@str_all,c_white,UIPlayer>LastPlayer,not iActEnabled(uid));

                       iAct_Observer_Player0..
                       iAct_Observer_Player7  : begin
                                                   p:=uid-iAct_Observer_Player0;
                                                   with g_gplayers[p] do
                                                     draw_UIButtonSText(tar,ux,uy,ta_LU,@name,PlayerGetColor(p,false),UIPlayer=p,not iActEnabled(uid));
                                                end;

                       iAct_Replay_Player0..
                       iAct_Replay_Player7    : begin
                                                   p:=uid-iAct_Replay_Player0;
                                                   with g_gplayers[p] do
                                                     draw_UIButtonSText(tar,ux,uy,ta_LU,@name,PlayerGetColor(p,false),UIPlayer=p,not iActEnabled(uid));
                                                end;
                       iAct_Replay_Log        : draw_UIButtonS(tar,ux,uy,spr_uibtn_ReplayLog  ,rpls_showlog     ,not iActEnabled(uid));
                       iAct_Replay_POV        : draw_UIButtonS(tar,ux,uy,spr_uibtn_ReplayPOV  ,rpls_POVRecorder ,not iActEnabled(uid));
                       iAct_Replay_Fast       : draw_UIButtonS(tar,ux,uy,spr_uibtn_ReplayFast ,sys_uncappedFPS  ,not iActEnabled(uid));
                       iAct_Replay_Pause      : draw_UIButtonS(tar,ux,uy,spr_uibtn_ReplayPause,replay_IsPaused  ,not iActEnabled(uid));
                       iAct_Replay_Back60     : draw_UIButtonS(tar,ux,uy,spr_uibtn_ReplayBack3,false            ,not iActEnabled(uid));
                       iAct_Replay_Back10     : draw_UIButtonS(tar,ux,uy,spr_uibtn_ReplayBack2,false            ,not iActEnabled(uid));
                       iAct_Replay_Back2      : draw_UIButtonS(tar,ux,uy,spr_uibtn_ReplayBack1,false            ,not iActEnabled(uid));
                       iAct_Replay_Forward2   : draw_UIButtonS(tar,ux,uy,spr_uibtn_ReplayForw1,false            ,not iActEnabled(uid));
                       iAct_Replay_Forward10  : draw_UIButtonS(tar,ux,uy,spr_uibtn_ReplayForw2,false            ,not iActEnabled(uid));
                       iAct_Replay_Forward60  : draw_UIButtonS(tar,ux,uy,spr_uibtn_ReplayForw3,false            ,not iActEnabled(uid));
                       end;
                  end;
   end;
end;

procedure draw_UIMouseMap(tar:pSDL_Surface);
var sx,sy,i,r:integer;
begin
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

procedure ui_MakeHintList;
var
tuid,
taid:byte;
s1  :shortstring;
procedure AddLine(pstr:pshortstring);
begin
   str_AddToStrList(@ui_MouseHintL,ui_HintLineLenUnit,false,false,pstr^);
end;
procedure BrushUnitTargetHint;
begin
   if(m_UnitTargetP<>nil)then
     with m_UnitTargetP^ do
     if(hits>0)then
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
          STRADD(@s1,str_doc_MaxHits+li2s(hits),sep_scomma);
          if(playeri=UIPlayer)and(uid_gen_EnergyLevel>0)then
          STRADD(@s1,str_hint_IncEnergyLevel+'('+tc_aqua+'+'+i2s(uid_gen_EnergyLevel)+tc_default+')',sep_scomma);
          AddLine(@s1);
          end;
          s1:=tc_white+'('+tc_default+chr(playeri)+name+tc_white+')';
          AddLine(@s1);
       end;
end;
begin
   case m_uifocus of
   mf_map      : case m_brush of
                 co_apatrol,
                 co_patrol : ;
                 1..255    : with g_uids[ m_brush] do AddLine(@uid_str_name);
                 -255..-1  : with g_aids[-m_brush] do
                             begin
                                s1:=str_ui_SelectTarget+'"'+ua_str_name+'"';
                                AddLine(@s1);
                                s1:=tc_docbr;
                                AddLine(@s1);
                                case ua_type of
                                uat_UnitAny,
                                uat_UnitOwn,
                                uat_UnitAlly,
                                uat_UnitEnemy: BrushUnitTargetHint;
                                end;
                             end
                 else BrushUnitTargetHint;
                 end;

   mf_Tabs     : if(0<=m_btnN)and(m_btnN<4)then AddLine(@str_ui_Tab[m_BtnN]);
   mf_CtrlPanel: if(0<=m_btnN)and(m_btnN<=ui_ButtonsNum)then
                   case ui_tab of
                   tab_Buildings,
                   tab_Units,
                   tab_Upgrades : if(UIPlayer<=LastPlayer)then
                                    with g_gplayers[UIPlayer] do
                                    begin
                                       taid:=ui_panel_PTabIActs[m_btnN];
                                       tuid:=ui_panel_uids[race,ui_tab,taid-iAct_SProd1];
                                       if(iActOn(taid))then
                                         case ui_tab of
                                         tab_Buildings,
                                         tab_Units    : with g_uids[tuid] do str_StringListCopy(@uid_HintInGame,@ui_MouseHintL);
                                         tab_Upgrades : with g_upgrs[tuid] do
                                                        begin
                                                           AddLine(@upgr_str_NameHK);
                                                           s1:=str_UpgradeCost(tuid,upgrs_cur[tuid]+1);
                                                           AddLine(@s1);
                                                           AddLine(@upgr_str_Descript);
                                                           AddLine(@upgr_str_Reqs);
                                                        end;
                                         end;
                                    end;
                   tab_Controls : begin
                                     tuid:=ui_panel_CTabIActs[ui_ControlTabType,m_BtnN];
                                     if(iActOn(tuid))then
                                       case tuid of
                                       0                     : ;
                                       iAct_Control_UAbility1,
                                       iAct_Control_UAbility2,
                                       iAct_Control_UAbility3: if(ui_CommandercPU<>nil)then
                                                                 with ui_CommandercPU^  do
                                                                 begin
                                                                    taid:=0;
                                                                    case tuid of
                                                                    iAct_Control_UAbility1: taid:=uid^.uid_ability1;
                                                                    iAct_Control_UAbility2: taid:=uid^.uid_ability2;
                                                                    iAct_Control_UAbility3: taid:=uid^.uid_ability3;
                                                                    end;
                                                                    if(taid>0)then
                                                                      with g_aids[taid] do
                                                                      begin
                                                                         s1:='';
                                                                         case tuid of
                                                                         iAct_Control_UAbility1: s1:=str_AbilityHintName(taid,0);
                                                                         iAct_Control_UAbility2: s1:=str_AbilityHintName(taid,1);
                                                                         iAct_Control_UAbility3: s1:=str_AbilityHintName(taid,2);
                                                                         end;
                                                                         AddLine(@s1);
                                                                         str_StringListCopy(@ua_HintInGame,@ui_MouseHintL,true);
                                                                      end;
                                                                 end;
                                       else                    AddLine(@str_action_hint[tuid]);
                                       end;
                                  end;
                    end;
   mf_MenuPause: case m_btnN of
                 0 : if(iActOn(iAct_InGameMenu ))then AddLine(@str_action_hint[iAct_InGameMenu ]);
                 2 : if(iActOn(iAct_InGamePause))then AddLine(@str_action_hint[iAct_InGamePause]);
                 end;
   end;
end;

procedure draw_ReplayProgress(tar:pSDL_Surface);
var
w : integer;
cx: single;
begin
   cx:=replay_GetProgress;
   w :=round(cx*ui_ReplayBarW);

   boxColor (tar,ui_ReplayBarX,ui_ReplayBarY-ui_ReplayBarH,ui_ReplayBarX+w,ui_ReplayBarY,c_yellow);
   draw_text(tar,ui_ReplayBarX,ui_ReplayBarY,i2s(round(cx*100))+'%',ta_LB,255,c_white);
end;

procedure draw_UILog(tar:pSDL_Surface;x,y:integer;logAlign,POVPlayer,LogLineLen,LogListH:byte;LogSet:TSob);
var i:integer;
begin
   MakeLogListForDraw(POVPlayer,LogLineLen,LogListH,0,LogSet);
   if(ui_log_n>0)then
     for i:=0 to ui_log_n-1 do
       if(ui_log_color[i]>0)then
         draw_text(tar,x,y-txt_line_h2*i,ui_log_lines[i],logAlign,255,ui_log_color[i]);
end;

procedure draw_UIText(tar:pSDL_Surface);
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
     draw_ReplayProgress(tar);

   if(net_status=ns_client)
   then logPov:=LocalPlayer
   else logPov:=UIPlayer;

   // last events and chat
   if(ui_InGameChat>0)or(rpls_showlog)then
   begin
      draw_UILog(tar,ui_logx,ui_logy-txt_line_h3,ta_LB,logPov,ui_log_LineLen,ui_log_ListSize,lmts_menu_chat);
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
        draw_UILog(tar,ui_logx,ui_logy,ta_LB,logPov,ui_log_LineLen,(ui_log_LastTimer div ui_log_TimeLast)+1,lmts_last_events);
     end;

   // resources
   if(UIPlayer<=LastPlayer)then
     with g_gplayers[UIPlayer] do
       if(state<>ps_none)and(not isdefeated)and(not isobserver)then
       begin
          limit:=armylimit+prod_unit_Limit;
          draw_text(tar,ui_EnergyX,ui_EnergyY   ,str_ui_EnergyLevel   +': '+tc_default+i2s(res_energyl_cur           )+tc_white+' / '+tc_aqua  +i2s(res_energyl_max)
                                                                                                                               ,ta_RU,255,ui_cenergy[res_energyl_cur<=0] );
          draw_text(tar,ui_EnergyX,ui_HellPowerY,str_ui_HellPower     +': '+tc_default+i2s(res_HellPower)                           ,ta_RU,255,c_white);
          draw_text(tar,ui_EnergyX,ui_UACLootY  ,str_ui_UACLoot       +': '+tc_default+i2s(res_UACLoot  )                           ,ta_RU,255,c_white);

          draw_text(tar,ui_ArmyX  ,ui_ArmyY0    ,str_ui_LimitArmy     +': '+tc_default+limit2s(limit,MinUnitLimit)+tc_white+' / '+tc_orange+ui_limitstr
                                                                                                                               ,ta_LU,255,ui_limit[limit>=MaxPlayerLimit]);
          draw_text(tar,ui_ArmyX  ,ui_ArmyY1    ,str_ui_LimitUnits    +': '+limit2s(units_bld_l[true ]                ,MinUnitLimit),ta_LU,255,c_white);
          draw_text(tar,ui_ArmyX  ,ui_ArmyY2    ,str_ui_LimitBuildings+': '+limit2s(units_bld_l[false]+prod_unit_Limit,MinUnitLimit),ta_LU,255,c_white);

          draw_UIGroupsIcons(tar);
       end;

   // GAME STATUS VICTORY/DEFEAT/PAUSE/REPLAY END
   if(GameGetStatus(@str,@col,UIPlayer))then draw_text(tar,ui_GameStatusX,ui_GameStatusY,str,ta_MU,255,col);

   // POV PLAYER
   if(rpls_pstate=rpls_read)or(g_gplayers[LocalPlayer].isobserver)then
     if(UIPlayer<=LastPlayer)
     then draw_text(tar,ui_GameStatusX,ui_PovPlayerY,g_gplayers[UIPlayer].name,ta_MU,255,PlayerGetColor(UIPlayer,false))
     else draw_text(tar,ui_GameStatusX,ui_PovPlayerY,str_all                  ,ta_MU,255,c_white                       );

   // TIMER
   draw_timer(tar,ui_timerX,ui_timerY,g_tick,ta_LU,255,str_ui_time,c_white);

   // OBJECTIVES
   y:=ui_objectivesY;
   draw_text(tar,ui_objectivesx,y,str_ui_Objectives,ta_LU,ui_Objectives_LineLen,c_white,@y);
   y+=txt_line_h2;
   case g_type  of
   gt_scirmish: case map_scenario of
                mc_KotH     : begin
                              draw_text(tar,ui_objectivesx,y,str_objective_KotH  ,ta_LU,ui_Objectives_LineLen,c_white,@y);
                              y+=txt_line_h2;
                              with map_KeyPointsL[0] do
                               if(g_tick<keyPoint_KotH_pause)
                               then draw_timer(tar,ui_objectivesx,y,keyPoint_KotH_pause-g_tick,ta_LU,ui_Objectives_LineLen,str_ui_KotHTime_act,c_gray,@y)
                               else
                                 with kp_TeamData[MaxPlayers] do
                                   if(kptd_OwnerPlayer<=LastPlayer)
                                   then draw_text(tar,ui_objectivesx,y,g_gplayers[kptd_OwnerPlayer].name+str_ui_KotHWinner,ta_LU,ui_Objectives_LineLen,PlayerGetColor(kptd_OwnerPlayer,false),@y)
                                   else
                                     if(kptd_Timer<=0)
                                     then draw_text(tar,ui_objectivesx,y,str_ui_KothTime+'---',ta_LU,ui_Objectives_LineLen,c_white,@y)
                                     else
                                       if(ui_blink2_colorb)
                                       then draw_timer(tar,ui_objectivesx,y,kp_CaptureTime-kptd_Timer,ta_LU,ui_Objectives_LineLen,str_ui_KothTime,c_white,@y)
                                       else draw_timer(tar,ui_objectivesx,y,kp_CaptureTime-kptd_Timer,ta_LU,ui_Objectives_LineLen,str_ui_KothTime,PlayerGetColor(kptd_TimerOwnerPlayer,false),@y);
                              end;
                mc_KeyPoints: draw_text(tar,ui_objectivesx,y,str_objective_KeyPoints  ,ta_LU,ui_Objectives_LineLen,c_white);
                mc_royale   : draw_text(tar,ui_objectivesx,y,str_objective_RoyalBattle,ta_LU,ui_Objectives_LineLen,c_white);
                else          draw_text(tar,ui_objectivesx,y,str_objective_Scirmish   ,ta_LU,ui_Objectives_LineLen,c_white);
                end;
   end;

   // MOUSE CURSOR TARGET HINT
   str_StringListClear(@ui_MouseHintL);
   ui_MakeHintList;
   with ui_MouseHintL do
     if(slist_n>0)then
     begin
        if(ui_ControlPanelPos=cpp_bottom)
        then y:=ui_MouseHintY-txt_line_h2*slist_n
        else y:=ui_MouseHintY;
        if(ui_ControlPanelPos=cpp_right)
        then x:=ui_MouseHintX+(ui_HintLineLenUnit-slist_w)*font_w1
        else x:=ui_MouseHintX;
        for i:=0 to slist_n-1 do
          draw_text(tar,x,y+txt_line_h2*i,slist_l[i],ta_LU,255,c_white);
     end;

   if(TestMode>0)then draw_text(tar,ui_cam_hw,ui_cam_hh,'TEST MODE '+b2s(TestMode),ta_MU,255,c_white);

   if(ui_ShowAPM            )then draw_text(tar,ui_APMx,ui_APMy,'APM: '                                              ,ta_LU,255,c_white);
   if(vid_ShowFPS           )then draw_text(tar,ui_FPSx,ui_FPSy,'FPS: '+c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')',ta_LU,255,c_white);

   if(rpls_pstate=rpls_write)then draw_text(tar,ui_RECx,ui_RECy,'*REC',ta_RU,255,c_red);
//
end;

procedure draw_UIMouseCursor(tar:pSDL_Surface);   //cursor/brash
function UIMouseEdgeCursor:boolean;
begin
   UIMouseEdgeCursor:=false;
   if(not ui_MouseScroll)then exit;

   if(mouse_x>ui_vmb_x1)and(mouse_y<ui_vmb_y0)
   then draw_sdlsurface(tar,mouse_x-spr_cursor_movex[2],mouse_y-spr_cursor_movey[2],spr_cursor_move[2])
   else
   if(mouse_x<ui_vmb_x0)and(mouse_y<ui_vmb_y0)
   then draw_sdlsurface(tar,mouse_x-spr_cursor_movex[4],mouse_y-spr_cursor_movey[4],spr_cursor_move[4])
   else
   if(mouse_x<ui_vmb_x0)and(mouse_y>ui_vmb_y1)
   then draw_sdlsurface(tar,mouse_x-spr_cursor_movex[6],mouse_y-spr_cursor_movey[6],spr_cursor_move[6])
   else
   if(mouse_x>ui_vmb_x1)and(mouse_y>ui_vmb_y1)
   then draw_sdlsurface(tar,mouse_x-spr_cursor_movex[8],mouse_y-spr_cursor_movey[8],spr_cursor_move[8])
   else
   if(mouse_x>ui_vmb_x1)
   then draw_sdlsurface(tar,mouse_x-spr_cursor_movex[1],mouse_y-spr_cursor_movey[1],spr_cursor_move[1])
   else
   if(mouse_x<ui_vmb_x0)
   then draw_sdlsurface(tar,mouse_x-spr_cursor_movex[5],mouse_y-spr_cursor_movey[5],spr_cursor_move[5])
   else
   if(mouse_y<ui_vmb_y0)
   then draw_sdlsurface(tar,mouse_x-spr_cursor_movex[3],mouse_y-spr_cursor_movey[3],spr_cursor_move[3])
   else
   if(mouse_y>ui_vmb_y1)
   then draw_sdlsurface(tar,mouse_x-spr_cursor_movex[7],mouse_y-spr_cursor_movey[7],spr_cursor_move[7])
   else exit;
   UIMouseEdgeCursor:=true;
end;
begin
   if(m_DragCamMove)
   then draw_sdlsurface(tar,mouse_x-spr_cursor_movex[0],mouse_y-spr_cursor_movey[0],spr_cursor_move[0])
   else
     if(not UIMouseEdgeCursor)then
       draw_sdlsurface(tar,mouse_x,mouse_y,spr_cursor);

   case m_brush of
   co_empty  :;
   co_move,
   co_patrol : draw_sdlsurface(tar,mouse_x+spr_cursorWh,mouse_y+spr_cursorHh,spr_cursorSubG);
   co_amove,
   co_apatrol: draw_sdlsurface(tar,mouse_x+spr_cursorWh,mouse_y+spr_cursorHh,spr_cursorSubR);
   else        draw_sdlsurface(tar,mouse_x+spr_cursorWh,mouse_y+spr_cursorHh,spr_cursorSubA);
   end;
end;

procedure draw_LayerUI(tar:pSDL_Surface);
var
ux,uy:integer;
PVisPlayer:PTPlayerGameData;
begin
   if(ui_update_mmap>0)
   then ui_update_mmap-=1
   else ui_update_mmap:=ui_update_period1;
   if(ui_umark_t>0)then
   begin
      ui_umark_t-=1;
      if(ui_umark_t=0)then ui_umark_u:=0;
   end;

   if(UIPlayer>LastPlayer)
   then PVisPlayer:=nil
   else PVisPlayer:=@g_gplayers[UIPlayer];

   if(rpls_pstate<rpls_read)then
   begin
      draw_UIMouseBrush(tar);
      draw_UIMouseMap  (tar);
   end;

   if(ui_update_mmap=0)then draw_UIMinimap(ui_UIPanelTemplate);

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

   draw_UIPanel(ui_UIPanel,PVisPlayer);

   draw_UIText(tar);
   if(mouse_select_xs0<>NOTSET)then
     rectangleColor(tar,mouse_select_xs0-ui_cam_x,
                        mouse_select_ys0-ui_cam_y, mouse_x, mouse_y, PlayerGetColor(UIPlayer,false));

   draw_sdlsurface(tar,ui_UIPanelX,ui_UIPanelY,ui_UIPanel);

   draw_UIMouseCursor(tar);
end;



