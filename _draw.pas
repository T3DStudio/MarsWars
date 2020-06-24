
procedure D_terrain;
var i,ix,iy,s,
    vx,vy:integer;
    spr:PTUsprite;
begin
   _draw_surf(_screen,-vid_vx mod ter_w,-vid_vy mod ter_h, ter_surf);

   vx:=vid_vx-vid_ab;
   vy:=vid_vy-vid_ab;

   for i:=1 to map_ADecn do
   begin
      with map_ADecs[i-1] do
      begin
         ix:=x-vx+vid_mwa;
         iy:=y-vy+vid_mha;
      end;
      s:=abs(i+(iy div vid_mha)+(ix div vid_mwa));

      with map_themes[map_themec] do
      begin
         s:=s mod _adecn;

         if(s=0)then continue;
         spr:=@spr_ADecs[_adecs[s],(i and $0001)>0];
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

procedure D_Fog;
var cx,cy,ssx,ssy,sty:integer;
begin
   if(ui_mc_a>0)then
   begin
      ssx:=ui_mc_a;
      ssy:=ssx shr 1;
      ellipseColor(_screen,ui_mc_x-vid_vx,ui_mc_y-vid_vy,ssx,ssy,ui_mc_c);

      if(G_Status=0)then dec(ui_mc_a,1);
   end;

   ssx:=-(vid_vx and %0000000000011111); //mod fog_cw;
   sty:=-(vid_vy and %0000000000011111); //mod fog_cw;

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

   for cx:=1 to ui_bldrrsi do circleColor(_screen,ui_bldrrsx[cx]-vid_vx,ui_bldrrsy[cx]-vid_vy,ui_bldrrsr[cx],c_white);
end;

procedure _draw_dbg;
var u,ix,iy,i:integer;
begin
   //_draw_text(_screen,750,0,i2s(m_mx)+' '+i2s(m_my) , ta_right,255, c_white);

   if(k_shift>2) then
   for u:=0 to MaxPlayers do
    with _players[u] do
    begin
       ix:=50+110*u;

       _draw_text(_screen,ix,70 ,b2s(u) , ta_FVLeft,255, color);
       _draw_text(_screen,ix,80 ,b2s(cenerg)+' '+b2s(menerg)+' '+#18+b2s(_lsuc) , ta_FVLeft,255, c_white);
       _draw_text(_screen,ix,90 ,#16+i2s(army)+' '#18+i2s(sarmy) , ta_FVLeft,255, c_white);
       _draw_text(_screen,ix,110,#16+i2s(uid_b)+' '#18+i2s(uid_sb) , ta_FVLeft,255, c_white);
       _draw_text(_screen,ix,120,#16+i2s(uid_u)+' '#18+i2s(uid_su) , ta_FVLeft,255, c_white);

       _draw_text(_screen,ix,140,#16+i2s(_bldrs) , ta_FVLeft,255, c_white);
       _draw_text(_screen,ix,150,#16+i2s(_brcks)+' '#18+i2s(_sbrcks) , ta_FVLeft,255, c_white);
       _draw_text(_screen,ix,160,#16+i2s(_smths) , ta_FVLeft,255, c_white);

       //for iy:=0 to 8  do _draw_text(_screen,ix,120+iy*10,b2s(u_e[true ,iy])+' '+b2s(u_s[true ,iy])+' '+i2s(ubx[iy]), ta_FVLeft,255, plcolor[u]);
       //for iy:=0 to 11 do _draw_text(_screen,ix,220+iy*10,b2s(u_e[false,iy])+' '+b2s(u_s[false,iy]), ta_FVLeft,255, plcolor[u]);
    end;
   //_draw_text(_screen,0,8,i2s(m_brush)+' '+i2s(m_brtar) , ta_FVLeft,255, c_white);


   if(k_ctrl>2)then
   for u:=1 to MaxUnits do
    with _units[u] do
    with _tuids[uid] do
     //if(hits>dead_hits)and(player=HPlayer)then
     begin
        ix:=x-vid_vx;
        iy:=y-vid_vy;

        circleColor(_screen,ix,iy,_r,c_gray);
        circleColor(_screen,ix,iy,a_rng[a_weap],c_lgray);
        circleColor(_screen,ix,iy,srng,c_white);
        circleColor(_screen,uo_x[0]-vid_vx,uo_y[0]-vid_vy,5,c_white);

      {  if(inapc>0)then continue;

        if(hits>0)and(uid=UID_URocketL)then
        begin
           if(alrm_x>0)then lineColor(_screen,ix,iy,alrm_x-vid_vx,alrm_y-vid_vy,plcolor[player]);
           //if(tar1>0)then lineColor(_screen,ix,iy,_units[tar1].x-vid_vx,_units[tar1].y-vid_vy,c_white);
            lineColor(_screen,ix+10,iy+10,uo_x-vid_vx,uo_y-vid_vy,c_white);
        end;  }

        //i2s(fsr)+' '+i2s(buff[ub_invis])+' '+
        //if(bld)then         +i2s(uo_id)+' '+i2s(uo_tar)+#12+i2s(ua_id)+' '+i2s(ua_tar)+#12+i2s(a_tar)+#12+b2s(player)+' '+#12+b2pm[sel]
         _draw_text(_screen,ix,iy,i2s(up_r), ta_left,255, _players[player].color); //+i2s(ua_id)+' '+i2s(uo_tar)+' '+i2s(a_tar)

        //if(apcc>0)then
        //_draw_text(_screen,ix,iy,i2s(a_tar), ta_left,255, _players[player].color);
        //for i:=0 to uo_n do _draw_text(_screen,ix,iy+(i+1)*10,' '+i2s(uo_id[i])+' '+i2s(uo_tar[i])+' '+i2s(uo_x[i])+' '+i2s(uo_y[i]), ta_left,255, _players[player].color);


        //if(hits>0)then
        // if(k_shift>2)
        // then lineColor(_screen,ix,iy,uo_x[0]-vid_vx,uo_y[0]-vid_vy,c_aqua);
         {else
           if(alrm_x<>0)then
            lineColor(_screen,ix,iy,alrm_x-vid_vx,alrm_y-vid_vy,plcolor[player]); }

        //_draw_text(_screen,ix,iy,i2s(u)+' '+i2s(rld_a), ta_left,255, plcolor[player]);// }

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
   D_objects;

   D_terrain;
   D_SpriteList;
   D_Fog;
   D_UnitOrderList;
   D_UI;

   if(_testmode)then _draw_dbg;
end;

procedure _drawGame;
begin
   if(_menu)
   then D_Menu
   else D_Game;

   SDL_Flip(_screen);
end;

