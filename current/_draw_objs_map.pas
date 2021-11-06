

function _theme_anim_time(base:integer):integer;
const fr_h3fps = fr_fps div 3;
      fr_4fps  = fr_fps*4;
begin
   case base of
   -1 : _theme_anim_time:=random(fr_h3fps)+fr_h3fps;
   -2 : _theme_anim_time:=random(fr_2fps )+1;
   -3 : _theme_anim_time:=random(fr_fps  )+1;
   -4 : _theme_anim_time:=random(fr_2fps )+1;
   -5 : _theme_anim_time:=random(fr_3fps )+1;
   -6 : _theme_anim_time:=random(fr_4fps )+1;
   else if(base>0)
        then _theme_anim_time:=base
        else _theme_anim_time:=-100;
   end;
end;

procedure _dds_anim(d:integer;sprl:PTUSpriteList;anml:PTThemeAnimL;lst:PTIntList;lstn:pinteger;first:boolean);
begin
   if(lstn^>0)then
    with map_dds[d] do
     if(animt>0)or(first)then
     begin
        animt-=1;
        if(animt<=0)then
        begin
           if(animn<0)or(first)then
           begin
              animn:= d mod lstn^;
              animn:= lst^[animn];
           end
           else
           begin
              animn:=anml^[animn].anext;
           end;
           animt:=_theme_anim_time(anml^[animn].atime);
           shh  := anml^[animn].sh;
           ox   := anml^[animn].xo;
           oy   := anml^[animn].yo;
           spr  :=@sprl^[animn];
           case anml^[animn].depth of
           0    : dpth :=y;
           else   dpth :=anml^[animn].depth;
           end;
        end;
     end;
end;

procedure map_sprites(noanim:boolean);
var d,
    ro :integer;
begin
   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t>0)then
     begin
        if(_RectInScreen(x,y,255,255,0)=false)then continue;

        ro:=0;
        if(1<=m_brush)and(m_brush<=255)then ro:=r-bld_dec_mr;

        if(noanim=false)or(spr=pspr_dummy)then
        case t of
        DID_LiquidR1,
        DID_LiquidR2,
        DID_LiquidR3,
        DID_LiquidR4 : if(theme_liquid_animt<2)
                       then spr:=@spr_liquid[((G_Step div theme_liquid_animm) mod LiquidAnim)+1,animn]
                       else spr:=@spr_liquid[1                                                 ,animn];
        DID_Other    : _dds_anim(d,@theme_spr_decors,@theme_anm_decors,@theme_decors,@theme_decorn,false);
        DID_SRock    : _dds_anim(d,@theme_spr_srocks,@theme_anm_srocks,@theme_srocks,@theme_srockn,false);
        DID_BRock    : _dds_anim(d,@theme_spr_brocks,@theme_anm_brocks,@theme_brocks,@theme_brockn,false);
        end;

        if(_RectInScreen(x+ox,y+oy,spr^.hw,spr^.hh,0))then
        begin
           _sl_add_dec(x,y,dpth,shh,spr,255,ro,ox,oy);
           if(pspr<>nil)then _sl_add_dec(x,y,-20000,-32000,pspr,255,ro,ox,oy);
        end;
     end;
end;

procedure _map_dds;
var d:integer;
begin
   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t>0)then
     begin
        dpth := y;
        shh  := -32000;
        animn:= -1;
        animt:= 0;
        spr  := pspr_dummy;
        pspr := nil;
        ox   := 0;
        oy   := 0;

        case t of
        DID_LiquidR1,
        DID_LiquidR2,
        DID_LiquidR3,
        DID_LiquidR4: begin
                         dpth := -10000;
                         mmc  := theme_liquid_color;
                         animn:= t;
                         pspr := @spr_liquidb[animn];
                      end;
        DID_Srock  :  begin
                         mmc  := c_dgray;
                         _dds_anim(d,@theme_spr_srocks,@theme_anm_srocks,@theme_srocks,@theme_srockn,true);
                      end;
        DID_Brock  :  begin
                         mmc  := c_dgray;
                         _dds_anim(d,@theme_spr_brocks,@theme_anm_brocks,@theme_brocks,@theme_brockn,true);
                      end;
        DID_other  :  begin
                         shh  := 0;
                         mmc  := c_gray;
                         _dds_anim(d,@theme_spr_decors,@theme_anm_decors,@theme_decors,@theme_decorn,true);
                      end;
        end;

        mmx:=round(x*map_mmcx);
        mmy:=round(y*map_mmcx);
        mmr:=max2(1,round(r*map_mmcx));
     end;
end;


