

procedure map_MiniMap_BackgroundObj(sd:TSob);
var d:integer;
begin
   for d:=1 to MaxObstacles do
     with map_ObstaclesL[d] do
       if(o_type in sd)then
         if(o_mmr>0)
         then FilledcircleColor(ui_bminimap,o_mmx,o_mmy,o_mmr,o_mmc)
         else pixelColor       (ui_bminimap,o_mmx,o_mmy,      o_mmc);
end;

procedure map_MiniMap_UpdateBackground;
begin
   sdl_FillRect(ui_bminimap,nil,0);
   map_MiniMap_BackgroundObj(dids_liquids);
   map_MiniMap_BackgroundObj([DID_other,DID_srock,DID_brock]);
end;

procedure map_MiniMap_KeyPoint(tar:pSDL_Surface;x,y,r:integer;sym:char;color:cardinal);
begin
   circleColor   (tar,x  ,y  ,r  ,color);
   if(sym<>#0)then
   characterColor(tar,x-3,y-3,sym,color);
end;

procedure map_MiniMap_PlayerStarts(tar:pSDL_Surface);
var p    :byte;
    color:cardinal;
    pc   :char;
begin
   if(map_MaxPlayers>0)then
     for p:=0 to map_MaxPlayers-1 do
     begin
        if(g_FixedPositions)then
        begin
           if(g_gplayers[p].state=ps_none)and(g_AISlots=0)then continue;
           color:=PlayerGetColor(p,false);
           pc:=b2s(p+1)[1];
        end
        else
        begin
           pc:='?';
           color:=c_white;
        end;

        map_MiniMap_KeyPoint(tar,round(map_PlayerStartX[p]*map_MiniMap_cx),
                                 round(map_PlayerStartY[p]*map_MiniMap_cx),trunc(base_1r*map_MiniMap_cx),pc,color);
     end;
end;

procedure map_MiniMap_KeyPoints(tar:pSDL_Surface;colored:boolean);
var i:byte;
    c:cardinal;
begin
   for i:=0 to LastKeyPoint do
     with map_KeyPointsL[i] do
       if(kpCaptureR>0)then
       begin
          if(colored)
          then c:=GetKeyPointColor(i,false)
          else c:=c_white;
          if((i=0)and(map_scenario=mc_KotH))
          then map_MiniMap_KeyPoint(tar,kpmmx,kpmmy,kpmmr,char_koth,c)
          else
            if(kpEnergy<=0)
            then map_MiniMap_KeyPoint(tar,kpmmx,kpmmy,kpmmr,char_kp ,c)
            else map_MiniMap_KeyPoint(tar,kpmmx,kpmmy,kpmmr,char_gen,c);
       end;
end;

procedure map_RedrawMenuMinimap;
begin
   sdl_FillRect(ui_minimap,nil,0);
   map_MiniMap_UpdateBackground;
   draw_sdlsurface(ui_minimap ,0,0,ui_bminimap);
   draw_sdlsurface(ui_mminimap,0,0,ui_minimap );
   map_MiniMap_PlayerStarts(ui_mminimap);
   map_MiniMap_KeyPoints   (ui_mminimap,false);
   menu_update:=menu_update or MainMenu;
end;

function doodads_GetAnimationTime(base:integer):integer;
begin
   case base of
   -1 : doodads_GetAnimationTime:=random(fr_fpst)+fr_fpst;
   -2 : doodads_GetAnimationTime:=random(fr_fps2)+1;
   -3 : doodads_GetAnimationTime:=random(fr_fps1)+1;
   -4 : doodads_GetAnimationTime:=random(fr_fps2)+1;
   -5 : doodads_GetAnimationTime:=random(fr_fps3)+1;
   -6 : doodads_GetAnimationTime:=random(fr_fps4)+1;
   else if(base>0)
        then doodads_GetAnimationTime:=base
        else doodads_GetAnimationTime:=-100;
   end;
end;

procedure doodads_Animation(d:integer;sprl:PTUSpriteList;anml:PTThemeAnimL;lst:PTIntList;lstn:pinteger;first:boolean);
begin
   if(lstn^>0)then
    with map_ObstaclesL[d] do
     if(o_animt>0)or(first)then
     begin
        o_animt-=1;
        if(o_animt<=0)then
        begin
           if(o_animn<0)or(first)then
           begin
              o_animn:= d mod lstn^;
              o_animn:= lst^[o_animn];
           end
           else
           begin
              o_animn:=anml^[o_animn].anext;
           end;
           o_animt  :=doodads_GetAnimationTime(anml^[o_animn].atime);
           o_ShadowZ:= anml^[o_animn].sh;
           o_OffsetX     := anml^[o_animn].xo;
           o_OffsetY     := anml^[o_animn].yo;
           o_FrontSprite :=@sprl^[o_animn];
           {case anml^[o_animn].depth of
           0    : o_SpriteDepth :=o_y;                     ?????????????????????
           else   o_SpriteDepth :=anml^[o_animn].depth;
           end;}
        end;
     end;
end;

procedure doodads_AddSprites(noanim:boolean);
var o,edgesR:integer;
begin
   for o:=1 to MaxObstacles do
     with map_ObstaclesL[o] do
       if(o_type>0)then
       if(RectInCam(o_x,o_y,o_r,o_r,0))then
       begin
          if(ui_DrawEdges)
          then edgesR:=o_r-BuildObstacleStepR
          else edgesR:=0;

          if(not noanim)or(o_FrontSprite=pspr_dummy)then
            case o_type of
            DID_LiquidR1,
            DID_LiquidR2,
            DID_LiquidR3,
            DID_LiquidR4 : if(theme_liquid_animt<2)
                           then o_FrontSprite:=@spr_liquid[((g_tick div theme_liquid_animm) mod LiquidAnim)+1,o_animn]
                           else o_FrontSprite:=@spr_liquid[1                                                 ,o_animn];
            DID_Other    : doodads_Animation(o,@theme_spr_decors,@theme_anm_decors,@theme_decors,@theme_decorn,false);
            DID_SRock    : doodads_Animation(o,@theme_spr_srocks,@theme_anm_srocks,@theme_srocks,@theme_srockn,false);
            DID_BRock    : doodads_Animation(o,@theme_spr_brocks,@theme_anm_brocks,@theme_brocks,@theme_brockn,false);
            end;

          if(RectInCam(o_x+o_OffsetX,o_y+o_OffsetY,o_FrontSprite^.hw,o_FrontSprite^.hh,0))then
          begin
             SpriteList_AddDoodad(o_x,o_y,o_SpriteDepth,o_ShadowZ,o_FrontSprite,255,o_OffsetX,o_OffsetY);
             if(o_BackSprite<>nil)then SpriteList_AddDoodad(o_x,o_y,sd_liquid_back,-32000,o_BackSprite,255,o_OffsetX,o_OffsetY);
             if(edgesR>0)then UnitsInfo_AddCircle(o_x,o_y,edgesR,ui_blink2_color_BY);
          end;
       end;
end;

procedure map_DoodadsSetDrawData;
var d:integer;
begin
   for d:=1 to MaxObstacles do
     with map_ObstaclesL[d] do
       if(o_type>0)then
       begin
          o_ShadowZ     := -32000;
          o_SpriteDepth := 0;
          o_animn       := -1;
          o_animt       := 0;
          o_OffsetX     := 0;
          o_OffsetY     := 0;
          o_FrontSprite := pspr_dummy;
          o_BackSprite  := nil;

          case o_type of
          DID_LiquidR1,
          DID_LiquidR2,
          DID_LiquidR3,
          DID_LiquidR4: begin
                           o_SpriteDepth:= sd_liquid;
                           o_mmc        := theme_liquid_color;
                           o_animn      := o_type;
                           o_BackSprite := @spr_liquidb[o_animn];
                        end;
          DID_Srock  :  begin
                           o_SpriteDepth:= sd_srocks+o_y;
                           o_mmc        := c_dgray;
                           doodads_Animation(d,@theme_spr_srocks,@theme_anm_srocks,@theme_srocks,@theme_srockn,true);
                        end;
          DID_Brock  :  begin
                           o_SpriteDepth:= sd_brocks+o_y;
                           o_mmc        := c_dgray;
                           doodads_Animation(d,@theme_spr_brocks,@theme_anm_brocks,@theme_brocks,@theme_brockn,true);
                        end;
          DID_other  :  begin
                           o_SpriteDepth:= sd_ground+o_y;
                           o_ShadowZ    := 0;
                           o_mmc        := c_gray;
                           doodads_Animation(d,@theme_spr_decors,@theme_anm_decors,@theme_decors,@theme_decorn,true);
                        end;
          end;

          o_mmx:=round(o_x*map_MiniMap_cx);
          o_mmy:=round(o_y*map_MiniMap_cx);
          o_mmr:=max2i(1,round(o_r*map_MiniMap_cx));
       end;
end;


