

function MakeReflectedSurface(sourceSurface:PSDL_Surface;xa,ya,transparent:boolean):PSDL_Surface;
var x,y,sx,sy:integer;
    c:cardinal;
begin
   MakeReflectedSurface:=gfx_SDLSurfaceCreate(sourceSurface^.w,sourceSurface^.h);
   for x:=1 to sourceSurface^.w do
    for y:=1 to sourceSurface^.h do
    begin
       if(xa)then sx:=sourceSurface^.w-x else sx:=x-1;
       if(ya)then sy:=sourceSurface^.h-y else sy:=y-1;
       c:=SDL_GETpixel(sourceSurface,x-1,y-1);

       SDL_SETpixel(MakeReflectedSurface,sx,sy,c);
    end;
   if(transparent)then SDL_SetColorKey(MakeReflectedSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(MakeReflectedSurface,0,0));
end;

procedure LoadTMWTextureList(MWTextureList:PTMWTextureList;MWTextureList_n:pinteger;fname:shortstring;addReflected:boolean);
var t:TMWTexture;
    i:integer;
procedure next;begin MWTextureList_n^+=1;setlength(MWTextureList^,MWTextureList_n^);MWTextureList^[MWTextureList_n^-1]:=t;end;
begin
   MWTextureList_n^:=0;
   i:=0;
   while true do
   begin
      with t do
      begin
         sdlSurface:=gfx_SDLSurfaceLoad(fname+i2s(i),false,false);
         if(sdlSurface=r_empty)then break;
         w :=sdlSurface^.w;
         h :=sdlSurface^.h;
         hw:=sdlSurface^.w div 2;
         hh:=sdlSurface^.h div 2;
      end;
      next;

      if(addReflected)then
      begin
         with t do sdlSurface:=MakeReflectedSurface(sdlSurface,true,false,false);
         next;
      end;

      i+=1;
   end;

   if(MWTextureList_n^=0)then
   begin
      t:=spr_dummy;
      next;
   end;
end;

procedure IntListAdd(intList:PTIntList;intListN:pinteger;value:integer);
begin
   intListN^+=1;
   setlength(intList^,intListN^);
   intList^[intListN^-1]:=value;
end;

procedure Str2IntList(intString:shortstring;intList:PTIntList;intListN:pinteger);
var p,l:integer;
    v,u:shortstring;
begin
   intListN^:=0;
   setlength(intList^,intListN^);

   l:=length(intString);
   while(l>0)do
   begin
      v:='';
      p:=pos(',',intString);
      if(p>0)then
      begin
         v:=copy(intString,1,p-1);
         delete(intString,1,p);
      end
      else
      begin
         v:=intString;
         delete(intString,1,l);
      end;

      while true do
      begin
         p:=pos(' ',v);
         if(p=0)
         then break
         else delete(v,p,1);
      end;

      if(length(v)>0)then
      begin
         p:=pos('_',v);
         if(p>0)then
         begin
            u:=copy(v,1,p-1);
            delete(v,1,p);
            if(length(u)>0)and(length(v)>0)then
            begin
               p:=s2i(u);
               l:=s2i(v);
               while (true) do
               begin
                  IntListAdd(intList,intListN,p);
                  if(p=l)
                  then break
                  else p+=sign(l-p);
               end;
            end;
         end
         else IntListAdd(intList,intListN,s2i(v));
      end;

      l:=length(intString);
   end;
end;

procedure gfx_MWTextureSetTransparent(spr:PTMWTexture;xa:boolean);
begin
   with spr^ do
    if(xa)
    then SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(sdlSurface,w-1,0))
    else SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(sdlSurface,0  ,0));
end;

procedure ThemeSetTransparent(SpriteList:pTMWTextureList;SpriteListN:integer;intString:shortstring);
var i,o,
intListN:integer;
intList :TIntList;
begin
   if(intString<>'all')then
   begin
      Str2IntList(intString,@intList,@intListN);

      if(intListN>0)then
        for i:=0 to intListN-1 do
        begin
           o:=intList[i]*2;
           if(o<SpriteListN)then
           begin
              gfx_MWTextureSetTransparent( @(SpriteList^[o  ]), ( o    mod 2)=1);
              gfx_MWTextureSetTransparent( @(SpriteList^[o+1]), ((o+1) mod 2)=1);
           end;
        end;
   end
   else
     if(SpriteListN>0)then
       for o:=0 to SpriteListN-1 do gfx_MWTextureSetTransparent( @(SpriteList^[o]), (o mod 2)=1 );
end;

{procedure DecAnim(l:PTThemeAnimL;it:pinteger;str:shortstring;_at,_an,_xo,_yo,_sh,_dp:integer);
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

procedure liqAnim(i:integer;r,g,b:byte;atp,animt:byte);
begin
   theme_clr_liquids[i]:=rgba2c(r,g,b,255);
   theme_anm_liquids[i]:=atp;
   theme_ant_liquids[i]:=animt;
end;

procedure LiquidAnims(i:integer;r,g,b:byte;atp,animt:byte);
begin
   liqAnim(i*2  ,r,g,b,atp,animt);
   liqAnim(i*2+1,r,g,b,atp,animt);
end;  }

procedure InitThemes;
var o:integer;
begin
   // load graph
   LoadTMWTextureList(@theme_all_decal_l  ,@theme_all_decal_n  ,str_f_map+'decals\adt'  ,true );
   LoadTMWTextureList(@theme_all_decor_l  ,@theme_all_decor_n  ,str_f_map+'decors\dec_' ,true );
   LoadTMWTextureList(@theme_all_srock_l  ,@theme_all_srock_n  ,str_f_map+'srocks\rocks',true );
   LoadTMWTextureList(@theme_all_brock_l  ,@theme_all_brock_n  ,str_f_map+'brocks\rockb',true );
   LoadTMWTextureList(@theme_all_terrain_l,@theme_all_terrain_n,str_f_map+'terrains\ter',false);

   // transparent

   ThemeSetTransparent(@theme_all_decal_l,theme_all_decal_n,'0_20,23_34');
   ThemeSetTransparent(@theme_all_decor_l,theme_all_decor_n,'all');
   ThemeSetTransparent(@theme_all_srock_l,theme_all_srock_n,'all');
   ThemeSetTransparent(@theme_all_brock_l,theme_all_brock_n,'all');
   {
   // animation and effects
   setlength(theme_anm_decors  ,theme_spr_decorn  );
   setlength(theme_anm_srocks  ,theme_spr_srockn  );
   setlength(theme_anm_brocks  ,theme_spr_brockn  );

   // shadow
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
   LiquidAnims(16, 100, 100, 100  , 2, 10);  // doom pl2 ice  }

   setlength(theme_all_terrain_mmcolor,theme_all_terrain_n);
   if(theme_all_terrain_n>0)then
     for o:=0 to theme_all_terrain_n-1 do
      theme_all_terrain_mmcolor[o]:=gfx_SDLSurfaceGetColor(theme_all_terrain_l[o].sdlSurface);
end;


procedure SetThemeList(intList:PTIntList;intListN:pinteger;smax:integer;addReflected:boolean;intString:shortstring);
var i,o,
 _iln:integer;
 _il :TIntList;
begin
   Str2IntList(intString,@_il,@_iln);

   intListN^:=0;
   setlength(intList^,intListN^);

   for i:=1 to _iln do
   begin
      o:=_il[i-1];
      if(o>=0)then
      begin
         if(addReflected)then
         begin
            o:=o*2;
            if(o<smax)then
            begin
               IntListAdd(intList,intListN,o  );
               IntListAdd(intList,intListN,o+1);
            end;
         end
         else
           if(o<smax)then IntListAdd(intList,intListN,o);
      end
      else IntListAdd(intList,intListN,o);
   end;
end;

{
theme_cur_decal_l,
theme_cur_decor_l,
theme_cur_srock_l,
theme_cur_brock_l,
theme_cur_crater_l,
theme_cur_liquid_l,
theme_cur_terrain_l   : TIntList;
theme_cur_decal_n,
theme_cur_decor_n,
theme_cur_srock_n,
theme_cur_brock_n,
theme_cur_crater_n,
theme_cur_liquid_n,
theme_cur_terrain_n   : integer;

theme_tile_terrain_id,
theme_tile_crater_id,
theme_tile_liquid_id
}

procedure SetTerrainIDs(new_terrain,new_crater,new_liquid:integer);
var t:integer;
begin
   if(theme_cur_terrain_n<=0)then theme_tile_terrain_id:=-1 else begin if(new_terrain<0)then t:=abs(new_terrain) mod theme_cur_terrain_n else t:=min2i(theme_cur_terrain_n-1,new_terrain);theme_tile_terrain_id:=theme_cur_terrain_l[t];end;
   if(theme_cur_crater_n <=0)then theme_tile_crater_id :=-1 else begin if(new_crater <0)then t:=abs(new_crater ) mod theme_cur_crater_n  else t:=min2i(theme_cur_crater_n -1,new_crater );theme_tile_crater_id :=theme_cur_crater_l [t];end;
   if(theme_cur_liquid_n <=0)then theme_tile_liquid_id :=-1 else begin if(new_liquid <0)then t:=abs(new_liquid ) mod theme_cur_liquid_n  else t:=min2i(theme_cur_liquid_n -1,new_liquid );theme_tile_liquid_id :=theme_cur_liquid_l [t];end;
end;

procedure SetTheme(new_theme:integer);
begin
   if(new_theme<0)or(new_theme>=theme_n)then new_theme:=abs(new_theme) mod theme_n;
   theme_cur:=new_theme;
   case theme_cur of
   0: begin  // TECH BASE
         SetThemeList(@theme_cur_terrain_l,@theme_cur_terrain_n,theme_all_terrain_n,false,'0,2,7,9,'           );
         SetThemeList(@theme_cur_crater_l ,@theme_cur_crater_n ,theme_all_terrain_n,false,'0,7,8,11,67'                   );
         SetThemeList(@theme_cur_liquid_l ,@theme_cur_liquid_n ,theme_all_terrain_n,false,'13,20,48,55,71,72'             );
         SetThemeList(@theme_cur_decal_l  ,@theme_cur_decal_n  ,theme_all_decal_n  ,true ,'-1_-4,1_3,21,22,26,27,29,31,32');
         SetThemeList(@theme_cur_srock_l  ,@theme_cur_srock_n  ,theme_all_srock_n  ,true ,'0'                         );
         SetThemeList(@theme_cur_brock_l  ,@theme_cur_brock_n  ,theme_all_brock_n  ,true ,'0'                          );
         SetThemeList(@theme_cur_decor_l  ,@theme_cur_decor_n  ,theme_all_decor_n  ,true ,'0' );

         theme_crater_tes:=tes_tech;
         //theme_liquid_style:=1;
         //theme_crater_style:=2;
      end;
   {1: begin  // TECH BLUE BASE
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
      end; }
   end;
end;



