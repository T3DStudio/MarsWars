function ShadowColor(c:cardinal):cardinal;
begin
   ShadowColor:=128 +
   (((c and $FF000000) shr 25) shl 24) +
   (((c and $00FF0000) shr 17) shl 16) +
   (((c and $0000FF00) shr  9) shl 8 );
end;

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
   if(tc=0)then exit;
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
         ta_right : ix:=x- (o*font_w);
         end;
      end
      else ix:=x;

      if(al=ta_chat)and(ss>chrs)
      then i:=ss-chrs
      else i:=1;

      o:=0;
      cl:=tc;
      for i:=i to ss do
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
            char_detect  : boxColor(sur,ix,y,ix+font_iw,y+font_iw,c_purple);
            char_advanced: boxColor(sur,ix,y,ix+font_iw,y+font_iw,c_white );
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
      else pixelColor       (r_bminimap,mmx,mmy,    mmc);
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
      if(g_mode=gm_invasion)and(i=0)then continue;

      x:=round(map_psx[i]*map_mmcx);
      y:=round(map_psy[i]*map_mmcx);

      c:=PlayerGetColor(i);

      characterColor(r_minimap,x-3,y-3,start_char,c);
         circleColor(r_minimap,x,y,trunc(base_r*map_mmcx),c);
   end;

   case g_mode of
gm_ecapture,
gm_KotH,
gm_capture: for i:=1 to MaxCPoints do
             with g_cpoints[i] do
              if(cpcapturer>0)then filledcircleColor(r_minimap,cpmx,cpmy,cpmr,c_purple);
    end;
end;

procedure map_RedrawMenuMinimap;
begin
   sdl_FillRect(r_minimap,nil,0);
   map_bminimap;
   _draw_surf(r_minimap,0,0,r_bminimap);
   if(g_show_positions)or(g_mode in [gm_invasion,gm_3x3,gm_2x2x2])then map_dstarts;
   _draw_surf(spr_mback,ui_menu_map_x0,ui_menu_map_y0,r_minimap);
   rectangleColor(spr_mback,ui_menu_map_x0,ui_menu_map_y0,ui_menu_map_x0+r_minimap^.w,ui_menu_map_y0+r_minimap^.h,c_white);
   vid_menu_redraw:=vid_menu_redraw or _menu;
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

function ui_addalrm(ax,ay:integer;av:byte;new:boolean):boolean;
var i,mx,my:integer;
begin
   ui_addalrm:=false;

   if(ax>map_mw)
   or(ay>map_mw)then exit;

   mx:=trunc(ax*map_mmcx);
   my:=trunc(ay*map_mmcx);

   if(not new)then
   for i:=0 to ui_max_alarms do
    with ui_alarms[i] do
     if(al_t>0)and(al_v=av)then
      if(dist2(al_mx,al_my,mx,my)<=vid_uialrm_t)then
      begin
         al_x :=(al_x +ax) div 2;
         al_y :=(al_y +ay) div 2;
         al_mx:=(al_mx+mx) div 2;
         al_my:=(al_my+my) div 2;
         al_t:=vid_uialrm_t;
         ui_addalrm:=true;
         exit;
      end;

   for i:=0 to ui_max_alarms do
    with ui_alarms[i] do
     if(al_t<=0)then
     begin
        al_x :=ax;
        al_y :=ay;
        al_mx:=mx;
        al_my:=my;
        al_v :=av;
        al_t :=vid_uialrm_t;
        case al_v of
aummat_attacked_u,
aummat_attacked_b: al_c:=c_red;
aummat_created_u,
aummat_created_b : al_c:=c_lime;
aummat_advance,
aummat_upgrade   : al_c:=c_yellow;
aummat_info      : al_c:=c_white;
        end;
        if((vid_mmvx-vid_uialrm_ti)>mx)or(mx>(vid_mmvx+map_mmvw+vid_uialrm_ti))or
          ((vid_mmvy-vid_uialrm_ti)>my)or(my>(vid_mmvy+map_mmvh+vid_uialrm_ti))then ui_addalrm:=true;
        break;
     end;

 {
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
           ((vid_mmvy-vid_uialrm_ti)>ay)or(ay>(vid_mmvy+map_mmvh+vid_uialrm_ti))then SoundPlayAnoncer(snd_under_attack[aab,_players[HPlayer].race],true);
         break;
      end; }
end;
{

lmt_chat0              = 0;  = player humber
lmt_chat1              = 1;
lmt_chat2              = 2;
lmt_chat3              = 3;
lmt_chat4              = 4;
lmt_chat5              = 5;
lmt_chat6              = 6;
lmt_game_message       = 10;
lmt_game_end           = 11;
lmt_player_defeated    = 12;
lmt_player_leave       = 13;
lmt_cant_build         = 14;
lmt_unit_ready         = 15;
lmt_unit_advanced      = 16;
lmt_upgrade_complete   = 17;
lmt_req_energy         = 18;
lmt_req_common         = 19;
lmt_req_ruids          = 20;
lmt_player_chat        = 255;
}

function LogMes2UIAlarm:boolean;
begin
   LogMes2UIAlarm:=true;
   with _players[HPlayer] do
   with log_l[log_i] do
   case mtype of
lmt_unit_advanced    : ui_addalrm(x,y,aummat_advance,true);
lmt_unit_ready       : if(_uids[uid]._ukbuilding)
                       then ui_addalrm(x,y,aummat_created_b,true)
                       else ui_addalrm(x,y,aummat_created_u,true);
lmt_upgrade_complete : ui_addalrm(x,y,aummat_upgrade,true);
lmt_map_mark         : LogMes2UIAlarm:=ui_addalrm(x,y,aummat_info   ,true);
   end;
end;


