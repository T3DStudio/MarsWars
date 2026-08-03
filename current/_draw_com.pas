
procedure draw_UIMouseActHint;  forward;

////////////////////////////////////////////////////////////////////////////////
//
//  COMMON DRAW PROCEDURES
//

procedure draw_LoadingScreen(load_str:pshortstring;color:TMWColor);
begin
   SDL_FillRect(vid_screen,nil,0);
   stringColor(vid_screen,(vid_vw div 2)-(length(load_str^)*font_w1 div 2), vid_vh div 2,@(load_str^[1]),color);
   SDL_FLIP(vid_screen);
end;

procedure draw_sdlsurface(tar:pSDL_Surface;x,y:integer;sur:PSDL_SURFACE);
begin
   vid_RECT^.x:=x;
   vid_RECT^.y:=y;
   vid_RECT^.w:=sur^.w;
   vid_RECT^.h:=sur^.h;
   SDL_BLITSURFACE(sur,nil,tar,vid_RECT);
end;

procedure draw_mwtexture(tar:pSDL_Surface;x,y:integer;mwtex:PTMWTexture);
begin
   with mwtex^ do
   begin
      vid_RECT^.x:=x;
      vid_RECT^.y:=y;
      vid_RECT^.w:=w;
      vid_RECT^.h:=h;
      SDL_BLITSURFACE(surf,nil,tar,vid_RECT);
   end;
end;

procedure draw_rectw(tar:pSDL_Surface;x0,y0,x1,y1,border,borderSkip:integer;color:TMWColor);
begin
   while(border<>0)do
   begin
      if(abs(border)>borderSkip)then
        rectangleColor(tar,x0-border,y0-border,
                           x1+border,y1+border,color);
      if(border>0)
      then border-=1
      else border+=1;
   end;
end;

procedure draw_text(sur:pSDL_Surface;x,y:integer;str:shortstring;alignment,MaxLineChars:byte;BaseColor:TMWColor;lastLineY:pinteger=nil;EdgeY:integer=integer.MaxValue);
var
strLen,i,
lines_n,
line      : byte;
textH,textW,
ix        : integer;
charc     : char;
color     : TMWColor;
lines_spos,
lines_epos,
lines_endc,
lines_len : shortstring;
begin
   if(BaseColor=0)
   or(MaxLineChars=0)then exit;
   strLen:=length(str);
   if(strLen=0)then exit;

   // text analize
   lines_spos:='';
   lines_epos:='';
   lines_endc:='';
   lines_len :='';

   textW:=0;
   textH:=0;
   str_analize(@str,@lines_spos,@lines_epos,@lines_endc,@lines_len,@textH,@lines_n,nil,MaxLineChars);

   case alignment of
   ta_LU,
   ta_MU,
   ta_RU  : ;
   ta_LM,
   ta_MM,
   ta_RM  : y-=(textH div 2);
   ta_LB,
   ta_MB,
   ta_RB  : y-= textH;
   end;

   color:=BaseColor;
   for line:=1 to lines_n do
   begin
      textW:=ord(lines_len[line])*font_w1;
      case alignment of
      ta_LU,
      ta_LM,
      ta_LB  : ix:=x;
      ta_MU,
      ta_MM,
      ta_MB  : ix:=x-(textW div 2);
      ta_RU,
      ta_RM,
      ta_RB  : ix:=x- textW;
      end;

      for i:=ord(lines_spos[line]) to ord(lines_epos[line]) do
      begin
         charc:=str[i];

         case charc of
         tc_docbr,
         tc_doccpt,
         tc_doccnt,
         tc_nl1..
         tc_nl3      : ;
         tc_RankUAC  : begin
                       draw_sdlsurface(sur,ix,y,spr_RaceRank[r_uac ]);
                       ix+= font_w1;
                       end;
         tc_RankHell : begin
                       draw_sdlsurface(sur,ix,y,spr_RaceRank[r_hell]);
                       ix+= font_w1;
                       end;
         tc_player0..
         tc_player7  : color:=PlayerGetColorDef(ord(charc));
         tc_purple   : color:=c_purple ;
         tc_red      : color:=c_red    ;
         tc_orange   : color:=c_orange ;
         tc_yellow   : color:=c_yellow ;
         tc_lime     : color:=c_lime   ;
         tc_aqua     : color:=c_aqua   ;
         tc_blue     : color:=c_blue   ;
         tc_gray     : color:=c_gray   ;
         tc_dgray    : color:=c_dgray  ;
         tc_white    : color:=c_white  ;
         tc_green    : color:=c_green  ;
         tc_default  : color:=BaseColor;
         else
            case charc of
            char_detect: boxColor(sur,ix,y,ix+font_wi,y+font_wi,c_purple );
            ',',';',
            '[',']',
            '{','}'    : boxColor(sur,ix,y,ix+font_wi,y+font_wi,BaseColor);
            else         boxColor(sur,ix,y,ix+font_wi,y+font_wi,color    );
            end;

            draw_mwtexture(sur,ix,y,@font_1[charc]);
            ix   += font_w1;
         end;
      end;

      case lines_endc[line] of
      tc_nl1 : y+=txt_line_h1;
      tc_nl2 : y+=txt_line_h2;
      tc_nl3 : y+=txt_line_h3;
      end;
      if((y+font_w1)>=EdgeY)then break;
   end;
   if(lastLineY<>nil)then lastLineY^:=y;
end;

procedure draw_timer(tar:pSDL_Surface;x,y:integer;time:cardinal;talign,tlength:byte;str:shortstring;color:TMWColor;lastLineY:pinteger=nil);
var m,s,h:cardinal;
    hs,ms,ss:shortstring;
begin
   s:=time div fr_fps1;
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
   draw_text(tar,x,y,str,talign,tlength,color,lastLineY);
end;



