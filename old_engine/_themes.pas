

function _xasurf(s:PSDL_Surface;xa,ya,trans:boolean):PSDL_Surface;
var x,y,sx,sy:integer;
    c:cardinal;
begin
   _xasurf:=_createSurf(s^.w,s^.h);
   for x:=1 to s^.w do
    for y:=1 to s^.h do
    begin
       if(xa)then sx:=s^.w-x else sx:=x-1;
       if(ya)then sy:=s^.h-y else sy:=y-1;
       c:=SDL_GETpixel(s,x-1,y-1);

       SDL_SETpixel(_xasurf,sx,sy,c);
    end;
   if(trans)then SDL_SetColorKey(_xasurf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(_xasurf,0,0));
end;

procedure LPTUSpriteL(l:PTUSpriteL;str:shortstring;it:pinteger);
var t:TMWSprite;
    i:integer;
procedure next;begin inc(it^,1);setlength(l^,it^);l^[it^-1]:=t;end;
begin
   it^ :=0;
   i   :=0;
   while true do
   begin
      with t do
      begin
         surf:=LoadIMG(str+i2s(i),false,false);
         if(surf=r_empty)then break;
         w   :=surf^.w;
         h   :=surf^.h;
         hw  :=surf^.w div 2;
         hh  :=surf^.h div 2;
      end;
      next;

      with t do
      begin
         surf:=_xasurf(surf,true,false,false);
      end;
      next;

      inc(i,1);
   end;

   if(it^=0)then
   begin
      t:=spr_dummy;
      next;
   end;
end;

procedure IntListAdd(_il:PTIntList;_iln:pinteger;k:integer);
begin
   inc(_iln^,1);
   setlength(_il^,_iln^);
   _il^[_iln^-1]:=k;
end;

procedure Str2IntList(s:shortstring;_il:PTIntList;_iln:pinteger);
var p,l:integer;
    v,u:shortstring;

begin
   _iln^:=0;
   setlength(_il^,_iln^);

   l:=length(s);
   while (l>0) do
   begin
      v:='';
      p:=pos(',',s);
      if(p>0)then
      begin
         v:=copy(s,1,p-1);
         delete(s,1,p);
      end
      else
      begin
         v:=s;
         delete(s,1,l);
      end;

      while (true) do
      begin
         p:=pos(' ',v);
         if(p=0)
         then break
         else delete(v,p,1);
      end;

      if(v<>'')then
      begin
         p:=pos('_',v);
         if(p>0)then
         begin
            u:=copy(v,1,p-1);
            delete(v,1,p);
            if(u<>'')and(v<>'')then
            begin
               p:=s2i(u);
               l:=s2i(v);
               while (true) do
               begin
                  IntListAdd(_il,_iln,p);
                  if(p=l)
                  then break
                  else inc(p,sign(l-p));
               end;
            end;
         end
         else IntListAdd(_il,_iln,s2i(v));
      end;

      l:=length(s);
   end;
end;

procedure ThemeSetTrans(l:PTUSpriteL;it:pinteger;str:shortstring);
var i,o,
 _iln:integer;
 _il :TIntList;
begin
   if(str<>'all')then
   begin
      Str2IntList(str,@_il,@_iln);

      for i:=1 to _iln do
      begin
         o:=_il[i-1]*2;
         if(o<it^)then
         begin
            with l^[o  ] do SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(surf,0,0));
            with l^[o+1] do SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(surf,0,0));
         end;
      end;
   end
   else
    for i:=1 to it^ do
     with l^[i-1] do
      SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(surf,0,0));
end;

{
animn,animt,
dpth,shh,ox,oy,
mmx,mmy,mmr :integer;
spr,
pspr        :PTMWSprite;
mmc         :cardinal;
}
procedure DecAnim(l:PTThemeAnimL;it:pinteger;str:shortstring;);
var i,o,
 _iln:integer;
 _il :TIntList;
begin
   if(str<>'all')then
   begin
      Str2IntList(str,@_il,@_iln);

   end;

procedure _liqAnim(i:integer;r,g,b:byte;atp,animt:byte);
begin
   theme_clr_liquids[i]:=rgba2c(r,g,b,255);
   theme_anm_liquids[i]:=atp;
   theme_ant_liquids[i]:=animt;
end;

procedure LiquidAnims(i:integer;r,g,b:byte;atp,animt:byte);
begin
   _liqAnim(i*2  ,r,g,b,atp,animt);
   _liqAnim(i*2+1,r,g,b,atp,animt);
end;

procedure InitThemes;
var o:integer;
begin
   // load graph
   LPTUSpriteL(@theme_spr_decals  , str_f_map+'decals\adt'      , @theme_spr_decaln  );
   LPTUSpriteL(@theme_spr_decors  , str_f_map+'decors\dec_'     , @theme_spr_decorn  );
   LPTUSpriteL(@theme_spr_srocks  , str_f_map+'srocks\rocks'    , @theme_spr_srockn  );
   LPTUSpriteL(@theme_spr_brocks  , str_f_map+'brocks\rockb'    , @theme_spr_brockn  );
   LPTUSpriteL(@theme_spr_liquids , str_f_map+'liquids\liquid_' , @theme_spr_liquidn );
   LPTUSpriteL(@theme_spr_terrains, str_f_map+'terrains\ter'    , @theme_spr_terrainn);

   // transparent                             21-22
   ThemeSetTrans(@theme_spr_decals,@theme_spr_decaln,'0_20,23_34');
   ThemeSetTrans(@theme_spr_decors,@theme_spr_decorn,'all');
   ThemeSetTrans(@theme_spr_srocks,@theme_spr_srockn,'all');
   ThemeSetTrans(@theme_spr_brocks,@theme_spr_brockn,'all');

   // animation and effects
   //setlength(theme_anm_decals  ,theme_spr_decaln  );
   setlength(theme_anm_decors  ,theme_spr_decorn  );
   setlength(theme_anm_srocks  ,theme_spr_srockn  );
   setlength(theme_anm_brocks  ,theme_spr_brockn  );

   for o:=1 to theme_spr_decorn do begin FillChar(theme_anm_decors[o-1],SizeOf(theme_anm_decors[o-1]),0);theme_anm_decors[o-1].sh:=1; end;
   for o:=1 to theme_spr_srockn do begin FillChar(theme_anm_srocks[o-1],SizeOf(theme_anm_srocks[o-1]),0); end;
   for o:=1 to theme_spr_brockn do begin FillChar(theme_anm_brocks[o-1],SizeOf(theme_anm_brocks[o-1]),0); end;

{
tdecan 1 , 0, 0, -8
tdecan 2 , 0, 0, -8
tdecan 3 , 0, 0, -14
tdecan 5 , 0, 0, -18
tdecan 7 , 0, 0, -18
tdecan 8 , 0, 0, -18
tdecan 9 , 0, 0, -18
tdecan 10, 0, 0, -18
tdecan 11, 0, 0, -18
tdecan 12, 0, 0, -18
tdecan 13, 0, 0, -3
tdecan 14, 250,114, 0
tdecan 114,250,14 , 0
tdecan 15, 0, 0, -5
tdecan 16, 0, 0, -5
tdecan 17, 0, 0, -5
tdecan 18, 0, 0, -18
tdecan 19, 0, 0, -21
tdecan 22 , 255,122, -9
tdecan 122, 252, 22, -9
tdecan 23 , 255,123, -8
tdecan 123, 252, 23, -8
tdecan 24, 0, 0, -8
tdecan 25, 0, 0, -8
tdecan 26, 0, 0, -8
tdecan 27, 0, 0, -8
tdecan 29, 0, 0, -7
tdecan 30, 0, 0, -4
tdecan 31, 0, 0, -4
tdecan 32, 0, 0, -20
tdecan 33, 0, 0, -22
tdecan 34, 0, 0, -10
tdecan 36, 0, 0, -10
tdecan 39, 0, 0, -5
tdecan 41, 0, 0, -5
tdecan 100, 15, 101, -15
tdecan 101, 15, 100, -15
tdecan 102, 15, 103, -15
tdecan 103, 15, 102, -15
tdecan 104, 15, 105, -15
tdecan 105, 15, 104, -15
tdecan 110, 15, 111, -3
tdecan 111, 15, 112, -3
tdecan 112, 15, 110, -3

### small rocks

srockan 3  , 20, 103, 0, rock with pool 1
srockan 103, 20,   3, 0
srockan 4  , 20, 104, 0, rock with pool 2
srockan 104, 20,   4, 0

srockan 9  , 250, 109, 0, hell rocks 1
srockan 109, 250,   9, 0
srockan 10 , 250, 110, 0, hell rocks 2
srockan 110, 250,  10, 0
srockan 11 , 250, 111, 0, hell rocks 3
srockan 111, 250,  11, 0
srockan 12 , 250, 112, 0, hell rocks 4
srockan 112, 250,  12, 0

### big rocks

brockan 5  , 250, 105, 0, hell rocks 1
brockan 105, 250, 5  , 0
brockan 6  , 250, 106, 0, hell rocks 2
brockan 106, 250, 6  , 0
brockan 7  , 250, 107, 0, hell rocks 3
brockan 107, 250, 7  , 0
brockan 8  , 250, 108, 0, hell rocks 4
brockan 108, 250, 8  , 0

brockan 9  , 20, 109, 0, tech slime canister
brockan 109, 20, 9  , 0
brockan 11 , 20, 111, 0, tech water canister
brockan 111, 20, 11 , 0

brockan 13 , 250, 113, 0, hell rocks 5
brockan 113, 250, 13 , 0
brockan 14 , 250, 114, 0, hell rocks 6
brockan 114, 250, 14 , 0
}

   // liquids
   setlength(theme_anm_liquids ,theme_spr_liquidn );
   setlength(theme_ant_liquids ,theme_spr_liquidn );
   setlength(theme_clr_liquids ,theme_spr_liquidn );

   LiquidAnims(0,  16 , 16 , 150  , 0, 30);
   LiquidAnims(1,  10 , 150, 10   , 0, 30);
   LiquidAnims(2,  136, 68 , 32   , 0, 30);
   LiquidAnims(3,  136, 0  , 16   , 0, 30);
   LiquidAnims(4,  220, 100, 15   , 0, 30);
   LiquidAnims(5,  163, 82 , 82   , 1, 20);
   LiquidAnims(6,  30 , 30 , 150  , 0, 15);
   LiquidAnims(7,  64 , 128, 128  , 0, 15);
   LiquidAnims(8,  210, 168, 0    , 0, 15);
   LiquidAnims(9,  160, 120, 15   , 1, 15);
   LiquidAnims(10, 140, 20 , 0    , 0, 15);
   LiquidAnims(11, 255, 180, 15   , 1, 15);
   LiquidAnims(12, 0  , 128, 64   , 0, 15);
   LiquidAnims(13, 200, 82 , 0    , 0, 15);
   LiquidAnims(14, 0  , 128, 192  , 0, 10);
   LiquidAnims(15, 80 , 230, 80   , 0, 10);
   LiquidAnims(16, 100, 100, 100  , 2, 10);

   theme_n:=3;
end;

procedure SetThemeList(lst:PTIntList;lstn,smax:pinteger;str:shortstring);
var i,o,
 _iln:integer;
 _il :TIntList;
begin
   Str2IntList(str,@_il,@_iln);

   lstn^:=0;
   setlength(lst^,lstn^);

   for i:=1 to _iln do
   begin
      o:=_il[i-1];
      if(o>=0)then
      begin
         o:=o*2;
         if(o<smax^)then
         begin
            IntListAdd(lst,lstn,o  );
            IntListAdd(lst,lstn,o+1);
         end;
      end
      else IntListAdd(lst,lstn,o);
   end;
end;

{

theme_decors,
theme_srocks,
theme_brocks,
theme_craters,
theme_liquids,
theme_bliquids,
theme_terrains    : TIntList;
}

procedure SetTheme(i,ter,liq,bliq,crt:integer);
procedure SetTLBlC;
begin
   if(theme_terrainn=0)then theme_map_trt :=-1 else if(ter <0)then theme_map_trt :=abs(ter  mod theme_terrainn) else theme_map_trt :=min2(theme_terrainn,ter );
   if(theme_liquidn =0)then theme_map_lqt :=-1 else if(liq <0)then theme_map_lqt :=abs(liq  mod theme_liquidn ) else theme_map_lqt :=min2(theme_liquidn ,liq );
   if(theme_bliquidn=0)then theme_map_blqt:=-1 else if(bliq<0)then theme_map_blqt:=abs(bliq mod theme_bliquidn) else theme_map_blqt:=min2(theme_bliquidn,bliq);
   if(theme_cratern =0)then theme_map_crt :=-1 else if(crt <0)then theme_map_crt :=abs(crt  mod theme_cratern ) else theme_map_crt :=min2(theme_cratern ,crt );
end;
begin
   i:=i mod theme_n;
   theme_i:=i;
   case i of
   0: begin
         theme_name:= #18+'TECH BASE';
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'-1_-4,21,22,26,27,29,31,32');

         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'17,18'      );
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'0_2,6,13_15');
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'19,26'      );
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'18,19,26'   );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_spr_srockn  ,'13_19'      );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_spr_brockn  ,'9_12'       );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_spr_decorn  ,'19,22_27,29_32,35,37_41,110_112');

         SetTLBlC;

         theme_map_blqtt:=1;
      end;
   1: begin
         theme_name:= #20+'ICE CAVES' ;
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'-1_-4,4_20,23_25,28,30,33,34');

         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'0,2,11_13,20,25');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'16'             );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'0,2,11_13,20,25');
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'0,2,11_13,20,25');

         SetTLBlC;

         theme_map_blqtt:=0;
      end;
   2: begin
         theme_name:=  #17+'HELL' ;
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'-1_-4,4,9,15,18_20,23_25,28,30,33,34');

         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'4,10,14,16,21,23');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'4,5,8_9,11'      );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'4,10,14,16,21,23');
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'4,10,14,16,21,23');

         SetTLBlC;

         theme_map_blqtt:=0;
      end;
   end;
end;

{
theme #18TECH BASE
terrain 17-18
liquid  0-2,6,13-15
adecs   0,21,22,26,27,29,31,32
tdecs   19,22-27,29-32,35,37-41,110-112
brocks  9-12
srocks  13-19

theme #20TECH BASE
terrain 19
liquid  1,2,12,15
adecs   0-3,21,22,26,27,29,31,32,33
tdecs   19,22-27,29-32,35,37-41,110-112
brocks  9-12
srocks  13-19

theme PLANET
terrain 0,2-16,20-25
liquid  0-15
adecs   0-17,23-25
tdecs   0-12,18,28-29,36,110-112
brocks  1-4
srocks  1-8,20,21

theme PLANET MOON
terrain 0,2-4,8,10-13,20-23,25
liquid  0,4,6,8,9,11,14
adecs   0-8,17,13,23-25
tdecs   3,29-34
brocks  1-4
srocks  1-8,20,21

theme #17HELL
terrain 4,10,14,16,21,23
liquid  4,5,8-9,11
adecs   0-4,9,15,18-20,23-25,28,30,33,34
tdecs   3,13-17,20,21,36,100-105
brocks  1-4
srocks  1-8

theme #16HELL
terrain 1
liquid  4,5,8-9,11
adecs   0-4,9,15,18-20,23-25,28,30,33,34
tdecs   3,13-17,20,21,36,100-105
brocks  5-8,13,14
srocks  9-12

theme #16CAVES
terrain 0-4,8-16,20-25
liquid  0-14
adecs   0-20,23-25,28,30,33,34
tdecs   0-22,28,35,36,100-105,110-112
brocks  1-4,12
srocks  1-8,13,14,20,21


theme #20ICE CAVES
terrain 0,2,11-13,20,25
liquid  16
adecs   0-20,23-25,28,30,33,34
tdecs   0-23,28,35,36,100-105,110-112
brocks  1-4
srocks  1,2,5-8,20,21


}

