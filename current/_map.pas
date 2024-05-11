{$IFDEF _FULLGAME}

procedure map_MakeThemeSprites;
begin
   MakeTerrain;
   MakeCrater;
   MakeLiquid;
   MakeLiquidBack;
end;

procedure map_seed2theme;
begin
   SetTheme(
      map_seed and $0000000F,            // theme number
   -((map_seed and $00000FF0) shr 4 ),   // terrain
   -((map_seed and $000FF000) shr 12),   // liquid
   -((map_seed and $0FF00000) shr 20),   // liquid back
   -((map_seed and $F0000000) shr 28));  // crater
end;

{$ENDIF}

procedure map_RefreshDoodadsCells;
var dx0,dy0,dx1,dy1,d,dy:integer;
begin
   for dx0:=0 to dcn do
   for dy0:=0 to dcn do
   with map_dcell[dx0,dy0] do
   begin
      n:=0;
      setlength(l,n);
   end;

   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t>0)then
     begin
        dx0:=(x-r-dcw) div dcw;
        dy0:=(y-r-dcw) div dcw;
        dx1:=(x+r+dcw) div dcw;
        dy1:=(y+r+dcw) div dcw;
        while(dx0<=dx1)do
        begin
           for dy:=dy0 to dy1 do
            if(0<=dx0)and(dx0<=dcn)and(0<=dy)and(dy<=dcn)then
             with map_dcell[dx0,dy] do
             begin
                n+=1;
                setlength(l,n);
                l[n-1]:=@map_dds[d];
             end;
           dx0+=1;
        end;
     end;
end;

procedure map_AddDoodad(dx,dy:integer;dt:byte);
begin
   if(map_ddn>MaxDoodads)then map_ddn:=MaxDoodads;
   if(map_ddn<0)then exit;

   case dt of
   DID_LiquidR1,
   DID_LiquidR2,
   DID_LiquidR3,
   DID_LiquidR4,
   DID_Brock,
   DID_Srock,
   DID_Other     : begin
                      with map_dds[map_ddn] do
                      begin
                         t:=dt;
                         r:=DID_R[t];
                         x:=dx;
                         y:=dy;
                      end;
                      map_ddn-=1;
                   end;
   else
   end;
end;

procedure map_RandomBaseVars;
begin
   g_random_i  := word(map_seed);
   g_random_p  := byte(map_seed);
end;

procedure map_Vars;
begin
   map_RandomBaseVars;
   map_b1      := map_mw-map_b0;
   map_hmw     := map_mw div 2;

   map_symmetryDir:=map_seed mod 360;
   map_symmetryX0 :=map_hmw;
   map_symmetryY0 :=map_hmw;
   map_symmetryX1 :=round(map_symmetryX0+map_mw*2*cos(map_symmetryDir*DEGTORAD));
   map_symmetryY1 :=round(map_symmetryY0+map_mw*2*sin(map_symmetryDir*DEGTORAD));
   {$IFDEF _FULLGAME}
   if(menu_s2<>ms2_camp)then map_mw:=mm3(MinSMapW,map_mw,MaxSMapW);
   map_mmcx    := (vid_panelw-2)/map_mw;
   map_mmvw    := trunc(vid_cam_w*map_mmcx)+1;
   map_mmvh    := trunc(vid_cam_h*map_mmcx)+1;
   {$ENDIF}
end;

procedure SymmetryXY(x,y:integer;rx,ry:pinteger;SymmetryType:byte;sx0,sy0,sx1,sy1:integer);
var dx,dy,c:longint;
    a,b    :single;
begin
   case SymmetryType of
   0:begin // no symmetry
        rx^:=NOTSET;
        ry^:=NOTSET;
     end;
   1:begin // point symmetry
        rx^:=sx0-(x-sx0);
        ry^:=sy0-(y-sy0);
     end;
   else    // line symmetry
     if (sx0=sx1)
     and(sy0=sy1)then
     begin
        rx^:=sx0-(x-sx0);
        ry^:=sy0-(y-sy0);
     end
     else
     begin
        dx:=sx0-sx1;
        dy:=sy0-sy1;

        c :=(dx*dx+dy*dy);
        a :=(dx*dx-dy*dy)/c;
        b :=(2*dx*dy)    /c;
        rx^:= round(a*(x-sx0)+b*(y-sy0)+sx0);
        ry^:= round(b*(x-sx0)-a*(y-sy0)+sy0);
     end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  CHECKS

function CheckMapBorders(x,y,aborder:integer):boolean;
begin
   if(x=NOTSET)or(y=NOTSET)
   then CheckMapBorders:=true
   else CheckMapBorders:=(-aborder<=x)and(x<=(map_mw+aborder))
                      and(-aborder<=y)and(y<=(map_mw+aborder));
end;

function map_IfPlayerStartHere(ix0,iy0,ix1,iy1,d:integer):boolean;
var p:byte;
begin
   if(d<=0)then
   begin
      map_IfPlayerStartHere:=true;
      exit;
   end;
   map_IfPlayerStartHere:=false;

   if(point_dist_int(ix0,iy0,ix1,iy1)<d)then
   begin
      map_IfPlayerStartHere:=true;
      exit;
   end;

   for p:=0 to MaxPlayers do
    if(point_dist_int(ix0,iy0,map_psx[p],map_psy[p])<d)
    or(point_dist_int(ix1,iy1,map_psx[p],map_psy[p])<d)then
    begin
       map_IfPlayerStartHere:=true;
       break;
    end;
end;

function map_IfCPointHere(ix0,iy0,ix1,iy1,d:integer):boolean;
var p:byte;
    t:integer;
begin
   if(d<=0)then
   begin
      map_IfCPointHere:=true;
      exit;
   end;
   map_IfCPointHere:=false;

   if(point_dist_int(ix0,iy0,ix1,iy1)<(d*2))then
   begin
      map_IfCPointHere:=true;
      exit;
   end;

   for p:=1 to MaxCpoints do
    with g_cpoints[p] do
     if(cpCaptureR>0)then
     begin
        t:=d+max2(cpsolidr,cpCaptureR);
        if(point_dist_int(ix0,iy0,cpx,cpy)<t)
        or(point_dist_int(ix1,iy1,cpx,cpy)<t)then
        begin
           map_IfCPointHere:=true;
           break;
        end;
     end;
end;

function map_IfDoodadHere(dtype:byte;ix0,iy0,ix1,iy1,DoodadAR:integer):boolean;
var d,o:integer;
function DoodadMinR(t1,t2:byte):integer;
begin
   {if(t1 in dids_liquids)
  and(t2 in dids_liquids)then
   begin
      DoodadMinR:=DID_R[t1]+DID_R[t2]-(DID_R[t1] div 5)-(DID_R[t2] div 5)-DoodadAR;
      exit;
   end;

   if(t1 in dids_liquids)
   or(t2 in dids_liquids)then
   begin
      DoodadMinR:=max2(DID_R[t1],DID_R[t2])-DoodadAR;
      exit;
   end;
   DoodadMinR:=DID_R[t1]+DID_R[t2]-DoodadAR-10;  }
   if(DoodadAR>=0)
   then DoodadMinR:=DID_R[t1]+DID_R[t2]+DoodadAR
   else DoodadMinR:=(DID_R[t1]+DID_R[t2])-(abs(DID_R[t1] div DoodadAR)+abs(DID_R[t2] div DoodadAR));
end;
begin
   map_IfDoodadHere:=false;

   if(point_dist_int(ix0,iy0,ix1,iy1)<DoodadMinR(dtype,dtype))then
   begin
      map_IfDoodadHere:=true;
      exit;
   end;

   for d:=1 to MaxDoodads do
    with map_dds[d] do
     if(t>0)then
     begin
        o:=DoodadMinR(t,dtype);
        if(point_dist_int(x,y,ix0,iy0)<o)
        or(point_dist_int(x,y,ix1,iy1)<o)then
        begin
           map_IfDoodadHere:=true;
           break;
        end;
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  CPOINTS

procedure map_CPoints_UpdatePFZone;
var pn:integer;
begin
   for pn:=1 to MaxCPoints do
    with g_cpoints[pn] do
     if(cpCaptureR>0)then cpzone:=pf_get_area(cpx,cpy);
end;

procedure map_CPoints_Default(num:byte;sr,cr,nr,energy,time:integer;lifetime:cardinal;newpoints:boolean);
var ix0,iy0,
    ix1,iy1,
    i,u,b,c,
    dst:integer;
function _setcpoint(px,py:integer):boolean;
var pn:byte;
begin
   for pn:=1 to MaxCPoints do
    if(g_cpoints[pn].cpCaptureR<=0)then break;

   if(pn>MaxCPoints)then
   begin
      _setcpoint:=true;
      exit;
   end
   else _setcpoint:=false;

   with g_cpoints[pn] do
   begin
      cpx          :=px;
      cpy          :=py;
      cp_ToCenterD :=point_dist_int(cpx,cpy,map_hmw,map_hmw);
      cpsolidr     :=sr;
      cpNoBuildR   :=nr;
      cpenergy     :=energy;
      cpCaptureR   :=cr;
      cpCaptureTime:=time;
      cplifetime   :=lifetime;
      {$IFDEF _FULLGAME}
      cpmx:=round(cpx*map_mmcx);
      cpmy:=round(cpy*map_mmcx);
      cpmr:=round(cpCaptureR*map_mmcx);
      {$ENDIF}
   end;
end;
begin
   if(newpoints)then FillChar(g_cpoints,SizeOf(g_cpoints),0);
   u:=map_mw div 50;
   b:=map_mw-(u*2);

   i:=0;
   while(i<num)do
   begin
      i+=1+byte(map_symmetry);
      c:=0;
      dst:=max2(base_1rh,map_mw div 8);
      while(c<1000)do
      begin
         ix0:=u+g_random(b);
         iy0:=u+g_random(b);
         SymmetryXY(ix0,iy0,@ix1,@iy1,map_symmetry,map_symmetryX0,map_symmetryY0,map_symmetryX1,map_symmetryY1);

         c+=1;
         if(c>500)then dst-=1;

         if CheckMapBorders(ix1,iy1,0)then
           if (not map_IfPlayerStartHere(ix0,iy0,ix1,iy1,dst))
           and(not map_IfCPointHere     (ix0,iy0,ix1,iy1,dst))then
           begin
              if(_setcpoint(ix0,iy0))then exit;
              if(ix1<>NOTSET)then
                if(_setcpoint(ix1,iy1))then exit;
              break;
           end;
      end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  PLAYER STARTS

procedure map_PlayerStartsCircle(cx,cy,sdir,r:integer);
const dstep = 360 div MaxPlayers;
var i:byte;
begin
   sdir:=abs(sdir mod 360)+(dstep div 2);
   for i:=1 to 3 do
   begin
      sdir+=dstep;
      map_psx[i  ]:=cx+trunc(r*cos(sdir*degtorad));
      map_psy[i  ]:=cy+trunc(r*sin(sdir*degtorad));
      map_psx[i+3]:=map_mw-map_psx[i  ];
      map_psy[i+3]:=map_mw-map_psy[i  ];
   end;
end;

procedure map_PlayerStartsDefault(FreeCenterR:integer);
var ix0,iy0,
    ix1,iy1,
    i,u,c,bb0,bb1,dst:integer;
begin
   bb0:=base_1r+(map_mw-MinSMapW) div 9;
   bb1:=map_mw-(bb0*2);
   dst:=base_1r+(map_mw div 5);

   for i:=1 to MaxPlayers do
   begin
      if(map_symmetry>0)and(i>3)then break;
      c:=0;
      u:=dst;
      while true do
      begin
         ix0:=bb0+g_random(bb1);
         iy0:=bb0+g_random(bb1);
         SymmetryXY(ix0,iy0,@ix1,@iy1,map_symmetry,map_symmetryX0,map_symmetryY0,map_symmetryX1,map_symmetryY1);

         c+=1;
         if(c>500 )then u-=1;

         if(CheckMapBorders(ix1,iy1,-bb0))then
           if(c>1000)
           or (not map_IfPlayerStartHere(ix0,iy0,ix1,iy1,u)
           and(point_dist_int(ix0,iy0,map_hmw,map_hmw)>FreeCenterR)
           and(point_dist_int(ix1,iy1,map_hmw,map_hmw)>FreeCenterR))then break;
      end;

      map_psx[i]:=ix0;
      map_psy[i]:=iy0;
      if(map_symmetry>0)then
      begin
         map_psx[i+3]:=ix1;
         map_psy[i+3]:=iy1;
      end;
   end;

   dst-=dst div 5;
   c:=0;
   for i:=1 to MaxPlayers do
   for u:=1 to MaxPlayers do
    if(i<>u)then
      if(point_dist_int(map_psx[i],map_psy[i],map_psx[u],map_psy[u])<dst)then c+=1;
   if(c>0)then map_PlayerStartsCircle(map_hmw,map_hmw,map_symmetryDir,map_hmw-(map_mw div 8));
end;

procedure map_ShufflePlayerStarts;
var x,y:byte;
    i:integer;
begin
   for x:=1 to MaxPlayers do
    for y:=1 to MaxPlayers do
     if(random(2)=0)and(x<>y)then
     begin
        i:=map_psx[x];map_psx[x]:=map_psx[y];map_psx[y]:=i;
        i:=map_psy[x];map_psy[x]:=map_psy[y];map_psy[y]:=i;
     end;
end;

procedure map_PlayerStarts;
var ix,iy,i,u,c:integer;
begin
   for i:=0 to MaxPlayers do
   begin
      map_psx[i]:=-5000;
      map_psy[i]:=-5000;
   end;

   case g_mode of
gm_3x3     :begin
               u :=map_hmw-(map_mw div 7);
               c :=u+base_hr;
               i :=map_symmetryDir+90;

               case map_type of
               mapt_lake  : ix:=round(60*(MinSMapW/map_mw))+round(3*(map_mw/MinSMapW));
               mapt_shore : ix:=round(60*(MinSMapW/map_mw))+round(5*(map_mw/MinSMapW));
               else         ix:=round(65*(MinSMapW/map_mw));
               end;

               map_psx[1]:=round(map_hmw+cos( i    *degtorad)*u);
               map_psy[1]:=round(map_hmw+sin( i    *degtorad)*u);
               map_psx[2]:=round(map_hmw+cos((i-ix)*degtorad)*c);
               map_psy[2]:=round(map_hmw+sin((i-ix)*degtorad)*c);
               map_psx[3]:=round(map_hmw+cos((i+ix)*degtorad)*c);
               map_psy[3]:=round(map_hmw+sin((i+ix)*degtorad)*c);

               map_psx[4]:=map_mw-map_psx[1];
               map_psy[4]:=map_mw-map_psy[1];
               map_psx[5]:=map_mw-map_psx[2];
               map_psy[5]:=map_mw-map_psy[2];
               map_psx[6]:=map_mw-map_psx[3];
               map_psy[6]:=map_mw-map_psy[3];
            end;
gm_2x2x2   :begin
               iy:=base_2r+(map_mw div 30);
               u :=map_hmw-(map_hmw div 3);
               c :=map_symmetryDir;

               ix:=round(60*(MinSMapW/map_mw));
               iy:=ix div 2;
               i:=1;
               while(i<MaxPlayers)do
               begin
               map_psx[i  ]:=round(map_hmw+cos((c-iy)*degtorad)*u);
               map_psy[i  ]:=round(map_hmw+sin((c-iy)*degtorad)*u);
               map_psx[i+1]:=round(map_hmw+cos((c+iy)*degtorad)*u);
               map_psy[i+1]:=round(map_hmw+sin((c+iy)*degtorad)*u);
               c+=120;
               i+=2;
               end;
            end;
gm_invasion:begin
               map_psx[0]:=map_hmw;
               map_psy[0]:=map_hmw;
               map_PlayerStartsCircle(map_hmw,map_hmw,map_symmetryDir,base_2r);
            end;
gm_KotH    :begin
               map_psx[0]:=map_hmw;
               map_psy[0]:=map_hmw;
               map_PlayerStartsCircle(map_hmw,map_hmw,map_symmetryDir,map_hmw-(map_mw div 8));
            end;
gm_royale  :begin
               map_PlayerStartsCircle(map_hmw,map_hmw,map_symmetryDir,map_hmw-(map_mw div 5));
            end;
gm_capture :begin
               map_PlayerStartsDefault(byte(map_type=mapt_lake)*(map_mw div 3));
            end;
   else
               map_PlayerStartsDefault(byte(map_type=mapt_lake)*(map_mw div 3));
   end;
end;

procedure map_CPoints;
begin
   FillChar(g_cpoints,SizeOf(g_cpoints),0);

   case g_mode of
gm_KotH   : with g_cpoints[1] do
            begin
               cpx:=map_hmw;
               cpy:=map_hmw;
               cpCaptureR   :=base_1r;
               cpCaptureTime:=fr_fps1*60;

               {$IFDEF _FULLGAME}
               cpmx:=round(cpx*map_mmcx);
               cpmy:=round(cpy*map_mmcx);
               cpmr:=round(cpCaptureR*map_mmcx)+1;
               {$ENDIF}
            end;
gm_capture: map_CPoints_Default(4,0,gm_cptp_r,base_1r,0,gm_cptp_time,0,true);
   end;

   if(g_generators>1)then
    map_CPoints_Default(MaxCPoints,50,gm_cptp_r,gm_cptp_r div 2,g_cgenerators_energy,gm_cptp_gtime,g_cgenerators_ltime[g_generators],false);
end;

function map_TrySetDoodad(di:byte;ix0,iy0,ix1,iy1,PStartDist,DoodadAR,MapBorder:integer):boolean;
begin
   map_TrySetDoodad:=false;
   if (not map_IfPlayerStartHere(ix0,iy0,ix1,iy1,PStartDist))
   and(not map_IfDoodadHere  (di,ix0,iy0,ix1,iy1,DoodadAR  ))then
   begin
      if CheckMapBorders(ix0,iy0,MapBorder)then map_AddDoodad(ix0,iy0,di);
      if(ix1<>NOTSET)then
      if CheckMapBorders(ix1,iy1,MapBorder)then map_AddDoodad(ix1,iy1,di);
      map_TrySetDoodad:=true;
   end;
end;

function map_DoodadNoisePickSet(ix0,iy0,ix1,iy1:integer;lqs,rks:pinteger;PStartDist,DoodadAR:integer):boolean;
var di:byte;
begin
   map_DoodadNoisePickSet:=false;
   for di:=DID_liquidR1 to DID_Other do
    case di of
    DID_LiquidR1,
    DID_LiquidR2,
    DID_LiquidR3,
    DID_LiquidR4  : if(lqs^<=0)
                    then continue
                    else
                      if(map_TrySetDoodad(di,ix0,iy0,ix1,iy1,PStartDist+DID_S2Rh[di],DoodadAR,DID_R[di]))then
                      begin
                         map_DoodadNoisePickSet:=true;
                         lqs^-=1;
                         break;
                      end
                      else continue;
    DID_SRock,
    DID_BRock     : if(rks^<=0)
                    then continue
                    else
                      if(map_TrySetDoodad(di,ix0,iy0,ix1,iy1,PStartDist+DID_S2Rh[di],DoodadAR,0))then
                      begin
                         map_DoodadNoisePickSet:=true;
                         rks^-=1;
                         break;
                      end
                      else continue;
    else
      if(map_TrySetDoodad(di,ix0,iy0,ix1,iy1,PStartDist+DID_S2Rh[di],DoodadAR,0))then
      begin
         map_DoodadNoisePickSet:=true;
         break;
      end
      else continue;
    end;
end;

procedure map_DoodadNoise(liquidX,othersX:byte;DoodadAR:integer);
const dpostime = 400;
var ix0,iy0,
    ix1,iy1,
    i,lqs,rks,
    cnt,ir,
    cicles:integer;
begin
   rks :=0;
   lqs :=0;

   if(othersX>0)then
   begin
      i:=(map_ddn div 8);
      if(liquidX>0)then
      begin
         ix0:=i*othersX;
         lqs:=max2(liquidX,(ix0 div 8)*liquidX);
         rks:=max2(othersX,ix0-lqs);
      end
      else rks:=max2(othersX,i*othersX);
   end
   else lqs:=max2(liquidX,(map_ddn div 80)*liquidX);

   cicles:=0;
   ir :=base_1r+(map_mw div 100);
   ix0:=integer(map_seed);
   iy0:=0;

   while(map_ddn>=0)do
   begin
      cnt:=0;
      while true do
      begin
         ix0:=g_randomx(ix0,map_mw);
         iy0:=g_randomx(iy0,map_mw);
         SymmetryXY(ix0,iy0,@ix1,@iy1,map_symmetry,map_symmetryX0,map_symmetryY0,map_symmetryX1,map_symmetryY1);

         if(map_DoodadNoisePickSet(ix0,iy0,ix1,iy1,@lqs,@rks,ir,DoodadAR))then
         begin
            cicles:=0;
            break;
         end;

         cnt+=1;
         if(cnt>=dpostime)then
         begin
            cicles+=1;
            break;
         end;
      end;
      if(cicles>10)then exit;
   end;
end;

procedure map_DoodadFiledCircle(di:byte;cx,cy,cr:integer;forcesymmetry:byte);
var sx,sy,
    ex,
    PStartDist,wr,
    wr2  :integer;
    n    :boolean;
    csxX,
    csyX,
    csxY,
    csyY :integer;
    oxX,oyX,
    oxY,oyY,
    dirX,
    dirY :single;
procedure CheckAndSet(ix0,iy0:integer;symmetry:boolean);
var ix1,iy1:integer;
begin
   if(point_dist_int(cx,cy,ix0,iy0)<=(cr-DID_R[di]))then
   begin
      if(symmetry)
      then SymmetryXY(ix0,iy0,@ix1,@iy1,forcesymmetry,map_symmetryX0,map_symmetryY0,map_symmetryX1,map_symmetryY1)
      else
      begin
         ix1:=NOTSET;
         iy1:=NOTSET;
      end;
      map_TrySetDoodad(di,ix0,iy0,ix1,iy1,PStartDist,-3,wr2); //wr2 div 2
   end;
end;
begin
   wr :=DID_S2R [di];
   wr2:=DID_S2Rh[di];
   PStartDist :=base_1r+wr2+(map_mw div 75);
   cr+=wr;

   sx:=0;
   sy:=0;
   ex:=cr+wr2;
   n :=false;

   dirX:=map_symmetryDir*DEGTORAD;
   oxX:=cos(dirX);
   oyX:=sin(dirX);
   dirY:=(map_symmetryDir+90)*DEGTORAD;
   oxY:=cos(dirY);
   oyY:=sin(dirY);

   while(sy<=ex)do
   begin
      csxY:=round(sy*oxY);
      csyY:=round(sy*oyY);

      if(n)
      then sx:=wr2
      else sx:=0;

      while(sx<=ex)do
      begin
         csxX:=round(sx*oxX);
         csyX:=round(sx*oyX);

         CheckAndSet(cx+csxX+csxY,cy+csyX+csyY,(sy>0)and(forcesymmetry>0));
         CheckAndSet(cx-csxX+csxY,cy-csyX+csyY,(sy>0)and(forcesymmetry>0));
         if(forcesymmetry=0)and(sy>0)then
         begin
         CheckAndSet(cx+csxX-csxY,cy+csyX-csyY,false);
         CheckAndSet(cx-csxX-csxY,cy-csyX-csyY,false);
         end;
         sx+=wr;
      end;

      n :=not n;
      sy+=wr;
   end;
end;

procedure map_ReMake;
var ix,iy:integer;
 symmetry:byte;
begin
   map_ddn:=0;
   FillChar(map_dds,SizeOf(map_dds),0);
   for ix:=0 to dcn do
   for iy:=0 to dcn do
   with map_dcell[ix,iy] do
   begin
      n:=0;
      setlength(l,n);
   end;

   map_ddn:=trunc(MaxDoodads*((sqr(map_mw) div ddc_div)/ddc_cf))+1;

   if(map_symmetry>0)
   then map_ddn:=mm3(1,round(map_ddn/1.5),MaxDoodads)
   else map_ddn:=mm3(1,      map_ddn     ,MaxDoodads);

   case map_type of
mapt_steppe: begin
             map_DoodadNoise(0,0,0);
             end;
mapt_nature: begin
             map_DoodadNoise(2,2,50);
             end;
mapt_lake  : begin
             ix:=round(map_mw/2.9);
             map_DoodadFiledCircle(DID_LiquidR1,map_hmw,map_hmw,ix,map_symmetry);
             if(map_mw<=3500)then
             begin
             //map_DoodadFiledCircle(DID_LiquidR2,map_hmw,map_hmw,ix,map_symmetry);
             map_DoodadFiledCircle(DID_LiquidR3,map_hmw,map_hmw,ix,map_symmetry);
             //map_DoodadFiledCircle(DID_LiquidR4,map_hmw,map_hmw,ix,map_symmetry);
             end;

             map_ddn:=map_ddn div 3;
             map_DoodadNoise(0,0,50);
             end;
mapt_shore: begin
             ix:=map_mw*2;
             if(map_symmetry=1)
             then symmetry:=0
             else symmetry:=map_symmetry;

             map_DoodadFiledCircle(DID_LiquidR1,map_symmetryX1,map_symmetryY1,ix,symmetry);
             if(map_mw<=3500)then
             begin
             //map_DoodadFiledCircle(DID_LiquidR2,map_symmetryX1,map_symmetryY1,ix,symmetry);
             map_DoodadFiledCircle(DID_LiquidR3,map_symmetryX1,map_symmetryY1,ix,symmetry);
            // map_DoodadFiledCircle(DID_LiquidR4,map_symmetryX1,map_symmetryY1,ix,symmetry);
             end;

             map_ddn:=map_ddn div 2;
             map_DoodadNoise(1,2,50);
             end;
mapt_sea   : begin
             ix:=map_mw;
             map_DoodadFiledCircle(DID_LiquidR1,map_hmw,map_hmw,ix,map_symmetry);
             if(map_mw<=3500)then
             begin
             //map_DoodadFiledCircle(DID_LiquidR2,map_hmw,map_hmw,ix,map_symmetry);
             map_DoodadFiledCircle(DID_LiquidR3,map_hmw,map_hmw,ix,map_symmetry);
             //map_DoodadFiledCircle(DID_LiquidR4,map_hmw,map_hmw,ix,map_symmetry);
             end;
             map_ddn:=map_ddn div 6;
             map_DoodadNoise(0,1,-50);
             end;
   end;

   map_RefreshDoodadsCells;
   map_RandomBaseVars;
   map_CPoints;
   pf_MakeZoneGrid;
   map_CPoints_UpdatePFZone;
   {$IFDEF _FULLGAME}
   map_DoodadsDrawData;
   map_tdmake;
   vid_map_RedrawBack:=true;
   {$ENDIF}
end;

procedure Map_randomseed;
begin
   map_seed:=random($FFFFFFFF)+(SDL_GetTicks shl 5);
end;

procedure Map_randommap;
begin
   Map_randomseed;

   map_mw :=MinSMapW+round(random(MaxSMapW-MinSMapW)/StepSMap)*StepSMap;
   map_type:=random(gms_m_types+1);
   map_symmetry:=random(3);
end;

procedure Map_premap;
begin
   map_Vars;
   map_PlayerStarts;
   {$IFDEF _FULLGAME}
   map_seed2theme;
   map_MakeThemeSprites;
   {$ENDIF}
   map_ReMake;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  map settings

function map_SetSize(new_size:integer):boolean;
begin
   map_SetSize:=false;
   if(g_preset_cur>0)or(new_size<MinSMapW)or(MaxSMapW<new_size)then exit;
   map_SetSize:=true;
   map_mw:=new_size;
   map_premap;
end;
function map_SetType(new_type:byte):boolean;
begin
   map_SetType:=false;
   if(g_preset_cur>0)or(gms_m_types<new_type)then exit;
   map_SetType:=true;
   map_type:=new_type;
   map_premap;
end;
function map_SetSymmetry(new_symmetry:byte):boolean;
begin
   map_SetSymmetry:=false;
   if(g_preset_cur>0)or(gms_m_symm<new_symmetry)then exit;
   map_SetSymmetry:=true;
   map_symmetry:=new_symmetry;
   map_premap;
end;


//



