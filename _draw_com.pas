
procedure _LoadingScreen;
begin
   SDL_FillRect(_screen,nil,0);
   stringColor(_screen,(vid_mw div 2)-40, vid_mh div 2,@str_loading[1],c_yellow);
   SDL_Flip(_screen);
end;

procedure _draw_surf(tar:pSDL_Surface;x,y:integer;sur:PSDL_SURFACE);
begin
   _rect^.x:=x;
   _rect^.y:=y;
   _rect^.w:=sur^.w;
   _rect^.h:=sur^.h;
   SDL_BLITSURFACE(sur,nil,tar,_rect);
end;

function mic(enbl,sel:boolean):cardinal;
begin
   mic:=c_white;
   if(enbl=false)
   then mic:=c_gray
   else
     if(sel)then mic:=c_yellow;
end;

procedure _draw_text(sur:pSDL_Surface;x,y:integer;s:shortstring;al,chrs:byte;tc:cardinal;maxs:byte=255);
var ss,i,o:byte;
    ix:integer;
     c:char;
    cl:cardinal;
begin
   ss:=length(s);
   if(ss>0)then
   begin
      case al of
      ta_FVmiddle : begin
                       ix:=x-((ss*font_w)shr 1)+1;
                       dec(y,font_hw);
                    end;
      ta_Fmiddle  : ix:=x-((ss*font_w)shr 1)+1;
      ta_Fright   : ix:=x-(ss*font_w);
      ta_FVright  : begin
                       ix:=x-(ss*font_w);
                       dec(y,font_hw);
                    end;
      else
         if(al in [ta_middle,ta_right])then
         begin
            o:=0;
            for i:=1 to ss do
             if not(s[i] in [#0..#6,#14..#25])then inc(o,1);

            case al of
            ta_middle: ix:=x-((o*font_w)shr 1);
            ta_right : ix:=x-(o*font_w);
            end;
         end
         else ix:=x;
         if(al=ta_FVleft)then dec(y,font_hw);
      end;

      o :=0;
      cl:=tc;
      for i:=1 to ss do
      begin
         c:=s[i];

         case c of
         #0..#6  : begin cl:=_players[ord(c)].color;if(i<ss)then continue;end; //tc:=cl;
         #11..#13: ;
         #14     : begin cl:=c_purple       ;if(i<ss)then continue;end;
         #15     : begin cl:=c_red          ;if(i<ss)then continue;end;
         #16     : begin cl:=c_orange       ;if(i<ss)then continue;end;
         #17     : begin cl:=c_yellow       ;if(i<ss)then continue;end;
         #18     : begin cl:=c_lime         ;if(i<ss)then continue;end;
         #19     : begin cl:=c_aqua         ;if(i<ss)then continue;end;
         #20     : begin cl:=c_blue         ;if(i<ss)then continue;end;
         #21     : begin cl:=c_gray         ;if(i<ss)then continue;end;
         #22     : begin cl:=c_lgray        ;if(i<ss)then continue;end;
         #23     : begin cl:=c_white        ;if(i<ss)then continue;end;
         #24     : begin cl:=c_dred         ;if(i<ss)then continue;end;
         #25     : begin cl:=tc             ;if(i<ss)then continue;end;
         else
            if(c<>' ')then
            begin
               case c of
                #7 : boxColor(sur,ix,y,ix+font_iw,y+font_iw,c_orange);
                #8 : boxColor(sur,ix,y,ix+font_iw,y+font_iw,c_white);
                #9 : boxColor(sur,ix,y,ix+font_iw,y+font_iw,c_purple);
                #10: boxColor(sur,ix,y,ix+font_iw,y+font_iw,c_aqua);
               else
                 boxColor(sur,ix,y,ix+font_iw,y+font_iw,cl);
               end;
               _draw_surf(sur,ix,y,spr_font[c]);
            end;

           inc(o,1);
           inc(ix,font_w);
           dec(maxs,1);
           if(maxs=0)then exit;
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

procedure _sl_add(ax,ay,ad,ash:integer;arc,amsk:cardinal;arct:boolean;aspr:pSDL_surface;ainv:byte;abar:single;aclu:integer;acrl,acll:byte;acru:string6;aco,ayo:integer);
begin
   if(vid_vsls<vid_mvs)and(_menu=false)and(aspr<>_dsurf)then
   begin
      inc(vid_vsls,1);
      with vid_vsl[vid_vsls]^ do
      begin
         vsx   := ax-vid_vx;
         vsy   := ay-vid_vy;
         vsd   := ad;
         vssh  := ash;
         vss   := aspr;
         vsrc  := arc;
         vsmsk := amsk;
         vsinv := ainv;
         vsbar := abar;
         vsclu := aclu;
         vscru := acru;
         vscrl := acrl;
         vscll := acll;
         vsrct := arct;
         vsco  := aco;
         vsyo  := ayo;
      end;
   end;
end;

procedure _sv_sort;
var i,u,r:word;
    dt:PTVisSpr;
begin
   if(vid_vsls>1)then
   begin
      r:=(vid_vsls-1);
      for i:=1 to vid_vsls do
       for u:=1 to r do
        if (vid_vsl[u]^.vsd<vid_vsl[i]^.vsd) then
        begin
          dt:=vid_vsl[u];
          vid_vsl[u]:=vid_vsl[i];
          vid_vsl[i]:=dt;
        end;
   end;
end;

procedure D_SpriteList;
var sx,sy:integer;
begin
   _sv_sort;

   while(vid_vsls>0)do
    with vid_vsl[vid_vsls]^ do
    begin
       inc(vsy,vsyo);     // y offset
       if(vssh>0)then     // shadow
       begin
          sx:=(vss^.w shr 1)-(vss^.w shr 3);
          sy:=vss^.h-(vss^.h shr 3);
          filledellipseColor(_screen,vsx+sx,vsy+sy+vssh,sx,vss^.h shr 2,c_ablack);
       end;
       if(vsinv>0)then    // sprite
       begin
          if(vsinv<255)then SDL_SetAlpha(vss,SDL_SRCALPHA,vsinv);    //SDL_RLEACCEL
          _draw_surf(_screen,vsx,vsy,vss);
          if(vsinv<255)then SDL_SetAlpha(vss,SDL_SRCALPHA,255);
       end;
       dec(vsy,vsyo);     // y offset

       if(vsmsk>0)or(vsco>0)then  // mask and size circle
       begin
          sx:=vss^.w shr 1;
          sy:=vss^.h shr 1;
          if(vsmsk>0)then filledellipseColor(_screen,vsx+sx,vsy+sy,sx,sy,vsmsk);
          if(vsco >0)then circleColor(_screen,vsx+sx,vsy+sy,vsco,c_gray);
       end;

       sy:=vsy;             // rect border
       sx:=vss^.h;
       if(vsy<4)then
       begin
          sx:=vss^.h+vsy-4;
          vsy:=4;
       end;

       if(sy>-vss^.h)then   // select rect
       begin
          if(vsrc>0)and(vsy>-vss^.h)then
          begin
             if(vsrct)then rectangleColor(_screen,vsx,vsy-1,vsx+vss^.w,vsy+sx, vsrc);
             if(vsbar>0)then
             begin
                boxColor(_screen,vsx,vsy-4,vsx+vss^.w             ,vsy-1,c_black);
                boxColor(_screen,vsx,vsy-4,vsx+trunc(vsbar*vss^.w),vsy-1,vsrc);
             end;
          end;

          inc(vsx,1);
          if(vsclu >0 )then _draw_text(_screen,vsx       ,vsy          ,i2s(vsclu),ta_left ,255,c_white);
          if(vscru<>'')then _draw_text(_screen,vsx+vss^.w,vsy          ,vscru     ,ta_right,3  ,c_white);
          if(vscll >0 )then _draw_text(_screen,vsx       ,vsy+sx-font_w,b2s(vscll),ta_left ,255,c_white);
          if(vscrl >0 )then _draw_text(_screen,vsx+vss^.w,vsy+sx-font_w,b2s(vscrl),ta_right,255,c_white);
          dec(vsx,1);
       end;

       vsy:=sy;

       dec(vid_vsls,1);
    end;
end;




