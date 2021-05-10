


procedure _draw_text(sur:pSDL_Surface;x,y:integer;s:string;al,chrs:byte;tc:cardinal);
var ss,i,o:byte;
    ix:integer;
     c:char;
    cl:cardinal;
begin
   ss:=length(s);
   if(ss>0)then
   begin
      ix:=x;
      if(al in [ta_middle,ta_right])then
      begin
         o:=0;
         for i:=1 to ss do
          if not(s[i] in [#0..#4,#14..#25])then inc(o,1);

         case al of
         ta_middle: ix:=x-((o*font_w)shr 1);
         ta_right : ix:=x-(o*font_w);
         end;
      end;

      o:=0;
      cl:=tc;
      for i:=1 to ss do
      begin
         c:=s[i];

         case c of
         #0..#6  : begin cl:=plcolor[ord(c)];if(i<ss)then continue;end; //tc:=cl;
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

           _draw_surf(sur,ix,y,font_ca[c]);

           inc(o,1);
           inc(ix,font_w);
         end;

         if(al=ta_left)then
          if(o>=chrs)or(c in [#11..#13])or(i=ss)then
          begin
             if(i<ss)then o:=0;

             ix:=x;
             inc(y,font_w);
             case c of
             #11 : inc(y,2);
             #12 : inc(y,txt_line_h2);
             #13 : inc(y,txt_line_h);
             else  inc(y,txt_line_h);
             end;
          end;
      end;
   end;
end;

procedure LoadingScreen;
begin
   SDL_FillRect(_screen,nil,0);
   stringColor(_screen,(vid_mw div 2)-40, vid_mh div 2,@str_loading[1],c_yellow);
   SDL_FLIP(_screen);
end;



procedure D_timer(x,y:integer;time:cardinal;ta:byte;str:string);
var m,s,h:cardinal;
    hs,ms,ss:string;
begin
   s:=time div vid_fps;
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
   _draw_text(_screen,x,y,str,ta,255,c_white);
end;

procedure ui_addalrm(aax,aay:integer;aab:boolean);
var i,ni:byte;
begin
   if(_rpls_rst>=rpl_rhead)then exit;

   ni:=255;
   for i:=0 to vid_uialrm_n do
    with ui_alrms[i] do
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
    for i:=0 to vid_uialrm_n do
     with ui_alrms[i] do
      if(at=0)then
      begin
         ax:=aax;
         ay:=aay;
         ab:=aab;
         at:=vid_uialrm_t;
         if((vid_mmvx-vid_uialrm_ti)>ax)or(ax>(vid_mmvx+map_mmvw+vid_uialrm_ti))or   // vid_mmvx,vid_mmvy,vid_mmvx+map_mmvw,vid_mmvy+map_mmvh
           ((vid_mmvy-vid_uialrm_ti)>ay)or(ay>(vid_mmvy+map_mmvh+vid_uialrm_ti))then PlaySND(snd_alarm,0);
         break;
      end;
end;



