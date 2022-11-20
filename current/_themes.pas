
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

procedure LPTUSpriteL(l:PTUSpriteList;str:shortstring;it:pinteger);
var t:TMWTexture;
    i:integer;
procedure next;begin it^+=1;setlength(l^,it^);l^[it^-1]:=t;end;
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

      i+=1;
   end;

   if(it^=0)then
   begin
      t:=spr_dummy;
      next;
   end;
end;

procedure IntListAdd(_il:PTIntList;_iln:pinteger;k:integer);
begin
   _iln^+=1;
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
                  else p+=sign(l-p);
               end;
            end;
         end
         else IntListAdd(_il,_iln,s2i(v));
      end;

      l:=length(s);
   end;
end;

procedure _SetTrans(spr:PTMWTexture;xa:boolean);
begin
   with spr^ do
    if(xa)
    then SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(surf,w-1,0))
    else SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(surf,0  ,0));
end;

procedure ThemeSetTrans(l:PTUSpriteList;it:pinteger;str:shortstring);
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
            _SetTrans( @(l^[o  ]), ( o    mod 2)=1);
            _SetTrans( @(l^[o+1]), ((o+1) mod 2)=1);
         end;
      end;
   end
   else
    for o:=1 to it^ do _SetTrans( @(l^[o-1]), ((o-1) mod 2)=1 );
end;

procedure DecAnim(l:PTThemeAnimL;it:pinteger;str:shortstring;_at,_an,_xo,_yo,_sh,_dp:integer);
var i,o,
 _iln:integer;
 _il :TIntList;
procedure _SetDecAnim(p:integer;xa:boolean);
begin
   with l^[p] do
   begin
      atime:=_at;
      if(xa)then
      begin
         anext:=_an*2+1;
         xo   :=-_xo;
      end
      else
      begin
         anext:=_an*2;
         xo   :=_xo;
      end;
      yo   :=_yo;
      sh   :=_sh;
      depth:=_dp;
   end;
end;
begin
   Str2IntList(str,@_il,@_iln);

   for i:=1 to _iln do
   begin
      o:=_il[i-1]*2;
      if(o<it^)then
      begin
         _SetDecAnim(o  ,false);
         _SetDecAnim(o+1,true );
      end;
   end;
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

   // transparent
   ThemeSetTrans(@theme_spr_decals,@theme_spr_decaln,'0_20,23_34');
   ThemeSetTrans(@theme_spr_decors,@theme_spr_decorn,'all');
   ThemeSetTrans(@theme_spr_srocks,@theme_spr_srockn,'all');
   ThemeSetTrans(@theme_spr_brocks,@theme_spr_brockn,'all');

   // animation and effects
   setlength(theme_anm_decors  ,theme_spr_decorn  );
   setlength(theme_anm_srocks  ,theme_spr_srockn  );
   setlength(theme_anm_brocks  ,theme_spr_brockn  );

   for o:=1 to theme_spr_decorn do begin FillChar(theme_anm_decors[o-1],SizeOf(theme_anm_decors[o-1]),0);with theme_anm_decors[o-1] do begin sh:=1;               end;end;
   for o:=1 to theme_spr_srockn do begin FillChar(theme_anm_srocks[o-1],SizeOf(theme_anm_srocks[o-1]),0);with theme_anm_srocks[o-1] do begin depth:=0;sh:=-32000; end;end;
   for o:=1 to theme_spr_brockn do begin FillChar(theme_anm_brocks[o-1],SizeOf(theme_anm_brocks[o-1]),0);with theme_anm_brocks[o-1] do begin depth:=0;sh:=-32000; end;end;

   //    DECORS
   //                                          ns         atm ana xo  yo   shadow  depth
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'13,35'   ,0  ,0  ,0  ,-3  ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'30,31,20,21'
                                                         ,0  ,0  ,0  ,-4  ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'15_17,39,41'
                                                         ,0  ,0  ,0  ,-5  ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'1,2,6,13'
                                                         ,0  ,0  ,0  ,-8  ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'24_27'   ,0  ,0  ,0  ,-8  ,-32000,0);

   DecAnim(@theme_anm_decors,@theme_spr_decorn,'34,36,29',0  ,0  ,0  ,-10 ,1      ,0);

   DecAnim(@theme_anm_decors,@theme_spr_decorn,'3'       ,0  ,0  ,0  ,-14 ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'7_12,18' ,0  ,0  ,0  ,-18 ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'5,11'    ,0  ,0  ,12 ,-18 ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'32'      ,0  ,0  ,0  ,-20 ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'19'      ,0  ,0  ,0  ,-21 ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'33'      ,0  ,0  ,5  ,-22 ,1      ,0);

   // Anims
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'14'      ,-1 ,51 ,0  , 0  ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'51'      ,-1 ,14 ,0  , 0  ,1      ,0);

   DecAnim(@theme_anm_decors,@theme_spr_decorn,'22'      ,-6 ,52 ,0  ,-9  ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'52'      ,-2 ,22 ,0  ,-9  ,1      ,0);

   DecAnim(@theme_anm_decors,@theme_spr_decorn,'23'      ,-5 ,53 ,0  ,-8  ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'53'      ,-2 ,23 ,0  ,-8  ,1      ,0);

   DecAnim(@theme_anm_decors,@theme_spr_decorn,'48'      ,15 ,49 ,4  ,-8  ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'49'      ,15 ,50 ,4  ,-8  ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'50'      ,15 ,48 ,4  ,-8  ,1      ,0);

   DecAnim(@theme_anm_decors,@theme_spr_decorn,'42'      ,15 ,43 ,0  ,-17 ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'43'      ,15 ,42 ,0  ,-17 ,1      ,0);

   DecAnim(@theme_anm_decors,@theme_spr_decorn,'44'      ,15 ,45 ,0  ,-17 ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'45'      ,15 ,44 ,0  ,-17 ,1      ,0);

   DecAnim(@theme_anm_decors,@theme_spr_decorn,'46'      ,15 ,47 ,0  ,-17 ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_spr_decorn,'47'      ,15 ,46 ,0  ,-17 ,1      ,0);


   // S ROCKS                                  ns         atm ana xo  yo   shadow  depth
   DecAnim(@theme_anm_srocks,@theme_spr_srockn,'3'       ,20 ,22 ,0  ,0   ,-32000 ,0); // rock with pool 1
   DecAnim(@theme_anm_srocks,@theme_spr_srockn,'22'      ,20 ,3  ,0  ,0   ,-32000 ,0);

   DecAnim(@theme_anm_srocks,@theme_spr_srockn,'4'       ,20 ,23 ,0  ,0   ,-32000 ,0); // rock with pool 2
   DecAnim(@theme_anm_srocks,@theme_spr_srockn,'23'      ,20 ,4  ,0  ,0   ,-32000 ,0);

   DecAnim(@theme_anm_srocks,@theme_spr_srockn,'9'       ,-1 ,24 ,0  ,0   ,-32000 ,0); // hell rocks 1
   DecAnim(@theme_anm_srocks,@theme_spr_srockn,'24'      ,-1 ,9  ,0  ,0   ,-32000 ,0);

   DecAnim(@theme_anm_srocks,@theme_spr_srockn,'10'      ,-1 ,25 ,0  ,0   ,-32000 ,0); // hell rocks 2
   DecAnim(@theme_anm_srocks,@theme_spr_srockn,'25'      ,-1 ,10 ,0  ,0   ,-32000 ,0);

   DecAnim(@theme_anm_srocks,@theme_spr_srockn,'11'      ,-1 ,26 ,0  ,0   ,-32000 ,0); // hell rocks 3
   DecAnim(@theme_anm_srocks,@theme_spr_srockn,'26'      ,-1 ,11 ,0  ,0   ,-32000 ,0);

   DecAnim(@theme_anm_srocks,@theme_spr_srockn,'12'      ,-1 ,0  ,0  ,0   ,-32000 ,0); // hell rocks 4
   DecAnim(@theme_anm_srocks,@theme_spr_srockn,'0'       ,-1 ,12 ,0  ,0   ,-32000 ,0);


   // B ROCKS                                  ns         atm ana xo  yo   shadow  depth
   DecAnim(@theme_anm_brocks,@theme_spr_brockn,'9'       ,-1 ,19 ,0  ,0   ,-32000 ,0); // tech slime canister
   DecAnim(@theme_anm_brocks,@theme_spr_brockn,'19'      ,-1 , 9 ,0  ,0   ,-32000 ,0);
   DecAnim(@theme_anm_brocks,@theme_spr_brockn,'11'      ,-1 ,20 ,0  ,0   ,-32000 ,0); // tech water canister
   DecAnim(@theme_anm_brocks,@theme_spr_brockn,'20'      ,-1 ,11 ,0  ,0   ,-32000 ,0);

   DecAnim(@theme_anm_brocks,@theme_spr_brockn,'5'       ,-1 ,15 ,0  ,0   ,-32000 ,0); // hell rocks 1
   DecAnim(@theme_anm_brocks,@theme_spr_brockn,'15'      ,-1 ,5  ,0  ,0   ,-32000 ,0);
   DecAnim(@theme_anm_brocks,@theme_spr_brockn,'6'       ,-1 ,16 ,0  ,0   ,-32000 ,0); // hell rocks 2
   DecAnim(@theme_anm_brocks,@theme_spr_brockn,'16'      ,-1 ,6  ,0  ,0   ,-32000 ,0);
   DecAnim(@theme_anm_brocks,@theme_spr_brockn,'7'       ,-1 ,17 ,0  ,0   ,-32000 ,0); // hell rocks 3
   DecAnim(@theme_anm_brocks,@theme_spr_brockn,'17'      ,-1 ,7  ,0  ,0   ,-32000 ,0);
   DecAnim(@theme_anm_brocks,@theme_spr_brockn,'8'       ,-1 ,18 ,0  ,0   ,-32000 ,0); // hell rocks 4
   DecAnim(@theme_anm_brocks,@theme_spr_brockn,'18'      ,-1 ,8  ,0  ,0   ,-32000 ,0);
   DecAnim(@theme_anm_brocks,@theme_spr_brockn,'13'      ,-1 ,21 ,0  ,0   ,-32000 ,0); // hell rocks 5
   DecAnim(@theme_anm_brocks,@theme_spr_brockn,'21'      ,-1 ,13 ,0  ,0   ,-32000 ,0);
   DecAnim(@theme_anm_brocks,@theme_spr_brockn,'14'      ,-1 ,0  ,0  ,0   ,-32000 ,0); // hell rocks 6
   DecAnim(@theme_anm_brocks,@theme_spr_brockn,'0'       ,-1 ,14 ,0  ,0   ,-32000 ,0);

   // liquids
   setlength(theme_anm_liquids ,theme_spr_liquidn );
   setlength(theme_ant_liquids ,theme_spr_liquidn );
   setlength(theme_clr_liquids ,theme_spr_liquidn );

   //              minimap color anim  anim     animstyle: 0=default; 1=1 frame + lava bliks; 2=static 1 frame
   //          n   R    G    B   style time
   LiquidAnims(0,  16 , 16 , 150  , 0, 30);  // doom water
   LiquidAnims(1,  10 , 150, 10   , 0, 30);  // doom slime
   LiquidAnims(2,  136, 68 , 32   , 0, 30);  // doom brown
   LiquidAnims(3,  136, 0  , 16   , 0, 30);  // doom blood
   LiquidAnims(4,  220, 100, 15   , 0, 30);  // doom lava
   LiquidAnims(5,  163, 82 , 82   , 1, 20);  // doom clifs
   LiquidAnims(6,  30 , 30 , 150  , 0, 15);  // heretic water
   LiquidAnims(7,  64 , 128, 128  , 0, 15);  // blood brown
   LiquidAnims(8,  210, 168, 0    , 0, 15);  // blood magma
   LiquidAnims(9,  160, 120, 15   , 1, 15);  // blood lava
   LiquidAnims(10, 140, 20 , 0    , 0, 15);  // blood blood
   LiquidAnims(11, 255, 180, 15   , 1, 15);  // heretic lava
   LiquidAnims(12, 0  , 128, 64   , 0, 15);  // blood slime
   LiquidAnims(13, 200, 82 , 0    , 0, 15);  // blood orange water
   LiquidAnims(14, 0  , 128, 192  , 0, 10);  // duke3d water
   LiquidAnims(15, 100, 180, 100  , 0, 10);  // duke3d slime
   LiquidAnims(16, 100, 100, 100  , 2, 10);  // doom pl2 ice
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
   if(theme_terrainn<=0)then theme_map_trt :=-1 else begin if(ter <0)then theme_map_trt :=abs(ter  mod theme_terrainn) else theme_map_trt :=min2(theme_terrainn-1,ter ); theme_map_trt :=theme_terrains[theme_map_trt  ];end;
   if(theme_bliquidn<=0)then theme_map_blqt:=-1 else begin if(bliq<0)then theme_map_blqt:=abs(bliq mod theme_bliquidn) else theme_map_blqt:=min2(theme_bliquidn-1,bliq); theme_map_blqt:=theme_bliquids[theme_map_blqt ];end;
   if(theme_cratern <=0)then theme_map_crt :=-1 else begin if(crt <0)then theme_map_crt :=abs(crt  mod theme_cratern ) else theme_map_crt :=min2(theme_cratern -1,crt ); theme_map_crt :=theme_craters [theme_map_crt  ];end;
   if(theme_liquidn <=0)then theme_map_lqt :=-1 else begin if(liq <0)then theme_map_lqt :=abs(liq  mod theme_liquidn ) else theme_map_lqt :=min2(theme_liquidn -1,liq ); theme_map_lqt :=theme_liquids [theme_map_lqt  ];end;
end;
begin
   if(i<0)or(i>=theme_n)then i:=abs(i) mod theme_n;
   theme_i:=i;
   case i of
   0: begin  // TECH BASE
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'-1_-4,1_3,21,22,26,27,29,31,32');
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'17,18'      );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'19,26'      );
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'17,18,19,26');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'0_2,6,13_15');
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_spr_srockn  ,'13_19'      );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_spr_brockn  ,'9_12'       );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_spr_decorn  ,'19,22_27,29_32,35,37_41,52_53');

         theme_liquid_style:=1;
         theme_crater_style:=2;
      end;
   1: begin  // TECH BLUE BASE
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'-1_-4,1_3,21,22,26,27,29,31,32');
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'19'         );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'17,18,26'   );
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'17,18,19,26');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'0_2,6,13_15');
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_spr_srockn  ,'13_19'      );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_spr_brockn  ,'9_12'       );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_spr_decorn  ,'19,22_27,29_32,35,37_41,52_53');

         theme_liquid_style:=1;
         theme_crater_style:=1;
      end;

   2: begin  // PLANET
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'-1_-4,1,4_17,23_25');
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'0,2_16,20_25'   );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'0,2_16,20_25,28');
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'0,2_16,20_25,28');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'0_15'           );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_spr_srockn  ,'1_8,20,21'      );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_spr_brockn  ,'1_4'            );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_spr_decorn  ,'0_12,18,28_29,36,48_50 ');

         theme_liquid_style:=0;
         theme_crater_style:=0;
      end;
   3: begin  // PLANET MOON
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'-1_-4,1,4_17,23_25'       );
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'0,2_4,8,10_13,20_23,25'   );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'0,2_4,8,10_13,20_23,25,28');
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'0,2_4,8,10_13,20_23,25,28');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'0,4,6,8,9,11,14'          );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_spr_srockn  ,'1_8,20,21'   );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_spr_brockn  ,'1_4'         );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_spr_decorn  ,'0_12,29_34 ' );

         theme_liquid_style:=0;
         theme_crater_style:=0;
      end;

   4: begin  // CAVES
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'-1_-4,1,4_20,23_25,28,30,33,34'   );
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'0_4,8_16,20_25'   );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'0_4,8_16,20_25,28_30');
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'0_4,8_16,20_25,28_30');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'0_14'             );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_spr_srockn  ,'1_8,13,14,20,21'  );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_spr_brockn  ,'1_4,12'           );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_spr_decorn  ,'0_22,28,35,36,42_47,48_50');

         theme_liquid_style:=0;
         theme_crater_style:=0;
      end;
   5: begin  // ICE CAVES
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'-1_-4,1_20,23_25,28,30,33,34');
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'0,2,11_13,20,25');
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'0,2,11_13,20,25,28');
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'0,2,11_13,20,25,28');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'16'             );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_spr_srockn  ,'1,2,5_8,20,21'  );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_spr_brockn  ,'1_4'            );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_spr_decorn  ,'0_23,28,35,36,42_47,48_50');

         theme_liquid_style:=0;
         theme_crater_style:=0;
      end;

   6: begin  // HELL
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'-1_-4,1,4,9,15,18_20,23_25,28,30,33,34');
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'1,27'                  );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'1,27'                  );
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'1,27'                  );
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'4,8_9,11'              );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_spr_srockn  ,'9_12'                  );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_spr_brockn  ,'5_8,13,14'             );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_spr_decorn  ,'3,13_17,20,21,36,42_47');

         theme_liquid_style:=0;
         theme_crater_style:=0;
      end;
   7: begin  // HELL CAVES
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'-1_-4,1,4,9,15,18_20,23_25,28,30,33,34');
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'4,10,14,16,21,23'      );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'4,10,14,16,21,23,29,30');
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'4,10,14,16,21,23,29,30');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'4,5,8_9,11'            );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_spr_srockn  ,'1_8'                   );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_spr_brockn  ,'1_4'                   );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_spr_decorn  ,'3,13_17,20,21,36,42_47');

         theme_liquid_style:=0;
         theme_crater_style:=0;
      end;
   end;
   SetTLBlC;
end;



