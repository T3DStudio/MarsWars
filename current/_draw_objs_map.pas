


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

procedure map_MiniMap_KeyPoint(tar:pSDL_Surface;x,y,r:integer;sym:char;color:TMWColor);
begin
   circleColor   (tar,x  ,y  ,r  ,color);
   if(sym<>#0)then
   characterColor(tar,x-3,y-3,sym,color);
end;

procedure map_MiniMap_PlayerStarts(tar:pSDL_Surface);
var p    :byte;
    color:TMWColor;
    pc   :char;
begin
   if(map_MaxPlayers>0)then
     for p:=0 to map_MaxPlayers-1 do
     begin
        if(g_FixedPositions)then
        begin
           if(g_PlayersMain[p].state=ps_none)and(g_AISlots=0)then continue;
           color:=PlayerGetColor(p,false);
           pc:=b2s(p+1)[1];
        end
        else
        begin
           pc:='?';
           color:=c_white;
        end;

        map_MiniMap_KeyPoint(tar,round(map_PlayerStartX[p]*map_MiniMap_cx),
                                 round(map_PlayerStartY[p]*map_MiniMap_cx),trunc(base_r1*map_MiniMap_cx),pc,color);
     end;
end;

procedure map_MiniMap_KeyPoints(tar:pSDL_Surface;forGame:boolean);
var i:byte;
    c:TMWColor;
   ch:char;
begin
   for i:=0 to LastKeyPoint do
     with map_KeyPointsL  [i] do
     with map_KeyPointsVis[i] do
     begin
        case forGame of
        true : begin
                  with kp_TeamData[KeyPoint_GetPlayerTeam(UIPlayer)] do
                    if(not kptd_Active)then continue;
                  c:=KeyPoint_GetColor(i,false);
               end;
        false: begin
                  with kp_TeamData[MaxPlayers] do
                    if(not kptd_Active)then continue;
                  c:=c_white;
               end;
        end;

        if((i=0)and(map_scenario=mc_KotH))
        then ch:=char_koth
        else
          if(kp_Energy<=0)
          then ch:=char_kp
          else ch:=char_gen;

        map_MiniMap_KeyPoint(tar,kpmmx,kpmmy,kpmmr,ch,c);
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

procedure draw_FilledRing(rx,ry,rOutR,rInR,fdepth,bdepth:integer;animStep:byte;sTemplateAF:PTLiquidTextureArray;sTemplateB:PTMWTexture);
var
sx,sy,
ex,ey,
nx,ny,
x,y,d,
oGO,oGI,
oRO,orI,
cellw1,
cellwh,
depth,
visBorder
      :integer;
odd   :boolean;
animX,
animN:byte;
begin
   cellwh:=round(sTemplateAF^[1].hw/1.36);
   cellw1:=cellwh*2;
   sx:=mm3i(ui_cam_x,rx-rOutR-cellwh,ui_cam_x+ui_cam_w);
   sy:=mm3i(ui_cam_y,ry-rOutR-cellwh,ui_cam_y+ui_cam_h);
   ex:=mm3i(ui_cam_x,rx+rOutR+cellwh,ui_cam_x+ui_cam_w);
   ey:=mm3i(ui_cam_y,ry+rOutR+cellwh,ui_cam_y+ui_cam_h);
   if(sx=ex)
   or(sy=ey)then exit;
   if(sx<0)then sx-=cellw1;
   if(sy<0)then sy-=cellw1;
   sx-= sx mod cellw1;
   sy-= sy mod cellw1;
   ex+=(ex mod cellw1)+cellwh;
   ey+=(ey mod cellw1)+cellwh;
   odd:=((sx div cellw1)mod 2)=0;
   oRO:=rOutR-cellwh-5;
   oRI:=rInR +cellwh+5;
   oGO:=rOutR+(cellwh div 2);
   oGI:=rInR -(cellwh div 2);
   visBorder:=max2i(sTemplateB^.w,sTemplateAF^[1].w);

   x:=sx;
   while(x<=ex)do
   begin
      animX:=byte(x div cellw1);
      if(odd)
      then y:=sy
      else y:=sy-cellwh;
      odd:=not odd;
      while(y<=ey)do
      begin
         if(RectInCam(x,y,visBorder,visBorder,0))then
         begin
            d:=point_dist_int(x,y,rx,ry);
            if(oGI<=d)and(d<=oGO)then
            begin
               if(abs(rOutR-d)<=cellwh)then
               begin
                  nx:=rx+round(oRO*(x-rx)/d);
                  ny:=ry+round(oRO*(y-ry)/d);
                  depth:=fdepth-1;
               end
               else
                 if(abs(rInR-d)<=cellwh)and(rInR>0)then
                 begin
                    nx:=rx+round(oRI*(x-rx)/d);
                    ny:=ry+round(oRI*(y-ry)/d);
                    depth:=fdepth-1;
                 end
                 else
                 begin
                    nx:=x;
                    ny:=y;
                    depth:=fdepth;
                 end;

               if((abs(rInR-d)<=cellw1)and(rInR>0))
               or(abs(rOutR-d)<=cellw1)then
               SpriteList_AddDoodad(nx,ny,bdepth ,-32000,sTemplateB,255,0,0);

               animN:=(abs(animStep+animX+byte(y div cellw1)) mod LiquidAnimCount)+1;

               //if(not InputAction(iact_Alt))then
               SpriteList_AddDoodad(nx,ny,depth,-32000,@sTemplateAF^[animN],255,0,0);

               {if(InputAction(iact_Control))then
               begin
               UnitsInfo_AddCircle(nx,ny,sTemplateAF^[1].hw,ui_blink2_color_BY);
               UnitsInfo_AddText(nx,ny,i2s(animN),c_white);
               end; }
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

procedure obstacles_AddSprites(skipAnim:boolean);
var
o:integer;
animStep:byte;
begin
   animStep:=((g_tick div theme_liquid_animTime) mod LiquidAnimCount)+1;
   for o:=1 to MaxObstacles do
     with map_ObstaclesL[o] do
       if(o_rO>0)then
       if(RectInCam(o_x,o_y,o_rO,o_rO,0))then
         with map_ObstaclesVis[o] do
         begin
            if(ov_SpriteFront<>nil)and(ov_SpriteFront<>pspr_dummy)then
            begin
               if(not skipAnim)then
                 obstacle_Animation(o);
               if(RectInCam(o_x+ov_OffsetX,o_y+ov_OffsetY,ov_SpriteFront^.hw,ov_SpriteFront^.hh,0))then
                 SpriteList_AddDoodad(o_x,o_y,ov_SpriteDepth,ov_ShadowZ,ov_SpriteFront,255,ov_OffsetX,ov_OffsetY);
            end
            else draw_FilledRing(o_x,o_y,o_rO,o_rI,sd_liquidFront,sd_liquidBack,
                                 animStep,
                                 @spr_liquidFront,
                                 @spr_liquidBack);

            if(ui_DrawEdges)then
            begin
               UnitsInfo_AddCircle(o_x,o_y,o_rO,ui_blink2_color_BY);
               if(o_rI>0)then
               UnitsInfo_AddCircle(o_x,o_y,o_rI,ui_blink2_color_BY);
            end;
         end;

   if(map_scenario=mc_royale)then
     draw_FilledRing(map_sizeh,map_sizeh,map_size1,g_royal_r,sd_decals,sd_decals-2,
                     animStep,
                     @spr_fireblueFront,
                     @spr_fireblueBack);
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
            ov_mmx        :=round(o_x *map_MiniMap_cx);
            ov_mmy        :=round(o_y *map_MiniMap_cx);
            ov_mmrO       :=round(o_rO*map_MiniMap_cx);
            ov_mmrI       :=round(o_rI*map_MiniMap_cx);
            ov_mmc        :=c_gray;
            ov_animNext   :=-1;
            ov_animTime   :=0;
            ov_SpriteFront:=nil;

            if(o_rO=map_ObstacleR(0))then
            begin
               ov_mmc:=c_ltgray;
               if(theme_obstacle0N>0)then
                 obstacle_SetAnimData(d,theme_obstacle0L[d mod theme_obstacle0N]);
            end
            else
              if(o_rO=map_ObstacleR(1))then
              begin
                 ov_mmc:=c_gray;
                 if(theme_obstacle1N>0)then
                   obstacle_SetAnimData(d,theme_obstacle1L[d mod theme_obstacle1N]);
              end
              else
                if(o_rO=map_ObstacleR(2))then
                begin
                   ov_mmc:=c_gray;
                   if(theme_obstacle2N>0)then
                     obstacle_SetAnimData(d,theme_obstacle2L[d mod theme_obstacle2N]);
                end
                else ov_mmc:=theme_liquid_color;
         end;
end;


