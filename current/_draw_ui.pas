
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

   for i:=0 to LastKeyPoint do
     with g_KeyPoints[i] do
       if(kpCaptureR>0)then
         if(kpEnergy>0)
         then map_minimap_KeyPoint(ui_minimap,kpmmx,kpmmy,kpmmr,char_gen ,GetKeyPointColor(i,false))
         else map_minimap_KeyPoint(ui_minimap,kpmmx,kpmmy,kpmmr,char_koth,GetKeyPointColor(i,false));

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

procedure d_UIMouseBrush(tar:pSDL_Surface;lx,ly:integer);
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
      lx+kpx-ui_cam_x,
      ly+kpy-ui_cam_y,
      kpNoBuildR,c_blue);

   // map build rect
   rectangleColor(tar,
   lx+SideStep-ui_cam_x,ly+SideStep-ui_cam_y,
   lx+map_Size-SideStep-ui_cam_x,ly+map_Size-SideStep-ui_cam_y,
   c_blue);
end;

begin
   m_brushx-=ui_cam_x-lx;
   m_brushy-=ui_cam_y-ly;

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
co_pability: if(ui_uibtn_pabilityu<>nil)then
               with ui_uibtn_pabilityu^.uid^ do
                 case uid_ability of
  uab_UACStrike     : if(ui_bucl_reload[uid_class]=0)then circleColor(tar,mouse_x,mouse_y,blizzard_sr               ,c_gray);
  uab_UACScan       : if(ui_bucl_reload[uid_class]=0)then circleColor(tar,mouse_x,mouse_y,ui_uibtn_pabilityu^.srange,c_gray);
  uab_RebuildInPoint: begin
                      spr:=uid2spr(uid_rebuild_uid,270,0);
                      SDL_SetAlpha(spr^.surf,SDL_SRCALPHA,128);
                      draw_sdlsurface(tar,m_brushx-spr^.hw,m_brushy-spr^.hh,spr^.surf);
                      SDL_SetAlpha(spr^.surf,SDL_SRCALPHA or SDL_RLEACCEL,255);

                      circleColor(tar,m_brushx,m_brushy,g_uids[uid_rebuild_uid].uid_r,c_gray);
                      DrawNoBuildAreas(g_uids[uid_rebuild_uid].uid_r);
                      end;
  uab_HTowerBlink,
  uab_HKeepBlink,
  uab_CCFly         : begin
                      spr:=uid2spr(ui_uibtn_pabilityu^.uidi,270,0);
                      SDL_SetAlpha(spr^.surf,SDL_SRCALPHA,128);
                      draw_sdlsurface(tar,m_brushx-spr^.hw,m_brushy-spr^.hh,spr^.surf);
                      SDL_SetAlpha(spr^.surf,SDL_SRCALPHA or SDL_RLEACCEL,255);

                      circleColor(tar,m_brushx,m_brushy,uid_r,c_gray);
                      DrawNoBuildAreas(uid_r);
                      end;
                 end;
   end;

   m_brushx+=ui_cam_x-lx;
   m_brushy+=ui_cam_y-ly;
end;

procedure d_GroupsIcons(tar:pSDL_Surface);
const rown = 6;
var  x,y,y0:integer;
     c,i,n :byte;
     b     :boolean;
begin
   y:=ui_texty+ui_GroupIcoW1h;
   draw_text(tar,ui_oicox,y,str_ui_UnitGroups,ta_RU,255,c_white);
   y+=ui_GroupIcoW1;
   if(MaxUnitGroups>1)then
     for i:=1 to MaxUnitGroups do
       with ui_group_d[i] do
       begin
          n  :=0;
          y0 :=-1;
          x  :=ui_oicox;
          for b:=false to true do
            for c:=0 to 255 do
              if(c in ugroup_uids[b])then
              begin
                 if(y0=-1)then y0:=y+font_wh;
                 if((n mod rown)=0)then
                 begin
                    if(n>0)then y+=ui_GroupIcoWq3;
                    x:=ui_oicox-ui_GroupIcoW2q3;
                 end;
                 with g_uids[c] do draw_sdlsurface(tar,x,y,uid_BTNSmall.surf);

                 x-=ui_GroupIcoWq3;
                 n+=1;
              end;
          if(y0=-1)then y0:=y+font_wh;
          if(ugroup_n>0)then
          begin
             draw_text(tar,ui_oicox,y0            ,b2s(i)       ,ta_RU,255,c_white );
             draw_text(tar,ui_oicox,y0+txt_line_h1,i2s(ugroup_n),ta_RU,255,c_orange);
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

   if(selected)then draw_rectw(tar,bx0,by0,bx1,by1,-2,0,c_lime);

   draw_sdlsurface(tar,((bx0+bx1)div 2)-(btn^.w div 2),
                       ((by0+by1)div 2)-(btn^.h div 2),btn);
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

function GetRebuildIco(pu:PTUnit):pSDL_Surface;
begin
   GetRebuildIco:=spr_b_rebuild;
   if(pu<>nil)then
     if(pu^.uid^.uid_rebuild_uid>0)then
       GetRebuildIco:=g_uids[pu^.uid^.uid_rebuild_uid].uid_BTNBig.surf;
end;

procedure d_Panel(tar:pSDL_Surface;POVPlayer:byte);
var
ucl,p,
uid,
ux,uy:integer;
req  :cardinal;
PVisPlayer:PTPlayer;
begin
   draw_sdlsurface(tar,0,0,ui_panel);
   for ucl:=0 to 3 do d_TabButtonSprite(tar,spr_tabs[ucl],ucl,ucl=ui_tab);

   d_ButtonSText(tar,0,ui_CtrlPanelBL,ta_MM,@str_ui_menu,c_white,false,false);
   if(GamePauseToggle(true))then
     if(g_status<=LastPlayer)
     then d_ButtonSText(tar,2,ui_CtrlPanelBL,ta_MM,@str_menu_Pause,PlayerGetColor(g_status,false),false,false)
     else d_ButtonSText(tar,2,ui_CtrlPanelBL,ta_MM,@str_menu_Pause,c_white                       ,false,false);

   if(ui_tab=tab_controls)then
     for ucl:=0 to ui_ButtonsNum do
     begin
        ux:=(ucl mod 3);
        uy:=(ucl div 3)+4;
        uid:=ui_panel_CtrlActs[ui_ControlTabType,ucl];
        case uid of
iAct_Control_UAbility1 : if(ui_uibtn_sabilityu<>nil)then
                         begin
                         drawButtonS(tar,ux,uy,spr_b_ab[ui_uibtn_sabilityu^.uid^.uid_ability],false,unit_sability(ui_uibtn_sabilityu,true)>0);
                         drawButtonT(tar,ux,uy,'','','','',ir2s(ui_uibtn_sabilityu^.rld),0 ,0 ,0 ,0 ,c_aqua,'');
                         end;
iAct_Control_UAbility2 : if(ui_uibtn_pabilityu<>nil)then
                         begin
                         if(ui_uibtn_pabilityu^.uid^.uid_ability=uab_RebuildInPoint)
                         then drawButtonS(tar,ux,uy,GetRebuildIco(ui_uibtn_pabilityu),false,unit_pability(ui_uibtn_pabilityu,-1,0,0,true)>0)
                         else drawButtonS(tar,ux,uy,spr_b_ab[ui_uibtn_pabilityu^.uid^.uid_ability],false,unit_pability(ui_uibtn_pabilityu,-1,0,0,true)>0);
                         drawButtonT(tar,ux,uy,'','','','',ir2s(ui_uibtn_pabilityu^.rld),0 ,0 ,0 ,0 ,c_aqua,'');
                         end;
iAct_Control_UAbility3 : if(ui_uibtn_rebuildu<>nil)then
                         drawButtonS(tar,ux,uy,GetRebuildIco(ui_uibtn_rebuildu),false,unit_Rebuild(ui_uibtn_rebuildu,true)>0);
iAct_Control_UAMove    : drawButtonS(tar,ux,uy,spr_b_attack ,false   ,ui_uibtn_move<=0   );
iAct_Control_UAStop    : drawButtonS(tar,ux,uy,spr_b_stop   ,false   ,ui_uibtn_move<=0   );
iAct_Control_UAPatrol  : drawButtonS(tar,ux,uy,spr_b_apatrol,false   ,ui_uibtn_move<=0   );
iAct_Control_UMove     : drawButtonS(tar,ux,uy,spr_b_move   ,false   ,ui_uibtn_move<=0   );
iAct_Control_UStop     : drawButtonS(tar,ux,uy,spr_b_hold   ,false   ,ui_uibtn_move<=0   );
iAct_Control_UPatrol   : drawButtonS(tar,ux,uy,spr_b_patrol ,false   ,ui_uibtn_move<=0   );
iAct_Control_UProdCncl : drawButtonS(tar,ux,uy,spr_b_cancel ,false   ,false              );
iAct_Control_UDestroy  : drawButtonS(tar,ux,uy,spr_b_delete ,false   ,false              );
iAct_Control_USelBase  : drawButtonS(tar,ux,uy,spr_tabs[0]  ,false   ,ui_group_f1.ugroup_n<=0);
iAct_Control_USelArmy  : drawButtonS(tar,ux,uy,spr_b_selall ,false   ,ui_group_f2.ugroup_n<=0);

iAct_Replay_Fog,
iAct_Observer_Fog      : drawButtonS(tar,ux,uy,spr_b_rfog ,ui_fog    ,false);

iAct_Replay_PlayerAll,
iAct_Observer_PlayerAll: d_ButtonSText(tar,ux,uy,ta_MM,@str_all,c_white,UIPlayer>LastPlayer,false);

iAct_Observer_Player0..
iAct_Observer_Player7  : begin
                            p:=uid-iAct_Observer_Player0;
                            with g_gplayers[p] do
                              d_ButtonSText(tar,ux,uy,ta_LU,@name,PlayerGetColor(p,false),UIPlayer=p,defeated);
                         end;

iAct_Replay_Player0..
iAct_Replay_Player7    : begin
                            p:=uid-iAct_Replay_Player0;
                            with g_gplayers[p] do
                              d_ButtonSText(tar,ux,uy,ta_LU,@name,PlayerGetColor(p,false),UIPlayer=p,defeated);
                         end;
iAct_Replay_Log        : drawButtonS(tar,ux,uy,spr_b_rlog  ,rpls_showlog     ,false);
iAct_Replay_POV        : drawButtonS(tar,ux,uy,spr_b_rvis  ,rpls_POVRecorder ,false);
iAct_Replay_Fast       : drawButtonS(tar,ux,uy,spr_b_rfast ,sys_uncappedFPS  ,false);
iAct_Replay_Pause      : drawButtonS(tar,ux,uy,spr_b_rstop ,replay_IsPaused  ,not replay_Pause(true));
iAct_Replay_Back60     : drawButtonS(tar,ux,uy,spr_b_rback3,false            ,false);
iAct_Replay_Back10     : drawButtonS(tar,ux,uy,spr_b_rback2,false            ,false);
iAct_Replay_Back2      : drawButtonS(tar,ux,uy,spr_b_rback1,false            ,false);
iAct_Replay_Forward2   : drawButtonS(tar,ux,uy,spr_b_rforw1,false            ,false);
iAct_Replay_Forward10  : drawButtonS(tar,ux,uy,spr_b_rforw2,false            ,false);
iAct_Replay_Forward60  : drawButtonS(tar,ux,uy,spr_b_rforw3,false            ,false);
        end;
     end;
{
drawButtonS(tar,ux,uy,spr_b_mmark  ,false   ,false              );
}

   if(POVPlayer>LastPlayer)then exit;

   PVisPlayer:=@g_gplayers[POVPlayer];

   with PVisPlayer^ do
   begin
      for ucl:=0 to 3 do
        case ucl of
        0: d_TabButtonText(tar,ucl,ui_bprod_first      ,ui_bprod_all,ucl_cs[true ],ucl_c[true ],c_white,c_yellow,c_lime,c_orange);
        1: d_TabButtonText(tar,ucl,it2s(ui_uprod_first),uproda      ,ucl_cs[false],ucl_c[false],c_white,c_yellow,c_lime,c_orange);
        2: d_TabButtonText(tar,ucl,it2s(ui_pprod_first),upproda     ,0            ,0           ,c_white,c_yellow,0     ,0       );
        3: d_TabButtonText(tar,ucl,0                   ,0           ,0            ,0           ,0      ,0       ,0     ,0       );
        end;

      case ui_tab of
      tab_buildings: for ucl:=0 to ui_ButtonsNum do
                     begin
                        uid:=ui_panel_uids[race ,ui_tab,ucl];
                        if(uid=0)then continue;

                        with g_uids[uid] do
                        begin
                           if(uid_e[uid]<=0)and(ucl_e[uid_ukbuilding,uid_class]<=0)then
                             if(a_units[uid]<=0)then continue;

                           ux:=(ucl mod 3);
                           uy:=(ucl div 3)+4;

                           drawButtonS(tar,ux,uy,uid_BTNBig.surf,m_brush=uid,(CheckUnitReqs(PVisPlayer,uid)>0) or not(uid in ui_bprod_possible));
                           drawButtonT(tar,ux,uy,

                           i2s(ui_bprod_ucl_time[uid_class]),i2s(ui_bprod_ucl_count[ucl]),i2s(ucl_s[true,ucl]),i2s(ucl_e[true,ucl])                       ,ir2s(ui_bucl_reload[ucl]),
                           ui_cenergy[cenergy<0]       ,c_dyellow                   ,c_lime              ,ui_max_color[ucl_e[true,ucl]>=a_units[uid]],c_aqua                   ,ir2s(build_cd));

                           //ui_uid_reload [uid]:=-1;
                           //ui_bucl_reload[ucl]:=-1;
                        end;
                     end;
      tab_units    : for ucl:=0 to ui_ButtonsNum do
                     begin
                        uid:=ui_panel_uids[race ,ui_tab,ucl];
                        if(uid=0)then continue;

                        with g_uids[uid] do
                        begin
                           if(uid_e[uid]<=0)and(ucl_e[uid_ukbuilding,uid_class]<=0)then
                             if(a_units[uid]<=0)then continue;

                           ux:=(ucl mod 3);
                           uy:=(ucl div 3)+4;

                           //(uprodu[uid]>=ui_uprod_uid_max[uid])
                           req:=CheckUnitReqs(PVisPlayer,uid);

                           drawButtonS(tar,ux,uy,uid_BTNBig.surf,false,(req>0) or (uproda>=uprodm) or (ui_uprod_cur>=ui_uprod_max) or(ui_uprod_uid_max[uid]<=0));
                           drawButtonT(tar,ux,uy,
                           ir2s(ui_uprod_uid_time[uid]),i2s(uprodu[uid]),i2s(uid_s[uid]),i2s(   uid_e[uid])                    ,i2s(ui_units_inapc[uid]),
                           ui_cenergy[cenergy<0]       ,c_dyellow       ,c_lime         ,ui_max_color[uid_e[uid]>=a_units[uid]],c_purple                ,'');
                        end;
                     end;
      tab_upgrades : for ucl:=0 to ui_ButtonsNum do
                     begin
                        uid:=ui_panel_uids[race ,ui_tab,ucl];

                        if(a_upgrs[uid]<=0)then continue;

                        ux:=(ucl mod 3);
                        uy:=(ucl div 3)+4;

                        drawButtonS(tar,ux,uy,g_upids[uid].upgr_btn.surf,ui_pprod_time[uid]>0,
                        (CheckUpgradeReqs(PVisPlayer,uid)>0)or(upproda>=upprodm) or (upprodu[uid]>=ui_pprod_max[uid]) );

                        drawButtonT(tar,ux,uy,
                        ir2s(ui_pprod_time[uid]),i2s(upprodu[uid]),'',b2s(   upgr[uid])                            ,'',
                        ui_cenergy[cenergy<0]  ,c_dyellow         ,0 ,ui_max_color[upgr[uid]>=g_upids[uid].upgr_max] ,0 ,'');
                     end;
      end;

   end;
end;

procedure d_MapMouse(tar:pSDL_Surface;lx,ly:integer);
var sx,sy,i,r:integer;
begin
   if(rpls_pstate<rpls_read)then
   begin
      d_UIMouseBrush(tar,lx,ly);

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

           sx:=al_x-ui_cam_x+lx;
           sy:=al_y-ui_cam_y+ly;

           r:=(32-(g_tick mod 32))*4;

           circleColor(tar,sx,sy,r,c_white);
        end;
   end;
end;

procedure d_Hints(tar:pSDL_Surface);
var
 uid :byte;
   s1:shortstring;
  hs1,
  hs2,
  hs3,
  hs4:pshortstring;
begin
   hs1:=nil;
   hs2:=nil;
   hs3:=nil;
   hs4:=nil;
   case m_focus of
   mf_map,
   mf_MiniMap  : if(ui_uibtn_pabilityu<>nil)and(m_brush=co_pability)then
                 begin
                    s1:='';
                    if(ui_uibtn_pabilityu^.uid^.uid_ability>0)
                    then s1:=str_ability_name[ui_uibtn_pabilityu^.uid^.uid_ability];
                    hs1:=@s1;
                 end
                 else
                   if(m_UnitTargetP<>nil)then
                     with m_UnitTargetP^ do
                     with uid^ do
                     with player^ do
                     begin
                        draw_text(tar,ui_textx,ui_hinty1,uid_txt_name+str_UnitAttributes(m_UnitTargetP,0),ta_LU,ui_ingamecl,c_white);

                        s1:='';
                        STRADD(@s1,lvlstr_w,sep_wdash);
                        STRADD(@s1,lvlstr_a,sep_wdash);
                        STRADD(@s1,lvlstr_s,sep_wdash);
                        if(length(s1)>0)then
                        draw_text(tar,ui_textx,ui_hinty2,str_hint_UpgradesLvl+s1+tc_default+', '+str_hint_hits+li2s(hits),ta_LU,ui_ingamecl,c_white);
                        draw_text(tar,ui_textx,ui_hinty3,tc_white+'('+tc_default+name+tc_white+')'                       ,ta_LU,ui_ingamecl,PlayerGetColor(pnum,false));
                     end;
   mf_Tabs     : if(0<=m_btnN)and(m_btnN<4)then hs1:=@str_ui_Tab[m_BtnN];
   mf_CtrlPanel: case m_btnN of
                 0..ui_ButtonsNum: case ui_tab of
                                   tab_Buildings,
                                   tab_Units,
                                   tab_Upgrades : if(UIPlayer<=LastPlayer)then
                                                    with g_gplayers[UIPlayer] do
                                                    begin
                                                       uid:=ui_panel_uids[race,ui_tab,m_BtnN];
                                                       if(uid>0)then
                                                         case ui_tab of
                                                         tab_Buildings,
                                                         tab_Units    : begin
                                                                           with g_uids[uid] do
                                                                             if(uid_e[uid]=0)and(ucl_e[uid_ukbuilding,uid_class]<=0)and(a_units[uid]<=0)then exit;
                                                                           hs1:=@g_uids[uid].uid_txt_NameCostHK;
                                                                           hs2:=@g_uids[uid].uid_txt_FullDescript;
                                                                           hs3:=@g_uids[uid].uid_txt_Weapons;
                                                                           hs4:=@g_uids[uid].uid_txt_Reqs;
                                                                        end;
                                                         tab_Upgrades : begin
                                                                           if(a_upgrs[uid]<=0)then exit;
                                                                           s1:=str_makeUpgrBaseHint(uid,upgr[uid]+1);
                                                                           hs1:=@s1;
                                                                           hs4:=@g_upids[uid].upgr_txt_Hint;
                                                                        end;
                                                         end;
                                                    end;
                                   tab_Controls : begin
                                                     uid:=ui_panel_CtrlActs[ui_ControlTabType,m_BtnN];
                                                     case uid of
                                                     0 :;
                                                     iAct_Control_UAbility1: if(ui_uibtn_sabilityu<>nil)then hs1:=@str_ability_name[ui_uibtn_sabilityu^.uid^.uid_ability];
                                                     iAct_Control_UAbility2: if(ui_uibtn_pabilityu<>nil)then
                                                                               with ui_uibtn_pabilityu^.uid^ do
                                                                                 if(uid_ability=uab_RebuildInPoint)
                                                                                 then hs1:=@g_uids[uid_rebuild_uid].uid_txt_name
                                                                                 else hs1:=@str_ability_name[ui_uibtn_pabilityu^.uid^.uid_ability];
                                                     iAct_Control_UAbility3: if(ui_uibtn_rebuildu <>nil)then
                                                                             begin
                                                                                s1:=strMakeRebuildHint(ui_uibtn_rebuildu^.uidi);
                                                                                hs1:=@s1;
                                                                             end;
                                                     else hs1:=@str_action_hint[uid];
                                                     end;

                                                  end;
                                   end;

                 24            : hs1:=@str_hint_menu;
                 26            : hs1:=@str_hint_pause;
                 end;
   end;
   if(hs1<>nil)then draw_text(tar,ui_textx,ui_hinty1,hs1^,ta_LU,ui_ingamecl,c_white);
   if(hs2<>nil)then draw_text(tar,ui_textx,ui_hinty2,hs2^,ta_LU,ui_ingamecl,c_white);
   if(hs3<>nil)then draw_text(tar,ui_textx,ui_hinty3,hs3^,ta_LU,ui_ingamecl,c_white);
   if(hs4<>nil)then draw_text(tar,ui_textx,ui_hinty4,hs4^,ta_LU,ui_ingamecl,c_white);
end;

procedure D_ReplayProgress(tar:pSDL_Surface);
var x,y,
    w:integer;
    cx :single;
begin
   x:=ui_mapx;
   y:=ui_mapy+ui_cam_h;

   cx:=replay_GetProgress;

   w:=round(ui_cam_w*cx);

   boxColor(tar,x,y-font_w1,x+w,y,c_yellow);
   draw_text(tar,x,y,i2s(round(cx*100))+'%',ta_LB,255,c_white);
end;

procedure D_UIText(tar:pSDL_Surface);
var i,
limit:integer;
  str:shortstring;
  col:cardinal;
function ChatString:shortstring;
begin
   case ingame_chat of
chat_all     : ChatString:=str_ui_ChatAll;
chat_allies  : ChatString:=str_ui_ChatAllies;
1..MaxPlayers: ChatString:=g_gplayers[ingame_chat-1].name+':';
   end;
end;
begin
   // replay progress bar
   if(rpls_pstate=rpls_read)then
     D_ReplayProgress(tar);

   // LOG and HINTs
   if(net_chat_shlm>0)then net_chat_shlm-=1;
   if(ingame_chat>0)or(rpls_showlog)then
   begin
      if(net_status=ns_client)
      then MakeLogListForDraw(LocalPlayer,ui_ingamecl,ui_game_log_height,lmts_menu_chat)
      else MakeLogListForDraw(UIPlayer   ,ui_ingamecl,ui_game_log_height,lmts_menu_chat);
      if(ui_log_n>0)then
        for i:=0 to ui_log_n-1 do
          if(ui_log_color[i]>0)then draw_text(tar,ui_textx,ui_logy-font_w1h*i,ui_log_lines[i],ta_LU,255,ui_log_color[i]);
      if(ingame_chat>0)then draw_text(tar,ui_textx,ui_chaty,ChatString+net_chat_str+chat_type[ui_blink1_colorb],ta_LU,ui_ingamecl,c_white);
   end
   else
     if(net_chat_shlm>0)then // last messages
     begin
        if(net_status=ns_client)
        then MakeLogListForDraw(LocalPlayer,ui_ingamecl,(net_chat_shlm div chat_LastMsgTime)+1,lmts_last_messages)
        else MakeLogListForDraw(UIPlayer   ,ui_ingamecl,(net_chat_shlm div chat_LastMsgTime)+1,lmts_last_messages);
        if(ui_log_n>0)then
          for i:=0 to ui_log_n-1 do
            if(ui_log_color[i]>0)then draw_text(tar,ui_textx,ui_logy-font_w1h*i,ui_log_lines[i],ta_LU,255,ui_log_color[i]);
     end;
   d_Hints(tar);

   // resources
   if(UIPlayer<=LastPlayer)then
     with g_gplayers[UIPlayer] do
       if(not defeated)and(not observer)then
       begin
          limit:=armylimit+uprodl;
          draw_text(tar,ui_energx,ui_energy,tc_aqua  +str_ui_energy+tc_default+i2s(cenergy               )+tc_white+' / '+tc_aqua  +i2s(menergy),ta_LU,255,ui_cenergy[cenergy<=0]);
          draw_text(tar,ui_armyx ,ui_armyy ,tc_orange+str_ui_army  +tc_default+limit2s(limit,MinUnitLimit)+tc_white+' / '+tc_orange+ui_limitstr ,ta_LU,255,ui_limit[limit>=MaxPlayerLimit]);

          if(ui_armyx<mouse_x)and(mouse_x<=(ui_armyx+140))and(ui_armyy<=mouse_y)and(mouse_y<=(ui_armyy+font_w1))then
          begin
          draw_text(tar,ui_armyx,ui_armyy+txt_line_h1  ,str_attr_building+tc_default+': '+limit2s(ucl_l[true ]       ,MinUnitLimit),ta_LU,255,c_white);
          draw_text(tar,ui_armyx,ui_armyy+txt_line_h1*2,str_attr_unit    +tc_default+': '+limit2s(ucl_l[false]+uprodl,MinUnitLimit),ta_LU,255,c_white);
          end;
       end;

   // VICTORY/DEFEAT/PAUSE/REPLAY END
   if(GameGetStatus(@str,@col,UIPlayer))then draw_text(tar,ui_uiuphx,ui_uiuphy,str,ta_MU,255,col);

   if(rpls_pstate>=rpls_read)or(g_gplayers[LocalPlayer].observer)then
     if(UIPlayer<=LastPlayer)
     then draw_text(tar,ui_uiuphx,ui_uiplayery,g_gplayers[UIPlayer].name,ta_MU,255,PlayerGetColor(UIPlayer,false))
     else draw_text(tar,ui_uiuphx,ui_uiplayery,str_all                 ,ta_MU,255,c_white                       );

   // TIMER
   D_Timer(tar,ui_textx,ui_texty,g_tick,ta_LU,str_ui_time,c_white);

   // INVASION
   case map_scenario of
mc_KotH    : with g_KeyPoints[0] do
              if(g_tick<g_step_koth_pause)
              then D_Timer(tar,ui_textx,ui_texty+font_w1h,g_step_koth_pause-g_tick,ta_LU,str_ui_KotHTime_act,c_gray)
              else
                if(kpOwnerPlayer<=LastPlayer)
                then draw_text(tar,ui_textx,ui_texty+font_w1h,g_gplayers[kpOwnerPlayer].name+str_ui_KotHWinner,ta_LU,255,PlayerGetColor(kpOwnerPlayer,false))
                else
                  if(kpTimer<=0)
                  then draw_text(tar,ui_textx,ui_texty+font_w1h,str_ui_KothTime+'---',ta_LU,255,c_white)
                  else
                    if(ui_blink2_colorb)
                    then D_Timer(tar,ui_textx,ui_texty+font_w1h,kpCaptureTime-kpTimer,ta_LU,str_ui_KothTime,c_white)
                    else D_Timer(tar,ui_textx,ui_texty+font_w1h,kpCaptureTime-kpTimer,ta_LU,str_ui_KothTime,PlayerGetColor(kpTimerOwnerPlayer,false));
   end;

   if(TestMode>0)then draw_text(tar,ui_cam_hw,ui_cam_hh,'TEST MODE '+b2s(TestMode),ta_MU,255,c_white);

   //if(ui_ShowAPM )then draw_text(tar,ui_apmx,ui_apmy,'APM: '+_playerAPM[UIPlayer].APM_Str                 ,ta_LU,255,c_white);
   if(vid_ShowFPS)then draw_text(tar,ui_fpsx,ui_fpsy,'FPS: '+c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')',ta_LU,255,c_white);

   if(UIPlayer<=LastPlayer)then
     d_GroupsIcons(tar);
end;

procedure d_UIMouseCursor(tar:pSDL_Surface);   //cursor/brash
var c:cardinal;
begin
   c:=0;
   case m_brush of
co_move,
co_patrol   : c:=c_lime;
co_amove,
co_apatrol  : c:=c_red;
co_pability : c:=c_aqua;
co_mmark    : c:=c_white;
   else draw_sdlsurface(tar,mouse_x,mouse_y,spr_cursor);
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
   d_MapMouse(tar,lx,ly);
   if(ui_update_timer=0)then d_MiniMap(ui_panel);
   if(ui_update_timer=0)or(ui_update_now)then
   begin
      d_Panel(ui_uipanel,UIPlayer);
      ui_update_now:=false;
   end;
   d_UIText(tar);
   if(mouse_select_x0>-1)then rectangleColor(tar,lx+mouse_select_x0-ui_cam_x, ly+mouse_select_y0-ui_cam_y, mouse_x, mouse_y, PlayerGetColor(UIPlayer,false));

   draw_sdlsurface(tar,ui_panelx,ui_panely,ui_uipanel);

   d_UIMouseCursor(tar);
end;



