

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

procedure DoodadAnimation(d:integer;sprl:PTUSpriteList;anml:PTThemeAnimL;lst:PTIntList;lstn:pinteger;first:boolean);
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
           o_animt  :=DoodadAnimationTime(anml^[o_animn].atime);
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

procedure doodads_sprites(noanim:boolean);
var d,ro:integer;
begin
   for d:=1 to MaxObstacles do
    with map_ObstaclesL[d] do
     if(o_type>0)then
     if(RectInCam(o_x,o_y,o_r,o_r,0))then
     begin
        ro:=0;
        with g_players[LocalPlayer] do
          case m_brush of
1..255         : ro:=o_r-bld_dec_mr;
co_pability    : if(ui_uibtn_pabilityu<>nil)then
                  case ui_uibtn_pabilityu^.uid^._ability of
                  uab_RebuildInPoint,
                  uab_HTowerBlink,
                  uab_HKeepBlink,
                  uab_CCFly         : ro:=o_r-bld_dec_mr;
                  end;
          end;

        if(not noanim)or(o_FrontSprite=pspr_dummy)then
          case o_type of
          DID_LiquidR1,
          DID_LiquidR2,
          DID_LiquidR3,
          DID_LiquidR4 : if(theme_liquid_animt<2)
                         then o_FrontSprite:=@spr_liquid[((g_tick div theme_liquid_animm) mod LiquidAnim)+1,o_animn]
                         else o_FrontSprite:=@spr_liquid[1                                                 ,o_animn];
          DID_Other    : DoodadAnimation(d,@theme_spr_decors,@theme_anm_decors,@theme_decors,@theme_decorn,false);
          DID_SRock    : DoodadAnimation(d,@theme_spr_srocks,@theme_anm_srocks,@theme_srocks,@theme_srockn,false);
          DID_BRock    : DoodadAnimation(d,@theme_spr_brocks,@theme_anm_brocks,@theme_brocks,@theme_brockn,false);
          end;

        if(RectInCam(o_x+o_OffsetX,o_y+o_OffsetY,o_FrontSprite^.hw,o_FrontSprite^.hh,0))then
        begin
           SpriteListAddDoodad(o_x,o_y,o_SpriteDepth,o_ShadowZ,o_FrontSprite,255,o_OffsetX,o_OffsetY);
           if(o_BackSprite<>nil)then SpriteListAddDoodad(o_x,o_y,sd_liquid_back,-32000,o_BackSprite,255,o_OffsetX,o_OffsetY);
           if(ro>0)then UnitsInfoAddCircle(o_x,o_y,ro,ui_blink2_color_BY);
        end;
     end;
end;

procedure map_DoodadsDrawData;
var d:integer;
begin
   for d:=1 to MaxObstacles do
    with map_ObstaclesL[d] do
     if(o_type>0)then
     begin
        o_ShadowZ:= -32000;
        o_SpriteDepth  :=0;
        o_animn  := -1;
        o_animt  := 0;
        o_OffsetX     := 0;
        o_OffsetY     := 0;
        o_FrontSprite := pspr_dummy;
        o_BackSprite:=nil;

        case o_type of
        DID_LiquidR1,
        DID_LiquidR2,
        DID_LiquidR3,
        DID_LiquidR4: begin
                         o_SpriteDepth  := sd_liquid;
                         o_mmc    := theme_liquid_color;
                         o_animn  := o_type;
                         o_BackSprite := @spr_liquidb[o_animn];
                      end;
        DID_Srock  :  begin
                         o_SpriteDepth  := sd_srocks+o_y;
                         o_mmc    := c_dgray;
                         DoodadAnimation(d,@theme_spr_srocks,@theme_anm_srocks,@theme_srocks,@theme_srockn,true);
                      end;
        DID_Brock  :  begin
                         o_SpriteDepth  := sd_brocks+o_y;
                         o_mmc    := c_dgray;
                         DoodadAnimation(d,@theme_spr_brocks,@theme_anm_brocks,@theme_brocks,@theme_brockn,true);
                      end;
        DID_other  :  begin
                         o_SpriteDepth  := sd_ground+o_y;
                         o_ShadowZ:= 0;
                         o_mmc    := c_gray;
                         DoodadAnimation(d,@theme_spr_decors,@theme_anm_decors,@theme_decors,@theme_decorn,true);
                      end;
        end;

        o_mmx:=round(o_x*map_mmcx);
        o_mmy:=round(o_y*map_mmcx);
        o_mmr:=max2i(1,round(o_r*map_mmcx));
     end;
end;


