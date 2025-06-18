

////////////////////////////////////////////////////////////////////////////////
//
//  SpriteList
//

function SpriteListNew:boolean;
begin
   SpriteListNew:=false;

   if(vid_Sprites_n>=vid_MaxScreenSprites)
   or(menu_state)then exit;

   SpriteListNew:=true;

   FillChar(vid_Sprites_l[vid_Sprites_n]^,SizeOf(TVSprite),0);
   vid_Sprites_l[vid_Sprites_n]^.alpha:=255;
   vid_Sprites_n+=1;
end;

procedure SpriteListAddUnit(ax,ay,adepth,ashadowz:integer;ashadowc,aaura:TMWColor;aspr:PTMWTexture;aalpha:byte);
begin
   if(SpriteListNew)then
     with vid_Sprites_l[vid_Sprites_n-1]^ do
     begin
        x           := ax-vid_cam_x;
        y           := ay-vid_cam_y;
        depth       := adepth;
        shadowz     := ashadowz;
        shadow_color:= ashadowc;
        sprite      := aspr;
        aura_color  := aaura;
        alpha       := aalpha;
     end;
end;
procedure SpriteListAddDoodad(ax,ay,adepth,ashadowz:integer;aspr:PTMWTexture;aalpha:byte;axflip:boolean);
begin
   if(SpriteListNew)then
     with vid_Sprites_l[vid_Sprites_n-1]^ do
     begin
        x           := ax-vid_cam_x;
        y           := ay-vid_cam_y;
        depth       := adepth;
        shadowz     := ashadowz;
        shadow_color:= c_black;
        sprite      := aspr;
        alpha       := aalpha;
        xflip       := axflip;
     end;
end;
procedure SpriteListAddMarker(ax,ay:integer;aspr:PTMWTexture);
begin
   if(SpriteListNew)then
     with vid_Sprites_l[vid_Sprites_n-1]^ do
     begin
        x      := ax-vid_cam_x;
        y      := ay-vid_cam_y-aspr^.hh;
        depth  := sd_marker;
        shadowz:= -32000;
        sprite := aspr;
        alpha  := 255;
     end;
end;
procedure SpriteListAddEffect(ax,ay,adepth:integer;aaura:TMWColor;aspr:PTMWTexture;aalpha:byte);
begin
   if(SpriteListNew)then
     with vid_Sprites_l[vid_Sprites_n-1]^ do
     begin
        x         := ax-vid_cam_x;
        y         := ay-vid_cam_y;
        depth     := adepth;
        shadowz   := -32000;
        sprite    := aspr;
        aura_color:= aaura;
        alpha     := aalpha;
     end;
end;

procedure SpriteListSort;
var i,j:word;
    dum:PTVSprite;
begin
   if(vid_Sprites_n>1)then
    for i:=0 to vid_Sprites_n-2 do
     for j:=0 to (vid_Sprites_n-i-2) do
      if(vid_Sprites_l[j]^.depth<vid_Sprites_l[j+1]^.depth)then
      begin
         dum:=vid_Sprites_l[j];
         vid_Sprites_l[j  ]:=vid_Sprites_l[j+1];
         vid_Sprites_l[j+1]:=dum;
      end;
end;

procedure d_SpriteList;
var sx,sy:integer;
begin
   SpriteListSort;
   while(vid_Sprites_n>0)do
   begin
      vid_Sprites_n-=1;
      with vid_Sprites_l[vid_Sprites_n]^ do
      begin
         x+=-sprite^.hw;
         y+=-sprite^.hh;

         if(shadowz>-fly_hz)and(shadow_color>0)then
         begin
            sx:=sprite^.hw;
            sy:=sprite^.h-(sprite^.h shr 3);

            draw_set_color(shadow_color);
            draw_set_alpha(127);
            draw_fellipse(x+sx,y+sy+shadowz,sx,sprite^.hh shr 1);
            draw_set_alpha(255);
         end;
         if(alpha>0)then
         begin
            draw_set_color(c_white);
            if(xflip)then
            begin
               if(alpha=255)
               then draw_mwtexture1(x,y,sprite,-1,1)
               else
               begin
                  draw_set_alpha(alpha);
                  draw_mwtexture1(x,y,sprite,-1,1);
                  draw_set_alpha(255);
               end;
            end
            else
              if(alpha=255)
              then draw_mwtexture1(x,y,sprite,1,1)
              else
              begin
                 draw_set_alpha(alpha);
                 draw_mwtexture1(x,y,sprite,1,1);
                 draw_set_alpha(255);
              end;
         end;

         if(aura_color>0)then
         begin
            x-=6;
            y-=6;
            sx:=sprite^.hw+6;
            sy:=sprite^.hh+6;
            draw_set_color(aura_color);
            draw_set_alpha(127);
            draw_fellipse(x+sx,y+sy+shadowz,sx,sprite^.hh shr 1);
            draw_set_alpha(255);
         end;
      end;
   end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//  UIInfo
//

function UIInfoItemNew:boolean;
begin
   UIInfoItemNew:=false;

   if(vid_UIItem_n>=vid_MaxScreenSprites)
   or(menu_state)then exit;

   UIInfoItemNew:=true;

   FillChar(vid_UIItem_l[vid_UIItem_n],SizeOf(TUIItem),0);
   vid_UIItem_n+=1;
end;

procedure UIInfoItemAddLine(ax0,ay0,ax1,ay1:integer;acolor:TMWColor);
begin
   if(UIInfoItemNew)then
     with vid_UIItem_l[vid_UIItem_n-1] do
     begin
        kind :=uinfo_line;
        x0   :=ax0;
        y0   :=ay0;
        x1   :=ax1;
        y1   :=ay1;
        color:=acolor;
     end;
end;
procedure UIInfoItemAddRect(ax0,ay0,ax1,ay1:integer;acolor:TMWColor);
begin
   if(UIInfoItemNew)then
     with vid_UIItem_l[vid_UIItem_n-1] do
     begin
        kind :=uinfo_rect;
        x0   :=ax0;
        y0   :=ay0;
        x1   :=ax1;
        y1   :=ay1;
        color:=acolor;
     end;
end;
procedure UIInfoItemAddRectText(ax0,ay0,ax1,ay1:integer;acolor:TMWColor;slt,slt2,srt,srd,sld:string6);
begin
   if(UIInfoItemNew)then
     with vid_UIItem_l[vid_UIItem_n-1] do
     begin
        kind    :=uinfo_rect;
        x0      :=ax0;
        y0      :=ay0;
        x1      :=ax1;
        y1      :=ay1;
        color   :=acolor;
        text_lt :=slt;
        text_lt2:=slt2;
        text_rt :=srt;
        text_rd :=srd;
        text_ld :=sld;
     end;
end;
procedure UIInfoItemAddBox(ax0,ay0,ax1,ay1:integer;acolor:TMWColor);
begin
   if(UIInfoItemNew)then
     with vid_UIItem_l[vid_UIItem_n-1] do
     begin
        kind :=uinfo_box;
        x0   :=ax0;
        y0   :=ay0;
        x1   :=ax1;
        y1   :=ay1;
        color:=acolor;
     end;
end;
procedure UIInfoItemAddCircle(ax0,ay0,ar:integer;acolor:TMWColor);
begin
   if(UIInfoItemNew)then
     with vid_UIItem_l[vid_UIItem_n-1] do
     begin
        kind :=uinfo_circle;
        x0   :=ax0;
        y0   :=ay0;
        x1   :=ar;
        color:=acolor;
     end;
end;
procedure UIInfoItemAddText(ax0,ay0:integer;text:string6;acolor:TMWColor);
begin
   if(UIInfoItemNew)then
     with vid_UIItem_l[vid_UIItem_n-1] do
     begin
        kind   :=uinfo_text;
        x0     :=ax0;
        y0     :=ay0;
        text_lt:=text;
        color  :=acolor;
     end;
end;
procedure UIInfoItemAddUSprite(ax0,ay0:integer;acolor:TMWColor;aspr:PTMWTexture;slt,slt2,srt,srd,sld:string6);
begin
   if(aspr=nil)
   or(aspr=ptex_dummy)then exit;

   if(UIInfoItemNew)then
     with vid_UIItem_l[vid_UIItem_n-1] do
     begin
        kind    :=uinfo_rect;
        x0      :=ax0-aspr^.hw;
        y0      :=ay0-aspr^.hh;
        x1      :=x0+aspr^.w;
        y1      :=y0+aspr^.h;

        if(x0<vid_cam_x)then
        begin
           x0:=vid_cam_x;
           x1:=x0+aspr^.w;
        end;
        if(x1>vid_cam_x1)then
        begin
           x1:=vid_cam_x1;
           x0:=x1-aspr^.w;
        end;
        if(y0<vid_cam_y)then
        begin
           y0:=vid_cam_y;
           y1:=y0+aspr^.h;
        end;
        if(y1>vid_cam_y1)then
        begin
           y1:=vid_cam_y1;
           y0:=y1-aspr^.h;
        end;

        sprite  :=aspr;
        color   :=acolor;
        text_lt :=slt;
        text_lt2:=slt2;
        text_rt :=srt;
        text_rd :=srd;
        text_ld :=sld;
     end;
end;
procedure UIInfoItemAddSprite(ax0,ay0:integer;aspr:PTMWTexture);
begin
   if(aspr=nil)
   or(aspr=ptex_dummy)then exit;

   if(UIInfoItemNew)then
     with vid_UIItem_l[vid_UIItem_n-1] do
     begin
        kind   :=uinfo_sprite;
        x0     :=ax0-aspr^.hw;
        y0     :=ay0-aspr^.hh;

        if(x0<vid_cam_x)then
        begin
           x0:=vid_cam_x;
           x1:=x0+aspr^.w;
        end;
        if(x1>vid_cam_x1)then
        begin
           x1:=vid_cam_x1;
           x0:=x1-aspr^.w;
        end;
        if(y0<vid_cam_y)then
        begin
           y0:=vid_cam_y;
           y1:=y0+aspr^.h;
        end;
        if(y1>vid_cam_y1)then
        begin
           y1:=vid_cam_y1;
           y0:=y1-aspr^.h;
        end;

        sprite :=aspr;
     end;
end;

procedure UIInfoItemProgressbar(ax0,ay0,ax1,ay1:integer;per:single;acolor:TMWColor);
var v:integer;
begin
   if(ax0<vid_cam_x)then
   begin
      v:=ax1-ax0;
      ax0:=vid_cam_x;
      ax1:=ax0+v;
   end;
   if(ax1>vid_cam_x1)then
   begin
      v:=ax1-ax0;
      ax1:=vid_cam_x1;
      ax0:=ax1-v;
   end;
   if(ay0<vid_cam_y)then
   begin
      v:=ay1-ay0;
      ay0:=vid_cam_y;
      ay1:=ay0+v;
   end;
   if(ay1>vid_cam_y1)then
   begin
      v:=ay1-ay0;
      ay1:=vid_cam_y1;
      ay0:=ay1-v;
   end;

   if(per<=0)
   then UIInfoItemAddBox(ax0,ay0,ax1,ay1,c_black)
   else
     if(per>=1)
     then UIInfoItemAddBox(ax0,ay0,ax1,ay1,acolor)
     else
     begin
        v:=trunc((ax1-ax0)*per);

        UIInfoItemAddBox(ax0   ,ay0,ax0+v,ay1,acolor );
        UIInfoItemAddBox(ax0+v,ay0,ax1   ,ay1,c_black);
     end;
end;

procedure UIInfoItemAddBuff(ax,ay:integer;pspr:PTMWTexture);
begin
   ay-=pspr^.hh;
   UIInfoItemAddSprite(ax,ay,pspr);
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

procedure UIInfoItemsAddUnit(pu:PTUnit;usmodel:PTMWSModel);
const buff_sprite_w = 18;
var srect,
choosen,
pain,
      hbar :boolean;
    acolor :TMWColor;
   buffx,
   buffy   :integer;
begin
   with pu^   do
   with uid^  do
   with usmodel^ do
   begin
      acolor:=PlayerColorNormal[playeri];

      choosen:=((ui_uhint=unum)or(ui_umark_u=unum))and(vid_blink1_colorb);

      srect :=((isselected)and(playeri=UIPlayer))
            or(InputAction(iAct_alt))
            or(choosen);

      hbar  :=false;
      if(srect)
      then hbar:=true
      else
        case vid_UnitHealthBars of
uhb_damaged : if(hits<_mhits)then hbar:=true;
uhb_always  : hbar:=true;
uhb_selected: ;
        end;

      if(srect)then
      begin
         if(playeri=UIPlayer)
         then UIInfoItemAddRectText(vx-sm_sel_hw,vy-sm_sel_hh,vx+sm_sel_hw,vy+sm_sel_hh,acolor,i2s6(group,false),'',lvlstr_b,i2s6(transportM,false),i2s6(transportC,false))
         else UIInfoItemAddRectText(vx-sm_sel_hw,vy-sm_sel_hh,vx+sm_sel_hw,vy+sm_sel_hh,acolor,lvlstr_w         ,'',lvlstr_b,lvlstr_a        ,lvlstr_s        );
        // UIInfoItemAddText(vx,vy-sm_sel_hh-basefont_w1,lvlstr_l,c_white);
      end;
      if(hbar)then UIInfoItemProgressbar(vx-sm_sel_hw,vy-sm_sel_hh-4,vx+sm_sel_hw,vy-sm_sel_hh,hits/_mhits,acolor);

    //  if(reload>0)and(playeri=UIPlayer)then UIInfoItemAddText(vx,vy-sm_sel_hh+basefont_w1,lvlstr_r,c_aqua);

     { if(speed<=0)or(not iscomplete)then
        case m_brush of
   1..255: UIInfoItemAddCircle(x,y,_r,vid_blink2_color_BY);
        end;   }


     // if(srect)and(_ukbuilding)and(UIUnitDrawRangeConditionals(pu))then UIInfoItemAddCircle(x,y,srange,vid_blink2_color_BG);

      //ub_Scaned
      case vid_blink3 of
      0: if(buff[ub_Scaned]>0)then UIInfoItemAddBuff(vx,vy,@spr_scan );
      1: if(buff[ub_Decay ]>0)then UIInfoItemAddBuff(vx,vy,@spr_decay);
      2:;
      end;

      pain:=(buff[ub_Pain]>0)and(_ukmech and not _ukbuilding);
      buffx:=0;
      if(buff[ub_HVision]>0)then buffx+=1;
      if(buff[ub_Invuln ]>0)then buffx+=1;
      if(pain              )then buffx+=1;

      if(buffx=0)then exit;

      buffx-=1;
      buffx:=vx-((buffx*buff_sprite_w) div 2);

      if(_ukbuilding)
      then buffy:=vy
      else buffy:=vy-sm_sel_hh-basefont_w1;

      if(buff[ub_HVision]>0)then begin UIInfoItemAddBuff(buffx,buffy,@spr_hvision);buffx+=buff_sprite_w;end;
      if(buff[ub_Invuln ]>0)then begin UIInfoItemAddBuff(buffx,buffy,@spr_invuln );buffx+=buff_sprite_w;end;
      if(pain              )then begin UIInfoItemAddBuff(buffx,buffy,@spr_stun   );buffx+=buff_sprite_w;end;
   end;
end;

procedure d_UIInfoItems;
var t:integer;
begin
   case map_scenario of
ms_royale: begin
           draw_set_color(ui_color_max[vid_blink2_colorb]);
           draw_circle(map_phsize-vid_cam_x,map_phsize-vid_cam_y,g_royal_r);
           end;
   end;

   while(vid_UIItem_n>0)do
     with vid_UIItem_l[vid_UIItem_n-1] do
     begin
        vid_UIItem_n-=1;

        x0-=vid_cam_x;
        y0-=vid_cam_y;
        if(kind=uinfo_rect)
        or(kind=uinfo_box)
        or(kind=uinfo_line)then
        begin
           x1-=vid_cam_x;
           y1-=vid_cam_y;
           if(kind<>uinfo_line)then
           begin
              if(x0>x1)then begin t:=x0;x0:=x1;x1:=t;end;
              if(y0>y1)then begin t:=y0;y0:=y1;y1:=t;end;
           end;
        end;

        if(sprite<>nil)then draw_mwtexture1(x0,y0,sprite,1,1);

        if(kind=uinfo_sprite)then continue;

        if(color<>c_none)then
        begin
           draw_set_color(color);
           case kind of
uinfo_line   : draw_line  (x0,y0,x1,y1);
uinfo_rect   : draw_rect  (x0,y0,x1,y1);
uinfo_box    : draw_frect (x0,y0,x1,y1);
uinfo_circle : draw_circle(x0,y0,x1   );
uinfo_text   : begin
               draw_text_line(x0,y0-basefont_wh,text_lt,ta_MU,255,c_black);
               continue;
               end;
           else
           end;
        end;

        draw_set_color(c_white);
        if(length(text_lt )>0)then draw_text_line(x0+1,y0+1            ,text_lt ,ta_LU,255,c_black);
        if(length(text_lt2)>0)then draw_text_line(x0+1,y0+basefont_w1+4,text_lt2,ta_LU,255,c_black);
        if(length(text_rt )>0)then draw_text_line(x1-1,y0+1            ,text_rt ,ta_RU,255,c_black);
        if(length(text_rd )>0)then draw_text_line(x1-1,y1-1-basefont_w1,text_rd ,ta_RU,255,c_black);
        if(length(text_ld )>0)then draw_text_line(x0+1,y1-1-basefont_w1,text_ld ,ta_LU,255,c_black);
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  Terrain
//

function DoodadAnimationTime(base:integer):integer;
begin
   case base of
   -1 : DoodadAnimationTime:=random(fr_fpsd3)+fr_fpsd3;
   -2 : DoodadAnimationTime:=random(fr_fps2 )+1;
   -3 : DoodadAnimationTime:=random(fr_fps1 )+1;
   -4 : DoodadAnimationTime:=random(fr_fps2 )+1;
   -5 : DoodadAnimationTime:=random(fr_fps3 )+1;
   -6 : DoodadAnimationTime:=random(fr_fps4 )+1;
   else if(base>0)
        then DoodadAnimationTime:=base
        else DoodadAnimationTime:=-100;
   end;
end;

procedure d_MapTerrain;
var
ssx,ssy,sty,
sx0,sy0,
cx,cy,
gx,gy,
mx,my,mty,
anim,i  :integer;
b,
AddEdges:boolean;
function GridGetSolidLevel(x,y:integer):byte;
begin
   if(map_InGridRange(x))and(map_InGridRange(y))
   then GridGetSolidLevel:=map_grid[x,y].tgc_solidlevel
   else GridGetSolidLevel:=mgsl_rocks;
end;
procedure DrawDecals;
var i:integer;
begin
   with map_grid_graph[gx,gy] do
    if(tgca_decal_n>0)then
      for i:=0 to tgca_decal_n-1 do
        with tgca_decal_l[i] do
          if(tgca_decalS<>nil)then
            draw_mwtexture1(ssx+tgca_decalX,ssy+tgca_decalX,tgca_decalS,-1+byte(tgca_decalF)*2,1);
end;
begin
   ssx:=-(vid_cam_x mod MapCellW)-MapCellW*2;
   sty:=-(vid_cam_y mod MapCellW)-MapCellW*2;
   sx0:= (vid_cam_x div MapCellW);
   sy0:= (vid_cam_y div MapCellW);
   mx := (sx0-2)*MapCellW;
   mty:= (sy0-2)*MapCellW;

   if(theme_cur_liquid_tas=tas_ice)
   then anim:=0
   else anim:=(G_Step div theme_cur_liquid_tasPeriod) mod theme_anim_step_n;

   AddEdges:=false;
   case m_brush of
1..255          : AddEdges:=true;
   end;

   draw_set_color(c_white);

   for cx:=-2 to ui_MapView_cw do
   begin
      ssy:=sty;
      my :=mty;
      for cy:=-2 to ui_MapView_ch do
      begin
         gx:=sx0+cx;
         gy:=sy0+cy;
         if(map_InGridRange(gx))and(map_InGridRange(gy))then
         with map_grid_graph[gx,gy] do
         begin
            if(AddEdges)then
            begin
               b:=GridGetSolidLevel(gx,gy)>mgsl_free;
               if(b)<>(GridGetSolidLevel(gx+1,gy)>mgsl_free)
               then UIInfoItemAddLine(mx+MapCellw,my         ,mx+MapCellw,my+MapCellw,vid_blink2_color_BY);
               if(b)<>(GridGetSolidLevel(gx,gy+1)>mgsl_free)
               then UIInfoItemAddLine(mx         ,my+MapCellw,mx+MapCellw,my+MapCellw,vid_blink2_color_BY);

               if(b)then
               begin
               UIInfoItemAddLine(mx+MapCellhw,my          ,mx          ,my+MapCellhw,vid_blink2_color_BY);
               UIInfoItemAddLine(mx+MapCellw ,my          ,mx          ,my+MapCellw ,vid_blink2_color_BY);
               UIInfoItemAddLine(mx+MapCellw ,my+MapCellhw,mx+MapCellhw,my+MapCellw ,vid_blink2_color_BY);
               end;
            end;

            if(tgca_tile_liquid=0)
            then draw_mwtexture1(ssx,ssy,theme_tileset_liquid[anim]^[tgca_tile_liquid],1,1)
            else
              if(tgca_tile_crater=0)then
              begin
                 draw_mwtexture1(ssx,ssy,theme_tileset_crater^[tgca_tile_crater],1,1);
                 DrawDecals;
                 if(1<=tgca_tile_liquid)and(tgca_tile_liquid<=MaxTileSet)then draw_mwtexture1(ssx,ssy,theme_tileset_liquid[anim]^[tgca_tile_liquid],1,1);
              end
              else
              begin
                 draw_mwtexture1(ssx,ssy,theme_tile_terrain,1,1);
                 if(1<=tgca_tile_crater)and(tgca_tile_crater<=MaxTileSet)then draw_mwtexture1(ssx,ssy,theme_tileset_crater      ^[tgca_tile_crater],1,1);
                 DrawDecals;
                 if(1<=tgca_tile_liquid)and(tgca_tile_liquid<=MaxTileSet)then draw_mwtexture1(ssx,ssy,theme_tileset_liquid[anim]^[tgca_tile_liquid],1,1);
              end;
           { with map_grid[gx,gy] do
            begin
               {if(map_IsObstacleZone(tgc_parea,true ))
               then draw_line(tar,ssx+32,ssy+32,w2s(tgc_parea),ta_LU,255,c_gray )
               else draw_line(tar,ssx+32,ssy+32,w2s(tgc_parea),ta_LU,255,c_white);
               if(map_IsObstacleZone(tgc_sarea,false))
               then draw_line(tar,ssx+32,ssy+46,w2s(tgc_sarea),ta_LU,255,c_green)
               else draw_line(tar,ssx+32,ssy+46,w2s(tgc_sarea),ta_LU,255,c_lime ); }
               //if(tgc_pf_solid)then UIInfoItemAddRect(mx,my,mx+MapCellw,my+MapCellw,c_red);
               //draw_line(tar,ssx+MapCellhw,ssy+MapCellhw,w2s(tgc_pf_zone),ta_LU,255,c_gray );
               if(tgc_pf_domain>0)then
               begin
                  draw_line(tar,ssx+MapCellhw,ssy+MapCellhw,w2s(tgc_pf_domain),ta_LU,255,c_white );
                  UIInfoItemAddRect(mx+1,my+1,mx+MapCellw,my+MapCellw,c_gray);
               end;
               if(tgc_pf_solid)then
               begin
                  UIInfoItemAddRect(mx+1,my+1,mx+MapCellw,my+MapCellw,c_red);
                  UIInfoItemAddLine(mx+1,my+1,mx+MapCellw,my+MapCellw,c_red);
                  UIInfoItemAddLine(mx+MapCellw,my+1,mx+1,my+MapCellw,c_red);
               end;
            end; }

            if(tgca_decor_n>0)then
              for i:=0 to tgca_decor_n-1 do
                with tgca_decor_l[i] do
                  if(tgca_decorS<>nil)and(tgca_decorA<>nil)then
                    with tgca_decorA^ do
                    begin
                       SpriteListAddDoodad(tgca_decorX+tda_xo,
                                           tgca_decorY+tda_yo,
                                           tgca_decorDepth,tda_shadow,tgca_decorS,255,tgca_decorF);
                       //UnitsInfoAddRect(tgca_decorX+tda_xo-tgca_decorS^.hw,tgca_decorY+tda_yo-tgca_decorS^.hh,
                       //                 tgca_decorX+tda_xo+tgca_decorS^.hw,tgca_decorY+tda_yo+tgca_decorS^.hh,c_yellow);

                       if(tgca_decorTime>0)then
                       begin
                          tgca_decorTime-=1;
                          if(tgca_decorTime=0)and(0<=tda_anext)and(tda_anext<theme_all_decor_n)then
                          begin
                             tgca_decorN   :=tda_anext;
                             tgca_decorS   := theme_all_decor_l[tgca_decorN];
                             tgca_decorA   :=@theme_anm_decors [tgca_decorN];
                             tgca_decorTime:=DoodadAnimationTime(tgca_decorA^.tda_atime);
                          end;
                       end;
                    end;
         end;

         ssy+=MapCellW;
         my +=MapCellW;
      end;
      ssx+=MapCellW;
      mx +=MapCellW;
   end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//  CPoints
//

procedure d_SpriteListAddCPoints;
const marks     = 15;
      mark_step = round(360/marks);
var t,i:integer;
   ddir:single;
  color:TMWColor;
begin
   for t:=1 to LastCPoint do
    with g_cpoints[t] do
     if(cpCaptureR>0)then
     begin
        if(not RectInCam(cpx,cpy,cpCaptureR,cpCaptureR,0))then continue;

      //  color:=GetCPColor(t);

        if(t=1)and(map_scenario=ms_KotH)then
        begin
           for i:=1 to marks do
           begin
              ddir:=(i*mark_step)*degtorad;
              {SpriteListAddEffect(
              cpx+round(cpCaptureR*cos(ddir)),
              cpy+round(cpCaptureR*sin(ddir)),
              sd_ground+cpy,ShadowColor(color),@spr_cp_koth,255);}
           end;
        end
        else
          {if(cpenergy<=0)
          then SpriteListAddEffect(cpx,cpy,sd_tcraters+cpy,ShadowColor(color),@spr_cp_out,255)
          else
          begin
             SpriteListAddEffect(cpx,cpy,sd_tcraters+cpy,0                 ,@spr_cp_out,255);
             SpriteListAddEffect(cpx,cpy,sd_tcraters+cpy,ShadowColor(color),@spr_cp_gen,255);
          end; }

        if(ui_MapPointInRevealedInScreen(cpx,cpy))then
        begin
          // if(cpTimer   >0)then UIInfoItemAddText(cpx,cpy+10,ir2s(cpCaptureTime-cpTimer),color  );
        //   if(cplifetime>0)then UIInfoItemAddText(cpx,cpy   ,cr2s(cplifetime           ),c_white);
        end;

       // for i:=0 to MaxPlayers do
       //  UIInfoItemAddText(cpx,cpy+(i+2)*10,i2s(cpunitsp_pstate[i])+' '+i2s(cpunitst_pstate[i]),c_white);
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  FOG
//

procedure D_Fog;
var
 cx, cy,
ssx,ssy,
    sty,
  tileX:integer;
function GetFogGridVal(fx,fy:integer):boolean;
begin
   GetFogGridVal:=true;
   if (0<=fx)and(fx<ui_FogView_gridW)
   and(0<=fy)and(fy<ui_FogView_gridh)then GetFogGridVal:=not ui_FogView_pgrid[fx,fy];
end;
begin
   for cx:=0 to ui_FogView_gridW-1 do
   for cy:=0 to ui_FogView_gridH-1 do
   ui_FogView_pgrid[cx,cy]:=ui_FogView_grid[cx,cy];

   ssx:=-(vid_cam_x mod fog_CellW);
   sty:=-(vid_cam_y mod fog_CellW);

   draw_set_color(c_white);
   for cx:=0 to ui_FogView_cw-1 do
   begin
      //vlineColor(tar,ssx,vid_mapx,vid_mapx+vid_cam_w,c_gray);
      ssy:=sty;
      for cy:=0 to ui_FogView_ch-1 do
      begin
         tileX:=TileSetGetN(GetFogGridVal(cx-1,cy-1),
                            GetFogGridVal(cx  ,cy-1),
                            GetFogGridVal(cx+1,cy-1),

                            GetFogGridVal(cx-1,cy  ),
                            GetFogGridVal(cx  ,cy  ),
                            GetFogGridVal(cx+1,cy  ),

                            GetFogGridVal(cx-1,cy+1),
                            GetFogGridVal(cx  ,cy+1),
                            GetFogGridVal(cx+1,cy+1));
         if(0<=tileX)and(tileX<=MaxTileSet)then
           draw_mwtexture1(ssx,ssy,ui_fog_tileset^[tileX],1,1);

         ui_FogView_grid[cx,cy]:=false;
         ssy+=fog_CellW;
      end;
      ssx+=fog_CellW;
   end;
end;


function SpriteDepth(y:integer;isfly:boolean):integer;
begin
   SpriteDepth:=map_flydepths[isfly]+y;
end;

function unit_SpriteDepth(pu:PTUnit):integer;
begin
   unit_SpriteDepth:=0;
   with pu^ do
    case uidi of
UID_UPortal,
UID_HTeleport,
UID_HPentagram,
//UID_HSymbol,
//UID_HASymbol,
UID_HAltar    : unit_SpriteDepth:=sd_tcraters+vy;
    else
      if(uid^._ukbuilding)and(not iscomplete)
      then unit_SpriteDepth:=sd_build+vy
      else
        if(hits>0)or(buff[ub_Resurect]>0)
        then unit_SpriteDepth:=SpriteDepth(vy,ukfly or (zfall>0))
        else unit_SpriteDepth:=SpriteDepth(vy,ukfly);
    end;
end;

procedure _draw_dbg;
var u,ix,iy:integer;
    c:TMWColor;
begin
   //draw_line(r_screen,750,0,i2s(mouse_map_x)+' '+i2s(mouse_map_y) , ta_RU,255, c_white);
   //draw_line(r_screen,750,0,i2s(spr_tdecsi), ta_RU,255, c_white);

   //draw_line(r_screen,750,0,b2pm[map_ffly] , ta_RU,255, c_white);

  { with g_players[PlayerClient] do
   begin
      draw_line(r_screen,ui_panel_pw,200,i2s(ai_pushtimei) , ta_LU,255, c_white);
      draw_line(r_screen,ui_panel_pw,210,i2s(ai_pushfrmi ) , ta_LU,255, c_white);
   end;       }

   {ix:=-vid_cam_x+vid_mapx;
   iy:=-vid_cam_y+vid_mapy;

   if(debug_r0<>NOTSET)then
   begin
   circleColor(r_screen,debug_x0+ix,debug_y0+iy,5,c_lime);
   rectangleColor(r_screen,ix+debug_x0,iy+debug_y0,ix+debug_x0+debug_a0,iy+debug_y0+debug_b0,c_lime);
   end;
   if(debug_r1<>NOTSET)then
   begin
   circleColor(r_screen,debug_x1-vid_cam_x+vid_mapx,debug_y1-vid_cam_y+vid_mapy,7,c_blue);
   rectangleColor(r_screen,ix+debug_x1,iy+debug_y1,ix+debug_x1+debug_a1,iy+debug_y1+debug_b1,c_blue);
   end;}

   if(InputAction(iAct_shift))then
   for u:=0 to LastPlayer do
    with g_players[u] do
    begin
       ix:=170+89*u;

     //  c:=PlayerColorNormal[u];

       //draw_line(r_screen,ix,80,b2s(ucl_cs[false]), ta_MU,255, c);

      // draw_line(r_screen,ix,90,b2s(army)+' '+b2s(ucl_c[false]) , ta_MU,255, c);

       //draw_line(r_screen,ix,100,b2s(ai_skill)+' '+b2s(ai_maxunits)+' '+b2s(ai_flags) , ta_MU,255, c);
       //draw_line(r_screen,ix,110,b2s(cenergy  )+' '+b2s(menergy) , ta_MU,255, c);


      // for iy:=0 to 8  do draw_line(r_screen,ix,130+iy*10,b2s(ucl_e[true ,iy])+'/'+b2s(ucl_eb[true ,iy])+' '+b2s(ucl_s[true ,iy])+' '+i2s(ucl_x[true,iy]), ta_LU,255, c);
      // for iy:=0 to 11 do draw_line(r_screen,ix,230+iy*10,b2s(ucl_e[false,iy])+' '+b2s(ucl_s [false,iy]), ta_LU,255, c);
    end;

   if(InputAction(iAct_control))then
   for u:=1 to MaxUnits do
    with g_units[u] do
    with player^ do
    with uid^ do
     if(hits>dead_hits)or(u=ai_scout_u_cur)then
     begin
        ix:=x-vid_cam_x;
        iy:=y-vid_cam_y;

        //draw_line(r_screen,ix,iy,i2s(anim), ta_LU,255, PlayerGetColor(playeri));

        if(hits>0)then
        //if(k_shift>1)then
        begin
           //circleColor(r_screen,ix,iy,_r  ,c_gray);
           //circleColor(r_screen,ix,iy,srange,c_white);
           if(isselected)then
           begin
              //lineColor(r_screen,ix,iy,vid_mapx+pf_mv_nx-vid_cam_x  ,vid_mapy+pf_mv_ny-vid_cam_y  ,c_red );
              //lineColor(r_screen,ix,iy,vid_mapx+moveDest_x    -vid_cam_x+1,vid_mapy+moveDest_y    -vid_cam_y+1,c_lime);

              //ix:=(((x-_rx2y_r*ugrid_cellw) div ugrid_cellw)*ugrid_cellw)-vid_cam_x+vid_mapx;
              //iy:=(((y-_rx2y_r*ugrid_cellw) div ugrid_cellw)*ugrid_cellw)-vid_cam_y+vid_mapy;

               //rectangleColor(r_screen,ix,iy,ix+_rx2y_r*2*ugrid_cellw+ugrid_cellw,iy+_rx2y_r*2*ugrid_cellw+ugrid_cellw,c_red);

              //lineColor(r_screen,ix+1,iy+1,ua_x+vid_mapx-vid_cam_x,ua_y-vid_cam_y,c_white);

              //if(aiu_alarm_d<32000)then
              //lineColor(r_screen,ix,iy,aiu_alarm_x+vid_mapx-vid_cam_x  ,aiu_alarm_y+vid_mapy-vid_cam_y  ,c_red );

              //lineColor(r_screen,ix,iy,ix+movePath_vx*MapCellW ,iy+movePath_vy*MapCellW  ,c_orange );
              //lineColor(r_screen,ix,iy,ix+debug_x0*MapCellW+12,iy+debug_y0*MapCellW+8,c_lime );

           end;

           {draw_line(r_screen,ix,iy   ,i2s(u)              , ta_LU,255, PlayerColorNormal[playeri]);
           draw_line(r_screen,ix,iy+10,i2s(hits)           , ta_LU,255, PlayerColorNormal[playeri]);
           draw_line(r_screen,ix,iy+20,w2s(zone)           , ta_LU,255, PlayerColorNormal[playeri]);
           draw_line(r_screen,ix,iy+30,str_b2c[isbuildarea], ta_LU,255, PlayerColorNormal[playeri]);  }


           //draw_line(r_screen,ix,iy+40,li2s(_level_armor), ta_LU,255, PlayerGetColor(playeri));
           //isbuildarea
//           draw_line(r_screen,ix,iy+40,i2s(_level_armor), ta_LU,255, PlayerGetColor(playeri));


           //draw_line(r_screen,ix,iy+20,b2pm[iscomplete], ta_LU,255, PlayerGetColor(playeri));

        end;

        {if(hits>0)and(transport=0)then
        if(playeri=PlayerClient)then
        begin
           if(isbuild)then
           begin
              if(alrm_x>0)then
               lineColor(r_screen,ix,iy,alrm_x-vid_cam_x,alrm_y-vid_cam_y,c_blue);  //i2s(u)+#13+i2s(tar1)+#13+i2s(uo_id)+#13+i2s(buff[ub_stop])
           end
           else
           begin
              if(alrm_x>0)then
               lineColor(r_screen,ix,iy,alrm_x-vid_cam_x,alrm_y-vid_cam_y,c_red);  //i2s(u)+#13+i2s(tar1)+#13+i2s(uo_id)+#13+i2s(buff[ub_stop])
           end;
           if(uo_x>0)then
            lineColor(r_screen,ix,iy,uo_x-vid_cam_x,uo_y-vid_cam_y,c_white);
        end;

        draw_line(r_screen,ix,iy,i2s(alrm_r)+#13+b2pm[alrm_b]+#12+i2s(player^.pnum), ta_LU,255, PlayerGetColor(playeri));}

        if(transport>0)then continue;

        if(hits>0){and(uidi=UID_URMStation)}then
        begin
           //draw_line(r_screen,ix,iy,i2s(u)+#13+i2s(tar1)+#13+i2s(uo_id)+#13+i2s(buff[ub_stop]), ta_LU,255, plcolor[player]);

           //if(tar1>0)then lineColor(r_screen,ix,iy,g_units[tar1].x-vid_cam_x,g_units[tar1].y-vid_cam_y,c_white);
            //lineColor(r_screen,ix+10,iy+10,uo_x-vid_cam_x,uo_y-vid_cam_y,c_white);  and(player=PlayerClient)
        end;

         //draw_line(r_screen,imap_mwcx,iy,b2s(painc)+' '+b2s(pains), ta_LU,255, plcolor[player]);
         //if(isselected)then            i2s(TeamVision[g_players[player].team])+#13+i2s(TeamDetection[g_players[player].team])
         //if(alrm_r<=0)then
         //

        {if(hits>0)then                      +' '+i2s(utrain)
         if(k_shift>2)
         then lineColor(r_screen,ix,iy,uo_x-vid_cam_x,uo_y-vid_cam_y,c_black)
         else
           if(alrm_x<>0)then


        draw_line(r_screen,ix,iy,i2s(u)+' '+i2s(rld_a), ta_LU,255, plcolor[player]);// }

        //if(isselected)then  circleColor(r_screen,ix,iy,r+5,plcolor[player]);
     end;

  { if(kt_ctrl>0)then
   for u:=1 to MaxMissiles do
   with g_missiles[u] do
   if(vstep>0)then
   begin
      ix:=vx-vid_cam_x+ui_MapView_x;
      iy:=vy-vid_cam_y+ui_MapView_y;

      circleColor(r_screen,ix,iy,5,c_lime);
      draw_line(r_screen,ix,iy,i2s(dir), ta_LU,255, c_white);
   end;  }

   {for u:=0 to 255 do
    if(ordx[u]>0)then
    begin
       ix:=ordx[u]-vid_cam_x;
       iy:=ordy[u]-vid_cam_y;

       draw_line(r_screen,ix,iy,i2s(u), ta_LU,255, c_white);
    end; }
end;


procedure _drawMWSModel(mwsm:PTMWSModel);
var i,x:integer;
begin
   x:=0;
   with mwsm^ do
   begin
      for i:=1 to sm_listn do
        with sm_list[i-1]^ do
        begin
           draw_mwtexture1(x,0,sm_list[i-1],1,1);
           x+=w;
        end;
      draw_text_line(0,48,i2s(sm_listn), ta_LU,255, 0);
   end;
end;

