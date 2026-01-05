


procedure map_MiniMap_UpdateBackground;
var
d,
maxRc,
maxRp:integer;
begin
   sdl_FillRect(ui_bminimap,nil,0);
   maxRp:=maxRp.MaxValue;
   while(true)do
   begin
      maxRc:=maxRc.MinValue;
      for d:=1 to MaxObstacles do
        with map_ObstaclesL[d] do
          if(o_rO>0)and(o_rO>maxRc)and(o_rO<maxRp)then maxRc:=o_rO;

      if(maxRc=maxRc.MinValue)then break;

      for d:=1 to MaxObstacles do
        with map_ObstaclesL[d] do
          if(o_rO=maxRc)then
            with map_ObstaclesVis[d] do
              if(ov_mmrO<=0)
              then pixelColor(ui_bminimap,ov_mmx,ov_mmy,ov_mmc)
              else
              begin
                 filledCircleColor(ui_bminimap,ov_mmx,ov_mmy,ov_mmrO,ov_mmc);
                 if(ov_mmrI>0)then
                 filledCircleColor(ui_bminimap,ov_mmx,ov_mmy,ov_mmrI,c_black);
              end;
      maxRp:=maxRc;
   end;
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

procedure draw_FilledRing(rx,ry,rOutR,rInR:integer;sTemplateF,sTemplateB:PTMWTexture);
var
sx,sy,
ex,ey,
nx,ny,
x,y,d,
oGO,oGI,
oRO,orI,
cellw1,
cellwh:integer;
odd   :boolean;
begin
   cellwh:=round(sTemplateF^.hw/1.36);
   cellw1:=cellwh*2;
   sx:=rx-rOutR-cellwh;
   sy:=ry-rOutR-cellwh;
   ex:=rx+rOutR+cellwh;
   ey:=ry+rOutR+cellwh;
   odd:=false;
   oRO:=rOutR-cellwh-5;
   oRI:=rInR +cellwh+5;
   oGO:=rOutR+(cellwh div 2);
   oGI:=rInR -(cellwh div 2);

   x:=sx;
   while(x<=ex)do
   begin
      if(odd)
      then y:=sy
      else y:=sy-cellwh;
      odd:=not odd;
      while(y<=ey)do
      begin
         if(RectInCam(x,y,sTemplateB^.w,sTemplateB^.h,0))then
         begin
            d:=point_dist_int(x,y,rx,ry);
            if(oGI<=d)and(d<=oGO)then
            begin
               if(abs(rOutR-d)<=cellwh)then
               begin
                  nx:=rx+round(oRO*(x-rx)/d);
                  ny:=ry+round(oRO*(y-ry)/d);
               end
               else
                 if(abs(rInR-d)<=cellwh)and(rInR>0)then
                 begin
                    nx:=rx+round(oRI*(x-rx)/d);
                    ny:=ry+round(oRI*(y-ry)/d);
                 end
                 else
                 begin
                    nx:=x;
                    ny:=y;
                 end;

               if((abs(rInR-d)<=cellw1)and(rInR>0))
               or(abs(rOutR-d)<=cellw1)then
               SpriteList_AddDoodad(nx,ny,sd_liquidBack ,-32000,sTemplateB,255,0,0);

               if(not InputAction(iact_Alt))then
               SpriteList_AddDoodad(nx,ny,sd_liquidFront,-32000,sTemplateF,255,0,0);

               if(InputAction(iact_Control))then
               UnitsInfo_AddCircle(nx,ny,sTemplateF^.hw,ui_blink2_color_BY);
            end;
         end;

         y+=cellw1;
      end;
      x+=cellw1;
   end;
end;

function obstacle_GetAnimationTime(base:integer):integer;
begin
   case base of
   -1 : obstacle_GetAnimationTime:=random(fr_fpst)+fr_fpst;
   -2 : obstacle_GetAnimationTime:=random(fr_fps2)+1;
   -3 : obstacle_GetAnimationTime:=random(fr_fps1)+1;
   -4 : obstacle_GetAnimationTime:=random(fr_fps2)+1;
   -5 : obstacle_GetAnimationTime:=random(fr_fps3)+1;
   -6 : obstacle_GetAnimationTime:=random(fr_fps4)+1;
   else if(base>0)
        then obstacle_GetAnimationTime:=base
        else obstacle_GetAnimationTime:=-100;
   end;
end;

procedure obstacle_SetAnimData(obsN,animDataN:integer);
begin
   if(theme_spr_obstaclesN>0)then
     with map_ObstaclesL  [obsN] do
     with map_ObstaclesVis[obsN] do
     begin
        ov_SpriteFront:=@theme_spr_obstaclesL[animDataN];
        ov_animTime   :=obstacle_GetAnimationTime(theme_obstacles_Anims[animDataN].toa_atime);
        ov_OffsetX    :=theme_obstacles_Anims[animDataN].toa_xo;
        ov_OffsetY    :=theme_obstacles_Anims[animDataN].toa_yo;
        ov_SpriteDepth:=theme_obstacles_Anims[animDataN].toa_depth+o_y;
        ov_ShadowZ    :=theme_obstacles_Anims[animDataN].toa_shadow;
        ov_animNext   :=theme_obstacles_Anims[animDataN].toa_anext;
     end;
end;

procedure obstacle_Animation(obsN:integer);
begin
   if(theme_spr_obstaclesN>0)then
     with map_ObstaclesL  [obsN] do
     with map_ObstaclesVis[obsN] do
       if(ov_animTime>0)and(0<=ov_animNext)and(ov_animNext<theme_spr_obstaclesN)then
       begin
          ov_animTime-=1;
          if(ov_animTime>0)then exit;
          obstacle_SetAnimData(obsN,ov_animNext);
       end;
end;

procedure doodads_AddSprites(skipAnim:boolean);
var o:integer;
begin
   for o:=1 to MaxObstacles do
     with map_ObstaclesL[o] do
       if(o_rO>0)then
       if(RectInCam(o_x,o_y,o_rO,o_rO,0))then
         with map_ObstaclesVis[o] do
         begin
            case ov_type of
            ov_obstacle0,
            ov_obstacle1,
            ov_obstacle2: if(not skipAnim)then
                            obstacle_Animation(o);
            ov_liquid   : draw_FilledRing(o_x,o_y,o_rO,o_rI,@spr_liquidFront[((g_tick div theme_liquid_animTime) mod LiquidAnimCount)+1],@spr_liquidBack);
            end;

            if(ov_SpriteFront<>nil)and(ov_SpriteFront<>pspr_dummy)then
              if(RectInCam(o_x+ov_OffsetX,o_y+ov_OffsetY,ov_SpriteFront^.hw,ov_SpriteFront^.hh,0))then
              begin
                 SpriteList_AddDoodad(o_x,o_y,ov_SpriteDepth,ov_ShadowZ,ov_SpriteFront,255,ov_OffsetX,ov_OffsetY);
                 if(ov_SpriteBack<>nil)and(ov_SpriteBack<>pspr_dummy)then
                 SpriteList_AddDoodad(o_x,o_y,sd_liquidBack,-32000  ,ov_SpriteBack ,255,ov_OffsetX,ov_OffsetY);
              end;

            if(ui_DrawEdges)then
            begin
               UnitsInfo_AddCircle(o_x,o_y,o_rO-BuildObstacleStepR,ui_blink2_color_BY);
               if(o_rI>0)then
               UnitsInfo_AddCircle(o_x,o_y,o_rI+BuildObstacleStepR,ui_blink2_color_BY);
            end;
         end;
end;

procedure map_DoodadsSetDrawData;
var d:integer;
begin
   FillChar(map_ObstaclesVis,SizeOf(map_ObstaclesVis),0);
   for d:=1 to MaxObstacles do
     with map_ObstaclesL[d] do
       if(o_rO>0)then
         with map_ObstaclesVis[d] do
         begin
            ov_mmx :=round(o_x *map_MiniMap_cx);
            ov_mmy :=round(o_y *map_MiniMap_cx);
            ov_mmrO:=round(o_rO*map_MiniMap_cx);
            ov_mmrI:=round(o_rI*map_MiniMap_cx);
            ov_mmc :=c_gray;
            ov_animNext   :=-1;
            ov_animTime   :=0;
            ov_SpriteFront:=nil;
            ov_SpriteBack :=nil;

            if(o_rO=map_ObstacleR(0))
            then ov_type:=ov_obstacle0
            else
              if(o_rO=map_ObstacleR(1))
              then ov_type:=ov_obstacle1
              else
                if(o_rO=map_ObstacleR(2))
                then ov_type:=ov_obstacle2
                else ov_type:=ov_liquid;

            case ov_type of
            ov_obstacle0: begin
                             ov_mmc :=c_ltgray;
                             if(theme_obstacle0N>0)then
                             obstacle_SetAnimData(d,theme_obstacle0L[d mod theme_obstacle0N]);
                          end;
            ov_obstacle1: begin
                             ov_mmc :=c_gray;
                             if(theme_obstacle1N>0)then
                             obstacle_SetAnimData(d,theme_obstacle1L[d mod theme_obstacle1N]);
                          end;
            ov_obstacle2: begin
                             ov_mmc :=c_gray;
                             if(theme_obstacle2N>0)then
                             obstacle_SetAnimData(d,theme_obstacle2L[d mod theme_obstacle2N]);
                          end;
            ov_liquid   : begin
                             ov_mmc :=theme_liquid_color;
                          end;
            end;
         end;
end;


