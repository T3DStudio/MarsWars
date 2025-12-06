

////////////////////////////////////////////////////////////////////////////////
//
//  SpriteList
//

const TVisSprSize =  SizeOf(TVisSpr);

var slatemp : PTVisSpr;

function SpriteListAdd:PTVisSpr;
begin
   SpriteListAdd:=nil;
   if(vid_ScreenSpritesS<vid_MaxScreenSprites)and(MainMenu=false)then
   begin
      vid_ScreenSpritesS+=1;
      SpriteListAdd:=vid_ScreenSpritesL[vid_ScreenSpritesS];
      FillChar(SpriteListAdd^,TVisSprSize,0);
      with vid_ScreenSpritesL[vid_ScreenSpritesS]^ do
      begin
         alpha:=255;
      end;
   end;
end;

procedure SpriteListAddUnit(ax,ay,adepth,ashadowz:integer;ashadowc,aaura:cardinal;aspr:PTMWTexture;aalpha:byte);
begin
   slatemp:=SpriteListAdd;
   if(slatemp<>nil)then
     with slatemp^ do
     begin
        x      := ax-ui_cam_x;
        y      := ay-ui_cam_y;
        depth  := adepth;
        shadowz:= ashadowz;
        shadowc:= ashadowc;
        sprite := aspr;
        aura   := aaura;
        alpha  := aalpha;
     end;
end;
procedure SpriteListAddDoodad(ax,ay,adepth,ashadowz:integer;aspr:PTMWTexture;aalpha:byte;axo,ayo:integer);
begin
   slatemp:=SpriteListAdd;
   if(slatemp<>nil)then
     with slatemp^ do
     begin
        x      := ax-ui_cam_x;
        y      := ay-ui_cam_y;
        depth  := adepth;
        shadowz:= ashadowz;
        shadowc:= c_ablack;
        sprite := aspr;
        alpha  := aalpha;
        xo     := axo;
        yo     := ayo;
     end;
end;
procedure SpriteListAddMarker(ax,ay:integer;aspr:PTMWTexture);
begin
   slatemp:=SpriteListAdd;
   if(slatemp<>nil)then
     with slatemp^ do
     begin
        x      := ax-ui_cam_x;
        y      := ay-ui_cam_y;
        depth  :=  sd_marker;
        shadowz:= shadowz.MinValue;
        sprite := aspr;
        alpha  := 255;
        yo     := -aspr^.hh;
     end;
end;
procedure SpriteListAddEffect(ax,ay,adepth:integer;aaura:cardinal;aspr:PTMWTexture;aalpha:byte);
begin
   if(aspr=nil)
   or(aspr=pspr_dummy)then exit;

   slatemp:=SpriteListAdd;
   if(slatemp<>nil)then
     with slatemp^ do
     begin
        x      := ax-ui_cam_x;
        y      := ay-ui_cam_y;
        depth  := adepth;
        shadowz:= shadowz.MinValue;
        sprite := aspr;
        aura   := aaura;
        alpha  := aalpha;
     end;
end;

procedure SpriteListSort;
var i,u:word;
    dt :PTVisSpr;
begin
   if(vid_ScreenSpritesS>1)then
    for i:=1 to vid_ScreenSpritesS do
     for u:=1 to (vid_ScreenSpritesS-1) do
      if(vid_ScreenSpritesL[u]^.depth<vid_ScreenSpritesL[u+1]^.depth)then
      begin
        dt:=vid_ScreenSpritesL[u];
        vid_ScreenSpritesL[u]:=vid_ScreenSpritesL[u+1];
        vid_ScreenSpritesL[u+1]:=dt;
      end;
end;

procedure D_LayerSpriteList(tar:pSDL_Surface);
var sx,sy:integer;
begin
   SpriteListSort;
   while(vid_ScreenSpritesS>0)do
     with vid_ScreenSpritesL[vid_ScreenSpritesS]^ do
     begin
        vid_ScreenSpritesS-=1;

        x-=-xo+sprite^.hw;
        y-=-yo+sprite^.hh;

        if(shadowz>-fly_hz)then
        begin
           sx:=sprite^.hw;
           sy:=sprite^.h-(sprite^.h shr 3);
           filledellipseColor(tar,x+sx,y+sy+shadowz,sx,sprite^.hh shr 1,shadowc);
        end;
        if(alpha>0)then
          if(alpha=255)
          then draw_sdlsurface(tar,x,y,sprite^.surf)
          else
          begin
             SDL_SetAlpha(sprite^.surf,SDL_SRCALPHA or SDL_RLEACCEL,alpha);
             draw_sdlsurface(tar,x,y,sprite^.surf);
             SDL_SetAlpha(sprite^.surf,SDL_RLEACCEL,255);
          end;

        if(aura>0)then
        begin
           x-=6;
           y-=6;
           sx:=sprite^.hw+6;
           sy:=sprite^.hh+6;
           filledellipseColor(tar,x+sx,y+sy,sx,sy,aura);
        end;
     end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//  UnitsInfo
//

function UnitsInfoNew:boolean;
begin
   UnitsInfoNew:=false;

   if(vid_PrimitivesS>=vid_MaxScreenSprites)then exit;

   FillChar(vid_PrimitivesL[vid_PrimitivesS],SizeOf(TVisPrim),0);
   vid_PrimitivesS+=1;

   UnitsInfoNew:=true;
end;

procedure UnitsInfoAddLine(ax0,ay0,ax1,ay1:integer;acolor:cardinal);
begin
   if(UnitsInfoNew)then
     with vid_PrimitivesL[vid_PrimitivesS-1] do
     begin
        kind :=uinfo_line;
        x0   :=ax0;
        y0   :=ay0;
        x1   :=ax1;
        y1   :=ay1;
        color:=acolor;
     end;
end;
procedure UnitsInfoAddRect(ax0,ay0,ax1,ay1:integer;acolor:cardinal);
begin
   if(UnitsInfoNew)then
     with vid_PrimitivesL[vid_PrimitivesS-1] do
     begin
        kind :=uinfo_rect;
        x0   :=ax0;
        y0   :=ay0;
        x1   :=ax1;
        y1   :=ay1;
        color:=acolor;
     end;
end;
procedure UnitsInfoAddRectText(ax0,ay0,ax1,ay1:integer;acolor:cardinal;slt,slt2,srt,srd,sld:string6);
begin
   if(UnitsInfoNew)then
     with vid_PrimitivesL[vid_PrimitivesS-1] do
     begin
        kind :=uinfo_rect;
        x0   :=ax0;
        y0   :=ay0;
        x1   :=ax1;
        y1   :=ay1;
        color:=acolor;
        text_lt :=slt;
        text_lt2:=slt2;
        text_rt :=srt;
        text_rd :=srd;
        text_ld :=sld;
     end;
end;
procedure UnitsInfoAddBox(ax0,ay0,ax1,ay1:integer;acolor:cardinal);
begin
   if(UnitsInfoNew)then
     with vid_PrimitivesL[vid_PrimitivesS-1] do
     begin
        kind :=uinfo_box;
        x0   :=ax0;
        y0   :=ay0;
        x1   :=ax1;
        y1   :=ay1;
        color:=acolor;
     end;
end;
procedure UnitsInfoAddCircle(ax0,ay0,ar:integer;acolor:cardinal);
begin
   if(UnitsInfoNew)then
     with vid_PrimitivesL[vid_PrimitivesS-1] do
     begin
        kind :=uinfo_circle;
        x0   :=ax0;
        y0   :=ay0;
        x1   :=ar;
        color:=acolor;
     end;
end;
procedure UnitsInfoAddText(ax0,ay0:integer;text:string6;acolor:cardinal);
var tw:integer;
begin
   if(UnitsInfoNew)then
     with vid_PrimitivesL[vid_PrimitivesS-1] do
     begin
        kind   :=uinfo_text;
        x0     :=ax0;
        y0     :=ay0;
        text_lt:=text;
        color  :=acolor;

        tw:=length(text)*font_wh;
        x0:=mm3i(ui_cam_x+tw     ,x0,ui_cam_x+ui_cam_w-tw    );
        y0:=mm3i(ui_cam_y+font_wh,y0,ui_cam_y+ui_cam_h-font_w1);
     end;
end;
procedure UnitsInfoAddUSprite(ax0,ay0:integer;acolor:cardinal;aspr:PTMWTexture;slt,slt2,srt,srd,sld:string6;abcolor:cardinal=0);
begin
   if(UnitsInfoNew)then
     with vid_PrimitivesL[vid_PrimitivesS-1] do
     begin
        kind    :=uinfo_rect;
        x0      :=ax0-aspr^.hw;
        y0      :=ay0-aspr^.hh;
        x1      :=x0+aspr^.w;
        y1      :=y0+aspr^.h;

        if(x0<ui_cam_x)then
        begin
           x0:=ui_cam_x;
           x1:=x0+aspr^.w;
        end;
        if(x1>(ui_cam_x+ui_cam_w))then
        begin
           x1:=(ui_cam_x+ui_cam_w);
           x0:=x1-aspr^.w;
        end;
        if(y0<ui_cam_y)then
        begin
           y0:=ui_cam_y;
           y1:=y0+aspr^.h;
        end;
        if(y1>(ui_cam_y+ui_cam_h))then
        begin
           y1:=(ui_cam_y+ui_cam_h);
           y0:=y1-aspr^.h;
        end;

        sprite  :=aspr;
        color   :=acolor;
        bcolor  :=abcolor;
        text_lt :=slt;
        text_lt2:=slt2;
        text_rt :=srt;
        text_rd :=srd;
        text_ld :=sld;
     end;
end;
procedure UnitsInfoAddSprite(ax0,ay0:integer;aspr:PTMWTexture);
begin
   if(UnitsInfoNew)then
     with vid_PrimitivesL[vid_PrimitivesS-1] do
     begin
        kind   :=uinfo_sprite;
        x0     :=ax0-aspr^.hw;
        y0     :=ay0-aspr^.hh;
        sprite :=aspr;
     end;
end;

procedure UnitsInfoProgressbar(ax0,ay0,ax1,ay1:integer;per:single;acolor:cardinal);
var v:integer;
begin
   if(per<0)then per:=0;
   if(per>1)then per:=1;
   if(ax0<ui_cam_x)then
   begin
      v:=ax1-ax0;
      ax0:=ui_cam_x;
      ax1:=ax0+v;
   end;
   if(ax1>(ui_cam_x+ui_cam_w))then
   begin
      v:=ax1-ax0;
      ax1:=(ui_cam_x+ui_cam_w);
      ax0:=ax1-v;
   end;
   if(ay0<ui_cam_y)then
   begin
      v:=ay1-ay0;
      ay0:=ui_cam_y;
      ay1:=ay0+v;
   end;
   if(ay1>(ui_cam_y+ui_cam_h))then
   begin
      v:=ay1-ay0;
      ay1:=(ui_cam_y+ui_cam_h);
      ay0:=ay1-v;
   end;

   if(per=0)
   then UnitsInfoAddBox(ax0,ay0,ax1,ay1,c_black)
   else
     if(per=1)
     then UnitsInfoAddBox(ax0,ay0,ax1,ay1,acolor)
     else
     begin
        v:=trunc((ax1-ax0)*per);

        UnitsInfoAddBox(ax0  ,ay0,ax0+v,ay1,acolor );
        UnitsInfoAddBox(ax0+v,ay0,ax1  ,ay1,c_black);
     end;
end;

procedure UnitsInfoAddBuff(ax,ay:integer;pspr:PTMWTexture);
begin
   ay-=pspr^.hh;
   UnitsInfoAddSprite(ax,ay,pspr);
end;

function i2s6(i:integer;null:boolean):string6;
begin
   if(i>0)
   then i2s6:=i2s(i)
   else
     if(null)
     then i2s6:='0'
     else i2s6:='';
end;

procedure UnitsInfoAddFromUnit(pu:PTUnit;usmodel:PTMWSModel);
const buff_sprite_w = 18;
var
srect,
choosen,
pain,
hbar   : boolean;
 acolor: cardinal;
buffx,
buffy  : integer;
begin
   with pu^   do
   with uid^  do
   with usmodel^ do
   begin
      acolor:=PlayerGetColor(playeri,false);

      choosen:=((m_UnitTargetN=unum)or(ui_umark_u=unum))and(ui_blink1_colorb);

      srect :=((isselected)and(playeri=UIPlayer))
            or(InputAction(iact_Alt))
            or(choosen);

      hbar  :=false;
      if(srect)
      then hbar:=true
      else
        case ui_HealthBars of
        0: if(hits<uid_MaxHits1)then hbar:=true;
        1: hbar:=true;
        end;

      if(srect)then
      begin
         if(playeri=UIPlayer)
         then UnitsInfoAddRectText(vx-sm_SelectionHW,vy-sm_SelectionHH,vx+sm_SelectionHW,vy+sm_SelectionHH,acolor,i2s6(group,false),'',lvlstr_b,i2s6(transportM,false),i2s6(transportC,false))
         else UnitsInfoAddRectText(vx-sm_SelectionHW,vy-sm_SelectionHH,vx+sm_SelectionHW,vy+sm_SelectionHH,acolor,lvlstr_w         ,'',lvlstr_b,lvlstr_a              ,lvlstr_s              );
         UnitsInfoAddText(vx,vy-sm_SelectionHH-font_w1,lvlstr_l,c_white);
      end;
      if(hbar )then UnitsInfoProgressbar(vx-sm_SelectionHW,vy-sm_SelectionHH-4,vx+sm_SelectionHW,vy-sm_SelectionHH,hits/uid_MaxHits1,acolor);

      if(rld>0)and(playeri=UIPlayer)and(iscomplete)then UnitsInfoAddText(vx,vy-sm_SelectionHH+font_w1,lvlstr_r,c_aqua);

      if(speed<=0)or(not iscomplete)then
        if(ui_DrawEdges)then
          UnitsInfoAddCircle(x,y,uid_r,ui_blink2_color_BY);

      if(srect)and(uid_isbuilding)and(ui_UnitNeedDrawRange(pu))then UnitsInfoAddCircle(x,y,srange,ui_blink2_color_BG);

      //ub_Scaned
      case ui_blink3 of
      0: if(buffs[ub_Scaned]>0)then UnitsInfoAddBuff(vx,vy,@spr_effect_Scan );
      1: if(buffs[ub_Decay ]>0)then UnitsInfoAddBuff(vx,vy,@spr_effect_Decay);
      2:;
      end;

      pain:=(buffs[ub_Pain]>0)and(uid_ismech)and(not uid_isbuilding);
      buffx:=0;
      if(buffs[ub_HVision]>0)then buffx+=1;
      if(buffs[ub_Invuln ]>0)then buffx+=1;
      if(pain               )then buffx+=1;

      if(buffx=0)then exit;

      buffx-=1;
      buffx:=vx-((buffx*buff_sprite_w) div 2);

      if(uid_isbuilding)
      then buffy:=vy
      else buffy:=vy-sm_SelectionHH-font_w1;

      if(buffs[ub_HVision]>0)then begin UnitsInfoAddBuff(buffx,buffy,@spr_effect_HVision);buffx+=buff_sprite_w;end;
      if(buffs[ub_Invuln ]>0)then begin UnitsInfoAddBuff(buffx,buffy,@spr_effect_Invuln );buffx+=buff_sprite_w;end;
      if(pain               )then begin UnitsInfoAddBuff(buffx,buffy,@spr_stun   );buffx+=buff_sprite_w;end;
   end;
end;

procedure D_LayerUnitsInfo(tar:pSDL_Surface);
var t:integer;
begin
   case map_scenario of
   mc_royale: circleColor(tar,map_hSize-ui_cam_x,map_hSize-ui_cam_y,g_royal_r,ui_max_color[ui_blink1_colorb]);
   end;

   while(vid_PrimitivesS>0)do
     with vid_PrimitivesL[vid_PrimitivesS-1] do
     begin
        vid_PrimitivesS-=1;

        x0-=ui_cam_x;
        y0-=ui_cam_y;
        if(kind=uinfo_rect)
        or(kind=uinfo_box)
        or(kind=uinfo_line)then
        begin
           x1-=ui_cam_x;
           y1-=ui_cam_y;
           if(kind<>uinfo_line)then
           begin
              if(x0>x1)then begin t:=x0;x0:=x1;x1:=t;end;
              if(y0>y1)then begin t:=y0;y0:=y1;y1:=t;end;
           end;
        end;

        if(bcolor>0)then
          boxColor(tar,x0,y0,x1,y1,bcolor);

        if(sprite<>nil)then
          with sprite^ do draw_sdlsurface(tar,x0,y0,surf);

        if(kind=uinfo_sprite)then continue;

        if(color>0)then
          case kind of
uinfo_line   : lineColor     (tar,x0,y0,x1,y1, color);
uinfo_rect   : rectangleColor(tar,x0,y0,x1,y1, color);
uinfo_box    : boxColor      (tar,x0,y0,x1,y1, color);
uinfo_circle : circleColor   (tar,x0,y0,x1,    color);
uinfo_text   : begin
               draw_text(tar,x0,y0,text_lt,ta_MM,255,color);
               continue;
               end;
          else
          end;

        if(length(text_lt )>0)then draw_text(tar,x0+2,y0+1       ,text_lt ,ta_LU,255,c_white);
        if(length(text_lt2)>0)then draw_text(tar,x0+2,y0+font_w1h,text_lt2,ta_LU,255,c_white);
        if(length(text_rt )>0)then draw_text(tar,x1-1,y0+1       ,text_rt ,ta_RU,255,c_white);
        if(length(text_rd )>0)then draw_text(tar,x1-1,y1-1       ,text_rd ,ta_RB,255,c_white);
        if(length(text_ld )>0)then draw_text(tar,x0+2,y1-1       ,text_ld ,ta_LB,255,c_white);
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  Terrain
//

procedure D_LayerTerrain(tar:pSDL_Surface);
var
i,t,s,
ix,iy,
cx,cy,
vx,vy:integer;
spr  :PTMWTexture;
begin
   cx:=-ui_cam_x mod map_ter_w;
   cy:=-ui_cam_y mod map_ter_h;

   if(ui_cam_x<0)then cx-=map_ter_w;
   if(ui_cam_y<0)then cy-=map_ter_w;

   draw_sdlsurface(tar,cx,cy,map_terrain);

   vx:=ui_cam_x-vid_ab;
   vy:=ui_cam_y-vid_ab;

   if(theme_decaln>0)then
     for i:=0 to map_ter_decaln-1 do
       with map_ter_decalL[i] do
       begin
          ix:=decal_x-vx+ui_mwa;
          iy:=decal_y-vy+ui_mha;

          s:=abs(i+(iy div ui_mha)+(ix div ui_mwa)) mod theme_decaln;

          t:=theme_decals[s];
          if(t<0)
          then spr:=@spr_crater[-t]
          else spr:=@theme_spr_decals[t];

          ix:=ix mod ui_mwa;
          iy:=iy mod ui_mha;

          if(ix<0)then ix:=ui_mwa+ix;
          if(iy<0)then iy:=ui_mha+iy;

          ix-=vid_ab;
          iy-=vid_ab;

          with spr^ do draw_sdlsurface(tar,ix-hw,iy-hh,spr^.surf);
       end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//  Key Points
//

procedure keyPoints_AddSprites;
var t,i:integer;
   ddir:single;
ccolor,
scolor:cardinal;
begin
   for t:=0 to LastKeyPoint do
    with g_KeyPoints[t] do
     if(kpCaptureR>0)and(RectInCam(kpx,kpy,kpCaptureR,kpCaptureR,0))then
     begin
        ccolor:=GetKeyPointColor(t,false);
        scolor:=GetKeyPointColor(t,true );

        if(kpEnergy>0)then
        begin
           SpriteListAddEffect(kpx,kpy,sd_tcraters+kpy,scolor,@spr_cp_gen,255);
           for i:=1 to 6 do
           begin
              ddir:=(i*60)*degtorad;
              SpriteListAddEffect(
              kpx+round(kpCaptureR*cos(ddir)),
              kpy+round(kpCaptureR*sin(ddir)),
              sd_fly+kpy,0,@spr_cp_koth,255);
           end;
        end
        else
          if(t=0)and(map_scenario=mc_KotH)then
          begin
             for i:=1 to 24 do
             begin
                ddir:=(i*15)*degtorad;
                SpriteListAddEffect(
                kpx+round(kpCaptureR*cos(ddir)),
                kpy+round(kpCaptureR*sin(ddir)),
                sd_fly+kpy,scolor,@spr_cp_koth,255);
             end;
          end
          else
          begin
             for i:=1 to 8 do
             begin
                ddir:=(i*45-integer((g_tick shr 2) mod 360))*degtorad;
                SpriteListAddEffect(
                kpx+round(kpCaptureR*cos(ddir)),
                kpy+round(kpCaptureR*sin(ddir)),
                sd_fly+kpy,0,@spr_cp_koth,255);
             end;
             SpriteListAddEffect(kpx,kpy,sd_tcraters+kpy,scolor,@spr_cp_out,255);
          end;

        if(ui_CheckMapPointFogVision(kpx,kpy,true))then
        begin
           if(kpTimer   >0)then UnitsInfoAddText(kpx,kpy+10,ir2s(kpCaptureTime-kpTimer),ccolor );
           if(kplifetime>0)then UnitsInfoAddText(kpx,kpy   ,cr2s(kplifetime           ),c_white);
        end;
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  FOG
//


procedure D_LayerFog(tar:pSDL_Surface);
var
cx,cy,
ssx,ssy,
sty    : integer;
fcell  : pboolean;
temp   : boolean;
begin
   ssx :=-ui_cam_fx-fog_cw;
   sty :=-ui_cam_fy-fog_cw;
   temp:=false;

   for cx:=-1 to ui_fog_gridw-1 do
   begin
      ssy:=sty;
      for cy:=-1 to ui_fog_gridh-1 do
      begin
         if(cx>=0)and(cy>=0)then
         begin
            fcell:=@ui_fog_fgrid[cx,cy];
            ui_fog_pgrid[cx,cy]:=fcell^;
         end
         else fcell:=@temp;

         if(not fcell^)
         or((ui_cam_x+ssx)<0)
         or((ui_cam_y+ssy)<0)
         then draw_sdlsurface(tar,ssx-fog_ds, ssy-fog_ds, ui_fog_surf);

         fcell^:=false;
         ssy+=fog_cw;
      end;
      ssx+=fog_cw;
   end;

   {ssx:=-ui_cam_fx;
   while(ssx<ui_cam_w)do
   begin
      vlineColor(tar,ssx,0,ui_cam_h,c_ltgray);
      ssx+=fog_cw;
   end;
   ssy:=-ui_cam_fy;
   while(ssy<ui_cam_h)do
   begin
      hlineColor(tar,0,ui_cam_w,ssy,c_ltgray);
      ssy+=fog_cw;
   end; }
end;

procedure draw_debug;
var u,ix,iy:integer;
    c:cardinal;
begin
   //draw_text(vid_screen,750,0,i2s(mouse_map_x)+' '+i2s(mouse_map_y) , ta_RU,255, c_white);
   //draw_text(vid_screen,750,0,i2s(spr_tdecsi), ta_RU,255, c_white);

   //draw_text(vid_screen,750,0,b2pm[map_ffly] , ta_RU,255, c_white);

  { with g_gplayers[LocalPlayer] do
   begin
      draw_text(vid_screen,ui_CtrlPanelW,200,i2s(ai_pushtimei) , ta_LU,255, c_white);
      draw_text(vid_screen,ui_CtrlPanelW,210,i2s(ai_pushfrmi ) , ta_LU,255, c_white);
   end;       }

   if(InputAction(iact_Shift))then
     for u:=0 to LastPlayer do
      with g_gplayers[u] do
      begin
         ix:=170+89*u;

         c:=PlayerGetColor(u,false);

         draw_text(vid_screen,ix,80,b2s(units_bld_s[false]), ta_MU,255, c);

         draw_text(vid_screen,ix,90,b2s(units_all_e)+' '+b2s(units_bld_e[false]) , ta_MU,255, c);

         //draw_text(vid_screen,ix,100,b2s(ai_skill)+' '+b2s(ai_maxunits)+' '+b2s(ai_flags) , ta_MU,255, c);
         draw_text(vid_screen,ix,110,b2s(energyl_cur  )+' '+b2s(energyl_max) , ta_MU,255, c);


         for iy:=0 to 8  do draw_text(vid_screen,ix,130+iy*10,b2s(units_ucl_e[true ,iy])+'/'+b2s(units_ucl_c[true ,iy])+' '+b2s(units_ucl_s[true ,iy])+' '+i2s(units_ucl_u[true,iy]), ta_LU,255, c);
         for iy:=0 to 11 do draw_text(vid_screen,ix,230+iy*10,b2s(units_ucl_e[false,iy])+' '+b2s(units_ucl_s [false,iy]), ta_LU,255, c);
      end;

   if(InputAction(iact_Control))then
   for u:=1 to MaxUnits do
    with g_units[u] do
    with player^ do
    with uid^ do
     if(hits>hits_dead)or(u=ai_scout_u_cur)then
     begin
        ix:=x-ui_cam_x;
        iy:=y-ui_cam_y;

        //draw_text(vid_screen,ix,iy,i2s(anim), ta_LU,255, PlayerGetColor(playeri));

        if(hits>0)then
        //if(k_shift>1)then
        begin
           circleColor(vid_screen,ix,iy,uid_r  ,c_gray);
          // circleColor(vid_screen,ix,iy,srange,c_white);
           if(isselected)then
           begin
              //lineColor(vid_screen,ix,iy,ui_mapx+pf_mv_nx-ui_cam_x  ,ui_mapy+pf_mv_ny-ui_cam_y  ,c_red );
              //lineColor(vid_screen,ix,iy,ui_mapx+move_x    -ui_cam_x+1,ui_mapy+move_y    -ui_cam_y+1,c_lime);

              //ix:=(((x-_rx2y_r*ugrid_cellw) div ugrid_cellw)*ugrid_cellw)-ui_cam_x+ui_mapx;
              //iy:=(((y-_rx2y_r*ugrid_cellw) div ugrid_cellw)*ugrid_cellw)-ui_cam_y+ui_mapy;

               //rectangleColor(vid_screen,ix,iy,ix+_rx2y_r*2*ugrid_cellw+ugrid_cellw,iy+_rx2y_r*2*ugrid_cellw+ugrid_cellw,c_red);

              lineColor(vid_screen,ix+1,iy+1,uo_x+ui_cam_x  ,uo_y-ui_cam_y  ,c_white);

              if(aiu_alarm_d<32000)then
              lineColor(vid_screen,ix,iy,aiu_alarm_x+ui_cam_x  ,aiu_alarm_y+ui_cam_y  ,c_red );

           end;

           draw_text(vid_screen,ix,iy   ,i2s(u)     , ta_LU,255, PlayerGetColor(playeri,false));
           draw_text(vid_screen,ix,iy+10,i2s(hits)  , ta_LU,255, PlayerGetColor(playeri,false));
           //draw_text(vid_screen,ix,iy+20,i2s(_unit_SpriteDepth(g_punits[u]) ), ta_LU,255, PlayerGetColor(playeri));
           draw_text(vid_screen,ix,iy+20,b2s(uo_id), ta_LU,255, PlayerGetColor(playeri,false));
          // draw_text(vid_screen,ix,iy+30,b2c[ukfly], ta_LU,255, PlayerGetColor(playeri,false));
           //draw_text(vid_screen,ix,iy+40,li2s(uid_LevelBonusArmor), ta_LU,255, PlayerGetColor(playeri));

//           draw_text(vid_screen,ix,iy+40,i2s(uid_LevelBonusArmor), ta_LU,255, PlayerGetColor(playeri));


           //draw_text(vid_screen,ix,iy+20,b2pm[iscomplete], ta_LU,255, PlayerGetColor(playeri));

        end;

        {if(hits>0)and(transportU=0)then
        if(playeri=LocalPlayer)then
        begin
           if(isbuild)then
           begin
              if(alrm_x>0)then
               lineColor(vid_screen,ix,iy,alrm_x-ui_cam_x,alrm_y-ui_cam_y,c_blue);  //i2s(u)+#13+i2s(tar1)+#13+i2s(uo_id)+#13+i2s(buffs[ub_stop])
           end
           else
           begin
              if(alrm_x>0)then
               lineColor(vid_screen,ix,iy,alrm_x-ui_cam_x,alrm_y-ui_cam_y,c_red);  //i2s(u)+#13+i2s(tar1)+#13+i2s(uo_id)+#13+i2s(buffs[ub_stop])
           end;
           if(uo_x>0)then
            lineColor(vid_screen,ix,iy,uo_x-ui_cam_x,uo_y-ui_cam_y,c_white);
        end;

        draw_text(vid_screen,ix,iy,i2s(alrm_r)+#13+b2pm[alrm_b]+#12+i2s(player^.pnum), ta_LU,255, PlayerGetColor(playeri));}

        if(transportU>0)then continue;

        if(hits>0){and(uidi=UID_URMStation)}then
        begin
           //draw_text(vid_screen,ix,iy,i2s(u)+#13+i2s(tar1)+#13+i2s(uo_id)+#13+i2s(buffs[ub_stop]), ta_LU,255, plcolor[player]);

           //if(tar1>0)then lineColor(vid_screen,ix,iy,g_units[tar1].x-ui_cam_x,g_units[tar1].y-ui_cam_y,c_white);
           //lineColor(vid_screen,ix+10,iy+10,uo_x-ui_cam_x,uo_y-ui_cam_y,c_white);  //and(player=LocalPlayer)
        end;

         //draw_text(vid_screen,imap_mwcx,iy,b2s(painc)+' '+b2s(pains), ta_LU,255, plcolor[player]);
         //if(isselected)then            i2s(TeamVision[g_gplayers[player].team])+#13+i2s(TeamDetection[g_gplayers[player].team])
         //if(alrm_r<=0)then
         //

        {if(hits>0)then                      +' '+i2s(utrain)
         if(k_shift>2)
         then lineColor(vid_screen,ix,iy,uo_x-ui_cam_x,uo_y-ui_cam_y,c_black)
         else
           if(alrm_x<>0)then


        draw_text(vid_screen,ix,iy,i2s(u)+' '+i2s(rld_a), ta_LU,255, plcolor[player]);// }

        //if(isselected)then  circleColor(vid_screen,ix,iy,r+5,plcolor[player]);
     end;

  { for u:=1 to MaxObstacles do
    with map_ObstaclesL[u] do
     if(o_type>0)then
      if(RectInCam(o_x,o_y,o_r,o_r,0))then
      begin
         ix:=o_x-ui_cam_x+ui_mapx;
         iy:=o_y-ui_cam_y+ui_mapy;
         draw_text(vid_screen,ix,iy,i2s(o_x)+' '+i2s(o_y), ta_mm,255, c_white);
      end;   }

   {if(InputAction(iact_Control))then
   for u:=0 to MaxMissiles do
   with g_missiles[u] do
   if(vstep>0)then
   begin
      ix:=vx-ui_cam_x+ui_mapx;
      iy:=vy-ui_cam_y+ui_mapy;

      circleColor(vid_screen,ix,iy,5,c_lime);
      draw_text(vid_screen,ix,iy,i2s(dir), ta_LU,255, c_white);
   end;  }


   {for u:=0 to 255 do
    if(ordx[u]>0)then
    begin
       ix:=ordx[u]-ui_cam_x;
       iy:=ordy[u]-ui_cam_y;

       draw_text(vid_screen,ix,iy,i2s(u), ta_LU,255, c_white);
    end; }
end;


procedure _drawMWSModel(mwsm:PTMWSModel);
var i,x:integer;
begin
   x:=0;
   with mwsm^ do
   begin
      for i:=1 to sm_spritesNum do
       with sm_spritesL[i-1] do
       begin
          draw_sdlsurface(vid_screen,x,0,surf);
          x+=w;
       end;
      draw_text(vid_screen,0,48,i2s(sm_spritesNum), ta_LU,255, c_white);
   end;
end;

