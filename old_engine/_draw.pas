{
x,y,depth,shadow z, rectangle color, amask color, spr, alpha, bar cx,
}

procedure _sl_add(ax,ay,ad,ash:integer;arc,amsk:cardinal;arct:boolean;aspr:pSDL_surface;ainv:byte;abar:single;aclu:integer;acrl,acll:byte;acru:string6;aro:integer);
begin
   if(vid_vsls<vid_mvs){and(G_Paused=0)}and(_menu=false)then
   begin
      inc(vid_vsls,1);
      with vid_vsl[vid_vsls] do
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
      end;
   end;
end;

procedure _sv_sort;
var i,u:word;
    dt:TVisSpr;
begin
   if(vid_vsls>1)then
    for i:=1 to vid_vsls do
     for u:=1 to (vid_vsls-1) do
      if (vid_vsl[u].d<vid_vsl[u+1].d) then
      begin
        dt:=vid_vsl[u];
        vid_vsl[u]:=vid_vsl[u+1];
        vid_vsl[u+1]:=dt;
      end;
end;

procedure D_SpriteList;
var sx,sy:integer;
begin
   _sv_sort;
   while(vid_vsls>0)do
    with vid_vsl[vid_vsls] do
    begin
       if(sh>0)then
       begin
          sx:=(s^.w shr 1);
          sy:=s^.h-(s^.h shr 3);
          filledellipseColor(_screen,x+sx,y+sy+sh,sx,s^.h shr 2,c_ablack);
       end;
       SDL_SetAlpha(s,SDL_SRCALPHA or SDL_RLEACCEL,inv);

       if(inv>0)then _draw_surf(_screen,x,y,s);

       if(msk>0)or(ro>0)then
       begin
          sx:=s^.w shr 1;
          sy:=s^.h shr 1;
          if(msk>0)then filledellipseColor(_screen,x+sx,y+sy,sx,sy,msk);
          if(ro >0)then circleColor(_screen,x+sx,y+sy,ro,c_gray);
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
             if(rct)then rectangleColor(_screen,x-1,y-1,x+s^.w,y+sx, rc);
             if(bar>0)then
             begin
                boxColor(_screen,x-1,y-4,x+s^.w           ,y-1,c_black);
                boxColor(_screen,x-1,y-4,x+trunc(bar*s^.w),y-1,rc);
             end;
          end;
          if(clu >0 )then _draw_text(_screen,x     ,y          ,i2s(clu),ta_left ,255,c_white);
          if(cru<>'')then _draw_text(_screen,x+s^.w,y          ,cru     ,ta_right,3,c_white);
          if(cll >0 )then _draw_text(_screen,x     ,y+sx-font_w,b2s(cll),ta_left ,255,c_white);
          if(crl >0 )then _draw_text(_screen,x+s^.w,y+sx-font_w,b2s(crl),ta_right,255,c_white);
       end;

       y:=sy;

       SDL_SetAlpha(s,SDL_SRCALPHA or SDL_RLEACCEL,255);

       dec(vid_vsls,1);
    end;

   if(ui_mc_a>0)then
   begin
      sx:=ui_mc_a;
      sy:=sx shr 1;
      ellipseColor(_screen,ui_mc_x-vid_vx,ui_mc_y-vid_vy,sx,sy,ui_mc_c);

      dec(ui_mc_a,1);
   end;
end;

procedure D_terrain;
var i,ix,iy,s:integer;
    vx,vy:integer;
    spr:PTUsprite;
begin
   _draw_surf(_screen,vid_panel-((vid_vx+vid_panel) mod ter_w),-vid_vy mod ter_h, vid_terrain);

   vx:=vid_vx-vid_ab;
   vy:=vid_vy-vid_ab;

   for i:=1 to MaxTDecsS do
    with _TDecs[i-1] do
    begin
       ix:=x-vx+vid_mwa;
       iy:=y-vy+vid_mha;

       s:=abs(i+(iy div vid_mha)+(ix div vid_mwa)) mod t_decsi;

       case s of
       0: continue;
       1..crater_ri: spr:=@spr_crater[s];
       else
         if(spr_tdecsi>0)
         then spr:=@spr_tdecs[s-crater_ri-1]
         else continue;
       end;

       ix:=ix mod vid_mwa;
       iy:=iy mod vid_mha;

       if(ix<0)then ix:=vid_mwa+ix;
       if(iy<0)then iy:=vid_mha+iy;

       dec(ix,vid_ab);
       dec(iy,vid_ab);

       _draw_surf(_screen,ix-spr^.hw,iy-spr^.hh,spr^.surf);
    end;
end;

procedure D_fog;
var cx,cy,ssx,ssy,sty:integer;
begin
   ssx:=vid_panel-((vid_vx+vid_panel) and %0000000000011111); //mod fog_cw;
   sty:=          -(vid_vy            and %0000000000011111); //mod fog_cw;

   for cx:=0 to fog_vfw do
   begin
      ssy:=sty;
      for cy:=0 to fog_vfh do
      begin
         fog_pgrid[cx,cy]:=fog_grid[cx,cy];
         if(_fog)then
         begin
            case fog_grid[cx,cy] of
               0 : _draw_surf(_screen,ssx-fog_chw, ssy-fog_chw, fog_surf[true ]);
               1 : _draw_surf(_screen,ssx-fog_cxr, ssy-fog_cxr, fog_surf[false]);
            else
            end;
            fog_grid[cx,cy]:=0;
         end
         else fog_grid[cx,cy]:=2;
         inc(ssy,fog_cw);
      end;
      inc(ssx,fog_cw);
   end;


   if(g_mode=gm_ct)then
    for cx:=1 to MaxPlayers do
     with g_ct_pl[cx] do
     begin
        circleColor(_screen,px-vid_vx,py-vid_vy,g_ct_pr,plcolor[pl]);
        //if(_testmode)then _draw_text(_screen,px-vid_vx,py-vid_vy,i2s(ct) , ta_left,255, plcolor[pl]);

        if(vid_rtui=0)then
        begin
           if(ct>0)and((G_Step mod 20)>10)
           then circleColor(_minimap,mpx,mpy,map_prmm,c_gray)
           else circleColor(_minimap,mpx,mpy,map_prmm,plcolor[pl]);
        end;
     end;

   if(menu_s2=ms2_camp)then
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
         boxColor(_screen,vid_panel,0,vid_mw,vid_mh,rgba2c(255,255,255,ui_msk));
         if(vid_rtui=0)then dec(ui_msks,1);
      end;
   end;
end;

procedure _draw_dbg;
var u,ix,iy:integer;
begin
   //_draw_text(_screen,750,0,i2s(m_mx)+' '+i2s(m_my) , ta_right,255, c_white);
   //_draw_text(_screen,750,0,i2s(spr_tdecsi), ta_right,255, c_white);

   //_draw_text(_screen,750,0,b2pm[map_ffly] , ta_right,255, c_white);


   if(k_shift>2) then
   for u:=0 to MaxPlayers do
    with _players[u] do
    begin
       ix:=170+89*u;

       _draw_text(_screen,ix,80,b2s(u_cs[false]), ta_middle,255, plcolor[u]);

       _draw_text(_screen,ix,90,b2s(army)+' '+b2s(u_c[false]) , ta_middle,255, plcolor[u]);

       _draw_text(_screen,ix,100,b2s(ai_skill)+' '+b2s(ai_maxarmy)+' '+b2s(ai_attack) , ta_middle,255, plcolor[u]);
       _draw_text(_screen,ix,110,b2s(cenerg  )+' '+b2s(menerg) , ta_middle,255, plcolor[u]);


       for iy:=0 to 8  do _draw_text(_screen,ix,130+iy*10,b2s(u_e[true ,iy])+'/'+b2s(u_eb[true ,iy])+' '+b2s(u_s[true ,iy])+' '+i2s(ubx[iy]), ta_left,255, plcolor[u]);
       for iy:=0 to 11 do _draw_text(_screen,ix,230+iy*10,b2s(u_e[false,iy])+' '+b2s(u_s[false,iy]), ta_left,255, plcolor[u]);
    end;

   if(k_ctrl>2)then
   for u:=1 to MaxUnits do
    with _units[u] do
     if(hits>dead_hits)then
     begin
        ix:=x-vid_vx;
        iy:=y-vid_vy;

        if(_testdmg)then
        begin
           _draw_text(_screen,ix,iy-12,i2s(bld_s), ta_left,255, c_white);
           continue;
        end;

        if(hits>0)then
        if(k_shift>1)then
        begin
           circleColor(_screen,ix,iy,r,c_gray);
           circleColor(_screen,ix,iy,sr,c_gray);
           if(sel)then lineColor(_screen,ix,iy,uo_x-vid_vx,uo_y-vid_vy,plcolor[player]);
        end;

        if(hits>0)and(inapc=0)then
        if(player=HPlayer)then
        begin
           lineColor(_screen,ix,iy,alrm_x-vid_vx,alrm_y-vid_vy,c_red);  //i2s(u)+#13+i2s(tar1)+#13+i2s(uo_id)+#13+i2s(buff[ub_stopafa])
           if(uo_x>0)then
            lineColor(_screen,ix,iy,uo_x-vid_vx,uo_y-vid_vy,c_white);
        end;

        _draw_text(_screen,ix,iy,i2s(alrm_r)+#13+b2pm[alrm_b], ta_left,255, plcolor[player]);

        if(inapc>0)then continue;

        if(hits>0){and(uid=UID_URocketL)}then
        begin
           //_draw_text(_screen,ix,iy,i2s(u)+#13+i2s(tar1)+#13+i2s(uo_id)+#13+i2s(buff[ub_stopafa]), ta_left,255, plcolor[player]);

           //if(tar1>0)then lineColor(_screen,ix,iy,_units[tar1].x-vid_vx,_units[tar1].y-vid_vy,c_white);
            //lineColor(_screen,ix+10,iy+10,uo_x-vid_vx,uo_y-vid_vy,c_white);  and(player=HPlayer)
        end;

         //_draw_text(_screen,imap_mwcx,iy,b2s(painc)+' '+b2s(pains), ta_left,255, plcolor[player]);
         //if(sel)then            i2s(vsnt[_players[player].team])+#13+i2s(vsni[_players[player].team])
         //if(alrm_r<=0)then
         //

        {if(hits>0)then                      +' '+i2s(utrain)
         if(k_shift>2)
         then lineColor(_screen,ix,iy,uo_x-vid_vx,uo_y-vid_vy,c_black)
         else
           if(alrm_x<>0)then


        _draw_text(_screen,ix,iy,i2s(u)+' '+i2s(rld_a), ta_left,255, plcolor[player]);// }

        //if(sel)then  circleColor(_screen,ix,iy,r+5,plcolor[player]);
     end;

   {for u:=0 to 255 do
    if(ordx[u]>0)then
    begin
       ix:=ordx[u]-vid_vx;
       iy:=ordy[u]-vid_vy;

       _draw_text(_screen,ix,iy,i2s(u), ta_left,255, c_white);
    end; }
end;

procedure D_Game;
begin
   D_terrain;
   D_SpriteList;
   D_fog;
   D_ui;
   D_UIText;
   if(m_sxs>-1)then rectangleColor(_screen,m_sxs-vid_vx, m_sys-vid_vy, m_vx, m_vy, plcolor[HPlayer]);
   d_uimouse;

   if(_testmode>1)and(net_nstat=0)then _draw_dbg;
end;


procedure DrawGame;
begin
   SDL_FillRect(_screen,nil,0);

   if(_menu)
   then D_Menu
   else D_Game;

   sdl_flip(_screen);
end;



