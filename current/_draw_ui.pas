
////////////////////////////////////////////////////////////////////////////////
//
//   base
//

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

////////////////////////////////////////////////////////////////////////////////
//
//   Mini Map
//

procedure d_MinimapAlarms;
var i,r:byte;
begin
   for i:=0 to ui_max_alarms do
    with ui_alarms[i] do
     if(al_t>0)then
     begin
        //r:=(al_t*2) mod vid_uialrm_t;
        r:=(g_step+cardinal(i+al_t)) mod ui_alarm_time;

        draw_set_color(al_c);
        case al_v of
aummat_attacked_b,
aummat_created_b,
aummat_upgrade    : draw_rect  (al_mx-r,al_my-r,al_mx+r,al_my+r);
aummat_advance,
aummat_attacked_u,
aummat_created_u,
aummat_info       : draw_circle(al_mx  ,al_my  ,              r);
        end;

        al_t-=2;
     end;

  { for i:=0 to LastKeyPoint do
    with g_KeyPoints[i] do
     if(cpCaptureR>0)then
      if(cpenergy>0)
      then map_MinimapSpot(cpmx,cpmy,cpmr,char_gen,GetCPColor(i))
      else map_MinimapSpot(cpmx,cpmy,cpmr,char_cp ,GetCPColor(i));  }

   case map_scenario of
ms_royale   : begin
              draw_set_color(ui_color_max[ui_blink2_colorb]);
              draw_circle(ui_hwp,ui_hwp,trunc(g_RoyalBattle_r*map_mm_cx)+1);
              end;
   end;
end;

procedure d_UpdateMinimap;
var i:byte;
begin
   {
   {$IFDEF DTEST}
   if(test_mode>1)then
    if(ui_player<=LastPlayer)then
     with g_players[ui_player] do
      for i:=0 to LastPlayer do
       with ai_alarms[i] do
        if(aia_enemy_limit>0)then
         ;//circleColor(r_gminimap,round(aia_x*map_mm_cx),round(aia_y*map_mm_cx),5,c_orange);
   {$ENDIF}  }

   draw_set_target(tex_ui_MiniMap0);
   draw_set_color(c_white);
   draw_rect(vid_mmvx,vid_mmvy,vid_mmvx+map_mm_CamW,vid_mmvy+map_mm_CamH);
   ui_minimap_scan_blink:=not ui_minimap_scan_blink;
   d_MinimapAlarms;

   draw_set_target(tex_ui_MiniMap1);
   draw_set_color(c_white);
   draw_mwtexture1(1,1,tex_ui_MiniMap0,1,1);
   draw_rect(0,0,ui_panel_pw,ui_panel_pw);

   draw_set_target(tex_ui_MiniMap0);
   draw_set_color(c_white);
   draw_mwtexture1(0,0,tex_map_bMiniMap,1,1);
   draw_set_target(nil);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   Other UI
//

procedure d_UIMouseMapBrush;
var
  spr:PTMWTexture;
mbrush_sx,
mbrush_sy,
      i:integer;
  dunit:TUnit;
 pdunit:PTUnit;
begin
   mbrush_sx:=mbrush_x-vid_cam_x;
   mbrush_sy:=mbrush_y-vid_cam_y;

   with g_players[PlayerClient]do
   case m_brush of
 1.. 255: begin
             with g_uids[m_brush] do
             begin
                spr:=sm_uid2MWTexture(m_brush,270,0);
                draw_set_color(c_white);
                draw_set_alpha(128);
                draw_mwtexture1(mbrush_sx-spr^.hw,mbrush_sy-spr^.hh,spr,1,1);
                draw_set_alpha(255);

                draw_set_color(m_brushc);
                draw_circle(mbrush_sx,mbrush_sy,_r);

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
                if(UIUnitDrawRangeConditionals(pdunit))then
                begin
                   draw_set_color(ui_blink2_color_BG);
                   draw_circle(mbrush_sx,mbrush_sy,dunit.srange);
                end;
             end;
             // points areas
             {for i:=1 to LastKeyPoint do
              with g_KeyPoints[i] do
               if(cpCaptureR>0)and(cpNoBuildR>0)then
                circleColor(tar,
                lx+cpx-vid_cam_x,
                ly+cpy-vid_cam_y,
                cpNoBuildR,c_blue); }
         end;
-255..-1: ;
   {for i:=0 to 255 do
    if(uid_s[i]>0)and(IsIntUnitRange(uid_x[i],nil))then
     with g_uids[i] do
      case _ability of
ua_UACStrike     : if(upgr[upgr_uac_rstrike]>0)then circleColor(tar,mouse_x,mouse_y,blizzard_sr,c_gray);
ua_UACScan       : circleColor(tar,mouse_x,mouse_y,g_units[uid_x[i]].srange,c_gray);
ua_RebuildInPoint: begin
                    spr:=sm_uid2MWTexture(_rebuild_uid,270,0);
                    SDL_SetAlpha(spr^.apidata,SDL_SRCALPHA,128);
                    draw_surf(tar,mbrush_x-spr^.hw,mbrush_y-spr^.hh,spr^.apidata);
                    SDL_SetAlpha(spr^.apidata,SDL_SRCALPHA or SDL_RLEACCEL,255);

                    circleColor(tar,mbrush_x,mbrush_y,g_uids[_rebuild_uid]._r,c_gray);
                    end;
ua_HTowerBlink,
ua_HKeepBlink,
ua_CCFly         : begin
                    spr:=sm_uid2MWTexture(i,270,0);
                    SDL_SetAlpha(spr^.apidata,SDL_SRCALPHA,128);
                    draw_surf(tar,mbrush_x-spr^.hw,mbrush_y-spr^.hh,spr^.apidata);
                    SDL_SetAlpha(spr^.apidata,SDL_SRCALPHA or SDL_RLEACCEL,255);

                    circleColor(tar,mbrush_x,mbrush_y,_r,c_gray);
                    end;
        end; }
   end;
end;

procedure ui_DrawGroupsIcons(tar:pSDL_Surface);
const rown = 6;
var  x,y,y0:integer;
     c,i,n :byte;
     b     :boolean;
begin
   y:=ui_textLUy+ui_oButtonWih;
   //draw_text_line(tar,ui_oicox-4,y+2,str_uiHint_UGroups,ta_RU,255,c_white);
   y+=ui_oButtonW1;
   if(MaxUnitGroups>1)then
   for i:=1 to MaxUnitGroups-1 do
   with ui_groups_d[i] do
   begin
      n  :=0;
      y0 :=-1;
      x  :=ui_oicox;
      for b:=false to true do
      for c:=0 to 255 do
      if(c in ugroup_uids[b])then
      begin
         if(y0=-1)then y0:=y+4;
         if((n mod rown)=0)then
         begin
            if(n>0)then y+=ui_oButtonWisw;
            x:=ui_oicox-ui_oButtonWips;
         end;
        // with g_uids[c] do draw_surf(tar,x,y,un_sbtn.apidata);

         x-=ui_oButtonWisw;
         n+=1;
      end;
      if(y0=-1)then y0:=y+4;
      if(ugroup_n>0)then
      begin
         //draw_text_line(tar,ui_oicox,y0   ,b2s(i)       ,ta_RU,255,c_white );
         //draw_text_line(tar,ui_oicox,y0+10,i2s(ugroup_n),ta_RU,255,c_orange);
      end;
      y+=ui_oButtonWih;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   Control panel
//

procedure ui_pButtonXYPos(x,y,sx,sy:integer;px,py:pinteger;turnBlock:boolean);
begin
   case ui_CBarPos of
uicbp_left,
uicbp_right  : begin
                px^:=(sx+x)*ui_pButtonW1;
                py^:=(sy+y)*ui_pButtonW1;
             end;
uicbp_top,
uicbp_bottom : begin
                if(turnBlock)then
                begin
                   px^:=x*ui_pButtonW1+ui_pButtonW1*ui_panel_bw*(y div ui_panel_bw);
                   py^:=y*ui_pButtonW1-ui_pButtonW1*ui_panel_bw*(y div ui_panel_bw);
                end
                else
                begin
                   px^:=y*ui_pButtonW1;
                   py^:=x*ui_pButtonW1;
                end;
                px^+=sy*ui_pButtonW1;
                py^+=sx*ui_pButtonW1;
             end;
   end;
end;

procedure ui_pButtonIco(ux,uy:integer;pButton:pTMWTexture;selected,disabled:boolean);
var i:integer;
begin
   ui_pButtonXYPos(ux,uy,0,1,@ux,@uy,true);

   draw_set_color(c_white);
   if(not selected)and(disabled)then draw_set_color(c_dgray);
   draw_mwtexture1(ux+ui_pButtonWb,uy+ui_pButtonWb,pButton,1,1);
   if(not selected)and(disabled)then draw_set_color(c_white);

   if(selected)then
   begin
      draw_set_color(c_lime);
      if(ui_pButtonWb>0)then
        for i:=1 to ui_pButtonWb do draw_rect(ux+i,uy+i,ux+ui_pButtonW1-i,uy+ui_pButtonW1-i);
   end;
end;

procedure ui_pButtonTxt(ux,uy:integer;
                        slu1,slu2,sru,srd,sld,smm:shortstring;
                        clu1,clu2,cru,crd,cld,cmm:TMWColor;
                        turnblock:boolean=true);
function cs(ps:pshortstring):boolean;begin cs:=(length(ps^)>0)and(ps^[1]<>'0'); end;
begin
   ui_pButtonXYPos(ux,uy,0,1,@ux,@uy,turnblock);
   if(cs(@slu1))then begin draw_set_color(clu1);draw_text_line(ux+ui_pButtonWb             ,uy+ui_pButtonWb+2           ,slu1,ta_LU,5,c_black);end;
   if(cs(@slu2))then begin draw_set_color(clu2);draw_text_line(ux+ui_pButtonWb             ,uy+ui_pButtonWb+basefont_w1h,slu2,ta_LU,5,c_black);end;
   if(cs(@sru ))then begin draw_set_color(cru );draw_text_line(ux+ui_pButtonW1-ui_pButtonWb,uy+ui_pButtonWb+2           ,sru ,ta_RU,5,c_black);end;
   if(cs(@srd ))then begin draw_set_color(crd );draw_text_line(ux+ui_pButtonW1-ui_pButtonWb,uy+ui_pButtonW1-ui_pButtonWb,srd ,ta_RD,5,c_black);end;
   if(cs(@sld ))then begin draw_set_color(cld );draw_text_line(ux+ui_pButtonWb             ,uy+ui_pButtonW1-ui_pButtonWb,sld ,ta_LD,5,c_black);end;
   if(cs(@smm ))then begin draw_set_color(cmm );draw_text_line(ux+ui_pButtonWh             ,uy+ui_pButtonWh             ,smm ,ta_MM,5,c_black);end;
end;

{procedure d_BTNStr(tar:pSDL_Surface;ux,uy:integer;txt:pshortstring;c:cardinal);
begin
   ui_pButtonXYPos(ux,uy,0,0,@ux,@uy,false);
   //draw_text_line(tar,ux+ui_pButtonWh,uy+ui_pButtonWq,txt^,ta_MU,6,c);
end; }

procedure ui_tButtonIco(ucl:byte;pButton:pTMWTexture;selected,disabled:boolean);
var bx,by,i:integer;
begin
   draw_set_color(c_white);
   case ui_CBarPos of
uicbp_left,
uicbp_right  : begin
                bx:=ucl*ui_tButtonW1;
                by:=0;
                if(not selected)and(disabled)then draw_set_color(c_dgray);
                draw_mwtexture1(bx+ui_tButtonWh-pButton^.hw,
                                by+ui_pButtonWh-pButton^.hh,pButton,1,1);
                if(not selected)and(disabled)then draw_set_color(c_white);
                if(selected)then
                begin
                   draw_set_color(c_lime);
                   if(ui_pButtonWb>0)then
                     for i:=1 to ui_pButtonWb do draw_rect(bx+i,by+i,bx+ui_tButtonW1-i,by+ui_pButtonW1-i);
                end;
             end;
uicbp_top,
uicbp_bottom : begin
                bx:=0;
                by:=ucl*ui_tButtonW1;
                if(not selected)and(disabled)then draw_set_color(c_dgray);
                draw_mwtexture1(bx+ui_pButtonWh-pButton^.hw,
                                by+ui_tButtonWh-pButton^.hh,pButton,1,1);
                if(not selected)and(disabled)then draw_set_color(c_white);
                if(selected)then
                begin
                   draw_set_color(c_lime);
                   if(ui_pButtonWb>0)then
                     for i:=1 to ui_pButtonWb do draw_rect(bx+i,by+i,bx+ui_pButtonW1-i,by+ui_tButtonW1-i);
                end;
             end;
   end;
end;

procedure ui_tButtonStr(ucl:byte;i1,i2,i3,i4:integer;
                                 c1,c2,c3,c4:TMWColor);
var bx,by:integer;
begin
   case ui_CBarPos of
uicbp_left,
uicbp_right  : begin
                bx:=ucl*ui_tButtonW1+4;
                by:=4;
                if(i1>0)then begin draw_set_color(c1);draw_text_line(bx,by,i2s(i1),ta_LU,3,c_black);end;by+=basefont_w1q+1;
                if(i2>0)then begin draw_set_color(c2);draw_text_line(bx,by,i2s(i2),ta_LU,3,c_black);end;by+=basefont_w1q+1;
                if(i3>0)then begin draw_set_color(c3);draw_text_line(bx,by,i2s(i3),ta_LU,3,c_black);end;by+=basefont_w1q+1;
                if(i4>0)then begin draw_set_color(c4);draw_text_line(bx,by,i2s(i4),ta_LU,3,c_black);end;
             end;
uicbp_top,
uicbp_bottom : begin
                bx:=4;
                by:=ucl*ui_tButtonW1+4;
                if(i1>0)then begin draw_set_color(c1);draw_text_line(bx               ,by               ,i2s(i1),ta_LU,255,c_black);end;
                if(i2>0)then begin draw_set_color(c2);draw_text_line(bx               ,by+ui_tButtonW1-6,i2s(i2),ta_LD,255,c_black);end;
                if(i3>0)then begin draw_set_color(c3);draw_text_line(bx+ui_pButtonW1-6,by               ,i2s(i3),ta_RU,255,c_black);end;
                if(i4>0)then begin draw_set_color(c4);draw_text_line(bx+ui_pButtonW1-6,by+ui_tButtonW1-6,i2s(i4),ta_RD,255,c_black);end;
             end;
   end;
end;

procedure d_UpdatePanel;
var
tab       : TTabType;
ucl,
uid,
ux,uy     : integer;
req       : cardinal;
pUIPlayer : PTPlayer;
procedure PlayersButtoms;
var p:byte;
begin
   for p:=0 to LastPlayer do
   begin
      //ui_pButtonTxt  (tar,ux,uy,g_players[p].name,'','','','',PlayerColorNormal[p],0,0,0,0,'');
      //ui_pButtonIco(tar,ux,uy,r_empty,p=POVPlayer,not GetBBit(@g_player_astatus,p));

      ux+=1;
      if(ux>2)then
      begin
         ux:=0;
         uy+=1;
      end;
   end;
   //ui_pButtonTxt  (tar,ux,uy,str_panelHint_all,'','','','',c_white,0,0,0,0,'');
   //ui_pButtonIco(tar,ux,uy,r_empty,LastPlayer<POVPlayer,false);
end;
begin
   ui_PanelUpdNow:=false;

   draw_set_target(tex_ui_ControlBar);

   // panel background
   draw_set_color(c_black);
   draw_frect(0,0,tex_ui_ControlBar^.w,tex_ui_ControlBar^.h);
   draw_set_color(c_white);
   case ui_CBarPos of
uicbp_left,
uicbp_right  : begin
             ux:=ui_tButtonW1;while(ux<ui_panel_pw )do begin draw_vline(ux          ,0           ,ui_pButtonW1);ux+=ui_tButtonW1;end;
             ux:=ui_pButtonW1;while(ux<ui_panel_pw )do begin draw_vline(ux          ,ui_pButtonW1,ui_panel_phi);ux+=ui_pButtonW1;end;
             uy:=0           ;while(uy<ui_panel_phi)do begin draw_hline(0           ,ui_panel_pw ,uy          );uy+=ui_pButtonW1;end;
             draw_vline(0          ,0,ui_panel_phi);
             draw_vline(ui_panel_pw,0,ui_panel_phi);
             draw_hline(0,ui_panel_pw,ui_panel_phi);
          end;
uicbp_top,
uicbp_bottom : begin
             uy:=ui_tButtonW1;while(uy<ui_panel_pw )do begin draw_hline(0           ,ui_pButtonW1,uy          );uy+=ui_tButtonW1;end;
             uy:=ui_pButtonW1;while(uy<ui_panel_pw )do begin draw_hline(ui_pButtonW1,ui_panel_phi,uy          );uy+=ui_pButtonW1;end;
             ux:=0           ;while(ux<ui_panel_phi)do begin draw_vline(ux          ,0           ,ui_panel_pw );ux+=ui_pButtonW1;end;
             draw_hline(0,ui_panel_phi,0          );
             draw_hline(0,ui_panel_phi,ui_panel_pw);
             draw_vline(ui_panel_phi,0,ui_panel_pw);
          end;
   end;

   for tab in TTabType do ui_tButtonIco(ord(tab),spr_tabs[ord(tab)],tab=ui_tab,ui_player>LastPlayer);

   // bottom line buttons
   ui_pButtonTxt(0,ui_panel_bhi,'','','','','',str_panelHint_menu,0,0,0,0,0,c_white,false);
   if(net_status>ns_single)then
   ui_pButtonTxt(2,ui_panel_bhi,'','','','','',str_pause         ,0,0,0,0,0,GetPlayerColor(g_status,c_white),false);

   if(ui_player<=LastPlayer)
   then pUIPlayer:=@g_players[ui_player]
   else pUIPlayer:=nil;

   if(pUIPlayer<>nil)then
   with pUIPlayer^ do
   begin
      // tabs
      ui_tButtonStr(ord(tt_buildings),     ui_bprod_first_time ,ui_bprod_all    ,ucl_cs[true ],ucl_c[true ],c_white,c_yellow,c_lime,c_orange);
      ui_tButtonStr(ord(tt_units    ),it2s(ui_uprod_first_time),ui_uprod_all_now,ucl_cs[false],ucl_c[false],c_white,c_yellow,c_lime,c_orange);
      ui_tButtonStr(ord(tt_upgrades ),it2s(ui_pprod_first_time),ui_pprod_all_now,0            ,0           ,c_white,c_yellow,0     ,0       );
      //ui_tButtonStr(ord(tt_controls ),0                        ,0               ,0            ,0           ,0      ,0       ,0     ,0       );

      // main buttons
      case ui_tab of
tt_buildings: for ucl:=0 to ui_pButtonsCount do  // buildings
              begin
                 uid:=ui_panel_uids[race,ord(ui_tab),ucl];
                 if(uid=0)then continue;

                 with g_uids[uid] do
                 begin
                    if(a_units[uid]<=0)and(uid_e[uid]<=0)and(ucl_e[_ukbuilding,_ucl]<=0)then continue;

                    ux:=ucl mod ui_panel_bw;
                    uy:=ucl div ui_panel_bw;

                    ui_pButtonIco(ux,uy,uid_ui_button,m_brush=uid,
                    (uid_CheckRequirements(pUIPlayer,uid)>0) or not(uid in ui_bprod_possible));
                    ui_pButtonTxt(ux,uy,
                    i2s(ui_bprod_first_ucl[_ucl]),i2s(ui_bprod_ucl_now[ucl]),i2s(ucl_s[true,ucl]),i2s(ucl_e[true,ucl])                       ,ir2s(ui_bucl_reload[ucl]),ir2s(build_cd),
                    ui_color_cenergy[cenergy<0]  ,c_dyellow                 ,c_lime              ,ui_color_max[ucl_e[true,ucl]>=a_units[uid]],c_aqua                   ,c_red         );

                 end;
              end;

tt_units    : for ucl:=0 to ui_pButtonsCount do  // units
              begin
                 uid:=ui_panel_uids[race,ord(ui_tab),ucl];
                 if(uid=0)then continue;

                 with g_uids[uid] do
                 begin
                    if(a_units[uid]<=0)and(uid_e[uid]<=0)and(ucl_e[_ukbuilding,_ucl]<=0)then continue;

                    ux:=ucl mod ui_panel_bw;
                    uy:=ucl div ui_panel_bw;

                    ui_pButtonIco(ux,uy,uid_ui_button,false,  //or (uprod_now_all>=uprod_max)
                    (uid_CheckRequirements(pUIPlayer,uid)>0)  or (ui_uprod_all_now>=ui_uprod_all_max) or(ui_uprod_uid_now[uid]>=ui_uprod_uid_max[uid]) );
                    ui_pButtonTxt(ux,uy,
                    ir2s(ui_uprod_uid_time[uid]),i2s(ui_uprod_uid_now[uid]),i2s(uid_s[uid]),i2s(uid_e[uid])                       ,i2s(ui_units_InTransport[uid]),'',
                    ui_color_cenergy[cenergy<0] ,c_dyellow                 ,c_lime         ,ui_color_max[uid_e[uid]>=a_units[uid]],c_purple                      ,0 );
                 end;
              end;

tt_upgrades : for ucl:=0 to ui_pButtonsCount do  // upgrades
              begin
                 uid:=ui_panel_uids[race,ord(ui_tab),ucl];

                 if(a_upgrs[uid]<=0)then continue;

                 ux:=(ucl mod ui_panel_bw);
                 uy:=(ucl div ui_panel_bw);

                 ui_pButtonIco(ux,uy,g_upids[uid]._up_btn,ui_pprod_pid_time[uid]>0,   //or(pprod_now>=pprod_max)
                 (upid_CheckRequirements(pUIPlayer,uid)>0) or (ui_pprod_all_now>=ui_pprod_all_max) or (ui_pprod_pid_now[uid]>=ui_pprod_pid_max[uid]) );
                 ui_pButtonTxt(ux,uy,
                 ir2s(ui_pprod_pid_time[uid]),i2s(pprod_now_uid[uid]),'',b2s(upgr[uid])                               ,'','',
                 ui_color_cenergy[cenergy<0] ,c_dyellow              ,0 ,ui_color_max[upgr[uid]>=g_upids[uid]._up_max],0 ,0 );
              end;

tt_controls : case tabControlContent of   // actions
              tcp_replay  : begin
                             ui_pButtonIco(0,0,spr_b_rfast,sys_uncappedFPS,false);
                             ui_pButtonIco(1,0,spr_b_rback,false          ,false);
                             ui_pButtonIco(2,0,spr_b_rskip,false          ,false);
                             ui_pButtonIco(0,1,spr_b_rstop,g_status>0     ,false);
                             ui_pButtonIco(1,1,spr_b_rvis ,rpls_POVCam    ,false);
                             ui_pButtonIco(2,1,spr_b_rlog ,rpls_showlog   ,false);
                             ui_pButtonIco(0,2,spr_b_rfog ,ui_fog         ,false);

                            { ux:=2;
                             uy:=2;
                             PlayersButtoms; }
                             end;
              tcp_observer: begin
                             {ui_pButtonIco(tar,0,0,spr_b_rfog ,ui_fog    ,false);

                             ux:=2;
                             uy:=0;
                             PlayersButtoms;}
                             end;
              tcp_controls : begin
                             {// добавить проверку на каждую икноку - имеет ли юнит абилку и может ли ее применять
                             //ui_pButtonIco(tar,0,0,spr_b_action ,false   ,unit_CheckAbility(ui_uibtn_abilityu));
                             //ui_pButtonIco(tar,1,0,spr_b_paction,false   ,ui_uibtn_abilityu=nil);
                             //ui_pButtonIco(tar,2,0,spr_b_rebuild,false   ,ui_uibtn_rebuild <=0 );

                             ui_pButtonIco(tar,0,1,spr_b_attack ,false   ,ui_uibtn_move<=0   );
                             ui_pButtonIco(tar,1,1,spr_b_stop   ,false   ,ui_uibtn_move<=0   );
                             ui_pButtonIco(tar,2,1,spr_b_apatrol,false   ,ui_uibtn_move<=0   );

                             ui_pButtonIco(tar,0,2,spr_b_move   ,false   ,ui_uibtn_move<=0   );
                             ui_pButtonIco(tar,1,2,spr_b_hold   ,false   ,ui_uibtn_move<=0   );
                             ui_pButtonIco(tar,2,2,spr_b_patrol ,false   ,ui_uibtn_move<=0   );

                             ui_pButtonIco(tar,0,3,spr_b_cancel ,false   ,false              );
                             ui_pButtonIco(tar,1,3,spr_tabs[0]  ,false   ,ui_groups_f1.ugroup_n<=0);
                             ui_pButtonIco(tar,2,3,spr_b_selall ,false   ,ui_groups_f2.ugroup_n<=0);

                             ui_pButtonIco(tar,0,4,spr_b_delete ,false   ,(ucl_cs[false]+ucl_cs[true])<=0);
                             ui_pButtonIco(tar,1,4,spr_b_mmark  ,false   ,false              );
                             ui_pButtonIco(tar,2,4,spr_b_rclck  ,m_action,false              );  }
                             end;
              end;
      end;
   end;

   draw_set_target(nil);
end;

procedure d_UIMouseMapClick;
var sx,sy,i,r:integer;
begin
   if(ui_mc_a>0)then //click effect
   begin
      sx:=ui_mc_a;
      sy:=sx shr 1;
      draw_set_color(ui_mc_c);
      draw_ellipse(ui_mc_x-vid_cam_x,ui_mc_y-vid_cam_y,sx,sy);

      ui_mc_a-=1;
   end;

   for i:=0 to ui_max_alarms do
     with ui_alarms[i] do
       if(al_t>0)then
       begin
          case al_v of
aummat_info    : ;
          else continue;
          end;

          sx:=al_x-vid_cam_x;
          sy:=al_y-vid_cam_y;

          r:=(fr_fpsd2-(g_step mod fr_fpsd2))*4;

          draw_set_color(c_white);
          draw_circle(sx,sy,r);
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
   {if(0<=m_panelBtn_x)and(m_panelBtn_x<3)and(3<=m_panelBtn_y)and(m_panelBtn_y<=ui_panel_LastB)then
   begin
      hs1:=nil;
      hs2:=nil;
      hs3:=nil;
      hs4:=nil;
      if(m_panelBtn_y=ui_panel_LastB)then // menu/pause line hints
      begin
         if(m_panelBtn_x=2)then
          if(net_status=ns_single)then exit;
         hs1:=@str_panelHint_Common[m_panelBtn_x];
      end
      else
      case m_panelBtn_y of  // tab hints
      3  : case (ui_CBarPos<2) of
           true :if(mouse_y>ui_panel_pw)then hs1:=@str_panelHint_Tab[(mouse_x-vid_panelx) div ui_tButtonW1];
           false:if(mouse_x>ui_panel_pw)then hs1:=@str_panelHint_Tab[(mouse_y-vid_panely) div ui_tButtonW1];
           end;
      else
        if(ui_CBarPos<2)then
        begin
           bx:= m_panelBtn_x;
           by:= m_panelBtn_y-4;
        end
        else
        begin
           bx:=(m_panelBtn_y-4);
           by:= m_panelBtn_x   ;
           by+=3*(bx div 3);
           bx-=3*(bx div 3);
        end;
        i :=(by*ui_panel_bw)+(bx mod ui_panel_bw);

        if(0<=i)and(i<=ui_pButtonsCount)then
        begin
           if(ui_tab=3)then
           begin
              if(i<=HotKeysArraySize)then
                case tabControlContent of
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
      if(hs1<>nil)then draw_text_line(tar,ui_textLUx,ui_hinty1,hs1^,ta_LU,ui_ingamecl,c_white);
      if(hs2<>nil)then draw_text_line(tar,ui_textLUx,ui_hinty2,hs2^,ta_LU,ui_ingamecl,c_white);
      if(hs3<>nil)then draw_text_line(tar,ui_textLUx,ui_hinty3,hs3^,ta_LU,ui_ingamecl,c_white);
      if(hs4<>nil)then draw_text_line(tar,ui_textLUx,ui_hinty4,hs4^,ta_LU,ui_ingamecl,c_white);
   end
   else
     if(IsIntUnitRange(ui_uhint,@tu))then
       with tu^ do
       with uid^ do
       with player^ do
       begin
          draw_line(tar,ui_textLUx,ui_hinty1,un_txt_uihintS+txt_makeAttributeStr(tu,0),ta_LU,ui_ingamecl,c_white);

          s1:='';
          _ADDSTR(@s1,lvlstr_w,sep_wdash);
          _ADDSTR(@s1,lvlstr_a,sep_wdash);
          _ADDSTR(@s1,lvlstr_s,sep_wdash);
          if(length(s1)>0)then draw_text_line(tar,ui_textLUx,ui_hinty2,str_uhint_UnitLevel+s1,ta_LU,ui_ingamecl,c_white);

          draw_line(tar,ui_textLUx,ui_hinty3,tc_white+'('+tc_default+name+tc_white+')',ta_LU,ui_ingamecl,PlayerColorNormal[pnum]);
     end;}
end;

procedure D_ReplayProgress(tar:pSDL_Surface);
var x,y,
    w:integer;
    cx :single;
begin
   {x:=vid_mapx;
   y:=vid_mapy+vid_cam_h-basefont_w1h;

   cx:=replay_GetProgress;

   w:=round(vid_cam_w*cx);

   boxColor(tar,x,y,x+w,y+basefont_w1h,c_yellow);
   draw_text_line(tar,x,y,rpls_list[rpls_list_sel]+' '+i2s(round(cx*100))+'%',ta_LU,255,c_white);}
end;

procedure D_UIText;
var i,
limit:integer;
  str:shortstring;
  col:cardinal;
function ChatString:shortstring;
begin
   case ui_IngameChat of
chat_all     : ChatString:=str_chat_all;
chat_allies  : ChatString:=str_chat_allies;
0..LastPlayer: ChatString:=g_players[ui_IngameChat].name+':';
   end;
end;
begin
   // replay progress bar
   //if(rpls_rstate=rpls_state_read)then D_ReplayProgress(tar);

   // LOG and HINTs
   {if(ui_LogLastMesTimer>0)then ui_LogLastMesTimer-=1;
   if(ui_IngameChat>0)or(rpls_showlog)then
   begin
      if(net_status=ns_client)
      then MakeLogListForDraw(PlayerClient ,ui_ingamecl,ui_GameLogHeight,lmts_menu_chat)
      else MakeLogListForDraw(ui_player     ,ui_ingamecl,ui_GameLogHeight,lmts_menu_chat);
      if(ui_log_n>0)then
       for i:=0 to ui_log_n-1 do
        if(ui_log_c[i]>0)then draw_line(tar,ui_textLUx,ui_logy-basefont_w1h*i,ui_log_s[i],ta_LU,255,ui_log_c[i]);
      if(ui_IngameChat>0)then draw_line(tar,ui_textLUx,ui_chaty,ChatString+net_chat_str+chat_type[ui_blink1_colorb],ta_LU,ui_ingamecl,c_white);
   end
   else
     if(ui_LogLastMesTimer>0)then // last messages
     begin
        if(net_status=ns_client)
        then MakeLogListForDraw(PlayerClient ,ui_ingamecl,(ui_LogLastMesTimer div log_LastMesTime)+1,lmts_last_messages)
        else MakeLogListForDraw(ui_player     ,ui_ingamecl,(ui_LogLastMesTimer div log_LastMesTime)+1,lmts_last_messages);
        if(ui_log_n>0)then
         for i:=0 to ui_log_n-1 do
          if(ui_log_c[i]>0)then draw_line(tar,ui_textLUx,ui_logy-basefont_w1h*i,ui_log_s[i],ta_LU,255,ui_log_c[i]);
     end;
   d_Hints(tar,POVPlayer);}

   // resources
   {if(POVPlayer<=LastPlayer)then
     with g_players[POVPlayer] do
     begin
        limit:=armylimit+uprodl;
        draw_line(tar,ui_energx,ui_energy,tc_aqua  +str_uiHint_Energy+tc_default+i2s(cenergy           )+tc_white+' / '+tc_aqua  +i2s(menergy),ta_LU,255,ui_color_cenergy[cenergy<=0]);
        draw_line(tar,ui_armyx ,ui_armyy ,tc_orange+str_uiHint_Army  +tc_default+l2s(limit,MinUnitLimit)+tc_white+' / '+tc_orange+ui_limitstr ,ta_LU,255,ui_color_limit[limit>=MaxPlayerLimit]);

        if(ui_armyx<mouse_x)and(mouse_x<=(ui_armyx+140))and(ui_armyy<=mouse_y)and(mouse_y<=(ui_armyy+basefont_w1))then
        begin
        draw_line(tar,ui_armyx,ui_armyy+draw_font_lhq  ,str_attr_building+tc_default+': '+l2s(ucl_l[true ]       ,MinUnitLimit),ta_LU,255,c_white);
        draw_line(tar,ui_armyx,ui_armyy+draw_font_lhq*2,str_attr_unit    +tc_default+': '+l2s(ucl_l[false]+uprodl,MinUnitLimit),ta_LU,255,c_white);
        end;
     end;

   // GAME STATUS
   if(GameGetStatusStrColor(@str,@col,POVPlayer))then draw_line(tar,ui_uiuphx,ui_uiuphy,str,ta_MU,255,col);

   if(POVPlayer<>PlayerClient)or(rpls_rstate>=rpls_state_read)then
     if(POVPlayer<=LastPlayer)
     then draw_line(tar,ui_uiuphx,ui_uiplayery,g_players[POVPlayer].name,ta_MU,255,PlayerColorNormal[POVPlayer])
     else draw_line(tar,ui_uiuphx,ui_uiplayery,str_panelHint_all                  ,ta_MU,255,c_white           );

   // TIMER
   D_Timer(tar,ui_textLUx,ui_textLUy,g_step,ta_LU,str_uiHint_Time,c_white);

   // Game mode specific info
   {case map_scenario of
ms_KotH    : with g_KeyPoints[1] do
              if(g_step<g_step_koth_pause)
              then D_Timer(tar,ui_textLUx,ui_textLUy+basefont_w1h,g_step_koth_pause-g_step,ta_LU,str_uiHint_KotHTimeAct,c_gray)
              else
                if(cpOwnerPlayer<=LastPlayer)
                then draw_line(tar,ui_textLUx,ui_textLUy+basefont_w1h,g_players[cpOwnerPlayer].name+str_uiHint_KotHWinner,ta_LU,255,PlayerColorNormal[cpOwnerPlayer])
                else
                  if(cpTimer<=0)
                  then draw_line(tar,ui_textLUx,ui_textLUy+basefont_w1h,str_uiHint_KotHTime+'---',ta_LU,255,c_white)
                  else
                    if(ui_blink2_colorb)
                    then D_Timer(tar,ui_textLUx,ui_textLUy+basefont_w1h,cpCaptureTime-cpTimer,ta_LU,str_uiHint_KotHTime,c_white)
                    else D_Timer(tar,ui_textLUx,ui_textLUy+basefont_w1h,cpCaptureTime-cpTimer,ta_LU,str_uiHint_KotHTime,PlayerColorNormal[cpTimerOwnerPlayer]);
   end;}

   //if(test_mode>0)then draw_line(tar,vid_mapx+vid_cam_hw,vid_mapy+vid_cam_hh,'TEST MODE '+b2s(test_mode),ta_MU,255,c_white);

   //if(ui_ShowAPM)then draw_line(tar,ui_apmx,ui_apmy,'APM: '+player_APMdata[POVPlayer].APM_Str                ,ta_LU,255,c_white);}

   draw_set_font(font_base,basefont_w1);
   draw_set_color(c_white);

   if(ui_ShowFPS)then draw_text_line(ui_fpsx,ui_fpsy,'FPS: '+c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')',ta_RU,255,c_black);

   //ui_DrawGroupsIcons(tar);
end;

procedure d_UIMouseCursor(tar:pSDL_Surface);   //cursor/brash
var c:cardinal;
begin
   c:=0;
  { case m_brush of
-255..-1    : with g_uability[-m_brush] do c:=ua_mbrush_c;
mb_mark     : c:=c_white;
   else
   end;
   if(c<>0)then
   begin
      circleColor(tar,mouse_x   ,mouse_y,10,           c);
      hlineColor (tar,mouse_x-12,mouse_x+12,mouse_y   ,c);
      vlineColor (tar,mouse_x   ,mouse_y-12,mouse_y+12,c);
   end
   else draw_surf(tar,mouse_x,mouse_y,spr_cursor);  }
end;





