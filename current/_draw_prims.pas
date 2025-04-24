
////////////////////////////////////////////////////////////////////////////////
//
//   BASE (SDL TEXTURES)
//

procedure draw_pixel(x0,y0:integer);
begin
   SDL_RenderDrawPoint(vid_renderer,x0,y0);
end;

procedure draw_line(x0,y0,x1,y1:integer);
begin
   SDL_RenderDrawLine(vid_renderer,x0,y0,x1,y1);
end;

procedure draw_hline(x0,x1,y0:integer);
begin
   SDL_RenderDrawLine(vid_renderer,x0,y0,x1,y0);
end;

procedure draw_vline(x0,y0,y1:integer);
begin
   SDL_RenderDrawLine(vid_renderer,x0,y0,x0,y1);
end;

procedure draw_rect(x0,y0,x1,y1:integer);
begin
   vid_rect^.x:=min2i(x0,x1);
   vid_rect^.y:=min2i(y0,y1);
   vid_rect^.w:=abs(x1-x0)+1;
   vid_rect^.h:=abs(y1-y0)+1;
   SDL_RenderDrawRect(vid_renderer,vid_rect);
end;
procedure draw_frect(x0,y0,x1,y1:integer);
begin
   vid_rect^.x:=min2i(x0,x1);
   vid_rect^.y:=min2i(y0,y1);
   vid_rect^.w:=abs(x1-x0)+1;
   vid_rect^.h:=abs(y1-y0)+1;
   SDL_RenderFillRect(vid_renderer,vid_rect);
end;

procedure draw_ellipse_quadrants(x,y,dx,dy:integer;filled:boolean);
var
xpdx,xmdx,
ypdy,ymdy:integer;
begin
   if(dx=0)then
   begin
      if(dy=0)
      then SDL_RenderDrawPoint(vid_renderer,x,y)
      else
      begin
         ypdy:=y+dy;
         ymdy:=y-dy;
         if(filled)
         then SDL_RenderDrawLine(vid_renderer,x,ymdy,x,ypdy)
         else
         begin
            SDL_RenderDrawPoint(vid_renderer,x,ymdy);
            SDL_RenderDrawPoint(vid_renderer,x,ypdy);
         end;
      end;
   end
   else
   begin
      xpdx:=x+dx;
      xmdx:=x-dx;
      ypdy:=y+dy;
      ymdy:=y-dy;
      if(filled)then
      begin
         SDL_RenderDrawLine(vid_renderer,xpdx,ymdy,xpdx,ypdy);
         SDL_RenderDrawLine(vid_renderer,xmdx,ymdy,xmdx,ypdy);
      end
      else
      begin
         SDL_RenderDrawPoint(vid_renderer,xpdx,ymdy);
         SDL_RenderDrawPoint(vid_renderer,xmdx,ymdy);
         SDL_RenderDrawPoint(vid_renderer,xpdx,ypdy);
         SDL_RenderDrawPoint(vid_renderer,xmdx,ypdy);
      end;
   end;
end;

procedure draw_base_ellipse(x,y,rx,ry:integer;filled:boolean);
const
DEFAULT_ELLIPSE_OVERSCAN = 4;
var
rxi ,ryi,
rx2 ,ry2,
rx22,ry22,
error,
curX,curY,curXp1,curYm1,
scrX,scrY,
oldX,oldY,
deltaX,deltaY,
ellipseOverscan : longint;
begin
   if(rx<0)
   or(ry<0)then exit;

   if(rx=0)then
   begin
      if(ry=0)
      then SDL_RenderDrawPoint(vid_renderer,x,y)
      else SDL_RenderDrawLine (vid_renderer,x,y-ry,x,y+ry);
      exit;
   end
   else
     if(ry=0)then
     begin
        SDL_RenderDrawLine(vid_renderer,x-rx,y,x+rx,y);
        exit;
     end;

   {
   Adjust overscan
   }
   rxi:=rx;
   ryi:=ry;
   if(rxi>=512)or(ryi>=512)
   then ellipseOverscan:=DEFAULT_ELLIPSE_OVERSCAN div 4
   else
     if(rxi>=256)or(ryi>=256)
     then ellipseOverscan:=DEFAULT_ELLIPSE_OVERSCAN div 2
     else ellipseOverscan:=DEFAULT_ELLIPSE_OVERSCAN;

   {
   Top/bottom center points.
   }
   oldX := 0;
   oldY := ryi;
   scrX := 0;
   scrY := ryi;
   //draw_ellipse_quadrants(x,y,0,ry,filled);

   // Midpoint ellipse algorithm with overdraw
   rxi *= ellipseOverscan;
   ryi *= ellipseOverscan;
   rx2 := rxi*rxi;
   rx22:= rx2+rx2;
   ry2 := ryi*ryi;
   ry22:= ry2+ry2;
   curX:= 0;
   curY:= ryi;
   deltaX:= 0;
   deltaY:= rx22*curY;

   error:=ry2-rx2*ryi+(rx2 div 4);
   while(deltaX<=deltaY)do
   begin
      curX+=1;
      deltaX+=ry22;

      error+=deltaX+ry2;
      if(error>=0)then
      begin
         curY  -=1;
         deltaY-=rx22;
         error -=deltaY;
      end;
      scrX:=curX div ellipseOverscan;
      scrY:=curY div ellipseOverscan;
      if((scrX<>oldX)and(scrY=oldY))
      or((scrX<>oldX)and(scrY<>oldY))then
      begin
 	 draw_ellipse_quadrants(x,y,scrX,scrY,filled);
 	 oldX:=scrX;
 	 oldY:=scrY;
      end;
   end;

   if(curY>0)then
   begin
      curXp1:=curX+1;
      curYm1:=curY-1;
      error :=ry2*curX*curXp1+((ry2+3) div 4)+rx2*curYm1*curYm1-rx2*ry2;
      while(curY>0)do
      begin
         curY  -=1;
         deltaY-=rx22;

         error+=rx2;
         error-=deltaY;
         if(error<=0)then
         begin
            curX  +=1;
            deltaX+=ry22;
            error +=deltaX;
 	 end;

         scrX:=curX div ellipseOverscan;
         scrY:=curY div ellipseOverscan;
         if((scrX<>oldX)and(scrY= oldY))
         or((scrX<>oldX)and(scrY<>oldY))then
         begin
            oldY-=1;
            while(oldY>=scrY)do
            begin
               draw_ellipse_quadrants(x,y,scrX,scrY,filled);
               oldY-=1;
               if(filled)then oldY:=scrY-1;
            end;

            oldX:=scrX;
            oldY:=scrY;
         end;
      end;

      if(not filled)then
      begin
         oldY-=1;
         while(oldY>=0)do
         begin
            draw_ellipse_quadrants(x,y,scrX,scrY,false);
            oldY-=1;
         end;
      end;
   end;
end;

procedure draw_ellipse(x,y,rx,ry:integer);
begin
   draw_base_ellipse(x,y,rx,ry,false);
end;

procedure draw_fellipse(x,y,rx,ry:integer);
begin
   draw_base_ellipse(x,y,rx,ry,true);
end;

procedure draw_circle(x0,y0,r:integer);
var x,y,
    tx,ty,
    di,error:integer;
begin
   if(r<0)then exit;
   di:=r*2;
   x :=r-1;
   y :=0;
   tx:=1;
   ty:=1;
   error:=tx-di;
   while(x>=y)do
   begin
      SDL_RenderDrawPoint(vid_renderer,x0+x,y0-y);
      SDL_RenderDrawPoint(vid_renderer,x0+x,y0+y);
      SDL_RenderDrawPoint(vid_renderer,x0-x,y0-y);
      SDL_RenderDrawPoint(vid_renderer,x0-x,y0+y);
      SDL_RenderDrawPoint(vid_renderer,x0+y,y0-x);
      SDL_RenderDrawPoint(vid_renderer,x0+y,y0+x);
      SDL_RenderDrawPoint(vid_renderer,x0-y,y0-x);
      SDL_RenderDrawPoint(vid_renderer,x0-y,y0+x);
      if(error<=0)then
      begin
         y    +=1;
         error+=ty;
         ty   +=2;
      end;
      if(error>0)then
      begin
         x    -=1;
         tx   +=2;
         error+=(tx-di);
      end;
   end;
end;

procedure draw_fcircle(x0,y0,r:integer);
var x,y,
    tx,ty,
    di,error:integer;
begin
   if(r<0)then exit;

   di:=r*2;
   x :=r-1;
   y :=0;
   tx:=1;
   ty:=1;
   error:=tx-di;
   while(x>=y)do
   begin
      SDL_RenderDrawLine(vid_renderer,x0-y,y0+x,x0+y,y0+x);
      SDL_RenderDrawLine(vid_renderer,x0-y,y0-x,x0+y,y0-x);
      SDL_RenderDrawLine(vid_renderer,x0-x,y0+y,x0-x,y0-y);
      SDL_RenderDrawLine(vid_renderer,x0+x,y0+y,x0+x,y0-y);
      if(error<=0)then
      begin
         y    +=1;
         error+=ty;
         ty   +=2;
      end;
      if(error>0)then
      begin
         x    -=1;
         tx   +=2;
         error+=(tx-di);
      end;
   end;
   draw_frect(x0-x,y0-y,x0+x,y0+y);
end;

////////////////////////////////////////////////////////////////////////////////
//
//   OTHER (SDL SURFACES)
//

procedure SDLSurf_boxColor(dst:pSDL_Surface;x1,y1,x2,y2:integer;color:TMWColor;lockSurf:boolean=true);
var
left,
right,
top,
bottom   : integer;
colorptr,
pixel    : pbyte;
pixellast: pointer;
x, dx, dy,
pixx, pixy,
w, h, tmp: integer;
begin
   if(dst=nil)then exit;

   if(dst^.clip_rect.w<=0)
   or(dst^.clip_rect.h<=0)then exit;

   if(dst^.format^.BytesPerPixel<>4)then

   if(x1>x2)then begin dx:=x1;x1:=x2;x2:=dx;end;
   if(y1>y2)then begin dy:=y1;y1:=y2;y2:=dy;end;

   left  :=dst^.clip_rect.x;
   if(x2<left)then exit;
   right :=dst^.clip_rect.x+dst^.clip_rect.w-1;
   if(x1>right)then exit;
   top   :=dst^.clip_rect.y;
   if(y2<top)then exit;
   bottom:=dst^.clip_rect.y+dst^.clip_rect.h-1;
   if(y1>bottom)then exit;

   { Clip all points }
   if(x1<left)
   then x1:=left
   else
     if(x1>right )then x1:=right;

   if (x2<left)
   then x2:=left
   else
     if(x2>right )then x2:=right;

   if(y1<top)
   then y1:=top
   else
     if(y1>bottom)then y1:=bottom;

   if(y2<top)
   then y2:=top
   else
     if(y2>bottom)then y2:=bottom;

   w:=x2-x1;
   h:=y2-y1;

   //if(w=0)or(h=0)then exit;

   colorptr:=@color;
   color   :=SDL_MapRGBA(dst^.format,colorptr[2],colorptr[1],colorptr[0],255);

   if(SDL_MUSTLOCK(dst))and(lockSurf)then
     if(SDL_LockSurface(dst)<0)then exit;

   {* More variable setup}
   dx:=w;
   dy:=h;
   pixx :=dst^.format^.BytesPerPixel;
   pixy :=dst^.pitch;
   pixel:=dst^.pixels+pixx*x1+pixy*y1;
   pixellast:= pixel +pixx*dx+pixy*dy;
   dx+=1;

   pixy-=pixx*dx;
   while(pixel<=pixellast)do
   begin
      for x:=0 to dx-1 do
      begin
         pixel^:=colorptr[0];pixel+=1;
         pixel^:=colorptr[1];pixel+=1;
         pixel^:=colorptr[2];pixel+=1;
         pixel^:=colorptr[3];pixel+=1;
      end;
      pixel+=pixy;
   end;

   if(SDL_MUSTLOCK(dst))and(lockSurf)then SDL_UnlockSurface(dst);
end;

procedure SDLSurf_filledcircleColor(dst:pSDL_Surface;x0,y0,r:integer;color:TMWColor);
var x,y,
    tx,ty,
    di,error:integer;
begin
   if(dst=nil)
   or(r<0)then exit;

   if(dst^.clip_rect.w<=0)
   or(dst^.clip_rect.h<=0)then exit;

   if(SDL_MUSTLOCK(dst))then
     if(SDL_LockSurface(dst)<0)then exit;

   di:=r*2;
   x :=r-1;
   y :=0;
   tx:=1;
   ty:=1;
   error:=tx-di;
   while(x>=y)do
   begin
      SDLSurf_boxColor(dst,x0-y,y0+x,x0+y,y0+x,color,false);
      SDLSurf_boxColor(dst,x0-y,y0-x,x0+y,y0-x,color,false);
      SDLSurf_boxColor(dst,x0-x,y0+y,x0-x,y0-y,color,false);
      SDLSurf_boxColor(dst,x0+x,y0+y,x0+x,y0-y,color,false);
      if(error<=0)then
      begin
         y    +=1;
         error+=ty;
         ty   +=2;
      end;
      if(error>0)then
      begin
         x    -=1;
         tx   +=2;
         error+=(tx-di);
      end;
   end;
   SDLSurf_boxColor(dst,x0-x,y0-y,x0+x,y0+y,color,false);

   if(SDL_MUSTLOCK(dst))then SDL_UnlockSurface(dst);
end;










