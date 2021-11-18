

procedure _draw_texture(tar:pSDL_Surface;x,y:integer;sur:PTMWTexture);
begin
   with sur^ do
   begin
      r_RECT^.x:=x;
      r_RECT^.y:=y;
      r_RECT^.w:=sur^.w;
      r_RECT^.h:=sur^.h;
      SDL_BLITSURFACE(surf,nil,tar,r_RECT);
   end;
end;

procedure _draw_surf(tar:pSDL_Surface;x,y:integer;sur:PSDL_SURFACE);
begin
   r_RECT^.x:=x;
   r_RECT^.y:=y;
   r_RECT^.w:=sur^.w;
   r_RECT^.h:=sur^.h;
   SDL_BLITSURFACE(sur,nil,tar,r_RECT);
end;


procedure _draw_text(sur:pSDL_Surface;x,y:integer;s:shortstring;al,chrs:byte;tc:cardinal);
var ss,i,o:byte;
    ix:integer;
     c:char;
    cl:cardinal;
begin
   ss:=length(s);
   if(ss>0)then
   begin
      if(al in [ta_middle,ta_right])then
      begin
         o:=0;
         for i:=1 to ss do
          if not(s[i] in [#0..#4,#14..#25])then o+=1;

         case al of
         ta_middle: ix:=x-((o*font_w)shr 1);
         ta_right : ix:=x-(o*font_w);
         end;
      end
      else ix:=x;

      o:=0;
      cl:=tc;
      for i:=1 to ss do
      begin
         c:=s[i];

         case c of
         #0..#6  : begin cl:=PlayerGetColor(ord(c));if(i<ss)then continue;end; //tc:=cl;
         #11..#13: ;
         #14     : begin cl:=c_purple       ;if(i<ss)then continue;end;
         #15     : begin cl:=c_red          ;if(i<ss)then continue;end;
         #16     : begin cl:=c_orange       ;if(i<ss)then continue;end;
         #17     : begin cl:=c_yellow       ;if(i<ss)then continue;end;
         #18     : begin cl:=c_lime         ;if(i<ss)then continue;end;
         #19     : begin cl:=c_aqua         ;if(i<ss)then continue;end;
         #20     : begin cl:=c_blue         ;if(i<ss)then continue;end;
         #21     : begin cl:=c_gray         ;if(i<ss)then continue;end;
         #22     : begin cl:=c_white        ;if(i<ss)then continue;end;
         #23     : begin cl:=c_green        ;if(i<ss)then continue;end;
         #25     : begin cl:=tc             ;if(i<ss)then continue;end;
         else
           case c of
             hp_detect : boxColor(sur,ix,y,ix+font_iw,y+font_iw,c_purple);
             hp_pshield: boxColor(sur,ix,y,ix+font_iw,y+font_iw,c_aqua);
             adv_char  : boxColor(sur,ix,y,ix+font_iw,y+font_iw,c_white);
           else
             boxColor(sur,ix,y,ix+font_iw,y+font_iw,cl);
           end;

           _draw_texture(sur,ix,y,@font_ca[c]);

           o  += 1;
           ix += font_w;
         end;

         if(al=ta_left)then
          if(o>=chrs)or(c in [#11..#13])or(i=ss)then
          begin
             if(i<ss)then o:=0;

             ix:=x;
             y +=font_w;
             case c of
             #11 : y+=2;
             #12 : y+=txt_line_h2;
             #13 : y+=txt_line_h;
             else  y+=txt_line_h;
             end;
          end;
      end;
   end;
end;

procedure _LoadingScreen;
begin
   SDL_FillRect(r_screen,nil,0);
   stringColor(r_screen,(vid_vw div 2)-40, vid_vh div 2,@str_loading[1],c_yellow);
   SDL_FLIP(r_screen);
end;



procedure _bmm_draw(sd:TSob);
var d:integer;
begin
   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t in sd)then
      if(mmr>0)
      then FilledcircleColor(r_bminimap,mmx,mmy,mmr,mmc)
      else pixelColor(r_bminimap,mmx,mmy,mmc);
end;

procedure map_bminimap;
begin
   sdl_FillRect(r_bminimap,nil,0);
   _bmm_draw(dids_liquids);
   _bmm_draw([DID_other,DID_srock,DID_brock]);
end;

procedure map_dstarts;
const start_char : char = '+';
var i  :byte;
    x,y:integer;
    c  :cardinal;
begin
   for i:=0 to MaxPlayers do
   begin
      if(g_mode=gm_inv)and(i=0)then continue;

      x:=trunc(map_psx[i]*map_mmcx);
      y:=trunc(map_psy[i]*map_mmcx);

      c:=PlayerGetColor(i);

      characterColor(r_minimap,x-3,y-3,start_char,c);
         circleColor(r_minimap,x,y,trunc(base_r*map_mmcx),c);
   end;

   if(g_mode=gm_cptp)then
    for i:=1 to MaxCPoints do
     with g_cpoints[i] do
      filledcircleColor(r_minimap,mpx,mpy,map_prmm,c_aqua);
end;

procedure _makeMMB;
begin
   sdl_FillRect(r_minimap,nil,0);
   map_bminimap;
   _draw_surf(r_minimap,0,0,r_bminimap);
   if(g_show_positions)or(g_mode in [gm_inv,gm_2fort,gm_3fort])then map_dstarts;
   _draw_surf(spr_mback,ui_menu_map_x0,ui_menu_map_y0,r_minimap);
   rectangleColor(spr_mback,ui_menu_map_x0,ui_menu_map_y0,ui_menu_map_x0+r_minimap^.w,ui_menu_map_y0+r_minimap^.h,c_white);
  // vid_mredraw:=true;
end;

procedure d_timer(tar:pSDL_Surface;x,y:integer;time:cardinal;ta:byte;str:string);
var m,s,h:cardinal;
    hs,ms,ss:string;
begin
   s:=time div fr_fps;
   m:=s div 60;
   s:=s mod 60;
   h:=m div 60;
   m:=m mod 60;
   if(h>0)then
   begin
      if(h<10)then hs:='0'+c2s(h) else hs:=c2s(h);
      str:=hs+':';
   end;
   if(m<10)then ms:='0'+c2s(m) else ms:=c2s(m);
   if(s<10)then ss:='0'+c2s(s) else ss:=c2s(s);
   str:=str+ms+':'+ss;
   _draw_text(tar,x,y,str,ta,255,c_white);
end;

procedure ui_addalrm(aax,aay:integer;aab:boolean);
var i,ni:byte;
begin
   if(_rpls_rst>=rpl_rhead)then exit;

   ni:=255;
   for i:=0 to ui_max_alarms do
    with ui_alarms[i] do
     if(at>0)then
      if(dist2(aax,aay,ax,ay)<=vid_uialrm_mr)and(ab=aab)then
      begin
         ax:=(ax+aax) div 2;
         ay:=(ay+aay) div 2;
         if(at<vid_uialrm_ti)then at:=vid_uialrm_t;
         ni:=i;
         break;
      end;

   if(ni=255)then
    for i:=0 to ui_max_alarms do
     with ui_alarms[i] do
      if(at=0)then
      begin
         ax:=aax;
         ay:=aay;
         ab:=aab;
         at:=vid_uialrm_t;
         if((vid_mmvx-vid_uialrm_ti)>ax)or(ax>(vid_mmvx+map_mmvw+vid_uialrm_ti))or   // vid_mmvx,vid_mmvy,vid_mmvx+map_mmvw,vid_mmvy+map_mmvh
           ((vid_mmvy-vid_uialrm_ti)>ay)or(ay>(vid_mmvy+map_mmvh+vid_uialrm_ti))then PlayInGameAnoncer(snd_under_attack[aab,_players[HPlayer].race]);
         break;
      end;
end;



