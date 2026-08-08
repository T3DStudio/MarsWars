
function gfx_FlipSurface(s:PSDL_Surface;xa,ya,trans:boolean):PSDL_Surface;
var x,y,sx,sy:integer;
    c:TMWColor;
begin
   gfx_FlipSurface:=gfx_CreateSDLSurface(s^.w,s^.h);
   for x:=1 to s^.w do
   for y:=1 to s^.h do
   begin
      if(xa)then sx:=s^.w-x else sx:=x-1;
      if(ya)then sy:=s^.h-y else sy:=y-1;
      c:=SDL_GETpixel(s,x-1,y-1);

      SDL_SETpixel(gfx_FlipSurface,sx,sy,c);
   end;
   if(trans)then SDL_SetColorKey(gfx_FlipSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(gfx_FlipSurface,0,0));
end;

procedure gfx_ThemeSetTransparent(spr:PTMWTexture;xa:boolean);
begin
   with spr^ do
     if(xa)
     then SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(surf,w-1,0))
     else SDL_SetColorKey(surf,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(surf,0  ,0));
end;

procedure theme_LoadSprites(l:PTUSpriteList;str:shortstring;it:pinteger);
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
         surf:=gfx_LoadSDLSurface(str+i2s(i),false,false);
         if(surf=spr_empty)then break;
         w   :=surf^.w;
         h   :=surf^.h;
         hw  :=surf^.w div 2;
         hh  :=surf^.h div 2;
      end;
      next;

      with t do
        surf:=gfx_FlipSurface(surf,true,false,false);
      next;

      i+=1;
   end;

   if(it^=0)then
   begin
      t:=spr_dummy;
      next;
   end;
end;

procedure IntListAdd(pList:pTIntList;pSize:pinteger;value:integer);
begin
   pSize^+=1;
   setlength(pList^,pSize^);
   pList^[pSize^-1]:=value;
end;

procedure Str2IntList(s:shortstring;pList:pTIntList;pSize:pinteger);
var p,l:integer;
    v,u:shortstring;
begin
   pSize^:=0;
   setlength(pList^,pSize^);

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
                  IntListAdd(pList,pSize,p);
                  if(p=l)
                  then break
                  else p+=sign(l-p);
               end;
            end;
         end
         else IntListAdd(pList,pSize,s2i(v));
      end;

      l:=length(s);
   end;
end;

procedure theme_SetTransparent(l:PTUSpriteList;it:pinteger;str:shortstring);
var i,o,
 tSize:integer;
 tList:TIntList;
begin
   if(str<>'all')then
   begin
      Str2IntList(str,@tList,@tSize);

      for i:=1 to tSize do
      begin
         o:=tList[i-1]*2;
         if(o<it^)then
         begin
            gfx_ThemeSetTransparent( @(l^[o  ]), ( o    mod 2)=1);
            gfx_ThemeSetTransparent( @(l^[o+1]), ((o+1) mod 2)=1);
         end;
      end;
   end
   else
    for o:=1 to it^ do gfx_ThemeSetTransparent( @(l^[o-1]), ((o-1) mod 2)=1 );
end;

procedure theme_SetObstaclesData(a_xo,a_yo,a_shadow,a_depth:integer;istr:shortstring);
var
i,o,
tSize:integer;
tList :TIntList;
procedure SetData(oid:integer;xa:boolean);
begin
   if(oid<0)or(theme_spr_obstaclesN<=oid)then   exit;

   with theme_obstacles_Anims[oid] do
   begin
      if(xa)then
      begin
         if(a_xo <>NOTSET)then toa_xo    :=-a_xo;
      end
      else
      begin
         if(a_xo <>NOTSET)then toa_xo    :=a_xo;
      end;
      if(a_yo    <>NOTSET)then toa_yo    :=a_yo;
      if(a_shadow<>NOTSET)then toa_shadow:=a_shadow;
      if(a_depth <>NOTSET)then toa_depth :=a_depth;
   end;
end;
begin
   if(theme_spr_obstaclesN<=0)then exit;

   if(istr<>'all')then
   begin
      Str2IntList(istr,@tList,@tSize);
      if(tSize>0)then
        for i:=1 to tSize do
        begin
           o:=tList[i-1]*2;
           SetData(o  ,false);
           SetData(o+1,true );
        end;
   end
   else
     for i:=0 to theme_spr_obstaclesN-1 do
       SetData(i,(i mod 2)=1);
end;

procedure theme_SetObstaclesAnim(a_atime:integer;istr:shortstring);
var
i,o1,o2,
tSize:integer;
tList:TIntList;
procedure SetNext(oid1,oid2:integer);
begin
   if(oid1<0)or(theme_spr_obstaclesN<=oid1)
   or(oid2<0)or(theme_spr_obstaclesN<=oid2)then exit;

   with theme_obstacles_Anims[oid1] do
   begin
      toa_anext:=oid2;
      toa_atime:=a_atime;
   end;
end;
begin
   Str2IntList(istr,@tList,@tSize);
   if(tSize>0)then
     for i:=0 to tSize-1 do
     begin
        o1:=tList[i              ]*2;
        o2:=tList[(i+1) mod tSize]*2;
        SetNext(o1  ,o2  );
        SetNext(o1+1,o2+1);
     end;
end;


procedure theme_SetLiquidAnims(i:integer;r,g,b:byte;animStyle:TThemeAnimStyle;animTime:byte);
procedure liqAnim(i:integer);
begin
   theme_liquids_MMColor  [i]:=gfx_TMWColor(r,g,b,255);
   theme_liquids_AnimStyle[i]:=animStyle;
   theme_liquids_AnimTime[i]:=animTime;
end;
begin
   liqAnim(i*2  );
   liqAnim(i*2+1);
end;

procedure InitThemes;
var o:integer;
begin
   theme_n:=9;

   setlength(str_themes,theme_n);

   // load graph
   theme_LoadSprites(@theme_spr_decalL    , folder_map+'decals\adt'     , @theme_spr_decalN    );
   theme_LoadSprites(@theme_spr_obstaclesL, folder_map+'obstacles\dec_' , @theme_spr_obstaclesN);
   theme_LoadSprites(@theme_spr_liquidL   , folder_map+'liquids\liquid_', @theme_spr_liquidN   );
   theme_LoadSprites(@theme_spr_terrainL  , folder_map+'terrains\ter'   , @theme_spr_terrainN  );

   // transparent
   theme_SetTransparent(@theme_spr_decalL    ,@theme_spr_decalN    ,'0_20,23_34');
   theme_SetTransparent(@theme_spr_obstaclesL,@theme_spr_obstaclesN,'all'       );

   // animation and effects
   setlength(theme_obstacles_Anims,theme_spr_obstaclesN);

   for o:=1 to theme_spr_obstaclesN do
   begin
      FillChar(theme_obstacles_Anims[o-1],SizeOf(TThemeObstacleAnim),0);
      with theme_obstacles_Anims[o-1] do toa_shadow:=1;
   end;

   //// OBSTACLES DATA

   // SHADOW                            SHADOW
   theme_SetObstaclesData(NOTSET,NOTSET,1     ,NOTSET,'0_53,125,126,131_134' );
   theme_SetObstaclesData(NOTSET,NOTSET,-32000,NOTSET,'24_27,54_124,127_130'  );

   // X Y offset          X      Y
   theme_SetObstaclesData(NOTSET,-3    ,NOTSET,NOTSET,'13,35'         );
   theme_SetObstaclesData(NOTSET,-4    ,NOTSET,NOTSET,'30,31,20,21'   );
   theme_SetObstaclesData(NOTSET,-5    ,NOTSET,NOTSET,'15_17,39,41'   );
   theme_SetObstaclesData(NOTSET,-5    ,NOTSET,NOTSET,'15_17,39,41'   );
   theme_SetObstaclesData(NOTSET,-8    ,NOTSET,NOTSET,'1,2,6,13,24_27');
   theme_SetObstaclesData(NOTSET,-10   ,NOTSET,NOTSET,'34,36,29'      );
   theme_SetObstaclesData(NOTSET,-14   ,NOTSET,NOTSET,'3'             );
   theme_SetObstaclesData(NOTSET,-18   ,NOTSET,NOTSET,'7_12,18'       );
   theme_SetObstaclesData(12    ,-18   ,NOTSET,NOTSET,'5,11'          );

   theme_SetObstaclesData(NOTSET,-20   ,NOTSET,NOTSET,'32'            );
   theme_SetObstaclesData(NOTSET,-21   ,NOTSET,NOTSET,'19'            );
   theme_SetObstaclesData(5     ,-22   ,NOTSET,NOTSET,'33'            );

   theme_SetObstaclesData(5     ,-22   ,NOTSET,NOTSET,'33'            );

   theme_SetObstaclesData(NOTSET,-9    ,NOTSET,NOTSET,'52,22'         );
   theme_SetObstaclesData(NOTSET,-8    ,NOTSET,NOTSET,'53,23'         );
   theme_SetObstaclesData(4     ,-8    ,NOTSET,NOTSET,'48_50'         );
   theme_SetObstaclesData(0     ,-17   ,NOTSET,NOTSET,'42_47'         );
   theme_SetObstaclesData(NOTSET,-32   ,NOTSET,NOTSET,'126'           );

   theme_SetObstaclesData(-4    ,-44   ,NOTSET,NOTSET,'131'           );
   theme_SetObstaclesData(NOTSET,-24   ,NOTSET,NOTSET,'132'           );
   theme_SetObstaclesData(NOTSET,-8    ,NOTSET,NOTSET,'133'           );
   theme_SetObstaclesData(NOTSET,-10   ,NOTSET,NOTSET,'134'           );

   // DEPTH
   theme_SetObstaclesData(NOTSET,NOTSET,NOTSET,sd_ground    ,'all' );
   theme_SetObstaclesData(NOTSET,NOTSET,NOTSET,sd_Obstacles2,'54_75,117_124,127_130' );
   theme_SetObstaclesData(NOTSET,NOTSET,NOTSET,sd_Obstacles1,'76_105,107_116');


   //// OBSTACLES ANIM
   theme_SetObstaclesAnim(-1  ,'51,14');
   theme_SetObstaclesAnim(-6  ,'52,22');
   theme_SetObstaclesAnim(-5  ,'53,23');
   theme_SetObstaclesAnim(15  ,'48_50');
   theme_SetObstaclesAnim(15  ,'43,42');
   theme_SetObstaclesAnim(15  ,'44,45');
   theme_SetObstaclesAnim(15  ,'46,47');

   theme_SetObstaclesAnim(20  ,'76,80');
   theme_SetObstaclesAnim(20  ,'78,94');
   theme_SetObstaclesAnim(20  ,'79,95');
   theme_SetObstaclesAnim(20  ,'91,96');
   theme_SetObstaclesAnim(20  ,'92,97');
   theme_SetObstaclesAnim(20  ,'93,102');
   theme_SetObstaclesAnim(20  ,'114,115');
   theme_SetObstaclesAnim(20  ,'113,116');

   theme_SetObstaclesAnim(20  ,'54,60');
   theme_SetObstaclesAnim(20  ,'57,67');
   theme_SetObstaclesAnim(20  ,'59,68');
   theme_SetObstaclesAnim(20  ,'61,71');
   theme_SetObstaclesAnim(20  ,'62,72');
   theme_SetObstaclesAnim(20  ,'63,73');
   theme_SetObstaclesAnim(20  ,'64,74');
   theme_SetObstaclesAnim(20  ,'65,75');

   // liquids
   setlength(theme_liquids_AnimStyle,theme_spr_liquidN);
   setlength(theme_liquids_AnimTime ,theme_spr_liquidN);
   setlength(theme_liquids_MMColor  ,theme_spr_liquidN);

   //                       minimap color    anim        anim
   //                   n   R    G    B      style       time
   theme_SetLiquidAnims(0,  16 , 16 , 150  , tas_liquid, 30);  // doom water
   theme_SetLiquidAnims(1,  10 , 150, 10   , tas_liquid, 30);  // doom slime
   theme_SetLiquidAnims(2,  136, 68 , 32   , tas_liquid, 30);  // doom brown
   theme_SetLiquidAnims(3,  136, 0  , 16   , tas_liquid, 30);  // doom blood
   theme_SetLiquidAnims(4,  220, 100, 15   , tas_liquid, 30);  // doom lava
   theme_SetLiquidAnims(5,  163, 82 , 82   , tas_magma , 20);  // doom clifs
   theme_SetLiquidAnims(6,  30 , 30 , 150  , tas_liquid, 15);  // heretic water
   theme_SetLiquidAnims(7,  64 , 128, 128  , tas_liquid, 15);  // blood brown
   theme_SetLiquidAnims(8,  210, 168, 0    , tas_liquid, 15);  // blood magma
   theme_SetLiquidAnims(9,  160, 120, 15   , tas_magma , 15);  // blood lava
   theme_SetLiquidAnims(10, 140, 20 , 0    , tas_liquid, 15);  // blood blood
   theme_SetLiquidAnims(11, 255, 180, 15   , tas_magma , 15);  // heretic lava
   theme_SetLiquidAnims(12, 0  , 128, 64   , tas_liquid, 15);  // blood slime
   theme_SetLiquidAnims(13, 200, 82 , 0    , tas_liquid, 15);  // blood orange water
   theme_SetLiquidAnims(14, 0  , 128, 192  , tas_liquid, 10);  // duke3d water
   theme_SetLiquidAnims(15, 100, 180, 100  , tas_liquid, 10);  // duke3d slime
   theme_SetLiquidAnims(16, 100, 100, 100  , tas_noanim, 10);  // doom pl2 ice
   theme_SetLiquidAnims(17, 255, 60 , 60   , tas_magma , 30);  // doom static red lava
   theme_SetLiquidAnims(18, 222, 222, 100  , tas_magma , 35);  // doom static yellow lava
   theme_SetLiquidAnims(19, 222,   0, 222  , tas_magma , 35);  // doom fireblue
   theme_SetLiquidAnims(20,  80,  80,  80  , tas_noanim, 10);  // doom pl2 black ice
end;

procedure SetThemeList(pList:pTIntList;pSize,pMax:pinteger;str:shortstring);
var
i,o,
tSize:integer;
tList:TIntList;
begin
   Str2IntList(str,@tList,@tSize);

   pSize^:=0;
   setlength(pList^,pSize^);

   if(tSize>0)then
     for i:=1 to tSize do
     begin
        o:=tList[i-1];
        if(o>=0)then
        begin
           o:=o*2;
           if(o<pMax^)then
           begin
              IntListAdd(pList,pSize,o  );
              IntListAdd(pList,pSize,o+1);
           end;
        end
        else IntListAdd(pList,pSize,o);
     end;
end;

procedure SetThemeDecals  (istr:shortstring);begin SetThemeList(@theme_decalL      ,@theme_decalN      ,@theme_spr_decalN    ,istr);end;
procedure SetThemeCraters (istr:shortstring);begin SetThemeList(@theme_craterL     ,@theme_craterN     ,@theme_spr_terrainN  ,istr);end;
procedure SetThemeTerrains(istr:shortstring);begin SetThemeList(@theme_terrainL    ,@theme_terrainN    ,@theme_spr_terrainN  ,istr);end;
procedure SetThemeLiquidsB(istr:shortstring);begin SetThemeList(@theme_liquidBackL ,@theme_liquidBackN ,@theme_spr_terrainN  ,istr);end;
procedure SetThemeLiquidsF(istr:shortstring);begin SetThemeList(@theme_liquidFrontL,@theme_liquidFrontN,@theme_spr_liquidN   ,istr);end;
procedure SetThemeObs0    (istr:shortstring);begin SetThemeList(@theme_obstacle0L  ,@theme_obstacle0N  ,@theme_spr_obstaclesN,istr);end;
procedure SetThemeObs1    (istr:shortstring);begin SetThemeList(@theme_obstacle1L  ,@theme_obstacle1N  ,@theme_spr_obstaclesN,istr);end;
procedure SetThemeObs2    (istr:shortstring);begin SetThemeList(@theme_obstacle2L  ,@theme_obstacle2N  ,@theme_spr_obstaclesN,istr);end;

procedure SetTheme(nTheme,nTerrain,nLiquidFront,nLiquidBack,nCrater:integer);
procedure SetTLBlC;
begin
   if(theme_craterN     <=0)then theme_map_Crater     :=-1 else begin if(nCrater     <0)then theme_map_Crater     :=abs(nCrater      mod theme_craterN     ) else theme_map_Crater     :=min2i(theme_craterN     -1,nCrater     ); theme_map_Crater     :=theme_craterL     [theme_map_Crater     ];end;
   if(theme_terrainN    <=0)then theme_map_Terrain    :=-1 else begin if(nTerrain    <0)then theme_map_Terrain    :=abs(nTerrain     mod theme_terrainN    ) else theme_map_Terrain    :=min2i(theme_terrainN    -1,nTerrain    ); theme_map_Terrain    :=theme_terrainL    [theme_map_Terrain    ];end;
   if(theme_liquidBackN <=0)then theme_map_LiquidBack :=-1 else begin if(nLiquidBack <0)then theme_map_LiquidBack :=abs(nLiquidBack  mod theme_liquidBackN ) else theme_map_LiquidBack :=min2i(theme_liquidBackN -1,nLiquidBack ); theme_map_LiquidBack :=theme_liquidBackL [theme_map_LiquidBack ];end;
   if(theme_liquidFrontN<=0)then theme_map_LiquidFront:=-1 else begin if(nLiquidFront<0)then theme_map_LiquidFront:=abs(nLiquidFront mod theme_liquidFrontN) else theme_map_LiquidFront:=min2i(theme_liquidFrontN-1,nLiquidFront); theme_map_LiquidFront:=theme_liquidFrontL[theme_map_LiquidFront];end;
end;
begin
   if(nTheme<0)or(nTheme>=theme_n)then nTheme:=abs(nTheme) mod theme_n;
   theme_i:=nTheme;
   case theme_i of
   0 : begin  // UAC BASE
          SetThemeTerrains('17,18,19'   );
          SetThemeCraters ('17,18,19,26');
          SetThemeLiquidsB('26'         );
          SetThemeLiquidsF('7,12,13,15');
          SetThemeDecals  ('-3,-3,-3,21,22,26,27,29,31,32');
          SetThemeObs0    ('19,22_27,35,37_41');
          SetThemeObs1    ('81_87');
          SetThemeObs2    ('56_58,65,67,75');

          theme_liquid_style:=tcs_smooth;
          theme_crater_style:=tcs_square;
       end;
   1 : begin  // ICE CAVE
          SetThemeTerrains('13,20');
          SetThemeCraters ('12,28');
          SetThemeLiquidsB('12,28');
          SetThemeLiquidsF('20');
          SetThemeDecals  ('-4_-1,1,4_8,13,15,17,23_25');
          SetThemeObs0    ('3,4,8,28,36,48,10,125');
          SetThemeObs1    ('77,88_90');
          SetThemeObs2    ('55,66,69,70');

          theme_liquid_style:=tcs_default;
          theme_crater_style:=tcs_default;
       end;
   2 : begin  // HELL CAVES
          SetThemeTerrains('1,10,16,21,23' );
          SetThemeCraters ('29,30,35,27'   );
          SetThemeLiquidsB('14,35,27');
          SetThemeLiquidsF('4,8,9,11');
          SetThemeDecals  ('-4_-3,-4_-3,8,10_20,23_25,28');
          SetThemeObs0    ('14,15,17,42_47');
          SetThemeObs1    ('76,78_80,93_95,102,113_116');
          SetThemeObs2    ('54,59_64,68,71_74');

          theme_liquid_style:=tcs_default;
          theme_crater_style:=tcs_default;
       end;
   3 : begin  // HELL CITY
          SetThemeTerrains('31_34');
          SetThemeCraters ('31_35');
          SetThemeLiquidsB('31_35');
          SetThemeLiquidsF('5,17,18');
          SetThemeDecals  ('-4,-4,-4,-4,-4,1_3,18_20,30,33,34');
          SetThemeObs0    ('13,16,20,21,106,112');
          SetThemeObs1    ('103_105,107_111');
          SetThemeObs2    ('117_120');

          theme_liquid_style:=tcs_smooth;
          theme_crater_style:=tcs_square;
       end;
   4 : begin  // EARTH CITY
          SetThemeTerrains('6,7,15'  );
          SetThemeCraters ('17,18');
          SetThemeLiquidsB('17,18,26');
          SetThemeLiquidsF('6,14');
          SetThemeDecals  ('-4,-4,-4,21,22');
          SetThemeObs0    ('22,23,22,23,24_27,31,32,131_134,131_134,131_134,131_134,131_134,131_134');
          SetThemeObs1    ('83_85,81_82,127,129');
          SetThemeObs2    ('121_124,58');

          theme_liquid_style:=tcs_smooth;
          theme_crater_style:=tcs_square;
       end;
   5 : begin  // EARTH MOON
          SetThemeTerrains('12,25');
          SetThemeCraters ('20,2' );
          SetThemeLiquidsB('12,25');
          SetThemeLiquidsF('16');
          SetThemeDecals  ('-4_-1,8,13,23_25,4_7');
          SetThemeObs0    ('3,125,3,125,3,125,3,125,3,125,29_32' );
          SetThemeObs1    ('33,34,126,77,88_90,77,88_90,77,88_90');
          SetThemeObs2    ('55,66');

          theme_liquid_style:=tcs_default;
          theme_crater_style:=tcs_default;
       end;
   6 : begin  // MARS
          SetThemeTerrains('8,9,22,24' );
          SetThemeCraters ('14,16,21');
          SetThemeLiquidsB('4,10');
          SetThemeLiquidsF('3,10');
          SetThemeDecals  ('-4_-1,0,10_12,14,16,17');
          SetThemeObs0    ('0_12,18,28,125' );
          SetThemeObs1    ('128,91_92,96_101,91_92,96_101,96_101' );
          SetThemeObs2    ('69,70,69,70,69,70,123');

          theme_liquid_style:=tcs_default;
          theme_crater_style:=tcs_default;
       end;
   7 : begin  // PHOBOS
          SetThemeTerrains('3,4,5,14');
          SetThemeCraters ('8,9,22'  );
          SetThemeLiquidsB('14,16,21');
          SetThemeLiquidsF('0,2');
          SetThemeDecals  ('-4_-1,-4_-1,-1,-1,0,10_12,14,16,17');
          SetThemeObs0    ('0_12,18,28,125,0_12,18,28,125,29_32' );
          SetThemeObs1    ('130,91_92,96_101,91_92,96_101,96_101' );
          SetThemeObs2    ('69,70,69,70,69,70,122');

          theme_liquid_style:=tcs_default;
          theme_crater_style:=tcs_default;
       end;
   8 : begin  // DEIMOS
          SetThemeTerrains('0,2,11' );
          SetThemeCraters ('13,20'  );
          SetThemeLiquidsB('2,12,13');
          SetThemeLiquidsF('1');
          SetThemeDecals  ('-4_-1,0,10_12,14,16,17');
          SetThemeObs0    ('1,3,4,8,10,18,125,1,3,4,8,10,18,125,21,24_31,106');
          SetThemeObs1    ('103_105,107_108,91_92,96_101,91_92,96_101,96_101,91_92,96_101,91_92,96_101,96_101');
          SetThemeObs2    ('55,66,55,66,55,66,55,66,55,66,55,66,117,118');

          theme_liquid_style:=tcs_default;
          theme_crater_style:=tcs_default;
       end;
   end;
   theme_map_RBattleFront:=38;
   SetTLBlC;
end;

procedure SetThemeCampaign(campaign,mission:byte);
begin
   case campaign of
   0 : case mission of  // CAMPAINGS:  HELL
       0 : begin
              SetThemeDecals  ('-1_-4,1,4,9,15,18_20,23_25,28,30,33,34');
              SetThemeObs0    ('0_12,14,16,18,20,21,28,106,112');
              SetThemeObs1    ('98_101,103_105,107,108');
              SetThemeObs2    ('55,69,70'              );

              theme_liquid_style:=tcs_default;
              theme_crater_style:=tcs_default;

              SetThemeTerrains('23');
              SetThemeLiquidsB('1' );
              SetThemeCraters ('27');
              SetThemeLiquidsF('4' );
           end;
       1 : begin
              SetThemeDecals  ('-1_-4,1,4,9,15,18_20,23_25,28,30,33,34');
              SetThemeObs0    ('0_12,14,16,18,20,21,28,106,112,42_47,51,36');
              SetThemeObs1    ('98_101,103_105,107_111,113_116');
              SetThemeObs2    ('55,69,70,117_118'              );

              theme_liquid_style:=tcs_default;
              theme_crater_style:=tcs_default;

              SetThemeTerrains('16');
              SetThemeLiquidsB('14' );
              SetThemeCraters ('29');
              SetThemeLiquidsF('9' );

              theme_map_RBattleFront:=8;
           end;
       end;
   end;

   theme_map_Terrain    :=theme_terrainL    [0];
   theme_map_LiquidBack :=theme_liquidBackL [0];
   theme_map_Crater     :=theme_craterL     [0];
   theme_map_LiquidFront:=theme_liquidFrontL[0];
end;


