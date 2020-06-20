

procedure _missile_effect(m:integer);
begin
   with _missiles[m] do
   begin
      case mid of
MID_ArchFire : begin PlaySND(snd_exp,nil); exit; end;
MID_Imp,
MID_Cacodemon,
MID_Baron,
MID_Mancubus,
MID_BPlasma,
MID_YPlasma   : PlaySND(snd_pexp,nil);
MID_BFG       : PlaySND(snd_bfgepx,nil);
MID_Revenant,
MID_Granade,
MID_URocket,
MID_HRocket   : PlaySND(snd_exp,nil);
MID_Blizzard  : PlaySND(snd_exp2,nil);
MID_SShot,
                       MID_SSShot,
                       MID_Bullet,
                       MID_Bulletx2,
                       MID_TBullet : begin
                                        if(mf=uf_ground)then
                                         if(mid in [MID_SShot,MID_SSShot])then
                                          for u:=1 to mtars do _effect_add(vx-sr+random(sr shl 1),vy-sr+random(sr shl 1),d+40,mid_Bullet);
                                        if(random(4)=0)then PlaySND(snd_rico,nil);
                                        continue;
                                     end;
      end;

      _effect_add(vx,vy,d+50,mid);
   end;
end;

/////////////////////////////////////////////////////////////////////////////////
////
////   UNITS
////
////////


function _udpth(pu:PTUnit):integer;
begin
   _udpth:=0;
   with (pu^) do
   with (puid^) do
    if(_sdpth<0)
    then _udpth:=_sdpth
    else
      if(hits>0)
      then _udpth:=map_flydpth[uf]+vy
      else _udpth:=vy;
end;

procedure _unit_mmcoords(pu:PTUnit);
begin
   with (pu^) do
   begin
      mmx:=trunc(x*map_mmcx);
      mmy:=trunc(y*map_mmcx);
   end;
end;

procedure _unit_minimap(pu:PTUnit);
begin
   if(ui_redraw=0)and(_menu=false)and(_draw)then
    with(pu^)do
     with(puid^)do
      if(hits>0)then
       with _players[player] do
        if(_mmr>1)
        then filledCircleColor(ui_uminimap,mmx,mmy,_mmr,color)
        else pixelColor       (ui_uminimap,mmx,mmy,     color);
end;

procedure _sf(tx,ty:integer);
begin
   if(0<=tx)and(0<=ty)and(tx<=fog_vfw)and(ty<=fog_vfh)then fog_grid[tx,ty]:=2;
end;

procedure _fog_sr(x,y,r:integer);
var iy,i:integer;
begin
   for i:=0 to r do
    for iy:=0 to _fcx[r,i] do
    begin
       _sf(x-i,y-iy);
       _sf(x-i,y+iy);
       if(i>0)then
       begin
          _sf(x+i,y-iy);
          _sf(x+i,y+iy);
       end;
    end;
end;

procedure _unit_sfog(pu:PTUnit);
begin
   with (pu^) do
   begin
      fx :=x div fog_cw;
      fy :=y div fog_cw;
   end;
end;

function _unit_fogrev(pu:PTUnit):boolean;
begin
   _unit_fogrev:=false;
   with (pu^) do
    with (puid^) do
     with (_players[player]) do
      if(_fog=false)
      then _unit_fogrev:=true
      else
       if(_uvision(_players[HPlayer].team,pu))then
        if(team=_players[HPlayer].team)or(HPlayer=0)then
        begin
           if(_fog_cscr(fx,fy,fsr))then _fog_sr(fx-vid_fsx,fy-vid_fsy,fsr);
           _unit_fogrev:=true;
        end
        else
        begin
           if(_fog_cscr(fx,fy,_fr))then _fog_sr(fx-vid_fsx,fy-vid_fsy,_fr);
           _unit_fogrev:=true;
        end;
end;

procedure _addPrcR(pu:PTUnit);
begin
   with (pu^) do
    with (puid^) do
    with _players[player] do
    begin
       case _tuids[-m_brtar]._itbuild of
       true : if(race_pstyle[true, race]=false)or (itbarea=false)then exit;
       false: if(race_pstyle[false,race]      )and(itwarea=false)then exit;
       end;

       inc(ui_bldrrsi,1);
       ui_bldrrsx[ui_bldrrsi]:=x;
       ui_bldrrsy[ui_bldrrsi]:=y;
       ui_bldrrsr[ui_bldrrsi]:=srng;
    end;
end;

procedure _unit_vis(pu:PTUnit);
var spr     : PTUSprite;
   dp,smy,
   inv,
   ro,sh    : integer;
   mc,rc    : cardinal;
   sb       : single;
   b0,b2,b3 : byte;
   b1       : string6;
   wanim,
   rct      : boolean;
begin
   with (pu^) do
    with (puid^) do
     with _players[player] do
     begin

        if(player=HPlayer)and(G_Status=0)then
        begin
           if(ordx[order]=0)then
           begin
              ordx[order]:=x;
              ordy[order]:=y;
           end
           else
           begin
              ordx[order]:=(ordx[order]+x) div 2;
              ordy[order]:=(ordy[order]+y) div 2;
           end;
           if(sel)then
           begin
               if(ui_lsuc=0  )then ui_lsuc:=uid;
               if(ui_lsuc=uid)then ui_su_bld:=ui_su_bld or bld;

              if(aattack)then ui_su_aut :=ui_su_aut+[uo_attack];
              ui_su_aut :=ui_su_aut+[aorder];

              ui_su_abil:=ui_su_abil+[uo_id[0], _toids[uo_id[0]]._oidi];
              if(a_rld>0)then ui_su_abil:=ui_su_abil+[_a_weap[a_weap].aw_order];
           end;
           if(bld)then
           begin
              if(_itbarrack)then
               if(un_r>0) then
               begin
                  sh:=(un_r div vid_fps)+1;
                  if(ui_uidipts[un_t]=0)or(sh<ui_uidipts[un_t])then ui_uidipts[un_t]:=sh;
                  if(ui_uidiptu=0)or(sh<ui_uidiptu)then ui_uidiptu:=sh;
               end;
              if(m_brush=uo_prod)and(m_brtar<0)then _addPrcR(pu);
              if(sel)then
               if(ui_lsuc=uid)then
               begin
                  if(speed>ui_su_spd  )then ui_su_spd  := speed;
               end;
           end
           else
           begin
              inc(ui_bldblds[uid],1);
              inc(ui_bldblda[_itbuild],1);
              //if(_bldstep>0)
              sh:=((_mhits-hits) div _bldstep div 2)+1;
              if(_itbuild)then
              begin
                 if(ui_uidipts[uid]=0)or(sh<ui_uidipts[uid])then ui_uidipts[uid]:=sh;
                 if(ui_uidiptb=0)or(sh<ui_uidiptb)then ui_uidiptb:=sh;
              end
              else
              begin
                 if(ui_uidipts[uid]=0)or(sh<ui_uidipts[uid])then ui_uidipts[uid]:=sh;
                 if(ui_uidiptu=0)or(sh<ui_uidiptu)then ui_uidiptu:=sh;
              end;
           end;
        end;

        if(_unit_fogrev(pu))then
        begin
           _unit_minimap(pu);

           if(G_Status>0)
           then wanim:=false
           else
             if(OnlySVCode)
             then wanim:={_canmove(pu) and (x<>mv_x)or(y<>mv_y)or}((x<>vx)or(y<>vy))
             else wanim:=(pains>0);

           spr:=_unit_spr(pu,wanim);
           sh :=0;
           smy:=vy;

           if(shadow<>0)then sh:=shadow;

           if ((vid_vx   -spr^.hw)<vx )and(vx <(vid_vx+vid_mw   +spr^.hw))and
              ((vid_vy-sh-spr^.hh)<smy)and(smy<(vid_vy+ui_panely+spr^.hh)) then
           begin
              dp :=_udpth(pu);
              inv:=255;
              rc :=0;
              sb :=0;
              mc :=0;
              b0 :=0;
              b1 :='';
              b2 :=0;
              b3 :=0;
              rct:=false;
              rc :=color;
              ro :=0;

              if(wanim)and(_foota>0)then _ueff_foot(pu);

              if(buff[ub_invuln]>0)then mc:=c_awhite;

              if(m_brtar=0)and(m_vy<ui_panely)then
               if(_chabilt(m_brush,HPlayer,unum))then
                if(dist2(vx,vy,m_mx,m_my)<_r)then m_brtar :=unum;

              if((sel)and(player=HPlayer))
              or(k_alt>1)
              or((ui_redraw>ui_redrawph)and(ui_umark_ut>0)and(ui_umark_u=unum))then
              begin
                 rct:=true;
                {if(buff[ub_hellpower]>0)then b1:=b1+hp_char; }
                 if(buff[ub_advanced ]>0)then b1:=b1+adv_char;
                 //if(buff[ub_detect   ]>0)then b1:=b1+hp_detect;

                 if(player=HPlayer)then
                 begin
                    if(order>0)then b0:=order;
                    if(_apcm>0)then
                    begin
                       b2:=_apcm;
                       b3:=apcc;
                    end;
                 end;
              end;
              if(hits<_mhits)or(rct)then sb:=hits/_mhits;

              if(bld)then
              begin
                 if(buff[ub_invis]>0)then inv:=128;
                 if(player=HPlayer)then
                 begin
                    if(_itbarrack)and(un_r>0)then _sl_add(vx-vid_hBW, smy-vid_hBW,dp+1,0,c_white,0,true,_tuids [un_t]._ubtn ,255,0,(un_r div vid_fps)+1,0,0,'',0,0);
                    if(_itsmith  )and(up_r>0)then _sl_add(vx-vid_hBW, smy-vid_hBW,dp+1,0,c_white,0,true,_tupids[up_t]._upbtn,255,0,(up_r div vid_fps)+1,0,0,'',0,0);
                 end;

                 if(_urace>0)then
                  if(buff[ub_detect   ]>0)then
                   with spr_detect[_urace] do _sl_add(vx-hw, smy-spr^.hh-surf^.h-7,dp,0,0,0,false,surf,255,0,0,0,0,'',0,0);

              end
              else
               if(_itbuild)then
               begin
                  if(race=r_hell)then
                  begin
                     inv:=g_step mod vid_2fps;
                     if(inv>=vid_fps)then inv:=(vid_2fps-inv);
                     inv:=55+trunc(200*hits/_mhits)-inv;
                     if(inv<0)then inv:=0;
                     if(_r<41)
                     then _sl_add(vx-spr_db_h1.hw,smy-spr_db_h1.hh+5 ,-5,0,0,0,false,spr_db_h1.surf,255-inv,0,0,0,0,'',0,0)
                     else _sl_add(vx-spr_db_h0.hw,smy-spr_db_h0.hh+10,-5,0,0,0,false,spr_db_h0.surf,255-inv,0,0,0,0,'',0,0);
                     if(buff[ub_invis]>0)then inv:=inv shr 1;
                  end;
               end;

              if(m_brtar<0)and(speed=0)and(_uf=uf_ground)then ro :=_r;

              _sl_add(vx-spr^.hw, smy-spr^.hh,dp,sh,rc,mc,rct,spr^.surf,inv,sb,b0,b2,b3,b1,ro,0);
           end;
        end;
     end;
end;

procedure _unit_dvis(pu:PTUnit);
var spr : PTUSprite;
    inv : integer;
    rct : boolean;
begin
   with (pu^) do
    with (puid^) do
     with _players[player] do
     begin
        if(_unit_fogrev(pu))then
        begin
           if(hits<=idead_hits)then exit;

           if(m_brtar=0)then
            if(_chabilt(m_brush,HPlayer,unum))then
             if(dist2(vx,vy,m_mx,m_my)<_r)then m_brtar :=unum;

           rct:=false;
           if((ui_redraw>ui_redrawph)and(ui_umark_ut>0)and(ui_umark_u=unum))then
           begin
              rct:=true;
           end;

           spr:=_unit_spr(pu,false);

           if ((vid_vx-spr^.hw)<vx )and(vx<(vid_vx+vid_mw   +spr^.hw))and
              ((vid_vy-spr^.hh)<vy )and(vy<(vid_vy+ui_panely+spr^.hh)) then
           begin
              inv:=hits-idead_hits;
              if(inv>255)then inv:=255;
              _sl_add(vx-spr^.hw, vy-spr^.hh,_udpth(pu),0,color,0,rct,spr^.surf,inv,0,0,0,0,'',0,0);
           end;
        end;
     end;
end;


/////////////////////////////////////////////////////////////////////////////////
////
////   MAP
////
////////


function _map_dec_anim_time(base:byte):byte;
begin
   case base of
   250: _map_dec_anim_time:=random(vid_h3fps)+vid_h3fps;
   251: _map_dec_anim_time:=random(vid_h2fps)+1;
   252: _map_dec_anim_time:=random(vid_fps  )+1;
   253: _map_dec_anim_time:=random(vid_2fps )+1;
   254: _map_dec_anim_time:=random(vid_3fps )+1;
   255: _map_dec_anim_time:=random(vid_4fps )+1;
   else _map_dec_anim_time:=base;
   end;
end;

procedure _dds_p;
var d,ro,yo:integer;
    spr :PTUSprite;
begin
   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t>0)then
     begin
        if(x<(vid_vx-255))or((vid_vx+vid_mw+255)<x)or
          (y<(vid_vy-255))or((vid_vy+ui_panely+255)<y)then  continue;

        yo:=0;
        if(m_brtar<0)
        then ro:=r-bld_dec_mr
        else ro :=0;

        case t of
        DID_LiquidR1,
        DID_LiquidR2,
        DID_LiquidR3,
        DID_LiquidR4 :
                       if(anm_Liquids[map_lqt]<2)
                       then spr:=@spr_liquid[a,((G_Step div ans_Liquids[map_lqt]) mod LiquidAnim)+1]
                       else spr:=@spr_liquid[a,1];
        DID_BRock    : begin
                          if(G_Status=0)and(BRocks_animt[a]>0)then
                           if(anim<=0)
                           then anim:=_map_dec_anim_time(BRocks_animt[a])
                           else
                             if(anim=1)then
                             begin
                                a:=BRocks_animn[a];
                                dec(anim,1);
                             end
                             else dec(anim,1);

                          spr:=@spr_BRocks[a,xas];
                       end;
        DID_SRock    : begin
                          if(G_Status=0)and(SRocks_animt[a]>0)then
                           if(anim<=0)
                           then anim:=_map_dec_anim_time(SRocks_animt[a])
                           else
                             if(anim=1)then
                             begin
                                a:=SRocks_animn[a];
                                dec(anim,1);
                             end
                             else dec(anim,1);

                          spr:=@spr_SRocks[a,xas];
                       end;
        DID_Other    : begin
                          if(G_Status=0)and(tdecs_animt[a]>0)then
                           if(anim<=0)
                           then anim:=_map_dec_anim_time(tdecs_animt[a])
                           else
                             if(anim=1)then
                             begin
                                a:=tdecs_animn[a];
                                dec(anim,1);
                             end
                             else dec(anim,1);

                          spr:=@spr_TDecs [a,xas];
                          yo:=tdecs_ys[a];
                       end
        else
           continue;
        end;

        if((vid_vx-spr^.hw)<x)and(x<(vid_vx+vid_mw+spr^.hw))and
          ((vid_vy-spr^.hh-yo)<y)and(y<(vid_vy+ui_panely+spr^.hh-yo))then
        begin
           _sl_add(x-spr^.hw, y-spr^.hh,dpth,shd,0,0,false,spr^.surf,255,0,0,0,0,'',ro,yo);
           if(t in [DID_LiquidR1..DID_LiquidR4])then
            with spr_liquidb[a] do
             _sl_add(x-hw, y-hh,dpth-10000,0,0,0,false,surf,255,0,0,0,0,'',0,0);
        end;
     end;
end;

procedure _bmm_draw(sd:TSob);
var d:integer;
begin
   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t in sd)then
      if(mmr>0)
      then filledcircleColor(ui_tminimap,mmx,mmy,mmr,mmc)
      else pixelColor(ui_tminimap,mmx,mmy,mmc);
end;

procedure map_tminimap;
begin
   _bmm_draw([DID_LiquidR1,DID_LiquidR2,DID_LiquidR3,DID_LiquidR4]);
   _bmm_draw([DID_Other,DID_SRock,DID_BRock]);
end;

procedure map_dstarts;
var i:byte;
    x,y:integer;
    c:cardinal;
begin
   for i:=0 to MaxPlayers do
   begin
      x:=trunc(map_psx[i]*map_mmcx);
      y:=trunc(map_psy[i]*map_mmcx);

      c:=_players[i].color;

      characterColor(ui_uminimap,x-3,y-3,#1        ,c);
      circleColor   (ui_uminimap,x  ,y  ,map_mmsp  ,c);
   end;
end;

procedure Map_minimapUPD;
begin
   boxColor(ui_tminimap,0,0,ui_mmwidth,ui_mmwidth,c_black);
   boxColor(ui_uminimap,0,0,ui_mmwidth,ui_mmwidth,c_black);
   map_tminimap;
   if(g_sslots)or(g_mode in [gm_tdm2,gm_tdm3])then map_dstarts;
   _draw_surf(spr_mback,ui_mmmpx,ui_mmmpy,ui_tminimap);
   _draw_surf(spr_mback,ui_mmmpx,ui_mmmpy,ui_uminimap);
   boxColor(ui_uminimap,0,0,ui_mmwidth,ui_mmwidth,c_black);
   vid_mredraw:=true;
end;

procedure Map_lqttrt;
begin
   map_themec:=(map_seed shr 24) mod map_themen;
   with map_themes[map_themec] do
   begin
      map_trt := _terrs[(map_seed shr 16) mod _terrn];
      map_lqt := _liqds[(map_seed shr 8 ) mod _liqdn];
   end;
end;

/////////////////////////////////////////////////////////////////////////////////
////
////   MISSILES
////
////////

procedure D_Missiles;
var m,
    d  :integer;
    spr:PTUSprite;
begin
   for m:=1 to MaxMissiles do
    with _missiles[m] do
     if(vst>0)then
     begin
        {if(mid=MID_Blizzard)and(vst=1)then
        begin
           _effect_add(vx,vy+10,-10,eid_db_h0);
           _effect_add(vx,vy,map_flydpth[mf]+vy+5,EID_BBExp);
           PlayUSND(snd_exp);
           continue;
        end;  }

        case mid of
        MID_Imp      : spr:=@spr_h_p0[0];
        MID_Cacodemon: spr:=@spr_h_p1[0];
        MID_Baron    : spr:=@spr_h_p2[0];
        MID_Blizzard,
        MID_HRocket  : spr:=@spr_h_p3[dir];
        MID_Granade  : spr:=@spr_h_p3[2];
        MID_URocket  : spr:=@spr_u_p3[dir];
        MID_Revenant : spr:=@spr_h_p4[dir];
        MID_Mancubus : spr:=@spr_h_p5[dir];
        MID_YPlasma  : spr:=@spr_h_p7[0];
        MID_BPlasma  : spr:=@spr_u_p0[0];
        MID_BFG      : spr:=@spr_u_p2[0];
        else
         spr:=@spr_dummy;
        end;

        if((vid_vx-spr^.hw)<x)and(x<(vid_vx+vid_mw+spr^.hw))and
          ((vid_vy-spr^.hh)<y)and(y<(vid_vy+ui_panely+spr^.hh))then
        begin
           d:=map_flydpth[mf]+vy;

           case mid of
             MID_URocket,
             MID_HRocket,
             MID_Granade  : if((vst mod 4)=0)then _effect_add(vx,vy,d-1,MID_Bullet);
             MID_Blizzard : if((vst mod 3)=0)then _effect_add(vx,vy,d-1,EID_Exp);
           end;

           _sl_add(vx-spr^.hw, vy-spr^.hh,d,0,0,0,false,spr^.surf,255,0,0,0,0,'',0,0);
        end;
     end;
end;

/////////////////////////////////////////////////////////////////////////////////
////
////   MAIN
////
////////

procedure D_objects;
var u : integer;
begin
   ui_su_mana := 0;
   ui_su_abil := [];
   ui_su_bld  := false;
   ui_su_aut  := [];
   ui_su_spd  := 0;

   if(m_brtar>0)then m_brtar:=0;

   FillChar(ordx      ,SizeOf(ordx      ),0);
   FillChar(ordy      ,SizeOf(ordy      ),0);
   FillChar(ui_bldblds,SizeOf(ui_bldblds),0);
   FillChar(ui_uidipts,SizeOf(ui_uidipts),0);
   ui_lsuc    := 0;
   ui_bldrrsi := 0;
   ui_uidiptu := 0;
   ui_uidiptb := 0;
   ui_bldblda[false] := 0;
   ui_bldblda[true ] := 0;

   for u:=1 to MaxUnits do
    with _units[u] do
     if(hits>dead_hits)then
      if(inapc>0)
      then _unit_fogrev(@_units[u])
      else
       if(hits>0)
       then _unit_vis (@_units[u])
       else _unit_dvis(@_units[u]);

   if(m_brush>0)and(m_brtar>0)then
   begin
      ui_umark_u :=m_brtar;
      ui_umark_ut:=vid_h4fps;
   end;

   _effectsCycle(true);
   _dds_p;
   D_Missiles;
end;

/////////////////////////////////////////////////////////////////////////////////
////
////   MAIN
////
////////

procedure _drawSprMap(spr:PTUSprite;x,y,r:integer;alpha:byte;rcolor:cardinal);
begin
   dec(x,vid_vx);
   dec(y,vid_vy);
   if(r>0)then circleColor(_screen,x,y,r,rcolor);
   with spr^ do
   begin
      if(alpha<255)then SDL_SetAlpha(surf,SDL_SRCALPHA,alpha);
      if(r>=0)
      then _draw_surf(_screen,x-hw,y-hh,surf)
      else _draw_surf(_screen,x-hw,y-surf^.h,surf);
      if(alpha<255)then SDL_SetAlpha(surf,SDL_SRCALPHA,255);
   end;
end;

procedure _arrow(x1,y1,x2,y2:integer;color:cardinal;crcl:boolean);
var dx,dy,ax1,ay1,ax2,ay2,d:integer;
begin
   dec(x1,vid_vx);
   dec(y1,vid_vy);
   dec(x2,vid_vx);
   dec(y2,vid_vy);
   lineColor(_screen,x1,y1,x2,y2,color);

   if(crcl)then circleColor(_screen,x2,y2,10,color);

   dx:=x2-x1;
   dy:=y2-y1;
   if(dx=0)and(dy=0)then exit;
   x1:=abs(dx);
   y1:=abs(dy);

   if(x1>y1)
   then begin if(y1>0)then d:=x1 div y1 else d:=0; end
   else begin if(x1>0)then d:=y1 div x1 else d:=0; end;

   if(d<2)then
   begin
      ax1:=x2-sign(dx)*8;
      ay1:=y2;
      ax2:=x2;
      ay2:=y2-sign(dy)*8;
   end
   else
   begin
      ax1:=x2-sign(dx)*6;
      ay1:=y2-sign(dy)*6;
      if(y1>x1)then
      begin
         ax2:=x2+sign(dx)*6;
         ay2:=y2-sign(dy)*6;
      end
      else
      begin
         ax2:=x2-sign(dx)*6;
         ay2:=y2+sign(dy)*6;
      end;
   end;

   lineColor(_screen,x2,y2,ax1,ay1,color);
   lineColor(_screen,x2,y2,ax2,ay2,color);
end;

procedure D_UnitOrderList;
var sox,
    soy,
    ioy,
    u:integer;
    p,
    k:byte;
begin
   for u:=1 to MaxUnits do
    with _units[u] do
     if(hits>0)and(player=HPlayer)then
     begin
        if(sel)
        then p:=0
        else p:=2;
        sox:=vx;
        soy:=vy;
        ioy:=vy;
        for k:=0 to uo_n do
        begin
           case p of
           1: if not(uo_id[k] in [uo_patrol,uo_spatrol])then continue;
           2: if(uo_id[k]<>uo_prod)then continue;
           end;

           if(uo_id[k]=uo_prod)then
           begin
              if(uo_tar[k]<-255)or(0<=uo_tar[k])then continue;
              if(sel)then _arrow(sox,soy,uo_x[k],uo_y[k],_toids[uo_id[k]]._omarc,false);
              with _tuids[-uo_tar[k]] do _drawSprMap(ui_uasprites[-uo_tar[k]],uo_x[k],uo_y[k],_r,128,c_gray);
              sox:=uo_x[k];
              soy:=uo_y[k];
              ioy:=soy;
           end
           else
             if((_toids[uo_id[k]].rtar and at_anytar)>0)then
             begin
                if(uo_x[k]>0)then
                begin
                   _arrow(sox,soy,uo_x[k],uo_y[k],_toids[uo_id[k]]._omarc,uo_id[k]=uo_spatrol);
                   sox:=uo_x[k];
                   soy:=uo_y[k];
                   ioy:=soy;
                end;
             end
             else
              if(k>0)then
              begin
                 _draw_text(_screen,sox-vid_vx,ioy-vid_vy,_toids[uo_id[k]]._oname,ta_Left,255,c_white);
                 inc(ioy,font_w);
              end;
           if(uo_id[k] in [uo_hold  ,uo_destroy])then break;
           if(uo_id[k] in [uo_spatrol,uo_patrol])then p:=1;
        end;

        if(sel)then
         if(uo_rallpos in puid^._orders)then
         begin
            _arrow(vx,vy,un_rx,un_ry,c_dorange,false);
            with _players[player] do _drawSprMap(@spr_mp[race],un_rx,un_ry,-1,255,0);
         end;
     end;
end;






