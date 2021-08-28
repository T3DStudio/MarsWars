
procedure _sl_add(ax,ay,ad,ash:integer;arc,amsk:cardinal;arct:boolean;aspr:PTMWTexture;ainv:byte;abar:single;aclu:integer;acrl,acll:byte;acru:string6;aro:integer);
begin
   if(vid_vsls<vid_mvs)and(_menu=false)then
   begin
      vid_vsls+=1;
      with vid_vsl[vid_vsls]^ do
      begin
         x   := ax-vid_vx;
         y   := ay-vid_vy;
         d   := ad;
         sh  := ash;
         s   := aspr;
         rc  := arc;
         msk := amsk;
         inv := ainv;
         bar := abar;
         clu := aclu;
         cru := acru;
         crl := acrl;
         cll := acll;
         rct := arct;
         ro  := aro;
         xo  := 0;
         yo  := 0;
      end;
   end;
end;
//_sl_add(x-spr^.hw, y-spr^.hh,dpth,shh,0,0,false,spr^.surf,255,0,0,0,0,'',ro);
procedure _sl_add_dec(ax,ay,ad,ash:integer;aspr:PTMWTexture;ainv:byte;aro,axo,ayo:integer);
begin
   if(vid_vsls<vid_mvs)and(_menu=false)then
   begin
      vid_vsls+=1;
      with vid_vsl[vid_vsls]^ do
      begin
         x   := ax-vid_vx;
         y   := ay-vid_vy;
         d   := ad;
         sh  := ash;
         s   := aspr;
         rc  := 0;
         msk := 0;
         inv := ainv;
         bar := 0;
         clu := 0;
         cru := '';
         crl := 0;
         cll := 0;
         rct := false;
         ro  := aro;
         xo  := axo;
         yo  := ayo;
      end;
   end;
end;
procedure _sl_add_dec2(ax,ay,ad,ash:integer;aspr:PTMWTexture;ainv:byte;aro,axo,ayo:integer;_cru:string6);
begin
   if(vid_vsls<vid_mvs)and(_menu=false)then
   begin
      vid_vsls+=1;
      with vid_vsl[vid_vsls]^ do
      begin
         x   := ax-vid_vx;
         y   := ay-vid_vy;
         d   := ad;
         sh  := ash;
         s   := aspr;
         rc  := 0;
         msk := 0;
         inv := ainv;
         bar := 0;
         clu := 0;
         cru := _cru;
         crl := 0;
         cll := 0;
         rct := false;
         ro  := aro;
         xo  := axo;
         yo  := ayo;
      end;
   end;
end;
//_sl_add(x-spr^.hw, y-spr^.hh,d,0,0,msk,false,spr^.surf,alpha,0,0,0,0,'',0);
procedure _sl_add_eff(ax,ay,ad:integer;amsk:cardinal;aspr:PTMWTexture;ainv:byte);
begin
   if(vid_vsls<vid_mvs)and(_menu=false)then
   begin
      vid_vsls+=1;
      with vid_vsl[vid_vsls]^ do
      begin
         x   := ax-vid_vx;
         y   := ay-vid_vy;
         d   := ad;
         sh  := -32000;
         s   := aspr;
         rc  := 0;
         msk := amsk;
         inv := ainv;
         bar := 0;
         clu := 0;
         cru := '';
         crl := 0;
         cll := 0;
         rct := false;
         ro  := 0;
         xo  := 0;
         yo  := 0;
      end;
   end;
end;

procedure _sv_sort;
var i,u:word;
    dt :PTVisSpr;
begin
   if(vid_vsls>1)then
    for i:=1 to vid_vsls do
     for u:=1 to (vid_vsls-1) do
      if(vid_vsl[u]^.d<vid_vsl[u+1]^.d)then
      begin
        dt:=vid_vsl[u];
        vid_vsl[u]:=vid_vsl[u+1];
        vid_vsl[u+1]:=dt;
      end;
end;

procedure D_SpriteList(tar:pSDL_Surface;lx,ly:integer);
var sx,sy:integer;
begin
   _sv_sort;
   while(vid_vsls>0)do
    with vid_vsl[vid_vsls]^ do
    begin
       x-=s^.hw;
       y-=s^.hh;

       x+=lx+xo;
       y+=ly+yo;

       if(sh>-fly_z)then
       begin
          sx:=s^.hw;
          sy:=s^.h-(s^.h shr 3);
          filledellipseColor(tar,x+sx,y+sy+sh,sx,s^.hh shr 1,c_ablack);
       end;
       if(inv<255)then SDL_SetAlpha(s^.surf,SDL_SRCALPHA or SDL_RLEACCEL,inv);

       if(inv>0)then _draw_surf(tar,x,y,s^.surf);

       x-=xo;
       y-=yo;

       if(msk>0)or(ro>0)then
       begin
          sx:=s^.w shr 1;
          sy:=s^.h shr 1;
          if(msk>0)then filledellipseColor(tar,x+sx,y+sy,sx,sy,msk);
          if(ro >0)then circleColor       (tar,x+sx,y+sy,ro,c_gray);
       end;

       sx:=s^.h;
       if(bar>0)
       then sy:=4
       else sy:=1;
       if(y<sy)then
       begin
          sx:=s^.h+y-sy;
          y:=sy;
       end;
       sy:=y;

       if(sy>-s^.h)then
       begin
          if(rc>0)and(y>-s^.h)then
          begin
             if(rct)then rectangleColor(tar,x-1,y-1,x+s^.w,y+sx, rc);
             if(bar>0)then
             begin
                boxColor(tar,x-1,y-4,x+s^.w           ,y-1,c_black);
                boxColor(tar,x-1,y-4,x+trunc(bar*s^.w),y-1,rc);
             end;
          end;
          if(clu >0 )then _draw_text(tar,x     ,y          ,i2s(clu),ta_left ,255,c_white);
          if(cru<>'')then _draw_text(tar,x+s^.w,y          ,cru     ,ta_right,3,c_white);
          if(cll >0 )then _draw_text(tar,x     ,y+sx-font_w,b2s(cll),ta_left ,255,c_white);
          if(crl >0 )then _draw_text(tar,x+s^.w,y+sx-font_w,b2s(crl),ta_right,255,c_white);
       end;

       y:=sy;

       if(inv<255)then SDL_SetAlpha(s^.surf,SDL_SRCALPHA or SDL_RLEACCEL,255);

       vid_vsls-=1;
    end;
end;

procedure D_terrain(tar:pSDL_Surface;lx,ly:integer);
var i,t,
  ix,iy,s:integer;
    vx,vy:integer;
    spr  :PTMWTexture;
begin
   _draw_surf(tar,
   lx-vid_vx mod ter_w,
   ly-vid_vy mod ter_h,
   vid_terrain);

   vx:=vid_vx-vid_ab;
   vy:=vid_vy-vid_ab;

   if(theme_decaln>0)then
    for i:=1 to _tdecaln do
     with _tdecals[i-1] do
     begin
        ix:=x-vx+vid_mwa;
        iy:=y-vy+vid_mha;

        s:=abs(i+(iy div vid_mha)+(ix div vid_mwa)) mod theme_decaln;

        t:=theme_decals[s];
        if(t<0)
        then spr:=@spr_crater[-t]
        else spr:=@theme_spr_decals[t];

        ix:=ix mod vid_mwa;
        iy:=iy mod vid_mha;

        if(ix<0)then ix:=vid_mwa+ix;
        if(iy<0)then iy:=vid_mha+iy;

        ix+=lx-vid_ab;
        iy+=ly-vid_ab;

        with spr^ do _draw_surf(tar,ix-hw,iy-hh,spr^.surf);
     end;
end;

procedure d_foglayer(tar:pSDL_Surface;lx,ly:integer);
var cx,cy,ssx,ssy,sty:integer;
begin
   ssx:=lx-(vid_vx and %0000000000011111); //mod fog_cw;
   sty:=ly-(vid_vy and %0000000000011111); //mod fog_cw;

   for cx:=0 to fog_vfw do
   begin
      ssy:=sty;
      for cy:=0 to fog_vfh do
      begin
         fog_pgrid[cx,cy]:=fog_grid[cx,cy];
         if(_fog)then
         begin
            if(fog_grid[cx,cy]=0)then _draw_surf(tar,ssx-fog_chw, ssy-fog_chw, fog_surf);
            fog_grid[cx,cy]:=0;
         end
         else fog_grid[cx,cy]:=2;
         ssy+=fog_cw;
      end;
      ssx+=fog_cw;
   end;


   case g_mode of
gm_ct:
      for cx:=1 to MaxCPoints do
       with g_cpoints[cx] do
        circleColor(tar,lx+px-vid_vx,ly+py-vid_vy,g_ct_pr,_PlayerColor(pl));
gm_royl:
      circleColor(tar,lx+map_hmw-vid_vx,lx+map_hmw-vid_vy,g_royal_r,ui_muc[(g_royal_r mod 2)=0]);
   end;

   {if(menu_s2=ms2_camp)then
   begin
      if(ui_msks>=0)then
      begin
         if(integer(ui_msk+ui_msks)>255)
         then ui_msk:=255
         else inc(ui_msk,ui_msks);
      end
      else
      begin
         if(integer(ui_msk+ui_msks)<0)
         then ui_msk:=0
         else inc(ui_msk,ui_msks);
      end;
      if(ui_msk>0)then
      begin
         boxColor(tar,vid_panelw,0,vid_sw,vid_sh,rgba2c(255,255,255,ui_msk));
         if(vid_rtui=0)then dec(ui_msks,1);
      end;
   end;  }
end;

procedure _draw_dbg;
var u,ix,iy:integer;
    c:cardinal;
begin
   //_draw_text(r_screen,750,0,i2s(m_mx)+' '+i2s(m_my) , ta_right,255, c_white);
   //_draw_text(r_screen,750,0,i2s(spr_tdecsi), ta_right,255, c_white);

   //_draw_text(r_screen,750,0,b2pm[map_ffly] , ta_right,255, c_white);

  { with _players[HPlayer] do
   begin
      _draw_text(r_screen,vid_panelw,200,i2s(ai_pushtimei) , ta_left,255, c_white);
      _draw_text(r_screen,vid_panelw,210,i2s(ai_pushfrmi ) , ta_left,255, c_white);
   end;       }

   if(k_shift>2) then
   for u:=0 to MaxPlayers do
    with _players[u] do
    begin
       ix:=170+89*u;

       c:=_PlayerColor(u);

       _draw_text(r_screen,ix,80,b2s(ucl_cs[false]), ta_middle,255, c);

       _draw_text(r_screen,ix,90,b2s(army)+' '+b2s(ucl_c[false]) , ta_middle,255, c);

       //_draw_text(r_screen,ix,100,b2s(ai_skill)+' '+b2s(ai_maxunits)+' '+b2s(ai_flags) , ta_middle,255, c);
       _draw_text(r_screen,ix,110,b2s(cenerg  )+' '+b2s(menerg) , ta_middle,255, c);


       for iy:=0 to 8  do _draw_text(r_screen,ix,130+iy*10,b2s(ucl_e[true ,iy])+'/'+b2s(ucl_eb[true ,iy])+' '+b2s(ucl_s[true ,iy])+' '+i2s(ucl_x[true,iy]), ta_left,255, c);
       for iy:=0 to 11 do _draw_text(r_screen,ix,230+iy*10,b2s(ucl_e[false,iy])+' '+b2s(ucl_s [false,iy]), ta_left,255, c);
    end;

   if(k_ctrl>2)then
   for u:=1 to MaxUnits do
    with _units[u] do
    with uid^ do
     if(hits>dead_hits)then
     begin
        ix:=x-vid_vx+vid_mapx;
        iy:=y-vid_vy+vid_mapy;

        //_draw_text(r_screen,ix,iy,i2s(anim), ta_left,255, _PlayerColor(playeri));

        if(hits>0)then
        //if(k_shift>1)then
        begin
           circleColor(r_screen,ix,iy,_r  ,c_gray);
           circleColor(r_screen,ix,iy,srange,c_white);
           if(sel)then lineColor(r_screen,ix,iy,uo_x-vid_vx,uo_y-vid_vy,_PlayerColor(player^.pnum));

           _draw_text(r_screen,ix,iy   ,i2s(u)    , ta_left,255, _PlayerColor(playeri));
           _draw_text(r_screen,ix,iy+10,i2s(a_tar) , ta_left,255, _PlayerColor(playeri));
           //_draw_text(r_screen,ix,iy+20,b2pm[bld], ta_left,255, _PlayerColor(playeri));

        end;

        {if(hits>0)and(inapc=0)then
        if(playeri=HPlayer)then
        begin
           if(isbuild)then
           begin
              if(alrm_x>0)then
               lineColor(r_screen,ix,iy,alrm_x-vid_vx,alrm_y-vid_vy,c_blue);  //i2s(u)+#13+i2s(tar1)+#13+i2s(uo_id)+#13+i2s(buff[ub_stopattack])
           end
           else
           begin
              if(alrm_x>0)then
               lineColor(r_screen,ix,iy,alrm_x-vid_vx,alrm_y-vid_vy,c_red);  //i2s(u)+#13+i2s(tar1)+#13+i2s(uo_id)+#13+i2s(buff[ub_stopattack])
           end;
           if(uo_x>0)then
            lineColor(r_screen,ix,iy,uo_x-vid_vx,uo_y-vid_vy,c_white);
        end;

        _draw_text(r_screen,ix,iy,i2s(alrm_r)+#13+b2pm[alrm_b]+#12+i2s(player^.pnum), ta_left,255, _PlayerColor(playeri));}

        if(inapc>0)then continue;

        if(hits>0){and(uidi=UID_URMStation)}then
        begin
           //_draw_text(r_screen,ix,iy,i2s(u)+#13+i2s(tar1)+#13+i2s(uo_id)+#13+i2s(buff[ub_stopattack]), ta_left,255, plcolor[player]);

           //if(tar1>0)then lineColor(r_screen,ix,iy,_units[tar1].x-vid_vx,_units[tar1].y-vid_vy,c_white);
            //lineColor(r_screen,ix+10,iy+10,uo_x-vid_vx,uo_y-vid_vy,c_white);  and(player=HPlayer)
        end;

         //_draw_text(r_screen,imap_mwcx,iy,b2s(painc)+' '+b2s(pains), ta_left,255, plcolor[player]);
         //if(sel)then            i2s(vsnt[_players[player].team])+#13+i2s(vsni[_players[player].team])
         //if(alrm_r<=0)then
         //

        {if(hits>0)then                      +' '+i2s(utrain)
         if(k_shift>2)
         then lineColor(r_screen,ix,iy,uo_x-vid_vx,uo_y-vid_vy,c_black)
         else
           if(alrm_x<>0)then


        _draw_text(r_screen,ix,iy,i2s(u)+' '+i2s(rld_a), ta_left,255, plcolor[player]);// }

        //if(sel)then  circleColor(r_screen,ix,iy,r+5,plcolor[player]);
     end;

   if(k_ctrl>2)then
   for u:=1 to MaxMissiles do
   with _missiles[u] do
   if(vst>0)then
   begin
      ix:=vx-vid_vx+vid_mapx;
      iy:=vy-vid_vy+vid_mapy;

      circleColor(r_screen,ix,iy,5,c_lime);
      _draw_text(r_screen,ix,iy,i2s(dir), ta_left,255, c_white);
   end;

   {for u:=0 to 255 do
    if(ordx[u]>0)then
    begin
       ix:=ordx[u]-vid_vx;
       iy:=ordy[u]-vid_vy;

       _draw_text(r_screen,ix,iy,i2s(u), ta_left,255, c_white);
    end; }
end;


procedure _drawMWSModel(mwsm:PTMWSModel);
var i,x:integer;
begin
   x:=0;
   with mwsm^ do
   begin
      for i:=1 to sn do
       with sl[i-1] do
       begin
          _draw_surf(r_screen,x,0,surf);
          x+=w;
       end;
      _draw_text(r_screen,0,48,i2s(sn), ta_left,255, c_white);
   end;
end;

