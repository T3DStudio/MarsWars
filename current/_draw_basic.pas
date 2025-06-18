
////////////////////////////////////////////////////////////////////////////////
//
//    Other


function gfx_MakeAlphaTMWColor(aa:byte):TMWColor;
begin
   gfx_MakeAlphaTMWColor:=aa shl 24;
end;

function gfx_MakeTMWColor(ar,ag,ab:byte):TMWColor;
begin
   gfx_MakeTMWColor:=$FF000000+(ar shl 16)+(ag shl 8)+ab;
end;

procedure draw_set_color(color:TMWColor);
begin
   if(draw_color=color)then exit;

   draw_color:=color;
   draw_color_r:=(color and $00FF0000) shr 16;
   draw_color_g:=(color and $0000FF00) shr 8;
   draw_color_b:= color and $000000FF;

   SDL_SetRenderDrawColor(vid_SDLRenderer,draw_color_r,draw_color_g,draw_color_b,draw_color_a);
end;

procedure draw_set_alpha(alpha:byte);
begin
   if(draw_color_a=alpha)then exit;

   draw_color_a:=alpha;
   if(draw_color_a=255)
   then SDL_SetRenderDrawBlendMode(vid_SDLRenderer,SDL_BLENDMODE_NONE)
   else SDL_SetRenderDrawBlendMode(vid_SDLRenderer,SDL_BLENDMODE_BLEND);

   SDL_SetRenderDrawColor(vid_SDLRenderer,draw_color_r,draw_color_g,draw_color_b,draw_color_a);
end;

procedure draw_clear;
begin
   SDL_RenderClear(vid_SDLRenderer);
end;

procedure draw_set_target(mwtex:PTMWTexture);
begin
   if(mwtex<>nil)then
     if(mwtex^.sdltexture<>nil)then
     begin
        SDL_SetRenderTarget(vid_SDLRenderer,mwtex^.sdltexture);
        exit;
     end;
   SDL_SetRenderTarget(vid_SDLRenderer,nil);
end;

{$INCLUDE _draw_prims.pas}

procedure draw_sdlsurface(tar:pSDL_Surface;x,y:integer;sur:pSDL_Surface);
begin
   if(tar=nil)
   or(sur=nil)then exit;
   vid_SDLRect^.x:=x;
   vid_SDLRect^.y:=y;
   vid_SDLRect^.w:=sur^.w;
   vid_SDLRect^.h:=sur^.h;
   SDL_BLITSURFACE(sur,nil,tar,vid_SDLRect);
end;

procedure draw_sdltexture(x,y,w,h:integer;tex:pSDL_Texture);
begin
   if(tex=nil)then exit;

   vid_SDLRect^.x:=x;
   vid_SDLRect^.y:=y;
   vid_SDLRect^.w:=w;
   vid_SDLRect^.h:=h;

   SDL_RenderCopy(vid_SDLRenderer,tex,nil,vid_SDLRect);
end;
procedure draw_sdltexture_ext(x,y,w,h:integer;tex:pSDL_Texture;angle:single;flipx,flipy:boolean);
var flip:integer;
begin
   if(tex=nil)then exit;

   vid_SDLRect^.x:=x;
   vid_SDLRect^.y:=y;
   vid_SDLRect^.w:=w;
   vid_SDLRect^.h:=h;

   flip:=SDL_FLIP_NONE;
   if(flipx)then flip+=SDL_FLIP_HORIZONTAL;
   if(flipy)then flip+=SDL_FLIP_VERTICAL;

   SDL_RenderCopyEx(vid_SDLRenderer,tex,nil,vid_SDLRect,angle,nil,flip);
end;

procedure draw_mwtexture1(x,y:integer;mwtex:pTMWTexture;xscale,yscale:single);
var nw,nh:integer;
begin
   if(mwtex<>nil)then
    with mwtex^ do
     if(sdltexture<>nil)then
     begin
        SDL_SetTextureColorMod(sdltexture,draw_color_r,draw_color_g,draw_color_b);
        SDL_SetTextureAlphaMod(sdltexture,draw_color_a);
        if(xscale<>1)and(xscale<>-1)then nw:=abs(trunc(w*xscale)) else nw:=w;
        if(yscale<>1)and(yscale<>-1)then nh:=abs(trunc(h*yscale)) else nh:=h;
        //if(xscale<0)then x-=nw;
       // if(yscale<0)then y-=nh;
        draw_sdltexture_ext(x,y,nw,nh,sdltexture,0,xscale<0,yscale<0);
     end;
end;
procedure draw_mwtexture2(x,y:integer;mwtex:pTMWTexture;nw,nh:integer);
begin
   if(mwtex<>nil)then
    with mwtex^ do
     if(sdltexture<>nil)then
     begin
        SDL_SetTextureColorMod(sdltexture,draw_color_r,draw_color_g,draw_color_b);
        SDL_SetTextureAlphaMod(sdltexture,draw_color_a);
        draw_sdltexture(x,y,nw,nh,sdltexture);
     end;
end;

procedure draw_set_fontUpdateSize(newSize:single);
begin
   if(draw_font_size<>newSize)then
   with draw_font^ do
   begin
      draw_font_size:=newSize;

      draw_font_w1 := round(font_w*draw_font_size);
      draw_font_wi := draw_font_w1-1;
      draw_font_wh := draw_font_w1 div 2;
      draw_font_wq := draw_font_w1 div 4;
      draw_font_w1h:= draw_font_wh*3;
      draw_font_wq3:=(draw_font_w1 div 4)*3;

      draw_font_h1 := round(font_h*draw_font_size);
      draw_font_hi := draw_font_h1-1;
      draw_font_hh := draw_font_h1 div 2;
      draw_font_hq := draw_font_h1 div 4;

      draw_font_lhq:=(draw_font_h1+draw_font_hq);
      draw_font_lhh:=(draw_font_h1+draw_font_hh);
   end;
end;

procedure draw_set_font(newFont:PTFont;newSizeW:integer);
begin
   draw_font:=newFont;
   draw_set_fontUpdateSize(newSizeW/draw_font^.font_w);
end;

{procedure draw_set_fontS(newFont:PTFont;newSizeS:single);
begin
   draw_font:=newFont;
   draw_set_fontUpdateSize(newSizeS);
end;}

function slength(str:shortstring):byte;
var i:byte;
begin
   slength:=0;
   i:=length(str);
   while(i>0)do
   begin
      if not(str[i] in tc_SpecialChars)then slength+=1;
      i-=1;
   end;
end;

procedure draw_char(x,y:integer;ch:char;color_back:TMWColor);
begin
   x-=draw_font_wh;
   y-=draw_font_hh;
   if(color_back<>c_none)then
   begin
      draw_set_color(color_back);
      draw_frect(x,y,x+draw_font_wi,y+draw_font_hi);
   end;

   draw_set_color(draw_color);
   draw_mwtexture2(x,y,draw_font^.MWTextures[ch],draw_font_w1,draw_font_h1);
end;

procedure draw_text_line(x,y:integer;str:shortstring;alignment:TAlignment;MaxLineLength:byte;color_back:TMWColor;restoreColor:boolean=true);
var
strLen,
cs,ce,
i,charn: byte;
ix,iy  : integer;
charc  : char;
rcolor,
tcolor : TMWColor;
begin
   strLen:=length(str);
   if(strLen=0)then exit;
   if(MaxLineLength<1)then MaxLineLength:=1;

   cs:=0;
   ce:=0;
   charn:=0;
   if(alignment=ta_chat)then
   begin
      ce:=strLen;
      for i:=strLen downto 1 do
      begin
         if not(str[i] in tc_SpecialChars)then
         begin
            charn+=1;
            cs:=i;
         end;
         if(charn=MaxLineLength)then break;
      end
   end
   else
   begin
      cs:=1;
      ce:=strLen;
      for i:=1 to strLen do
      begin
         if not(str[i] in tc_SpecialChars)then charn+=1;
         if(charn=MaxLineLength)then break;
      end;
   end;
   if(cs=0)or(ce=0)or(cs>ce)then exit;

   case alignment of //  X
   ta_chat,
   ta_LU,
   ta_LM,
   ta_LD  : ix:=x;
   ta_MU,
   ta_MM,
   ta_MD  : ix:=x-((charn*draw_font_w1) div 2);
   ta_RU,
   ta_RM,
   ta_RD  : ix:=x- (charn*draw_font_w1);
   else
   end;

   case alignment of //  Y
   ta_chat,
   ta_LU,
   ta_MU,
   ta_RU  : iy:=y;
   ta_LM,
   ta_MM,
   ta_RM  : iy:=y-draw_font_hh;
   ta_LD,
   ta_MD,
   ta_RD  : iy:=y-draw_font_h1;
   end;

   rcolor:=draw_color;
   tcolor:=draw_color;
   if(color_back<>c_none)then
   begin
      draw_set_color(color_back);
      draw_frect(ix,iy,ix-1+draw_font_w1*charn,iy+draw_font_hi);
   end;

   x:=ix;
   y:=iy;
   for i:=cs to ce do
   begin
      charc:=str[i];

      case charc of
      tc_player0..
      tc_player7  : tcolor:=PlayerColorNormal[ord(charc)];
      tc_nl1,
      tc_nl2      : ;
      tc_brown    : tcolor:=c_brown ;
      tc_purple   : tcolor:=c_purple;
      tc_red      : tcolor:=c_red   ;
      tc_orange   : tcolor:=c_orange;
      tc_yellow   : tcolor:=c_yellow;
      tc_lime     : tcolor:=c_lime  ;
      tc_aqua     : tcolor:=c_aqua  ;
      tc_blue     : tcolor:=c_blue  ;
      tc_gray     : tcolor:=c_gray  ;
      tc_dgray    : tcolor:=c_dgray ;
      tc_white    : tcolor:=c_white ;
      tc_green    : tcolor:=c_green ;
      tc_default  : tcolor:=rcolor;
      else
         {case charc of
         char_detect  : tcolor:=c_purple;
         char_advanced: tcolor:=c_white;
         ',',';','[',
         ']','{','}'  : tcolor:=rcolor;
         else
         end;}

         draw_set_color(tcolor);
         draw_mwtexture2(x,y,draw_font^.MWTextures[charc],draw_font_w1,draw_font_h1);

         x+= draw_font_w1;
      end;
      if(i=ce)then draw_set_color(tcolor);
   end;
   if(restoreColor)then
     draw_set_color(rcolor);
end;

procedure draw_text(x,y:integer;str:shortstring;alignment:TAlignment;MaxLineLength:byte;color_back:TMWColor);
var
w,h,max_w,max_h: integer;
strLen,i,char_w,
line_n : byte;
line_l : array of shortstring;
line_h : array of integer;
begin
   strLen:=length(str);
   if(strLen=0)
   or(MaxLineLength=0)then exit;
   line_n:=0;
   setlength(line_l,line_n);
   setlength(line_h,line_n);
   max_w:=0;
   max_h:=0;
   while(strLen>0)do
   begin
      char_w:=MaxLineLength;
      if(strLen<char_w)then char_w:=strLen;

      h:=draw_font_lhh;
      i:=pos(tc_nl1,str);
      if(i>0)and(i<=char_w)then
      begin
         char_w:=i;
         h:=draw_font_lhq;
      end;
      i:=pos(tc_nl2,str);
      if(i>0)and(i<=char_w)then
      begin
         char_w:=i;
         h:=draw_font_lhh;
      end;
      w:=char_w*draw_font_w1;
      if(w>max_w)then max_w:=w;
      max_h+=h;

      line_n+=1;
      setlength(line_l,line_n);
      setlength(line_h,line_n);

      line_h[line_n-1]:=h;
      line_l[line_n-1]:=copy(str,1,char_w);
      delete(str,1,char_w);
      strLen-=char_w;
   end;

   if(line_n=0)then exit;

   case alignment of //  X
   ta_chat,
   ta_LU,
   ta_LM,
   ta_LD  : ;
   ta_MU,
   ta_MM,
   ta_MD  : x-=max_w div 2;
   ta_RU,
   ta_RM,
   ta_RD  : x-=max_w;
   else
   end;

   case alignment of //  Y
   ta_chat,
   ta_LU,
   ta_MU,
   ta_RU  : ;
   ta_LM,
   ta_MM,
   ta_RM  : y-=max_h div 2;
   ta_LD,
   ta_MD,
   ta_RD  : y-=max_h;
   end;

   for i:=1 to line_n do
   begin
      draw_text_line(x,y,line_l[i-1],ta_LU,255,color_back,i=line_n);
      y+=line_h[i-1];
   end;

   line_n:=0;
   setlength(line_l,line_n);
   setlength(line_h,line_n);
end;

procedure draw_LoadingScreen(CaptionString:shortstring;color:TMWColor);
var w,h:longint;
begin
   SDL_RenderGetLogicalSize(vid_SDLRenderer,@w,@h);
   draw_set_color(c_black);
   draw_set_alpha(127);
   draw_clear;
   draw_set_font(font_Base,basefont_w2);
   draw_set_color(color);
   draw_set_alpha(255);
   draw_text_line(w div 2,h div 2,CaptionString,ta_MM,255,0);
   SDL_RenderPresent(vid_SDLRenderer);
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

procedure d_timer(x,y:integer;time:cardinal;ta:TAlignment;str:shortstring;color:TMWColor);
begin
   draw_set_color(color);
   draw_text_line(x,y,str+str_GStep2Time(time),ta,255,c_black);
end;

////////////////////////////////////////////////////////////////////////////////
//
//    Minimap

procedure map_MinimapBackground;
var
gx ,gy :integer;
mmx,mmy:single;
begin
   draw_set_target(tex_map_bMiniMap);
   draw_set_color(c_black);
   draw_clear;
   mmx:=0;
   for gx:=0 to map_csize do
   begin
      mmy:=0;
      for gy:=0 to map_csize do
      begin
         case map_grid[gx,gy].tgc_solidlevel of
mgsl_nobuild : begin
               draw_set_color(c_dgray);
               draw_frect(trunc(mmx),trunc(mmy),trunc(mmx+map_mm_gridW),trunc(mmy+map_mm_gridW));
               end;
mgsl_liquid  : begin
               draw_set_color(c_gray);
               draw_frect(trunc(mmx),trunc(mmy),trunc(mmx+map_mm_gridW),trunc(mmy+map_mm_gridW));
               end;
mgsl_rocks   : begin
               draw_set_color(c_ltgray);
               draw_frect(trunc(mmx),trunc(mmy),trunc(mmx+map_mm_gridW),trunc(mmy+map_mm_gridW));
               end;
         end;

         mmy+=map_mm_gridW;
      end;
      mmx+=map_mm_gridW;
   end;
   draw_set_target(nil);
end;

procedure map_MinimapSpot(x,y,r:integer;sym:char;color:TMWColor);
begin
   draw_set_color(color);
   draw_circle(x,y,r);
   draw_set_font(font_base,basefont_w1);
   draw_char(x,y,sym,c_none);
end;

procedure map_MinimapPlayerStarts(UnknownStarts,teamStarts:boolean);
var p    :byte;
    x,y,r:integer;
begin
   if(map_MaxPlayers>0)then
     for p:=0 to map_MaxPlayers-1 do
     begin
        x:=round(map_mm_cx*map_PlayerStartX[p]);
        y:=round(map_mm_cx*map_PlayerStartY[p]);
        r:=trunc(map_mm_cx*base_1r);

        if(UnknownStarts)then
        begin
           if(teamStarts)
           then map_MinimapSpot(x,y,r,chr(ord('1')+PlayerSlotGetTeam(p,255)),c_white)
           else map_MinimapSpot(x,y,r,'?',c_white)
        end
        else
          if (g_slot_state[p]<>pss_closed  )
          and(g_slot_state[p]<>pss_observer)
          then
            if(g_players[p].player_type>pt_none)or(g_ai_slots>0)
            then map_MinimapSpot(x,y,r,b2s(p+1)[1],PlayerColorNormal[p])
            else map_MinimapSpot(x,y,r,'+'        ,c_white             );
     end;
end;

procedure map_MinimapCPoints;
var i  :byte;
begin
   for i:=0 to LastCPoint do
    with g_cpoints[i] do
     if(cpCaptureR>0)then
      if((i=0)and(map_scenario=ms_KotH))or(cpenergy<=0)
      then map_MinimapSpot(cpmx,cpmy,cpmr,char_cp ,c_purple)
      else map_MinimapSpot(cpmx,cpmy,cpmr,char_gen,c_white );
end;

procedure map_RedrawMenuMinimap;
begin
   draw_set_target(tex_map_mMiniMap);
   draw_set_color(c_white);
   draw_mwtexture1(0,0,tex_map_bMiniMap,1,1);

   map_MinimapPlayerStarts(not g_fixed_positions,map_scenario in ms_ScenariosFixedTeams);
   map_MinimapCPoints;

   {draw_set_color(c_red);
   draw_line(
   round(map_phsize*map_mm_cx),
   round(map_phsize*map_mm_cx),
   round(map_phsize*map_mm_cx)+round(2000*map_mm_cx*cos(map_symmetryDir*degtorad)),
   round(map_phsize*map_mm_cx)+round(2000*map_mm_cx*sin(map_symmetryDir*degtorad))
   ); }

   draw_set_target(nil);
end;

function ui_AddMarker(ax,ay:integer;av:byte;new:boolean):boolean;
var i,ni,mx,my:integer;
begin
   {
   new  false - not required new alarm point
        true  - required
   return - true if alarm was created
   }
   ui_AddMarker:=false;

   ax:=mm3i(1,ax,map_psize);
   ay:=mm3i(1,ay,map_psize);

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
lmt_unit_promoted    :      ui_AddMarker(xi,yi,aummat_advance   ,true);
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


