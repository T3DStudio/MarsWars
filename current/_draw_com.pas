
////////////////////////////////////////////////////////////////////////////////
//
//    Other

function rgba2c(r,g,b,a:byte):cardinal;
begin
   rgba2c:=a+(b shl 8)+(g shl 16)+(r shl 24);
end;

function ShadowColor(c:cardinal):cardinal;
begin
   ShadowColor:=128 +
   (((c and $FF000000) shr 25) shl 24) +
   (((c and $00FF0000) shr 17) shl 16) +
   (((c and $0000FF00) shr  9) shl 8 );
end;

procedure draw_mwtexture(s_dst:pSDL_Surface;x,y:integer;mwt_src:PTMWTexture);
begin
   with mwt_src^ do
   begin
      r_RECT^.x:=x;
      r_RECT^.y:=y;
      r_RECT^.w:=mwt_src^.w;
      r_RECT^.h:=mwt_src^.h;
      SDL_BLITSURFACE(sdlSurface,nil,s_dst,r_RECT);
   end;
end;

procedure draw_surf(s_dst:pSDL_Surface;x,y:integer;s_src:pSDL_Surface);
begin
   r_RECT^.x:=x;
   r_RECT^.y:=y;
   r_RECT^.w:=s_src^.w;
   r_RECT^.h:=s_src^.h;
   SDL_BLITSURFACE(s_src,nil,s_dst,r_RECT);
end;

procedure draw_set_FontSize1(size:integer);
begin
   case size of
   15 : draw_font:=@font_1h;
   20 : draw_font:=@font_2;
   30 : draw_font:=@font_3;
   else draw_font:=@font_1;
        size:=10;
   end;

   draw_font_w1  := round(basefont_w1*size/10);
   draw_font_wi  := draw_font_w1-1;
   draw_font_wh  := draw_font_w1 div 2;
   draw_font_wq  := draw_font_w1 div 4;
   draw_font_w1h := draw_font_wh*3;
   draw_font_wq3 :=(draw_font_w1 div 4)*3;

   draw_font_h1  :=(draw_font_w1+draw_font_wq);
   draw_font_h2  :=(draw_font_w1+draw_font_wh);
end;

procedure draw_text(sur:pSDL_Surface;x,y:integer;str:shortstring;alignment,MaxLineLength:byte;BaseColor:cardinal);
var
strLen,
i,charn,
line_l,
line_n: byte;
ix,iy : integer;
charc : char;
bcolor,
tcolor: cardinal;
begin
   if(BaseColor=0)then exit;
   strLen:=length(str);
   if(strLen=0)then exit;
   if(MaxLineLength<1)then MaxLineLength:=1;

   line_l:=0;
   line_n:=1;
   charn :=0;
   for i:=1 to strLen do
   begin
      if not(str[i] in tc_SpecialChars)then charn+=1;
      if(charn>line_l)then line_l:=charn;
      if(charn=MaxLineLength)or(str[i] in [tc_nl1..tc_nl2])then
      begin
         line_n+=1;
         line_l:=0;
      end;
   end;

   case alignment of //  X
   ta_chat,
   ta_LU,
   ta_LM,
   ta_LD  : ix:=x;
   ta_MU,
   ta_MM,
   ta_MD  : ix:=x-((line_l*draw_font_w1) div 2);
   ta_RU,
   ta_RM,
   ta_RD  : ix:=x- (line_l*draw_font_w1);
   else
   end;

   case alignment of //  Y
   ta_chat,
   ta_LU,
   ta_MU,
   ta_RU  : iy:=y;
   ta_LM,
   ta_MM,
   ta_RM  : if(line_n>1)
            then iy:=y-((line_n*draw_font_w1h) div 2)+draw_font_wh
            else iy:=y-draw_font_wh;
   ta_LD,
   ta_MD,
   ta_RD  : if(line_n>1)
            then iy:=y- (line_n*draw_font_w1h)+draw_font_wh
            else iy:=y-draw_font_w1;
   end;

   if(alignment=ta_chat)and(strLen>MaxLineLength)
   then i:=strLen-MaxLineLength
   else i:=1;

   x:=ix;
   y:=iy;

   charn:=0;
   tcolor:=BaseColor;
   while i<=strLen do
   begin
      charc:=str[i];

      case charc of
      tc_player0..
      tc_player7  : tcolor:=PlayerColorScheme[ord(charc)];
      tc_nl1,
      tc_nl2      : begin
                       x:=ix;
                       case charc of
                       tc_nl1 : y+=draw_font_h1;
                       tc_nl2 : y+=draw_font_h2;
                       end;
                    end;
      tc_purple   : tcolor:=c_purple ;
      tc_red      : tcolor:=c_red    ;
      tc_orange   : tcolor:=c_orange ;
      tc_yellow   : tcolor:=c_yellow ;
      tc_lime     : tcolor:=c_lime   ;
      tc_aqua     : tcolor:=c_aqua   ;
      tc_blue     : tcolor:=c_blue   ;
      tc_gray     : tcolor:=c_gray   ;
      tc_dgray    : tcolor:=c_dgray  ;
      tc_white    : tcolor:=c_white  ;
      tc_green    : tcolor:=c_green  ;
      tc_default  : tcolor:=BaseColor;
      else
         case charc of
         char_detect  : bcolor:=c_purple;
         char_advanced: bcolor:=c_white;
         ',',';','[',
         ']','{','}'  : bcolor:=BaseColor;
         else           bcolor:=tcolor;
         end;
         boxColor(sur,x,y,x+draw_font_wi,y+draw_font_wi,bcolor);

         draw_mwtexture(sur,x,y,@(draw_font^[charc]));

         charn+= 1;
         x    += draw_font_w1;
         if(charn>=MaxLineLength)then
         begin
            x:=ix;
            y+=draw_font_h2;
            charn:=0;
         end;
      end;
      if(i=255)and(strLen=255)then break;
      i+=1;
   end;
end;

procedure DrawLoadingScreen(CaptionString:shortstring;color:cardinal);
begin
   SDL_FillRect(r_screen,nil,0);
   draw_text(r_screen,vid_vw div 2,vid_vh div 2,CaptionString,ta_MU,255,color);
   SDL_FLIP(r_screen);
end;

function TileSetGetN(b00,b10,b20,
                     b01,b11,b21,
                     b02,b12,b22:boolean):integer;
begin
   TileSetGetN:=-1;
   if(b11)
   then TileSetGetN:=0
   else
   begin
      TileSetGetN:=0;
      if(b00)then TileSetGetN+=1;
      if(b10)then TileSetGetN+=2;
      if(b20)then TileSetGetN+=4;
      if(b01)then TileSetGetN+=8;
      if(b21)then TileSetGetN+=16;
      if(b02)then TileSetGetN+=32;
      if(b12)then TileSetGetN+=64;
      if(b22)then TileSetGetN+=128;
      if(TileSetGetN=0)then TileSetGetN:=-1;
   end;
end;

procedure d_timer(tar:pSDL_Surface;x,y:integer;time:cardinal;ta:byte;str:shortstring;color:cardinal);
begin
   draw_text(tar,x,y,str+str_GStep2Time(time),ta,255,color);
end;

////////////////////////////////////////////////////////////////////////////////
//
//    Minimap

procedure map_MinimapBackground;
var
gx ,gy :integer;
mmx,mmy:single;
begin
   sdl_FillRect(r_bminimap,nil,0);

   mmx:=0;
   for gx:=0 to map_LastCell do
   begin
      mmy:=0;
      for gy:=0 to map_LastCell do
      begin
         case map_grid[gx,gy].tgc_solidlevel of
mgsl_nobuild : boxColor(r_bminimap,trunc(mmx),trunc(mmy),trunc(mmx+map_mm_gridW),trunc(mmy+map_mm_gridW),c_ltgray);
mgsl_liquid  : boxColor(r_bminimap,trunc(mmx),trunc(mmy),trunc(mmx+map_mm_gridW),trunc(mmy+map_mm_gridW),theme_cur_liquid_mmcolor);
mgsl_rocks   : boxColor(r_bminimap,trunc(mmx),trunc(mmy),trunc(mmx+map_mm_gridW),trunc(mmy+map_mm_gridW),c_gray  );
         end;

         mmy+=map_mm_gridW;
      end;
      mmx+=map_mm_gridW;
   end;
end;

procedure map_MinimapSpot(tar:pSDL_Surface;x,y,r:integer;sym:char;color:cardinal);
begin
   circleColor   (tar,x  ,y  ,r  ,color);
   characterColor(tar,x-3,y-3,sym,color);
end;

procedure map_MinimapPlayerStarts(tar:pSDL_Surface;UnknownStarts,teamStarts:boolean);
var i    :byte;
    x,y,r:integer;
begin
   for i:=0 to LastPlayer do
   begin
      x:=round(map_PlayerStartX[i]*map_mm_cx);
      y:=round(map_PlayerStartY[i]*map_mm_cx);
      r:=trunc(base_1r*map_mm_cx);

      // clear
      filledcircleColor(tar,x,y,r ,c_black);
            circleColor(tar,x,y,r ,c_black);
         characterColor(tar,x,y,#8,c_black);

      if(UnknownStarts)then
      begin
         if(teamStarts)
         then map_MinimapSpot(tar,x,y,r,chr(ord('1')+PlayerSlotGetTeam(g_mode,i,255)),c_white)
         else map_MinimapSpot(tar,x,y,r,'?',c_white)
      end
      else
        if (g_slot_state[i]<>pss_closed  )
        and(g_slot_state[i]<>pss_observer)
        then
          if(g_players[i].player_type>pt_none)or(g_ai_slots>0)
          then map_MinimapSpot(tar,x,y,r,b2s(i+1)[1],PlayerColorScheme[i])
          else map_MinimapSpot(tar,x,y,r,'+'        ,c_white);
   end;

   {x:=round(map_symmetryX0*map_mm_cx);
   y:=round(map_symmetryY0*map_mm_cx);
   lineColor(r_minimap,
   x,y,
   round(map_symmetryX1*map_mm_cx),
   round(map_symmetryY1*map_mm_cx),
   c_lime);

   lineColor(r_minimap,
   x,y,
   x-(round(map_symmetryX1*map_mm_cx)-x),
   y-(round(map_symmetryY1*map_mm_cx)-y),
   c_lime); }
end;

procedure map_MinimapCPoints(tar:pSDL_Surface);
var i  :byte;
begin
   for i:=1 to MaxCPoints do
    with g_cpoints[i] do
     if(cpCaptureR>0)then
      if((i=0)and(g_mode=gm_koth))or(cpenergy<=0)
      then map_MinimapSpot(tar,cpmx,cpmy,cpmr,char_cp ,c_purple)
      else map_MinimapSpot(tar,cpmx,cpmy,cpmr,char_gen,c_white );
end;

procedure map_RedrawMenuMinimap;
begin
   sdl_FillRect(r_mminimap,nil,0);
   draw_surf(r_mminimap,0,0,r_bminimap);

   map_MinimapPlayerStarts(r_mminimap,not g_fixed_positions,g_mode in gm_ModesFixedTeams);
   map_MinimapCPoints(r_mminimap);
end;



function ui_AddMarker(ax,ay:integer;av:byte;new:boolean):boolean;
var i,ni,mx,my:integer;
begin
   {
   new  false - not required new alarm point
        true  - required
   return - true if alarm created
   }
   ui_AddMarker:=false;

   ax:=mm3i(1,ax,map_size);
   ay:=mm3i(1,ay,map_size);

   mx:=trunc(ax*map_mm_cx);
   my:=trunc(ay*map_mm_cx);

   if(not new)then
    for i:=0 to ui_max_alarms do
     with ui_alarms[i] do
      if(al_t>0)and(al_v=av)then
       if(point_dist_rint(al_mx,al_my,mx,my)<=ui_alarm_time)then
       begin
          al_x :=(al_x +ax) div 2;
          al_y :=(al_y +ay) div 2;
          al_mx:=(al_mx+mx) div 2;
          al_my:=(al_my+my) div 2;
          al_t :=ui_alarm_time;
          exit;
       end;

   ni:=0;
   for i:=0 to ui_max_alarms do
    if(ui_alarms[i].al_t<ui_alarms[ni].al_t)
    then ni:=i;

   with ui_alarms[ni] do
    if(al_t<=0)or(not new)then
    begin
       al_x :=ax;
       al_y :=ay;
       al_mx:=mx;
       al_my:=my;
       al_v :=av;
       al_t :=ui_alarm_time;
       case al_v of
aummat_attacked_u,
aummat_attacked_b : al_c:=c_red;
aummat_created_u,
aummat_created_b  : al_c:=c_lime;
aummat_advance    : al_c:=c_aqua;
aummat_upgrade    : al_c:=c_yellow;
aummat_info       : al_c:=c_white;
       end;
       ui_AddMarker:=true;
    end;
end;

function LogMes2UIAlarm:boolean;
begin
   // true  - need announcer sound
   // false - no need announcer sound

   if(UIPlayer>LastPlayer)
   then LogMes2UIAlarm:=false
   else
   begin
      LogMes2UIAlarm:=true;
      with g_players[UIPlayer] do
        with log_l[log_i] do
          case mtype of
lmt_unit_advanced    :      ui_AddMarker(xi,yi,aummat_advance   ,true);
lmt_unit_ready       : if(g_uids[argx]._ukbuilding)
                       then ui_AddMarker(xi,yi,aummat_created_b ,true)
                       else ui_AddMarker(xi,yi,aummat_created_u ,true);
lmt_upgrade_complete :      ui_AddMarker(xi,yi,aummat_upgrade   ,true);
lmt_map_mark         :      ui_AddMarker(xi,yi,aummat_info      ,true);
lmt_allies_attacked,
lmt_unit_attacked    : begin
                       if(g_uids[argx]._ukbuilding)
                       then ui_AddMarker(xi,yi,aummat_attacked_b,false)
                       else ui_AddMarker(xi,yi,aummat_attacked_u,false);
                       LogMes2UIAlarm:=not PointInCam(xi,yi);
                       end;
          end;
   end;
end;


